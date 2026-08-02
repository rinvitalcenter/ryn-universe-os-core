import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/core/repositories/repository_result.dart';
import 'package:ryn_universe_os_core/core/runtime/ryn_runtime_services.dart';
import 'package:ryn_universe_os_core/core/theme/ryn_tokens.dart';
import 'package:ryn_universe_os_core/features/people/domain/person_core_models.dart';
import 'package:ryn_universe_os_core/features/people/domain/person_core_repositories.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_calculation_engine.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_models.dart';
import 'package:ryn_universe_os_core/features/saju/presentation/saju_manse_page.dart';

void main() {
  late RynAppDatabase database;
  late RynRuntimeServices services;
  late _WidgetPeopleRepository peopleRepository;

  setUp(() {
    database = RynAppDatabase(NativeDatabase.memory());
    services = RynRuntimeServices(database);
    peopleRepository = _WidgetPeopleRepository();
  });

  tearDown(() => database.close());

  Future<void> seedPerson({String name = '합성 회원 A', bool self = false}) async {
    final now = DateTime.utc(2026, 7, 31);
    final person = Person(
      id: 'person.synthetic.saju',
      displayName: name,
      status: PersonStatuses.active,
      relationshipSummary: '사주 스터디 회원',
      createdAt: now,
      updatedAt: now,
    );
    await services.people.createPerson(person);
    peopleRepository.people = [person];
    if (self) peopleRepository.selfPerson = person;
    if (self) {
      await services.personRoles.addRole(
        PersonRole(
          id: 'role.synthetic.saju.self',
          personId: 'person.synthetic.saju',
          roleType: PersonRoleTypes.self,
          effectiveFrom: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  Future<void> pumpPage(
    WidgetTester tester, {
    Size size = const Size(1440, 900),
    ThemeMode themeMode = ThemeMode.light,
    double textScale = 1,
  }) async {
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: RynTheme.light(
          fontFamily: 'Pretendard',
          fontFamilyFallback: const ['Segoe UI', 'Malgun Gothic'],
        ),
        darkTheme: RynTheme.dark(
          fontFamily: 'Pretendard',
          fontFamilyFallback: const ['Segoe UI', 'Malgun Gothic'],
        ),
        themeMode: themeMode,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: SajuMansePage(
            peopleRepository: peopleRepository,
            snapshotRepository: services.sajuSnapshots,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> selectMale(WidgetTester tester) async {
    await tapVisible(tester, find.byKey(const Key('saju-gender')));
    await tester.tap(find.text('남성').last);
    await tester.pumpAndSettle();
  }

  testWidgets('empty state asks for a Person without developer placeholders', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('사주 만세력'), findsOneWidget);
    expect(find.text('먼저 명식을 연결할 사람을 선택해 주세요.'), findsOneWidget);
    expect(find.textContaining('repository'), findsNothing);
    expect(find.textContaining('enum'), findsNothing);
    expect(find.byKey(const Key('saju-calculate')), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('saju-calculate')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets(
    'Person, solar/lunar/leap and known/unknown input are interactive',
    (tester) async {
      await seedPerson(self: true);
      await pumpPage(tester);

      expect(find.text('합성 회원 A'), findsWidgets);
      expect(find.byKey(const Key('saju-person-selector')), findsOneWidget);
      expect(find.byKey(const Key('saju-calendar-solar')), findsOneWidget);
      expect(find.byKey(const Key('saju-calendar-lunar')), findsOneWidget);
      expect(find.byKey(const Key('saju-lunar-leap')), findsNothing);

      await tester.tap(find.byKey(const Key('saju-calendar-lunar')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('saju-lunar-leap')), findsOneWidget);

      await tapVisible(tester, find.byKey(const Key('saju-hour-unknown')));
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('saju-time-hour')))
            .enabled,
        isFalse,
      );
      expect(find.text('기준 지역: 서울'), findsOneWidget);
      expect(find.text('시간대: 한국 표준시'), findsOneWidget);
      expect(find.text('야자시: 적용 안 함'), findsOneWidget);
    },
  );

  testWidgets(
    'known-time calculation presents four pillars and policy detail',
    (tester) async {
      await seedPerson();
      await pumpPage(tester);

      await tester.enterText(find.byKey(const Key('saju-date-year')), '2024');
      await tester.enterText(find.byKey(const Key('saju-date-month')), '2');
      await tester.enterText(find.byKey(const Key('saju-date-day')), '10');
      await tapVisible(tester, find.byKey(const Key('saju-calculate')));

      expect(find.byKey(const Key('saju-pillar-hour')), findsOneWidget);
      expect(find.byKey(const Key('saju-pillar-day')), findsOneWidget);
      expect(find.byKey(const Key('saju-pillar-month')), findsOneWidget);
      expect(find.byKey(const Key('saju-pillar-year')), findsOneWidget);
      expect(find.text('네 기둥과 여덟 글자'), findsOneWidget);
      expect(find.text('양력 2024-02-10'), findsOneWidget);
      expect(find.textContaining('음력'), findsWidgets);
      expect(find.text('계산 기준'), findsOneWidget);

      await tapVisible(tester, find.byKey(const Key('saju-policy-details')));
      expect(find.text('천을귀인 V5.20 호환 정책'), findsOneWidget);
      expect(find.text('입춘 기준 연주'), findsOneWidget);
      expect(find.text('월절입 기준 월주'), findsOneWidget);
      expect(find.textContaining('proprietary algorithm'), findsOneWidget);
    },
  );

  testWidgets(
    'unknown hour has an explicit three-pillar result without fake stem',
    (tester) async {
      await seedPerson();
      await pumpPage(tester);
      await tester.enterText(find.byKey(const Key('saju-date-year')), '2024');
      await tester.enterText(find.byKey(const Key('saju-date-month')), '2');
      await tester.enterText(find.byKey(const Key('saju-date-day')), '10');
      await tapVisible(tester, find.byKey(const Key('saju-hour-unknown')));
      await tapVisible(tester, find.byKey(const Key('saju-calculate')));

      expect(
        find.descendant(
          of: find.byKey(const Key('saju-pillar-hour')),
          matching: find.text('시간 미상'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('시주를 제외한 세 기둥'), findsOneWidget);
      expect(find.byKey(const Key('saju-pillar-hour-stem')), findsNothing);
      expect(find.byKey(const Key('saju-pillar-hour-branch')), findsNothing);
    },
  );

  testWidgets(
    'result board shows independent element tiles and ten-god relations',
    (tester) async {
      await seedPerson();
      await pumpPage(tester);
      await tapVisible(tester, find.byKey(const Key('saju-calculate')));

      Finder inside(String key, String text) =>
          find.descendant(of: find.byKey(Key(key)), matching: find.text(text));

      expect(inside('saju-pillar-hour-stem', '癸'), findsOneWidget);
      expect(inside('saju-pillar-hour-stem', '수'), findsOneWidget);
      expect(inside('saju-pillar-hour-stem-relation', '정관'), findsOneWidget);
      expect(inside('saju-pillar-hour-branch', '巳'), findsOneWidget);
      expect(inside('saju-pillar-hour-branch', '화'), findsOneWidget);
      expect(inside('saju-pillar-hour-branch-relation', '비견'), findsOneWidget);

      expect(inside('saju-pillar-day-stem', '丙'), findsOneWidget);
      expect(inside('saju-pillar-day-stem', '화'), findsOneWidget);
      expect(inside('saju-pillar-day-stem-relation', '일간(나)'), findsOneWidget);
      expect(inside('saju-pillar-day-branch', '寅'), findsOneWidget);
      expect(inside('saju-pillar-day-branch', '목'), findsOneWidget);
      expect(inside('saju-pillar-day-branch-relation', '편인'), findsOneWidget);

      expect(inside('saju-pillar-month-stem-relation', '비견'), findsOneWidget);
      expect(inside('saju-pillar-month-branch-relation', '정관'), findsOneWidget);
      expect(inside('saju-pillar-year-stem-relation', '상관'), findsOneWidget);
      expect(inside('saju-pillar-year-branch-relation', '비견'), findsOneWidget);

      final hanja = tester.widget<Text>(inside('saju-pillar-day-stem', '丙'));
      expect(hanja.style?.fontFamily, 'ChosunGs');
      expect(hanja.style?.fontFamilyFallback, contains('Malgun Gothic'));
    },
  );

  testWidgets('rollover interval fails closed with user-facing copy', (
    tester,
  ) async {
    await seedPerson();
    await pumpPage(tester);
    await tester.enterText(find.byKey(const Key('saju-date-year')), '2024');
    await tester.enterText(find.byKey(const Key('saju-date-month')), '2');
    await tester.enterText(find.byKey(const Key('saju-date-day')), '10');
    await tester.enterText(find.byKey(const Key('saju-time-hour')), '23');
    await tester.enterText(find.byKey(const Key('saju-time-minute')), '15');
    await tapVisible(tester, find.byKey(const Key('saju-calculate')));

    expect(find.text('현재 이 시간대의 자정 경계 정책을 확인 중입니다.'), findsOneWidget);
    expect(find.textContaining('unresolvedDayRollover'), findsNothing);
  });

  testWidgets('initial save appears in immutable history and can be selected', (
    tester,
  ) async {
    await seedPerson();
    await pumpPage(tester);
    await tester.enterText(find.byKey(const Key('saju-date-year')), '2024');
    await tester.enterText(find.byKey(const Key('saju-date-month')), '2');
    await tester.enterText(find.byKey(const Key('saju-date-day')), '10');
    await tapVisible(tester, find.byKey(const Key('saju-calculate')));

    expect(find.byKey(const Key('saju-save')), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('saju-save')));

    expect(find.text('저장됨'), findsWidgets);
    expect(find.text('Revision 1'), findsOneWidget);
    expect(find.byKey(const Key('saju-history-item-0')), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('saju-history-item-0')));
    expect(find.text('저장 당시의 명식을 표시하고 있습니다.'), findsOneWidget);
  });

  testWidgets(
    'persisted pillars derive ten gods on display without calculate action',
    (tester) async {
      await seedPerson();
      final snapshot =
          SajuCalculationEngine.production(
            utcNow: () => DateTime.utc(2026, 7, 31),
          ).calculate(
            SajuBirthInput.solar(
              date: const SajuLocalDate(1990, 1, 1),
              time: const SajuLocalTime(10, 30),
              gender: SajuGender.male,
            ),
          );
      final save = await services.sajuSnapshots.saveInitialSnapshot(
        snapshotId: 'snapshot.persisted.r2',
        personId: 'person.synthetic.saju',
        chartGroupId: 'chart.persisted.r2',
        snapshot: snapshot,
        createdAtUtcUs: DateTime.utc(2026, 7, 31).microsecondsSinceEpoch,
      );
      expect(save.isSuccess, isTrue);

      await pumpPage(tester);

      expect(find.text('저장됨 · R1'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('saju-pillar-day-stem-relation')),
          matching: find.text('일간(나)'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('saju-pillar-day-branch-relation')),
          matching: find.text('편인'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('Daeun and Seun tabs expose a safe no-source state', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.byKey(const Key('saju-tab-natal')), findsOneWidget);
    expect(find.byKey(const Key('saju-tab-daeun')), findsOneWidget);
    expect(find.byKey(const Key('saju-tab-seun')), findsOneWidget);

    await tapVisible(tester, find.byKey(const Key('saju-tab-daeun')));
    expect(
      find.text('대운과 세운을 확인하려면 먼저 원국을 계산하거나 저장된 명식을 선택해 주세요.'),
      findsOneWidget,
    );
    expect(find.textContaining('Revision 0'), findsNothing);
  });

  testWidgets('unsaved natal source renders eleven Daeun and ten Seun labels', (
    tester,
  ) async {
    await seedPerson();
    await pumpPage(tester, size: const Size(1600, 1000));
    await tester.enterText(find.byKey(const Key('saju-date-year')), '1990');
    await tester.enterText(find.byKey(const Key('saju-date-month')), '3');
    await tester.enterText(find.byKey(const Key('saju-date-day')), '15');
    await selectMale(tester);
    await tapVisible(tester, find.byKey(const Key('saju-calculate')));

    await tapVisible(tester, find.byKey(const Key('saju-tab-daeun')));
    expect(find.text('저장 전 원국'), findsWidgets);
    expect(find.text('대운수 7 · 순행'), findsOneWidget);
    expect(find.text('첫 시작 7세 · 1996년'), findsOneWidget);
    expect(find.byKey(const Key('saju-daeun-timeline-scroll')), findsOneWidget);
    for (var sequence = 1; sequence <= 11; sequence++) {
      expect(find.byKey(Key('saju-daeun-cycle-$sequence')), findsOneWidget);
    }

    await tapVisible(tester, find.byKey(const Key('saju-daeun-provenance')));
    expect(find.text('계산 기준과 출처'), findsWidgets);
    expect(find.textContaining('rynSajuDaeunSeun'), findsOneWidget);
    expect(find.textContaining('annualSexagenaryLabelOnlyV1'), findsOneWidget);
    await tester.tap(find.text('닫기'));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.byKey(const Key('saju-daeun-cycle-2')));
    expect(find.text('2번째 대운'), findsOneWidget);

    await tapVisible(tester, find.byKey(const Key('saju-tab-seun')));
    for (var year = 2006; year <= 2015; year++) {
      expect(find.byKey(Key('saju-seun-year-$year')), findsOneWidget);
    }
    expect(find.byKey(const Key('saju-seun-disclaimer')), findsOneWidget);
    expect(find.text('올해 위치'), findsOneWidget);
    expect(find.textContaining('특정 날짜의 활성 세운을 판정하지 않습니다'), findsOneWidget);
    expect(find.text('활성'), findsNothing);
    expect(find.text('적용 중'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('save promotes provenance without losing Daeun selection', (
    tester,
  ) async {
    await seedPerson();
    await pumpPage(tester, size: const Size(1600, 1000));
    await tester.enterText(find.byKey(const Key('saju-date-year')), '1990');
    await tester.enterText(find.byKey(const Key('saju-date-month')), '3');
    await tester.enterText(find.byKey(const Key('saju-date-day')), '15');
    await selectMale(tester);
    await tapVisible(tester, find.byKey(const Key('saju-calculate')));
    await tapVisible(tester, find.byKey(const Key('saju-tab-daeun')));
    await tester.tap(find.byKey(const Key('saju-daeun-cycle-2')));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.byKey(const Key('saju-tab-natal')));
    await tapVisible(tester, find.byKey(const Key('saju-save')));
    await tapVisible(tester, find.byKey(const Key('saju-tab-daeun')));

    expect(find.text('Revision 1'), findsWidgets);
    expect(find.text('2번째 대운'), findsOneWidget);
    expect(find.text('저장 전 원국'), findsNothing);
  });

  testWidgets('derived workspace is responsive in dark and scaled desktop', (
    tester,
  ) async {
    await seedPerson();
    await pumpPage(
      tester,
      size: const Size(1280, 800),
      themeMode: ThemeMode.dark,
      textScale: 1.2,
    );
    await selectMale(tester);
    await tapVisible(tester, find.byKey(const Key('saju-calculate')));
    await tapVisible(tester, find.byKey(const Key('saju-tab-daeun')));

    expect(find.byKey(const Key('saju-daeun-timeline-scroll')), findsOneWidget);
    expect(find.byKey(const Key('saju-daeun-detail')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tapVisible(tester, find.byKey(const Key('saju-tab-seun')));
    expect(find.byKey(const Key('saju-seun-detail')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unknown-time stable result warns and still shows 11 cycles', (
    tester,
  ) async {
    await seedPerson();
    await pumpPage(tester, size: const Size(1600, 1000));
    await tester.enterText(find.byKey(const Key('saju-date-year')), '2023');
    await tester.enterText(find.byKey(const Key('saju-date-month')), '6');
    await tester.enterText(find.byKey(const Key('saju-date-day')), '15');
    await tapVisible(tester, find.byKey(const Key('saju-hour-unknown')));
    await selectMale(tester);
    await tapVisible(tester, find.byKey(const Key('saju-calculate')));
    await tapVisible(tester, find.byKey(const Key('saju-tab-daeun')));

    expect(
      find.textContaining('해당 날짜의 분 단위 후보에서 대운수가 동일하게 계산되어'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('saju-daeun-cycle-11')), findsOneWidget);
  });

  testWidgets('ambiguous Daeun fails while annual Seun remains available', (
    tester,
  ) async {
    await seedPerson();
    await pumpPage(tester, size: const Size(1600, 1000));
    await tester.enterText(find.byKey(const Key('saju-date-year')), '2023');
    await tester.enterText(find.byKey(const Key('saju-date-month')), '6');
    await tester.enterText(find.byKey(const Key('saju-date-day')), '10');
    await tapVisible(tester, find.byKey(const Key('saju-hour-unknown')));
    await selectMale(tester);
    await tapVisible(tester, find.byKey(const Key('saju-calculate')));
    await tapVisible(tester, find.byKey(const Key('saju-tab-daeun')));

    expect(
      find.text('출생시간에 따라 대운수가 달라질 수 있어 현재 대운 결과를 확정할 수 없습니다.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('saju-daeun-timeline-scroll')), findsNothing);

    await tapVisible(tester, find.byKey(const Key('saju-tab-seun')));
    expect(find.byKey(const Key('saju-seun-year-2023')), findsOneWidget);
    expect(find.byKey(const Key('saju-seun-disclaimer')), findsOneWidget);
  });

  testWidgets('forward horizon fails closed without blocking Seun', (
    tester,
  ) async {
    await seedPerson();
    await pumpPage(tester, size: const Size(1600, 1000));
    await tester.enterText(find.byKey(const Key('saju-date-year')), '2050');
    await tester.enterText(find.byKey(const Key('saju-date-month')), '12');
    await tester.enterText(find.byKey(const Key('saju-date-day')), '20');
    await selectMale(tester);
    await tapVisible(tester, find.byKey(const Key('saju-calculate')));
    await tapVisible(tester, find.byKey(const Key('saju-tab-daeun')));

    expect(find.text('현재 절입 계산 지원 범위를 넘어 대운수를 계산할 수 없습니다.'), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('saju-tab-seun')));
    expect(find.byKey(const Key('saju-seun-year-2050')), findsOneWidget);
  });

  testWidgets('light/dark, text scale and desktop widths have no overflow', (
    tester,
  ) async {
    await seedPerson();
    for (final config in <(Size, ThemeMode, double)>[
      (const Size(1280, 800), ThemeMode.light, 1.0),
      (const Size(1920, 1009), ThemeMode.dark, 1.0),
      (const Size(1600, 1000), ThemeMode.light, 1.35),
    ]) {
      await pumpPage(
        tester,
        size: config.$1,
        themeMode: config.$2,
        textScale: config.$3,
      );
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('saju-calculate')), findsOneWidget);
      expect(find.byKey(const Key('saju-workspace-scroll')), findsOneWidget);
    }
  });
}

final class _WidgetPeopleRepository implements PersonRepository {
  List<Person> people = const [];
  Person? selfPerson;

  @override
  Stream<List<Person>> watchPeople({bool includeArchived = false}) =>
      Stream.value(people);

  @override
  Future<RepositoryResult<Person?>> findActiveSelfPerson() async =>
      RepositoryResult.success(selfPerson);

  @override
  Future<RepositoryResult<Person>> createPerson(Person person) async =>
      RepositoryResult.success(person);

  @override
  Future<RepositoryResult<Person>> getPerson(String id) async =>
      RepositoryResult.failure(
        const RepositoryError(
          code: RepositoryErrorCode.notFound,
          safeMessage: 'not found',
        ),
      );

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
