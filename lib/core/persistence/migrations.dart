/// First global Drift schema marker retained for migration history.
const int plannedInitialSchemaVersion = 1;

/// Current global schema version.
///
/// Version 5 adds only the approved Tarot aggregate tables and typed Home
/// singleton state to the existing version 4 governance schema.
const int plannedCurrentSchemaVersion = 5;

/// The only supported upgrade in this phase is the truthful add-only 4 -> 5
/// migration implemented by [RynAppDatabase.migration].
const String migrationImplementationStatus = 'add_only_4_to_5_implemented';
