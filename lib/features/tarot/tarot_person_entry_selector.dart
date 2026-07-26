import 'package:flutter/material.dart';

import 'models/tarot_reading_context.dart';

final class TarotPersonOption {
  const TarotPersonOption({
    required this.personId,
    required this.displayName,
    this.relationshipSummary,
  });

  final String personId;
  final String displayName;
  final String? relationshipSummary;
}

class TarotPersonEntrySelector extends StatelessWidget {
  const TarotPersonEntrySelector({
    super.key,
    required this.targetMode,
    required this.readingContext,
    required this.personOptions,
    required this.onModeSelected,
    required this.onSelectPerson,
  });

  final TarotReadingMode targetMode;
  final TarotReadingContext readingContext;
  final List<TarotPersonOption> personOptions;
  final ValueChanged<TarotReadingMode> onModeSelected;
  final VoidCallback onSelectPerson;

  TarotPersonOption? get _selectedPerson {
    final personId = readingContext.personId;
    if (personId == null) return null;
    for (final option in personOptions) {
      if (option.personId == personId) return option;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selectedPerson = _selectedPerson;
    final unavailable =
        readingContext.mode == TarotReadingMode.person &&
        readingContext.personId != null &&
        selectedPerson == null;
    return Container(
      key: const Key('tarot-person-entry-selector'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _TargetColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _TargetColors.line(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: _TargetColors.blue(context),
              ),
              const SizedBox(width: 8),
              Text(
                '리딩 대상',
                style: TextStyle(
                  color: _TargetColors.text(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '사람 리딩은 Person 연결이 필요해요.',
                style: TextStyle(
                  color: _TargetColors.subtext(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SegmentedButton<TarotReadingMode>(
            key: const Key('tarot-target-mode-selector'),
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: TarotReadingMode.self,
                icon: Icon(Icons.self_improvement_rounded, size: 17),
                label: Text('나를 위한 리딩', key: Key('tarot-target-mode-self')),
              ),
              ButtonSegment(
                value: TarotReadingMode.person,
                icon: Icon(Icons.person_outline_rounded, size: 17),
                label: Text('사람을 위한 리딩', key: Key('tarot-target-mode-person')),
              ),
              ButtonSegment(
                value: TarotReadingMode.practice,
                icon: Icon(Icons.school_outlined, size: 17),
                label: Text('연습 리딩', key: Key('tarot-target-mode-practice')),
              ),
            ],
            selected: {targetMode},
            onSelectionChanged: (selection) => onModeSelected(selection.single),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? _TargetColors.selected(context)
                    : _TargetColors.surface(context);
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? _TargetColors.blue(context)
                    : _TargetColors.text(context);
              }),
              side: WidgetStateProperty.resolveWith((states) {
                return BorderSide(
                  color: states.contains(WidgetState.selected)
                      ? _TargetColors.blue(context)
                      : _TargetColors.line(context),
                );
              }),
              textStyle: const WidgetStatePropertyAll(
                TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: switch (targetMode) {
              TarotReadingMode.self => _TargetExplanation(
                key: const ValueKey('self-target-explanation'),
                icon: Icons.favorite_border_rounded,
                text: '내 마음과 선택을 차분히 돌아보는 리딩입니다.',
              ),
              TarotReadingMode.practice => _TargetExplanation(
                key: const ValueKey('practice-target-explanation'),
                icon: Icons.menu_book_outlined,
                text: '사람 기록과 연결하지 않고 카드 흐름을 연습합니다.',
              ),
              TarotReadingMode.person => _PersonTargetSummary(
                person: selectedPerson,
                unavailable: unavailable,
                onSelectPerson: onSelectPerson,
              ),
            },
          ),
        ],
      ),
    );
  }
}

Future<TarotPersonOption?> showTarotPersonPicker({
  required BuildContext context,
  required List<TarotPersonOption> options,
  String? selectedPersonId,
}) {
  return showDialog<TarotPersonOption>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _TarotPersonPickerDialog(
      options: options,
      selectedPersonId: selectedPersonId,
    ),
  );
}

class _TargetExplanation extends StatelessWidget {
  const _TargetExplanation({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _TargetColors.blue(context)),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: _TargetColors.subtext(context),
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PersonTargetSummary extends StatelessWidget {
  const _PersonTargetSummary({
    required this.person,
    required this.unavailable,
    required this.onSelectPerson,
  });

  final TarotPersonOption? person;
  final bool unavailable;
  final VoidCallback onSelectPerson;

  @override
  Widget build(BuildContext context) {
    final option = person;
    return Container(
      key: const Key('tarot-selected-person-summary'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _TargetColors.selected(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _TargetColors.blue(context)),
      ),
      child: Row(
        children: [
          Icon(
            unavailable
                ? Icons.person_off_outlined
                : option == null
                ? Icons.person_search_rounded
                : Icons.check_circle_rounded,
            color: unavailable
                ? Theme.of(context).colorScheme.error
                : _TargetColors.blue(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: option == null
                ? Text(
                    unavailable
                        ? '선택한 사람을 현재 목록에서 찾을 수 없습니다. 다시 선택해 주세요.'
                        : '리딩 전에 사람을 선택해 주세요.',
                    style: TextStyle(
                      color: _TargetColors.text(context),
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.displayName,
                        style: TextStyle(
                          color: _TargetColors.text(context),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (option.relationshipSummary?.trim().isNotEmpty ==
                          true) ...[
                        const SizedBox(height: 3),
                        Text(
                          option.relationshipSummary!,
                          style: TextStyle(
                            color: _TargetColors.subtext(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          const SizedBox(width: 10),
          TextButton(
            key: const Key('tarot-person-select-action'),
            onPressed: onSelectPerson,
            child: Text(option == null ? '사람 선택' : '사람 변경'),
          ),
        ],
      ),
    );
  }
}

class _TarotPersonPickerDialog extends StatefulWidget {
  const _TarotPersonPickerDialog({
    required this.options,
    required this.selectedPersonId,
  });

  final List<TarotPersonOption> options;
  final String? selectedPersonId;

  @override
  State<_TarotPersonPickerDialog> createState() =>
      _TarotPersonPickerDialogState();
}

class _TarotPersonPickerDialogState extends State<_TarotPersonPickerDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TarotPersonOption> get _filteredOptions {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.options;
    return widget.options
        .where((option) => option.displayName.toLowerCase().contains(query))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredOptions;
    return Dialog(
      key: const Key('tarot-person-picker'),
      backgroundColor: _TargetColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: _TargetColors.line(context)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '리딩할 사람 선택',
                          style: TextStyle(
                            color: _TargetColors.text(context),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '등록된 사람 중 한 사람을 선택합니다.',
                          style: TextStyle(
                            color: _TargetColors.subtext(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const Key('tarot-person-picker-cancel'),
                    tooltip: '닫기',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('tarot-person-search'),
                controller: _searchController,
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: '이름 검색',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: _TargetColors.input(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _TargetColors.line(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _TargetColors.line(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _TargetColors.blue(context),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: widget.options.isEmpty
                    ? const _EmptyPeopleState()
                    : filtered.isEmpty
                    ? Center(
                        child: Text(
                          '검색 결과가 없습니다.',
                          style: TextStyle(
                            color: _TargetColors.subtext(context),
                          ),
                        ),
                      )
                    : ListView.separated(
                        key: const Key('tarot-person-option-list'),
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          color: _TargetColors.line(context),
                        ),
                        itemBuilder: (context, index) {
                          final option = filtered[index];
                          final selected =
                              option.personId == widget.selectedPersonId;
                          return ListTile(
                            key: Key('tarot-person-option-${option.personId}'),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            selected: selected,
                            selectedTileColor: _TargetColors.selected(context),
                            leading: CircleAvatar(
                              backgroundColor: _TargetColors.input(context),
                              foregroundColor: _TargetColors.blue(context),
                              child: const Icon(Icons.person_outline_rounded),
                            ),
                            title: Text(
                              option.displayName,
                              style: TextStyle(
                                color: _TargetColors.text(context),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle:
                                option.relationshipSummary?.trim().isNotEmpty ==
                                    true
                                ? Text(option.relationshipSummary!)
                                : null,
                            trailing: selected
                                ? Icon(
                                    Icons.check_rounded,
                                    color: _TargetColors.blue(context),
                                  )
                                : null,
                            onTap: () => Navigator.pop(context, option),
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

class _EmptyPeopleState extends StatelessWidget {
  const _EmptyPeopleState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline_rounded,
              color: _TargetColors.subtext(context),
              size: 34,
            ),
            const SizedBox(height: 12),
            Text(
              '등록된 사람이 없습니다.',
              style: TextStyle(
                color: _TargetColors.text(context),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '사람 모듈에서 먼저 사람을 추가해 주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _TargetColors.subtext(context)),
            ),
          ],
        ),
      ),
    );
  }
}

abstract final class _TargetColors {
  static bool _dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surface(BuildContext context) =>
      _dark(context) ? const Color(0xFF202124) : const Color(0xFFFFFFFF);
  static Color input(BuildContext context) =>
      _dark(context) ? const Color(0xFF17181B) : const Color(0xFFF4F5F7);
  static Color selected(BuildContext context) =>
      _dark(context) ? const Color(0xFF172D45) : const Color(0xFFEAF3FF);
  static Color line(BuildContext context) =>
      _dark(context) ? const Color(0xFF3A3C42) : const Color(0xFFD8DADF);
  static Color text(BuildContext context) =>
      _dark(context) ? const Color(0xFFF3F4F6) : const Color(0xFF1D1E22);
  static Color subtext(BuildContext context) =>
      _dark(context) ? const Color(0xFFB4B7BF) : const Color(0xFF60636B);
  static Color blue(BuildContext context) =>
      _dark(context) ? const Color(0xFF64A9FF) : const Color(0xFF0A67C7);
}
