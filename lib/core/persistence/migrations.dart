/// First global Drift schema marker retained for migration history.
const int plannedInitialSchemaVersion = 1;

/// Current global schema version.
///
/// Version 8 adds one nullable canonical Person reference to Tarot readings.
const int plannedCurrentSchemaVersion = 11;

/// Supported upgrades remain truthful and add-only through schema version 11.
const String migrationImplementationStatus =
    'add_only_10_to_11_saju_snapshot_with_4_through_9_chained_implemented';
