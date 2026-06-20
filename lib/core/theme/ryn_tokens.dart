import 'package:flutter/material.dart';

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

  static const Color coreInk = Color(0xFF070A12);
  static const Color coreNight = Color(0xFF0C1120);
  static const Color coreBlue = Color(0xFF5EA8FF);
  static const Color coreViolet = Color(0xFF9D7CFF);
  static const Color coreCyan = Color(0xFF5FE7F0);
  static const Color coreGold = Color(0xFFFFD27A);

  // User OS visual baseline: clean light mode + OLED-first dark mode.
  static const Color lightCanvas = Color(0xFFF6F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSoft = Color(0xFFF2F4F8);
  static const Color lightBorder = Color(0xFFE2E6EE);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF667085);
  static const Color lightAccent = Color(0xFF2F6FED);
  static const Color lightAccentSoft = Color(0xFFEAF2FF);

  static const Color oledCanvas = Color(0xFF000000);
  static const Color oledSurface = Color(0xFF07090D);
  static const Color oledSurfaceSoft = Color(0xFF10141C);
  static const Color oledCard = Color(0xFF171C26);
  static const Color oledBorder = Color(0xFF2A3140);
  static const Color oledTextPrimary = Color(0xFFF6F7FB);
  static const Color oledTextSecondary = Color(0xFFA3AAB7);
  static const Color oledAccent = Color(0xFF64A8FF);
  static const Color oledAccentSoft = Color(0xFF102033);

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
  static const double radiusXs = 6;
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 28;
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
    Radius.circular(radiusPill),
  );

  // ---------------------------------------------------------------------------
  // Border tokens
  // ---------------------------------------------------------------------------

  static const Color borderSubtle = Color(0x1FFFFFFF);
  static const Color borderFocused = coreCyan;
  static const Color borderApproval = Color(0x80FFD27A);
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
  static const Color interactionSelectedOverlay = Color(0x245EA8FF);
  static const Duration interactionFast = Duration(milliseconds: 120);
  static const Duration interactionRegular = Duration(milliseconds: 180);

  // ---------------------------------------------------------------------------
  // Command surface / Kanban semantic aliases
  // ---------------------------------------------------------------------------

  static const Color commandSurfaceAccent = coreBlue;
  static const Color commandSurfaceQuietAccent = Color(0x995EA8FF);
  static const Color commandApprovalAccent = approvalRequired;
  static const Color commandRiskAccent = riskHigh;

  static const Color kanbanLaneAccent = coreViolet;
  static const Color kanbanMarkerStatic = statusStatic;
  static const Color kanbanCardSelectedAccent = coreCyan;
  static const Color kanbanBlockedAccent = statusBlocked;
}
