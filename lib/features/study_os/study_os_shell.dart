// ignore_for_file: unused_element

import 'package:flutter/material.dart';

import '../../core/text/user_text.dart';

class StudyOsShell extends StatefulWidget {
  const StudyOsShell({super.key});

  @override
  State<StudyOsShell> createState() => _StudyOsShellState();
}

class _StudyOsShellState extends State<StudyOsShell> {
  String? _detail;

  @override
  Widget build(BuildContext context) {
    final studyTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2F6FED),
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      useMaterial3: true,
    );
    return Theme(
      data: studyTheme,
      child: _detail == null
          ? _StudyUserReadySurface(
              onOpenDetail: (label) => setState(() => _detail = label),
            )
          : _StudyDetailSurface(
              title: _detail!,
              onBack: () => setState(() => _detail = null),
            ),
    );
  }
}

class _StudyUserReadySurface extends StatelessWidget {
  const _StudyUserReadySurface({required this.onOpenDetail});

  final ValueChanged<String> onOpenDetail;

  static const _actions = <_StudyActionCardSpec>[
    _StudyActionCardSpec(
      UserText.studyActionToday,
      UserText.studyPickNeededItem,
      Icons.today_rounded,
    ),
    _StudyActionCardSpec(
      UserText.studyActionAttendance,
      '출석 상태를 확인합니다.',
      Icons.fact_check_rounded,
    ),
    _StudyActionCardSpec(
      UserText.studyActionMaterials,
      '수업 자료를 준비합니다.',
      Icons.menu_book_rounded,
    ),
    _StudyActionCardSpec(
      UserText.studyActionJournal,
      '수업 메모를 이어갑니다.',
      Icons.edit_note_rounded,
    ),
    _StudyActionCardSpec(
      UserText.studyActionReports,
      '정리할 산출물을 확인합니다.',
      Icons.summarize_rounded,
    ),
    _StudyActionCardSpec(
      UserText.studyActionMembers,
      '회원 화면으로 이동합니다.',
      Icons.group_rounded,
    ),
    _StudyActionCardSpec(
      UserText.studyActionSessions,
      '세션 목록을 확인합니다.',
      Icons.calendar_month_rounded,
    ),
    _StudyActionCardSpec(
      UserText.studyActionSettings,
      '화면 모드를 확인합니다.',
      Icons.tune_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return _StudyOsSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      UserText.studyOsTitle,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      UserText.studyUserSubtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1500
                  ? 5
                  : constraints.maxWidth >= 1120
                  ? 4
                  : constraints.maxWidth >= 760
                  ? 3
                  : constraints.maxWidth >= 520
                  ? 2
                  : 1;
              final spacing = 12.0;
              final cardWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final action in _actions)
                    SizedBox(
                      width: cardWidth,
                      child: _StudyUserActionCard(
                        spec: action,
                        onTap: () => onOpenDetail(action.title),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const _StudyUserEmptyState(),
        ],
      ),
    );
  }
}

class _StudyActionCardSpec {
  const _StudyActionCardSpec(this.title, this.body, this.icon);

  final String title;
  final String body;
  final IconData icon;
}

class _StudyUserActionCard extends StatelessWidget {
  const _StudyUserActionCard({required this.spec, this.onTap});

  final _StudyActionCardSpec spec;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final card = Container(
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.60),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(spec.icon, color: colorScheme.primary, size: 21),
          ),
          const SizedBox(height: 10),
          Text(
            spec.title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            spec.body,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class _StudyDetailSurface extends StatelessWidget {
  const _StudyDetailSurface({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return _StudyOsSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text(UserText.backToWorkspace),
          ),
          const SizedBox(height: 10),
          Text(
            '${UserText.navStudy} > $title',
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.60),
              ),
            ),
            child: const Text(UserText.emptyItems),
          ),
        ],
      ),
    );
  }
}

class _StudyUserEmptyState extends StatelessWidget {
  const _StudyUserEmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${UserText.studyEmptyRegistered} ${UserText.studyPickNeededItem}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            UserText.studyOsKicker,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            UserText.studyOsTitle,
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
              UserText.studyOsCaption,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
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
            title: UserText.studyScreenMapTitle,
            body: UserText.studyScreenMapBody,
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
        const SizedBox(height: 18),
        const _StudyOsUsableDashboard(),
        const SizedBox(height: 20),
        Text(
          UserText.studySelectedScreenLabel,
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
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: spec.cues
                        .map((cue) => _StudyOsMiniChip(cue))
                        .toList(),
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
      title: UserText.studyOverviewTitle,
      body: UserText.studyOverviewBody,
    );
  }
}

class _StudyOsUsableDashboard extends StatelessWidget {
  const _StudyOsUsableDashboard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _StudyOsPreparationCard(),
        SizedBox(height: 14),
        _StudyOsOperationFlow(),
        SizedBox(height: 14),
        _StudyOsCueGrid(),
      ],
    );
  }
}

class _StudyOsPreparationCard extends StatelessWidget {
  const _StudyOsPreparationCard();

  @override
  Widget build(BuildContext context) {
    return const _StudyOsInsetCard(
      icon: Icons.event_available_rounded,
      title: UserText.studyNextPrepTitle,
      body: UserText.studyNextPrepBody,
      chips: [
        UserText.studyActionOpenSessions,
        UserText.studyActionOpenAttendance,
      ],
    );
  }
}

class _StudyOsOperationFlow extends StatelessWidget {
  const _StudyOsOperationFlow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 680;
        const steps = [
          _StudyOsFlowStep(
            icon: Icons.flag_rounded,
            title: UserText.studyFlowBefore,
            body: UserText.studyFlowBeforeBody,
          ),
          _StudyOsFlowStep(
            icon: Icons.play_circle_rounded,
            title: UserText.studyFlowSessionDay,
            body: UserText.studyFlowSessionDayBody,
          ),
          _StudyOsFlowStep(
            icon: Icons.check_circle_rounded,
            title: UserText.studyFlowAfter,
            body: UserText.studyFlowAfterBody,
          ),
        ];

        if (compact) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StudyOsFlowStep(
                icon: Icons.flag_rounded,
                title: UserText.studyFlowBefore,
                body: UserText.studyFlowBeforeBody,
              ),
              SizedBox(height: 10),
              _StudyOsFlowStep(
                icon: Icons.play_circle_rounded,
                title: UserText.studyFlowSessionDay,
                body: UserText.studyFlowSessionDayBody,
              ),
              SizedBox(height: 10),
              _StudyOsFlowStep(
                icon: Icons.check_circle_rounded,
                title: UserText.studyFlowAfter,
                body: UserText.studyFlowAfterBody,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: steps
              .map(
                (step) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: step,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StudyOsCueGrid extends StatelessWidget {
  const _StudyOsCueGrid();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StudyOsCueChip(Icons.fact_check_rounded, UserText.studyCueAttendance),
        _StudyOsCueChip(Icons.menu_book_rounded, UserText.studyCueMaterials),
        _StudyOsCueChip(Icons.link_rounded, UserText.studyCueSessionLink),
        _StudyOsCueChip(Icons.edit_note_rounded, UserText.studyCueNotesReport),
        _StudyOsCueChip(Icons.shield_rounded, UserText.studyCueLocalSafe),
      ],
    );
  }
}

class _StudyOsInsetCard extends StatelessWidget {
  const _StudyOsInsetCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.chips,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<String> chips;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StudyOsIconBadge(icon: icon, selected: true, large: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: chips
                      .map((chip) => _StudyOsMiniChip(chip))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyOsFlowStep extends StatelessWidget {
  const _StudyOsFlowStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _StudyOsInsetTile(icon: icon, title: title, body: body);
  }
}

class _StudyOsCueChip extends StatelessWidget {
  const _StudyOsCueChip(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StudyOsMiniChip extends StatelessWidget {
  const _StudyOsMiniChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _StudyOsInsetTile extends StatelessWidget {
  const _StudyOsInsetTile({
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.46),
        ),
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
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: textTheme.bodySmall?.copyWith(
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

class _StudyOsReadinessPanel extends StatelessWidget {
  const _StudyOsReadinessPanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StudyOsSectionHeader(
          title: UserText.studyReadinessTitle,
          body: UserText.studyPickNeededItem,
        ),
        SizedBox(height: 14),
        _StudyOsStatusTile(
          icon: Icons.today_rounded,
          title: UserText.studyReadinessLocalOnly,
          body: UserText.studyAddPreparation,
        ),
        SizedBox(height: 10),
        _StudyOsStatusTile(
          icon: Icons.menu_book_rounded,
          title: UserText.studyReadinessStatic,
          body: UserText.studyActionOpenMaterials,
        ),
        SizedBox(height: 10),
        _StudyOsStatusTile(
          icon: Icons.edit_note_rounded,
          title: UserText.studyReadinessNoSave,
          body: UserText.studyActionOpenJournal,
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
      child: const Text(UserText.studyEmptyState),
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

class _StudyOsScreenSpec {
  const _StudyOsScreenSpec({
    required this.label,
    required this.helper,
    required this.icon,
    required this.cues,
  });

  final String label;
  final String helper;
  final IconData icon;
  final List<String> cues;

  static const screens = <_StudyOsScreenSpec>[
    _StudyOsScreenSpec(
      label: UserText.studyScreenHome,
      helper: UserText.studyHomeHelper,
      icon: Icons.home_rounded,
      cues: [UserText.studyCueAttendance, UserText.studyCueMaterials],
    ),
    _StudyOsScreenSpec(
      label: UserText.studyScreenSessions,
      helper: UserText.studySessionsHelper,
      icon: Icons.calendar_month_rounded,
      cues: [UserText.studyActionOpenSessions, UserText.studyFlowBefore],
    ),
    _StudyOsScreenSpec(
      label: UserText.studyScreenSessionDetail,
      helper: UserText.studySessionDetailHelper,
      icon: Icons.view_agenda_rounded,
      cues: [UserText.studyCueSessionLink, UserText.studyFlowSessionDay],
    ),
    _StudyOsScreenSpec(
      label: UserText.studyScreenMembers,
      helper: UserText.studyMembersHelper,
      icon: Icons.group_rounded,
      cues: [UserText.studyCueAttendance, UserText.studyPickNeededItem],
    ),
    _StudyOsScreenSpec(
      label: UserText.studyScreenAttendance,
      helper: UserText.studyAttendanceHelper,
      icon: Icons.fact_check_rounded,
      cues: [UserText.studyCueAttendance, UserText.studyActionOpenAttendance],
    ),
    _StudyOsScreenSpec(
      label: UserText.studyScreenMaterials,
      helper: UserText.studyMaterialsHelper,
      icon: Icons.menu_book_rounded,
      cues: [UserText.studyCueMaterials, UserText.studyCueSessionLink],
    ),
    _StudyOsScreenSpec(
      label: UserText.studyScreenJournal,
      helper: UserText.studyJournalHelper,
      icon: Icons.edit_note_rounded,
      cues: [UserText.studyFlowAfter, UserText.studyCueNotesReport],
    ),
    _StudyOsScreenSpec(
      label: UserText.studyScreenReports,
      helper: UserText.studyReportsHelper,
      icon: Icons.summarize_rounded,
      cues: [UserText.studyCueNotesReport, UserText.studyActionOpenJournal],
    ),
    _StudyOsScreenSpec(
      label: UserText.studyScreenSettings,
      helper: UserText.studyLocalSafetyHelper,
      icon: Icons.tune_rounded,
      cues: [UserText.themeSettingTitle, UserText.studyPickNeededItem],
    ),
  ];

  static _StudyOsScreenSpec byLabel(String label) {
    return screens.firstWhere(
      (screen) => screen.label == label,
      orElse: () => screens.first,
    );
  }
}
