import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/features/saju/data/persistence/drift_saju_snapshot_repository.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_calculation_engine.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_models.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_snapshot_repository.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_backup_database_inspector.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late RynAppDatabase database;
  late DriftSajuSnapshotRepository repository;
  late SajuCalculationEngine engine;

  setUp(() async {
    database = RynAppDatabase(NativeDatabase.memory());
    repository = DriftSajuSnapshotRepository(database);
    engine = SajuCalculationEngine.production(
      utcNow: () => DateTime.utc(2026, 7, 31),
    );
    await _insertPerson(database, 'person.1');
  });

  tearDown(() => database.close());

  test('initial save and revision preserve an immutable linear chain', () async {
    final firstSnapshot = _calculate(engine, const SajuLocalDate(2024, 2, 10));
    final initial = await repository.saveInitialSnapshot(
      snapshotId: 'snapshot.1',
      personId: 'person.1',
      chartGroupId: 'chart.1',
      snapshot: firstSnapshot,
      createdAtUtcUs: 0,
    );

    expect(initial.isSuccess, isTrue, reason: initial.failure?.safeMessage);
    expect(initial.value!.revisionNumber, 1);
    expect(initial.value!.revisionReason, SajuRevisionReason.initial);

    final secondSnapshot = _calculate(engine, const SajuLocalDate(2024, 2, 11));
    final revision = await repository.createRevision(
      snapshotId: 'snapshot.2',
      personId: 'person.1',
      chartGroupId: 'chart.1',
      expectedCurrentRevisionNumber: 1,
      revisionReason: SajuRevisionReason.inputCorrected,
      snapshot: secondSnapshot,
      createdAtUtcUs: 1,
    );

    expect(revision.isSuccess, isTrue);
    expect(revision.value!.revisionNumber, 2);
    final firstAfter = await repository.getSnapshotById('snapshot.1');
    expect(firstAfter.value!.snapshot.convertedSolarDate, const SajuLocalDate(2024, 2, 10));
    expect(firstAfter.value!.revisionNumber, 1);

    final listed = await repository.listSnapshotsForPerson('person.1');
    expect(listed.value!.map((record) => record.revisionNumber), [2, 1]);
    final latest = await repository.getLatestSnapshotForPerson('person.1');
    expect(latest.value!.id, 'snapshot.2');
  });

  test('watch emits Person snapshots after an append', () async {
    final emissions = <List<SajuPersistedSnapshot>>[];
    final subscription = repository
        .watchSnapshotsForPerson('person.1')
        .listen(emissions.add);
    addTearDown(subscription.cancel);

    final saved = await repository.saveInitialSnapshot(
      snapshotId: 'snapshot.watch',
      personId: 'person.1',
      chartGroupId: 'chart.watch',
      snapshot: _calculate(engine, const SajuLocalDate(2024, 3, 1)),
      createdAtUtcUs: 1,
    );
    expect(saved.isSuccess, isTrue, reason: saved.failure?.safeMessage);
    await pumpEventQueue(times: 5);

    expect(emissions, isNotEmpty);
    expect(emissions.last.single.id, 'snapshot.watch');
  });

  test('missing Person and invalid Birth Profile ownership fail without rows', () async {
    final snapshot = _calculate(engine, const SajuLocalDate(2024, 4, 1));
    final missing = await repository.saveInitialSnapshot(
      snapshotId: 'snapshot.missing',
      personId: 'person.missing',
      chartGroupId: 'chart.missing',
      snapshot: snapshot,
      createdAtUtcUs: 1,
    );
    expect(missing.failure?.code, SajuSnapshotFailureCode.personNotFound);

    await _insertPerson(database, 'person.2');
    await _insertBirthProfile(database, id: 'birth.2', personId: 'person.2');
    final mismatch = await repository.saveInitialSnapshot(
      snapshotId: 'snapshot.mismatch',
      personId: 'person.1',
      sourceBirthProfileId: 'birth.2',
      chartGroupId: 'chart.mismatch',
      snapshot: snapshot,
      createdAtUtcUs: 1,
    );
    expect(
      mismatch.failure!.code,
      SajuSnapshotFailureCode.birthProfilePersonMismatch,
    );
    expect(await _count(database), 0);
  });

  test('backup inspector revalidates canonical Saju payload digests', () async {
    final root = await Directory.systemTemp.createTemp('ryn-saju-inspector-');
    final file = File('${root.path}${Platform.pathSeparator}saju.sqlite');
    final fileDatabase = RynAppDatabase(NativeDatabase(file));
    var fileDatabaseOpen = true;
    try {
      await fileDatabase.customStatement(
        '''INSERT INTO persons (
          id, display_name, status, relationship_summary,
          created_at_utc_us, updated_at_utc_us
        ) VALUES (?, ?, 'active', '', 0, 0)''',
        <Object?>['person-a', '합성 인물 A'],
      );
      final fileRepository = DriftSajuSnapshotRepository(fileDatabase);
      final saved = await fileRepository.saveInitialSnapshot(
        snapshotId: 'snapshot-a',
        personId: 'person-a',
        chartGroupId: 'chart-a',
        snapshot: _calculate(
          SajuCalculationEngine.production(
            utcNow: () => DateTime.utc(2026, 7, 31),
          ),
          const SajuLocalDate(2024, 2, 10),
        ),
        createdAtUtcUs: 0,
      );
      expect(saved.isSuccess, isTrue, reason: saved.failure?.safeMessage);
      await fileDatabase.close();
      fileDatabaseOpen = false;

      final evidence = const TarotBackupDatabaseInspector().inspectVerified(
        file.path,
      );
      expect(evidence.tableRowCounts['saju_chart_snapshots'], 1);

      final raw = sqlite3.open(file.path);
      raw.execute(
        "UPDATE saju_chart_snapshots SET calculation_signature_sha256 = ?",
        <Object?>['b' * 64],
      );
      raw.close();
      expect(
        () => const TarotBackupDatabaseInspector().inspectVerified(file.path),
        throwsA(
          isA<TarotBackupInspectionException>().having(
            (error) => error.code,
            'code',
            'aggregate_invariant_failed',
          ),
        ),
      );
    } finally {
      if (fileDatabaseOpen) await fileDatabase.close();
      if (root.existsSync()) await root.delete(recursive: true);
    }
  });

  test('duplicate immutable save and stale concurrent revision fail closed', () async {
    final initialSnapshot = _calculate(engine, const SajuLocalDate(2024, 5, 1));
    final initial = await repository.saveInitialSnapshot(
      snapshotId: 'snapshot.initial',
      personId: 'person.1',
      chartGroupId: 'chart.concurrent',
      snapshot: initialSnapshot,
      createdAtUtcUs: 1,
    );
    expect(initial.isSuccess, isTrue, reason: initial.failure?.safeMessage);

    final duplicate = await repository.saveInitialSnapshot(
      snapshotId: 'snapshot.duplicate',
      personId: 'person.1',
      chartGroupId: 'chart.duplicate',
      snapshot: initialSnapshot,
      createdAtUtcUs: 2,
    );
    expect(duplicate.failure?.code, SajuSnapshotFailureCode.duplicateSnapshot);

    final nextA = _calculate(engine, const SajuLocalDate(2024, 5, 2));
    final nextB = _calculate(engine, const SajuLocalDate(2024, 5, 3));
    final results = await Future.wait([
      repository.createRevision(
        snapshotId: 'snapshot.revision.a',
        personId: 'person.1',
        chartGroupId: 'chart.concurrent',
        expectedCurrentRevisionNumber: 1,
        revisionReason: SajuRevisionReason.inputCorrected,
        snapshot: nextA,
        createdAtUtcUs: 3,
      ),
      repository.createRevision(
        snapshotId: 'snapshot.revision.b',
        personId: 'person.1',
        chartGroupId: 'chart.concurrent',
        expectedCurrentRevisionNumber: 1,
        revisionReason: SajuRevisionReason.inputCorrected,
        snapshot: nextB,
        createdAtUtcUs: 3,
      ),
    ]);

    expect(results.where((result) => result.isSuccess), hasLength(1));
    expect(
      results.where((result) => !result.isSuccess).single.failure?.code,
      SajuSnapshotFailureCode.revisionConflict,
    );
    expect(await _count(database), 2);
  });
}

SajuChartSnapshot _calculate(
  SajuCalculationEngine engine,
  SajuLocalDate date,
) => engine.calculate(
  SajuBirthInput.solar(
    date: date,
    time: const SajuLocalTime(10, 0),
    gender: SajuGender.female,
  ),
  calculatedAt: DateTime.utc(2026, 7, 31),
);

Future<void> _insertPerson(RynAppDatabase database, String id) =>
    database.customStatement(
      "INSERT INTO persons (id, display_name, status, created_at_utc_us, updated_at_utc_us) VALUES ('$id', '합성 인물', 'active', 1, 1)",
    );

Future<void> _insertBirthProfile(
  RynAppDatabase database, {
  required String id,
  required String personId,
}) => database.customStatement(
  "INSERT INTO person_birth_profiles (id, person_id, revision_number, birth_date_precision, birth_time_precision, calendar_system, verification_state, created_at_utc_us) VALUES ('$id', '$personId', 1, 'exact', 'exact', 'solar', 'confirmed', 1)",
);

Future<int> _count(RynAppDatabase database) async =>
    (await database
            .customSelect(
              'SELECT count(*) AS total FROM saju_chart_snapshots',
            )
            .getSingle())
        .read<int>('total');
