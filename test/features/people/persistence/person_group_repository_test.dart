import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/features/people/data/persistence/drift_person_group_repository.dart';
import 'package:ryn_universe_os_core/features/people/data/persistence/drift_person_core_repositories.dart';
import 'package:ryn_universe_os_core/features/people/domain/person_core_models.dart';

void main() {
  late RynAppDatabase database;
  late DriftPersonRepository people;
  late DriftPersonGroupRepository groups;
  final now = DateTime.utc(2026, 7, 22, 1);

  Person person(String id) => Person(
    id: id,
    displayName: id.endsWith('001') ? '테스트 인물 001' : '테스트 인물 002',
    status: PersonStatuses.active,
    createdAt: now,
    updatedAt: now,
  );

  PersonGroup group(String id, String name) => PersonGroup(
    id: id,
    name: name,
    normalizedName: normalizePersonGroupName(name),
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    database = RynAppDatabase(NativeDatabase.memory());
    people = DriftPersonRepository(database);
    groups = DriftPersonGroupRepository(database);
  });

  tearDown(() => database.close());

  test(
    'create trims name and rejects blank long and normalized duplicates',
    () async {
      expect(
        (await groups.createGroup(
          group('group.a', '  테스트   그룹 A  '),
        )).value?.name,
        '테스트 그룹 A',
      );
      expect(
        (await groups.createGroup(
          group('group.blank', '   '),
        )).error?.code.name,
        'validationFailed',
      );
      expect(
        (await groups.createGroup(
          group('group.long', '가' * 61),
        )).error?.code.name,
        'validationFailed',
      );
      expect(
        (await groups.createGroup(
          group('group.duplicate', '테스트 그룹 a'),
        )).error?.code.name,
        'conflict',
      );
      expect(
        (await groups.watchActiveGroups().first).single.normalizedName,
        '테스트 그룹 a',
      );
    },
  );

  test(
    'rename archive restore preserve membership and active archived watches',
    () async {
      await people.createPerson(person('person.001'));
      await groups.createGroup(group('group.a', '테스트 그룹 A'));
      expect(
        (await groups.assignPerson(
          groupId: 'group.a',
          personId: 'person.001',
          createdAt: now,
        )).isSuccess,
        isTrue,
      );

      final renamed = await groups.renameGroup(
        'group.a',
        name: '  테스트   그룹 B ',
        updatedAt: now.add(const Duration(minutes: 1)),
      );
      expect(renamed.value?.name, '테스트 그룹 B');
      expect(renamed.value?.updatedAt, now.add(const Duration(minutes: 1)));

      final archived = await groups.archiveGroup(
        'group.a',
        at: now.add(const Duration(minutes: 2)),
      );
      expect(archived.value?.archivedAt, isNotNull);
      expect(await groups.watchActiveGroups().first, isEmpty);
      expect(await groups.watchArchivedGroups().first, hasLength(1));
      expect(
        await groups.watchMembershipsForPerson('person.001').first,
        hasLength(1),
      );
      expect(
        (await groups.assignPerson(
          groupId: 'group.a',
          personId: 'person.001',
          createdAt: now,
        )).error?.code.name,
        'validationFailed',
      );

      final restored = await groups.restoreGroup(
        'group.a',
        at: now.add(const Duration(minutes: 3)),
      );
      expect(restored.value?.archivedAt, isNull);
      expect(await groups.watchActiveGroups().first, hasLength(1));
      expect(await groups.watchPeopleInGroup('group.a').first, hasLength(1));
    },
  );

  test(
    'one person can join multiple groups and duplicate assignment is idempotent',
    () async {
      await people.createPerson(person('person.001'));
      await groups.createGroup(group('group.a', '테스트 그룹 A'));
      await groups.createGroup(group('group.b', '테스트 그룹 B'));

      final first = await groups.assignPerson(
        groupId: 'group.a',
        personId: 'person.001',
        createdAt: now,
      );
      final duplicate = await groups.assignPerson(
        groupId: 'group.a',
        personId: 'person.001',
        createdAt: now.add(const Duration(minutes: 1)),
      );
      await groups.assignPerson(
        groupId: 'group.b',
        personId: 'person.001',
        createdAt: now,
      );

      expect(first.isSuccess, isTrue);
      expect(duplicate.isSuccess, isTrue);
      expect(
        await groups.watchMembershipsForPerson('person.001').first,
        hasLength(2),
      );
    },
  );

  test(
    'multiple people can join one group and absent removal is safe',
    () async {
      await people.createPerson(person('person.001'));
      await people.createPerson(person('person.002'));
      await groups.createGroup(group('group.a', '테스트 그룹 A'));
      await groups.assignPerson(
        groupId: 'group.a',
        personId: 'person.001',
        createdAt: now,
      );
      await groups.assignPerson(
        groupId: 'group.a',
        personId: 'person.002',
        createdAt: now,
      );

      expect(await groups.watchPeopleInGroup('group.a').first, hasLength(2));
      expect(
        (await groups.removePerson(
          groupId: 'group.a',
          personId: 'missing.person',
        )).value,
        isFalse,
      );
      expect(
        (await groups.removePerson(
          groupId: 'group.a',
          personId: 'person.001',
        )).value,
        isTrue,
      );
      expect(await groups.watchPeopleInGroup('group.a').first, hasLength(1));
    },
  );

  test(
    'missing references fail safely and database rejects orphan memberships',
    () async {
      await people.createPerson(person('person.001'));
      await groups.createGroup(group('group.a', '테스트 그룹 A'));

      expect(
        (await groups.assignPerson(
          groupId: 'missing.group',
          personId: 'person.001',
          createdAt: now,
        )).error?.code.name,
        'notFound',
      );
      expect(
        (await groups.assignPerson(
          groupId: 'group.a',
          personId: 'missing.person',
          createdAt: now,
        )).error?.code.name,
        'notFound',
      );
      await expectLater(
        database.customStatement(
          "INSERT INTO person_group_memberships (group_id, person_id, created_at_utc_us) VALUES ('missing.group', 'missing.person', 1)",
        ),
        throwsA(anything),
      );
    },
  );
}
