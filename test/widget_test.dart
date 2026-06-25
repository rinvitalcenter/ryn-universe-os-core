import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ryn_universe_os_core/core/text/user_text.dart';
import 'package:ryn_universe_os_core/main.dart';

void main() {
  test('text registries keep user copy separated from developer copy', () {
    final userTextFile = File('lib/core/text/user_text.dart');
    final devTextFile = File('lib/core/text/dev_text.dart');
    final internalTextFile = File('lib/core/text/internal_text.dart');
    expect(userTextFile.existsSync(), isTrue);
    expect(devTextFile.existsSync(), isTrue);
    expect(internalTextFile.existsSync(), isTrue);

    final userText = userTextFile.readAsStringSync();
    final userVisibleStrings = RegExp(
      "'([^']*)'",
    ).allMatches(userText).map((match) => match.group(1) ?? '').join('\n');
    const rawDeveloperTerms = <String>[
      'DB',
      'schema',
      'migration',
      'runtime',
      'AppData',
      'Drift',
      'CRUD',
      'HOLD',
      'guard',
      'Git',
      'Codex',
      'Hermes',
      'token',
      'QA',
      'shell',
      'static',
      'implementation',
      'persistence',
      'Minimum Viable Core',
      '화면 구성',
      '선택한 화면',
      '9개 화면',
      '보관 전',
    ];
    for (final term in rawDeveloperTerms) {
      expect(
        userVisibleStrings.contains(term),
        isFalse,
        reason: 'UserText visible string contains $term',
      );
    }

    expect(UserText.navHome, '홈');
    expect(UserText.navReading, '리딩');
    expect(UserText.studyOsTitle, 'Ryn Study OS 2.0');

    final studyShell = File(
      'lib/features/study_os/study_os_shell.dart',
    ).readAsStringSync();
    expect(studyShell.contains('dev_text.dart'), isFalse);
  });

  test('production typography uses bundled Pretendard', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(RynFonts.text, 'Pretendard');
    expect(RynFonts.display, 'Pretendard');
    expect(RynFonts.rounded, 'Pretendard');
    expect(RynFonts.textFallback, contains('Malgun Gothic'));
    expect(pubspec.contains('family: Pretendard'), isTrue);
    expect(
      pubspec.contains('assets/fonts/pretendard/Pretendard-Regular.otf'),
      isTrue,
    );
    expect(
      File('assets/fonts/pretendard/Pretendard-Regular.otf').existsSync(),
      isTrue,
    );
  });

  testWidgets('renders clean action Home, practical menu, and theme control', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();

    const menuLabels = <String>[
      UserText.navHome,
      UserText.navOperating,
      UserText.navStudy,
      UserText.navReading,
      UserText.navPractice,
      UserText.navContent,
      UserText.navRecord,
      UserText.navOutput,
      UserText.navAi,
      UserText.navSettings,
    ];

    for (final label in menuLabels) {
      expect(find.text(label), findsAtLeastNWidgets(1));
    }

    expect(find.text(UserText.homeToday), findsOneWidget);
    expect(find.text(UserText.homeThisWeek), findsOneWidget);
    expect(find.text(UserText.homeContinue), findsOneWidget);
    expect(find.text(UserText.homeTodayEmpty), findsAtLeastNWidgets(1));
    expect(find.text(UserText.homeTodo), findsOneWidget);
    expect(find.text(UserText.homeTodaySchedule), findsOneWidget);
    expect(find.text(UserText.homeWeekSchedule), findsOneWidget);
    expect(find.text(UserText.homeQuickMemo), findsOneWidget);
    expect(find.text(UserText.homeContinueRecords), findsOneWidget);
    expect(find.text(UserText.homeMaterialsReady), findsOneWidget);
    expect(find.text(UserText.homeOutputsReview), findsOneWidget);
    expect(find.text(UserText.homeAiAssist), findsOneWidget);
    expect(find.text(UserText.homeQuickLinks), findsOneWidget);
    expect(find.text(UserText.homeStudyOps), findsNothing);
    expect(find.text(UserText.homeReadingPractice), findsNothing);
    expect(find.text('Ryn Business OS'), findsNothing);
    expect(
      find.text('수업, 상담, 자료, 기록, 산출물을 한 화면에서 준비하는 개인 운영 허브'),
      findsNothing,
    );
    expect(find.text('운영 모듈'), findsNothing);
    expect(find.text('Calm'), findsNothing);
    expect(find.text('Control'), findsNothing);
    expect(find.text('Continuity'), findsNothing);
    expect(find.text('Local-First'), findsNothing);
    expect(find.text('AI-Native'), findsNothing);
    expect(find.text('AI Command Center'), findsNothing);

    await tester.tap(find.text(UserText.navSettings).first);
    await tester.pumpAndSettle();

    expect(find.textContaining('검색 / 자료 / 기록 / 일정'), findsOneWidget);
    expect(find.text(UserText.themeSettingTitle), findsOneWidget);
    expect(find.text(UserText.themeLight), findsAtLeastNWidgets(1));
    expect(find.text(UserText.themeDark), findsAtLeastNWidgets(1));
    expect(find.text(UserText.themeSystem), findsAtLeastNWidgets(1));
  });

  testWidgets('keeps normal user surfaces free of developer wording', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();

    expect(find.text(UserText.homeToday), findsAtLeastNWidgets(1));
    expect(find.text('AI Command Center'), findsNothing);
    expect(find.text('Chief / Governance Deck'), findsNothing);
    expect(find.text('Safety Status Strip'), findsNothing);
    expect(find.text('DB CLOSED / NO WRITE'), findsNothing);
    expect(find.textContaining('HOLD', findRichText: true), findsNothing);
    expect(find.textContaining('runtime', findRichText: true), findsNothing);
    expect(find.textContaining('CRUD', findRichText: true), findsNothing);

    await tester.tap(find.text(UserText.navOperating).first);
    await tester.pumpAndSettle();

    expect(find.text(UserText.operatingAreaTitle), findsAtLeastNWidgets(1));
    expect(find.text('AI Command Center'), findsNothing);
    expect(find.textContaining('DB', findRichText: true), findsNothing);
  });

  testWidgets('renders compact 364px client layout without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(364, 1129);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.navAi).first);
    await tester.pumpAndSettle();

    expect(find.text(UserText.aiWorkbenchTitle), findsAtLeastNWidgets(1));
    expect(find.text(UserText.aiWorkbenchCue), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text(UserText.aiWorkbenchReview));
    await tester.pumpAndSettle();

    expect(find.text(UserText.aiWorkbenchReview), findsAtLeastNWidgets(1));
    expect(find.text(UserText.aiWorkbenchApproved), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'contains Home canvas inside desktop capture while staying wider than mobile cap',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const RynUniverseApp());
      await tester.pumpAndSettle();

      final businessHomeRect = tester.getRect(
        find
            .byWidgetPredicate(
              (widget) =>
                  widget.runtimeType.toString() == '_BusinessHomeDashboard',
            )
            .first,
      );

      expect(businessHomeRect.width, greaterThan(1100));
      expect(businessHomeRect.width, lessThanOrEqualTo(1700));
      expect(businessHomeRect.right, lessThanOrEqualTo(2400));
      expect(find.text(UserText.homeToday), findsAtLeastNWidgets(1));

      final homeGroups = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_HomeDashboardGroup',
      );
      expect(homeGroups, findsNWidgets(3));
      final firstHomeGroup = tester.getRect(homeGroups.at(0));
      final secondHomeGroup = tester.getRect(homeGroups.at(1));
      expect(
        (firstHomeGroup.width - secondHomeGroup.width).abs(),
        lessThan(0.1),
      );
      expect(firstHomeGroup.height, greaterThan(180));

      await tester.tap(find.text(UserText.navOperating).first);
      await tester.pumpAndSettle();
      final workspaceRect = tester.getRect(
        find
            .byWidgetPredicate(
              (widget) => widget.runtimeType.toString() == '_BusinessAreaPage',
            )
            .first,
      );
      expect((businessHomeRect.width - workspaceRect.width).abs(), lessThan(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Home secondary quick links navigate to workspace homes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(UserText.navStudy).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.navStudy).last);
    await tester.pumpAndSettle();
    expect(find.text(UserText.studyWorkspaceTitle), findsAtLeastNWidgets(1));
    expect(find.text(UserText.studyActionAttendance), findsOneWidget);

    await tester.ensureVisible(find.text(UserText.navHome).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.navHome).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(UserText.navReading).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.navReading).last);
    await tester.pumpAndSettle();
    expect(find.text(UserText.readingWorkspaceTitle), findsAtLeastNWidgets(1));
    expect(find.text(UserText.readingToolTarot), findsOneWidget);
    expect(find.text(UserText.readingToolSaju), findsOneWidget);
  });

  testWidgets('Reading workspace opens RWS Tarot draw flow without storage', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();

    const menuLabels = <String>[
      UserText.navHome,
      UserText.navOperating,
      UserText.navStudy,
      UserText.navReading,
      UserText.navPractice,
      UserText.navContent,
      UserText.navRecord,
      UserText.navOutput,
      UserText.navAi,
      UserText.navSettings,
    ];
    for (final label in menuLabels) {
      expect(find.text(label), findsAtLeastNWidgets(1));
    }

    await tester.tap(find.text(UserText.navReading).first);
    await tester.pumpAndSettle();
    expect(find.text(UserText.readingToolTarot), findsAtLeastNWidgets(1));

    await tester.tap(find.text(UserText.readingToolTarot).last);
    await tester.pumpAndSettle();

    expect(find.text(UserText.tarotDeckSelect), findsOneWidget);
    expect(find.text(UserText.tarotSpreadSelect), findsOneWidget);
    expect(find.text('준비하기'), findsOneWidget);
    expect(find.text('셔플하기'), findsAtLeastNWidgets(1));
    expect(find.text(UserText.tarotQuestion), findsOneWidget);
    expect(find.text(UserText.tarotMemo), findsOneWidget);
    expect(find.byKey(const Key('tarot-rws-card-image')), findsNothing);
    expect(find.byKey(const Key('tarot-empty-slot')), findsNothing);

    expect(find.text(UserText.tarotSpreadGroupFree), findsOneWidget);
    expect(find.text(UserText.tarotSpreadGroupFixed), findsOneWidget);
    for (final spread in [
      UserText.tarotSpreadOne,
      UserText.tarotSpreadThree,
      UserText.tarotSpreadFour,
      UserText.tarotSpreadFive,
      UserText.tarotSpreadBinary,
      UserText.tarotSpreadCeltic,
    ]) {
      expect(find.text(spread), findsAtLeastNWidgets(1));
    }
    expect(find.text('관계 리딩'), findsNothing);
    expect(find.text('문제-원인-해결'), findsNothing);

    expect(find.text('카드 뒷면 선택'), findsOneWidget);
    expect(find.text('코스믹 게이트'), findsOneWidget);
    expect(find.text('이너 로터스'), findsOneWidget);
    expect(find.text('생명의 나무'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('tarot-card-back-option-cosmic_gate')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('tarot-card-back-option-inner_lotus')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('tarot-card-back-option-life_tree')),
      findsOneWidget,
    );
    var setupBackImages = tester.widgetList<Image>(
      find.byKey(const Key('tarot-card-back-image')),
    );
    expect(
      setupBackImages
          .map((image) => (image.image as AssetImage).assetName)
          .where(
            (assetName) =>
                assetName ==
                'assets/tarot/card_backs/ryn_cosmic_gate_back_v1.png',
          ),
      isNotEmpty,
    );

    await tester.tap(
      find.byKey(const ValueKey('tarot-card-back-option-inner_lotus')),
    );
    await tester.pumpAndSettle();
    setupBackImages = tester.widgetList<Image>(
      find.byKey(const Key('tarot-card-back-image')),
    );
    expect(
      setupBackImages
          .map((image) => (image.image as AssetImage).assetName)
          .where(
            (assetName) =>
                assetName ==
                'assets/tarot/card_backs/ryn_inner_lotus_back_v1.png',
          ),
      isNotEmpty,
    );

    await tester.tap(
      find.byKey(const ValueKey('tarot-card-back-option-life_tree')),
    );
    await tester.pumpAndSettle();
    setupBackImages = tester.widgetList<Image>(
      find.byKey(const Key('tarot-card-back-image')),
    );
    expect(
      setupBackImages
          .map((image) => (image.image as AssetImage).assetName)
          .where(
            (assetName) =>
                assetName ==
                'assets/tarot/card_backs/ryn_life_tree_back_v1.png',
          ),
      isNotEmpty,
    );

    expect(find.text(UserText.tarotPositionSetup), findsOneWidget);
    expect(find.text(UserText.tarotPositionSetupHelper), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('과거'), findsWidgets);
    expect(find.text('현재'), findsWidgets);
    expect(find.text('미래'), findsWidgets);

    await tester.enterText(
      find.byKey(const ValueKey('tarot-position-label-input-3카드-1')),
      '중심',
    );
    await tester.pumpAndSettle();
    expect(find.text('중심'), findsOneWidget);

    await tester.tap(find.text(UserText.tarotSpreadFive));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(find.text('원인'), findsWidgets);
    expect(find.text('가능성'), findsWidgets);
    expect(find.text('중심'), findsNothing);

    await tester.tap(find.text(UserText.tarotSpreadThree));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('과거'), findsWidgets);
    expect(find.text('현재'), findsWidgets);
    expect(find.text('미래'), findsWidgets);
    await tester.enterText(
      find.byKey(const ValueKey('tarot-position-label-input-3카드-1')),
      '중심',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tarot-deck-carousel')), findsOneWidget);
    for (final deck in [
      UserText.tarotDeckUniversalWaite,
      UserText.tarotDeckOracle,
      UserText.tarotDeckPersonalScan,
    ]) {
      expect(find.text(deck), findsAtLeastNWidgets(1));
    }

    expect(find.byKey(const Key('tarot-shuffle-button')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('tarot-shuffle-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tarot-shuffle-button')));
    await tester.pumpAndSettle();

    expect(find.text(UserText.tarotDrawPreparation), findsOneWidget);
    expect(find.byKey(const Key('tarot-full-deck-stage')), findsOneWidget);
    expect(find.byKey(const Key('tarot-full-deck-card-0')), findsOneWidget);
    expect(find.byKey(const Key('tarot-full-deck-card-77')), findsOneWidget);
    expect(find.byKey(const Key('tarot-card-back-image')), findsNWidgets(78));
    final drawTableBackAssetNames = tester
        .widgetList<Image>(find.byKey(const Key('tarot-card-back-image')))
        .map((image) => (image.image as AssetImage).assetName)
        .toSet();
    expect(drawTableBackAssetNames, {
      'assets/tarot/card_backs/ryn_life_tree_back_v1.png',
    });
    expect(find.byKey(const Key('tarot-rws-card-image')), findsNothing);
    expect(find.byKey(const Key('tarot-show-result-button')), findsOneWidget);

    final deckStageTopLeft = tester.getTopLeft(
      find.byKey(const Key('tarot-full-deck-stage')),
    );
    final deckStageSize = tester.getSize(
      find.byKey(const Key('tarot-full-deck-stage')),
    );
    Future<void> tapArcCard(double xRatio) async {
      await tester.tapAt(
        deckStageTopLeft + Offset(deckStageSize.width * xRatio, 250),
      );
      await tester.pumpAndSettle();
    }

    await tapArcCard(0.5);
    expect(find.text('1 / 3 선택'), findsOneWidget);
    expect(find.byKey(const Key('tarot-rws-card-image')), findsNothing);

    await tapArcCard(0.62);
    await tapArcCard(0.38);
    expect(find.text('3 / 3 선택'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tarot-show-result-button')));
    await tester.pumpAndSettle();
    expect(find.text(UserText.tarotResultTable), findsOneWidget);
    expect(find.text('카드를 펼쳐보세요'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('tarot-drawn-card')), findsNWidgets(3));
    expect(find.byKey(const Key('tarot-empty-slot')), findsNothing);
    expect(find.byKey(const Key('tarot-rws-card-image')), findsNothing);
    expect(find.byKey(const Key('tarot-card-back-image')), findsNWidgets(3));
    final resultBackAssetNames = tester
        .widgetList<Image>(find.byKey(const Key('tarot-card-back-image')))
        .map((image) => (image.image as AssetImage).assetName)
        .toSet();
    expect(resultBackAssetNames, {
      'assets/tarot/card_backs/ryn_life_tree_back_v1.png',
    });
    expect(
      find.byKey(const Key('tarot-result-card-back-slot')),
      findsNWidgets(3),
    );
    final resultCardSize = tester.getSize(
      find.byKey(const Key('tarot-drawn-card')).first,
    );
    final resultBackSize = tester.getSize(
      find.byKey(const Key('tarot-card-back-image')).first,
    );
    expect(
      (resultCardSize.width - resultBackSize.width).abs(),
      lessThanOrEqualTo(1),
    );
    expect(
      (resultCardSize.height - resultBackSize.height).abs(),
      lessThanOrEqualTo(1),
    );
    expect(find.text('중심'), findsOneWidget);
    expect(find.byKey(const Key('tarot-reveal-all-button')), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('tarot-result-card-back-slot')).first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-rws-card-image')), findsOneWidget);
    expect(find.byKey(const Key('tarot-card-back-image')), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('tarot-reveal-all-button')));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
    final firstImage = tester.widget<Image>(
      find.byKey(const Key('tarot-rws-card-image')).first,
    );
    expect(firstImage.image, isA<AssetImage>());
    expect(firstImage.fit, BoxFit.contain);
    expect(
      (firstImage.image as AssetImage).assetName,
      startsWith('assets/tarot/decks/rws_public_domain/'),
    );
    expect(find.text(UserText.tarotUpright), findsNothing);
    expect(find.text(UserText.tarotReversed), findsNothing);
    final drawnAssetNames = tester
        .widgetList<Image>(find.byKey(const Key('tarot-rws-card-image')))
        .map((image) => (image.image as AssetImage).assetName)
        .toSet();
    expect(drawnAssetNames, hasLength(3));

    await tester.tap(find.text(UserText.tarotResetDraw));
    await tester.pumpAndSettle();
    expect(find.text('준비하기'), findsOneWidget);
    expect(find.byKey(const Key('tarot-rws-card-image')), findsNothing);

    await tester.tap(find.text(UserText.tarotSpreadOne));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-drawn-card')), findsOneWidget);
    expect(find.byKey(const Key('tarot-empty-slot')), findsNothing);

    expect(find.textContaining('DB', findRichText: true), findsNothing);
    expect(find.textContaining('runtime', findRichText: true), findsNothing);
    expect(
      find.textContaining('persistence', findRichText: true),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tarot focus cleanup is safe when app tree disposes', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.navReading).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.readingToolTarot).last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('tarot-shuffle-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tarot-shuffle-button')));
    await tester.pumpAndSettle();

    expect(find.text(UserText.tarotDrawPreparation), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'final IA workspaces expose operating, practice, and content tools',
    (WidgetTester tester) async {
      await tester.pumpWidget(const RynUniverseApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text(UserText.navOperating).first);
      await tester.pumpAndSettle();
      expect(find.text(UserText.operatingTodo), findsOneWidget);
      expect(find.text(UserText.operatingSchedule), findsOneWidget);
      expect(find.text(UserText.operatingQuickMemo), findsOneWidget);

      await tester.tap(find.text(UserText.navPractice).first);
      await tester.pumpAndSettle();
      expect(find.text(UserText.practiceQigong), findsOneWidget);
      expect(find.text(UserText.practiceYoga), findsOneWidget);
      expect(find.text(UserText.practiceMeditation), findsOneWidget);
      expect(find.text(UserText.practiceJournal), findsOneWidget);

      await tester.tap(find.text(UserText.navContent).first);
      await tester.pumpAndSettle();
      expect(find.text(UserText.contentLessonPlan), findsOneWidget);
      expect(find.text(UserText.contentEbook), findsOneWidget);
      expect(find.text(UserText.contentLectureDraft), findsOneWidget);
      expect(find.text(UserText.contentSnsDraft), findsOneWidget);
    },
  );

  testWidgets('renders Study OS 2.0 shell without runtime persistence', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text(UserText.navStudy).first);
    await tester.pumpAndSettle();

    expect(find.text(UserText.studyOsTitle), findsOneWidget);
    expect(find.text(UserText.studyUserSubtitle), findsOneWidget);
    expect(find.text(UserText.studyActionToday), findsOneWidget);
    expect(find.text(UserText.studyActionAttendance), findsOneWidget);
    expect(find.text(UserText.studyActionMaterials), findsOneWidget);
    expect(find.text(UserText.studyActionJournal), findsOneWidget);
    expect(find.text(UserText.studyActionReports), findsOneWidget);
    expect(find.text(UserText.studyActionMembers), findsOneWidget);
    expect(find.text(UserText.studyActionSessions), findsOneWidget);
    expect(find.textContaining(UserText.studyEmptyRegistered), findsOneWidget);
    expect(
      find.textContaining(UserText.studyPickNeededItem),
      findsAtLeastNWidgets(1),
    );

    final studyCards = find.byWidgetPredicate(
      (widget) => widget.runtimeType.toString() == '_StudyUserActionCard',
    );
    expect(studyCards, findsWidgets);
    final firstStudyCard = tester.getRect(studyCards.at(0));
    final secondStudyCard = tester.getRect(studyCards.at(1));
    expect((firstStudyCard.width - secondStudyCard.width).abs(), lessThan(0.1));
    expect(firstStudyCard.height, lessThanOrEqualTo(150));

    await tester.tap(find.text(UserText.studyActionAttendance).first);
    await tester.pumpAndSettle();
    expect(
      find.text('${UserText.navStudy} > ${UserText.studyActionAttendance}'),
      findsOneWidget,
    );
    expect(find.text(UserText.backToWorkspace), findsOneWidget);
    expect(find.text(UserText.emptyItems), findsOneWidget);
    await tester.tap(find.text(UserText.backToWorkspace));
    await tester.pumpAndSettle();
    expect(find.text(UserText.studyWorkspaceTitle), findsOneWidget);

    const forbiddenStudyLabels = <String>[
      '화면 구성',
      '선택한 화면',
      '보관 전',
      '화면 흐름 확인 단계',
      '아직 입력한 내용은 보관되지 않습니다.',
      '정적 화면 shell',
      'DB 연결 없음',
      '저장/수정 없음',
    ];
    for (final label in forbiddenStudyLabels) {
      expect(find.text(label), findsNothing);
    }
    expect(find.textContaining('runtime', findRichText: true), findsNothing);
    expect(find.textContaining('CRUD', findRichText: true), findsNothing);
    expect(find.textContaining('shell', findRichText: true), findsNothing);
    expect(find.textContaining('static', findRichText: true), findsNothing);
    expect(
      find.textContaining('implementation', findRichText: true),
      findsNothing,
    );
    expect(
      find.textContaining('persistence', findRichText: true),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark mode keeps user navigation and Study surface readable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text(UserText.navSettings).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.themeDark).first);
    await tester.pumpAndSettle();

    expect(find.text(UserText.themeDark), findsAtLeastNWidgets(1));
    await tester.tap(find.text(UserText.navHome).first);
    await tester.pumpAndSettle();
    expect(find.text(UserText.navHome), findsAtLeastNWidgets(1));

    final homeItemColors = tester
        .widgetList<Container>(
          find.byKey(const Key('home-dashboard-item-card')),
        )
        .map((container) => container.decoration)
        .whereType<BoxDecoration>()
        .map((decoration) => decoration.color)
        .whereType<Color>()
        .toList();
    expect(homeItemColors, isNotEmpty);
    expect(homeItemColors.contains(Colors.white), isFalse);
    final homeQuickLinkColors = tester
        .widgetList<Container>(find.byKey(const Key('home-quick-link-chip')))
        .map((container) => container.decoration)
        .whereType<BoxDecoration>()
        .map((decoration) => decoration.color)
        .whereType<Color>()
        .toList();
    expect(homeQuickLinkColors, isNotEmpty);
    expect(homeQuickLinkColors.contains(Colors.white), isFalse);

    await tester.tap(find.text(UserText.navStudy).first);
    await tester.pumpAndSettle();

    expect(find.text(UserText.studyOsTitle), findsOneWidget);
    expect(find.text(UserText.studyActionAttendance), findsOneWidget);
    final studyCardColors = tester
        .widgetList<Container>(find.byKey(const Key('study-user-action-card')))
        .map((container) => container.decoration)
        .whereType<BoxDecoration>()
        .map((decoration) => decoration.color)
        .whereType<Color>()
        .toList();
    expect(studyCardColors, isNotEmpty);
    expect(studyCardColors.contains(Colors.white), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AI Workbench stays lightweight and user-facing', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.navAi).first);
    await tester.pumpAndSettle();

    expect(find.text(UserText.aiWorkbenchTitle), findsAtLeastNWidgets(1));
    expect(find.text(UserText.aiWorkbenchCue), findsOneWidget);
    expect(find.text(UserText.aiWorkbenchRequest), findsOneWidget);
    expect(find.text(UserText.aiWorkbenchReview), findsOneWidget);
    expect(find.text(UserText.aiWorkbenchApproved), findsOneWidget);
    expect(find.text('AI Command Center'), findsNothing);
    expect(find.text('Kanban Orchestra'), findsNothing);
    expect(find.textContaining('DB', findRichText: true), findsNothing);
    expect(find.textContaining('HOLD', findRichText: true), findsNothing);
  });
}
