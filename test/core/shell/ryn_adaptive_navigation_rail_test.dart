import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/shell/ryn_adaptive_navigation_rail.dart';
import 'package:ryn_universe_os_core/core/shell/ryn_app_shell.dart';
import 'package:ryn_universe_os_core/core/shell/ryn_top_utility_bar.dart';
import 'package:ryn_universe_os_core/core/theme/ryn_tokens.dart';

const _destinations = <RynShellDestination>[
  RynShellDestination(id: 'home', label: '홈', icon: Icons.home_rounded),
  RynShellDestination(
    id: 'people',
    label: '사람',
    icon: Icons.people_alt_rounded,
  ),
  RynShellDestination(
    id: 'records',
    label: '기록',
    icon: Icons.edit_note_rounded,
  ),
];

Widget _themed(Widget child, {ThemeMode mode = ThemeMode.light}) {
  return MaterialApp(
    theme: RynTheme.light(fontFamily: 'Arial', fontFamilyFallback: const []),
    darkTheme: RynTheme.dark(fontFamily: 'Arial', fontFamilyFallback: const []),
    themeMode: mode,
    home: child,
  );
}

class _ShellHarness extends StatefulWidget {
  const _ShellHarness({
    this.disableAnimations = false,
    this.textScale = 1,
    this.navigationHidden = false,
  });

  final bool disableAnimations;
  final double textScale;
  final bool navigationHidden;

  @override
  State<_ShellHarness> createState() => _ShellHarnessState();
}

class _ShellHarnessState extends State<_ShellHarness> {
  String selected = 'home';

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(
        disableAnimations: widget.disableAnimations,
        textScaler: TextScaler.linear(widget.textScale),
      ),
      child: RynAppShell(
        destinations: _destinations,
        selectedDestinationId: selected,
        onDestinationSelected: (value) => setState(() => selected = value),
        navigationHidden: widget.navigationHidden,
        utilityBar: const RynTopUtilityBar(
          title: '홈',
          themeControl: SizedBox(key: Key('theme-control')),
          ownerControl: SizedBox(key: Key('owner-control')),
        ),
        pageHost: const ColoredBox(
          color: Colors.transparent,
          child: SizedBox.expand(key: Key('workspace')),
        ),
      ),
    );
  }
}

class _LifecycleProbe extends StatefulWidget {
  const _LifecycleProbe({required this.id, required this.events});

  final String id;
  final List<String> events;

  @override
  State<_LifecycleProbe> createState() => _LifecycleProbeState();
}

class _LifecycleProbeState extends State<_LifecycleProbe> {
  int value = 0;

  @override
  void initState() {
    super.initState();
    widget.events.add('init:${widget.id}');
  }

  @override
  void dispose() {
    widget.events.add('dispose:${widget.id}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${widget.id}:$value', key: Key('value-${widget.id}')),
        Text(
          TickerMode.valuesOf(context).enabled
              ? 'ticker-on:${widget.id}'
              : 'ticker-off:${widget.id}',
          key: Key('ticker-${widget.id}'),
        ),
        TextButton(
          key: Key('increment-${widget.id}'),
          onPressed: () => setState(() => value++),
          child: const Text('증가'),
        ),
      ],
    );
  }
}

class _PageHostHarness extends StatefulWidget {
  const _PageHostHarness({super.key, required this.events});

  final List<String> events;

  @override
  State<_PageHostHarness> createState() => _PageHostHarnessState();
}

class _PageHostHarnessState extends State<_PageHostHarness> {
  String selected = 'home';

  void select(String value) => setState(() => selected = value);

  @override
  Widget build(BuildContext context) {
    return RynLazyPersistentPageHost(
      selectedPageId: selected,
      pageBuilders: {
        'home': (_) => _LifecycleProbe(id: 'home', events: widget.events),
        'people': (_) => _LifecycleProbe(id: 'people', events: widget.events),
      },
    );
  }
}

void main() {
  testWidgets(
    'Shell starts Compact and exposes icon tooltip and selected semantics',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_themed(const _ShellHarness()));
      await tester.pump();

      expect(find.byKey(const Key('ryn-rail-mode-compact')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('ryn-navigation-rail'))).width,
        72,
      );
      final rail = tester.widget<AnimatedContainer>(
        find.byKey(const Key('ryn-navigation-rail')),
      );
      expect(rail.duration, const Duration(milliseconds: 200));
      expect(rail.curve, Curves.easeOutCubic);
      expect(rail.clipBehavior, Clip.hardEdge);
      expect(find.byTooltip('홈'), findsOneWidget);
      expect(find.byTooltip('사람'), findsOneWidget);
      final homeTooltip = find.ancestor(
        of: find.byKey(const Key('ryn-nav-home')),
        matching: find.byType(Tooltip),
      );
      expect(homeTooltip, findsOneWidget);
      expect(
        tester.widget<Tooltip>(homeTooltip).waitDuration,
        const Duration(milliseconds: 500),
      );

      final homeSemantics = tester.widget<Semantics>(
        find.byKey(const Key('ryn-nav-home')),
      );
      expect(homeSemantics.properties.selected, isTrue);
      expect(homeSemantics.properties.button, isTrue);
    },
  );

  testWidgets(
    'Pointer hover Peeks without changing destination and exit returns Compact',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_themed(const _ShellHarness()));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: const Offset(1000, 800));
      await mouse.moveTo(
        tester.getCenter(find.byKey(const Key('ryn-navigation-rail'))),
      );
      await tester.pump();
      expect(
        tester
            .widget<AnimatedOpacity>(
              find.byKey(const Key('ryn-nav-home-label-opacity')),
            )
            .duration,
        const Duration(milliseconds: 140),
      );
      expect(
        tester
            .widget<Transform>(
              find.byKey(const Key('ryn-nav-home-label-slide')),
            )
            .transform
            .getTranslation()
            .x,
        6,
      );
      await tester.pump(const Duration(milliseconds: 220));

      expect(find.byKey(const Key('ryn-rail-mode-peek')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('ryn-navigation-rail'))).width,
        232,
      );
      expect(find.byKey(const Key('ryn-nav-home-selected')), findsOneWidget);
      expect(
        tester
            .widget<Transform>(
              find.byKey(const Key('ryn-nav-home-label-slide')),
            )
            .transform
            .getTranslation()
            .x,
        0,
      );

      await mouse.moveTo(const Offset(1000, 800));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 119));
      expect(find.byKey(const Key('ryn-rail-mode-peek')), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byKey(const Key('ryn-rail-mode-compact')), findsOneWidget);

      await mouse.moveTo(
        tester.getCenter(find.byKey(const Key('ryn-navigation-rail'))),
      );
      await tester.pump();
      await mouse.moveTo(const Offset(1000, 800));
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Pin survives destination changes and unpin returns Compact', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_themed(const _ShellHarness()));
    await tester.tap(find.byKey(const Key('ryn-rail-pin-toggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.byKey(const Key('ryn-rail-mode-pinned')), findsOneWidget);

    await tester.tap(find.byKey(const Key('ryn-nav-people')));
    await tester.pump();
    expect(find.byKey(const Key('ryn-rail-mode-pinned')), findsOneWidget);
    expect(find.byKey(const Key('ryn-nav-people-selected')), findsOneWidget);

    await tester.tap(find.byKey(const Key('ryn-rail-pin-toggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.byKey(const Key('ryn-rail-mode-compact')), findsOneWidget);
  });

  testWidgets(
    'Keyboard focus Peeks, arrows move focus, and Escape closes temporary Peek',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_themed(const _ShellHarness()));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));
      expect(find.byKey(const Key('ryn-rail-mode-peek')), findsOneWidget);
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'ryn-shell-destination-0',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(find.byKey(const Key('ryn-nav-home-selected')), findsOneWidget);
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'ryn-shell-destination-1',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(find.byKey(const Key('ryn-nav-people-selected')), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));
      expect(find.byKey(const Key('ryn-rail-mode-compact')), findsOneWidget);
    },
  );

  testWidgets(
    'Reduced motion changes rail state without waiting for width animation',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _themed(const _ShellHarness(disableAnimations: true)),
      );
      await tester.tap(find.byKey(const Key('ryn-rail-pin-toggle')));
      await tester.pump();
      expect(find.byKey(const Key('ryn-rail-mode-pinned')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('ryn-navigation-rail'))).width,
        232,
      );
      expect(
        tester
            .widget<AnimatedContainer>(
              find.byKey(const Key('ryn-navigation-rail')),
            )
            .duration,
        Duration.zero,
      );
      expect(
        tester
            .widget<AnimatedOpacity>(
              find.byKey(const Key('ryn-nav-home-label-opacity')),
            )
            .duration,
        Duration.zero,
      );
      expect(
        tester
            .widget<AnimatedContainer>(
              find.byKey(const Key('ryn-nav-home-selected')),
            )
            .duration,
        Duration.zero,
      );
    },
  );

  testWidgets(
    'Lazy host creates on first visit and preserves state without dispose',
    (tester) async {
      final events = <String>[];
      final key = GlobalKey<_PageHostHarnessState>();
      await tester.pumpWidget(
        _themed(_PageHostHarness(key: key, events: events)),
      );

      expect(events, ['init:home']);
      expect(
        find.byKey(const Key('value-people'), skipOffstage: false),
        findsNothing,
      );
      await tester.tap(find.byKey(const Key('increment-home')));
      await tester.pump();
      expect(find.text('home:1'), findsOneWidget);

      key.currentState!.select('people');
      await tester.pump();
      expect(events, ['init:home', 'init:people']);
      expect(find.text('ticker-off:home', skipOffstage: false), findsOneWidget);
      expect(find.text('ticker-on:people'), findsOneWidget);
      expect(
        tester
            .widget<TickerMode>(
              find.byKey(
                const ValueKey<String>('ryn-page-home-ticker'),
                skipOffstage: false,
              ),
            )
            .enabled,
        isFalse,
      );
      expect(
        tester
            .widget<ExcludeFocus>(
              find.byKey(
                const ValueKey<String>('ryn-page-home-focus'),
                skipOffstage: false,
              ),
            )
            .excluding,
        isTrue,
      );
      expect(
        tester
            .widget<ExcludeSemantics>(
              find.byKey(
                const ValueKey<String>('ryn-page-home-semantics'),
                skipOffstage: false,
              ),
            )
            .excluding,
        isTrue,
      );
      expect(
        tester
            .widget<IgnorePointer>(
              find.byKey(
                const ValueKey<String>('ryn-page-home-pointer'),
                skipOffstage: false,
              ),
            )
            .ignoring,
        isTrue,
      );
      expect(events.where((event) => event.startsWith('dispose:')), isEmpty);

      key.currentState!.select('home');
      await tester.pump();
      expect(find.text('home:1'), findsOneWidget);
      expect(events.where((event) => event == 'init:home'), hasLength(1));
    },
  );

  testWidgets(
    'Global utility appears once and search affordance is disabled honestly',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_themed(const _ShellHarness()));

      expect(find.byKey(const Key('ryn-top-utility-bar')), findsOneWidget);
      expect(
        find.byKey(const Key('ryn-global-search-coming-soon')),
        findsOneWidget,
      );
      final search = tester.widget<OutlinedButton>(
        find.byKey(const Key('ryn-global-search-coming-soon')),
      );
      expect(search.onPressed, isNull);
      expect(find.text('통합 검색 · 준비 중'), findsOneWidget);
    },
  );

  testWidgets('Immersive shell removes hidden global chrome from focus', (
    tester,
  ) async {
    await tester.pumpWidget(
      _themed(const _ShellHarness(navigationHidden: true)),
    );

    expect(find.byKey(const Key('ryn-navigation-hidden')), findsOneWidget);
    final utilityFocusGuard = find.byKey(
      const Key('ryn-global-chrome-focus-guard'),
      skipOffstage: false,
    );
    expect(utilityFocusGuard, findsOneWidget);
    expect(tester.widget<ExcludeFocus>(utilityFocusGuard).excluding, isTrue);
    expect(
      tester
          .widget<ExcludeSemantics>(
            find.byKey(
              const Key('ryn-global-chrome-semantics-guard'),
              skipOffstage: false,
            ),
          )
          .excluding,
      isTrue,
    );
    expect(
      tester
          .widget<IgnorePointer>(
            find.byKey(
              const Key('ryn-global-chrome-pointer-guard'),
              skipOffstage: false,
            ),
          )
          .ignoring,
      isTrue,
    );
  });

  test('Dark button themes use the semantic primary foreground', () {
    final theme = RynTheme.dark(
      fontFamily: 'Arial',
      fontFamilyFallback: const [],
    );
    final colors = theme.extension<RynSemanticColors>()!;

    expect(
      theme.filledButtonTheme.style?.foregroundColor?.resolve({}),
      colors.onPrimaryInteractive,
    );
    expect(
      theme.elevatedButtonTheme.style?.foregroundColor?.resolve({}),
      colors.onPrimaryInteractive,
    );
  });

  for (final scale in <double>[1.25, 1.5]) {
    testWidgets(
      'Shell remains usable at ${(scale * 100).round()}% text scale',
      (tester) async {
        tester.view.physicalSize = const Size(1400, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_themed(_ShellHarness(textScale: scale)));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('ryn-rail-pin-toggle')), findsOneWidget);
        expect(find.byKey(const Key('ryn-top-utility-bar')), findsOneWidget);
        expect(find.byKey(const Key('ryn-rail-mode-compact')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
