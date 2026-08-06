import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/ryn_tokens.dart';
import '../application/saju_daeun_seun_controller.dart';
import '../domain/daeun_seun_models.dart';
import 'saju_element_palette.dart';

class SajuDaeunTimeline extends StatelessWidget {
  const SajuDaeunTimeline({
    super.key,
    required this.controller,
    this.showSourceBanner = true,
    this.showDetail = true,
  });

  final SajuDaeunSeunController controller;
  final bool showSourceBanner;
  final bool showDetail;

  @override
  Widget build(BuildContext context) {
    if (!controller.hasSource) {
      return const _StatusPanel(
        title: '대운 자료가 아직 없습니다.',
        body: '대운과 세운을 확인하려면 먼저 원국을 계산하거나 저장된 명식을 선택해 주세요.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showSourceBanner) ...[
          _SourceBanner(controller: controller),
          const SizedBox(height: 12),
        ],
        if (controller.daeunPhase == SajuDerivedPhase.calculating)
          const _StatusPanel(
            title: '대운을 계산하고 있습니다.',
            body: '원국을 바꾸지 않고 현재 명식의 대운 흐름을 준비합니다.',
            loading: true,
          )
        else if (controller.daeunPhase == SajuDerivedPhase.error)
          _StatusPanel(
            title: controller.daeunError ?? '대운 결과를 표시할 수 없습니다.',
            body: controller.seunPhase == SajuDerivedPhase.ready
                ? '원국은 그대로 유지됩니다. 아래 세운 영역에서 연도별 간지 라벨을 확인할 수 있습니다.'
                : '위 원국 영역에서 출생정보와 계산 기준을 확인해 주세요.',
          )
        else if (controller.daeunResult case final result?)
          _DaeunResultStage(
            controller: controller,
            result: result,
            showDetail: showDetail,
          )
        else
          const _StatusPanel(
            title: '대운 결과가 준비되지 않았습니다.',
            body: '원국을 다시 계산하거나 저장 이력을 선택해 주세요.',
          ),
      ],
    );
  }
}

class _DaeunResultStage extends StatelessWidget {
  const _DaeunResultStage({
    required this.controller,
    required this.result,
    required this.showDetail,
  });

  final SajuDaeunSeunController controller;
  final DaeunCalculationResult result;
  final bool showDetail;

  @override
  Widget build(BuildContext context) {
    final direction = result.direction == DaeunDirection.forward ? '순행' : '역행';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _MetaChip(label: '대운수 ${result.daeunNumber} · $direction'),
            _MetaChip(
              label:
                  '첫 시작 ${result.firstStartTraditionalAge}세 · ${result.firstStartYear}년',
            ),
            _MetaChip(label: '전통 나이 · ${result.cycles.length}주기'),
            TextButton.icon(
              key: const Key('saju-daeun-provenance'),
              onPressed: () => _showProvenance(context, result.metadata),
              icon: const Icon(Icons.source_outlined, size: 16),
              label: const Text('계산 근거'),
            ),
          ],
        ),
        if (result.warnings.isNotEmpty) ...[
          const SizedBox(height: 10),
          _WarningStrip(warnings: result.warnings),
        ],
        const SizedBox(height: 8),
        _DaeunBand(controller: controller, result: result),
        if (showDetail) ...[
          const SizedBox(height: 12),
          SajuDaeunDetailPanel(controller: controller),
        ],
      ],
    );
  }
}

class _DaeunBand extends StatefulWidget {
  const _DaeunBand({required this.controller, required this.result});

  final SajuDaeunSeunController controller;
  final DaeunCalculationResult result;

  @override
  State<_DaeunBand> createState() => _DaeunBandState();
}

class _DaeunBandState extends State<_DaeunBand> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'Saju Daeun band');
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final cycles = widget.result.cycles;
    final selected = widget.controller.selectedDaeunCycle;
    final currentIndex = selected == null
        ? 0
        : cycles.indexWhere((cycle) => cycle.sequence == selected.sequence);
    final normalizedIndex = currentIndex < 0 ? 0 : currentIndex;
    final targetIndex = switch (key) {
      LogicalKeyboardKey.arrowLeft => normalizedIndex - 1,
      LogicalKeyboardKey.arrowRight => normalizedIndex + 1,
      LogicalKeyboardKey.home => 0,
      LogicalKeyboardKey.end => cycles.length - 1,
      _ => normalizedIndex,
    };
    if (key != LogicalKeyboardKey.arrowLeft &&
        key != LogicalKeyboardKey.arrowRight &&
        key != LogicalKeyboardKey.home &&
        key != LogicalKeyboardKey.end) {
      return KeyEventResult.ignored;
    }
    final bounded = targetIndex.clamp(0, cycles.length - 1);
    if (bounded != normalizedIndex) {
      unawaited(widget.controller.selectDaeunCycle(cycles[bounded].sequence));
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(bounded));
    }
    return KeyEventResult.handled;
  }

  void _reveal(int index) {
    if (!_scrollController.hasClients) return;
    final target = (index * 118.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    unawaited(
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return Focus(
      key: const Key('saju-daeun-keyboard'),
      focusNode: _focusNode,
      onKeyEvent: _onKeyEvent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 6.0;
          final fitAll = constraints.maxWidth >= 1000;
          final itemWidth = fitAll
              ? (constraints.maxWidth - gap * 10) / 11
              : 112.0;
          final row = Row(
            children: [
              for (
                var index = 0;
                index < widget.result.cycles.length;
                index++
              ) ...[
                if (index > 0) const SizedBox(width: gap),
                _DaeunNode(
                  width: itemWidth,
                  cycle: widget.result.cycles[index],
                  selected:
                      widget.controller.selectedDaeunCycle?.sequence ==
                      widget.result.cycles[index].sequence,
                  onTap: () {
                    _focusNode.requestFocus();
                    unawaited(
                      widget.controller.selectDaeunCycle(
                        widget.result.cycles[index].sequence,
                      ),
                    );
                    _reveal(index);
                  },
                ),
              ],
              if (!fitAll) const SizedBox(width: 38),
            ],
          );
          return Stack(
            children: [
              SingleChildScrollView(
                key: const Key('saju-daeun-timeline-scroll'),
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: row,
              ),
              if (!fitAll)
                Positioned.fill(
                  left: null,
                  child: IgnorePointer(
                    child: Container(
                      width: 34,
                      alignment: Alignment.center,
                      color: colors.primarySurface.withValues(alpha: 0.92),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: colors.mutedText,
                      ),
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

class _DaeunNode extends StatelessWidget {
  const _DaeunNode({
    required this.width,
    required this.cycle,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final DaeunCycle cycle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final selection = SajuElementPalette.selection(
      Theme.of(context).brightness,
    );
    return SizedBox(
      width: width,
      height: 107,
      child: Material(
        color: selected ? selection.background : colors.secondarySurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: selected ? selection.border : colors.hairline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          key: Key('saju-daeun-cycle-${cycle.sequence}'),
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(7, 6, 7, 7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${cycle.sequence}',
                  style: TextStyle(
                    color: selected ? selection.foreground : colors.mutedText,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cycle.pillar.hanja,
                  style: TextStyle(
                    fontFamily: 'ChosunGs',
                    color: selected ? selection.foreground : colors.primaryText,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${cycle.startTraditionalAge}세 · ${cycle.startYear}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? selection.foreground
                        : colors.secondaryText,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${cycle.heavenlyStemTenGod.label} · ${cycle.earthlyBranchMainQiTenGod.label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.mutedText, fontSize: 9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SajuDaeunDetailPanel extends StatelessWidget {
  const SajuDaeunDetailPanel({super.key, required this.controller});

  final SajuDaeunSeunController controller;

  @override
  Widget build(BuildContext context) {
    final cycle = controller.selectedDaeunCycle;
    if (cycle == null) return const SizedBox.shrink();
    final colors = context.rynColors;
    return Container(
      key: const Key('saju-daeun-detail'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primarySurface,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: colors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${cycle.sequence}번째 대운',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cycle.pillar.hanja,
                style: TextStyle(
                  fontFamily: 'ChosunGs',
                  color: colors.primaryText,
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cycle.startTraditionalAge}세 · ${cycle.startYear}–${cycle.endYearExclusive - 1}',
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${cycle.heavenlyStemTenGod.label} / ${cycle.earthlyBranchMainQiTenGod.label}',
                      style: TextStyle(color: colors.secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceBanner extends StatelessWidget {
  const _SourceBanner({required this.controller});

  final SajuDaeunSeunController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final provenance = controller.sourceProvenance;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.secondarySurface,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: colors.hairline),
      ),
      child: Text(
        '${provenance?.sourceLabel ?? '원국'} · ${provenance?.timezoneId ?? 'Asia/Seoul'} · ${provenance?.birthPlaceProfile ?? '서울 호환'}',
        style: TextStyle(color: colors.secondaryText, fontSize: 12),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.title,
    required this.body,
    this.loading = false,
  });

  final String title;
  final String body;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.secondarySurface,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: colors.hairline),
      ),
      child: Row(
        children: [
          if (loading) ...[
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(color: colors.secondaryText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: colors.secondarySurface,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: colors.hairline),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.secondaryText,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WarningStrip extends StatelessWidget {
  const _WarningStrip({required this.warnings});

  final List<DaeunSeunWarningCode> warnings;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final copy =
        warnings.contains(DaeunSeunWarningCode.unknownTimeStableCivilDay)
        ? '해당 날짜의 분 단위 후보에서 대운수가 동일하게 계산되어 시간 미상 결과를 표시합니다.'
        : '계산 경계를 확인해 주세요.';
    return Text(
      copy,
      style: TextStyle(color: colors.secondaryText, fontSize: 12, height: 1.4),
    );
  }
}

Future<void> _showProvenance(
  BuildContext context,
  DaeunSeunMetadata metadata,
) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('계산 기준과 출처'),
    content: SizedBox(
      width: 620,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProvenanceRow(
              label: 'Engine',
              value: '${metadata.engineId} ${metadata.engineVersion}',
            ),
            _ProvenanceRow(
              label: 'Policy',
              value: '${metadata.policyId} ${metadata.policyVersion}',
            ),
            _ProvenanceRow(
              label: 'Reference',
              value:
                  '${metadata.referenceProductId} ${metadata.referenceVersion}',
            ),
            _ProvenanceRow(label: 'Fixture', value: metadata.fixtureSet),
            _ProvenanceRow(
              label: 'Direction',
              value: metadata.directionRuleVersion,
            ),
            _ProvenanceRow(label: 'Term', value: metadata.termSelectionVersion),
            _ProvenanceRow(
              label: 'Daeun number',
              value: metadata.daeunNumberVersion,
            ),
            _ProvenanceRow(
              label: 'First cycle',
              value: metadata.firstCycleVersion,
            ),
            _ProvenanceRow(
              label: 'Sequence',
              value: metadata.cycleSequenceVersion,
            ),
            _ProvenanceRow(label: 'Age mode', value: metadata.ageModeVersion),
            _ProvenanceRow(
              label: 'Unknown time',
              value: metadata.unknownTimeVersion,
            ),
            _ProvenanceRow(label: 'Seun', value: metadata.seunVersion),
            _ProvenanceRow(
              label: 'Seun boundary',
              value: metadata.seunBoundaryVersion,
            ),
            _ProvenanceRow(label: 'Ten Gods', value: metadata.tenGodVersion),
            _ProvenanceRow(
              label: 'Base engine',
              value: '${metadata.baseEngineId} ${metadata.baseEngineVersion}',
            ),
            _ProvenanceRow(
              label: 'Base policy',
              value: '${metadata.basePolicyId} ${metadata.basePolicyVersion}',
            ),
            _ProvenanceRow(label: 'Timezone', value: metadata.baseTimezoneId),
            _ProvenanceRow(
              label: 'Birth profile',
              value: metadata.baseBirthPlaceProfile,
            ),
            _ProvenanceRow(
              label: 'Base day pillar',
              value: metadata.baseDayPillarId,
            ),
            _ProvenanceRow(
              label: 'Source snapshot',
              value: metadata.sourceSnapshotReference,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('닫기'),
      ),
    ],
  ),
);

class _ProvenanceRow extends StatelessWidget {
  const _ProvenanceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: SelectableText('$label · $value'),
  );
}
