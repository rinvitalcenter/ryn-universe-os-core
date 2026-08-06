import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/ryn_tokens.dart';
import '../application/saju_daeun_seun_controller.dart';
import '../domain/daeun_seun_models.dart';
import 'saju_element_palette.dart';

class SajuSeunPanel extends StatelessWidget {
  const SajuSeunPanel({
    super.key,
    required this.controller,
    this.showHeader = true,
    this.showDetail = true,
  });

  final SajuDaeunSeunController controller;
  final bool showHeader;
  final bool showDetail;

  @override
  Widget build(BuildContext context) {
    if (!controller.hasSource) {
      return const _StatusPanel(
        title: '세운 자료가 아직 없습니다.',
        body: '대운과 세운을 확인하려면 먼저 원국을 계산하거나 저장된 명식을 선택해 주세요.',
      );
    }
    if (controller.seunPhase == SajuDerivedPhase.calculating) {
      return const _StatusPanel(
        title: '세운 연도 라벨을 준비하고 있습니다.',
        body: '선택 대운을 기준으로 10개 연도를 구성합니다.',
        loading: true,
      );
    }
    if (controller.seunPhase == SajuDerivedPhase.error) {
      return _StatusPanel(
        title: controller.seunError ?? '세운 연도 라벨을 표시할 수 없습니다.',
        body: '원국과 대운은 그대로 유지됩니다. 입력과 계산 범위를 확인해 주세요.',
      );
    }
    if (controller.seunEntries.isEmpty) {
      return const _StatusPanel(
        title: '세운 결과가 준비되지 않았습니다.',
        body: '원국을 다시 계산하거나 대운을 선택해 주세요.',
      );
    }

    final selectedDaeun = controller.selectedDaeunCycle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeader) ...[
          Text(
            '세운 연도 라벨',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
        ],
        if (selectedDaeun != null) ...[
          _DaeunContext(cycle: selectedDaeun),
          const SizedBox(height: 6),
        ],
        _SeunBand(controller: controller),
        const SizedBox(height: 6),
        Text(
          key: const Key('saju-seun-disclaimer'),
          controller.seunWarning ?? '세운은 연도별 간지 라벨이며 특정 날짜의 활성 세운을 판정하지 않습니다.',
          style: TextStyle(
            color: context.rynColors.mutedText,
            fontSize: 11,
            height: 1.2,
          ),
        ),
        if (showDetail) ...[
          const SizedBox(height: 12),
          SajuSeunDetailPanel(controller: controller),
        ],
      ],
    );
  }
}

class _DaeunContext extends StatelessWidget {
  const _DaeunContext({required this.cycle});

  final DaeunCycle cycle;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return Row(
      children: [
        Container(
          width: 3,
          height: 24,
          color: SajuElementPalette.selection(
            Theme.of(context).brightness,
          ).border,
        ),
        const SizedBox(width: 9),
        Text(
          '${cycle.sequence}번째 대운 · ${cycle.pillar.hanja}',
          style: TextStyle(
            color: colors.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${cycle.startTraditionalAge}세 · ${cycle.startYear}–${cycle.endYearExclusive - 1}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.secondaryText, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _SeunBand extends StatefulWidget {
  const _SeunBand({required this.controller});

  final SajuDaeunSeunController controller;

  @override
  State<_SeunBand> createState() => _SeunBandState();
}

class _SeunBandState extends State<_SeunBand> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'Saju Seun band');
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final entries = widget.controller.seunEntries;
    final currentIndex = entries.indexWhere(
      (entry) => entry.gregorianYear == widget.controller.selectedSeunYear,
    );
    final normalizedIndex = currentIndex < 0 ? 0 : currentIndex;
    final key = event.logicalKey;
    final targetIndex = switch (key) {
      LogicalKeyboardKey.arrowLeft => normalizedIndex - 1,
      LogicalKeyboardKey.arrowRight => normalizedIndex + 1,
      LogicalKeyboardKey.home => 0,
      LogicalKeyboardKey.end => entries.length - 1,
      _ => normalizedIndex,
    };
    if (key != LogicalKeyboardKey.arrowLeft &&
        key != LogicalKeyboardKey.arrowRight &&
        key != LogicalKeyboardKey.home &&
        key != LogicalKeyboardKey.end) {
      return KeyEventResult.ignored;
    }
    final bounded = targetIndex.clamp(0, entries.length - 1);
    if (bounded != normalizedIndex) {
      widget.controller.selectSeunYear(entries[bounded].gregorianYear);
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(bounded));
    }
    return KeyEventResult.handled;
  }

  void _reveal(int index) {
    if (!_scrollController.hasClients) return;
    final target = (index * 108.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.controller.seunEntries;
    final colors = context.rynColors;
    return Focus(
      key: const Key('saju-seun-keyboard'),
      focusNode: _focusNode,
      onKeyEvent: _onKeyEvent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 6.0;
          final fitAll = constraints.maxWidth >= 900;
          final itemWidth = fitAll
              ? (constraints.maxWidth - gap * 9) / 10
              : 102.0;
          final row = Row(
            children: [
              for (var index = 0; index < entries.length; index++) ...[
                if (index > 0) const SizedBox(width: gap),
                _SeunNode(
                  width: itemWidth,
                  entry: entries[index],
                  selected:
                      widget.controller.selectedSeunYear ==
                      entries[index].gregorianYear,
                  onTap: () {
                    _focusNode.requestFocus();
                    widget.controller.selectSeunYear(
                      entries[index].gregorianYear,
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
                key: const Key('saju-seun-year-scroll'),
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

class _SeunNode extends StatelessWidget {
  const _SeunNode({
    required this.width,
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final SeunAnnualEntry entry;
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
      height: 85,
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
          key: Key('saju-seun-year-${entry.gregorianYear}'),
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(7, 5, 7, 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${entry.gregorianYear}',
                  style: TextStyle(
                    color: selected
                        ? selection.foreground
                        : colors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.pillar.hanja,
                  style: TextStyle(
                    fontFamily: 'ChosunGs',
                    color: selected ? selection.foreground : colors.primaryText,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.heavenlyStemTenGod.label} · ${entry.earthlyBranchMainQiTenGod.label}',
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

class SajuSeunDetailPanel extends StatelessWidget {
  const SajuSeunDetailPanel({super.key, required this.controller});

  final SajuDaeunSeunController controller;

  @override
  Widget build(BuildContext context) {
    final entry = controller.selectedSeunEntry;
    if (entry == null) return const SizedBox.shrink();
    final colors = context.rynColors;
    return Container(
      key: const Key('saju-seun-detail'),
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
            '${entry.gregorianYear}년',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                entry.pillar.hanja,
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
                child: Text(
                  '${entry.heavenlyStemTenGod.label} / ${entry.earthlyBranchMainQiTenGod.label}',
                  style: TextStyle(color: colors.secondaryText),
                ),
              ),
            ],
          ),
        ],
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
