import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/application/tarot_backup_snapshot_coordinator.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/application/tarot_restore_coordinator.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/domain/tarot_restore_operation_result.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_backup_database_inspector.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_restore_candidate_validator.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../support/tarot_backup_recovery_fixture.dart';

void main() {
  TarotBackupRecoveryFixture? fixture;
  _PersonRestoreLifecycle? lifecycle;

  tearDown(() async {
    lifecycle?.dispose();
    lifecycle = null;
    await fixture?.dispose();
    fixture = null;
  });

  Future<Map<String, int>> roundTrip({
    required bool includePerson,
    required bool includeTarot,
  }) async {
    fixture = await TarotBackupRecoveryFixture.create(
      validReading: includeTarot,
    );
    var database = fixture!.openSource();
    if (includePerson) fixture!.insertSyntheticPersonCore(database);
    fixture!.release(database);

    final package = await fixture!.createRestoreCandidate();

    database = fixture!.openSource();
    if (includePerson) {
      database.execute('PRAGMA foreign_keys = ON');
      database.execute(
        "DELETE FROM persons WHERE id = 'person.synthetic.study.01'",
      );
    }
    if (includeTarot) {
      fixture!.insertValidReading(database, id: 'synthetic-r2');
    }
    fixture!.release(database);

    lifecycle = _PersonRestoreLifecycle(fixture!.sourceFile)..openInitial();
    final coordinator = TarotRestoreCoordinator(
      candidateValidator: TarotRestoreCandidateValidator(
        inspectPath: (_) async => true,
      ),
      backupCoordinator: TarotBackupSnapshotCoordinator(
        clock: () => DateTime.utc(2026, 7, 17, 2, 3, 4),
        operationIdGenerator: () => 'b1c2d3e4',
      ),
    );
    final result = await coordinator.restore(
      candidatePackagePath: package.path,
      liveDatabasePath: fixture!.sourceFile.path,
      resolvedPaths: fixture!.resolvedPaths(inspectPath: (_) async => true),
      sourceProfileEvidence:
          const TarotBackupSourceProfileEvidence.syntheticQa(),
      applicationVersion: '1.0.0+1',
      operationId: 'deadbeef',
      lifecycle: lifecycle!,
    );

    expect(
      result.status,
      TarotRestoreOperationStatus.succeeded,
      reason: result.failureCode,
    );
    expect(lifecycle!.closeCount, 1);
    expect(lifecycle!.reopenCount, 1);
    expect(lifecycle!.validateCount, 1);
    return <String, int>{
      'persons': lifecycle!.count('persons'),
      'roles': lifecycle!.count('person_roles'),
      'birthProfiles': lifecycle!.count('person_birth_profiles'),
      'encounters': lifecycle!.count('encounters'),
      'notes': lifecycle!.count('encounter_notes'),
      'readings': lifecycle!.count('tarot_readings'),
    };
  }

  test(
    'Person-only schema v6 backup validates and restores synthetic rows',
    () async {
      final counts = await roundTrip(includePerson: true, includeTarot: false);

      expect(counts, <String, int>{
        'persons': 1,
        'roles': 1,
        'birthProfiles': 1,
        'encounters': 1,
        'notes': 1,
        'readings': 0,
      });
    },
  );

  test('Tarot-only schema v6 backup restore remains compatible', () async {
    final counts = await roundTrip(includePerson: false, includeTarot: true);

    expect(counts['persons'], 0);
    expect(counts['readings'], 1);
  });

  test(
    'mixed Person and Tarot schema v6 backup restores both domains',
    () async {
      final counts = await roundTrip(includePerson: true, includeTarot: true);

      expect(counts['persons'], 1);
      expect(counts['notes'], 1);
      expect(counts['readings'], 1);
    },
  );

  test(
    'schema v5 backup fails closed with explicit compatibility policy',
    () async {
      fixture = await TarotBackupRecoveryFixture.create(validReading: false);
      final database = fixture!.openSource();
      for (final table in const <String>[
        'encounter_notes',
        'encounters',
        'person_birth_profiles',
        'person_relationships',
        'person_roles',
        'persons',
      ]) {
        database.execute('DROP TABLE $table');
      }
      database.userVersion = 5;
      fixture!.release(database);

      expect(
        () => const TarotBackupDatabaseInspector().inspectVerified(
          fixture!.sourceFile.path,
        ),
        throwsA(
          isA<TarotBackupInspectionException>().having(
            (error) => error.code,
            'code',
            'schema_v5_restore_requires_v5_application',
          ),
        ),
      );
    },
  );

  test(
    'schema v6 restore rejects missing Person constraints and indexes',
    () async {
      fixture = await TarotBackupRecoveryFixture.create(validReading: false);
      var database = fixture!.openSource();
      database.execute('DROP INDEX person_roles_single_active_self');
      fixture!.release(database);

      expect(
        () => const TarotBackupDatabaseInspector().inspectVerified(
          fixture!.sourceFile.path,
        ),
        throwsA(
          isA<TarotBackupInspectionException>().having(
            (error) => error.code,
            'code',
            'schema_contract_mismatch',
          ),
        ),
      );

      await fixture!.dispose();
      fixture = await TarotBackupRecoveryFixture.create(validReading: false);
      database = fixture!.openSource();
      database.execute('DROP TABLE person_roles');
      database.execute('''CREATE TABLE person_roles (
      id TEXT NOT NULL PRIMARY KEY,
      person_id TEXT NOT NULL,
      role_type TEXT NOT NULL,
      effective_from_utc_us INTEGER NOT NULL,
      effective_to_utc_us INTEGER NULL,
      note TEXT NULL,
      created_at_utc_us INTEGER NOT NULL,
      updated_at_utc_us INTEGER NOT NULL
    )''');
      fixture!.release(database);

      expect(
        () => const TarotBackupDatabaseInspector().inspectVerified(
          fixture!.sourceFile.path,
        ),
        throwsA(
          isA<TarotBackupInspectionException>().having(
            (error) => error.code,
            'code',
            'schema_contract_mismatch',
          ),
        ),
      );
    },
  );
}

final class _PersonRestoreLifecycle implements TarotRestoreRuntimeLifecycle {
  _PersonRestoreLifecycle(this.liveFile);

  final File liveFile;
  Database? _database;
  int closeCount = 0;
  int reopenCount = 0;
  int validateCount = 0;

  void openInitial() {
    _database = sqlite3.open(liveFile.path);
  }

  int count(String table) =>
      _database!.select('SELECT count(*) FROM $table').single.values.single
          as int;

  @override
  Future<void> close() async {
    closeCount += 1;
    _database?.close();
    _database = null;
  }

  @override
  Future<void> reopen() async {
    reopenCount += 1;
    _database = sqlite3.open(liveFile.path);
  }

  @override
  Future<void> validateBasicRead() async {
    validateCount += 1;
    if (_database?.userVersion != 6) {
      throw StateError('synthetic schema read failed');
    }
    const TarotBackupDatabaseInspector().inspectVerified(liveFile.path);
  }

  void dispose() {
    _database?.close();
    _database = null;
  }
}
