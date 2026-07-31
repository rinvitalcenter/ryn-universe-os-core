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
    this.payloadSchemaVersion = schemaVersion,
  }) : requiredTables = List.unmodifiable(requiredTables),
       requiredColumnsByTable = UnmodifiableMapView(<String, List<String>>{
         for (final entry in requiredColumnsByTable.entries)
           entry.key: List.unmodifiable(entry.value),
       }),
       tableRowCounts = UnmodifiableMapView(Map.of(tableRowCounts)),
       lifecycleStateCounts = UnmodifiableMapView(Map.of(lifecycleStateCounts));

  static const int backupFormatVersion = 1;
  static const String applicationIdentity = 'RinVitalCenter/RynUniverseOS';
  static const String legacyContentScope =
      'person_core_tarot_study_qigong_persistence_v0_5';
  static const String contentScope =
      'person_core_tarot_study_qigong_saju_persistence_v0_6';
  static const int schemaVersion = 11;
  static const int schemaVersionV10 = 10;
  static const int schemaVersionV9 = 9;
  static const int schemaVersionV8 = 8;
  static const int schemaVersionV7 = 7;
  static const int legacySchemaVersion = 6;
  static const Set<int> supportedRestoreSchemaVersions = <int>{
    legacySchemaVersion,
    schemaVersionV7,
    schemaVersionV8,
    schemaVersionV9,
    schemaVersionV10,
    schemaVersion,
  };
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

  static const List<String> requiredTablesV6 = <String>[
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

  static const Map<String, List<String>> requiredColumnsByTableV6 =
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

  static const List<String> requiredTablesV7 = <String>[
    ...requiredTablesV6,
    'person_groups',
    'person_group_memberships',
  ];

  static const Map<String, List<String>> requiredColumnsByTableV7 =
      <String, List<String>>{
        ...requiredColumnsByTableV6,
        'person_groups': <String>[
          'id',
          'name',
          'normalized_name',
          'archived_at_utc_us',
          'created_at_utc_us',
          'updated_at_utc_us',
        ],
        'person_group_memberships': <String>[
          'group_id',
          'person_id',
          'created_at_utc_us',
        ],
      };

  static const List<String> requiredTablesV8 = requiredTablesV7;
  static final Map<String, List<String>> requiredColumnsByTableV8 =
      Map.unmodifiable(<String, List<String>>{
        ...requiredColumnsByTableV7,
        'tarot_readings': <String>[
          'reading_instance_id',
          'source_type',
          'person_id',
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
      });

  static const List<String> requiredTablesV9 = <String>[
    ...requiredTablesV8,
    'study_sessions',
    'study_session_participants',
    'study_materials',
    'study_session_materials',
  ];

  static final Map<String, List<String>> requiredColumnsByTableV9 =
      Map.unmodifiable(<String, List<String>>{
        ...requiredColumnsByTableV8,
        'study_sessions': <String>[
          'id',
          'title',
          'occurred_at_utc_us',
          'timezone_offset_minutes',
          'location',
          'track',
          'status',
          'summary',
          'operation_notes',
          'learning_goal',
          'covered_content',
          'progress_status',
          'next_steps',
          'created_at_utc_us',
          'updated_at_utc_us',
        ],
        'study_session_participants': <String>[
          'session_id',
          'person_id',
          'attendance_status',
          'note',
          'learning_note',
          'created_at_utc_us',
          'updated_at_utc_us',
        ],
        'study_materials': <String>[
          'id',
          'title',
          'type',
          'url',
          'storage_note',
          'description',
          'created_at_utc_us',
          'updated_at_utc_us',
        ],
        'study_session_materials': <String>[
          'session_id',
          'material_id',
          'created_at_utc_us',
        ],
      });

  static const List<String> requiredTablesV10 = <String>[
    ...requiredTablesV9,
    'qigong_media_assets',
    'qigong_posts',
    'qigong_post_blocks',
    'qigong_post_media',
    'qigong_tags',
    'qigong_post_tags',
    'qigong_publications',
  ];

  static final Map<String, List<String>> requiredColumnsByTableV10 =
      Map.unmodifiable(<String, List<String>>{
        ...requiredColumnsByTableV9,
        'qigong_media_assets': <String>[
          'id',
          'sha256',
          'managed_relative_path',
          'original_file_name',
          'mime_type',
          'byte_size',
          'caption',
          'alt_text',
          'width',
          'height',
          'created_at_utc_us',
        ],
        'qigong_posts': <String>[
          'id',
          'title',
          'status',
          'practice_day_number',
          'occurred_at_utc_us',
          'duration_minutes',
          'location',
          'excerpt',
          'raw_memo',
          'personal_draft',
          'ai_working_draft',
          'image_prompt',
          'prompt_history_json',
          'keywords_json',
          'cover_media_id',
          'created_at_utc_us',
          'updated_at_utc_us',
          'archived_at_utc_us',
        ],
        'qigong_post_blocks': <String>[
          'id',
          'post_id',
          'block_order',
          'type',
          'text_content',
          'gallery_columns',
        ],
        'qigong_post_media': <String>[
          'id',
          'post_id',
          'block_id',
          'media_id',
          'media_order',
          'is_cover',
        ],
        'qigong_tags': <String>['id', 'name', 'normalized_name'],
        'qigong_post_tags': <String>['post_id', 'tag_id'],
        'qigong_publications': <String>[
          'post_id',
          'platform',
          'status',
          'external_title',
          'external_url',
          'published_at_utc_us',
          'platform_note',
        ],
      });

  static const List<String> requiredTablesV11 = <String>[
    ...requiredTablesV10,
    'saju_chart_snapshots',
  ];

  static final Map<String, List<String>> requiredColumnsByTableV11 =
      Map.unmodifiable(<String, List<String>>{
        ...requiredColumnsByTableV10,
        'saju_chart_snapshots': <String>[
          'id',
          'person_id',
          'source_birth_profile_id',
          'chart_group_id',
          'revision_number',
          'revision_reason',
          'created_at_utc_us',
          'calculated_at_utc_us',
          'calendar_type',
          'input_local_date',
          'input_local_time',
          'hour_unknown',
          'gender_compatibility_value',
          'original_lunar_year',
          'original_lunar_month',
          'original_lunar_day',
          'original_lunar_leap_month',
          'timezone_id',
          'birth_place_profile',
          'yaja_enabled',
          'converted_solar_date',
          'converted_lunar_date',
          'converted_lunar_leap_month',
          'birth_utc_instant_us',
          'utc_offset_at_birth_minutes',
          'effective_hour_calculation_time',
          'year_pillar_canonical_id',
          'year_pillar_cycle_index',
          'year_pillar_stem_index',
          'year_pillar_branch_index',
          'year_pillar_hanja',
          'year_pillar_korean_label',
          'month_pillar_canonical_id',
          'month_pillar_cycle_index',
          'month_pillar_stem_index',
          'month_pillar_branch_index',
          'month_pillar_hanja',
          'month_pillar_korean_label',
          'day_pillar_canonical_id',
          'day_pillar_cycle_index',
          'day_pillar_stem_index',
          'day_pillar_branch_index',
          'day_pillar_hanja',
          'day_pillar_korean_label',
          'hour_pillar_canonical_id',
          'hour_pillar_cycle_index',
          'hour_pillar_stem_index',
          'hour_pillar_branch_index',
          'hour_pillar_hanja',
          'hour_pillar_korean_label',
          'engine_id',
          'engine_version',
          'policy_id',
          'policy_version',
          'day_rollover_policy',
          'longitude_correction_policy',
          'dst_correction_policy',
          'supported_range_version',
          'solar_term_algorithm_version',
          'lunar_converter_version',
          'day_anchor_version',
          'time_scale_adapter_version',
          'warnings_json',
          'input_fingerprint_sha256',
          'calculation_signature_sha256',
        ],
      });

  /// Current backup-format-v1 physical inventory.
  static const List<String> requiredTablesV1 = requiredTablesV11;
  static final Map<String, List<String>> requiredColumnsByTableV1 =
      requiredColumnsByTableV11;

  static List<String> requiredTablesFor(int version) => switch (version) {
    legacySchemaVersion => requiredTablesV6,
    schemaVersionV7 => requiredTablesV7,
    schemaVersionV8 => requiredTablesV8,
    schemaVersionV9 => requiredTablesV9,
    schemaVersionV10 => requiredTablesV10,
    schemaVersion => requiredTablesV11,
    _ => const <String>[],
  };

  static Map<String, List<String>> requiredColumnsFor(int version) =>
      switch (version) {
        legacySchemaVersion => requiredColumnsByTableV6,
        schemaVersionV7 => requiredColumnsByTableV7,
        schemaVersionV8 => requiredColumnsByTableV8,
        schemaVersionV9 => requiredColumnsByTableV9,
        schemaVersionV10 => requiredColumnsByTableV10,
        schemaVersion => requiredColumnsByTableV11,
        _ => const <String, List<String>>{},
      };

  static String? contentScopeFor(int version) => switch (version) {
    legacySchemaVersion ||
    schemaVersionV7 ||
    schemaVersionV8 ||
    schemaVersionV9 ||
    schemaVersionV10 => legacyContentScope,
    schemaVersion => contentScope,
    _ => null,
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
  final int payloadSchemaVersion;
}
