import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/core/runtime/ryn_runtime_services.dart';
import 'package:ryn_universe_os_core/features/people/domain/person_core_models.dart';
import 'package:ryn_universe_os_core/features/study_os/application/study_operations_controller.dart';
import 'package:ryn_universe_os_core/features/study_os/domain/study_operations_models.dart';

void main() {
  late RynAppDatabase database;
  late RynRuntimeServices services;
  late StudyOperationsController controller;

  setUp(() async {
    database = RynAppDatabase(NativeDatabase.memory());
    services = RynRuntimeServices(database);
    await services.people.createPerson(_person('p.a', '사람 A'));
    await services.people.createPerson(_person('p.b', '사람 B'));
    await services.studyOperations.saveSession(
      _record(
        id: 's.tarot',
        title: '타로 심화 실습',
        date: DateTime.utc(2026, 8, 2, 9),
        track: StudyTrack.tarot,
        status: StudySessionStatus.completed,
        personId: 'p.a',
        attendance: StudyAttendanceStatus.attended,
      ),
    );
    await services.studyOperations.saveSession(
      _record(
        id: 's.saju',
        title: '사주 기초 운영',
        date: DateTime.utc(2026, 9, 3, 10),
        track: StudyTrack.saju,
        status: StudySessionStatus.planned,
        personId: 'p.b',
        attendance: StudyAttendanceStatus.absent,
      ),
    );
    controller = StudyOperationsController(
      repository: services.studyOperations,
      peopleRepository: services.people,
    );
    await controller.bootstrap();
    await _settleStreams();
  });

  tearDown(() async {
    controller.dispose();
    await database.close();
  });

  test('track status Person attendance date text and sort filters compose', () {
    controller.updateFilter(
      StudySessionFilter(
        query: '심화',
        track: StudyTrack.tarot,
        status: StudySessionStatus.completed,
        personId: 'p.a',
        attendance: StudyAttendanceStatus.attended,
        from: DateTime(2026, 8, 2),
        to: DateTime(2026, 8, 2),
      ),
    );
    expect(controller.filteredSessions.map((item) => item.session.id), ['s.tarot']);

    controller.updateFilter(
      const StudySessionFilter(sortOrder: StudySortOrder.oldest),
    );
    expect(
      controller.filteredSessions.map((item) => item.session.id),
      ['s.tarot', 's.saju'],
    );
  });

  test('saved selection opens the exact persisted aggregate', () async {
    expect(await controller.selectSession('s.saju'), isTrue);
    expect(controller.selectedRecord?.session.title, '사주 기초 운영');
    expect(controller.selectedRecord?.participants.single.personId, 'p.b');
  });
}

Future<void> _settleStreams() => Future<void>.delayed(const Duration(milliseconds: 20));

final _now = DateTime.utc(2026, 8, 1, 9);

Person _person(String id, String name) => Person(
  id: id,
  displayName: name,
  status: 'active',
  createdAt: _now,
  updatedAt: _now,
);

StudySessionRecord _record({
  required String id,
  required String title,
  required DateTime date,
  required StudyTrack track,
  required StudySessionStatus status,
  required String personId,
  required StudyAttendanceStatus attendance,
}) => StudySessionRecord(
  session: StudySession(
    id: id,
    title: title,
    occurredAt: date,
    timezoneOffsetMinutes: 540,
    location: '합성 공간',
    track: track,
    status: status,
    summary: '운영 키워드',
    progress: StudyProgressStatus.inProgress,
    createdAt: _now,
    updatedAt: _now,
  ),
  participants: [
    StudySessionParticipant(personId: personId, attendance: attendance),
  ],
);
