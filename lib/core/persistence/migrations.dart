/// First global Drift schema marker retained for migration history.
const int plannedInitialSchemaVersion = 1;

/// Current global schema version.
///
/// Version 8 adds one nullable canonical Person reference to Tarot readings.
const int plannedCurrentSchemaVersion = 10;

/// Supported upgrades remain truthful and add-only through schema version 8.
const String migrationImplementationStatus =
    'add_only_7_to_8_with_4_5_and_6_chained_to_8_implemented';
