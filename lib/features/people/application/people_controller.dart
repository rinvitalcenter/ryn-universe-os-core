import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/repositories/repository_result.dart';
import '../domain/person_core_models.dart';
import '../domain/person_core_repositories.dart';

enum PeopleLoadState { loading, ready, failure }

abstract final class PeopleRoleCatalog {
  static const orderedTypes = <String>[
    PersonRoleTypes.self,
    PersonRoleTypes.family,
    PersonRoleTypes.friend,
    PersonRoleTypes.studyMember,
    PersonRoleTypes.client,
    PersonRoleTypes.student,
    PersonRoleTypes.instructor,
    PersonRoleTypes.practiceParticipant,
    PersonRoleTypes.other,
  ];

  static const labels = <String, String>{
    PersonRoleTypes.self: '나',
    PersonRoleTypes.family: '가족',
    PersonRoleTypes.friend: '친구',
    PersonRoleTypes.studyMember: '스터디 회원',
    PersonRoleTypes.client: '상담 대상',
    PersonRoleTypes.student: '수강생',
    PersonRoleTypes.instructor: '강사',
    PersonRoleTypes.practiceParticipant: '수련 참여자',
    PersonRoleTypes.other: '기타',
  };

  static String labelFor(String? roleType) => labels[roleType] ?? '역할 미등록';
}

typedef PeopleIdFactory = String Function(String prefix);

final class PeopleController extends ChangeNotifier {
  factory PeopleController({
    required PersonRepository peopleRepository,
    required PersonRoleRepository roleRepository,
    required PersonGroupRepository groupRepository,
    DateTime Function()? now,
    PeopleIdFactory? idFactory,
  }) => PeopleController._(
    peopleRepository,
    roleRepository,
    groupRepository,
    now ?? DateTime.now,
    idFactory,
  );

  PeopleController._(
    this._peopleRepository,
    this._roleRepository,
    this._groupRepository,
    this._now,
    this._idFactory,
  );

  final PersonRepository _peopleRepository;
  final PersonRoleRepository _roleRepository;
  final PersonGroupRepository _groupRepository;
  final DateTime Function() _now;
  final PeopleIdFactory? _idFactory;

  StreamSubscription<List<Person>>? _peopleSubscription;
  StreamSubscription<List<PersonGroup>>? _activeGroupsSubscription;
  StreamSubscription<List<PersonGroup>>? _archivedGroupsSubscription;
  final Map<String, StreamSubscription<List<PersonRole>>> _roleSubscriptions =
      {};
  final Map<String, StreamSubscription<List<PersonGroupMembership>>>
  _membershipSubscriptions = {};
  final Map<String, List<PersonRole>> _rolesByPerson = {};
  final Map<String, List<PersonGroupMembership>> _membershipsByPerson = {};
  List<Person> _people = const [];
  List<PersonGroup> _activeGroups = const [];
  List<PersonGroup> _archivedGroups = const [];
  PeopleLoadState _state = PeopleLoadState.loading;
  String? _selectedPersonId;
  String? _errorMessage;
  bool _showArchived = false;
  bool _operationInProgress = false;
  String _searchQuery = '';
  String? _primaryRoleFilter;
  String? _selectedGroupFilter;
  int _idSerial = 0;

  PeopleLoadState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get showingArchived => _showArchived;
  bool get operationInProgress => _operationInProgress;
  String get searchQuery => _searchQuery;
  String? get primaryRoleFilter => _primaryRoleFilter;
  String? get selectedGroupFilter => _selectedGroupFilter;
  List<PersonGroup> get activeGroups => List.unmodifiable(_activeGroups);
  List<PersonGroup> get archivedGroups => List.unmodifiable(_archivedGroups);
  List<Person> get activePeople => _people
      .where((person) => person.archivedAt == null)
      .toList(growable: false);
  List<Person> get archivedPeople => _people
      .where((person) => person.archivedAt != null)
      .toList(growable: false);
  List<Person> get lanePeople => _showArchived ? archivedPeople : activePeople;
  List<Person> get visiblePeople => lanePeople
      .where(_matchesPrimaryRole)
      .where(_matchesGroup)
      .where(_matchesSearch)
      .toList(growable: false);
  int get resultCount => visiblePeople.length;
  bool get hasPeopleInCurrentLane => lanePeople.isNotEmpty;

  Person? get selectedPerson {
    final selectedId = _selectedPersonId;
    if (selectedId == null) return null;
    for (final person in _people) {
      if (person.id == selectedId) return person;
    }
    return null;
  }

  void start() {
    if (_peopleSubscription != null) return;
    _state = PeopleLoadState.loading;
    notifyListeners();
    _peopleSubscription = _peopleRepository
        .watchPeople(includeArchived: true)
        .listen(_acceptPeople, onError: _acceptStreamFailure);
    _activeGroupsSubscription = _groupRepository.watchActiveGroups().listen(
      _acceptActiveGroups,
      onError: (_) => _acceptGroupStreamFailure(),
    );
    _archivedGroupsSubscription = _groupRepository.watchArchivedGroups().listen(
      _acceptArchivedGroups,
      onError: (_) => _acceptGroupStreamFailure(),
    );
  }

  void _acceptPeople(List<Person> people) {
    _people = [...people]
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    _state = PeopleLoadState.ready;
    _syncRoleSubscriptions();
    _syncMembershipSubscriptions();
    _keepSelectionVisible();
    notifyListeners();
  }

  void _acceptStreamFailure(Object _) {
    _state = PeopleLoadState.failure;
    _errorMessage = '사람 기록을 불러오지 못했습니다. 다시 시도해 주세요.';
    notifyListeners();
  }

  void _acceptActiveGroups(List<PersonGroup> groups) {
    _activeGroups = [...groups]
      ..sort((left, right) => left.name.compareTo(right.name));
    final filter = _selectedGroupFilter;
    if (filter != null && !_activeGroups.any((group) => group.id == filter)) {
      _selectedGroupFilter = null;
    }
    _keepSelectionVisible();
    notifyListeners();
  }

  void _acceptArchivedGroups(List<PersonGroup> groups) {
    _archivedGroups = [...groups]
      ..sort((left, right) => left.name.compareTo(right.name));
    notifyListeners();
  }

  void _acceptGroupStreamFailure() {
    _errorMessage = '그룹 기록을 불러오지 못했습니다. 다시 시도해 주세요.';
    notifyListeners();
  }

  void _syncRoleSubscriptions() {
    final personIds = _people.map((person) => person.id).toSet();
    for (final id in _roleSubscriptions.keys.toList()) {
      if (!personIds.contains(id)) {
        unawaited(_roleSubscriptions.remove(id)?.cancel());
        _rolesByPerson.remove(id);
      }
    }
    for (final id in personIds) {
      if (_roleSubscriptions.containsKey(id)) continue;
      _roleSubscriptions[id] = _roleRepository
          .watchRolesForPerson(id)
          .listen(
            (roles) {
              _rolesByPerson[id] = roles;
              _keepSelectionVisible();
              notifyListeners();
            },
            onError: (_) {
              _errorMessage = '역할 기록을 불러오지 못했습니다. 다시 시도해 주세요.';
              notifyListeners();
            },
          );
    }
  }

  void _syncMembershipSubscriptions() {
    final personIds = _people.map((person) => person.id).toSet();
    for (final id in _membershipSubscriptions.keys.toList()) {
      if (!personIds.contains(id)) {
        unawaited(_membershipSubscriptions.remove(id)?.cancel());
        _membershipsByPerson.remove(id);
      }
    }
    for (final id in personIds) {
      if (_membershipSubscriptions.containsKey(id)) continue;
      _membershipSubscriptions[id] = _groupRepository
          .watchMembershipsForPerson(id)
          .listen((memberships) {
            _membershipsByPerson[id] = memberships;
            _keepSelectionVisible();
            notifyListeners();
          }, onError: (_) => _acceptGroupStreamFailure());
    }
  }

  void _keepSelectionVisible() {
    final visibleIds = visiblePeople.map((person) => person.id).toSet();
    if (_selectedPersonId == null || !visibleIds.contains(_selectedPersonId)) {
      _selectedPersonId = visiblePeople.firstOrNull?.id;
    }
  }

  List<PersonRole> activeRolesFor(String personId) =>
      (_rolesByPerson[personId] ?? const [])
          .where((role) => role.effectiveTo == null)
          .toList(growable: false);

  String? primaryRoleFor(String personId) {
    final activeTypes = activeRolesFor(
      personId,
    ).map((role) => role.roleType).toSet();
    for (final roleType in PeopleRoleCatalog.orderedTypes) {
      if (activeTypes.contains(roleType)) return roleType;
    }
    return null;
  }

  List<PersonGroupMembership> membershipsForPerson(String personId) =>
      List.unmodifiable(_membershipsByPerson[personId] ?? const []);

  List<PersonGroup> groupsForPerson(String personId) {
    final groupIds = membershipsForPerson(
      personId,
    ).map((membership) => membership.groupId).toSet();
    return _activeGroups
        .where((group) => groupIds.contains(group.id))
        .toList(growable: false);
  }

  int peopleCountForGroup(String groupId) => _membershipsByPerson.values
      .where(
        (memberships) =>
            memberships.any((membership) => membership.groupId == groupId),
      )
      .length;

  bool _matchesPrimaryRole(Person person) {
    final filter = _primaryRoleFilter;
    return filter == null || primaryRoleFor(person.id) == filter;
  }

  bool _matchesGroup(Person person) {
    final filter = _selectedGroupFilter;
    return filter == null ||
        membershipsForPerson(
          person.id,
        ).any((membership) => membership.groupId == filter);
  }

  bool _matchesSearch(Person person) {
    final query = _searchQuery.toLowerCase();
    if (query.isEmpty) return true;
    final relationship = person.relationshipSummary?.toLowerCase() ?? '';
    final roleLabel = PeopleRoleCatalog.labelFor(
      primaryRoleFor(person.id),
    ).toLowerCase();
    final groupNames = groupsForPerson(
      person.id,
    ).map((group) => group.name.toLowerCase());
    return person.displayName.toLowerCase().contains(query) ||
        relationship.contains(query) ||
        roleLabel.contains(query) ||
        groupNames.any((name) => name.contains(query));
  }

  void selectPerson(String personId) {
    if (_selectedPersonId == personId) return;
    _selectedPersonId = personId;
    notifyListeners();
  }

  void showArchived(bool value) {
    if (_showArchived == value) return;
    _showArchived = value;
    _keepSelectionVisible();
    notifyListeners();
  }

  void updateSearchQuery(String value) {
    final query = value.trim();
    if (_searchQuery == query) return;
    _searchQuery = query;
    _keepSelectionVisible();
    notifyListeners();
  }

  void updatePrimaryRoleFilter(String? roleType) {
    if (roleType != null && !PersonRoleTypes.values.contains(roleType)) return;
    if (_primaryRoleFilter == roleType) return;
    _primaryRoleFilter = roleType;
    _keepSelectionVisible();
    notifyListeners();
  }

  void updateGroupFilter(String? groupId) {
    if (groupId != null && !_activeGroups.any((group) => group.id == groupId)) {
      return;
    }
    if (_selectedGroupFilter == groupId) return;
    _selectedGroupFilter = groupId;
    _keepSelectionVisible();
    notifyListeners();
  }

  void clearFilters() {
    if (_searchQuery.isEmpty &&
        _primaryRoleFilter == null &&
        _selectedGroupFilter == null) {
      return;
    }
    _searchQuery = '';
    _primaryRoleFilter = null;
    _selectedGroupFilter = null;
    _keepSelectionVisible();
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> stop() async {
    await _peopleSubscription?.cancel();
    _peopleSubscription = null;
    await _activeGroupsSubscription?.cancel();
    _activeGroupsSubscription = null;
    await _archivedGroupsSubscription?.cancel();
    _archivedGroupsSubscription = null;
    for (final subscription in _roleSubscriptions.values) {
      await subscription.cancel();
    }
    _roleSubscriptions.clear();
    for (final subscription in _membershipSubscriptions.values) {
      await subscription.cancel();
    }
    _membershipSubscriptions.clear();
  }

  Future<bool> createGroup(String name) async {
    _setOperation(true);
    final at = _now().toUtc();
    final trimmed = name.trim();
    final result = await _groupRepository.createGroup(
      PersonGroup(
        id: _nextId('person-group'),
        name: trimmed,
        normalizedName: normalizePersonGroupName(trimmed),
        createdAt: at,
        updatedAt: at,
      ),
    );
    if (result.isFailure) {
      _setGroupRepositoryFailure(result.error!);
      return false;
    }
    _upsertLocalGroup(result.value!);
    _setOperation(false);
    return true;
  }

  Future<bool> renameGroup(String groupId, String name) async {
    _setOperation(true);
    final result = await _groupRepository.renameGroup(
      groupId,
      name: name,
      updatedAt: _now().toUtc(),
    );
    if (result.isFailure) {
      _setGroupRepositoryFailure(result.error!);
      return false;
    }
    _upsertLocalGroup(result.value!);
    _setOperation(false);
    return true;
  }

  Future<bool> archiveGroup(String groupId) async {
    _setOperation(true);
    final result = await _groupRepository.archiveGroup(
      groupId,
      at: _now().toUtc(),
    );
    if (result.isFailure) {
      _setGroupRepositoryFailure(result.error!);
      return false;
    }
    _upsertLocalGroup(result.value!);
    if (_selectedGroupFilter == groupId) _selectedGroupFilter = null;
    _keepSelectionVisible();
    _setOperation(false);
    return true;
  }

  Future<bool> restoreGroup(String groupId) async {
    _setOperation(true);
    final result = await _groupRepository.restoreGroup(
      groupId,
      at: _now().toUtc(),
    );
    if (result.isFailure) {
      _setGroupRepositoryFailure(result.error!);
      return false;
    }
    _upsertLocalGroup(result.value!);
    _setOperation(false);
    return true;
  }

  Future<bool> assignSelectedToGroup(String groupId) async {
    final person = selectedPerson;
    if (person == null || person.archivedAt != null) return false;
    _setOperation(true);
    final result = await _groupRepository.assignPerson(
      groupId: groupId,
      personId: person.id,
      createdAt: _now().toUtc(),
    );
    if (result.isFailure) {
      _setGroupRepositoryFailure(result.error!);
      return false;
    }
    final memberships = _membershipsByPerson[person.id] ?? const [];
    _membershipsByPerson[person.id] = [
      for (final membership in memberships)
        if (membership.groupId != groupId) membership,
      result.value!,
    ];
    _keepSelectionVisible();
    _setOperation(false);
    return true;
  }

  Future<bool> removeSelectedFromGroup(String groupId) async {
    final person = selectedPerson;
    if (person == null) return false;
    _setOperation(true);
    final result = await _groupRepository.removePerson(
      groupId: groupId,
      personId: person.id,
    );
    if (result.isFailure) {
      _setGroupRepositoryFailure(result.error!);
      return false;
    }
    _membershipsByPerson[person.id] =
        (_membershipsByPerson[person.id] ?? const [])
            .where((membership) => membership.groupId != groupId)
            .toList(growable: false);
    _keepSelectionVisible();
    _setOperation(false);
    return true;
  }

  Future<bool> createPerson({
    required String displayName,
    Set<String> roleTypes = const {},
    String? relationshipSummary,
    DateTime? firstMetOn,
  }) async {
    final name = displayName.trim();
    final summary = relationshipSummary?.trim();
    if (name.isEmpty || !roleTypes.every(PersonRoleTypes.values.contains)) {
      _setFailure('입력한 내용을 다시 확인해 주세요.');
      return false;
    }

    _setOperation(true);
    final at = _now().toUtc();
    final person = Person(
      id: _nextId('person'),
      displayName: name,
      status: PersonStatuses.active,
      relationshipSummary: summary == null || summary.isEmpty ? null : summary,
      firstMetOn: firstMetOn,
      createdAt: at,
      updatedAt: at,
    );
    final personResult = await _peopleRepository.createPerson(person);
    if (personResult.isFailure) {
      _setRepositoryFailure(personResult.error!);
      return false;
    }

    final createdRoles = <PersonRole>[];
    for (final roleType in roleTypes) {
      final role = PersonRole(
        id: _nextId('role.$roleType'),
        personId: person.id,
        roleType: roleType,
        effectiveFrom: at,
        createdAt: at,
        updatedAt: at,
      );
      final roleResult = await _roleRepository.addRole(role);
      if (roleResult.isFailure) {
        await _peopleRepository.erasePerson(person.id);
        _removeLocalPerson(person.id);
        _setRepositoryFailure(roleResult.error!);
        return false;
      }
      createdRoles.add(roleResult.value!);
    }

    _upsertLocalPerson(personResult.value!);
    _rolesByPerson[person.id] = createdRoles;
    _showArchived = false;
    _selectedPersonId = person.id;
    _keepSelectionVisible();
    _setOperation(false);
    return true;
  }

  Future<bool> archiveSelected() async {
    final person = selectedPerson;
    if (person == null || person.archivedAt != null) return false;
    _setOperation(true);
    final result = await _peopleRepository.archivePerson(
      person.id,
      at: _now().toUtc(),
    );
    if (result.isFailure) {
      _setRepositoryFailure(result.error!);
      return false;
    }
    _upsertLocalPerson(result.value!);
    _keepSelectionVisible();
    _setOperation(false);
    return true;
  }

  Future<bool> restoreSelected() async {
    final person = selectedPerson;
    if (person == null || person.archivedAt == null) return false;
    _setOperation(true);
    final result = await _peopleRepository.restorePerson(
      person.id,
      at: _now().toUtc(),
    );
    if (result.isFailure) {
      _setRepositoryFailure(result.error!);
      return false;
    }
    _upsertLocalPerson(result.value!);
    _showArchived = false;
    _selectedPersonId = person.id;
    _keepSelectionVisible();
    _setOperation(false);
    return true;
  }

  void _upsertLocalPerson(Person person) {
    _people = [
      for (final existing in _people)
        if (existing.id != person.id) existing,
      person,
    ]..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
  }

  void _upsertLocalGroup(PersonGroup group) {
    _activeGroups = [
      for (final existing in _activeGroups)
        if (existing.id != group.id) existing,
      if (group.archivedAt == null) group,
    ]..sort((left, right) => left.name.compareTo(right.name));
    _archivedGroups = [
      for (final existing in _archivedGroups)
        if (existing.id != group.id) existing,
      if (group.archivedAt != null) group,
    ]..sort((left, right) => left.name.compareTo(right.name));
  }

  void _removeLocalPerson(String id) {
    _people = _people
        .where((person) => person.id != id)
        .toList(growable: false);
    _rolesByPerson.remove(id);
    unawaited(_roleSubscriptions.remove(id)?.cancel());
    _membershipsByPerson.remove(id);
    unawaited(_membershipSubscriptions.remove(id)?.cancel());
  }

  String _nextId(String prefix) {
    final custom = _idFactory;
    if (custom != null) return custom(prefix);
    final micros = _now().toUtc().microsecondsSinceEpoch;
    return '$prefix.$micros.${_idSerial++}';
  }

  void _setOperation(bool value) {
    _operationInProgress = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }

  void _setFailure(String message) {
    _operationInProgress = false;
    _errorMessage = message;
    notifyListeners();
  }

  void _setRepositoryFailure(RepositoryError error) {
    final message = switch (error.code) {
      RepositoryErrorCode.validationFailed => '입력한 내용을 다시 확인해 주세요.',
      RepositoryErrorCode.conflict => '이미 같은 상태의 역할이 등록되어 있습니다.',
      RepositoryErrorCode.notFound => '사람 기록을 찾을 수 없습니다.',
      _ => '사람 기록을 저장하지 못했습니다. 다시 시도해 주세요.',
    };
    _setFailure(message);
  }

  void _setGroupRepositoryFailure(RepositoryError error) {
    final message = switch (error.code) {
      RepositoryErrorCode.validationFailed => '그룹 이름과 상태를 다시 확인해 주세요.',
      RepositoryErrorCode.conflict => '이미 같은 이름의 그룹이 있습니다.',
      RepositoryErrorCode.notFound => '그룹 또는 사람 기록을 찾을 수 없습니다.',
      _ => '그룹 기록을 저장하지 못했습니다. 다시 시도해 주세요.',
    };
    _setFailure(message);
  }

  @override
  void dispose() {
    unawaited(_peopleSubscription?.cancel());
    unawaited(_activeGroupsSubscription?.cancel());
    unawaited(_archivedGroupsSubscription?.cancel());
    for (final subscription in _roleSubscriptions.values) {
      unawaited(subscription.cancel());
    }
    _roleSubscriptions.clear();
    for (final subscription in _membershipSubscriptions.values) {
      unawaited(subscription.cancel());
    }
    _membershipSubscriptions.clear();
    super.dispose();
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
