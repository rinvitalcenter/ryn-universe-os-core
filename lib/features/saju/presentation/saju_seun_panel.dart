import 'package:flutter/material.dart';

import '../../../core/theme/ryn_tokens.dart';
import '../application/saju_daeun_seun_controller.dart';
import '../domain/daeun_seun_models.dart';
import '../domain/ten_gods.dart';
import 'saju_element_palette.dart';

class SajuSeunPanel extends StatelessWidget {
  const SajuSeunPanel({super.key, required this.controller});

  final SajuDaeunSeunController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.hasSource) return const _NoSourceState();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SeunHeader(controller: controller),
        const SizedBox(height: 16),
        if (controller.daeunPhase == SajuDerivedPhase.error &&
            controller.seunPhase == SajuDerivedPhase.ready) ...[
          _NoticeStrip(
            icon: Icons.call_split_rounded,
            text:
                '${controller.daeunError} 대운과 별개로 계산 가능한 연도별 세운 라벨은 아래에 표시합니다.',
          ),
          const SizedBox(height: 14),
        ],
        if (controller.seunPhase == SajuDerivedPhase.calculating)
          const _StatusPanel(
            title: '세운 연도 라벨을 준비하고 있습니다.',
            body: '선택한 원국의 일간을 기준으로 연도별 간지와 십성을 구성합니다.',
            progress: true,
          )
        else if (controller.seunPhase == SajuDerivedPhase.error)
          _StatusPanel(
            title: controller.seunError ?? '세운 연도 라벨을 표시할 수 없습니다.',
            body: '지원 범위는 1990년부터 2159년까지입니다.',
          )
        else if (controller.seunEntries.isNotEmpty)
          _SeunResult(controller: controller)
        else
          const _StatusPanel(
            title: '세운 연도를 준비하고 있습니다.',
            body: '원국 source를 확인해 주세요.',
          ),
      ],
    );
  }
}

class _SeunHeader extends StatelessWidget {
  const _SeunHeader({required this.controller});

  final SajuDaeunSeunController controller;

  @override
  Widget build(BuildContext context) {
    final cycle = controller.selectedDaeunCycle;
    final provenance = controller.sourceProvenance;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.rynColors.secondarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.rynColors.hairline),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            '세운 · 연도별 간지',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          _Chip(label: provenance?.sourceLabel ?? ''),
          if (cycle != null)
            _Chip(
              label:
                  '${cycle.sequence}번째 대운 · ${cycle.startYear}–${cycle.endYearExclusive - 1}',
            )
          else
            const _Chip(label: '대운 context 없음'),
          const _Chip(label: '천을귀인 V5.20 호환'),
        ],
      ),
    );
  }
}

class _SeunResult extends StatelessWidget {
  const _SeunResult({required this.controller});

  final SajuDaeunSeunController controller;

  @override
  Widget build(BuildContext context) {
    final first = controller.seunEntries.first.gregorianYear;
    final last = controller.seunEntries.last.gregorianYear;
    final currentYear = controller.currentGregorianYear;
    final currentInWindow = controller.seunEntries.any(
      (entry) => entry.gregorianYear == currentYear,
    );
    final strip = _AnnualStrip(controller: controller);
    final detail = _SelectedSeunDetail(controller: controller);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 10,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$first–$last · 10년',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '대운은 비교 context이며 세운 간지를 바꾸지 않습니다.',
                  style: TextStyle(color: context.rynColors.secondaryText),
                ),
              ],
            ),
            OutlinedButton.icon(
              key: const Key('saju-seun-current-year'),
              onPressed: currentInWindow
                  ? () => controller.selectSeunYear(currentYear)
                  : null,
              icon: const Icon(Icons.my_location_rounded, size: 18),
              label: const Text('올해 위치'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 1060) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: strip),
                  const SizedBox(width: 20),
                  SizedBox(width: 330, child: detail),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [strip, const SizedBox(height: 18), detail],
            );
          },
        ),
        const SizedBox(height: 18),
        Container(
          key: const Key('saju-seun-disclaimer'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: .58),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '세운은 연도별 간지 라벨로 제공합니다. 적용 시작일과 종료일은 천을귀인 V5.20 화면에서 확인되지 않아 현재 버전에서는 특정 날짜의 활성 세운을 판정하지 않습니다.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnnualStrip extends StatelessWidget {
  const _AnnualStrip({required this.controller});

  final SajuDaeunSeunController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
    decoration: BoxDecoration(
      color: context.rynColors.primarySurface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: context.rynColors.hairline),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '10년의 연도 라벨',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          key: const Key('saju-seun-strip-scroll'),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final entry in controller.seunEntries) ...[
                _YearNode(
                  entry: entry,
                  selected: controller.selectedSeunYear == entry.gregorianYear,
                  onTap: () => controller.selectSeunYear(entry.gregorianYear),
                ),
                if (entry != controller.seunEntries.last)
                  const SizedBox(width: 10),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _YearNode extends StatelessWidget {
  const _YearNode({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final SeunAnnualEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: '${entry.gregorianYear}년 ${entry.pillar.koreanLabel}',
      child: InkWell(
        key: Key('saju-seun-year-${entry.gregorianYear}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: selected ? 132 : 120,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primaryContainer
                : context.rynColors.secondarySurface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? scheme.primary : context.rynColors.hairline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${entry.gregorianYear}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 9),
              Text(
                entry.pillar.hanja,
                style: const TextStyle(
                  fontFamily: 'ChosunGs',
                  fontFamilyFallback: ['Malgun Gothic', 'Segoe UI Symbol'],
                  fontSize: 28,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${entry.heavenlyStemTenGod.label} · ${entry.earthlyBranchMainQiTenGod.label}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedSeunDetail extends StatelessWidget {
  const _SelectedSeunDetail({required this.controller});

  final SajuDaeunSeunController controller;

  @override
  Widget build(BuildContext context) {
    final entry = controller.selectedSeunEntry;
    return Container(
      key: const Key('saju-seun-detail'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.rynColors.raisedUtilityMaterial,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.rynColors.hairline),
      ),
      child: entry == null
          ? const Text('연도를 선택해 주세요.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.gregorianYear}년',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  entry.pillar.hanja,
                  style: const TextStyle(
                    fontFamily: 'ChosunGs',
                    fontFamilyFallback: ['Malgun Gothic', 'Segoe UI Symbol'],
                    fontSize: 48,
                    height: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(entry.pillar.koreanLabel),
                const SizedBox(height: 18),
                _RelationRow(
                  label: '천간',
                  tenGod: entry.heavenlyStemTenGod,
                  element: entry.stemFiveElement,
                ),
                const SizedBox(height: 10),
                _RelationRow(
                  label: '지지 본기',
                  tenGod: entry.earthlyBranchMainQiTenGod,
                  element: entry.branchFiveElement,
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
    final palette = SajuElementPalette.resolve(
      element,
      Theme.of(context).brightness,
    );
    return Row(
      children: [
        SizedBox(width: 68, child: Text(label)),
        Expanded(
          child: Text(
            tenGod.label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: palette.background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: palette.border),
          ),
          child: Text(
            element.label,
            style: TextStyle(
              color: palette.foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: context.rynColors.primarySurface,
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
    required this.title,
    required this.body,
    this.progress = false,
  });

  final String title;
  final String body;
  final bool progress;

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
        if (progress)
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          )
        else
          const Icon(Icons.info_outline_rounded, size: 22),
        const SizedBox(width: 13),
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
    title: '원국이 필요합니다.',
    body: '대운과 세운을 확인하려면 먼저 원국을 계산하거나 저장된 명식을 선택해 주세요.',
  );
}
