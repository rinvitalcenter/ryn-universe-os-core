import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:newton_particles/newton_particles.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ryn_universe_os_core/core/text/user_text.dart';
import 'package:ryn_universe_os_core/core/theme/ryn_tokens.dart';

class RynPalette {
  const RynPalette._();

  // Light surfaces: clean near-white, low tint, thin borders.
  static const ivoryCanvas = RynTokens.lightCanvas;
  static const ivory = RynTokens.lightSurface;
  static const ivorySoft = RynTokens.lightSurfaceSoft;
  static const ivoryLine = RynTokens.lightBorder;
  static const ink = RynTokens.lightTextPrimary;
  static const muted = RynTokens.lightTextSecondary;
  static const warmMuted = RynTokens.lightTextSecondary;

  // OLED dark surfaces: near-black base, neutral panels, blue/violet accents.
  static const oledCanvas = RynTokens.oledCanvas;
  static const oledSurface = RynTokens.oledSurface;
  static const oledSurfaceSoft = RynTokens.oledSurfaceSoft;
  static const oledCard = RynTokens.oledCard;
  static const oledLine = RynTokens.oledBorder;
  static const oledInk = RynTokens.oledTextPrimary;
  static const oledMuted = RynTokens.oledTextSecondary;

  static const navy = Color(0xFF07101F);
  static const deepNavy = Color(0xFF101A2F);
  static const graphite = Color(0xFF1B2638);
  static const navyLine = Color(0xFF2D3B55);
  static const gold = Color(0xFFD4AF5F);
  static const goldSoft = RynTokens.lightAccentSoft;
  static const lavender = Color(0xFFE9E5FF);
  static const lavenderStrong = Color(0xFF8B7CF6);
  static const tarotMidnight = Color(0xFF060918);
  static const tarotNavy = Color(0xFF0B1028);
  static const tarotViolet = Color(0xFF211848);
  static const tarotLavender = Color(0xFFB3A8F0);
  static const tarotGold = Color(0xFFD9BC7A);
  static const accentBlue = RynTokens.lightAccent;
  static const accentBlueDark = RynTokens.oledAccent;
  static const accentSoftDark = RynTokens.oledAccentSoft;
  static const success = Color(0xFF4F8A6B);
  static const warning = Color(0xFFC08337);
  static const shadow = Color(0x1A0F172A);
  static const darkShadow = Color(0xA6000000);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
  static Color canvas(BuildContext context) =>
      isDark(context) ? oledCanvas : ivoryCanvas;
  static Color surface(BuildContext context) =>
      isDark(context) ? oledSurface : ivory;
  static Color surfaceSoft(BuildContext context) =>
      isDark(context) ? oledSurfaceSoft : ivorySoft;
  static Color surfaceElevated(BuildContext context) =>
      isDark(context) ? oledCard : ivory;
  static Color line(BuildContext context) =>
      isDark(context) ? oledLine : ivoryLine;
  static Color text(BuildContext context) => isDark(context) ? oledInk : ink;
  static Color subtext(BuildContext context) =>
      isDark(context) ? oledMuted : muted;
  static Color accent(BuildContext context) =>
      isDark(context) ? accentBlueDark : accentBlue;
  static Color accentSoft(BuildContext context) =>
      isDark(context) ? accentSoftDark : goldSoft;
  static Color navSelected(BuildContext context) =>
      isDark(context) ? const Color(0xFF18243A) : navy;
  static Color iconOnAccent(BuildContext context) =>
      isDark(context) ? accentBlueDark : deepNavy;
  static List<BoxShadow> panelShadow(BuildContext context) => isDark(context)
      ? const <BoxShadow>[
          BoxShadow(
            color: Color(0xB0000000),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ]
      : const <BoxShadow>[
          BoxShadow(color: shadow, blurRadius: 24, offset: Offset(0, 14)),
        ];
}

class RynMetrics {
  const RynMetrics._();

  static const maxWidth = 3200.0;
  static const radiusShell = 32.0;
  static const radiusCard = 24.0;
  static const radiusSoft = 18.0;
  static const radiusPill = 999.0;
}

class _TarotShellCard extends StatelessWidget {
  const _TarotShellCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: RynPalette.surface(context),
        borderRadius: BorderRadius.circular(RynMetrics.radiusShell),
        border: Border.all(color: RynPalette.line(context)),
        boxShadow: RynPalette.panelShadow(context),
      ),
      child: child,
    );
  }
}

enum _TarotDrawPhase { beforeShuffle, shuffling, ready, drawing, complete }

enum _TarotFlowStage { setup, draw, result, interpretation }

enum _TarotDirectionMode { uprightOnly, auto }

class _TarotUiText {
  const _TarotUiText._();

  static const shuffle = '셔플하기';
  static const shuffling = '카드를 섞고 있습니다';
  static const prepare = '준비하기';
  static const showResult = '결과 보기';
  static const directionMode = '방향 선택';
  static const uprightOnly = '정방향만';
  static const autoDirection = '정/역방향';
  static const changeDirection = '방향 바꾸기';
  static const revealPrompt = '카드를 펼쳐보세요';
  static const revealAll = '모두 펼치기';
}

// Future TAROT-SPREAD-LAYOUT2: revisit 5-card overlap/spacing after the FX
// foundation stabilizes; this task intentionally avoids layout micro-polish.
// Future TAROT-SPREAD-LAYOUT2: revisit Celtic Cross overlap/spacing after the
// FX foundation stabilizes; this task intentionally avoids layout micro-polish.

class TarotSpreadShell extends StatefulWidget {
  const TarotSpreadShell({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<TarotSpreadShell> createState() => _TarotSpreadShellState();
}

class _TarotSpreadShellState extends State<TarotSpreadShell> {
  static const _deckDefinitions = [
    _TarotDeckDefinition(
      id: 'rws_public_domain',
      label: UserText.tarotDeckUniversalWaite,
      cardCount: 78,
      assetBacked: true,
    ),
    _TarotDeckDefinition(id: 'thoth', label: UserText.tarotDeckThoth),
    _TarotDeckDefinition(id: 'marseille', label: UserText.tarotDeckMarseille),
    _TarotDeckDefinition(id: 'manshin_1', label: UserText.tarotDeckManshin1),
    _TarotDeckDefinition(id: 'manshin_2', label: UserText.tarotDeckManshin2),
    _TarotDeckDefinition(id: 'oracle', label: UserText.tarotDeckOracle),
    _TarotDeckDefinition(id: 'lenormand', label: UserText.tarotDeckLenormand),
    _TarotDeckDefinition(
      id: 'personal_scan',
      label: UserText.tarotDeckPersonalScan,
    ),
  ];

  static const _cardBackDefinitions = [
    _TarotCardBackDefinition(
      id: 'cosmic_gate',
      label: '코스믹 게이트',
      assetPath: 'assets/tarot/card_backs/ryn_cosmic_gate_back_v1.png',
    ),
    _TarotCardBackDefinition(
      id: 'inner_lotus',
      label: '이너 로터스',
      assetPath: 'assets/tarot/card_backs/ryn_inner_lotus_back_v1.png',
    ),
    _TarotCardBackDefinition(
      id: 'life_tree',
      label: '생명의 나무',
      assetPath: 'assets/tarot/card_backs/ryn_life_tree_back_v1.png',
    ),
  ];

  static const _freeSpreadDefinitions = [
    _TarotSpreadDefinition(UserText.tarotSpreadOne, _tarotSpreadOneSlots),
    _TarotSpreadDefinition(UserText.tarotSpreadThree, _tarotSpreadThreeSlots),
    _TarotSpreadDefinition(UserText.tarotSpreadFour, _tarotSpreadFourSlots),
    _TarotSpreadDefinition(UserText.tarotSpreadFive, _tarotSpreadFiveSlots),
  ];

  static const _fixedSpreadDefinitions = [
    _TarotSpreadDefinition(UserText.tarotSpreadBinary, _tarotSpreadBinarySlots),
    _TarotSpreadDefinition(UserText.tarotSpreadCeltic, _tarotSpreadCelticSlots),
  ];

  static const _spreadDefinitions = [
    ..._freeSpreadDefinitions,
    ..._fixedSpreadDefinitions,
  ];

  static const _rwsCards = [
    _TarotCardDefinition(
      'cups_01',
      'Ace of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups01.jpg',
    ),
    _TarotCardDefinition(
      'cups_02',
      '2 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups02.jpg',
    ),
    _TarotCardDefinition(
      'cups_03',
      '3 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups03.jpg',
    ),
    _TarotCardDefinition(
      'cups_04',
      '4 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups04.jpg',
    ),
    _TarotCardDefinition(
      'cups_05',
      '5 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups05.jpg',
    ),
    _TarotCardDefinition(
      'cups_06',
      '6 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups06.jpg',
    ),
    _TarotCardDefinition(
      'cups_07',
      '7 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups07.jpg',
    ),
    _TarotCardDefinition(
      'cups_08',
      '8 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups08.jpg',
    ),
    _TarotCardDefinition(
      'cups_09',
      '9 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups09.jpg',
    ),
    _TarotCardDefinition(
      'cups_10',
      '10 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups10.jpg',
    ),
    _TarotCardDefinition(
      'cups_11',
      'Page of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups11.jpg',
    ),
    _TarotCardDefinition(
      'cups_12',
      'Knight of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups12.jpg',
    ),
    _TarotCardDefinition(
      'cups_13',
      'Queen of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups13.jpg',
    ),
    _TarotCardDefinition(
      'cups_14',
      'King of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups14.jpg',
    ),
    _TarotCardDefinition(
      'major_00',
      'The Fool',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_00_Fool.jpg',
    ),
    _TarotCardDefinition(
      'major_01',
      'The Magician',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_01_Magician.jpg',
    ),
    _TarotCardDefinition(
      'major_02',
      'The High Priestess',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_02_High_Priestess.jpg',
    ),
    _TarotCardDefinition(
      'major_03',
      'The Empress',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_03_Empress.jpg',
    ),
    _TarotCardDefinition(
      'major_04',
      'The Emperor',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_04_Emperor.jpg',
    ),
    _TarotCardDefinition(
      'major_05',
      'The Hierophant',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_05_Hierophant.jpg',
    ),
    _TarotCardDefinition(
      'major_06',
      'The Lovers',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_06_Lovers.jpg',
    ),
    _TarotCardDefinition(
      'major_07',
      'The Chariot',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_07_Chariot.jpg',
    ),
    _TarotCardDefinition(
      'major_08',
      'Strength',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_08_Strength.jpg',
    ),
    _TarotCardDefinition(
      'major_09',
      'The Hermit',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_09_Hermit.jpg',
    ),
    _TarotCardDefinition(
      'major_10',
      'Wheel of Fortune',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_10_Wheel_of_Fortune.jpg',
    ),
    _TarotCardDefinition(
      'major_11',
      'Justice',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_11_Justice.jpg',
    ),
    _TarotCardDefinition(
      'major_12',
      'The Hanged Man',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_12_Hanged_Man.jpg',
    ),
    _TarotCardDefinition(
      'major_13',
      'Death',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_13_Death.jpg',
    ),
    _TarotCardDefinition(
      'major_14',
      'Temperance',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_14_Temperance.jpg',
    ),
    _TarotCardDefinition(
      'major_15',
      'The Devil',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_15_Devil.jpg',
    ),
    _TarotCardDefinition(
      'major_16',
      'The Tower',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_16_Tower.jpg',
    ),
    _TarotCardDefinition(
      'major_17',
      'The Star',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_17_Star.jpg',
    ),
    _TarotCardDefinition(
      'major_18',
      'The Moon',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_18_Moon.jpg',
    ),
    _TarotCardDefinition(
      'major_19',
      'The Sun',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_19_Sun.jpg',
    ),
    _TarotCardDefinition(
      'major_20',
      'Judgement',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_20_Judgement.jpg',
    ),
    _TarotCardDefinition(
      'major_21',
      'The World',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_21_World.jpg',
    ),
    _TarotCardDefinition(
      'pents_01',
      'Ace of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents01.jpg',
    ),
    _TarotCardDefinition(
      'pents_02',
      '2 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents02.jpg',
    ),
    _TarotCardDefinition(
      'pents_03',
      '3 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents03.jpg',
    ),
    _TarotCardDefinition(
      'pents_04',
      '4 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents04.jpg',
    ),
    _TarotCardDefinition(
      'pents_05',
      '5 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents05.jpg',
    ),
    _TarotCardDefinition(
      'pents_06',
      '6 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents06.jpg',
    ),
    _TarotCardDefinition(
      'pents_07',
      '7 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents07.jpg',
    ),
    _TarotCardDefinition(
      'pents_08',
      '8 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents08.jpg',
    ),
    _TarotCardDefinition(
      'pents_09',
      '9 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents09.jpg',
    ),
    _TarotCardDefinition(
      'pents_10',
      '10 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents10.jpg',
    ),
    _TarotCardDefinition(
      'pents_11',
      'Page of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents11.jpg',
    ),
    _TarotCardDefinition(
      'pents_12',
      'Knight of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents12.jpg',
    ),
    _TarotCardDefinition(
      'pents_13',
      'Queen of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents13.jpg',
    ),
    _TarotCardDefinition(
      'pents_14',
      'King of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents14.jpg',
    ),
    _TarotCardDefinition(
      'swords_01',
      'Ace of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords01.jpg',
    ),
    _TarotCardDefinition(
      'swords_02',
      '2 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords02.jpg',
    ),
    _TarotCardDefinition(
      'swords_03',
      '3 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords03.jpg',
    ),
    _TarotCardDefinition(
      'swords_04',
      '4 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords04.jpg',
    ),
    _TarotCardDefinition(
      'swords_05',
      '5 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords05.jpg',
    ),
    _TarotCardDefinition(
      'swords_06',
      '6 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords06.jpg',
    ),
    _TarotCardDefinition(
      'swords_07',
      '7 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords07.jpg',
    ),
    _TarotCardDefinition(
      'swords_08',
      '8 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords08.jpg',
    ),
    _TarotCardDefinition(
      'swords_09',
      '9 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords09.jpg',
    ),
    _TarotCardDefinition(
      'swords_10',
      '10 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords10.jpg',
    ),
    _TarotCardDefinition(
      'swords_11',
      'Page of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords11.jpg',
    ),
    _TarotCardDefinition(
      'swords_12',
      'Knight of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords12.jpg',
    ),
    _TarotCardDefinition(
      'swords_13',
      'Queen of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords13.jpg',
    ),
    _TarotCardDefinition(
      'swords_14',
      'King of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords14.jpg',
    ),
    _TarotCardDefinition(
      'wands_01',
      'Ace of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands01.jpg',
    ),
    _TarotCardDefinition(
      'wands_02',
      '2 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands02.jpg',
    ),
    _TarotCardDefinition(
      'wands_03',
      '3 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands03.jpg',
    ),
    _TarotCardDefinition(
      'wands_04',
      '4 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands04.jpg',
    ),
    _TarotCardDefinition(
      'wands_05',
      '5 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands05.jpg',
    ),
    _TarotCardDefinition(
      'wands_06',
      '6 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands06.jpg',
    ),
    _TarotCardDefinition(
      'wands_07',
      '7 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands07.jpg',
    ),
    _TarotCardDefinition(
      'wands_08',
      '8 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands08.jpg',
    ),
    _TarotCardDefinition(
      'wands_09',
      '9 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands09.jpg',
    ),
    _TarotCardDefinition(
      'wands_10',
      '10 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands10.jpg',
    ),
    _TarotCardDefinition(
      'wands_11',
      'Page of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands11.jpg',
    ),
    _TarotCardDefinition(
      'wands_12',
      'Knight of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands12.jpg',
    ),
    _TarotCardDefinition(
      'wands_13',
      'Queen of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands13.jpg',
    ),
    _TarotCardDefinition(
      'wands_14',
      'King of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands14.jpg',
    ),
  ];

  String _selectedDeckId = 'rws_public_domain';
  String _selectedCardBackId = 'cosmic_gate';
  String _selectedSpread = UserText.tarotSpreadThree;
  _TarotDirectionMode _directionMode = _TarotDirectionMode.auto;
  late List<_TarotCardDefinition> _remainingDeck;
  final List<_DrawnTarotCard> _drawnCards = [];
  final Set<int> _selectedDeckIndexes = {};
  final Set<int> _revealedResultIndexes = {};
  final Set<int> _revealFxIndexes = {};
  late List<String> _positionLabels;
  _TarotDrawPhase _phase = _TarotDrawPhase.beforeShuffle;
  _TarotFlowStage _stage = _TarotFlowStage.setup;

  @override
  void initState() {
    super.initState();
    _positionLabels = _defaultPositionLabelsFor(_selectedSpread);
    _prepareFreshDeck(clearDrawn: true);
  }

  _TarotDeckDefinition get _selectedDeck => _deckDefinitions.firstWhere(
    (deck) => deck.id == _selectedDeckId,
    orElse: () => _deckDefinitions.first,
  );

  _TarotCardBackDefinition get _selectedCardBack =>
      _cardBackDefinitions.firstWhere(
        (cardBack) => cardBack.id == _selectedCardBackId,
        orElse: () => _cardBackDefinitions.first,
      );

  _TarotSpreadDefinition get _selectedSpreadDefinition =>
      _spreadDefinitions.firstWhere(
        (spread) => spread.label == _selectedSpread,
        orElse: () => _spreadDefinitions[1],
      );

  List<_TarotSlotSpec> get _slots => [
    for (var index = 0; index < _selectedSpreadDefinition.slots.length; index++)
      _selectedSpreadDefinition.slots[index].copyWith(
        label: index < _positionLabels.length
            ? _normalizedPositionLabel(
                _positionLabels[index],
                _selectedSpreadDefinition.slots[index].label,
              )
            : _selectedSpreadDefinition.slots[index].label,
      ),
  ];

  List<String> _defaultPositionLabelsFor(String spreadLabel) {
    final definition = _spreadDefinitions.firstWhere(
      (spread) => spread.label == spreadLabel,
      orElse: () => _spreadDefinitions[1],
    );
    return [for (final slot in definition.slots) slot.label];
  }

  String _normalizedPositionLabel(String value, String fallback) {
    final normalized = value.trim();
    return normalized.isEmpty ? fallback : normalized;
  }

  void _updatePositionLabel(int index, String value) {
    if (index < 0 || index >= _positionLabels.length) return;
    setState(() => _positionLabels[index] = value);
  }

  bool get _isComplete => _drawnCards.length >= _slots.length;

  bool _isNextCardReversed() {
    return _directionMode == _TarotDirectionMode.auto &&
        _drawnCards.length.isOdd;
  }

  void _selectDirectionMode(_TarotDirectionMode mode) {
    setState(() => _directionMode = mode);
  }

  void _toggleDrawnDirection(int index) {
    if (index < 0 || index >= _drawnCards.length) return;
    setState(() {
      final current = _drawnCards[index];
      _drawnCards[index] = _DrawnTarotCard(
        card: current.card,
        reversed: !current.reversed,
      );
    });
  }

  void _prepareFreshDeck({required bool clearDrawn}) {
    _remainingDeck = List<_TarotCardDefinition>.of(_rwsCards)
      ..shuffle(math.Random());
    if (clearDrawn) {
      _drawnCards.clear();
      _selectedDeckIndexes.clear();
      _revealedResultIndexes.clear();
      _revealFxIndexes.clear();
    }
  }

  Future<void> _startShuffle() async {
    if (_phase == _TarotDrawPhase.shuffling) return;
    setState(() {
      _prepareFreshDeck(clearDrawn: true);
      _phase = _TarotDrawPhase.shuffling;
    });
    await Future<void>.delayed(const Duration(milliseconds: 760));
    if (!mounted) return;
    setState(() {
      _phase = _TarotDrawPhase.ready;
      _stage = _TarotFlowStage.draw;
    });
  }

  void _resetDraw() {
    setState(() {
      _prepareFreshDeck(clearDrawn: true);
      _phase = _TarotDrawPhase.beforeShuffle;
      _stage = _TarotFlowStage.setup;
    });
  }

  void _drawOneFromFan(int deckIndex) {
    if (_phase == _TarotDrawPhase.shuffling ||
        _drawnCards.length >= _slots.length ||
        deckIndex < 0 ||
        deckIndex >= _remainingDeck.length ||
        _selectedDeckIndexes.contains(deckIndex)) {
      return;
    }
    if (_phase == _TarotDrawPhase.beforeShuffle) {
      _prepareFreshDeck(clearDrawn: true);
    }
    setState(() {
      _stage = _TarotFlowStage.draw;
      _phase = _TarotDrawPhase.drawing;
      final card = _remainingDeck[deckIndex];
      _selectedDeckIndexes.add(deckIndex);
      _drawnCards.add(
        _DrawnTarotCard(card: card, reversed: _isNextCardReversed()),
      );
      _phase = _isComplete ? _TarotDrawPhase.complete : _TarotDrawPhase.ready;
    });
  }

  void _drawAll() {
    if (_phase == _TarotDrawPhase.shuffling) return;
    setState(() {
      if (_phase == _TarotDrawPhase.beforeShuffle) {
        _prepareFreshDeck(clearDrawn: _drawnCards.isEmpty);
      }
      _phase = _TarotDrawPhase.drawing;
      for (
        var index = 0;
        index < _remainingDeck.length && _drawnCards.length < _slots.length;
        index++
      ) {
        if (_selectedDeckIndexes.contains(index)) continue;
        final card = _remainingDeck[index];
        _selectedDeckIndexes.add(index);
        _drawnCards.add(
          _DrawnTarotCard(card: card, reversed: _isNextCardReversed()),
        );
      }
      _phase = _isComplete ? _TarotDrawPhase.complete : _TarotDrawPhase.ready;
      if (_isComplete) _enterResultStage();
    });
  }

  void _startRevealFx(int index) {
    _revealFxIndexes.add(index);
    Future<void>.delayed(const Duration(milliseconds: 620), () {
      if (!mounted) return;
      setState(() => _revealFxIndexes.remove(index));
    });
  }

  void _revealResultCard(int index) {
    if (index < 0 || index >= _drawnCards.length) return;
    if (_revealedResultIndexes.contains(index)) return;
    setState(() {
      _revealedResultIndexes.add(index);
      _startRevealFx(index);
    });
  }

  Future<void> _revealAllResultCards() async {
    for (var index = 0; index < _drawnCards.length; index++) {
      if (!_revealedResultIndexes.contains(index)) {
        _revealResultCard(index);
        await Future<void>.delayed(const Duration(milliseconds: 90));
        if (!mounted) return;
      }
    }
  }

  void _enterResultStage() {
    _revealedResultIndexes.clear();
    _revealFxIndexes.clear();
    _stage = _TarotFlowStage.result;
  }

  void _showResult() {
    if (!_isComplete) return;
    setState(_enterResultStage);
  }

  void _showInterpretation() {
    if (!_isComplete) return;
    setState(() => _stage = _TarotFlowStage.interpretation);
  }

  void _selectSpread(String spread) {
    setState(() {
      _selectedSpread = spread;
      _positionLabels = _defaultPositionLabelsFor(spread);
      _prepareFreshDeck(clearDrawn: true);
      _phase = _TarotDrawPhase.beforeShuffle;
      _stage = _TarotFlowStage.setup;
    });
  }

  Map<int, int> _selectedDeckOrder() {
    final order = <int, int>{};
    var i = 1;
    for (final deckIndex in _selectedDeckIndexes) {
      order[deckIndex] = i++;
    }
    return order;
  }

  void _selectDeck(String deckId) {
    setState(() {
      _selectedDeckId = deckId;
      _prepareFreshDeck(clearDrawn: true);
      _phase = _TarotDrawPhase.beforeShuffle;
      _stage = _TarotFlowStage.setup;
    });
  }

  void _selectCardBack(String cardBackId) {
    setState(() => _selectedCardBackId = cardBackId);
  }

  @override
  Widget build(BuildContext context) {
    final immersive = _stage != _TarotFlowStage.setup;
    final Widget stageContent = switch (_stage) {
      _TarotFlowStage.setup => _TarotSetupStage(
        decks: _deckDefinitions,
        selectedDeckId: _selectedDeckId,
        onDeckSelected: _selectDeck,
        cardBacks: _cardBackDefinitions,
        selectedCardBackId: _selectedCardBackId,
        selectedCardBack: _selectedCardBack,
        onCardBackSelected: _selectCardBack,
        freeSpreads: _freeSpreadDefinitions,
        fixedSpreads: _fixedSpreadDefinitions,
        selectedSpread: _selectedSpread,
        onSpreadSelected: _selectSpread,
        selectedDeck: _selectedDeck,
        onShuffle: _startShuffle,
        onAutoDraw: _drawAll,
        isShuffling: _phase == _TarotDrawPhase.shuffling,
        directionMode: _directionMode,
        onDirectionModeSelected: _selectDirectionMode,
        positionLabels: _positionLabels,
        defaultPositionLabels: _defaultPositionLabelsFor(_selectedSpread),
        onPositionLabelChanged: _updatePositionLabel,
      ),
      _TarotFlowStage.draw => _TarotFullDeckDrawStage(
        deck: _selectedDeck,
        spread: _selectedSpread,
        cards: _remainingDeck,
        selectedIndexes: _selectedDeckIndexes,
        selectedOrder: _selectedDeckOrder(),
        selectedCount: _drawnCards.length,
        targetCount: _slots.length,
        isShuffling: _phase == _TarotDrawPhase.shuffling,
        onSelected: _drawOneFromFan,
        onAutoDraw: _drawAll,
        onShowResult: _showResult,
        onReset: _resetDraw,
        cardBack: _selectedCardBack,
      ),
      _TarotFlowStage.result => _TarotResultStage(
        spreadLabel: _selectedSpread,
        slots: _slots,
        drawnCards: _drawnCards,
        revealedIndexes: _revealedResultIndexes,
        revealFxIndexes: _revealFxIndexes,
        onRevealCard: _revealResultCard,
        onRevealAll: _revealAllResultCards,
        onInterpret: _showInterpretation,
        onReset: _resetDraw,
        onDirectionToggle: _toggleDrawnDirection,
        cardBack: _selectedCardBack,
      ),
      _TarotFlowStage.interpretation => _TarotInterpretationStage(
        spreadLabel: _selectedSpread,
        slots: _slots,
        drawnCards: _drawnCards,
        revealedIndexes: _revealedResultIndexes,
        onBackToResult: () => setState(() => _stage = _TarotFlowStage.result),
        onReset: _resetDraw,
      ),
    };
    return LayoutBuilder(
      builder: (context, shellConstraints) {
        final boundedHeight = shellConstraints.hasBoundedHeight;
        return _TarotShellCard(
          padding: EdgeInsets.all(immersive ? 10 : 22),
          child: Column(
            mainAxisSize: boundedHeight ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (immersive)
                _TarotImmersiveTopBar(
                  stage: _stage,
                  spreadLabel: _selectedSpread,
                  onBack: widget.onBack,
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${UserText.navReading} > ${UserText.tarotTitle}',
                            style: TextStyle(
                              color: RynPalette.subtext(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            UserText.tarotTitle,
                            style: TextStyle(
                              color: RynPalette.text(context),
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            UserText.tarotSubtitle,
                            style: TextStyle(
                              color: RynPalette.subtext(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text(UserText.backToWorkspace),
                    ),
                  ],
                ),
              SizedBox(height: immersive ? 8 : 18),
              if (boundedHeight)
                Expanded(child: SingleChildScrollView(child: stageContent))
              else
                stageContent,
            ],
          ),
        );
      },
    );
  }
}

class _TarotImmersiveTopBar extends StatelessWidget {
  const _TarotImmersiveTopBar({
    required this.stage,
    required this.spreadLabel,
    required this.onBack,
  });

  final _TarotFlowStage stage;
  final String spreadLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final stageLabel = switch (stage) {
      _TarotFlowStage.draw => UserText.tarotDrawPreparation,
      _TarotFlowStage.interpretation => '해석 패널',
      _ => UserText.tarotResultTable,
    };
    return Row(
      children: [
        TextButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded, size: 17),
          label: const Text(UserText.backToWorkspace),
        ),
        const SizedBox(width: 8),
        _TarotSmallStageLabel(label: stageLabel),
        const SizedBox(width: 8),
        _TarotSmallBadge(spreadLabel, compact: true),
      ],
    );
  }
}

class _TarotSetupStage extends StatefulWidget {
  const _TarotSetupStage({
    required this.decks,
    required this.selectedDeckId,
    required this.onDeckSelected,
    required this.cardBacks,
    required this.selectedCardBackId,
    required this.selectedCardBack,
    required this.onCardBackSelected,
    required this.freeSpreads,
    required this.fixedSpreads,
    required this.selectedSpread,
    required this.onSpreadSelected,
    required this.selectedDeck,
    required this.onShuffle,
    required this.onAutoDraw,
    required this.isShuffling,
    required this.directionMode,
    required this.onDirectionModeSelected,
    required this.positionLabels,
    required this.defaultPositionLabels,
    required this.onPositionLabelChanged,
  });

  final List<_TarotDeckDefinition> decks;
  final String selectedDeckId;
  final ValueChanged<String> onDeckSelected;
  final List<_TarotCardBackDefinition> cardBacks;
  final String selectedCardBackId;
  final _TarotCardBackDefinition selectedCardBack;
  final ValueChanged<String> onCardBackSelected;
  final List<_TarotSpreadDefinition> freeSpreads;
  final List<_TarotSpreadDefinition> fixedSpreads;
  final String selectedSpread;
  final ValueChanged<String> onSpreadSelected;
  final _TarotDeckDefinition selectedDeck;
  final VoidCallback onShuffle;
  final VoidCallback onAutoDraw;
  final bool isShuffling;
  final _TarotDirectionMode directionMode;
  final ValueChanged<_TarotDirectionMode> onDirectionModeSelected;
  final List<String> positionLabels;
  final List<String> defaultPositionLabels;
  final void Function(int index, String value) onPositionLabelChanged;

  @override
  State<_TarotSetupStage> createState() => _TarotSetupStageState();
}

class _TarotSetupStageState extends State<_TarotSetupStage> {
  int _stepIndex = 0;

  void _goToStep(int step) {
    setState(() => _stepIndex = step.clamp(0, 3));
  }

  @override
  Widget build(BuildContext context) {
    final purposeStep = _TarotStepPanel(
      title: '1 질문과 목적',
      subtitle: '오늘 리딩의 중심을 먼저 잡고 덱 선택으로 넘어갑니다.',
      child: const _TarotQuestionGuidanceLayout(),
    );
    final deckStep = _TarotStepPanel(
      title: '2 덱 선택',
      subtitle: '상담 분위기에 맞는 덱을 고르세요.',
      child: _TarotDeckChoiceSection(
        title: '',
        decks: widget.decks,
        selectedDeckId: widget.selectedDeckId,
        onSelected: widget.onDeckSelected,
        cardBack: widget.selectedCardBack,
      ),
    );
    final detailStep = _TarotStepPanel(
      title: '3 카드 세부 설정',
      subtitle: '카드 뒷면, 스프레드, 방향, 자리 이름을 정합니다.',
      child: _TarotCardDetailSetupLayout(
        cardBacks: widget.cardBacks,
        selectedCardBackId: widget.selectedCardBackId,
        onCardBackSelected: widget.onCardBackSelected,
        freeSpreads: widget.freeSpreads,
        fixedSpreads: widget.fixedSpreads,
        selectedSpread: widget.selectedSpread,
        onSpreadSelected: widget.onSpreadSelected,
        directionMode: widget.directionMode,
        onDirectionModeSelected: widget.onDirectionModeSelected,
        positionLabels: widget.positionLabels,
        defaultPositionLabels: widget.defaultPositionLabels,
        onPositionLabelChanged: widget.onPositionLabelChanged,
      ),
    );
    final drawStep = _TarotStepPanel(
      title: '4 셔플과 드로우',
      subtitle: '준비가 끝나면 카드를 섞거나 자동으로 펼칩니다.',
      child: _TarotPreparationPanel(
        selectedDeck: widget.selectedDeck,
        selectedSpread: widget.selectedSpread,
        isShuffling: widget.isShuffling,
        onShuffle: widget.onShuffle,
        onAutoDraw: widget.onAutoDraw,
        cardBack: widget.selectedCardBack,
      ),
    );
    final steps = [purposeStep, deckStep, detailStep, drawStep];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TarotStageProgress(
          key: const Key('tarot-setup-progress'),
          activeIndex: _stepIndex,
          labels: const ['정리', '덱', '세부 설정', '셔플'],
          keyPrefix: 'tarot-setup-step-chip',
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            OutlinedButton.icon(
              style: _tarotOutlinedSetupActionStyle(context),
              onPressed: _stepIndex == 0
                  ? null
                  : () => _goToStep(_stepIndex - 1),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('이전'),
            ),
            const Spacer(),
            if (_stepIndex < steps.length - 1)
              FilledButton.icon(
                style: _tarotFilledSetupActionStyle(context),
                onPressed: () => _goToStep(_stepIndex + 1),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('다음'),
              )
            else
              _TarotSmallBadge('준비 완료 후 셔플하거나 자동으로 펼치세요'),
          ],
        ),
        const SizedBox(height: 12),
        KeyedSubtree(
          key: Key('tarot-active-setup-step-$_stepIndex'),
          child: steps[_stepIndex],
        ),
      ],
    );
  }
}

class _TarotStepPanel extends StatelessWidget {
  const _TarotStepPanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RynPalette.surfaceElevated(context),
        borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
        border: Border.all(color: RynPalette.line(context)),
        boxShadow: RynPalette.panelShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              color: RynPalette.text(context),
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              color: RynPalette.subtext(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

ButtonStyle _tarotFilledActionStyle() {
  return FilledButton.styleFrom(
    backgroundColor: RynPalette.tarotGold,
    foregroundColor: RynPalette.tarotMidnight,
    disabledBackgroundColor: Colors.white.withValues(alpha: 0.14),
    disabledForegroundColor: Colors.white.withValues(alpha: 0.42),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}

ButtonStyle _tarotOutlinedActionStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    disabledForegroundColor: Colors.white.withValues(alpha: 0.42),
    side: BorderSide(color: RynPalette.tarotGold.withValues(alpha: 0.62)),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}

ButtonStyle _tarotTextActionStyle() {
  return TextButton.styleFrom(
    foregroundColor: Colors.white,
    disabledForegroundColor: Colors.white.withValues(alpha: 0.42),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}

ButtonStyle _tarotFilledSetupActionStyle(BuildContext context) {
  return FilledButton.styleFrom(
    backgroundColor: RynPalette.tarotGold,
    foregroundColor: RynPalette.tarotMidnight,
    disabledBackgroundColor: RynPalette.line(context),
    disabledForegroundColor: RynPalette.subtext(context),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}

ButtonStyle _tarotOutlinedSetupActionStyle(BuildContext context) {
  return OutlinedButton.styleFrom(
    foregroundColor: RynPalette.text(context),
    disabledForegroundColor: RynPalette.subtext(
      context,
    ).withValues(alpha: 0.55),
    side: BorderSide(color: RynPalette.line(context)),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}

class _TarotQuestionGuidanceLayout extends StatelessWidget {
  const _TarotQuestionGuidanceLayout();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final guide = Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                RynPalette.tarotViolet.withValues(alpha: 0.10),
                RynPalette.tarotGold.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: RynPalette.line(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TarotSmallBadge('상담 전 정렬', compact: true),
              const SizedBox(height: 14),
              Text(
                '질문은 짧게, 목적은 분명하게 잡아두세요.',
                style: TextStyle(
                  color: RynPalette.text(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '카드를 뽑기 전 오늘 알고 싶은 방향을 한 문장으로 정하면 덱 선택과 해석 흐름이 선명해집니다.',
                style: TextStyle(
                  color: RynPalette.subtext(context),
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: RynPalette.tarotGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '이 화면의 메모는 현재 상담 준비를 돕는 정리 공간입니다.',
                      style: TextStyle(
                        color: RynPalette.subtext(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
        final memo = const _TarotMemoPanel();
        return SizedBox(
          key: const Key('tarot-setup-guidance-layout'),
          height: wide ? 430 : null,
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 4, child: guide),
                    const SizedBox(width: 16),
                    Expanded(flex: 6, child: memo),
                  ],
                )
              : Column(children: [guide, const SizedBox(height: 14), memo]),
        );
      },
    );
  }
}

class _TarotCardDetailSetupLayout extends StatelessWidget {
  const _TarotCardDetailSetupLayout({
    required this.cardBacks,
    required this.selectedCardBackId,
    required this.onCardBackSelected,
    required this.freeSpreads,
    required this.fixedSpreads,
    required this.selectedSpread,
    required this.onSpreadSelected,
    required this.directionMode,
    required this.onDirectionModeSelected,
    required this.positionLabels,
    required this.defaultPositionLabels,
    required this.onPositionLabelChanged,
  });

  final List<_TarotCardBackDefinition> cardBacks;
  final String selectedCardBackId;
  final ValueChanged<String> onCardBackSelected;
  final List<_TarotSpreadDefinition> freeSpreads;
  final List<_TarotSpreadDefinition> fixedSpreads;
  final String selectedSpread;
  final ValueChanged<String> onSpreadSelected;
  final _TarotDirectionMode directionMode;
  final ValueChanged<_TarotDirectionMode> onDirectionModeSelected;
  final List<String> positionLabels;
  final List<String> defaultPositionLabels;
  final void Function(int index, String value) onPositionLabelChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1040;
        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TarotCardBackChoiceSection(
              cardBacks: cardBacks,
              selectedCardBackId: selectedCardBackId,
              onSelected: onCardBackSelected,
            ),
            const SizedBox(height: 14),
            _TarotDirectionChoiceSection(
              selected: directionMode,
              onSelected: onDirectionModeSelected,
            ),
          ],
        );
        final right = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TarotSpreadChoiceSection(
              title: UserText.tarotSpreadSelect,
              freeSpreads: freeSpreads,
              fixedSpreads: fixedSpreads,
              selected: selectedSpread,
              onSelected: onSpreadSelected,
            ),
            const SizedBox(height: 14),
            _TarotPositionSetupSection(
              spreadLabel: selectedSpread,
              labels: positionLabels,
              defaultLabels: defaultPositionLabels,
              onChanged: onPositionLabelChanged,
            ),
          ],
        );
        return Container(
          key: const Key('tarot-card-detail-balanced-layout'),
          decoration: BoxDecoration(
            color: RynPalette.surfaceSoft(context).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: RynPalette.line(context)),
          ),
          padding: const EdgeInsets.all(14),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: left),
                    const SizedBox(width: 14),
                    Expanded(flex: 6, child: right),
                  ],
                )
              : Column(children: [left, const SizedBox(height: 14), right]),
        );
      },
    );
  }
}

class _TarotPositionSetupSection extends StatelessWidget {
  const _TarotPositionSetupSection({
    required this.spreadLabel,
    required this.labels,
    required this.defaultLabels,
    required this.onChanged,
  });

  final String spreadLabel;
  final List<String> labels;
  final List<String> defaultLabels;
  final void Function(int index, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RynPalette.surfaceElevated(context),
        borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
        border: Border.all(color: RynPalette.line(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: 18,
                color: RynPalette.accent(context),
              ),
              const SizedBox(width: 8),
              Text(
                UserText.tarotPositionSetup,
                style: TextStyle(
                  color: RynPalette.text(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              _TarotSmallBadge(spreadLabel, compact: true),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            UserText.tarotPositionSetupHelper,
            style: TextStyle(
              color: RynPalette.subtext(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth >= 900
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth >= 560
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  for (var index = 0; index < labels.length; index++)
                    SizedBox(
                      width: itemWidth,
                      child: TextFormField(
                        key: ValueKey(
                          'tarot-position-label-input-$spreadLabel-$index',
                        ),
                        initialValue: labels[index],
                        maxLength: 12,
                        onChanged: (value) => onChanged(index, value),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          counterText: '',
                          isDense: true,
                          labelText: '${index + 1}번 자리',
                          hintText: index < defaultLabels.length
                              ? defaultLabels[index]
                              : null,
                          filled: true,
                          fillColor: RynPalette.surfaceSoft(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: RynPalette.line(context),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: RynPalette.line(context),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: RynPalette.accent(context),
                              width: 1.4,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: RynPalette.text(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TarotSmallStageLabel extends StatelessWidget {
  const _TarotSmallStageLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: _TarotSmallBadge(label, compact: true),
    );
  }
}

class _TarotStageProgress extends StatelessWidget {
  const _TarotStageProgress({
    super.key,
    required this.activeIndex,
    this.labels = const ['준비', '카드 드로우', '공개', '해석'],
    this.keyPrefix = 'tarot-stage-chip',
  });

  final int activeIndex;
  final List<String> labels;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var index = 0; index < labels.length; index++)
          _TarotStageChip(
            key: Key(
              '$keyPrefix-$index-${index == activeIndex ? 'active' : 'idle'}',
            ),
            label: labels[index],
            active: index == activeIndex,
          ),
      ],
    );
  }
}

class _TarotStageChip extends StatelessWidget {
  const _TarotStageChip({super.key, required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(
                colors: [RynPalette.tarotViolet, RynPalette.lavenderStrong],
              )
            : null,
        color: active ? null : Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
        border: Border.all(
          color: active
              ? RynPalette.tarotGold.withValues(alpha: 0.58)
              : Colors.white.withValues(alpha: 0.11),
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: RynPalette.lavenderStrong.withValues(alpha: 0.28),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : RynPalette.tarotLavender,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

class _TarotCosmicParticles extends StatelessWidget {
  const _TarotCosmicParticles();

  static const _particles = <({double x, double y, double size, double alpha})>[
    (x: 0.12, y: 0.22, size: 2.8, alpha: 0.42),
    (x: 0.24, y: 0.76, size: 2.2, alpha: 0.28),
    (x: 0.42, y: 0.18, size: 2.0, alpha: 0.34),
    (x: 0.58, y: 0.68, size: 3.0, alpha: 0.24),
    (x: 0.73, y: 0.28, size: 2.4, alpha: 0.38),
    (x: 0.88, y: 0.62, size: 2.8, alpha: 0.30),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (final particle in _particles)
                Positioned(
                  left: constraints.maxWidth * particle.x,
                  top: constraints.maxHeight * particle.y,
                  child: Container(
                    width: particle.size,
                    height: particle.size,
                    decoration: BoxDecoration(
                      color: RynPalette.tarotLavender.withValues(
                        alpha: particle.alpha,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: RynPalette.tarotLavender.withValues(
                            alpha: particle.alpha,
                          ),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TarotPreparationPanel extends StatelessWidget {
  const _TarotPreparationPanel({
    required this.selectedDeck,
    required this.selectedSpread,
    required this.isShuffling,
    required this.onShuffle,
    required this.onAutoDraw,
    required this.cardBack,
  });

  final _TarotDeckDefinition selectedDeck;
  final String selectedSpread;
  final bool isShuffling;
  final VoidCallback onShuffle;
  final VoidCallback onAutoDraw;
  final _TarotCardBackDefinition cardBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-ritual-shuffle-stage'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment(0, -0.28),
          radius: 1.12,
          colors: [
            Color(0x55312275),
            Color(0x2AD9BC7A),
            RynPalette.tarotNavy,
            RynPalette.tarotMidnight,
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: RynPalette.tarotGold.withValues(alpha: 0.18)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 960;
          final header = Align(
            alignment: wide ? Alignment.topLeft : Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: wide ? 560 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: wide
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  const _TarotSmallStageLabel(label: '셔플 의식'),
                  const SizedBox(height: 12),
                  const Text(
                    '덱을 깨우고 리딩 테이블을 엽니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '선택한 카드 뒷면으로 78장의 실제 카드가 얼굴을 숨긴 채 펼쳐집니다.',
                    textAlign: wide ? TextAlign.start : TextAlign.center,
                    style: TextStyle(
                      color: RynPalette.tarotLavender,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          );
          final summary = Align(
            alignment: wide ? Alignment.topRight : Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: _TarotSelectionSummary(
                deck: selectedDeck,
                spread: selectedSpread,
              ),
            ),
          );
          final deck = Align(
            alignment: wide ? const Alignment(0.18, 0.03) : Alignment.center,
            child: SizedBox(
              key: const Key('tarot-ritual-deck-preview'),
              width: wide ? 440 : 320,
              height: wide ? 500 : 380,
              child: Center(
                child: KeyedSubtree(
                  key: const Key('tarot-ritual-hero-deck-stack'),
                  child: _ShuffleDeckStack(
                    isShuffling: isShuffling,
                    onTap: onShuffle,
                    cardBack: cardBack,
                    large: true,
                  ),
                ),
              ),
            ),
          );
          final actions = Align(
            alignment: wide ? const Alignment(0, 0.93) : Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('tarot-shuffle-button'),
                      style: _tarotFilledActionStyle(),
                      onPressed: isShuffling ? null : onShuffle,
                      icon: const Icon(Icons.shuffle_rounded, size: 18),
                      label: Text(
                        isShuffling
                            ? _TarotUiText.shuffling
                            : _TarotUiText.shuffle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: _tarotOutlinedActionStyle(),
                      onPressed: isShuffling ? null : onAutoDraw,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: const Text(UserText.tarotAutoDraw),
                    ),
                  ),
                ],
              ),
            ),
          );
          return SizedBox(
            key: const Key('tarot-unified-ritual-layout'),
            height: wide ? 540 : 640,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: RadialGradient(
                        center: wide
                            ? const Alignment(0.2, 0.08)
                            : Alignment.center,
                        radius: 0.92,
                        colors: [
                          RynPalette.tarotGold.withValues(alpha: 0.18),
                          const Color(0x66312275),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(left: 0, right: 0, top: wide ? 0 : 8, child: header),
                if (wide) Positioned(top: 0, right: 0, child: summary),
                deck,
                actions,
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TarotFullDeckDrawStage extends StatelessWidget {
  const _TarotFullDeckDrawStage({
    required this.deck,
    required this.spread,
    required this.cards,
    required this.selectedIndexes,
    required this.selectedOrder,
    required this.selectedCount,
    required this.targetCount,
    required this.isShuffling,
    required this.onSelected,
    required this.onAutoDraw,
    required this.onShowResult,
    required this.onReset,
    required this.cardBack,
  });

  final _TarotDeckDefinition deck;
  final String spread;
  final List<_TarotCardDefinition> cards;
  final Set<int> selectedIndexes;
  final Map<int, int> selectedOrder;
  final int selectedCount;
  final int targetCount;
  final bool isShuffling;
  final ValueChanged<int> onSelected;
  final VoidCallback onAutoDraw;
  final VoidCallback onShowResult;
  final VoidCallback onReset;
  final _TarotCardBackDefinition cardBack;

  @override
  Widget build(BuildContext context) {
    final canReveal = selectedCount >= targetCount;
    final remainingToSelect = math.max(0, targetCount - selectedCount);
    final guideText = canReveal ? '카드를 모두 선택했습니다' : '$targetCount장을 골라주세요';
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment(0, -0.62),
          radius: 1.22,
          colors: [
            Color(0x66312275),
            Color(0x1FD9BC7A),
            RynPalette.tarotNavy,
            RynPalette.tarotMidnight,
          ],
        ),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.095)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 38,
            offset: Offset(0, 22),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _TarotCosmicParticles()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const _TarotStageProgress(activeIndex: 1),
                  TextButton.icon(
                    style: _tarotTextActionStyle(),
                    onPressed: onReset,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text(_TarotUiText.prepare),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Text(
                      '${deck.label} · $spread',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  _TarotSmallBadge('$selectedCount / $targetCount 선택'),
                  _TarotSmallBadge('남은 선택 $remainingToSelect장'),
                  OutlinedButton.icon(
                    style: _tarotOutlinedActionStyle(),
                    onPressed: isShuffling ? null : onAutoDraw,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: const Text(UserText.tarotAutoDraw),
                  ),
                  FilledButton.icon(
                    key: const Key('tarot-show-result-button'),
                    style: _tarotFilledActionStyle(),
                    onPressed: canReveal ? onShowResult : null,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text(_TarotUiText.showResult),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Column(
                  children: [
                    Text(
                      guideText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '마음이 머무는 카드를 직관으로 선택하세요',
                      style: TextStyle(
                        color: RynPalette.tarotLavender,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _TarotFullDeckBoard(
                cards: cards,
                selectedIndexes: selectedIndexes,
                selectedOrder: selectedOrder,
                targetReached: canReveal,
                onSelected: onSelected,
                cardBack: cardBack,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarotFullDeckBoard extends StatefulWidget {
  const _TarotFullDeckBoard({
    required this.cards,
    required this.selectedIndexes,
    required this.selectedOrder,
    required this.targetReached,
    required this.onSelected,
    required this.cardBack,
  });

  final List<_TarotCardDefinition> cards;
  final Set<int> selectedIndexes;
  final Map<int, int> selectedOrder;
  final bool targetReached;
  final ValueChanged<int> onSelected;
  final _TarotCardBackDefinition cardBack;

  @override
  State<_TarotFullDeckBoard> createState() => _TarotFullDeckBoardState();
}

class _TarotFullDeckBoardState extends State<_TarotFullDeckBoard> {
  int? _hoveredIndex;

  void _setHoveredIndex(int? index) {
    if (_hoveredIndex == index) return;
    setState(() => _hoveredIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-full-deck-stage'),
      height: 720,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF070A18), Color(0xFF111735), Color(0xFF201747)],
        ),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: RynPalette.tarotGold.withValues(alpha: 0.16)),
        boxShadow: [
          const BoxShadow(
            color: Color(0xAA000000),
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
          BoxShadow(
            color: RynPalette.lavenderStrong.withValues(alpha: 0.18),
            blurRadius: 58,
            spreadRadius: 3,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final availableHeight = constraints.maxHeight;
          final desiredWidth = availableWidth >= 1500 ? 92.0 : 74.0;
          final widthForFullArc = (availableWidth * 0.96) / 15;
          final cardWidth = math.max(
            48.0,
            math.min(
              desiredWidth,
              math.min(widthForFullArc, availableHeight * 0.17),
            ),
          );
          final cardHeight = cardWidth * 1.5;
          final tableWidth = availableWidth;
          final tableHeight = math.max(availableHeight, 560.0);
          final orderedIndexes =
              List<int>.generate(widget.cards.length, (i) => i)..sort((a, b) {
                int zRank(int index) {
                  if (index == _hoveredIndex) return 3;
                  if (widget.selectedIndexes.contains(index)) return 2;
                  return 1;
                }

                final rankCompare = zRank(a).compareTo(zRank(b));
                if (rankCompare != 0) return rankCompare;
                return a.compareTo(b);
              });
          return SizedBox(
            key: const Key('tarot-full-deck-grid'),
            width: tableWidth,
            height: tableHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.1),
                          radius: 0.98,
                          colors: [
                            RynPalette.tarotLavender.withValues(alpha: 0.16),
                            RynPalette.lavenderStrong.withValues(alpha: 0.075),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                for (final index in orderedIndexes)
                  _PositionedFanCard(
                    index: index,
                    cardId: widget.cards[index].id,
                    count: widget.cards.length,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    tableWidth: tableWidth,
                    tableHeight: tableHeight,
                    selected: widget.selectedIndexes.contains(index),
                    selectedOrder: widget.selectedOrder[index],
                    hasSelection: widget.selectedIndexes.isNotEmpty,
                    hovered: _hoveredIndex == index,
                    disabled:
                        widget.targetReached &&
                        !widget.selectedIndexes.contains(index),
                    onHoverChanged: (hovered) =>
                        _setHoveredIndex(hovered ? index : null),
                    onTap: () => widget.onSelected(index),
                    cardBack: widget.cardBack,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PositionedFanCard extends StatelessWidget {
  const _PositionedFanCard({
    required this.index,
    required this.cardId,
    required this.count,
    required this.cardWidth,
    required this.cardHeight,
    required this.tableWidth,
    required this.tableHeight,
    required this.selected,
    required this.selectedOrder,
    required this.hasSelection,
    required this.hovered,
    required this.disabled,
    required this.onHoverChanged,
    required this.onTap,
    required this.cardBack,
  });

  final int index;
  final String cardId;
  final int count;
  final double cardWidth;
  final double cardHeight;
  final double tableWidth;
  final double tableHeight;
  final bool selected;
  final int? selectedOrder;
  final bool hasSelection;
  final bool hovered;
  final bool disabled;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTap;
  final _TarotCardBackDefinition cardBack;

  @override
  Widget build(BuildContext context) {
    final centerIndex = (count - 1) / 2;
    final normalized = centerIndex == 0
        ? 0.0
        : (index - centerIndex) / centerIndex;
    final centerX = tableWidth / 2;
    final fanWidth = (tableWidth * 0.985 - cardWidth) / 2;
    final baseY = tableHeight * 0.20;
    final curveDepth = tableHeight * 0.43;
    final x = centerX + normalized * fanWidth - cardWidth / 2;
    final y = baseY + curveDepth * normalized * normalized;
    final rotation = normalized * (math.pi / 180) * 48;
    return Positioned(
      left: x.clamp(10.0, tableWidth - cardWidth - 10),
      top: y.clamp(18.0, tableHeight - cardHeight - 18),
      width: cardWidth,
      height: cardHeight,
      child: _TarotFullDeckCard(
        key: Key('tarot-full-deck-card-$index'),
        index: index,
        cardId: cardId,
        angle: rotation,
        selected: selected,
        selectedOrder: selectedOrder,
        hasSelection: hasSelection,
        hovered: hovered,
        disabled: disabled,
        onHoverChanged: onHoverChanged,
        onTap: onTap,
        cardBack: cardBack,
      ),
    );
  }
}

class _TarotFullDeckCard extends StatelessWidget {
  const _TarotFullDeckCard({
    super.key,
    required this.index,
    required this.cardId,
    required this.angle,
    required this.selected,
    required this.selectedOrder,
    required this.hasSelection,
    required this.hovered,
    required this.disabled,
    required this.onHoverChanged,
    required this.onTap,
    required this.cardBack,
  });

  final int index;
  final String cardId;
  final double angle;
  final bool selected;
  final int? selectedOrder;
  final bool hasSelection;
  final bool hovered;
  final bool disabled;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTap;
  final _TarotCardBackDefinition cardBack;

  @override
  Widget build(BuildContext context) {
    final lifted = hovered && !disabled;
    final selected = this.selected;
    final liftAngle = angle - math.pi / 2;
    final liftAmount = selected
        ? 18.0
        : lifted
        ? 16.0
        : 0.0;
    final liftOffset = Offset(
      math.cos(liftAngle) * liftAmount,
      math.sin(liftAngle) * liftAmount,
    );
    final opacity = disabled
        ? 0.34
        : selected
        ? 1.0
        : hasSelection
        ? 0.68
        : 1.0;
    return KeyedSubtree(
      key: Key('tarot-face-down-card-identity-$cardId'),
      child: MouseRegion(
        cursor: disabled ? MouseCursor.defer : SystemMouseCursors.click,
        onEnter: (_) => onHoverChanged(true),
        onExit: (_) => onHoverChanged(false),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: disabled ? null : onTap,
          child: AnimatedScale(
            scale: selected
                ? 1.12
                : lifted
                ? 1.22
                : 1.0,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: Transform.translate(
              offset: liftOffset,
              child: Transform.rotate(
                angle: angle,
                child: Opacity(
                  opacity: opacity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IgnorePointer(
                        ignoring: selected,
                        child: SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: KeyedSubtree(
                              key: Key(
                                'tarot-draw-face-down-card-back-image-$index',
                              ),
                              child:
                                  _TarotCardBackChoice(
                                        onTap: disabled ? () {} : onTap,
                                        compact: true,
                                        glowing: selected || lifted,
                                        assetPath: cardBack.assetPath,
                                      )
                                      .animate(target: selected ? 1 : 0)
                                      .scale(
                                        begin: const Offset(1, 1),
                                        end: const Offset(1.04, 1.04),
                                        duration: 220.ms,
                                        curve: Curves.easeOutCubic,
                                      )
                                      .shimmer(
                                        duration: 520.ms,
                                        color: RynPalette.accent(
                                          context,
                                        ).withValues(alpha: 0.22),
                                      ),
                            ),
                          ),
                        ),
                      ),
                      if (selected && selectedOrder != null)
                        Positioned(
                          right: -5,
                          top: -7,
                          child: Container(
                            key: Key('tarot-selected-order-$selectedOrder'),
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: RynPalette.accent(context),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: RynPalette.surface(context),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: RynPalette.accent(
                                    context,
                                  ).withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Text(
                              '$selectedOrder',
                              style: TextStyle(
                                color: RynPalette.iconOnAccent(context),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TarotResultStage extends StatelessWidget {
  const _TarotResultStage({
    required this.spreadLabel,
    required this.slots,
    required this.drawnCards,
    required this.revealedIndexes,
    required this.revealFxIndexes,
    required this.onRevealCard,
    required this.onRevealAll,
    required this.onInterpret,
    required this.onReset,
    required this.onDirectionToggle,
    required this.cardBack,
  });

  final String spreadLabel;
  final List<_TarotSlotSpec> slots;
  final List<_DrawnTarotCard> drawnCards;
  final Set<int> revealedIndexes;
  final Set<int> revealFxIndexes;
  final ValueChanged<int> onRevealCard;
  final VoidCallback onRevealAll;
  final VoidCallback onInterpret;
  final VoidCallback onReset;
  final ValueChanged<int> onDirectionToggle;
  final _TarotCardBackDefinition cardBack;

  @override
  Widget build(BuildContext context) {
    final allRevealed = revealedIndexes.length >= drawnCards.length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment(0, -0.66),
          radius: 1.24,
          colors: [
            Color(0x66312275),
            Color(0x222C204E),
            RynPalette.tarotNavy,
            RynPalette.tarotMidnight,
          ],
        ),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.095)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 38,
            offset: Offset(0, 22),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _TarotCosmicParticles()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const _TarotStageProgress(activeIndex: 2),
                  TextButton.icon(
                    style: _tarotTextActionStyle(),
                    onPressed: onReset,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text(UserText.tarotResetDraw),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '리딩 결과',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$spreadLabel · 이미지를 먼저 보고 직관으로 읽어보세요',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: RynPalette.tarotLavender,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _TarotSmallStageLabel(label: _TarotUiText.revealPrompt),
                  OutlinedButton.icon(
                    key: const Key('tarot-reveal-all-button'),
                    style: _tarotOutlinedActionStyle(),
                    onPressed: allRevealed ? null : onRevealAll,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: const Text(_TarotUiText.revealAll),
                  ),
                  FilledButton.icon(
                    key: const Key('tarot-open-interpretation-button'),
                    style: _tarotFilledActionStyle(),
                    onPressed: onInterpret,
                    icon: const Icon(Icons.menu_book_rounded, size: 18),
                    label: const Text('해석 보기'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                child: _TarotSpreadCanvas(
                  spreadLabel: spreadLabel,
                  slots: slots,
                  drawnCards: drawnCards,
                  revealedIndexes: revealedIndexes,
                  revealFxIndexes: revealFxIndexes,
                  onRevealCard: onRevealCard,
                  onDirectionToggle: onDirectionToggle,
                  showEmptySlots: false,
                  onEmptySlotTap: () {},
                  cardBack: cardBack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarotInterpretationStage extends StatelessWidget {
  const _TarotInterpretationStage({
    required this.spreadLabel,
    required this.slots,
    required this.drawnCards,
    required this.revealedIndexes,
    required this.onBackToResult,
    required this.onReset,
  });

  final String spreadLabel;
  final List<_TarotSlotSpec> slots;
  final List<_DrawnTarotCard> drawnCards;
  final Set<int> revealedIndexes;
  final VoidCallback onBackToResult;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-interpretation-stage'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment(0, -0.72),
          radius: 1.18,
          colors: [
            Color(0x66312275),
            Color(0x22151B3C),
            RynPalette.tarotNavy,
            RynPalette.tarotMidnight,
          ],
        ),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.095)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 38,
            offset: Offset(0, 22),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _TarotCosmicParticles()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const _TarotStageProgress(activeIndex: 3),
                  TextButton.icon(
                    style: _tarotTextActionStyle(),
                    onPressed: onBackToResult,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('공개로 돌아가기'),
                  ),
                  TextButton.icon(
                    style: _tarotTextActionStyle(),
                    onPressed: onReset,
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    label: const Text(UserText.tarotResetDraw),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '해석 공간',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$spreadLabel · 공개된 카드의 이름, 자리, 방향만 참고하세요',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: RynPalette.tarotLavender,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _TarotInterpretationShell(
                slots: slots,
                drawnCards: drawnCards,
                revealedIndexes: revealedIndexes,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarotInterpretationShell extends StatelessWidget {
  const _TarotInterpretationShell({
    required this.slots,
    required this.drawnCards,
    required this.revealedIndexes,
  });

  final List<_TarotSlotSpec> slots;
  final List<_DrawnTarotCard> drawnCards;
  final Set<int> revealedIndexes;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-interpretation-shell'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            RynPalette.tarotViolet.withValues(alpha: 0.24),
            RynPalette.tarotMidnight.withValues(alpha: 0.34),
          ],
        ),
        borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
        border: Border.all(color: RynPalette.tarotGold.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: RynPalette.lavenderStrong.withValues(alpha: 0.14),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories_rounded,
                size: 18,
                color: RynPalette.tarotGold,
              ),
              const SizedBox(width: 8),
              const Text(
                '해석 패널',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '카드를 펼친 뒤 이름, 자리, 방향을 확인하며 자신의 해석을 정리하세요.',
            style: TextStyle(
              color: RynPalette.tarotLavender,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < drawnCards.length; index++) ...[
            _TarotReflectionLine(
              label: index < slots.length
                  ? slots[index].label
                  : '${index + 1}번',
              card: drawnCards[index],
              revealed: revealedIndexes.contains(index),
            ),
            if (index != drawnCards.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _TarotReflectionLine extends StatelessWidget {
  const _TarotReflectionLine({
    required this.label,
    required this.card,
    required this.revealed,
  });

  final String label;
  final _DrawnTarotCard card;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final direction = card.reversed
        ? UserText.tarotReversed
        : UserText.tarotUpright;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: RynPalette.tarotGold,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            revealed ? '${card.card.label} · $direction' : '아직 펼치기 전',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: revealed ? Colors.white : RynPalette.tarotLavender,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarotDeckChoiceSection extends StatefulWidget {
  const _TarotDeckChoiceSection({
    required this.title,
    required this.decks,
    required this.selectedDeckId,
    required this.onSelected,
    required this.cardBack,
  });

  final String title;
  final List<_TarotDeckDefinition> decks;
  final String selectedDeckId;
  final ValueChanged<String> onSelected;
  final _TarotCardBackDefinition cardBack;

  @override
  State<_TarotDeckChoiceSection> createState() =>
      _TarotDeckChoiceSectionState();
}

class _TarotDeckChoiceSectionState extends State<_TarotDeckChoiceSection> {
  static const int _maxVisibleDecks = 7;
  static const int _deckFanHalf = 3;

  String? _hoveredDeckId;
  late int _centerDeckIndex;

  @override
  void initState() {
    super.initState();
    _centerDeckIndex = _selectedDeckIndex();
  }

  @override
  void didUpdateWidget(covariant _TarotDeckChoiceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDeckId != widget.selectedDeckId ||
        oldWidget.decks.length != widget.decks.length) {
      _centerDeckIndex = _selectedDeckIndex();
    }
  }

  int _selectedDeckIndex() {
    final index = widget.decks.indexWhere(
      (deck) => deck.id == widget.selectedDeckId,
    );
    return math.max(0, index);
  }

  String _deckSubtitle(_TarotDeckDefinition deck) {
    if (deck.assetBacked) return 'RWS 이미지 · ${deck.cardCount}장';
    if (deck.id == 'personal_scan') return '나만의 덱 자리';
    if (deck.id == 'oracle') return '오라클 리딩';
    if (deck.id == 'lenormand') return '레노먼드 리딩';
    return '준비된 덱 자리';
  }

  void _centerDeck(int index) {
    if (widget.decks.isEmpty) return;
    final normalized =
        ((index % widget.decks.length) + widget.decks.length) %
        widget.decks.length;
    setState(() => _centerDeckIndex = normalized);
    widget.onSelected(widget.decks[normalized].id);
  }

  List<({int deckIndex, int slot})> _visibleDeckEntries() {
    final visibleCount = math.min(_maxVisibleDecks, widget.decks.length);
    if (widget.decks.length <= _maxVisibleDecks) {
      return [
        for (var index = 0; index < widget.decks.length; index++)
          (deckIndex: index, slot: index),
      ];
    }
    return [
      for (var slot = 0; slot < visibleCount; slot++)
        (
          deckIndex:
              ((_centerDeckIndex + slot - _deckFanHalf) % widget.decks.length +
                  widget.decks.length) %
              widget.decks.length,
          slot: slot,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedDeckIndex();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title.isNotEmpty) ...[
          Text(
            widget.title,
            style: TextStyle(
              color: RynPalette.text(context),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Text(
          '큰 카드 이미지를 중심으로 오늘의 상담 덱을 고르세요.',
          style: TextStyle(
            color: RynPalette.subtext(context),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          key: const Key('tarot-jukebox-deck-stage'),
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment(0, -0.28),
              radius: 1.08,
              colors: [
                Color(0x55312275),
                Color(0x33151B3C),
                RynPalette.tarotNavy,
                RynPalette.tarotMidnight,
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: RynPalette.tarotGold.withValues(alpha: 0.18),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 30,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: KeyedSubtree(
            key: const Key('tarot-immersive-deck-stage'),
            child: SizedBox(
              key: const Key('tarot-deck-carousel'),
              height: 650,
              child: Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final visibleEntries = _visibleDeckEntries();
                        final visibleCount = visibleEntries.length;
                        final centerSlot = visibleCount >> 1;
                        final fanWidth = math.min(
                          constraints.maxWidth * 0.88,
                          1180.0,
                        );
                        final orderedEntries = [...visibleEntries]
                          ..sort((a, b) {
                            final aDistance = (a.slot - centerSlot).abs();
                            final bDistance = (b.slot - centerSlot).abs();
                            return bDistance.compareTo(aDistance);
                          });
                        return Stack(
                          key: const Key('tarot-deck-fan-carousel'),
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            for (final entry in orderedEntries)
                              _PositionedDeckFanCard(
                                deck: widget.decks[entry.deckIndex],
                                subtitle: _deckSubtitle(
                                  widget.decks[entry.deckIndex],
                                ),
                                selected:
                                    widget.decks[entry.deckIndex].id ==
                                    widget.selectedDeckId,
                                hovered:
                                    widget.decks[entry.deckIndex].id ==
                                    _hoveredDeckId,
                                slot: entry.slot,
                                centerSlot: centerSlot,
                                fanWidth: fanWidth,
                                canvasWidth: constraints.maxWidth,
                                canvasHeight: constraints.maxHeight,
                                onTap: () => _centerDeck(entry.deckIndex),
                                cardBack: widget.cardBack,
                                onHoverChanged: (hovered) {
                                  setState(() {
                                    _hoveredDeckId = hovered
                                        ? widget.decks[entry.deckIndex].id
                                        : null;
                                  });
                                },
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (widget.decks.length > 1)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _TarotDeckFanArrow(
                            key: const Key('tarot-deck-fan-left'),
                            icon: Icons.chevron_left_rounded,
                            onPressed: () => _centerDeck(_centerDeckIndex - 1),
                          ),
                          const SizedBox(width: 14),
                          for (
                            var index = 0;
                            index < widget.decks.length;
                            index++
                          )
                            AnimatedContainer(
                              key: Key('tarot-deck-fan-dot-$index'),
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: index == selectedIndex ? 10 : 7,
                              height: index == selectedIndex ? 10 : 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == selectedIndex
                                    ? RynPalette.tarotGold
                                    : RynPalette.subtext(
                                        context,
                                      ).withValues(alpha: 0.25),
                              ),
                            ),
                          const SizedBox(width: 14),
                          _TarotDeckFanArrow(
                            key: const Key('tarot-deck-fan-right'),
                            icon: Icons.chevron_right_rounded,
                            onPressed: () => _centerDeck(_centerDeckIndex + 1),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PositionedDeckFanCard extends StatelessWidget {
  const _PositionedDeckFanCard({
    required this.deck,
    required this.subtitle,
    required this.selected,
    required this.hovered,
    required this.slot,
    required this.centerSlot,
    required this.fanWidth,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.onTap,
    required this.onHoverChanged,
    required this.cardBack,
  });

  final _TarotDeckDefinition deck;
  final String subtitle;
  final bool selected;
  final bool hovered;
  final int slot;
  final int centerSlot;
  final double fanWidth;
  final double canvasWidth;
  final double canvasHeight;
  final VoidCallback onTap;
  final ValueChanged<bool> onHoverChanged;
  final _TarotCardBackDefinition cardBack;

  @override
  Widget build(BuildContext context) {
    final distance = slot - centerSlot;
    final normalized = centerSlot == 0 ? 0.0 : distance / centerSlot;
    final slotDistance = distance.abs();
    final cardWidth = selected
        ? 366.0
        : slotDistance == 1
        ? 292.0
        : slotDistance == 2
        ? 238.0
        : 190.0;
    final x = canvasWidth / 2 + normalized * fanWidth / 2 - cardWidth / 2;
    final y = selected ? 18.0 : 40.0 + slotDistance * slotDistance * 10.0;
    return Positioned(
      left: x.clamp(8.0, math.max(8.0, canvasWidth - cardWidth - 8)),
      top: y.clamp(4.0, math.max(4.0, canvasHeight - 232.0)),
      width: cardWidth,
      child: _TarotDeckCarouselCard(
        key: ValueKey('tarot-deck-fan-slot-$slot-${deck.id}'),
        deck: deck,
        subtitle: subtitle,
        selected: selected,
        hovered: hovered,
        distanceFromSelected: distance,
        onTap: onTap,
        onHoverChanged: onHoverChanged,
        cardBack: cardBack,
      ),
    );
  }
}

class _TarotSelectedDeckCardGlow extends StatelessWidget {
  const _TarotSelectedDeckCardGlow({
    required this.selected,
    required this.hovered,
    required this.child,
  });

  final bool selected;
  final bool hovered;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!selected) return child;
    return DecoratedBox(
      key: const Key('tarot-selected-card-edge-glow'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: RynPalette.tarotGold.withValues(alpha: hovered ? 0.92 : 0.68),
          width: hovered ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: RynPalette.tarotGold.withValues(
              alpha: hovered ? 0.34 : 0.24,
            ),
            blurRadius: hovered ? 28 : 22,
            spreadRadius: 1.2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 26,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TarotDeckFanArrow extends StatelessWidget {
  const _TarotDeckFanArrow({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        foregroundColor: Colors.white,
        side: BorderSide(color: RynPalette.tarotGold.withValues(alpha: 0.24)),
        shadowColor: Colors.black.withValues(alpha: 0.18),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: icon == Icons.chevron_left_rounded ? '이전 덱' : '다음 덱',
    );
  }
}

class _TarotDeckCarouselCard extends StatelessWidget {
  const _TarotDeckCarouselCard({
    super.key,
    required this.deck,
    required this.subtitle,
    required this.selected,
    required this.hovered,
    required this.distanceFromSelected,
    required this.onTap,
    required this.onHoverChanged,
    required this.cardBack,
  });

  final _TarotDeckDefinition deck;
  final String subtitle;
  final bool selected;
  final bool hovered;
  final int distanceFromSelected;
  final VoidCallback onTap;
  final ValueChanged<bool> onHoverChanged;
  final _TarotCardBackDefinition cardBack;

  @override
  Widget build(BuildContext context) {
    final distance = distanceFromSelected.clamp(-3, 3);
    final absDistance = distance.abs();
    final near = absDistance == 1;
    final side = absDistance == 2;
    final far = absDistance >= 3;
    final tilt = selected ? 0.0 : distance * 0.095;
    final lift = selected
        ? -18.0
        : hovered
        ? -10.0
        : near
        ? 14.0
        : side
        ? 42.0
        : 72.0;
    final width = selected
        ? 326.0
        : near
        ? 250.0
        : side
        ? 202.0
        : 160.0;
    final cardImageWidth = selected
        ? 236.0
        : near
        ? 168.0
        : side
        ? 130.0
        : 98.0;
    final cardImageHeight = cardImageWidth * 1.535;
    final glowColor = selected
        ? RynPalette.tarotGold.withValues(alpha: 0.30)
        : RynPalette.lavenderStrong.withValues(
            alpha: hovered
                ? 0.18
                : near
                ? 0.08
                : 0.04,
          );

    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: width,
        key: selected ? const Key('tarot-coverflow-hero-card') : null,
        padding: EdgeInsets.fromLTRB(
          selected ? 8 : 5,
          selected ? 10 : 8,
          selected ? 8 : 5,
          selected ? 8 : 7,
        ),
        transform: Matrix4.identity()
          ..translateByDouble(0.0, lift, 0.0, 1.0)
          ..rotateZ(tilt),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? Colors.transparent
              : Colors.black.withValues(alpha: far ? 0.18 : 0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: glowColor,
              blurRadius: selected
                  ? 24
                  : near
                  ? 20
                  : 14,
              spreadRadius: selected ? 0 : 0,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.18 : 0.10),
              blurRadius: selected ? 28 : 18,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('tarot-deck-carousel-card-${deck.id}'),
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KeyedSubtree(
                    key: selected
                        ? const Key('tarot-jukebox-center-card')
                        : near
                        ? Key('tarot-coverflow-near-card-${deck.id}')
                        : side
                        ? Key('tarot-coverflow-side-card-${deck.id}')
                        : Key('tarot-coverflow-far-card-${deck.id}'),
                    child: _TarotSelectedDeckCardGlow(
                      selected: selected,
                      hovered: hovered,
                      child: _TarotCardBack(
                        compact: false,
                        glowing: selected || hovered,
                        assetPath: cardBack.assetPath,
                        width: cardImageWidth,
                        height: cardImageHeight,
                      ),
                    ),
                  ),
                  SizedBox(height: selected ? 18 : 10),
                  Text(
                    deck.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? Colors.white : RynPalette.tarotLavender,
                      fontSize: selected ? 15 : 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected
                          ? RynPalette.tarotGold
                          : RynPalette.subtext(context),
                      fontSize: selected ? 11 : 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TarotCardBackChoiceSection extends StatelessWidget {
  const _TarotCardBackChoiceSection({
    required this.cardBacks,
    required this.selectedCardBackId,
    required this.onSelected,
  });

  final List<_TarotCardBackDefinition> cardBacks;
  final String selectedCardBackId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RynPalette.surfaceElevated(context),
        borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
        border: Border.all(color: RynPalette.line(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카드 뒷면 선택',
            style: TextStyle(
              color: RynPalette.text(context),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '드로우와 결과 공개 전 카드에 사용할 이미지를 고르세요.',
            style: TextStyle(
              color: RynPalette.subtext(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final cardBack in cardBacks)
                _TarotCardBackOption(
                  cardBack: cardBack,
                  selected: cardBack.id == selectedCardBackId,
                  onTap: () => onSelected(cardBack.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarotCardBackOption extends StatelessWidget {
  const _TarotCardBackOption({
    required this.cardBack,
    required this.selected,
    required this.onTap,
  });

  final _TarotCardBackDefinition cardBack;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 146,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: selected
            ? RynPalette.tarotViolet.withValues(alpha: 0.18)
            : RynPalette.surfaceSoft(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? RynPalette.tarotGold.withValues(alpha: 0.86)
              : RynPalette.line(context),
          width: selected ? 1.4 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: RynPalette.tarotGold.withValues(alpha: 0.20),
                  blurRadius: 22,
                  spreadRadius: 1,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('tarot-card-back-option-${cardBack.id}'),
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TarotCardBack(
                compact: true,
                glowing: selected,
                assetPath: cardBack.assetPath,
              ),
              const SizedBox(height: 10),
              Text(
                cardBack.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? RynPalette.tarotGold
                      : RynPalette.text(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarotSpreadChoiceSection extends StatelessWidget {
  const _TarotSpreadChoiceSection({
    required this.title,
    required this.freeSpreads,
    required this.fixedSpreads,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<_TarotSpreadDefinition> freeSpreads;
  final List<_TarotSpreadDefinition> fixedSpreads;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: RynPalette.text(context),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        _TarotSpreadGroup(
          label: UserText.tarotSpreadGroupFree,
          spreads: freeSpreads,
          selected: selected,
          onSelected: onSelected,
        ),
        const SizedBox(height: 10),
        _TarotSpreadGroup(
          label: UserText.tarotSpreadGroupFixed,
          spreads: fixedSpreads,
          selected: selected,
          onSelected: onSelected,
        ),
      ],
    );
  }
}

class _TarotSpreadGroup extends StatelessWidget {
  const _TarotSpreadGroup({
    required this.label,
    required this.spreads,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<_TarotSpreadDefinition> spreads;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: RynPalette.subtext(context),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 7),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final spread in spreads)
              ChoiceChip(
                label: Text(spread.label),
                selected: spread.label == selected,
                onSelected: (_) => onSelected(spread.label),
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: spread.label == selected
                      ? RynPalette.iconOnAccent(context)
                      : RynPalette.text(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                selectedColor: RynPalette.accent(context),
                backgroundColor: RynPalette.surfaceElevated(context),
                side: BorderSide(color: RynPalette.line(context)),
              ),
          ],
        ),
      ],
    );
  }
}

class _TarotDirectionChoiceSection extends StatelessWidget {
  const _TarotDirectionChoiceSection({
    required this.selected,
    required this.onSelected,
  });

  final _TarotDirectionMode selected;
  final ValueChanged<_TarotDirectionMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _TarotUiText.directionMode,
          style: TextStyle(
            color: RynPalette.text(context),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<_TarotDirectionMode>(
          segments: const [
            ButtonSegment(
              value: _TarotDirectionMode.uprightOnly,
              label: Text(_TarotUiText.uprightOnly),
              icon: Icon(Icons.vertical_align_top_rounded, size: 16),
            ),
            ButtonSegment(
              value: _TarotDirectionMode.auto,
              label: Text(_TarotUiText.autoDirection),
              icon: Icon(Icons.sync_alt_rounded, size: 16),
            ),
          ],
          selected: {selected},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => onSelected(selection.first),
        ),
      ],
    );
  }
}

class _TarotSelectionSummary extends StatelessWidget {
  const _TarotSelectionSummary({required this.deck, required this.spread});

  final _TarotDeckDefinition deck;
  final String spread;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RynPalette.surfaceSoft(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RynPalette.line(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            UserText.tarotCurrentSelection,
            style: TextStyle(
              color: RynPalette.subtext(context),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${deck.label} · $spread',
            style: TextStyle(
              color: RynPalette.text(context),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShuffleDeckStack extends StatelessWidget {
  const _ShuffleDeckStack({
    required this.isShuffling,
    required this.onTap,
    required this.cardBack,
    this.large = false,
  });

  final bool isShuffling;
  final VoidCallback onTap;
  final _TarotCardBackDefinition cardBack;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isShuffling ? null : onTap,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(isShuffling),
        tween: Tween(begin: 0, end: isShuffling ? 1 : 0),
        duration: const Duration(milliseconds: 720),
        curve: Curves.easeInOutCubic,
        builder: (context, value, child) {
          final shake = math.sin(value * math.pi * 8) * 0.08;
          final scale = 1 + math.sin(value * math.pi) * 0.05;
          return Transform.rotate(
            angle: shake,
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: SizedBox(
          key: const Key('tarot-shuffle-stack'),
          width: large ? 340 : 116,
          height: large ? 460 : 156,
          child:
              Stack(
                    alignment: Alignment.center,
                    children: [
                      for (var index = 5; index >= 0; index--)
                        Positioned(
                          left: large ? 48 + index * 8 : 14 + index * 3,
                          top: large ? 28 + index * 7 : 10 + index * 3,
                          child: Opacity(
                            opacity: 0.48 + index * 0.08,
                            child: Transform.translate(
                              offset: isShuffling && large
                                  ? Offset(
                                      (index.isEven ? -1 : 1) *
                                          math.sin(index + 1) *
                                          8,
                                      -math.sin(index + 1) * 4,
                                    )
                                  : Offset.zero,
                              child: Transform.rotate(
                                angle: isShuffling && large
                                    ? (index - 2.5) * 0.018
                                    : (index - 2.5) * 0.006,
                                child: _TarotCardBack(
                                  compact: false,
                                  glowing: isShuffling || index == 0,
                                  assetPath: cardBack.assetPath,
                                  width: large ? 218 : null,
                                  height: large ? 334 : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (isShuffling)
                        const Positioned.fill(
                          child: _TarotFxBurst(
                            particleCount: 10,
                            origin: Offset(0.5, 0.48),
                          ),
                        ),
                    ],
                  )
                  .animate(target: isShuffling ? 1 : 0)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.05, 1.05),
                    duration: 360.ms,
                    curve: Curves.easeOutCubic,
                  ),
        ),
      ),
    );
  }
}

class _TarotCardBackChoice extends StatelessWidget {
  const _TarotCardBackChoice({
    required this.onTap,
    this.compact = false,
    this.glowing = false,
    this.assetPath = _TarotCardBack.defaultAssetPath,
  });

  final VoidCallback onTap;
  final bool compact;
  final bool glowing;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('tarot-card-back-choice'),
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: _TarotCardBack(
          compact: compact,
          glowing: glowing,
          assetPath: assetPath,
        ),
      ),
    );
  }
}

class _TarotCardBack extends StatelessWidget {
  const _TarotCardBack({
    this.compact = false,
    this.glowing = false,
    this.assetPath = defaultAssetPath,
    this.width,
    this.height,
  });

  static const defaultAssetPath =
      'assets/tarot/card_backs/ryn_cosmic_gate_back_v1.png';

  final bool compact;
  final bool glowing;
  final String assetPath;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final accent = RynPalette.tarotGold;
    final displayWidth = width ?? (compact ? 58.0 : 86.0);
    final displayHeight = height ?? (compact ? 87.0 : 132.0);
    return AnimatedContainer(
      key: const Key('tarot-card-back'),
      duration: const Duration(milliseconds: 220),
      width: displayWidth,
      height: displayHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RynPalette.tarotViolet, RynPalette.tarotNavy],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: accent.withValues(alpha: glowing ? 0.92 : 0.58),
        ),
        boxShadow: [
          const BoxShadow(
            color: Color(0x99000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
          if (glowing)
            BoxShadow(
              color: accent.withValues(alpha: 0.46),
              blurRadius: compact ? 22 : 32,
              spreadRadius: 2,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Shimmer.fromColors(
          enabled: compact || glowing,
          loop: 1,
          period: const Duration(milliseconds: 1800),
          baseColor: RynPalette.tarotLavender.withValues(alpha: 0.08),
          highlightColor: Colors.white.withValues(alpha: glowing ? 0.42 : 0.22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                assetPath,
                key: const Key('tarot-card-back-image'),
                fit: BoxFit.cover,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: glowing ? 0.16 : 0.04),
                      Colors.transparent,
                      accent.withValues(alpha: glowing ? 0.18 : 0.06),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarotFxBurst extends StatelessWidget {
  const _TarotFxBurst({
    this.particleCount = 8,
    this.origin = const Offset(0.5, 0.5),
  });

  final int particleCount;
  final Offset origin;

  @override
  Widget build(BuildContext context) {
    final accent = RynPalette.accent(context);
    return IgnorePointer(
      child: Newton(
        effectConfigurations: [
          ExplosionPreset(
            colors: [
              accent.withValues(alpha: 0.62),
              RynPalette.lavenderStrong.withValues(alpha: 0.52),
              Colors.white.withValues(alpha: 0.5),
            ],
            particleCount: particleCount,
            particlesPerEmit: particleCount,
            origin: origin,
            gravity: Gravity.zero,
          ).toConfiguration(),
        ],
      ),
    );
  }
}

class _TarotRevealReadyFrame extends StatelessWidget {
  const _TarotRevealReadyFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(duration: 180.ms, curve: Curves.easeOutCubic)
        .scale(
          begin: const Offset(0.985, 0.985),
          end: const Offset(1, 1),
          duration: 220.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class _TarotSpreadCanvas extends StatelessWidget {
  const _TarotSpreadCanvas({
    required this.spreadLabel,
    required this.slots,
    required this.drawnCards,
    required this.revealedIndexes,
    required this.revealFxIndexes,
    required this.onRevealCard,
    required this.onDirectionToggle,
    required this.onEmptySlotTap,
    required this.cardBack,
    this.showEmptySlots = true,
  });

  final String spreadLabel;
  final List<_TarotSlotSpec> slots;
  final List<_DrawnTarotCard> drawnCards;
  final Set<int> revealedIndexes;
  final Set<int> revealFxIndexes;
  final ValueChanged<int> onRevealCard;
  final ValueChanged<int> onDirectionToggle;
  final VoidCallback onEmptySlotTap;
  final _TarotCardBackDefinition cardBack;
  final bool showEmptySlots;

  @override
  Widget build(BuildContext context) {
    final canvasHeight = _canvasHeightForSlots(slots.length);
    return Container(
      key: Key('tarot-result-layout-${slots.length}'),
      height: canvasHeight,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF090D1F), Color(0xFF151B3C), Color(0xFF211747)],
        ),
        borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
        border: Border.all(color: RynPalette.tarotGold.withValues(alpha: 0.13)),
        boxShadow: [
          BoxShadow(
            color: RynPalette.lavenderStrong.withValues(alpha: 0.13),
            blurRadius: 38,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.22),
                  radius: 0.96,
                  colors: [
                    RynPalette.lavenderStrong.withValues(alpha: 0.12),
                    const Color(0xFF070A18),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardSize = _cardSizeForLayout(
                    slots.length,
                    constraints,
                  );
                  const labelHeight = 36.0;
                  final slotHeight = cardSize.height + labelHeight;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      for (var index = 0; index < slots.length; index++)
                        Positioned(
                          key: Key('tarot-result-slot-${slots.length}-$index'),
                          left:
                              (constraints.maxWidth - cardSize.width) *
                              slots[index].xRatio,
                          top:
                              (constraints.maxHeight - slotHeight) *
                              slots[index].yRatio,
                          width: cardSize.width,
                          height: slotHeight,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _TarotPositionLabel(label: slots[index].label),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: cardSize.width,
                                height: cardSize.height,
                                child: index < drawnCards.length
                                    ? _TarotDrawnCardView(
                                        drawnCard: drawnCards[index],
                                        index: index,
                                        revealed: revealedIndexes.contains(
                                          index,
                                        ),
                                        showRevealFx: revealFxIndexes.contains(
                                          index,
                                        ),
                                        onReveal: () => onRevealCard(index),
                                        onDirectionToggle: onDirectionToggle,
                                        cardBack: cardBack,
                                      )
                                    : showEmptySlots
                                    ? _TarotEmptySlot(
                                        label: slots[index].label,
                                        onTap: onEmptySlotTap,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double _canvasHeightForSlots(int count) {
  if (count == 1) return 620;
  if (count <= 3) return 620;
  if (count <= 4) return 520;
  if (count <= 6) return 620;
  return 720;
}

Size _cardSizeForLayout(int count, BoxConstraints constraints) {
  final maxWidth = constraints.maxWidth;
  final maxHeight = constraints.maxHeight;
  const labelAllowance = 34.0;
  final preferredWidth = switch (count) {
    1 => 320.0,
    <= 3 => 230.0,
    4 => 180.0,
    5 => 168.0,
    6 => 158.0,
    _ => 104.0,
  };
  final horizontalSlots = switch (count) {
    1 => 1.25,
    <= 3 => 3.15,
    4 => 4.4,
    5 => 5.1,
    6 => 5.2,
    _ => 7.0,
  };
  final verticalSlots = switch (count) {
    1 => 1.15,
    <= 3 => 1.28,
    4 => 1.35,
    5 => 2.15,
    6 => 2.2,
    _ => 3.4,
  };
  final widthLimit = maxWidth / horizontalSlots;
  final heightLimit = ((maxHeight / verticalSlots) - labelAllowance) / 1.62;
  final width = math.max(
    72.0,
    math.min(preferredWidth, math.min(widthLimit, heightLimit)),
  );
  return Size(width, width * 1.62);
}

class _TarotPositionLabel extends StatelessWidget {
  const _TarotPositionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-position-label'),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: RynPalette.tarotViolet.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
        border: Border.all(color: RynPalette.tarotGold.withValues(alpha: 0.32)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: RynPalette.tarotLavender,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

class _TarotEmptySlot extends StatelessWidget {
  const _TarotEmptySlot({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          key: const Key('tarot-empty-slot'),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: RynPalette.surfaceSoft(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RynPalette.line(context)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                color: RynPalette.accent(context),
                size: 22,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: RynPalette.text(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                UserText.tarotEmptySlot,
                style: TextStyle(
                  color: RynPalette.subtext(context),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarotDrawnCardView extends StatelessWidget {
  const _TarotDrawnCardView({
    required this.drawnCard,
    required this.index,
    required this.revealed,
    required this.showRevealFx,
    required this.onReveal,
    required this.onDirectionToggle,
    required this.cardBack,
  });

  final _DrawnTarotCard drawnCard;
  final int index;
  final bool revealed;
  final bool showRevealFx;
  final VoidCallback onReveal;
  final ValueChanged<int> onDirectionToggle;
  final _TarotCardBackDefinition cardBack;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('tarot-drawn-card'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          const BoxShadow(
            color: Color(0x88000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
          if (revealed || showRevealFx)
            BoxShadow(
              color: RynPalette.accent(context).withValues(alpha: 0.18),
              blurRadius: 22,
              spreadRadius: 1,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _TarotFlipRevealFrame(
              revealed: revealed,
              back: _TarotUnrevealedResultCard(
                onReveal: onReveal,
                cardBack: cardBack,
              ),
              front: _TarotRevealedCardFace(drawnCard: drawnCard),
            ),
            if (showRevealFx)
              const Positioned.fill(child: _TarotFxBurst(particleCount: 8)),
          ],
        ),
      ),
    );
  }
}

class _TarotUnrevealedResultCard extends StatelessWidget {
  const _TarotUnrevealedResultCard({
    required this.onReveal,
    required this.cardBack,
  });

  final VoidCallback onReveal;
  final _TarotCardBackDefinition cardBack;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('tarot-result-card-back-slot'),
        borderRadius: BorderRadius.circular(4),
        onTap: onReveal,
        child: _TarotFullSlotCardBack(
          glowing: true,
          assetPath: cardBack.assetPath,
        ),
      ),
    ).animate().shimmer(
      duration: 1600.ms,
      color: Colors.white.withValues(alpha: 0.16),
    );
  }
}

class _TarotFullSlotCardBack extends StatelessWidget {
  const _TarotFullSlotCardBack({
    this.glowing = false,
    this.assetPath = _TarotCardBack.defaultAssetPath,
  });

  final bool glowing;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RynPalette.tarotViolet, RynPalette.tarotNavy],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: RynPalette.tarotGold.withValues(alpha: glowing ? 0.96 : 0.58),
          width: glowing ? 1.4 : 1,
        ),
        boxShadow: glowing
            ? [
                BoxShadow(
                  color: RynPalette.tarotGold.withValues(alpha: 0.24),
                  blurRadius: 28,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: RynPalette.lavenderStrong.withValues(alpha: 0.18),
                  blurRadius: 34,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              assetPath,
              key: const Key('tarot-card-back-image'),
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: glowing ? 0.16 : 0.04),
                    Colors.transparent,
                    RynPalette.tarotGold.withValues(
                      alpha: glowing ? 0.18 : 0.06,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarotRevealedCardFace extends StatelessWidget {
  const _TarotRevealedCardFace({required this.drawnCard});

  final _DrawnTarotCard drawnCard;

  @override
  Widget build(BuildContext context) {
    final orientation = drawnCard.reversed
        ? UserText.tarotReversed
        : UserText.tarotUpright;
    return Tooltip(
      message:
          '${drawnCard.card.label} · $orientation · ${_TarotUiText.changeDirection}',
      child: _TarotRevealReadyFrame(
        child: AnimatedRotation(
          turns: drawnCard.reversed ? 0.5 : 0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: Image.asset(
            drawnCard.card.imagePath,
            key: const Key('tarot-rws-card-image'),
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}

class _TarotFlipRevealFrame extends StatelessWidget {
  const _TarotFlipRevealFrame({
    required this.revealed,
    required this.back,
    required this.front,
  });

  final bool revealed;
  final Widget back;
  final Widget front;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, child) {
            final value = animation.value;
            final angle = (1 - value) * math.pi / 2;
            return Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: child,
              ),
            );
          },
        );
      },
      child: KeyedSubtree(
        key: ValueKey(revealed ? 'front' : 'back'),
        child: revealed ? front : back,
      ),
    );
  }
}

class _TarotMemoPanel extends StatelessWidget {
  const _TarotMemoPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RynPalette.surfaceElevated(context),
        borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
        border: Border.all(color: RynPalette.line(context)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TarotMemoLine(
            title: UserText.tarotQuestion,
            hint: UserText.tarotQuestionHint,
          ),
          SizedBox(height: 12),
          _TarotMemoLine(
            title: UserText.tarotKeywords,
            hint: UserText.tarotKeywordsHint,
          ),
          SizedBox(height: 12),
          _TarotMemoLine(
            title: UserText.tarotMemo,
            hint: UserText.tarotMemoHint,
            tall: true,
          ),
        ],
      ),
    );
  }
}

class _TarotMemoLine extends StatelessWidget {
  const _TarotMemoLine({
    required this.title,
    required this.hint,
    this.tall = false,
  });

  final String title;
  final String hint;
  final bool tall;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: RynPalette.text(context),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: tall ? 96 : 42),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RynPalette.surfaceSoft(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: RynPalette.line(context)),
            ),
            child: Text(
              hint,
              style: TextStyle(
                color: RynPalette.subtext(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TarotSmallBadge extends StatelessWidget {
  const _TarotSmallBadge(this.label, {this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: RynPalette.accentSoft(context).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
        border: Border.all(color: RynPalette.line(context)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: RynPalette.text(context),
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TarotCardBackDefinition {
  const _TarotCardBackDefinition({
    required this.id,
    required this.label,
    required this.assetPath,
  });

  final String id;
  final String label;
  final String assetPath;
}

class _TarotDeckDefinition {
  const _TarotDeckDefinition({
    required this.id,
    required this.label,
    this.cardCount = 0,
    this.assetBacked = false,
  });

  final String id;
  final String label;
  final int cardCount;
  final bool assetBacked;
}

class _TarotSpreadDefinition {
  const _TarotSpreadDefinition(this.label, this.slots);

  final String label;
  final List<_TarotSlotSpec> slots;

  int get cardCount => slots.length;
}

class _TarotCardDefinition {
  const _TarotCardDefinition(this.id, this.label, this.imagePath);

  final String id;
  final String label;
  final String imagePath;
}

class _DrawnTarotCard {
  const _DrawnTarotCard({required this.card, required this.reversed});

  final _TarotCardDefinition card;
  final bool reversed;
}

class _TarotSlotSpec {
  const _TarotSlotSpec(this.label, this.xRatio, this.yRatio);

  final String label;
  final double xRatio;
  final double yRatio;

  _TarotSlotSpec copyWith({String? label}) =>
      _TarotSlotSpec(label ?? this.label, xRatio, yRatio);
}

const _tarotSpreadOneSlots = [_TarotSlotSpec('핵심', 0.5, 0.5)];

const _tarotSpreadThreeSlots = [
  _TarotSlotSpec('과거', 0.14, 0.5),
  _TarotSlotSpec('현재', 0.5, 0.5),
  _TarotSlotSpec('미래', 0.86, 0.5),
];

const _tarotSpreadFourSlots = [
  _TarotSlotSpec('기반', 0.05, 0.5),
  _TarotSlotSpec('현재', 0.35, 0.5),
  _TarotSlotSpec('조언', 0.65, 0.5),
  _TarotSlotSpec('흐름', 0.95, 0.5),
];

const _tarotSpreadFiveSlots = [
  _TarotSlotSpec('원인', 0.06, 0.40),
  _TarotSlotSpec('현재', 0.27, 0.60),
  _TarotSlotSpec('조언', 0.50, 0.34),
  _TarotSlotSpec('가능성', 0.73, 0.60),
  _TarotSlotSpec('결과', 0.94, 0.40),
];

const _tarotSpreadCelticSlots = [
  _TarotSlotSpec('현재', 0.27, 0.50),
  _TarotSlotSpec('도전', 0.42, 0.50),
  _TarotSlotSpec('기반', 0.35, 0.78),
  _TarotSlotSpec('과거', 0.10, 0.50),
  _TarotSlotSpec('목표', 0.35, 0.20),
  _TarotSlotSpec('미래', 0.60, 0.50),
  _TarotSlotSpec('자아', 0.78, 0.96),
  _TarotSlotSpec('환경', 0.92, 0.65),
  _TarotSlotSpec('희망·두려움', 0.78, 0.34),
  _TarotSlotSpec('결과', 0.92, 0.03),
];

const _tarotSpreadBinarySlots = [
  _TarotSlotSpec('현재', 0.50, 0.56),
  _TarotSlotSpec('A 과정', 0.12, 0.30),
  _TarotSlotSpec('A 결과', 0.28, 0.66),
  _TarotSlotSpec('B 과정', 0.88, 0.30),
  _TarotSlotSpec('B 결과', 0.72, 0.66),
];
