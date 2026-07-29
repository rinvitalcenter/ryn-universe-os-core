import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/core/repositories/repository_result.dart';
import 'package:ryn_universe_os_core/core/runtime/ryn_runtime_services.dart';
import 'package:ryn_universe_os_core/features/people/domain/person_core_models.dart';
import 'package:ryn_universe_os_core/features/people/domain/person_core_repositories.dart';
import 'package:ryn_universe_os_core/features/study_os/domain/study_operations_models.dart';
import 'package:ryn_universe_os_core/features/study_os/domain/study_operations_repository.dart';
import 'package:ryn_universe_os_core/features/study_os/study_os_shell.dart';

void main() {
  late RynAppDatabase database;
  late RynRuntimeServices services;
  final now = DateTime.utc(2026, 8, 1, 9);

  setUp(() async {
    database = RynAppDatabase(NativeDatabase.memory());
    services = RynRuntimeServices(database);
    for (var index = 1; index <= 4; index++) {
      await services.people.createPerson(
        _person('person.$index', '활성 회원 $index', now),
      );
    }
    await services.people.createPerson(
      _person('person.archived', '보관 회원', now, archivedAt: now),
    );
    await services.studyOperations.saveMaterial(
      StudyMaterial(
        id: 'material.guide',
        title: '타로 실습 교안',
        type: StudyMaterialType.handout,
        storageNote: '서재 A칸',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await services.studyOperations.saveMaterial(
      StudyMaterial(
        id: 'material.video',
        title: '사주 기초 영상',
        type: StudyMaterialType.video,
        url: 'https://example.invalid/synthetic',
        createdAt: now,
        updatedAt: now,
      ),
    );
  });

  tearDown(() => database.close());

  testWidgets('creates selects details and updates one session', (
    tester,
  ) async {
    await _pump(tester, services, now);

    expect(find.byKey(const Key('study-next-session-hero')), findsOneWidget);
    expect(find.text('운영의 다음을 한눈에'), findsOneWidget);
    await tester.tap(find.byKey(const Key('study-new-session')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('study-session-editor')), findsOneWidget);
    expect(find.text('보관 회원'), findsNothing);
    await tester.enterText(
      find.byKey(const Key('study-title-field')),
      '합성 통합 스터디',
    );
    await tester.enterText(
      find.byKey(const Key('study-location-field')),
      '합성 라운지',
    );
    await tester.tap(find.byKey(const Key('study-person-person.1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('타로 실습 교안'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('study-save-session')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('study-session-detail')), findsOneWidget);
    expect(find.text('합성 통합 스터디'), findsWidgets);
    expect(find.text('활성 회원 1'), findsOneWidget);
    expect(find.text('타로 실습 교안'), findsOneWidget);

    await tester.tap(find.byKey(const Key('study-edit-session')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('study-title-field')),
      '합성 통합 스터디 · 수정',
    );
    await tester.tap(find.byKey(const Key('study-save-session')));
    await tester.pumpAndSettle();
    expect(find.text('합성 통합 스터디 · 수정'), findsWidgets);
    expect(tester.takeException(), isNull);
    await _disposeStudy(tester);
  });

  testWidgets('required validation keeps editor values and prevents writes', (
    tester,
  ) async {
    await _pump(tester, services, now);
    await tester.tap(find.byKey(const Key('study-new-session')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('study-location-field')),
      '입력 보존 공간',
    );
    await tester.tap(find.byKey(const Key('study-save-session')));
    await tester.pumpAndSettle();

    expect(find.text('제목을 입력해 주세요.'), findsOneWidget);
    expect(find.text('입력 보존 공간'), findsOneWidget);
    expect(await _count(database, 'study_sessions'), 0);
    await _disposeStudy(tester);
  });

  testWidgets('registers reusable material from catalog', (tester) async {
    await _pump(tester, services, now);
    await tester.tap(find.text('자료').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('study-new-material')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('material-title-field')),
      '새 합성 도서',
    );
    await tester.tap(find.byKey(const Key('material-save-button')));
    await tester.pumpAndSettle();

    expect(find.text('새 합성 도서'), findsOneWidget);
    expect(await _count(database, 'study_materials'), 3);
    await _disposeStudy(tester);
  });

  testWidgets('renders loading state until the session stream emits', (
    tester,
  ) async {
    final sessionGate = StreamController<List<StudySessionSummary>>();
    addTearDown(sessionGate.close);
    await _pumpRepositories(
      tester,
      _SessionStreamStudyRepository(
        delegate: services.studyOperations,
        sessions: sessionGate.stream,
      ),
      services.people,
      now,
      settle: false,
    );
    await tester.pump();

    expect(find.byKey(const Key('study-loading-state')), findsOneWidget);
    expect(find.text('운영 기록을 불러오고 있습니다.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await _disposeStudy(tester);
  });

  testWidgets('renders safe error state with retry action', (tester) async {
    await _pumpRepositories(
      tester,
      _SessionStreamStudyRepository(
        delegate: services.studyOperations,
        sessions: Stream<List<StudySessionSummary>>.error(
          StateError('synthetic raw failure must stay hidden'),
        ),
      ),
      services.people,
      now,
    );

    expect(find.byKey(const Key('study-error-state')), findsOneWidget);
    expect(find.text('운영 기록을 불러오지 못했습니다.'), findsOneWidget);
    expect(find.byKey(const Key('study-retry-load')), findsOneWidget);
    expect(find.textContaining('synthetic raw failure'), findsNothing);
    await _disposeStudy(tester);
  });

  testWidgets('Light Dark and 1366 overflow smoke stay readable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1366, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final brightness in [Brightness.light, Brightness.dark]) {
      await _pump(
        tester,
        services,
        now,
        brightness: brightness,
        size: const Size(1366, 768),
      );
      expect(find.byKey(const Key('study-operations-page')), findsOneWidget);
      expect(find.text('운영의 다음을 한눈에'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await _disposeStudy(tester);
  });
}

Future<void> _pump(
  WidgetTester tester,
  RynRuntimeServices services,
  DateTime now, {
  Brightness brightness = Brightness.light,
  Size size = const Size(1440, 1000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: brightness, useMaterial3: true),
      home: Scaffold(
        body: StudyOsShell(
          repository: services.studyOperations,
          peopleRepository: services.people,
          now: () => now,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpRepositories(
  WidgetTester tester,
  StudyOperationsRepository repository,
  PersonRepository peopleRepository,
  DateTime now, {
  bool settle = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: StudyOsShell(
          repository: repository,
          peopleRepository: peopleRepository,
          now: () => now,
        ),
      ),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

Future<void> _disposeStudy(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  for (var index = 0; index < 6; index++) {
    await tester.pump(Duration.zero);
  }
}

Person _person(String id, String name, DateTime now, {DateTime? archivedAt}) =>
    Person(
      id: id,
      displayName: name,
      status: 'active',
      archivedAt: archivedAt,
      createdAt: now,
      updatedAt: archivedAt ?? now,
    );

Future<int> _count(RynAppDatabase database, String table) async =>
    (await database
            .customSelect('SELECT count(*) AS total FROM $table')
            .getSingle())
        .read<int>('total');

final class _SessionStreamStudyRepository implements StudyOperationsRepository {
  const _SessionStreamStudyRepository({
    required this.delegate,
    required this.sessions,
  });

  final StudyOperationsRepository delegate;
  final Stream<List<StudySessionSummary>> sessions;

  @override
  Stream<List<StudySessionSummary>> watchSessions() => sessions;

  @override
  Stream<List<StudyMaterial>> watchMaterials() => delegate.watchMaterials();

  @override
  Future<RepositoryResult<StudySessionRecord>> loadSession(String sessionId) =>
      delegate.loadSession(sessionId);

  @override
  Future<RepositoryResult<StudyMaterial>> saveMaterial(
    StudyMaterial material,
  ) => delegate.saveMaterial(material);

  @override
  Future<RepositoryResult<StudySessionRecord>> saveSession(
    StudySessionRecord record,
  ) => delegate.saveSession(record);
}
