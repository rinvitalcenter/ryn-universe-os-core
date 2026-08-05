import 'package:flutter/widgets.dart';

enum DesktopViewportWidthClass { compact, baseline, expanded }

enum DesktopViewportHeightClass { compact, standard, tall }

enum DesktopViewportAspectClass { portrait, standard, wide, ultrawide }

enum DesktopViewportRailState { hidden, compact, peek, pinned }

/// Feature-agnostic facts about the active Flutter window and the usable area
/// left after shell chrome has consumed its layout space.
///
/// Physical values are estimates for the active window only. Flutter does not
/// expose the physical dimensions of the monitor through this model.
@immutable
final class DesktopViewportMetrics {
  const DesktopViewportMetrics._({
    required this.windowLogicalSize,
    required this.devicePixelRatio,
    required this.fullWindowConstraintSize,
    required this.shellUsableSize,
    required this.railConsumedWidth,
    required this.workspaceSize,
    required this.effectiveContentWidth,
    required this.widthClass,
    required this.heightClass,
    required this.aspectClass,
    required this.railState,
  });

  factory DesktopViewportMetrics.calculate({
    required Size windowLogicalSize,
    required double devicePixelRatio,
    required Size fullWindowConstraintSize,
    required Size shellUsableSize,
    required DesktopViewportRailState railState,
    double? workspaceWidth,
    double? workspaceHeight,
    double? effectiveContentWidth,
  }) {
    final safeWindowSize = _safeSize(windowLogicalSize);
    final safeFullWindowConstraints = _safeSize(fullWindowConstraintSize);
    final safeShellUsableSize = _safeSize(shellUsableSize);
    final safeWorkspaceWidth = _safeDimension(
      workspaceWidth ?? safeShellUsableSize.width,
    );
    final safeWorkspaceHeight = _safeDimension(
      workspaceHeight ?? safeShellUsableSize.height,
    );
    final safeContentWidth = _safeDimension(
      effectiveContentWidth ?? safeWorkspaceWidth,
    );
    final safeDpr = devicePixelRatio.isFinite && devicePixelRatio > 0
        ? devicePixelRatio
        : 1.0;
    final aspectRatio = safeShellUsableSize.height == 0
        ? 0.0
        : safeShellUsableSize.width / safeShellUsableSize.height;

    return DesktopViewportMetrics._(
      windowLogicalSize: safeWindowSize,
      devicePixelRatio: safeDpr,
      fullWindowConstraintSize: safeFullWindowConstraints,
      shellUsableSize: safeShellUsableSize,
      railConsumedWidth: _safeDimension(
        safeFullWindowConstraints.width - safeShellUsableSize.width,
      ),
      workspaceSize: Size(safeWorkspaceWidth, safeWorkspaceHeight),
      effectiveContentWidth: safeContentWidth,
      widthClass: _widthClassFor(safeShellUsableSize.width),
      heightClass: _heightClassFor(safeShellUsableSize.height),
      aspectClass: _aspectClassFor(aspectRatio),
      railState: railState,
    );
  }

  final Size windowLogicalSize;
  final double devicePixelRatio;
  final Size fullWindowConstraintSize;
  final Size shellUsableSize;
  final double railConsumedWidth;
  final Size workspaceSize;
  final double effectiveContentWidth;
  final DesktopViewportWidthClass widthClass;
  final DesktopViewportHeightClass heightClass;
  final DesktopViewportAspectClass aspectClass;
  final DesktopViewportRailState railState;

  double get windowLogicalWidth => windowLogicalSize.width;
  double get windowLogicalHeight => windowLogicalSize.height;
  double get fullWindowConstraintWidth => fullWindowConstraintSize.width;
  double get fullWindowConstraintHeight => fullWindowConstraintSize.height;
  double get shellUsableWidth => shellUsableSize.width;
  double get shellUsableHeight => shellUsableSize.height;
  double get workspaceWidth => workspaceSize.width;
  double get workspaceHeight => workspaceSize.height;

  Size get estimatedWindowPhysicalSize =>
      Size(estimatedWindowPhysicalWidth, estimatedWindowPhysicalHeight);
  double get estimatedWindowPhysicalWidth =>
      windowLogicalWidth * devicePixelRatio;
  double get estimatedWindowPhysicalHeight =>
      windowLogicalHeight * devicePixelRatio;

  double get aspectRatio =>
      shellUsableHeight == 0 ? 0 : shellUsableWidth / shellUsableHeight;

  bool get isCompactRail => railState == DesktopViewportRailState.compact;
  bool get isPeekRail => railState == DesktopViewportRailState.peek;
  bool get isPinnedRail => railState == DesktopViewportRailState.pinned;

  DesktopViewportMetrics copyWithWorkspace({
    required double workspaceWidth,
    required double workspaceHeight,
    required double effectiveContentWidth,
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

  /// Callable diagnostic text for tests and deliberate debug capture.
  /// It does not log, persist, or identify content or people.
  String formatDebugMetrics() {
    final tokens = DesktopWorkspaceTokens.resolve(this);
    return 'windowLogical=${_sizeText(windowLogicalSize)} '
        'dpr=${devicePixelRatio.toStringAsFixed(2)} '
        'windowPhysicalEstimate=${_sizeText(estimatedWindowPhysicalSize)} '
        'fullWindowConstraints=${_sizeText(fullWindowConstraintSize)} '
        'shellUsable=${_sizeText(shellUsableSize)} '
        'workspace=${_sizeText(workspaceSize)} '
        'rail=${railState.name} '
        'railConsumed=${railConsumedWidth.toStringAsFixed(1)} '
        'widthClass=${widthClass.name} '
        'heightClass=${heightClass.name} '
        'aspectClass=${aspectClass.name} '
        'appWorkspaceCap=${tokens.appWorkspaceMaxWidth.toStringAsFixed(1)}';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DesktopViewportMetrics &&
            other.windowLogicalSize == windowLogicalSize &&
            other.devicePixelRatio == devicePixelRatio &&
            other.fullWindowConstraintSize == fullWindowConstraintSize &&
            other.shellUsableSize == shellUsableSize &&
            other.railConsumedWidth == railConsumedWidth &&
            other.workspaceSize == workspaceSize &&
            other.effectiveContentWidth == effectiveContentWidth &&
            other.widthClass == widthClass &&
            other.heightClass == heightClass &&
            other.aspectClass == aspectClass &&
            other.railState == railState;
  }

  @override
  int get hashCode => Object.hash(
    windowLogicalSize,
    devicePixelRatio,
    fullWindowConstraintSize,
    shellUsableSize,
    railConsumedWidth,
    workspaceSize,
    effectiveContentWidth,
    widthClass,
    heightClass,
    aspectClass,
    railState,
  );

  static DesktopViewportWidthClass _widthClassFor(double width) {
    if (width < DesktopWorkspaceTokens.reducedPaddingThreshold) {
      return DesktopViewportWidthClass.compact;
    }
    if (width < DesktopWorkspaceTokens.expandedWorkspaceThreshold) {
      return DesktopViewportWidthClass.baseline;
    }
    return DesktopViewportWidthClass.expanded;
  }

  static DesktopViewportHeightClass _heightClassFor(double height) {
    if (height < 800) return DesktopViewportHeightClass.compact;
    if (height < 1200) return DesktopViewportHeightClass.standard;
    return DesktopViewportHeightClass.tall;
  }

  static DesktopViewportAspectClass _aspectClassFor(double aspectRatio) {
    if (aspectRatio < 1) return DesktopViewportAspectClass.portrait;
    if (aspectRatio < 1.7) return DesktopViewportAspectClass.standard;
    if (aspectRatio < 2.1) return DesktopViewportAspectClass.wide;
    return DesktopViewportAspectClass.ultrawide;
  }

  static double _safeDimension(double value) =>
      value.isFinite && value > 0 ? value : 0;

  static Size _safeSize(Size size) =>
      Size(_safeDimension(size.width), _safeDimension(size.height));

  static String _sizeText(Size size) =>
      '${size.width.toStringAsFixed(1)}x${size.height.toStringAsFixed(1)}';
}

/// Shared workspace sizing facts resolved from the active shell viewport.
@immutable
final class DesktopWorkspaceTokens {
  const DesktopWorkspaceTokens._({
    required this.appWorkspaceMaxWidth,
    required this.adaptiveWorkbenchMaxWidth,
    required this.focusedWorkspaceMaxWidth,
    required this.shellHorizontalPadding,
    required this.elasticWorkspaceGutter,
  });

  static const double ultraCompactThreshold = 420;
  static const double reducedPaddingThreshold = 720;
  static const double expandedWorkspaceThreshold = 2200;
  static const double appWorkspaceStandardMaxWidth = 1480;
  static const double appWorkspaceExpandedMaxWidth = 1680;
  static const double appWorkspaceUltraCompactMaxWidth = 260;
  static const double adaptiveWorkbenchMaximumWidth = 2240;
  static const double focusedWorkspaceMaximumWidth = 1120;
  static const double shellPaddingUltraCompact = 6;
  static const double shellPaddingReduced = 12;
  static const double shellPaddingStandard = 20;

  final double appWorkspaceMaxWidth;
  final double adaptiveWorkbenchMaxWidth;
  final double focusedWorkspaceMaxWidth;
  final double shellHorizontalPadding;
  final double elasticWorkspaceGutter;

  double? get readingFieldMaxWidth => null;
  double? get immersiveTarotStageMaxWidth => null;
  double? get readableTextMaxWidth => null;
  double? get sidePanelMaxWidth => null;

  factory DesktopWorkspaceTokens.resolve(DesktopViewportMetrics metrics) {
    final width = metrics.shellUsableWidth;
    final ultraCompact = width < ultraCompactThreshold;
    final padding = ultraCompact
        ? shellPaddingUltraCompact
        : width < reducedPaddingThreshold
        ? shellPaddingReduced
        : shellPaddingStandard;
    final appCap = ultraCompact
        ? appWorkspaceUltraCompactMaxWidth
        : width < expandedWorkspaceThreshold
        ? appWorkspaceStandardMaxWidth
        : appWorkspaceExpandedMaxWidth;

    return DesktopWorkspaceTokens._(
      appWorkspaceMaxWidth: appCap,
      adaptiveWorkbenchMaxWidth: adaptiveWorkbenchMaximumWidth,
      focusedWorkspaceMaxWidth: focusedWorkspaceMaximumWidth,
      shellHorizontalPadding: padding,
      elasticWorkspaceGutter: padding,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DesktopWorkspaceTokens &&
            other.appWorkspaceMaxWidth == appWorkspaceMaxWidth &&
            other.adaptiveWorkbenchMaxWidth == adaptiveWorkbenchMaxWidth &&
            other.focusedWorkspaceMaxWidth == focusedWorkspaceMaxWidth &&
            other.shellHorizontalPadding == shellHorizontalPadding &&
            other.elasticWorkspaceGutter == elasticWorkspaceGutter;
  }

  @override
  int get hashCode => Object.hash(
    appWorkspaceMaxWidth,
    adaptiveWorkbenchMaxWidth,
    focusedWorkspaceMaxWidth,
    shellHorizontalPadding,
    elasticWorkspaceGutter,
  );
}

final class DesktopViewportScope extends InheritedWidget {
  const DesktopViewportScope({
    super.key,
    required this.metrics,
    required this.tokens,
    required super.child,
  });

  final DesktopViewportMetrics metrics;
  final DesktopWorkspaceTokens tokens;

  static DesktopViewportScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<DesktopViewportScope>();
    assert(scope != null, 'No DesktopViewportScope found in context.');
    return scope!;
  }

  static DesktopViewportScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DesktopViewportScope>();

  @override
  bool updateShouldNotify(DesktopViewportScope oldWidget) =>
      metrics != oldWidget.metrics || tokens != oldWidget.tokens;
}
