import 'dart:math' as math;

import 'package:flutter/material.dart';
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

enum _TarotFlowStage { setup, draw, result }

class _TarotUiText {
  const _TarotUiText._();

  static const shuffle = '셔플하기';
  static const shuffling = '카드를 섞고 있습니다';
  static const prepare = '준비하기';
  static const showResult = '결과 보기';
}

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

  static const _spreadDefinitions = [
    _TarotSpreadDefinition(UserText.tarotSpreadOne, _tarotSpreadOneSlots),
    _TarotSpreadDefinition(UserText.tarotSpreadThree, _tarotSpreadThreeSlots),
    _TarotSpreadDefinition(UserText.tarotSpreadFour, _tarotSpreadFourSlots),
    _TarotSpreadDefinition(UserText.tarotSpreadFive, _tarotSpreadFiveSlots),
    _TarotSpreadDefinition(UserText.tarotSpreadCeltic, _tarotSpreadCelticSlots),
    _TarotSpreadDefinition(UserText.tarotSpreadBinary, _tarotSpreadBinarySlots),
    _TarotSpreadDefinition(
      UserText.tarotSpreadRelation,
      _tarotSpreadRelationSlots,
    ),
    _TarotSpreadDefinition(UserText.tarotSpreadIssue, _tarotSpreadIssueSlots),
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
  String _selectedSpread = UserText.tarotSpreadThree;
  late List<_TarotCardDefinition> _remainingDeck;
  final List<_DrawnTarotCard> _drawnCards = [];
  final Set<int> _selectedDeckIndexes = {};
  _TarotDrawPhase _phase = _TarotDrawPhase.beforeShuffle;
  _TarotFlowStage _stage = _TarotFlowStage.setup;

  @override
  void initState() {
    super.initState();
    _prepareFreshDeck(clearDrawn: true);
  }

  _TarotDeckDefinition get _selectedDeck => _deckDefinitions.firstWhere(
    (deck) => deck.id == _selectedDeckId,
    orElse: () => _deckDefinitions.first,
  );

  _TarotSpreadDefinition get _selectedSpreadDefinition =>
      _spreadDefinitions.firstWhere(
        (spread) => spread.label == _selectedSpread,
        orElse: () => _spreadDefinitions[1],
      );

  List<_TarotSlotSpec> get _slots => _selectedSpreadDefinition.slots;

  bool get _isComplete => _drawnCards.length >= _slots.length;

  void _prepareFreshDeck({required bool clearDrawn}) {
    _remainingDeck = List<_TarotCardDefinition>.of(_rwsCards)
      ..shuffle(math.Random());
    if (clearDrawn) {
      _drawnCards.clear();
      _selectedDeckIndexes.clear();
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
        _DrawnTarotCard(card: card, reversed: _drawnCards.length.isOdd),
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
          _DrawnTarotCard(card: card, reversed: _drawnCards.length.isOdd),
        );
      }
      _phase = _isComplete ? _TarotDrawPhase.complete : _TarotDrawPhase.ready;
      if (_isComplete) _stage = _TarotFlowStage.result;
    });
  }

  void _showResult() {
    if (!_isComplete) return;
    setState(() => _stage = _TarotFlowStage.result);
  }

  void _selectSpread(String spread) {
    setState(() {
      _selectedSpread = spread;
      _prepareFreshDeck(clearDrawn: true);
      _phase = _TarotDrawPhase.beforeShuffle;
      _stage = _TarotFlowStage.setup;
    });
  }

  void _selectDeck(String deckId) {
    setState(() {
      _selectedDeckId = deckId;
      _prepareFreshDeck(clearDrawn: true);
      _phase = _TarotDrawPhase.beforeShuffle;
      _stage = _TarotFlowStage.setup;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _TarotShellCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 18),
          if (_stage == _TarotFlowStage.setup)
            _TarotSetupStage(
              decks: _deckDefinitions,
              selectedDeckId: _selectedDeckId,
              onDeckSelected: _selectDeck,
              spreads: _spreadDefinitions,
              selectedSpread: _selectedSpread,
              onSpreadSelected: _selectSpread,
              selectedDeck: _selectedDeck,
              onShuffle: _startShuffle,
              onAutoDraw: _drawAll,
              isShuffling: _phase == _TarotDrawPhase.shuffling,
            )
          else if (_stage == _TarotFlowStage.draw)
            _TarotFullDeckDrawStage(
              deck: _selectedDeck,
              spread: _selectedSpread,
              cards: _remainingDeck,
              selectedIndexes: _selectedDeckIndexes,
              selectedCount: _drawnCards.length,
              targetCount: _slots.length,
              isShuffling: _phase == _TarotDrawPhase.shuffling,
              onSelected: _drawOneFromFan,
              onAutoDraw: _drawAll,
              onShowResult: _showResult,
              onReset: _resetDraw,
            )
          else
            _TarotResultStage(
              spreadLabel: _selectedSpread,
              slots: _slots,
              drawnCards: _drawnCards,
              onReset: _resetDraw,
            ),
        ],
      ),
    );
  }
}

class _TarotSetupStage extends StatelessWidget {
  const _TarotSetupStage({
    required this.decks,
    required this.selectedDeckId,
    required this.onDeckSelected,
    required this.spreads,
    required this.selectedSpread,
    required this.onSpreadSelected,
    required this.selectedDeck,
    required this.onShuffle,
    required this.onAutoDraw,
    required this.isShuffling,
  });

  final List<_TarotDeckDefinition> decks;
  final String selectedDeckId;
  final ValueChanged<String> onDeckSelected;
  final List<_TarotSpreadDefinition> spreads;
  final String selectedSpread;
  final ValueChanged<String> onSpreadSelected;
  final _TarotDeckDefinition selectedDeck;
  final VoidCallback onShuffle;
  final VoidCallback onAutoDraw;
  final bool isShuffling;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TarotSmallStageLabel(label: _TarotUiText.prepare),
        const SizedBox(height: 12),
        _TarotDeckChoiceSection(
          title: UserText.tarotDeckSelect,
          decks: decks,
          selectedDeckId: selectedDeckId,
          onSelected: onDeckSelected,
        ),
        const SizedBox(height: 14),
        _TarotChoiceSection(
          title: UserText.tarotSpreadSelect,
          options: [for (final spread in spreads) spread.label],
          selected: selectedSpread,
          onSelected: onSpreadSelected,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 960;
            final preparation = _TarotPreparationPanel(
              selectedDeck: selectedDeck,
              selectedSpread: selectedSpread,
              isShuffling: isShuffling,
              onShuffle: onShuffle,
              onAutoDraw: onAutoDraw,
            );
            final memo = const _TarotMemoPanel();
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: preparation),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: memo),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [preparation, const SizedBox(height: 16), memo],
            );
          },
        ),
      ],
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

class _TarotPreparationPanel extends StatelessWidget {
  const _TarotPreparationPanel({
    required this.selectedDeck,
    required this.selectedSpread,
    required this.isShuffling,
    required this.onShuffle,
    required this.onAutoDraw,
  });

  final _TarotDeckDefinition selectedDeck;
  final String selectedSpread;
  final bool isShuffling;
  final VoidCallback onShuffle;
  final VoidCallback onAutoDraw;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RynPalette.surfaceElevated(context),
        borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
        border: Border.all(color: RynPalette.line(context)),
        boxShadow: RynPalette.panelShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TarotSelectionSummary(deck: selectedDeck, spread: selectedSpread),
          const SizedBox(height: 18),
          Center(
            child: _ShuffleDeckStack(
              isShuffling: isShuffling,
              onTap: onShuffle,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('tarot-shuffle-button'),
            onPressed: isShuffling ? null : onShuffle,
            icon: const Icon(Icons.shuffle_rounded, size: 18),
            label: Text(
              isShuffling ? _TarotUiText.shuffling : _TarotUiText.shuffle,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: isShuffling ? null : onAutoDraw,
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Text(UserText.tarotAutoDraw),
          ),
        ],
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
    required this.selectedCount,
    required this.targetCount,
    required this.isShuffling,
    required this.onSelected,
    required this.onAutoDraw,
    required this.onShowResult,
    required this.onReset,
  });

  final _TarotDeckDefinition deck;
  final String spread;
  final List<_TarotCardDefinition> cards;
  final Set<int> selectedIndexes;
  final int selectedCount;
  final int targetCount;
  final bool isShuffling;
  final ValueChanged<int> onSelected;
  final VoidCallback onAutoDraw;
  final VoidCallback onShowResult;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final remainingToSelect = math.max(0, targetCount - selectedCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TarotSmallStageLabel(label: UserText.tarotDrawPreparation),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: RynPalette.surfaceElevated(context),
            borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
            border: Border.all(color: RynPalette.line(context)),
            boxShadow: RynPalette.panelShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TarotSelectionSummary(deck: deck, spread: spread),
                  ),
                  const SizedBox(width: 12),
                  _TarotSmallBadge('$selectedCount / $targetCount 선택'),
                  const SizedBox(width: 8),
                  _TarotSmallBadge('남은 선택 $remainingToSelect장'),
                ],
              ),
              const SizedBox(height: 16),
              _TarotFullDeckBoard(
                cards: cards,
                selectedIndexes: selectedIndexes,
                targetReached: selectedCount >= targetCount,
                onSelected: onSelected,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isShuffling ? null : onAutoDraw,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: const Text(UserText.tarotAutoDraw),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('tarot-show-result-button'),
                      onPressed: selectedCount >= targetCount
                          ? onShowResult
                          : null,
                      icon: const Icon(Icons.table_chart_rounded, size: 18),
                      label: const Text(_TarotUiText.showResult),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text(UserText.tarotResetDraw),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TarotFullDeckBoard extends StatelessWidget {
  const _TarotFullDeckBoard({
    required this.cards,
    required this.selectedIndexes,
    required this.targetReached,
    required this.onSelected,
  });

  final List<_TarotCardDefinition> cards;
  final Set<int> selectedIndexes;
  final bool targetReached;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-full-deck-stage'),
      height: 560,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RynPalette.surfaceSoft(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: RynPalette.line(context)),
      ),
      child: SingleChildScrollView(
        key: const Key('tarot-full-deck-grid'),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 10,
          children: [
            for (var index = 0; index < cards.length; index++)
              SizedBox(
                key: Key('tarot-full-deck-card-$index'),
                width: 48,
                height: 72,
                child: _TarotFullDeckCard(
                  index: index,
                  selected: selectedIndexes.contains(index),
                  disabled: targetReached && !selectedIndexes.contains(index),
                  onTap: () => onSelected(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TarotFullDeckCard extends StatefulWidget {
  const _TarotFullDeckCard({
    required this.index,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final int index;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  State<_TarotFullDeckCard> createState() => _TarotFullDeckCardState();
}

class _TarotFullDeckCardState extends State<_TarotFullDeckCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final lifted = _hovered && !widget.disabled;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: lifted ? 1.18 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Opacity(
          opacity: widget.disabled ? 0.45 : 1,
          child: _TarotCardBackChoice(
            onTap: widget.disabled || widget.selected ? () {} : widget.onTap,
            compact: true,
            glowing: widget.selected || lifted,
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
    required this.onReset,
  });

  final String spreadLabel;
  final List<_TarotSlotSpec> slots;
  final List<_DrawnTarotCard> drawnCards;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const _TarotSmallStageLabel(label: _TarotUiText.showResult),
            const Spacer(),
            TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(UserText.tarotResetDraw),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _TarotSpreadCanvas(
          spreadLabel: spreadLabel,
          slots: slots,
          drawnCards: drawnCards,
          showEmptySlots: false,
          onEmptySlotTap: () {},
        ),
        const SizedBox(height: 16),
        const _TarotMemoPanel(),
      ],
    );
  }
}

class _TarotDeckChoiceSection extends StatelessWidget {
  const _TarotDeckChoiceSection({
    required this.title,
    required this.decks,
    required this.selectedDeckId,
    required this.onSelected,
  });

  final String title;
  final List<_TarotDeckDefinition> decks;
  final String selectedDeckId;
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final deck in decks)
              ChoiceChip(
                label: Text(deck.label),
                selected: deck.id == selectedDeckId,
                onSelected: (_) => onSelected(deck.id),
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: deck.id == selectedDeckId
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

class _TarotChoiceSection extends StatelessWidget {
  const _TarotChoiceSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(option),
                selected: option == selected,
                onSelected: (_) => onSelected(option),
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: option == selected
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
  const _ShuffleDeckStack({required this.isShuffling, required this.onTap});

  final bool isShuffling;
  final VoidCallback onTap;

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
          width: 116,
          height: 156,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var index = 3; index >= 0; index--)
                Positioned(
                  left: 14 + index * 3,
                  top: 10 + index * 3,
                  child: Opacity(
                    opacity: 0.62 + index * 0.09,
                    child: _TarotCardBack(
                      compact: false,
                      glowing: isShuffling || index == 0,
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

class _TarotCardBackChoice extends StatelessWidget {
  const _TarotCardBackChoice({
    required this.onTap,
    this.compact = false,
    this.glowing = false,
  });

  final VoidCallback onTap;
  final bool compact;
  final bool glowing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('tarot-card-back-choice'),
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: _TarotCardBack(compact: compact, glowing: glowing),
      ),
    );
  }
}

class _TarotCardBack extends StatelessWidget {
  const _TarotCardBack({this.compact = false, this.glowing = false});

  static const defaultAssetPath =
      'assets/tarot/card_backs/ryn_cosmic_gate_back_v1.png';

  final bool compact;
  final bool glowing;

  @override
  Widget build(BuildContext context) {
    final accent = RynPalette.accent(context);
    return AnimatedContainer(
      key: const Key('tarot-card-back'),
      duration: const Duration(milliseconds: 220),
      width: compact ? 48 : 86,
      height: compact ? 72 : 132,
      decoration: BoxDecoration(
        color: RynPalette.accentSoft(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withValues(alpha: glowing ? 0.75 : 0.45),
        ),
        boxShadow: [
          ...RynPalette.panelShadow(context),
          if (glowing)
            BoxShadow(
              color: accent.withValues(alpha: 0.36),
              blurRadius: compact ? 18 : 28,
              spreadRadius: 2,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              defaultAssetPath,
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
    );
  }
}

class _TarotSpreadCanvas extends StatelessWidget {
  const _TarotSpreadCanvas({
    required this.spreadLabel,
    required this.slots,
    required this.drawnCards,
    required this.onEmptySlotTap,
    this.showEmptySlots = true,
  });

  final String spreadLabel;
  final List<_TarotSlotSpec> slots;
  final List<_DrawnTarotCard> drawnCards;
  final VoidCallback onEmptySlotTap;
  final bool showEmptySlots;

  @override
  Widget build(BuildContext context) {
    final canvasHeight = _canvasHeightForSlots(slots.length);
    return Container(
      height: canvasHeight,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RynPalette.surfaceSoft(context),
        borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
        border: Border.all(color: RynPalette.line(context)),
        boxShadow: RynPalette.panelShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: RynPalette.accent(context),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                UserText.tarotResultTable,
                style: TextStyle(
                  color: RynPalette.text(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              _TarotSmallBadge(spreadLabel, compact: true),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: RynPalette.surface(context),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: RynPalette.line(context)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardSize = _cardSizeForLayout(
                    slots.length,
                    constraints,
                  );
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      for (var index = 0; index < slots.length; index++)
                        Positioned(
                          left:
                              (constraints.maxWidth - cardSize.width) *
                              slots[index].xRatio,
                          top:
                              (constraints.maxHeight - cardSize.height) *
                              slots[index].yRatio,
                          width: cardSize.width,
                          height: cardSize.height,
                          child: index < drawnCards.length
                              ? _TarotDrawnCardView(
                                  drawnCard: drawnCards[index],
                                )
                              : showEmptySlots
                              ? _TarotEmptySlot(
                                  label: slots[index].label,
                                  onTap: onEmptySlotTap,
                                )
                              : const SizedBox.shrink(),
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
  if (count == 1) return 680;
  if (count <= 3) return 660;
  if (count <= 5) return 720;
  if (count <= 6) return 740;
  return 780;
}

Size _cardSizeForLayout(int count, BoxConstraints constraints) {
  final maxWidth = constraints.maxWidth;
  final maxHeight = constraints.maxHeight;
  final preferredWidth = switch (count) {
    1 => 210.0,
    <= 3 => 160.0,
    <= 5 => 132.0,
    <= 6 => 124.0,
    _ => 96.0,
  };
  final horizontalSlots = switch (count) {
    1 => 1.8,
    <= 3 => 4.0,
    <= 5 => 5.0,
    <= 6 => 4.2,
    _ => 5.8,
  };
  final verticalSlots = switch (count) {
    1 => 1.2,
    <= 3 => 1.7,
    <= 5 => 3.2,
    <= 6 => 3.4,
    _ => 4.25,
  };
  final widthLimit = maxWidth / horizontalSlots;
  final heightLimit = ((maxHeight / verticalSlots) - 50) / 1.62;
  final width = math.max(
    62.0,
    math.min(preferredWidth, math.min(widthLimit, heightLimit)),
  );
  return Size(width, (width * 1.62) + 50);
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
  const _TarotDrawnCardView({required this.drawnCard});

  final _DrawnTarotCard drawnCard;

  @override
  Widget build(BuildContext context) {
    final orientation = drawnCard.reversed
        ? UserText.tarotReversed
        : UserText.tarotUpright;
    return Container(
      key: const Key('tarot-drawn-card'),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: RynPalette.surfaceElevated(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RynPalette.accent(context).withValues(alpha: 0.4),
        ),
        boxShadow: RynPalette.panelShadow(context),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: ColoredBox(
                color: RynPalette.surface(context),
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
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 44,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  drawnCard.card.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: RynPalette.text(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                _TarotSmallBadge(orientation, compact: true),
              ],
            ),
          ),
        ],
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
        color: RynPalette.accentSoft(context),
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
}

const _tarotSpreadOneSlots = [_TarotSlotSpec('중심', 0.5, 0.5)];

const _tarotSpreadThreeSlots = [
  _TarotSlotSpec('과거', 0.08, 0.5),
  _TarotSlotSpec('현재', 0.5, 0.5),
  _TarotSlotSpec('미래', 0.92, 0.5),
];

const _tarotSpreadFourSlots = [
  _TarotSlotSpec('상단', 0.5, 0.0),
  _TarotSlotSpec('좌측', 0.08, 0.5),
  _TarotSlotSpec('우측', 0.92, 0.5),
  _TarotSlotSpec('하단', 0.5, 1.0),
];

const _tarotSpreadFiveSlots = [
  _TarotSlotSpec('중심', 0.5, 0.5),
  _TarotSlotSpec('위', 0.5, 0.0),
  _TarotSlotSpec('아래', 0.5, 1.0),
  _TarotSlotSpec('좌', 0.04, 0.5),
  _TarotSlotSpec('우', 0.96, 0.5),
];

const _tarotSpreadCelticSlots = [
  _TarotSlotSpec('현재', 0.28, 0.5),
  _TarotSlotSpec('교차', 0.43, 0.5),
  _TarotSlotSpec('위', 0.36, 0.0),
  _TarotSlotSpec('아래', 0.36, 1.0),
  _TarotSlotSpec('과거', 0.04, 0.5),
  _TarotSlotSpec('미래', 0.62, 0.5),
  _TarotSlotSpec('조언', 0.96, 1.0),
  _TarotSlotSpec('환경', 0.96, 0.66),
  _TarotSlotSpec('희망', 0.96, 0.33),
  _TarotSlotSpec('결과', 0.96, 0.0),
];

const _tarotSpreadBinarySlots = [
  _TarotSlotSpec('A 시작', 0.18, 0.0),
  _TarotSlotSpec('A 흐름', 0.18, 0.5),
  _TarotSlotSpec('A 결과', 0.18, 1.0),
  _TarotSlotSpec('B 시작', 0.82, 0.0),
  _TarotSlotSpec('B 흐름', 0.82, 0.5),
  _TarotSlotSpec('B 결과', 0.82, 1.0),
];

const _tarotSpreadRelationSlots = [
  _TarotSlotSpec('나', 0.08, 0.5),
  _TarotSlotSpec('상대', 0.92, 0.5),
  _TarotSlotSpec('연결', 0.5, 0.0),
  _TarotSlotSpec('흐름', 0.5, 1.0),
];

const _tarotSpreadIssueSlots = [
  _TarotSlotSpec('문제', 0.08, 0.5),
  _TarotSlotSpec('원인', 0.5, 0.5),
  _TarotSlotSpec('해결', 0.92, 0.5),
];
