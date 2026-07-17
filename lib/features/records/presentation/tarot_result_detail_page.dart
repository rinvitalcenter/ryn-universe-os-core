import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../core/formatters/korean_date_time_formatter.dart';
import '../../tarot/models/tarot_interpretation_session_draft.dart';
import '../../tarot/models/tarot_reading_result_snapshot.dart';
import 'records_tarot_card.dart';

class TarotResultDetailPage extends StatelessWidget {
  const TarotResultDetailPage({
    required this.snapshot,
    required this.isActiveOnHome,
    required this.onBack,
    required this.onShowOnHome,
    required this.onHideFromHome,
    this.interpretationDraft,
    this.questionDisplayText,
    super.key,
  });

  final TarotReadingResultSnapshot snapshot;
  final TarotInterpretationSessionDraft? interpretationDraft;
  final String? questionDisplayText;
  final bool isActiveOnHome;
  final VoidCallback onBack;
  final VoidCallback onShowOnHome;
  final VoidCallback onHideFromHome;

  TarotInterpretationSessionDraft? get _matchingDraft =>
      interpretationDraft?.readingInstanceId == snapshot.readingInstanceId
      ? interpretationDraft
      : null;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FocusTraversalGroup(
      child: SingleChildScrollView(
        key: const Key('tarot-result-detail-page'),
        padding: const EdgeInsets.all(28),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('tarot-result-detail-back'),
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('성장 기록으로 돌아가기'),
                    ),
                    if (isActiveOnHome)
                      TextButton.icon(
                        onPressed: onHideFromHome,
                        icon: const Icon(Icons.visibility_off_outlined),
                        label: const Text('홈에서 닫기'),
                      )
                    else
                      FilledButton.tonalIcon(
                        key: const Key('detail-show-on-home'),
                        onPressed: onShowOnHome,
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('홈에 표시'),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  '셀프 타로 저널',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  questionDisplayText ?? snapshot.readingQuestionText,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _DetailMeta(
                      icon: Icons.calendar_today_outlined,
                      label: KoreanDateTimeFormatter.full(snapshot.readingAt),
                    ),
                    _DetailMeta(
                      icon: Icons.style_outlined,
                      label: snapshot.deckNameSnapshot,
                    ),
                    _DetailMeta(
                      icon: Icons.grid_view_rounded,
                      label: snapshot.spreadNameSnapshot,
                    ),
                    _DetailMeta(
                      icon: Icons.layers_outlined,
                      label: '${snapshot.placements.length}장',
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final spreadScene = _TarotRecordSpreadScene(
                      snapshot: snapshot,
                    );
                    final journal = _TarotRecordInterpretationJournal(
                      draft: _matchingDraft,
                    );
                    if (constraints.maxWidth < 1000) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          spreadScene,
                          const SizedBox(height: 22),
                          journal,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: spreadScene),
                        const SizedBox(width: 22),
                        Expanded(flex: 4, child: journal),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 34),
                _TarotRecordCardDetailSection(snapshot: snapshot),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TarotRecordCardDetailSection extends StatefulWidget {
  const _TarotRecordCardDetailSection({required this.snapshot});

  final TarotReadingResultSnapshot snapshot;

  @override
  State<_TarotRecordCardDetailSection> createState() =>
      _TarotRecordCardDetailSectionState();
}

class _TarotRecordCardDetailSectionState
    extends State<_TarotRecordCardDetailSection> {
  bool _expanded = false;
  final FocusNode _toggleFocusNode = FocusNode(
    debugLabel: 'tarot-record-card-detail-toggle',
  );

  @override
  void dispose() {
    _toggleFocusNode.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final count = widget.snapshot.placements.length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 240),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '카드별 상세 · $count장',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '각 카드의 이름, 위치, 방향을 개별적으로 확인합니다.',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                key: const Key('tarot-record-card-detail-toggle'),
                label: '카드별 상세, ${_expanded ? '펼침' : '접힘'}',
                expanded: _expanded,
                button: true,
                child: TextButton.icon(
                  focusNode: _toggleFocusNode,
                  onPressed: _toggleExpanded,
                  icon: Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                  ),
                  label: Text(_expanded ? '접기' : '펼치기'),
                ),
              ),
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: 18),
            FocusTraversalGroup(
              key: const Key('tarot-record-card-detail-panel'),
              child: FocusTraversalGroup(
                key: const Key('tarot-record-full-card-list'),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth < 700 ? 112.0 : 128.0;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 22,
                      children: [
                        for (final placement in widget.snapshot.placements)
                          Semantics(
                            sortKey: OrdinalSortKey(
                              placement.placementOrder.toDouble(),
                            ),
                            child: KeyedSubtree(
                              key: Key(
                                'tarot-record-card-detail-item-${placement.placementOrder}',
                              ),
                              child: FocusableActionDetector(
                                key: Key(
                                  'detail-placement-${placement.placementOrder}',
                                ),
                                child: RecordsTarotCard(
                                  deckId: widget.snapshot.deckId,
                                  placement: placement,
                                  width: width,
                                  detail: true,
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
          ],
        ],
      ),
    );
  }
}

class _TarotRecordSpreadScene extends StatelessWidget {
  const _TarotRecordSpreadScene({required this.snapshot});

  final TarotReadingResultSnapshot snapshot;

  bool get _isCelticCross =>
      snapshot.spreadId == 'celtic_cross' && snapshot.placements.length == 10;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '${snapshot.spreadNameSnapshot} 스프레드 장면',
      child: Container(
        key: const Key('tarot-record-spread-scene'),
        height: _isCelticCross ? 620 : 470,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF161B29),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0x335F6C8B)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (snapshot.placements.length == 1) {
              return Center(
                child: _ScenePlacement(
                  snapshot: snapshot,
                  placement: snapshot.placements.single,
                  width: 178,
                ),
              );
            }
            if (snapshot.placements.length == 3) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final placement in snapshot.placements)
                    _ScenePlacement(
                      snapshot: snapshot,
                      placement: placement,
                      width: 118,
                    ),
                ],
              );
            }
            if (_isCelticCross) {
              return _CelticCrossScene(snapshot: snapshot);
            }
            return Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 18,
              children: [
                for (final placement in snapshot.placements)
                  _ScenePlacement(
                    snapshot: snapshot,
                    placement: placement,
                    width: 82,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CelticCrossScene extends StatelessWidget {
  const _CelticCrossScene({required this.snapshot});

  final TarotReadingResultSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      key: const Key('tarot-record-celtic-cross'),
      builder: (context, constraints) {
        const width = 56.0;
        const positions = <Offset>[
          Offset(.34, .48),
          Offset(.34, .48),
          Offset(.34, .12),
          Offset(.34, .84),
          Offset(.10, .48),
          Offset(.58, .48),
        ];
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (var index = 0; index < 6; index++)
              Positioned(
                left: positions[index].dx * constraints.maxWidth - width / 2,
                top: positions[index].dy * constraints.maxHeight - 58,
                child: _ScenePlacement(
                  snapshot: snapshot,
                  placement: snapshot.placements[index],
                  width: width,
                  quarterTurn: index == 1,
                ),
              ),
            Positioned(
              key: const Key('tarot-record-celtic-staff'),
              right: constraints.maxWidth * .04,
              top: 4,
              bottom: 4,
              width: 76,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var index = 9; index >= 6; index--)
                    _ScenePlacement(
                      snapshot: snapshot,
                      placement: snapshot.placements[index],
                      width: width,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScenePlacement extends StatelessWidget {
  const _ScenePlacement({
    required this.snapshot,
    required this.placement,
    required this.width,
    this.quarterTurn = false,
  });

  final TarotReadingResultSnapshot snapshot;
  final TarotCardPlacementSnapshot placement;
  final double width;
  final bool quarterTurn;

  @override
  Widget build(BuildContext context) {
    final card = RecordsTarotCard(
      deckId: snapshot.deckId,
      placement: placement,
      width: width,
      showOrientation: false,
    );
    return FocusableActionDetector(
      key: Key('tarot-record-scene-placement-${placement.placementOrder}'),
      child: quarterTurn
          ? Transform.rotate(angle: math.pi / 2, child: card)
          : card,
    );
  }
}

class _TarotRecordInterpretationJournal extends StatelessWidget {
  const _TarotRecordInterpretationJournal({required this.draft});

  final TarotInterpretationSessionDraft? draft;

  @override
  Widget build(BuildContext context) {
    final sections = <(String, String)>[
      ('전체 이미지 관찰', draft?.wholeImageObservation.trim() ?? ''),
      ('흐름 해석', draft?.flowInterpretation.trim() ?? ''),
      ('핵심 메시지', draft?.coreMessage.trim() ?? ''),
      ('오늘의 조언 / 작은 실천', draft?.smallAction.trim() ?? ''),
    ].where((entry) => entry.$2.isNotEmpty).toList(growable: false);
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: '작성한 해석',
      child: Container(
        key: const Key('tarot-record-interpretation-journal'),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: FocusableActionDetector(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '나의 해석',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                '작성한 해석은 현재 앱 실행 동안 이어집니다.',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              if (sections.isEmpty)
                Text(
                  '이번 리딩에서 작성한 해석이 없습니다.',
                  style: TextStyle(color: colors.onSurfaceVariant, height: 1.6),
                )
              else
                for (var index = 0; index < sections.length; index++) ...[
                  if (index > 0) ...[
                    const SizedBox(height: 18),
                    Divider(color: colors.outlineVariant),
                    const SizedBox(height: 14),
                  ],
                  Semantics(
                    header: true,
                    child: Text(
                      sections[index].$1,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  SelectableText(
                    sections[index].$2,
                    style: const TextStyle(height: 1.65),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailMeta extends StatelessWidget {
  const _DetailMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: colors.onSurfaceVariant),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
