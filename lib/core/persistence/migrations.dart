/// Migration policy placeholder for the early Drift/SQLite schema slices.
///
/// No table migration, data migration, backup, restore, export, or destructive
/// operation is implemented in SCHEMA-DRAFT4.
///
/// Future schema tasks must define migration behavior together with tests before
/// introducing runtime data or destructive changes.
const int plannedInitialSchemaVersion = 1;

/// Current planned schema version after adding the minimal agent_runs and
/// approval_records schema slice. This is a version marker only; migration code
/// is not implemented in this task.
const int plannedCurrentSchemaVersion = 4;

/// Documentation marker for the current implementation boundary.
const String migrationImplementationStatus = 'schema_migrations_not_implemented';
