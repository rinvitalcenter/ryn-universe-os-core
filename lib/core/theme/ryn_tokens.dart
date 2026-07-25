import 'package:flutter/material.dart';

/// Canonical Apple-neutral semantic colors for Ryn Universe OS.
///
/// Feature widgets consume roles from this extension instead of embedding
/// palette values. Legacy constants below remain available as compatibility
/// aliases while modules migrate in separately approved work.
@immutable
final class RynSemanticColors extends ThemeExtension<RynSemanticColors> {
  const RynSemanticColors({
    required this.appCanvas,
    required this.primarySurface,
    required this.secondarySurface,
    required this.tertiarySurface,
    required this.raisedUtilityMaterial,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.hairline,
    required this.divider,
    required this.primaryAction,
    required this.primaryActionOnDark,
    required this.selectedState,
    required this.focusRing,
    required this.success,
    required this.warning,
    required this.destructive,
    required this.onPrimaryInteractive,
    required this.onSuccess,
    required this.onWarning,
    required this.onDestructive,
    required this.scrim,
    required this.hoverOverlay,
    required this.pressedOverlay,
    required this.disabledContent,
    required this.peopleIdentity,
  });

  static const light = RynSemanticColors(
    appCanvas: Color(0xFFF5F6F8),
    primarySurface: Color(0xFFFFFFFF),
    secondarySurface: Color(0xFFF8F9FB),
    tertiarySurface: Color(0xFFECEFF3),
    raisedUtilityMaterial: Color(0xFFF2F5F9),
    primaryText: Color(0xFF1B1D21),
    secondaryText: Color(0xFF4E545F),
    mutedText: Color(0xFF6D7582),
    hairline: Color(0xFFD8DDE5),
    divider: Color(0xFFC9D0DA),
    primaryAction: Color(0xFF0A63D8),
    primaryActionOnDark: Color(0xFF63A8FF),
    selectedState: Color(0x1A0A63D8),
    focusRing: Color(0xFF0067E5),
    success: Color(0xFF147A39),
    warning: Color(0xFF9A5A00),
    destructive: Color(0xFFC81E2A),
    onPrimaryInteractive: Color(0xFFFFFFFF),
    onSuccess: Color(0xFFFFFFFF),
    onWarning: Color(0xFFFFFFFF),
    onDestructive: Color(0xFFFFFFFF),
    scrim: Color(0x52000000),
    hoverOverlay: Color(0x0D1B1D21),
    pressedOverlay: Color(0x171B1D21),
    disabledContent: Color(0x9E6D7582),
    peopleIdentity: Color(0xFF147A39),
  );

  static const dark = RynSemanticColors(
    appCanvas: Color(0xFF101216),
    primarySurface: Color(0xFF17191E),
    secondarySurface: Color(0xFF1E2127),
    tertiarySurface: Color(0xFF262A31),
    raisedUtilityMaterial: Color(0xFF2B3038),
    primaryText: Color(0xFFF5F7FA),
    secondaryText: Color(0xFFC0C6D0),
    mutedText: Color(0xFF929AA7),
    hairline: Color(0xFF343943),
    divider: Color(0xFF454B57),
    primaryAction: Color(0xFF63A8FF),
    primaryActionOnDark: Color(0xFF63A8FF),
    selectedState: Color(0x1F63A8FF),
    focusRing: Color(0xFF7CB7FF),
    success: Color(0xFF45C56A),
    warning: Color(0xFFF2B84B),
    destructive: Color(0xFFFF6B73),
    onPrimaryInteractive: Color(0xFF0B1524),
    onSuccess: Color(0xFF17191E),
    onWarning: Color(0xFF17191E),
    onDestructive: Color(0xFF17191E),
    scrim: Color(0x7A000000),
    hoverOverlay: Color(0x12F5F7FA),
    pressedOverlay: Color(0x1CF5F7FA),
    disabledContent: Color(0x9E929AA7),
    peopleIdentity: Color(0xFF45C56A),
  );

  final Color appCanvas;
  final Color primarySurface;
  final Color secondarySurface;
  final Color tertiarySurface;
  final Color raisedUtilityMaterial;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final Color hairline;
  final Color divider;
  final Color primaryAction;
  final Color primaryActionOnDark;
  final Color selectedState;
  final Color focusRing;
  final Color success;
  final Color warning;
  final Color destructive;
  final Color onPrimaryInteractive;
  final Color onSuccess;
  final Color onWarning;
  final Color onDestructive;
  final Color scrim;
  final Color hoverOverlay;
  final Color pressedOverlay;
  final Color disabledContent;
  final Color peopleIdentity;

  @override
  RynSemanticColors copyWith({
    Color? appCanvas,
    Color? primarySurface,
    Color? secondarySurface,
    Color? tertiarySurface,
    Color? raisedUtilityMaterial,
    Color? primaryText,
    Color? secondaryText,
    Color? mutedText,
    Color? hairline,
    Color? divider,
    Color? primaryAction,
    Color? primaryActionOnDark,
    Color? selectedState,
    Color? focusRing,
    Color? success,
    Color? warning,
    Color? destructive,
    Color? onPrimaryInteractive,
    Color? onSuccess,
    Color? onWarning,
    Color? onDestructive,
    Color? scrim,
    Color? hoverOverlay,
    Color? pressedOverlay,
    Color? disabledContent,
    Color? peopleIdentity,
  }) => RynSemanticColors(
    appCanvas: appCanvas ?? this.appCanvas,
    primarySurface: primarySurface ?? this.primarySurface,
    secondarySurface: secondarySurface ?? this.secondarySurface,
    tertiarySurface: tertiarySurface ?? this.tertiarySurface,
    raisedUtilityMaterial: raisedUtilityMaterial ?? this.raisedUtilityMaterial,
    primaryText: primaryText ?? this.primaryText,
    secondaryText: secondaryText ?? this.secondaryText,
    mutedText: mutedText ?? this.mutedText,
    hairline: hairline ?? this.hairline,
    divider: divider ?? this.divider,
    primaryAction: primaryAction ?? this.primaryAction,
    primaryActionOnDark: primaryActionOnDark ?? this.primaryActionOnDark,
    selectedState: selectedState ?? this.selectedState,
    focusRing: focusRing ?? this.focusRing,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    destructive: destructive ?? this.destructive,
    onPrimaryInteractive: onPrimaryInteractive ?? this.onPrimaryInteractive,
    onSuccess: onSuccess ?? this.onSuccess,
    onWarning: onWarning ?? this.onWarning,
    onDestructive: onDestructive ?? this.onDestructive,
    scrim: scrim ?? this.scrim,
    hoverOverlay: hoverOverlay ?? this.hoverOverlay,
    pressedOverlay: pressedOverlay ?? this.pressedOverlay,
    disabledContent: disabledContent ?? this.disabledContent,
    peopleIdentity: peopleIdentity ?? this.peopleIdentity,
  );

  @override
  RynSemanticColors lerp(
    covariant ThemeExtension<RynSemanticColors>? other,
    double t,
  ) {
    if (other is! RynSemanticColors) return this;
    return RynSemanticColors(
      appCanvas: Color.lerp(appCanvas, other.appCanvas, t)!,
      primarySurface: Color.lerp(primarySurface, other.primarySurface, t)!,
      secondarySurface: Color.lerp(
        secondarySurface,
        other.secondarySurface,
        t,
      )!,
      tertiarySurface: Color.lerp(tertiarySurface, other.tertiarySurface, t)!,
      raisedUtilityMaterial: Color.lerp(
        raisedUtilityMaterial,
        other.raisedUtilityMaterial,
        t,
      )!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      primaryAction: Color.lerp(primaryAction, other.primaryAction, t)!,
      primaryActionOnDark: Color.lerp(
        primaryActionOnDark,
        other.primaryActionOnDark,
        t,
      )!,
      selectedState: Color.lerp(selectedState, other.selectedState, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      onPrimaryInteractive: Color.lerp(
        onPrimaryInteractive,
        other.onPrimaryInteractive,
        t,
      )!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      onDestructive: Color.lerp(onDestructive, other.onDestructive, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      hoverOverlay: Color.lerp(hoverOverlay, other.hoverOverlay, t)!,
      pressedOverlay: Color.lerp(pressedOverlay, other.pressedOverlay, t)!,
      disabledContent: Color.lerp(disabledContent, other.disabledContent, t)!,
      peopleIdentity: Color.lerp(peopleIdentity, other.peopleIdentity, t)!,
    );
  }
}

extension RynSemanticTheme on BuildContext {
  RynSemanticColors get rynColors =>
      Theme.of(this).extension<RynSemanticColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? RynSemanticColors.dark
          : RynSemanticColors.light);
}

/// Shared ThemeData factory for the Apple-neutral foundation.
final class RynTheme {
  const RynTheme._();

  static ThemeData light({
    required String fontFamily,
    required List<String> fontFamilyFallback,
  }) => _build(
    colors: RynSemanticColors.light,
    brightness: Brightness.light,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
  );

  static ThemeData dark({
    required String fontFamily,
    required List<String> fontFamilyFallback,
  }) => _build(
    colors: RynSemanticColors.dark,
    brightness: Brightness.dark,
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
  );

  static ThemeData _build({
    required RynSemanticColors colors,
    required Brightness brightness,
    required String fontFamily,
    required List<String> fontFamilyFallback,
  }) {
    final dark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: colors.primaryAction,
          brightness: brightness,
        ).copyWith(
          primary: colors.primaryAction,
          onPrimary: colors.onPrimaryInteractive,
          secondary: colors.primaryAction,
          onSecondary: colors.onPrimaryInteractive,
          error: colors.destructive,
          surface: colors.primarySurface,
          onSurface: colors.primaryText,
          onSurfaceVariant: colors.secondaryText,
          outline: colors.hairline,
          outlineVariant: colors.hairline,
          surfaceContainerLowest: colors.appCanvas,
          surfaceContainerLow: colors.secondarySurface,
          surfaceContainer: colors.tertiarySurface,
          surfaceContainerHigh: colors.tertiarySurface,
          surfaceContainerHighest: colors.tertiarySurface,
        );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(RynTokens.radiusMd),
      borderSide: BorderSide(color: colors.hairline),
    );
    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.appCanvas,
      canvasColor: colors.appCanvas,
      dividerColor: colors.hairline,
      shadowColor: Colors.transparent,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      useMaterial3: true,
      extensions: [colors],
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primaryAction,
          foregroundColor: colors.onPrimaryInteractive,
          disabledBackgroundColor: colors.tertiarySurface,
          disabledForegroundColor: colors.mutedText,
          elevation: RynTokens.elevationNone,
          shadowColor: Colors.transparent,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryAction,
          foregroundColor: colors.onPrimaryInteractive,
          elevation: RynTokens.elevationNone,
          shadowColor: Colors.transparent,
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primaryAction,
          side: BorderSide(color: colors.hairline),
          elevation: RynTokens.elevationNone,
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.primaryAction),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.primarySurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.focusRing, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.destructive),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.destructive, width: 2),
        ),
        labelStyle: TextStyle(color: colors.secondaryText),
        hintStyle: TextStyle(color: colors.mutedText),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: colors.primaryAction,
        labelColor: colors.primaryAction,
        unselectedLabelColor: colors.secondaryText,
        dividerColor: colors.hairline,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(RynTokens.elevationNone),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? colors.primaryAction
                : colors.secondaryText,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? colors.selectedState
                : Colors.transparent,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: colors.hairline)),
        ),
      ),
      focusColor: colors.focusRing.withValues(alpha: dark ? 0.28 : 0.18),
      splashColor: colors.primaryAction.withValues(alpha: 0.08),
      highlightColor: colors.primaryAction.withValues(alpha: 0.05),
    );
  }
}

/// Semantic visual tokens for Ryn Universe OS Core.
///
/// This file is intentionally lightweight: it defines reusable constants only.
/// It does not wire ThemeData, change app behavior, introduce assets/fonts,
/// or imply live state, persistence, API, Telegram, or automation behavior.
final class RynTokens {
  const RynTokens._();

  // ---------------------------------------------------------------------------
  // Core color tokens
  // ---------------------------------------------------------------------------

  static const Color coreInk = Color(0xFF1D2433);
  static const Color coreNight = Color(0xFF111623);
  static const Color coreBlue = Color(0xFF2D3854);
  static const Color coreViolet = Color(0xFF9D7CFF);
  static const Color coreCyan = Color(0xFF5FE7F0);
  static const Color coreGold = Color(0xFFA99058);

  // User OS visual baseline: clean light mode + OLED-first dark mode.
  static const Color lightCanvas = Color(0xFFF7F7F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSoft = Color(0xFFEFEFEC);
  static const Color lightBorder = Color(0xFFD8DADF);
  static const Color lightTextPrimary = Color(0xFF1D2433);
  static const Color lightTextSecondary = Color(0xFF687083);
  static const Color lightAccent = Color(0xFF2D3854);
  static const Color lightAccentSoft = Color(0x102D3854);

  static const Color oledCanvas = Color(0xFF111623);
  static const Color oledSurface = Color(0xFF181E2D);
  static const Color oledSurfaceSoft = Color(0xFF202737);
  static const Color oledCard = Color(0xFF252D3F);
  static const Color oledBorder = Color(0xFF323A4D);
  static const Color oledTextPrimary = Color(0xFFF1F3F7);
  static const Color oledTextSecondary = Color(0xFFA6ADBB);
  static const Color oledAccent = Color(0xFF8EA0C8);
  static const Color oledAccentSoft = Color(0x1A8EA0C8);

  // Neutral scale: dark-mode first, light-mode ready.
  static const Color neutral0 = Color(0xFF03050A);
  static const Color neutral50 = Color(0xFF0B1020);
  static const Color neutral100 = Color(0xFF121A2F);
  static const Color neutral150 = Color(0xFF172139);
  static const Color neutral200 = Color(0xFF22304A);
  static const Color neutral300 = Color(0xFF35435F);
  static const Color neutral500 = Color(0xFF758098);
  static const Color neutral700 = Color(0xFFB5BED1);
  static const Color neutral900 = Color(0xFFF3F6FC);

  // ---------------------------------------------------------------------------
  // Surface / background tokens
  // ---------------------------------------------------------------------------

  static const Color surfaceAppBase = coreInk;
  static const Color surfaceShell = Color(0xFF0A0F1D);
  static const Color surfaceNavigation = Color(0xFF0D1424);
  static const Color surfaceCommand = Color(0xFF111B31);
  static const Color surfaceCommandElevated = Color(0xFF17243D);
  static const Color surfaceCard = Color(0xFF141E33);
  static const Color surfaceCardSelected = Color(0xFF1C2D4D);
  static const Color surfaceDetail = Color(0xFF10192C);
  static const Color surfaceKanbanLane = Color(0xFF0F1728);
  static const Color surfaceKanbanColumn = Color(0xFF141D31);
  static const Color surfaceMarker = Color(0x1A5FE7F0);
  static const Color surfaceApprovalSoft = Color(0x26FFD27A);
  static const Color surfaceRiskSoft = Color(0x26FF7B7B);

  // ---------------------------------------------------------------------------
  // Text color tokens
  // ---------------------------------------------------------------------------

  static const Color textPrimary = neutral900;
  static const Color textSecondary = neutral700;
  static const Color textMuted = Color(0xFF8D98AE);
  static const Color textDisabled = Color(0xFF596275);
  static const Color textOnAccent = Color(0xFF06101E);
  static const Color textLink = coreCyan;
  static const Color textStatic = Color(0xFF9BEAF0);
  static const Color textApproval = coreGold;
  static const Color textRisk = Color(0xFFFFA1A1);
  static const Color textSuccess = Color(0xFF9EE6B1);

  // ---------------------------------------------------------------------------
  // Spacing tokens
  // ---------------------------------------------------------------------------

  static const double space0 = 0;
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space7 = 32;
  static const double space8 = 40;
  static const double space9 = 48;

  // ---------------------------------------------------------------------------
  // Radius tokens
  // ---------------------------------------------------------------------------

  static const double radiusNone = 0;
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 10;
  static const double radiusLg = 12;
  static const double radiusXl = 12;
  static const double radiusPill = 999;

  static const BorderRadius radiusCard = BorderRadius.all(
    Radius.circular(radiusMd),
  );
  static const BorderRadius radiusPanel = BorderRadius.all(
    Radius.circular(radiusLg),
  );
  static const BorderRadius radiusShell = BorderRadius.all(
    Radius.circular(radiusXl),
  );
  static const BorderRadius radiusChip = BorderRadius.all(
    Radius.circular(radiusSm),
  );

  // ---------------------------------------------------------------------------
  // Border tokens
  // ---------------------------------------------------------------------------

  static const Color borderSubtle = Color(0x1FFFFFFF);
  static const Color borderFocused = coreCyan;
  static const Color borderApproval = Color(0x40A99058);
  static const Color borderRisk = Color(0x80FF7B7B);
  static const Color borderStatic = Color(0x665FE7F0);

  static const double borderWidthHairline = 0.75;
  static const double borderWidthRegular = 1;
  static const double borderWidthFocus = 1.5;

  // ---------------------------------------------------------------------------
  // Elevation / shadow tokens
  // ---------------------------------------------------------------------------

  static const double elevationNone = 0;
  static const double elevationCard = 2;
  static const double elevationCommand = 8;

  static const List<BoxShadow> shadowNone = <BoxShadow>[];
  static const List<BoxShadow> shadowCard = <BoxShadow>[
    BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 10)),
  ];
  static const List<BoxShadow> shadowCommand = <BoxShadow>[
    BoxShadow(color: Color(0x59000000), blurRadius: 32, offset: Offset(0, 18)),
  ];

  // ---------------------------------------------------------------------------
  // Status / risk tokens
  // ---------------------------------------------------------------------------

  static const Color statusReady = coreCyan;
  static const Color statusReview = coreViolet;
  static const Color statusApprovalWaiting = coreGold;
  static const Color statusDoneRecorded = Color(0xFF8EE6A2);
  static const Color statusBlocked = Color(0xFFFF7B7B);
  static const Color statusDeferred = Color(0xFF8B93A8);
  static const Color statusStatic = Color(0xFF9BEAF0);

  static const Color riskLow = Color(0xFF82DFA2);
  static const Color riskMedium = Color(0xFFFFC66D);
  static const Color riskHigh = Color(0xFFFF7B7B);
  static const Color approvalRequired = coreGold;
  static const Color approvalNotConnected = statusDeferred;

  // ---------------------------------------------------------------------------
  // Interaction tokens
  // ---------------------------------------------------------------------------

  static const Color interactionHoverOverlay = Color(0x0FFFFFFF);
  static const Color interactionPressedOverlay = Color(0x1AFFFFFF);
  static const Color interactionSelectedOverlay = Color(0x182D3854);
  static const Duration interactionFast = Duration(milliseconds: 120);
  static const Duration interactionRegular = Duration(milliseconds: 180);

  // R2 global shell geometry and motion.
  static const double shellRailCompactWidth = 72;
  static const double shellRailExpandedWidth = 232;
  static const double shellNavigationTarget = 44;
  static const double shellLabelSlide = 6;
  static const double shellFocusWidth = 2;
  static const Duration motionInstant = Duration.zero;
  static const Duration motionFast = Duration(milliseconds: 120);
  static const Duration motionShort = Duration(milliseconds: 150);
  static const Duration motionStandard = Duration(milliseconds: 200);
  static const Duration motionEmphasis = Duration(milliseconds: 260);
  static const Duration shellLabelDuration = Duration(milliseconds: 140);
  static const Duration shellTooltipDelay = Duration(milliseconds: 500);
  static const Duration shellPointerExitDelay = Duration(milliseconds: 120);

  // ---------------------------------------------------------------------------
  // Command surface / Kanban semantic aliases
  // ---------------------------------------------------------------------------

  static const Color commandSurfaceAccent = coreBlue;
  static const Color commandSurfaceQuietAccent = Color(0x802D3854);
  static const Color commandApprovalAccent = approvalRequired;
  static const Color commandRiskAccent = riskHigh;

  static const Color kanbanLaneAccent = coreViolet;
  static const Color kanbanMarkerStatic = statusStatic;
  static const Color kanbanCardSelectedAccent = coreCyan;
  static const Color kanbanBlockedAccent = statusBlocked;
}
