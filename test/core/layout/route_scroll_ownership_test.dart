import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/layout/ryn_workspace_host.dart';
import 'package:ryn_universe_os_core/main.dart';

Future<void> _pumpApp(WidgetTester tester, {double textScale = 1}) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  await tester.pumpWidget(const RynUniverseApp());
  await tester.pumpAndSettle();
}

Finder _ancestorDocumentScroll(Finder target) =>
    find.ancestor(of: target, matching: find.byType(SingleChildScrollView));

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues();
  });

  testWidgets(
    'Home owns its document scroll without a global scroll ancestor',
    (tester) async {
      await _pumpApp(tester);

      final page = find.byKey(const Key('home-cinematic-scene'));
      expect(page, findsOneWidget);
      expect(_ancestorDocumentScroll(page), findsNothing);
      expect(
        find.byKey(
          RynWorkspacePresentationScope.modeKey(
            RynWorkspaceScrollMode.featurePage,
          ),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Reading and Records own scrolling without host competition', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byKey(const Key('ryn-nav-reading')));
    await tester.pumpAndSettle();
    final reading = find.byKey(const Key('reading-atelier-page'));
    expect(reading, findsOneWidget);
    expect(_ancestorDocumentScroll(reading), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('ryn-nav-records')));
    await tester.pumpAndSettle();
    final records = find.byKey(const Key('records-session-page'));
    expect(records, findsOneWidget);
    expect(_ancestorDocumentScroll(records), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('People route declares intentional independent panels', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byKey(const Key('ryn-nav-people')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        RynWorkspacePresentationScope.modeKey(
          RynWorkspaceScrollMode.independentPanels,
        ),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('people-page')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reading route retains approved app-cap bypass', (tester) async {
    tester.view.physicalSize = const Size(2199, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ryn-nav-reading')));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(RynWorkspaceHost.workspaceBoundsKey)).width,
      greaterThan(1480),
    );
    expect(tester.takeException(), isNull);
  });

  for (final textScale in <double>[1, 1.25, 1.5]) {
    testWidgets('route ownership stays usable at text scale $textScale', (
      tester,
    ) async {
      await _pumpApp(tester, textScale: textScale);
      expect(find.byKey(const Key('home-cinematic-scene')), findsOneWidget);

      await tester.tap(find.byKey(const Key('ryn-nav-reading')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('reading-atelier-page')), findsOneWidget);
      await tester.tap(find.byKey(const Key('ryn-nav-records')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('records-session-page')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Records status and primary action remain usable at 2.0', (
    tester,
  ) async {
    await _pumpApp(tester, textScale: 2);
    await tester.tap(find.byKey(const Key('ryn-nav-records')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('records-session-status-row')).hitTestable(),
      findsOneWidget,
    );
    expect(find.text('새 셀프 타로 시작').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
