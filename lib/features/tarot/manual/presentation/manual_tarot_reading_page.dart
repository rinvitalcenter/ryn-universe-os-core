import 'package:flutter/material.dart';

import '../../../../core/formatters/korean_date_time_formatter.dart';
import '../../../people/domain/person_core_models.dart';
import '../../data/tarot_spread_registry.dart';
import '../../models/tarot_card_definition.dart';
import '../../models/tarot_deck_definition.dart';
import '../../models/tarot_reading_result_snapshot.dart';
import '../application/manual_tarot_reading_controller.dart';

class ManualTarotReadingPage extends StatefulWidget {
  const ManualTarotReadingPage({
    required this.controller,
    required this.onClose,
    required this.onSaved,
    super.key,
  });

  final ManualTarotReadingController controller;
  final VoidCallback onClose;
  final Future<void> Function(String readingId) onSaved;

  @override
  State<ManualTarotReadingPage> createState() => _ManualTarotReadingPageState();
}

class _ManualTarotReadingPageState extends State<ManualTarotReadingPage> {
  late final ScrollController _scrollController;
  late final TextEditingController _personSearchController;
  late final TextEditingController _questionController;
  late final TextEditingController _wholeImageController;
  late final TextEditingController _flowController;
  late final TextEditingController _coreMessageController;
  late final TextEditingController _smallActionController;
  String _personQuery = '';

  @override
  void initState() {
    super.initState();
    final state = widget.controller.state;
    _scrollController = ScrollController();
    _personSearchController = TextEditingController();
    _questionController = TextEditingController(text: state.question);
    _wholeImageController = TextEditingController(
      text: state.interpretation.wholeImageObservation,
    );
    _flowController = TextEditingController(
      text: state.interpretation.flowInterpretation,
    );
    _coreMessageController = TextEditingController(
      text: state.interpretation.coreMessage,
    );
    _smallActionController = TextEditingController(
      text: state.interpretation.smallAction,
    );
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _scrollController.dispose();
    _personSearchController.dispose();
    _questionController.dispose();
    _wholeImageController.dispose();
    _flowController.dispose();
    _coreMessageController.dispose();
    _smallActionController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final palette = _ManualPalette.of(context);
    return ColoredBox(
      key: const Key('manual-tarot-recorder'),
      color: palette.canvas,
      child: SafeArea(
        child: Column(
          children: [
            _header(palette),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  key: const Key('manual-recorder-scroll'),
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 30),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 1390) {
                        return _wideWorkspace(palette);
                      }
                      if (constraints.maxWidth >= 720) {
                        return _intermediateWorkspace(palette);
                      }
                      return _compactWorkspace(palette);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(_ManualPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: '기록으로 돌아가기',
            onPressed: _requestClose,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '수동 타로 기록',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '이미 진행한 리딩을 실제 순서 그대로 남겨요.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: palette.muted),
                ),
              ],
            ),
          ),
          _saveStatusPill(palette),
        ],
      ),
    );
  }

  Widget _wideWorkspace(_ManualPalette palette) {
    return Row(
      key: const Key('manual-tarot-wide-workspace'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 310, child: _contextPanel(palette)),
        const SizedBox(width: 16),
        Expanded(child: _cardAndInterpretationPanel(palette)),
        const SizedBox(width: 16),
        SizedBox(width: 310, child: _savePanel(palette)),
      ],
    );
  }

  Widget _intermediateWorkspace(_ManualPalette palette) {
    return Column(
      key: const Key('manual-tarot-intermediate-workspace'),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 300, child: _contextPanel(palette)),
            const SizedBox(width: 14),
            Expanded(child: _cardPanel(palette)),
          ],
        ),
        const SizedBox(height: 14),
        _interpretationPanel(palette),
        const SizedBox(height: 14),
        _savePanel(palette),
      ],
    );
  }

  Widget _compactWorkspace(_ManualPalette palette) {
    return Column(
      key: const Key('manual-tarot-compact-workspace'),
      children: [
        _contextPanel(palette),
        const SizedBox(height: 12),
        _cardPanel(palette),
        const SizedBox(height: 12),
        _interpretationPanel(palette),
        const SizedBox(height: 12),
        _savePanel(palette),
      ],
    );
  }

  Widget _cardAndInterpretationPanel(_ManualPalette palette) {
    return Column(
      children: [
        _cardPanel(palette),
        const SizedBox(height: 16),
        _interpretationPanel(palette),
      ],
    );
  }

  Widget _contextPanel(_ManualPalette palette) {
    final state = widget.controller.state;
    final people = widget.controller.availablePeople
        .where((person) {
          final query = _personQuery.trim().toLowerCase();
          return query.isEmpty ||
              person.displayName.toLowerCase().contains(query);
        })
        .toList(growable: false);
    return _LedgerSurface(
      palette: palette,
      title: '대상 · 기본 정보',
      subtitle: '리딩이 실제로 일어난 맥락',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Person', palette),
          const SizedBox(height: 7),
          TextField(
            key: const Key('manual-person-search'),
            controller: _personSearchController,
            onChanged: (value) => setState(() => _personQuery = value),
            decoration: _inputDecoration(
              palette,
              hintText: '사람 검색',
              icon: Icons.search_rounded,
            ),
          ),
          const SizedBox(height: 8),
          if (people.isEmpty)
            _emptyMessage('선택할 수 있는 사람이 없습니다.', palette)
          else
            for (final person in people.take(12))
              _personRow(
                person,
                state.selectedPerson?.id == person.id,
                palette,
              ),
          if (state.fieldErrors['person'] case final error?) ...[
            const SizedBox(height: 7),
            _errorText(error, palette),
          ],
          const SizedBox(height: 18),
          _label('질문', palette),
          const SizedBox(height: 7),
          TextField(
            key: const Key('manual-question'),
            controller: _questionController,
            minLines: 2,
            maxLines: 4,
            onChanged: widget.controller.setQuestion,
            decoration: _inputDecoration(
              palette,
              hintText: '리딩에서 다룬 질문을 입력해 주세요',
            ),
          ),
          if (state.fieldErrors['question'] case final error?) ...[
            const SizedBox(height: 7),
            _errorText(error, palette),
          ],
          const SizedBox(height: 18),
          _label('실제 리딩 일시', palette),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('manual-date'),
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 17),
                  label: Text(_dateLabel(state.readingAt)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('manual-time'),
                  onPressed: _pickTime,
                  icon: const Icon(Icons.schedule_rounded, size: 17),
                  label: Text(_timeLabel(state.readingAt)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _timezoneLabel(state.readingTimezoneOffsetMinutes),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: palette.muted),
          ),
          const SizedBox(height: 18),
          _label('덱', palette),
          const SizedBox(height: 7),
          DropdownButtonFormField<TarotDeckDefinition>(
            key: const Key('manual-deck'),
            initialValue: state.deck,
            isExpanded: true,
            decoration: _inputDecoration(palette),
            items: [
              for (final deck in widget.controller.availableDecks)
                DropdownMenuItem(value: deck, child: Text(deck.label)),
            ],
            onChanged: (deck) {
              if (deck != null) _requestDeckChange(deck);
            },
          ),
          const SizedBox(height: 16),
          _label('스프레드', palette),
          const SizedBox(height: 7),
          DropdownButtonFormField<TarotSpreadDefinition>(
            key: const Key('manual-spread'),
            initialValue: state.spread,
            decoration: _inputDecoration(palette),
            items: [
              for (final spread in widget.controller.availableSpreads)
                DropdownMenuItem(
                  value: spread,
                  child: Text(spread.displayName),
                ),
            ],
            onChanged: (spread) {
              if (spread != null) _requestSpreadChange(spread);
            },
          ),
        ],
      ),
    );
  }

  Widget _personRow(Person person, bool selected, _ManualPalette palette) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        key: ValueKey('manual-person-row-${person.id}'),
        color: selected ? palette.selected : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => widget.controller.selectPerson(person),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: selected ? palette.accent : palette.input,
                  child: Icon(
                    selected ? Icons.check_rounded : Icons.person_outline,
                    size: 16,
                    color: selected ? palette.onAccent : palette.muted,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    person.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardPanel(_ManualPalette palette) {
    final state = widget.controller.state;
    return _LedgerSurface(
      palette: palette,
      title: '카드 배치',
      subtitle: '진행한 순서와 방향을 그대로 입력',
      trailing: Text(
        '${widget.controller.completedPositionCount} / ${state.entries.length}',
        key: const Key('manual-progress'),
        style: TextStyle(color: palette.accent, fontWeight: FontWeight.w700),
      ),
      child: Column(
        children: [
          for (var index = 0; index < state.entries.length; index++) ...[
            _cardEntry(index, state.entries[index], palette),
            if (index != state.entries.length - 1)
              Divider(height: 25, color: palette.line),
          ],
          if (state.fieldErrors['placements'] case final error?) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: _errorText(error, palette),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cardEntry(
    int index,
    ManualTarotCardEntry entry,
    _ManualPalette palette,
  ) {
    final card = entry.card;
    return Semantics(
      label: '${entry.position.displayName} 카드 입력',
      child: Row(
        key: ValueKey('manual-card-entry-${entry.position.id}'),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}'.padLeft(2, '0'),
                  style: TextStyle(
                    color: palette.accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  entry.position.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 52,
            height: 74,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: palette.input,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: palette.line),
            ),
            child: card == null
                ? Icon(Icons.style_outlined, color: palette.muted)
                : Image.asset(
                    card.assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Icon(Icons.style_outlined, color: palette.muted),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card?.displayNameKo ?? card?.displayName ?? '카드를 선택해 주세요',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: card == null ? palette.muted : null,
                    fontWeight: card == null
                        ? FontWeight.w500
                        : FontWeight.w700,
                  ),
                ),
                if (card != null && card.displayNameKo != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    card.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: palette.muted),
                  ),
                ],
                const SizedBox(height: 7),
                SegmentedButton<TarotCardOrientation>(
                  key: ValueKey('manual-orientation-${entry.position.id}'),
                  segments: const [
                    ButtonSegment(
                      value: TarotCardOrientation.upright,
                      label: Text('정방향'),
                    ),
                    ButtonSegment(
                      value: TarotCardOrientation.reversed,
                      label: Text('역방향'),
                    ),
                  ],
                  selected: {entry.orientation},
                  onSelectionChanged: (value) => widget.controller
                      .setOrientation(entry.position.id, value.single),
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            key: ValueKey('manual-card-picker-${entry.position.id}'),
            onPressed: () => _showCardPicker(entry.position.id),
            icon: const Icon(Icons.search_rounded, size: 17),
            label: Text(card == null ? '선택' : '교체'),
          ),
        ],
      ),
    );
  }

  Widget _interpretationPanel(_ManualPalette palette) {
    return _LedgerSurface(
      palette: palette,
      title: '해석 기록',
      subtitle: '비워 두어도 저장할 수 있어요',
      child: Column(
        children: [
          _interpretationField(
            key: const Key('manual-interpretation-observation'),
            label: '전체 이미지 관찰',
            controller: _wholeImageController,
            onChanged: (value) => widget.controller.updateInterpretation(
              wholeImageObservation: value,
            ),
            palette: palette,
          ),
          const SizedBox(height: 12),
          _interpretationField(
            key: const Key('manual-interpretation-flow'),
            label: '흐름 해석',
            controller: _flowController,
            onChanged: (value) => widget.controller.updateInterpretation(
              flowInterpretation: value,
            ),
            palette: palette,
          ),
          const SizedBox(height: 12),
          _interpretationField(
            key: const Key('manual-interpretation-message'),
            label: '핵심 메시지',
            controller: _coreMessageController,
            onChanged: (value) =>
                widget.controller.updateInterpretation(coreMessage: value),
            palette: palette,
          ),
          const SizedBox(height: 12),
          _interpretationField(
            key: const Key('manual-interpretation-action'),
            label: '작은 실천',
            controller: _smallActionController,
            onChanged: (value) =>
                widget.controller.updateInterpretation(smallAction: value),
            palette: palette,
          ),
        ],
      ),
    );
  }

  Widget _interpretationField({
    required Key key,
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required _ManualPalette palette,
  }) {
    return TextField(
      key: key,
      controller: controller,
      minLines: 2,
      maxLines: 5,
      onChanged: onChanged,
      decoration: _inputDecoration(palette, labelText: label),
    );
  }

  Widget _savePanel(_ManualPalette palette) {
    final state = widget.controller.state;
    final selected = state.selectedPerson;
    final saving =
        state.saveStatus == ManualTarotSaveStatus.saving ||
        state.saveStatus == ManualTarotSaveStatus.validating;
    return _LedgerSurface(
      palette: palette,
      title: '기록 요약 · 저장',
      subtitle: '저장 전 한 번 더 확인',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryLine('대상', selected?.displayName ?? '선택 안 됨', palette),
          _summaryLine(
            '일시',
            KoreanDateTimeFormatter.full(state.readingAt),
            palette,
          ),
          _summaryLine('덱', state.deck.label, palette),
          _summaryLine('스프레드', state.spread.displayName, palette),
          _summaryLine(
            '카드',
            '${widget.controller.completedPositionCount} / ${state.entries.length}',
            palette,
          ),
          const SizedBox(height: 14),
          Divider(color: palette.line),
          const SizedBox(height: 10),
          Text(
            state.question.trim().isEmpty
                ? '질문을 입력해 주세요.'
                : state.question.trim(),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: state.question.trim().isEmpty ? palette.muted : null,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          if (state.formError case final error?) ...[
            const SizedBox(height: 14),
            _errorBox(error, palette),
          ],
          if (saving) ...[
            const SizedBox(height: 14),
            LinearProgressIndicator(
              key: const Key('manual-saving-progress'),
              minHeight: 3,
              borderRadius: BorderRadius.circular(999),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('manual-save'),
              onPressed: saving ? null : _save,
              icon: Icon(
                saving ? Icons.hourglass_top_rounded : Icons.save_outlined,
              ),
              label: Text(saving ? '저장 중…' : '이 리딩 저장'),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _saveStatusLabel(state.saveStatus),
              key: const Key('manual-save-status'),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: palette.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryLine(String label, String value, _ManualPalette palette) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: palette.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveStatusPill(_ManualPalette palette) {
    final status = widget.controller.state.saveStatus;
    final saved = status == ManualTarotSaveStatus.saved;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: saved ? palette.successSoft : palette.input,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: saved ? palette.success : palette.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            saved
                ? Icons.check_circle_outline_rounded
                : Icons.edit_note_rounded,
            size: 16,
            color: saved ? palette.success : palette.muted,
          ),
          const SizedBox(width: 5),
          Text(
            saved ? '저장 완료' : '저장 전',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: saved ? palette.success : palette.muted,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final id = await widget.controller.save();
    if (id != null && mounted) await widget.onSaved(id);
  }

  Future<void> _requestClose() async {
    if (!widget.controller.state.isDirty) {
      widget.onClose();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('작성 중인 기록을 닫을까요?'),
        content: const Text('아직 저장하지 않은 질문, 카드와 해석이 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('계속 작성'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('작성 내용 버리기'),
          ),
        ],
      ),
    );
    if (discard == true) widget.onClose();
  }

  Future<void> _pickDate() async {
    final current = widget.controller.state.readingAt;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (picked == null) return;
    final changed = DateTime(
      picked.year,
      picked.month,
      picked.day,
      current.hour,
      current.minute,
    );
    widget.controller.setReadingAt(
      changed,
      timezoneOffsetMinutes: changed.timeZoneOffset.inMinutes,
    );
  }

  Future<void> _pickTime() async {
    final current = widget.controller.state.readingAt;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (picked == null) return;
    final changed = DateTime(
      current.year,
      current.month,
      current.day,
      picked.hour,
      picked.minute,
    );
    widget.controller.setReadingAt(
      changed,
      timezoneOffsetMinutes: changed.timeZoneOffset.inMinutes,
    );
  }

  Future<void> _requestSpreadChange(TarotSpreadDefinition spread) async {
    if (widget.controller.selectSpread(spread)) return;
    final discard = await _confirmPlacementDiscard('스프레드를 바꾸면 입력한 카드가 비워집니다.');
    if (discard) widget.controller.selectSpread(spread, discardExisting: true);
  }

  Future<void> _requestDeckChange(TarotDeckDefinition deck) async {
    if (widget.controller.selectDeck(deck)) return;
    final discard = await _confirmPlacementDiscard('덱을 바꾸면 입력한 카드가 비워집니다.');
    if (discard) widget.controller.selectDeck(deck, discardExisting: true);
  }

  Future<bool> _confirmPlacementDiscard(String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('카드 입력을 다시 시작할까요?'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('변경'),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _showCardPicker(String positionId) async {
    final selected = await showDialog<TarotCardDefinition>(
      context: context,
      builder: (context) =>
          _ManualCardPickerDialog(cards: widget.controller.state.deck.cards),
    );
    if (selected != null) widget.controller.selectCard(positionId, selected);
  }

  InputDecoration _inputDecoration(
    _ManualPalette palette, {
    String? hintText,
    String? labelText,
    IconData? icon,
  }) => InputDecoration(
    hintText: hintText,
    labelText: labelText,
    prefixIcon: icon == null ? null : Icon(icon, size: 18),
    filled: true,
    fillColor: palette.input,
    isDense: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: palette.line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: palette.line),
    ),
  );

  Widget _label(String text, _ManualPalette palette) => Text(
    text,
    style: Theme.of(context).textTheme.labelMedium?.copyWith(
      color: palette.muted,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _emptyMessage(String text, _ManualPalette palette) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: palette.input,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(text, style: TextStyle(color: palette.muted)),
  );

  Widget _errorText(String text, _ManualPalette palette) => Text(
    text,
    style: TextStyle(color: palette.error, fontSize: 12, height: 1.4),
  );

  Widget _errorBox(String text, _ManualPalette palette) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: palette.errorSoft,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: palette.error.withValues(alpha: 0.35)),
    ),
    child: Text(text, style: TextStyle(color: palette.error, height: 1.4)),
  );

  static String _dateLabel(DateTime value) =>
      '${value.year}.${value.month.toString().padLeft(2, '0')}.${value.day.toString().padLeft(2, '0')}';
  static String _timeLabel(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  static String _timezoneLabel(int offset) {
    final sign = offset >= 0 ? '+' : '-';
    final absolute = offset.abs();
    return 'UTC$sign${(absolute ~/ 60).toString().padLeft(2, '0')}:${(absolute % 60).toString().padLeft(2, '0')}';
  }

  static String _saveStatusLabel(ManualTarotSaveStatus status) =>
      switch (status) {
        ManualTarotSaveStatus.idle => '확인 후 한 번만 저장해 주세요.',
        ManualTarotSaveStatus.validating => '입력 내용을 확인하고 있어요.',
        ManualTarotSaveStatus.saving => '안전하게 저장하고 있어요.',
        ManualTarotSaveStatus.saved => '기록에 안전하게 저장했습니다.',
        ManualTarotSaveStatus.failed => '입력은 유지되었습니다. 확인 후 다시 시도해 주세요.',
      };
}

class _ManualCardPickerDialog extends StatefulWidget {
  const _ManualCardPickerDialog({required this.cards});

  final List<TarotCardDefinition> cards;

  @override
  State<_ManualCardPickerDialog> createState() =>
      _ManualCardPickerDialogState();
}

class _ManualCardPickerDialogState extends State<_ManualCardPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final cards = widget.cards
        .where((card) {
          if (query.isEmpty) return true;
          return card.displayName.toLowerCase().contains(query) ||
              (card.displayNameKo?.toLowerCase().contains(query) ?? false) ||
              (card.number?.toString() == query);
        })
        .toList(growable: false);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '카드 선택',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '닫기',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('manual-card-search'),
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: '번호 또는 카드 이름 검색',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: cards.isEmpty
                    ? const Center(child: Text('검색 결과가 없습니다.'))
                    : ListView.separated(
                        key: const Key('manual-card-search-results'),
                        itemCount: cards.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return ListTile(
                            key: ValueKey('manual-card-option-${card.id}'),
                            leading: SizedBox(
                              width: 34,
                              height: 48,
                              child: Image.asset(
                                card.assetPath,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.style_outlined),
                              ),
                            ),
                            title: Text(card.displayNameKo ?? card.displayName),
                            subtitle: card.displayNameKo == null
                                ? null
                                : Text(card.displayName),
                            onTap: () => Navigator.pop(context, card),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LedgerSurface extends StatelessWidget {
  const _LedgerSurface({
    required this.palette,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final _ManualPalette palette;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.line),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.25,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: palette.muted),
                      ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

final class _ManualPalette {
  const _ManualPalette({
    required this.canvas,
    required this.surface,
    required this.input,
    required this.line,
    required this.selected,
    required this.accent,
    required this.onAccent,
    required this.muted,
    required this.error,
    required this.errorSoft,
    required this.success,
    required this.successSoft,
    required this.shadow,
  });

  final Color canvas;
  final Color surface;
  final Color input;
  final Color line;
  final Color selected;
  final Color accent;
  final Color onAccent;
  final Color muted;
  final Color error;
  final Color errorSoft;
  final Color success;
  final Color successSoft;
  final Color shadow;

  static _ManualPalette of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark
        ? const _ManualPalette(
            canvas: Color(0xFF0B111B),
            surface: Color(0xFF121B29),
            input: Color(0xFF182334),
            line: Color(0xFF2A384B),
            selected: Color(0xFF233956),
            accent: Color(0xFF8FB7E8),
            onAccent: Color(0xFF08111D),
            muted: Color(0xFF9AA9BA),
            error: Color(0xFFFFA8A8),
            errorSoft: Color(0xFF342126),
            success: Color(0xFF84D3A3),
            successSoft: Color(0xFF173126),
            shadow: Color(0x66000000),
          )
        : const _ManualPalette(
            canvas: Color(0xFFF3F5F7),
            surface: Color(0xFFFCFDFE),
            input: Color(0xFFF1F4F7),
            line: Color(0xFFD9E0E7),
            selected: Color(0xFFE5EEF8),
            accent: Color(0xFF315D89),
            onAccent: Colors.white,
            muted: Color(0xFF657281),
            error: Color(0xFF9B3434),
            errorSoft: Color(0xFFFCECEC),
            success: Color(0xFF367153),
            successSoft: Color(0xFFEAF5EE),
            shadow: Color(0x140B1624),
          );
  }
}
