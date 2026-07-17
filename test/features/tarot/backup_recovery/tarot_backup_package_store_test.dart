import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/backup_recovery/sha256_digest_service.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/domain/tarot_backup_manifest.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_backup_database_inspector.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_backup_package_store.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_backup_path_contract.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_sqlite_online_backup_service.dart';

import '../../../support/tarot_backup_recovery_fixture.dart';

void main() {
  late TarotBackupRecoveryFixture fixture;
  const digest = DartSha256DigestService();

  tearDown(() async {
    await fixture.dispose();
  });

  Future<VerifiedTarotBackupPackage> createPackage({
    TarotBackupPackageStore? store,
    String operationId = 'a1b2c3d4',
    Future<bool> Function(String)? inspectPath,
  }) async {
    final resolved = fixture.resolvedPaths(inspectPath: inspectPath);
    final packagePaths = resolved.packagePaths(
      createdAtUtc: DateTime.utc(2026, 7, 17, 1, 2, 3),
      operationId: operationId,
    );
    return (store ?? const TarotBackupPackageStore()).createVerifiedPackage(
      paths: resolved,
      packagePaths: packagePaths,
      snapshotWriter: (payload) async {
        final result = await const TarotSqliteOnlineBackupService()
            .createSnapshot(
              sourceDatabasePath: fixture.sourceFile.path,
              targetDatabasePath: payload.path,
              paths: resolved,
            );
        return result.afterSanitation;
      },
      manifestFactory:
          ({
            required evidence,
            required payloadSha256,
            required payloadSizeBytes,
          }) => _manifest(
            evidence: evidence,
            payloadSha256: payloadSha256,
            payloadSizeBytes: payloadSizeBytes,
          ),
    );
  }

  test('creates exact three-file package and exact checksum bytes', () async {
    fixture = await TarotBackupRecoveryFixture.create();

    final result = await createPackage();

    expect(result.finalDirectory.path, endsWith('.rynbackup'));
    final relativeFiles =
        result.finalDirectory
            .listSync(recursive: true)
            .whereType<File>()
            .map(
              (file) => file.path
                  .substring(result.finalDirectory.path.length + 1)
                  .replaceAll('\\', '/'),
            )
            .toList()
          ..sort();
    expect(relativeFiles, <String>[
      'checksums/sha256.txt',
      'data/ryn_universe_os_core_snapshot.sqlite',
      'manifest.json',
    ]);
    final manifestFile = File('${result.finalDirectory.path}/manifest.json');
    final payloadFile = File(
      '${result.finalDirectory.path}/data/ryn_universe_os_core_snapshot.sqlite',
    );
    final checksumFile = File(
      '${result.finalDirectory.path}/checksums/sha256.txt',
    );
    final manifestHash = await digest.digestFile(manifestFile);
    final payloadHash = await digest.digestFile(payloadFile);
    expect(
      await checksumFile.readAsBytes(),
      utf8.encode(
        '$manifestHash  manifest.json\n'
        '$payloadHash  data/ryn_universe_os_core_snapshot.sqlite',
      ),
    );
    expect(result.manifest.databasePayloadSha256, payloadHash);
    expect(result.manifest.databasePayloadSizeBytes, payloadFile.lengthSync());
    expect(result.finalReadbackVerified, isTrue);
  });

  test('uses same-parent partial name then final rename', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final seen = <String>[];
    final store = TarotBackupPackageStore(
      beforePartialReadback: (directory) async => seen.add(directory.path),
      afterFinalRename: (directory) async => seen.add(directory.path),
    );

    final result = await createPackage(store: store);

    expect(seen.first, contains('.partial-a1b2c3d4'));
    expect(seen.last, result.finalDirectory.path);
    expect(Directory(seen.first).existsSync(), isFalse);
  });

  test(
    'reparse ancestry is re-inspected at every sensitive boundary',
    () async {
      fixture = await TarotBackupRecoveryFixture.create();
      final inspections = <String>[];

      final result = await createPackage(
        inspectPath: (path) async {
          inspections.add(path);
          return true;
        },
      );

      expect(result.finalReadbackVerified, isTrue);
      expect(
        inspections.where((path) => path == fixture.backupRoot.path).length,
        greaterThanOrEqualTo(2),
      );
      expect(
        inspections.where((path) => path.contains('.partial-a1b2c3d4')).length,
        greaterThanOrEqualTo(4),
      );
      expect(
        inspections.where((path) => path.endsWith('.rynbackup')).length,
        greaterThanOrEqualTo(3),
      );
      expect(
        inspections.any(
          (path) => path.endsWith('ryn_universe_os_core_snapshot.sqlite'),
        ),
        isTrue,
      );
    },
  );

  test('nested reparse failure after final rename withholds success', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    var finalRenamed = false;
    final store = TarotBackupPackageStore(
      afterFinalRename: (_) async => finalRenamed = true,
    );

    await expectLater(
      createPackage(
        store: store,
        inspectPath: (path) async {
          if (!finalRenamed) return true;
          return !path.replaceAll('\\', '/').contains('/data/');
        },
      ),
      throwsA(isA<TarotBackupPackageException>()),
    );
    expect(
      fixture.backupRoot.listSync().whereType<Directory>().where(
        (directory) => directory.path.endsWith('.rynbackup'),
      ),
      hasLength(1),
    );
  });

  test('never overwrites an existing final package', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final resolved = fixture.resolvedPaths();
    final paths = resolved.packagePaths(
      createdAtUtc: DateTime.utc(2026, 7, 17, 1, 2, 3),
      operationId: 'a1b2c3d4',
    );
    await paths.finalDirectory.create();
    final sentinel = File('${paths.finalDirectory.path}/sentinel')
      ..writeAsStringSync('keep');

    await expectLater(
      createPackage(),
      throwsA(isA<TarotBackupPackageException>()),
    );
    expect(sentinel.readAsStringSync(), 'keep');
  });

  test(
    'unexpected or missing files prevent finalization and clean partial',
    () async {
      for (final mode in <String>['extra', 'missing']) {
        fixture = await TarotBackupRecoveryFixture.create();
        String? partialPath;
        final store = TarotBackupPackageStore(
          beforePartialReadback: (directory) async {
            partialPath = directory.path;
            if (mode == 'extra') {
              await File('${directory.path}/extra.txt').writeAsString('extra');
            } else {
              await File('${directory.path}/manifest.json').delete();
            }
          },
        );

        await expectLater(
          createPackage(store: store),
          throwsA(isA<TarotBackupPackageException>()),
        );
        expect(Directory(partialPath!).existsSync(), isFalse);
        expect(
          fixture.backupRoot.listSync().whereType<Directory>().where(
            (directory) => directory.path.endsWith('.rynbackup'),
          ),
          isEmpty,
        );
        await fixture.dispose();
      }
    },
  );

  test(
    'altered manifest or payload fails final readback and returns no success',
    () async {
      for (final mode in <String>['manifest', 'payload']) {
        fixture = await TarotBackupRecoveryFixture.create();
        String? finalPath;
        final store = TarotBackupPackageStore(
          afterFinalRename: (directory) async {
            finalPath = directory.path;
            final file = mode == 'manifest'
                ? File('${directory.path}/manifest.json')
                : File(
                    '${directory.path}/data/ryn_universe_os_core_snapshot.sqlite',
                  );
            final handle = await file.open(mode: FileMode.append);
            await handle.writeByte(1);
            await handle.flush();
            await handle.close();
          },
        );

        await expectLater(
          createPackage(store: store),
          throwsA(isA<TarotBackupPackageException>()),
        );
        expect(Directory(finalPath!).existsSync(), isFalse);
        await fixture.dispose();
      }
    },
  );

  test(
    'failed partial cleanup is quarantined and never reported successful',
    () async {
      fixture = await TarotBackupRecoveryFixture.create();
      final store = TarotBackupPackageStore(
        beforePartialReadback: (directory) async {
          await File('${directory.path}/unexpected').writeAsString('x');
        },
        deleteDirectory: (_) async {
          throw const FileSystemException('synthetic cleanup failure');
        },
      );

      await expectLater(
        createPackage(store: store),
        throwsA(isA<TarotBackupPackageException>()),
      );
      final quarantines = fixture.backupRoot
          .listSync()
          .whereType<Directory>()
          .where((directory) => directory.path.contains('.quarantine-'));
      expect(quarantines, hasLength(1));
    },
  );

  test('checksum mismatch and oversize payload are rejected', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final mismatchStore = TarotBackupPackageStore(
      beforePartialReadback: (directory) async {
        final checksum = File('${directory.path}/checksums/sha256.txt');
        final invalidHash = '0' * 64;
        await checksum.writeAsString(
          '$invalidHash  manifest.json\n'
          '$invalidHash  data/ryn_universe_os_core_snapshot.sqlite',
        );
      },
    );
    await expectLater(
      createPackage(store: mismatchStore),
      throwsA(isA<TarotBackupPackageException>()),
    );

    await fixture.dispose();
    fixture = await TarotBackupRecoveryFixture.create();
    final oversizeStore = TarotBackupPackageStore(
      beforePayloadHash: (payload) async {
        final handle = await payload.open(mode: FileMode.append);
        await handle.truncate(TarotBackupPackageStore.maximumPayloadBytes + 1);
        await handle.close();
      },
    );
    await expectLater(
      createPackage(store: oversizeStore),
      throwsA(isA<TarotBackupPackageException>()),
    );
  });

  test('unsafe manifest swap is rejected before initial digest', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    var unsafe = false;
    var returnedVerifiedPackage = false;
    var manifestInspectionsAfterHook = 0;
    final resolved = fixture.resolvedPaths(
      inspectPath: (path) async {
        final isManifest = path
            .replaceAll('\\', '/')
            .endsWith('/manifest.json');
        if (unsafe && isManifest) {
          manifestInspectionsAfterHook += 1;
          return false;
        }
        return true;
      },
    );
    final planned = resolved.packagePaths(
      createdAtUtc: DateTime.utc(2026, 7, 17, 1, 2, 3),
      operationId: 'a1b2c3d4',
    );
    final manifest = File(
      '${planned.partialDirectory.path}${Platform.pathSeparator}manifest.json',
    );
    final checksum = File(
      '${planned.partialDirectory.path}${Platform.pathSeparator}checksums'
      '${Platform.pathSeparator}sha256.txt',
    );
    final externalDirectory = await Directory(
      '${fixture.root.path}${Platform.pathSeparator}external',
    ).create();
    final externalSentinel = File(
      '${externalDirectory.path}${Platform.pathSeparator}sentinel',
    )..writeAsStringSync('keep');
    final trackingDigest = _TrackingDigestService(
      externalPath: externalSentinel.path,
    );
    final store = TarotBackupPackageStore(
      digestService: trackingDigest,
      beforeManifestHash: () async {
        expect(manifest.existsSync(), isTrue);
        unsafe = true;
      },
    );

    await expectLater(
      createPackage(store: store, inspectPath: resolved.inspectPath).then((
        result,
      ) {
        returnedVerifiedPackage = true;
        return result;
      }),
      throwsA(isA<TarotBackupPackageException>()),
    );

    expect(manifestInspectionsAfterHook, greaterThan(0));
    expect(trackingDigest.manifestDigestCount, 0);
    expect(trackingDigest.externalDigestCount, 0);
    expect(externalSentinel.readAsStringSync(), 'keep');
    expect(checksum.existsSync(), isFalse);
    expect(planned.finalDirectory.existsSync(), isFalse);
    expect(returnedVerifiedPackage, isFalse);
  });

  test('unvalidated outside package path never reaches cleanup', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final victim = await Directory(
      '${fixture.root.path}${Platform.pathSeparator}victim',
    ).create();
    final sentinel = File('${victim.path}${Platform.pathSeparator}sentinel')
      ..writeAsStringSync('keep');
    var cleanupCount = 0;
    final resolved = fixture.resolvedPaths();
    final planned = resolved.packagePaths(
      createdAtUtc: DateTime.utc(2026, 7, 17, 1, 2, 3),
      operationId: 'a1b2c3d4',
    );
    final malicious = TarotBackupPackagePaths(
      finalDirectory: planned.finalDirectory,
      partialDirectory: victim,
    );
    final store = TarotBackupPackageStore(
      deleteDirectory: (_) async => cleanupCount++,
    );

    await expectLater(
      store.createVerifiedPackage(
        paths: resolved,
        packagePaths: malicious,
        snapshotWriter: (_) async => throw StateError('must_not_run'),
        manifestFactory:
            ({
              required evidence,
              required payloadSha256,
              required payloadSizeBytes,
            }) => throw StateError('must_not_run'),
      ),
      throwsA(isA<TarotBackupPackageException>()),
    );
    expect(cleanupCount, 0);
    expect(sentinel.readAsStringSync(), 'keep');
    expect(planned.finalDirectory.existsSync(), isFalse);
  });

  test('cross-parent package paths are rejected before mutation', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final resolved = fixture.resolvedPaths();
    final planned = resolved.packagePaths(
      createdAtUtc: DateTime.utc(2026, 7, 17, 1, 2, 3),
      operationId: 'a1b2c3d4',
    );
    final nested = Directory(
      '${fixture.backupRoot.path}${Platform.pathSeparator}nested',
    );
    final invalid = TarotBackupPackagePaths(
      finalDirectory: Directory(
        '${nested.path}${Platform.pathSeparator}'
        '${planned.finalDirectory.path.split(Platform.pathSeparator).last}',
      ),
      partialDirectory: planned.partialDirectory,
    );

    await expectLater(
      resolved.validatePackagePaths(invalid),
      throwsA(isA<TarotBackupPathException>()),
    );
    expect(nested.existsSync(), isFalse);
  });

  test('payload hook path swap is rejected before hash', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    var unsafe = false;
    final store = TarotBackupPackageStore(
      beforePayloadHash: (_) async => unsafe = true,
    );

    await expectLater(
      createPackage(store: store, inspectPath: (_) async => !unsafe),
      throwsA(isA<TarotBackupPackageException>()),
    );
  });
}

TarotBackupManifest _manifest({
  required TarotDatabaseEvidence evidence,
  required String payloadSha256,
  required int payloadSizeBytes,
}) => TarotBackupManifest(
  applicationVersion: '1.0.0+1',
  sourceRuntimeMode: 'tarot_backup_recovery_qa',
  sourceEnvironment: 'development',
  sourcePurpose: 'core_tarot_backup_recovery_v0_2',
  createdAtUtc: DateTime.utc(2026, 7, 17, 1, 2, 3),
  databasePayloadSizeBytes: payloadSizeBytes,
  databasePayloadSha256: payloadSha256,
  requiredTables: TarotBackupManifest.requiredTablesV1,
  requiredColumnsByTable: TarotBackupManifest.requiredColumnsByTableV1,
  tableRowCounts: evidence.tableRowCounts,
  readingIdCount: evidence.distinctReadingIdCount,
  placementCount: evidence.placementCount,
  interpretationCount: evidence.interpretationCount,
  runtimeStateRowCount: evidence.runtimeStateRowCount,
  activeHomeReadingIdPresent: evidence.activeHomeReadingIdPresent,
  lifecycleStateCounts: evidence.lifecycleStateCounts,
  unsupportedTableRowsZero: evidence.unsupportedTableRowsZero,
  verifiedAtUtc: DateTime.utc(2026, 7, 17, 1, 2, 4),
);

final class _TrackingDigestService implements Sha256DigestService {
  _TrackingDigestService({required this.externalPath});

  final String externalPath;
  final Sha256DigestService _delegate = const DartSha256DigestService();
  int manifestDigestCount = 0;
  int externalDigestCount = 0;

  @override
  Sha256Accumulator start() => _delegate.start();

  @override
  Future<String> digestFile(File file, {int chunkSize = 65536}) {
    final normalized = file.absolute.path.replaceAll('\\', '/').toLowerCase();
    if (normalized.endsWith('/manifest.json')) manifestDigestCount += 1;
    if (normalized ==
        File(externalPath).absolute.path.replaceAll('\\', '/').toLowerCase()) {
      externalDigestCount += 1;
    }
    return _delegate.digestFile(file, chunkSize: chunkSize);
  }
}
