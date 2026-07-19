import 'package:drift/drift.dart';

@DataClassName('PersonRow')
class Persons extends Table {
  TextColumn get id => text().withLength(min: 1, max: 120)();
  TextColumn get displayName =>
      text().named('display_name').withLength(min: 1, max: 240)();
  TextColumn get status => text().withLength(min: 1, max: 40)();
  TextColumn get relationshipSummary =>
      text().named('relationship_summary').withLength(max: 2000).nullable()();
  IntColumn get firstMetOnUtcUs =>
      integer().named('first_met_on_utc_us').nullable()();
  IntColumn get archivedAtUtcUs =>
      integer().named('archived_at_utc_us').nullable()();
  IntColumn get createdAtUtcUs => integer().named('created_at_utc_us')();
  IntColumn get updatedAtUtcUs => integer().named('updated_at_utc_us')();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    "CHECK (length(trim(id)) > 0)",
    "CHECK (length(trim(display_name)) > 0)",
    "CHECK (status IN ('active', 'inactive'))",
    'CHECK (updated_at_utc_us >= created_at_utc_us)',
  ];
}

@DataClassName('PersonRoleRow')
class PersonRoles extends Table {
  TextColumn get id => text().withLength(min: 1, max: 120)();
  TextColumn get personId => text()
      .named('person_id')
      .references(Persons, #id, onDelete: KeyAction.cascade)();
  TextColumn get roleType =>
      text().named('role_type').withLength(min: 1, max: 60)();
  IntColumn get effectiveFromUtcUs =>
      integer().named('effective_from_utc_us')();
  IntColumn get effectiveToUtcUs =>
      integer().named('effective_to_utc_us').nullable()();
  TextColumn get note => text().withLength(max: 1000).nullable()();
  IntColumn get createdAtUtcUs => integer().named('created_at_utc_us')();
  IntColumn get updatedAtUtcUs => integer().named('updated_at_utc_us')();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    "CHECK (role_type IN ('self', 'family', 'friend', 'studyMember', 'client', 'student', 'instructor', 'practiceParticipant', 'other'))",
    'CHECK (effective_to_utc_us IS NULL OR effective_to_utc_us >= effective_from_utc_us)',
    'CHECK (updated_at_utc_us >= created_at_utc_us)',
  ];
}

@DataClassName('PersonRelationshipRow')
class PersonRelationships extends Table {
  TextColumn get id => text().withLength(min: 1, max: 120)();
  @ReferenceName('relationshipsFromPerson')
  TextColumn get fromPersonId => text()
      .named('from_person_id')
      .references(Persons, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('relationshipsToPerson')
  TextColumn get toPersonId => text()
      .named('to_person_id')
      .references(Persons, #id, onDelete: KeyAction.cascade)();
  TextColumn get relationshipType =>
      text().named('relationship_type').withLength(min: 1, max: 80)();
  IntColumn get effectiveFromUtcUs =>
      integer().named('effective_from_utc_us')();
  IntColumn get effectiveToUtcUs =>
      integer().named('effective_to_utc_us').nullable()();
  TextColumn get note => text().withLength(max: 1000).nullable()();
  IntColumn get createdAtUtcUs => integer().named('created_at_utc_us')();
  IntColumn get updatedAtUtcUs => integer().named('updated_at_utc_us')();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {fromPersonId, toPersonId, relationshipType, effectiveFromUtcUs},
  ];

  @override
  List<String> get customConstraints => const [
    'CHECK (from_person_id != to_person_id)',
    "CHECK (length(trim(relationship_type)) > 0)",
    'CHECK (effective_to_utc_us IS NULL OR effective_to_utc_us >= effective_from_utc_us)',
    'CHECK (updated_at_utc_us >= created_at_utc_us)',
  ];
}

@DataClassName('PersonBirthProfileRow')
class PersonBirthProfiles extends Table {
  TextColumn get id => text().withLength(min: 1, max: 120)();
  TextColumn get personId => text()
      .named('person_id')
      .references(Persons, #id, onDelete: KeyAction.cascade)();
  IntColumn get revisionNumber => integer().named('revision_number')();
  TextColumn get birthDate =>
      text().named('birth_date').withLength(max: 10).nullable()();
  TextColumn get birthDatePrecision =>
      text().named('birth_date_precision').withLength(min: 1, max: 20)();
  TextColumn get birthTime =>
      text().named('birth_time').withLength(max: 5).nullable()();
  TextColumn get birthTimePrecision =>
      text().named('birth_time_precision').withLength(min: 1, max: 20)();
  TextColumn get birthplaceLabel =>
      text().named('birthplace_label').withLength(max: 300).nullable()();
  TextColumn get timeZoneId =>
      text().named('time_zone_id').withLength(max: 120).nullable()();
  IntColumn get utcOffsetMinutesAtBirth =>
      integer().named('utc_offset_minutes_at_birth').nullable()();
  TextColumn get calendarSystem =>
      text().named('calendar_system').withLength(min: 1, max: 20)();
  BoolColumn get isLeapMonth => boolean().named('is_leap_month').nullable()();
  TextColumn get sourceNote =>
      text().named('source_note').withLength(max: 2000).nullable()();
  TextColumn get verificationState =>
      text().named('verification_state').withLength(min: 1, max: 20)();
  TextColumn get supersedesBirthProfileId => text()
      .named('supersedes_birth_profile_id')
      .nullable()
      .references(PersonBirthProfiles, #id, onDelete: KeyAction.setNull)();
  IntColumn get supersededAtUtcUs =>
      integer().named('superseded_at_utc_us').nullable()();
  IntColumn get createdAtUtcUs => integer().named('created_at_utc_us')();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {personId, revisionNumber},
  ];

  @override
  List<String> get customConstraints => const [
    'CHECK (revision_number >= 1)',
    "CHECK (birth_date_precision IN ('exact', 'approximate', 'unknown'))",
    "CHECK (birth_time_precision IN ('exact', 'approximate', 'unknown'))",
    "CHECK (calendar_system IN ('solar', 'lunar', 'unknown'))",
    "CHECK (verification_state IN ('unverified', 'confirmed', 'disputed'))",
    'CHECK (utc_offset_minutes_at_birth IS NULL OR utc_offset_minutes_at_birth BETWEEN -840 AND 840)',
    "CHECK (calendar_system = 'lunar' OR is_leap_month IS NULL)",
    'CHECK (supersedes_birth_profile_id IS NULL OR supersedes_birth_profile_id != id)',
  ];
}

@DataClassName('EncounterRow')
class Encounters extends Table {
  TextColumn get id => text().withLength(min: 1, max: 120)();
  TextColumn get personId => text()
      .named('person_id')
      .references(Persons, #id, onDelete: KeyAction.cascade)();
  IntColumn get occurredAtUtcUs => integer().named('occurred_at_utc_us')();
  TextColumn get occurredPrecision =>
      text().named('occurred_precision').withLength(min: 1, max: 20)();
  TextColumn get encounterType =>
      text().named('encounter_type').withLength(min: 1, max: 60)();
  TextColumn get title => text().withLength(min: 1, max: 240)();
  TextColumn get summary => text().withLength(max: 4000).nullable()();
  TextColumn get status => text().withLength(min: 1, max: 20)();
  IntColumn get followUpAtUtcUs =>
      integer().named('follow_up_at_utc_us').nullable()();
  IntColumn get archivedAtUtcUs =>
      integer().named('archived_at_utc_us').nullable()();
  IntColumn get createdAtUtcUs => integer().named('created_at_utc_us')();
  IntColumn get updatedAtUtcUs => integer().named('updated_at_utc_us')();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    "CHECK (occurred_precision IN ('exact', 'approximate', 'dateOnly'))",
    "CHECK (encounter_type IN ('inPersonCounseling', 'onlineCounseling', 'phoneCall', 'studyMeeting', 'practiceInstruction', 'followUpReview', 'selfReview', 'other'))",
    "CHECK (length(trim(title)) > 0)",
    "CHECK (status IN ('completed', 'voided'))",
    'CHECK (updated_at_utc_us >= created_at_utc_us)',
  ];
}

@DataClassName('EncounterNoteRow')
class EncounterNotes extends Table {
  TextColumn get id => text().withLength(min: 1, max: 120)();
  TextColumn get encounterId => text()
      .named('encounter_id')
      .references(Encounters, #id, onDelete: KeyAction.cascade)();
  TextColumn get noteType =>
      text().named('note_type').withLength(min: 1, max: 40)();
  TextColumn get body => text().withLength(max: 12000)();
  IntColumn get recordedAtUtcUs => integer().named('recorded_at_utc_us')();
  IntColumn get updatedAtUtcUs => integer().named('updated_at_utc_us')();
  TextColumn get supersedesNoteId => text()
      .named('supersedes_note_id')
      .nullable()
      .references(EncounterNotes, #id, onDelete: KeyAction.setNull)();
  IntColumn get supersededAtUtcUs =>
      integer().named('superseded_at_utc_us').nullable()();
  IntColumn get redactedAtUtcUs =>
      integer().named('redacted_at_utc_us').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    "CHECK (note_type IN ('reportedFact', 'ownerObservation', 'toolInterpretation', 'workingHypothesis', 'agreedAction', 'privateReflection'))",
    "CHECK ((redacted_at_utc_us IS NULL AND length(trim(body)) > 0) OR (redacted_at_utc_us IS NOT NULL AND body = ''))",
    'CHECK (supersedes_note_id IS NULL OR supersedes_note_id != id)',
    'CHECK (updated_at_utc_us >= recorded_at_utc_us)',
  ];
}
