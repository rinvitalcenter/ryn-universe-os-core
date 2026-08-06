import 'package:flutter/material.dart';

import '../../../core/theme/ryn_tokens.dart';
import '../domain/saju_snapshot.dart';
import '../domain/sexagenary_cycle.dart';
import '../domain/ten_gods.dart';
import 'saju_element_palette.dart';

class SajuIntegratedNatalGrid extends StatelessWidget {
  const SajuIntegratedNatalGrid({
    super.key,
    required this.snapshot,
    this.status,
  });

  final SajuChartSnapshot snapshot;
  final Widget? status;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return Container(
      key: const Key('saju-pillar-grid'),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: colors.secondarySurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '01',
                style: TextStyle(
                  color: colors.mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '네 기둥과 여덟 글자',
                style: TextStyle(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (status != null) ...[
                status!,
                const SizedBox(width: 10),
              ],
              Text(
                '시주  |  일주  |  월주  |  년주',
                style: TextStyle(color: colors.mutedText, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _PillarColumn(
                    key: const Key('saju-pillar-hour'),
                    pillarId: 'hour',
                    label: '시주',
                    entry: snapshot.hourPillar,
                    dayStemIndex: snapshot.dayPillar.stemIndex,
                    unknown: snapshot.hourUnknown,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _PillarColumn(
                    key: const Key('saju-pillar-day'),
                    pillarId: 'day',
                    label: '일주',
                    entry: snapshot.dayPillar,
                    dayStemIndex: snapshot.dayPillar.stemIndex,
                    dayPillar: true,
                    emphasized: true,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _PillarColumn(
                    key: const Key('saju-pillar-month'),
                    pillarId: 'month',
                    label: '월주',
                    entry: snapshot.monthPillar,
                    dayStemIndex: snapshot.dayPillar.stemIndex,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _PillarColumn(
                    key: const Key('saju-pillar-year'),
                    pillarId: 'year',
                    label: '년주',
                    entry: snapshot.yearPillar,
                    dayStemIndex: snapshot.dayPillar.stemIndex,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillarColumn extends StatelessWidget {
  const _PillarColumn({
    super.key,
    required this.pillarId,
    required this.label,
    required this.entry,
    required this.dayStemIndex,
    this.unknown = false,
    this.dayPillar = false,
    this.emphasized = false,
  });

  final String pillarId;
  final String label;
  final SexagenaryEntry? entry;
  final int dayStemIndex;
  final bool unknown;
  final bool dayPillar;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final appColors = context.rynColors;
    final selection = SajuElementPalette.selection(
      Theme.of(context).brightness,
    );
    final value = entry;
    final stemRelation = value == null
        ? null
        : SajuTenGodCalculator.calculate(
            dayStemIndex: dayStemIndex,
            targetStemIndex: value.stemIndex,
          );
    final branchRelation = value == null
        ? null
        : SajuTenGodCalculator.forBranchMainQi(
            dayStemIndex: dayStemIndex,
            branchIndex: value.branchIndex,
          );
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: emphasized ? selection.background : appColors.primarySurface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: emphasized ? selection.border : appColors.hairline,
          width: emphasized ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          _GridRow(
            height: 24,
            child: Text(
              label,
              style: TextStyle(
                color: emphasized
                    ? selection.foreground
                    : appColors.primaryText,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (unknown)
            SizedBox(
              key: const Key('saju-unknown-hour-pillars'),
              height: 166,
              child: Center(
                child: Text(
                  '시간 미상',
                  style: TextStyle(color: appColors.secondaryText),
                ),
              ),
            )
          else ...[
            _GridRow(
              height: 22,
              child: KeyedSubtree(
                key: Key('saju-pillar-$pillarId-stem-relation'),
                child: Text(
                  dayPillar ? '일간·나' : stemRelation!.label,
                  style: TextStyle(
                    color: appColors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            _GridRow(
              height: 48,
              child: _ElementGlyph(
                key: Key('saju-pillar-$pillarId-stem'),
                hanja: value!.hanja.substring(0, 1),
                element: SajuStemNature.elementForStem(value.stemIndex),
              ),
            ),
            _GridRow(
              height: 48,
              child: _ElementGlyph(
                key: Key('saju-pillar-$pillarId-branch'),
                hanja: value.hanja.substring(1, 2),
                element: SajuStemNature.elementForStem(
                  SajuBranchMainQiRegistry.stemForBranch(
                    value.branchIndex,
                  ).index,
                ),
              ),
            ),
            _GridRow(
              height: 22,
              child: KeyedSubtree(
                key: Key('saju-pillar-$pillarId-branch-relation'),
                child: Text(
                  branchRelation!.label,
                  style: TextStyle(
                    color: appColors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            _GridRow(
              height: 26,
              last: true,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 5,
                runSpacing: 3,
                children: [
                  _ElementMarker(
                    label: '천간',
                    element: SajuStemNature.elementForStem(value.stemIndex),
                  ),
                  _ElementMarker(
                    label: '지지',
                    element: SajuStemNature.elementForStem(
                      SajuBranchMainQiRegistry.stemForBranch(
                        value.branchIndex,
                      ).index,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GridRow extends StatelessWidget {
  const _GridRow({
    required this.height,
    required this.child,
    this.last = false,
  });

  final double height;
  final Widget child;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 5),
    decoration: BoxDecoration(
      border: last
          ? null
          : Border(bottom: BorderSide(color: context.rynColors.hairline)),
    ),
    child: child,
  );
}

class _ElementGlyph extends StatelessWidget {
  const _ElementGlyph({super.key, required this.hanja, required this.element});

  final String hanja;
  final SajuFiveElement element;

  @override
  Widget build(BuildContext context) {
    final colors = SajuElementPalette.resolve(
      element,
      Theme.of(context).brightness,
    );
    return Container(
      width: double.infinity,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(left: BorderSide(color: colors.border, width: 3)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            hanja,
            style: TextStyle(
              color: colors.foreground,
              fontFamily: 'ChosunGs',
              fontFamilyFallback: const ['Malgun Gothic'],
              fontSize: 36,
              height: 1,
              fontWeight: FontWeight.w400,
            ),
          ),
          Positioned(
            right: 5,
            top: 5,
            child: Text(
              element.label,
              style: TextStyle(
                color: colors.foreground,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ElementMarker extends StatelessWidget {
  const _ElementMarker({required this.label, required this.element});

  final String label;
  final SajuFiveElement element;

  @override
  Widget build(BuildContext context) {
    final colors = SajuElementPalette.resolve(
      element,
      Theme.of(context).brightness,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: colors.border,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '$label ${element.label}',
          style: TextStyle(color: colors.foreground, fontSize: 9),
        ),
      ],
    );
  }
}
