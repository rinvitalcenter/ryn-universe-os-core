import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/layout/desktop_viewport.dart';
import 'package:ryn_universe_os_core/core/shell/ryn_adaptive_navigation_rail.dart';
import 'package:ryn_universe_os_core/core/shell/ryn_app_shell.dart';
import 'package:ryn_universe_os_core/core/theme/ryn_tokens.dart';

DesktopViewportMetrics _metrics({
  Size windowLogicalSize = const Size(1440, 900),
  double devicePixelRatio = 2,
  Size fullWindowConstraintSize = const Size(1440, 900),
  Size shellUsableSize = const Size(1368, 836),
  DesktopViewportRailState railState = DesktopViewportRailState.compact,
  double? workspaceWidth,
  double? workspaceHeight,
  double? effectiveContentWidth,
}) {
  return DesktopViewportMetrics.calculate(
    windowLogicalSize: windowLogicalSize,
    devicePixelRatio: devicePixelRatio,
    fullWindowConstraintSize: fullWindowConstraintSize,
    shellUsableSize: shellUsableSize,
    railState: railState,
    workspaceWidth: workspaceWidth,
    workspaceHeight: workspaceHeight,
    effectiveContentWidth: effectiveContentWidth,
  );
}

void main() {
  group('DesktopViewportMetrics', () {
    test(
      'converts logical active-window size to a physical-pixel estimate',
      () {
        final metrics = _metrics(
          windowLogicalSize: const Size(1440, 900),
          devicePixelRatio: 2,
        );

        expect(metrics.estimatedWindowPhysicalWidth, 2880);
        expect(metrics.estimatedWindowPhysicalHeight, 1800);
        expect(metrics.estimatedWindowPhysicalSize, const Size(2880, 1800));
      },
    );

    test('determines width classes from shell usable logical width', () {
      expect(
        _metrics(shellUsableSize: const Size(719, 900)).widthClass,
        DesktopViewportWidthClass.compact,
      );
      expect(
        _metrics(shellUsableSize: const Size(720, 900)).widthClass,
        DesktopViewportWidthClass.baseline,
      );
      expect(
        _metrics(shellUsableSize: const Size(2200, 1200)).widthClass,
        DesktopViewportWidthClass.expanded,
      );
    });

    test('determines height classes without changing feature breakpoints', () {
      expect(
        _metrics(shellUsableSize: const Size(1400, 799)).heightClass,
        DesktopViewportHeightClass.compact,
      );
      expect(
        _metrics(shellUsableSize: const Size(1400, 800)).heightClass,
        DesktopViewportHeightClass.standard,
      );
      expect(
        _metrics(shellUsableSize: const Size(1800, 1200)).heightClass,
        DesktopViewportHeightClass.tall,
      );
    });

    test('determines aspect classes from usable workspace shape', () {
      expect(
        _metrics(shellUsableSize: const Size(700, 900)).aspectClass,
        DesktopViewportAspectClass.portrait,
      );
      expect(
        _metrics(shellUsableSize: const Size(1440, 900)).aspectClass,
        DesktopViewportAspectClass.standard,
      );
      expect(
        _metrics(shellUsableSize: const Size(1920, 1080)).aspectClass,
        DesktopViewportAspectClass.wide,
      );
      expect(
        _metrics(shellUsableSize: const Size(2560, 1080)).aspectClass,
        DesktopViewportAspectClass.ultrawide,
      );
    });

    test('derives rail-consumed width from actual layout constraints', () {
      final metrics = _metrics(
        fullWindowConstraintSize: const Size(1440, 900),
        shellUsableSize: const Size(1368, 836),
      );

      expect(metrics.railConsumedWidth, 72);
      expect(metrics.shellUsableWidth, 1368);
      expect(metrics.isCompactRail, isTrue);
      expect(metrics.isPeekRail, isFalse);
      expect(metrics.isPinnedRail, isFalse);
    });

    test('reports explicit rail states without inferring animation width', () {
      expect(
        _metrics(railState: DesktopViewportRailState.peek).isPeekRail,
        isTrue,
      );
      expect(
        _metrics(railState: DesktopViewportRailState.pinned).isPinnedRail,
        isTrue,
      );
      expect(
        _metrics(railState: DesktopViewportRailState.hidden).isCompactRail,
        isFalse,
      );
    });

    test('clamps narrow workspace dimensions and content width to zero', () {
      final metrics = _metrics(
        fullWindowConstraintSize: const Size(40, 30),
        shellUsableSize: const Size(0, 0),
        workspaceWidth: -120,
        workspaceHeight: -80,
        effectiveContentWidth: -24,
      );

      expect(metrics.workspaceWidth, 0);
      expect(metrics.workspaceHeight, 0);
      expect(metrics.effectiveContentWidth, 0);
      expect(metrics.aspectRatio, 0);
    });

    test('copyWithWorkspace preserves window and shell facts', () {
      final original = _metrics();
      final updated = original.copyWithWorkspace(
        workspaceWidth: 1200,
        workspaceHeight: 800,
        effectiveContentWidth: 1180,
      );

      expect(updated.windowLogicalSize, original.windowLogicalSize);
      expect(updated.shellUsableSize, original.shellUsableSize);
      expect(updated.railState, original.railState);
      expect(updated.workspaceSize, const Size(1200, 800));
      expect(updated.effectiveContentWidth, 1180);
    });

    test('provides callable debug output without automatic logging', () {
      final output = _metrics().formatDebugMetrics();

      expect(output, contains('windowLogical=1440.0x900.0'));
      expect(output, contains('dpr=2.00'));
      expect(output, contains('windowPhysicalEstimate=2880.0x1800.0'));
      expect(output, contains('shellUsable=1368.0x836.0'));
      expect(output, contains('rail=compact'));
      expect(output, contains('widthClass=baseline'));
      expect(output, contains('heightClass=standard'));
      expect(output, contains('aspectClass=standard'));
      expect(output, contains('appWorkspaceCap=1480.0'));
    });

    test('supports stable equality and hash behavior', () {
      final first = _metrics();
      final same = _metrics();
      final changed = _metrics(shellUsableSize: const Size(1367, 836));

      expect(first, same);
      expect(first.hashCode, same.hashCode);
      expect(first, isNot(changed));
    });
  });

  group('DesktopWorkspaceTokens', () {
    test('preserves current app workspace cap around 2200', () {
      expect(
        DesktopWorkspaceTokens.resolve(
          _metrics(shellUsableSize: const Size(2199, 1000)),
        ).appWorkspaceMaxWidth,
        1480,
      );
      expect(
        DesktopWorkspaceTokens.resolve(
          _metrics(shellUsableSize: const Size(2200, 1000)),
        ).appWorkspaceMaxWidth,
        1680,
      );
      expect(
        DesktopWorkspaceTokens.resolve(
          _metrics(shellUsableSize: const Size(2201, 1000)),
        ).appWorkspaceMaxWidth,
        1680,
      );
    });

    test('preserves current shell padding coordinates', () {
      expect(
        DesktopWorkspaceTokens.resolve(
          _metrics(shellUsableSize: const Size(419, 800)),
        ).shellHorizontalPadding,
        6,
      );
      expect(
        DesktopWorkspaceTokens.resolve(
          _metrics(shellUsableSize: const Size(420, 800)),
        ).shellHorizontalPadding,
        12,
      );
      expect(
        DesktopWorkspaceTokens.resolve(
          _metrics(shellUsableSize: const Size(720, 800)),
        ).shellHorizontalPadding,
        20,
      );
    });

    test('keeps feature-specific caps as unwired extension points', () {
      final tokens = DesktopWorkspaceTokens.resolve(_metrics());

      expect(tokens.readingFieldMaxWidth, isNull);
      expect(tokens.immersiveTarotStageMaxWidth, isNull);
      expect(tokens.readableTextMaxWidth, isNull);
      expect(tokens.sidePanelMaxWidth, isNull);
      expect(tokens.elasticWorkspaceGutter, tokens.shellHorizontalPadding);
    });
  });

  test('DesktopViewportScope notifies only for meaningful changes', () {
    final firstMetrics = _metrics();
    final sameMetrics = _metrics();
    final changedMetrics = _metrics(shellUsableSize: const Size(1400, 836));
    final first = DesktopViewportScope(
      metrics: firstMetrics,
      tokens: DesktopWorkspaceTokens.resolve(firstMetrics),
      child: const SizedBox(),
    );
    final same = DesktopViewportScope(
      metrics: sameMetrics,
      tokens: DesktopWorkspaceTokens.resolve(sameMetrics),
      child: const SizedBox(),
    );
    final changed = DesktopViewportScope(
      metrics: changedMetrics,
      tokens: DesktopWorkspaceTokens.resolve(changedMetrics),
      child: const SizedBox(),
    );

    expect(same.updateShouldNotify(first), isFalse);
    expect(changed.updateShouldNotify(first), isTrue);
  });

  testWidgets(
    'RynAppShell provides post-rail and post-utility metrics to pages',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      DesktopViewportMetrics? captured;

      await tester.pumpWidget(
        MaterialApp(
          theme: RynTheme.light(
            fontFamily: 'Arial',
            fontFamilyFallback: const [],
          ),
          home: RynAppShell(
            destinations: const [
              RynShellDestination(
                id: 'home',
                label: '홈',
                icon: Icons.home_rounded,
              ),
            ],
            selectedDestinationId: 'home',
            onDestinationSelected: (_) {},
            utilityBar: const SizedBox(height: 64),
            pageHost: Builder(
              builder: (context) {
                captured = DesktopViewportScope.of(context).metrics;
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.windowLogicalSize, const Size(1440, 900));
      expect(captured!.fullWindowConstraintSize, const Size(1440, 900));
      expect(captured!.shellUsableSize, const Size(1368, 836));
      expect(captured!.railConsumedWidth, 72);
      expect(captured!.railState, DesktopViewportRailState.compact);

      await tester.tap(find.byKey(const Key('ryn-rail-pin-toggle')));
      await tester.pumpAndSettle();

      expect(captured!.shellUsableSize, const Size(1208, 836));
      expect(captured!.railConsumedWidth, 232);
      expect(captured!.railState, DesktopViewportRailState.pinned);
    },
  );
}
