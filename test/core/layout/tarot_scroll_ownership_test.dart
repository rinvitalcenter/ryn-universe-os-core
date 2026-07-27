import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/layout/ryn_workspace_host.dart';
import 'package:ryn_universe_os_core/core/text/user_text.dart';
import 'package:ryn_universe_os_core/features/tarot/tarot_spread_shell.dart';

Finder _modeAncestor(Finder target, RynWorkspaceScrollMode mode) =>
    find.ancestor(
      of: target,
      matching: find.byKey(RynWorkspacePresentationScope.modeKey(mode)),
    );

Finder _documentScrollAncestor(Finder target) =>
    find.ancestor(of: target, matching: find.byType(SingleChildScrollView));

Future<void> _pumpTarot(
  WidgetTester tester, {
  double textScale = 1,
  Size size = const Size(1440, 1000),
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
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: Scaffold(body: TarotSpreadShell(onBack: () {})),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openRitual(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const Key('tarot-rail-change-deck')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('tarot-rail-change-deck')));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('다음'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('다음'));
  await tester.pumpAndSettle();
  final oneCard = find.widgetWithText(ChoiceChip, UserText.tarotSpreadOne);
  await tester.ensureVisible(oneCard);
  await tester.pumpAndSettle();
  await tester.tap(oneCard);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('다음'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('다음'));
  await tester.pumpAndSettle();
}

Future<void> _openInterpretation(WidgetTester tester) async {
  await _openRitual(tester);
  await tester.tap(find.text(UserText.tarotAutoDraw));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('tarot-result-card-back-slot')).first);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('tarot-open-interpretation-button')));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues();
  });

  testWidgets('Tarot setup owns one page scroll and reaches continuation', (
    tester,
  ) async {
    await _pumpTarot(tester);

    final setup = find.byKey(const Key('tarot-active-setup-step-0'));
    expect(setup, findsOneWidget);
    expect(find.byKey(const Key('tarot-setup-page-scroll')), findsOneWidget);
    expect(
      _modeAncestor(setup, RynWorkspaceScrollMode.featurePage),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byKey(const Key('tarot-rail-change-deck')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tarot-rail-change-deck')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ritual Selection Revelation are viewport bounded', (
    tester,
  ) async {
    await _pumpTarot(tester);
    await _openRitual(tester);

    final ritual = find.byKey(const Key('tarot-r2-stage-ritual'));
    expect(ritual, findsOneWidget);
    expect(
      _modeAncestor(ritual, RynWorkspaceScrollMode.viewportBounded),
      findsOneWidget,
    );
    expect(_documentScrollAncestor(ritual), findsNothing);
    expect(
      find.byKey(const Key('tarot-shuffle-button')).hitTestable(),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('tarot-shuffle-button')));
    await tester.pumpAndSettle();
    final selection = find.byKey(const Key('tarot-r2-stage-selection'));
    expect(selection, findsOneWidget);
    expect(
      _modeAncestor(selection, RynWorkspaceScrollMode.viewportBounded),
      findsOneWidget,
    );
    expect(_documentScrollAncestor(selection), findsNothing);
    expect(find.byKey(const Key('tarot-show-result-button')), findsOneWidget);

    await tester.tap(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();
    final revelation = find.byKey(const Key('tarot-r2-stage-revelation'));
    expect(revelation, findsOneWidget);
    expect(
      _modeAncestor(revelation, RynWorkspaceScrollMode.viewportBounded),
      findsOneWidget,
    );
    expect(_documentScrollAncestor(revelation), findsNothing);
    expect(
      find.byKey(const Key('tarot-open-interpretation-button')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Interpretation uses only its intentional story panel scroll', (
    tester,
  ) async {
    await _pumpTarot(tester);
    await _openRitual(tester);
    await tester.tap(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('tarot-result-card-back-slot')).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tarot-open-interpretation-button')));
    await tester.pumpAndSettle();

    final interpretation = find.byKey(const Key('tarot-interpretation-shell'));
    expect(interpretation, findsOneWidget);
    expect(
      _modeAncestor(interpretation, RynWorkspaceScrollMode.independentPanels),
      findsOneWidget,
    );
    expect(_documentScrollAncestor(interpretation), findsNothing);
    expect(
      find.byKey(const Key('tarot-interpretation-fields-scroll')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('tarot-interpretation-completion-dock')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final textScale in [1.0, 1.25, 1.5]) {
    testWidgets(
      'compact Interpretation keeps spread and dock outside story scroll at $textScale',
      (tester) async {
        await _pumpTarot(
          tester,
          size: const Size(840, 1000),
          textScale: textScale,
        );
        await _openInterpretation(tester);

        final interpretation = find.byKey(
          const Key('tarot-interpretation-shell'),
        );
        final storyScroll = find.byKey(
          const Key('tarot-interpretation-fields-scroll'),
        );
        final spread = find.byKey(
          const Key('tarot-interpretation-spread-snapshot-preview'),
        );
        final dock = find.byKey(
          const Key('tarot-interpretation-completion-dock'),
        );
        expect(
          _modeAncestor(
            interpretation,
            RynWorkspaceScrollMode.independentPanels,
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('tarot-interpretation-compact-scroll')),
          findsNothing,
        );
        expect(storyScroll, findsOneWidget);
        expect(find.ancestor(of: spread, matching: storyScroll), findsNothing);
        expect(find.ancestor(of: dock, matching: storyScroll), findsNothing);
        expect(
          find.byKey(const Key('tarot-open-records-action')).hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull, reason: 'textScale=$textScale');
      },
    );
  }

  testWidgets('compact Interpretation completion remains reachable at 2.0', (
    tester,
  ) async {
    await _pumpTarot(tester, size: const Size(840, 1000), textScale: 2);
    await _openInterpretation(tester);

    expect(
      find.byKey(const Key('tarot-interpretation-fields-scroll')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('tarot-open-records-action')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final scenario in <(String, Size, double)>[
    ('galaxy', const Size(1920, 1009.5), 1),
    ('1366', const Size(1366, 768), 1),
    ('galaxy-125', const Size(1920, 1009.5), 1.25),
    ('galaxy-150', const Size(1920, 1009.5), 1.5),
  ]) {
    testWidgets(
      'Preparation CTA bounds hit-test and transition ${scenario.$1}',
      (tester) async {
        await _pumpTarot(tester, size: scenario.$2, textScale: scenario.$3);
        final cta = find.byKey(const Key('tarot-rail-primary-cta'));
        final setupViewport = find.byKey(const Key('tarot-setup-page-scroll'));
        expect(cta, findsOneWidget);
        expect(tester.widget<FilledButton>(cta).onPressed, isNotNull);

        await tester.ensureVisible(cta);
        await tester.pumpAndSettle();
        final ctaRect = tester.getRect(cta);
        final viewportRect = tester.getRect(setupViewport);
        expect(ctaRect.left, greaterThanOrEqualTo(viewportRect.left));
        expect(ctaRect.right, lessThanOrEqualTo(viewportRect.right));
        expect(ctaRect.top, greaterThanOrEqualTo(viewportRect.top));
        expect(ctaRect.bottom, lessThanOrEqualTo(viewportRect.bottom));
        expect(cta.hitTestable(at: Alignment.center), findsOneWidget);

        await tester.tapAt(ctaRect.center);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tarot-r2-stage-ritual')), findsOneWidget);
        expect(tester.takeException(), isNull, reason: scenario.$1);
      },
    );
  }

  testWidgets('context ribbon and primary command remain usable at 2.0', (
    tester,
  ) async {
    await _pumpTarot(tester, textScale: 2);
    await _openRitual(tester);
    await tester.tap(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('tarot-reading-context-ribbon')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('tarot-reading-command-bar')), findsOneWidget);
    expect(
      find.byKey(const Key('tarot-open-interpretation-button')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('immersive stages stay bounded at 1366x768', (tester) async {
    await _pumpTarot(tester, size: const Size(1366, 768));
    await _openRitual(tester);
    expect(find.byKey(const Key('tarot-r2-stage-ritual')), findsOneWidget);
    expect(
      find.byKey(const Key('tarot-shuffle-button')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('tarot-shuffle-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-r2-stage-selection')), findsOneWidget);
    expect(find.byKey(const Key('tarot-show-result-button')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-r2-stage-revelation')), findsOneWidget);
    expect(
      find.byKey(const Key('tarot-open-interpretation-button')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
