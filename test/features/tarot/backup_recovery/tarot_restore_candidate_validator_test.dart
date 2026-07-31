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

  for (final schemaVersion in <int>[6, 7, 8, 9, 10]) {
    test(
      'valid schema v$schemaVersion candidate is accepted for staging',
      () async {
        fixture = await TarotBackupRecoveryFixture.create();
        final package = await fixture.createRestoreCandidate(
          schemaVersion: schemaVersion,
        );

        final result = await validator().validate(package.path);

        expect(result.schemaVersion, schemaVersion);
      },
    );
  }

  test('schema v5 is rejected with a typed compatibility failure', () async {
    final package = await candidate();
    await _changeManifestField(package, 'schemaVersion', 5);

    await expectFailure(package, 'unsupported_schema_version');
  });

  test('schema v12 is rejected before snapshot inspection', () async {
    final package = await candidate();
    await _changeManifestField(package, 'schemaVersion', 12);

    await expectFailure(package, 'unsupported_future_schema');
  });

  test('DB-only restore rejects Qigong managed media inventory', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final database = fixture.openSource();
    database.execute(
      '''INSERT INTO qigong_media_assets (
        id, sha256, managed_relative_path, original_file_name,
        mime_type, byte_size, caption, alt_text, created_at_utc_us
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      <Object?>[
        'qigong-media.synthetic.01',
        'a' * 64,
        'qigong_media/aa/asset.bin',
        'asset.bin',
        'application/octet-stream',
        1,
        '',
        '',
        DateTime.utc(2026, 7, 17).microsecondsSinceEpoch,
      ],
    );
    fixture.release(database);
    final package = await fixture.createRestoreCandidate();

    await expectFailure(package, 'qigong_complete_backup_required');
  });

  test('v8 orphan Person link is rejected', () async {
    final package = await candidate();
    await _mutateSnapshot(package, (database) {
      database.execute('PRAGMA foreign_keys = OFF');
      database.execute(
        "UPDATE tarot_readings SET person_id = 'person.missing'",
      );
    });
    await fixture.refreshRestoreCandidateIntegrity(package);

    await expectFailure(package, 'snapshot_invalid');
  });

  test('v8 missing Person FK is rejected', () async {
    fixture = await TarotBackupRecoveryFixture.create(validReading: false);
    final package = await fixture.createRestoreCandidate();
    await _mutateSnapshot(package, (database) {
      database.execute('DROP TABLE tarot_readings');
      database.execute(
        _tarotReadingsWithPersonFk('RESTRICT').replaceFirst(
          ' REFERENCES persons(id) ON UPDATE NO ACTION ON DELETE RESTRICT',
          '',
        ),
      );
    });
    await fixture.refreshRestoreCandidateIntegrity(package);

    await expectFailure(package, 'snapshot_invalid');
  });

  test('v8 missing person_id column is rejected', () async {
    fixture = await TarotBackupRecoveryFixture.create(validReading: false);
    final package = await fixture.createRestoreCandidate();
    await _mutateSnapshot(package, (database) {
      database.execute('DROP TABLE tarot_readings');
      database.execute(
        _tarotReadingsWithPersonFk('RESTRICT').replaceFirst(
          '  person_id TEXT NULL REFERENCES persons(id) ON UPDATE NO ACTION ON DELETE RESTRICT,\n',
          '',
        ),
      );
    });
    await fixture.refreshRestoreCandidateIntegrity(package);

    await expectFailure(package, 'snapshot_invalid');
  });

  for (final action in <String>['CASCADE', 'SET NULL']) {
    test('v8 $action Person FK contract is rejected', () async {
      fixture = await TarotBackupRecoveryFixture.create(validReading: false);
      final package = await fixture.createRestoreCandidate();
      await _mutateSnapshot(package, (database) {
        database.execute('DROP TABLE tarot_readings');
        database.execute(_tarotReadingsWithPersonFk(action));
      });
      await fixture.refreshRestoreCandidateIntegrity(package);

      await expectFailure(package, 'snapshot_invalid');
    });
  }

  for (final action in <String>['CASCADE', 'SET NULL']) {
    test('v8 ON UPDATE $action Person FK contract is rejected', () async {
      fixture = await TarotBackupRecoveryFixture.create(validReading: false);
      final package = await fixture.createRestoreCandidate();
      await _mutateSnapshot(package, (database) {
        database.execute('DROP TABLE tarot_readings');
        database.execute(
          _tarotReadingsWithPersonFk('RESTRICT', updateAction: action),
        );
      });
      await fixture.refreshRestoreCandidateIntegrity(package);

      await expectFailure(package, 'snapshot_invalid');
    });
  }

  test('v8 duplicate canonical Person FK is rejected', () async {
    fixture = await TarotBackupRecoveryFixture.create(validReading: false);
    final package = await fixture.createRestoreCandidate();
    await _mutateSnapshot(package, (database) {
      database.execute('DROP TABLE tarot_readings');
      database.execute(
        _tarotReadingsWithPersonFk('RESTRICT', duplicatePersonFk: true),
      );
    });
    await fixture.refreshRestoreCandidateIntegrity(package);

    await expectFailure(package, 'snapshot_invalid');
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
    await expectFailure(package, 'manifest_not_canonical');
  });

  test('unsupported backup format version fails', () async {
    final package = await candidate();
    await _changeManifestField(package, 'backupFormatVersion', 2);
    await expectFailure(package, 'unsupported_backup_format');
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
    await expectFailure(package, 'manifest_database_schema_mismatch');
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

  final sajuPhysicalContractMutations = <String, String Function(String)>{
    'primary key': (sql) => _replaceSchemaToken(
      sql,
      RegExp(r'PRIMARY KEY\s*\(\s*"id"\s*\)', caseSensitive: false),
      'CHECK (1 = 1)',
    ),
    'revision unique': (sql) => _replaceSchemaToken(
      sql,
      RegExp(
        r'UNIQUE\s*\(\s*"chart_group_id"\s*,\s*"revision_number"\s*\)',
        caseSensitive: false,
      ),
      'CHECK (1 = 1)',
    ),
    'duplicate fingerprint unique': (sql) => _replaceSchemaToken(
      sql,
      RegExp(
        r'UNIQUE\s*\(\s*"person_id"\s*,\s*"input_fingerprint_sha256"\s*,\s*"calculation_signature_sha256"\s*\)',
        caseSensitive: false,
      ),
      'CHECK (1 = 1)',
    ),
    'required nullability': (sql) => _replaceSchemaToken(
      sql,
      RegExp(r'"engine_id"\s+TEXT\s+NOT NULL', caseSensitive: false),
      '"engine_id" TEXT',
    ),
    'nullable nullability': (sql) => _replaceSchemaToken(
      sql,
      RegExp(
        r'"source_birth_profile_id"\s+TEXT\s+NULL',
        caseSensitive: false,
      ),
      '"source_birth_profile_id" TEXT NOT NULL',
    ),
    'timestamp check': (sql) => _replaceSchemaToken(
      sql,
      RegExp(
        r'CHECK\s*\(\s*created_at_utc_us\s*>=\s*0\s*\)',
        caseSensitive: false,
      ),
      'CHECK (1 = 1)',
    ),
  };
  for (final mutation in sajuPhysicalContractMutations.entries) {
    test('v11 Saju physical ${mutation.key} loss is rejected', () async {
      final package = await candidate();
      await _mutateSnapshot(
        package,
        (database) => _rebuildSajuTable(database, mutation.value),
      );
      await fixture.refreshRestoreCandidateIntegrity(package);

      await expectFailure(package, 'snapshot_invalid');
    });
  }

  test('v11 Saju unapproved named index is rejected', () async {
    final package = await candidate();
    await _mutateSnapshot(
      package,
      (database) => database.execute(
        'CREATE INDEX arbitrary_saju_source_profile_idx '
        'ON saju_chart_snapshots (source_birth_profile_id)',
      ),
    );
    await fixture.refreshRestoreCandidateIntegrity(package);

    await expectFailure(package, 'snapshot_invalid');
  });

  test('v11 Saju approved index with partial SQL is rejected', () async {
    final package = await candidate();
    await _mutateSnapshot(package, (database) {
      database.execute('DROP INDEX saju_snapshots_person_birth_date_idx');
      database.execute(
        'CREATE INDEX saju_snapshots_person_birth_date_idx '
        'ON saju_chart_snapshots (person_id, converted_solar_date) '
        'WHERE source_birth_profile_id IS NOT NULL',
      );
    });
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

void _rebuildSajuTable(
  Database database,
  String Function(String sql) mutate,
) {
  final tableSql = database
      .select(
        "SELECT sql FROM sqlite_master WHERE type = 'table' "
        "AND name = 'saju_chart_snapshots'",
      )
      .single['sql'] as String;
  final namedIndexSql = database
      .select(
        "SELECT sql FROM sqlite_master WHERE type = 'index' "
        "AND name LIKE 'saju_snapshots_%' ORDER BY name",
      )
      .map((row) => row['sql'] as String)
      .toList(growable: false);
  final replacementSql = mutate(tableSql);
  if (replacementSql == tableSql) {
    throw StateError('synthetic Saju schema mutation did not match');
  }
  database.execute('PRAGMA foreign_keys = OFF');
  database.execute('DROP TABLE saju_chart_snapshots');
  database.execute(replacementSql);
  for (final sql in namedIndexSql) {
    database.execute(sql);
  }
}

String _replaceSchemaToken(
  String sql,
  RegExp token,
  String replacement,
) {
  if (!token.hasMatch(sql)) {
    throw StateError('synthetic Saju schema token not found: $token');
  }
  return sql.replaceFirst(token, replacement);
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

String _tarotReadingsWithPersonFk(
  String action, {
  String updateAction = 'NO ACTION',
  bool duplicatePersonFk = false,
}) =>
    '''
CREATE TABLE tarot_readings (
  reading_instance_id TEXT NOT NULL PRIMARY KEY,
  source_type TEXT NOT NULL,
  person_id TEXT NULL REFERENCES persons(id) ON UPDATE $updateAction ON DELETE $action,
  question_original_snapshot TEXT NOT NULL,
  question_display_text TEXT NOT NULL,
  deck_id TEXT NOT NULL,
  deck_name_snapshot TEXT NOT NULL,
  spread_id TEXT NOT NULL,
  spread_name_snapshot TEXT NOT NULL,
  expected_placement_count INTEGER NOT NULL,
  reading_at_utc_us INTEGER NOT NULL,
  reading_timezone_offset_min INTEGER NOT NULL,
  created_at_utc_us INTEGER NOT NULL,
  updated_at_utc_us INTEGER NOT NULL,
  lifecycle_status TEXT NOT NULL,
  finished_at_utc_us INTEGER NULL${duplicatePersonFk ? ',' : ''}
  ${duplicatePersonFk ? 'FOREIGN KEY(person_id) REFERENCES persons(id) ON UPDATE NO ACTION ON DELETE RESTRICT' : ''}
)
''';
