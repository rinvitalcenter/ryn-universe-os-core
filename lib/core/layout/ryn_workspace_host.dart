import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'desktop_viewport.dart';

/// Declares which widget owns vertical movement inside one workspace axis.
enum RynWorkspaceScrollMode {
  /// A normal document or list page owns its page-level vertical scroll.
  featurePage,

  /// The feature receives a finite viewport and must not document-scroll.
  viewportBounded,

  /// Intentional child panels may scroll independently inside a finite viewport.
  independentPanels,
}

@immutable
final class RynWorkspacePresentation {
  const RynWorkspacePresentation({
    required this.mode,
    this.bypassAppWorkspaceCap = false,
  });

  const RynWorkspacePresentation.featurePage({
    this.bypassAppWorkspaceCap = false,
  }) : mode = RynWorkspaceScrollMode.featurePage;

  const RynWorkspacePresentation.viewportBounded({
    this.bypassAppWorkspaceCap = false,
  }) : mode = RynWorkspaceScrollMode.viewportBounded;

  const RynWorkspacePresentation.independentPanels({
    this.bypassAppWorkspaceCap = false,
  }) : mode = RynWorkspaceScrollMode.independentPanels;

  final RynWorkspaceScrollMode mode;
  final bool bypassAppWorkspaceCap;
}

final class RynWorkspacePresentationScope extends InheritedWidget {
  const RynWorkspacePresentationScope({
    super.key,
    required this.presentation,
    required super.child,
  });

  final RynWorkspacePresentation presentation;

  RynWorkspaceScrollMode get mode => presentation.mode;

  static Key modeKey(RynWorkspaceScrollMode mode) =>
      ValueKey<String>('ryn-workspace-scroll-mode-${mode.name}');

  static RynWorkspacePresentationScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<RynWorkspacePresentationScope>();
    assert(scope != null, 'No RynWorkspacePresentationScope found in context.');
    return scope!;
  }

  static RynWorkspacePresentationScope? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<RynWorkspacePresentationScope>();

  @override
  bool updateShouldNotify(RynWorkspacePresentationScope oldWidget) =>
      presentation.mode != oldWidget.presentation.mode ||
      presentation.bypassAppWorkspaceCap !=
          oldWidget.presentation.bypassAppWorkspaceCap;
}

/// Aligns one route workspace without becoming its vertical scroll owner.
///
/// The host preserves the approved horizontal caps and margins, publishes
/// finite post-margin workspace metrics, and leaves all scrolling to the
/// declared feature page or intentional child panels.
final class RynWorkspaceHost extends StatelessWidget {
  const RynWorkspaceHost({
    super.key,
    required this.presentation,
    required this.child,
  });

  static const workspaceBoundsKey = Key('ryn-workspace-bounds');

  static const double _topPadding = 16;
  static const double _bottomPadding = 28;
  static const double _readingMinimumBroadWidth = 900;

  final RynWorkspacePresentation presentation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shellScope = DesktopViewportScope.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final tokens = DesktopWorkspaceTokens.resolve(shellScope.metrics);
        final horizontalPadding = tokens.shellHorizontalPadding;
        final availableWidth = math.max(
          0.0,
          constraints.maxWidth - horizontalPadding * 2,
        );
        final availableHeight = math.max(
          0.0,
          constraints.maxHeight - _topPadding - _bottomPadding,
        );
        final maxContentWidth = presentation.bypassAppWorkspaceCap
            ? math.max(_readingMinimumBroadWidth, availableWidth)
            : tokens.appWorkspaceMaxWidth;
        final contentWidth = math.min(availableWidth, maxContentWidth);
        final workspaceMetrics = shellScope.metrics.copyWithWorkspace(
          workspaceWidth: contentWidth,
          workspaceHeight: availableHeight,
          effectiveContentWidth: contentWidth,
        );
        final workspaceTokens = DesktopWorkspaceTokens.resolve(
          workspaceMetrics,
        );

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            _topPadding,
            horizontalPadding,
            _bottomPadding,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              key: workspaceBoundsKey,
              width: contentWidth,
              height: availableHeight,
              child: DesktopViewportScope(
                metrics: workspaceMetrics,
                tokens: workspaceTokens,
                child: RynWorkspacePresentationScope(
                  key: RynWorkspacePresentationScope.modeKey(presentation.mode),
                  presentation: presentation,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
