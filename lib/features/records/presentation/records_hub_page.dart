import 'package:flutter/material.dart';

import '../../../core/formatters/korean_date_time_formatter.dart';
import '../../tarot/models/tarot_interpretation_session_draft.dart';
import '../../tarot/models/tarot_reading_result_snapshot.dart';
import '../application/record_hub_controller.dart';
import '../domain/record_summary.dart';
import 'records_tarot_spread_preview.dart';

class RecordsHubPage extends StatefulWidget {
  const RecordsHubPage({
    required this.controller,
    required this.snapshotFor,
    required this.interpretationFor,
    required this.activeReadingInstanceId,
    required this.onOpenFullDetail,
    required this.onShowOnHome,
    required this.onStartSelfTarot,
    super.key,
  });

  final RecordHubController controller;
  final TarotReadingResultSnapshot? Function(RecordKey key) snapshotFor;
  final TarotInterpretationSessionDraft? Function(RecordKey key)
  interpretationFor;
  final String? activeReadingInstanceId;
  final ValueChanged<TarotReadingResultSnapshot> onOpenFullDetail;
  final ValueChanged<TarotReadingResultSnapshot> onShowOnHome;
  final VoidCallback onStartSelfTarot;

  @override
  State<RecordsHubPage> createState() => _RecordsHubPageState();
}

class _RecordsHubPageState extends State<RecordsHubPage> {
  late final TextEditingController _searchController;
  RecordKey? _detailModeKey;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.controller.searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (_detailModeKey != null && constraints.maxWidth < 1180) {
              return _detailMode(_detailModeKey!);
            }
            if (constraints.maxWidth >= 1180) {
              return _threeRegion();
            }
            if (constraints.maxWidth >= 760) {
              return _twoRegion();
            }
            return _compact();
          },
        );
      },
    );
  }

  Widget _threeRegion() {
    return ColoredBox(
      key: const Key('records-hub-three-region'),
      color: _palette.background,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 224, child: _navigationPane()),
            const SizedBox(width: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 430, maxWidth: 560),
              child: _listPane(),
            ),
            const SizedBox(width: 14),
            Expanded(child: _previewPane(widget.controller.selectedKey)),
          ],
        ),
      ),
    );
  }

  Widget _twoRegion() {
    return ColoredBox(
      key: const Key('records-hub-two-region'),
      color: _palette.background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 210, child: _navigationPane()),
            const SizedBox(width: 14),
            Expanded(child: _listPane(openDetailOnSelection: true)),
          ],
        ),
      ),
    );
  }

  Widget _compact() {
    return ColoredBox(
      key: const Key('records-hub-compact'),
      color: _palette.background,
      child: SafeArea(
        child: Column(
          children: [
            _compactSectionStrip(),
            Expanded(child: _listPane(openDetailOnSelection: true)),
          ],
        ),
      ),
    );
  }

  Widget _detailMode(RecordKey key) {
    return ColoredBox(
      key: const Key('records-hub-detail-mode'),
      color: _palette.background,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _detailModeKey = null),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('목록으로'),
                ),
              ),
            ),
            Expanded(child: _previewPane(key)),
          ],
        ),
      ),
    );
  }

  Widget _navigationPane() {
    return _PaneSurface(
      child: ListView(
        key: const Key('records-hub-navigation-scroll'),
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.inventory_2_outlined, color: _palette.accent),
                const SizedBox(height: 12),
                Text(
                  '기록 탐색',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '나만의 기록을 차분히 찾아보세요.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _palette.muted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _navItem(RecordHubSection.all, Icons.archive_outlined, '전체 기록'),
          _navItem(RecordHubSection.recent, Icons.schedule_rounded, '최근 기록'),
          _navItem(RecordHubSection.tarot, Icons.style_outlined, '타로'),
          _navItem(
            RecordHubSection.byDate,
            Icons.calendar_month_outlined,
            '날짜별',
          ),
          const SizedBox(height: 18),
          Divider(color: _palette.divider),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.person_outline, size: 17, color: _palette.muted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '사람별 기록은 연결된 기록이 생기면 열립니다.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _palette.muted,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactSectionStrip() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(
        children: [
          _sectionChip(RecordHubSection.all, '전체'),
          _sectionChip(RecordHubSection.recent, '최근'),
          _sectionChip(RecordHubSection.tarot, '타로'),
          _sectionChip(RecordHubSection.byDate, '날짜별'),
        ],
      ),
    );
  }

  Widget _sectionChip(RecordHubSection section, String label) {
    final selected = widget.controller.section == section;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text(label),
        onSelected: (_) => widget.controller.updateSection(section),
      ),
    );
  }

  Widget _navItem(RecordHubSection section, IconData icon, String label) {
    final selected = widget.controller.section == section;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: selected ? _palette.selected : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => widget.controller.updateSection(section),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: selected ? _palette.accent : _palette.muted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
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

  Widget _listPane({bool openDetailOnSelection = false}) {
    return _PaneSurface(
      child: Column(
        children: [
          _listHeader(),
          if (widget.controller.hasErrors) _adapterError(),
          Expanded(
            child:
                widget.controller.isLoading &&
                    widget.controller.allSummaries.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _listBody(openDetailOnSelection),
          ),
        ],
      ),
    );
  }

  Widget _listHeader() {
    final visibleCount = widget.controller.visibleSummaries.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _sectionTitle(widget.controller.section),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$visibleCount개의 기록',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: _palette.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('records-hub-search-field'),
            controller: _searchController,
            onChanged: widget.controller.updateSearchQuery,
            decoration: InputDecoration(
              hintText: '질문, 덱, 스프레드, 카드 검색',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: '검색 지우기',
                      onPressed: () {
                        _searchController.clear();
                        widget.controller.updateSearchQuery('');
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
              filled: true,
              fillColor: _palette.input,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: _palette.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: _palette.divider),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 7,
            children: [
              _filterMenu(
                icon: Icons.layers_outlined,
                label: widget.controller.moduleFilter == RecordModuleType.tarot
                    ? '타로'
                    : '모든 모듈',
                entries: const {'all': '모든 모듈', 'tarot': '타로'},
                onSelected: (value) => widget.controller.updateModuleFilter(
                  value == 'tarot' ? RecordModuleType.tarot : null,
                ),
              ),
              _dateMenu(),
              _filterMenu(
                icon: Icons.flag_outlined,
                label: switch (widget.controller.statusFilter) {
                  RecordDisplayStatus.continuing => '이어가는 중',
                  RecordDisplayStatus.finished => '마침',
                  null => '모든 상태',
                },
                entries: const {
                  'all': '모든 상태',
                  'continuing': '이어가는 중',
                  'finished': '마침',
                },
                onSelected: (value) =>
                    widget.controller.updateStatusFilter(switch (value) {
                      'continuing' => RecordDisplayStatus.continuing,
                      'finished' => RecordDisplayStatus.finished,
                      _ => null,
                    }),
              ),
              if (widget.controller.hasActiveFilters)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.refresh_rounded, size: 17),
                  label: const Text('필터 지우기'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateMenu() {
    final hasDate =
        widget.controller.dateFrom != null || widget.controller.dateTo != null;
    return _filterMenu(
      icon: Icons.calendar_today_outlined,
      label: hasDate ? '최근 30일' : '전체 기간',
      entries: const {'all': '전체 기간', '30': '최근 30일'},
      onSelected: (value) {
        if (value != '30' || widget.controller.allSummaries.isEmpty) {
          widget.controller.updateDateRange(null, null);
          return;
        }
        final latest = widget.controller.allSummaries
            .map((item) => item.occurredAt)
            .reduce((left, right) => left.isAfter(right) ? left : right);
        widget.controller.updateDateRange(
          latest.subtract(const Duration(days: 29)),
          DateTime(latest.year, latest.month, latest.day, 23, 59, 59, 999),
        );
      },
    );
  }

  Widget _filterMenu({
    required IconData icon,
    required String label,
    required Map<String, String> entries,
    required ValueChanged<String> onSelected,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final entry in entries.entries)
          PopupMenuItem(value: entry.key, child: Text(entry.value)),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _palette.input,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: _palette.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: _palette.muted),
              const SizedBox(width: 5),
              Text(label, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 3),
              Icon(Icons.expand_more_rounded, size: 15, color: _palette.muted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listBody(bool openDetailOnSelection) {
    final summaries = widget.controller.visibleSummaries;
    if (summaries.isEmpty) {
      return widget.controller.allSummaries.isEmpty
          ? _allEmpty()
          : _filterEmpty();
    }
    return ListView.separated(
      key: const Key('records-hub-center-scroll'),
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 14),
      itemCount: summaries.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: _palette.divider),
      itemBuilder: (context, index) {
        final summary = summaries[index];
        final showDateHeader =
            widget.controller.section == RecordHubSection.byDate &&
            (index == 0 ||
                !_sameDay(summary.occurredAt, summaries[index - 1].occurredAt));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 14, 10, 5),
                child: Text(
                  '${summary.occurredAt.year}년 ${summary.occurredAt.month}월 ${summary.occurredAt.day}일',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: _palette.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            _recordRow(summary, openDetailOnSelection),
          ],
        );
      },
    );
  }

  Widget _recordRow(RecordSummary summary, bool openDetailOnSelection) {
    final selected = widget.controller.selectedKey == summary.key;
    return Material(
      key: ValueKey('record-row-${summary.key.canonicalRecordId}'),
      color: selected ? _palette.selected : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          widget.controller.select(summary.key);
          if (openDetailOnSelection) {
            setState(() => _detailModeKey = summary.key);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 42,
                decoration: BoxDecoration(
                  color: _palette.tarotTile,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.style_outlined,
                  size: 18,
                  color: _palette.accent,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _badge('타로'),
                        const SizedBox(width: 6),
                        _badge(_statusLabel(summary.status), quiet: true),
                        const Spacer(),
                        Text(
                          '${summary.occurredAt.month}.${summary.occurredAt.day}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: _palette.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      summary.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary.shortSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _palette.muted,
                        height: 1.35,
                      ),
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

  Widget _previewPane(RecordKey? key) {
    if (key == null) {
      return _PaneSurface(child: const Center(child: Text('살펴볼 기록을 선택해 주세요')));
    }
    final summary = widget.controller.summaryFor(key);
    final snapshot = widget.snapshotFor(key);
    if (summary == null || snapshot == null) return _missingSource();
    final interpretation = widget.interpretationFor(key);
    return _PaneSurface(
      key: const Key('records-hub-selected-preview'),
      child: SingleChildScrollView(
        key: const Key('records-hub-preview-scroll'),
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 26),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _badge('타로'),
                    const SizedBox(width: 7),
                    _badge(_statusLabel(summary.status), quiet: true),
                    const Spacer(),
                    if (widget.activeReadingInstanceId == key.canonicalRecordId)
                      _badge('홈에 표시 중', quiet: true),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  summary.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.28,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  KoreanDateTimeFormatter.full(summary.occurredAt),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _palette.muted),
                ),
                const SizedBox(height: 5),
                Text(
                  summary.shortSummary,
                  style: TextStyle(color: _palette.muted),
                ),
                const SizedBox(height: 22),
                RecordsTarotSpreadPreview(snapshot: snapshot),
                const SizedBox(height: 22),
                _interpretationPreview(interpretation),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: summary.capabilities.canOpenFullDetail
                          ? () => widget.onOpenFullDetail(snapshot)
                          : null,
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('전체 기록 열기'),
                    ),
                    if (summary.capabilities.canShowOnHome &&
                        widget.activeReadingInstanceId != key.canonicalRecordId)
                      OutlinedButton.icon(
                        onPressed: () => widget.onShowOnHome(snapshot),
                        icon: const Icon(Icons.home_outlined, size: 18),
                        label: const Text('홈에 표시'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _interpretationPreview(TarotInterpretationSessionDraft? draft) {
    final core = draft?.coreMessage.trim() ?? '';
    final action = draft?.smallAction.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '해석 메모',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: _palette.input,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _palette.divider),
          ),
          child: core.isEmpty && action.isEmpty
              ? Text(
                  '이번 리딩에서 작성한 해석이 없습니다.',
                  style: TextStyle(color: _palette.muted),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (core.isNotEmpty) ...[
                      Text('핵심 메시지', style: _quietLabelStyle),
                      const SizedBox(height: 4),
                      Text(core),
                    ],
                    if (core.isNotEmpty && action.isNotEmpty)
                      const SizedBox(height: 13),
                    if (action.isNotEmpty) ...[
                      Text('작은 실천', style: _quietLabelStyle),
                      const SizedBox(height: 4),
                      Text(action),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _allEmpty() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 36, color: _palette.muted),
          const SizedBox(height: 14),
          Text(
            '아직 남긴 기록이 없습니다',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 리딩이나 수련 기록을 남기면 이곳에서 다시 살펴볼 수 있어요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _palette.muted, height: 1.45),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: widget.onStartSelfTarot,
            child: const Text('셀프 타로 시작'),
          ),
        ],
      ),
    ),
  );

  Widget _filterEmpty() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '조건에 맞는 기록이 없습니다',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: _clearFilters, child: const Text('필터 지우기')),
        ],
      ),
    ),
  );

  Widget _adapterError() => MaterialBanner(
    content: const Text('타로 기록을 불러오지 못했습니다.'),
    actions: [
      TextButton(
        onPressed: widget.controller.refresh,
        child: const Text('다시 시도'),
      ),
    ],
  );

  Widget _missingSource() => _PaneSurface(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('원본 기록을 찾을 수 없습니다'),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: widget.controller.refresh,
              child: const Text('다시 불러오기'),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _badge(String label, {bool quiet = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: quiet ? _palette.input : _palette.tarotTile,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: _palette.divider),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: quiet ? _palette.muted : _palette.accent,
      ),
    ),
  );

  void _clearFilters() {
    _searchController.clear();
    widget.controller.clearFilters();
    setState(() {});
  }

  _RecordsPalette get _palette => _RecordsPalette.of(context);
  TextStyle get _quietLabelStyle => TextStyle(
    color: _palette.muted,
    fontSize: 11,
    fontWeight: FontWeight.w700,
  );

  static String _sectionTitle(RecordHubSection section) => switch (section) {
    RecordHubSection.all => '전체 기록',
    RecordHubSection.recent => '최근 기록',
    RecordHubSection.tarot => '타로 기록',
    RecordHubSection.byDate => '날짜별 기록',
  };

  static String _statusLabel(RecordDisplayStatus status) => switch (status) {
    RecordDisplayStatus.continuing => '이어가는 중',
    RecordDisplayStatus.finished => '마침',
  };

  static bool _sameDay(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

class _PaneSurface extends StatelessWidget {
  const _PaneSurface({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = _RecordsPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.divider),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(14), child: child),
    );
  }
}

final class _RecordsPalette {
  const _RecordsPalette({
    required this.background,
    required this.surface,
    required this.input,
    required this.selected,
    required this.tarotTile,
    required this.divider,
    required this.muted,
    required this.accent,
    required this.shadow,
  });

  final Color background;
  final Color surface;
  final Color input;
  final Color selected;
  final Color tarotTile;
  final Color divider;
  final Color muted;
  final Color accent;
  final Color shadow;

  static _RecordsPalette of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark
        ? const _RecordsPalette(
            background: Color(0xFF0B0F17),
            surface: Color(0xFF111722),
            input: Color(0xFF171E2A),
            selected: Color(0xFF1C2637),
            tarotTile: Color(0xFF232C43),
            divider: Color(0xFF273142),
            muted: Color(0xFF98A4B8),
            accent: Color(0xFFB8C5DB),
            shadow: Color(0x33000000),
          )
        : const _RecordsPalette(
            background: Color(0xFFF2F4F7),
            surface: Color(0xFFFCFCFD),
            input: Color(0xFFF3F5F8),
            selected: Color(0xFFE8EDF5),
            tarotTile: Color(0xFFE6EAF2),
            divider: Color(0xFFDDE2EA),
            muted: Color(0xFF667085),
            accent: Color(0xFF34445E),
            shadow: Color(0x0F182230),
          );
  }
}
