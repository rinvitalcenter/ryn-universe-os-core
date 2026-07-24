import 'package:flutter/material.dart';

import '../../../core/theme/ryn_tokens.dart';
import '../application/people_controller.dart';
import '../domain/person_core_models.dart';

Future<void> showPeopleGroupManagement(
  BuildContext context,
  PeopleController controller,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.transparent,
  builder: (context) => _PeopleGroupManagementSheet(controller: controller),
);

Future<void> showPersonGroupMemberships(
  BuildContext context,
  PeopleController controller,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.transparent,
  builder: (context) => _PersonGroupMembershipSheet(controller: controller),
);

class _PeopleGroupManagementSheet extends StatefulWidget {
  const _PeopleGroupManagementSheet({required this.controller});

  final PeopleController controller;

  @override
  State<_PeopleGroupManagementSheet> createState() =>
      _PeopleGroupManagementSheetState();
}

class _PeopleGroupManagementSheetState
    extends State<_PeopleGroupManagementSheet> {
  final _nameController = TextEditingController();
  bool _creating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_creating) return;
    setState(() => _creating = true);
    final created = await widget.controller.createGroup(_nameController.text);
    if (!mounted) return;
    if (created) _nameController.clear();
    setState(() => _creating = false);
  }

  Future<void> _rename(PersonGroup group) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _RenameGroupDialog(initialName: group.name),
    );
    if (name != null) await widget.controller.renameGroup(group.id, name);
  }

  Future<void> _archive(PersonGroup group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('그룹을 보관할까요?'),
        content: Text('${group.name}의 사람 연결은 그대로 보존되며, 언제든 복원할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            key: const Key('people-group-archive-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('그룹 보관'),
          ),
        ],
      ),
    );
    if (confirmed == true) await widget.controller.archiveGroup(group.id);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final colors = context.rynColors;
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          key: const Key('people-group-management-sheet'),
          constraints: BoxConstraints(
            maxWidth: 720,
            maxHeight: MediaQuery.sizeOf(context).height * 0.86,
          ),
          decoration: BoxDecoration(
            color: colors.primarySurface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(RynTokens.radiusLg),
            ),
            border: Border.all(color: colors.hairline),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '그룹 관리',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      key: const Key('people-group-management-close'),
                      tooltip: '닫기',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                Text(
                  '역할과 별개로 사람을 여러 그룹에 연결할 수 있습니다.',
                  style: TextStyle(color: colors.secondaryText),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('people-group-name-field'),
                        controller: _nameController,
                        maxLength: 60,
                        decoration: const InputDecoration(
                          labelText: '새 그룹 이름',
                          hintText: '예: 테스트 그룹 A',
                        ),
                        onSubmitted: (_) => _create(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      key: const Key('people-group-create-action'),
                      onPressed: _creating ? null : _create,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('만들기'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '이어가는 그룹',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.controller.activeGroups.isEmpty)
                  _EmptyGroupLine(
                    key: const Key('people-group-active-empty'),
                    text: '아직 만든 그룹이 없습니다.',
                  )
                else
                  for (final group in widget.controller.activeGroups)
                    _GroupRow(
                      group: group,
                      count: widget.controller.peopleCountForGroup(group.id),
                      onRename: () => _rename(group),
                      onArchive: () => _archive(group),
                    ),
                const SizedBox(height: 18),
                Text(
                  '보관한 그룹',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.controller.archivedGroups.isEmpty)
                  const _EmptyGroupLine(text: '보관한 그룹이 없습니다.')
                else
                  for (final group in widget.controller.archivedGroups)
                    ListTile(
                      key: Key('people-archived-group-${group.id}'),
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.inventory_2_outlined),
                      title: Text(group.name),
                      subtitle: Text(
                        '${widget.controller.peopleCountForGroup(group.id)}명 연결 보존',
                      ),
                      trailing: OutlinedButton(
                        key: Key('people-group-restore-${group.id}'),
                        onPressed: widget.controller.operationInProgress
                            ? null
                            : () => widget.controller.restoreGroup(group.id),
                        child: const Text('복원'),
                      ),
                    ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _RenameGroupDialog extends StatefulWidget {
  const _RenameGroupDialog({required this.initialName});

  final String initialName;

  @override
  State<_RenameGroupDialog> createState() => _RenameGroupDialogState();
}

class _RenameGroupDialogState extends State<_RenameGroupDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('그룹 이름 바꾸기'),
    content: TextField(
      key: const Key('people-group-rename-field'),
      controller: _controller,
      autofocus: true,
      maxLength: 60,
      decoration: const InputDecoration(labelText: '그룹 이름'),
      onSubmitted: (value) => Navigator.pop(context, value),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('취소'),
      ),
      FilledButton(
        key: const Key('people-group-rename-save'),
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('저장'),
      ),
    ],
  );
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({
    required this.group,
    required this.count,
    required this.onRename,
    required this.onArchive,
  });

  final PersonGroup group;
  final int count;
  final VoidCallback onRename;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) => Container(
    key: Key('people-group-row-${group.id}'),
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: context.rynColors.secondarySurface,
      borderRadius: BorderRadius.circular(RynTokens.radiusMd),
      border: Border.all(color: context.rynColors.hairline),
    ),
    child: ListTile(
      leading: const Icon(Icons.group_work_outlined),
      title: Text(group.name),
      subtitle: Text('$count명'),
      trailing: Wrap(
        spacing: 2,
        children: [
          IconButton(
            tooltip: '그룹 이름 바꾸기',
            onPressed: onRename,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: '그룹 보관',
            onPressed: onArchive,
            icon: const Icon(Icons.inventory_2_outlined),
          ),
        ],
      ),
    ),
  );
}

class _PersonGroupMembershipSheet extends StatefulWidget {
  const _PersonGroupMembershipSheet({required this.controller});

  final PeopleController controller;

  @override
  State<_PersonGroupMembershipSheet> createState() =>
      _PersonGroupMembershipSheetState();
}

class _PersonGroupMembershipSheetState
    extends State<_PersonGroupMembershipSheet> {
  String? _busyGroupId;

  Future<void> _toggle(String groupId, bool selected) async {
    setState(() => _busyGroupId = groupId);
    if (selected) {
      await widget.controller.assignSelectedToGroup(groupId);
    } else {
      await widget.controller.removeSelectedFromGroup(groupId);
    }
    if (mounted) setState(() => _busyGroupId = null);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final colors = context.rynColors;
      final person = widget.controller.selectedPerson;
      final membershipIds = person == null
          ? const <String>{}
          : widget.controller
                .membershipsForPerson(person.id)
                .map((membership) => membership.groupId)
                .toSet();
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          key: const Key('person-group-membership-sheet'),
          constraints: const BoxConstraints(maxWidth: 620),
          decoration: BoxDecoration(
            color: colors.primarySurface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(RynTokens.radiusLg),
            ),
            border: Border.all(color: colors.hairline),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      person == null ? '그룹 연결' : '${person.displayName}의 그룹',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    key: const Key('person-group-membership-close'),
                    tooltip: '닫기',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (widget.controller.activeGroups.isEmpty)
                const _EmptyGroupLine(
                  key: Key('person-group-assignment-empty'),
                  text: '먼저 그룹 관리에서 그룹을 만들어 주세요.',
                )
              else
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final group in widget.controller.activeGroups)
                          Material(
                            color: Colors.transparent,
                            child: CheckboxListTile(
                              key: Key('person-group-choice-${group.id}'),
                              value: membershipIds.contains(group.id),
                              onChanged: _busyGroupId == null
                                  ? (value) => _toggle(group.id, value ?? false)
                                  : null,
                              title: Text(group.name),
                              subtitle: Text(
                                '${widget.controller.peopleCountForGroup(group.id)}명',
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _EmptyGroupLine extends StatelessWidget {
  const _EmptyGroupLine({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: context.rynColors.secondarySurface,
      borderRadius: BorderRadius.circular(RynTokens.radiusMd),
      border: Border.all(color: context.rynColors.hairline),
    ),
    child: Text(text, style: TextStyle(color: context.rynColors.secondaryText)),
  );
}
