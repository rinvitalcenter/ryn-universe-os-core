import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/ryn_tokens.dart';
import '../../people/domain/person_core_repositories.dart';
import '../application/saju_manse_controller.dart';
import '../domain/saju_calculation_engine.dart';
import '../domain/saju_models.dart';
import '../domain/saju_snapshot_repository.dart';
import '../domain/sexagenary_cycle.dart';
import '../domain/ten_gods.dart';
import 'saju_element_palette.dart';

class SajuMansePage extends StatefulWidget {
  const SajuMansePage({
    super.key,
    required this.peopleRepository,
    required this.snapshotRepository,
    this.calculationEngine,
  });

  final PersonRepository peopleRepository;
  final SajuSnapshotRepository snapshotRepository;
  final SajuCalculationEngine? calculationEngine;

  @override
  State<SajuMansePage> createState() => _SajuMansePageState();
}

class _SajuMansePageState extends State<SajuMansePage> {
  late final SajuManseController _controller;
  late final TextEditingController _yearController;
  late final TextEditingController _monthController;
  late final TextEditingController _dayController;
  late final TextEditingController _hourController;
  late final TextEditingController _minuteController;

  @override
  void initState() {
    super.initState();
    _controller = SajuManseController(
      peopleRepository: widget.peopleRepository,
      snapshotRepository: widget.snapshotRepository,
      calculationEngine:
          widget.calculationEngine ?? SajuCalculationEngine.production(),
    )..addListener(_onChanged);
    final draft = _controller.draft;
    _yearController = TextEditingController(
      text: draft.birthDate.year.toString(),
    );
    _monthController = TextEditingController(
      text: draft.birthDate.month.toString(),
    );
    _dayController = TextEditingController(
      text: draft.birthDate.day.toString(),
    );
    _hourController = TextEditingController(
      text: draft.birthTime.hour.toString().padLeft(2, '0'),
    );
    _minuteController = TextEditingController(
      text: draft.birthTime.minute.toString().padLeft(2, '0'),
    );
    _controller.start();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    unawaited(_controller.stop());
    _controller.dispose();
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _startNewChart() {
    _controller.startNewChart();
    final draft = _controller.draft;
    _yearController.text = draft.birthDate.year.toString();
    _monthController.text = draft.birthDate.month.toString();
    _dayController.text = draft.birthDate.day.toString();
    _hourController.text = draft.birthTime.hour.toString().padLeft(2, '0');
    _minuteController.text = draft.birthTime.minute.toString().padLeft(2, '0');
  }

  Future<void> _calculate() async {
    _controller.updateBirthDate(
      SajuLocalDate(
        int.tryParse(_yearController.text.trim()) ?? 0,
        int.tryParse(_monthController.text.trim()) ?? 0,
        int.tryParse(_dayController.text.trim()) ?? 0,
      ),
    );
    _controller.updateBirthTime(
      SajuLocalTime(
        int.tryParse(_hourController.text.trim()) ?? -1,
        int.tryParse(_minuteController.text.trim()) ?? -1,
      ),
    );
    await _controller.calculate();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return ColoredBox(
      color: colors.appCanvas,
      child: SingleChildScrollView(
        key: const Key('saju-workspace-scroll'),
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 44),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WorkspaceHeader(
                  controller: _controller,
                  onNewChart: _startNewChart,
                ),
                const SizedBox(height: 22),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 920;
                    final input = _BirthInputPanel(
                      controller: _controller,
                      yearController: _yearController,
                      monthController: _monthController,
                      dayController: _dayController,
                      hourController: _hourController,
                      minuteController: _minuteController,
                      onCalculate: _calculate,
                    );
                    final result = _ResultBoard(
                      controller: _controller,
                      onSave: _controller.save,
                    );
                    if (!wide) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [input, const SizedBox(height: 20), result],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 388, child: input),
                        const SizedBox(width: 22),
                        Expanded(child: result),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                _SavedHistory(controller: _controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({required this.controller, required this.onNewChart});

  final SajuManseController controller;
  final VoidCallback onNewChart;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final selected = controller.selectedPerson;
    final latest = controller.savedSnapshots.firstOrNull;
    return Wrap(
      spacing: 18,
      runSpacing: 14,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '사주 만세력',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                selected == null
                    ? '사람과 출생 정보를 연결해 정확한 명식을 계산하고 기록합니다.'
                    : '${selected.displayName} · ${_phaseLabel(controller.phase)} · '
                          '${latest == null ? '저장 이력 없음' : '최신 Revision ${latest.revisionNumber}'}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colors.secondaryText),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          key: const Key('saju-new-chart'),
          onPressed: controller.isBusy ? null : onNewChart,
          icon: const Icon(Icons.add_rounded),
          label: const Text('새 명식'),
        ),
      ],
    );
  }
}

class _BirthInputPanel extends StatelessWidget {
  const _BirthInputPanel({
    required this.controller,
    required this.yearController,
    required this.monthController,
    required this.dayController,
    required this.hourController,
    required this.minuteController,
    required this.onCalculate,
  });

  final SajuManseController controller;
  final TextEditingController yearController;
  final TextEditingController monthController;
  final TextEditingController dayController;
  final TextEditingController hourController;
  final TextEditingController minuteController;
  final Future<void> Function() onCalculate;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final draft = controller.draft;
    return Material(
      color: colors.primarySurface,
      elevation: 1,
      shadowColor: colors.scrim.withValues(alpha: 0.12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colors.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '출생 정보',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colors.primaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '기록할 사람과 달력 기준을 먼저 확인해 주세요.',
              style: TextStyle(color: colors.secondaryText),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              key: const Key('saju-person-selector'),
              initialValue: controller.selectedPerson?.id,
              decoration: const InputDecoration(
                labelText: 'Person',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              hint: const Text('사람 선택'),
              items: [
                for (final person in controller.activePeople)
                  DropdownMenuItem(
                    value: person.id,
                    child: Text(person.displayName),
                  ),
              ],
              onChanged: controller.isBusy
                  ? null
                  : (id) {
                      if (id != null) unawaited(controller.selectPerson(id));
                    },
            ),
            if (controller.selectedPerson?.relationshipSummary case final text?)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  text,
                  style: TextStyle(color: colors.mutedText, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),
            Text('달력', style: _fieldLabel(context)),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    key: const Key('saju-calendar-solar'),
                    label: const SizedBox(
                      width: double.infinity,
                      child: Text('양력', textAlign: TextAlign.center),
                    ),
                    selected: draft.calendarType == SajuCalendarType.solar,
                    onSelected: controller.isBusy
                        ? null
                        : (_) => controller.updateCalendarType(
                            SajuCalendarType.solar,
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    key: const Key('saju-calendar-lunar'),
                    label: const SizedBox(
                      width: double.infinity,
                      child: Text('음력', textAlign: TextAlign.center),
                    ),
                    selected:
                        draft.calendarType == SajuCalendarType.koreanLunar,
                    onSelected: controller.isBusy
                        ? null
                        : (_) => controller.updateCalendarType(
                            SajuCalendarType.koreanLunar,
                          ),
                  ),
                ),
              ],
            ),
            if (draft.calendarType == SajuCalendarType.koreanLunar) ...[
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                key: const Key('saju-lunar-leap'),
                contentPadding: EdgeInsets.zero,
                title: const Text('윤달'),
                subtitle: const Text('해당 음력 연월이 윤달일 때만 선택'),
                value: draft.lunarLeapMonth,
                onChanged: controller.isBusy
                    ? null
                    : controller.setLunarLeapMonth,
              ),
            ],
            const SizedBox(height: 18),
            Text('출생일', style: _fieldLabel(context)),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _NumberField(
                    fieldKey: const Key('saju-date-year'),
                    controller: yearController,
                    label: '년',
                    maxLength: 4,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NumberField(
                    fieldKey: const Key('saju-date-month'),
                    controller: monthController,
                    label: '월',
                    maxLength: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NumberField(
                    fieldKey: const Key('saju-date-day'),
                    controller: dayController,
                    label: '일',
                    maxLength: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              draft.calendarType == SajuCalendarType.solar
                  ? '지원 범위  ·  1990-01-01 ~ 2050-12-31'
                  : '음력 날짜는 지원 범위 안의 대응 양력으로 검증합니다.',
              style: TextStyle(color: colors.mutedText, fontSize: 12),
            ),
            const SizedBox(height: 18),
            Text('출생시간', style: _fieldLabel(context)),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    fieldKey: const Key('saju-time-hour'),
                    controller: hourController,
                    label: '시',
                    maxLength: 2,
                    enabled: !draft.hourUnknown,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    ':',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: _NumberField(
                    fieldKey: const Key('saju-time-minute'),
                    controller: minuteController,
                    label: '분',
                    maxLength: 2,
                    enabled: !draft.hourUnknown,
                  ),
                ),
              ],
            ),
            CheckboxListTile(
              key: const Key('saju-hour-unknown'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('시간 미상'),
              subtitle: const Text('시주 없이 년주·월주·일주를 계산합니다.'),
              value: draft.hourUnknown,
              onChanged: controller.isBusy
                  ? null
                  : (value) => controller.setHourUnknown(value ?? false),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<SajuGender>(
              initialValue: draft.gender,
              decoration: const InputDecoration(labelText: '성별'),
              items: const [
                DropdownMenuItem(
                  value: SajuGender.unspecified,
                  child: Text('선택 안 함'),
                ),
                DropdownMenuItem(value: SajuGender.female, child: Text('여성')),
                DropdownMenuItem(value: SajuGender.male, child: Text('남성')),
              ],
              onChanged: controller.isBusy
                  ? null
                  : (value) {
                      if (value != null) controller.updateGender(value);
                    },
            ),
            const SizedBox(height: 18),
            _PolicySummary(),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const Key('saju-calculate'),
              onPressed: controller.canCalculate ? onCalculate : null,
              icon: controller.phase == SajuMansePhase.calculating
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.calculate_outlined),
              label: Text(
                controller.phase == SajuMansePhase.calculating
                    ? '계산 중'
                    : '명식 계산',
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle? _fieldLabel(BuildContext context) => Theme.of(
    context,
  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800);
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.maxLength,
    this.enabled = true,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final int maxLength;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: fieldKey,
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ],
      textAlign: TextAlign.center,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _PolicySummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondarySurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.hairline),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('계산 환경', style: TextStyle(fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text('기준 지역: 서울'),
            Text('시간대: 한국 표준시'),
            Text('야자시: 적용 안 함'),
          ],
        ),
      ),
    );
  }
}

class _ResultBoard extends StatelessWidget {
  const _ResultBoard({required this.controller, required this.onSave});

  final SajuManseController controller;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final snapshot = controller.displayedSnapshot;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primarySurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '네 기둥과 여덟 글자',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.primaryText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        snapshot == null
                            ? '계산 결과가 이 화면의 중심에 표시됩니다.'
                            : controller.currentPersistedSnapshot == null
                            ? '저장 전 계산 결과'
                            : '저장 당시의 immutable snapshot',
                        style: TextStyle(color: colors.secondaryText),
                      ),
                    ],
                  ),
                ),
                if (controller.currentPersistedSnapshot != null)
                  _StatusPill(
                    label:
                        '저장됨 · R${controller.currentPersistedSnapshot!.revisionNumber}',
                    color: colors.success,
                  )
                else if (snapshot != null)
                  _StatusPill(label: '저장 전', color: colors.warning),
              ],
            ),
            const SizedBox(height: 18),
            if (snapshot == null)
              _ResultEmpty(hasPerson: controller.selectedPerson != null)
            else ...[
              _FourPillarStage(snapshot: snapshot),
              const SizedBox(height: 18),
              _ResultFacts(snapshot: snapshot),
              const SizedBox(height: 14),
              _Warnings(snapshot: snapshot),
              const SizedBox(height: 10),
              _PolicyDetails(snapshot: snapshot),
              if (controller.errorMessage case final message?) ...[
                const SizedBox(height: 14),
                _InlineMessage(message: message, error: true),
              ],
              if (controller.noticeMessage case final message?) ...[
                const SizedBox(height: 14),
                _InlineMessage(message: message),
              ],
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  key: const Key('saju-save'),
                  onPressed: controller.canSave ? onSave : null,
                  icon: controller.phase == SajuMansePhase.saving
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.bookmark_add_outlined),
                  label: Text(
                    controller.currentPersistedSnapshot != null
                        ? '저장됨'
                        : controller.phase == SajuMansePhase.saving
                        ? '저장 중'
                        : '명식 저장',
                  ),
                ),
              ),
            ],
            if (snapshot == null && controller.errorMessage != null) ...[
              const SizedBox(height: 14),
              _InlineMessage(message: controller.errorMessage!, error: true),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultEmpty extends StatelessWidget {
  const _ResultEmpty({required this.hasPerson});

  final bool hasPerson;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return Container(
      constraints: const BoxConstraints(minHeight: 430),
      decoration: BoxDecoration(
        color: colors.secondarySurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.hairline),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.forest_outlined, size: 38, color: colors.peopleIdentity),
          const SizedBox(height: 14),
          Text(
            hasPerson
                ? '출생 정보를 입력하면 네 기둥과 여덟 글자를 확인할 수 있습니다.'
                : '먼저 명식을 연결할 사람을 선택해 주세요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FourPillarStage extends StatelessWidget {
  const _FourPillarStage({required this.snapshot});

  final SajuChartSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final stageTop = dark ? const Color(0xFF13241F) : const Color(0xFF173E33);
    final stageBottom = dark
        ? const Color(0xFF0D1715)
        : const Color(0xFF0E2A23);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [stageTop, stageBottom],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x669E8B60)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      child: Column(
        children: [
          Text(
            snapshot.hourUnknown ? '세 기둥 · 여섯 글자' : '네 기둥 · 여덟 글자',
            style: const TextStyle(
              color: Color(0xFFD7C9A2),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PillarCard(
                  key: const Key('saju-pillar-hour'),
                  pillarId: 'hour',
                  label: '시주',
                  entry: snapshot.hourPillar,
                  dayStemIndex: snapshot.dayPillar.stemIndex,
                  unknown: snapshot.hourUnknown,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PillarCard(
                  key: const Key('saju-pillar-day'),
                  pillarId: 'day',
                  label: '일주',
                  entry: snapshot.dayPillar,
                  dayStemIndex: snapshot.dayPillar.stemIndex,
                  dayPillar: true,
                  emphasized: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PillarCard(
                  key: const Key('saju-pillar-month'),
                  pillarId: 'month',
                  label: '월주',
                  entry: snapshot.monthPillar,
                  dayStemIndex: snapshot.dayPillar.stemIndex,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PillarCard(
                  key: const Key('saju-pillar-year'),
                  pillarId: 'year',
                  label: '년주',
                  entry: snapshot.yearPillar,
                  dayStemIndex: snapshot.dayPillar.stemIndex,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillarCard extends StatelessWidget {
  const _PillarCard({
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
      constraints: const BoxConstraints(minHeight: 374),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: emphasized ? const Color(0x26E8DDBD) : const Color(0x12FFFFFF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: emphasized ? const Color(0xB3C7B27A) : const Color(0x3DFFFFFF),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD7C9A2),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (unknown)
            const SizedBox(
              height: 292,
              child: Center(
                child: Text(
                  '시간 미상',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFF4F0E7),
                    fontSize: 18,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else ...[
            _TenGodLabel(
              key: Key('saju-pillar-$pillarId-stem-relation'),
              label: dayPillar ? '일간(나)' : stemRelation!.label,
            ),
            const SizedBox(height: 7),
            _ElementHanjaTile(
              key: Key('saju-pillar-$pillarId-stem'),
              hanja: value!.hanja.substring(0, 1),
              element: SajuStemNature.elementForStem(value.stemIndex),
            ),
            const SizedBox(height: 7),
            _ElementHanjaTile(
              key: Key('saju-pillar-$pillarId-branch'),
              hanja: value.hanja.substring(1, 2),
              element: SajuStemNature.elementForStem(
                SajuBranchMainQiRegistry.stemForBranch(value.branchIndex).index,
              ),
            ),
            const SizedBox(height: 7),
            _TenGodLabel(
              key: Key('saju-pillar-$pillarId-branch-relation'),
              label: branchRelation!.label,
            ),
            const SizedBox(height: 9),
            Text(
              value.koreanLabel,
              style: const TextStyle(
                color: Color(0xFFCFD9D3),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TenGodLabel extends StatelessWidget {
  const _TenGodLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    textAlign: TextAlign.center,
    style: const TextStyle(
      color: Color(0xFFD7C9A2),
      fontSize: 12,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _ElementHanjaTile extends StatelessWidget {
  const _ElementHanjaTile({
    super.key,
    required this.hanja,
    required this.element,
  });

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
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 8),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              element.label,
              style: TextStyle(
                color: colors.foreground.withValues(alpha: 0.9),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            hanja,
            style: TextStyle(
              color: colors.foreground,
              fontFamily: 'ChosunGs',
              fontFamilyFallback: const ['Malgun Gothic'],
              fontSize: 44,
              height: 0.92,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultFacts extends StatelessWidget {
  const _ResultFacts({required this.snapshot});

  final SajuChartSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final lunar = snapshot.convertedLunarDate;
    final facts = <String>[
      '입력 ${snapshot.calendarType == SajuCalendarType.solar ? '양력' : '음력'} ${snapshot.originalInputDate}',
      '양력 ${snapshot.convertedSolarDate.iso8601}',
      '음력 ${lunar.year.toString().padLeft(4, '0')}-${lunar.month.toString().padLeft(2, '0')}-${lunar.day.toString().padLeft(2, '0')}${lunar.isLeapMonth ? ' · 윤달' : ''}',
      snapshot.hourUnknown
          ? '출생시간 · 미상'
          : '출생시간 · ${snapshot.inputLocalTime!.hour.toString().padLeft(2, '0')}:${snapshot.inputLocalTime!.minute.toString().padLeft(2, '0')}',
      '절입 경계 · 입춘·월절입 기준 적용',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final fact in facts)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: colors.secondarySurface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: colors.hairline),
            ),
            child: Text(
              fact,
              style: TextStyle(color: colors.secondaryText, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _Warnings extends StatelessWidget {
  const _Warnings({required this.snapshot});

  final SajuChartSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.warnings.isEmpty) return const SizedBox.shrink();
    final colors = context.rynColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.warning.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: colors.warning),
              const SizedBox(width: 7),
              const Text(
                '확인할 계산 기준',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 7),
          for (final warning in snapshot.warnings)
            Text(
              '• ${_warningLabel(warning)}',
              style: TextStyle(color: colors.secondaryText, height: 1.5),
            ),
        ],
      ),
    );
  }
}

class _PolicyDetails extends StatefulWidget {
  const _PolicyDetails({required this.snapshot});

  final SajuChartSnapshot snapshot;

  @override
  State<_PolicyDetails> createState() => _PolicyDetailsState();
}

class _PolicyDetailsState extends State<_PolicyDetails> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            key: const Key('saju-policy-details'),
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '계산 기준',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.expand_more_rounded),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.topCenter,
            child: !_expanded
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            const _PolicyTag('천을귀인 V5.20 호환 정책'),
                            const _PolicyTag('한국 표준시'),
                            const _PolicyTag('입춘 기준 연주'),
                            const _PolicyTag('월절입 기준 월주'),
                            const _PolicyTag('야자시 미적용'),
                            const _PolicyTag('서울 호환 시간 보정'),
                            const _PolicyTag('지원 범위 1990–2050'),
                            _PolicyTag(
                              'Engine ${widget.snapshot.engineVersion}',
                            ),
                            _PolicyTag(
                              'Policy ${widget.snapshot.policyVersion}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '이 정책은 천을귀인의 proprietary algorithm을 복제하지 않으며, 관찰된 결과와의 제품 호환 및 minute-level 절입 경계를 명시적으로 관리합니다.',
                          style: TextStyle(fontSize: 12, height: 1.5),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PolicyTag extends StatelessWidget {
  const _PolicyTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.secondarySurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.hairline),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _SavedHistory extends StatelessWidget {
  const _SavedHistory({required this.controller});

  final SajuManseController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final items = controller.savedSnapshots;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primarySurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '저장된 명식',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${items.length}개',
                  style: TextStyle(color: colors.mutedText),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (controller.selectedPerson == null)
              Text(
                '사람을 선택하면 저장 이력을 확인할 수 있습니다.',
                style: TextStyle(color: colors.secondaryText),
              )
            else if (items.isEmpty)
              Text(
                '아직 저장된 명식이 없습니다.',
                style: TextStyle(color: colors.secondaryText),
              )
            else
              for (var index = 0; index < items.length; index++) ...[
                _HistoryTile(
                  key: Key('saju-history-item-$index'),
                  persisted: items[index],
                  latest: index == 0,
                  selected:
                      controller.currentPersistedSnapshot?.id ==
                      items[index].id,
                  onTap: () => controller.selectSavedSnapshot(items[index].id),
                ),
                if (index != items.length - 1)
                  Divider(height: 1, color: colors.hairline),
              ],
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    super.key,
    required this.persisted,
    required this.latest,
    required this.selected,
    required this.onTap,
  });

  final SajuPersistedSnapshot persisted;
  final bool latest;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final snapshot = persisted.snapshot;
    final created = DateTime.fromMicrosecondsSinceEpoch(
      persisted.createdAtUtcUs,
      isUtc: true,
    ).toLocal();
    final pillars = [
      snapshot.hourPillar?.koreanLabel ?? '시간 미상',
      snapshot.dayPillar.koreanLabel,
      snapshot.monthPillar.koreanLabel,
      snapshot.yearPillar.koreanLabel,
    ].join(' · ');
    return Material(
      color: selected ? colors.selectedState : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.secondarySurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.hairline),
                ),
                child: Text(
                  'R${persisted.revisionNumber}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Revision ${persisted.revisionNumber}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        if (latest)
                          _StatusPill(label: '최신', color: colors.success),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${snapshot.originalInputDate} · ${snapshot.calendarType == SajuCalendarType.solar ? '양력' : '음력'} · ${snapshot.hourUnknown ? '시간 미상' : '시간 확인'}',
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      pillars,
                      style: TextStyle(color: colors.mutedText, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${created.year}.${created.month.toString().padLeft(2, '0')}.${created.day.toString().padLeft(2, '0')}',
                style: TextStyle(color: colors.mutedText, fontSize: 12),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message, this.error = false});

  final String message;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final color = error ? colors.destructive : colors.success;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

String _phaseLabel(SajuMansePhase phase) => switch (phase) {
  SajuMansePhase.empty => 'Person 선택 전',
  SajuMansePhase.input => '입력 중',
  SajuMansePhase.calculating => '계산 중',
  SajuMansePhase.resultUnsaved => '저장 전 결과',
  SajuMansePhase.saving => '저장 중',
  SajuMansePhase.resultSaved => '저장된 결과',
  SajuMansePhase.error => '확인 필요',
};

String _warningLabel(SajuWarningCode warning) => switch (warning) {
  SajuWarningCode.observedSeoulLongitudeCalibration => '서울 호환 시간 보정을 적용했습니다.',
  SajuWarningCode.minuteLevelSolarTermCompatibility =>
    '절입 경계는 분 단위 호환 정책으로 계산했습니다.',
  SajuWarningCode.dayRolloverPolicyPendingCapture =>
    '23:00~다음 날 00:29는 현재 지원하지 않습니다.',
  SajuWarningCode.hourUnknown => '출생시간 미상으로 시주를 계산하지 않았습니다.',
};

class SajuUnavailablePage extends StatelessWidget {
  const SajuUnavailablePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.grid_view_rounded,
                size: 40,
                color: colors.primaryAction,
              ),
              const SizedBox(height: 16),
              Text(
                '사주 기록을 열 수 없습니다.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                '앱을 다시 시작한 뒤 Person 기록 연결 상태를 확인해 주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.secondaryText, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
