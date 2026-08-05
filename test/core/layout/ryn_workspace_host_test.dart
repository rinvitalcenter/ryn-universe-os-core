import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/layout/desktop_viewport.dart';
import 'package:ryn_universe_os_core/core/layout/ryn_workspace_host.dart';

DesktopViewportMetrics _metrics(
  Size size, {
  Size? fullWindowSize,
  DesktopViewportRailState railState = DesktopViewportRailState.hidden,
}) {
  return DesktopViewportMetrics.calculate(
    windowLogicalSize: fullWindowSize ?? size,
    devicePixelRatio: 1,
    fullWindowConstraintSize: fullWindowSize ?? size,
    shellUsableSize: size,
    railState: railState,
  );
}

Future<void> _pumpHost(
  WidgetTester tester, {
  required Size size,
  Size? fullWindowSize,
  DesktopViewportRailState railState = DesktopViewportRailState.hidden,
  RynWorkspacePresentation presentation =
      const RynWorkspacePresentation.featurePage(),
}) async {
  tester.view.physicalSize = fullWindowSize ?? size;
  tester.view.devicePixelRatio = 1;
  final metrics = _metrics(
    size,
    fullWindowSize: fullWindowSize,
    railState: railState,
  );
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox.fromSize(
            size: size,
            child: DesktopViewportScope(
              metrics: metrics,
              tokens: DesktopWorkspaceTokens.resolve(metrics),
              child: RynWorkspaceHost(
                presentation: presentation,
                child: Builder(
                  builder: (context) {
                    final metrics = DesktopViewportScope.of(context).metrics;
                    final scope = RynWorkspacePresentationScope.of(context);
                    return SizedBox.expand(
                      key: const Key('test-feature-page'),
                      child: Text(
                        '${scope.mode.name}:${scope.presentation.widthPolicy.name}:'
                        '${metrics.workspaceWidth}x${metrics.workspaceHeight}',
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues();
  });

  group('RynWorkspaceHost audit coordinates', () {
    for (final coordinate in <(double, double)>[
      (419, 260),
      (420, 396),
      (719, 695),
      (720, 680),
      (2199, 1480),
      (2200, 1680),
      (2201, 1680),
    ]) {
      testWidgets('logical width ${coordinate.$1} yields ${coordinate.$2}', (
        tester,
      ) async {
        await _pumpHost(tester, size: Size(coordinate.$1, 900));

        expect(tester.getSize(find.byType(Scaffold)), Size(coordinate.$1, 900));
        expect(
          tester.getSize(find.byKey(RynWorkspaceHost.workspaceBoundsKey)),
          Size(coordinate.$2, 856),
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Reading bypass retains the approved broad workspace', (
      tester,
    ) async {
      await _pumpHost(
        tester,
        size: const Size(2199, 900),
        presentation: const RynWorkspacePresentation.featurePage(
          bypassAppWorkspaceCap: true,
        ),
      );

      expect(
        tester.getSize(find.byKey(RynWorkspaceHost.workspaceBoundsKey)),
        const Size(2159, 856),
      );
    });

    testWidgets('ordinary remains top-left below and above each cap', (
      tester,
    ) async {
      for (final coordinate in <(Size, Size)>[
        (const Size(1440, 900), const Size(1400, 856)),
        (const Size(2048, 900), const Size(1480, 856)),
        (const Size(2560, 900), const Size(1680, 856)),
      ]) {
        await _pumpHost(tester, size: coordinate.$1);
        final workspace = find.byKey(RynWorkspaceHost.workspaceBoundsKey);

        expect(tester.getSize(workspace), coordinate.$2);
        expect(tester.getTopLeft(workspace), const Offset(20, 16));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('immersive uses the full post-gutter width', (tester) async {
      await _pumpHost(
        tester,
        size: const Size(2560, 900),
        presentation: const RynWorkspacePresentation.featurePage(
          widthPolicy: RynWorkspaceWidthPolicy.immersive,
        ),
      );

      final workspace = find.byKey(RynWorkspaceHost.workspaceBoundsKey);
      expect(tester.getSize(workspace), const Size(2520, 856));
      expect(tester.getTopLeft(workspace), const Offset(20, 16));
      expect(tester.takeException(), isNull);
    });

    testWidgets('adaptive workbench uses available width below its cap', (
      tester,
    ) async {
      await _pumpHost(
        tester,
        size: const Size(2200, 900),
        presentation: const RynWorkspacePresentation.featurePage(
          widthPolicy: RynWorkspaceWidthPolicy.adaptiveWorkbench,
        ),
      );

      final workspace = find.byKey(RynWorkspaceHost.workspaceBoundsKey);
      expect(tester.getSize(workspace), const Size(2160, 856));
      expect(tester.getTopLeft(workspace), const Offset(20, 16));
      expect(tester.takeException(), isNull);
    });

    testWidgets('adaptive workbench caps at 2240 and centers', (tester) async {
      await _pumpHost(
        tester,
        size: const Size(2600, 900),
        presentation: const RynWorkspacePresentation.featurePage(
          widthPolicy: RynWorkspaceWidthPolicy.adaptiveWorkbench,
        ),
      );

      final workspace = find.byKey(RynWorkspaceHost.workspaceBoundsKey);
      expect(tester.getSize(workspace), const Size(2240, 856));
      expect(tester.getTopLeft(workspace), const Offset(180, 16));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'adaptive workbench follows compact and pinned rail constraints',
      (tester) async {
        for (final coordinate in <(Size, DesktopViewportRailState, Offset)>[
          (
            const Size(2528, 900),
            DesktopViewportRailState.compact,
            const Offset(144, 16),
          ),
          (
            const Size(2368, 900),
            DesktopViewportRailState.pinned,
            const Offset(64, 16),
          ),
        ]) {
          await _pumpHost(
            tester,
            size: coordinate.$1,
            fullWindowSize: const Size(2600, 900),
            railState: coordinate.$2,
            presentation: const RynWorkspacePresentation.featurePage(
              widthPolicy: RynWorkspaceWidthPolicy.adaptiveWorkbench,
            ),
          );

          final workspace = find.byKey(RynWorkspaceHost.workspaceBoundsKey);
          expect(tester.getSize(workspace), const Size(2240, 856));
          expect(tester.getTopLeft(workspace), coordinate.$3);
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets('focused uses available width below its cap', (tester) async {
      await _pumpHost(
        tester,
        size: const Size(1000, 900),
        presentation: const RynWorkspacePresentation.featurePage(
          widthPolicy: RynWorkspaceWidthPolicy.focused,
        ),
      );

      final workspace = find.byKey(RynWorkspaceHost.workspaceBoundsKey);
      expect(tester.getSize(workspace), const Size(960, 856));
      expect(tester.getTopLeft(workspace), const Offset(20, 16));
      expect(tester.takeException(), isNull);
    });

    testWidgets('focused caps at 1120 and centers', (tester) async {
      await _pumpHost(
        tester,
        size: const Size(1440, 900),
        presentation: const RynWorkspacePresentation.featurePage(
          widthPolicy: RynWorkspaceWidthPolicy.focused,
        ),
      );

      final workspace = find.byKey(RynWorkspaceHost.workspaceBoundsKey);
      expect(tester.getSize(workspace), const Size(1120, 856));
      expect(tester.getTopLeft(workspace), const Offset(160, 16));
      expect(tester.takeException(), isNull);
    });

    testWidgets('legacy bypass takes precedence over an ordinary policy', (
      tester,
    ) async {
      const presentation = RynWorkspacePresentation.featurePage(
        bypassAppWorkspaceCap: true,
        widthPolicy: RynWorkspaceWidthPolicy.ordinary,
      );
      await _pumpHost(
        tester,
        size: const Size(2560, 900),
        presentation: presentation,
      );

      expect(
        presentation.effectiveWidthPolicy,
        RynWorkspaceWidthPolicy.immersive,
      );
      expect(
        tester.getSize(find.byKey(RynWorkspaceHost.workspaceBoundsKey)),
        const Size(2520, 856),
      );
      expect(tester.takeException(), isNull);
    });

    test('presentation constructors default to ordinary width', () {
      const presentations = <RynWorkspacePresentation>[
        RynWorkspacePresentation.featurePage(),
        RynWorkspacePresentation.viewportBounded(),
        RynWorkspacePresentation.independentPanels(),
      ];

      for (final presentation in presentations) {
        expect(presentation.widthPolicy, RynWorkspaceWidthPolicy.ordinary);
        expect(
          presentation.effectiveWidthPolicy,
          RynWorkspaceWidthPolicy.ordinary,
        );
      }
    });

    test('presentation scope notices semantic width changes', () {
      const oldScope = RynWorkspacePresentationScope(
        presentation: RynWorkspacePresentation.featurePage(),
        child: SizedBox(),
      );
      const newScope = RynWorkspacePresentationScope(
        presentation: RynWorkspacePresentation.featurePage(
          widthPolicy: RynWorkspaceWidthPolicy.focused,
        ),
        child: SizedBox(),
      );

      expect(newScope.updateShouldNotify(oldScope), isTrue);
    });

    for (final mode in RynWorkspaceScrollMode.values) {
      testWidgets('${mode.name} is explicit and never adds global scroll', (
        tester,
      ) async {
        await _pumpHost(
          tester,
          size: const Size(1440, 900),
          presentation: RynWorkspacePresentation(mode: mode),
        );

        expect(
          find.byKey(RynWorkspacePresentationScope.modeKey(mode)),
          findsOneWidget,
        );
        expect(find.byType(SingleChildScrollView), findsNothing);
        expect(find.byType(Scrollable), findsNothing);
        expect(
          find.textContaining('${mode.name}:ordinary:1400.0x856.0'),
          findsOneWidget,
        );
      });
    }

    testWidgets('tiny workspace remains finite and non-negative', (
      tester,
    ) async {
      await _pumpHost(tester, size: const Size(10, 30));

      final size = tester.getSize(
        find.byKey(RynWorkspaceHost.workspaceBoundsKey),
      );
      expect(size.width, 0);
      expect(size.height, 0);
      expect(size.width.isFinite, isTrue);
      expect(size.height.isFinite, isTrue);
      expect(tester.takeException(), isNull);
    });

    for (final coordinate in <(Size, Size)>[
      (const Size(1440, 900), const Size(1400, 856)),
      (const Size(2048, 1152), const Size(1480, 1108)),
      (const Size(2560, 1440), const Size(1680, 1396)),
      (const Size(1366, 768), const Size(1326, 724)),
    ]) {
      testWidgets(
        '${coordinate.$1.width}x${coordinate.$1.height} keeps finite workspace',
        (tester) async {
          await _pumpHost(tester, size: coordinate.$1);

          expect(
            tester.getSize(find.byKey(RynWorkspaceHost.workspaceBoundsKey)),
            coordinate.$2,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
