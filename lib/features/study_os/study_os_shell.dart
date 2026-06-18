import 'package:flutter/material.dart';

import '../../core/text/app_text.dart';

class StudyOsShell extends StatefulWidget {
  const StudyOsShell({super.key});

  @override
  State<StudyOsShell> createState() => _StudyOsShellState();
}

class _StudyOsShellState extends State<StudyOsShell> {
  String _selectedScreen = AppText.studyScreenHome;

  void _selectScreen(String label) {
    setState(() {
      _selectedScreen = label;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _StudyOsScreenSpec.byLabel(_selectedScreen);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StudyOsHero(),
        const SizedBox(height: 14),
        _StudyOsScreenMap(
          selectedLabel: selected.label,
          onSelected: _selectScreen,
        ),
        const SizedBox(height: 14),
        _StudyOsScreenDetail(spec: selected),
      ],
    );
  }
}

class _StudyOsHero extends StatelessWidget {
  const _StudyOsHero();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _StudyOsPill(AppText.studyOsStaticShellMarker),
                _StudyOsPill(AppText.studyOsNoRuntimeDb),
                _StudyOsPill(AppText.studyOsNoCrud),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              AppText.studyOsTitle,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppText.studyOsCaption,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _StudyOsActionChip(AppText.studyPrimaryActionPlan),
                _StudyOsActionChip(AppText.studyPrimaryActionReview),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StudyOsScreenMap extends StatelessWidget {
  const _StudyOsScreenMap({
    required this.selectedLabel,
    required this.onSelected,
  });

  final String selectedLabel;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final cards = _StudyOsScreenSpec.screens
            .map(
              (screen) => _StudyOsScreenButton(
                spec: screen,
                selected: screen.label == selectedLabel,
                onSelected: onSelected,
              ),
            )
            .toList();

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cards,
          );
        }

        return Wrap(spacing: 10, runSpacing: 10, children: cards);
      },
    );
  }
}

class _StudyOsScreenButton extends StatelessWidget {
  const _StudyOsScreenButton({
    required this.spec,
    required this.selected,
    required this.onSelected,
  });

  final _StudyOsScreenSpec spec;
  final bool selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = selected
        ? colorScheme.primaryContainer
        : colorScheme.surface;
    final foreground = selected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onSelected(spec.label),
          child: Container(
            width: 180,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? colorScheme.primary.withValues(alpha: 0.28)
                    : colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(spec.icon, color: foreground, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    spec.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
}

class _StudyOsScreenDetail extends StatelessWidget {
  const _StudyOsScreenDetail({required this.spec});

  final _StudyOsScreenSpec spec;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(spec.icon, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    spec.label,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              spec.helper,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            const _StudyOsEmptyState(),
          ],
        ),
      ),
    );
  }
}

class _StudyOsEmptyState extends StatelessWidget {
  const _StudyOsEmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(AppText.studyEmptyState),
    );
  }
}

class _StudyOsPill extends StatelessWidget {
  const _StudyOsPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: TextStyle(
            color: colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _StudyOsActionChip extends StatelessWidget {
  const _StudyOsActionChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _StudyOsScreenSpec {
  const _StudyOsScreenSpec({
    required this.label,
    required this.helper,
    required this.icon,
  });

  final String label;
  final String helper;
  final IconData icon;

  static const screens = <_StudyOsScreenSpec>[
    _StudyOsScreenSpec(
      label: AppText.studyScreenHome,
      helper: AppText.studyHomeHelper,
      icon: Icons.home_rounded,
    ),
    _StudyOsScreenSpec(
      label: AppText.studyScreenSessions,
      helper: AppText.studySessionsHelper,
      icon: Icons.calendar_month_rounded,
    ),
    _StudyOsScreenSpec(
      label: AppText.studyScreenSessionDetail,
      helper: AppText.studySessionDetailHelper,
      icon: Icons.view_agenda_rounded,
    ),
    _StudyOsScreenSpec(
      label: AppText.studyScreenMembers,
      helper: AppText.studyMembersHelper,
      icon: Icons.group_rounded,
    ),
    _StudyOsScreenSpec(
      label: AppText.studyScreenAttendance,
      helper: AppText.studyAttendanceHelper,
      icon: Icons.fact_check_rounded,
    ),
    _StudyOsScreenSpec(
      label: AppText.studyScreenMaterials,
      helper: AppText.studyMaterialsHelper,
      icon: Icons.menu_book_rounded,
    ),
    _StudyOsScreenSpec(
      label: AppText.studyScreenJournal,
      helper: AppText.studyJournalHelper,
      icon: Icons.edit_note_rounded,
    ),
    _StudyOsScreenSpec(
      label: AppText.studyScreenReports,
      helper: AppText.studyReportsHelper,
      icon: Icons.summarize_rounded,
    ),
    _StudyOsScreenSpec(
      label: AppText.studyScreenSettings,
      helper: AppText.studyLocalSafetyHelper,
      icon: Icons.shield_rounded,
    ),
  ];

  static _StudyOsScreenSpec byLabel(String label) {
    return screens.firstWhere(
      (screen) => screen.label == label,
      orElse: () => screens.first,
    );
  }
}
