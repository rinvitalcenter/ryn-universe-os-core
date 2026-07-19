/// First global Drift schema marker retained for migration history.
const int plannedInitialSchemaVersion = 1;

/// Current global schema version.
///
/// Version 6 adds the approved Person Core foundation without changing the
/// existing governance or Tarot tables.
const int plannedCurrentSchemaVersion = 6;

/// Supported upgrades are truthful add-only 5 -> 6 and chained 4 -> 5 -> 6
/// migrations implemented by [RynAppDatabase.migration].
const String migrationImplementationStatus =
    'add_only_5_to_6_and_4_to_5_to_6_implemented';
