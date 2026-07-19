import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../../core/persistence/app_database.dart';
import '../../../../core/repositories/repository_result.dart';
import '../../domain/person_core_models.dart';
import '../../domain/person_core_repositories.dart';

final class DriftPersonRepository implements PersonRepository {
  DriftPersonRepository(this.database);
  final RynAppDatabase database;

  @override
  Future<RepositoryResult<Person>> createPerson(Person person) async {
    if (!_validPerson(person)) return _validation<Person>();
    return _write(() async {
      await database.into(database.persons).insert(_personCompanion(person));
      return person;
    });
  }

  @override
  Future<RepositoryResult<Person>> getPerson(String id) async {
    final row = await (database.select(
      database.persons,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null
        ? _notFound<Person>()
        : RepositoryResult.success(_person(row));
  }

  @override
  Stream<List<Person>> watchPeople({bool includeArchived = false}) {
    final query = database.select(database.persons)
      ..orderBy([(t) => OrderingTerm(expression: t.displayName)]);
    if (!includeArchived) query.where((t) => t.archivedAtUtcUs.isNull());
    return query.watch().map(
      (rows) => rows.map(_person).toList(growable: false),
    );
  }

  @override
  Future<RepositoryResult<Person>> updatePerson(Person person) async {
    if (!_validPerson(person)) return _validation<Person>();
    return _write(() async {
      final changed = await (database.update(
        database.persons,
      )..where((t) => t.id.equals(person.id))).write(_personCompanion(person));
      if (changed != 1) throw const _MissingRow();
      return person;
    });
  }

  @override
  Future<RepositoryResult<Person>> archivePerson(
    String id, {
    required DateTime at,
  }) => _setArchive(id, at);

  @override
  Future<RepositoryResult<Person>> restorePerson(
    String id, {
    required DateTime at,
  }) => _setArchive(id, null, updatedAt: at);

  Future<RepositoryResult<Person>> _setArchive(
    String id,
    DateTime? archivedAt, {
    DateTime? updatedAt,
  }) async {
    final existing = await getPerson(id);
    if (existing.isFailure) return existing;
    final changed = existing.value!.copyWith(
      archivedAt: archivedAt,
      updatedAt: updatedAt ?? archivedAt!,
    );
    return updatePerson(changed);
  }

  @override
  Future<RepositoryResult<Person?>> findActiveSelfPerson() async {
    final query =
        database.select(database.persons).join([
          innerJoin(
            database.personRoles,
            database.personRoles.personId.equalsExp(database.persons.id),
          ),
        ])..where(
          database.personRoles.roleType.equals(PersonRoleTypes.self) &
              database.personRoles.effectiveToUtcUs.isNull() &
              database.persons.archivedAtUtcUs.isNull(),
        );
    final row = await query.getSingleOrNull();
    return RepositoryResult.success(
      row == null ? null : _person(row.readTable(database.persons)),
    );
  }

  @override
  Future<RepositoryResult<bool>> erasePerson(String id) => _write(() async {
    return database.transaction(() async {
      final deleted = await (database.delete(
        database.persons,
      )..where((t) => t.id.equals(id))).go();
      if (deleted != 1) throw const _MissingRow();
      return true;
    });
  });
}

final class DriftPersonRoleRepository implements PersonRoleRepository {
  DriftPersonRoleRepository(this.database);
  final RynAppDatabase database;

  @override
  Future<RepositoryResult<PersonRole>> addRole(PersonRole role) {
    if (!_validRole(role)) return Future.value(_validation<PersonRole>());
    return _write(() async {
      await database.into(database.personRoles).insert(_roleCompanion(role));
      return role;
    });
  }

  @override
  Future<RepositoryResult<PersonRole>> closeRole(
    String id, {
    required DateTime effectiveTo,
    required DateTime updatedAt,
  }) => _write(() async {
    final row = await (database.select(
      database.personRoles,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) throw const _MissingRow();
    if (row.effectiveToUtcUs != null ||
        effectiveTo.isBefore(_date(row.effectiveFromUtcUs))) {
      throw const _InvalidInput();
    }
    await (database.update(
      database.personRoles,
    )..where((t) => t.id.equals(id))).write(
      PersonRolesCompanion(
        effectiveToUtcUs: Value(_us(effectiveTo)),
        updatedAtUtcUs: Value(_us(updatedAt)),
      ),
    );
    return _role(
      row.copyWith(
        effectiveToUtcUs: Value(_us(effectiveTo)),
        updatedAtUtcUs: _us(updatedAt),
      ),
    );
  });

  @override
  Stream<List<PersonRole>> watchRolesForPerson(String personId) {
    final query = database.select(database.personRoles)
      ..where((t) => t.personId.equals(personId))
      ..orderBy([(t) => OrderingTerm(expression: t.effectiveFromUtcUs)]);
    return query.watch().map((rows) => rows.map(_role).toList(growable: false));
  }
}

final class DriftPersonRelationshipRepository
    implements PersonRelationshipRepository {
  DriftPersonRelationshipRepository(this.database);
  final RynAppDatabase database;

  @override
  Future<RepositoryResult<PersonRelationship>> createRelationship(
    PersonRelationship relationship,
  ) {
    if (!_validRelationship(relationship)) {
      return Future.value(_validation<PersonRelationship>());
    }
    return _write(() async {
      await database
          .into(database.personRelationships)
          .insert(_relationshipCompanion(relationship));
      return relationship;
    });
  }

  @override
  Future<RepositoryResult<PersonRelationship>> closeRelationship(
    String id, {
    required DateTime effectiveTo,
    required DateTime updatedAt,
  }) => _write(() async {
    final row = await (database.select(
      database.personRelationships,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) throw const _MissingRow();
    if (row.effectiveToUtcUs != null ||
        effectiveTo.isBefore(_date(row.effectiveFromUtcUs))) {
      throw const _InvalidInput();
    }
    await (database.update(
      database.personRelationships,
    )..where((t) => t.id.equals(id))).write(
      PersonRelationshipsCompanion(
        effectiveToUtcUs: Value(_us(effectiveTo)),
        updatedAtUtcUs: Value(_us(updatedAt)),
      ),
    );
    return _relationship(
      row.copyWith(
        effectiveToUtcUs: Value(_us(effectiveTo)),
        updatedAtUtcUs: _us(updatedAt),
      ),
    );
  });

  @override
  Stream<List<PersonRelationship>> watchRelationshipsForPerson(
    String personId,
  ) {
    final query = database.select(database.personRelationships)
      ..where(
        (t) => t.fromPersonId.equals(personId) | t.toPersonId.equals(personId),
      )
      ..orderBy([(t) => OrderingTerm(expression: t.effectiveFromUtcUs)]);
    return query.watch().map(
      (rows) => rows.map(_relationship).toList(growable: false),
    );
  }
}

final class DriftPersonBirthProfileRepository
    implements PersonBirthProfileRepository {
  DriftPersonBirthProfileRepository(this.database);
  final RynAppDatabase database;

  @override
  Future<RepositoryResult<PersonBirthProfile>> createInitialProfile(
    PersonBirthProfile profile,
  ) {
    if (!_validBirth(profile) ||
        profile.revisionNumber != 1 ||
        profile.supersedesBirthProfileId != null ||
        profile.supersededAt != null) {
      return Future.value(_validation<PersonBirthProfile>());
    }
    return _write(() async {
      await database
          .into(database.personBirthProfiles)
          .insert(_birthCompanion(profile));
      return profile;
    });
  }

  @override
  Future<RepositoryResult<PersonBirthProfile>> createRevision(
    PersonBirthProfile revision,
  ) {
    if (!_validBirth(revision) ||
        revision.supersedesBirthProfileId == null ||
        revision.supersededAt != null) {
      return Future.value(_validation<PersonBirthProfile>());
    }
    return _write(
      () => database.transaction(() async {
        final current =
            await (database.select(database.personBirthProfiles)..where(
                  (t) =>
                      t.personId.equals(revision.personId) &
                      t.supersededAtUtcUs.isNull(),
                ))
                .getSingleOrNull();
        if (current == null) throw const _MissingRow();
        if (revision.supersedesBirthProfileId != current.id ||
            revision.revisionNumber != current.revisionNumber + 1) {
          throw const _InvalidInput();
        }
        final supersededAt = _us(revision.createdAt);
        await (database.update(
          database.personBirthProfiles,
        )..where((t) => t.id.equals(current.id))).write(
          PersonBirthProfilesCompanion(supersededAtUtcUs: Value(supersededAt)),
        );
        await database
            .into(database.personBirthProfiles)
            .insert(_birthCompanion(revision));
        return revision;
      }),
    );
  }

  @override
  Future<RepositoryResult<PersonBirthProfile?>> getCurrentProfile(
    String personId,
  ) async {
    final row =
        await (database.select(database.personBirthProfiles)..where(
              (t) => t.personId.equals(personId) & t.supersededAtUtcUs.isNull(),
            ))
            .getSingleOrNull();
    return RepositoryResult.success(row == null ? null : _birth(row));
  }

  @override
  Stream<List<PersonBirthProfile>> watchProfileHistory(String personId) {
    final query = database.select(database.personBirthProfiles)
      ..where((t) => t.personId.equals(personId))
      ..orderBy([(t) => OrderingTerm(expression: t.revisionNumber)]);
    return query.watch().map(
      (rows) => rows.map(_birth).toList(growable: false),
    );
  }
}

final class DriftEncounterRepository implements EncounterRepository {
  DriftEncounterRepository(this.database);
  final RynAppDatabase database;

  @override
  Future<RepositoryResult<Encounter>> createEncounter(Encounter encounter) {
    if (!_validEncounter(encounter)) {
      return Future.value(_validation<Encounter>());
    }
    return _write(() async {
      await database
          .into(database.encounters)
          .insert(_encounterCompanion(encounter));
      return encounter;
    });
  }

  @override
  Future<RepositoryResult<Encounter>> getEncounter(String id) async {
    final row = await (database.select(
      database.encounters,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null
        ? _notFound<Encounter>()
        : RepositoryResult.success(_encounter(row));
  }

  @override
  Stream<List<Encounter>> watchEncountersForPerson(
    String personId, {
    bool includeArchived = false,
  }) {
    final query = database.select(database.encounters)
      ..where((t) => t.personId.equals(personId))
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAtUtcUs)]);
    if (!includeArchived) query.where((t) => t.archivedAtUtcUs.isNull());
    return query.watch().map(
      (rows) => rows.map(_encounter).toList(growable: false),
    );
  }

  @override
  Future<RepositoryResult<Encounter>> updateEncounter(Encounter encounter) {
    if (!_validEncounter(encounter)) {
      return Future.value(_validation<Encounter>());
    }
    return _write(() async {
      final changed =
          await (database.update(database.encounters)
                ..where((t) => t.id.equals(encounter.id)))
              .write(_encounterCompanion(encounter));
      if (changed != 1) throw const _MissingRow();
      return encounter;
    });
  }

  @override
  Future<RepositoryResult<Encounter>> archiveEncounter(
    String id, {
    required DateTime at,
  }) async {
    final existing = await getEncounter(id);
    if (existing.isFailure) return existing;
    return updateEncounter(
      existing.value!.copyWith(archivedAt: at, updatedAt: at),
    );
  }
}

final class DriftEncounterNoteRepository implements EncounterNoteRepository {
  DriftEncounterNoteRepository(this.database);
  final RynAppDatabase database;

  @override
  Future<RepositoryResult<EncounterNote>> addNote(EncounterNote note) {
    if (!_validNote(note) ||
        note.supersedesNoteId != null ||
        note.supersededAt != null) {
      return Future.value(_validation<EncounterNote>());
    }
    return _write(() async {
      await database.into(database.encounterNotes).insert(_noteCompanion(note));
      return note;
    });
  }

  @override
  Future<RepositoryResult<EncounterNote>> correctTypo(
    String id, {
    required String body,
    required DateTime updatedAt,
  }) => _write(() async {
    final row = await (database.select(
      database.encounterNotes,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) throw const _MissingRow();
    if (row.supersededAtUtcUs != null ||
        row.redactedAtUtcUs != null ||
        body.trim().isEmpty) {
      throw const _InvalidInput();
    }
    await (database.update(
      database.encounterNotes,
    )..where((t) => t.id.equals(id))).write(
      EncounterNotesCompanion(
        body: Value(body.trim()),
        updatedAtUtcUs: Value(_us(updatedAt)),
      ),
    );
    return _note(
      row.copyWith(body: body.trim(), updatedAtUtcUs: _us(updatedAt)),
    );
  });

  @override
  Future<RepositoryResult<EncounterNote>> createRevision(
    EncounterNote revision,
  ) {
    if (!_validNote(revision) ||
        revision.supersedesNoteId == null ||
        revision.supersededAt != null) {
      return Future.value(_validation<EncounterNote>());
    }
    return _write(
      () => database.transaction(() async {
        final current =
            await (database.select(database.encounterNotes)
                  ..where((t) => t.id.equals(revision.supersedesNoteId!)))
                .getSingleOrNull();
        if (current == null) throw const _MissingRow();
        if (current.encounterId != revision.encounterId ||
            current.supersededAtUtcUs != null ||
            current.redactedAtUtcUs != null) {
          throw const _InvalidInput();
        }
        final at = _us(revision.recordedAt);
        await (database.update(
          database.encounterNotes,
        )..where((t) => t.id.equals(current.id))).write(
          EncounterNotesCompanion(
            supersededAtUtcUs: Value(at),
            updatedAtUtcUs: Value(at),
          ),
        );
        await database
            .into(database.encounterNotes)
            .insert(_noteCompanion(revision));
        return revision;
      }),
    );
  }

  @override
  Future<RepositoryResult<EncounterNote>> redactNote(
    String id, {
    required DateTime at,
  }) => _write(
    () => database.transaction(() async {
      final row = await (database.select(
        database.encounterNotes,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null) throw const _MissingRow();
      if (row.redactedAtUtcUs != null) throw const _InvalidInput();

      final encounterRows = await (database.select(
        database.encounterNotes,
      )..where((t) => t.encounterId.equals(row.encounterId))).get();
      final chainIds = <String>{id};
      var expanded = true;
      while (expanded) {
        expanded = false;
        for (final candidate in encounterRows) {
          final predecessorId = candidate.supersedesNoteId;
          if (chainIds.contains(candidate.id) ||
              (predecessorId != null && chainIds.contains(predecessorId))) {
            if (chainIds.add(candidate.id)) expanded = true;
            if (predecessorId != null && chainIds.add(predecessorId)) {
              expanded = true;
            }
          }
        }
      }

      final instant = _us(at);
      await (database.update(
        database.encounterNotes,
      )..where((t) => t.id.isIn(chainIds))).write(
        EncounterNotesCompanion(
          body: const Value(''),
          redactedAtUtcUs: Value(instant),
          updatedAtUtcUs: Value(instant),
        ),
      );
      return _note(
        row.copyWith(
          body: '',
          redactedAtUtcUs: Value(instant),
          updatedAtUtcUs: instant,
        ),
      );
    }),
  );

  @override
  Stream<List<EncounterNote>> watchNotesForEncounter(String encounterId) {
    final query = database.select(database.encounterNotes)
      ..where((t) => t.encounterId.equals(encounterId))
      ..orderBy([(t) => OrderingTerm(expression: t.recordedAtUtcUs)]);
    return query.watch().map((rows) => rows.map(_note).toList(growable: false));
  }
}

int _us(DateTime value) => value.toUtc().microsecondsSinceEpoch;
DateTime _date(int value) =>
    DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
DateTime? _nullableDate(int? value) => value == null ? null : _date(value);

bool _base(String id, DateTime created, DateTime updated) =>
    id.trim().isNotEmpty &&
    created.isUtc &&
    updated.isUtc &&
    !updated.isBefore(created);
bool _validPerson(Person value) =>
    _base(value.id, value.createdAt, value.updatedAt) &&
    value.displayName.trim().isNotEmpty &&
    PersonStatuses.values.contains(value.status);
bool _validRole(PersonRole value) =>
    _base(value.id, value.createdAt, value.updatedAt) &&
    value.personId.trim().isNotEmpty &&
    PersonRoleTypes.values.contains(value.roleType) &&
    value.effectiveFrom.isUtc &&
    (value.effectiveTo == null ||
        !value.effectiveTo!.isBefore(value.effectiveFrom));
bool _validRelationship(PersonRelationship value) =>
    _base(value.id, value.createdAt, value.updatedAt) &&
    value.fromPersonId != value.toPersonId &&
    value.relationshipType.trim().isNotEmpty &&
    value.effectiveFrom.isUtc &&
    (value.effectiveTo == null ||
        !value.effectiveTo!.isBefore(value.effectiveFrom));
bool _validBirth(PersonBirthProfile value) =>
    value.id.trim().isNotEmpty &&
    value.personId.trim().isNotEmpty &&
    value.revisionNumber >= 1 &&
    value.createdAt.isUtc &&
    BirthPrecisions.values.contains(value.birthDatePrecision) &&
    BirthPrecisions.values.contains(value.birthTimePrecision) &&
    BirthCalendarSystems.values.contains(value.calendarSystem) &&
    BirthVerificationStates.values.contains(value.verificationState) &&
    (value.utcOffsetMinutesAtBirth == null ||
        (value.utcOffsetMinutesAtBirth! >= -840 &&
            value.utcOffsetMinutesAtBirth! <= 840)) &&
    (value.calendarSystem == BirthCalendarSystems.lunar ||
        value.isLeapMonth == null);
bool _validEncounter(Encounter value) =>
    _base(value.id, value.createdAt, value.updatedAt) &&
    value.personId.trim().isNotEmpty &&
    value.occurredAt.isUtc &&
    EncounterPrecisions.values.contains(value.occurredPrecision) &&
    EncounterTypes.values.contains(value.encounterType) &&
    value.title.trim().isNotEmpty &&
    EncounterStatuses.values.contains(value.status);
bool _validNote(EncounterNote value) =>
    value.id.trim().isNotEmpty &&
    value.encounterId.trim().isNotEmpty &&
    EncounterNoteTypes.values.contains(value.noteType) &&
    value.body.trim().isNotEmpty &&
    value.recordedAt.isUtc &&
    value.updatedAt.isUtc &&
    !value.updatedAt.isBefore(value.recordedAt) &&
    value.redactedAt == null;

PersonsCompanion _personCompanion(Person v) => PersonsCompanion(
  id: Value(v.id),
  displayName: Value(v.displayName.trim()),
  status: Value(v.status),
  relationshipSummary: Value(v.relationshipSummary),
  firstMetOnUtcUs: Value(v.firstMetOn == null ? null : _us(v.firstMetOn!)),
  archivedAtUtcUs: Value(v.archivedAt == null ? null : _us(v.archivedAt!)),
  createdAtUtcUs: Value(_us(v.createdAt)),
  updatedAtUtcUs: Value(_us(v.updatedAt)),
);
Person _person(PersonRow r) => Person(
  id: r.id,
  displayName: r.displayName,
  status: r.status,
  relationshipSummary: r.relationshipSummary,
  firstMetOn: _nullableDate(r.firstMetOnUtcUs),
  archivedAt: _nullableDate(r.archivedAtUtcUs),
  createdAt: _date(r.createdAtUtcUs),
  updatedAt: _date(r.updatedAtUtcUs),
);

PersonRolesCompanion _roleCompanion(PersonRole v) => PersonRolesCompanion(
  id: Value(v.id),
  personId: Value(v.personId),
  roleType: Value(v.roleType),
  effectiveFromUtcUs: Value(_us(v.effectiveFrom)),
  effectiveToUtcUs: Value(v.effectiveTo == null ? null : _us(v.effectiveTo!)),
  note: Value(v.note),
  createdAtUtcUs: Value(_us(v.createdAt)),
  updatedAtUtcUs: Value(_us(v.updatedAt)),
);
PersonRole _role(PersonRoleRow r) => PersonRole(
  id: r.id,
  personId: r.personId,
  roleType: r.roleType,
  effectiveFrom: _date(r.effectiveFromUtcUs),
  effectiveTo: _nullableDate(r.effectiveToUtcUs),
  note: r.note,
  createdAt: _date(r.createdAtUtcUs),
  updatedAt: _date(r.updatedAtUtcUs),
);

PersonRelationshipsCompanion _relationshipCompanion(PersonRelationship v) =>
    PersonRelationshipsCompanion(
      id: Value(v.id),
      fromPersonId: Value(v.fromPersonId),
      toPersonId: Value(v.toPersonId),
      relationshipType: Value(v.relationshipType.trim()),
      effectiveFromUtcUs: Value(_us(v.effectiveFrom)),
      effectiveToUtcUs: Value(
        v.effectiveTo == null ? null : _us(v.effectiveTo!),
      ),
      note: Value(v.note),
      createdAtUtcUs: Value(_us(v.createdAt)),
      updatedAtUtcUs: Value(_us(v.updatedAt)),
    );
PersonRelationship _relationship(PersonRelationshipRow r) => PersonRelationship(
  id: r.id,
  fromPersonId: r.fromPersonId,
  toPersonId: r.toPersonId,
  relationshipType: r.relationshipType,
  effectiveFrom: _date(r.effectiveFromUtcUs),
  effectiveTo: _nullableDate(r.effectiveToUtcUs),
  note: r.note,
  createdAt: _date(r.createdAtUtcUs),
  updatedAt: _date(r.updatedAtUtcUs),
);

PersonBirthProfilesCompanion _birthCompanion(PersonBirthProfile v) =>
    PersonBirthProfilesCompanion(
      id: Value(v.id),
      personId: Value(v.personId),
      revisionNumber: Value(v.revisionNumber),
      birthDate: Value(v.birthDate),
      birthDatePrecision: Value(v.birthDatePrecision),
      birthTime: Value(v.birthTime),
      birthTimePrecision: Value(v.birthTimePrecision),
      birthplaceLabel: Value(v.birthplaceLabel),
      timeZoneId: Value(v.timeZoneId),
      utcOffsetMinutesAtBirth: Value(v.utcOffsetMinutesAtBirth),
      calendarSystem: Value(v.calendarSystem),
      isLeapMonth: Value(v.isLeapMonth),
      sourceNote: Value(v.sourceNote),
      verificationState: Value(v.verificationState),
      supersedesBirthProfileId: Value(v.supersedesBirthProfileId),
      supersededAtUtcUs: Value(
        v.supersededAt == null ? null : _us(v.supersededAt!),
      ),
      createdAtUtcUs: Value(_us(v.createdAt)),
    );
PersonBirthProfile _birth(PersonBirthProfileRow r) => PersonBirthProfile(
  id: r.id,
  personId: r.personId,
  revisionNumber: r.revisionNumber,
  birthDate: r.birthDate,
  birthDatePrecision: r.birthDatePrecision,
  birthTime: r.birthTime,
  birthTimePrecision: r.birthTimePrecision,
  birthplaceLabel: r.birthplaceLabel,
  timeZoneId: r.timeZoneId,
  utcOffsetMinutesAtBirth: r.utcOffsetMinutesAtBirth,
  calendarSystem: r.calendarSystem,
  isLeapMonth: r.isLeapMonth,
  sourceNote: r.sourceNote,
  verificationState: r.verificationState,
  supersedesBirthProfileId: r.supersedesBirthProfileId,
  supersededAt: _nullableDate(r.supersededAtUtcUs),
  createdAt: _date(r.createdAtUtcUs),
);

EncountersCompanion _encounterCompanion(Encounter v) => EncountersCompanion(
  id: Value(v.id),
  personId: Value(v.personId),
  occurredAtUtcUs: Value(_us(v.occurredAt)),
  occurredPrecision: Value(v.occurredPrecision),
  encounterType: Value(v.encounterType),
  title: Value(v.title.trim()),
  summary: Value(v.summary),
  status: Value(v.status),
  followUpAtUtcUs: Value(v.followUpAt == null ? null : _us(v.followUpAt!)),
  archivedAtUtcUs: Value(v.archivedAt == null ? null : _us(v.archivedAt!)),
  createdAtUtcUs: Value(_us(v.createdAt)),
  updatedAtUtcUs: Value(_us(v.updatedAt)),
);
Encounter _encounter(EncounterRow r) => Encounter(
  id: r.id,
  personId: r.personId,
  occurredAt: _date(r.occurredAtUtcUs),
  occurredPrecision: r.occurredPrecision,
  encounterType: r.encounterType,
  title: r.title,
  summary: r.summary,
  status: r.status,
  followUpAt: _nullableDate(r.followUpAtUtcUs),
  archivedAt: _nullableDate(r.archivedAtUtcUs),
  createdAt: _date(r.createdAtUtcUs),
  updatedAt: _date(r.updatedAtUtcUs),
);

EncounterNotesCompanion _noteCompanion(EncounterNote v) =>
    EncounterNotesCompanion(
      id: Value(v.id),
      encounterId: Value(v.encounterId),
      noteType: Value(v.noteType),
      body: Value(v.body.trim()),
      recordedAtUtcUs: Value(_us(v.recordedAt)),
      updatedAtUtcUs: Value(_us(v.updatedAt)),
      supersedesNoteId: Value(v.supersedesNoteId),
      supersededAtUtcUs: Value(
        v.supersededAt == null ? null : _us(v.supersededAt!),
      ),
      redactedAtUtcUs: Value(v.redactedAt == null ? null : _us(v.redactedAt!)),
    );
EncounterNote _note(EncounterNoteRow r) => EncounterNote(
  id: r.id,
  encounterId: r.encounterId,
  noteType: r.noteType,
  body: r.body,
  recordedAt: _date(r.recordedAtUtcUs),
  updatedAt: _date(r.updatedAtUtcUs),
  supersedesNoteId: r.supersedesNoteId,
  supersededAt: _nullableDate(r.supersededAtUtcUs),
  redactedAt: _nullableDate(r.redactedAtUtcUs),
);

Future<RepositoryResult<T>> _write<T>(Future<T> Function() body) async {
  try {
    return RepositoryResult.success(await body());
  } on _MissingRow {
    return _notFound<T>();
  } on _InvalidInput {
    return _validation<T>();
  } on SqliteException catch (error) {
    final conflict =
        error.message.toLowerCase().contains('unique') ||
        error.extendedResultCode == 2067;
    return RepositoryResult.failure(
      RepositoryError(
        code: conflict
            ? RepositoryErrorCode.conflict
            : RepositoryErrorCode.persistenceUnavailable,
        safeMessage: conflict
            ? 'The record conflicts with existing data.'
            : 'The record could not be stored.',
      ),
    );
  } on Object {
    return RepositoryResult.failure(
      const RepositoryError(
        code: RepositoryErrorCode.persistenceUnavailable,
        safeMessage: 'The record could not be stored.',
      ),
    );
  }
}

RepositoryResult<T> _validation<T>() => RepositoryResult.failure(
  const RepositoryError(
    code: RepositoryErrorCode.validationFailed,
    safeMessage: 'The record is invalid.',
  ),
);
RepositoryResult<T> _notFound<T>() => RepositoryResult.failure(
  const RepositoryError(
    code: RepositoryErrorCode.notFound,
    safeMessage: 'The record was not found.',
  ),
);

final class _MissingRow implements Exception {
  const _MissingRow();
}

final class _InvalidInput implements Exception {
  const _InvalidInput();
}
