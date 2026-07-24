import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/core/runtime/ryn_runtime_services.dart';
import 'package:ryn_universe_os_core/features/people/application/people_controller.dart';
import 'package:ryn_universe_os_core/features/people/domain/person_core_models.dart';

void main() {
  late RynAppDatabase database;
  late RynRuntimeServices services;
  final now = DateTime.utc(2026, 7, 20, 9);

  setUp(() {
    database = RynAppDatabase(NativeDatabase.memory());
    services = RynRuntimeServices(database);
  });

  tearDown(() => database.close());

  Future<void> settleController(PeopleController controller) async {
    for (var attempt = 0; attempt < 30; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      if (controller.state != PeopleLoadState.loading) return;
    }
  }

  Future<PeopleController> readyController() async {
    var serial = 0;
    final controller = PeopleController(
      peopleRepository: services.people,
      roleRepository: services.personRoles,
      groupRepository: services.personGroups,
      now: () => now,
      idFactory: (prefix) => '$prefix.filter.${serial++}',
    );
    addTearDown(controller.dispose);
    controller.start();
    await settleController(controller);
    return controller;
  }

  Future<void> createSynthetic(
    PeopleController controller, {
    required String name,
    String? relationship,
    Set<String> roles = const {},
  }) async {
    expect(
      await controller.createPerson(
        displayName: name,
        relationshipSummary: relationship,
        roleTypes: roles,
      ),
      isTrue,
    );
  }

  test('blank query returns all people in the current archive lane', () async {
    final controller = await readyController();
    await createSynthetic(controller, name: '합성 인물 A');
    await createSynthetic(controller, name: '합성 인물 B');

    controller.updateSearchQuery('   ');

    expect(controller.visiblePeople, hasLength(2));
    expect(controller.resultCount, 2);
  });

  test('search matches display name', () async {
    final controller = await readyController();
    await createSynthetic(controller, name: '합성 인물 가람');
    await createSynthetic(controller, name: '합성 인물 누리');

    controller.updateSearchQuery('가람');

    expect(controller.visiblePeople.single.displayName, '합성 인물 가람');
  });

  test('search matches relationship context', () async {
    final controller = await readyController();
    await createSynthetic(
      controller,
      name: '합성 인물 A',
      relationship: '함께 공부하는 사람',
    );
    await createSynthetic(controller, name: '합성 인물 B', relationship: '오래된 이웃');

    controller.updateSearchQuery('공부');

    expect(controller.visiblePeople.single.displayName, '합성 인물 A');
  });

  test('search matches the primary role label', () async {
    final controller = await readyController();
    await createSynthetic(
      controller,
      name: '합성 인물 A',
      roles: const {PersonRoleTypes.studyMember},
    );
    await createSynthetic(
      controller,
      name: '합성 인물 B',
      roles: const {PersonRoleTypes.friend},
    );

    controller.updateSearchQuery('스터디 회원');

    expect(controller.visiblePeople.single.displayName, '합성 인물 A');
  });

  test('primary role filter returns only matching people', () async {
    final controller = await readyController();
    await createSynthetic(
      controller,
      name: '합성 가족',
      roles: const {PersonRoleTypes.family},
    );
    await createSynthetic(
      controller,
      name: '합성 친구',
      roles: const {PersonRoleTypes.friend},
    );

    controller.updatePrimaryRoleFilter(PersonRoleTypes.family);

    expect(controller.visiblePeople.single.displayName, '합성 가족');
    expect(
      controller.primaryRoleFor(controller.visiblePeople.single.id),
      PersonRoleTypes.family,
    );
  });

  test('search and primary role filter use intersection semantics', () async {
    final controller = await readyController();
    await createSynthetic(
      controller,
      name: '합성 친구 가람',
      roles: const {PersonRoleTypes.friend},
    );
    await createSynthetic(
      controller,
      name: '합성 가족 가람',
      roles: const {PersonRoleTypes.family},
    );

    controller
      ..updateSearchQuery('가람')
      ..updatePrimaryRoleFilter(PersonRoleTypes.friend);

    expect(controller.visiblePeople.single.displayName, '합성 친구 가람');
  });

  test('active and archived people remain separated while filtering', () async {
    final controller = await readyController();
    await createSynthetic(
      controller,
      name: '합성 가족 Active',
      roles: const {PersonRoleTypes.family},
    );
    await createSynthetic(
      controller,
      name: '합성 가족 Archived',
      roles: const {PersonRoleTypes.family},
    );
    expect(await controller.archiveSelected(), isTrue);

    controller.updatePrimaryRoleFilter(PersonRoleTypes.family);
    expect(controller.visiblePeople.single.displayName, '합성 가족 Active');

    controller.showArchived(true);
    expect(controller.visiblePeople.single.displayName, '합성 가족 Archived');
  });

  test('filtered selection falls back to the first visible person', () async {
    final controller = await readyController();
    await createSynthetic(
      controller,
      name: '합성 가족',
      roles: const {PersonRoleTypes.family},
    );
    await createSynthetic(
      controller,
      name: '합성 친구',
      roles: const {PersonRoleTypes.friend},
    );
    expect(controller.selectedPerson?.displayName, '합성 친구');

    controller.updatePrimaryRoleFilter(PersonRoleTypes.family);

    expect(controller.selectedPerson?.displayName, '합성 가족');
  });

  test('no-result state leaves stored people unchanged', () async {
    final controller = await readyController();
    await createSynthetic(controller, name: '합성 인물 A');
    await createSynthetic(controller, name: '합성 인물 B');
    final storedIds = controller.activePeople
        .map((person) => person.id)
        .toSet();

    controller.updateSearchQuery('일치하지 않는 합성 검색어');

    expect(controller.visiblePeople, isEmpty);
    expect(controller.selectedPerson, isNull);
    expect(
      controller.activePeople.map((person) => person.id).toSet(),
      storedIds,
    );
  });

  test(
    'creates durable Person with roles then archives restores and reboots',
    () async {
      final controller = PeopleController(
        peopleRepository: services.people,
        roleRepository: services.personRoles,
        groupRepository: services.personGroups,
        now: () => now,
        idFactory: (prefix) => '$prefix.synthetic.01',
      );
      addTearDown(controller.dispose);

      controller.start();
      await settleController(controller);
      expect(controller.state, PeopleLoadState.ready);
      expect(controller.activePeople, isEmpty);

      final created = await controller.createPerson(
        displayName: '  합성 인물 A  ',
        relationshipSummary: 'SYNTHETIC_RELATIONSHIP_NOTE',
        firstMetOn: DateTime.utc(2026, 7, 1),
        roleTypes: const {PersonRoleTypes.friend, PersonRoleTypes.studyMember},
      );
      expect(created, isTrue);
      await settleController(controller);

      expect(controller.selectedPerson?.displayName, '합성 인물 A');
      expect(controller.activePeople, hasLength(1));
      expect(
        controller
            .activeRolesFor(controller.selectedPerson!.id)
            .map((r) => r.roleType),
        containsAll([PersonRoleTypes.friend, PersonRoleTypes.studyMember]),
      );

      expect(await controller.archiveSelected(), isTrue);
      await settleController(controller);
      expect(controller.activePeople, isEmpty);
      expect(controller.archivedPeople.single.displayName, '합성 인물 A');

      controller.showArchived(true);
      controller.selectPerson(controller.archivedPeople.single.id);
      expect(await controller.restoreSelected(), isTrue);
      await settleController(controller);
      expect(controller.activePeople.single.displayName, '합성 인물 A');
      expect(controller.archivedPeople, isEmpty);

      await controller.stop();
      final reopened = PeopleController(
        peopleRepository: services.people,
        roleRepository: services.personRoles,
        groupRepository: services.personGroups,
      );
      addTearDown(reopened.dispose);
      reopened.start();
      await settleController(reopened);

      expect(reopened.activePeople.single.displayName, '합성 인물 A');
      expect(
        reopened
            .activeRolesFor(reopened.activePeople.single.id)
            .map((r) => r.roleType),
        containsAll([PersonRoleTypes.friend, PersonRoleTypes.studyMember]),
      );
    },
  );

  test(
    'maps duplicate active self conflict and rolls back partial Person',
    () async {
      final controller = PeopleController(
        peopleRepository: services.people,
        roleRepository: services.personRoles,
        groupRepository: services.personGroups,
        now: () => now,
        idFactory: (() {
          var serial = 0;
          return (String prefix) => '$prefix.synthetic.${serial++}';
        })(),
      );
      addTearDown(controller.dispose);
      controller.start();
      await settleController(controller);

      expect(
        await controller.createPerson(
          displayName: '합성 인물 Self',
          roleTypes: const {PersonRoleTypes.self},
        ),
        isTrue,
      );
      expect(
        await controller.createPerson(
          displayName: '합성 인물 Self 충돌',
          roleTypes: const {PersonRoleTypes.self},
        ),
        isFalse,
      );
      await settleController(controller);

      expect(controller.errorMessage, '이미 같은 상태의 역할이 등록되어 있습니다.');
      expect(
        (await services.people.watchPeople(includeArchived: true).first).map(
          (person) => person.displayName,
        ),
        isNot(contains('합성 인물 Self 충돌')),
      );
    },
  );

  test(
    'group commands persist multi-membership and search role group intersect',
    () async {
      final controller = await readyController();
      await createSynthetic(
        controller,
        name: '테스트 인물 001',
        roles: const {PersonRoleTypes.friend},
      );
      final firstId = controller.selectedPerson!.id;
      await createSynthetic(
        controller,
        name: '테스트 인물 002',
        roles: const {PersonRoleTypes.friend},
      );
      final secondId = controller.selectedPerson!.id;

      expect(await controller.createGroup('테스트 그룹 A'), isTrue);
      expect(await controller.createGroup('테스트 그룹 B'), isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final groupA = controller.activeGroups.firstWhere(
        (group) => group.name == '테스트 그룹 A',
      );
      final groupB = controller.activeGroups.firstWhere(
        (group) => group.name == '테스트 그룹 B',
      );

      controller.selectPerson(firstId);
      expect(await controller.assignSelectedToGroup(groupA.id), isTrue);
      expect(await controller.assignSelectedToGroup(groupB.id), isTrue);
      controller.selectPerson(secondId);
      expect(await controller.assignSelectedToGroup(groupB.id), isTrue);

      controller
        ..updateSearchQuery('테스트')
        ..updatePrimaryRoleFilter(PersonRoleTypes.friend)
        ..updateGroupFilter(groupA.id);
      expect(controller.visiblePeople.single.id, firstId);
      expect(controller.selectedPerson?.id, firstId);

      controller
        ..updateGroupFilter(null)
        ..updatePrimaryRoleFilter(null)
        ..updateSearchQuery('그룹 A');
      expect(controller.visiblePeople.single.id, firstId);

      controller
        ..updateSearchQuery('')
        ..updateGroupFilter(groupA.id);
      expect(await controller.archiveGroup(groupA.id), isTrue);
      expect(controller.selectedGroupFilter, isNull);
      expect(
        controller.activeGroups.map((group) => group.id),
        isNot(contains(groupA.id)),
      );
      expect(
        controller.archivedGroups.map((group) => group.id),
        contains(groupA.id),
      );
      expect(
        controller.groupsForPerson(firstId).map((group) => group.id),
        isNot(contains(groupA.id)),
      );

      expect(await controller.restoreGroup(groupA.id), isTrue);
      expect(
        controller.groupsForPerson(firstId).map((group) => group.id),
        contains(groupA.id),
      );
      controller.selectPerson(firstId);
      expect(await controller.removeSelectedFromGroup(groupB.id), isTrue);
      expect(
        controller.groupsForPerson(firstId).map((group) => group.id),
        isNot(contains(groupB.id)),
      );
    },
  );
}
