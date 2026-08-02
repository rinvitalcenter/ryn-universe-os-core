import 'package:flutter/material.dart';

import '../../../core/theme/ryn_tokens.dart';
import '../application/saju_daeun_seun_controller.dart';
import '../domain/daeun_seun_models.dart';
import '../domain/ten_gods.dart';
import 'saju_element_palette.dart';

class SajuDaeunTimeline extends StatelessWidget {
  const SajuDaeunTimeline({super.key, required this.controller});

  final SajuDaeunSeunController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.hasSource) return const _NoSourceState();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SourceBanner(controller: controller),
        const SizedBox(height: 16),
        if (controller.daeunPhase == SajuDerivedPhase.calculating)
          const _StatusPanel(
            icon: Icons.hourglass_top_rounded,
            title: '대운을 계산하고 있습니다.',
            body: '저장된 값은 바꾸지 않고 현재 원국에서 결과를 구성합니다.',
            showProgress: true,
          )
        else if (controller.daeunPhase == SajuDerivedPhase.error)
          _StatusPanel(
            icon: Icons.info_outline_rounded,
            title: controller.daeunError ?? '대운 결과를 표시할 수 없습니다.',
            body: controller.seunPhase == SajuDerivedPhase.ready
                ? '원국은 그대로 유지됩니다. 세운 탭에서는 연도별 간지 라벨을 확인할 수 있습니다.'
                : '원국 탭에서 출생정보와 계산 기준을 확인해 주세요.',
          )
        else if (controller.daeunResult case final result?)
          _DaeunResultStage(controller: controller, result: result)
        else
          const _StatusPanel(
            icon: Icons.auto_awesome_outlined,
            title: '대운 결과를 준비하고 있습니다.',
            body: '잠시 후 다시 확인해 주세요.',
          ),
      ],
    );
  }
}

class _DaeunResultStage extends StatelessWidget {
  const _DaeunResultStage({required this.controller, required this.result});

  final SajuDaeunSeunController controller;
  final DaeunCalculationResult result;

  @override
  Widget build(BuildContext context) {
    final direction = result.direction == DaeunDirection.forward ? '순행' : '역행';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '대운수 ${result.daeunNumber} · $direction',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            _SoftChip(
              label:
                  '첫 시작 ${result.firstStartTraditionalAge}세 · ${result.firstStartYear}년',
            ),
            const _SoftChip(label: '전통나이 기준'),
          ],
        ),
        if (controller.daeunWarning case final warning?) ...[
          const SizedBox(height: 14),
          _NoticeStrip(icon: Icons.schedule_rounded, text: warning),
        ],
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final detail = _SelectedDaeunDetail(controller: controller);
            final timeline = _Timeline(controller: controller, result: result);
            if (constraints.maxWidth >= 1080) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: timeline),
                  const SizedBox(width: 20),
                  SizedBox(width: 330, child: detail),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [timeline, const SizedBox(height: 18), detail],
            );
          },
        ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            key: const Key('saju-daeun-provenance'),
            onPressed: () => _showProvenance(context, controller),
            icon: const Icon(Icons.verified_outlined, size: 18),
            label: const Text('계산 기준과 출처'),
          ),
        ),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.controller, required this.result});

  final SajuDaeunSeunController controller;
  final DaeunCalculationResult result;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.rynColors.primarySurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.rynColors.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '11개의 시간 흐름',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '옆으로 이동하며 대운을 선택해 보세요.',
              style: TextStyle(color: context.rynColors.secondaryText),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              key: const Key('saju-daeun-timeline-scroll'),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final cycle in result.cycles) ...[
                    _DaeunNode(
                      cycle: cycle,
                      selected:
                          controller.selectedDaeunSequence == cycle.sequence,
                      onTap: () => controller.selectDaeunCycle(cycle.sequence),
                    ),
                    if (cycle.sequence != result.cycles.last.sequence)
                      Container(
                        width: 30,
                        height: 2,
                        color: context.rynColors.hairline,
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaeunNode extends StatelessWidget {
  const _DaeunNode({
    required this.cycle,
    required this.selected,
    required this.onTap,
  });

  final DaeunCycle cycle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: '${cycle.sequence}번째 대운 ${cycle.pillar.koreanLabel}',
      child: InkWell(
        key: Key('saju-daeun-cycle-${cycle.sequence}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: selected ? 164 : 148,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : colors.secondarySurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? scheme.primary : colors.hairline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${cycle.startTraditionalAge}세 · ${cycle.startYear}년',
                style: TextStyle(
                  color: selected
                      ? scheme.onPrimaryContainer
                      : colors.secondaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                cycle.pillar.hanja,
                style: TextStyle(
                  fontFamily: 'ChosunGs',
                  fontFamilyFallback: const [
                    'Malgun Gothic',
                    'Segoe UI Symbol',
                  ],
                  fontSize: selected ? 32 : 28,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                '${cycle.heavenlyStemTenGod.label} · ${cycle.earthlyBranchMainQiTenGod.label}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedDaeunDetail extends StatelessWidget {
  const _SelectedDaeunDetail({required this.controller});

  final SajuDaeunSeunController controller;

  @override
  Widget build(BuildContext context) {
    final cycle = controller.selectedDaeunCycle;
    if (cycle == null) return const SizedBox.shrink();
    return Container(
      key: const Key('saju-daeun-detail'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.rynColors.raisedUtilityMaterial,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.rynColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${cycle.sequence}번째 대운',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: context.rynColors.secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            cycle.pillar.hanja,
            style: const TextStyle(
              fontFamily: 'ChosunGs',
              fontFamilyFallback: ['Malgun Gothic', 'Segoe UI Symbol'],
              fontSize: 48,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${cycle.pillar.koreanLabel} · ${cycle.startTraditionalAge}세 · ${cycle.startYear}년',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 18),
          _RelationRow(
            label: '천간',
            tenGod: cycle.heavenlyStemTenGod,
            element: cycle.stemFiveElement,
          ),
          const SizedBox(height: 10),
          _RelationRow(
            label: '지지 본기',
            tenGod: cycle.earthlyBranchMainQiTenGod,
            element: cycle.branchFiveElement,
          ),
          const SizedBox(height: 16),
          Text(
            controller.sourceProvenance?.sourceLabel ?? '',
            style: TextStyle(color: context.rynColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _RelationRow extends StatelessWidget {
  const _RelationRow({
    required this.label,
    required this.tenGod,
    required this.element,
  });

  final String label;
  final SajuTenGod tenGod;
  final SajuFiveElement element;

  @override
  Widget build(BuildContext context) {
    final elementColors = SajuElementPalette.resolve(
      element,
      Theme.of(context).brightness,
    );
    return Row(
      children: [
        SizedBox(
          width: 68,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Text(
            tenGod.label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: elementColors.background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: elementColors.border),
          ),
          child: Text(
            element.label,
            style: TextStyle(
              color: elementColors.foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SourceBanner extends StatelessWidget {
  const _SourceBanner({required this.controller});

  final SajuDaeunSeunController controller;

  @override
  Widget build(BuildContext context) {
    final provenance = controller.sourceProvenance;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: context.rynColors.secondarySurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.rynColors.hairline),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 18),
          const Text(
            '천을귀인 V5.20 호환 · 전통나이',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          _SoftChip(label: provenance?.sourceLabel ?? ''),
          if (provenance != null)
            Text(
              '원국 계산 ${provenance.sourceCalculatedAt.toLocal().toIso8601String().split('T').first}',
              style: TextStyle(color: context.rynColors.secondaryText),
            ),
        ],
      ),
    );
  }
}

class _SoftChip extends StatelessWidget {
  const _SoftChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: context.rynColors.secondarySurface,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: context.rynColors.hairline),
    ),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}

class _NoticeStrip extends StatelessWidget {
  const _NoticeStrip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.secondaryContainer.withValues(alpha: .6),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.icon,
    required this.title,
    required this.body,
    this.showProgress = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool showProgress;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: context.rynColors.primarySurface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: context.rynColors.hairline),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showProgress)
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          )
        else
          Icon(icon, size: 24),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: TextStyle(color: context.rynColors.secondaryText),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _NoSourceState extends StatelessWidget {
  const _NoSourceState();

  @override
  Widget build(BuildContext context) => const _StatusPanel(
    icon: Icons.account_tree_outlined,
    title: '원국이 필요합니다.',
    body: '대운과 세운을 확인하려면 먼저 원국을 계산하거나 저장된 명식을 선택해 주세요.',
  );
}

Future<void> _showProvenance(
  BuildContext context,
  SajuDaeunSeunController controller,
) async {
  final source = controller.sourceProvenance;
  final metadata =
      controller.daeunResult?.metadata ??
      controller.seunEntries.firstOrNull?.metadata;
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('계산 기준과 출처'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetadataLine('원국 상태', source?.sourceLabel ?? '확인 불가'),
              _MetadataLine(
                '원국 엔진',
                '${source?.sourceEngineId} ${source?.sourceEngineVersion}',
              ),
              _MetadataLine(
                '원국 정책',
                '${source?.sourcePolicyId} ${source?.sourcePolicyVersion}',
              ),
              _MetadataLine('시간대', source?.timezoneId ?? ''),
              _MetadataLine('지역 기준', source?.birthPlaceProfile ?? ''),
              _MetadataLine('야자시', source?.yajaEnabled == true ? 'ON' : 'OFF'),
              const Divider(height: 28),
              _MetadataLine(
                '대운·세운 엔진',
                '${metadata?.engineId} ${metadata?.engineVersion}',
              ),
              _MetadataLine(
                '정책',
                '${metadata?.policyId} ${metadata?.policyVersion}',
              ),
              _MetadataLine('검증 fixture', metadata?.fixtureSet ?? ''),
              _MetadataLine('방향 규칙', metadata?.directionRuleVersion ?? ''),
              _MetadataLine('월절입 선택', metadata?.termSelectionVersion ?? ''),
              _MetadataLine('대운수', metadata?.daeunNumberVersion ?? ''),
              _MetadataLine('시간 미상', metadata?.unknownTimeVersion ?? ''),
              _MetadataLine('세운', metadata?.seunVersion ?? ''),
              _MetadataLine('세운 경계', metadata?.seunBoundaryVersion ?? ''),
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
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 116,
          child: Text(
            label,
            style: TextStyle(color: context.rynColors.secondaryText),
          ),
        ),
        Expanded(child: SelectableText(value)),
      ],
    ),
  );
}
