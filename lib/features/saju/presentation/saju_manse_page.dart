import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/ryn_tokens.dart';
import '../../people/domain/person_core_repositories.dart';
import '../application/saju_daeun_seun_controller.dart';
import '../application/saju_manse_controller.dart';
import '../domain/saju_calculation_engine.dart';
import '../domain/saju_models.dart';
import '../domain/saju_snapshot_repository.dart';
import 'saju_daeun_timeline.dart';
import 'saju_integrated_workbench.dart';
import 'saju_seun_panel.dart';

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
  late final SajuDaeunSeunController _daeunSeunController;
  late final TextEditingController _yearController;
  late final TextEditingController _monthController;
  late final TextEditingController _dayController;
  late final TextEditingController _hourController;
  late final TextEditingController _minuteController;
  SajuChartSnapshot? _lastCalculatedSnapshot;
  int _natalCalculationGeneration = 0;

  @override
  void initState() {
    super.initState();
    _controller = SajuManseController(
      peopleRepository: widget.peopleRepository,
      snapshotRepository: widget.snapshotRepository,
      calculationEngine:
          widget.calculationEngine ?? SajuCalculationEngine.production(),
    )..addListener(_onNatalChanged);
    _daeunSeunController = SajuDaeunSeunController()
      ..addListener(_onDerivedChanged);
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

  void _onNatalChanged() {
    unawaited(_syncDerivedSource());
    if (mounted) setState(() {});
  }

  void _onDerivedChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _syncDerivedSource() async {
    final persisted = _controller.currentPersistedSnapshot;
    if (persisted != null) {
      final canPromote =
          _daeunSeunController.sourceType ==
              SajuDaeunSeunSourceType.unsavedNatalResult &&
          _daeunSeunController.sourceSnapshot?.deterministicSignature ==
              persisted.snapshot.deterministicSignature;
      if (canPromote) {
        await _daeunSeunController.promoteToPersistedSource(persisted);
      } else {
        await _daeunSeunController.loadPersistedSource(persisted);
      }
      return;
    }

    final calculated = _controller.currentCalculatedSnapshot;
    final person = _controller.selectedPerson;
    if (calculated != null && person != null) {
      if (!identical(calculated, _lastCalculatedSnapshot)) {
        _lastCalculatedSnapshot = calculated;
        _natalCalculationGeneration += 1;
      }
      await _daeunSeunController.loadUnsavedSource(
        personId: person.id,
        natalCalculationGeneration: _natalCalculationGeneration,
        snapshot: calculated,
      );
      return;
    }

    _lastCalculatedSnapshot = null;
    if (_daeunSeunController.hasSource) {
      _daeunSeunController.clearSource();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onNatalChanged);
    _daeunSeunController.removeListener(_onDerivedChanged);
    unawaited(_controller.stop());
    _controller.dispose();
    _daeunSeunController.dispose();
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
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 2200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WorkspaceHeader(
                  controller: _controller,
                  onNewChart: _startNewChart,
                ),
                const SizedBox(height: 10),
                LayoutBuilder(builder: _buildIntegratedWorkbench),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntegratedWorkbench(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final inputRail = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BirthInputPanel(
          controller: _controller,
          yearController: _yearController,
          monthController: _monthController,
          dayController: _dayController,
          hourController: _hourController,
          minuteController: _minuteController,
          onCalculate: _calculate,
        ),
        const SizedBox(height: 16),
        _SavedHistory(controller: _controller),
      ],
    );
    final analysis = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KeyedSubtree(
          key: const Key('saju-natal-section'),
          child: _ResultBoard(controller: _controller),
        ),
        const SizedBox(height: 8),
        _WorkbenchSection(
          key: const Key('saju-daeun-section'),
          index: '02',
          title: '대운 · 11주기',
          helper: '선택한 흐름이 세운 10년의 기준이 됩니다.',
          child: SajuDaeunTimeline(
            controller: _daeunSeunController,
            showSourceBanner: false,
            showDetail: false,
          ),
        ),
        const SizedBox(height: 8),
        _WorkbenchSection(
          key: const Key('saju-seun-section'),
          index: '03',
          title: '세운 · 선택 대운의 10년',
          helper: '연도 간지 라벨이며 특정 날짜의 활성 세운을 판정하지 않습니다.',
          child: SajuSeunPanel(
            controller: _daeunSeunController,
            showHeader: false,
            showDetail: false,
          ),
        ),
      ],
    );
    final contextRail = _WorkbenchContextRail(
      controller: _daeunSeunController,
      natalController: _controller,
      onSave: _controller.save,
    );

    final content = constraints.maxWidth >= 1740
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                key: const Key('saju-input-rail'),
                width: 300,
                child: inputRail,
              ),
              const SizedBox(width: 18),
              Expanded(child: analysis),
              const SizedBox(width: 18),
              SizedBox(
                key: const Key('saju-context-rail'),
                width: 320,
                child: contextRail,
              ),
            ],
          )
        : constraints.maxWidth >= 1080
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                key: const Key('saju-input-rail'),
                width: 282,
                child: inputRail,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    analysis,
                    const SizedBox(height: 14),
                    KeyedSubtree(
                      key: const Key('saju-context-rail'),
                      child: contextRail,
                    ),
                  ],
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KeyedSubtree(key: const Key('saju-input-rail'), child: inputRail),
              const SizedBox(height: 16),
              analysis,
              const SizedBox(height: 14),
              KeyedSubtree(
                key: const Key('saju-context-rail'),
                child: contextRail,
              ),
            ],
          );

    return KeyedSubtree(
      key: const Key('saju-integrated-workbench'),
      child: content,
    );
  }
}

class _WorkbenchSection extends StatelessWidget {
  const _WorkbenchSection({
    super.key,
    required this.index,
    required this.title,
    required this.helper,
    required this.child,
  });

  final String index;
  final String title;
  final String helper;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primarySurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  index,
                  style: TextStyle(
                    color: colors.mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    helper,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: colors.mutedText, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _WorkbenchContextRail extends StatelessWidget {
  const _WorkbenchContextRail({
    required this.controller,
    required this.natalController,
    required this.onSave,
  });

  final SajuDaeunSeunController controller;
  final SajuManseController natalController;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final provenance = controller.sourceProvenance;
    final persisted = natalController.currentPersistedSnapshot;
    final status = persisted != null
        ? '저장된 원국 · R${persisted.revisionNumber}'
        : natalController.displayedSnapshot != null
        ? '저장 전 원국'
        : '계산 전';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondarySurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '선택 정보',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: TextStyle(color: colors.secondaryText, fontSize: 12),
            ),
            const SizedBox(height: 14),
            if (!controller.hasSource)
              Text(
                '원국을 계산하거나 저장 이력에서 명식을 선택하면 대운과 세운의 선택 정보가 여기에 표시됩니다.',
                style: TextStyle(color: colors.secondaryText, height: 1.5),
              )
            else ...[
              SajuDaeunDetailPanel(controller: controller),
              const SizedBox(height: 10),
              SajuSeunDetailPanel(controller: controller),
              const SizedBox(height: 10),
              Text(
                '올해 위치',
                style: TextStyle(
                  color: colors.mutedText,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '현재 ${controller.currentGregorianYear}년 · 선택 ${controller.selectedSeunYear ?? '—'}년',
                style: TextStyle(color: colors.secondaryText, fontSize: 11),
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: colors.hairline),
              const SizedBox(height: 12),
              Container(
                key: const Key('saju-source-context'),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primarySurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colors.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '출처 · ${provenance?.sourceLabel ?? status}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Engine ${provenance?.sourceEngineVersion ?? '—'} · Policy ${provenance?.sourcePolicyVersion ?? '—'}',
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${provenance?.timezoneId ?? 'Asia/Seoul'} · ${provenance?.birthPlaceProfile ?? '서울 호환'}',
                      style: TextStyle(color: colors.mutedText, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (natalController.displayedSnapshot case final snapshot?) ...[
                const SizedBox(height: 12),
                Divider(height: 1, color: colors.hairline),
                const SizedBox(height: 10),
                _ResultFacts(snapshot: snapshot),
                const SizedBox(height: 8),
                _Warnings(snapshot: snapshot),
                const SizedBox(height: 4),
                _PolicyDetails(snapshot: snapshot),
                const SizedBox(height: 8),
                FilledButton.icon(
                  key: const Key('saju-save'),
                  onPressed: natalController.canSave ? onSave : null,
                  icon: natalController.phase == SajuMansePhase.saving
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.bookmark_add_outlined),
                  label: Text(
                    natalController.currentPersistedSnapshot != null
                        ? '저장됨'
                        : natalController.phase == SajuMansePhase.saving
                        ? '저장 중'
                        : '명식 저장',
                  ),
                ),
              ],
            ],
          ],
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
    final hasResult = controller.displayedSnapshot != null;
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
                style: (hasResult
                        ? Theme.of(context).textTheme.titleLarge
                        : Theme.of(context).textTheme.headlineMedium)
                    ?.copyWith(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w800,
                  letterSpacing: hasResult ? -0.3 : -0.8,
                ),
              ),
              SizedBox(height: hasResult ? 2 : 6),
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

class _BirthInputPanel extends StatefulWidget {
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
  State<_BirthInputPanel> createState() => _BirthInputPanelState();
}

class _BirthInputPanelState extends State<_BirthInputPanel> {
  var _editing = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final controller = widget.controller;
    final yearController = widget.yearController;
    final monthController = widget.monthController;
    final dayController = widget.dayController;
    final hourController = widget.hourController;
    final minuteController = widget.minuteController;
    final onCalculate = widget.onCalculate;
    final draft = controller.draft;
    final snapshot = controller.displayedSnapshot;
    if (snapshot != null && !_editing) {
      return _BirthInputSummary(
        controller: controller,
        snapshot: snapshot,
        onEdit: () => setState(() => _editing = true),
      );
    }
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
              isExpanded: true,
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
                    child: Text(
                      person.displayName,
                      overflow: TextOverflow.ellipsis,
                    ),
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
              key: const Key('saju-gender'),
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

class _BirthInputSummary extends StatelessWidget {
  const _BirthInputSummary({
    required this.controller,
    required this.snapshot,
    required this.onEdit,
  });

  final SajuManseController controller;
  final SajuChartSnapshot snapshot;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final time = snapshot.hourUnknown
        ? '시간 미상'
        : '${snapshot.inputLocalTime!.hour.toString().padLeft(2, '0')}:${snapshot.inputLocalTime!.minute.toString().padLeft(2, '0')}';
    final calendar = snapshot.calendarType == SajuCalendarType.solar ? '양력' : '음력';
    final gender = switch (controller.draft.gender) {
      SajuGender.female => '여성',
      SajuGender.male => '남성',
      SajuGender.unspecified => '성별 미지정',
    };
    return Material(
      key: const Key('saju-input-summary'),
      color: colors.primarySurface,
      elevation: 1,
      shadowColor: colors.scrim.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              controller.selectedPerson?.displayName ?? '연결된 사람',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '$calendar ${snapshot.originalInputDate} · $time',
              style: TextStyle(color: colors.secondaryText, fontSize: 12),
            ),
            const SizedBox(height: 3),
            Text(
              gender,
              style: TextStyle(color: colors.mutedText, fontSize: 11),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              key: const Key('saju-edit-input'),
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('입력 수정'),
            ),
          ],
        ),
      ),
    );
  }
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
  const _ResultBoard({required this.controller});

  final SajuManseController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final snapshot = controller.displayedSnapshot;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primarySurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.hairline),
      ),
      child: Padding(
        padding: EdgeInsets.all(snapshot == null ? 14 : 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (snapshot == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '네 기둥과 여덟 글자',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colors.primaryText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ResultEmpty(hasPerson: controller.selectedPerson != null),
                ],
              )
            else ...[
              SajuIntegratedNatalGrid(
                snapshot: snapshot,
                status: controller.currentPersistedSnapshot != null
                    ? _StatusPill(
                        label:
                            '저장됨 · R${controller.currentPersistedSnapshot!.revisionNumber}',
                        color: colors.success,
                      )
                    : _StatusPill(label: '저장 전', color: colors.warning),
              ),
              if (controller.errorMessage case final message?) ...[
                const SizedBox(height: 8),
                _InlineMessage(message: message, error: true),
              ],
              if (controller.noticeMessage case final message?) ...[
                const SizedBox(height: 8),
                _InlineMessage(message: message),
              ],
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
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(Icons.info_outline_rounded, size: 16, color: colors.warning),
        for (final warning in snapshot.warnings)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: colors.warning.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: colors.warning.withValues(alpha: 0.25)),
            ),
            child: Text(
              _warningLabel(warning),
              style: TextStyle(color: colors.secondaryText, fontSize: 11),
            ),
          ),
      ],
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
              padding: const EdgeInsets.symmetric(vertical: 5),
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
