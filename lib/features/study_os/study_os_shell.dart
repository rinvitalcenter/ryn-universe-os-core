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
        const SizedBox(height: 18),
        _StudyOsScreenMap(
          selectedLabel: selected.label,
          onSelected: _selectScreen,
        ),
        const SizedBox(height: 18),
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

    return _StudyOsSurface(
      padding: const EdgeInsets.all(28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          final titleBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppText.studyOsKicker,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppText.studyOsTitle,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  AppText.studyOsCaption,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          );

          final statusBlock = Column(
            crossAxisAlignment: wide
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: const [
              _StudyOsPill(AppText.studyOsStaticShellMarker),
              SizedBox(height: 8),
              _StudyOsPill(AppText.studyOsNoRuntimeDb),
              SizedBox(height: 8),
              _StudyOsPill(AppText.studyOsNoCrud),
            ],
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [titleBlock, const SizedBox(height: 18), statusBlock],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: titleBlock),
              const SizedBox(width: 24),
              statusBlock,
            ],
          );
        },
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
    return _StudyOsSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StudyOsSectionHeader(
            title: AppText.studyScreenMapTitle,
            body: AppText.studyScreenMapBody,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final cards = _StudyOsScreenSpec.screens
                  .asMap()
                  .entries
                  .map(
                    (entry) => _StudyOsScreenButton(
                      index: entry.key + 1,
                      spec: entry.value,
                      selected: entry.value.label == selectedLabel,
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
          ),
        ],
      ),
    );
  }
}

class _StudyOsScreenButton extends StatelessWidget {
  const _StudyOsScreenButton({
    required this.index,
    required this.spec,
    required this.selected,
    required this.onSelected,
  });

  final int index;
  final _StudyOsScreenSpec spec;
  final bool selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = selected
        ? colorScheme.primaryContainer.withValues(alpha: 0.82)
        : colorScheme.surfaceContainerLow.withValues(alpha: 0.74);
    final foreground = selected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onSelected(spec.label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            width: 190,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? colorScheme.primary.withValues(alpha: 0.35)
                    : colorScheme.outlineVariant.withValues(alpha: 0.72),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StudyOsIconBadge(icon: spec.icon, selected: selected),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: foreground.withValues(alpha: 0.62),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        spec.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
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
    return _StudyOsSurface(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          final detail = _StudyOsSelectedScreen(spec: spec);
          const readiness = _StudyOsReadinessPanel();

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [detail, const SizedBox(height: 18), readiness],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: detail),
              const SizedBox(width: 24),
              const Expanded(flex: 4, child: readiness),
            ],
          );
        },
      ),
    );
  }
}

class _StudyOsSelectedScreen extends StatelessWidget {
  const _StudyOsSelectedScreen({required this.spec});

  final _StudyOsScreenSpec spec;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StudyOsOverview(),
        const SizedBox(height: 20),
        Text(
          AppText.studySelectedScreenLabel,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StudyOsIconBadge(icon: spec.icon, selected: true, large: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spec.label,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    spec.helper,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _StudyOsEmptyState(),
      ],
    );
  }
}

class _StudyOsOverview extends StatelessWidget {
  const _StudyOsOverview();

  @override
  Widget build(BuildContext context) {
    return const _StudyOsSectionHeader(
      title: AppText.studyOverviewTitle,
      body: AppText.studyOverviewBody,
    );
  }
}

class _StudyOsReadinessPanel extends StatelessWidget {
  const _StudyOsReadinessPanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StudyOsSectionHeader(
          title: AppText.studyReadinessTitle,
          body: AppText.studyEmptyState,
        ),
        SizedBox(height: 14),
        _StudyOsStatusTile(
          icon: Icons.laptop_windows_rounded,
          title: AppText.studyReadinessLocalOnly,
          body: AppText.studyLocalSafetyHelper,
        ),
        SizedBox(height: 10),
        _StudyOsStatusTile(
          icon: Icons.layers_rounded,
          title: AppText.studyReadinessStatic,
          body: AppText.studyOsStaticShellMarker,
        ),
        SizedBox(height: 10),
        _StudyOsStatusTile(
          icon: Icons.lock_outline_rounded,
          title: AppText.studyReadinessNoSave,
          body: AppText.studyOsNoCrud,
        ),
      ],
    );
  }
}

class _StudyOsSectionHeader extends StatelessWidget {
  const _StudyOsSectionHeader({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          body,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: const Text(AppText.studyEmptyState),
    );
  }
}

class _StudyOsStatusTile extends StatelessWidget {
  const _StudyOsStatusTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
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

class _StudyOsSurface extends StatelessWidget {
  const _StudyOsSurface({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _StudyOsIconBadge extends StatelessWidget {
  const _StudyOsIconBadge({
    required this.icon,
    required this.selected,
    this.large = false,
  });

  final IconData icon;
  final bool selected;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = large ? 42.0 : 34.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.12)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(large ? 16 : 13),
      ),
      child: Icon(
        icon,
        size: large ? 24 : 19,
        color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
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
        color: colorScheme.secondaryContainer.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: TextStyle(
            color: colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
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
