import 'dart:collection';

final class TarotBackupManifest {
  TarotBackupManifest({
    required this.applicationVersion,
    required this.sourceRuntimeMode,
    required this.sourceEnvironment,
    required this.sourcePurpose,
    required this.createdAtUtc,
    required this.databasePayloadSizeBytes,
    required this.databasePayloadSha256,
    required List<String> requiredTables,
    required Map<String, List<String>> requiredColumnsByTable,
    required Map<String, int> tableRowCounts,
    required this.readingIdCount,
    required this.placementCount,
    required this.interpretationCount,
    required this.runtimeStateRowCount,
    required this.activeHomeReadingIdPresent,
    required Map<String, int> lifecycleStateCounts,
    required this.unsupportedTableRowsZero,
    required this.verifiedAtUtc,
  }) : requiredTables = List.unmodifiable(requiredTables),
       requiredColumnsByTable = UnmodifiableMapView(<String, List<String>>{
         for (final entry in requiredColumnsByTable.entries)
           entry.key: List.unmodifiable(entry.value),
       }),
       tableRowCounts = UnmodifiableMapView(Map.of(tableRowCounts)),
       lifecycleStateCounts = UnmodifiableMapView(Map.of(lifecycleStateCounts));

  static const int backupFormatVersion = 1;
  static const String applicationIdentity = 'RinVitalCenter/RynUniverseOS';
  static const String contentScope = 'person_core_tarot_persistence_v0_3';
  static const int schemaVersion = 6;
  static const String schemaV5RestorePolicy =
      'restore_with_schema_v5_application_then_reopen_to_migrate';
  static const String databasePayloadFilename =
      'data/ryn_universe_os_core_snapshot.sqlite';
  static const String checksumFilename = 'checksums/sha256.txt';
  static const String verificationResult = 'verified';

  static const List<String> canonicalFieldOrder = <String>[
    'backupFormatVersion',
    'applicationIdentity',
    'applicationVersion',
    'sourceRuntimeMode',
    'sourceEnvironment',
    'sourcePurpose',
    'contentScope',
    'createdAtUtc',
    'schemaVersion',
    'databasePayloadFilename',
    'databasePayloadSizeBytes',
    'databasePayloadSha256',
    'checksumFilename',
    'requiredTables',
    'requiredColumnsByTable',
    'tableRowCounts',
    'readingIdCount',
    'placementCount',
    'interpretationCount',
    'runtimeStateRowCount',
    'activeHomeReadingIdPresent',
    'lifecycleStateCounts',
    'unsupportedTableRowsZero',
    'verificationResult',
    'verifiedAtUtc',
  ];

  static const List<String> requiredTablesV1 = <String>[
    'app_settings',
    'obsidian_report_refs',
    'audit_trail',
    'missions',
    'task_cards',
    'agent_runs',
    'approval_records',
    'tarot_readings',
    'tarot_card_placements',
    'tarot_interpretations',
    'app_runtime_state',
    'persons',
    'person_roles',
    'person_relationships',
    'person_birth_profiles',
    'encounters',
    'encounter_notes',
  ];

  static const Map<String, List<String>> requiredColumnsByTableV1 =
      <String, List<String>>{
        'app_settings': <String>[
          'key',
          'value',
          'value_type',
          'redaction_state',
          'updated_at',
        ],
        'obsidian_report_refs': <String>[
          'id',
          'doc_type',
          'vault_path',
          'sha256',
          'redaction_state',
          'created_at',
          'updated_at',
        ],
        'audit_trail': <String>[
          'id',
          'occurred_at',
          'actor_type',
          'actor_id',
          'action',
          'target_type',
          'target_id',
          'before_hash',
          'after_hash',
          'redacted_snapshot',
          'redaction_state',
          'reason',
          'correlation_id',
          'created_at',
        ],
        'missions': <String>[
          'id',
          'title',
          'description',
          'status',
          'mode',
          'created_at',
          'updated_at',
          'archived_at',
        ],
        'task_cards': <String>[
          'id',
          'mission_id',
          'title',
          'description',
          'lane',
          'status',
          'priority',
          'order_key',
          'risk_level',
          'created_at',
          'updated_at',
          'archived_at',
        ],
        'agent_runs': <String>[
          'id',
          'mission_id',
          'task_card_id',
          'agent_name',
          'run_kind',
          'phase',
          'condition',
          'autonomy_level',
          'execution_target',
          'started_at',
          'ended_at',
          'summary',
          'error_text',
          'output_ref',
          'created_at',
          'updated_at',
        ],
        'approval_records': <String>[
          'id',
          'subject_type',
          'subject_id',
          'approval_type',
          'state',
          'requested_by',
          'requested_at',
          'decided_by',
          'decided_at',
          'decision',
          'decision_note',
          'successor_approval_id',
          'obsidian_ref_id',
          'created_at',
          'updated_at',
        ],
        'tarot_readings': <String>[
          'reading_instance_id',
          'source_type',
          'question_original_snapshot',
          'question_display_text',
          'deck_id',
          'deck_name_snapshot',
          'spread_id',
          'spread_name_snapshot',
          'expected_placement_count',
          'reading_at_utc_us',
          'reading_timezone_offset_min',
          'created_at_utc_us',
          'updated_at_utc_us',
          'lifecycle_status',
          'finished_at_utc_us',
        ],
        'tarot_card_placements': <String>[
          'reading_instance_id',
          'placement_order',
          'position_id',
          'position_name_snapshot',
          'card_id',
          'card_name_snapshot',
          'orientation',
        ],
        'tarot_interpretations': <String>[
          'reading_instance_id',
          'whole_image_observation',
          'flow_interpretation',
          'core_message',
          'small_action',
          'created_at_utc_us',
          'updated_at_utc_us',
        ],
        'app_runtime_state': <String>[
          'state_key',
          'active_home_tarot_reading_id',
          'updated_at_utc_us',
        ],
        'persons': <String>[
          'id',
          'display_name',
          'status',
          'relationship_summary',
          'first_met_on_utc_us',
          'archived_at_utc_us',
          'created_at_utc_us',
          'updated_at_utc_us',
        ],
        'person_roles': <String>[
          'id',
          'person_id',
          'role_type',
          'effective_from_utc_us',
          'effective_to_utc_us',
          'note',
          'created_at_utc_us',
          'updated_at_utc_us',
        ],
        'person_relationships': <String>[
          'id',
          'from_person_id',
          'to_person_id',
          'relationship_type',
          'effective_from_utc_us',
          'effective_to_utc_us',
          'note',
          'created_at_utc_us',
          'updated_at_utc_us',
        ],
        'person_birth_profiles': <String>[
          'id',
          'person_id',
          'revision_number',
          'birth_date',
          'birth_date_precision',
          'birth_time',
          'birth_time_precision',
          'birthplace_label',
          'time_zone_id',
          'utc_offset_minutes_at_birth',
          'calendar_system',
          'is_leap_month',
          'source_note',
          'verification_state',
          'supersedes_birth_profile_id',
          'superseded_at_utc_us',
          'created_at_utc_us',
        ],
        'encounters': <String>[
          'id',
          'person_id',
          'occurred_at_utc_us',
          'occurred_precision',
          'encounter_type',
          'title',
          'summary',
          'status',
          'follow_up_at_utc_us',
          'archived_at_utc_us',
          'created_at_utc_us',
          'updated_at_utc_us',
        ],
        'encounter_notes': <String>[
          'id',
          'encounter_id',
          'note_type',
          'body',
          'recorded_at_utc_us',
          'updated_at_utc_us',
          'supersedes_note_id',
          'superseded_at_utc_us',
          'redacted_at_utc_us',
        ],
      };

  final String applicationVersion;
  final String sourceRuntimeMode;
  final String sourceEnvironment;
  final String sourcePurpose;
  final DateTime createdAtUtc;
  final int databasePayloadSizeBytes;
  final String databasePayloadSha256;
  final List<String> requiredTables;
  final Map<String, List<String>> requiredColumnsByTable;
  final Map<String, int> tableRowCounts;
  final int readingIdCount;
  final int placementCount;
  final int interpretationCount;
  final int runtimeStateRowCount;
  final bool activeHomeReadingIdPresent;
  final Map<String, int> lifecycleStateCounts;
  final bool unsupportedTableRowsZero;
  final DateTime verifiedAtUtc;
}
