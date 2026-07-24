import 'package:flutter/material.dart';

import '../../../core/theme/ryn_tokens.dart';
import '../application/people_controller.dart';
import '../domain/person_core_models.dart';
import '../domain/person_core_repositories.dart';
import 'people_group_sheets.dart';

class PeopleUnavailablePage extends StatelessWidget {
  const PeopleUnavailablePage({super.key});

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('people-page'),
    constraints: const BoxConstraints(minHeight: 420),
    decoration: BoxDecoration(
      color: _PeopleColors.workspace(context),
      borderRadius: BorderRadius.circular(RynTokens.radiusLg),
      border: Border.all(color: _PeopleColors.hairline(context)),
    ),
    child: const _IntentionalEmpty(
      icon: Icons.cloud_off_outlined,
      text: '사람 기록을 준비하지 못했습니다.',
      supporting: '앱을 다시 시작한 뒤 한 번 더 확인해 주세요.',
    ),
  );
}

class PeoplePage extends StatefulWidget {
  const PeoplePage({
    super.key,
    required this.peopleRepository,
    required this.roleRepository,
    required this.groupRepository,
    this.onStartSession,
  });

  final PersonRepository peopleRepository;
  final PersonRoleRepository roleRepository;
  final PersonGroupRepository groupRepository;
  final ValueChanged<Person>? onStartSession;

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  late final PeopleController _controller;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _controller = PeopleController(
      peopleRepository: widget.peopleRepository,
      roleRepository: widget.roleRepository,
      groupRepository: widget.groupRepository,
    )..start();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openCreate() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PersonCreateSheet(controller: _controller),
    );
    if (!mounted || created != true) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('사람 기록을 시작했습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        key: const Key('people-page'),
        decoration: BoxDecoration(
          color: _PeopleColors.workspace(context),
          borderRadius: BorderRadius.circular(RynTokens.radiusLg),
          border: Border.all(color: _PeopleColors.hairline(context)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PeopleHeader(
              showingArchived: _controller.showingArchived,
              onAdd: _openCreate,
            ),
            const SizedBox(height: 22),
            if (_controller.errorMessage case final message?) ...[
              _PeopleNotice(
                message: message,
                onDismiss: _controller.clearError,
              ),
              const SizedBox(height: 14),
            ],
            switch (_controller.state) {
              PeopleLoadState.loading => const _PeopleLoadingScene(),
              PeopleLoadState.failure => _PeopleFailureScene(
                message:
                    _controller.errorMessage ??
                    '사람 기록을 불러오지 못했습니다. 다시 시도해 주세요.',
              ),
              PeopleLoadState.ready => _PeopleReadyScene(
                controller: _controller,
                searchController: _searchController,
                onStartSession: widget.onStartSession,
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _PeopleHeader extends StatelessWidget {
  const _PeopleHeader({required this.showingArchived, required this.onAdd});

  final bool showingArchived;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final title = Row(
          children: [
            const _SeedMark(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showingArchived ? '보관한 사람' : '사람의 여정',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: _PeopleColors.text(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    showingArchived
                        ? '잠시 멈춘 기록도 그대로 머물러 있습니다.'
                        : '한 사람의 변화와 시간을 차분히 이어갑니다.',
                    style: TextStyle(color: _PeopleColors.muted(context)),
                  ),
                ],
              ),
            ),
          ],
        );
        final add = Semantics(
          button: true,
          label: '사람 추가',
          child: FilledButton.icon(
            key: const Key('people-add-action'),
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              backgroundColor: _PeopleColors.primary(context),
              foregroundColor: _PeopleColors.onPrimary(context),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            ),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('사람 추가'),
          ),
        );
        if (constraints.maxWidth < 650) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [title, const SizedBox(height: 16), add],
          );
        }
        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: 20),
            add,
          ],
        );
      },
    );
  }
}

class _PeopleReadyScene extends StatelessWidget {
  const _PeopleReadyScene({
    required this.controller,
    required this.searchController,
    this.onStartSession,
  });

  final PeopleController controller;
  final TextEditingController searchController;
  final ValueChanged<Person>? onStartSession;

  @override
  Widget build(BuildContext context) {
    if (!controller.hasPeopleInCurrentLane) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ArchiveSwitch(controller: controller),
          const SizedBox(height: 16),
          _PeopleEmptyScene(showingArchived: controller.showingArchived),
        ],
      );
    }
    final selected = controller.selectedPerson;
    return LayoutBuilder(
      builder: (context, constraints) {
        final master = _PeopleMasterPanel(
          controller: controller,
          searchController: searchController,
        );
        final detail = selected == null
            ? _PeopleNoResultsScene(
                groupFiltered: controller.selectedGroupFilter != null,
                onClear: () {
                  searchController.clear();
                  controller.clearFilters();
                },
              )
            : PersonDetailPage(
                person: selected,
                roles: controller.activeRolesFor(selected.id),
                groups: controller.groupsForPerson(selected.id),
                busy: controller.operationInProgress,
                onArchive: () => _confirmArchive(context),
                onRestore: () => _restore(context),
                onManageGroups: () =>
                    showPersonGroupMemberships(context, controller),
                onRemoveGroup: controller.removeSelectedFromGroup,
                onStartSession: onStartSession == null
                    ? null
                    : () => onStartSession!(selected),
              );
        if (constraints.maxWidth < 920) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [master, const SizedBox(height: 16), detail],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 326, child: master),
            const SizedBox(width: 18),
            Expanded(child: detail),
          ],
        );
      },
    );
  }

  Future<void> _confirmArchive(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이 사람을 보관할까요?'),
        content: const Text('기록은 지워지지 않으며, 보관한 사람에서 언제든 다시 이어갈 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            key: const Key('person-archive-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('보관하기'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final success = await controller.archiveSelected();
    if (!context.mounted || !success) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('사람 기록을 보관했습니다.')));
  }

  Future<void> _restore(BuildContext context) async {
    final success = await controller.restoreSelected();
    if (!context.mounted || !success) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이 사람을 다시 이어갑니다')));
  }
}

class _ArchiveSwitch extends StatelessWidget {
  const _ArchiveSwitch({required this.controller});
  final PeopleController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SegmentedButton<bool>(
        key: const Key('people-show-archived'),
        segments: const [
          ButtonSegment(
            value: false,
            label: Text('이어가는 사람'),
            icon: Icon(Icons.eco_outlined),
          ),
          ButtonSegment(
            value: true,
            label: Text('보관한 사람'),
            icon: Icon(Icons.inventory_2_outlined),
          ),
        ],
        selected: {controller.showingArchived},
        onSelectionChanged: (value) => controller.showArchived(value.single),
      ),
    );
  }
}

class _PeopleMasterPanel extends StatelessWidget {
  const _PeopleMasterPanel({
    required this.controller,
    required this.searchController,
  });
  final PeopleController controller;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('people-master-panel'),
      decoration: BoxDecoration(
        color: _PeopleColors.master(context),
        borderRadius: BorderRadius.circular(RynTokens.radiusLg),
        border: Border.all(color: _PeopleColors.hairline(context)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ArchiveSwitch(controller: controller),
          const SizedBox(height: 12),
          TextField(
            key: const Key('people-search-field'),
            controller: searchController,
            onChanged: controller.updateSearchQuery,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: '이름, 관계, 역할 검색',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: controller.searchQuery.isEmpty
                  ? null
                  : IconButton(
                      key: const Key('people-search-clear'),
                      tooltip: '검색 지우기',
                      onPressed: () {
                        searchController.clear();
                        controller.updateSearchQuery('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  key: const Key('people-primary-role-filter'),
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(
                      'people-primary-role-filter-${controller.primaryRoleFilter ?? 'all'}',
                    ),
                    initialValue: controller.primaryRoleFilter ?? 'all',
                    isExpanded: true,
                    isDense: true,
                    decoration: const InputDecoration(
                      labelText: '대표 역할',
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('전체')),
                      for (final roleType in PeopleRoleCatalog.orderedTypes)
                        DropdownMenuItem(
                          value: roleType,
                          child: Text(PeopleRoleCatalog.labelFor(roleType)),
                        ),
                    ],
                    onChanged: (value) => controller.updatePrimaryRoleFilter(
                      value == 'all' ? null : value,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  key: const Key('people-group-filter'),
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(
                      'people-group-filter-${controller.selectedGroupFilter ?? 'all'}',
                    ),
                    initialValue: controller.selectedGroupFilter ?? 'all',
                    isExpanded: true,
                    isDense: true,
                    decoration: const InputDecoration(
                      labelText: '그룹',
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'all',
                        child: Text('모든 그룹'),
                      ),
                      for (final group in controller.activeGroups)
                        DropdownMenuItem(
                          value: group.id,
                          child: Text(
                            '${group.name} · ${controller.peopleCountForGroup(group.id)}명',
                          ),
                        ),
                    ],
                    onChanged: (value) => controller.updateGroupFilter(
                      value == 'all' ? null : value,
                    ),
                  ),
                ),
              ),
              IconButton(
                key: const Key('people-group-manage'),
                tooltip: '그룹 관리',
                onPressed: () => showPeopleGroupManagement(context, controller),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          if (controller.activeGroups.isEmpty) ...[
            const SizedBox(height: 7),
            Text(
              '아직 만든 그룹이 없습니다.',
              key: const Key('people-no-groups'),
              style: TextStyle(
                color: _PeopleColors.muted(context),
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            '${controller.resultCount}명',
            key: const Key('people-result-count'),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: _PeopleColors.muted(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Semantics(
            label: controller.showingArchived ? '보관한 사람 목록' : '이어가는 사람 목록',
            child: ConstrainedBox(
              key: Key(
                controller.showingArchived
                    ? 'people-archived-list'
                    : 'people-active-list',
              ),
              constraints: const BoxConstraints(maxHeight: 300),
              child: controller.visiblePeople.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        '조건에 맞는 사람이 없습니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _PeopleColors.muted(context)),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final person in controller.visiblePeople) ...[
                            _PersonListItem(
                              person: person,
                              roles: controller.activeRolesFor(person.id),
                              selected:
                                  controller.selectedPerson?.id == person.id,
                              onTap: () => controller.selectPerson(person.id),
                            ),
                            if (person != controller.visiblePeople.last)
                              const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonListItem extends StatelessWidget {
  const _PersonListItem({
    required this.person,
    required this.roles,
    required this.selected,
    required this.onTap,
  });

  final Person person;
  final List<PersonRole> roles;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final archived = person.archivedAt != null;
    final subtitle = person.relationshipSummary?.trim().isNotEmpty == true
        ? person.relationshipSummary!
        : roles.isEmpty
        ? '역할을 천천히 더해보세요.'
        : roles
              .map((role) => PeopleRoleCatalog.labelFor(role.roleType))
              .join(' · ');
    return Semantics(
      button: true,
      selected: selected,
      label:
          '${person.displayName}${archived ? ', 보관됨' : ''}${selected ? ', 선택됨' : ''}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('person-list-item-${person.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(RynTokens.radiusMd),
          child: AnimatedContainer(
            key: Key('person-list-surface-${person.id}'),
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: archived
                  ? _PeopleColors.archived(context)
                  : selected
                  ? _PeopleColors.selected(context)
                  : _PeopleColors.row(context),
              borderRadius: BorderRadius.circular(RynTokens.radiusMd),
              border: Border.all(
                color: selected
                    ? _PeopleColors.primary(context)
                    : _PeopleColors.hairline(context),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                if (selected) ...[
                  Container(
                    key: Key('person-selected-indicator-${person.id}'),
                    width: 3,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _PeopleColors.primary(context),
                      borderRadius: BorderRadius.circular(RynTokens.radiusPill),
                    ),
                  ),
                  const SizedBox(width: 9),
                ],
                CircleAvatar(
                  backgroundColor: _PeopleColors.seedSoft(context),
                  foregroundColor: _PeopleColors.identity(context),
                  child: Icon(
                    archived
                        ? Icons.inventory_2_outlined
                        : Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              person.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _PeopleColors.text(context),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: _PeopleColors.primary(context),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _PeopleColors.muted(context),
                          fontSize: 12.5,
                        ),
                      ),
                      if (archived) ...[
                        const SizedBox(height: 5),
                        Text(
                          '보관된 기록',
                          style: TextStyle(
                            color: _PeopleColors.archiveText(context),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

class PersonDetailPage extends StatelessWidget {
  const PersonDetailPage({
    super.key,
    required this.person,
    required this.roles,
    required this.groups,
    required this.busy,
    required this.onArchive,
    required this.onRestore,
    required this.onManageGroups,
    required this.onRemoveGroup,
    this.onStartSession,
  });

  final Person person;
  final List<PersonRole> roles;
  final List<PersonGroup> groups;
  final bool busy;
  final VoidCallback onArchive;
  final VoidCallback onRestore;
  final VoidCallback onManageGroups;
  final Future<bool> Function(String groupId) onRemoveGroup;
  final VoidCallback? onStartSession;

  @override
  Widget build(BuildContext context) {
    final archived = person.archivedAt != null;
    return Container(
      key: Key('person-detail-${person.id}'),
      decoration: BoxDecoration(
        color: _PeopleColors.detail(context),
        borderRadius: BorderRadius.circular(RynTokens.radiusLg),
        border: Border.all(color: _PeopleColors.hairline(context)),
      ),
      padding: const EdgeInsets.all(22),
      child: DefaultTabController(
        length: 7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 14,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '지금 이 사람',
                      style: TextStyle(
                        color: _PeopleColors.primary(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      person.displayName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: _PeopleColors.text(context),
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.7,
                          ),
                    ),
                  ],
                ),
                if (archived)
                  Semantics(
                    button: true,
                    label: '보관한 사람 복원',
                    child: FilledButton.icon(
                      key: const Key('person-restore-action'),
                      onPressed: busy ? null : onRestore,
                      icon: const Icon(Icons.restore_rounded),
                      label: const Text('다시 이어가기'),
                    ),
                  )
                else
                  Semantics(
                    button: true,
                    label: '선택한 사람 보관',
                    child: OutlinedButton.icon(
                      key: const Key('person-archive-action'),
                      onPressed: busy ? null : onArchive,
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('보관'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            TabBar(
              key: const Key('people-detail-tabs'),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: _PeopleColors.primary(context),
              labelColor: _PeopleColors.primary(context),
              unselectedLabelColor: _PeopleColors.muted(context),
              dividerColor: _PeopleColors.hairline(context),
              tabs: const [
                Tab(text: '개요'),
                Tab(text: '이해 지도'),
                Tab(text: '만남'),
                Tab(text: '리딩'),
                Tab(text: '수련'),
                Tab(text: '스터디'),
                Tab(text: '기록'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 330,
              child: TabBarView(
                children: [
                  _PersonOverview(
                    person: person,
                    roles: roles,
                    groups: groups,
                    onManageGroups: onManageGroups,
                    onRemoveGroup: onRemoveGroup,
                    onStartSession: onStartSession,
                  ),
                  const _IntentionalEmpty(
                    icon: Icons.hub_outlined,
                    text: '사주·점성·휴먼디자인 기록이 아직 없습니다.',
                  ),
                  const _IntentionalEmpty(
                    icon: Icons.handshake_outlined,
                    text: '첫 만남 기록을 남기면 시간의 흐름이 시작됩니다.',
                  ),
                  const _IntentionalEmpty(
                    icon: Icons.auto_stories_outlined,
                    text: '이 사람과 연결된 타로·오라클 리딩이 아직 없습니다.',
                  ),
                  const _IntentionalEmpty(
                    icon: Icons.self_improvement_outlined,
                    text: '기공·명상·요가 실천 기록이 아직 없습니다.',
                  ),
                  const _IntentionalEmpty(
                    icon: Icons.groups_2_outlined,
                    text: '스터디 참여 기록이 아직 없습니다.',
                  ),
                  const _IntentionalEmpty(
                    icon: Icons.timeline_rounded,
                    text: '만남과 리딩이 쌓이면 이곳에 시간순으로 나타납니다.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonOverview extends StatelessWidget {
  const _PersonOverview({
    required this.person,
    required this.roles,
    required this.groups,
    required this.onManageGroups,
    required this.onRemoveGroup,
    this.onStartSession,
  });
  final Person person;
  final List<PersonRole> roles;
  final List<PersonGroup> groups;
  final VoidCallback onManageGroups;
  final Future<bool> Function(String groupId) onRemoveGroup;
  final VoidCallback? onStartSession;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('person-section-overview'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: roles.isEmpty
                ? [const _RolePill(label: '역할 미등록')]
                : [
                    for (final role in roles)
                      _RolePill(
                        label: PeopleRoleCatalog.labelFor(role.roleType),
                      ),
                  ],
          ),
          const SizedBox(height: 16),
          _OverviewLine(
            icon: Icons.nature_people_outlined,
            label: '관계의 맥락',
            value: person.relationshipSummary ?? '관계의 맥락을 천천히 더해보세요.',
          ),
          if (person.firstMetOn != null) ...[
            const SizedBox(height: 12),
            _OverviewLine(
              icon: Icons.calendar_today_outlined,
              label: '처음 만난 날',
              value: _formatDate(person.firstMetOn!),
            ),
          ],
          const SizedBox(height: 12),
          const _OverviewLine(
            icon: Icons.eco_outlined,
            label: '다음 기록',
            value: '첫 만남이나 리딩이 연결되면 변화의 흐름이 이곳에 이어집니다.',
          ),
          if (onStartSession != null) ...[
            const SizedBox(height: 18),
            TextButton.icon(
              key: const Key('person-start-session-action'),
              onPressed: onStartSession,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('새 만남 빠른 시작'),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            '그룹',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (groups.isEmpty)
            Text(
              '소속 그룹이 없습니다.',
              key: const Key('person-no-group-membership'),
              style: TextStyle(color: _PeopleColors.muted(context)),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final group in groups)
                  InputChip(
                    key: Key('person-group-pill-${group.id}'),
                    label: Text(group.name),
                    tooltip: '${group.name}에서 제외',
                    onDeleted: () => onRemoveGroup(group.id),
                  ),
              ],
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('person-group-membership-action'),
              onPressed: onManageGroups,
              icon: const Icon(Icons.group_add_outlined),
              label: const Text('그룹 연결 관리'),
            ),
          ),
        ],
      ),
    );
  }
}

class PersonCreateSheet extends StatefulWidget {
  const PersonCreateSheet({super.key, required this.controller});
  final PeopleController controller;

  @override
  State<PersonCreateSheet> createState() => _PersonCreateSheetState();
}

class _PersonCreateSheetState extends State<PersonCreateSheet> {
  final _nameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _firstMetController = TextEditingController();
  final _roles = <String>{};
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _firstMetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '이름을 입력해 주세요.');
      return;
    }
    DateTime? firstMetOn;
    final dateText = _firstMetController.text.trim();
    if (dateText.isNotEmpty) {
      firstMetOn = DateTime.tryParse(dateText);
      if (firstMetOn == null) {
        setState(() => _error = '날짜는 2026-07-20 형식으로 입력해 주세요.');
        return;
      }
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final success = await widget.controller.createPerson(
      displayName: name,
      relationshipSummary: _relationshipController.text,
      firstMetOn: firstMetOn,
      roleTypes: _roles,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
      return;
    }
    setState(() {
      _saving = false;
      _error = widget.controller.errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        key: const Key('people-create-sheet'),
        constraints: const BoxConstraints(maxWidth: 720),
        decoration: BoxDecoration(
          color: _PeopleColors.input(context),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(RynTokens.radiusLg),
          ),
          border: Border.all(color: _PeopleColors.hairline(context)),
        ),
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '사람 기록 시작',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    tooltip: '닫기',
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '지금 필요한 만큼만 적고, 이후의 시간은 천천히 이어가세요.',
                style: TextStyle(color: _PeopleColors.muted(context)),
              ),
              const SizedBox(height: 20),
              TextField(
                key: const Key('people-display-name-field'),
                controller: _nameController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '표시 이름 *',
                  hintText: '이 사람을 기억할 이름',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const Key('people-relationship-field'),
                controller: _relationshipController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '관계의 맥락',
                  hintText: '예: 함께 공부하는 사람',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const Key('people-first-met-field'),
                controller: _firstMetController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: '처음 만난 날',
                  hintText: 'YYYY-MM-DD',
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '처음 역할',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in PeopleRoleCatalog.labels.entries)
                    FilterChip(
                      key: Key('people-role-${entry.key}'),
                      label: Text(entry.value),
                      selected: _roles.contains(entry.key),
                      onSelected: _saving
                          ? null
                          : (selected) => setState(() {
                              if (selected) {
                                _roles.add(entry.key);
                              } else {
                                _roles.remove(entry.key);
                              }
                            }),
                    ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Semantics(
                button: true,
                label: '사람 기록 저장',
                child: FilledButton.icon(
                  key: const Key('people-save-action'),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_saving ? '저장하는 중' : '저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeopleLoadingScene extends StatelessWidget {
  const _PeopleLoadingScene();
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 360,
    child: const Center(
      child: CircularProgressIndicator(semanticsLabel: '사람 기록 불러오는 중'),
    ),
  );
}

class _PeopleFailureScene extends StatelessWidget {
  const _PeopleFailureScene({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) =>
      _IntentionalEmpty(icon: Icons.cloud_off_outlined, text: message);
}

class _PeopleEmptyScene extends StatelessWidget {
  const _PeopleEmptyScene({required this.showingArchived});
  final bool showingArchived;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 360),
    decoration: BoxDecoration(
      color: _PeopleColors.detail(context),
      borderRadius: BorderRadius.circular(RynTokens.radiusLg),
      border: Border.all(color: _PeopleColors.hairline(context)),
    ),
    child: _IntentionalEmpty(
      icon: showingArchived ? Icons.inventory_2_outlined : Icons.eco_rounded,
      text: showingArchived ? '보관한 사람이 아직 없습니다.' : '아직 이어갈 사람이 없습니다',
      supporting: showingArchived
          ? '보관한 기록은 지워지지 않고 이곳에 머뭅니다.'
          : '사람을 추가하면 한 사람의 긴 성장 기록이 시작됩니다.',
    ),
  );
}

class _PeopleNoResultsScene extends StatelessWidget {
  const _PeopleNoResultsScene({
    required this.onClear,
    required this.groupFiltered,
  });
  final VoidCallback onClear;
  final bool groupFiltered;

  @override
  Widget build(BuildContext context) => Container(
    key: Key(groupFiltered ? 'people-group-no-results' : 'people-no-results'),
    constraints: const BoxConstraints(minHeight: 360),
    decoration: BoxDecoration(
      color: _PeopleColors.detail(context),
      borderRadius: BorderRadius.circular(RynTokens.radiusLg),
      border: Border.all(color: _PeopleColors.hairline(context)),
    ),
    child: _IntentionalEmpty(
      icon: Icons.search_off_rounded,
      text: groupFiltered ? '이 그룹에 조건과 맞는 사람이 없습니다' : '검색 결과가 없습니다',
      supporting: groupFiltered
          ? '그룹, 검색어 또는 대표 역할을 바꾸어 보세요.'
          : '검색어나 대표 역할을 바꾸면 전체 사람을 다시 볼 수 있습니다.',
      action: TextButton.icon(
        key: const Key('people-clear-filters'),
        onPressed: onClear,
        icon: const Icon(Icons.restart_alt_rounded),
        label: const Text('필터 지우기'),
      ),
    ),
  );
}

class _IntentionalEmpty extends StatelessWidget {
  const _IntentionalEmpty({
    required this.icon,
    required this.text,
    this.supporting,
    this.action,
  });
  final IconData icon;
  final String text;
  final String? supporting;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: _PeopleColors.identity(context)),
          const SizedBox(height: 14),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _PeopleColors.text(context),
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          if (supporting != null) ...[
            const SizedBox(height: 7),
            Text(
              supporting!,
              textAlign: TextAlign.center,
              style: TextStyle(color: _PeopleColors.muted(context)),
            ),
          ],
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    ),
  );
}

class _PeopleNotice extends StatelessWidget {
  const _PeopleNotice({required this.message, required this.onDismiss});
  final String message;
  final VoidCallback onDismiss;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.errorContainer,
    borderRadius: BorderRadius.circular(14),
    child: ListTile(
      leading: const Icon(Icons.info_outline_rounded),
      title: Text(message),
      trailing: IconButton(
        tooltip: '알림 닫기',
        onPressed: onDismiss,
        icon: const Icon(Icons.close_rounded),
      ),
    ),
  );
}

class _SeedMark extends StatelessWidget {
  const _SeedMark();
  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: _PeopleColors.seedSoft(context),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.circle_outlined,
          color: _PeopleColors.identity(context),
          size: 30,
        ),
        Transform.translate(
          offset: const Offset(4, -3),
          child: Icon(
            Icons.eco_rounded,
            color: _PeopleColors.identity(context),
            size: 21,
          ),
        ),
      ],
    ),
  );
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: _PeopleColors.seedSoft(context),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: _PeopleColors.hairline(context)),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: _PeopleColors.muted(context),
        fontWeight: FontWeight.w800,
        fontSize: 12.5,
      ),
    ),
  );
}

class _OverviewLine extends StatelessWidget {
  const _OverviewLine({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: _PeopleColors.identity(context)),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: _PeopleColors.muted(context),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: _PeopleColors.text(context),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

String _formatDate(DateTime value) =>
    '${value.year}.${value.month.toString().padLeft(2, '0')}.${value.day.toString().padLeft(2, '0')}';

abstract final class _PeopleColors {
  static Color workspace(BuildContext context) => context.rynColors.appCanvas;
  static Color master(BuildContext context) =>
      context.rynColors.secondarySurface;
  static Color detail(BuildContext context) => context.rynColors.primarySurface;
  static Color row(BuildContext context) => context.rynColors.primarySurface;
  static Color selected(BuildContext context) =>
      context.rynColors.selectedState;
  static Color input(BuildContext context) => context.rynColors.primarySurface;
  static Color archived(BuildContext context) =>
      context.rynColors.tertiarySurface;
  static Color primary(BuildContext context) => context.rynColors.primaryAction;
  static Color onPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;
  static Color seedSoft(BuildContext context) =>
      context.rynColors.tertiarySurface;
  static Color identity(BuildContext context) =>
      context.rynColors.peopleIdentity;
  static Color text(BuildContext context) => context.rynColors.primaryText;
  static Color muted(BuildContext context) => context.rynColors.secondaryText;
  static Color archiveText(BuildContext context) => context.rynColors.mutedText;
  static Color hairline(BuildContext context) => context.rynColors.hairline;
}
