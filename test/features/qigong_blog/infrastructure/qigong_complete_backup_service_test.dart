import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:ryn_universe_os_core/core/backup_recovery/sha256_digest_service.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/features/qigong_blog/application/qigong_complete_restore_coordinator.dart';
import 'package:ryn_universe_os_core/features/qigong_blog/application/qigong_complete_restore_startup_recovery_coordinator.dart';
import 'package:ryn_universe_os_core/features/qigong_blog/domain/qigong_complete_restore_operation_marker.dart';
import 'package:ryn_universe_os_core/features/qigong_blog/infrastructure/qigong_complete_backup_service.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_sqlite_online_backup_service.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test(
    'marker round trips every durable phase without absolute paths',
    () async {
      final root = await Directory.systemTemp.createTemp('ryn-qigong-marker-');
      try {
        final operation = await Directory(
          p.join(root.path, '.qigong-complete-restore-deadbeef'),
        ).create();
        const store = QigongCompleteRestoreOperationMarkerStore();
        for (final phase in QigongCompleteRestorePhase.values) {
          final marker = QigongCompleteRestoreOperationMarker(
            operationId: 'deadbeef',
            phase: phase,
            startedAtUtc: DateTime.utc(2026, 7, 31, 1),
            updatedAtUtc: DateTime.utc(2026, 7, 31, 1, 1),
            candidatePackageIdentitySha256: 'a' * 64,
            stagedDirectoryName: 'staged',
            rollbackDirectoryName: 'rollback',
            sourceSchemaVersion: 10,
            expectedTargetSchemaVersion: 10,
            lastCompletedStep: phase.name,
            originalMediaDirectoryPresent: true,
          );

          await store.write(operationDirectory: operation, marker: marker);
          final decoded = await store.read(operationDirectory: operation);
          final text = await File(
            p.join(
              operation.path,
              QigongCompleteRestoreOperationMarkerStore.filename,
            ),
          ).readAsString();

          expect(decoded.phase, phase);
          expect(decoded.operationType, 'qigongCompleteRestoreV1');
          expect(text, isNot(contains(root.absolute.path)));
          expect(text, isNot(contains(r'C:\Users')));
        }
      } finally {
        await root.delete(recursive: true);
      }
    },
  );

  test(
    'marker replacement failure preserves the previous durable phase',
    () async {
      final root = await Directory.systemTemp.createTemp('ryn-qigong-marker-');
      try {
        final operation = await Directory(
          p.join(root.path, '.qigong-complete-restore-deadbeef'),
        ).create();
        var failNextReplacement = false;
        final store = QigongCompleteRestoreOperationMarkerStore(
          renameFile: (source, target) {
            if (failNextReplacement && source.path.endsWith('.next')) {
              throw const FileSystemException(
                'synthetic marker replace failure',
              );
            }
            return source.rename(target);
          },
        );
        await store.write(
          operationDirectory: operation,
          marker: _marker(QigongCompleteRestorePhase.prepared),
        );
        failNextReplacement = true;

        await expectLater(
          store.write(
            operationDirectory: operation,
            marker: _marker(QigongCompleteRestorePhase.candidateStaged),
          ),
          throwsA(isA<FileSystemException>()),
        );
        expect(
          (await store.read(operationDirectory: operation)).phase,
          QigongCompleteRestorePhase.prepared,
        );
      } finally {
        await root.delete(recursive: true);
      }
    },
  );

  test(
    'schema ten complete package restores DB and replaces media set',
    () async {
      final fixture = await _QigongFixture.create();
      try {
        final package = await fixture.service.createBackup(
          createdAtUtc: DateTime.utc(2026, 7, 31, 2),
          operationId: 'a1b2c3d4',
        );
        final database = sqlite3.open(fixture.databaseFile.path);
        database.execute("DELETE FROM qigong_media_assets");
        database.close();
        await fixture.mediaFile.delete();
        final orphan = File(p.join(fixture.mediaRoot.path, 'orphan.bin'));
        await orphan.writeAsBytes(<int>[9, 9, 9], flush: true);
        final lifecycle = _TestQigongLifecycle(fixture.databaseFile)
          ..openInitial();
        final coordinator = QigongCompleteRestoreCoordinator(
          backupService: fixture.service,
          clock: () => DateTime.utc(2026, 7, 31, 3),
          safetyOperationIdGenerator: () => 'b1c2d3e4',
        );

        final result = await coordinator.restore(
          candidatePackage: package,
          operationId: 'deadbeef',
          lifecycle: lifecycle,
        );

        expect(result.status, QigongCompleteRestoreStatus.succeeded);
        expect(lifecycle.closeCount, 1);
        expect(lifecycle.reopenCount, 1);
        expect(lifecycle.rehydrateCount, 1);
        expect(orphan.existsSync(), isFalse);
        expect(await fixture.mediaFile.readAsBytes(), <int>[1, 2, 3, 4]);
        final restored = sqlite3.open(
          fixture.databaseFile.path,
          mode: OpenMode.readOnly,
        );
        expect(
          restored
              .select('SELECT count(*) FROM qigong_media_assets')
              .single
              .values
              .single,
          1,
        );
        restored.close();
        lifecycle.dispose();
      } finally {
        await fixture.dispose();
      }
    },
  );

  test('complete package rejects missing or changed media bytes', () async {
    final fixture = await _QigongFixture.create();
    try {
      final package = await fixture.service.createBackup(
        createdAtUtc: DateTime.utc(2026, 7, 31, 5),
        operationId: '10000001',
      );
      final media = File(
        p.join(package.path, 'media', 'qigong_media', 'asset.bin'),
      );
      await media.delete();
      await _expectBackupFailure(
        fixture.service.validateBackup(package),
        'media_payload_missing',
      );
    } finally {
      await fixture.dispose();
    }
  });

  test('complete package rejects media hash mismatch', () async {
    final fixture = await _QigongFixture.create();
    try {
      final package = await fixture.service.createBackup(
        createdAtUtc: DateTime.utc(2026, 7, 31, 5, 1),
        operationId: '10000002',
      );
      await File(
        p.join(package.path, 'media', 'qigong_media', 'asset.bin'),
      ).writeAsBytes(<int>[4, 3, 2, 1], flush: true);
      await _expectBackupFailure(
        fixture.service.validateBackup(package),
        'media_hash_mismatch',
      );
    } finally {
      await fixture.dispose();
    }
  });

  test('complete package rejects duplicate media identity', () async {
    final fixture = await _QigongFixture.create();
    try {
      final package = await fixture.service.createBackup(
        createdAtUtc: DateTime.utc(2026, 7, 31, 5, 2),
        operationId: '10000003',
      );
      final manifest = File(p.join(package.path, 'manifest.json'));
      final values =
          jsonDecode(await manifest.readAsString()) as Map<String, dynamic>;
      final media = values['media'] as List<dynamic>;
      media.add(Map<String, dynamic>.from(media.single as Map));
      await manifest.writeAsString(jsonEncode(values), flush: true);
      await _expectBackupFailure(
        fixture.service.validateBackup(package),
        'media_manifest_invalid',
      );
    } finally {
      await fixture.dispose();
    }
  });

  test('complete package rejects unsafe media relative path', () async {
    final fixture = await _QigongFixture.create();
    try {
      final package = await fixture.service.createBackup(
        createdAtUtc: DateTime.utc(2026, 7, 31, 5, 3),
        operationId: '10000004',
      );
      final manifest = File(p.join(package.path, 'manifest.json'));
      final values =
          jsonDecode(await manifest.readAsString()) as Map<String, dynamic>;
      final media = values['media'] as List<dynamic>;
      (media.single as Map<String, dynamic>)['relativePath'] = '../escape.bin';
      await manifest.writeAsString(jsonEncode(values), flush: true);
      await _expectBackupFailure(
        fixture.service.validateBackup(package),
        'unsafe_media_relative_path',
      );
    } finally {
      await fixture.dispose();
    }
  });

  test('complete package rejects Windows separator traversal', () async {
    final fixture = await _QigongFixture.create();
    try {
      final package = await fixture.service.createBackup(
        createdAtUtc: DateTime.utc(2026, 7, 31, 5, 3),
        operationId: '1000000a',
      );
      final manifest = File(p.join(package.path, 'manifest.json'));
      final values =
          jsonDecode(await manifest.readAsString()) as Map<String, dynamic>;
      final media = values['media'] as List<dynamic>;
      (media.single as Map<String, dynamic>)['relativePath'] =
          r'qigong_media/sub\..\..\outside';
      await manifest.writeAsString(jsonEncode(values), flush: true);
      await _expectBackupFailure(
        fixture.service.validateBackup(package),
        'unsafe_media_relative_path',
      );
    } finally {
      await fixture.dispose();
    }
  });

  for (final unsafePath in <String>[
    'qigong_media/asset.bin:stream',
    'qigong_media//asset.bin',
    'qigong_media/sub/../asset.bin',
    r'qigong_media/sub\asset.bin',
  ]) {
    test(
      'complete package rejects noncanonical media path $unsafePath',
      () async {
        final fixture = await _QigongFixture.create();
        try {
          final package = await fixture.service.createBackup(
            createdAtUtc: DateTime.utc(2026, 7, 31, 5, 3),
            operationId: '1000000b',
          );
          final manifest = File(p.join(package.path, 'manifest.json'));
          final values =
              jsonDecode(await manifest.readAsString()) as Map<String, dynamic>;
          final media = values['media'] as List<dynamic>;
          (media.single as Map<String, dynamic>)['relativePath'] = unsafePath;
          await manifest.writeAsString(jsonEncode(values), flush: true);
          await _expectBackupFailure(
            fixture.service.validateBackup(package),
            'unsafe_media_relative_path',
          );
        } finally {
          await fixture.dispose();
        }
      },
    );
  }

  test(
    'complete package rejects manifest database inventory mismatch',
    () async {
      final fixture = await _QigongFixture.create();
      try {
        final package = await fixture.service.createBackup(
          createdAtUtc: DateTime.utc(2026, 7, 31, 5, 4),
          operationId: '10000005',
        );
        final manifest = File(p.join(package.path, 'manifest.json'));
        final values =
            jsonDecode(await manifest.readAsString()) as Map<String, dynamic>;
        final media = values['media'] as List<dynamic>;
        (media.single as Map<String, dynamic>)['id'] =
            'media.synthetic.changed';
        await manifest.writeAsString(jsonEncode(values), flush: true);
        await _expectBackupFailure(
          fixture.service.validateBackup(package),
          'media_manifest_database_mismatch',
        );
      } finally {
        await fixture.dispose();
      }
    },
  );

  test('complete package rejects unexpected inventory file', () async {
    final fixture = await _QigongFixture.create();
    try {
      final package = await fixture.service.createBackup(
        createdAtUtc: DateTime.utc(2026, 7, 31, 5, 5),
        operationId: '10000006',
      );
      await File(p.join(package.path, 'unexpected.bin')).writeAsBytes(<int>[1]);
      await _expectBackupFailure(
        fixture.service.validateBackup(package),
        'package_inventory_mismatch',
      );
    } finally {
      await fixture.dispose();
    }
  });

  test('database replacement failure rolls back the complete pair', () async {
    final fixture = await _QigongFixture.create();
    final lifecycle = _TestQigongLifecycle(fixture.databaseFile)..openInitial();
    try {
      final package = await fixture.service.createBackup(
        createdAtUtc: DateTime.utc(2026, 7, 31, 6),
        operationId: '20000001',
      );
      final coordinator = QigongCompleteRestoreCoordinator(
        backupService: fixture.service,
        clock: () => DateTime.utc(2026, 7, 31, 6, 1),
        safetyOperationIdGenerator: () => '30000001',
        renameFile: (source, target) {
          if (source.path.contains('${p.separator}staged${p.separator}')) {
            throw const FileSystemException(
              'synthetic database replace failure',
            );
          }
          return source.rename(target);
        },
      );

      final result = await coordinator.restore(
        candidatePackage: package,
        operationId: '40000001',
        lifecycle: lifecycle,
      );

      expect(result.status, QigongCompleteRestoreStatus.failedRolledBack);
      expect(await fixture.mediaFile.readAsBytes(), <int>[1, 2, 3, 4]);
      expect(lifecycle.reopenCount, 1);
    } finally {
      lifecycle.dispose();
      await fixture.dispose();
    }
  });

  test('media replacement failure rolls back DB and media', () async {
    final fixture = await _QigongFixture.create();
    final lifecycle = _TestQigongLifecycle(fixture.databaseFile)..openInitial();
    try {
      final package = await fixture.service.createBackup(
        createdAtUtc: DateTime.utc(2026, 7, 31, 6, 2),
        operationId: '20000002',
      );
      final coordinator = QigongCompleteRestoreCoordinator(
        backupService: fixture.service,
        clock: () => DateTime.utc(2026, 7, 31, 6, 3),
        safetyOperationIdGenerator: () => '30000002',
        renameDirectory: (source, target) {
          if (source.path.contains('${p.separator}staged${p.separator}')) {
            throw const FileSystemException('synthetic media replace failure');
          }
          return source.rename(target);
        },
      );

      final result = await coordinator.restore(
        candidatePackage: package,
        operationId: '40000002',
        lifecycle: lifecycle,
      );

      expect(result.status, QigongCompleteRestoreStatus.failedRolledBack);
      expect(await fixture.mediaFile.readAsBytes(), <int>[1, 2, 3, 4]);
      final database = sqlite3.open(
        fixture.databaseFile.path,
        mode: OpenMode.readOnly,
      );
      expect(database.userVersion, 10);
      database.close();
    } finally {
      lifecycle.dispose();
      await fixture.dispose();
    }
  });

  test(
    'rollback removes candidate sidecars absent from original set',
    () async {
      final fixture = await _QigongFixture.create();
      final lifecycle = _TestQigongLifecycle(fixture.databaseFile)
        ..openInitial();
      try {
        final package = await fixture.service.createBackup(
          createdAtUtc: DateTime.utc(2026, 7, 31, 6, 2),
          operationId: '2000000a',
        );
        final wal = File('${fixture.databaseFile.path}-wal');
        final shm = File('${fixture.databaseFile.path}-shm');
        final coordinator = QigongCompleteRestoreCoordinator(
          backupService: fixture.service,
          clock: () => DateTime.utc(2026, 7, 31, 6, 3),
          safetyOperationIdGenerator: () => '3000000a',
          renameDirectory: (source, target) async {
            if (source.path.contains('${p.separator}staged${p.separator}')) {
              await wal.writeAsBytes(<int>[1], flush: true);
              await shm.writeAsBytes(<int>[2], flush: true);
              throw const FileSystemException(
                'synthetic media replace failure',
              );
            }
            return source.rename(target);
          },
        );

        final result = await coordinator.restore(
          candidatePackage: package,
          operationId: '4000000a',
          lifecycle: lifecycle,
        );

        expect(result.status, QigongCompleteRestoreStatus.failedRolledBack);
        expect(wal.existsSync(), isFalse);
        expect(shm.existsSync(), isFalse);
      } finally {
        lifecycle.dispose();
        await fixture.dispose();
      }
    },
  );

  test('reopen failure rolls back and reopens the old runtime', () async {
    final fixture = await _QigongFixture.create();
    final lifecycle = _TestQigongLifecycle(
      fixture.databaseFile,
      reopenFailures: 1,
    )..openInitial();
    try {
      final package = await fixture.service.createBackup(
        createdAtUtc: DateTime.utc(2026, 7, 31, 6, 4),
        operationId: '20000003',
      );
      final result =
          await QigongCompleteRestoreCoordinator(
            backupService: fixture.service,
            clock: () => DateTime.utc(2026, 7, 31, 6, 5),
            safetyOperationIdGenerator: () => '30000003',
          ).restore(
            candidatePackage: package,
            operationId: '40000003',
            lifecycle: lifecycle,
          );

      expect(result.status, QigongCompleteRestoreStatus.failedRolledBack);
      expect(lifecycle.reopenCount, 2);
      expect(await fixture.mediaFile.readAsBytes(), <int>[1, 2, 3, 4]);
    } finally {
      lifecycle.dispose();
      await fixture.dispose();
    }
  });

  test('validation failure rolls back the replacement pair', () async {
    final fixture = await _QigongFixture.create();
    final lifecycle = _TestQigongLifecycle(
      fixture.databaseFile,
      validationFailures: 1,
    )..openInitial();
    try {
      final package = await fixture.service.createBackup(
        createdAtUtc: DateTime.utc(2026, 7, 31, 6, 6),
        operationId: '20000004',
      );
      final result =
          await QigongCompleteRestoreCoordinator(
            backupService: fixture.service,
            clock: () => DateTime.utc(2026, 7, 31, 6, 7),
            safetyOperationIdGenerator: () => '30000004',
          ).restore(
            candidatePackage: package,
            operationId: '40000004',
            lifecycle: lifecycle,
          );

      expect(result.status, QigongCompleteRestoreStatus.failedRolledBack);
      expect(lifecycle.validateCount, 2);
    } finally {
      lifecycle.dispose();
      await fixture.dispose();
    }
  });

  test(
    'validated cleanup failure keeps candidate and defers cleanup',
    () async {
      final fixture = await _QigongFixture.create();
      final package = await fixture.service.createBackup(
        createdAtUtc: DateTime.utc(2026, 7, 31, 6, 6),
        operationId: '2000000b',
      );
      final lifecycle = _TestQigongLifecycle(fixture.databaseFile)
        ..openInitial();
      try {
        await lifecycle.close();
        await fixture.databaseFile.writeAsBytes(<int>[1, 2, 3], flush: true);
        final coordinator = QigongCompleteRestoreCoordinator(
          backupService: fixture.service,
          clock: () => DateTime.utc(2026, 7, 31, 6, 7),
          safetyOperationIdGenerator: () => '3000000b',
          allowRawRollbackFallback: true,
          renameDirectory: (source, target) {
            if (p.basename(target).startsWith('.qigong-raw-rollback-')) {
              throw const FileSystemException('synthetic cleanup failure');
            }
            return source.rename(target);
          },
        );

        final result = await coordinator.restore(
          candidatePackage: package,
          operationId: '4000000b',
          lifecycle: lifecycle,
        );

        expect(result.status, QigongCompleteRestoreStatus.succeeded);
        expect(result.failureCode, 'post_validation_cleanup_deferred');
        expect(Directory(result.operationDirectoryPath!).existsSync(), isTrue);
        expect(
          sqlite3.open(fixture.databaseFile.path, mode: OpenMode.readOnly)
            ..close(),
          isA<Database>(),
        );
      } finally {
        lifecycle.dispose();
        await fixture.dispose();
      }
    },
  );

  test('generic safety snapshot failure cannot use raw fallback', () async {
    final fixture = await _QigongFixture.create();
    final lifecycle = _TestQigongLifecycle(fixture.databaseFile)..openInitial();
    try {
      final package = await fixture.service.createBackup(
        createdAtUtc: DateTime.utc(2026, 7, 31, 6, 6),
        operationId: '2000000c',
      );
      final failingService = QigongCompleteBackupService(
        profileRoot: fixture.profileRoot,
        sourceDatabaseFile: fixture.databaseFile,
        backupRoot: fixture.backupRoot,
        onlineBackupService: TarotSqliteOnlineBackupService(
          onlineBackup: (source, target, deadline) async {
            throw StateError('synthetic snapshot failure');
          },
        ),
      );
      final result =
          await QigongCompleteRestoreCoordinator(
            backupService: failingService,
            clock: () => DateTime.utc(2026, 7, 31, 6, 7),
            safetyOperationIdGenerator: () => '3000000c',
            allowRawRollbackFallback: true,
          ).restore(
            candidatePackage: package,
            operationId: '4000000c',
            lifecycle: lifecycle,
          );

      expect(result.status, QigongCompleteRestoreStatus.failedBeforeMutation);
      expect(result.failureCode, 'safety_snapshot_failed');
      expect(lifecycle.closeCount, 0);
    } finally {
      lifecycle.dispose();
      await fixture.dispose();
    }
  });

  test('rollback failure preserves a fatal durable marker', () async {
    final fixture = await _QigongFixture.create();
    final lifecycle = _TestQigongLifecycle(fixture.databaseFile)..openInitial();
    try {
      final package = await fixture.service.createBackup(
        createdAtUtc: DateTime.utc(2026, 7, 31, 6, 8),
        operationId: '20000005',
      );
      final coordinator = QigongCompleteRestoreCoordinator(
        backupService: fixture.service,
        clock: () => DateTime.utc(2026, 7, 31, 6, 9),
        safetyOperationIdGenerator: () => '30000005',
        renameFile: (source, target) {
          if (source.path.contains('${p.separator}staged${p.separator}') ||
              source.path.contains('${p.separator}rollback${p.separator}')) {
            throw const FileSystemException('synthetic rollback failure');
          }
          return source.rename(target);
        },
      );

      final result = await coordinator.restore(
        candidatePackage: package,
        operationId: '40000005',
        lifecycle: lifecycle,
      );

      expect(result.status, QigongCompleteRestoreStatus.fatalPreserved);
      final evidence = Directory(result.operationDirectoryPath!);
      expect(evidence.existsSync(), isTrue);
      final marker = await const QigongCompleteRestoreOperationMarkerStore()
          .read(operationDirectory: evidence);
      expect(marker.phase, QigongCompleteRestorePhase.fatalPreserved);
    } finally {
      lifecycle.dispose();
      await fixture.dispose();
    }
  });

  for (final phase in const <QigongCompleteRestorePhase>[
    QigongCompleteRestorePhase.prepared,
    QigongCompleteRestorePhase.candidateStaged,
    QigongCompleteRestorePhase.runtimeClosed,
  ]) {
    test(
      'startup $phase validates untouched pair and cleans residue',
      () async {
        final fixture = await _QigongFixture.create();
        try {
          final operation = await _writeMarker(fixture, phase);
          final result = await QigongCompleteRestoreStartupRecoveryCoordinator(
            backupService: fixture.service,
          ).recoverIfNeeded();

          expect(
            result.status,
            QigongCompleteRestoreStartupRecoveryStatus.untouchedFinalized,
          );
          expect(operation.existsSync(), isFalse);
        } finally {
          await fixture.dispose();
        }
      },
    );
  }

  for (final phase in const <QigongCompleteRestorePhase>[
    QigongCompleteRestorePhase.rollbackCaptured,
    QigongCompleteRestorePhase.databaseReplaced,
    QigongCompleteRestorePhase.mediaReplaced,
    QigongCompleteRestorePhase.databaseReopened,
    QigongCompleteRestorePhase.rollbackInProgress,
  ]) {
    test('startup $phase restores the original DB media pair', () async {
      final fixture = await _QigongFixture.create();
      try {
        final operation = await _writeMarker(fixture, phase);
        final rollbackDatabaseRoot = await Directory(
          p.join(operation.path, 'rollback', 'database'),
        ).create(recursive: true);
        await fixture.databaseFile.copy(
          p.join(
            rollbackDatabaseRoot.path,
            p.basename(fixture.databaseFile.path),
          ),
        );
        final rollbackMedia = await Directory(
          p.join(operation.path, 'rollback', 'qigong_media'),
        ).create(recursive: true);
        await fixture.mediaFile.copy(p.join(rollbackMedia.path, 'asset.bin'));
        await fixture.databaseFile.delete();
        await fixture.mediaRoot.delete(recursive: true);

        final result = await QigongCompleteRestoreStartupRecoveryCoordinator(
          backupService: fixture.service,
        ).recoverIfNeeded();

        expect(
          result.status,
          QigongCompleteRestoreStartupRecoveryStatus.originalRecovered,
        );
        expect(await fixture.mediaFile.readAsBytes(), <int>[1, 2, 3, 4]);
        expect(operation.existsSync(), isFalse);
      } finally {
        await fixture.dispose();
      }
    });
  }

  for (final phase in const <QigongCompleteRestorePhase>[
    QigongCompleteRestorePhase.validated,
    QigongCompleteRestorePhase.completed,
  ]) {
    test('startup $phase keeps the verified replacement pair', () async {
      final fixture = await _QigongFixture.create();
      try {
        final operation = await _writeMarker(fixture, phase);
        final result = await QigongCompleteRestoreStartupRecoveryCoordinator(
          backupService: fixture.service,
        ).recoverIfNeeded();

        expect(
          result.status,
          QigongCompleteRestoreStartupRecoveryStatus.replacementKept,
        );
        expect(operation.existsSync(), isFalse);
      } finally {
        await fixture.dispose();
      }
    });
  }

  test('fatalPreserved prevents automatic mutation', () async {
    final fixture = await _QigongFixture.create();
    try {
      final operation = await _writeMarker(
        fixture,
        QigongCompleteRestorePhase.fatalPreserved,
      );
      final before = await fixture.databaseFile.readAsBytes();

      final result = await QigongCompleteRestoreStartupRecoveryCoordinator(
        backupService: fixture.service,
      ).recoverIfNeeded();

      expect(result.requiresManualRecovery, isTrue);
      expect(operation.existsSync(), isTrue);
      expect(await fixture.databaseFile.readAsBytes(), before);
    } finally {
      await fixture.dispose();
    }
  });

  test('simultaneous DB-only and complete markers fail closed', () async {
    final fixture = await _QigongFixture.create();
    try {
      final operation = await _writeMarker(
        fixture,
        QigongCompleteRestorePhase.prepared,
      );
      final databaseOnly = await Directory(
        p.join(fixture.databaseFile.parent.path, '.restore-cafebabe'),
      ).create();
      await File(
        p.join(databaseOnly.path, 'restore-operation.json'),
      ).writeAsString('{}', flush: true);

      final result = await QigongCompleteRestoreStartupRecoveryCoordinator(
        backupService: fixture.service,
      ).recoverIfNeeded();

      expect(result.requiresManualRecovery, isTrue);
      expect(result.failureCode, 'simultaneous_restore_markers');
      expect(operation.existsSync(), isTrue);
      expect(databaseOnly.existsSync(), isTrue);
    } finally {
      await fixture.dispose();
    }
  });
}

Future<void> _expectBackupFailure(Future<Object?> future, String code) async {
  await expectLater(
    future,
    throwsA(
      isA<QigongBackupException>().having((error) => error.code, 'code', code),
    ),
  );
}

QigongCompleteRestoreOperationMarker _marker(
  QigongCompleteRestorePhase phase,
) => QigongCompleteRestoreOperationMarker(
  operationId: 'deadbeef',
  phase: phase,
  startedAtUtc: DateTime.utc(2026, 7, 31, 1),
  updatedAtUtc: DateTime.utc(2026, 7, 31, 1, 1),
  candidatePackageIdentitySha256: 'a' * 64,
  stagedDirectoryName: 'staged',
  rollbackDirectoryName: 'rollback',
  sourceSchemaVersion: 10,
  expectedTargetSchemaVersion: 10,
  lastCompletedStep: phase.name,
  originalMediaDirectoryPresent: true,
);

Future<Directory> _writeMarker(
  _QigongFixture fixture,
  QigongCompleteRestorePhase phase,
) async {
  final operation = await Directory(
    p.join(fixture.profileRoot.path, '.qigong-complete-restore-deadbeef'),
  ).create();
  final marker = QigongCompleteRestoreOperationMarker(
    operationId: 'deadbeef',
    phase: phase,
    startedAtUtc: DateTime.utc(2026, 7, 31, 4),
    updatedAtUtc: DateTime.utc(2026, 7, 31, 4, 1),
    candidatePackageIdentitySha256: 'b' * 64,
    stagedDirectoryName: 'staged',
    rollbackDirectoryName: 'rollback',
    sourceSchemaVersion: 10,
    expectedTargetSchemaVersion: 10,
    lastCompletedStep: phase.name,
    originalMediaDirectoryPresent: true,
  );
  await const QigongCompleteRestoreOperationMarkerStore().write(
    operationDirectory: operation,
    marker: marker,
  );
  return operation;
}

final class _QigongFixture {
  _QigongFixture({
    required this.root,
    required this.profileRoot,
    required this.backupRoot,
    required this.databaseFile,
    required this.mediaRoot,
    required this.mediaFile,
    required this.service,
  });

  final Directory root;
  final Directory profileRoot;
  final Directory backupRoot;
  final File databaseFile;
  final Directory mediaRoot;
  final File mediaFile;
  final QigongCompleteBackupService service;

  static Future<_QigongFixture> create() async {
    final root = await Directory.systemTemp.createTemp('ryn-qigong-complete-');
    final profileRoot = await Directory(p.join(root.path, 'profile')).create();
    final backupRoot = await Directory(p.join(root.path, 'backups')).create();
    final runtime = await Directory(
      p.join(profileRoot.path, 'runtime'),
    ).create();
    final databaseFile = File(p.join(runtime.path, 'ryn.sqlite'));
    final drift = RynAppDatabase(NativeDatabase(databaseFile));
    await drift.customSelect('SELECT 1').get();
    await drift.close();
    final mediaRoot = await Directory(
      p.join(profileRoot.path, 'qigong_media'),
    ).create();
    final mediaFile = File(p.join(mediaRoot.path, 'asset.bin'));
    await mediaFile.writeAsBytes(<int>[1, 2, 3, 4], flush: true);
    const digest = DartSha256DigestService();
    final hash = await digest.digestFile(mediaFile);
    final database = sqlite3.open(databaseFile.path);
    database.execute(
      '''INSERT INTO qigong_media_assets (
        id, sha256, managed_relative_path, original_file_name,
        mime_type, byte_size, caption, alt_text, created_at_utc_us
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      <Object?>[
        'media.synthetic.01',
        hash,
        'qigong_media/asset.bin',
        'asset.bin',
        'application/octet-stream',
        4,
        '',
        '',
        DateTime.utc(2026, 7, 31).microsecondsSinceEpoch,
      ],
    );
    database.close();
    final service = QigongCompleteBackupService(
      profileRoot: profileRoot,
      sourceDatabaseFile: databaseFile,
      backupRoot: backupRoot,
    );
    return _QigongFixture(
      root: root,
      profileRoot: profileRoot,
      backupRoot: backupRoot,
      databaseFile: databaseFile,
      mediaRoot: mediaRoot,
      mediaFile: mediaFile,
      service: service,
    );
  }

  Future<void> dispose() => root.delete(recursive: true);
}

final class _TestQigongLifecycle
    implements QigongCompleteRestoreRuntimeLifecycle {
  _TestQigongLifecycle(
    this.databaseFile, {
    this.reopenFailures = 0,
    this.validationFailures = 0,
  });

  final File databaseFile;
  int reopenFailures;
  int validationFailures;
  Database? _database;
  int closeCount = 0;
  int reopenCount = 0;
  int validateCount = 0;
  int rehydrateCount = 0;
  int leaveCount = 0;

  void openInitial() => _database = sqlite3.open(databaseFile.path);

  @override
  Future<void> enterMaintenance() async {}

  @override
  Future<void> close() async {
    closeCount += 1;
    _database?.close();
    _database = null;
  }

  @override
  Future<void> reopen() async {
    reopenCount += 1;
    if (reopenFailures > 0) {
      reopenFailures -= 1;
      throw StateError('synthetic reopen failure');
    }
    _database = sqlite3.open(databaseFile.path);
  }

  @override
  Future<void> validateBasicRead() async {
    validateCount += 1;
    if (validationFailures > 0) {
      validationFailures -= 1;
      throw StateError('synthetic validation failure');
    }
    expect(_database?.select('SELECT 1').single.values.single, 1);
  }

  @override
  Future<void> rehydrate() async {
    rehydrateCount += 1;
  }

  @override
  Future<void> leaveMaintenance() async {
    leaveCount += 1;
  }

  void dispose() {
    _database?.close();
    _database = null;
  }
}
