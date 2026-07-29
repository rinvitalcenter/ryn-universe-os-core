import 'package:drift/drift.dart';

import '../../../people/data/persistence/person_tables.dart';

@DataClassName('StudySessionRow')
class StudySessions extends Table {
  TextColumn get id => text().withLength(min: 1, max: 120)();
  TextColumn get title => text().withLength(min: 1, max: 240)();
  IntColumn get occurredAtUtcUs => integer().named('occurred_at_utc_us')();
  IntColumn get timezoneOffsetMinutes =>
      integer().named('timezone_offset_minutes')();
  TextColumn get location => text().withLength(min: 1, max: 300)();
  TextColumn get track => text().withLength(min: 1, max: 20)();
  TextColumn get status => text().withLength(min: 1, max: 20)();
  TextColumn get summary => text().withLength(max: 4000).nullable()();
  TextColumn get operationNotes =>
      text().named('operation_notes').withLength(max: 12000).nullable()();
  TextColumn get learningGoal =>
      text().named('learning_goal').withLength(max: 4000).nullable()();
  TextColumn get coveredContent =>
      text().named('covered_content').withLength(max: 8000).nullable()();
  TextColumn get progressStatus => text()
      .named('progress_status')
      .withLength(min: 1, max: 20)
      .withDefault(const Constant('not_started'))();
  TextColumn get nextSteps =>
      text().named('next_steps').withLength(max: 4000).nullable()();
  IntColumn get createdAtUtcUs => integer().named('created_at_utc_us')();
  IntColumn get updatedAtUtcUs => integer().named('updated_at_utc_us')();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    "CHECK (length(trim(id)) > 0)",
    "CHECK (length(trim(title)) > 0)",
    "CHECK (length(trim(location)) > 0)",
    "CHECK (track IN ('tarot', 'saju', 'mixed'))",
    "CHECK (status IN ('planned', 'completed', 'cancelled'))",
    "CHECK (progress_status IN ('not_started', 'in_progress', 'completed', 'deferred'))",
    'CHECK (timezone_offset_minutes BETWEEN -840 AND 840)',
    'CHECK (updated_at_utc_us >= created_at_utc_us)',
  ];
}

@DataClassName('StudySessionParticipantRow')
class StudySessionParticipants extends Table {
  TextColumn get sessionId => text()
      .named('session_id')
      .references(StudySessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get personId => text()
      .named('person_id')
      .references(Persons, #id, onDelete: KeyAction.restrict)();
  TextColumn get attendanceStatus => text()
      .named('attendance_status')
      .withLength(min: 1, max: 20)
      .withDefault(const Constant('planned'))();
  TextColumn get note => text().withLength(max: 1000).nullable()();
  TextColumn get learningNote =>
      text().named('learning_note').withLength(max: 2000).nullable()();
  IntColumn get createdAtUtcUs => integer().named('created_at_utc_us')();
  IntColumn get updatedAtUtcUs => integer().named('updated_at_utc_us')();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, personId};

  @override
  List<String> get customConstraints => const [
    "CHECK (attendance_status IN ('planned', 'attended', 'absent', 'late', 'cancelled'))",
    'CHECK (updated_at_utc_us >= created_at_utc_us)',
  ];
}

@DataClassName('StudyMaterialRow')
class StudyMaterials extends Table {
  TextColumn get id => text().withLength(min: 1, max: 120)();
  TextColumn get title => text().withLength(min: 1, max: 240)();
  TextColumn get type => text().withLength(min: 1, max: 30)();
  TextColumn get url => text().withLength(max: 2000).nullable()();
  TextColumn get storageNote =>
      text().named('storage_note').withLength(max: 1000).nullable()();
  TextColumn get description => text().withLength(max: 4000).nullable()();
  IntColumn get createdAtUtcUs => integer().named('created_at_utc_us')();
  IntColumn get updatedAtUtcUs => integer().named('updated_at_utc_us')();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    "CHECK (length(trim(id)) > 0)",
    "CHECK (length(trim(title)) > 0)",
    "CHECK (type IN ('handout', 'card_news', 'web_page', 'video', 'book', 'practice', 'other'))",
    'CHECK (updated_at_utc_us >= created_at_utc_us)',
  ];
}

@DataClassName('StudySessionMaterialRow')
class StudySessionMaterials extends Table {
  TextColumn get sessionId => text()
      .named('session_id')
      .references(StudySessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get materialId => text()
      .named('material_id')
      .references(StudyMaterials, #id, onDelete: KeyAction.restrict)();
  IntColumn get createdAtUtcUs => integer().named('created_at_utc_us')();

  @override
  Set<Column<Object>> get primaryKey => {sessionId, materialId};
}
