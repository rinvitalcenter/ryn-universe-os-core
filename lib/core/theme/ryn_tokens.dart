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
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.hairline,
    required this.primaryAction,
    required this.primaryActionOnDark,
    required this.selectedState,
    required this.focusRing,
    required this.success,
    required this.warning,
    required this.destructive,
    required this.peopleIdentity,
  });

  static const light = RynSemanticColors(
    appCanvas: Color(0xFFF5F5F7),
    primarySurface: Color(0xFFFFFFFF),
    secondarySurface: Color(0xFFFAFAFC),
    tertiarySurface: Color(0xFFF0F0F2),
    primaryText: Color(0xFF1D1D1F),
    secondaryText: Color(0xFF515154),
    mutedText: Color(0xFF7A7A7A),
    hairline: Color(0xFFE0E0E0),
    primaryAction: Color(0xFF0066CC),
    primaryActionOnDark: Color(0xFF2997FF),
    selectedState: Color(0x140066CC),
    focusRing: Color(0xFF0071E3),
    success: Color(0xFF248A3D),
    warning: Color(0xFFB25000),
    destructive: Color(0xFFD70015),
    peopleIdentity: Color(0xFF248A3D),
  );

  static const dark = RynSemanticColors(
    appCanvas: Color(0xFF000000),
    primarySurface: Color(0xFF1D1D1F),
    secondarySurface: Color(0xFF272729),
    tertiarySurface: Color(0xFF2A2A2C),
    primaryText: Color(0xFFFFFFFF),
    secondaryText: Color(0xFFCCCCCC),
    mutedText: Color(0xFF999999),
    hairline: Color(0x33FFFFFF),
    primaryAction: Color(0xFF2997FF),
    primaryActionOnDark: Color(0xFF2997FF),
    selectedState: Color(0x292997FF),
    focusRing: Color(0xFF2997FF),
    success: Color(0xFF32D74B),
    warning: Color(0xFFFFD60A),
    destructive: Color(0xFFFF453A),
    peopleIdentity: Color(0xFF32D74B),
  );

  final Color appCanvas;
  final Color primarySurface;
  final Color secondarySurface;
  final Color tertiarySurface;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final Color hairline;
  final Color primaryAction;
  final Color primaryActionOnDark;
  final Color selectedState;
  final Color focusRing;
  final Color success;
  final Color warning;
  final Color destructive;
  final Color peopleIdentity;

  @override
  RynSemanticColors copyWith({
    Color? appCanvas,
    Color? primarySurface,
    Color? secondarySurface,
    Color? tertiarySurface,
    Color? primaryText,
    Color? secondaryText,
    Color? mutedText,
    Color? hairline,
    Color? primaryAction,
    Color? primaryActionOnDark,
    Color? selectedState,
    Color? focusRing,
    Color? success,
    Color? warning,
    Color? destructive,
    Color? peopleIdentity,
  }) => RynSemanticColors(
    appCanvas: appCanvas ?? this.appCanvas,
    primarySurface: primarySurface ?? this.primarySurface,
    secondarySurface: secondarySurface ?? this.secondarySurface,
    tertiarySurface: tertiarySurface ?? this.tertiarySurface,
    primaryText: primaryText ?? this.primaryText,
    secondaryText: secondaryText ?? this.secondaryText,
    mutedText: mutedText ?? this.mutedText,
    hairline: hairline ?? this.hairline,
    primaryAction: primaryAction ?? this.primaryAction,
    primaryActionOnDark: primaryActionOnDark ?? this.primaryActionOnDark,
    selectedState: selectedState ?? this.selectedState,
    focusRing: focusRing ?? this.focusRing,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    destructive: destructive ?? this.destructive,
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
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
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
          onPrimary: Colors.white,
          secondary: colors.primaryAction,
          onSecondary: Colors.white,
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
          foregroundColor: Colors.white,
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
          foregroundColor: Colors.white,
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
