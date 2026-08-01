import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/repositories/repository_result.dart';
import 'package:ryn_universe_os_core/features/people/domain/person_core_models.dart';
import 'package:ryn_universe_os_core/features/people/domain/person_core_repositories.dart';
import 'package:ryn_universe_os_core/features/saju/application/saju_manse_controller.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_calculation_engine.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_models.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_snapshot_repository.dart';

void main() {
  late _FakePeopleRepository people;
  late _FakeSnapshotRepository snapshots;
  late SajuManseController controller;
  var calculationCalls = 0;
  final engine = SajuCalculationEngine.production(
    utcNow: () => DateTime.utc(2026, 7, 31, 9),
  );

  SajuChartSnapshot calculate(SajuBirthInput input) {
    calculationCalls += 1;
    return engine.calculate(input);
  }

  setUp(() {
    people = _FakePeopleRepository();
    snapshots = _FakeSnapshotRepository();
    calculationCalls = 0;
    controller = SajuManseController(
      peopleRepository: people,
      snapshotRepository: snapshots,
      calculationExecutor: calculate,
      now: () => DateTime.utc(2026, 7, 31, 9),
      idFactory: (prefix) => '$prefix.test-id',
    );
  });

  tearDown(() async {
    await controller.stop();
    await people.close();
  });

  test('initial state is input-ready without a selected Person', () {
    expect(controller.phase, SajuMansePhase.empty);
    expect(controller.selectedPerson, isNull);
    expect(controller.activePeople, isEmpty);
    expect(controller.currentCalculatedSnapshot, isNull);
    expect(controller.savedSnapshots, isEmpty);
    expect(controller.canCalculate, isFalse);
  });

  test(
    'start filters inactive and archived people and prefers active self',
    () async {
      final self = _person('person.self', '나의 기록');
      people.selfPerson = self;
      controller.start();
      people.emit([
        _person('person.inactive', '비활성', status: PersonStatuses.inactive),
        _person('person.archived', '보관됨', archived: true),
        _person('person.member', '스터디 회원'),
        self,
      ]);
      await pumpEventQueue(times: 5);

      expect(controller.activePeople.map((person) => person.id), [
        'person.member',
        'person.self',
      ]);
      expect(controller.selectedPerson?.id, 'person.self');
      expect(snapshots.loadedPersonIds, contains('person.self'));
    },
  );

  test('Person selection loads latest immutable snapshots', () async {
    final member = _person('person.member', '스터디 회원');
    final persisted = _persisted(
      engine,
      personId: member.id,
      snapshotId: 'snapshot.saved',
    );
    snapshots.byPerson[member.id] = [persisted];
    controller.start();
    people.emit([member]);
    await pumpEventQueue(times: 5);

    expect(controller.selectedPerson, member);
    expect(controller.savedSnapshots, [persisted]);
    expect(controller.currentPersistedSnapshot, persisted);
    expect(controller.phase, SajuMansePhase.resultSaved);
    expect(
      calculationCalls,
      0,
      reason: 'persisted history must not recalculate',
    );
  });

  test(
    'solar, lunar, leap, known and unknown draft actions are immutable inputs',
    () {
      controller.updateCalendarType(SajuCalendarType.koreanLunar);
      controller.setLunarLeapMonth(true);
      controller.updateBirthDate(const SajuLocalDate(2024, 4, 8));
      controller.updateBirthTime(const SajuLocalTime(14, 25));
      controller.updateGender(SajuGender.female);

      expect(controller.draft.calendarType, SajuCalendarType.koreanLunar);
      expect(controller.draft.lunarLeapMonth, isTrue);
      expect(controller.draft.birthDate, const SajuLocalDate(2024, 4, 8));
      expect(controller.draft.birthTime, const SajuLocalTime(14, 25));
      expect(controller.draft.gender, SajuGender.female);

      controller.setHourUnknown(true);
      expect(controller.draft.hourUnknown, isTrue);
      expect(controller.draft.toDomainInput().localTime, isNull);
      controller.updateCalendarType(SajuCalendarType.solar);
      expect(controller.draft.lunarLeapMonth, isFalse);
    },
  );

  test(
    'calculate maps supported range and rollover failures to safe Korean copy',
    () async {
      controller.start();
      people.emit([_person('person.1', '회원')]);
      await pumpEventQueue(times: 3);

      controller.updateBirthDate(const SajuLocalDate(1989, 12, 31));
      await controller.calculate();
      expect(controller.phase, SajuMansePhase.error);
      expect(controller.errorMessage, '지원 가능한 날짜 범위를 벗어났습니다.');

      controller.updateBirthDate(const SajuLocalDate(2024, 2, 10));
      controller.updateBirthTime(const SajuLocalTime(23, 15));
      await controller.calculate();
      expect(controller.errorMessage, '현재 이 시간대의 자정 경계 정책을 확인 중입니다.');
    },
  );

  test(
    'known-time calculation executes once and produces an unsaved board',
    () async {
      controller.start();
      people.emit([_person('person.1', '회원')]);
      await pumpEventQueue(times: 3);
      controller.updateBirthDate(const SajuLocalDate(2024, 2, 10));
      controller.updateBirthTime(const SajuLocalTime(10, 30));

      await Future.wait([controller.calculate(), controller.calculate()]);

      expect(calculationCalls, 1);
      expect(controller.phase, SajuMansePhase.resultUnsaved);
      expect(controller.currentCalculatedSnapshot?.hourPillar, isNotNull);
      expect(controller.canSave, isTrue);
    },
  );

  test(
    'minimum supported lunar date is validated after solar conversion',
    () async {
      controller.start();
      people.emit([_person('person.1', '회원')]);
      await pumpEventQueue(times: 3);
      controller.updateCalendarType(SajuCalendarType.koreanLunar);
      controller.updateBirthDate(const SajuLocalDate(1989, 12, 5));
      controller.updateBirthTime(const SajuLocalTime(10, 30));

      await controller.calculate();

      expect(calculationCalls, 1);
      expect(controller.phase, SajuMansePhase.resultUnsaved);
      expect(
        controller.currentCalculatedSnapshot?.convertedSolarDate,
        const SajuLocalDate(1990, 1, 1),
      );
    },
  );

  test('unknown-time calculation preserves no fake hour pillar', () async {
    controller.start();
    people.emit([_person('person.1', '회원')]);
    await pumpEventQueue(times: 3);
    controller.updateBirthDate(const SajuLocalDate(2024, 2, 10));
    controller.setHourUnknown(true);

    await controller.calculate();

    expect(controller.currentCalculatedSnapshot?.hourUnknown, isTrue);
    expect(controller.currentCalculatedSnapshot?.hourPillar, isNull);
    expect(controller.noticeMessage, contains('시주를 제외한 세 기둥'));
  });

  test(
    'calculation exception is mapped without exposing enum or detail',
    () async {
      final failing = SajuManseController(
        peopleRepository: people,
        snapshotRepository: snapshots,
        calculationExecutor: (_) => throw const SajuCalculationException(
          code: SajuErrorCode.invalidLunarLeapMonth,
          userMessage: 'raw-domain-message',
          detail: 'secret-enum-detail',
        ),
      );
      addTearDown(failing.stop);
      failing.start();
      people.emit([_person('person.1', '회원')]);
      await pumpEventQueue(times: 3);

      await failing.calculate();

      expect(failing.errorMessage, '해당 연월에는 선택한 윤달이 존재하지 않습니다.');
      expect(failing.errorMessage, isNot(contains('raw-domain-message')));
      expect(failing.errorMessage, isNot(contains('secret-enum-detail')));
    },
  );

  test(
    'initial save uses repository-owned revision and refreshes history',
    () async {
      controller.start();
      people.emit([_person('person.1', '회원')]);
      await pumpEventQueue(times: 3);
      controller.updateBirthDate(const SajuLocalDate(2024, 2, 10));
      await controller.calculate();

      final saved = _persisted(
        engine,
        personId: 'person.1',
        snapshotId: 'saju-snapshot.test-id',
      );
      snapshots.saveResult = SajuSnapshotResult.success(saved);
      snapshots.byPerson['person.1'] = [saved];
      await controller.save();

      expect(snapshots.saveCalls, 1);
      expect(snapshots.lastSavePersonId, 'person.1');
      expect(snapshots.lastSaveChartGroupId, 'saju-chart.test-id');
      expect(controller.phase, SajuMansePhase.resultSaved);
      expect(controller.currentPersistedSnapshot?.revisionNumber, 1);
    },
  );

  test(
    'duplicate and persistence save failures use safe user messages',
    () async {
      controller.start();
      people.emit([_person('person.1', '회원')]);
      await pumpEventQueue(times: 3);
      controller.updateBirthDate(const SajuLocalDate(2024, 2, 10));
      await controller.calculate();

      snapshots.saveResult = SajuSnapshotResult.failed(
        SajuSnapshotFailureCode.duplicateSnapshot,
        'raw duplicate database detail',
      );
      await controller.save();
      expect(controller.errorMessage, '동일한 명식이 이미 저장돼 있습니다.');

      snapshots.saveResult = SajuSnapshotResult.failed(
        SajuSnapshotFailureCode.persistenceFailure,
        'raw sqlite detail',
      );
      await controller.save();
      expect(controller.errorMessage, '명식을 저장하지 못했습니다. 다시 시도해 주세요.');
    },
  );

  test(
    'Person switch clears unsaved result and saved selection never recalculates',
    () async {
      final first = _person('person.1', '첫 회원');
      final second = _person('person.2', '둘째 회원');
      final saved = _persisted(
        engine,
        personId: second.id,
        snapshotId: 'snapshot.2',
      );
      snapshots.byPerson[second.id] = [saved];
      controller.start();
      people.emit([first, second]);
      await pumpEventQueue(times: 3);
      await controller.calculate();
      expect(controller.currentCalculatedSnapshot, isNotNull);

      await controller.selectPerson(second.id);
      controller.selectSavedSnapshot(saved.id);

      expect(controller.selectedPerson, second);
      expect(controller.currentCalculatedSnapshot, isNull);
      expect(controller.currentPersistedSnapshot, saved);
      expect(calculationCalls, 1);
    },
  );
}

Person _person(
  String id,
  String name, {
  String status = PersonStatuses.active,
  bool archived = false,
}) {
  final now = DateTime.utc(2026, 7, 31);
  return Person(
    id: id,
    displayName: name,
    status: status,
    archivedAt: archived ? now : null,
    createdAt: now,
    updatedAt: now,
  );
}

SajuPersistedSnapshot _persisted(
  SajuCalculationEngine engine, {
  required String personId,
  required String snapshotId,
}) => SajuPersistedSnapshot(
  id: snapshotId,
  personId: personId,
  sourceBirthProfileId: null,
  chartGroupId: 'chart.$snapshotId',
  revisionNumber: 1,
  revisionReason: SajuRevisionReason.initial,
  createdAtUtcUs: 1,
  inputFingerprintSha256: 'a' * 64,
  calculationSignatureSha256: 'b' * 64,
  snapshot: engine.calculate(
    SajuBirthInput.solar(
      date: const SajuLocalDate(2024, 2, 10),
      time: const SajuLocalTime(10, 30),
      gender: SajuGender.female,
    ),
  ),
);

final class _FakePeopleRepository implements PersonRepository {
  final _controller = StreamController<List<Person>>.broadcast();
  Person? selfPerson;

  void emit(List<Person> people) => _controller.add(people);
  Future<void> close() => _controller.close();

  @override
  Stream<List<Person>> watchPeople({bool includeArchived = false}) =>
      _controller.stream;

  @override
  Future<RepositoryResult<Person?>> findActiveSelfPerson() async =>
      RepositoryResult.success(selfPerson);

  @override
  Future<RepositoryResult<Person>> getPerson(String id) async =>
      RepositoryResult.failure(
        const RepositoryError(
          code: RepositoryErrorCode.notFound,
          safeMessage: 'not found',
        ),
      );

  @override
  Future<RepositoryResult<Person>> createPerson(Person person) async =>
      RepositoryResult.success(person);

  @override
  Future<RepositoryResult<Person>> updatePerson(Person person) async =>
      RepositoryResult.success(person);

  @override
  Future<RepositoryResult<Person>> archivePerson(
    String id, {
    required DateTime at,
  }) => throw UnimplementedError();

  @override
  Future<RepositoryResult<Person>> restorePerson(
    String id, {
    required DateTime at,
  }) => throw UnimplementedError();

  @override
  Future<RepositoryResult<bool>> erasePerson(String id) async =>
      RepositoryResult.success(true);
}

final class _FakeSnapshotRepository implements SajuSnapshotRepository {
  final Map<String, List<SajuPersistedSnapshot>> byPerson = {};
  final List<String> loadedPersonIds = [];
  int saveCalls = 0;
  String? lastSavePersonId;
  String? lastSaveChartGroupId;
  SajuSnapshotResult<SajuPersistedSnapshot>? saveResult;

  @override
  Future<SajuSnapshotResult<List<SajuPersistedSnapshot>>>
  listSnapshotsForPerson(String personId) async {
    loadedPersonIds.add(personId);
    return SajuSnapshotResult.success(byPerson[personId] ?? const []);
  }

  @override
  Future<SajuSnapshotResult<SajuPersistedSnapshot?>> getLatestSnapshotForPerson(
    String personId,
  ) async =>
      SajuSnapshotResult.success((byPerson[personId] ?? const []).firstOrNull);

  @override
  Future<SajuSnapshotResult<SajuPersistedSnapshot>> saveInitialSnapshot({
    required String snapshotId,
    required String personId,
    String? sourceBirthProfileId,
    required String chartGroupId,
    required SajuChartSnapshot snapshot,
    required int createdAtUtcUs,
  }) async {
    saveCalls += 1;
    lastSavePersonId = personId;
    lastSaveChartGroupId = chartGroupId;
    return saveResult ??
        SajuSnapshotResult.failed(
          SajuSnapshotFailureCode.persistenceFailure,
          'not configured',
        );
  }

  @override
  Future<SajuSnapshotResult<SajuPersistedSnapshot>> createRevision({
    required String snapshotId,
    required String personId,
    String? sourceBirthProfileId,
    required String chartGroupId,
    required int expectedCurrentRevisionNumber,
    required SajuRevisionReason revisionReason,
    required SajuChartSnapshot snapshot,
    required int createdAtUtcUs,
  }) => throw UnimplementedError();

  @override
  Future<SajuSnapshotResult<SajuPersistedSnapshot>> getSnapshotById(
    String id,
  ) => throw UnimplementedError();

  @override
  Stream<List<SajuPersistedSnapshot>> watchSnapshotsForPerson(
    String personId,
  ) => const Stream.empty();
}
