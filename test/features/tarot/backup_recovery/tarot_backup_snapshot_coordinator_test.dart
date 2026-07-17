import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/application/tarot_backup_snapshot_coordinator.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/domain/tarot_backup_operation_state.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_sqlite_online_backup_service.dart';

import '../../../support/tarot_backup_recovery_fixture.dart';

void main() {
  late TarotBackupRecoveryFixture fixture;

  tearDown(() async {
    await fixture.dispose();
  });

  TarotBackupSnapshotCoordinator coordinator({
    TarotSqliteOnlineBackupService service =
        const TarotSqliteOnlineBackupService(),
  }) => TarotBackupSnapshotCoordinator(
    onlineBackupService: service,
    clock: () => DateTime.utc(2026, 7, 17, 1, 2, 3),
    operationIdGenerator: () => 'a1b2c3d4',
  );

  test('end-to-end snapshot returns only final verified package', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final progress = <TarotBackupProgress>[];

    final result = await coordinator().createVerifiedBackup(
      sourceDatabasePath: fixture.sourceFile.path,
      resolvedPaths: fixture.resolvedPaths(),
      sourceProfileEvidence:
          const TarotBackupSourceProfileEvidence.syntheticQa(),
      applicationVersion: '1.0.0+1',
      onProgress: progress.add,
    );

    expect(progress.map((item) => item.stage), <TarotBackupStage>[
      TarotBackupStage.preparing,
      TarotBackupStage.snapshotting,
      TarotBackupStage.verifying,
      TarotBackupStage.succeeded,
    ]);
    expect(result.finalReadbackVerified, isTrue);
    expect(result.finalDirectory.existsSync(), isTrue);
    expect(result.manifest.tableRowCounts['tarot_readings'], 1);
    expect(result.manifest.readingIdCount, 1);
    expect(result.manifest.unsupportedTableRowsZero, isTrue);
  });

  test(
    'unsupported table failure emits failed and leaves no final artifact',
    () async {
      fixture = await TarotBackupRecoveryFixture.create();
      final db = fixture.openSource();
      db.execute(
        "INSERT INTO app_settings (key, value_type, redaction_state, updated_at) "
        "VALUES ('synthetic', 'string', 'none_required', 0)",
      );
      fixture.release(db);
      final progress = <TarotBackupProgress>[];

      await expectLater(
        coordinator().createVerifiedBackup(
          sourceDatabasePath: fixture.sourceFile.path,
          resolvedPaths: fixture.resolvedPaths(),
          sourceProfileEvidence:
              const TarotBackupSourceProfileEvidence.syntheticQa(),
          applicationVersion: '1.0.0+1',
          onProgress: progress.add,
        ),
        throwsA(isA<TarotBackupCoordinatorException>()),
      );
      expect(progress.last.stage, TarotBackupStage.failed);
      expect(
        fixture.backupRoot.listSync().whereType<Directory>().where(
          (directory) => directory.path.endsWith('.rynbackup'),
        ),
        isEmpty,
      );
    },
  );

  test(
    'backup failure releases source and cleans incomplete artifact',
    () async {
      fixture = await TarotBackupRecoveryFixture.create();
      final service = TarotSqliteOnlineBackupService(
        onlineBackup: (_, _, _) async {
          throw StateError('SYNTHETIC_PRIVATE_QUESTION');
        },
      );
      final progress = <TarotBackupProgress>[];

      await expectLater(
        coordinator(service: service).createVerifiedBackup(
          sourceDatabasePath: fixture.sourceFile.path,
          resolvedPaths: fixture.resolvedPaths(),
          sourceProfileEvidence:
              const TarotBackupSourceProfileEvidence.syntheticQa(),
          applicationVersion: '1.0.0+1',
          onProgress: progress.add,
        ),
        throwsA(
          isA<TarotBackupCoordinatorException>().having(
            (error) => error.toString(),
            'safe error',
            isNot(contains('SYNTHETIC_PRIVATE_QUESTION')),
          ),
        ),
      );
      expect(progress.last.stage, TarotBackupStage.failed);
      final source = fixture.openSource();
      expect(source.select('SELECT 1').single.values.single, 1);
      fixture.release(source);
      expect(fixture.backupRoot.listSync(), isEmpty);
    },
  );

  test(
    'manifest checksum filenames and errors contain no sensitive text',
    () async {
      fixture = await TarotBackupRecoveryFixture.create();

      final result = await coordinator().createVerifiedBackup(
        sourceDatabasePath: fixture.sourceFile.path,
        resolvedPaths: fixture.resolvedPaths(),
        sourceProfileEvidence:
            const TarotBackupSourceProfileEvidence.syntheticQa(),
        applicationVersion: '1.0.0+1',
      );
      final allText = StringBuffer()
        ..write(
          await File(
            '${result.finalDirectory.path}/manifest.json',
          ).readAsString(),
        )
        ..write(
          await File(
            '${result.finalDirectory.path}/checksums/sha256.txt',
          ).readAsString(),
        )
        ..write(result.finalDirectory.path);
      final lower = allText.toString().toLowerCase();
      for (final forbidden in <String>[
        'synthetic_question',
        'synthetic_interpretation',
        'synthetic_card',
        'synthetic-r1',
      ]) {
        expect(lower, isNot(contains(forbidden)));
      }
      expect(
        jsonDecode(
          await File(
            '${result.finalDirectory.path}/manifest.json',
          ).readAsString(),
        ),
        isA<Map<String, Object?>>(),
      );
    },
  );

  test('observer exceptions never change verified success', () async {
    for (final throwingStage in <TarotBackupStage>[
      TarotBackupStage.preparing,
      TarotBackupStage.snapshotting,
      TarotBackupStage.verifying,
      TarotBackupStage.succeeded,
    ]) {
      fixture = await TarotBackupRecoveryFixture.create();
      final history = <TarotBackupStage>[];
      final result = await coordinator().createVerifiedBackup(
        sourceDatabasePath: fixture.sourceFile.path,
        resolvedPaths: fixture.resolvedPaths(),
        sourceProfileEvidence:
            const TarotBackupSourceProfileEvidence.syntheticQa(),
        applicationVersion: '1.0.0+1',
        onProgress: (progress) {
          history.add(progress.stage);
          if (progress.stage == throwingStage) throw StateError('observer');
        },
      );
      expect(result.finalReadbackVerified, isTrue);
      expect(
        history,
        isNot(
          containsAllInOrder(<TarotBackupStage>[
            TarotBackupStage.succeeded,
            TarotBackupStage.failed,
          ]),
        ),
      );
      await fixture.dispose();
    }
  });

  test('failed observer cannot replace original operation failure', () async {
    fixture = await TarotBackupRecoveryFixture.create();
    final service = TarotSqliteOnlineBackupService(
      onlineBackup: (_, _, _) async => throw StateError('original'),
    );
    await expectLater(
      coordinator(service: service).createVerifiedBackup(
        sourceDatabasePath: fixture.sourceFile.path,
        resolvedPaths: fixture.resolvedPaths(),
        sourceProfileEvidence:
            const TarotBackupSourceProfileEvidence.syntheticQa(),
        applicationVersion: '1.0.0+1',
        onProgress: (progress) {
          if (progress.stage == TarotBackupStage.failed) {
            throw StateError('observer');
          }
        },
      ),
      throwsA(isA<TarotBackupCoordinatorException>()),
    );
  });
}
