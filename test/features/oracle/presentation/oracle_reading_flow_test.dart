import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/main.dart';
import 'package:ryn_universe_os_core/features/oracle/application/oracle_reading_controller.dart';
import 'package:ryn_universe_os_core/features/oracle/domain/oracle_reading_session.dart';
import 'package:ryn_universe_os_core/features/oracle/presentation/oracle_reading_shell.dart';
import 'package:ryn_universe_os_core/features/reading/presentation/reading_atelier_page.dart';

void main() {
  testWidgets('Reading Atelier exposes independent Tarot and Oracle entries', (
    tester,
  ) async {
    var tarotStarted = false;
    await _pumpAtSize(
      tester,
      size: const Size(1280, 720),
      child: ReadingAtelierPage(
        onStartTarot: () => tarotStarted = true,
        onStartOracle: () {},
      ),
    );

    expect(find.text('Reading Atelier'), findsOneWidget);
    expect(find.text('구조를 읽다'), findsOneWidget);
    expect(find.text('메시지를 듣다'), findsOneWidget);
    expect(find.byKey(const Key('reading-atelier-scene')), findsOneWidget);
    expect(
      find.byKey(const Key('reading-atelier-continuous-field')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('atelier-tarot-doorway')), findsOneWidget);
    expect(find.byKey(const Key('atelier-oracle-doorway')), findsOneWidget);
    expect(find.byKey(const Key('atelier-empty-card-stack')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('atelier-tarot-action')));
    expect(tarotStarted, isTrue);
  });

  testWidgets('Oracle entry opens the Horoscope Belline setup', (tester) async {
    await _pumpAtSize(
      tester,
      size: const Size(1280, 720),
      child: const _ReadingEntryHarness(),
    );

    await tester.tap(find.byKey(const Key('atelier-oracle-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('oracle-reading-shell')), findsOneWidget);
    expect(find.text('호로스코프 벨린 오라클'), findsAtLeastNWidgets(1));
    expect(find.text('52장'), findsOneWidget);
    expect(find.text('역방향 미사용'), findsOneWidget);
    expect(find.byKey(const Key('oracle-draw-choice-1')), findsOneWidget);
    expect(find.byKey(const Key('oracle-draw-choice-3')), findsOneWidget);
    expect(find.byKey(const Key('oracle-setup-cover-scene')), findsOneWidget);
    final start = find.byKey(const Key('oracle-start-reading'));
    expect(tester.widget<FilledButton>(start).onPressed, isNull);
    expect(find.text('메시지를 만나기'), findsOneWidget);
    final choices = find.byType(SegmentedButton<int>);
    expect(tester.widget<SegmentedButton<int>>(choices).selected, {1});
    await tester.tap(find.byKey(const Key('oracle-draw-choice-3')));
    await tester.pump();
    expect(tester.widget<SegmentedButton<int>>(choices).selected, {3});
  });

  testWidgets(
    'shuffle is one-shot and draw uses ribbons with a selection dock',
    (tester) async {
      final controller = OracleReadingController();
      await _pumpAtSize(
        tester,
        size: const Size(1280, 720),
        child: OracleReadingShell(
          controller: controller,
          onBackToAtelier: () {},
        ),
      );
      await tester.enterText(
        find.byKey(const Key('oracle-question-field')),
        'SYNTHETIC_ORACLE_QUESTION',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('oracle-draw-choice-3')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('oracle-start-reading')));
      await tester.pumpAndSettle();

      final shuffle = find.byKey(const Key('oracle-shuffle-action'));
      await tester.tap(shuffle);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.widget<FilledButton>(shuffle).onPressed, isNull);
      expect(controller.stage, OracleReadingStage.shuffle);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('oracle-draw-ribbon-1')), findsOneWidget);
      expect(find.byKey(const Key('oracle-draw-ribbon-2')), findsOneWidget);
      expect(find.byKey(const Key('oracle-draw-ribbon-3')), findsOneWidget);
      expect(find.byKey(const Key('oracle-selection-dock')), findsOneWidget);
      expect(find.byKey(const Key('oracle-selection-slot-1')), findsOneWidget);
      expect(find.byKey(const Key('oracle-selection-slot-2')), findsOneWidget);
      expect(find.byKey(const Key('oracle-selection-slot-3')), findsOneWidget);
      final reveal = find.byKey(const Key('oracle-confirm-selection'));
      expect(tester.widget<FilledButton>(reveal).onPressed, isNull);

      final card = controller.shuffledCards.first;
      final cardFinder = find.byKey(Key('oracle-draw-card-${card.cardId}'));
      await tester.ensureVisible(cardFinder);
      await tester.tap(cardFinder);
      await tester.pump();
      expect(controller.selectedCards, hasLength(1));
      expect(find.byKey(const Key('oracle-selected-card-1')), findsOneWidget);
      await tester.tap(cardFinder);
      await tester.pump();
      expect(controller.selectedCards, isEmpty);
    },
  );

  testWidgets('Core Reading navigation opens the real Oracle shell', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const RynUniverseApp(bootstrapOnStart: false));
    await tester.pumpAndSettle();

    final readingNav = find.text('리딩').first;
    await tester.ensureVisible(readingNav);
    await tester.tap(readingNav);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reading-atelier-page')), findsOneWidget);

    await tester.tap(find.byKey(const Key('atelier-oracle-action')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('oracle-reading-shell')), findsOneWidget);
  });

  testWidgets('front assets stay hidden until exact manual draw is revealed', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final controller = OracleReadingController();
    await _pumpAtSize(
      tester,
      size: const Size(1280, 720),
      child: OracleReadingShell(controller: controller, onBackToAtelier: () {}),
    );

    await tester.enterText(
      find.byKey(const Key('oracle-question-field')),
      'SYNTHETIC_ORACLE_QUESTION',
    );
    await tester.pump();
    final threeChoice = find.byKey(const Key('oracle-draw-choice-3'));
    await tester.ensureVisible(threeChoice);
    await tester.tap(threeChoice);
    await tester.pump();
    final start = find.byKey(const Key('oracle-start-reading'));
    await tester.ensureVisible(start);
    expect(tester.widget<FilledButton>(start).onPressed, isNotNull);
    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(controller.stage, OracleReadingStage.shuffle);
    await tester.tap(find.byKey(const Key('oracle-shuffle-action')));
    await tester.pumpAndSettle();

    final hiddenCard = controller.shuffledCards.first;
    expect(
      find.bySemanticsLabel('${hiddenCard.sequence}번 카드, 선택 가능'),
      findsNothing,
    );
    expect(find.bySemanticsLabel('뒤집힌 오라클 카드, 선택 가능'), findsWidgets);
    expect(find.byKey(const Key('oracle-result-card-image-1')), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName.contains('/cards/'),
      ),
      findsNothing,
    );

    for (final card in controller.shuffledCards.take(3)) {
      final finder = find.byKey(Key('oracle-draw-card-${card.cardId}'));
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump();
    }
    expect(controller.selectedCards, hasLength(3));

    final reveal = find.byKey(const Key('oracle-confirm-selection'));
    await tester.ensureVisible(reveal);
    await tester.tap(reveal);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('oracle-result-card-image-1')), findsOneWidget);
    expect(find.byKey(const Key('oracle-result-card-image-2')), findsOneWidget);
    expect(find.byKey(const Key('oracle-result-card-image-3')), findsOneWidget);
    expect(find.byKey(const Key('oracle-story-workspace')), findsOneWidget);
    expect(find.byKey(const Key('oracle-story-card-scene')), findsOneWidget);
    expect(find.text('지금'), findsOneWidget);
    expect(find.text('알아차릴 것'), findsOneWidget);
    expect(find.text('작은 실천'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('reflection completes and latest result resumes in one session', (
    tester,
  ) async {
    final controller = OracleReadingController();
    await _pumpAtSize(
      tester,
      size: const Size(1280, 720),
      child: OracleReadingShell(controller: controller, onBackToAtelier: () {}),
    );

    await tester.enterText(
      find.byKey(const Key('oracle-question-field')),
      'SYNTHETIC_ORACLE_QUESTION',
    );
    await tester.pump();
    final start = find.byKey(const Key('oracle-start-reading'));
    await tester.ensureVisible(start);
    expect(tester.widget<FilledButton>(start).onPressed, isNotNull);
    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(controller.stage, OracleReadingStage.shuffle);
    await tester.tap(find.byKey(const Key('oracle-shuffle-action')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('oracle-selection-slot-1')), findsOneWidget);
    expect(find.byKey(const Key('oracle-selection-slot-2')), findsNothing);

    final card = controller.shuffledCards.first;
    final cardFinder = find.byKey(Key('oracle-draw-card-${card.cardId}'));
    await tester.ensureVisible(cardFinder);
    await tester.tap(cardFinder);
    await tester.pump();
    final reveal = find.byKey(const Key('oracle-confirm-selection'));
    await tester.ensureVisible(reveal);
    await tester.tap(reveal);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('oracle-message-action')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('oracle-story-workspace')), findsOneWidget);
    expect(find.byKey(const Key('oracle-story-card-scene')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('oracle-message-note-field')),
      '합성 메시지',
    );
    await tester.enterText(
      find.byKey(const Key('oracle-small-action-field')),
      '합성 실천',
    );
    await tester.tap(find.byKey(const Key('oracle-complete-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('oracle-completed-stage')), findsOneWidget);
    expect(find.byKey(const Key('oracle-story-workspace')), findsOneWidget);
    expect(find.byKey(const Key('oracle-story-card-scene')), findsOneWidget);
    expect(find.byKey(const Key('oracle-new-reading-action')), findsOneWidget);
    expect(find.text('SYNTHETIC_ORACLE_QUESTION'), findsOneWidget);
    expect(find.text('합성 메시지'), findsOneWidget);
    expect(find.text('합성 실천'), findsOneWidget);
    expect(controller.latestResult, isNotNull);

    final continueAction = find.byKey(
      const Key('oracle-continue-latest-action'),
    );
    await tester.ensureVisible(continueAction);
    await tester.tap(continueAction);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('oracle-message-note-field')), findsOneWidget);
  });

  testWidgets('Atelier keeps the completed Oracle scene available to resume', (
    tester,
  ) async {
    final controller = OracleReadingController();
    controller.start(questionText: 'SYNTHETIC_ORACLE_QUESTION', drawCount: 1);
    controller.shuffle();
    controller.selectCard(controller.shuffledCards.first.cardId);
    controller.confirmSelection();
    controller.openInterpretation();
    controller.updateInterpretation(
      messageNote: '합성 메시지',
      smallAction: '합성 실천',
    );
    controller.complete();
    var resumed = false;
    await _pumpAtSize(
      tester,
      size: const Size(1280, 720),
      child: ReadingAtelierPage(
        onStartTarot: () {},
        onStartOracle: () {},
        recentOracleResult: controller.latestResult,
        onResumeOracle: () => resumed = true,
      ),
    );

    expect(find.byKey(const Key('atelier-empty-card-stack')), findsNothing);
    expect(find.text('SYNTHETIC_ORACLE_QUESTION'), findsOneWidget);
    await tester.tap(find.byKey(const Key('atelier-resume-oracle-action')));
    expect(resumed, isTrue);
  });

  testWidgets('Oracle Story Workspace stays usable at 1280 and 900 widths', (
    tester,
  ) async {
    for (final width in [1280.0, 900.0]) {
      final controller = OracleReadingController();
      controller.start(questionText: 'SYNTHETIC_ORACLE_QUESTION', drawCount: 3);
      controller.shuffle();
      for (final card in controller.shuffledCards.take(3)) {
        controller.selectCard(card.cardId);
      }
      controller.confirmSelection();
      await _pumpAtSize(
        tester,
        size: Size(width, 720),
        child: OracleReadingShell(
          controller: controller,
          onBackToAtelier: () {},
        ),
      );

      expect(tester.takeException(), isNull, reason: 'width=$width');
      expect(find.byKey(const Key('oracle-story-workspace')), findsOneWidget);
      expect(find.byKey(const Key('oracle-story-card-scene')), findsOneWidget);
      if (width == 1280) {
        expect(
          tester.getRect(find.byKey(const Key('oracle-message-action'))).bottom,
          lessThanOrEqualTo(720),
        );
      }
    }
  });

  testWidgets('Atelier remains overflow-free at approved responsive widths', (
    tester,
  ) async {
    for (final width in [1280.0, 1000.0, 900.0, 860.0]) {
      await _pumpAtSize(
        tester,
        size: Size(width, 720),
        child: ReadingAtelierPage(onStartTarot: () {}, onStartOracle: () {}),
      );
      expect(tester.takeException(), isNull, reason: 'width=$width');
      expect(find.byKey(const Key('atelier-tarot-action')), findsOneWidget);
      expect(find.byKey(const Key('atelier-oracle-action')), findsOneWidget);
      if (width == 1280) {
        expect(
          tester.getRect(find.byKey(const Key('atelier-oracle-action'))).bottom,
          lessThanOrEqualTo(720),
        );
      }
    }
  });
}

Future<void> _pumpAtSize(
  WidgetTester tester, {
  required Size size,
  required Widget child,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}

class _ReadingEntryHarness extends StatefulWidget {
  const _ReadingEntryHarness();

  @override
  State<_ReadingEntryHarness> createState() => _ReadingEntryHarnessState();
}

class _ReadingEntryHarnessState extends State<_ReadingEntryHarness> {
  final controller = OracleReadingController();
  var oracleOpen = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (oracleOpen) {
      return OracleReadingShell(
        controller: controller,
        onBackToAtelier: () => setState(() => oracleOpen = false),
      );
    }
    return ReadingAtelierPage(
      onStartTarot: () {},
      onStartOracle: () => setState(() => oracleOpen = true),
      recentOracleResult: controller.latestResult,
      onResumeOracle: controller.latestResult == null
          ? null
          : () {
              controller.resumeLatest();
              setState(() => oracleOpen = true);
            },
    );
  }
}
