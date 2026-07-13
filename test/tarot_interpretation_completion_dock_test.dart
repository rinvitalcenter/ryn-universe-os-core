import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/text/user_text.dart';
import 'package:ryn_universe_os_core/features/tarot/tarot_spread_shell.dart';

bool focusIsInside(Key target) {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null) return false;
  var found = context.widget.key == target;
  context.visitAncestorElements((element) {
    found = found || element.widget.key == target;
    return !found;
  });
  return found;
}

void main() {
  Future<void> openInterpretation(
    WidgetTester tester, {
    required Size size,
    ThemeMode themeMode = ThemeMode.dark,
  }) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeMode,
        home: Scaffold(body: TarotSpreadShell(onBack: () {})),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, UserText.tarotSpreadOne));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('tarot-result-card-back-slot')).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tarot-open-interpretation-button')));
    await tester.pumpAndSettle();
    tester.view.physicalSize = size;
    await tester.pumpAndSettle();
  }

  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues();
  });

  testWidgets('wide interpretation keeps completion dock in initial viewport', (
    tester,
  ) async {
    await openInterpretation(tester, size: const Size(1280, 720));

    final dock = find.byKey(const Key('tarot-interpretation-completion-dock'));
    expect(dock, findsOneWidget);
    final rect = tester.getRect(dock);
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.bottom, lessThanOrEqualTo(720));
    expect(dock.hitTestable(), findsOneWidget);
    expect(
      find.byKey(const Key('tarot-finish-home-action')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'right fields scroll independently while completion dock stays fixed',
    (tester) async {
      await openInterpretation(tester, size: const Size(1280, 720));

      final fieldsScroll = find.byKey(
        const Key('tarot-interpretation-fields-scroll'),
      );
      final dock = find.byKey(
        const Key('tarot-interpretation-completion-dock'),
      );
      final lastField = find.byKey(
        const Key('tarot-interpretation-field-action'),
      );
      final dockBefore = tester.getRect(dock);
      final internalScrollable = find.descendant(
        of: fieldsScroll,
        matching: find.byType(Scrollable),
      );
      final position = tester
          .state<ScrollableState>(internalScrollable.first)
          .position;
      final pixelsBefore = position.pixels;

      await tester.ensureVisible(lastField);
      await tester.pumpAndSettle();

      expect(position.pixels, greaterThan(pixelsBefore));
      expect(tester.getRect(dock), dockBefore);
      final lastRect = tester.getRect(lastField);
      expect(lastRect.bottom, lessThanOrEqualTo(dockBefore.top));
      expect(lastField.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('completion actions remain keyboard reachable in logical order', (
    tester,
  ) async {
    await openInterpretation(tester, size: const Size(1280, 720));

    final lastField = find.byKey(
      const Key('tarot-interpretation-field-action'),
    );
    await tester.ensureVisible(lastField);
    await tester.pumpAndSettle();
    await tester.tap(lastField);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(focusIsInside(const Key('tarot-finish-home-action')), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(focusIsInside(const Key('tarot-open-records-action')), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(focusIsInside(const Key('tarot-start-new-reading-action')), isTrue);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('completion dock has no overflow in ${mode.name} mode', (
      tester,
    ) async {
      await openInterpretation(
        tester,
        size: const Size(1280, 720),
        themeMode: mode,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-completion-dock')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
