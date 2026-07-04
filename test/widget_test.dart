import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ryn_universe_os_core/core/text/user_text.dart';
import 'package:ryn_universe_os_core/features/tarot/data/tarot_deck_registry.dart';
import 'package:ryn_universe_os_core/features/tarot/tarot_spread_shell.dart';
import 'package:ryn_universe_os_core/main.dart';

void main() {
  test('tarot deck registry preserves existing RWS asset baseline', () {
    final rwsDeck = TarotDeckRegistry.rwsPublicDomain;

    expect(TarotDeckRegistry.decks, contains(rwsDeck));
    expect(rwsDeck.deckId, 'rws_public_domain');
    expect(rwsDeck.cards, hasLength(78));
    expect(
      rwsDeck.representativeAssetPath,
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_00_Fool.jpg',
    );
    expect(
      rwsDeck.cards.first.assetPath,
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups01.jpg',
    );
    expect(
      rwsDeck.cards
          .firstWhere((card) => card.semanticId == 'pents_01')
          .assetPath,
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents01.jpg',
    );
  });

  test('Tarot setup flow uses honest visible step keys only', () {
    final tarotShell = File(
      'lib/features/tarot/tarot_spread_shell.dart',
    ).readAsStringSync();

    expect(tarotShell.contains('tarot-global-flow-정리'), isFalse);
    expect(
      tarotShell.contains("key: Key('tarot-active-setup-step-1')"),
      isFalse,
    );
    expect(
      tarotShell.contains("key: Key('tarot-active-setup-step-2')"),
      isFalse,
    );
    expect(
      tarotShell.contains("key: Key('tarot-active-setup-step-3')"),
      isFalse,
    );
    expect(tarotShell.contains('stepIndex == 0 ? 5 : stepIndex + 1'), isFalse);
  });

  test('Tarot intake follows Midnight Atelier design-system markers', () {
    final tarotShell = File(
      'lib/features/tarot/tarot_spread_shell.dart',
    ).readAsStringSync();

    expect(tarotShell.contains('tarot-midnight-atelier-stepper'), isTrue);
    expect(tarotShell.contains('질문 준비'), isTrue);
    expect(tarotShell.contains('테이블'), isTrue);
    expect(tarotShell.contains('해석'), isTrue);
    expect(tarotShell.contains('tarot-free-question-hero-surface'), isTrue);
    expect(tarotShell.contains('tarot-reading-intake-receipt-card'), isTrue);
    expect(
      tarotShell.contains("key: const Key('tarot-global-flow-nav')"),
      isFalse,
    );
  });

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

  testWidgets(
    'Tarot intake navigation preserves values and summarizes caution',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('tarot-active-setup-step-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-midnight-atelier-stepper')),
        findsOneWidget,
      );
      expect(find.text('질문 준비'), findsOneWidget);
      expect(find.text('테이블'), findsOneWidget);
      expect(find.text('해석'), findsAtLeastNWidgets(1));
      expect(find.byKey(const Key('tarot-intro-panel')), findsOneWidget);
      expect(find.text('바로 덱 선택'), findsOneWidget);
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('tarot-active-setup-step-1')),
        findsOneWidget,
      );
      expect(find.text('연애'), findsOneWidget);
      expect(find.text('자유 질문'), findsOneWidget);
      for (final categoryLabel in [
        '연애',
        '금전',
        '일·승진·진로',
        '관계',
        '가족',
        '영적 성장',
        '예·아니오',
        '시기',
        '선택',
        '자유 질문',
      ]) {
        expect(find.text(categoryLabel), findsOneWidget);
      }
      final stageRect = tester.getRect(
        find.byKey(const Key('tarot-unified-intake-stage-frame')),
      );
      final freeQuestionCardRect = tester.getRect(
        find.byKey(const ValueKey('tarot-question-category-open_question')),
      );
      expect(freeQuestionCardRect.bottom <= stageRect.bottom, isTrue);
      await tester.tap(
        find.byKey(const ValueKey('tarot-question-category-money')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('tarot-active-setup-step-2')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-free-question-hero-surface')),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const Key('tarot-free-question-input')),
        '내 마음이 제일 먼저 묻고 싶은 것은 무엇일까요?',
      );
      await tester.enterText(
        find.byKey(const Key('tarot-question-title-input')),
        '이번 선택의 핵심',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-active-setup-step-3')),
        findsOneWidget,
      );
      await tester.tap(find.text('이전'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-active-setup-step-2')),
        findsOneWidget,
      );
      expect(find.text('내 마음이 제일 먼저 묻고 싶은 것은 무엇일까요?'), findsOneWidget);
      expect(find.text('이번 선택의 핵심'), findsOneWidget);

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('tarot-session-context-input')),
        '짧고 차분한 상담 흐름이 필요합니다.',
      );
      await tester.enterText(
        find.byKey(const Key('tarot-sensitivity-note-input')),
        '확정적으로 단정하지 않기',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('tarot-active-setup-step-4')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-reading-intake-receipt-card')),
        findsOneWidget,
      );
      expect(find.text('금전'), findsAtLeastNWidgets(1));
      expect(find.text('내 마음이 제일 먼저 묻고 싶은 것은 무엇일까요?'), findsAtLeastNWidgets(1));
      expect(find.text('이번 선택의 핵심'), findsAtLeastNWidgets(1));
      expect(find.text('짧고 차분한 상담 흐름이 필요합니다.'), findsAtLeastNWidgets(1));
      expect(find.text('확정적으로 단정하지 않기'), findsAtLeastNWidgets(1));
      await tester.ensureVisible(find.text('덱과 스프레드 선택하기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('덱과 스프레드 선택하기'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-active-setup-step-5')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tarot-deck-carousel')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

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

    expect(find.byKey(const Key('tarot-active-setup-step-0')), findsOneWidget);
    expect(find.byKey(const Key('tarot-intro-panel')), findsOneWidget);
    expect(find.text('바로 덱 선택'), findsOneWidget);
    expect(find.text(UserText.tarotDeckSelect), findsNothing);
    expect(find.text(UserText.tarotSpreadSelect), findsNothing);
    expect(find.byKey(const Key('tarot-shuffle-button')), findsNothing);
    expect(find.byKey(const Key('tarot-rws-card-image')), findsNothing);
    expect(find.byKey(const Key('tarot-empty-slot')), findsNothing);

    await tester.tap(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tarot-active-setup-step-5')), findsOneWidget);
    expect(find.text('2 덱 선택'), findsOneWidget);
    expect(find.byKey(const Key('tarot-deck-carousel')), findsOneWidget);
    expect(find.byKey(const Key('tarot-deck-fan-carousel')), findsOneWidget);
    expect(find.byKey(const Key('tarot-deck-fan-left')), findsOneWidget);
    expect(find.byKey(const Key('tarot-deck-fan-right')), findsOneWidget);
    expect(find.byKey(const Key('tarot-deck-fan-dot-0')), findsOneWidget);
    final centerDeckRect = tester.getRect(
      find.byKey(const ValueKey('tarot-deck-carousel-card-rws_public_domain')),
    );
    final neighborDeckRect = tester.getRect(
      find.byKey(const ValueKey('tarot-deck-carousel-card-thoth')),
    );
    expect(centerDeckRect.width, greaterThan(neighborDeckRect.width));
    expect(centerDeckRect.top, lessThan(neighborDeckRect.top));
    expect(
      find.text(UserText.tarotDeckUniversalWaite),
      findsAtLeastNWidgets(1),
    );
    for (var index = 0; index < 8; index++) {
      expect(find.byKey(Key('tarot-deck-fan-dot-$index')), findsOneWidget);
    }
    expect(find.byKey(const Key('tarot-coverflow-hero-card')), findsOneWidget);
    expect(
      find.byKey(const Key('tarot-selected-card-edge-glow')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('tarot-coverflow-near-card-thoth')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('tarot-coverflow-side-card-marseille')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('tarot-coverflow-far-card-oracle')),
      findsOneWidget,
    );
    expect(find.text(UserText.tarotSpreadSelect), findsNothing);

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tarot-active-setup-step-6')), findsOneWidget);
    expect(find.text(UserText.tarotSpreadSelect), findsOneWidget);
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
    expect(find.text('1'), findsWidgets);
    expect(find.text('5'), findsWidgets);

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

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-active-setup-step-7')), findsOneWidget);
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
    expect(find.text('중심'), findsAtLeastNWidgets(1));
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
    expect(find.byKey(const Key('tarot-active-setup-step-0')), findsOneWidget);
    expect(find.byKey(const Key('tarot-rws-card-image')), findsNothing);

    await tester.ensureVisible(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.tarotSpreadOne));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
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

  testWidgets(
    'Tarot setup keeps primary actions visible in constrained desktop size',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 820);
      tester.view.devicePixelRatio = 2.0;
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
      await tester.ensureVisible(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tarot-shuffle-button')), findsOneWidget);
      expect(find.text(UserText.tarotAutoDraw), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('tarot-shuffle-button')));
      await tester.pumpAndSettle();
      final shuffleRect = tester.getRect(
        find.byKey(const Key('tarot-shuffle-button')),
      );
      final autoDrawRect = tester.getRect(find.text(UserText.tarotAutoDraw));
      const logicalHeight = 410.0;
      expect(shuffleRect.top, greaterThanOrEqualTo(0));
      expect(shuffleRect.bottom, lessThanOrEqualTo(logicalHeight));
      expect(autoDrawRect.top, greaterThanOrEqualTo(0));
      expect(autoDrawRect.bottom, lessThanOrEqualTo(logicalHeight));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Tarot result surface keeps actions reachable with reflection shell',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 820);
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
      await tester.ensureVisible(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(UserText.tarotSpreadOne));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotSpreadOne));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();

      expect(find.text(UserText.tarotResultTable), findsOneWidget);
      expect(find.byKey(const Key('tarot-reveal-all-button')), findsOneWidget);
      expect(find.byKey(const Key('tarot-interpretation-shell')), findsNothing);
      expect(find.text('해석 패널'), findsNothing);
      expect(find.text('해석 보기'), findsOneWidget);

      final revealAllRect = tester.getRect(
        find.byKey(const Key('tarot-reveal-all-button')),
      );
      expect(revealAllRect.right, lessThanOrEqualTo(1200));
      expect(revealAllRect.left, greaterThanOrEqualTo(0));
      await tester.ensureVisible(find.text('해석 보기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('해석 보기'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-interpretation-shell')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-workspace-shell')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-card-rail')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-notes-panel')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-synthesis-panel')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-scope-banner')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-card-preview-0')),
        findsOneWidget,
      );
      expect(find.text('해석 패널'), findsAtLeastNWidgets(1));
      expect(find.text('핵심'), findsAtLeastNWidgets(1));
      expect(find.textContaining('저장', findRichText: true), findsNothing);
      expect(find.textContaining('export', findRichText: true), findsNothing);
      expect(find.textContaining('PDF', findRichText: true), findsNothing);
      expect(find.textContaining('AI', findRichText: true), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Tarot table cloth color applies through reading flow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tarot-table-cloth-selector')), findsOneWidget);
    for (final label in [
      '딥 퍼플',
      '딥 그린',
      '로즈 와인',
      '미드나잇 네이비',
      '차콜 블랙',
      '뮤티드 골드',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.ensureVisible(
      find.byKey(const Key('tarot-table-cloth-muted_gold')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tarot-table-cloth-muted_gold')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tarot-selected-table-cloth-muted_gold')),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-shuffle-button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tarot-shuffle-button')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tarot-draw-table-cloth-muted_gold')),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tarot-result-table-cloth-muted_gold')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('tarot-result-layout-3')), findsOneWidget);
    expect(
      find.byKey(const Key('tarot-layout-adjustment-toolbar')),
      findsOneWidget,
    );
    expect(find.text('해석 보기'), findsOneWidget);

    await tester.tap(find.text('모두 펼치기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tarot-focusable-result-card-0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-focus-detail-overlay')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tarot-focus-close-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('해석 보기'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tarot-interpretation-table-cloth-muted_gold')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('tarot-interpretation-workspace-shell')),
      findsOneWidget,
    );
    expect(find.textContaining('저장', findRichText: true), findsNothing);
    expect(find.textContaining('export', findRichText: true), findsNothing);
    expect(find.textContaining('PDF', findRichText: true), findsNothing);
    expect(find.textContaining('AI', findRichText: true), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tarot compact spreads use tall centered muted-gold tables', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Future<({Rect board, Rect card})> renderSpread({
      required String label,
      required String spreadId,
      required int count,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('tarot-table-cloth-muted_gold')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tarot-table-cloth-muted_gold')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(label).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tarot-shuffle-button')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text('모두 펼치기'));
      await tester.pumpAndSettle();

      final board = tester.getRect(
        find.byKey(Key('tarot-result-layout-$count')),
      );
      final card = tester.getRect(
        find.byKey(const Key('tarot-focusable-result-card-0')),
      );
      expect(
        find.byKey(const Key('tarot-result-table-cloth-muted_gold')),
        findsOneWidget,
        reason: spreadId,
      );
      expect(
        find.byKey(const Key('tarot-layout-adjustment-toolbar')),
        findsOneWidget,
        reason: spreadId,
      );
      expect(tester.takeException(), isNull, reason: spreadId);
      return (board: board, card: card);
    }

    final seven = await renderSpread(
      label: '7카드',
      spreadId: 'seven_card',
      count: 7,
    );
    final compactSpreads =
        <({String label, String spreadId, int count, double minCardWidth})>[
          (
            label: UserText.tarotSpreadOne,
            spreadId: 'one_card',
            count: 1,
            minCardWidth: 360,
          ),
          (
            label: UserText.tarotSpreadThree,
            spreadId: 'three_card',
            count: 3,
            minCardWidth: 270,
          ),
          (
            label: UserText.tarotSpreadFive,
            spreadId: 'five_card',
            count: 5,
            minCardWidth: 210,
          ),
        ];

    for (final spread in compactSpreads) {
      final rendered = await renderSpread(
        label: spread.label,
        spreadId: spread.spreadId,
        count: spread.count,
      );
      expect(
        rendered.board.height,
        greaterThanOrEqualTo(seven.board.height - 4),
        reason: '${spread.spreadId} table should align with seven-card height',
      );
      expect(
        rendered.card.width,
        greaterThanOrEqualTo(spread.minCardWidth),
        reason: '${spread.spreadId} card size must not be reduced',
      );
      final cardCenterRatio =
          (rendered.card.center.dy - rendered.board.top) /
          rendered.board.height;
      expect(
        cardCenterRatio,
        inInclusiveRange(0.46, 0.58),
        reason: '${spread.spreadId} card should sit in the visual middle zone',
      );
    }
  });

  testWidgets(
    'Tarot owner review flow exposes step panels and dedicated result layouts',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-active-setup-step-0')),
        findsOneWidget,
      );
      expect(find.text('1 질문과 목적'), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-midnight-atelier-stepper')),
        findsOneWidget,
      );
      for (final label in [
        '인트로',
        '카테고리',
        '질문',
        '상담 정보',
        '요약',
        '덱',
        '세부 설정',
        '셔플',
        '공개',
        '해석',
      ]) {
        expect(find.byKey(Key('tarot-global-flow-$label')), findsOneWidget);
      }
      expect(
        find.byKey(const Key('tarot-setup-guidance-layout')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tarot-deck-carousel')), findsNothing);
      expect(find.text(UserText.tarotSpreadSelect), findsNothing);
      expect(find.byKey(const Key('tarot-shuffle-button')), findsNothing);
      expect(find.text('리딩 포인트'), findsNothing);

      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-active-setup-step-5')),
        findsOneWidget,
      );
      expect(find.text('2 덱 선택'), findsOneWidget);
      expect(find.text('덱 선택'), findsNothing);
      expect(find.byKey(const Key('tarot-global-flow-덱')), findsOneWidget);
      expect(find.byKey(const Key('tarot-deck-carousel')), findsOneWidget);
      expect(find.byKey(const Key('tarot-jukebox-deck-stage')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-jukebox-center-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-coverflow-hero-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-selected-card-edge-glow')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-coverflow-near-card-thoth')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-coverflow-side-card-marseille')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-coverflow-far-card-oracle')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-immersive-deck-stage')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tarot-deck-fan-carousel')), findsOneWidget);
      expect(find.byKey(const Key('tarot-deck-bento-tile')), findsNothing);
      expect(find.text(UserText.tarotSpreadSelect), findsNothing);
      expect(find.byKey(const Key('tarot-shuffle-button')), findsNothing);

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-active-setup-step-6')),
        findsOneWidget,
      );
      expect(find.text('3 카드 세부 설정'), findsOneWidget);
      expect(find.byKey(const Key('tarot-global-flow-세부 설정')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-card-detail-balanced-layout')),
        findsOneWidget,
      );
      expect(find.text(UserText.tarotSpreadSelect), findsOneWidget);
      expect(find.byKey(const Key('tarot-deck-carousel')), findsNothing);
      expect(find.byKey(const Key('tarot-shuffle-button')), findsNothing);

      await tester.tap(find.text(UserText.tarotSpreadFour));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-active-setup-step-7')),
        findsOneWidget,
      );
      expect(find.text('4 셔플과 드로우'), findsOneWidget);
      expect(find.byKey(const Key('tarot-global-flow-셔플')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-ritual-shuffle-stage')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-unified-ritual-layout')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-ritual-deck-preview')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-ritual-hero-deck-stack')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tarot-shuffle-button')), findsOneWidget);
      expect(find.byKey(const Key('tarot-deck-carousel')), findsNothing);
      expect(find.text(UserText.tarotSpreadSelect), findsNothing);
      await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tarot-shuffle-button')));
      await tester.pumpAndSettle();
      expect(find.text(UserText.tarotDrawPreparation), findsOneWidget);
      expect(find.byKey(const Key('tarot-full-deck-stage')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-face-down-card-identity-major_00')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-draw-face-down-card-back-image-0')),
        findsOneWidget,
      );
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tarot-result-layout-4')), findsOneWidget);
      expect(find.byKey(const Key('tarot-reading-workspace')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-reading-command-bar')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tarot-interpretation-shell')), findsNothing);
      expect(find.text('배치 조정'), findsOneWidget);
      expect(find.text('기본 배치로'), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-layout-adjustment-toolbar')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-adjustable-result-card-0')),
        findsOneWidget,
      );
      final fixedSlotBefore = tester.getRect(
        find.byKey(const Key('tarot-result-slot-4-0')),
      );
      await tester.drag(
        find.byKey(const Key('tarot-adjustable-result-card-0')),
        const Offset(96, 42),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(const Key('tarot-result-slot-4-0'))),
        fixedSlotBefore,
      );
      await tester.tap(find.text('배치 조정'));
      await tester.pumpAndSettle();
      expect(find.text('배치 완료'), findsOneWidget);
      await tester.drag(
        find.byKey(const Key('tarot-adjustable-result-card-0')),
        const Offset(96, 42),
      );
      await tester.pumpAndSettle();
      final fixedSlotMoved = tester.getRect(
        find.byKey(const Key('tarot-result-slot-4-0')),
      );
      expect(fixedSlotMoved.center.dx, greaterThan(fixedSlotBefore.center.dx));
      expect(
        find.byKey(const Key('tarot-slot-label-anchor-bottom-four_1')),
        findsAtLeastNWidgets(1),
      );
      await tester.tap(find.text('배치 완료'));
      await tester.pumpAndSettle();
      expect(find.text('배치 조정'), findsOneWidget);
      expect(
        tester.getRect(find.byKey(const Key('tarot-result-slot-4-0'))),
        fixedSlotMoved,
      );
      await tester.tap(find.text('기본 배치로'));
      await tester.pumpAndSettle();
      final fixedSlotReset = tester.getRect(
        find.byKey(const Key('tarot-result-slot-4-0')),
      );
      expect(
        (fixedSlotReset.center.dx - fixedSlotBefore.center.dx).abs(),
        lessThan(1),
      );
      expect(
        (fixedSlotReset.center.dy - fixedSlotBefore.center.dy).abs(),
        lessThan(1),
      );
      expect(find.text('해석 패널'), findsNothing);
      expect(find.text('해석 보기'), findsOneWidget);
      expect(find.textContaining('저장', findRichText: true), findsNothing);
      expect(find.textContaining('export', findRichText: true), findsNothing);
      expect(find.textContaining('history', findRichText: true), findsNothing);
      expect(find.textContaining('AI', findRichText: true), findsNothing);

      final rowRects = List<Rect>.generate(
        4,
        (index) =>
            tester.getRect(find.byKey(Key('tarot-result-slot-4-$index'))),
      );
      final maxTopDelta = rowRects
          .map((rect) => (rect.top - rowRects.first.top).abs())
          .reduce(math.max);
      expect(maxTopDelta, lessThan(28));
      await tester.tap(find.text('해석 보기'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-interpretation-shell')),
        findsOneWidget,
      );
      expect(find.text('해석 패널'), findsAtLeastNWidgets(1));
      expect(find.byKey(const Key('tarot-result-layout-4')), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotSpreadFive));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tarot-result-layout-5')), findsOneWidget);
      for (var index = 0; index < 5; index++) {
        final slotRect = tester.getRect(
          find.byKey(Key('tarot-result-slot-5-$index')),
        );
        expect(slotRect.left, greaterThanOrEqualTo(0));
        expect(slotRect.right, lessThanOrEqualTo(1920));
        expect(slotRect.bottom, lessThanOrEqualTo(1080));
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotSpreadCeltic));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tarot-result-layout-10')), findsOneWidget);
      final rightColumnRects = [
        for (var index = 6; index < 10; index++)
          tester.getRect(find.byKey(Key('tarot-result-slot-10-$index'))),
      ];
      for (var index = 1; index < rightColumnRects.length; index++) {
        expect(
          (rightColumnRects[index].center.dx -
                  rightColumnRects[index - 1].center.dx)
              .abs(),
          lessThan(12),
        );
        expect(
          (rightColumnRects[index].center.dy -
                  rightColumnRects[index - 1].center.dy)
              .abs(),
          greaterThan(rightColumnRects[index].height * 0.55),
        );
      }

      expect(find.text('관계 리딩'), findsNothing);
      expect(find.text('문제-원인-해결'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

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
    await tester.ensureVisible(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
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

  test(
    'Tarot spread registry source defines corrected family meanings and anchors',
    () {
      final source = File(
        'lib/features/tarot/tarot_spread_shell.dart',
      ).readAsStringSync();
      final registrySource = File(
        'lib/features/tarot/data/tarot_deck_registry.dart',
      ).readAsStringSync();
      final expectedLiteralLabels = <String>[
        '자유 드로우',
        '2카드',
        '7카드',
        '그리드 6',
        '그리드 8',
        '그리드 9',
        '미니 켈틱 크로스',
        '십자',
        '말발굽',
        '매직 세븐',
        '리딩 마인드',
        '탄뎀',
        '릴레이션십',
        '컵 오브 릴레이션십',
        '호로스코프',
        '1년 운세',
      ];
      final expectedIds = <String>[
        'free_draw',
        'one_card',
        'two_card',
        'three_card',
        'four_card',
        'five_card',
        'seven_card',
        'grid_6',
        'grid_8',
        'grid_9',
        'celtic_cross',
        'mini_celtic_cross',
        'cross',
        'horseshoe',
        'magic_seven',
        'binary_choice',
        'reading_mind',
        'tandem',
        'relationship',
        'cup_of_relationship',
        'horoscope',
        'year_ahead',
      ];

      for (final label in expectedLiteralLabels) {
        expect(source, contains("label: '$label'"), reason: label);
      }
      for (final id in expectedIds) {
        expect(source, contains("id: '$id'"), reason: id);
      }
      expect(source, contains('id: \'free_draw\''));
      for (final id in <String>[
        'free_draw',
        'one_card',
        'two_card',
        'three_card',
        'four_card',
        'five_card',
        'seven_card',
        'grid_6',
        'grid_8',
        'grid_9',
      ]) {
        expect(
          source,
          contains("id: '$id',"),
          reason: 'freeLayout id missing: $id',
        );
      }
      expect(source, contains('_TarotSpreadFamily.freeLayout'));
      expect(source, contains('_TarotSpreadFamily.fixedMeaning'));
      expect(source, contains('_TarotPositionMeaningMode.userDefined'));
      expect(source, contains('_TarotPositionMeaningMode.predefined'));
      expect(source, contains('supportsDrag: true'));
      expect(RegExp(r'supportsDrag: true').allMatches(source), hasLength(1));
      expect(source, contains('int _selectedFreeDrawCount = 5'));
      expect(
        source,
        contains('_freeDrawSlotsForCount(_selectedFreeDrawCount)'),
      );
      expect(source, contains('tarot-free-draw-count-selector'));
      expect(source, contains('static const List<int> _quickCounts'));
      expect(source, contains('[1, 3, 5, 7, 10, 13, 22]'));
      expect(source, contains(r'tarot-free-draw-count-option-$count'));
      expect(source, contains('count.clamp(1, 30)'));
      expect(source, contains('_TarotResultCanvasStyle.freeBoard'));
      expect(source, contains('_TarotResultCanvasStyle.radial'));
      expect(source, contains('variantCount: 3'));
      expect(source, contains('overlapTargetSlotId: \'mini_center\''));
      expect(source, contains('overlapTargetSlotId: \'cup_center\''));
      expect(source, contains("slotId: '\${prefix}_center'"));
      expect(source, contains('tarot-free-draw-draggable-card-'));
      expect(source, contains('tarot-fixed-spread-board-'));
      expect(source, contains('tarot-reading-workspace'));
      expect(source, contains('tarot-reading-command-bar'));
      expect(source, contains('fillAvailable: true'));
      expect(source, contains('tarot-layout-adjustment-toolbar'));
      expect(source, contains('tarot-floating-layout-controls'));
      expect(source, contains('tarot-layout-adjustment-enter'));
      expect(source, contains('tarot-layout-adjustment-done'));
      expect(source, contains('tarot-layout-adjustment-reset'));
      expect(source, contains('tarot-representative-deck-image'));
      expect(source, contains('representativeAssetPath'));
      expect(registrySource, contains('RWS_Tarot_00_Fool.jpg'));
      expect(source, contains('tarot-adjustable-result-card-'));
      expect(source, contains('final Map<int, Offset> _temporaryOffsets'));
      expect(source, contains('bool _adjustmentMode = false'));
      expect(source, contains('bool get _canMoveCards'));
      expect(source, contains('bool get _shouldShowPersistentCaptions'));
      expect(source, contains('static const Set<String> _denseSpreadIds'));
      expect(source, contains('_cardSizeForSpreadType'));
      expect(source, contains('_layoutForSpread'));
      expect(source, contains('_boardPaddingForSpread'));
      expect(source, contains('_spreadOccupancyTarget'));
      expect(source, contains('_overlapPolicyForSpread'));
      expect(source, contains('SPREAD-LAYOUT-TEMPLATE1'));
      expect(source, contains('const _manualSpreadGeometryBlueprints'));
      expect(source, contains('class _TarotSpreadGeometryBlueprint'));
      expect(source, contains('class _EffectiveSpreadLayout'));
      expect(source, contains('enum _TarotOverlapPolicy'));
      expect(source, contains('R7: keep the hit/label halo compact'));
      expect(source, contains('return _TarotSlotAnchor.hidden'));
      expect(source, contains('enum _TarotSlotAnchor'));
      expect(source, contains('labelAnchor:'));
      expect(source, contains('infoAnchor:'));
      expect(source, contains('labelOffsetX:'));
      expect(source, contains('avoidOverlap:'));
      expect(source, contains('allowAutoFlipAnchor:'));
      expect(source, contains('preferredSide:'));
      expect(source, contains('_radialAnchorForIndex'));
      expect(source, contains('tarot-slot-label-anchor-'));
      expect(source, contains('_TarotSlotAnchor.bottom'));
      expect(source, contains('_TarotSlotAnchor.left'));
      expect(source, contains('_TarotSlotAnchor.right'));
      expect(source, contains('tarot-reading-back-command'));
      expect(source, contains('UserText.backToWorkspace'));
      expect(source, contains('selected card-back labels must stay readable'));
      expect(source, contains('gold remains in the rim/glow, not text'));
      expect(
        source,
        contains("'celtic_cross': _TarotSpreadGeometryBlueprint("),
      );
      expect(
        source,
        contains('layout: _EffectiveSpreadLayout(columns: 4.70, rows: 3.45)'),
      );
      expect(
        source,
        contains("'mini_celtic_cross': _TarotSpreadGeometryBlueprint("),
      );
      expect(source, contains("'cross': _TarotSpreadGeometryBlueprint("));
      expect(source, contains("'horseshoe': _TarotSpreadGeometryBlueprint("));
      expect(source, contains("'magic_seven': _TarotSpreadGeometryBlueprint("));
      expect(
        source,
        contains("'binary_choice': _TarotSpreadGeometryBlueprint("),
      );
      expect(
        source,
        contains("'reading_mind': _TarotSpreadGeometryBlueprint("),
      );
      expect(source, contains("'tandem': _TarotSpreadGeometryBlueprint("));
      expect(
        source,
        contains("'relationship': _TarotSpreadGeometryBlueprint("),
      );
      expect(
        source,
        contains("'cup_of_relationship': _TarotSpreadGeometryBlueprint("),
      );
      expect(source, contains("'horoscope': _TarotSpreadGeometryBlueprint("));
      expect(source, contains("'year_ahead': _TarotSpreadGeometryBlueprint("));
      expect(source, isNot(contains('관계 리딩')));
      expect(source, isNot(contains('문제-원인-해결')));
      expect(source, isNot(contains('save')));
      expect(source, isNot(contains('export')));
      expect(source, isNot(contains('history')));
      expect(source, contains("id: 'one_card',"));
      expect(source, contains('family: _TarotSpreadFamily.freeLayout'));
      expect(source, contains("id: 'celtic_cross',"));
      expect(source, contains('family: _TarotSpreadFamily.fixedMeaning'));

      String definitionBlock(String id) {
        final start = source.indexOf("id: '$id'");
        expect(start, isNonNegative, reason: id);
        final next = source.indexOf(
          '  const _TarotSpreadDefinition(',
          start + 1,
        );
        final nextDynamic = source.indexOf(
          '  _TarotSpreadDefinition(',
          start + 1,
        );
        final candidates = [
          if (next > start) next,
          if (nextDynamic > start) nextDynamic,
        ]..sort();
        final end = candidates.isEmpty
            ? source.indexOf('];', start)
            : candidates.first;
        return source.substring(start, end);
      }

      for (final id in <String>[
        'free_draw',
        'one_card',
        'two_card',
        'three_card',
        'four_card',
        'five_card',
        'seven_card',
        'grid_6',
        'grid_8',
        'grid_9',
      ]) {
        final block = definitionBlock(id);
        expect(block, contains('_TarotSpreadFamily.freeLayout'), reason: id);
        expect(
          block,
          contains('_TarotPositionMeaningMode.userDefined'),
          reason: id,
        );
      }
      for (final id in <String>[
        'celtic_cross',
        'mini_celtic_cross',
        'cross',
        'horseshoe',
        'magic_seven',
        'binary_choice',
        'reading_mind',
        'tandem',
        'relationship',
        'cup_of_relationship',
        'horoscope',
        'year_ahead',
      ]) {
        final block = definitionBlock(id);
        expect(block, contains('_TarotSpreadFamily.fixedMeaning'), reason: id);
        expect(
          block,
          contains('_TarotPositionMeaningMode.predefined'),
          reason: id,
        );
      }
      expect(
        definitionBlock('one_card'),
        isNot(contains('supportsDrag: true')),
      );
      expect(source, contains('labelAnchor: _TarotSlotAnchor.right'));
      expect(source, contains('infoAnchor: _TarotSlotAnchor.right'));
      for (final slotId in <String>[
        'free_1',
        'two_left',
        'three_present',
        'four_3',
      ]) {
        final slotStart = source.indexOf("slotId: '$slotId'");
        expect(slotStart, isNonNegative, reason: slotId);
        final slotEnd = source.indexOf('),', slotStart);
        final slotBlock = source.substring(slotStart, slotEnd);
        expect(
          slotBlock,
          contains('labelAnchor: _TarotSlotAnchor.bottom'),
          reason: '$slotId label must sit outside card art',
        );
      }
      expect(source, contains("slotId: 'five_1'"));
      expect(source, contains("slotId: 'five_3'"));
      expect(source, contains("slotId: 'five_5'"));
      expect(source, contains("slotId: 'celtic_result'"));
      expect(
        source,
        matches(RegExp(r"0\.84,\s+0\.03,\s+slotId: 'celtic_result'")),
      );
      expect(source, contains("rotationDeg: 90"));
      expect(source, contains("slotId: 'cup_left_top'"));
      expect(source, contains("slotId: 'cup_right_top'"));
      expect(source, contains("slotId: 'cup_overlap'"));
      expect(source, contains('preferredSide: _TarotSlotAnchor.outside'));
      expect(source, contains('labelAnchor: _TarotSlotAnchor.outside'));
    },
  );

  testWidgets(
    'Tarot expanded spreads render free, overlap, and radial boards',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Future<void> mountAtSpreadStep() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('tarot-active-setup-step-6')),
          findsOneWidget,
        );
      }

      Future<void> selectSpreadAndAutoDraw(
        String label, {
        Future<void> Function()? beforeDrawStep,
      }) async {
        await tester.ensureVisible(find.text(label).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        if (beforeDrawStep != null) await beforeDrawStep();
        await tester.ensureVisible(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
        await tester.tap(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
      }

      await mountAtSpreadStep();
      expect(find.text(UserText.tarotSpreadGroupFree), findsOneWidget);
      expect(find.text(UserText.tarotSpreadGroupFixed), findsOneWidget);
      for (final label in <String>[
        '자유 드로우',
        '2카드',
        '7카드',
        '그리드 6',
        '그리드 8',
        '그리드 9',
        '미니 켈틱 크로스',
        '십자',
        '말발굽',
        '매직 세븐',
        '리딩 마인드',
        '탄뎀',
        '릴레이션십',
        '컵 오브 릴레이션십',
        '호로스코프',
        '1년 운세',
      ]) {
        await tester.ensureVisible(find.text(label).first);
        await tester.pumpAndSettle();
        expect(find.text(label), findsAtLeastNWidgets(1), reason: label);
      }
      expect(find.text('관계 리딩'), findsNothing);
      expect(find.text('문제-원인-해결'), findsNothing);

      await selectSpreadAndAutoDraw(
        '자유 드로우',
        beforeDrawStep: () async {
          expect(
            find.byKey(const Key('tarot-free-draw-count-selector')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('tarot-free-draw-count-current')),
            findsOneWidget,
          );
          expect(find.text('5 / 30'), findsOneWidget);
          await tester.tap(
            find.byKey(const Key('tarot-free-draw-count-option-10')),
          );
          await tester.pumpAndSettle();
          expect(find.text('10 / 30'), findsOneWidget);
        },
      );
      expect(find.byKey(const Key('tarot-result-layout-10')), findsOneWidget);
      expect(find.byKey(const Key('tarot-free-draw-board')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-free-draw-top-strip')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-free-draw-draggable-card-0')),
        findsOneWidget,
      );

      void expectTrueGridGeometry({
        required String spreadId,
        required int count,
        required int columns,
        required int rows,
        required double minSlotHeight,
      }) {
        final rects = [
          for (var index = 0; index < count; index++)
            tester.getRect(find.byKey(Key('tarot-result-slot-$count-$index'))),
        ];
        expect(rects, hasLength(count));
        expect(rects.first.height, greaterThan(minSlotHeight));
        for (var row = 0; row < rows; row++) {
          final rowRects = rects.skip(row * columns).take(columns).toList();
          final y = rowRects.first.center.dy;
          for (final rect in rowRects) {
            expect((rect.center.dy - y).abs(), lessThan(3), reason: spreadId);
          }
          for (var column = 1; column < rowRects.length; column++) {
            expect(
              rowRects[column].center.dx,
              greaterThan(rowRects[column - 1].center.dx),
              reason: '$spreadId column order',
            );
          }
        }
        for (var row = 1; row < rows; row++) {
          expect(
            rects[row * columns].center.dy,
            greaterThan(rects[(row - 1) * columns].center.dy),
            reason: '$spreadId row order',
          );
        }
      }

      await mountAtSpreadStep();
      await selectSpreadAndAutoDraw('그리드 6');
      expect(find.byKey(const Key('tarot-result-layout-6')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-fixed-spread-board-grid_6')),
        findsOneWidget,
      );
      expectTrueGridGeometry(
        spreadId: 'grid_6',
        count: 6,
        columns: 3,
        rows: 2,
        minSlotHeight: 280,
      );

      await mountAtSpreadStep();
      await selectSpreadAndAutoDraw('그리드 9');
      expect(find.byKey(const Key('tarot-result-layout-9')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-fixed-spread-board-grid_9')),
        findsOneWidget,
      );
      expectTrueGridGeometry(
        spreadId: 'grid_9',
        count: 9,
        columns: 3,
        rows: 3,
        minSlotHeight: 220,
      );

      await mountAtSpreadStep();
      await selectSpreadAndAutoDraw('미니 켈틱 크로스');
      expect(find.byKey(const Key('tarot-result-layout-6')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-fixed-spread-board-mini_celtic_cross')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('tarot-spread-slot-mini_celtic_cross-mini_overlay'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tarot-free-draw-board')), findsNothing);

      await mountAtSpreadStep();
      await selectSpreadAndAutoDraw('호로스코프');
      expect(find.byKey(const Key('tarot-result-layout-13')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-fixed-spread-board-horoscope')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-spread-slot-horoscope-house_center')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-spread-slot-horoscope-house_12')),
        findsOneWidget,
      );
      expect(find.textContaining('저장', findRichText: true), findsNothing);
      expect(find.textContaining('export', findRichText: true), findsNothing);
      expect(find.textContaining('history', findRichText: true), findsNothing);
      expect(find.textContaining('AI', findRichText: true), findsNothing);
    },
  );

  testWidgets(
    'Tarot grid spreads keep real cards inside non-overlapping cells',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Future<void> mountAtSpreadStep() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
      }

      Future<void> selectSpreadAndAutoDraw(String label) async {
        await tester.ensureVisible(find.text(label).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
        await tester.tap(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
      }

      bool overlaps(Rect a, Rect b) =>
          a.left < b.right &&
          a.right > b.left &&
          a.top < b.bottom &&
          a.bottom > b.top;

      void expectCellGrid({
        required String spreadId,
        required String label,
        required int count,
        required int columns,
        required int rows,
        required double minHorizontalGap,
        required double minVerticalGap,
        required double minCardWidth,
      }) {
        final board = tester.getRect(
          find.byKey(Key('tarot-fixed-spread-board-$spreadId')),
        );
        final cardRects = [
          for (var index = 0; index < count; index++)
            tester.getRect(
              find.byKey(Key('tarot-grid-card-visual-$spreadId-$index')),
            ),
        ];
        expect(cardRects, hasLength(count), reason: spreadId);
        for (final rect in cardRects) {
          expect(
            rect.width,
            greaterThanOrEqualTo(minCardWidth),
            reason: '$spreadId readable card width',
          );
          expect(
            rect.left,
            greaterThanOrEqualTo(board.left + 16),
            reason: '$spreadId inside left',
          );
          expect(
            rect.right,
            lessThanOrEqualTo(board.right - 16),
            reason: '$spreadId inside right',
          );
          expect(
            rect.top,
            greaterThanOrEqualTo(board.top + 16),
            reason: '$spreadId inside top',
          );
          expect(
            rect.bottom,
            lessThanOrEqualTo(board.bottom - 16),
            reason: '$spreadId inside bottom',
          );
        }
        for (var a = 0; a < cardRects.length; a++) {
          for (var b = a + 1; b < cardRects.length; b++) {
            expect(
              overlaps(cardRects[a], cardRects[b]),
              isFalse,
              reason: '$spreadId card $a overlaps $b',
            );
          }
        }
        for (var row = 0; row < rows; row++) {
          final rowRects = cardRects.skip(row * columns).take(columns).toList();
          final y = rowRects.first.center.dy;
          for (final rect in rowRects) {
            expect(
              (rect.center.dy - y).abs(),
              lessThan(2),
              reason: '$spreadId row alignment',
            );
          }
          for (var column = 1; column < columns; column++) {
            final gap = rowRects[column].left - rowRects[column - 1].right;
            expect(
              gap,
              greaterThanOrEqualTo(minHorizontalGap),
              reason: '$spreadId horizontal gap',
            );
          }
        }
        for (var row = 1; row < rows; row++) {
          final upper = cardRects
              .skip((row - 1) * columns)
              .take(columns)
              .toList();
          final lower = cardRects.skip(row * columns).take(columns).toList();
          final gap =
              lower.map((r) => r.top).reduce(math.min) -
              upper.map((r) => r.bottom).reduce(math.max);
          expect(
            gap,
            greaterThanOrEqualTo(minVerticalGap),
            reason: '$spreadId vertical gap',
          );
        }
        expect(
          find.byKey(const Key('tarot-layout-adjustment-toolbar')),
          findsOneWidget,
          reason: label,
        );
        expect(tester.takeException(), isNull, reason: spreadId);
      }

      for (final spread
          in <
            ({
              String id,
              String label,
              int count,
              int columns,
              int rows,
              double minWidth,
            })
          >[
            (
              id: 'grid_6',
              label: '그리드 6',
              count: 6,
              columns: 3,
              rows: 2,
              minWidth: 180,
            ),
            (
              id: 'grid_8',
              label: '그리드 8',
              count: 8,
              columns: 4,
              rows: 2,
              minWidth: 158,
            ),
            (
              id: 'grid_9',
              label: '그리드 9',
              count: 9,
              columns: 3,
              rows: 3,
              minWidth: 150,
            ),
          ]) {
        await mountAtSpreadStep();
        await selectSpreadAndAutoDraw(spread.label);
        expectCellGrid(
          spreadId: spread.id,
          label: spread.label,
          count: spread.count,
          columns: spread.columns,
          rows: spread.rows,
          minHorizontalGap: 20,
          minVerticalGap: 26,
          minCardWidth: spread.minWidth,
        );
      }
    },
  );

  testWidgets('Tarot Celtic and cross spreads avoid accidental card overlap', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Future<void> mountAtSpreadStep() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
    }

    Future<void> selectSpreadAndAutoDraw(String label) async {
      await tester.ensureVisible(find.text(label).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
    }

    bool overlaps(Rect a, Rect b) =>
        a.left < b.right &&
        a.right > b.left &&
        a.top < b.bottom &&
        a.bottom > b.top;

    double horizontalGap(Rect a, Rect b) {
      if (a.right <= b.left) return b.left - a.right;
      if (b.right <= a.left) return a.left - b.right;
      return 0;
    }

    double verticalGap(Rect a, Rect b) {
      if (a.bottom <= b.top) return b.top - a.bottom;
      if (b.bottom <= a.top) return a.top - b.bottom;
      return 0;
    }

    void expectSpreadGeometry({
      required String spreadId,
      required String label,
      required int count,
      required double minCardWidth,
      required Set<String> intentionalOverlapPairs,
    }) {
      final board = tester.getRect(
        find.byKey(Key('tarot-fixed-spread-board-$spreadId')),
      );
      final cardRects = [
        for (var index = 0; index < count; index++)
          tester.getRect(
            find.byKey(Key('tarot-fixed-card-visual-$spreadId-$index')),
          ),
      ];
      expect(cardRects, hasLength(count), reason: spreadId);
      for (final rect in cardRects) {
        expect(
          rect.width,
          greaterThanOrEqualTo(minCardWidth),
          reason: '$spreadId readable card width',
        );
        expect(
          rect.left,
          greaterThanOrEqualTo(board.left + 12),
          reason: '$spreadId inside left',
        );
        expect(
          rect.right,
          lessThanOrEqualTo(board.right - 12),
          reason: '$spreadId inside right',
        );
        expect(
          rect.top,
          greaterThanOrEqualTo(board.top + 12),
          reason: '$spreadId inside top',
        );
        expect(
          rect.bottom,
          lessThanOrEqualTo(board.bottom - 12),
          reason: '$spreadId inside bottom',
        );
      }
      for (var a = 0; a < cardRects.length; a++) {
        for (var b = a + 1; b < cardRects.length; b++) {
          final pair = '$a:$b';
          if (intentionalOverlapPairs.contains(pair)) {
            expect(
              overlaps(cardRects[a], cardRects[b]),
              isTrue,
              reason: '$spreadId intentional crossing $pair',
            );
            continue;
          }
          expect(
            overlaps(cardRects[a], cardRects[b]),
            isFalse,
            reason: '$spreadId accidental overlap $pair',
          );
          expect(
            math.max(
              horizontalGap(cardRects[a], cardRects[b]),
              verticalGap(cardRects[a], cardRects[b]),
            ),
            greaterThanOrEqualTo(18),
            reason: '$spreadId near-overlap $pair',
          );
        }
      }
      expect(
        find.byKey(const Key('tarot-layout-adjustment-toolbar')),
        findsOneWidget,
        reason: label,
      );
      expect(
        find.byKey(const Key('tarot-reading-back-command')),
        findsOneWidget,
        reason: label,
      );
      expect(tester.takeException(), isNull, reason: spreadId);
    }

    for (final spread
        in <
          ({
            String id,
            String label,
            int count,
            double minWidth,
            Set<String> intentionalPairs,
          })
        >[
          (
            id: 'mini_celtic_cross',
            label: '미니 켈틱 크로스',
            count: 6,
            minWidth: 148,
            intentionalPairs: {'2:5'},
          ),
          (
            id: 'celtic_cross',
            label: UserText.tarotSpreadCeltic,
            count: 10,
            minWidth: 122,
            intentionalPairs: {'0:1'},
          ),
          (
            id: 'cross',
            label: '십자',
            count: 5,
            minWidth: 150,
            intentionalPairs: {},
          ),
        ]) {
      await mountAtSpreadStep();
      await selectSpreadAndAutoDraw(spread.label);
      expectSpreadGeometry(
        spreadId: spread.id,
        label: spread.label,
        count: spread.count,
        minCardWidth: spread.minWidth,
        intentionalOverlapPairs: spread.intentionalPairs,
      );
    }
  });

  testWidgets(
    'Tarot relationship cluster spreads keep intentional groups readable',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Future<void> mountAtSpreadStep() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
      }

      Future<void> selectSpreadAndAutoDraw(String label) async {
        await tester.ensureVisible(find.text(label).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
        await tester.tap(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
      }

      bool overlaps(Rect a, Rect b) =>
          a.left < b.right &&
          a.right > b.left &&
          a.top < b.bottom &&
          a.bottom > b.top;

      double horizontalGap(Rect a, Rect b) {
        if (a.right <= b.left) return b.left - a.right;
        if (b.right <= a.left) return a.left - b.right;
        return 0;
      }

      double verticalGap(Rect a, Rect b) {
        if (a.bottom <= b.top) return b.top - a.bottom;
        if (b.bottom <= a.top) return a.top - b.bottom;
        return 0;
      }

      void expectClusterGeometry({
        required String spreadId,
        required String label,
        required int count,
        required double minCardWidth,
        required Set<String> intentionalOverlapPairs,
      }) {
        final board = tester.getRect(
          find.byKey(Key('tarot-fixed-spread-board-$spreadId')),
        );
        final cardRects = [
          for (var index = 0; index < count; index++)
            tester.getRect(
              find.byKey(Key('tarot-fixed-card-visual-$spreadId-$index')),
            ),
        ];
        expect(cardRects, hasLength(count), reason: spreadId);
        for (final rect in cardRects) {
          expect(
            rect.width,
            greaterThanOrEqualTo(minCardWidth),
            reason: '$spreadId readable card width',
          );
          expect(
            rect.left,
            greaterThanOrEqualTo(board.left + 12),
            reason: '$spreadId inside left',
          );
          expect(
            rect.right,
            lessThanOrEqualTo(board.right - 12),
            reason: '$spreadId inside right',
          );
          expect(
            rect.top,
            greaterThanOrEqualTo(board.top + 12),
            reason: '$spreadId inside top',
          );
          expect(
            rect.bottom,
            lessThanOrEqualTo(board.bottom - 12),
            reason: '$spreadId inside bottom',
          );
        }
        for (var a = 0; a < cardRects.length; a++) {
          for (var b = a + 1; b < cardRects.length; b++) {
            final pair = '$a:$b';
            if (intentionalOverlapPairs.contains(pair)) {
              expect(
                overlaps(cardRects[a], cardRects[b]),
                isTrue,
                reason: '$spreadId intentional cluster overlap $pair',
              );
              continue;
            }
            expect(
              overlaps(cardRects[a], cardRects[b]),
              isFalse,
              reason: '$spreadId accidental overlap $pair',
            );
            expect(
              math.max(
                horizontalGap(cardRects[a], cardRects[b]),
                verticalGap(cardRects[a], cardRects[b]),
              ),
              greaterThanOrEqualTo(16),
              reason: '$spreadId near-overlap $pair',
            );
          }
        }
        expect(
          find.byKey(const Key('tarot-layout-adjustment-toolbar')),
          findsOneWidget,
          reason: label,
        );
        expect(
          find.byKey(const Key('tarot-reading-back-command')),
          findsOneWidget,
          reason: label,
        );
        expect(tester.takeException(), isNull, reason: spreadId);
      }

      for (final spread
          in <
            ({
              String id,
              String label,
              int count,
              double minWidth,
              Set<String> intentionalPairs,
            })
          >[
            (
              id: 'reading_mind',
              label: '리딩 마인드',
              count: 9,
              minWidth: 124,
              intentionalPairs: {},
            ),
            (
              id: 'tandem',
              label: '탄뎀',
              count: 6,
              minWidth: 146,
              intentionalPairs: {},
            ),
            (
              id: 'relationship',
              label: '릴레이션십',
              count: 7,
              minWidth: 138,
              intentionalPairs: {},
            ),
            (
              id: 'cup_of_relationship',
              label: '컵 오브 릴레이션십',
              count: 9,
              minWidth: 116,
              intentionalPairs: {'4:6'},
            ),
          ]) {
        await mountAtSpreadStep();
        await selectSpreadAndAutoDraw(spread.label);
        expectClusterGeometry(
          spreadId: spread.id,
          label: spread.label,
          count: spread.count,
          minCardWidth: spread.minWidth,
          intentionalOverlapPairs: spread.intentionalPairs,
        );
      }
    },
  );

  testWidgets(
    'Tarot remaining owner-polish spreads keep readable default geometry',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Future<void> mountAtSpreadStep() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
      }

      Future<void> selectSpreadAndAutoDraw(String label) async {
        await tester.ensureVisible(find.text(label).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
        await tester.tap(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
      }

      bool overlaps(Rect a, Rect b) =>
          a.left < b.right &&
          a.right > b.left &&
          a.top < b.bottom &&
          a.bottom > b.top;

      double horizontalGap(Rect a, Rect b) {
        if (a.right <= b.left) return b.left - a.right;
        if (b.right <= a.left) return a.left - b.right;
        return 0;
      }

      double verticalGap(Rect a, Rect b) {
        if (a.bottom <= b.top) return b.top - a.bottom;
        if (b.bottom <= a.top) return a.top - b.bottom;
        return 0;
      }

      void expectPolishedGeometry({
        required String spreadId,
        required String label,
        required int count,
        required double minCardWidth,
        required double minSeparation,
      }) {
        final board = tester.getRect(
          find.byKey(Key('tarot-fixed-spread-board-$spreadId')),
        );
        final cardRects = [
          for (var index = 0; index < count; index++)
            tester.getRect(
              find.byKey(Key('tarot-fixed-card-visual-$spreadId-$index')),
            ),
        ];
        expect(cardRects, hasLength(count), reason: spreadId);
        for (final rect in cardRects) {
          expect(
            rect.width,
            greaterThanOrEqualTo(minCardWidth),
            reason: '$spreadId readable card width',
          );
          expect(
            rect.left,
            greaterThanOrEqualTo(board.left + 8),
            reason: '$spreadId inside left',
          );
          expect(
            rect.right,
            lessThanOrEqualTo(board.right - 8),
            reason: '$spreadId inside right',
          );
          expect(
            rect.top,
            greaterThanOrEqualTo(board.top + 8),
            reason: '$spreadId inside top',
          );
          expect(
            rect.bottom,
            lessThanOrEqualTo(board.bottom - 8),
            reason: '$spreadId inside bottom',
          );
        }
        for (var a = 0; a < cardRects.length; a++) {
          for (var b = a + 1; b < cardRects.length; b++) {
            expect(
              overlaps(cardRects[a], cardRects[b]),
              isFalse,
              reason: '$spreadId accidental overlap $a:$b',
            );
            expect(
              math.max(
                horizontalGap(cardRects[a], cardRects[b]),
                verticalGap(cardRects[a], cardRects[b]),
              ),
              greaterThanOrEqualTo(minSeparation),
              reason: '$spreadId near-overlap $a:$b',
            );
          }
        }
        expect(
          find.byKey(const Key('tarot-layout-adjustment-toolbar')),
          findsOneWidget,
          reason: label,
        );
        expect(
          find.byKey(const Key('tarot-reading-back-command')),
          findsOneWidget,
          reason: label,
        );
        expect(tester.takeException(), isNull, reason: spreadId);
      }

      for (final spread
          in <
            ({
              String id,
              String label,
              int count,
              double minWidth,
              double minSeparation,
            })
          >[
            (
              id: 'seven_card',
              label: '7카드',
              count: 7,
              minWidth: 168,
              minSeparation: 16,
            ),
            (
              id: 'binary_choice',
              label: UserText.tarotSpreadBinary,
              count: 5,
              minWidth: 152,
              minSeparation: 16,
            ),
            (
              id: 'horseshoe',
              label: '말발굽',
              count: 5,
              minWidth: 154,
              minSeparation: 16,
            ),
            (
              id: 'horoscope',
              label: '호로스코프',
              count: 13,
              minWidth: 112,
              minSeparation: 4,
            ),
            (
              id: 'year_ahead',
              label: '1년 운세',
              count: 13,
              minWidth: 112,
              minSeparation: 4,
            ),
          ]) {
        await mountAtSpreadStep();
        await selectSpreadAndAutoDraw(spread.label);
        expectPolishedGeometry(
          spreadId: spread.id,
          label: spread.label,
          count: spread.count,
          minCardWidth: spread.minWidth,
          minSeparation: spread.minSeparation,
        );
      }
    },
  );

  testWidgets(
    'Tarot revealed result card opens and closes focus detail overlay',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();

      await tester.tap(find.text('모두 펼치기'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tarot-focus-detail-overlay')), findsNothing);

      final boardCardRect = tester.getRect(
        find.byKey(const Key('tarot-focusable-result-card-0')),
      );
      await tester.tap(find.byKey(const Key('tarot-focusable-result-card-0')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('tarot-focus-detail-overlay')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tarot-focus-card-image')), findsOneWidget);
      final focusedCardRect = tester.getRect(
        find.byKey(const Key('tarot-focus-card-image')),
      );
      expect(focusedCardRect.height, greaterThan(boardCardRect.height * 1.25));
      expect(find.byKey(const Key('tarot-focus-card-name')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-focus-card-orientation')),
        findsOneWidget,
      );
      expect(find.text(UserText.tarotUpright), findsOneWidget);
      expect(find.text('과거'), findsWidgets);
      expect(find.text(UserText.tarotDeckUniversalWaite), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-layout-adjustment-toolbar')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-reading-back-command')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-fixed-spread-board-three_card')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('tarot-focus-close-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tarot-focus-detail-overlay')), findsNothing);
      expect(
        find.byKey(const Key('tarot-fixed-spread-board-three_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-layout-adjustment-toolbar')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-reading-back-command')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Tarot all 22 spreads render from manual geometry blueprints', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const spreads = <({String id, String label, int count, bool freeDraw})>[
      (id: 'free_draw', label: '자유 드로우', count: 5, freeDraw: true),
      (
        id: 'one_card',
        label: UserText.tarotSpreadOne,
        count: 1,
        freeDraw: false,
      ),
      (id: 'two_card', label: '2카드', count: 2, freeDraw: false),
      (
        id: 'three_card',
        label: UserText.tarotSpreadThree,
        count: 3,
        freeDraw: false,
      ),
      (
        id: 'four_card',
        label: UserText.tarotSpreadFour,
        count: 4,
        freeDraw: false,
      ),
      (
        id: 'five_card',
        label: UserText.tarotSpreadFive,
        count: 5,
        freeDraw: false,
      ),
      (id: 'seven_card', label: '7카드', count: 7, freeDraw: false),
      (id: 'grid_6', label: '그리드 6', count: 6, freeDraw: false),
      (id: 'grid_8', label: '그리드 8', count: 8, freeDraw: false),
      (id: 'grid_9', label: '그리드 9', count: 9, freeDraw: false),
      (
        id: 'celtic_cross',
        label: UserText.tarotSpreadCeltic,
        count: 10,
        freeDraw: false,
      ),
      (id: 'mini_celtic_cross', label: '미니 켈틱 크로스', count: 6, freeDraw: false),
      (id: 'cross', label: '십자', count: 5, freeDraw: false),
      (id: 'horseshoe', label: '말발굽', count: 5, freeDraw: false),
      (id: 'magic_seven', label: '매직 세븐', count: 7, freeDraw: false),
      (
        id: 'binary_choice',
        label: UserText.tarotSpreadBinary,
        count: 5,
        freeDraw: false,
      ),
      (id: 'reading_mind', label: '리딩 마인드', count: 9, freeDraw: false),
      (id: 'tandem', label: '탄뎀', count: 6, freeDraw: false),
      (id: 'relationship', label: '릴레이션십', count: 7, freeDraw: false),
      (
        id: 'cup_of_relationship',
        label: '컵 오브 릴레이션십',
        count: 9,
        freeDraw: false,
      ),
      (id: 'horoscope', label: '호로스코프', count: 13, freeDraw: false),
      (id: 'year_ahead', label: '1년 운세', count: 13, freeDraw: false),
    ];

    for (final spread in spreads) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(spread.label).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(spread.label).first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();

      expect(
        find.byKey(Key('tarot-result-layout-${spread.count}')),
        findsOneWidget,
        reason: spread.id,
      );
      expect(
        find.byKey(
          Key(
            spread.freeDraw
                ? 'tarot-free-draw-board'
                : 'tarot-fixed-spread-board-${spread.id}',
          ),
        ),
        findsOneWidget,
        reason: spread.id,
      );
      expect(
        find.byKey(const Key('tarot-reading-back-command')),
        findsOneWidget,
        reason: spread.id,
      );
      expect(
        find.byKey(const Key('tarot-layout-adjustment-toolbar')),
        findsOneWidget,
        reason: spread.id,
      );
      expect(
        find.byKey(const Key('tarot-result-card-back-slot')),
        findsAtLeastNWidgets(spread.count),
        reason: spread.id,
      );
      final firstRect = tester.getRect(
        find.byKey(Key('tarot-result-slot-${spread.count}-0')),
      );
      expect(firstRect.width, greaterThan(95), reason: spread.id);
      expect(firstRect.height, greaterThan(160), reason: spread.id);
      expect(tester.takeException(), isNull, reason: spread.id);
    }
  });
}
