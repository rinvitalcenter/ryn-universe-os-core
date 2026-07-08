import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:newton_particles/newton_particles.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ryn_universe_os_core/core/text/user_text.dart';
import 'package:ryn_universe_os_core/features/tarot/data/tarot_card_meaning_registry.dart';
import 'package:ryn_universe_os_core/features/tarot/data/tarot_deck_registry.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_card_definition.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_deck_definition.dart';
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
  static const tarotLightBackground = Color(0xFFF7F3EC);
  static const tarotLightShell = Color(0xFFFFFDF8);
  static const tarotLightStage = Color(0xFFF1EDF8);
  static const tarotLightPanel = Color(0xFFFBF8F2);
  static const tarotLightInput = Color(0xFFF2EEE8);
  static const tarotLightSummary = Color(0xFFF8F4EE);
  static const tarotLightGuide = Color(0xFFF4F0FA);
  static const tarotLightSelected = Color(0xFFEDE5FF);
  static const tarotLightLine = Color(0xFFDDD5C9);
  static const tarotLightText = Color(0xFF23242A);
  static const tarotLightMuted = Color(0xFF6C6874);
  static const tarotLightPurple = Color(0xFF6E56A3);
  static const tarotLightGold = Color(0xFFC7A45A);

  static const tarotMidnight = Color(0xFF101116);
  static const tarotNavy = Color(0xFF151823);
  static const tarotViolet = Color(0xFF2B2740);
  static const tarotPanel = Color(0xFF222534);
  static const tarotPanelSoft = Color(0xFF252838);
  static const tarotInput = Color(0xFF12151E);
  static const tarotGuide = Color(0xFF242235);
  static const tarotLine = Color(0xFF373B4A);
  static const tarotLavender = Color(0xFF8D7BCB);
  static const tarotGold = Color(0xFFD0AF63);
  static const tarotIvory = Color(0xFFF2EDE3);
  static const tarotMist = Color(0xFFB9B6C7);
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

  static Color tarotAppBackground(BuildContext context) =>
      isDark(context) ? tarotMidnight : tarotLightBackground;
  static Color tarotPageShell(BuildContext context) =>
      isDark(context) ? tarotNavy : tarotLightShell;
  static Color tarotReadingStage(BuildContext context) =>
      isDark(context) ? const Color(0xFF1A1D2A) : tarotLightStage;
  static Color tarotBentoPanel(BuildContext context) =>
      isDark(context) ? tarotPanel : tarotLightPanel;
  static Color tarotBentoPanelSoft(BuildContext context) =>
      isDark(context) ? tarotPanelSoft : const Color(0xFFFFFFFF);
  static Color tarotInputField(BuildContext context) =>
      isDark(context) ? tarotInput : tarotLightInput;
  static Color tarotSummaryPanel(BuildContext context) =>
      isDark(context) ? tarotPanelSoft : tarotLightSummary;
  static Color tarotGuidePanel(BuildContext context) =>
      isDark(context) ? tarotGuide : tarotLightGuide;
  static Color tarotSelectedPanel(BuildContext context) =>
      isDark(context) ? tarotViolet : tarotLightSelected;
  static Color tarotBorder(BuildContext context) =>
      isDark(context) ? tarotLine : tarotLightLine;
  static Color tarotTextPrimary(BuildContext context) =>
      isDark(context) ? tarotIvory : tarotLightText;
  static Color tarotTextSecondary(BuildContext context) =>
      isDark(context) ? tarotMist : tarotLightMuted;
  static Color tarotPurpleAccent(BuildContext context) =>
      isDark(context) ? tarotLavender : tarotLightPurple;
  static Color tarotGoldAccent(BuildContext context) =>
      isDark(context) ? tarotGold : tarotLightGold;

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
        color: RynPalette.tarotPageShell(context),
        borderRadius: BorderRadius.circular(RynMetrics.radiusShell),
        border: Border.all(
          color: RynPalette.tarotBorder(context).withValues(alpha: 0.72),
        ),
        boxShadow: RynPalette.panelShadow(context),
      ),
      child: child,
    );
  }
}

class _TarotReadingTableTheme extends StatelessWidget {
  const _TarotReadingTableTheme({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    return Theme(
      key: const Key('tarot-reading-table-forced-dark-theme'),
      data: base.copyWith(
        brightness: Brightness.dark,
        colorScheme: base.colorScheme.copyWith(
          brightness: Brightness.dark,
          surface: RynPalette.tarotPanel,
          onSurface: RynPalette.tarotIvory,
          primary: RynPalette.tarotGold,
          onPrimary: RynPalette.tarotMidnight,
          secondary: RynPalette.tarotLavender,
        ),
      ),
      child: child,
    );
  }
}

enum _TarotDrawPhase { beforeShuffle, shuffling, ready, drawing, complete }

enum _ShuffleRitualMotionPhase {
  idle,
  hoverReady,
  shuffleStart,
  shuffleActive,
  settle,
  transitionToFan,
}

enum _TarotFlowStage { setup, draw, result, interpretation }

enum _TarotDirectionMode { uprightOnly, auto }

class _TarotQuestionCategory {
  const _TarotQuestionCategory({
    required this.id,
    required this.label,
    required this.helper,
    required this.icon,
  });

  final String id;
  final String label;
  final String helper;
  final IconData icon;
}

class _TarotReadingContext {
  const _TarotReadingContext({
    required this.category,
    required this.freeQuestion,
    required this.querentAlias,
    required this.sensitivityNote,
  });

  final _TarotQuestionCategory category;
  final String freeQuestion;
  final String querentAlias;
  final String sensitivityNote;

  String get question {
    final value = freeQuestion.trim();
    if (value.isNotEmpty) return value;
    return '오늘 가장 먼저 비춰볼 질문';
  }

  String get quotedQuestion => '“$question”';
  String get alias => querentAlias.trim();
  String get caution => sensitivityNote.trim();
}

const _tarotQuestionCategories = [
  _TarotQuestionCategory(
    id: 'love',
    label: '연애',
    helper: '마음의 흐름을 봅니다',
    icon: Icons.favorite_rounded,
  ),
  _TarotQuestionCategory(
    id: 'money',
    label: '금전',
    helper: '가능성과 조건을 봅니다',
    icon: Icons.account_balance_rounded,
  ),
  _TarotQuestionCategory(
    id: 'career',
    label: '일·승진·진로',
    helper: '방향과 선택을 봅니다',
    icon: Icons.trending_up_rounded,
  ),
  _TarotQuestionCategory(
    id: 'social_relation',
    label: '관계',
    helper: '마음의 흐름을 봅니다',
    icon: Icons.people_alt_rounded,
  ),
  _TarotQuestionCategory(
    id: 'family',
    label: '가족',
    helper: '관계의 균형을 봅니다',
    icon: Icons.home_rounded,
  ),
  _TarotQuestionCategory(
    id: 'spiritual_growth',
    label: '영적 성장',
    helper: '내면의 신호를 봅니다',
    icon: Icons.auto_awesome_rounded,
  ),
  _TarotQuestionCategory(
    id: 'yes_no',
    label: '예·아니오',
    helper: '가능성과 조건을 봅니다',
    icon: Icons.rule_rounded,
  ),
  _TarotQuestionCategory(
    id: 'timing',
    label: '시기',
    helper: '준비의 신호를 봅니다',
    icon: Icons.schedule_rounded,
  ),
  _TarotQuestionCategory(
    id: 'choice',
    label: '선택',
    helper: '기준과 주의점을 봅니다',
    icon: Icons.alt_route_rounded,
  ),
  _TarotQuestionCategory(
    id: 'open_question',
    label: '자유 질문',
    helper: '지금 필요한 흐름을 봅니다',
    icon: Icons.edit_note_rounded,
  ),
];

class _TarotTableClothDefinition {
  const _TarotTableClothDefinition({
    required this.id,
    required this.label,
    required this.intent,
    required this.primary,
    required this.secondary,
    required this.shadow,
  });

  final String id;
  final String label;
  final String intent;
  final Color primary;
  final Color secondary;
  final Color shadow;
}

const _tarotTableClothDefinitions = [
  _TarotTableClothDefinition(
    id: 'deep_purple',
    label: '미드나잇 바이올렛',
    intent: '직관 · 영성 · 내면',
    primary: Color(0xFF221A4E),
    secondary: Color(0xFF090D24),
    shadow: Color(0xFF5E559A),
  ),
  _TarotTableClothDefinition(
    id: 'deep_green',
    label: '딥 그린',
    intent: '재물 · 성장 · 회복',
    primary: Color(0xFF163F36),
    secondary: Color(0xFF071B20),
    shadow: Color(0xFF477E67),
  ),
  _TarotTableClothDefinition(
    id: 'rose_wine',
    label: '로즈 와인',
    intent: '연애 · 관계 · 감정',
    primary: Color(0xFF56213D),
    secondary: Color(0xFF160D25),
    shadow: Color(0xFF93617F),
  ),
  _TarotTableClothDefinition(
    id: 'midnight_navy',
    label: '미드나잇 네이비',
    intent: '진로 · 선택 · 장기 방향',
    primary: Color(0xFF142C56),
    secondary: Color(0xFF071126),
    shadow: Color(0xFF5E79AA),
  ),
  _TarotTableClothDefinition(
    id: 'charcoal_black',
    label: '차콜 블랙',
    intent: '보호 · 정화 · 냉정한 판단',
    primary: Color(0xFF34363D),
    secondary: Color(0xFF12141A),
    shadow: Color(0xFFB9BDC8),
  ),
  _TarotTableClothDefinition(
    id: 'muted_gold',
    label: '뮤티드 골드',
    intent: '성취 · 기회 · 자신감',
    primary: Color(0xFF8B6B34),
    secondary: Color(0xFF121326),
    shadow: Color(0xFFBFA76A),
  ),
];

bool _isMutedGoldCloth(_TarotTableClothDefinition cloth) =>
    cloth.id == 'muted_gold';

Color _tarotClothTableBase(
  BuildContext context,
  _TarotTableClothDefinition cloth,
) => RynPalette.isDark(context)
    ? (_isMutedGoldCloth(cloth)
          ? const Color(0xFF101321)
          : RynPalette.tarotNavy)
    : const Color(0xFFE5DFEC);

Color _tarotClothTableEdge(
  BuildContext context,
  _TarotTableClothDefinition cloth,
) => RynPalette.isDark(context)
    ? (_isMutedGoldCloth(cloth) ? const Color(0xFF1A1730) : cloth.secondary)
    : const Color(0xFFD6CCDF);

double _tarotClothPrimaryAlpha(_TarotTableClothDefinition cloth) =>
    _isMutedGoldCloth(cloth) ? 0.24 : 0.30;

double _tarotClothShadowAlpha(_TarotTableClothDefinition cloth) =>
    _isMutedGoldCloth(cloth) ? 0.08 : 0.06;

class _TarotUiText {
  const _TarotUiText._();

  static const shuffle = '셔플하기';
  static const shuffling = '카드를 섞고 있습니다';
  static const prepare = '준비하기';
  static const showResult = '결과 보기';
  static const directionMode = '방향 선택';
  static const uprightOnly = '정방향만';
  static const autoDirection = '정/역방향';
  static const revealPrompt = '카드를 펼쳐보세요';
  static const interpretationPrompt = '해석 보기로 이어가세요';
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
  static const _deckDefinitions = TarotDeckRegistry.decks;

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

  static final _freeSpreadDefinitions = _spreadDefinitions
      .where((spread) => spread.family == _TarotSpreadFamily.freeLayout)
      .toList(growable: false);

  static final _fixedSpreadDefinitions = _spreadDefinitions
      .where((spread) => spread.family == _TarotSpreadFamily.fixedMeaning)
      .toList(growable: false);

  static final _spreadDefinitions = _buildTarotSpreadRegistry();

  static const _rwsCards = TarotDeckRegistry.rwsCards;

  String _selectedDeckId = 'rws_public_domain';
  String? _selectedCardBackOverrideId;
  String _selectedTableClothId = 'deep_purple';
  String _selectedSpread = UserText.tarotSpreadThree;
  String _selectedQuestionCategoryId = 'love';
  String _freeQuestion = '';
  String _questionTitle = '';
  String _questionDetail = '';
  String _currentSituation = '';
  String _desiredClarity = '';
  String _querentAlias = '';
  String _querentRelationship = '';
  String _querentBirthNote = '';
  String _sessionContext = '';
  String _sensitivityNote = '';
  int _selectedFreeDrawCount = 5;
  _TarotDirectionMode _directionMode = _TarotDirectionMode.auto;
  late List<TarotCardDefinition> _remainingDeck;
  final List<_DrawnTarotCard> _drawnCards = [];

  final Set<int> _selectedDeckIndexes = {};
  final Set<int> _revealedResultIndexes = {};
  final Set<int> _revealFxIndexes = {};
  Uint8List? _interpretationSnapshotBytes;
  late List<String> _positionLabels;
  _TarotDrawPhase _phase = _TarotDrawPhase.beforeShuffle;
  _TarotFlowStage _stage = _TarotFlowStage.setup;
  int _setupStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _positionLabels = _defaultPositionLabelsFor(_selectedSpread);
    _prepareFreshDeck(clearDrawn: true);
  }

  TarotDeckDefinition get _selectedDeck => _deckDefinitions.firstWhere(
    (deck) => deck.id == _selectedDeckId,
    orElse: () => _deckDefinitions.first,
  );

  _TarotCardBackDefinition? get _selectedDeckCardBack {
    final assetPath = _selectedDeck.cardBackAssetPath;
    if (assetPath == null || assetPath.trim().isEmpty) return null;
    return _TarotCardBackDefinition(
      id: 'deck-${_selectedDeck.id}',
      label: '덱 기본',
      assetPath: assetPath,
    );
  }

  List<_TarotCardBackDefinition> get _effectiveCardBackDefinitions => [
    ?_selectedDeckCardBack,
    ..._cardBackDefinitions,
  ];

  String get _selectedCardBackId =>
      _selectedCardBackOverrideId ??
      _selectedDeckCardBack?.id ??
      _cardBackDefinitions.first.id;

  _TarotCardBackDefinition get _selectedCardBack =>
      _effectiveCardBackDefinitions.firstWhere(
        (cardBack) => cardBack.id == _selectedCardBackId,
        orElse: () => _cardBackDefinitions.first,
      );

  _TarotTableClothDefinition get _selectedTableCloth =>
      _tarotTableClothDefinitions.firstWhere(
        (cloth) => cloth.id == _selectedTableClothId,
        orElse: () => _tarotTableClothDefinitions.first,
      );

  _TarotSpreadDefinition get _selectedSpreadDefinition =>
      _spreadDefinitions.firstWhere(
        (spread) => spread.label == _selectedSpread,
        orElse: () => _spreadDefinitions[1],
      );

  _TarotQuestionCategory get _selectedQuestionCategory =>
      _tarotQuestionCategories.firstWhere(
        (category) => category.id == _selectedQuestionCategoryId,
        orElse: () => _tarotQuestionCategories.first,
      );

  _TarotReadingContext get _readingContext => _TarotReadingContext(
    category: _selectedQuestionCategory,
    freeQuestion: _freeQuestion,
    querentAlias: _querentAlias,
    sensitivityNote: _sensitivityNote,
  );

  void _updateQuestionCategory(String categoryId) {
    setState(() => _selectedQuestionCategoryId = categoryId);
  }

  void _updateFreeQuestion(String value) =>
      setState(() => _freeQuestion = value);
  void _updateQuestionTitle(String value) =>
      setState(() => _questionTitle = value);
  void _updateQuestionDetail(String value) =>
      setState(() => _questionDetail = value);
  void _updateCurrentSituation(String value) =>
      setState(() => _currentSituation = value);
  void _updateDesiredClarity(String value) =>
      setState(() => _desiredClarity = value);
  void _updateQuerentAlias(String value) =>
      setState(() => _querentAlias = value);
  void _updateQuerentRelationship(String value) =>
      setState(() => _querentRelationship = value);
  void _updateQuerentBirthNote(String value) =>
      setState(() => _querentBirthNote = value);
  void _updateSessionContext(String value) =>
      setState(() => _sessionContext = value);
  void _updateSensitivityNote(String value) =>
      setState(() => _sensitivityNote = value);

  bool get _isFreeDrawSelected => _selectedSpreadDefinition.id == 'free_draw';

  List<_TarotSlotSpec> get _baseSlots => _isFreeDrawSelected
      ? _freeDrawSlotsForCount(_selectedFreeDrawCount)
      : _selectedSpreadDefinition.slots;

  List<_TarotSlotSpec> get _slots => [
    for (var index = 0; index < _baseSlots.length; index++)
      _baseSlots[index].copyWith(
        label: index < _positionLabels.length
            ? _normalizedPositionLabel(
                _positionLabels[index],
                _baseSlots[index].label,
              )
            : _baseSlots[index].label,
      ),
  ];

  List<String> _defaultPositionLabelsFor(String spreadLabel) {
    final definition = _spreadDefinitions.firstWhere(
      (spread) => spread.label == spreadLabel,
      orElse: () => _spreadDefinitions[1],
    );
    final slots = definition.id == 'free_draw'
        ? _freeDrawSlotsForCount(_selectedFreeDrawCount)
        : definition.slots;
    return [for (final slot in slots) slot.label];
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

  void _selectFreeDrawCount(int count) {
    final next = count.clamp(1, 30);
    if (next == _selectedFreeDrawCount) return;
    setState(() {
      _selectedFreeDrawCount = next;
      if (_isFreeDrawSelected) {
        _positionLabels = _defaultPositionLabelsFor(_selectedSpread);
        _prepareFreshDeck(clearDrawn: true);
        _phase = _TarotDrawPhase.beforeShuffle;
        _stage = _TarotFlowStage.setup;
      }
    });
  }

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
    final cards = _selectedDeck.cards.isEmpty ? _rwsCards : _selectedDeck.cards;
    _remainingDeck = List<TarotCardDefinition>.of(cards)
      ..shuffle(math.Random());
    if (clearDrawn) {
      _drawnCards.clear();
      _selectedDeckIndexes.clear();
      _revealedResultIndexes.clear();
      _revealFxIndexes.clear();
      _interpretationSnapshotBytes = null;
    }
  }

  Future<void> _startShuffle() async {
    if (_phase == _TarotDrawPhase.shuffling) return;
    setState(() {
      _prepareFreshDeck(clearDrawn: true);
      _phase = _TarotDrawPhase.shuffling;
    });
    await Future<void>.delayed(const Duration(milliseconds: 1200));
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
      _setupStepIndex = 0;
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
    _interpretationSnapshotBytes = null;
    _stage = _TarotFlowStage.result;
  }

  void _showResult() {
    if (!_isComplete) return;
    setState(_enterResultStage);
  }

  void _showInterpretation(GlobalKey resultBoundaryKey) {
    if (!_isComplete) return;
    setState(() {
      _interpretationSnapshotBytes = null;
      _stage = _TarotFlowStage.interpretation;
    });
    _captureTarotResultBoardPng(resultBoundaryKey)
        .then((snapshotBytes) {
          if (!mounted || _stage != _TarotFlowStage.interpretation) return;
          setState(() => _interpretationSnapshotBytes = snapshotBytes);
        })
        .catchError((_) {
          if (!mounted || _stage != _TarotFlowStage.interpretation) return;
          setState(() => _interpretationSnapshotBytes = null);
        });
  }

  void _selectSpread(String spread) {
    setState(() {
      _selectedSpread = spread;
      _positionLabels = _defaultPositionLabelsFor(spread);
      _prepareFreshDeck(clearDrawn: true);
      _phase = _TarotDrawPhase.beforeShuffle;
      _stage = _TarotFlowStage.setup;
      _setupStepIndex = 6;
    });
  }

  void _selectSetupStep(int index) {
    setState(() {
      _stage = _TarotFlowStage.setup;
      _setupStepIndex = index.clamp(0, 7);
    });
  }

  void _selectFlowIndex(int index) {
    if (index <= 7) {
      _selectSetupStep(index);
      return;
    }
    if (!_isComplete) return;
    setState(() {
      if (index == 9) _interpretationSnapshotBytes = null;
      _stage = index == 8
          ? _TarotFlowStage.result
          : _TarotFlowStage.interpretation;
    });
  }

  int get _activeFlowIndex => switch (_stage) {
    _TarotFlowStage.setup => _setupStepIndex,
    _TarotFlowStage.draw => 7,
    _TarotFlowStage.result => 8,
    _TarotFlowStage.interpretation => 9,
  };

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
      _selectedCardBackOverrideId = null;
      _prepareFreshDeck(clearDrawn: true);
      _phase = _TarotDrawPhase.beforeShuffle;
      _stage = _TarotFlowStage.setup;
      _setupStepIndex = 5;
    });
  }

  void _selectCardBack(String cardBackId) {
    setState(() {
      _selectedCardBackOverrideId = cardBackId == _selectedDeckCardBack?.id
          ? null
          : cardBackId;
    });
  }

  void _selectTableCloth(String clothId) {
    if (_selectedTableClothId == clothId) return;
    setState(() => _selectedTableClothId = clothId);
  }

  @override
  Widget build(BuildContext context) {
    final immersive = _stage != _TarotFlowStage.setup;
    final Widget rawStageContent = switch (_stage) {
      _TarotFlowStage.setup => _TarotSetupStage(
        decks: _deckDefinitions,
        selectedDeckId: _selectedDeckId,
        onDeckSelected: _selectDeck,
        cardBacks: _effectiveCardBackDefinitions,
        selectedCardBackId: _selectedCardBackId,
        selectedCardBack: _selectedCardBack,
        onCardBackSelected: _selectCardBack,
        tableCloths: _tarotTableClothDefinitions,
        selectedTableClothId: _selectedTableClothId,
        onTableClothSelected: _selectTableCloth,
        freeSpreads: _freeSpreadDefinitions,
        fixedSpreads: _fixedSpreadDefinitions,
        selectedSpread: _selectedSpread,
        onSpreadSelected: _selectSpread,
        selectedDeck: _selectedDeck,
        questionCategories: _tarotQuestionCategories,
        selectedQuestionCategoryId: _selectedQuestionCategoryId,
        selectedQuestionCategory: _selectedQuestionCategory,
        onQuestionCategorySelected: _updateQuestionCategory,
        freeQuestion: _freeQuestion,
        questionTitle: _questionTitle,
        questionDetail: _questionDetail,
        currentSituation: _currentSituation,
        desiredClarity: _desiredClarity,
        onFreeQuestionChanged: _updateFreeQuestion,
        onQuestionTitleChanged: _updateQuestionTitle,
        onQuestionDetailChanged: _updateQuestionDetail,
        onCurrentSituationChanged: _updateCurrentSituation,
        onDesiredClarityChanged: _updateDesiredClarity,
        querentAlias: _querentAlias,
        querentRelationship: _querentRelationship,
        querentBirthNote: _querentBirthNote,
        sessionContext: _sessionContext,
        sensitivityNote: _sensitivityNote,
        onQuerentAliasChanged: _updateQuerentAlias,
        onQuerentRelationshipChanged: _updateQuerentRelationship,
        onQuerentBirthNoteChanged: _updateQuerentBirthNote,
        onSessionContextChanged: _updateSessionContext,
        onSensitivityNoteChanged: _updateSensitivityNote,
        onShuffle: _startShuffle,
        onAutoDraw: _drawAll,
        isShuffling: _phase == _TarotDrawPhase.shuffling,
        readingContext: _readingContext,
        directionMode: _directionMode,
        onDirectionModeSelected: _selectDirectionMode,
        positionLabels: _positionLabels,
        defaultPositionLabels: _defaultPositionLabelsFor(_selectedSpread),
        onPositionLabelChanged: _updatePositionLabel,
        selectedFreeDrawCount: _selectedFreeDrawCount,
        onFreeDrawCountChanged: _selectFreeDrawCount,
        stepIndex: _setupStepIndex,
        onStepChanged: _selectSetupStep,
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
        tableCloth: _selectedTableCloth,
        readingContext: _readingContext,
      ),
      _TarotFlowStage.result => _TarotResultStage(
        spreadDefinition: _selectedSpreadDefinition,
        spreadLabel: _selectedSpread,
        slots: _slots,
        drawnCards: _drawnCards,
        revealedIndexes: _revealedResultIndexes,
        revealFxIndexes: _revealFxIndexes,
        onRevealCard: _revealResultCard,
        onRevealAll: _revealAllResultCards,
        onInterpret: _showInterpretation,
        onReset: _resetDraw,
        onBack: widget.onBack,
        onDirectionToggle: _toggleDrawnDirection,
        cardBack: _selectedCardBack,
        deckLabel: _selectedDeck.label,
        tableCloth: _selectedTableCloth,
        readingContext: _readingContext,
      ),
      _TarotFlowStage.interpretation => _TarotInterpretationStage(
        spreadLabel: _selectedSpread,
        drawnCards: _drawnCards,
        tableCloth: _selectedTableCloth,
        readingContext: _readingContext,
        spreadSnapshotBytes: _interpretationSnapshotBytes,
        onBackToResult: () => setState(() => _stage = _TarotFlowStage.result),
        onReset: _resetDraw,
      ),
    };
    final Widget stageContent = _stage == _TarotFlowStage.setup
        ? rawStageContent
        : _TarotReadingTableTheme(child: rawStageContent);
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
                              color: RynPalette.tarotTextSecondary(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            UserText.tarotTitle,
                            style: TextStyle(
                              color: RynPalette.tarotTextPrimary(context),
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            UserText.tarotSubtitle,
                            style: TextStyle(
                              color: RynPalette.tarotTextSecondary(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _TarotBackButton(onPressed: widget.onBack),
                  ],
                ),
              if (!immersive) ...[
                const SizedBox(height: 10),
                _TarotGlobalFlowNav(
                  activeIndex: _activeFlowIndex,
                  enabledIndexes: {
                    0,
                    1,
                    2,
                    3,
                    4,
                    5,
                    6,
                    7,
                    if (_isComplete) 8,
                    if (_isComplete) 9,
                  },
                  onSelected: _selectFlowIndex,
                ),
                const SizedBox(height: 18),
              ] else
                const SizedBox(height: 8),
              if (boundedHeight && _stage == _TarotFlowStage.result)
                Expanded(child: stageContent)
              else if (boundedHeight)
                Expanded(child: SingleChildScrollView(child: stageContent))
              else if (_stage == _TarotFlowStage.result)
                SizedBox(
                  height:
                      _canvasHeightForDefinition(_selectedSpreadDefinition) +
                      70,
                  child: stageContent,
                )
              else
                stageContent,
            ],
          ),
        );
      },
    );
  }
}

class _TarotBackButton extends StatelessWidget {
  const _TarotBackButton({required this.onPressed, this.compact = false});

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const Key('tarot-back-button-strong'),
      style: OutlinedButton.styleFrom(
        foregroundColor: RynPalette.tarotTextPrimary(context),
        backgroundColor: RynPalette.tarotBentoPanel(context),
        side: BorderSide(
          color: RynPalette.tarotGoldAccent(context).withValues(alpha: 0.38),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 8 : 11,
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
      onPressed: onPressed,
      icon: Icon(Icons.arrow_back_rounded, size: compact ? 17 : 19),
      label: const Text(UserText.backToWorkspace),
    );
  }
}

class _TarotGlobalFlowNav extends StatelessWidget {
  const _TarotGlobalFlowNav({
    required this.activeIndex,
    required this.enabledIndexes,
    required this.onSelected,
  });

  static const labels = [
    '인트로',
    '카테고리',
    '질문',
    '상담 정보',
    '요약',
    '덱',
    '세부 설정',
    '셔플',
    '공개',
    '해석',
  ];

  final int activeIndex;
  final Set<int> enabledIndexes;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const phases = [
      _TarotAtelierPhase('질문 준비', 0, 4),
      _TarotAtelierPhase('테이블', 5, 8),
      _TarotAtelierPhase('해석', 9, 9),
    ];
    return Container(
      key: const Key('tarot-midnight-atelier-stepper'),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: RynPalette.tarotGuidePanel(
          context,
        ).withValues(alpha: RynPalette.isDark(context) ? 0.88 : 0.82),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: RynPalette.tarotPurpleAccent(context).withValues(alpha: 0.18),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 960;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final phase in phases)
                SizedBox(
                  width: compact
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 20) / 3,
                  child: _TarotAtelierPhaseGroup(
                    phase: phase,
                    labels: labels,
                    activeIndex: activeIndex,
                    enabledIndexes: enabledIndexes,
                    onSelected: onSelected,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TarotAtelierPhase {
  const _TarotAtelierPhase(this.label, this.start, this.end);

  final String label;
  final int start;
  final int end;
}

class _TarotAtelierPhaseGroup extends StatelessWidget {
  const _TarotAtelierPhaseGroup({
    required this.phase,
    required this.labels,
    required this.activeIndex,
    required this.enabledIndexes,
    required this.onSelected,
  });

  final _TarotAtelierPhase phase;
  final List<String> labels;
  final int activeIndex;
  final Set<int> enabledIndexes;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final current = activeIndex >= phase.start && activeIndex <= phase.end;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: current
            ? RynPalette.tarotGuidePanel(context).withValues(alpha: 0.62)
            : RynPalette.tarotBentoPanel(context).withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: current
              ? RynPalette.tarotGoldAccent(context).withValues(alpha: 0.42)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            phase.label,
            style: TextStyle(
              color: current
                  ? RynPalette.tarotTextPrimary(context)
                  : RynPalette.tarotTextSecondary(context),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var index = phase.start; index <= phase.end; index++)
                _TarotAtelierStepDot(
                  index: index,
                  label: labels[index],
                  active: activeIndex == index,
                  enabled: enabledIndexes.contains(index),
                  onSelected: onSelected,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarotAtelierStepDot extends StatelessWidget {
  const _TarotAtelierStepDot({
    required this.index,
    required this.label,
    required this.active,
    required this.enabled,
    required this.onSelected,
  });

  final int index;
  final String label;
  final bool active;
  final bool enabled;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final foreground = active
        ? RynPalette.tarotMidnight
        : enabled
        ? RynPalette.tarotTextPrimary(context)
        : RynPalette.tarotTextSecondary(context).withValues(alpha: 0.48);
    return InkWell(
      key: Key('tarot-global-flow-$label'),
      onTap: enabled ? () => onSelected(index) : null,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? RynPalette.tarotGoldAccent(context)
              : Colors.white.withValues(alpha: enabled ? 0.08 : 0.035),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active
                ? RynPalette.tarotGoldAccent(context)
                : Colors.white.withValues(alpha: enabled ? 0.14 : 0.06),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: foreground,
            fontSize: 11,
            fontWeight: active ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ),
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
        _TarotBackButton(onPressed: onBack, compact: true),
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
    required this.tableCloths,
    required this.selectedTableClothId,
    required this.onTableClothSelected,
    required this.freeSpreads,
    required this.fixedSpreads,
    required this.selectedSpread,
    required this.onSpreadSelected,
    required this.selectedDeck,
    required this.questionCategories,
    required this.selectedQuestionCategoryId,
    required this.selectedQuestionCategory,
    required this.onQuestionCategorySelected,
    required this.freeQuestion,
    required this.questionTitle,
    required this.questionDetail,
    required this.currentSituation,
    required this.desiredClarity,
    required this.onFreeQuestionChanged,
    required this.onQuestionTitleChanged,
    required this.onQuestionDetailChanged,
    required this.onCurrentSituationChanged,
    required this.onDesiredClarityChanged,
    required this.querentAlias,
    required this.querentRelationship,
    required this.querentBirthNote,
    required this.sessionContext,
    required this.sensitivityNote,
    required this.onQuerentAliasChanged,
    required this.onQuerentRelationshipChanged,
    required this.onQuerentBirthNoteChanged,
    required this.onSessionContextChanged,
    required this.onSensitivityNoteChanged,
    required this.onShuffle,
    required this.onAutoDraw,
    required this.isShuffling,
    required this.readingContext,
    required this.directionMode,
    required this.onDirectionModeSelected,
    required this.positionLabels,
    required this.defaultPositionLabels,
    required this.onPositionLabelChanged,
    required this.selectedFreeDrawCount,
    required this.onFreeDrawCountChanged,
    required this.stepIndex,
    required this.onStepChanged,
  });

  final List<TarotDeckDefinition> decks;
  final String selectedDeckId;
  final ValueChanged<String> onDeckSelected;
  final List<_TarotCardBackDefinition> cardBacks;
  final String selectedCardBackId;
  final _TarotCardBackDefinition selectedCardBack;
  final ValueChanged<String> onCardBackSelected;
  final List<_TarotTableClothDefinition> tableCloths;
  final String selectedTableClothId;
  final ValueChanged<String> onTableClothSelected;
  final List<_TarotSpreadDefinition> freeSpreads;
  final List<_TarotSpreadDefinition> fixedSpreads;
  final String selectedSpread;
  final ValueChanged<String> onSpreadSelected;
  final TarotDeckDefinition selectedDeck;
  final List<_TarotQuestionCategory> questionCategories;
  final String selectedQuestionCategoryId;
  final _TarotQuestionCategory selectedQuestionCategory;
  final ValueChanged<String> onQuestionCategorySelected;
  final String freeQuestion;
  final String questionTitle;
  final String questionDetail;
  final String currentSituation;
  final String desiredClarity;
  final ValueChanged<String> onFreeQuestionChanged;
  final ValueChanged<String> onQuestionTitleChanged;
  final ValueChanged<String> onQuestionDetailChanged;
  final ValueChanged<String> onCurrentSituationChanged;
  final ValueChanged<String> onDesiredClarityChanged;
  final String querentAlias;
  final String querentRelationship;
  final String querentBirthNote;
  final String sessionContext;
  final String sensitivityNote;
  final ValueChanged<String> onQuerentAliasChanged;
  final ValueChanged<String> onQuerentRelationshipChanged;
  final ValueChanged<String> onQuerentBirthNoteChanged;
  final ValueChanged<String> onSessionContextChanged;
  final ValueChanged<String> onSensitivityNoteChanged;
  final VoidCallback onShuffle;
  final VoidCallback onAutoDraw;
  final bool isShuffling;
  final _TarotReadingContext readingContext;
  final _TarotDirectionMode directionMode;
  final ValueChanged<_TarotDirectionMode> onDirectionModeSelected;
  final List<String> positionLabels;
  final List<String> defaultPositionLabels;
  final void Function(int index, String value) onPositionLabelChanged;
  final int selectedFreeDrawCount;
  final ValueChanged<int> onFreeDrawCountChanged;
  final int stepIndex;
  final ValueChanged<int> onStepChanged;

  @override
  State<_TarotSetupStage> createState() => _TarotSetupStageState();
}

class _TarotSetupStageState extends State<_TarotSetupStage> {
  void _goToStep(int step) => widget.onStepChanged(step.clamp(0, 7));

  @override
  Widget build(BuildContext context) {
    final introStep = _TarotStepPanel(
      title: '1 질문과 목적',
      subtitle: '카드를 뽑기 전 질문의 결을 차분히 정리합니다.',
      useUnifiedIntakeFrame: true,
      child: _TarotIntroPanel(
        onStart: () => _goToStep(1),
        onSkipToDeck: () => _goToStep(5),
      ),
    );
    final categoryStep = _TarotStepPanel(
      title: '2 질문 카테고리',
      subtitle: '오늘 리딩의 중심 주제를 고르세요.',
      useUnifiedIntakeFrame: true,
      child: _TarotCategorySelectionPanel(
        categories: widget.questionCategories,
        selectedCategoryId: widget.selectedQuestionCategoryId,
        onSelected: widget.onQuestionCategorySelected,
      ),
    );
    final questionStep = _TarotStepPanel(
      title: '3 자세한 질문',
      subtitle: '떠오르는 질문을 먼저 적고, 필요한 만큼만 구조화합니다.',
      useUnifiedIntakeFrame: true,
      child: _TarotQuestionInputPanel(
        freeQuestion: widget.freeQuestion,
        questionTitle: widget.questionTitle,
        questionDetail: widget.questionDetail,
        currentSituation: widget.currentSituation,
        desiredClarity: widget.desiredClarity,
        onFreeQuestionChanged: widget.onFreeQuestionChanged,
        onQuestionTitleChanged: widget.onQuestionTitleChanged,
        onQuestionDetailChanged: widget.onQuestionDetailChanged,
        onCurrentSituationChanged: widget.onCurrentSituationChanged,
        onDesiredClarityChanged: widget.onDesiredClarityChanged,
      ),
    );
    final querentStep = _TarotStepPanel(
      title: '4 상담 정보',
      subtitle: '필요한 만큼만 참고 정보를 적어둡니다.',
      useUnifiedIntakeFrame: true,
      child: _TarotQuerentInputPanel(
        querentAlias: widget.querentAlias,
        querentRelationship: widget.querentRelationship,
        querentBirthNote: widget.querentBirthNote,
        sessionContext: widget.sessionContext,
        sensitivityNote: widget.sensitivityNote,
        onQuerentAliasChanged: widget.onQuerentAliasChanged,
        onQuerentRelationshipChanged: widget.onQuerentRelationshipChanged,
        onQuerentBirthNoteChanged: widget.onQuerentBirthNoteChanged,
        onSessionContextChanged: widget.onSessionContextChanged,
        onSensitivityNoteChanged: widget.onSensitivityNoteChanged,
      ),
    );
    final summaryStep = _TarotStepPanel(
      title: '5 질문 요약',
      subtitle: '리딩을 시작하기 전 질문과 상담 맥락을 확인합니다.',
      useUnifiedIntakeFrame: true,
      child: _TarotIntakeSummaryPanel(
        category: widget.selectedQuestionCategory,
        freeQuestion: widget.freeQuestion,
        questionTitle: widget.questionTitle,
        questionDetail: widget.questionDetail,
        currentSituation: widget.currentSituation,
        desiredClarity: widget.desiredClarity,
        querentAlias: widget.querentAlias,
        querentRelationship: widget.querentRelationship,
        sessionContext: widget.sessionContext,
        sensitivityNote: widget.sensitivityNote,
        onContinue: () => _goToStep(5),
      ),
    );
    final deckStep = _TarotStepPanel(
      title: '2 덱 선택',
      subtitle: '상담 분위기에 맞는 덱을 고르세요.',
      child: _TarotDeckChoiceSection(
        title: '',
        decks: widget.decks,
        selectedDeckId: widget.selectedDeckId,
        onSelected: widget.onDeckSelected,
      ),
    );
    final detailStep = _TarotStepPanel(
      title: '3 카드 세부 설정',
      subtitle: '카드 뒷면, 스프레드, 방향, 자리 이름을 정합니다.',
      child: _TarotCardDetailSetupLayout(
        cardBacks: widget.cardBacks,
        selectedCardBackId: widget.selectedCardBackId,
        onCardBackSelected: widget.onCardBackSelected,
        tableCloths: widget.tableCloths,
        selectedTableClothId: widget.selectedTableClothId,
        onTableClothSelected: widget.onTableClothSelected,
        freeSpreads: widget.freeSpreads,
        fixedSpreads: widget.fixedSpreads,
        selectedSpread: widget.selectedSpread,
        onSpreadSelected: widget.onSpreadSelected,
        directionMode: widget.directionMode,
        onDirectionModeSelected: widget.onDirectionModeSelected,
        positionLabels: widget.positionLabels,
        defaultPositionLabels: widget.defaultPositionLabels,
        onPositionLabelChanged: widget.onPositionLabelChanged,
        selectedFreeDrawCount: widget.selectedFreeDrawCount,
        onFreeDrawCountChanged: widget.onFreeDrawCountChanged,
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
        readingContext: widget.readingContext,
      ),
    );
    final steps = [
      introStep,
      categoryStep,
      questionStep,
      querentStep,
      summaryStep,
      deckStep,
      detailStep,
      drawStep,
    ];
    final stepIndex = widget.stepIndex.clamp(0, steps.length - 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 2),
        Row(
          children: [
            OutlinedButton.icon(
              style: _tarotOutlinedSetupActionStyle(context),
              onPressed: stepIndex == 0 ? null : () => _goToStep(stepIndex - 1),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('이전'),
            ),
            const Spacer(),
            if (stepIndex < steps.length - 1)
              FilledButton.icon(
                style: _tarotFilledSetupActionStyle(context),
                onPressed: () => _goToStep(stepIndex + 1),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('다음'),
              )
            else
              _TarotSmallBadge('준비 완료 후 셔플하거나 자동으로 펼치세요'),
          ],
        ),
        const SizedBox(height: 12),
        KeyedSubtree(
          key: Key('tarot-active-setup-step-$stepIndex'),
          child: steps[stepIndex],
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
    this.useUnifiedIntakeFrame = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool useUnifiedIntakeFrame;

  @override
  Widget build(BuildContext context) {
    final isIntakeRoom = useUnifiedIntakeFrame;
    final panelGradient = isIntakeRoom
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              RynPalette.tarotPageShell(context),
              RynPalette.tarotReadingStage(context),
              RynPalette.tarotBentoPanel(context),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              RynPalette.tarotNavy,
              Color(0xFF1A1D2A),
              RynPalette.tarotPanel,
            ],
          );
    final titleColor = isIntakeRoom
        ? RynPalette.tarotTextPrimary(context)
        : RynPalette.tarotIvory;
    final subtitleColor = isIntakeRoom
        ? RynPalette.tarotTextSecondary(context)
        : RynPalette.tarotMist;
    final borderColor = isIntakeRoom
        ? RynPalette.tarotPurpleAccent(context).withValues(alpha: 0.18)
        : RynPalette.tarotGold.withValues(alpha: 0.18);
    final stageBody = isIntakeRoom
        ? _TarotUnifiedIntakeStageFrame(child: child)
        : _TarotReadingTableTheme(child: child);

    return Container(
      key: Key(
        isIntakeRoom
            ? 'tarot-light-intake-shell-surface'
            : 'tarot-dark-reading-table-surface',
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: panelGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isIntakeRoom ? 0.08 : 0.30),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          stageBody,
        ],
      ),
    );
  }
}

class _TarotUnifiedIntakeStageFrame extends StatelessWidget {
  const _TarotUnifiedIntakeStageFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final height = wide ? 540.0 : 680.0;
        return SizedBox(
          key: const Key('tarot-unified-intake-stage-frame'),
          height: height,
          child: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

ButtonStyle _tarotFilledActionStyle([BuildContext? context]) {
  final gold = context == null
      ? RynPalette.tarotGold
      : RynPalette.tarotGoldAccent(context);
  return FilledButton.styleFrom(
    // TAROT-TABLE-CHROME-POLISH1: primary reading-table action hierarchy.
    backgroundColor: gold,
    foregroundColor: RynPalette.tarotMidnight,
    disabledBackgroundColor: RynPalette.tarotMist.withValues(alpha: 0.18),
    disabledForegroundColor: RynPalette.tarotMist.withValues(alpha: 0.58),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    textStyle: const TextStyle(
      fontWeight: FontWeight.w900,
      letterSpacing: -0.1,
    ),
  );
}

ButtonStyle _tarotOutlinedActionStyle([BuildContext? context]) {
  final gold = context == null
      ? RynPalette.tarotGold
      : RynPalette.tarotGoldAccent(context);
  return OutlinedButton.styleFrom(
    // TAROT-TABLE-CHROME-POLISH1: secondary actions stay dark translucent.
    foregroundColor: RynPalette.tarotIvory,
    backgroundColor: RynPalette.tarotMidnight.withValues(alpha: 0.34),
    disabledForegroundColor: RynPalette.tarotMist.withValues(alpha: 0.50),
    side: BorderSide(color: gold.withValues(alpha: 0.36)),
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
    textStyle: const TextStyle(
      fontWeight: FontWeight.w900,
      letterSpacing: -0.1,
    ),
  );
}

ButtonStyle _tarotTextActionStyle() {
  return TextButton.styleFrom(
    foregroundColor: RynPalette.tarotIvory,
    disabledForegroundColor: RynPalette.tarotMist.withValues(alpha: 0.46),
    textStyle: const TextStyle(
      fontWeight: FontWeight.w900,
      letterSpacing: -0.1,
    ),
  );
}

ButtonStyle _tarotCompactFilledActionStyle([BuildContext? context]) {
  final gold = context == null
      ? RynPalette.tarotGold
      : RynPalette.tarotGoldAccent(context);
  return FilledButton.styleFrom(
    backgroundColor: gold,
    foregroundColor: RynPalette.tarotMidnight,
    disabledBackgroundColor: RynPalette.tarotMist.withValues(alpha: 0.18),
    disabledForegroundColor: RynPalette.tarotMist.withValues(alpha: 0.56),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    minimumSize: const Size(0, 34),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}

ButtonStyle _tarotCompactOutlinedActionStyle([BuildContext? context]) {
  final gold = context == null
      ? RynPalette.tarotGold
      : RynPalette.tarotGoldAccent(context);
  return OutlinedButton.styleFrom(
    foregroundColor: RynPalette.tarotIvory,
    backgroundColor: RynPalette.tarotMidnight.withValues(alpha: 0.34),
    disabledForegroundColor: RynPalette.tarotMist.withValues(alpha: 0.50),
    side: BorderSide(color: gold.withValues(alpha: 0.34)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    minimumSize: const Size(0, 34),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}

ButtonStyle _tarotCompactTextActionStyle() {
  return TextButton.styleFrom(
    foregroundColor: RynPalette.tarotIvory,
    disabledForegroundColor: RynPalette.tarotMist.withValues(alpha: 0.48),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    minimumSize: const Size(0, 34),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}

ButtonStyle _tarotFilledSetupActionStyle(BuildContext context) {
  return FilledButton.styleFrom(
    backgroundColor: RynPalette.tarotGoldAccent(context),
    foregroundColor: RynPalette.tarotMidnight,
    disabledBackgroundColor: RynPalette.tarotBorder(
      context,
    ).withValues(alpha: 0.72),
    disabledForegroundColor: RynPalette.tarotTextSecondary(context),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}

ButtonStyle _tarotOutlinedSetupActionStyle(BuildContext context) {
  return OutlinedButton.styleFrom(
    foregroundColor: RynPalette.tarotTextPrimary(context),
    disabledForegroundColor: RynPalette.tarotTextSecondary(
      context,
    ).withValues(alpha: 0.45),
    side: BorderSide(
      color: RynPalette.tarotTextSecondary(context).withValues(alpha: 0.22),
    ),
    textStyle: const TextStyle(fontWeight: FontWeight.w700),
  );
}

class _TarotIntroPanel extends StatelessWidget {
  const _TarotIntroPanel({required this.onStart, required this.onSkipToDeck});

  final VoidCallback onStart;
  final VoidCallback onSkipToDeck;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-intro-panel'),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RynPalette.tarotPageShell(context).withValues(alpha: 0.98),
            RynPalette.tarotReadingStage(context).withValues(alpha: 0.96),
            RynPalette.tarotGuidePanel(context).withValues(alpha: 0.84),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: RynPalette.tarotGoldAccent(context).withValues(alpha: 0.34),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -24,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white.withValues(alpha: 0.08),
              size: 160,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                key: Key('tarot-setup-guidance-layout'),
                width: 1,
                height: 1,
              ),
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: RynPalette.tarotGoldAccent(
                        context,
                      ).withValues(alpha: 0.18),
                      border: Border.all(
                        color: RynPalette.tarotGoldAccent(
                          context,
                        ).withValues(alpha: 0.52),
                      ),
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      color: RynPalette.tarotGoldAccent(context),
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const _TarotSmallBadge('오늘의 리딩 준비', compact: true),
                ],
              ),
              const SizedBox(height: 58),
              Text(
                '오늘의 리딩을 시작합니다',
                style: TextStyle(
                  color: RynPalette.tarotTextPrimary(context),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  '주제를 고르고 질문을 정리한 뒤, 덱을 준비하는 하나의 상담 입장 흐름입니다.\n입력한 내용은 이번 리딩 흐름 안에서만 참고합니다.',
                  style: TextStyle(
                    color: RynPalette.tarotTextSecondary(context),
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _TarotSmallBadge('주제 선택', compact: true),
                  _TarotSmallBadge('질문 정리', compact: true),
                  _TarotSmallBadge('덱 준비', compact: true),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  FilledButton.icon(
                    style: _tarotFilledSetupActionStyle(context),
                    onPressed: onStart,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('질문 시작하기'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    style: _tarotOutlinedSetupActionStyle(context),
                    onPressed: onSkipToDeck,
                    icon: const Icon(Icons.style_rounded, size: 18),
                    label: const Text('바로 덱 선택'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarotCategorySelectionPanel extends StatelessWidget {
  const _TarotCategorySelectionPanel({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<_TarotQuestionCategory> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = categories.firstWhere(
      (category) => category.id == selectedCategoryId,
      orElse: () => categories.first,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 960;
        final spacious = constraints.maxWidth >= 1180;
        final cards = GridView.builder(
          key: const Key('tarot-question-category-panel'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: spacious ? 5 : (wide ? 3 : 2),
            crossAxisSpacing: spacious ? 10 : 12,
            mainAxisSpacing: spacious ? 10 : 12,
            mainAxisExtent: spacious ? 88 : null,
            childAspectRatio: wide ? 2.95 : 2.55,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return _TarotCategoryCard(
              category: category,
              selected: selectedCategoryId == category.id,
              onTap: () => onSelected(category.id),
            );
          },
        );
        final guide = _TarotIntakeSectionCard(
          icon: selected.icon,
          title: '${selected.label} 리딩 가이드',
          subtitle: selected.helper,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TarotConsultationNote(
                icon: Icons.lock_clock_rounded,
                text: '가장 궁금한 장면 하나만 떠올리고, 이번 리딩 안에서 차분히 이어갑니다.',
              ),
            ],
          ),
        );
        return wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 8, child: cards),
                  const SizedBox(width: 14),
                  Expanded(flex: 3, child: guide),
                ],
              )
            : Column(children: [cards, const SizedBox(height: 14), guide]);
      },
    );
  }
}

class _TarotCategoryCard extends StatelessWidget {
  const _TarotCategoryCard({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final _TarotQuestionCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('tarot-question-category-${category.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    RynPalette.tarotSelectedPanel(
                      context,
                    ).withValues(alpha: 0.96),
                    RynPalette.tarotGuidePanel(context).withValues(alpha: 0.86),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    RynPalette.tarotBentoPanel(context).withValues(alpha: 0.96),
                    RynPalette.tarotReadingStage(
                      context,
                    ).withValues(alpha: 0.72),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? RynPalette.tarotGoldAccent(context).withValues(alpha: 0.74)
                : RynPalette.tarotPurpleAccent(context).withValues(alpha: 0.16),
            width: selected ? 1.3 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: RynPalette.tarotGoldAccent(
                      context,
                    ).withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? RynPalette.tarotGoldAccent(
                        context,
                      ).withValues(alpha: 0.14)
                    : RynPalette.tarotPurpleAccent(
                        context,
                      ).withValues(alpha: 0.12),
              ),
              child: Icon(
                category.icon,
                color: selected
                    ? RynPalette.tarotGoldAccent(context)
                    : RynPalette.tarotPurpleAccent(context),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.label,
                    style: TextStyle(
                      color: selected
                          ? RynPalette.tarotTextPrimary(context)
                          : RynPalette.tarotTextPrimary(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.helper,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? RynPalette.tarotTextSecondary(context)
                          : RynPalette.tarotTextSecondary(context),
                      fontSize: 11,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarotQuestionInputPanel extends StatelessWidget {
  const _TarotQuestionInputPanel({
    required this.freeQuestion,
    required this.questionTitle,
    required this.questionDetail,
    required this.currentSituation,
    required this.desiredClarity,
    required this.onFreeQuestionChanged,
    required this.onQuestionTitleChanged,
    required this.onQuestionDetailChanged,
    required this.onCurrentSituationChanged,
    required this.onDesiredClarityChanged,
  });

  final String freeQuestion;
  final String questionTitle;
  final String questionDetail;
  final String currentSituation;
  final String desiredClarity;
  final ValueChanged<String> onFreeQuestionChanged;
  final ValueChanged<String> onQuestionTitleChanged;
  final ValueChanged<String> onQuestionDetailChanged;
  final ValueChanged<String> onCurrentSituationChanged;
  final ValueChanged<String> onDesiredClarityChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final left = KeyedSubtree(
          key: const Key('tarot-free-question-hero-surface'),
          child: _TarotIntakeSectionCard(
            icon: Icons.mode_edit_outline_rounded,
            title: '떠오른 질문 그대로',
            subtitle: '먼저 자연어로 적고, 아래에서 한 줄로 정리해요.',
            child: Column(
              children: [
                _TarotIntakeTextField(
                  fieldKey: const Key('tarot-free-question-input'),
                  label: '자유 질문',
                  hint: '예: 지금 내 마음이 가장 먼저 묻고 싶은 것은?',
                  initialValue: freeQuestion,
                  onChanged: onFreeQuestionChanged,
                  minLines: 3,
                  helperText: '떠오르는 질문을 그대로 적어도 좋아요.',
                ),
                const SizedBox(height: 12),
                _TarotIntakeTextField(
                  fieldKey: const Key('tarot-question-title-input'),
                  label: '질문 한 줄',
                  hint: '예: 이번 선택에서 가장 중요한 기준은?',
                  initialValue: questionTitle,
                  onChanged: onQuestionTitleChanged,
                ),
                const SizedBox(height: 12),
                _TarotIntakeTextField(
                  fieldKey: const Key('tarot-question-detail-input'),
                  label: '자세한 질문',
                  hint: '상황과 궁금한 점을 조금 더 적어주세요.',
                  initialValue: questionDetail,
                  onChanged: onQuestionDetailChanged,
                  minLines: 4,
                ),
              ],
            ),
          ),
        );
        final right = _TarotIntakeSectionCard(
          icon: Icons.center_focus_strong_rounded,
          title: '현재 흐름과 초점',
          subtitle: '지금 놓인 상황과 가장 보고 싶은 지점을 나눠 적어요.',
          child: Column(
            children: [
              _TarotIntakeTextField(
                fieldKey: const Key('tarot-question-current-situation-input'),
                label: '현재 상황',
                hint: '지금 놓인 상황을 짧게 정리해요.',
                initialValue: currentSituation,
                onChanged: onCurrentSituationChanged,
                minLines: 3,
              ),
              const SizedBox(height: 12),
              _TarotIntakeTextField(
                fieldKey: const Key('tarot-question-desired-clarity-input'),
                label: '알고 싶은 핵심',
                hint: '가장 선명하게 보고 싶은 지점',
                initialValue: desiredClarity,
                onChanged: onDesiredClarityChanged,
              ),
            ],
          ),
        );
        return wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 14),
                  Expanded(child: right),
                ],
              )
            : Column(children: [left, const SizedBox(height: 14), right]);
      },
    );
  }
}

class _TarotQuerentInputPanel extends StatelessWidget {
  const _TarotQuerentInputPanel({
    required this.querentAlias,
    required this.querentRelationship,
    required this.querentBirthNote,
    required this.sessionContext,
    required this.sensitivityNote,
    required this.onQuerentAliasChanged,
    required this.onQuerentRelationshipChanged,
    required this.onQuerentBirthNoteChanged,
    required this.onSessionContextChanged,
    required this.onSensitivityNoteChanged,
  });

  final String querentAlias;
  final String querentRelationship;
  final String querentBirthNote;
  final String sessionContext;
  final String sensitivityNote;
  final ValueChanged<String> onQuerentAliasChanged;
  final ValueChanged<String> onQuerentRelationshipChanged;
  final ValueChanged<String> onQuerentBirthNoteChanged;
  final ValueChanged<String> onSessionContextChanged;
  final ValueChanged<String> onSensitivityNoteChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final identity = _TarotIntakeSectionCard(
          icon: Icons.person_outline_rounded,
          title: '내담자 기본 맥락',
          subtitle: '리딩에 도움이 되는 최소 정보만 적습니다.',
          trailing: const _TarotSmallBadge('이번 리딩 안에서만 참고해요', compact: true),
          child: Column(
            children: [
              _TarotIntakeTextField(
                fieldKey: const Key('tarot-querent-alias-input'),
                label: '이름 또는 별칭',
                hint: '예: 린님, 내담자 A',
                initialValue: querentAlias,
                onChanged: onQuerentAliasChanged,
              ),
              const SizedBox(height: 12),
              _TarotIntakeTextField(
                fieldKey: const Key('tarot-querent-relationship-input'),
                label: '나와의 관계',
                hint: '예: 본인, 지인, 상담 대상',
                initialValue: querentRelationship,
                onChanged: onQuerentRelationshipChanged,
              ),
              const SizedBox(height: 12),
              _TarotIntakeTextField(
                fieldKey: const Key('tarot-querent-birth-note-input'),
                label: '나이·생년 참고',
                hint: '필요할 때만 가볍게 적어요.',
                initialValue: querentBirthNote,
                onChanged: onQuerentBirthNoteChanged,
              ),
            ],
          ),
        );
        final contextCard = _TarotIntakeSectionCard(
          icon: Icons.forum_outlined,
          title: '상담 진행 참고',
          subtitle: '오늘 리딩의 톤과 조심할 지점을 미리 정리합니다.',
          child: Column(
            children: [
              _TarotIntakeTextField(
                fieldKey: const Key('tarot-session-context-input'),
                label: '상담 맥락',
                hint: '오늘 리딩이 필요한 배경',
                initialValue: sessionContext,
                onChanged: onSessionContextChanged,
                minLines: 3,
              ),
              const SizedBox(height: 12),
              _TarotIntakeTextField(
                fieldKey: const Key('tarot-sensitivity-note-input'),
                label: '주의할 점',
                hint: '조심스럽게 다뤄야 할 표현이나 상황',
                initialValue: sensitivityNote,
                onChanged: onSensitivityNoteChanged,
                minLines: 2,
              ),
            ],
          ),
        );
        return wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: identity),
                  const SizedBox(width: 14),
                  Expanded(child: contextCard),
                ],
              )
            : Column(
                children: [identity, const SizedBox(height: 14), contextCard],
              );
      },
    );
  }
}

class _TarotIntakeSummaryPanel extends StatelessWidget {
  const _TarotIntakeSummaryPanel({
    required this.category,
    required this.freeQuestion,
    required this.questionTitle,
    required this.questionDetail,
    required this.currentSituation,
    required this.desiredClarity,
    required this.querentAlias,
    required this.querentRelationship,
    required this.sessionContext,
    required this.sensitivityNote,
    required this.onContinue,
  });

  final _TarotQuestionCategory category;
  final String freeQuestion;
  final String questionTitle;
  final String questionDetail;
  final String currentSituation;
  final String desiredClarity;
  final String querentAlias;
  final String querentRelationship;
  final String sessionContext;
  final String sensitivityNote;
  final VoidCallback onContinue;

  String _fallback(String value) =>
      value.trim().isEmpty ? '아직 적지 않았어요' : value.trim();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-reading-intake-receipt-card'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RynPalette.tarotPageShell(context),
            RynPalette.tarotReadingStage(context),
            RynPalette.tarotSummaryPanel(context).withValues(alpha: 0.84),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: RynPalette.tarotGoldAccent(context).withValues(alpha: 0.22),
        ),
        boxShadow: RynPalette.panelShadow(context),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 920;
          final header = Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: RynPalette.tarotGoldAccent(
                    context,
                  ).withValues(alpha: 0.16),
                ),
                child: Icon(
                  category.icon,
                  color: RynPalette.tarotGoldAccent(context),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '리딩 접수 요약',
                      style: TextStyle(
                        color: RynPalette.tarotTextPrimary(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${category.label} · ${category.helper}',
                      style: TextStyle(
                        color: RynPalette.tarotTextSecondary(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final question = _TarotSummaryGroup(
            title: '질문 흐름',
            icon: Icons.help_outline_rounded,
            children: [
              _TarotSummaryPill(label: '자유 질문', value: _fallback(freeQuestion)),
              _TarotSummaryPill(
                label: '질문 한 줄',
                value: _fallback(questionTitle),
              ),
              _TarotSummaryPill(
                label: '자세한 질문',
                value: _fallback(questionDetail),
              ),
              _TarotSummaryPill(
                label: '현재 상황',
                value: _fallback(currentSituation),
              ),
              _TarotSummaryPill(
                label: '알고 싶은 핵심',
                value: _fallback(desiredClarity),
              ),
            ],
          );
          final querent = _TarotSummaryGroup(
            title: '상담 맥락',
            icon: Icons.person_search_rounded,
            children: [
              _TarotSummaryPill(label: '카테고리', value: category.label),
              _TarotSummaryPill(
                label: '이름 또는 별칭',
                value: _fallback(querentAlias),
              ),
              _TarotSummaryPill(
                label: '나와의 관계',
                value: _fallback(querentRelationship),
              ),
              _TarotSummaryPill(
                label: '상담 맥락',
                value: _fallback(sessionContext),
              ),
              _TarotSummaryPill(
                label: '주의할 점',
                value: _fallback(sensitivityNote),
              ),
            ],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              const SizedBox(height: 16),
              wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: question),
                        const SizedBox(width: 14),
                        Expanded(child: querent),
                      ],
                    )
                  : Column(
                      children: [question, const SizedBox(height: 14), querent],
                    ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _TarotConsultationNote(
                      icon: Icons.lock_clock_rounded,
                      text: '입력한 내용은 이번 리딩 흐름 안에서만 참고합니다.',
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    style: _tarotFilledSetupActionStyle(context),
                    onPressed: onContinue,
                    icon: const Icon(Icons.style_rounded),
                    label: const Text('덱과 스프레드 선택하기'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TarotIntakeSectionCard extends StatelessWidget {
  const _TarotIntakeSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RynPalette.tarotBentoPanel(context).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: RynPalette.tarotBorder(context).withValues(alpha: 0.78),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: RynPalette.tarotPurpleAccent(context),
                size: 22,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: RynPalette.tarotTextPrimary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: RynPalette.tarotTextSecondary(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TarotConsultationNote extends StatelessWidget {
  const _TarotConsultationNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: RynPalette.tarotGuidePanel(context).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RynPalette.tarotPurpleAccent(context).withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: RynPalette.tarotPurpleAccent(context), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: RynPalette.tarotTextSecondary(context),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarotIntakeTextField extends StatelessWidget {
  const _TarotIntakeTextField({
    required this.fieldKey,
    required this.label,
    required this.hint,
    required this.initialValue,
    required this.onChanged,
    this.minLines = 1,
    this.helperText,
  });

  final Key fieldKey;
  final String label;
  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final int minLines;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      initialValue: initialValue,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : 5,
      onChanged: onChanged,
      style: TextStyle(
        color: RynPalette.tarotTextPrimary(context),
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText ?? (minLines > 1 ? '필요한 만큼만 짧게 적어도 좋아요.' : null),
        filled: true,
        fillColor: RynPalette.tarotInputField(context),
        labelStyle: TextStyle(
          color: RynPalette.tarotTextSecondary(context),
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: RynPalette.tarotTextSecondary(context).withValues(alpha: 0.58),
        ),
        helperStyle: TextStyle(
          color: RynPalette.tarotTextSecondary(context).withValues(alpha: 0.70),
        ),
        floatingLabelStyle: TextStyle(
          color: RynPalette.tarotGoldAccent(context),
          fontWeight: FontWeight.w800,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: RynPalette.tarotPurpleAccent(
              context,
            ).withValues(alpha: 0.14),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: RynPalette.tarotGoldAccent(context),
            width: 1.4,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: RynPalette.tarotPurpleAccent(
              context,
            ).withValues(alpha: 0.14),
          ),
        ),
      ),
    );
  }
}

class _TarotSummaryGroup extends StatelessWidget {
  const _TarotSummaryGroup({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RynPalette.tarotBentoPanel(context).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: RynPalette.tarotBorder(context).withValues(alpha: 0.74),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: RynPalette.tarotPurpleAccent(context),
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: RynPalette.tarotTextPrimary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _TarotSummaryPill extends StatelessWidget {
  const _TarotSummaryPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: RynPalette.tarotBentoPanelSoft(context).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: RynPalette.tarotBorder(context).withValues(alpha: 0.56),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: RynPalette.tarotTextSecondary(context),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: RynPalette.tarotTextPrimary(context),
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarotCardDetailSetupLayout extends StatelessWidget {
  const _TarotCardDetailSetupLayout({
    required this.cardBacks,
    required this.selectedCardBackId,
    required this.onCardBackSelected,
    required this.tableCloths,
    required this.selectedTableClothId,
    required this.onTableClothSelected,
    required this.freeSpreads,
    required this.fixedSpreads,
    required this.selectedSpread,
    required this.onSpreadSelected,
    required this.directionMode,
    required this.onDirectionModeSelected,
    required this.positionLabels,
    required this.defaultPositionLabels,
    required this.onPositionLabelChanged,
    required this.selectedFreeDrawCount,
    required this.onFreeDrawCountChanged,
  });

  final List<_TarotCardBackDefinition> cardBacks;
  final String selectedCardBackId;
  final ValueChanged<String> onCardBackSelected;
  final List<_TarotTableClothDefinition> tableCloths;
  final String selectedTableClothId;
  final ValueChanged<String> onTableClothSelected;
  final List<_TarotSpreadDefinition> freeSpreads;
  final List<_TarotSpreadDefinition> fixedSpreads;
  final String selectedSpread;
  final ValueChanged<String> onSpreadSelected;
  final _TarotDirectionMode directionMode;
  final ValueChanged<_TarotDirectionMode> onDirectionModeSelected;
  final List<String> positionLabels;
  final List<String> defaultPositionLabels;
  final void Function(int index, String value) onPositionLabelChanged;
  final int selectedFreeDrawCount;
  final ValueChanged<int> onFreeDrawCountChanged;

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
            _TarotTableClothChoiceSection(
              cloths: tableCloths,
              selectedClothId: selectedTableClothId,
              onSelected: onTableClothSelected,
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
            if (selectedSpread == '자유 드로우') ...[
              const SizedBox(height: 14),
              _TarotFreeDrawCountSelector(
                selectedCount: selectedFreeDrawCount,
                onChanged: onFreeDrawCountChanged,
              ),
            ],
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
            color: RynPalette.tarotReadingStage(context),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: RynPalette.tarotBorder(context).withValues(alpha: 0.70),
            ),
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

class _TarotFreeDrawCountSelector extends StatelessWidget {
  const _TarotFreeDrawCountSelector({
    required this.selectedCount,
    required this.onChanged,
  });

  final int selectedCount;
  final ValueChanged<int> onChanged;

  static const List<int> _quickCounts = [1, 3, 5, 7, 10, 13, 22];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-free-draw-count-selector'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RynPalette.tarotBentoPanel(context),
        borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
        border: Border.all(
          color: RynPalette.tarotBorder(context).withValues(alpha: 0.72),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.style_rounded,
                size: 18,
                color: RynPalette.tarotPurpleAccent(context),
              ),
              const SizedBox(width: 8),
              Text(
                '카드 수',
                style: TextStyle(
                  color: RynPalette.tarotTextPrimary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              _TarotSmallBadge('$selectedCount장', compact: true),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '몇 장을 펼칠까요? 자유 드로우는 원하는 장수만큼 카드를 펼칠 수 있습니다.',
            style: TextStyle(
              color: RynPalette.tarotTextSecondary(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final count in _quickCounts)
                ChoiceChip(
                  key: Key('tarot-free-draw-count-option-$count'),
                  label: Text('$count'),
                  selected: selectedCount == count,
                  onSelected: (_) => onChanged(count),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton.outlined(
                key: const Key('tarot-free-draw-count-minus'),
                tooltip: '카드 수 줄이기',
                onPressed: selectedCount <= 1
                    ? null
                    : () => onChanged(selectedCount - 1),
                icon: const Icon(Icons.remove_rounded),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$selectedCount / 30',
                  key: const Key('tarot-free-draw-count-current'),
                  style: TextStyle(
                    color: RynPalette.tarotTextPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton.outlined(
                key: const Key('tarot-free-draw-count-plus'),
                tooltip: '카드 수 늘리기',
                onPressed: selectedCount >= 30
                    ? null
                    : () => onChanged(selectedCount + 1),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
      ),
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
        color: RynPalette.tarotBentoPanel(context),
        borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
        border: Border.all(
          color: RynPalette.tarotBorder(context).withValues(alpha: 0.72),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: 18,
                color: RynPalette.tarotPurpleAccent(context),
              ),
              const SizedBox(width: 8),
              Text(
                UserText.tarotPositionSetup,
                style: TextStyle(
                  color: RynPalette.tarotTextPrimary(context),
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
              color: RynPalette.tarotTextSecondary(context),
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
                          fillColor: RynPalette.tarotInputField(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: RynPalette.tarotBorder(
                                context,
                              ).withValues(alpha: 0.72),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: RynPalette.tarotBorder(
                                context,
                              ).withValues(alpha: 0.72),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: RynPalette.tarotPurpleAccent(context),
                              width: 1.4,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: RynPalette.tarotTextPrimary(context),
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

class _TarotTableChromeBar extends StatelessWidget {
  const _TarotTableChromeBar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // TAROT-TABLE-CHROME-POLISH1: shared premium table toolbar family.
    return Container(
      key: const Key('tarot-table-chrome-polish-marker'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: RynPalette.tarotMidnight.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.095)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }
}

class _TarotStatusChip extends StatelessWidget {
  const _TarotStatusChip(this.label, {this.completed = false});

  final String label;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    // TAROT-TABLE-CHROME-POLISH1: compact status chip grammar.
    return Container(
      key: const Key('tarot-status-chip-unified'),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: RynPalette.tarotMidnight.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
        border: Border.all(
          color: completed
              ? RynPalette.tarotGoldAccent(context).withValues(alpha: 0.44)
              : Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: completed
                  ? RynPalette.tarotGoldAccent(context)
                  : RynPalette.tarotPurpleAccent(
                      context,
                    ).withValues(alpha: 0.72),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: completed ? RynPalette.tarotIvory : RynPalette.tarotMist,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.05,
            ),
          ),
        ],
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
                      color: RynPalette.tarotPurpleAccent(
                        context,
                      ).withValues(alpha: particle.alpha),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: RynPalette.tarotPurpleAccent(
                            context,
                          ).withValues(alpha: particle.alpha),
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

class _TarotReadingContextRibbon extends StatelessWidget {
  const _TarotReadingContextRibbon({required this.readingContext});

  final _TarotReadingContext readingContext;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _TarotContextChip(
        icon: readingContext.category.icon,
        label: '이번 리딩의 주제',
        value: readingContext.category.label,
      ),
      if (readingContext.alias.isNotEmpty)
        _TarotContextChip(
          icon: Icons.person_outline_rounded,
          label: '함께 볼 점',
          value: readingContext.alias,
        ),
      if (readingContext.caution.isNotEmpty)
        _TarotContextChip(
          icon: Icons.visibility_outlined,
          label: '주의해서 볼 점',
          value: readingContext.caution,
        ),
    ];
    return Container(
      key: const Key('tarot-reading-context-ribbon'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        // TAROT-TABLE-CHROME-POLISH1: context ribbon retained, readable, subdued.
        color: RynPalette.tarotMidnight.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.085)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 18,
                color: RynPalette.tarotGoldAccent(
                  context,
                ).withValues(alpha: 0.86),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 질문',
                      style: TextStyle(
                        color: RynPalette.tarotPurpleAccent(
                          context,
                        ).withValues(alpha: 0.94),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      readingContext.quotedQuestion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        height: 1.28,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 6, children: chips),
        ],
      ),
    );
  }
}

class _TarotContextChip extends StatelessWidget {
  const _TarotContextChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.075)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: RynPalette.tarotPurpleAccent(context)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$label · $value',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: RynPalette.tarotPurpleAccent(
                  context,
                ).withValues(alpha: 0.96),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
          ),
        ],
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
    required this.readingContext,
  });

  final TarotDeckDefinition selectedDeck;
  final String selectedSpread;
  final bool isShuffling;
  final VoidCallback onShuffle;
  final VoidCallback onAutoDraw;
  final _TarotCardBackDefinition cardBack;
  final _TarotReadingContext readingContext;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-ritual-shuffle-stage'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.34, 0.08),
          radius: 1.08,
          colors: [
            RynPalette.tarotGuidePanel(context).withValues(alpha: 0.22),
            RynPalette.tarotGoldAccent(context).withValues(alpha: 0.055),
            RynPalette.tarotReadingStage(context),
            RynPalette.tarotPageShell(context),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: RynPalette.tarotGoldAccent(context).withValues(alpha: 0.18),
        ),
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
                      color: RynPalette.tarotPurpleAccent(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _TarotReadingContextRibbon(readingContext: readingContext),
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
            alignment: wide ? const Alignment(0.42, 0.02) : Alignment.center,
            child: SizedBox(
              key: const Key('tarot-ritual-deck-preview'),
              width: wide ? 400 : 320,
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
                  child: KeyedSubtree(
                    key: const Key('tarot-premium-static-ambient'),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: RadialGradient(
                          center: wide
                              ? const Alignment(0.38, 0.12)
                              : Alignment.center,
                          radius: 0.78,
                          colors: [
                            RynPalette.tarotGoldAccent(
                              context,
                            ).withValues(alpha: 0.095),
                            const Color(0x4A312275),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      key: const Key('tarot-premium-active-ambient'),
                      duration: const Duration(milliseconds: 220),
                      opacity: isShuffling ? 1 : 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: RadialGradient(
                            center: wide
                                ? const Alignment(0.48, 0.16)
                                : Alignment.center,
                            radius: 0.62,
                            colors: [
                              RynPalette.tarotGoldAccent(
                                context,
                              ).withValues(alpha: 0.12),
                              RynPalette.tarotPurpleAccent(
                                context,
                              ).withValues(alpha: 0.07),
                              Colors.transparent,
                            ],
                          ),
                        ),
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
    required this.tableCloth,
    required this.readingContext,
  });

  final TarotDeckDefinition deck;
  final String spread;
  final List<TarotCardDefinition> cards;
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
  final _TarotTableClothDefinition tableCloth;
  final _TarotReadingContext readingContext;

  @override
  Widget build(BuildContext context) {
    final canReveal = selectedCount >= targetCount;
    final remainingToSelect = math.max(0, targetCount - selectedCount);
    final guideText = canReveal ? '카드를 모두 선택했습니다' : '$targetCount장을 골라주세요';
    return Container(
      key: Key('tarot-draw-table-cloth-${tableCloth.id}'),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.62),
          radius: 1.22,
          colors: [
            tableCloth.primary.withValues(
              alpha: _tarotClothPrimaryAlpha(tableCloth) + 0.02,
            ),
            tableCloth.shadow.withValues(
              alpha: _tarotClothShadowAlpha(tableCloth),
            ),
            _tarotClothTableBase(context, tableCloth),
            _tarotClothTableEdge(context, tableCloth),
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
              _TarotTableChromeBar(
                children: [
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
                        color: RynPalette.tarotIvory,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  _TarotStatusChip(
                    '$selectedCount / $targetCount 선택',
                    completed: canReveal,
                  ),
                  _TarotStatusChip('남은 선택 $remainingToSelect장'),
                  OutlinedButton.icon(
                    style: _tarotOutlinedActionStyle(context),
                    onPressed: isShuffling ? null : onAutoDraw,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: const Text(UserText.tarotAutoDraw),
                  ),
                  FilledButton.icon(
                    key: const Key('tarot-show-result-button'),
                    style: _tarotFilledActionStyle(context),
                    onPressed: canReveal ? onShowResult : null,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text(_TarotUiText.showResult),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _TarotReadingContextRibbon(readingContext: readingContext),
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
                        color: RynPalette.tarotPurpleAccent(context),
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
                tableCloth: tableCloth,
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
    required this.tableCloth,
  });

  final List<TarotCardDefinition> cards;
  final Set<int> selectedIndexes;
  final Map<int, int> selectedOrder;
  final bool targetReached;
  final ValueChanged<int> onSelected;
  final _TarotCardBackDefinition cardBack;
  final _TarotTableClothDefinition tableCloth;

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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _isMutedGoldCloth(widget.tableCloth)
                ? const Color(0xFF1D160C)
                : const Color(0xFF070A18),
            _tarotClothTableEdge(context, widget.tableCloth),
            widget.tableCloth.primary.withValues(
              alpha: _isMutedGoldCloth(widget.tableCloth) ? 0.82 : 0.72,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: RynPalette.tarotGoldAccent(context).withValues(alpha: 0.16),
        ),
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
                            widget.tableCloth.shadow.withValues(
                              alpha: _isMutedGoldCloth(widget.tableCloth)
                                  ? 0.22
                                  : 0.16,
                            ),
                            widget.tableCloth.primary.withValues(
                              alpha: _isMutedGoldCloth(widget.tableCloth)
                                  ? 0.12
                                  : 0.075,
                            ),
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
                              color: RynPalette.tarotPurpleAccent(context),
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
                                color: RynPalette.tarotMidnight,
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

class _TarotResultStage extends StatefulWidget {
  const _TarotResultStage({
    required this.spreadDefinition,
    required this.spreadLabel,
    required this.slots,
    required this.drawnCards,
    required this.revealedIndexes,
    required this.revealFxIndexes,
    required this.onRevealCard,
    required this.onRevealAll,
    required this.onInterpret,
    required this.onReset,
    required this.onBack,
    required this.onDirectionToggle,
    required this.cardBack,
    required this.deckLabel,
    required this.tableCloth,
    required this.readingContext,
  });

  final _TarotSpreadDefinition spreadDefinition;
  final String spreadLabel;
  final List<_TarotSlotSpec> slots;
  final List<_DrawnTarotCard> drawnCards;
  final Set<int> revealedIndexes;
  final Set<int> revealFxIndexes;
  final ValueChanged<int> onRevealCard;
  final VoidCallback onRevealAll;
  final ValueChanged<GlobalKey> onInterpret;
  final VoidCallback onReset;
  final VoidCallback onBack;
  final ValueChanged<int> onDirectionToggle;
  final _TarotCardBackDefinition cardBack;
  final String deckLabel;
  final _TarotTableClothDefinition tableCloth;
  final _TarotReadingContext readingContext;

  @override
  State<_TarotResultStage> createState() => _TarotResultStageState();
}

class _TarotResultStageState extends State<_TarotResultStage> {
  // TAROT-READING-IMAGE-EXPORT1-R3-FLICKER-FIX: stable capture key avoids
  // remounting the board RepaintBoundary during card reveal rebuilds.
  final GlobalKey _imageBoundaryKey = GlobalKey(
    debugLabel: 'tarot-result-image-boundary',
  );

  @override
  Widget build(BuildContext context) {
    final allRevealed =
        widget.revealedIndexes.length >= widget.drawnCards.length;
    return KeyedSubtree(
      key: const Key('tarot-reading-workspace'),
      child: Container(
        key: Key('tarot-result-table-cloth-${widget.tableCloth.id}'),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.58),
            radius: 1.18,
            colors: [
              widget.tableCloth.primary.withValues(
                alpha: _tarotClothPrimaryAlpha(widget.tableCloth),
              ),
              widget.tableCloth.shadow.withValues(
                alpha: _tarotClothShadowAlpha(widget.tableCloth),
              ),
              _tarotClothTableBase(context, widget.tableCloth),
              _tarotClothTableEdge(context, widget.tableCloth),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.095)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 34,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _TarotCosmicParticles()),
            Positioned(
              top: 56,
              left: 12,
              right: 12,
              child: IgnorePointer(
                child: _TarotReadingContextRibbon(
                  readingContext: widget.readingContext,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TarotReadingCommandBar(
                  spreadLabel: widget.spreadLabel,
                  allRevealed: allRevealed,
                  onReset: widget.onReset,
                  onBack: widget.onBack,
                  onRevealAll: widget.onRevealAll,
                  onInterpret: () {
                    widget.onInterpret(_imageBoundaryKey);
                  },
                  onSaveImage: () => _saveTarotResultBoardPng(
                    context: context,
                    boundaryKey: _imageBoundaryKey,
                    spreadLabel: widget.spreadLabel,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _TarotSpreadCanvas(
                    spreadDefinition: widget.spreadDefinition,
                    spreadLabel: widget.spreadLabel,
                    slots: widget.slots,
                    drawnCards: widget.drawnCards,
                    revealedIndexes: widget.revealedIndexes,
                    revealFxIndexes: widget.revealFxIndexes,
                    onRevealCard: widget.onRevealCard,
                    onDirectionToggle: widget.onDirectionToggle,
                    showEmptySlots: false,
                    fillAvailable: true,
                    onEmptySlotTap: () {},
                    cardBack: widget.cardBack,
                    deckLabel: widget.deckLabel,
                    tableCloth: widget.tableCloth,
                    captureBoundaryKey: _imageBoundaryKey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _saveTarotResultBoardPng({
  required BuildContext context,
  required GlobalKey boundaryKey,
  required String spreadLabel,
}) async {
  try {
    final bytes = await _captureTarotResultBoardPng(boundaryKey);
    final file = await _writeTarotResultBoardPng(bytes, spreadLabel);
    if (!context.mounted) return;
    _showTarotImageSaveMessage(context, '이미지를 저장했어요: ${file.path}');
  } catch (_) {
    if (!context.mounted) return;
    _showTarotImageSaveMessage(context, '이미지 저장에 실패했어요. 다시 시도해 주세요.');
  }
}

Future<Uint8List> _captureTarotResultBoardPng(GlobalKey boundaryKey) async {
  // TAROT-READING-IMAGE-EXPORT1: PNG save captures only the visible result board boundary.
  final renderObject = boundaryKey.currentContext?.findRenderObject();
  if (renderObject is! RenderRepaintBoundary) {
    throw StateError('result image boundary is not ready');
  }
  final image = await renderObject.toImage(pixelRatio: 2);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  if (byteData == null) {
    throw StateError('result image bytes are empty');
  }
  return byteData.buffer.asUint8List();
}

Future<File> _writeTarotResultBoardPng(
  Uint8List bytes,
  String spreadLabel,
) async {
  final directory = await _tarotImageSaveDirectory();
  await directory.create(recursive: true);
  final filename =
      'tarot_result_${_safeTarotFilenamePart(spreadLabel)}_${_tarotTimestamp()}.png';
  final file = File('${directory.path}${Platform.pathSeparator}$filename');
  return file.writeAsBytes(bytes, flush: true);
}

Future<Directory> _tarotImageSaveDirectory() async {
  final home =
      Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
  if (home == null || home.trim().isEmpty) {
    return Directory.current;
  }
  return Directory(
    '${home.trim()}${Platform.pathSeparator}Downloads${Platform.pathSeparator}Ryn Tarot',
  );
}

String _safeTarotFilenamePart(String value) {
  final normalized = value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  final safe = normalized.replaceAll(RegExp(r'[^a-z0-9가-힣_\-]+'), '');
  return safe.isEmpty ? 'spread' : safe;
}

String _tarotTimestamp() {
  String two(int value) => value.toString().padLeft(2, '0');
  final now = DateTime.now();
  return '${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}${two(now.second)}';
}

void _showTarotImageSaveMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class _TarotReadingCommandBar extends StatelessWidget {
  const _TarotReadingCommandBar({
    required this.spreadLabel,
    required this.allRevealed,
    required this.onReset,
    required this.onBack,
    required this.onRevealAll,
    required this.onInterpret,
    required this.onSaveImage,
  });

  final String spreadLabel;
  final bool allRevealed;
  final VoidCallback onReset;
  final VoidCallback onBack;
  final VoidCallback onRevealAll;
  final VoidCallback onInterpret;
  final VoidCallback onSaveImage;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const Key('tarot-reading-command-bar'),
      child: _TarotTableChromeBar(
        children: [
          TextButton.icon(
            key: const Key('tarot-reading-back-command'),
            style: _tarotCompactTextActionStyle(),
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text(UserText.backToWorkspace),
          ),
          TextButton.icon(
            key: const Key('tarot-reading-reset-command'),
            style: _tarotCompactTextActionStyle(),
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text(UserText.tarotResetDraw),
          ),
          _TarotStatusChip('공개 · $spreadLabel', completed: allRevealed),
          Text(
            allRevealed
                ? _TarotUiText.interpretationPrompt
                : _TarotUiText.revealPrompt,
            style: TextStyle(
              color: RynPalette.tarotPurpleAccent(
                context,
              ).withValues(alpha: 0.92),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          OutlinedButton.icon(
            key: const Key('tarot-reveal-all-button'),
            style: _tarotCompactOutlinedActionStyle(context),
            onPressed: allRevealed ? null : onRevealAll,
            icon: const Icon(Icons.auto_awesome_rounded, size: 16),
            label: const Text(_TarotUiText.revealAll),
          ),
          OutlinedButton.icon(
            key: const Key('tarot-save-result-image-button'),
            style: _tarotCompactOutlinedActionStyle(context),
            onPressed: onSaveImage,
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('이미지 저장'),
          ),
          FilledButton.icon(
            key: const Key('tarot-open-interpretation-button'),
            style: _tarotCompactFilledActionStyle(context),
            onPressed: onInterpret,
            icon: const Icon(Icons.menu_book_rounded, size: 16),
            label: const Text('해석 보기'),
          ),
        ],
      ),
    );
  }
}

class _TarotInterpretationStage extends StatelessWidget {
  const _TarotInterpretationStage({
    required this.spreadLabel,
    required this.drawnCards,
    required this.tableCloth,
    required this.readingContext,
    required this.spreadSnapshotBytes,
    required this.onBackToResult,
    required this.onReset,
  });

  final String spreadLabel;
  final List<_DrawnTarotCard> drawnCards;
  final _TarotTableClothDefinition tableCloth;
  final _TarotReadingContext readingContext;
  final Uint8List? spreadSnapshotBytes;
  final VoidCallback onBackToResult;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('tarot-interpretation-table-cloth-${tableCloth.id}'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.72),
          radius: 1.18,
          colors: [
            tableCloth.primary.withValues(
              alpha: _tarotClothPrimaryAlpha(tableCloth),
            ),
            tableCloth.shadow.withValues(
              alpha: _tarotClothShadowAlpha(tableCloth),
            ),
            _tarotClothTableBase(context, tableCloth),
            _tarotClothTableEdge(context, tableCloth),
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
              _TarotTableChromeBar(
                children: [
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
                  const _TarotStatusChip('해석 패널', completed: true),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '해석 공간',
                          style: TextStyle(
                            color: RynPalette.tarotIvory,
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
                            color: RynPalette.tarotPurpleAccent(context),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TarotInterpretationShell(
                drawnCards: drawnCards,
                tableCloth: tableCloth,
                readingContext: readingContext,
                spreadLabel: spreadLabel,
                spreadSnapshotBytes: spreadSnapshotBytes,
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
    required this.drawnCards,
    required this.tableCloth,
    required this.readingContext,
    required this.spreadLabel,
    required this.spreadSnapshotBytes,
  });

  final List<_DrawnTarotCard> drawnCards;
  final _TarotTableClothDefinition tableCloth;
  final _TarotReadingContext readingContext;
  final String spreadLabel;
  final Uint8List? spreadSnapshotBytes;

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
            RynPalette.tarotBentoPanelSoft(context).withValues(alpha: 0.94),
            RynPalette.tarotGuidePanel(context).withValues(alpha: 0.62),
            _tarotClothTableEdge(
              context,
              tableCloth,
            ).withValues(alpha: _isMutedGoldCloth(tableCloth) ? 0.20 : 0.18),
          ],
        ),
        borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
        border: Border.all(
          color: RynPalette.tarotGoldAccent(context).withValues(alpha: 0.24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        key: const Key('tarot-interpretation-workspace-shell'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            key: Key('tarot-interpretation-story-workspace'),
            width: 0,
            height: 0,
          ),
          const SizedBox(
            key: Key('tarot-interpretation-deduped-question-context'),
            width: 0,
            height: 0,
          ),
          const SizedBox(
            key: Key('tarot-interpretation-expanded-workspace'),
            width: 0,
            height: 0,
          ),
          const SizedBox(
            key: Key('tarot-interpretation-font-audit'),
            width: 0,
            height: 0,
          ),
          Row(
            children: [
              Icon(
                Icons.auto_stories_rounded,
                size: 18,
                color: RynPalette.tarotGoldAccent(context),
              ),
              const SizedBox(width: 8),
              const Text(
                '스토리 해석 공간',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 10),
              _TarotStatusChip(spreadLabel, completed: true),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '전체 스프레드를 한 장면으로 보고, 질문과 연결되는 리딩 스토리를 정리하세요.',
            style: TextStyle(
              color: RynPalette.tarotPurpleAccent(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final spreadPreview = _TarotInterpretationSpreadPreview(
                tableCloth: tableCloth,
                snapshotBytes: spreadSnapshotBytes,
              );
              final notesPanel = _TarotInterpretationStoryNotesPanel(
                readingContext: readingContext,
                spreadLabel: spreadLabel,
                cardCount: drawnCards.length,
              );
              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    spreadPreview,
                    const SizedBox(height: 14),
                    notesPanel,
                  ],
                );
              }
              return Row(
                key: const Key('tarot-interpretation-two-column-layout'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: spreadPreview),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: notesPanel),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TarotInterpretationSpreadPreview extends StatelessWidget {
  const _TarotInterpretationSpreadPreview({
    required this.tableCloth,
    required this.snapshotBytes,
  });

  final _TarotTableClothDefinition tableCloth;
  final Uint8List? snapshotBytes;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-interpretation-spread-snapshot-preview'),
      height: 660,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.36),
          radius: 1.08,
          colors: [
            tableCloth.primary.withValues(alpha: 0.28),
            _tarotClothTableBase(context, tableCloth).withValues(alpha: 0.72),
            _tarotClothTableEdge(context, tableCloth),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: RynPalette.tarotGoldAccent(context).withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TarotInterpretationPanelTitle(
            icon: Icons.photo_size_select_large_rounded,
            title: '전체 스프레드 보기',
            subtitle: '결과 보드의 최종 장면을 보며 질문과 연결되는 흐름을 읽어보세요.',
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              key: const Key('tarot-interpretation-whole-spread-reading'),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: snapshotBytes == null
                    ? const _TarotInterpretationSnapshotFallback()
                    : Image.memory(
                        snapshotBytes!,
                        key: const Key('tarot-interpretation-snapshot-image'),
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '각 카드를 자세히 보려면 결과 보드에서 카드를 눌러 집중 보기를 여세요. 여기서는 전체 장면과 흐름을 먼저 읽어주세요.',
            style: TextStyle(
              color: RynPalette.tarotPurpleAccent(context),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarotInterpretationSnapshotFallback extends StatelessWidget {
  const _TarotInterpretationSnapshotFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          '스프레드 이미지를 준비하지 못했습니다. 결과 화면에서 다시 해석 보기를 눌러주세요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: RynPalette.tarotPurpleAccent(context),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _TarotInterpretationStoryNotesPanel extends StatelessWidget {
  const _TarotInterpretationStoryNotesPanel({
    required this.readingContext,
    required this.spreadLabel,
    required this.cardCount,
  });

  final _TarotReadingContext readingContext;
  final String spreadLabel;
  final int cardCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-interpretation-story-notes-panel'),
      constraints: const BoxConstraints(minHeight: 660),
      padding: const EdgeInsets.all(14),
      decoration: _tarotInterpretationPanelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TarotInterpretationContextSummary(
            readingContext: readingContext,
            spreadLabel: '$spreadLabel · $cardCount장',
          ),
          const SizedBox(height: 12),
          const _TarotStoryNoteField(
            title: '전체 이미지 관찰',
            lines: 4,
            hint:
                '전체 배열에서 가장 먼저 눈에 들어온 장면을 적어보세요.\n카드들이 함께 만드는 분위기를 한 문장으로 적어보세요.',
          ),
          const SizedBox(height: 10),
          const _TarotStoryNoteField(
            title: '흐름 해석',
            lines: 5,
            hint: '과거에서 현재, 미래로 이어지는 흐름을 이야기처럼 정리해보세요.\n질문과 연결되는 전환점을 적어보세요.',
          ),
          const SizedBox(height: 10),
          const _TarotStoryNoteField(
            title: '핵심 메시지',
            lines: 3,
            hint: '이번 리딩이 비추는 핵심 문장을 적어보세요.',
          ),
          const SizedBox(height: 10),
          const _TarotStoryNoteField(
            title: '오늘의 조언 / 작은 실천',
            lines: 3,
            hint: '오늘 바로 해볼 수 있는 작은 행동을 적어보세요.',
          ),
          const SizedBox(height: 12),
          const _TarotInterpretationInMemoryNote(),
        ],
      ),
    );
  }
}

class _TarotStoryNoteField extends StatelessWidget {
  const _TarotStoryNoteField({
    required this.title,
    required this.hint,
    required this.lines,
  });

  final String title;
  final String hint;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: Key('tarot-interpretation-story-field-$title'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: RynPalette.tarotGoldAccent(context),
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          minLines: lines,
          maxLines: lines,
          style: const TextStyle(
            color: RynPalette.tarotIvory,
            fontSize: 12.5,
            height: 1.35,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: RynPalette.tarotPurpleAccent(
                context,
              ).withValues(alpha: 0.78),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.18),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: RynPalette.tarotGoldAccent(
                  context,
                ).withValues(alpha: 0.45),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TarotInterpretationInMemoryNote extends StatelessWidget {
  const _TarotInterpretationInMemoryNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-interpretation-in-memory-note'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_clock_rounded,
            size: 16,
            color: RynPalette.tarotGoldAccent(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '작성한 해석은 이 화면을 벗어나면 남지 않습니다. 필요한 내용은 지금 흐름 안에서 정리해 주세요.',
              key: const Key('no-persistence-interpretation-note'),
              style: TextStyle(
                color: RynPalette.tarotPurpleAccent(context),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarotInterpretationContextSummary extends StatelessWidget {
  const _TarotInterpretationContextSummary({
    required this.readingContext,
    required this.spreadLabel,
  });

  final _TarotReadingContext readingContext;
  final String spreadLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-interpretation-context-summary'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: RynPalette.tarotGoldAccent(context).withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 18,
            color: RynPalette.tarotGoldAccent(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 질문',
                  style: TextStyle(
                    color: RynPalette.tarotGoldAccent(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  readingContext.quotedQuestion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RynPalette.tarotIvory,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.28,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TarotInterpretationContextChip(
                      label: '이번 리딩의 주제',
                      value: readingContext.category.label,
                    ),
                    _TarotInterpretationContextChip(
                      label: '스프레드',
                      value: spreadLabel,
                    ),
                    if (readingContext.alias.isNotEmpty)
                      _TarotInterpretationContextChip(
                        label: '상담 대상',
                        value: readingContext.alias,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarotInterpretationContextChip extends StatelessWidget {
  const _TarotInterpretationContextChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('tarot-interpretation-context-chip-$label'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label · ',
              style: TextStyle(
                color: RynPalette.tarotPurpleAccent(context),
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: RynPalette.tarotIvory,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        style: const TextStyle(fontSize: 11.5),
      ),
    );
  }
}

class _TarotInterpretationPanelTitle extends StatelessWidget {
  const _TarotInterpretationPanelTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: RynPalette.tarotGoldAccent(context)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: RynPalette.tarotPurpleAccent(context),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

BoxDecoration _tarotInterpretationPanelDecoration(BuildContext context) {
  return BoxDecoration(
    color: Colors.black.withValues(alpha: 0.16),
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
  );
}

class _TarotDeckChoiceSection extends StatefulWidget {
  const _TarotDeckChoiceSection({
    required this.title,
    required this.decks,
    required this.selectedDeckId,
    required this.onSelected,
  });

  final String title;
  final List<TarotDeckDefinition> decks;
  final String selectedDeckId;
  final ValueChanged<String> onSelected;

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

  String _deckSubtitle(TarotDeckDefinition deck) {
    if (deck.assetBacked) return 'RWS 계열 · ${deck.cardCount}장';
    if (deck.id == 'personal_scan') return '나만의 덱 준비 중';
    if (deck.id == 'oracle') return '오라클 리딩';
    if (deck.id == 'lenormand') return '레노먼드 리딩';
    return '준비 중인 덱';
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
              color: RynPalette.tarotTextPrimary(context),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Text(
          '큰 카드 이미지를 중심으로 오늘의 상담 덱을 고르세요.',
          style: TextStyle(
            color: RynPalette.tarotTextSecondary(context),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          key: const Key('tarot-jukebox-deck-stage'),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.28),
              radius: 1.08,
              colors: [
                RynPalette.tarotGuidePanel(context).withValues(alpha: 0.34),
                RynPalette.tarotReadingStage(context),
                RynPalette.tarotPageShell(context),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: RynPalette.tarotGoldAccent(
                context,
              ).withValues(alpha: 0.18),
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
                                    ? RynPalette.tarotGoldAccent(context)
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
  });

  final TarotDeckDefinition deck;
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
          color: RynPalette.tarotGoldAccent(
            context,
          ).withValues(alpha: hovered ? 0.92 : 0.68),
          width: hovered ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: RynPalette.tarotGoldAccent(
              context,
            ).withValues(alpha: hovered ? 0.34 : 0.24),
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
        side: BorderSide(
          color: RynPalette.tarotGoldAccent(context).withValues(alpha: 0.24),
        ),
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
  });

  final TarotDeckDefinition deck;
  final String subtitle;
  final bool selected;
  final bool hovered;
  final int distanceFromSelected;
  final VoidCallback onTap;
  final ValueChanged<bool> onHoverChanged;

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
        ? RynPalette.tarotGoldAccent(context).withValues(alpha: 0.30)
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
                      child: _TarotRepresentativeDeckArtwork(
                        deck: deck,
                        glowing: selected || hovered,
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
                      color: selected
                          ? Colors.white
                          : RynPalette.tarotPurpleAccent(context),
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
                          ? RynPalette.tarotPurpleAccent(context)
                          : RynPalette.tarotTextSecondary(context),
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

class _TarotRepresentativeDeckArtwork extends StatelessWidget {
  const _TarotRepresentativeDeckArtwork({
    required this.deck,
    required this.glowing,
    required this.width,
    required this.height,
  });

  final TarotDeckDefinition deck;
  final bool glowing;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final representativeAsset =
        deck.coverAssetPath ?? deck.representativeAssetPath;
    if (representativeAsset == null) {
      return _TarotUnavailableDeckPreview(
        glowing: glowing,
        width: width,
        height: height,
      );
    }
    return AnimatedContainer(
      key: const Key('tarot-representative-deck-artwork'),
      duration: const Duration(milliseconds: 220),
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: RynPalette.tarotGoldAccent(
            context,
          ).withValues(alpha: glowing ? 0.86 : 0.46),
        ),
        boxShadow: [
          const BoxShadow(
            color: Color(0x99000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
          if (glowing)
            BoxShadow(
              color: RynPalette.tarotGoldAccent(
                context,
              ).withValues(alpha: 0.22),
              blurRadius: 28,
              spreadRadius: 1,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Image.asset(
          representativeAsset,
          key: const Key('tarot-representative-deck-image'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _TarotUnavailableDeckPreview extends StatelessWidget {
  const _TarotUnavailableDeckPreview({
    required this.glowing,
    required this.width,
    required this.height,
  });

  final bool glowing;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      key: const Key('tarot-unavailable-deck-preview'),
      duration: const Duration(milliseconds: 220),
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RynPalette.tarotBentoPanel(context),
            RynPalette.tarotGuidePanel(context),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: RynPalette.tarotBorder(
            context,
          ).withValues(alpha: glowing ? 0.82 : 0.46),
        ),
        boxShadow: [
          const BoxShadow(
            color: Color(0x99000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
          if (glowing)
            BoxShadow(
              color: RynPalette.tarotGoldAccent(
                context,
              ).withValues(alpha: 0.16),
              blurRadius: 22,
              spreadRadius: 1,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: RynPalette.tarotPageShell(
                  context,
                ).withValues(alpha: 0.36),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_motion_rounded,
                    color: RynPalette.tarotGoldAccent(
                      context,
                    ).withValues(alpha: 0.72),
                    size: width >= 180 ? 34 : 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '준비 중',
                    key: const Key('tarot-unavailable-deck-preview-label'),
                    style: TextStyle(
                      color: RynPalette.tarotTextPrimary(context),
                      fontSize: width >= 180 ? 13 : 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        color: RynPalette.tarotBentoPanel(context),
        borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
        border: Border.all(
          color: RynPalette.tarotBorder(context).withValues(alpha: 0.72),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '카드 뒷면 선택',
            style: TextStyle(
              color: RynPalette.tarotTextPrimary(context),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '드로우와 결과 공개 전 카드에 사용할 이미지를 고르세요.',
            style: TextStyle(
              color: RynPalette.tarotTextSecondary(context),
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
            ? RynPalette.tarotGuidePanel(context).withValues(alpha: 0.78)
            : RynPalette.tarotBentoPanelSoft(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? RynPalette.tarotGoldAccent(context).withValues(alpha: 0.86)
              : RynPalette.tarotBorder(context).withValues(alpha: 0.72),
          width: selected ? 1.4 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: RynPalette.tarotGoldAccent(
                    context,
                  ).withValues(alpha: 0.14),
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
                  // PATCH1: selected card-back labels must stay readable on the
                  // light selected tile; gold remains in the rim/glow, not text.
                  color: RynPalette.tarotTextPrimary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.1,
                  shadows: selected
                      ? [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.65),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarotTableClothChoiceSection extends StatelessWidget {
  const _TarotTableClothChoiceSection({
    required this.cloths,
    required this.selectedClothId,
    required this.onSelected,
  });

  final List<_TarotTableClothDefinition> cloths;
  final String selectedClothId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-table-cloth-selector'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RynPalette.tarotBentoPanel(context),
        borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
        border: Border.all(
          color: RynPalette.tarotBorder(context).withValues(alpha: 0.76),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.texture_rounded,
                size: 18,
                color: RynPalette.tarotPurpleAccent(context),
              ),
              const SizedBox(width: 8),
              Text(
                '리딩 천 색상',
                style: TextStyle(
                  color: RynPalette.tarotTextPrimary(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '질문 분위기에 맞춰 테이블의 색감을 은은하게 바꿉니다.',
            style: TextStyle(
              color: RynPalette.tarotTextSecondary(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final cloth in cloths)
                _TarotTableClothOption(
                  cloth: cloth,
                  selected: cloth.id == selectedClothId,
                  onTap: () => onSelected(cloth.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarotTableClothOption extends StatelessWidget {
  const _TarotTableClothOption({
    required this.cloth,
    required this.selected,
    required this.onTap,
  });

  final _TarotTableClothDefinition cloth;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      key: selected ? Key('tarot-selected-table-cloth-${cloth.id}') : null,
      duration: const Duration(milliseconds: 180),
      width: 172,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cloth.primary.withValues(alpha: selected ? 0.42 : 0.26),
            cloth.secondary.withValues(alpha: selected ? 0.74 : 0.52),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? RynPalette.tarotGoldAccent(context).withValues(alpha: 0.82)
              : Colors.white.withValues(alpha: 0.10),
          width: selected ? 1.4 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: cloth.shadow.withValues(alpha: 0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('tarot-table-cloth-${cloth.id}'),
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        cloth.shadow.withValues(alpha: 0.82),
                        cloth.primary,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cloth.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cloth.intent,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            color: RynPalette.tarotTextPrimary(context),
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
            color: RynPalette.tarotTextSecondary(context),
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
                      ? RynPalette.tarotMidnight
                      : RynPalette.tarotTextPrimary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                selectedColor: RynPalette.tarotGoldAccent(context),
                backgroundColor: RynPalette.tarotBentoPanel(context),
                side: BorderSide(
                  color: RynPalette.tarotBorder(
                    context,
                  ).withValues(alpha: 0.72),
                ),
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
            color: RynPalette.tarotTextPrimary(context),
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

  final TarotDeckDefinition deck;
  final String spread;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RynPalette.tarotBentoPanelSoft(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: RynPalette.tarotBorder(context).withValues(alpha: 0.72),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            UserText.tarotCurrentSelection,
            style: TextStyle(
              color: RynPalette.tarotTextSecondary(context),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${deck.label} · $spread',
            style: TextStyle(
              color: RynPalette.tarotTextPrimary(context),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShuffleDeckStack extends StatefulWidget {
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
  State<_ShuffleDeckStack> createState() => _ShuffleDeckStackState();
}

class _ShuffleDeckStackState extends State<_ShuffleDeckStack> {
  bool _hoverReady = false;

  _ShuffleRitualMotionPhase _phaseFor(double progress) {
    if (!widget.isShuffling) {
      return _hoverReady
          ? _ShuffleRitualMotionPhase.hoverReady
          : _ShuffleRitualMotionPhase.idle; // Still Altar idle
    }
    if (progress < 0.14) return _ShuffleRitualMotionPhase.shuffleStart;
    if (progress < 0.76) {
      return _ShuffleRitualMotionPhase.shuffleActive; // Ritual Cut active
    }
    if (progress < 0.92) {
      return _ShuffleRitualMotionPhase.settle; // Settle signal
    }
    return _ShuffleRitualMotionPhase.transitionToFan;
  }

  double _phaseT(double progress, double begin, double end) {
    return ((progress - begin) / (end - begin)).clamp(0.0, 1.0);
  }

  Offset _ritualCutOffset(int index, double progress) {
    final phase = _phaseFor(progress);
    if (phase == _ShuffleRitualMotionPhase.idle ||
        phase == _ShuffleRitualMotionPhase.hoverReady) {
      return Offset.zero;
    }
    final startLift = Curves.easeOutCubic.transform(_phaseT(progress, 0, 0.14));
    if (phase == _ShuffleRitualMotionPhase.shuffleStart) {
      return Offset(0, -8 * startLift);
    }

    final cutOut = Curves.easeInOutCubic.transform(
      _phaseT(progress, 0.14, 0.42),
    );
    final cross = Curves.easeInOutCubic.transform(
      _phaseT(progress, 0.42, 0.68),
    );
    final settle = Curves.easeOutCubic.transform(_phaseT(progress, 0.68, 0.92));
    final group = index % 3;
    final direction = switch (group) {
      0 => const Offset(-22, -9),
      1 => const Offset(10, -16),
      _ => const Offset(20, 10),
    };
    final crossDrift = switch (group) {
      0 => const Offset(18, 7),
      1 => const Offset(-8, 13),
      _ => const Offset(-14, -6),
    };
    final separated = Offset.lerp(Offset.zero, direction, cutOut)!;
    final crossed = Offset.lerp(separated, crossDrift, cross)!;
    final restored = Offset.lerp(crossed, Offset.zero, settle)!;
    return restored + Offset(0, -8 * (1 - settle));
  }

  double _ritualCutAngle(int index, double progress) {
    final idleAngle = (index - 4) * 0.004;
    final phase = _phaseFor(progress);
    if (phase == _ShuffleRitualMotionPhase.idle ||
        phase == _ShuffleRitualMotionPhase.hoverReady) {
      return idleAngle;
    }
    final cutOut = Curves.easeInOutCubic.transform(
      _phaseT(progress, 0.14, 0.42),
    );
    final settle = Curves.easeOutCubic.transform(_phaseT(progress, 0.68, 0.92));
    final groupAngle = switch (index % 3) {
      0 => -0.052,
      1 => 0.026,
      _ => 0.061,
    };
    return idleAngle + groupAngle * cutOut * (1 - settle);
  }

  double _ritualCutScale(double progress) {
    final phase = _phaseFor(progress);
    if (phase == _ShuffleRitualMotionPhase.idle) return 1;
    if (phase == _ShuffleRitualMotionPhase.hoverReady) return 1.01;
    final lift = Curves.easeOutCubic.transform(_phaseT(progress, 0, 0.16));
    final settle = Curves.easeOutCubic.transform(_phaseT(progress, 0.70, 0.92));
    return 1 + (0.035 * lift * (1 - settle));
  }

  Offset _stableAltarOffset(int index) {
    // tarot-stable-altar-idle-marker
    if (index == 8) return Offset.zero;
    final depth = 8 - index;
    return Offset(depth * 1.25, depth * 1.05);
  }

  double _stableAltarAngle(int index) {
    if (index == 8) return 0;
    return (index - 4) * 0.0014;
  }

  double _stableAltarOpacity(int index) {
    if (index == 8) return 1;
    return 0.28 + index * 0.052;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isShuffling ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) {
        if (!widget.isShuffling) setState(() => _hoverReady = true);
      },
      onExit: (_) {
        if (_hoverReady) setState(() => _hoverReady = false);
      },
      child: GestureDetector(
        onTap: widget.isShuffling ? null : widget.onTap,
        child: TweenAnimationBuilder<double>(
          key: ValueKey(widget.isShuffling),
          tween: Tween(begin: 0, end: widget.isShuffling ? 1 : 0),
          duration: 1080.ms,
          curve: Curves.linear,
          builder: (context, progress, child) {
            final phase = _phaseFor(progress);
            final hoverLift = phase == _ShuffleRitualMotionPhase.hoverReady;
            final hoverOffset = hoverLift
                ? const Offset(0, -0.01)
                : Offset.zero;
            final baseScale = _ritualCutScale(progress);
            return AnimatedSlide(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              offset: hoverOffset,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                scale: baseScale,
                child: child,
              ),
            );
          },
          child: RepaintBoundary(
            key: const Key('tarot-premium-ritual-pile-boundary'),
            child: SizedBox(
              key: const Key('tarot-shuffle-stack'),
              width: widget.large ? 320 : 116,
              height: widget.large ? 430 : 156,
              child: TweenAnimationBuilder<double>(
                key: ValueKey('ritual-cut-${widget.isShuffling}'),
                tween: Tween(begin: 0, end: widget.isShuffling ? 1 : 0),
                duration: 1080.ms,
                curve: Curves.linear,
                builder: (context, progress, _) {
                  final idle = !widget.isShuffling;
                  final phase = _phaseFor(progress);
                  final active =
                      widget.isShuffling &&
                      phase != _ShuffleRitualMotionPhase.transitionToFan;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      for (var index = 8; index >= 0; index--)
                        Positioned(
                          left: widget.large
                              ? (idle ? 58 + index * 1.35 : 42 + index * 4.5)
                              : 14 + index * 2.5,
                          top: widget.large
                              ? (idle ? 34 + index * 1.12 : 20 + index * 4.4)
                              : 10 + index * 2.6,
                          child: Opacity(
                            // opacity: idle ? _stableAltarOpacity(index) : 0.62 + index * 0.035
                            opacity: idle
                                ? _stableAltarOpacity(index)
                                : 0.62 + index * 0.035,
                            child: Transform.translate(
                              // offset: idle ? _stableAltarOffset(index) : _ritualCutOffset(index, progress)
                              offset: widget.large
                                  ? (idle
                                        ? _stableAltarOffset(index)
                                        : _ritualCutOffset(index, progress))
                                  : Offset.zero,
                              child: Transform.rotate(
                                // angle: idle ? _stableAltarAngle(index) : _ritualCutAngle(index, progress)
                                angle: widget.large
                                    ? (idle
                                          ? _stableAltarAngle(index)
                                          : _ritualCutAngle(index, progress))
                                    : (index - 4) * 0.004,
                                child: _TarotCardBack(
                                  compact: false,
                                  glowing: active,
                                  assetPath: widget.cardBack.assetPath,
                                  width: widget.large ? 202 : null,
                                  height: widget.large ? 310 : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (widget.isShuffling)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 220),
                              opacity: active ? 1 : 0,
                              child: const _TarotFxBurst(
                                particleCount: 6,
                                origin: Offset(0.48, 0.46),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
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
    final accent = RynPalette.tarotGoldAccent(context);
    final displayWidth = width ?? (compact ? 58.0 : 86.0);
    final displayHeight = height ?? (compact ? 87.0 : 132.0);
    final highlightOverlay = DecoratedBox(
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
    );
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              assetPath,
              key: const Key('tarot-card-back-image'),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
            if (compact || glowing)
              Shimmer.fromColors(
                enabled: true,
                loop: 1,
                period: const Duration(milliseconds: 1800),
                baseColor: RynPalette.tarotPurpleAccent(
                  context,
                ).withValues(alpha: 0.08),
                highlightColor: Colors.white.withValues(
                  alpha: glowing ? 0.42 : 0.22,
                ),
                child: highlightOverlay,
              )
            else
              highlightOverlay,
          ],
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
    final accent = RynPalette.tarotPurpleAccent(context);
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

class _TarotSpreadCanvas extends StatefulWidget {
  const _TarotSpreadCanvas({
    required this.spreadDefinition,
    required this.spreadLabel,
    required this.slots,
    required this.drawnCards,
    required this.revealedIndexes,
    required this.revealFxIndexes,
    required this.onRevealCard,
    required this.onDirectionToggle,
    required this.onEmptySlotTap,
    required this.cardBack,
    required this.deckLabel,
    required this.tableCloth,
    this.captureBoundaryKey,
    this.showEmptySlots = true,
    this.fillAvailable = false,
  });

  final _TarotSpreadDefinition spreadDefinition;
  final String spreadLabel;
  final List<_TarotSlotSpec> slots;
  final List<_DrawnTarotCard> drawnCards;
  final Set<int> revealedIndexes;
  final Set<int> revealFxIndexes;
  final ValueChanged<int> onRevealCard;
  final ValueChanged<int> onDirectionToggle;
  final VoidCallback onEmptySlotTap;
  final _TarotCardBackDefinition cardBack;
  final String deckLabel;
  final _TarotTableClothDefinition tableCloth;
  final GlobalKey? captureBoundaryKey;
  final bool showEmptySlots;
  final bool fillAvailable;

  @override
  State<_TarotSpreadCanvas> createState() => _TarotSpreadCanvasState();
}

class _TarotSpreadCanvasState extends State<_TarotSpreadCanvas> {
  final Map<int, Offset> _temporaryOffsets = {};
  final Map<int, int> _dragZ = {};
  int _dragSequence = 100;
  bool _adjustmentMode = false;
  int? _hoveredIndex;
  int? _focusedCardIndex;

  bool get _supportsDrag => widget.spreadDefinition.supportsDrag;
  bool get _canMoveCards => _supportsDrag || _adjustmentMode;
  bool get _isDenseSpread =>
      _denseSpreadIds.contains(widget.spreadDefinition.id);
  bool get _isStrictGridSpread =>
      _strictGridSpreadIds.contains(widget.spreadDefinition.id);
  bool get _isCelticCrossSpread =>
      _celticCrossSpreadIds.contains(widget.spreadDefinition.id);

  bool get _shouldShowPersistentCaptions =>
      !_supportsDrag &&
      !_isDenseSpread &&
      !_isStrictGridSpread &&
      !_isCelticCrossSpread &&
      widget.spreadDefinition.canvasStyle != _TarotResultCanvasStyle.radial;

  static const Set<String> _strictGridSpreadIds = {
    'grid_6',
    'grid_8',
    'grid_9',
  };

  static const Set<String> _celticCrossSpreadIds = {
    'mini_celtic_cross',
    'celtic_cross',
    'cross',
    'reading_mind',
    'tandem',
    'relationship',
    'cup_of_relationship',
    'seven_card',
    'binary_choice',
    'horseshoe',
    'horoscope',
    'year_ahead',
  };

  static const Set<String> _denseSpreadIds = {
    'celtic_cross',
    'mini_celtic_cross',
    'cross',
    'seven_card',
    'horseshoe',
    'magic_seven',
    'binary_choice',
    'reading_mind',
    'tandem',
    'relationship',
    'cup_of_relationship',
    'horoscope',
    'year_ahead',
  };

  @override
  void didUpdateWidget(covariant _TarotSpreadCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spreadDefinition.id != widget.spreadDefinition.id ||
        oldWidget.drawnCards.length != widget.drawnCards.length) {
      _temporaryOffsets.clear();
      _dragZ.clear();
      _dragSequence = 100;
      _focusedCardIndex = null;
    }
  }

  Offset _slotOffset(int index) {
    final slot = widget.slots[index];
    return _temporaryOffsets[index] ?? Offset(slot.xRatio, slot.yRatio);
  }

  void _toggleAdjustmentMode() {
    setState(() => _adjustmentMode = !_adjustmentMode);
  }

  void _resetTemporaryLayout() {
    setState(() {
      _temporaryOffsets.clear();
      _dragZ.clear();
      _dragSequence = 100;
      _focusedCardIndex = null;
      _hoveredIndex = null;
    });
  }

  void _setHoveredIndex(int? index) {
    if (_hoveredIndex == index) return;
    setState(() => _hoveredIndex = index);
  }

  void _openFocusedCard(int index) {
    if (!widget.revealedIndexes.contains(index)) return;
    setState(() => _focusedCardIndex = index);
  }

  void _closeFocusedCard() {
    if (_focusedCardIndex == null) return;
    setState(() => _focusedCardIndex = null);
  }

  List<int> _paintOrder() {
    final indexes = List<int>.generate(widget.slots.length, (index) => index);
    indexes.sort((a, b) {
      final zA = widget.slots[a].zIndex + (_dragZ[a] ?? 0);
      final zB = widget.slots[b].zIndex + (_dragZ[b] ?? 0);
      return zA.compareTo(zB);
    });
    return indexes;
  }

  void _startDrag(int index) {
    if (!_canMoveCards) return;
    setState(() {
      _dragSequence += 1;
      _dragZ[index] = _dragSequence;
    });
  }

  void _updateDrag(
    int index,
    DragUpdateDetails details,
    BoxConstraints constraints,
  ) {
    if (!_canMoveCards) return;
    final current = _slotOffset(index);
    final next = Offset(
      (current.dx + details.delta.dx / math.max(1, constraints.maxWidth)).clamp(
        0.02,
        0.98,
      ),
      (current.dy + details.delta.dy / math.max(1, constraints.maxHeight))
          .clamp(0.02, 0.98),
    );
    setState(() => _temporaryOffsets[index] = next);
  }

  _TarotSlotAnchor _effectiveLabelAnchor(_TarotSlotSpec slot, int index) {
    final active = _hoveredIndex == index || _dragZ.containsKey(index);
    if (!active && !_shouldShowPersistentCaptions) {
      return _TarotSlotAnchor.hidden;
    }
    if (!active && _shouldShowPersistentCaptions) {
      return _TarotSlotAnchor.bottom;
    }
    if (slot.labelAnchor != null) return slot.labelAnchor!;
    if (slot.infoAnchor != null) return slot.infoAnchor!;
    if (widget.spreadDefinition.canvasStyle == _TarotResultCanvasStyle.radial) {
      return _radialAnchorForIndex(index);
    }
    if (slot.isHorizontalOverlay) return _TarotSlotAnchor.bottomRight;
    if (slot.yRatio <= 0.18) return _TarotSlotAnchor.bottom;
    if (slot.yRatio >= 0.82) return _TarotSlotAnchor.top;
    if (slot.xRatio <= 0.18) return _TarotSlotAnchor.right;
    if (slot.xRatio >= 0.82) return _TarotSlotAnchor.left;
    if (slot.xRatio < 0.35) return _TarotSlotAnchor.right;
    if (slot.xRatio > 0.65) return _TarotSlotAnchor.left;
    return _TarotSlotAnchor.bottom;
  }

  _TarotSlotAnchor _radialAnchorForIndex(int index) {
    if (index == 0) return _TarotSlotAnchor.inside;
    final slot = widget.slots[index];
    final dx = slot.xRatio - 0.5;
    final dy = slot.yRatio - 0.5;
    if (dy.abs() > dx.abs()) {
      return dy < 0 ? _TarotSlotAnchor.bottom : _TarotSlotAnchor.top;
    }
    return dx < 0 ? _TarotSlotAnchor.right : _TarotSlotAnchor.left;
  }

  Positioned _anchoredLabel({
    required _TarotSlotSpec slot,
    required _TarotSlotAnchor anchor,
    required double slotWidth,
    required double slotHeight,
    required double cardLeft,
    required double cardTop,
    required Size cardSize,
  }) {
    const labelHeight = 26.0;
    // R5 global rule: labels are compact hints, never wide pills over card art.
    final labelWidth = math.min(118.0, math.max(64.0, cardSize.width * 0.72));
    double left = (slotWidth - labelWidth) / 2;
    double top = slotHeight - labelHeight;
    switch (anchor) {
      case _TarotSlotAnchor.top:
        top = 0;
      case _TarotSlotAnchor.bottom:
        top = slotHeight - labelHeight;
      case _TarotSlotAnchor.left:
        left = 0;
        top = cardTop + cardSize.height * 0.42;
      case _TarotSlotAnchor.right:
        left = slotWidth - labelWidth;
        top = cardTop + cardSize.height * 0.42;
      case _TarotSlotAnchor.topLeft:
        left = 0;
        top = 0;
      case _TarotSlotAnchor.topRight:
        left = slotWidth - labelWidth;
        top = 0;
      case _TarotSlotAnchor.bottomLeft:
        left = 0;
        top = slotHeight - labelHeight;
      case _TarotSlotAnchor.bottomRight:
        left = slotWidth - labelWidth;
        top = slotHeight - labelHeight;
      case _TarotSlotAnchor.outside:
        top = slot.yRatio < 0.5 ? slotHeight - labelHeight : 0;
      case _TarotSlotAnchor.inside:
        left = (slotWidth - labelWidth) / 2;
        top = slotHeight - labelHeight;
      case _TarotSlotAnchor.hidden:
        top = -labelHeight;
    }
    return Positioned(
      key: Key(
        'tarot-slot-label-anchor-${anchor.name}-${slot.slotId ?? slot.label}',
      ),
      left: (left + slot.labelOffsetX).clamp(
        0.0,
        math.max(0.0, slotWidth - labelWidth),
      ),
      top: (top + slot.labelOffsetY).clamp(
        0.0,
        math.max(0.0, slotHeight - labelHeight),
      ),
      width: labelWidth,
      height: labelHeight,
      child: _TarotPositionLabel(label: slot.label),
    );
  }

  _StrictGridSpec _strictGridSpec() {
    switch (widget.spreadDefinition.id) {
      case 'grid_6':
        return const _StrictGridSpec(columns: 3, rows: 2);
      case 'grid_8':
        return const _StrictGridSpec(columns: 4, rows: 2);
      case 'grid_9':
        return const _StrictGridSpec(columns: 3, rows: 3);
      default:
        return const _StrictGridSpec(columns: 1, rows: 1);
    }
  }

  _StrictGridMetrics _strictGridMetrics(BoxConstraints constraints) {
    final spec = _strictGridSpec();
    final padding = _boardPaddingForSpread(widget.spreadDefinition);
    final horizontalGap = widget.spreadDefinition.id == 'grid_8' ? 24.0 : 28.0;
    final verticalGap = widget.spreadDefinition.id == 'grid_9' ? 28.0 : 34.0;
    final usableWidth = math.max(
      1.0,
      constraints.maxWidth - padding.horizontal,
    );
    final usableHeight = math.max(
      1.0,
      constraints.maxHeight - padding.vertical,
    );
    final cellWidth = math.max(
      1.0,
      (usableWidth - horizontalGap * (spec.columns - 1)) / spec.columns,
    );
    final cellHeight = math.max(
      1.0,
      (usableHeight - verticalGap * (spec.rows - 1)) / spec.rows,
    );
    return _StrictGridMetrics(
      spec: spec,
      padding: padding,
      horizontalGap: horizontalGap,
      verticalGap: verticalGap,
      cellWidth: cellWidth,
      cellHeight: cellHeight,
    );
  }

  Size _strictGridCardSize(BoxConstraints constraints) {
    final metrics = _strictGridMetrics(constraints);
    final preferredWidth = _preferredCardWidthForSpread(
      widget.spreadDefinition,
      widget.slots.length,
    );
    final minimumWidth = _minimumCardWidthForSpread(
      widget.spreadDefinition,
      widget.slots.length,
    );
    final cellWidthLimit = metrics.cellWidth * 0.92;
    final cellHeightLimit = metrics.cellHeight * 0.92 / 1.62;
    final width = math.max(
      minimumWidth,
      math.min(preferredWidth, math.min(cellWidthLimit, cellHeightLimit)),
    );
    return Size(width, width * 1.62);
  }

  Offset _strictGridCellOffset(int index) {
    final spec = _strictGridSpec();
    final column = index % spec.columns;
    final row = index ~/ spec.columns;
    if (spec.columns == 1 && spec.rows == 1) return const Offset(0.5, 0.5);
    final x = spec.columns == 1 ? 0.5 : column / (spec.columns - 1);
    final y = spec.rows == 1 ? 0.5 : row / (spec.rows - 1);
    return Offset(x, y);
  }

  Rect _strictGridSlotRect({
    required int index,
    required double slotWidth,
    required double slotHeight,
    required BoxConstraints constraints,
  }) {
    final metrics = _strictGridMetrics(constraints);
    final column = index % metrics.spec.columns;
    final row = index ~/ metrics.spec.columns;
    final cellLeft =
        metrics.padding.left +
        column * (metrics.cellWidth + metrics.horizontalGap);
    final cellTop =
        metrics.padding.top + row * (metrics.cellHeight + metrics.verticalGap);
    return Rect.fromLTWH(
      cellLeft + (metrics.cellWidth - slotWidth) / 2,
      cellTop + (metrics.cellHeight - slotHeight) / 2,
      slotWidth,
      slotHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canvasHeight = _canvasHeightForDefinition(widget.spreadDefinition);
    return Container(
      key: Key('tarot-result-layout-${widget.slots.length}'),
      height: widget.fillAvailable ? null : canvasHeight,
      constraints: widget.fillAvailable ? const BoxConstraints.expand() : null,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _isMutedGoldCloth(widget.tableCloth)
                ? RynPalette.tarotReadingStage(context)
                : RynPalette.tarotReadingStage(context),
            RynPalette.tarotSummaryPanel(context),
            widget.tableCloth.primary.withValues(
              alpha: _isMutedGoldCloth(widget.tableCloth) ? 0.18 : 0.26,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
        border: Border.all(
          color: RynPalette.tarotGoldAccent(context).withValues(alpha: 0.13),
        ),
        boxShadow: [
          BoxShadow(
            color: RynPalette.lavenderStrong.withValues(alpha: 0.13),
            blurRadius: 32,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              key: widget.captureBoundaryKey,
              child: KeyedSubtree(
                key: const Key('tarot-result-image-capture-boundary'),
                child: Container(
                  key: Key(
                    _supportsDrag
                        ? 'tarot-free-draw-board'
                        : 'tarot-fixed-spread-board-${widget.spreadDefinition.id}',
                  ),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.18),
                      radius: 0.98,
                      colors: [
                        widget.tableCloth.shadow.withValues(
                          alpha: _isMutedGoldCloth(widget.tableCloth)
                              ? 0.04
                              : 0.06,
                        ),
                        _isMutedGoldCloth(widget.tableCloth)
                            ? RynPalette.tarotInputField(context)
                            : RynPalette.tarotInputField(context),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final baseCardSize = _cardSizeForLayout(
                        widget.slots.length,
                        constraints,
                        widget.spreadDefinition,
                      );
                      const labelHeight = 36.0;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          for (final index in _paintOrder())
                            _buildPositionedSlot(
                              context: context,
                              index: index,
                              constraints: constraints,
                              baseCardSize: baseCardSize,
                              labelHeight: labelHeight,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: _TarotFloatingAdjustmentControls(
              supportsDrag: _supportsDrag,
              adjustmentMode: _adjustmentMode,
              hasTemporaryOffsets: _temporaryOffsets.isNotEmpty,
              onToggle: _toggleAdjustmentMode,
              onReset: _resetTemporaryLayout,
            ),
          ),
          if (_focusedCardIndex case final focusedIndex?
              when focusedIndex < widget.drawnCards.length)
            Positioned.fill(
              child: _TarotFocusedCardOverlay(
                drawnCard: widget.drawnCards[focusedIndex],
                slotLabel: widget.slots[focusedIndex].label,
                deckLabel: widget.deckLabel,
                onClose: _closeFocusedCard,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPositionedSlot({
    required BuildContext context,
    required int index,
    required BoxConstraints constraints,
    required Size baseCardSize,
    required double labelHeight,
  }) {
    final slot = widget.slots[index];
    final usesStrictGridCell =
        _isStrictGridSpread && !_temporaryOffsets.containsKey(index);
    final offset = usesStrictGridCell
        ? _strictGridCellOffset(index)
        : _slotOffset(index);
    final strictGridCardSize = usesStrictGridCell
        ? _strictGridCardSize(constraints)
        : null;
    final cardSize =
        strictGridCardSize ??
        Size(
          baseCardSize.width * slot.widthFactor,
          baseCardSize.height * slot.heightFactor,
        );
    final labelAnchor = usesStrictGridCell
        ? _TarotSlotAnchor.hidden
        : _effectiveLabelAnchor(slot, index);
    // R7: keep the hit/label halo compact so spacing serves the card group,
    // not invisible label gutters. Demand labels may still sit outside the art.
    final labelGutter = usesStrictGridCell
        ? 0.0
        : labelAnchor == _TarotSlotAnchor.hidden
        ? 20.0
        : 70.0;
    final verticalGutter = usesStrictGridCell
        ? 0.0
        : labelAnchor == _TarotSlotAnchor.hidden
        ? 22.0
        : labelHeight + 22.0;
    final slotWidth = cardSize.width + labelGutter;
    final slotHeight = cardSize.height + verticalGutter;
    final cardLeft = (slotWidth - cardSize.width) / 2;
    final cardTop = (slotHeight - cardSize.height) / 2;

    final cardWidget = SizedBox(
      key: usesStrictGridCell
          ? Key('tarot-grid-card-visual-${widget.spreadDefinition.id}-$index')
          : _isCelticCrossSpread
          ? Key('tarot-fixed-card-visual-${widget.spreadDefinition.id}-$index')
          : null,
      width: cardSize.width,
      height: cardSize.height,
      child: index < widget.drawnCards.length
          ? _TarotDrawnCardView(
              drawnCard: widget.drawnCards[index],
              index: index,
              revealed: widget.revealedIndexes.contains(index),
              showRevealFx: widget.revealFxIndexes.contains(index),
              onReveal: () => widget.onRevealCard(index),
              onFocus: () => _openFocusedCard(index),
              onDirectionToggle: widget.onDirectionToggle,
              cardBack: widget.cardBack,
            )
          : widget.showEmptySlots
          ? _TarotEmptySlot(label: slot.label, onTap: widget.onEmptySlotTap)
          : const SizedBox.shrink(),
    );
    final slotBody = SizedBox(
      width: slotWidth,
      height: slotHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: cardLeft, top: cardTop, child: cardWidget),
          if (labelAnchor != _TarotSlotAnchor.hidden)
            _anchoredLabel(
              slot: slot,
              anchor: labelAnchor,
              slotWidth: slotWidth,
              slotHeight: slotHeight,
              cardLeft: cardLeft,
              cardTop: cardTop,
              cardSize: cardSize,
            ),
        ],
      ),
    );

    final draggableSlot = MouseRegion(
      onEnter: (_) => _setHoveredIndex(index),
      onExit: (_) => _setHoveredIndex(null),
      cursor: _canMoveCards
          ? SystemMouseCursors.move
          : SystemMouseCursors.basic,
      child: GestureDetector(
        key: Key(
          _supportsDrag
              ? 'tarot-free-draw-draggable-card-$index'
              : 'tarot-adjustable-result-card-$index',
        ),
        behavior: HitTestBehavior.translucent,
        onPanStart: _canMoveCards ? (_) => _startDrag(index) : null,
        onPanUpdate: _canMoveCards
            ? (details) => _updateDrag(index, details, constraints)
            : null,
        child: slotBody,
      ),
    );

    final transformed = Transform.rotate(
      angle: slot.rotationDeg * math.pi / 180,
      child: draggableSlot,
    );

    final gridSlotRect = usesStrictGridCell
        ? _strictGridSlotRect(
            index: index,
            slotWidth: slotWidth,
            slotHeight: slotHeight,
            constraints: constraints,
          )
        : null;

    return Positioned(
      key: Key('tarot-result-slot-${widget.slots.length}-$index'),
      left:
          gridSlotRect?.left ?? (constraints.maxWidth - slotWidth) * offset.dx,
      top:
          gridSlotRect?.top ?? (constraints.maxHeight - slotHeight) * offset.dy,
      width: slotWidth,
      height: slotHeight,
      child: KeyedSubtree(
        key: Key(
          'tarot-spread-slot-${widget.spreadDefinition.id}-${slot.slotId ?? index}',
        ),
        child: transformed,
      ),
    );
  }
}

class _StrictGridSpec {
  const _StrictGridSpec({required this.columns, required this.rows});

  final int columns;
  final int rows;
}

class _StrictGridMetrics {
  const _StrictGridMetrics({
    required this.spec,
    required this.padding,
    required this.horizontalGap,
    required this.verticalGap,
    required this.cellWidth,
    required this.cellHeight,
  });

  final _StrictGridSpec spec;
  final EdgeInsets padding;
  final double horizontalGap;
  final double verticalGap;
  final double cellWidth;
  final double cellHeight;
}

class _TarotFloatingAdjustmentControls extends StatelessWidget {
  const _TarotFloatingAdjustmentControls({
    required this.supportsDrag,
    required this.adjustmentMode,
    required this.hasTemporaryOffsets,
    required this.onToggle,
    required this.onReset,
  });

  final bool supportsDrag;
  final bool adjustmentMode;
  final bool hasTemporaryOffsets;
  final VoidCallback onToggle;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const Key('tarot-layout-adjustment-toolbar'),
      child: KeyedSubtree(
        key: Key(
          supportsDrag
              ? 'tarot-free-draw-top-strip'
              : 'tarot-floating-layout-controls',
        ),
        child: _TarotTableChromeBar(
          children: [
            Icon(
              Icons.open_with_rounded,
              size: 15,
              color: RynPalette.tarotGoldAccent(
                context,
              ).withValues(alpha: 0.86),
            ),
            OutlinedButton(
              key: Key(
                adjustmentMode
                    ? 'tarot-layout-adjustment-done'
                    : 'tarot-layout-adjustment-enter',
              ),
              style: _tarotCompactOutlinedActionStyle(context),
              onPressed: supportsDrag ? null : onToggle,
              child: Text(adjustmentMode ? '배치 완료' : '배치 조정'),
            ),
            TextButton(
              key: const Key('tarot-layout-adjustment-reset'),
              style: _tarotCompactTextActionStyle(),
              onPressed: hasTemporaryOffsets ? onReset : null,
              child: const Text('기본 배치로'),
            ),
          ],
        ),
      ),
    );
  }
}

const _compactTallTableSpreadIds = <String>{
  'one_card',
  'two_card',
  'three_card',
  'four_card',
  'five_card',
};

double _canvasHeightForDefinition(_TarotSpreadDefinition definition) {
  if (definition.supportsDrag) return 760;
  if (definition.id == 'mini_celtic_cross' || definition.id == 'cross') {
    return 940;
  }
  if (definition.id == 'celtic_cross') return 960;
  if (definition.id == 'reading_mind' ||
      definition.id == 'cup_of_relationship') {
    return 960;
  }
  if (definition.id == 'tandem' || definition.id == 'relationship') {
    return 920;
  }
  if (definition.id == 'seven_card') return 820;
  if (_compactTallTableSpreadIds.contains(definition.id)) return 820;
  if (definition.id == 'binary_choice') return 860;
  if (definition.id == 'horseshoe') {
    return 840;
  }
  if (definition.id == 'horoscope' || definition.id == 'year_ahead') {
    return 1020;
  }
  if (definition.canvasStyle == _TarotResultCanvasStyle.radial) return 880;
  if (definition.canvasStyle == _TarotResultCanvasStyle.grid) {
    return definition.cardCount == 9 ? 780 : 720;
  }
  final count = definition.cardCount;
  if (count == 1) return 640;
  if (count <= 3) return 620;
  if (count <= 5) return 620;
  if (count <= 7) return 720;
  if (count <= 9) return 760;
  return 840;
}

Size _cardSizeForLayout(
  int count,
  BoxConstraints constraints,
  _TarotSpreadDefinition definition,
) => _cardSizeForSpreadType(count, constraints, definition);

Size _cardSizeForSpreadType(
  int count,
  BoxConstraints constraints,
  _TarotSpreadDefinition definition,
) {
  final layout = _layoutForSpread(definition, count);
  final padding = _boardPaddingForSpread(definition);
  final overlapPolicy = _overlapPolicyForSpread(definition);
  final occupancy =
      _spreadOccupancyTarget(definition, count) -
      (overlapPolicy == _TarotOverlapPolicy.intentionalMinimal ? 0.03 : 0.0);
  final maxWidth = math.max(1.0, constraints.maxWidth - padding.horizontal);
  final maxHeight = math.max(1.0, constraints.maxHeight - padding.vertical);
  final preferredWidth = _preferredCardWidthForSpread(definition, count);
  final widthLimit = maxWidth * occupancy / layout.columns;
  final heightLimit = maxHeight * occupancy / layout.rows / 1.62;
  final minimumWidth = _minimumCardWidthForSpread(definition, count);
  final width = math.min(
    preferredWidth,
    math.max(minimumWidth, math.min(widthLimit, heightLimit)),
  );
  return Size(width, width * 1.62);
}

double _preferredCardWidthForSpread(
  _TarotSpreadDefinition definition,
  int count,
) {
  return _blueprintForSpread(definition, count).preferredCardWidth;
}

double _minimumCardWidthForSpread(
  _TarotSpreadDefinition definition,
  int count,
) {
  return _blueprintForSpread(definition, count).minimumCardWidth;
}

_EffectiveSpreadLayout _layoutForSpread(
  _TarotSpreadDefinition definition,
  int count,
) {
  return _blueprintForSpread(definition, count).layout;
}

EdgeInsets _boardPaddingForSpread(_TarotSpreadDefinition definition) {
  return _blueprintForSpread(definition, definition.cardCount).padding;
}

double _spreadOccupancyTarget(_TarotSpreadDefinition definition, int count) {
  return _blueprintForSpread(definition, count).occupancyTarget;
}

_TarotOverlapPolicy _overlapPolicyForSpread(_TarotSpreadDefinition definition) {
  return _blueprintForSpread(definition, definition.cardCount).overlapPolicy;
}

_TarotSpreadGeometryBlueprint _blueprintForSpread(
  _TarotSpreadDefinition definition,
  int count,
) {
  final manual = _manualSpreadGeometryBlueprints[definition.id];
  if (manual != null) return manual;
  if (definition.supportsDrag) return _freeDrawGeometryBlueprint;
  return _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(
      columns: math.max(3.0, math.sqrt(count) * 1.35),
      rows: math.max(2.0, math.sqrt(count)),
    ),
    preferredCardWidth: switch (count) {
      1 => 360,
      <= 3 => 270,
      <= 5 => 210,
      <= 7 => 176,
      <= 9 => 154,
      _ => 132,
    },
    minimumCardWidth: switch (count) {
      1 => 240,
      <= 3 => 185,
      <= 5 => 148,
      <= 9 => 112,
      _ => 96,
    },
    occupancyTarget: 0.84,
  );
}

// SPREAD-LAYOUT-TEMPLATE1: manual geometry blueprints are the default source
// for reading-board scale and spacing. Slot identity and base coordinates remain
// in each spread's explicit _TarotSlotSpec list; this blueprint layer supplies
// the per-spread card-size, gutter/occupancy, alignment budget, and intentional
// overlap policy so major spreads no longer depend on generic family formulas.
const _manualSpreadGeometryBlueprints = <String, _TarotSpreadGeometryBlueprint>{
  'one_card': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 1.0, rows: 1.0),
    preferredCardWidth: 330,
    minimumCardWidth: 260,
    occupancyTarget: 0.90,
  ),
  'two_card': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 2.0, rows: 1.0),
    preferredCardWidth: 310,
    minimumCardWidth: 220,
    occupancyTarget: 0.88,
  ),
  'three_card': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 3.0, rows: 1.0),
    preferredCardWidth: 280,
    minimumCardWidth: 192,
    occupancyTarget: 0.88,
  ),
  'four_card': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 4.0, rows: 1.0),
    preferredCardWidth: 238,
    minimumCardWidth: 168,
    occupancyTarget: 0.88,
  ),
  'five_card': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 5.0, rows: 1.0),
    preferredCardWidth: 212,
    minimumCardWidth: 154,
    occupancyTarget: 0.88,
  ),
  'seven_card': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 4.0, rows: 2.0),
    preferredCardWidth: 188,
    minimumCardWidth: 168,
    occupancyTarget: 0.90,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
  ),
  'grid_6': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 3.0, rows: 2.0),
    preferredCardWidth: 194,
    minimumCardWidth: 138,
    occupancyTarget: 0.91,
    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 20),
  ),
  'grid_8': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 4.0, rows: 2.0),
    preferredCardWidth: 176,
    minimumCardWidth: 124,
    occupancyTarget: 0.91,
    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 20),
  ),
  'grid_9': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 3.0, rows: 3.0),
    preferredCardWidth: 162,
    minimumCardWidth: 116,
    occupancyTarget: 0.90,
    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 20),
  ),
  'celtic_cross': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 4.70, rows: 3.45),
    preferredCardWidth: 156,
    minimumCardWidth: 118,
    occupancyTarget: 0.88,
    overlapPolicy: _TarotOverlapPolicy.intentionalMinimal,
  ),
  'mini_celtic_cross': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 2.55, rows: 2.45),
    preferredCardWidth: 162,
    minimumCardWidth: 148,
    occupancyTarget: 0.90,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    overlapPolicy: _TarotOverlapPolicy.intentionalMinimal,
  ),
  'cross': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 2.55, rows: 2.45),
    preferredCardWidth: 166,
    minimumCardWidth: 150,
    occupancyTarget: 0.90,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
  ),
  'horseshoe': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 3.85, rows: 2.65),
    preferredCardWidth: 176,
    minimumCardWidth: 154,
    occupancyTarget: 0.89,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
  ),
  'magic_seven': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 3.55, rows: 3.15),
    preferredCardWidth: 162,
    minimumCardWidth: 118,
    occupancyTarget: 0.87,
  ),
  'binary_choice': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 3.10, rows: 2.75),
    preferredCardWidth: 184,
    minimumCardWidth: 152,
    occupancyTarget: 0.88,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
  ),
  'reading_mind': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 3.55, rows: 3.85),
    preferredCardWidth: 132,
    minimumCardWidth: 124,
    occupancyTarget: 0.88,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
  ),
  'tandem': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 3.05, rows: 2.95),
    preferredCardWidth: 166,
    minimumCardWidth: 146,
    occupancyTarget: 0.90,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
  ),
  'relationship': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 3.15, rows: 3.05),
    preferredCardWidth: 154,
    minimumCardWidth: 138,
    occupancyTarget: 0.90,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
  ),
  'cup_of_relationship': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 3.55, rows: 3.85),
    preferredCardWidth: 126,
    minimumCardWidth: 116,
    occupancyTarget: 0.88,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    overlapPolicy: _TarotOverlapPolicy.intentionalSoft,
  ),
  'horoscope': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 4.20, rows: 4.05),
    preferredCardWidth: 130,
    minimumCardWidth: 112,
    occupancyTarget: 0.88,
    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  ),
  'year_ahead': _TarotSpreadGeometryBlueprint(
    layout: _EffectiveSpreadLayout(columns: 4.20, rows: 4.05),
    preferredCardWidth: 130,
    minimumCardWidth: 112,
    occupancyTarget: 0.88,
    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  ),
};

const _freeDrawGeometryBlueprint = _TarotSpreadGeometryBlueprint(
  layout: _EffectiveSpreadLayout(columns: 5.0, rows: 2.55),
  preferredCardWidth: 210,
  minimumCardWidth: 128,
  occupancyTarget: 0.74,
);

class _TarotSpreadGeometryBlueprint {
  const _TarotSpreadGeometryBlueprint({
    required this.layout,
    required this.preferredCardWidth,
    required this.minimumCardWidth,
    required this.occupancyTarget,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
    this.overlapPolicy = _TarotOverlapPolicy.none,
  });

  final _EffectiveSpreadLayout layout;
  final double preferredCardWidth;
  final double minimumCardWidth;
  final double occupancyTarget;
  final EdgeInsets padding;
  final _TarotOverlapPolicy overlapPolicy;
}

class _EffectiveSpreadLayout {
  const _EffectiveSpreadLayout({required this.columns, required this.rows});

  final double columns;
  final double rows;
}

enum _TarotOverlapPolicy { none, intentionalMinimal, intentionalSoft }

class _TarotPositionLabel extends StatelessWidget {
  const _TarotPositionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-position-label'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // TAROT-RESULT-LABEL-POLISH1: label-only polish; table surface unchanged.
        color: RynPalette.tarotViolet.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
        border: Border.all(
          color: RynPalette.tarotGoldAccent(context).withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: RynPalette.tarotIvory.withValues(alpha: 0.88),
          fontSize: 11.2,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.05,
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
            color: RynPalette.tarotBentoPanelSoft(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: RynPalette.tarotBorder(context).withValues(alpha: 0.72),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                color: RynPalette.tarotPurpleAccent(context),
                size: 22,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: RynPalette.tarotTextPrimary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                UserText.tarotEmptySlot,
                style: TextStyle(
                  color: RynPalette.tarotTextSecondary(context),
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
    required this.onFocus,
    required this.onDirectionToggle,
    required this.cardBack,
  });

  final _DrawnTarotCard drawnCard;
  final int index;
  final bool revealed;
  final bool showRevealFx;
  final VoidCallback onReveal;
  final VoidCallback onFocus;
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
              color: RynPalette.tarotPurpleAccent(
                context,
              ).withValues(alpha: 0.18),
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
              front: _TarotRevealedCardFace(
                drawnCard: drawnCard,
                index: index,
                onFocus: onFocus,
              ),
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
          color: RynPalette.tarotGoldAccent(
            context,
          ).withValues(alpha: glowing ? 0.96 : 0.58),
          width: glowing ? 1.4 : 1,
        ),
        boxShadow: glowing
            ? [
                BoxShadow(
                  color: RynPalette.tarotGoldAccent(
                    context,
                  ).withValues(alpha: 0.24),
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
                    RynPalette.tarotGoldAccent(
                      context,
                    ).withValues(alpha: glowing ? 0.18 : 0.06),
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
  const _TarotRevealedCardFace({
    required this.drawnCard,
    required this.index,
    required this.onFocus,
  });

  final _DrawnTarotCard drawnCard;
  final int index;
  final VoidCallback onFocus;

  @override
  Widget build(BuildContext context) {
    final orientation = drawnCard.reversed
        ? UserText.tarotReversed
        : UserText.tarotUpright;
    return Tooltip(
      message: '${drawnCard.card.label} · $orientation · 크게 보기',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('tarot-focusable-result-card-$index'),
          borderRadius: BorderRadius.circular(4),
          onTap: onFocus,
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
        ),
      ),
    );
  }
}

class _TarotFocusedCardOverlay extends StatelessWidget {
  const _TarotFocusedCardOverlay({
    required this.drawnCard,
    required this.slotLabel,
    required this.deckLabel,
    required this.onClose,
  });

  final _DrawnTarotCard drawnCard;
  final String slotLabel;
  final String deckLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final orientation = drawnCard.reversed
        ? UserText.tarotReversed
        : UserText.tarotUpright;
    final meaning = TarotCardMeaningRegistry.resolve(drawnCard.card.semanticId);
    return Material(
      key: const Key('tarot-focus-detail-overlay'),
      color: Colors.black.withValues(alpha: 0.68),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920, maxHeight: 760),
          child: Container(
            key: const Key('tarot-card-focus-panel-marker'),
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF080B1A),
                  Color(0xFF111936),
                  Color(0xFF211747),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: RynPalette.tarotGoldAccent(
                  context,
                ).withValues(alpha: 0.34),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xCC000000),
                  blurRadius: 42,
                  offset: Offset(0, 22),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  flex: 5,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1 / 1.62,
                      child: _TarotRevealReadyFrame(
                        child: AnimatedRotation(
                          turns: drawnCard.reversed ? 0.5 : 0,
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          child: Image.asset(
                            drawnCard.card.imagePath,
                            key: const Key('tarot-focus-card-image'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Flexible(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '카드 집중 보기',
                              key: const Key('tarot-card-focus-panel-title'),
                              style: TextStyle(
                                color: RynPalette.tarotPurpleAccent(context),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          IconButton(
                            key: const Key('tarot-focus-close-button'),
                            tooltip: '닫기',
                            onPressed: onClose,
                            icon: const Icon(Icons.close_rounded),
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        drawnCard.card.label,
                        key: const Key('tarot-focus-card-name'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _TarotFocusInfoChip(
                        icon: Icons.swap_vert_rounded,
                        label: orientation,
                        valueKey: const Key('tarot-focus-card-orientation'),
                      ),
                      const SizedBox(height: 10),
                      _TarotFocusInfoChip(
                        icon: Icons.place_rounded,
                        label: slotLabel,
                        valueKey: const Key('tarot-focus-slot-label'),
                      ),
                      const SizedBox(height: 10),
                      _TarotFocusInfoChip(
                        icon: Icons.style_rounded,
                        label: deckLabel,
                        valueKey: const Key('tarot-focus-deck-label'),
                      ),
                      const SizedBox(height: 16),
                      _TarotFocusReadingPrompt(
                        meaning: meaning,
                        reversed: drawnCard.reversed,
                      ),
                      const Spacer(),
                      Text(
                        '해석 공간에서 이 카드를 먼저 살펴보세요. 현재 배열과 임시 조정은 그대로 유지됩니다.',
                        key: const Key('tarot-focus-panel-guidance'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.64),
                          fontSize: 12,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TarotFocusReadingPrompt extends StatelessWidget {
  const _TarotFocusReadingPrompt({
    required this.meaning,
    required this.reversed,
  });

  final TarotCardMeaning meaning;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-card-focus-reading-prompt'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // TAROT-CARD-FOCUS-PANEL1: focused card detail panel; selected card preview retained.
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meaning.titleKo,
            key: const Key('tarot-focus-meaning-title'),
            style: TextStyle(
              color: RynPalette.tarotGoldAccent(
                context,
              ).withValues(alpha: 0.90),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final keyword in meaning.keywords)
                _TarotMeaningKeywordChip(keyword: keyword),
            ],
          ),
          const SizedBox(height: 10),
          _TarotMeaningLine(
            label: reversed ? '역방향' : '정방향',
            text: reversed ? meaning.reversed : meaning.upright,
            valueKey: const Key('tarot-focus-meaning-orientation-text'),
          ),
          const SizedBox(height: 8),
          _TarotMeaningLine(
            label: '질문 렌즈',
            text: meaning.questionLens,
            valueKey: const Key('tarot-focus-meaning-question-lens'),
          ),
          const SizedBox(height: 8),
          _TarotMeaningLine(
            label: '자리 렌즈',
            text: meaning.positionLens,
            valueKey: const Key('tarot-focus-meaning-position-lens'),
          ),
          const SizedBox(height: 8),
          Text(
            meaning.smallAction,
            key: const Key('tarot-focus-meaning-small-action'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarotMeaningKeywordChip extends StatelessWidget {
  const _TarotMeaningKeywordChip({required this.keyword});

  final String keyword;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('tarot-focus-meaning-keyword'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: RynPalette.tarotGoldAccent(context).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
        border: Border.all(
          color: RynPalette.tarotGoldAccent(context).withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        keyword,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.84),
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TarotMeaningLine extends StatelessWidget {
  const _TarotMeaningLine({
    required this.label,
    required this.text,
    required this.valueKey,
  });

  final String label;
  final String text;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: RynPalette.tarotPurpleAccent(context),
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          text,
          key: valueKey,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.73),
            fontSize: 11.3,
            fontWeight: FontWeight.w600,
            height: 1.32,
          ),
        ),
      ],
    );
  }
}

class _TarotFocusInfoChip extends StatelessWidget {
  const _TarotFocusInfoChip({
    required this.icon,
    required this.label,
    required this.valueKey,
  });

  final IconData icon;
  final String label;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: RynPalette.tarotGoldAccent(context)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              key: valueKey,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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

// ignore: unused_element
class _TarotMemoPanel extends StatelessWidget {
  const _TarotMemoPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RynPalette.tarotBentoPanel(context),
        borderRadius: BorderRadius.circular(RynMetrics.radiusCard),
        border: Border.all(
          color: RynPalette.tarotBorder(context).withValues(alpha: 0.72),
        ),
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
            color: RynPalette.tarotTextPrimary(context),
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
              color: RynPalette.tarotBentoPanelSoft(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: RynPalette.tarotBorder(context).withValues(alpha: 0.72),
              ),
            ),
            child: Text(
              hint,
              style: TextStyle(
                color: RynPalette.tarotTextSecondary(context),
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
        color: RynPalette.tarotNavy.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(RynMetrics.radiusPill),
        border: Border.all(
          color: RynPalette.tarotGoldAccent(context).withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: RynPalette.tarotMist,
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

enum _TarotSpreadFamily { freeLayout, fixedMeaning }

enum _TarotPositionMeaningMode { userDefined, predefined }

enum _TarotSlotAnchor {
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  outside,
  inside,
  hidden,
}

enum _TarotResultCanvasStyle { freeBoard, fixedBoard, grid, radial }

class _TarotSpreadDefinition {
  const _TarotSpreadDefinition({
    required this.id,
    required this.label,
    required this.family,
    required this.subtype,
    required this.slots,
    this.variant,
    this.variantCount,
    this.supportsDrag = false,
    this.positionMeaningMode = _TarotPositionMeaningMode.predefined,
    this.canvasStyle = _TarotResultCanvasStyle.fixedBoard,
  });

  final String id;
  final String label;
  final _TarotSpreadFamily family;
  final String subtype;
  final String? variant;
  final int? variantCount;
  final bool supportsDrag;
  final _TarotPositionMeaningMode positionMeaningMode;
  final _TarotResultCanvasStyle canvasStyle;
  final List<_TarotSlotSpec> slots;

  int get cardCount => slots.length;
}

class _DrawnTarotCard {
  const _DrawnTarotCard({required this.card, required this.reversed});

  final TarotCardDefinition card;
  final bool reversed;
}

class _TarotSlotSpec {
  const _TarotSlotSpec(
    this.label,
    this.xRatio,
    this.yRatio, {
    this.slotId,
    this.rotationDeg = 0,
    this.zIndex = 0,
    this.widthFactor = 1,
    this.heightFactor = 1,
    this.overlapTargetSlotId,
    this.draggableOverride,
    this.labelAnchor,
    this.infoAnchor,
    this.labelOffsetX = 0,
    this.labelOffsetY = 0,
    this.infoOffsetX = 0,
    this.infoOffsetY = 0,
    this.avoidOverlap = true,
    this.allowAutoFlipAnchor = true,
    this.preferredSide,
    this.isHorizontalOverlay = false,
  });

  final String label;
  final double xRatio;
  final double yRatio;
  final String? slotId;
  final double rotationDeg;
  final int zIndex;
  final double widthFactor;
  final double heightFactor;
  final String? overlapTargetSlotId;
  final bool? draggableOverride;
  final _TarotSlotAnchor? labelAnchor;
  final _TarotSlotAnchor? infoAnchor;
  final double labelOffsetX;
  final double labelOffsetY;
  final double infoOffsetX;
  final double infoOffsetY;
  final bool avoidOverlap;
  final bool allowAutoFlipAnchor;
  final _TarotSlotAnchor? preferredSide;
  final bool isHorizontalOverlay;

  _TarotSlotSpec copyWith({String? label}) => _TarotSlotSpec(
    label ?? this.label,
    xRatio,
    yRatio,
    slotId: slotId,
    rotationDeg: rotationDeg,
    zIndex: zIndex,
    widthFactor: widthFactor,
    heightFactor: heightFactor,
    overlapTargetSlotId: overlapTargetSlotId,
    draggableOverride: draggableOverride,
    labelAnchor: labelAnchor,
    infoAnchor: infoAnchor,
    labelOffsetX: labelOffsetX,
    labelOffsetY: labelOffsetY,
    infoOffsetX: infoOffsetX,
    infoOffsetY: infoOffsetY,
    avoidOverlap: avoidOverlap,
    allowAutoFlipAnchor: allowAutoFlipAnchor,
    preferredSide: preferredSide,
    isHorizontalOverlay: isHorizontalOverlay,
  );
}

List<_TarotSpreadDefinition> _buildTarotSpreadRegistry() => [
  const _TarotSpreadDefinition(
    id: 'free_draw',
    label: '자유 드로우',
    family: _TarotSpreadFamily.freeLayout,
    subtype: 'free-board',
    supportsDrag: true,
    positionMeaningMode: _TarotPositionMeaningMode.userDefined,
    canvasStyle: _TarotResultCanvasStyle.freeBoard,
    slots: _tarotSpreadFreeDrawSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'one_card',
    label: UserText.tarotSpreadOne,
    family: _TarotSpreadFamily.freeLayout,
    subtype: 'single',
    positionMeaningMode: _TarotPositionMeaningMode.userDefined,
    slots: _tarotSpreadOneSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'two_card',
    label: '2카드',
    family: _TarotSpreadFamily.freeLayout,
    subtype: 'pair',
    positionMeaningMode: _TarotPositionMeaningMode.userDefined,
    slots: _tarotSpreadTwoSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'three_card',
    label: UserText.tarotSpreadThree,
    family: _TarotSpreadFamily.freeLayout,
    subtype: 'triptych',
    positionMeaningMode: _TarotPositionMeaningMode.userDefined,
    slots: _tarotSpreadThreeSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'four_card',
    label: UserText.tarotSpreadFour,
    family: _TarotSpreadFamily.freeLayout,
    subtype: 'row',
    positionMeaningMode: _TarotPositionMeaningMode.userDefined,
    slots: _tarotSpreadFourSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'five_card',
    label: UserText.tarotSpreadFive,
    family: _TarotSpreadFamily.freeLayout,
    subtype: 'shallow-arc',
    positionMeaningMode: _TarotPositionMeaningMode.userDefined,
    slots: _tarotSpreadFiveSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'seven_card',
    label: '7카드',
    family: _TarotSpreadFamily.freeLayout,
    subtype: 'staggered-seven',
    positionMeaningMode: _TarotPositionMeaningMode.userDefined,
    slots: _tarotSpreadSevenSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'grid_6',
    label: '그리드 6',
    family: _TarotSpreadFamily.freeLayout,
    subtype: 'grid',
    positionMeaningMode: _TarotPositionMeaningMode.userDefined,
    variant: '6',
    variantCount: 3,
    canvasStyle: _TarotResultCanvasStyle.grid,
    slots: _tarotSpreadGridSixSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'grid_8',
    label: '그리드 8',
    family: _TarotSpreadFamily.freeLayout,
    subtype: 'grid',
    positionMeaningMode: _TarotPositionMeaningMode.userDefined,
    variant: '8',
    variantCount: 3,
    canvasStyle: _TarotResultCanvasStyle.grid,
    slots: _tarotSpreadGridEightSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'grid_9',
    label: '그리드 9',
    family: _TarotSpreadFamily.freeLayout,
    subtype: 'grid',
    positionMeaningMode: _TarotPositionMeaningMode.userDefined,
    variant: '9',
    variantCount: 3,
    canvasStyle: _TarotResultCanvasStyle.grid,
    slots: _tarotSpreadGridNineSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'celtic_cross',
    label: UserText.tarotSpreadCeltic,
    family: _TarotSpreadFamily.fixedMeaning,
    subtype: 'celtic',
    positionMeaningMode: _TarotPositionMeaningMode.predefined,
    slots: _tarotSpreadCelticSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'mini_celtic_cross',
    label: '미니 켈틱 크로스',
    family: _TarotSpreadFamily.fixedMeaning,
    subtype: 'mini-celtic',
    positionMeaningMode: _TarotPositionMeaningMode.predefined,
    slots: _tarotSpreadMiniCelticSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'cross',
    label: '십자',
    family: _TarotSpreadFamily.fixedMeaning,
    subtype: 'cross',
    positionMeaningMode: _TarotPositionMeaningMode.predefined,
    slots: _tarotSpreadCrossSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'horseshoe',
    label: '말발굽',
    family: _TarotSpreadFamily.fixedMeaning,
    subtype: 'horseshoe',
    positionMeaningMode: _TarotPositionMeaningMode.predefined,
    slots: _tarotSpreadHorseshoeSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'magic_seven',
    label: '매직 세븐',
    family: _TarotSpreadFamily.fixedMeaning,
    subtype: 'magic-seven',
    positionMeaningMode: _TarotPositionMeaningMode.predefined,
    slots: _tarotSpreadMagicSevenSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'binary_choice',
    label: UserText.tarotSpreadBinary,
    family: _TarotSpreadFamily.fixedMeaning,
    subtype: 'choice',
    positionMeaningMode: _TarotPositionMeaningMode.predefined,
    slots: _tarotSpreadBinarySlots,
  ),
  const _TarotSpreadDefinition(
    id: 'reading_mind',
    label: '리딩 마인드',
    family: _TarotSpreadFamily.fixedMeaning,
    subtype: 'mind-tier',
    positionMeaningMode: _TarotPositionMeaningMode.predefined,
    slots: _tarotSpreadReadingMindSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'tandem',
    label: '탄뎀',
    family: _TarotSpreadFamily.fixedMeaning,
    subtype: 'tandem',
    positionMeaningMode: _TarotPositionMeaningMode.predefined,
    slots: _tarotSpreadTandemSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'relationship',
    label: '릴레이션십',
    family: _TarotSpreadFamily.fixedMeaning,
    subtype: 'relationship',
    positionMeaningMode: _TarotPositionMeaningMode.predefined,
    slots: _tarotSpreadRelationshipSlots,
  ),
  const _TarotSpreadDefinition(
    id: 'cup_of_relationship',
    label: '컵 오브 릴레이션십',
    family: _TarotSpreadFamily.fixedMeaning,
    subtype: 'relationship-cup',
    positionMeaningMode: _TarotPositionMeaningMode.predefined,
    slots: _tarotSpreadCupRelationshipSlots,
  ),
  _TarotSpreadDefinition(
    id: 'horoscope',
    label: '호로스코프',
    family: _TarotSpreadFamily.fixedMeaning,
    subtype: 'radial',
    positionMeaningMode: _TarotPositionMeaningMode.predefined,
    canvasStyle: _TarotResultCanvasStyle.radial,
    slots: _radialSlots(prefix: 'house', centerLabel: '중심', outerLabel: '하우스'),
  ),
  _TarotSpreadDefinition(
    id: 'year_ahead',
    label: '1년 운세',
    family: _TarotSpreadFamily.fixedMeaning,
    subtype: 'radial-year',
    positionMeaningMode: _TarotPositionMeaningMode.predefined,
    canvasStyle: _TarotResultCanvasStyle.radial,
    slots: _radialSlots(
      prefix: 'month',
      centerLabel: '올해의 주제',
      outerLabel: '월',
    ),
  ),
];

List<_TarotSlotSpec> _radialSlots({
  required String prefix,
  required String centerLabel,
  required String outerLabel,
}) {
  const ringOffsets = <Offset>[
    Offset(0.20, 0.08),
    Offset(0.40, 0.08),
    Offset(0.60, 0.08),
    Offset(0.80, 0.08),
    Offset(0.88, 0.36),
    Offset(0.88, 0.64),
    Offset(0.80, 0.92),
    Offset(0.60, 0.92),
    Offset(0.40, 0.92),
    Offset(0.20, 0.92),
    Offset(0.12, 0.64),
    Offset(0.12, 0.36),
  ];
  return [
    _TarotSlotSpec(
      centerLabel,
      0.50,
      0.50,
      slotId: '${prefix}_center',
      zIndex: 20,
      widthFactor: 1.0,
      heightFactor: 1.0,
      labelAnchor: _TarotSlotAnchor.inside,
      infoAnchor: _TarotSlotAnchor.inside,
    ),
    for (var index = 0; index < ringOffsets.length; index++)
      _TarotSlotSpec(
        prefix == 'month' ? '${index + 1}월' : '$outerLabel ${index + 1}',
        ringOffsets[index].dx,
        ringOffsets[index].dy,
        slotId: '${prefix}_${index + 1}',
        zIndex: index,
        widthFactor: 0.95,
        heightFactor: 0.95,
        preferredSide: _TarotSlotAnchor.outside,
        labelAnchor: _TarotSlotAnchor.outside,
        infoAnchor: _TarotSlotAnchor.outside,
      ),
  ];
}

const _tarotSpreadFreeDrawSlots = [
  _TarotSlotSpec(
    '카드 1',
    0.14,
    0.28,
    slotId: 'free_1',
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
  _TarotSlotSpec(
    '카드 2',
    0.32,
    0.40,
    slotId: 'free_2',
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
  _TarotSlotSpec(
    '카드 3',
    0.50,
    0.30,
    slotId: 'free_3',
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
  _TarotSlotSpec(
    '카드 4',
    0.68,
    0.42,
    slotId: 'free_4',
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
  _TarotSlotSpec(
    '카드 5',
    0.86,
    0.28,
    slotId: 'free_5',
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
];

List<_TarotSlotSpec> _freeDrawSlotsForCount(int count) {
  final safeCount = count.clamp(1, 30);
  return [
    for (var index = 0; index < safeCount; index++)
      _TarotSlotSpec(
        '카드 ${index + 1}',
        _freeDrawXRatio(index, safeCount),
        _freeDrawYRatio(index, safeCount),
        slotId: 'free_${index + 1}',
        labelAnchor: _TarotSlotAnchor.bottom,
      ),
  ];
}

double _freeDrawXRatio(int index, int count) {
  if (count == 1) return 0.5;
  final columns = math.min(6, math.max(2, math.sqrt(count).ceil() + 1));
  final column = index % columns;
  final row = index ~/ columns;
  final rowShift = row.isOdd ? 0.5 : 0.0;
  return ((column + 0.5 + rowShift) / columns).clamp(0.10, 0.90);
}

double _freeDrawYRatio(int index, int count) {
  final columns = math.min(6, math.max(2, math.sqrt(count).ceil() + 1));
  final rows = (count / columns).ceil();
  if (rows == 1) return 0.48;
  final row = index ~/ columns;
  return ((row + 0.5) / rows).clamp(0.16, 0.84);
}

const _tarotSpreadOneSlots = [
  _TarotSlotSpec(
    '핵심',
    0.5,
    0.52,
    slotId: 'one_center',
    widthFactor: 1.10,
    heightFactor: 1.10,
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
];

const _tarotSpreadTwoSlots = [
  _TarotSlotSpec(
    '왼쪽',
    0.32,
    0.52,
    slotId: 'two_left',
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
  _TarotSlotSpec(
    '오른쪽',
    0.68,
    0.52,
    slotId: 'two_right',
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
];

const _tarotSpreadThreeSlots = [
  _TarotSlotSpec(
    '과거',
    0.18,
    0.52,
    slotId: 'three_past',
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
  _TarotSlotSpec(
    '현재',
    0.5,
    0.52,
    slotId: 'three_present',
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
  _TarotSlotSpec(
    '미래',
    0.82,
    0.52,
    slotId: 'three_future',
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
];

const _tarotSpreadFourSlots = [
  _TarotSlotSpec(
    '기반',
    0.06,
    0.52,
    slotId: 'four_1',
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
  _TarotSlotSpec(
    '현재',
    0.35,
    0.52,
    slotId: 'four_2',
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
  _TarotSlotSpec(
    '조언',
    0.65,
    0.52,
    slotId: 'four_3',
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
  _TarotSlotSpec(
    '흐름',
    0.94,
    0.52,
    slotId: 'four_4',
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
];

const _tarotSpreadFiveSlots = [
  _TarotSlotSpec(
    '1',
    0.10,
    0.52,
    slotId: 'five_1',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '2',
    0.30,
    0.52,
    slotId: 'five_2',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '3',
    0.50,
    0.52,
    slotId: 'five_3',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '4',
    0.70,
    0.52,
    slotId: 'five_4',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '5',
    0.90,
    0.52,
    slotId: 'five_5',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
];

const _tarotSpreadSevenSlots = [
  _TarotSlotSpec(
    '상단 1',
    0.14,
    0.20,
    slotId: 'seven_1',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '상단 2',
    0.38,
    0.20,
    slotId: 'seven_2',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '상단 3',
    0.62,
    0.20,
    slotId: 'seven_3',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '상단 4',
    0.86,
    0.20,
    slotId: 'seven_4',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '하단 1',
    0.26,
    0.80,
    slotId: 'seven_5',
    labelAnchor: _TarotSlotAnchor.top,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '하단 2',
    0.50,
    0.80,
    slotId: 'seven_6',
    labelAnchor: _TarotSlotAnchor.top,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '하단 3',
    0.74,
    0.80,
    slotId: 'seven_7',
    labelAnchor: _TarotSlotAnchor.top,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
];

const _tarotSpreadGridSixSlots = [
  _TarotSlotSpec(
    '1',
    0.22,
    0.16,
    slotId: 'grid6_1',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '2',
    0.50,
    0.16,
    slotId: 'grid6_2',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '3',
    0.78,
    0.16,
    slotId: 'grid6_3',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '4',
    0.22,
    0.84,
    slotId: 'grid6_4',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '5',
    0.50,
    0.84,
    slotId: 'grid6_5',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '6',
    0.78,
    0.84,
    slotId: 'grid6_6',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
];

const _tarotSpreadGridEightSlots = [
  _TarotSlotSpec(
    '1',
    0.10,
    0.16,
    slotId: 'grid8_1',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.96,
    heightFactor: 0.96,
  ),
  _TarotSlotSpec(
    '2',
    0.37,
    0.16,
    slotId: 'grid8_2',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.96,
    heightFactor: 0.96,
  ),
  _TarotSlotSpec(
    '3',
    0.63,
    0.16,
    slotId: 'grid8_3',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.96,
    heightFactor: 0.96,
  ),
  _TarotSlotSpec(
    '4',
    0.90,
    0.16,
    slotId: 'grid8_4',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.96,
    heightFactor: 0.96,
  ),
  _TarotSlotSpec(
    '5',
    0.10,
    0.84,
    slotId: 'grid8_5',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.96,
    heightFactor: 0.96,
  ),
  _TarotSlotSpec(
    '6',
    0.37,
    0.84,
    slotId: 'grid8_6',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.96,
    heightFactor: 0.96,
  ),
  _TarotSlotSpec(
    '7',
    0.63,
    0.84,
    slotId: 'grid8_7',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.96,
    heightFactor: 0.96,
  ),
  _TarotSlotSpec(
    '8',
    0.90,
    0.84,
    slotId: 'grid8_8',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.96,
    heightFactor: 0.96,
  ),
];

const _tarotSpreadGridNineSlots = [
  _TarotSlotSpec(
    '1',
    0.22,
    0.18,
    slotId: 'grid9_1',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.94,
    heightFactor: 0.94,
  ),
  _TarotSlotSpec(
    '2',
    0.50,
    0.18,
    slotId: 'grid9_2',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.94,
    heightFactor: 0.94,
  ),
  _TarotSlotSpec(
    '3',
    0.78,
    0.18,
    slotId: 'grid9_3',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.94,
    heightFactor: 0.94,
  ),
  _TarotSlotSpec(
    '4',
    0.22,
    0.50,
    slotId: 'grid9_4',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.94,
    heightFactor: 0.94,
  ),
  _TarotSlotSpec(
    '5',
    0.50,
    0.50,
    slotId: 'grid9_5',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.94,
    heightFactor: 0.94,
  ),
  _TarotSlotSpec(
    '6',
    0.78,
    0.50,
    slotId: 'grid9_6',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.94,
    heightFactor: 0.94,
  ),
  _TarotSlotSpec(
    '7',
    0.22,
    0.82,
    slotId: 'grid9_7',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.94,
    heightFactor: 0.94,
  ),
  _TarotSlotSpec(
    '8',
    0.50,
    0.82,
    slotId: 'grid9_8',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.94,
    heightFactor: 0.94,
  ),
  _TarotSlotSpec(
    '9',
    0.78,
    0.82,
    slotId: 'grid9_9',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.94,
    heightFactor: 0.94,
  ),
];

const _tarotSpreadCelticSlots = [
  _TarotSlotSpec(
    '현재',
    0.34,
    0.50,
    slotId: 'celtic_present',
    zIndex: 2,
    labelAnchor: _TarotSlotAnchor.left,
    infoAnchor: _TarotSlotAnchor.left,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '도전',
    0.34,
    0.50,
    slotId: 'celtic_cross',
    rotationDeg: 90,
    zIndex: 3,
    overlapTargetSlotId: 'celtic_present',
    isHorizontalOverlay: true,
    labelAnchor: _TarotSlotAnchor.right,
    infoAnchor: _TarotSlotAnchor.right,
    widthFactor: 1.0,
    heightFactor: 0.94,
  ),
  _TarotSlotSpec(
    '기반',
    0.34,
    0.90,
    slotId: 'celtic_base',
    labelAnchor: _TarotSlotAnchor.top,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '과거',
    0.10,
    0.50,
    slotId: 'celtic_past',
    labelAnchor: _TarotSlotAnchor.right,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '목표',
    0.34,
    0.10,
    slotId: 'celtic_goal',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '미래',
    0.58,
    0.50,
    slotId: 'celtic_future',
    labelAnchor: _TarotSlotAnchor.left,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '자아',
    0.84,
    0.99,
    slotId: 'celtic_self',
    labelAnchor: _TarotSlotAnchor.left,
    widthFactor: 0.94,
    heightFactor: 0.94,
  ),
  _TarotSlotSpec(
    '환경',
    0.84,
    0.67,
    slotId: 'celtic_env',
    labelAnchor: _TarotSlotAnchor.left,
    widthFactor: 0.94,
    heightFactor: 0.94,
  ),
  _TarotSlotSpec(
    '희망·두려움',
    0.84,
    0.35,
    slotId: 'celtic_hopes',
    labelAnchor: _TarotSlotAnchor.left,
    widthFactor: 0.94,
    heightFactor: 0.94,
  ),
  _TarotSlotSpec(
    '결과',
    0.84,
    0.03,
    slotId: 'celtic_result',
    labelAnchor: _TarotSlotAnchor.left,
    widthFactor: 0.94,
    heightFactor: 0.94,
  ),
];

const _tarotSpreadMiniCelticSlots = [
  _TarotSlotSpec(
    '위',
    0.50,
    0.04,
    slotId: 'mini_top',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '왼쪽',
    0.16,
    0.50,
    slotId: 'mini_left',
    labelAnchor: _TarotSlotAnchor.right,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '중심',
    0.50,
    0.50,
    slotId: 'mini_center',
    zIndex: 2,
    labelAnchor: _TarotSlotAnchor.left,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '오른쪽',
    0.84,
    0.50,
    slotId: 'mini_right',
    labelAnchor: _TarotSlotAnchor.left,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '아래',
    0.50,
    0.96,
    slotId: 'mini_bottom',
    labelAnchor: _TarotSlotAnchor.top,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '가로 영향',
    0.50,
    0.50,
    slotId: 'mini_overlay',
    rotationDeg: 90,
    zIndex: 3,
    overlapTargetSlotId: 'mini_center',
    isHorizontalOverlay: true,
    labelAnchor: _TarotSlotAnchor.right,
    infoAnchor: _TarotSlotAnchor.right,
    widthFactor: 1.0,
    heightFactor: 0.94,
  ),
];

const _tarotSpreadCrossSlots = [
  _TarotSlotSpec(
    '위',
    0.50,
    0.03,
    slotId: 'cross_top',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '왼쪽',
    0.16,
    0.50,
    slotId: 'cross_left',
    labelAnchor: _TarotSlotAnchor.right,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '중심',
    0.50,
    0.50,
    slotId: 'cross_center',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '오른쪽',
    0.84,
    0.50,
    slotId: 'cross_right',
    labelAnchor: _TarotSlotAnchor.left,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '아래',
    0.50,
    0.97,
    slotId: 'cross_bottom',
    labelAnchor: _TarotSlotAnchor.top,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
];

const _tarotSpreadHorseshoeSlots = [
  _TarotSlotSpec(
    '왼쪽 기둥',
    0.16,
    0.82,
    slotId: 'horse_left_base',
    labelAnchor: _TarotSlotAnchor.right,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '왼쪽 흐름',
    0.32,
    0.46,
    slotId: 'horse_left_arc',
    labelAnchor: _TarotSlotAnchor.right,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '상단',
    0.50,
    0.14,
    slotId: 'horse_top',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '오른쪽 흐름',
    0.68,
    0.46,
    slotId: 'horse_right_arc',
    labelAnchor: _TarotSlotAnchor.left,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '오른쪽 기둥',
    0.84,
    0.82,
    slotId: 'horse_right_base',
    labelAnchor: _TarotSlotAnchor.left,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
];

const _tarotSpreadMagicSevenSlots = [
  _TarotSlotSpec(
    '상단',
    0.50,
    0.10,
    slotId: 'magic_top',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.90,
    heightFactor: 0.90,
  ),
  _TarotSlotSpec(
    '상단 왼쪽',
    0.24,
    0.30,
    slotId: 'magic_upper_left',
    labelAnchor: _TarotSlotAnchor.right,
    widthFactor: 0.90,
    heightFactor: 0.90,
  ),
  _TarotSlotSpec(
    '상단 오른쪽',
    0.76,
    0.30,
    slotId: 'magic_upper_right',
    labelAnchor: _TarotSlotAnchor.left,
    widthFactor: 0.90,
    heightFactor: 0.90,
  ),
  _TarotSlotSpec(
    '중심',
    0.50,
    0.52,
    slotId: 'magic_center',
    zIndex: 2,
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 0.90,
    heightFactor: 0.90,
  ),
  _TarotSlotSpec(
    '하단 왼쪽',
    0.24,
    0.74,
    slotId: 'magic_lower_left',
    labelAnchor: _TarotSlotAnchor.right,
    widthFactor: 0.90,
    heightFactor: 0.90,
  ),
  _TarotSlotSpec(
    '하단 오른쪽',
    0.76,
    0.74,
    slotId: 'magic_lower_right',
    labelAnchor: _TarotSlotAnchor.left,
    widthFactor: 0.90,
    heightFactor: 0.90,
  ),
  _TarotSlotSpec(
    '하단',
    0.50,
    0.92,
    slotId: 'magic_bottom',
    labelAnchor: _TarotSlotAnchor.top,
    widthFactor: 0.90,
    heightFactor: 0.90,
  ),
];

const _tarotSpreadBinarySlots = [
  _TarotSlotSpec(
    'A 시작',
    0.22,
    0.12,
    slotId: 'choice_a_top',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    'B 시작',
    0.78,
    0.12,
    slotId: 'choice_b_top',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    'A 흐름',
    0.22,
    0.64,
    slotId: 'choice_a_mid',
    labelAnchor: _TarotSlotAnchor.right,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    'B 흐름',
    0.78,
    0.64,
    slotId: 'choice_b_mid',
    labelAnchor: _TarotSlotAnchor.left,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '중심 조언',
    0.50,
    0.92,
    slotId: 'choice_advice',
    zIndex: 2,
    labelAnchor: _TarotSlotAnchor.top,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
];

const _tarotSpreadReadingMindSlots = [
  _TarotSlotSpec(
    '의식 상단',
    0.50,
    0.01,
    slotId: 'mind_top',
    widthFactor: 1.0,
    heightFactor: 1.0,
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
  _TarotSlotSpec(
    '생각 1',
    0.18,
    0.34,
    slotId: 'mind_2',
    widthFactor: 1.0,
    heightFactor: 1.0,
    labelAnchor: _TarotSlotAnchor.right,
  ),
  _TarotSlotSpec(
    '생각 2',
    0.50,
    0.34,
    slotId: 'mind_3',
    widthFactor: 1.0,
    heightFactor: 1.0,
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
  _TarotSlotSpec(
    '생각 3',
    0.82,
    0.34,
    slotId: 'mind_4',
    widthFactor: 1.0,
    heightFactor: 1.0,
    labelAnchor: _TarotSlotAnchor.left,
  ),
  _TarotSlotSpec(
    '마음 왼쪽',
    0.22,
    0.66,
    slotId: 'mind_5',
    widthFactor: 1.0,
    heightFactor: 1.0,
    labelAnchor: _TarotSlotAnchor.right,
  ),
  _TarotSlotSpec(
    '중심 마음',
    0.50,
    0.66,
    slotId: 'mind_6',
    zIndex: 2,
    widthFactor: 1.0,
    heightFactor: 1.0,
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
  _TarotSlotSpec(
    '마음 오른쪽',
    0.78,
    0.66,
    slotId: 'mind_7',
    widthFactor: 1.0,
    heightFactor: 1.0,
    labelAnchor: _TarotSlotAnchor.left,
  ),
  _TarotSlotSpec(
    '기반 왼쪽',
    0.38,
    0.97,
    slotId: 'mind_8',
    widthFactor: 1.0,
    heightFactor: 1.0,
    labelAnchor: _TarotSlotAnchor.top,
  ),
  _TarotSlotSpec(
    '기반 오른쪽',
    0.62,
    0.97,
    slotId: 'mind_9',
    widthFactor: 1.0,
    heightFactor: 1.0,
    labelAnchor: _TarotSlotAnchor.top,
  ),
];

const _tarotSpreadTandemSlots = [
  _TarotSlotSpec(
    '상단 중심',
    0.34,
    0.02,
    slotId: 'tandem_top',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '왼쪽 위',
    0.66,
    0.02,
    slotId: 'tandem_left_upper',
    labelAnchor: _TarotSlotAnchor.left,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '오른쪽 위',
    0.34,
    0.50,
    slotId: 'tandem_right_upper',
    labelAnchor: _TarotSlotAnchor.right,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '중심',
    0.66,
    0.50,
    slotId: 'tandem_center',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '왼쪽 아래',
    0.34,
    0.98,
    slotId: 'tandem_left_lower',
    labelAnchor: _TarotSlotAnchor.top,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '오른쪽 아래',
    0.66,
    0.98,
    slotId: 'tandem_right_lower',
    labelAnchor: _TarotSlotAnchor.top,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
];

const _tarotSpreadRelationshipSlots = [
  _TarotSlotSpec(
    '상단 왼쪽',
    0.24,
    0.02,
    slotId: 'relationship_top_left',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '상단 오른쪽',
    0.76,
    0.02,
    slotId: 'relationship_top_right',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '나',
    0.24,
    0.50,
    slotId: 'relationship_me',
    labelAnchor: _TarotSlotAnchor.right,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '상대',
    0.76,
    0.50,
    slotId: 'relationship_you',
    labelAnchor: _TarotSlotAnchor.left,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '하단 왼쪽',
    0.24,
    0.98,
    slotId: 'relationship_bottom_left',
    labelAnchor: _TarotSlotAnchor.top,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '하단 중심',
    0.50,
    0.50,
    slotId: 'relationship_bottom_center',
    zIndex: 2,
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '하단 오른쪽',
    0.76,
    0.98,
    slotId: 'relationship_bottom_right',
    labelAnchor: _TarotSlotAnchor.top,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
];

const _tarotSpreadCupRelationshipSlots = [
  _TarotSlotSpec(
    '왼쪽 상단',
    0.22,
    0.02,
    slotId: 'cup_left_top',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '상단 중심',
    0.50,
    0.00,
    slotId: 'cup_top',
    widthFactor: 1.0,
    heightFactor: 1.0,
    labelAnchor: _TarotSlotAnchor.bottom,
  ),
  _TarotSlotSpec(
    '오른쪽 상단',
    0.78,
    0.02,
    slotId: 'cup_right_top',
    labelAnchor: _TarotSlotAnchor.bottom,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '왼쪽 마음',
    0.18,
    0.40,
    slotId: 'cup_left_heart',
    labelAnchor: _TarotSlotAnchor.right,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '중심 연결',
    0.50,
    0.48,
    slotId: 'cup_center',
    zIndex: 2,
    widthFactor: 1.0,
    heightFactor: 1.0,
    labelAnchor: _TarotSlotAnchor.left,
  ),
  _TarotSlotSpec(
    '오른쪽 마음',
    0.82,
    0.40,
    slotId: 'cup_right_heart',
    labelAnchor: _TarotSlotAnchor.left,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '겹친 마음',
    0.50,
    0.48,
    slotId: 'cup_overlap',
    zIndex: 3,
    overlapTargetSlotId: 'cup_center',
    isHorizontalOverlay: true,
    labelAnchor: _TarotSlotAnchor.right,
    infoAnchor: _TarotSlotAnchor.right,
    widthFactor: 1.0,
    heightFactor: 0.94,
  ),
  _TarotSlotSpec(
    '왼쪽 기반',
    0.34,
    0.96,
    slotId: 'cup_left_base',
    labelAnchor: _TarotSlotAnchor.top,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
  _TarotSlotSpec(
    '오른쪽 기반',
    0.66,
    0.96,
    slotId: 'cup_right_base',
    labelAnchor: _TarotSlotAnchor.top,
    widthFactor: 1.0,
    heightFactor: 1.0,
  ),
];
