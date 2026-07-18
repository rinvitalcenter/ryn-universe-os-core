import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/domain/tarot_backup_manifest.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_restore_candidate_validator.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../support/tarot_backup_recovery_fixture.dart';

void main() {
  late TarotBackupRecoveryFixture fixture;

  tearDown(() async {
    await fixture.dispose();
  });

  Future<Directory> candidate() async {
    fixture = await TarotBackupRecoveryFixture.create();
    return fixture.createRestoreCandidate();
  }

  TarotRestoreCandidateValidator validator({
    Future<bool> Function(String)? inspectPath,
    List<String> protectedRootPaths = const <String>[],
  }) => TarotRestoreCandidateValidator(
    inspectPath: inspectPath ?? (_) async => true,
    protectedRootPaths: protectedRootPaths,
  );

  Future<void> expectFailure(
    Directory package,
    String code, {
    TarotRestoreCandidateValidator? using,
  }) async {
    await expectLater(
      (using ?? validator()).validate(package.path),
      throwsA(
        isA<TarotRestoreCandidateValidationException>().having(
          (error) => error.code,
          'code',
          code,
        ),
      ),
    );
  }

  test('valid candidate returns immutable restore metadata', () async {
    final package = await candidate();

    final result = await validator().validate(package.path);

    expect(result.packagePath, package.absolute.path);
    expect(
      result.snapshotPath,
      File(
        '${package.absolute.path}${Platform.pathSeparator}'
        '${TarotBackupManifest.databasePayloadFilename.replaceAll('/', Platform.pathSeparator)}',
      ).absolute.path,
    );
    expect(result.createdAtUtc, DateTime.utc(2026, 7, 17, 1, 2, 3));
    expect(result.operationId, 'a1b2c3d4');
    expect(result.backupFormatVersion, TarotBackupManifest.backupFormatVersion);
    expect(result.schemaVersion, TarotBackupManifest.schemaVersion);
    expect(result.snapshotSha256, hasLength(64));
    expect(result.snapshotSizeBytes, greaterThan(0));
  });

  test('missing manifest fails', () async {
    final package = await candidate();
    await File('${package.path}/manifest.json').delete();
    await expectFailure(package, 'required_component_missing');
  });

  test('missing snapshot fails', () async {
    final package = await candidate();
    await File(
      '${package.path}/${TarotBackupManifest.databasePayloadFilename}',
    ).delete();
    await expectFailure(package, 'required_component_missing');
  });

  test('missing checksum file fails', () async {
    final package = await candidate();
    await File(
      '${package.path}/${TarotBackupManifest.checksumFilename}',
    ).delete();
    await expectFailure(package, 'required_component_missing');
  });

  test('invalid manifest JSON fails', () async {
    final package = await candidate();
    await File('${package.path}/manifest.json').writeAsString('{');
    await expectFailure(package, 'manifest_invalid');
  });

  test('non-canonical manifest fails', () async {
    final package = await candidate();
    final manifest = File('${package.path}/manifest.json');
    final decoded = jsonDecode(await manifest.readAsString());
    await manifest.writeAsString(
      const JsonEncoder.withIndent('  ').convert(decoded),
    );
    await expectFailure(package, 'manifest_invalid');
  });

  test('unsupported backup format version fails', () async {
    final package = await candidate();
    await _changeManifestField(package, 'backupFormatVersion', 2);
    await expectFailure(package, 'manifest_invalid');
  });

  test('wrong snapshot filename fails', () async {
    final package = await candidate();
    await _changeManifestField(
      package,
      'databasePayloadFilename',
      'data/wrong.sqlite',
    );
    await expectFailure(package, 'manifest_invalid');
  });

  test('malformed checksum file fails', () async {
    final package = await candidate();
    await File(
      '${package.path}/${TarotBackupManifest.checksumFilename}',
    ).writeAsString('not-a-checksum');
    await expectFailure(package, 'checksum_invalid');
  });

  test('manifest and checksum digest mismatch fails', () async {
    final package = await candidate();
    final checksum = File(
      '${package.path}/${TarotBackupManifest.checksumFilename}',
    );
    final lines = (await checksum.readAsString()).split('\n');
    await checksum.writeAsString(
      '${lines.first}\n${'0' * 64}  '
      '${TarotBackupManifest.databasePayloadFilename}',
    );
    await expectFailure(package, 'checksum_mismatch');
  });

  test('snapshot tampering fails', () async {
    final package = await candidate();
    await File(
      '${package.path}/${TarotBackupManifest.databasePayloadFilename}',
    ).writeAsBytes(<int>[1], mode: FileMode.append);
    await expectFailure(package, 'checksum_mismatch');
  });

  test('invalid SQLite file fails', () async {
    final package = await candidate();
    await File(
      '${package.path}/${TarotBackupManifest.databasePayloadFilename}',
    ).writeAsString('not sqlite');
    await fixture.refreshRestoreCandidateIntegrity(package);
    await expectFailure(package, 'snapshot_invalid');
  });

  test('schema version mismatch fails', () async {
    final package = await candidate();
    await _mutateSnapshot(package, (database) => database.userVersion = 999);
    await fixture.refreshRestoreCandidateIntegrity(package);
    await expectFailure(package, 'snapshot_invalid');
  });

  test('missing required table fails', () async {
    final package = await candidate();
    await _mutateSnapshot(
      package,
      (database) => database.execute('DROP TABLE app_settings'),
    );
    await fixture.refreshRestoreCandidateIntegrity(package);
    await expectFailure(package, 'snapshot_invalid');
  });

  test('unexpected column fails', () async {
    final package = await candidate();
    await _mutateSnapshot(
      package,
      (database) => database.execute(
        'ALTER TABLE app_settings ADD COLUMN unexpected TEXT',
      ),
    );
    await fixture.refreshRestoreCandidateIntegrity(package);
    await expectFailure(package, 'snapshot_invalid');
  });

  test('candidate root symlink junction or reparse evidence fails', () async {
    final package = await candidate();
    await expectFailure(
      package,
      'unsafe_path',
      using: validator(
        inspectPath: (path) async => path != package.absolute.path,
      ),
    );
  });

  test('nested required file symlink or reparse evidence fails', () async {
    final package = await candidate();
    await expectFailure(
      package,
      'unsafe_path',
      using: validator(
        inspectPath: (path) async =>
            !path.replaceAll('\\', '/').endsWith('/manifest.json'),
      ),
    );
  });

  test('nonzero WAL SHM or journal sidecar fails', () async {
    final package = await candidate();
    await File(
      '${package.path}/${TarotBackupManifest.databasePayloadFilename}-wal',
    ).writeAsBytes(<int>[1]);
    await expectFailure(package, 'unexpected_package_structure');
  });

  test('candidate validation performs no write', () async {
    final package = await candidate();
    final before = await _treeBytes(package);

    await validator().validate(package.path);

    expect(await _treeBytes(package), before);
  });

  test('protected paths are rejected before filesystem inspection', () async {
    final package = await candidate();
    final inspected = <String>[];

    await expectFailure(
      package,
      'protected_path',
      using: validator(
        protectedRootPaths: <String>[package.path],
        inspectPath: (path) async {
          inspected.add(path);
          return true;
        },
      ),
    );

    expect(inspected, isEmpty);
  });
}

Future<void> _changeManifestField(
  Directory package,
  String key,
  Object value,
) async {
  final file = File('${package.path}/manifest.json');
  final decoded = jsonDecode(await file.readAsString()) as Map<String, Object?>;
  decoded[key] = value;
  await file.writeAsString(jsonEncode(decoded));
}

Future<void> _mutateSnapshot(
  Directory package,
  void Function(Database database) mutate,
) async {
  final database = sqlite3.open(
    '${package.path}/${TarotBackupManifest.databasePayloadFilename}',
  );
  try {
    mutate(database);
  } finally {
    database.close();
  }
}

Future<Map<String, List<int>>> _treeBytes(Directory root) async {
  final result = <String, List<int>>{};
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (FileSystemEntity.typeSync(entity.path, followLinks: false) ==
        FileSystemEntityType.file) {
      final relative = entity.path
          .substring(root.path.length + 1)
          .replaceAll('\\', '/');
      result[relative] = await File(entity.path).readAsBytes();
    }
  }
  return result;
}
