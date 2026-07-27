import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/layout/desktop_viewport.dart';
import 'package:ryn_universe_os_core/core/layout/ryn_workspace_host.dart';

DesktopViewportMetrics _metrics(Size size) {
  return DesktopViewportMetrics.calculate(
    windowLogicalSize: size,
    devicePixelRatio: 1,
    fullWindowConstraintSize: size,
    shellUsableSize: size,
    railState: DesktopViewportRailState.hidden,
  );
}

Future<void> _pumpHost(
  WidgetTester tester, {
  required Size size,
  RynWorkspacePresentation presentation =
      const RynWorkspacePresentation.featurePage(),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  final metrics = _metrics(size);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DesktopViewportScope(
          metrics: metrics,
          tokens: DesktopWorkspaceTokens.resolve(metrics),
          child: RynWorkspaceHost(
            presentation: presentation,
            child: Builder(
              builder: (context) {
                final metrics = DesktopViewportScope.of(context).metrics;
                final mode = RynWorkspacePresentationScope.of(context).mode;
                return SizedBox.expand(
                  key: const Key('test-feature-page'),
                  child: Text(
                    '${mode.name}:${metrics.workspaceWidth}x${metrics.workspaceHeight}',
                  ),
                );
              },
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
          find.textContaining('${mode.name}:1400.0x856.0'),
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
