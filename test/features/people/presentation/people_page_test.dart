import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/core/runtime/ryn_runtime_services.dart';
import 'package:ryn_universe_os_core/core/theme/ryn_tokens.dart';
import 'package:ryn_universe_os_core/features/people/domain/person_core_models.dart';
import 'package:ryn_universe_os_core/features/people/presentation/people_page.dart';

void main() {
  late RynAppDatabase database;
  late RynRuntimeServices services;

  setUp(() {
    database = RynAppDatabase(NativeDatabase.memory());
    services = RynRuntimeServices(database);
  });

  tearDown(() => database.close());

  Future<void> pumpPeople(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
    Size size = const Size(1280, 720),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        themeMode: themeMode,
        theme: RynTheme.light(
          fontFamily: 'Pretendard',
          fontFamilyFallback: const ['Segoe UI', 'Malgun Gothic'],
        ),
        darkTheme: RynTheme.dark(
          fontFamily: 'Pretendard',
          fontFamilyFallback: const ['Segoe UI', 'Malgun Gothic'],
        ),
        home: Scaffold(
          body: PeoplePage(
            peopleRepository: services.people,
            roleRepository: services.personRoles,
            groupRepository: services.personGroups,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
        .clearAllTestValues();
  });

  Future<void> seedPerson({
    required String id,
    required String name,
    required String relationship,
    required String roleType,
    required DateTime updatedAt,
  }) async {
    await services.people.createPerson(
      Person(
        id: id,
        displayName: name,
        status: PersonStatuses.active,
        relationshipSummary: relationship,
        createdAt: updatedAt,
        updatedAt: updatedAt,
      ),
    );
    await services.personRoles.addRole(
      PersonRole(
        id: 'role.$id',
        personId: id,
        roleType: roleType,
        effectiveFrom: updatedAt,
        createdAt: updatedAt,
        updatedAt: updatedAt,
      ),
    );
  }

  testWidgets(
    'People navigator searches filters counts clears and updates overview safely',
    (tester) async {
      await seedPerson(
        id: 'person.synthetic.family',
        name: '합성 가족 가람',
        relationship: '함께 사는 가족',
        roleType: PersonRoleTypes.family,
        updatedAt: DateTime.utc(2026, 7, 20, 9),
      );
      await seedPerson(
        id: 'person.synthetic.study',
        name: '합성 스터디 누리',
        relationship: '함께 공부하는 사람',
        roleType: PersonRoleTypes.studyMember,
        updatedAt: DateTime.utc(2026, 7, 20, 10),
      );
      await pumpPeople(tester);

      expect(find.byKey(const Key('people-search-field')), findsOneWidget);
      expect(
        find.byKey(const Key('people-primary-role-filter')),
        findsOneWidget,
      );
      expect(find.text('2명'), findsOneWidget);
      expect(
        find.byKey(const Key('person-detail-person.synthetic.study')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('people-search-field')),
        '가족',
      );
      await tester.pumpAndSettle();
      expect(find.text('1명'), findsOneWidget);
      expect(find.text('합성 가족 가람'), findsAtLeastNWidgets(1));
      expect(find.text('합성 스터디 누리'), findsNothing);
      expect(
        find.byKey(const Key('person-detail-person.synthetic.family')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('people-search-field')),
        '없는 사람',
      );
      await tester.pumpAndSettle();
      expect(find.text('검색 결과가 없습니다'), findsOneWidget);
      expect(find.text('0명'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('people-search-field')), '');
      await tester.tap(find.byKey(const Key('people-primary-role-filter')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('스터디 회원').last);
      await tester.pumpAndSettle();
      expect(find.text('1명'), findsOneWidget);
      expect(find.text('합성 스터디 누리'), findsAtLeastNWidgets(1));
      expect(find.text('합성 가족 가람'), findsNothing);

      await tester.tap(find.byKey(const Key('people-primary-role-filter')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('전체').last);
      await tester.pumpAndSettle();
      expect(find.text('2명'), findsOneWidget);
      expect(find.text('합성 가족 가람'), findsAtLeastNWidgets(1));
      expect(find.text('합성 스터디 누리'), findsAtLeastNWidgets(1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('People navigator remains usable at 1280x720 in light and dark', (
    tester,
  ) async {
    final baseTime = DateTime.utc(2026, 7, 20);
    for (var index = 0; index < 105; index += 1) {
      await seedPerson(
        id: 'person.synthetic.desktop.$index',
        name: '합성 데스크톱 인물 $index',
        relationship: '레이아웃 검증용 합성 관계 $index',
        roleType: PersonRoleTypes.practiceParticipant,
        updatedAt: baseTime.add(Duration(minutes: index)),
      );
    }

    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      await pumpPeople(tester, themeMode: theme);
      expect(find.byKey(const Key('people-search-field')), findsOneWidget);
      expect(
        find.byKey(const Key('people-primary-role-filter')),
        findsOneWidget,
      );
      expect(find.text('105명'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('people-search-field')),
        '인물 104',
      );
      await tester.pumpAndSettle();
      expect(find.text('1명'), findsOneWidget);
      expect(find.text('합성 데스크톱 인물 104'), findsAtLeastNWidgets(1));
      expect(tester.takeException(), isNull, reason: '$theme @ 1280x720');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });

  testWidgets(
    'custom group loop creates renames archives restores assigns filters and removes',
    (tester) async {
      await seedPerson(
        id: 'person.synthetic.groups',
        name: '테스트 인물 001',
        relationship: '그룹 UI 검증용 합성 관계',
        roleType: PersonRoleTypes.friend,
        updatedAt: DateTime.utc(2026, 7, 21, 10),
      );
      await pumpPeople(tester);

      expect(find.byKey(const Key('people-group-filter')), findsOneWidget);
      expect(find.byKey(const Key('people-no-groups')), findsOneWidget);
      expect(
        find.byKey(const Key('person-no-group-membership')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('people-group-manage')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('people-group-management-sheet')),
        findsOneWidget,
      );

      for (final name in ['테스트 그룹 A', '테스트 그룹 B']) {
        await tester.enterText(
          find.byKey(const Key('people-group-name-field')),
          name,
        );
        await tester.tap(find.byKey(const Key('people-group-create-action')));
        await tester.pumpAndSettle();
      }
      expect(find.text('테스트 그룹 A'), findsOneWidget);
      expect(find.text('테스트 그룹 B'), findsOneWidget);

      await tester.tap(find.byTooltip('그룹 이름 바꾸기').first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('people-group-rename-field')),
        '테스트 그룹 A 수정',
      );
      await tester.tap(find.byKey(const Key('people-group-rename-save')));
      await tester.pumpAndSettle();
      expect(find.text('테스트 그룹 A 수정'), findsOneWidget);

      await tester.tap(find.byTooltip('그룹 보관').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('people-group-archive-confirm')));
      await tester.pumpAndSettle();
      expect(find.text('테스트 그룹 A 수정'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, '복원'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('people-group-management-close')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('person-group-membership-action')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('person-group-membership-sheet')),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(CheckboxListTile, '테스트 그룹 A 수정'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(CheckboxListTile, '테스트 그룹 B'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('person-group-membership-close')));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InputChip, '테스트 그룹 A 수정'), findsOneWidget);
      expect(find.widgetWithText(InputChip, '테스트 그룹 B'), findsOneWidget);

      final removable = tester.widget<InputChip>(
        find.widgetWithText(InputChip, '테스트 그룹 B'),
      );
      removable.onDeleted!();
      await tester.pumpAndSettle();
      expect(find.widgetWithText(InputChip, '테스트 그룹 B'), findsNothing);

      await tester.tap(find.byKey(const Key('people-group-filter')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('테스트 그룹 A 수정 · 1명').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('people-search-field')),
        '일치하지 않는 합성 검색어',
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('people-group-no-results')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('empty add detail archive and restore happy path', (
    tester,
  ) async {
    await pumpPeople(tester);

    expect(find.byKey(const Key('people-page')), findsOneWidget);
    expect(find.text('아직 이어갈 사람이 없습니다'), findsOneWidget);
    expect(find.byKey(const Key('people-add-action')), findsOneWidget);

    await tester.tap(find.byKey(const Key('people-add-action')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('people-create-sheet')), findsOneWidget);

    await tester.tap(find.byKey(const Key('people-save-action')));
    await tester.pump();
    expect(find.text('이름을 입력해 주세요.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('people-display-name-field')),
      '합성 스터디 회원',
    );
    await tester.enterText(
      find.byKey(const Key('people-relationship-field')),
      'SYNTHETIC_RELATIONSHIP_NOTE',
    );
    await tester.tap(find.byKey(const Key('people-role-friend')));
    await tester.tap(find.byKey(const Key('people-role-studyMember')));
    await tester.tap(find.byKey(const Key('people-save-action')));
    await tester.pumpAndSettle();

    expect(find.text('합성 스터디 회원'), findsAtLeastNWidgets(1));
    expect(find.text('친구'), findsAtLeastNWidgets(1));
    expect(find.text('스터디 회원'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('person-section-overview')), findsOneWidget);
    expect(find.text('SYNTHETIC_RELATIONSHIP_NOTE'), findsAtLeastNWidgets(1));

    await tester.tap(find.byKey(const Key('person-archive-action')));
    await tester.pumpAndSettle();
    expect(find.text('이 사람을 보관할까요?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('person-archive-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('아직 이어갈 사람이 없습니다'), findsOneWidget);
    await tester.tap(find.byKey(const Key('people-show-archived')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('people-archived-list')), findsOneWidget);
    expect(find.text('합성 스터디 회원'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('person-restore-action')), findsOneWidget);
    await tester.tap(find.byKey(const Key('person-restore-action')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('people-active-list')), findsOneWidget);
    expect(find.text('합성 스터디 회원'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('person-archive-action')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets(
    'People keeps intentional list and detail panels without outer document scroll',
    (tester) async {
      await seedPerson(
        id: 'person.synthetic.panels',
        name: '합성 패널 검증',
        relationship: '독립 패널 검증 관계',
        roleType: PersonRoleTypes.friend,
        updatedAt: DateTime.utc(2026, 7, 27, 12),
      );
      await pumpPeople(tester, size: const Size(1400, 900));

      final page = find.byKey(const Key('people-page'));
      final master = find.byKey(const Key('people-master-panel'));
      final detail = find.byKey(
        const Key('person-detail-person.synthetic.panels'),
      );
      final verticalScroll = find.byWidgetPredicate(
        (widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.vertical,
      );
      expect(find.ancestor(of: page, matching: verticalScroll), findsNothing);
      expect(
        find.descendant(of: master, matching: verticalScroll),
        findsOneWidget,
      );
      expect(
        find.descendant(of: detail, matching: verticalScroll),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('People filters remain reachable at 2.0 text scale', (
    tester,
  ) async {
    await seedPerson(
      id: 'person.synthetic.text-scale',
      name: '합성 확대 검증',
      relationship: '접근성 확대 검증 관계',
      roleType: PersonRoleTypes.friend,
      updatedAt: DateTime.utc(2026, 7, 27, 13),
    );
    await pumpPeople(tester, size: const Size(1400, 900), textScale: 2);

    expect(find.byKey(const Key('people-search-field')), findsOneWidget);
    expect(
      find.byKey(const Key('people-primary-role-filter')).hitTestable(),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('people-group-filter')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets(
    'loaded People uses deterministic compact panels from 260 through 719',
    (tester) async {
      final now = DateTime.utc(2026, 7, 27, 14);
      await seedPerson(
        id: 'person.synthetic.compact.a',
        name: '합성 좁은 화면 A',
        relationship: '좁은 화면 선택 검증 A',
        roleType: PersonRoleTypes.friend,
        updatedAt: now,
      );
      await seedPerson(
        id: 'person.synthetic.compact.b',
        name: '합성 좁은 화면 B',
        relationship: '좁은 화면 선택 검증 B',
        roleType: PersonRoleTypes.studyMember,
        updatedAt: now.add(const Duration(minutes: 1)),
      );

      for (final width in [260.0, 419.0, 420.0, 719.0, 720.0]) {
        await pumpPeople(tester, size: Size(width, 900));

        final page = find.byKey(const Key('people-page'));
        final outerDocumentScroll = find.ancestor(
          of: page,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SingleChildScrollView &&
                widget.scrollDirection == Axis.vertical,
          ),
        );
        expect(outerDocumentScroll, findsNothing, reason: 'width=$width');
        expect(
          find.byKey(const Key('people-compact-master-mode')),
          findsOneWidget,
          reason: 'width=$width',
        );
        expect(
          find.byKey(const Key('people-search-field')).hitTestable(),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('people-primary-role-filter')).hitTestable(),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('people-group-filter')).hitTestable(),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const Key('person-list-item-person.synthetic.compact.a')),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('people-compact-detail-mode')),
          findsOneWidget,
          reason: 'width=$width',
        );
        expect(
          find.byKey(const Key('person-detail-person.synthetic.compact.a')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('people-compact-back-to-master')).hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull, reason: 'width=$width');

        await tester.tap(
          find.byKey(const Key('people-compact-back-to-master')),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('people-compact-master-mode')),
          findsOneWidget,
        );
        expect(
          find.byKey(
            const Key('person-selected-indicator-person.synthetic.compact.a'),
          ),
          findsOneWidget,
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'width=$width after back',
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    },
  );

  testWidgets(
    'loaded People keeps wide independent panels at content width 720',
    (tester) async {
      await seedPerson(
        id: 'person.synthetic.boundary.720',
        name: '합성 720 경계',
        relationship: '넓은 패널 경계 검증',
        roleType: PersonRoleTypes.friend,
        updatedAt: DateTime.utc(2026, 7, 27, 15),
      );
      await pumpPeople(tester, size: const Size(770, 900));

      expect(
        find.byKey(const Key('people-wide-master-detail')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('people-master-panel')), findsOneWidget);
      expect(
        find.byKey(const Key('person-detail-person.synthetic.boundary.720')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('people-compact-master-mode')), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('light and dark People scenes remain usable at desktop widths', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 7, 20);
    await services.people.createPerson(
      Person(
        id: 'person.synthetic.01',
        displayName: '합성 인물 A',
        status: PersonStatuses.active,
        createdAt: now,
        updatedAt: now,
      ),
    );

    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final width in [1280.0, 1000.0, 860.0]) {
        await pumpPeople(tester, themeMode: theme, size: Size(width, 720));
        expect(find.byKey(const Key('people-page')), findsOneWidget);
        expect(find.byKey(const Key('people-add-action')), findsOneWidget);
        expect(find.text('합성 인물 A'), findsAtLeastNWidgets(1));
        expect(tester.takeException(), isNull, reason: '$theme @ $width');
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    }
  });

  testWidgets(
    'People reference uses neutral surfaces blue interaction and flat chrome',
    (tester) async {
      final now = DateTime.utc(2026, 7, 21);
      await seedPerson(
        id: 'person.synthetic.visual',
        name: '합성 시각 기준 인물',
        relationship: 'Apple-neutral 시각 검증용 합성 관계',
        roleType: PersonRoleTypes.friend,
        updatedAt: now,
      );

      for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
        await pumpPeople(tester, themeMode: themeMode);

        final pageContext = tester.element(
          find.byKey(const Key('people-page')),
        );
        final semantic = Theme.of(pageContext).extension<RynSemanticColors>()!;

        BoxDecoration decorationFor(Key key) =>
            tester.widget<Container>(find.byKey(key)).decoration!
                as BoxDecoration;

        final workspace = decorationFor(const Key('people-page'));
        final master = decorationFor(const Key('people-master-panel'));
        final detail = decorationFor(
          const Key('person-detail-person.synthetic.visual'),
        );
        final selected =
            tester
                    .widget<AnimatedContainer>(
                      find.byKey(
                        const Key(
                          'person-list-surface-person.synthetic.visual',
                        ),
                      ),
                    )
                    .decoration!
                as BoxDecoration;
        final indicator = decorationFor(
          const Key('person-selected-indicator-person.synthetic.visual'),
        );

        expect(workspace.color, semantic.appCanvas);
        expect(master.color, semantic.secondarySurface);
        expect(detail.color, semantic.primarySurface);
        expect(selected.color, semantic.selectedState);
        expect(selected.border!.top.color, semantic.primaryAction);
        expect(indicator.color, semantic.primaryAction);
        expect([
          workspace.color,
          master.color,
          detail.color,
          selected.color,
        ], isNot(contains(semantic.peopleIdentity)));

        final addButton = tester.widget<FilledButton>(
          find.byKey(const Key('people-add-action')),
        );
        expect(
          addButton.style?.backgroundColor?.resolve(<WidgetState>{}),
          semantic.primaryAction,
        );

        final tabs = tester.widget<TabBar>(
          find.byKey(const Key('people-detail-tabs')),
        );
        expect(tabs.indicatorColor, semantic.primaryAction);
        expect(tabs.labelColor, semantic.primaryAction);

        final focusedBorder =
            Theme.of(pageContext).inputDecorationTheme.focusedBorder!
                as OutlineInputBorder;
        expect(focusedBorder.borderSide.color, semantic.focusRing);
        expect(focusedBorder.borderSide.width, 2);

        await tester.tap(find.byKey(const Key('people-search-field')));
        await tester.pump();
        final editable = tester.widget<EditableText>(
          find.descendant(
            of: find.byKey(const Key('people-search-field')),
            matching: find.byType(EditableText),
          ),
        );
        expect(editable.focusNode.hasFocus, isTrue);

        for (final element
            in find
                .descendant(
                  of: find.byKey(const Key('people-page')),
                  matching: find.byType(Container),
                )
                .evaluate()) {
          final decoration = (element.widget as Container).decoration;
          if (decoration is BoxDecoration) {
            expect(
              decoration.boxShadow ?? const <BoxShadow>[],
              isEmpty,
              reason: 'People chrome must remain flat in $themeMode.',
            );
          }
        }

        expect(tester.takeException(), isNull, reason: '$themeMode @ 1280x720');
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    },
  );
}
