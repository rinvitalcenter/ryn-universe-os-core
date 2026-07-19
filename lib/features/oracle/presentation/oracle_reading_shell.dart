import 'package:flutter/material.dart';

import '../../../core/text/user_text.dart';
import '../application/oracle_reading_controller.dart';
import '../domain/oracle_card_definition.dart';
import '../domain/oracle_reading_session.dart';

class OracleReadingShell extends StatefulWidget {
  const OracleReadingShell({
    super.key,
    required this.controller,
    required this.onBackToAtelier,
  });

  final OracleReadingController controller;
  final VoidCallback onBackToAtelier;

  @override
  State<OracleReadingShell> createState() => _OracleReadingShellState();
}

class _OracleReadingShellState extends State<OracleReadingShell> {
  late final TextEditingController _questionController;
  late final TextEditingController _messageController;
  late final TextEditingController _actionController;
  var _drawCount = 1;
  var _shuffleInProgress = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.controller.questionText,
    );
    _questionController.addListener(_onQuestionChanged);
    _messageController = TextEditingController(
      text: widget.controller.messageNote,
    );
    _actionController = TextEditingController(
      text: widget.controller.smallAction,
    );
    _drawCount = widget.controller.drawCount;
  }

  @override
  void dispose() {
    _questionController.removeListener(_onQuestionChanged);
    _questionController.dispose();
    _messageController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  void _onQuestionChanged() {
    if (mounted) setState(() {});
  }

  void _start() {
    widget.controller.start(
      questionText: _questionController.text,
      drawCount: _drawCount,
    );
  }

  void _toggleCard(String cardId) {
    final selected = widget.controller.selectedCards.any(
      (card) => card.cardId == cardId,
    );
    if (selected) {
      widget.controller.deselectCard(cardId);
    } else {
      widget.controller.selectCard(cardId);
    }
  }

  Future<void> _shuffle() async {
    if (_shuffleInProgress) return;
    setState(() => _shuffleInProgress = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    widget.controller.shuffle();
    if (mounted) setState(() => _shuffleInProgress = false);
  }

  void _complete() {
    widget.controller.updateInterpretation(
      messageNote: _messageController.text,
      smallAction: _actionController.text,
    );
    widget.controller.complete();
  }

  void _continueLatest() {
    if (!widget.controller.reopenLatestInterpretation()) return;
    _messageController.text = widget.controller.messageNote;
    _actionController.text = widget.controller.smallAction;
  }

  void _newReading() {
    widget.controller.startNewReading();
    _questionController.clear();
    _messageController.clear();
    _actionController.clear();
    setState(() => _drawCount = 1);
  }

  void _handleHeaderBack() {
    final stage = widget.controller.stage;
    if (stage == OracleReadingStage.setup ||
        stage == OracleReadingStage.completed) {
      widget.onBackToAtelier();
      return;
    }
    widget.controller.startNewReading();
    _messageController.clear();
    _actionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      key: const Key('oracle-reading-shell'),
      animation: widget.controller,
      builder: (context, _) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(2, 2, 2, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _OracleHeader(
              stage: widget.controller.stage,
              onBack: _handleHeaderBack,
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _buildStage(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStage(BuildContext context) {
    return switch (widget.controller.stage) {
      OracleReadingStage.setup => _buildSetup(context),
      OracleReadingStage.shuffle => _buildShuffle(context),
      OracleReadingStage.draw => _buildDraw(context),
      OracleReadingStage.result => _buildResult(context),
      OracleReadingStage.interpretation => _buildInterpretation(context),
      OracleReadingStage.completed => _buildCompleted(context),
    };
  }

  Widget _buildSetup(BuildContext context) {
    final deck = widget.controller.deck;
    final canStart = _questionController.text.trim().isNotEmpty;
    return _OracleStageSurface(
      key: const ValueKey('oracle-setup-stage'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 820;
          final scheme = Theme.of(context).colorScheme;
          final cover = Container(
            key: const Key('oracle-setup-cover-scene'),
            constraints: const BoxConstraints(minHeight: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary.withValues(alpha: 0.12),
                  scheme.surface.withValues(alpha: 0.18),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  width: 300,
                  height: 300,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.12),
                        width: 22,
                      ),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    deck.coverAssetPath,
                    width: compact ? 190 : 230,
                    height: compact ? 296 : 356,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 18,
                  child: Row(
                    children: [
                      Text(
                        '52장',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text('·', style: TextStyle(color: scheme.outline)),
                      const SizedBox(width: 8),
                      Text(
                        '역방향 미사용',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
          final form = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '오늘 마음에 머무는 질문',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                deck.displayName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                key: const Key('oracle-question-field'),
                controller: _questionController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '지금 마음에 머무는 질문을 적어보세요',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '어떤 방식으로 메시지를 만날까요?',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              SegmentedButton<int>(
                showSelectedIcon: true,
                segments: const [
                  ButtonSegment(
                    value: 1,
                    label: Text('한 장의 메시지', key: Key('oracle-draw-choice-1')),
                    icon: Icon(Icons.looks_one_rounded),
                  ),
                  ButtonSegment(
                    value: 3,
                    label: Text('세 장의 흐름', key: Key('oracle-draw-choice-3')),
                    icon: Icon(Icons.filter_3_rounded),
                  ),
                ],
                selected: {_drawCount},
                onSelectionChanged: (selection) {
                  setState(() => _drawCount = selection.single);
                },
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  key: const Key('oracle-start-reading'),
                  onPressed: canStart ? _start : null,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('메시지를 만나기'),
                ),
              ),
            ],
          );
          if (compact) {
            return Column(children: [cover, const SizedBox(height: 20), form]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 43, child: cover),
              const SizedBox(width: 38),
              Expanded(flex: 57, child: form),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShuffle(BuildContext context) {
    final deck = widget.controller.deck;
    final scheme = Theme.of(context).colorScheme;
    return _OracleStageSurface(
      key: const ValueKey('oracle-shuffle-stage'),
      child: Container(
        constraints: const BoxConstraints(minHeight: 440),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              scheme.primary.withValues(alpha: 0.10),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '질문을 마음에 두고 카드를 섞어보세요',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.controller.questionText}  ·  ${widget.controller.drawCount}장 리딩',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 290,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (var index = 2; index >= 0; index--)
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeInOutCubic,
                      offset: _shuffleInProgress
                          ? Offset(
                              (index - 1) * 0.28,
                              index.isEven ? -0.04 : 0.04,
                            )
                          : Offset(index * 0.025, -index * 0.018),
                      child: AnimatedRotation(
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeInOutCubic,
                        turns: _shuffleInProgress
                            ? (index - 1) * 0.035
                            : (index - 1) * 0.006,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            deck.cardBackAssetPath,
                            width: 188,
                            height: 294,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('oracle-shuffle-action'),
              onPressed: _shuffleInProgress ? null : _shuffle,
              icon: Icon(
                _shuffleInProgress
                    ? Icons.hourglass_top_rounded
                    : Icons.autorenew_rounded,
              ),
              label: Text(_shuffleInProgress ? '카드가 자리를 찾는 중' : '카드 섞기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraw(BuildContext context) {
    final controller = widget.controller;
    final rows = List.generate(
      3,
      (row) => [
        for (
          var index = row;
          index < controller.shuffledCards.length;
          index += 3
        )
          controller.shuffledCards[index],
      ],
    );
    return _OracleStageSurface(
      key: const ValueKey('oracle-draw-stage'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '마음이 머무는 카드를 선택하세요',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${controller.questionText}  ·  ${controller.selectedCards.length} / ${controller.drawCount}장 선택',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          for (var row = 0; row < rows.length; row++)
            _OracleCardRibbon(
              key: Key('oracle-draw-ribbon-${row + 1}'),
              cards: rows[row],
              selectedCards: controller.selectedCards,
              cardBackAssetPath: controller.deck.cardBackAssetPath,
              leadingInset: row * 28,
              onTap: _toggleCard,
            ),
          const SizedBox(height: 10),
          _OracleSelectionDock(
            key: const Key('oracle-selection-dock'),
            drawCount: controller.drawCount,
            selectedCards: controller.selectedCards,
            cardBackAssetPath: controller.deck.cardBackAssetPath,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.center,
            child: FilledButton.icon(
              key: const Key('oracle-confirm-selection'),
              onPressed: controller.canConfirmSelection
                  ? controller.confirmSelection
                  : null,
              icon: const Icon(Icons.visibility_rounded),
              label: const Text('선택한 카드 공개'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    return _buildStoryWorkspace(context, stage: OracleReadingStage.result);
  }

  Widget _buildInterpretation(BuildContext context) {
    return _buildStoryWorkspace(
      context,
      stage: OracleReadingStage.interpretation,
    );
  }

  Widget _buildCompleted(BuildContext context) {
    return KeyedSubtree(
      key: const Key('oracle-completed-stage'),
      child: _buildStoryWorkspace(context, stage: OracleReadingStage.completed),
    );
  }

  Widget _buildStoryWorkspace(
    BuildContext context, {
    required OracleReadingStage stage,
  }) {
    final editable = stage == OracleReadingStage.interpretation;
    final completed = stage == OracleReadingStage.completed;
    final placements = widget.controller.placements;
    final scheme = Theme.of(context).colorScheme;
    return _OracleStageSurface(
      key: ValueKey(
        stage == OracleReadingStage.completed
            ? 'oracle-completed-workspace-stage'
            : 'oracle-${stage.name}-stage',
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 900;
          final cardScene = Container(
            key: const Key('oracle-story-card-scene'),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary.withValues(alpha: 0.09),
                  scheme.surface.withValues(alpha: 0.24),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < placements.length; index++) ...[
                  if (index > 0) const SizedBox(width: 14),
                  Flexible(
                    child: _OracleRevealedCard(
                      placement: placements[index],
                      imageKey: Key('oracle-result-card-image-${index + 1}'),
                      prominent: placements.length == 1,
                    ),
                  ),
                ],
              ],
            ),
          );
          final story = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (completed) ...[
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      completed ? '리딩을 천천히 마쳤습니다' : '카드가 전하는 이야기를 한 장면에 남겨보세요',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.controller.questionText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                key: const Key('oracle-message-note-field'),
                controller: _messageController,
                enabled: editable,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '이 리딩이 전하는 메시지',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const Key('oracle-small-action-field'),
                controller: _actionController,
                enabled: editable,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '지금 실천할 한 가지',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const Spacer(),
              if (stage == OracleReadingStage.result)
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    key: const Key('oracle-message-action'),
                    onPressed: widget.controller.openInterpretation,
                    icon: const Icon(Icons.edit_note_rounded),
                    label: const Text('메시지 기록하기'),
                  ),
                )
              else if (editable)
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    key: const Key('oracle-complete-action'),
                    onPressed: _complete,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('리딩 완료'),
                  ),
                )
              else
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton.icon(
                      key: const Key('oracle-back-to-atelier'),
                      onPressed: widget.onBackToAtelier,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('리딩으로 돌아가기'),
                    ),
                    OutlinedButton.icon(
                      key: const Key('oracle-new-reading-action'),
                      onPressed: _newReading,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('새 오라클 리딩'),
                    ),
                    FilledButton.icon(
                      key: const Key('oracle-continue-latest-action'),
                      onPressed: _continueLatest,
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('다시 이어보기'),
                    ),
                  ],
                ),
            ],
          );
          return SizedBox(
            key: const Key('oracle-story-workspace'),
            height: compact ? 900 : 500,
            child: compact
                ? Column(
                    children: [
                      Expanded(child: cardScene),
                      const SizedBox(height: 18),
                      SizedBox(height: 430, child: story),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 58, child: cardScene),
                      const SizedBox(width: 24),
                      Expanded(flex: 42, child: story),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _OracleHeader extends StatelessWidget {
  const _OracleHeader({required this.stage, required this.onBack});

  final OracleReadingStage stage;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip:
              stage == OracleReadingStage.setup ||
                  stage == OracleReadingStage.completed
              ? '리딩으로 돌아가기'
              : '질문 설정으로 돌아가기',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                UserText.oracleReadingTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                _stageLabel(stage),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 86,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stage.index + 1} / ${OracleReadingStage.values.length}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: (stage.index + 1) / OracleReadingStage.values.length,
                minHeight: 3,
                borderRadius: BorderRadius.circular(99),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _stageLabel(OracleReadingStage stage) => switch (stage) {
    OracleReadingStage.setup => '질문과 카드 수를 정합니다',
    OracleReadingStage.shuffle => '카드를 섞습니다',
    OracleReadingStage.draw => '마음이 머무는 카드를 고릅니다',
    OracleReadingStage.result => '선택한 메시지를 확인합니다',
    OracleReadingStage.interpretation => '나의 문장과 작은 실천을 남깁니다',
    OracleReadingStage.completed => '완료한 리딩을 확인합니다',
  };
}

class _OracleStageSurface extends StatelessWidget {
  const _OracleStageSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.surfaceContainerLow, scheme.surfaceContainerLowest],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _OracleCardRibbon extends StatelessWidget {
  const _OracleCardRibbon({
    super.key,
    required this.cards,
    required this.selectedCards,
    required this.cardBackAssetPath,
    required this.leadingInset,
    required this.onTap,
  });

  final List<OracleCardDefinition> cards;
  final List<OracleCardDefinition> selectedCards;
  final String cardBackAssetPath;
  final int leadingInset;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 126,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.only(left: leadingInset.toDouble(), top: 7),
          child: Row(
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                if (index > 0) const SizedBox(width: 7),
                Builder(
                  builder: (context) {
                    final card = cards[index];
                    final selectedOrder = selectedCards.indexWhere(
                      (item) => item.cardId == card.cardId,
                    );
                    return _OracleRibbonCard(
                      key: Key('oracle-draw-card-${card.cardId}'),
                      card: card,
                      cardBackAssetPath: cardBackAssetPath,
                      selectedOrder: selectedOrder < 0
                          ? null
                          : selectedOrder + 1,
                      onTap: () => onTap(card.cardId),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OracleRibbonCard extends StatefulWidget {
  const _OracleRibbonCard({
    super.key,
    required this.card,
    required this.cardBackAssetPath,
    required this.selectedOrder,
    required this.onTap,
  });

  final OracleCardDefinition card;
  final String cardBackAssetPath;
  final int? selectedOrder;
  final VoidCallback onTap;

  @override
  State<_OracleRibbonCard> createState() => _OracleRibbonCardState();
}

class _OracleRibbonCardState extends State<_OracleRibbonCard> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFFC7A45A);
    final scheme = Theme.of(context).colorScheme;
    final selected = widget.selectedOrder != null;
    return Semantics(
      button: true,
      selected: selected,
      label: selected
          ? '뒤집힌 오라클 카드, ${widget.selectedOrder}번째로 선택됨'
          : '뒤집힌 오라클 카드, 선택 가능',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(
            0,
            _hovered
                ? -8
                : selected
                ? -4
                : 0,
            0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected ? selectedColor : scheme.outlineVariant,
              width: selected ? 3 : 1,
            ),
            boxShadow: [
              if (_hovered || selected)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 78,
                height: 116,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.asset(
                        widget.cardBackAssetPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (selected)
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: selectedColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${widget.selectedOrder}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
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
    );
  }
}

class _OracleSelectionDock extends StatelessWidget {
  const _OracleSelectionDock({
    super.key,
    required this.drawCount,
    required this.selectedCards,
    required this.cardBackAssetPath,
  });

  final int drawCount;
  final List<OracleCardDefinition> selectedCards;
  final String cardBackAssetPath;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labels = drawCount == 1
        ? const ['지금 나에게 온 메시지']
        : const ['지금', '알아차릴 것', '작은 실천'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < drawCount; index++) ...[
            if (index > 0) const SizedBox(width: 12),
            Expanded(
              child: Container(
                key: Key('oracle-selection-slot-${index + 1}'),
                height: 62,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    if (index < selectedCards.length)
                      ClipRRect(
                        key: Key('oracle-selected-card-${index + 1}'),
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          cardBackAssetPath,
                          width: 28,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Icon(
                        Icons.add_rounded,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        labels[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OracleRevealedCard extends StatelessWidget {
  const _OracleRevealedCard({
    required this.placement,
    required this.imageKey,
    required this.prominent,
  });

  final OracleCardPlacement placement;
  final Key imageKey;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final width = prominent ? 220.0 : 170.0;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            placement.positionName,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              placement.imageAssetPath,
              key: imageKey,
              width: width,
              height: prominent ? 338 : 260,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            placement.cardTitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (placement.originalTitle case final title?)
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
