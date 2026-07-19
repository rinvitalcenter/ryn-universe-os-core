import 'package:drift/drift.dart';

import '../../features/people/data/persistence/person_tables.dart';
import '../../features/tarot/data/persistence/tarot_tables.dart';
import 'database_connection.dart';
import 'migrations.dart';
import 'runtime_data_profile.dart';

part 'app_database.g.dart';

/// Low-risk runtime application settings metadata.
///
/// This table is intentionally limited to non-secret key/value metadata. Raw
/// secrets, provider tokens, private payloads, and sensitive personal data are
/// forbidden by policy and must not be stored here.
class AppSettings extends Table {
  TextColumn get key => text().withLength(min: 1, max: 120)();

  TextColumn get value => text().withLength(max: 1000).nullable()();

  TextColumn get valueType => text()
      .named('value_type')
      .withLength(min: 1, max: 40)
      .withDefault(const Constant('string'))();

  TextColumn get redactionState => text()
      .named('redaction_state')
      .withLength(min: 1, max: 40)
      .withDefault(const Constant('none_required'))();

  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Human-governance Obsidian report references.
///
/// Stores safe reference metadata only: document type, vault-relative path,
/// optional content hash, and optional redaction status. The Markdown body is not
/// runtime state and raw sensitive content must not be persisted in this table.
class ObsidianReportRefs extends Table {
  TextColumn get id => text().withLength(min: 1, max: 120)();

  TextColumn get docType =>
      text().named('doc_type').withLength(min: 1, max: 80)();

  TextColumn get vaultPath =>
      text().named('vault_path').withLength(min: 1, max: 500)();

  TextColumn get sha256 => text().withLength(min: 64, max: 64).nullable()();

  TextColumn get redactionState => text()
      .named('redaction_state')
      .withLength(min: 1, max: 40)
      .withDefault(const Constant('none_required'))();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Minimal append-only audit trail foundation.
///
/// This table stores redacted governance/event metadata only. It does not store
/// raw secrets, raw prompt/API payloads, private logs, evidence binaries, full
/// entity snapshots, or real user/private data. Append-only behavior is a future
/// repository/transaction policy and is not implemented as CRUD in this slice.
class AuditTrail extends Table {
  TextColumn get id => text().withLength(min: 1, max: 120)();

  DateTimeColumn get occurredAt => dateTime().named('occurred_at')();

  TextColumn get actorType =>
      text().named('actor_type').withLength(min: 1, max: 60)();

  TextColumn get actorId =>
      text().named('actor_id').withLength(min: 1, max: 120).nullable()();

  TextColumn get action => text().withLength(min: 1, max: 120)();

  TextColumn get targetType =>
      text().named('target_type').withLength(min: 1, max: 80)();

  TextColumn get targetId =>
      text().named('target_id').withLength(min: 1, max: 120).nullable()();

  TextColumn get beforeHash =>
      text().named('before_hash').withLength(min: 64, max: 64).nullable()();

  TextColumn get afterHash =>
      text().named('after_hash').withLength(min: 64, max: 64).nullable()();

  TextColumn get redactedSnapshot =>
      text().named('redacted_snapshot').withLength(max: 8000).nullable()();

  TextColumn get redactionState => text()
      .named('redaction_state')
      .withLength(min: 1, max: 40)
      .withDefault(const Constant('none_required'))();

  TextColumn get reason => text().withLength(max: 1000).nullable()();

  TextColumn get correlationId =>
      text().named('correlation_id').withLength(min: 1, max: 120).nullable()();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Minimal mission grouping foundation.
///
/// This table stores high-level operational work grouping metadata only. It does
/// not store raw secrets, private payloads, runtime execution attempts, approvals,
/// evidence binaries, Obsidian Markdown bodies, or audit enforcement state.
class Missions extends Table {
  TextColumn get id => text().withLength(min: 1, max: 120)();

  TextColumn get title => text().withLength(min: 1, max: 240)();

  TextColumn get description => text().withLength(max: 2000).nullable()();

  TextColumn get status => text()
      .withLength(min: 1, max: 40)
      .withDefault(const Constant('active'))();

  TextColumn get mode => text()
      .withLength(min: 1, max: 40)
      .withDefault(const Constant('standard'))();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();

  DateTimeColumn get archivedAt => dateTime().named('archived_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Minimal task card intent foundation.
///
/// Task cards represent intended work, not agent execution attempts, approval
/// decisions, activity-feed events, QA evidence records, or audit rows. This
/// slice stores card metadata only and does not implement CRUD or UI state.
class TaskCards extends Table {
  TextColumn get id => text().withLength(min: 1, max: 120)();

  TextColumn get missionId =>
      text().named('mission_id').withLength(min: 1, max: 120).nullable()();

  TextColumn get title => text().withLength(min: 1, max: 240)();

  TextColumn get description => text().withLength(max: 4000).nullable()();

  TextColumn get lane => text()
      .withLength(min: 1, max: 80)
      .withDefault(const Constant('planned'))();

  TextColumn get status => text()
      .withLength(min: 1, max: 40)
      .withDefault(const Constant('planned'))();

  TextColumn get priority => text()
      .withLength(min: 1, max: 40)
      .withDefault(const Constant('normal'))();

  TextColumn get orderKey =>
      text().named('order_key').withLength(min: 1, max: 120).nullable()();

  TextColumn get riskLevel => text()
      .named('risk_level')
      .withLength(min: 1, max: 40)
      .withDefault(const Constant('low'))();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();

  DateTimeColumn get archivedAt => dateTime().named('archived_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Minimal agent execution-attempt foundation.
///
/// Agent Run is an execution attempt, not a human approval decision, task-card
/// completion marker, activity-feed event, QA evidence record, audit append
/// enforcement row, or secret container. This slice stores lifecycle metadata
/// only and does not implement CRUD, runtime execution, or provider wiring.
class AgentRuns extends Table {
  TextColumn get id => text().withLength(min: 1, max: 120)();

  TextColumn get missionId =>
      text().named('mission_id').withLength(min: 1, max: 120).nullable()();

  TextColumn get taskCardId =>
      text().named('task_card_id').withLength(min: 1, max: 120).nullable()();

  TextColumn get agentName =>
      text().named('agent_name').withLength(min: 1, max: 120)();

  TextColumn get runKind => text()
      .named('run_kind')
      .withLength(min: 1, max: 60)
      .withDefault(const Constant('manual'))();

  TextColumn get phase =>
      text().withLength(min: 1, max: 60).withDefault(const Constant('draft'))();

  TextColumn get condition => text()
      .withLength(min: 1, max: 60)
      .withDefault(const Constant('healthy'))();

  TextColumn get autonomyLevel => text()
      .named('autonomy_level')
      .withLength(min: 1, max: 60)
      .withDefault(const Constant('guarded'))();

  TextColumn get executionTarget => text()
      .named('execution_target')
      .withLength(min: 1, max: 80)
      .withDefault(const Constant('local'))();

  DateTimeColumn get startedAt => dateTime().named('started_at').nullable()();

  DateTimeColumn get endedAt => dateTime().named('ended_at').nullable()();

  TextColumn get summary => text().withLength(max: 4000).nullable()();

  TextColumn get errorText =>
      text().named('error_text').withLength(max: 4000).nullable()();

  TextColumn get outputRef =>
      text().named('output_ref').withLength(max: 500).nullable()();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Minimal human approval decision-boundary foundation.
///
/// Approval Record is a human governance decision boundary, not an execution
/// attempt, task-card completion marker, activity-feed event, QA evidence record,
/// audit append enforcement row, or secret container. Request-changes loops are
/// represented by state/decision/successor metadata only in this slice.
class ApprovalRecords extends Table {
  TextColumn get id => text().withLength(min: 1, max: 120)();

  TextColumn get subjectType =>
      text().named('subject_type').withLength(min: 1, max: 80)();

  TextColumn get subjectId =>
      text().named('subject_id').withLength(min: 1, max: 120)();

  TextColumn get approvalType =>
      text().named('approval_type').withLength(min: 1, max: 80)();

  TextColumn get state =>
      text().withLength(min: 1, max: 60).withDefault(const Constant('draft'))();

  TextColumn get requestedBy =>
      text().named('requested_by').withLength(min: 1, max: 120).nullable()();

  DateTimeColumn get requestedAt =>
      dateTime().named('requested_at').nullable()();

  TextColumn get decidedBy =>
      text().named('decided_by').withLength(min: 1, max: 120).nullable()();

  DateTimeColumn get decidedAt => dateTime().named('decided_at').nullable()();

  TextColumn get decision => text().withLength(max: 60).nullable()();

  TextColumn get decisionNote =>
      text().named('decision_note').withLength(max: 4000).nullable()();

  TextColumn get successorApprovalId => text()
      .named('successor_approval_id')
      .withLength(min: 1, max: 120)
      .nullable()();

  TextColumn get obsidianRefId =>
      text().named('obsidian_ref_id').withLength(min: 1, max: 120).nullable()();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Generated Drift database for approved governance, Person Core, and Tarot
/// persistence slices.
@DriftDatabase(
  tables: [
    AppSettings,
    ObsidianReportRefs,
    AuditTrail,
    Missions,
    TaskCards,
    AgentRuns,
    ApprovalRecords,
    TarotReadings,
    TarotCardPlacements,
    TarotInterpretations,
    AppRuntimeState,
    Persons,
    PersonRoles,
    PersonRelationships,
    PersonBirthProfiles,
    Encounters,
    EncounterNotes,
  ],
)
final class RynAppDatabase extends _$RynAppDatabase {
  RynAppDatabase(super.executor);

  /// Opens only the explicitly resolved development SQLite database.
  static Future<RynAppDatabase> openDevelopment({
    required RynResolvedDatabasePath resolvedPath,
  }) async {
    final executor = await openRynRuntimeDatabaseConnection(
      resolvedPath: resolvedPath,
    );
    return RynAppDatabase(executor);
  }

  @override
  int get schemaVersion => plannedCurrentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _ensurePersonCoreIndexes();
      await _ensureMainRuntimeState();
    },
    onUpgrade: (migrator, from, to) async {
      if (to != 6 || (from != 4 && from != 5)) {
        throw StateError('Unsupported database migration path: $from -> $to');
      }
      if (from == 4) {
        await migrator.createTable(tarotReadings);
        await migrator.createTable(tarotCardPlacements);
        await migrator.createTable(tarotInterpretations);
        await migrator.createTable(appRuntimeState);
      }
      await migrator.createTable(persons);
      await migrator.createTable(personRoles);
      await migrator.createTable(personRelationships);
      await migrator.createTable(personBirthProfiles);
      await migrator.createTable(encounters);
      await migrator.createTable(encounterNotes);
      await _ensurePersonCoreIndexes();
      await _ensureMainRuntimeState();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      final previous = details.versionBefore;
      if (previous != null && previous > schemaVersion) {
        throw StateError(
          'Database schema $previous is newer than supported $schemaVersion',
        );
      }
    },
  );

  Future<void> _ensureMainRuntimeState() => customStatement(
    "INSERT OR IGNORE INTO app_runtime_state "
    "(state_key, active_home_tarot_reading_id, updated_at_utc_us) "
    "VALUES ('main', NULL, 0)",
  );

  Future<void> _ensurePersonCoreIndexes() async {
    const statements = <String>[
      'CREATE INDEX IF NOT EXISTS persons_status_archive_idx ON persons (status, archived_at_utc_us)',
      'CREATE INDEX IF NOT EXISTS persons_display_name_idx ON persons (display_name)',
      'CREATE INDEX IF NOT EXISTS person_roles_person_period_idx ON person_roles (person_id, effective_from_utc_us)',
      'CREATE UNIQUE INDEX IF NOT EXISTS person_roles_active_unique ON person_roles (person_id, role_type) WHERE effective_to_utc_us IS NULL',
      "CREATE UNIQUE INDEX IF NOT EXISTS person_roles_single_active_self ON person_roles (role_type) WHERE role_type = 'self' AND effective_to_utc_us IS NULL",
      'CREATE INDEX IF NOT EXISTS person_relationships_from_idx ON person_relationships (from_person_id, effective_from_utc_us)',
      'CREATE INDEX IF NOT EXISTS person_relationships_to_idx ON person_relationships (to_person_id, effective_from_utc_us)',
      'CREATE INDEX IF NOT EXISTS person_birth_profiles_history_idx ON person_birth_profiles (person_id, revision_number)',
      'CREATE UNIQUE INDEX IF NOT EXISTS person_birth_profiles_current_unique ON person_birth_profiles (person_id) WHERE superseded_at_utc_us IS NULL',
      'CREATE INDEX IF NOT EXISTS encounters_person_occurred_idx ON encounters (person_id, occurred_at_utc_us DESC)',
      'CREATE INDEX IF NOT EXISTS encounters_person_follow_up_idx ON encounters (person_id, follow_up_at_utc_us)',
      'CREATE INDEX IF NOT EXISTS encounter_notes_encounter_recorded_idx ON encounter_notes (encounter_id, recorded_at_utc_us)',
    ];
    for (final statement in statements) {
      await customStatement(statement);
    }
  }
}
