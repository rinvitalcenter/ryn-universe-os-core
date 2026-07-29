import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/core/runtime/ryn_runtime_services.dart';
import 'package:ryn_universe_os_core/features/people/domain/person_core_models.dart';
import 'package:ryn_universe_os_core/features/study_os/domain/study_operations_models.dart';

void main() {
  late RynAppDatabase database;
  late RynRuntimeServices services;

  setUp(() async {
    database = RynAppDatabase(NativeDatabase.memory());
    services = RynRuntimeServices(database);
    await services.people.createPerson(_person('person.active.a', '활성 사람 A'));
    await services.people.createPerson(_person('person.active.b', '활성 사람 B'));
    await services.people.createPerson(
      _person('person.archived', '보관 사람', archivedAt: _createdAt),
    );
  });

  tearDown(() => database.close());

  test('creates loads and updates one transactional Study aggregate', () async {
    final material = _material('material.guide', '타로 실습 교안');
    expect((await services.studyOperations.saveMaterial(material)).isSuccess, isTrue);

    final original = _record(
      participants: const [
        StudySessionParticipant(
          personId: 'person.active.a',
          attendance: StudyAttendanceStatus.attended,
          note: '첫 참석',
        ),
      ],
      materialIds: const ['material.guide'],
    );
    expect((await services.studyOperations.saveSession(original)).isSuccess, isTrue);

    final loaded = await services.studyOperations.loadSession(original.session.id);
    expect(loaded.value?.session.title, '합성 타로 운영 회차');
    expect(loaded.value?.participants.single.personId, 'person.active.a');
    expect(loaded.value?.materialIds, ['material.guide']);
    expect(loaded.value?.session.learningGoal, '3카드 흐름을 설명한다');
    expect(loaded.value?.session.coveredContent, '과거·현재·미래 실습');
    expect(loaded.value?.session.nextSteps, '역방향 사례 이어보기');

    final updated = original.copyWith(
      session: original.session.copyWith(
        title: '합성 타로 운영 회차 · 수정',
        status: StudySessionStatus.completed,
        progress: StudyProgressStatus.completed,
        updatedAt: _createdAt.add(const Duration(hours: 2)),
      ),
      participants: const [
        StudySessionParticipant(
          personId: 'person.active.a',
          attendance: StudyAttendanceStatus.late,
          note: '10분 지각',
          learningNote: '카드 연결이 자연스러움',
        ),
        StudySessionParticipant(
          personId: 'person.active.b',
          attendance: StudyAttendanceStatus.attended,
        ),
      ],
    );
    expect((await services.studyOperations.saveSession(updated)).isSuccess, isTrue);
    final reloaded = (await services.studyOperations.loadSession(original.session.id)).value!;
    expect(reloaded.session.title, contains('수정'));
    expect(reloaded.participants, hasLength(2));
    expect(reloaded.participants.first.attendance, StudyAttendanceStatus.late);
  });

  test('rejects duplicate participants and duplicate material relations', () async {
    final material = _material('material.duplicate', '중복 검사 자료');
    await services.studyOperations.saveMaterial(material);
    final duplicatePeople = _record(
      participants: const [
        StudySessionParticipant(personId: 'person.active.a'),
        StudySessionParticipant(personId: 'person.active.a'),
      ],
    );
    final peopleResult = await services.studyOperations.saveSession(duplicatePeople);
    expect(peopleResult.isFailure, isTrue);
    expect(await _count(database, 'study_sessions'), 0);
    expect(await _count(database, 'study_session_participants'), 0);

    final duplicateMaterials = _record(
      materialIds: const ['material.duplicate', 'material.duplicate'],
    );
    final materialResult = await services.studyOperations.saveSession(duplicateMaterials);
    expect(materialResult.isFailure, isTrue);
    expect(await _count(database, 'study_sessions'), 0);
    expect(await _count(database, 'study_session_materials'), 0);
  });

  test('excludes archived Person from new links but preserves historical attendance', () async {
    final historical = _record(
      participants: const [
        StudySessionParticipant(
          personId: 'person.active.a',
          attendance: StudyAttendanceStatus.attended,
        ),
      ],
    );
    expect((await services.studyOperations.saveSession(historical)).isSuccess, isTrue);
    await services.people.archivePerson(
      'person.active.a',
      at: _createdAt.add(const Duration(days: 1)),
    );

    final preserved = historical.copyWith(
      session: historical.session.copyWith(
        operationNotes: '보관 후 과거 기록 수정',
        updatedAt: _createdAt.add(const Duration(days: 2)),
      ),
      participants: const [
        StudySessionParticipant(
          personId: 'person.active.a',
          attendance: StudyAttendanceStatus.attended,
          note: '과거 참석 유지',
        ),
      ],
    );
    expect((await services.studyOperations.saveSession(preserved)).isSuccess, isTrue);

    final rejected = _record(
      id: 'session.archived.rejected',
      participants: const [
        StudySessionParticipant(personId: 'person.archived'),
      ],
    );
    expect((await services.studyOperations.saveSession(rejected)).isFailure, isTrue);
    expect(await _count(database, 'study_sessions'), 1);
  });

  test('material catalog reuses one material across sessions and relations stay unique', () async {
    final material = _material('material.shared', '공용 실습 자료');
    await services.studyOperations.saveMaterial(material);
    await services.studyOperations.saveSession(
      _record(id: 'session.a', materialIds: const ['material.shared']),
    );
    await services.studyOperations.saveSession(
      _record(id: 'session.b', materialIds: const ['material.shared']),
    );
    expect(await _count(database, 'study_materials'), 1);
    expect(await _count(database, 'study_session_materials'), 2);
  });

  test('watch summaries expose filter dimensions without Person display duplication', () async {
    await services.studyOperations.saveSession(
      _record(
        participants: const [
          StudySessionParticipant(
            personId: 'person.active.a',
            attendance: StudyAttendanceStatus.absent,
          ),
        ],
      ),
    );
    final summaries = await services.studyOperations.watchSessions().first;
    expect(summaries.single.participantIds, contains('person.active.a'));
    expect(summaries.single.attendanceStates, contains(StudyAttendanceStatus.absent));

    final columns = await database
        .customSelect('PRAGMA table_info(study_session_participants)')
        .get();
    final names = columns.map((row) => row.read<String>('name')).toSet();
    expect(names, contains('person_id'));
    expect(names, isNot(contains('display_name')));
    expect(names, isNot(contains('person_name')));
  });

  test('database constraints prevent orphan and duplicate relation writes', () async {
    await expectLater(
      database.customStatement(
        "INSERT INTO study_session_participants "
        "(session_id, person_id, attendance_status, created_at_utc_us, updated_at_utc_us) "
        "VALUES ('missing', 'person.active.a', 'planned', 1, 1)",
      ),
      throwsA(anything),
    );
    expect(await _count(database, 'study_session_participants'), 0);
  });
}

final _createdAt = DateTime.utc(2026, 8, 1, 9);

Person _person(String id, String name, {DateTime? archivedAt}) => Person(
    id: id,
    displayName: name,
    status: 'active',
    archivedAt: archivedAt,
    createdAt: _createdAt,
    updatedAt: archivedAt ?? _createdAt,
  );

StudyMaterial _material(String id, String title) => StudyMaterial(
    id: id,
    title: title,
    type: StudyMaterialType.handout,
    storageNote: '서재 A칸',
    description: '합성 자료',
    createdAt: _createdAt,
    updatedAt: _createdAt,
  );

StudySessionRecord _record({
    String id = 'session.synthetic.01',
    List<StudySessionParticipant> participants = const [],
    List<String> materialIds = const [],
  }) => StudySessionRecord(
    session: StudySession(
      id: id,
      title: '합성 타로 운영 회차',
      occurredAt: DateTime.utc(2026, 8, 3, 10),
      timezoneOffsetMinutes: 540,
      location: '합성 스튜디오',
      track: StudyTrack.tarot,
      status: StudySessionStatus.planned,
      summary: '3카드 리딩 실습',
      operationNotes: '진행 순서를 먼저 안내',
      learningGoal: '3카드 흐름을 설명한다',
      coveredContent: '과거·현재·미래 실습',
      progress: StudyProgressStatus.inProgress,
      nextSteps: '역방향 사례 이어보기',
      createdAt: _createdAt,
      updatedAt: _createdAt,
    ),
    participants: participants,
    materialIds: materialIds,
  );

Future<int> _count(RynAppDatabase database, String table) async {
  final row = await database
      .customSelect('SELECT count(*) AS total FROM $table')
      .getSingle();
  return row.read<int>('total');
}
