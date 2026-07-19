import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/features/people/data/persistence/drift_person_core_repositories.dart';
import 'package:ryn_universe_os_core/features/people/domain/person_core_models.dart';

void main() {
  late RynAppDatabase database;
  late DriftPersonRepository people;
  late DriftPersonRoleRepository roles;
  late DriftPersonRelationshipRepository relationships;
  late DriftPersonBirthProfileRepository birthProfiles;
  late DriftEncounterRepository encounters;
  late DriftEncounterNoteRepository notes;

  final createdAt = DateTime.utc(2026, 7, 19, 1);

  setUp(() {
    database = RynAppDatabase(NativeDatabase.memory());
    people = DriftPersonRepository(database);
    roles = DriftPersonRoleRepository(database);
    relationships = DriftPersonRelationshipRepository(database);
    birthProfiles = DriftPersonBirthProfileRepository(database);
    encounters = DriftEncounterRepository(database);
    notes = DriftEncounterNoteRepository(database);
  });

  tearDown(() => database.close());

  Person syntheticPerson(String id, String name) => Person(
    id: id,
    displayName: name,
    status: PersonStatuses.active,
    createdAt: createdAt,
    updatedAt: createdAt,
  );

  test(
    'Person create watch update archive restore and erase are durable',
    () async {
      final person = syntheticPerson('person.synthetic.self', '합성 인물 A');
      expect((await people.createPerson(person)).isSuccess, isTrue);
      expect((await people.getPerson(person.id)).value?.displayName, '합성 인물 A');
      expect(await people.watchPeople().first, hasLength(1));

      final updated = person.copyWith(
        displayName: '합성 인물 A 수정',
        relationshipSummary: 'SYNTHETIC_RELATIONSHIP',
        updatedAt: createdAt.add(const Duration(minutes: 1)),
      );
      expect((await people.updatePerson(updated)).isSuccess, isTrue);
      expect(
        (await people.archivePerson(
          person.id,
          at: createdAt.add(const Duration(minutes: 2)),
        )).value?.archivedAt,
        isNotNull,
      );
      expect(await people.watchPeople().first, isEmpty);
      expect(
        (await people.restorePerson(
          person.id,
          at: createdAt.add(const Duration(minutes: 3)),
        )).value?.archivedAt,
        isNull,
      );

      expect((await people.erasePerson(person.id)).value, isTrue);
      expect((await people.getPerson(person.id)).error?.code.name, 'notFound');
    },
  );

  test(
    'Person erasure cascades owned records and preserves the other Person',
    () async {
      final person = syntheticPerson('person.synthetic.erase.01', '합성 인물 A');
      final other = syntheticPerson('person.synthetic.other.01', '합성 인물 B');
      await people.createPerson(person);
      await people.createPerson(other);
      await roles.addRole(
        PersonRole(
          id: 'role.synthetic.erase.01',
          personId: person.id,
          roleType: PersonRoleTypes.friend,
          effectiveFrom: createdAt,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
      await relationships.createRelationship(
        PersonRelationship(
          id: 'relationship.synthetic.erase.01',
          fromPersonId: person.id,
          toPersonId: other.id,
          relationshipType: 'friendOf',
          effectiveFrom: createdAt,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
      await birthProfiles.createInitialProfile(
        PersonBirthProfile(
          id: 'birth.synthetic.erase.01',
          personId: person.id,
          revisionNumber: 1,
          birthDatePrecision: BirthPrecisions.unknown,
          birthTimePrecision: BirthPrecisions.unknown,
          calendarSystem: BirthCalendarSystems.unknown,
          verificationState: BirthVerificationStates.unverified,
          createdAt: createdAt,
        ),
      );
      final encounter = Encounter(
        id: 'encounter.synthetic.erase.01',
        personId: person.id,
        occurredAt: createdAt,
        occurredPrecision: EncounterPrecisions.exact,
        encounterType: EncounterTypes.studyMeeting,
        title: 'SYNTHETIC_ENCOUNTER',
        status: EncounterStatuses.completed,
        createdAt: createdAt,
        updatedAt: createdAt,
      );
      await encounters.createEncounter(encounter);
      await notes.addNote(
        EncounterNote(
          id: 'note.synthetic.erase.01',
          encounterId: encounter.id,
          noteType: EncounterNoteTypes.ownerObservation,
          body: 'SYNTHETIC_PERSON_NOTE',
          recordedAt: createdAt,
          updatedAt: createdAt,
        ),
      );

      final erased = await people.erasePerson(person.id);

      expect(erased.value, isTrue);
      expect((await people.getPerson(person.id)).isFailure, isTrue);
      expect((await people.getPerson(other.id)).value?.id, other.id);
      for (final table in const <String>[
        'person_roles',
        'person_relationships',
        'person_birth_profiles',
        'encounters',
        'encounter_notes',
      ]) {
        final row = await database
            .customSelect('SELECT count(*) AS total FROM $table')
            .getSingle();
        expect(row.read<int>('total'), 0, reason: table);
      }
    },
  );

  test(
    'active roles reject duplicates and allow only one active self Person',
    () async {
      final first = syntheticPerson('person.synthetic.self', '합성 인물 A');
      final second = syntheticPerson('person.synthetic.study.01', '합성 인물 B');
      await people.createPerson(first);
      await people.createPerson(second);

      final selfRole = PersonRole(
        id: 'role.synthetic.self.01',
        personId: first.id,
        roleType: PersonRoleTypes.self,
        effectiveFrom: createdAt,
        createdAt: createdAt,
        updatedAt: createdAt,
      );
      expect((await roles.addRole(selfRole)).isSuccess, isTrue);
      expect((await people.findActiveSelfPerson()).value?.id, first.id);
      expect(
        (await roles.addRole(
          selfRole.copyWith(id: 'role.synthetic.self.duplicate'),
        )).error?.code.name,
        'conflict',
      );
      expect(
        (await roles.addRole(
          selfRole.copyWith(
            id: 'role.synthetic.self.other',
            personId: second.id,
          ),
        )).error?.code.name,
        'conflict',
      );

      expect(
        (await roles.closeRole(
          selfRole.id,
          effectiveTo: createdAt.add(const Duration(days: 1)),
          updatedAt: createdAt.add(const Duration(days: 1)),
        )).isSuccess,
        isTrue,
      );
      expect(
        (await roles.addRole(
          selfRole.copyWith(
            id: 'role.synthetic.self.other',
            personId: second.id,
            effectiveFrom: createdAt.add(const Duration(days: 2)),
            updatedAt: createdAt.add(const Duration(days: 2)),
          ),
        )).isSuccess,
        isTrue,
      );
    },
  );

  test(
    'relationship rejects self-reference and closes one directional record',
    () async {
      final first = syntheticPerson('person.synthetic.self', '합성 인물 A');
      final second = syntheticPerson('person.synthetic.study.01', '합성 인물 B');
      await people.createPerson(first);
      await people.createPerson(second);

      final invalid = PersonRelationship(
        id: 'relationship.synthetic.invalid',
        fromPersonId: first.id,
        toPersonId: first.id,
        relationshipType: 'friendOf',
        effectiveFrom: createdAt,
        createdAt: createdAt,
        updatedAt: createdAt,
      );
      expect(
        (await relationships.createRelationship(invalid)).isFailure,
        isTrue,
      );

      final valid = invalid.copyWith(
        id: 'relationship.synthetic.01',
        toPersonId: second.id,
      );
      expect((await relationships.createRelationship(valid)).isSuccess, isTrue);
      expect(
        await relationships.watchRelationshipsForPerson(first.id).first,
        hasLength(1),
      );
      expect(
        (await relationships.closeRelationship(
          valid.id,
          effectiveTo: createdAt.add(const Duration(days: 1)),
          updatedAt: createdAt.add(const Duration(days: 1)),
        )).value?.effectiveTo,
        isNotNull,
      );
    },
  );

  test(
    'birth correction appends a revision and supersedes without overwrite',
    () async {
      final person = syntheticPerson('person.synthetic.self', '합성 인물 A');
      await people.createPerson(person);
      final initial = PersonBirthProfile(
        id: 'birth.synthetic.01',
        personId: person.id,
        revisionNumber: 1,
        birthDate: '2000-01-01',
        birthDatePrecision: BirthPrecisions.approximate,
        birthTimePrecision: BirthPrecisions.unknown,
        calendarSystem: BirthCalendarSystems.solar,
        verificationState: BirthVerificationStates.unverified,
        createdAt: createdAt,
      );
      expect(
        (await birthProfiles.createInitialProfile(
          initial.copyWith(
            id: 'birth.synthetic.invalid.initial',
            supersededAt: createdAt.add(const Duration(minutes: 1)),
          ),
        )).isFailure,
        isTrue,
      );
      expect(
        (await birthProfiles.createInitialProfile(initial)).isSuccess,
        isTrue,
      );

      final revision = initial.copyWith(
        id: 'birth.synthetic.02',
        revisionNumber: 2,
        birthDatePrecision: BirthPrecisions.exact,
        supersedesBirthProfileId: initial.id,
        createdAt: createdAt.add(const Duration(days: 1)),
      );
      expect(
        (await birthProfiles.createRevision(
          revision.copyWith(
            id: 'birth.synthetic.invalid.revision',
            supersededAt: createdAt.add(const Duration(days: 2)),
          ),
        )).isFailure,
        isTrue,
      );
      expect(
        (await birthProfiles.getCurrentProfile(person.id)).value?.id,
        initial.id,
      );
      expect((await birthProfiles.createRevision(revision)).isSuccess, isTrue);
      expect(
        (await birthProfiles.getCurrentProfile(person.id)).value?.id,
        revision.id,
      );
      final history = await birthProfiles.watchProfileHistory(person.id).first;
      expect(history, hasLength(2));
      expect(history.first.supersededAt, isNotNull);
      expect(history.first.birthDatePrecision, BirthPrecisions.approximate);
    },
  );

  test(
    'Encounter and typed notes support archive typo revision and redaction',
    () async {
      final person = syntheticPerson('person.synthetic.self', '합성 인물 A');
      await people.createPerson(person);
      final encounter = Encounter(
        id: 'encounter.synthetic.01',
        personId: person.id,
        occurredAt: createdAt,
        occurredPrecision: EncounterPrecisions.exact,
        encounterType: EncounterTypes.selfReview,
        title: 'SYNTHETIC_ENCOUNTER',
        status: EncounterStatuses.completed,
        createdAt: createdAt,
        updatedAt: createdAt,
      );
      expect((await encounters.createEncounter(encounter)).isSuccess, isTrue);
      expect(
        await encounters.watchEncountersForPerson(person.id).first,
        hasLength(1),
      );

      final note = EncounterNote(
        id: 'note.synthetic.01',
        encounterId: encounter.id,
        noteType: EncounterNoteTypes.ownerObservation,
        body: 'SYNTHETIC_PERSON_NOTE',
        recordedAt: createdAt,
        updatedAt: createdAt,
      );
      expect(
        (await notes.addNote(
          note.copyWith(
            id: 'note.synthetic.invalid.initial',
            supersededAt: createdAt.add(const Duration(minutes: 1)),
          ),
        )).isFailure,
        isTrue,
      );
      expect((await notes.addNote(note)).isSuccess, isTrue);
      expect(
        (await notes.correctTypo(
          note.id,
          body: 'SYNTHETIC_PERSON_NOTE_FIXED',
          updatedAt: createdAt.add(const Duration(minutes: 1)),
        )).value?.body,
        'SYNTHETIC_PERSON_NOTE_FIXED',
      );

      final revision = note.copyWith(
        id: 'note.synthetic.02',
        body: 'SYNTHETIC_PERSON_NOTE_REVISED',
        supersedesNoteId: note.id,
        recordedAt: createdAt.add(const Duration(minutes: 2)),
        updatedAt: createdAt.add(const Duration(minutes: 2)),
      );
      expect(
        (await notes.createRevision(
          revision.copyWith(
            id: 'note.synthetic.invalid.revision',
            supersededAt: createdAt.add(const Duration(minutes: 3)),
          ),
        )).isFailure,
        isTrue,
      );
      expect((await notes.createRevision(revision)).isSuccess, isTrue);
      final history = await notes.watchNotesForEncounter(encounter.id).first;
      expect(history, hasLength(2));
      expect(history.first.supersededAt, isNotNull);
      expect(
        (await notes.redactNote(
          revision.id,
          at: createdAt.add(const Duration(minutes: 3)),
        )).value?.body,
        isEmpty,
      );
      final redactedHistory = await notes
          .watchNotesForEncounter(encounter.id)
          .first;
      expect(redactedHistory.every((item) => item.body.isEmpty), isTrue);
      expect(redactedHistory.every((item) => item.redactedAt != null), isTrue);

      expect(
        (await encounters.archiveEncounter(
          encounter.id,
          at: createdAt.add(const Duration(minutes: 4)),
        )).value?.archivedAt,
        isNotNull,
      );
      expect(
        await encounters.watchEncountersForPerson(person.id).first,
        isEmpty,
      );
    },
  );
}
