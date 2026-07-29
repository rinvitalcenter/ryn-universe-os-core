import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/text/user_text.dart';
import '../people/domain/person_core_models.dart';
import '../people/domain/person_core_repositories.dart';
import 'application/study_operations_controller.dart';
import 'application/study_session_editor_controller.dart';
import 'domain/study_operations_models.dart';
import 'domain/study_operations_repository.dart';

class StudyOsShell extends StatefulWidget {
  const StudyOsShell({
    super.key,
    this.repository,
    this.peopleRepository,
    this.now,
  });

  final StudyOperationsRepository? repository;
  final PersonRepository? peopleRepository;
  final DateTime Function()? now;

  @override
  State<StudyOsShell> createState() => _StudyOsShellState();
}

enum _StudySection { home, sessions, materials }

class _StudyOsShellState extends State<StudyOsShell> {
  StudyOperationsController? _controller;
  _StudySection _section = _StudySection.home;
  StudySessionRecord? _editing;

  DateTime get _now => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _bindController();
  }

  @override
  void didUpdateWidget(covariant StudyOsShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.peopleRepository != widget.peopleRepository) {
      _controller?.dispose();
      _bindController();
    }
  }

  void _bindController() {
    final repository = widget.repository;
    final people = widget.peopleRepository;
    if (repository == null || people == null) return;
    _controller = StudyOperationsController(
      repository: repository,
      peopleRepository: people,
    );
    unawaited(_controller!.bootstrap());
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  StudySessionRecord _newRecord() {
    final now = _now;
    return StudySessionRecord(
      session: StudySession(
        id: 'study.${now.toUtc().microsecondsSinceEpoch}',
        title: '',
        occurredAt: now.add(const Duration(days: 7)),
        timezoneOffsetMinutes: now.timeZoneOffset.inMinutes.clamp(-840, 840),
        location: '',
        track: StudyTrack.tarot,
        status: StudySessionStatus.planned,
        progress: StudyProgressStatus.notStarted,
        createdAt: now.toUtc(),
        updatedAt: now.toUtc(),
      ),
    );
  }

  void _openNew() => setState(() => _editing = _newRecord());

  Future<void> _editSelected() async {
    final controller = _controller;
    final selected = controller?.selectedRecord;
    if (selected != null) setState(() => _editing = selected);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final scheme = dark ? _darkScheme : _lightScheme;
    final theme = Theme.of(context).copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      dividerColor: scheme.outlineVariant,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
    return Theme(
      data: theme,
      child: Material(
        key: const Key('study-operations-page'),
        color: scheme.surface,
        child: _controller == null
            ? _StudyUnavailable(onRetry: _bindController)
            : AnimatedBuilder(
                animation: _controller!,
                builder: (context, _) => LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 1050;
                    final controller = _controller!;
                    final initialError = controller.errorMessage;
                    final content = controller.loading
                        ? const _StudyLoading()
                        : initialError != null && controller.sessions.isEmpty
                        ? _StudyLoadError(
                            message: initialError,
                            onRetry: () => unawaited(controller.bootstrap()),
                          )
                        : _editing == null
                        ? _sectionContent(controller, compact)
                        : _StudySessionEditor(
                            key: ValueKey(
                              'study-editor-${_editing!.session.id}',
                            ),
                            repository: widget.repository!,
                            record: _editing!,
                            people: controller.people,
                            materials: controller.materials,
                            now: _now,
                            onCancel: () => setState(() => _editing = null),
                            onSaved: (record) {
                              controller.selectSaved(record);
                              setState(() {
                                _editing = null;
                                _section = _StudySection.sessions;
                              });
                            },
                          );
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1720),
                        child: Row(
                          children: [
                            if (!compact)
                              _StudyRail(
                                section: _section,
                                editing: _editing != null,
                                onSection: (value) => setState(() {
                                  _editing = null;
                                  _section = value;
                                }),
                                onNew: _openNew,
                              ),
                            Expanded(
                              child: Column(
                                children: [
                                  if (compact)
                                    _StudyCompactHeader(
                                      section: _section,
                                      onSection: (value) => setState(() {
                                        _editing = null;
                                        _section = value;
                                      }),
                                      onNew: _openNew,
                                    ),
                                  Expanded(
                                    child: AnimatedSwitcher(
                                      duration:
                                          MediaQuery.disableAnimationsOf(
                                            context,
                                          )
                                          ? Duration.zero
                                          : const Duration(milliseconds: 220),
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      child: content,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _sectionContent(StudyOperationsController controller, bool compact) =>
      switch (_section) {
        _StudySection.home => _StudyHome(
          key: const ValueKey('study-home'),
          controller: controller,
          now: _now,
          onNew: _openNew,
          onOpenSessions: () =>
              setState(() => _section = _StudySection.sessions),
          onSelect: (id) async {
            if (await controller.selectSession(id) && mounted) {
              setState(() => _section = _StudySection.sessions);
            }
          },
        ),
        _StudySection.sessions => _StudySessionsWorkspace(
          key: const ValueKey('study-sessions'),
          controller: controller,
          compact: compact,
          onNew: _openNew,
          onEdit: _editSelected,
        ),
        _StudySection.materials => _StudyMaterialsWorkspace(
          key: const ValueKey('study-materials'),
          controller: controller,
          repository: widget.repository!,
          now: _now,
        ),
      };
}

class _StudyRail extends StatelessWidget {
  const _StudyRail({
    required this.section,
    required this.editing,
    required this.onSection,
    required this.onNew,
  });

  final _StudySection section;
  final bool editing;
  final ValueChanged<_StudySection> onSection;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 224,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border(right: BorderSide(color: colors.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: colors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'Study',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _RailItem(
            icon: Icons.space_dashboard_rounded,
            label: '운영 홈',
            selected: !editing && section == _StudySection.home,
            onTap: () => onSection(_StudySection.home),
          ),
          _RailItem(
            icon: Icons.calendar_view_day_rounded,
            label: '회차',
            selected: !editing && section == _StudySection.sessions,
            onTap: () => onSection(_StudySection.sessions),
          ),
          _RailItem(
            icon: Icons.library_books_rounded,
            label: '자료',
            selected: !editing && section == _StudySection.materials,
            onTap: () => onSection(_StudySection.materials),
          ),
          const Spacer(),
          FilledButton.icon(
            key: const Key('study-new-session'),
            onPressed: onNew,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('새 회차'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '사람과 회차를 연결해\n운영의 다음을 기억합니다.',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withValues(alpha: 0.11)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 11),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? colors.primary : colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudyCompactHeader extends StatelessWidget {
  const _StudyCompactHeader({
    required this.section,
    required this.onSection,
    required this.onNew,
  });

  final _StudySection section;
  final ValueChanged<_StudySection> onSection;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerLowest,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.school_rounded, size: 20),
          const SizedBox(width: 8),
          const Text('Study', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(width: 16),
          for (final item in _StudySection.values)
            TextButton(
              onPressed: () => onSection(item),
              child: Text(switch (item) {
                _StudySection.home => '홈',
                _StudySection.sessions => '회차',
                _StudySection.materials => '자료',
              }),
            ),
          const Spacer(),
          FilledButton.icon(
            onPressed: onNew,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('새 회차'),
          ),
        ],
      ),
    ),
  );
}

class _StudyHome extends StatelessWidget {
  const _StudyHome({
    super.key,
    required this.controller,
    required this.now,
    required this.onNew,
    required this.onOpenSessions,
    required this.onSelect,
  });

  final StudyOperationsController controller;
  final DateTime now;
  final VoidCallback onNew;
  final VoidCallback onOpenSessions;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final sessions = controller.sessions;
    final next = _nextPlanned(sessions, now);
    final completed = sessions
        .where((item) => item.session.status == StudySessionStatus.completed)
        .toList();
    final attended = sessions
        .expand((item) => item.participantIds)
        .toSet()
        .length;
    final trackCounts = {
      for (final track in StudyTrack.values)
        track: sessions.where((item) => item.session.track == track).length,
    };
    return CustomScrollView(
      key: const Key('study-home-scroll'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(34, 32, 34, 42),
          sliver: SliverList.list(
            children: [
              _PageHeader(
                eyebrow: 'STUDY OPERATIONS',
                title: '운영의 다음을 한눈에',
                subtitle: '예정된 회차부터 출석과 이어갈 내용까지, 지금 필요한 흐름만 모았습니다.',
                action: FilledButton.icon(
                  onPressed: onNew,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('새 회차 만들기'),
                ),
              ),
              const SizedBox(height: 30),
              _NextSessionHero(next: next, onNew: onNew, onOpen: onSelect),
              const SizedBox(height: 26),
              _OperationalStrip(
                activePeople: controller.activePeople.length,
                recentPeople: attended,
                completed: completed.length,
                materials: controller.materials.length,
                trackCounts: trackCounts,
              ),
              const SizedBox(height: 34),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '최근 운영 기록',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onOpenSessions,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('전체 회차'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (sessions.isEmpty)
                _StudyEmpty(
                  icon: Icons.calendar_today_rounded,
                  title: '첫 운영 회차를 준비해 볼까요?',
                  body: '참여 회원과 자료를 연결하고, 다음에 이어갈 내용을 한 번에 남길 수 있습니다.',
                  actionLabel: '첫 회차 만들기',
                  onAction: onNew,
                )
              else
                ...sessions
                    .take(5)
                    .map(
                      (item) => _RecentSessionRow(
                        summary: item,
                        onTap: () => onSelect(item.session.id),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NextSessionHero extends StatelessWidget {
  const _NextSessionHero({
    required this.next,
    required this.onNew,
    required this.onOpen,
  });

  final StudySessionSummary? next;
  final VoidCallback onNew;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final session = next?.session;
    return Container(
      key: const Key('study-next-session-hero'),
      constraints: const BoxConstraints(minHeight: 238),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.16),
            colors.tertiary.withValues(alpha: 0.07),
            colors.surfaceContainerLow,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
      ),
      child: session == null
          ? Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEXT SESSION',
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '예정된 회차가 없습니다',
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '다음 만남의 주제와 참여자를 먼저 정해 두면 운영이 가벼워집니다.',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton(
                        onPressed: onNew,
                        child: const Text('회차 준비하기'),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.event_available_rounded,
                  size: 104,
                  color: colors.primary.withValues(alpha: 0.18),
                ),
              ],
            )
          : InkWell(
              onTap: () => onOpen(session.id),
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _StatusPill(label: session.status.label),
                            const SizedBox(width: 8),
                            _StatusPill(
                              label: session.track.label,
                              quiet: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          session.title,
                          style: const TextStyle(
                            fontSize: 29,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.7,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${_dateTimeLabel(session.occurredAt)}  ·  ${session.location}',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Icon(
                              Icons.people_alt_rounded,
                              size: 18,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 7),
                            Text('${next!.participantIds.length}명 참여 예정'),
                            const SizedBox(width: 20),
                            Icon(
                              Icons.auto_stories_rounded,
                              size: 18,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 7),
                            Text('${next!.materialCount}개 자료'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 30,
                    color: colors.primary,
                  ),
                ],
              ),
            ),
    );
  }
}

class _OperationalStrip extends StatelessWidget {
  const _OperationalStrip({
    required this.activePeople,
    required this.recentPeople,
    required this.completed,
    required this.materials,
    required this.trackCounts,
  });

  final int activePeople;
  final int recentPeople;
  final int completed;
  final int materials;
  final Map<StudyTrack, int> trackCounts;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final narrow = constraints.maxWidth < 760;
      final items = [
        _Metric('활성 회원', '$activePeople', '신규 선택 가능'),
        _Metric('최근 참여', '$recentPeople', '고유 참여 인원'),
        _Metric('완료 회차', '$completed', '운영 기록'),
        _Metric('자료', '$materials', '재사용 가능'),
      ];
      final metrics = narrow
          ? Wrap(
              spacing: 12,
              runSpacing: 12,
              children: items
                  .map(
                    (item) => SizedBox(
                      width: (constraints.maxWidth - 12) / 2,
                      child: item,
                    ),
                  )
                  .toList(),
            )
          : Row(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  Expanded(child: items[index]),
                  if (index != items.length - 1) const SizedBox(width: 12),
                ],
              ],
            );
      return Column(
        children: [
          metrics,
          const SizedBox(height: 13),
          _TrackDistribution(counts: trackCounts),
        ],
      );
    },
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.note);
  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            note,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _TrackDistribution extends StatelessWidget {
  const _TrackDistribution({required this.counts});
  final Map<StudyTrack, int> counts;

  @override
  Widget build(BuildContext context) {
    final total = counts.values.fold<int>(0, (sum, value) => sum + value);
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          '트랙',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
        ),
        const SizedBox(width: 14),
        for (final track in StudyTrack.values) ...[
          Container(
            width: total == 0 ? 34 : 34 + 90 * ((counts[track] ?? 0) / total),
            height: 7,
            decoration: BoxDecoration(
              color: switch (track) {
                StudyTrack.tarot => colors.primary,
                StudyTrack.saju => colors.tertiary,
                StudyTrack.mixed => colors.secondary,
              },
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            '${track.label} ${counts[track] ?? 0}',
            style: const TextStyle(fontSize: 11.5),
          ),
          const SizedBox(width: 14),
        ],
      ],
    );
  }
}

class _RecentSessionRow extends StatelessWidget {
  const _RecentSessionRow({required this.summary, required this.onTap});
  final StudySessionSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final session = summary.session;
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 58,
                child: Column(
                  children: [
                    Text(
                      '${session.occurredAt.toLocal().month}월',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${session.occurredAt.toLocal().day}',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 3,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${session.track.label} · ${session.location} · ${summary.participantIds.length}명',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(label: session.status.label, quiet: true),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudySessionsWorkspace extends StatelessWidget {
  const _StudySessionsWorkspace({
    super.key,
    required this.controller,
    required this.compact,
    required this.onNew,
    required this.onEdit,
  });

  final StudyOperationsController controller;
  final bool compact;
  final VoidCallback onNew;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(
            eyebrow: 'SESSIONS',
            title: '회차 운영 기록',
            subtitle: '예정부터 완료까지, 사람과 출석의 맥락을 놓치지 않고 이어갑니다.',
            action: FilledButton.icon(
              onPressed: onNew,
              icon: const Icon(Icons.add_rounded),
              label: const Text('새 회차'),
            ),
          ),
          const SizedBox(height: 22),
          _StudyFilterBar(controller: controller),
          const SizedBox(height: 16),
          Expanded(
            child: controller.loading
                ? const Center(child: CircularProgressIndicator())
                : controller.filteredSessions.isEmpty
                ? _StudyEmpty(
                    icon: Icons.search_off_rounded,
                    title: controller.sessions.isEmpty
                        ? '아직 저장된 회차가 없습니다'
                        : '조건에 맞는 회차가 없습니다',
                    body: controller.sessions.isEmpty
                        ? '새 회차를 만들면 이곳에서 바로 이어서 관리할 수 있습니다.'
                        : '필터를 줄이거나 검색어를 바꿔 보세요.',
                    actionLabel: controller.sessions.isEmpty
                        ? '새 회차'
                        : '필터 초기화',
                    onAction: controller.sessions.isEmpty
                        ? onNew
                        : controller.clearFilters,
                  )
                : compact
                ? _CompactSessionList(controller: controller, onEdit: onEdit)
                : Row(
                    children: [
                      SizedBox(
                        width: 350,
                        child: _SessionList(controller: controller),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _SessionDetail(
                          controller: controller,
                          onEdit: onEdit,
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

class _StudyFilterBar extends StatelessWidget {
  const _StudyFilterBar({required this.controller});
  final StudyOperationsController controller;

  @override
  Widget build(BuildContext context) {
    final filter = controller.filter;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 260,
          child: TextField(
            key: const Key('study-search-field'),
            onChanged: (value) =>
                controller.updateFilter(filter.copyWith(query: value)),
            decoration: const InputDecoration(
              hintText: '제목, 장소, 메모 검색',
              prefixIcon: Icon(Icons.search_rounded, size: 20),
              isDense: true,
            ),
          ),
        ),
        _FilterDropdown<StudySessionStatus>(
          hint: '상태',
          value: filter.status,
          values: StudySessionStatus.values,
          label: (value) => value.label,
          onChanged: (value) =>
              controller.updateFilter(filter.copyWith(status: value)),
        ),
        _FilterDropdown<StudyTrack>(
          hint: '트랙',
          value: filter.track,
          values: StudyTrack.values,
          label: (value) => value.label,
          onChanged: (value) =>
              controller.updateFilter(filter.copyWith(track: value)),
        ),
        _FilterDropdown<StudyAttendanceStatus>(
          hint: '출석',
          value: filter.attendance,
          values: StudyAttendanceStatus.values,
          label: (value) => value.label,
          onChanged: (value) =>
              controller.updateFilter(filter.copyWith(attendance: value)),
        ),
        _FilterDropdown<String>(
          hint: '사람',
          value: filter.personId,
          values: controller.people.map((item) => item.id).toList(),
          label: (id) => _personName(controller.people, id),
          onChanged: (value) =>
              controller.updateFilter(filter.copyWith(personId: value)),
        ),
        SegmentedButton<StudySortOrder>(
          segments: const [
            ButtonSegment(value: StudySortOrder.newest, label: Text('최근순')),
            ButtonSegment(value: StudySortOrder.oldest, label: Text('오래된순')),
          ],
          selected: {filter.sortOrder},
          showSelectedIcon: false,
          onSelectionChanged: (value) =>
              controller.updateFilter(filter.copyWith(sortOrder: value.first)),
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
        ),
        TextButton.icon(
          key: const Key('study-date-filter'),
          onPressed: () async {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2040),
              initialDateRange: filter.from != null && filter.to != null
                  ? DateTimeRange(start: filter.from!, end: filter.to!)
                  : null,
            );
            if (range != null) {
              controller.updateFilter(
                filter.copyWith(from: range.start, to: range.end),
              );
            }
          },
          icon: const Icon(Icons.date_range_rounded, size: 18),
          label: Text(
            filter.from == null
                ? '날짜'
                : '${_dateLabel(filter.from!)}–${_dateLabel(filter.to!)}',
          ),
        ),
        if (filter.query.isNotEmpty ||
            filter.status != null ||
            filter.track != null ||
            filter.attendance != null ||
            filter.personId != null ||
            filter.from != null)
          IconButton(
            tooltip: '필터 초기화',
            onPressed: controller.clearFilters,
            icon: const Icon(Icons.filter_alt_off_rounded),
          ),
      ],
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.values,
    required this.label,
    required this.onChanged,
  });

  final String hint;
  final T? value;
  final List<T> values;
  final String Function(T) label;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonHideUnderline(
    child: DropdownButton<T?>(
      value: value,
      hint: Text(hint),
      borderRadius: BorderRadius.circular(14),
      items: [
        DropdownMenuItem<T?>(value: null, child: Text('$hint · 전체')),
        for (final item in values)
          DropdownMenuItem<T?>(value: item, child: Text(label(item))),
      ],
      onChanged: onChanged,
    ),
  );
}

class _SessionList extends StatelessWidget {
  const _SessionList({required this.controller});
  final StudyOperationsController controller;

  @override
  Widget build(BuildContext context) => ListView.separated(
    key: const Key('study-session-list'),
    itemCount: controller.filteredSessions.length,
    separatorBuilder: (_, _) => const SizedBox(height: 8),
    itemBuilder: (context, index) {
      final item = controller.filteredSessions[index];
      final selected = controller.selectedRecord?.session.id == item.session.id;
      return _SessionListTile(
        summary: item,
        selected: selected,
        onTap: () => controller.selectSession(item.session.id),
      );
    },
  );
}

class _SessionListTile extends StatelessWidget {
  const _SessionListTile({
    required this.summary,
    required this.selected,
    required this.onTap,
  });
  final StudySessionSummary summary;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final session = summary.session;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('study-session-${session.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withValues(alpha: 0.10)
                : colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? colors.primary.withValues(alpha: 0.45)
                  : colors.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusPill(label: session.status.label, quiet: true),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                _dateTimeLabel(session.occurredAt),
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Text(
                    session.track.label,
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.people_alt_rounded,
                    size: 15,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${summary.participantIds.length}',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionDetail extends StatelessWidget {
  const _SessionDetail({required this.controller, required this.onEdit});
  final StudyOperationsController controller;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final record = controller.selectedRecord;
    if (record == null) {
      return const _StudyEmpty(
        icon: Icons.touch_app_rounded,
        title: '확인할 회차를 선택하세요',
        body: '목록에서 회차를 고르면 출석, 자료, 진도와 다음 내용을 한 자리에서 볼 수 있습니다.',
      );
    }
    final session = record.session;
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: const Key('study-session-detail'),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(26),
            sliver: SliverList.list(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _StatusPill(label: session.track.label),
                              const SizedBox(width: 8),
                              _StatusPill(
                                label: session.status.label,
                                quiet: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            session.title,
                            style: const TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            '${_dateTimeLabel(session.occurredAt)} · ${session.location}',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      key: const Key('study-edit-session'),
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('수정'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _DetailSection(
                  title: '운영 개요',
                  icon: Icons.notes_rounded,
                  body: session.summary ?? '기록 없음',
                ),
                _DetailSection(
                  title: '학습 목표',
                  icon: Icons.flag_rounded,
                  body: session.learningGoal ?? '기록 없음',
                  trailing: _StatusPill(
                    label: session.progress.label,
                    quiet: true,
                  ),
                ),
                _DetailSection(
                  title: '실제로 다룬 내용',
                  icon: Icons.checklist_rounded,
                  body: session.coveredContent ?? '기록 없음',
                ),
                _DetailSection(
                  title: '다음에 이어갈 내용',
                  icon: Icons.arrow_forward_rounded,
                  body: session.nextSteps ?? '기록 없음',
                ),
                _DetailSection(
                  title: '운영 메모',
                  icon: Icons.edit_note_rounded,
                  body: session.operationNotes ?? '기록 없음',
                ),
                const SizedBox(height: 8),
                Text(
                  '참여와 출석',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                if (record.participants.isEmpty)
                  Text(
                    '연결된 참여자가 없습니다.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  )
                else
                  for (final participant in record.participants)
                    _ParticipantDetailRow(
                      participant: participant,
                      name: _personName(
                        controller.people,
                        participant.personId,
                      ),
                    ),
                const SizedBox(height: 24),
                Text(
                  '연결 자료',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                if (record.materialIds.isEmpty)
                  Text(
                    '연결된 자료가 없습니다.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: record.materialIds.map((id) {
                      final material = _materialFor(controller.materials, id);
                      return Chip(
                        avatar: const Icon(
                          Icons.auto_stories_rounded,
                          size: 17,
                        ),
                        label: Text(material?.title ?? '연결된 자료'),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantDetailRow extends StatelessWidget {
  const _ParticipantDetailRow({required this.participant, required this.name});
  final StudySessionParticipant participant;
  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: colors.primary.withValues(alpha: 0.12),
            child: Text(
              name.characters.firstOrNull ?? '사',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                if (participant.note case final note?)
                  Text(
                    note,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                if (participant.learningNote case final note?)
                  Text(
                    '학습 메모 · $note',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          _StatusPill(label: participant.attendance.label, quiet: true),
        ],
      ),
    );
  }
}

class _CompactSessionList extends StatelessWidget {
  const _CompactSessionList({required this.controller, required this.onEdit});
  final StudyOperationsController controller;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => ListView.separated(
    itemCount: controller.filteredSessions.length,
    separatorBuilder: (_, _) => const SizedBox(height: 8),
    itemBuilder: (context, index) {
      final item = controller.filteredSessions[index];
      return _SessionListTile(
        summary: item,
        selected: controller.selectedRecord?.session.id == item.session.id,
        onTap: () async {
          await controller.selectSession(item.session.id);
          if (context.mounted) {
            await showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => FractionallySizedBox(
                heightFactor: 0.88,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: _SessionDetail(
                    controller: controller,
                    onEdit: () {
                      Navigator.pop(context);
                      onEdit();
                    },
                  ),
                ),
              ),
            );
          }
        },
      );
    },
  );
}

class _StudyMaterialsWorkspace extends StatelessWidget {
  const _StudyMaterialsWorkspace({
    super.key,
    required this.controller,
    required this.repository,
    required this.now,
  });
  final StudyOperationsController controller;
  final StudyOperationsRepository repository;
  final DateTime now;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PageHeader(
          eyebrow: 'MATERIALS',
          title: '자료 라이브러리',
          subtitle: '파일을 복제하지 않고, 자주 쓰는 교안과 링크의 위치를 가볍게 기억합니다.',
          action: FilledButton.icon(
            key: const Key('study-new-material'),
            onPressed: () => _showMaterialDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('자료 등록'),
          ),
        ),
        const SizedBox(height: 26),
        Expanded(
          child: controller.materials.isEmpty
              ? _StudyEmpty(
                  icon: Icons.library_add_rounded,
                  title: '첫 자료를 등록해 보세요',
                  body: '교안, 도서, 웹페이지와 보관 위치를 남겨 여러 회차에서 다시 사용할 수 있습니다.',
                  actionLabel: '자료 등록',
                  onAction: () => _showMaterialDialog(context),
                )
              : GridView.builder(
                  key: const Key('study-material-grid'),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 360,
                    mainAxisExtent: 190,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: controller.materials.length,
                  itemBuilder: (context, index) =>
                      _MaterialCard(material: controller.materials[index]),
                ),
        ),
      ],
    ),
  );

  Future<void> _showMaterialDialog(BuildContext context) async {
    final material = await showDialog<StudyMaterial>(
      context: context,
      builder: (_) => _MaterialEditorDialog(repository: repository, now: now),
    );
    if (material != null) controller.selectSavedMaterial(material);
  }
}

class _MaterialEditorDialog extends StatefulWidget {
  const _MaterialEditorDialog({required this.repository, required this.now});

  final StudyOperationsRepository repository;
  final DateTime now;

  @override
  State<_MaterialEditorDialog> createState() => _MaterialEditorDialogState();
}

class _MaterialEditorDialogState extends State<_MaterialEditorDialog> {
  final _title = TextEditingController();
  final _url = TextEditingController();
  final _storage = TextEditingController();
  final _description = TextEditingController();
  StudyMaterialType _type = StudyMaterialType.handout;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _url.dispose();
    _storage.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final timestamp = widget.now.toUtc();
    final result = await widget.repository.saveMaterial(
      StudyMaterial(
        id: 'material.${timestamp.microsecondsSinceEpoch}',
        title: _title.text,
        type: _type,
        url: _url.text,
        storageNote: _storage.text,
        description: _description.text,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.pop(context, result.value);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('새 자료 등록'),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('material-title-field'),
              controller: _title,
              decoration: const InputDecoration(labelText: '자료 제목'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<StudyMaterialType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: '유형'),
              items: StudyMaterialType.values
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item, child: Text(item.label)),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _url,
              decoration: const InputDecoration(labelText: 'URL · 선택'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _storage,
              decoration: const InputDecoration(labelText: '보관 위치 · 선택'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: '설명 · 선택'),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('취소'),
      ),
      FilledButton(
        key: const Key('material-save-button'),
        onPressed: _saving ? null : _save,
        child: Text(_saving ? '등록 중' : '등록'),
      ),
    ],
  );
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.material});
  final StudyMaterial material;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final locator = material.url?.trim().isNotEmpty == true
        ? material.url!
        : material.storageNote?.trim().isNotEmpty == true
        ? material.storageNote!
        : '위치 메모 없음';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories_rounded, color: colors.primary),
              const Spacer(),
              _StatusPill(label: material.type.label, quiet: true),
            ],
          ),
          const SizedBox(height: 17),
          Text(
            material.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            material.description ?? '설명 없음',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.link_rounded,
                size: 15,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  locator,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudySessionEditor extends StatefulWidget {
  const _StudySessionEditor({
    super.key,
    required this.repository,
    required this.record,
    required this.people,
    required this.materials,
    required this.now,
    required this.onCancel,
    required this.onSaved,
  });

  final StudyOperationsRepository repository;
  final StudySessionRecord record;
  final List<Person> people;
  final List<StudyMaterial> materials;
  final DateTime now;
  final VoidCallback onCancel;
  final ValueChanged<StudySessionRecord> onSaved;

  @override
  State<_StudySessionEditor> createState() => _StudySessionEditorState();
}

class _StudySessionEditorState extends State<_StudySessionEditor> {
  late final StudySessionEditorController _controller;
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _summary;
  late final TextEditingController _operations;
  late final TextEditingController _goal;
  late final TextEditingController _covered;
  late final TextEditingController _next;
  late DateTime _occurredAt;
  late StudyTrack _track;
  late StudySessionStatus _status;
  late StudyProgressStatus _progress;
  late List<StudySessionParticipant> _participants;
  late List<String> _materialIds;

  @override
  void initState() {
    super.initState();
    final session = widget.record.session;
    _title = TextEditingController(text: session.title);
    _location = TextEditingController(text: session.location);
    _summary = TextEditingController(text: session.summary);
    _operations = TextEditingController(text: session.operationNotes);
    _goal = TextEditingController(text: session.learningGoal);
    _covered = TextEditingController(text: session.coveredContent);
    _next = TextEditingController(text: session.nextSteps);
    _occurredAt = session.occurredAt.toLocal();
    _track = session.track;
    _status = session.status;
    _progress = session.progress;
    _participants = List.of(widget.record.participants);
    _materialIds = List.of(widget.record.materialIds);
    _controller = StudySessionEditorController(
      repository: widget.repository,
      initialDraft: widget.record,
    )..addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    for (final item in [
      _title,
      _location,
      _summary,
      _operations,
      _goal,
      _covered,
      _next,
    ]) {
      item.dispose();
    }
    super.dispose();
  }

  StudySessionRecord _buildRecord() => widget.record.copyWith(
    session: widget.record.session.copyWith(
      title: _title.text,
      location: _location.text,
      occurredAt: _occurredAt.toUtc(),
      timezoneOffsetMinutes: _occurredAt.timeZoneOffset.inMinutes.clamp(
        -840,
        840,
      ),
      track: _track,
      status: _status,
      summary: _summary.text,
      operationNotes: _operations.text,
      learningGoal: _goal.text,
      coveredContent: _covered.text,
      progress: _progress,
      nextSteps: _next.text,
      updatedAt: widget.now.toUtc(),
    ),
    participants: List.unmodifiable(_participants),
    materialIds: List.unmodifiable(_materialIds),
  );

  Future<void> _save() async {
    _controller.updateDraft(_buildRecord());
    final success = await _controller.save();
    if (success && mounted) {
      widget.onSaved(_controller.draft);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('회차를 저장했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final activePeople = widget.people
        .where(
          (person) => person.status == 'active' && person.archivedAt == null,
        )
        .toList();
    final historicalIds = _participants.map((item) => item.personId).toSet();
    final selectablePeople = [
      ...activePeople,
      ...widget.people.where(
        (person) =>
            historicalIds.contains(person.id) &&
            !activePeople.any((item) => item.id == person.id),
      ),
    ];
    return Column(
      key: const Key('study-session-editor'),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 18),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            border: Border(bottom: BorderSide(color: colors.outlineVariant)),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: '닫기',
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.record.session.title.trim().isEmpty
                          ? '새 회차'
                          : '회차 수정',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '운영 맥락을 잃지 않도록 필요한 내용만 차분히 남깁니다.',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (_controller.errorMessage case final error?)
                Flexible(
                  child: Text(
                    error,
                    style: TextStyle(
                      color: colors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(width: 14),
              FilledButton.icon(
                key: const Key('study-save-session'),
                onPressed: _controller.isSaving ? null : _save,
                icon: _controller.isSaving
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_controller.isSaving ? '저장 중' : '저장'),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1100;
              final main = _EditorMain(
                title: _title,
                location: _location,
                summary: _summary,
                operations: _operations,
                goal: _goal,
                covered: _covered,
                next: _next,
                occurredAt: _occurredAt,
                track: _track,
                status: _status,
                progress: _progress,
                onOccurredAt: (value) => setState(() => _occurredAt = value),
                onTrack: (value) => setState(() => _track = value),
                onStatus: (value) => setState(() => _status = value),
                onProgress: (value) => setState(() => _progress = value),
              );
              final links = _EditorLinks(
                people: selectablePeople,
                participants: _participants,
                materials: widget.materials,
                materialIds: _materialIds,
                onParticipants: (value) =>
                    setState(() => _participants = value),
                onMaterials: (value) => setState(() => _materialIds = value),
              );
              if (!wide) {
                return SingleChildScrollView(
                  key: const Key('study-editor-scroll'),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [main, const SizedBox(height: 18), links],
                  ),
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 7,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(32, 28, 24, 42),
                      child: main,
                    ),
                  ),
                  Container(width: 1, color: colors.outlineVariant),
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 28, 42),
                      child: links,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EditorMain extends StatelessWidget {
  const _EditorMain({
    required this.title,
    required this.location,
    required this.summary,
    required this.operations,
    required this.goal,
    required this.covered,
    required this.next,
    required this.occurredAt,
    required this.track,
    required this.status,
    required this.progress,
    required this.onOccurredAt,
    required this.onTrack,
    required this.onStatus,
    required this.onProgress,
  });

  final TextEditingController title;
  final TextEditingController location;
  final TextEditingController summary;
  final TextEditingController operations;
  final TextEditingController goal;
  final TextEditingController covered;
  final TextEditingController next;
  final DateTime occurredAt;
  final StudyTrack track;
  final StudySessionStatus status;
  final StudyProgressStatus progress;
  final ValueChanged<DateTime> onOccurredAt;
  final ValueChanged<StudyTrack> onTrack;
  final ValueChanged<StudySessionStatus> onStatus;
  final ValueChanged<StudyProgressStatus> onProgress;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _SectionTitle('회차 정보', '언제, 어디서, 어떤 트랙으로 만나는지 정합니다.'),
      const SizedBox(height: 16),
      TextField(
        key: const Key('study-title-field'),
        controller: title,
        autofocus: true,
        textInputAction: TextInputAction.next,
        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
        decoration: const InputDecoration(labelText: '회차 제목'),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('study-location-field'),
              controller: location,
              decoration: const InputDecoration(
                labelText: '장소',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              key: const Key('study-date-time-button'),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2040),
                  initialDate: occurredAt,
                );
                if (date == null || !context.mounted) return;
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(occurredAt),
                );
                if (time != null) {
                  onOccurredAt(
                    DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.schedule_rounded),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(_dateTimeLabel(occurredAt)),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      _SegmentField<StudyTrack>(
        label: '트랙',
        values: StudyTrack.values,
        selected: track,
        text: (value) => value.label,
        onChanged: onTrack,
      ),
      const SizedBox(height: 12),
      _SegmentField<StudySessionStatus>(
        label: '상태',
        values: StudySessionStatus.values,
        selected: status,
        text: (value) => value.label,
        onChanged: onStatus,
      ),
      const SizedBox(height: 30),
      const _SectionTitle('운영과 학습', '평가표가 아니라 다음 운영을 위한 기억을 남깁니다.'),
      const SizedBox(height: 16),
      TextField(
        key: const Key('study-summary-field'),
        controller: summary,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: '주제 또는 아젠다',
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: goal,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: '회차 학습 목표',
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: covered,
        maxLines: 4,
        decoration: const InputDecoration(
          labelText: '실제로 다룬 내용',
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 12),
      _SegmentField<StudyProgressStatus>(
        label: '진도',
        values: StudyProgressStatus.values,
        selected: progress,
        text: (value) => value.label,
        onChanged: onProgress,
      ),
      const SizedBox(height: 12),
      TextField(
        controller: next,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: '다음에 이어갈 내용',
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: operations,
        maxLines: 5,
        decoration: const InputDecoration(
          labelText: '운영 메모',
          alignLabelWithHint: true,
        ),
      ),
    ],
  );
}

class _SegmentField<T> extends StatelessWidget {
  const _SegmentField({
    required this.label,
    required this.values,
    required this.selected,
    required this.text,
    required this.onChanged,
  });
  final String label;
  final List<T> values;
  final T selected;
  final String Function(T) text;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 54,
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      Expanded(
        child: SegmentedButton<T>(
          segments: values
              .map(
                (value) =>
                    ButtonSegment(value: value, label: Text(text(value))),
              )
              .toList(),
          selected: {selected},
          showSelectedIcon: false,
          onSelectionChanged: (values) => onChanged(values.first),
        ),
      ),
    ],
  );
}

class _EditorLinks extends StatelessWidget {
  const _EditorLinks({
    required this.people,
    required this.participants,
    required this.materials,
    required this.materialIds,
    required this.onParticipants,
    required this.onMaterials,
  });

  final List<Person> people;
  final List<StudySessionParticipant> participants;
  final List<StudyMaterial> materials;
  final List<String> materialIds;
  final ValueChanged<List<StudySessionParticipant>> onParticipants;
  final ValueChanged<List<String>> onMaterials;

  @override
  Widget build(BuildContext context) {
    final selected = {for (final item in participants) item.personId: item};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('참여와 출석', '활성 회원만 새로 선택할 수 있습니다.'),
        const SizedBox(height: 12),
        if (people.isEmpty)
          const _InlineEmpty(
            icon: Icons.person_add_alt_rounded,
            text: '선택 가능한 회원이 없습니다.',
          )
        else
          for (final person in people)
            _ParticipantEditorRow(
              person: person,
              participant: selected[person.id],
              archived: person.archivedAt != null,
              onChanged: (value) {
                final next = List<StudySessionParticipant>.of(participants)
                  ..removeWhere((item) => item.personId == person.id);
                if (value != null) next.add(value);
                onParticipants(next);
              },
            ),
        const SizedBox(height: 28),
        const _SectionTitle('연결 자료', '한 번 등록한 자료를 여러 회차에서 다시 씁니다.'),
        const SizedBox(height: 12),
        if (materials.isEmpty)
          const _InlineEmpty(
            icon: Icons.library_books_rounded,
            text: '등록된 자료가 없습니다. 자료 화면에서 먼저 추가해 주세요.',
          )
        else
          for (final material in materials)
            CheckboxListTile(
              value: materialIds.contains(material.id),
              onChanged: (checked) {
                final next = List<String>.of(materialIds);
                checked == true
                    ? next.add(material.id)
                    : next.remove(material.id);
                onMaterials(next.toSet().toList());
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(
                material.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(material.type.label),
              controlAffinity: ListTileControlAffinity.leading,
            ),
      ],
    );
  }
}

class _ParticipantEditorRow extends StatefulWidget {
  const _ParticipantEditorRow({
    required this.person,
    required this.participant,
    required this.archived,
    required this.onChanged,
  });
  final Person person;
  final StudySessionParticipant? participant;
  final bool archived;
  final ValueChanged<StudySessionParticipant?> onChanged;

  @override
  State<_ParticipantEditorRow> createState() => _ParticipantEditorRowState();
}

class _ParticipantEditorRowState extends State<_ParticipantEditorRow> {
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _note = TextEditingController(text: widget.participant?.note);
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final participant = widget.participant;
    return AnimatedSize(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 160),
      child: Column(
        children: [
          CheckboxListTile(
            key: Key('study-person-${widget.person.id}'),
            value: participant != null,
            onChanged: widget.archived && participant == null
                ? null
                : (checked) => widget.onChanged(
                    checked == true
                        ? StudySessionParticipant(personId: widget.person.id)
                        : null,
                  ),
            contentPadding: EdgeInsets.zero,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              widget.person.displayName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: widget.archived ? const Text('보관된 회원 · 과거 기록 유지') : null,
          ),
          if (participant != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(42, 0, 0, 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 158,
                    child: DropdownButtonFormField<StudyAttendanceStatus>(
                      initialValue: participant.attendance,
                      isExpanded: true,
                      isDense: true,
                      decoration: const InputDecoration(labelText: '출석'),
                      items: StudyAttendanceStatus.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => widget.onChanged(
                        participant.copyWith(attendance: value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _note,
                      decoration: const InputDecoration(labelText: '참여 메모'),
                      onChanged: (value) =>
                          widget.onChanged(participant.copyWith(note: value)),
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

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.action,
  });
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.55,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.9,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                subtitle,
                style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        action,
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.subtitle);
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
    ],
  );
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.body,
    this.trailing,
  });
  final String title;
  final IconData icon;
  final String body;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, this.quiet = false});
  final String label;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: quiet
            ? colors.surfaceContainerHighest
            : colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: quiet ? colors.onSurfaceVariant : colors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StudyLoading extends StatelessWidget {
  const _StudyLoading();

  @override
  Widget build(BuildContext context) => const Center(
    key: Key('study-loading-state'),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 18),
        Text(
          '운영 기록을 불러오고 있습니다.',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _StudyLoadError extends StatelessWidget {
  const _StudyLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => KeyedSubtree(
    key: const Key('study-error-state'),
    child: _StudyEmpty(
      icon: Icons.sync_problem_rounded,
      title: '운영 기록을 열지 못했습니다',
      body: message,
      actionKey: const Key('study-retry-load'),
      actionLabel: '다시 불러오기',
      onAction: onRetry,
    ),
  );
}

class _StudyEmpty extends StatelessWidget {
  const _StudyEmpty({
    required this.icon,
    required this.title,
    required this.body,
    this.actionKey,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String body;
  final Key? actionKey;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 44),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: colors.primary, size: 27),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant, height: 1.45),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                FilledButton(
                  key: actionKey,
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(icon, size: 19),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _StudyUnavailable extends StatelessWidget {
  const _StudyUnavailable({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
        child: _PageHeader(
          eyebrow: 'STUDY OPERATIONS',
          title: UserText.studyOsTitle,
          subtitle: UserText.studyUserSubtitle,
          action: const SizedBox.shrink(),
        ),
      ),
      Expanded(
        child: _StudyEmpty(
          icon: Icons.hourglass_top_rounded,
          title: '운영 공간을 준비하고 있습니다',
          body: '잠시 후 회차와 자료를 이어서 관리할 수 있습니다.',
          actionLabel: '다시 확인',
          onAction: onRetry,
        ),
      ),
    ],
  );
}

StudySessionSummary? _nextPlanned(
  List<StudySessionSummary> sessions,
  DateTime now,
) {
  final planned =
      sessions
          .where(
            (item) =>
                item.session.status == StudySessionStatus.planned &&
                !item.session.occurredAt.isBefore(now.toUtc()),
          )
          .toList()
        ..sort(
          (left, right) =>
              left.session.occurredAt.compareTo(right.session.occurredAt),
        );
  return planned.firstOrNull;
}

String _personName(List<Person> people, String id) {
  for (final person in people) {
    if (person.id == id) return person.displayName;
  }
  return '연결된 사람';
}

StudyMaterial? _materialFor(List<StudyMaterial> materials, String id) {
  for (final material in materials) {
    if (material.id == id) return material;
  }
  return null;
}

String _dateLabel(DateTime value) {
  final local = value.toLocal();
  return '${local.year}.${local.month.toString().padLeft(2, '0')}.${local.day.toString().padLeft(2, '0')}';
}

String _dateTimeLabel(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour > 12
      ? local.hour - 12
      : local.hour == 0
      ? 12
      : local.hour;
  final period = local.hour < 12 ? '오전' : '오후';
  return '${_dateLabel(local)} · $period $hour:${local.minute.toString().padLeft(2, '0')}';
}

const _lightScheme = ColorScheme.light(
  primary: Color(0xFF315E87),
  onPrimary: Colors.white,
  secondary: Color(0xFF56697C),
  tertiary: Color(0xFF54736D),
  surface: Color(0xFFF7F8FA),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF0F3F6),
  surfaceContainerHighest: Color(0xFFE6EBF0),
  onSurface: Color(0xFF17212B),
  onSurfaceVariant: Color(0xFF5F6B76),
  outlineVariant: Color(0xFFDCE2E8),
  error: Color(0xFFBA1A1A),
);

const _darkScheme = ColorScheme.dark(
  primary: Color(0xFF8DBBE5),
  onPrimary: Color(0xFF0C2940),
  secondary: Color(0xFFA9BAC9),
  tertiary: Color(0xFF93C9BD),
  surface: Color(0xFF0B0F14),
  surfaceContainerLowest: Color(0xFF10161D),
  surfaceContainerLow: Color(0xFF151C24),
  surfaceContainerHighest: Color(0xFF202A35),
  onSurface: Color(0xFFEAF0F5),
  onSurfaceVariant: Color(0xFFA9B4BE),
  outlineVariant: Color(0xFF293440),
  error: Color(0xFFFFB4AB),
);
