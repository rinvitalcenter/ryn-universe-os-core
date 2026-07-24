/// First global Drift schema marker retained for migration history.
const int plannedInitialSchemaVersion = 1;

/// Current global schema version.
///
/// Version 7 adds persistent custom Person groups and memberships without
/// changing the meaning of existing Person, Role, governance, or Tarot data.
const int plannedCurrentSchemaVersion = 7;

/// Supported upgrades remain truthful and add-only through schema version 7.
const String migrationImplementationStatus =
    'add_only_6_to_7_with_4_and_5_chained_to_7_implemented';
