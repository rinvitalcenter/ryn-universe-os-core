import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../../../../../core/persistence/app_database.dart';
import '../../../saju/data/persistence/saju_snapshot_persistence_mapper.dart';
import '../domain/tarot_backup_manifest.dart';

typedef TarotInspectorDatabaseOpen =
    Database Function(String filename, OpenMode mode, bool uri);
typedef TarotInspectorDatabaseClose = void Function(Database database);

enum TarotDatabaseInspectionPolicy {
  normalReadOnlySource,
  immutableReadOnlyFrozenTarget,
}

final class TarotBackupDatabaseInspector {
  const TarotBackupDatabaseInspector({
    this.openDatabase = _openInspectorDatabase,
    this.closeDatabase = _closeInspectorDatabase,
  });

  final TarotInspectorDatabaseOpen openDatabase;
  final TarotInspectorDatabaseClose closeDatabase;

  static const List<String> _unsupportedTables = <String>[
    'app_settings',
    'obsidian_report_refs',
    'audit_trail',
    'missions',
    'task_cards',
    'agent_runs',
    'approval_records',
  ];

  TarotDatabaseEvidence inspect(
    String databasePath, {
    TarotDatabaseInspectionPolicy policy =
        TarotDatabaseInspectionPolicy.normalReadOnlySource,
  }) {
    Database? database;
    TarotDatabaseEvidence? evidence;
    TarotBackupInspectionException? failure;
    try {
      final immutableTarget =
          policy == TarotDatabaseInspectionPolicy.immutableReadOnlyFrozenTarget;
      database = openDatabase(
        immutableTarget ? _immutableReadOnlyUri(databasePath) : databasePath,
        OpenMode.readOnly,
        immutableTarget,
      );
      database.execute('PRAGMA query_only = ON');
      final schemaVersion = database.userVersion;
      if (schemaVersion == 5) {
        throw const TarotBackupInspectionException(
          'schema_v5_restore_requires_v5_application',
        );
      }
      final requiredTables = TarotBackupManifest.requiredTablesFor(
        schemaVersion,
      );
      final requiredColumns = TarotBackupManifest.requiredColumnsFor(
        schemaVersion,
      );
      if (requiredTables.isEmpty) {
        throw const TarotBackupInspectionException('schema_version_mismatch');
      }
      final tableNames = database
          .select("SELECT name FROM sqlite_master WHERE type = 'table'")
          .map((row) => row['name']! as String)
          .toSet();
      final tableExistence = <String, bool>{
        for (final table in requiredTables) table: tableNames.contains(table),
      };
      final columnResults = <String, bool>{};
      final exactColumnResults = <String, bool>{};
      for (final table in requiredTables) {
        if (!tableNames.contains(table)) {
          columnResults[table] = false;
          exactColumnResults[table] = false;
          continue;
        }
        final actual = database
            .select('PRAGMA table_info("$table")')
            .map((row) => row['name']! as String)
            .toSet();
        final required = requiredColumns[table]!;
        columnResults[table] = required.every(actual.contains);
        exactColumnResults[table] = _sameSet(actual, required.toSet());
      }
      final applicationTables = tableNames
          .where((table) => !table.toLowerCase().startsWith('sqlite_'))
          .toSet();
      final unexpectedTablesAbsent = _sameSet(
        applicationTables,
        requiredTables.toSet(),
      );

      final rowCounts = <String, int>{};
      for (final table in requiredTables) {
        rowCounts[table] = tableNames.contains(table)
            ? _scalar(database, 'SELECT count(*) FROM "$table"')
            : 0;
      }
      final hasTarotTables = <String>[
        'tarot_readings',
        'tarot_card_placements',
        'tarot_interpretations',
        'app_runtime_state',
      ].every(tableNames.contains);
      final tarotAggregate = hasTarotTables
          ? _inspectAggregate(database, schemaVersion: schemaVersion)
          : const _AggregateEvidence.invalid();
      final hasPersonCoreTables = <String>[
        'persons',
        'person_roles',
        'person_relationships',
        'person_birth_profiles',
        'encounters',
        'encounter_notes',
      ].every(tableNames.contains);
      final personCoreInvariantsOk =
          hasPersonCoreTables && _inspectPersonCore(database);
      final personSchemaContractOk =
          hasPersonCoreTables &&
          _inspectPersonSchemaContract(
            database,
            includeGroups: schemaVersion >= TarotBackupManifest.schemaVersionV7,
          );
      final groupInvariantsOk =
          schemaVersion == TarotBackupManifest.legacySchemaVersion ||
          _inspectPersonGroups(database);
      final tarotPersonSchemaContractOk =
          hasTarotTables &&
          _inspectTarotPersonSchemaContract(database, schemaVersion);
      final hasStudyTables = <String>[
        'study_sessions',
        'study_session_participants',
        'study_materials',
        'study_session_materials',
      ].every(tableNames.contains);
      final studySchemaContractOk =
          schemaVersion < TarotBackupManifest.schemaVersionV9 ||
          (hasStudyTables && _inspectStudySchemaContract(database));
      final studyInvariantsOk =
          schemaVersion < TarotBackupManifest.schemaVersionV9 ||
          (hasStudyTables && _inspectStudyInvariants(database));
      final hasQigongTables = <String>[
        'qigong_posts',
        'qigong_post_blocks',
        'qigong_media_assets',
        'qigong_post_media',
        'qigong_tags',
        'qigong_post_tags',
        'qigong_publications',
      ].every(tableNames.contains);
      final qigongSchemaContractOk =
          schemaVersion < TarotBackupManifest.schemaVersionV10 ||
          (hasQigongTables && _inspectQigongSchemaContract(database));
      final qigongInvariantsOk =
          schemaVersion < TarotBackupManifest.schemaVersionV10 ||
          (hasQigongTables && _inspectQigongInvariants(database));
      final hasSajuTable = tableNames.contains('saju_chart_snapshots');
      final sajuSchemaContractOk =
          schemaVersion < TarotBackupManifest.schemaVersion ||
          (hasSajuTable && _inspectSajuSchemaContract(database));
      final sajuInvariantsOk =
          schemaVersion < TarotBackupManifest.schemaVersion ||
          (hasSajuTable && _inspectSajuInvariants(database));
      final integrityCheckOk =
          database.select('PRAGMA integrity_check').length == 1 &&
          database.select('PRAGMA integrity_check').first.values.first == 'ok';
      final foreignKeyCheckOk = database
          .select('PRAGMA foreign_key_check')
          .isEmpty;
      final unsupportedRowsZero = _unsupportedTables.every(
        (table) => (rowCounts[table] ?? 0) == 0,
      );

      evidence = TarotDatabaseEvidence(
        schemaVersion: schemaVersion,
        tableExistence: tableExistence,
        requiredColumnResults: columnResults,
        exactColumnResults: exactColumnResults,
        unexpectedTablesAbsent: unexpectedTablesAbsent,
        tableRowCounts: rowCounts,
        readingRowCount: rowCounts['tarot_readings'] ?? 0,
        distinctReadingIdCount: tarotAggregate.distinctReadingIdCount,
        placementCount: rowCounts['tarot_card_placements'] ?? 0,
        interpretationCount: rowCounts['tarot_interpretations'] ?? 0,
        runtimeStateRowCount: rowCounts['app_runtime_state'] ?? 0,
        lifecycleStateCounts: tarotAggregate.lifecycleStateCounts,
        activeHomeReadingIdPresent: tarotAggregate.activeHomeReadingIdPresent,
        unsupportedTableRowsZero: unsupportedRowsZero,
        integrityCheckOk: integrityCheckOk,
        foreignKeyCheckOk: foreignKeyCheckOk,
        schemaContractOk:
            personSchemaContractOk &&
            tarotPersonSchemaContractOk &&
            studySchemaContractOk &&
            qigongSchemaContractOk &&
            sajuSchemaContractOk,
        aggregateInvariantsOk:
            tarotAggregate.valid &&
            personCoreInvariantsOk &&
            groupInvariantsOk &&
            studyInvariantsOk &&
            qigongInvariantsOk &&
            sajuInvariantsOk,
        freelistCount: _scalar(database, 'PRAGMA freelist_count'),
        hasUnexpectedNonEmptySidecar: false,
      );
    } on TarotBackupInspectionException catch (error) {
      failure = error;
    } on Object {
      failure = const TarotBackupInspectionException(
        'database_inspection_failed',
      );
    }
    if (database != null) {
      try {
        closeDatabase(database);
      } on Object {
        failure = TarotBackupInspectionException(
          failure?.code ?? 'database_close_failed',
          closeUnresolved: true,
        );
      }
    }
    if (failure == null) {
      evidence = evidence!.withSidecarState(_hasNonEmptySidecar(databasePath));
    }
    if (failure != null) throw failure;
    return evidence!;
  }

  TarotDatabaseEvidence inspectVerified(
    String databasePath, {
    TarotDatabaseInspectionPolicy policy =
        TarotDatabaseInspectionPolicy.normalReadOnlySource,
    bool requireAcceptableSidecars = false,
    Set<int> acceptedSchemaVersions = const <int>{
      TarotBackupManifest.schemaVersion,
    },
  }) {
    final evidence = inspect(databasePath, policy: policy);
    if (evidence.schemaVersion == 5) {
      throw const TarotBackupInspectionException(
        'schema_v5_restore_requires_v5_application',
      );
    }
    if (!acceptedSchemaVersions.contains(evidence.schemaVersion)) {
      throw const TarotBackupInspectionException('schema_version_mismatch');
    }
    if (!evidence.requiredTablesPresent) {
      throw const TarotBackupInspectionException('required_table_missing');
    }
    if (!evidence.unexpectedTablesAbsent) {
      throw const TarotBackupInspectionException('unexpected_table_present');
    }
    if (!evidence.requiredColumnsPresent) {
      throw const TarotBackupInspectionException('required_column_missing');
    }
    if (!evidence.exactColumnsMatch) {
      throw const TarotBackupInspectionException('unexpected_column_present');
    }
    if (!evidence.integrityCheckOk) {
      throw const TarotBackupInspectionException('integrity_check_failed');
    }
    if (!evidence.foreignKeyCheckOk) {
      throw const TarotBackupInspectionException('foreign_key_check_failed');
    }
    if (!evidence.schemaContractOk) {
      throw const TarotBackupInspectionException('schema_contract_mismatch');
    }
    if (!evidence.unsupportedTableRowsZero) {
      throw const TarotBackupInspectionException('unsupported_table_nonzero');
    }
    if (!evidence.aggregateInvariantsOk) {
      throw const TarotBackupInspectionException('aggregate_invariant_failed');
    }
    if (requireAcceptableSidecars && evidence.hasUnexpectedNonEmptySidecar) {
      throw const TarotBackupInspectionException('target_sidecar_unsafe');
    }
    return evidence;
  }

  _AggregateEvidence _inspectAggregate(
    Database database, {
    required int schemaVersion,
  }) {
    final readingRow = database
        .select(
          'SELECT count(*) AS total, '
          'count(DISTINCT reading_instance_id) AS distinct_total '
          'FROM tarot_readings',
        )
        .single;
    final invalidPlacementAggregates = _scalar(
      database,
      '''SELECT count(*) FROM tarot_readings r WHERE
        (SELECT count(*) FROM tarot_card_placements p
          WHERE p.reading_instance_id = r.reading_instance_id)
            != r.expected_placement_count OR
        (SELECT min(placement_order) FROM tarot_card_placements p
          WHERE p.reading_instance_id = r.reading_instance_id) != 1 OR
        (SELECT max(placement_order) FROM tarot_card_placements p
          WHERE p.reading_instance_id = r.reading_instance_id)
            != r.expected_placement_count OR
        (SELECT count(DISTINCT placement_order) FROM tarot_card_placements p
          WHERE p.reading_instance_id = r.reading_instance_id)
            != r.expected_placement_count OR
        (SELECT count(DISTINCT position_id) FROM tarot_card_placements p
          WHERE p.reading_instance_id = r.reading_instance_id)
            != r.expected_placement_count''',
    );
    final invalidEnums = _scalar(database, '''SELECT
        (SELECT count(*) FROM tarot_card_placements
          WHERE orientation NOT IN ('not_used', 'upright', 'reversed')) +
        (SELECT count(*) FROM tarot_readings
          WHERE source_type NOT IN ('self_drawn', 'manually_recorded')) +
        (SELECT count(*) FROM tarot_readings
          WHERE lifecycle_status NOT IN ('continuing', 'finished'))''');
    final invalidFinishedState = _scalar(
      database,
      '''SELECT count(*) FROM tarot_readings WHERE
        (lifecycle_status = 'continuing' AND finished_at_utc_us IS NOT NULL) OR
        (lifecycle_status = 'finished' AND finished_at_utc_us IS NULL)''',
    );
    final orphanPlacements = _scalar(
      database,
      '''SELECT count(*) FROM tarot_card_placements p
        LEFT JOIN tarot_readings r
          ON r.reading_instance_id = p.reading_instance_id
        WHERE r.reading_instance_id IS NULL''',
    );
    final orphanInterpretations = _scalar(
      database,
      '''SELECT count(*) FROM tarot_interpretations i
        LEFT JOIN tarot_readings r
          ON r.reading_instance_id = i.reading_instance_id
        WHERE r.reading_instance_id IS NULL''',
    );
    final orphanPersonLinks =
        schemaVersion >= TarotBackupManifest.schemaVersionV8
        ? _scalar(database, '''SELECT count(*) FROM tarot_readings r
              LEFT JOIN persons p ON p.id = r.person_id
              WHERE r.person_id IS NOT NULL AND p.id IS NULL''')
        : 0;
    final duplicateInterpretations = _scalar(database, '''SELECT count(*) FROM (
        SELECT reading_instance_id FROM tarot_interpretations
        GROUP BY reading_instance_id HAVING count(*) > 1
      )''');
    final invalidRuntimeState = _scalar(
      database,
      "SELECT count(*) FROM app_runtime_state WHERE state_key != 'main'",
    );
    final runtimeCount = _scalar(
      database,
      'SELECT count(*) FROM app_runtime_state',
    );
    final invalidActiveHome = _scalar(
      database,
      '''SELECT count(*) FROM app_runtime_state s
        LEFT JOIN tarot_readings r
          ON r.reading_instance_id = s.active_home_tarot_reading_id
        WHERE s.active_home_tarot_reading_id IS NOT NULL AND
          (r.reading_instance_id IS NULL OR r.lifecycle_status != 'continuing')''',
    );
    final lifecycleCounts = <String, int>{
      'continuing': _scalar(
        database,
        "SELECT count(*) FROM tarot_readings WHERE lifecycle_status = 'continuing'",
      ),
      'finished': _scalar(
        database,
        "SELECT count(*) FROM tarot_readings WHERE lifecycle_status = 'finished'",
      ),
    };
    final activePresent =
        _scalar(
          database,
          'SELECT count(*) FROM app_runtime_state '
          'WHERE active_home_tarot_reading_id IS NOT NULL',
        ) ==
        1;
    final distinctCount = readingRow['distinct_total']! as int;
    final readingCount = readingRow['total']! as int;
    return _AggregateEvidence(
      distinctReadingIdCount: distinctCount,
      lifecycleStateCounts: lifecycleCounts,
      activeHomeReadingIdPresent: activePresent,
      valid:
          distinctCount == readingCount &&
          invalidPlacementAggregates == 0 &&
          invalidEnums == 0 &&
          invalidFinishedState == 0 &&
          orphanPlacements == 0 &&
          orphanInterpretations == 0 &&
          orphanPersonLinks == 0 &&
          duplicateInterpretations == 0 &&
          runtimeCount == 1 &&
          invalidRuntimeState == 0 &&
          invalidActiveHome == 0,
    );
  }

  bool _inspectTarotPersonSchemaContract(Database database, int schemaVersion) {
    final foreignKeys = database
        .select('PRAGMA foreign_key_list("tarot_readings")')
        .map(
          (row) =>
              '${row['from']}|${row['table']}|${row['to']}|'
                      '${row['on_update']}|${row['on_delete']}'
                  .toLowerCase(),
        )
        .toList(growable: false);
    final expected = schemaVersion >= TarotBackupManifest.schemaVersionV8
        ? const <String>{'person_id|persons|id|no action|restrict'}
        : const <String>{};
    return foreignKeys.length == expected.length &&
        _sameSet(foreignKeys.toSet(), expected);
  }

  bool _inspectStudySchemaContract(Database database) {
    Set<String> foreignKeys(String table) => database
        .select('PRAGMA foreign_key_list("$table")')
        .map(
          (row) =>
              '${row['from']}|${row['table']}|${row['to']}|'
                      '${row['on_update']}|${row['on_delete']}'
                  .toLowerCase(),
        )
        .toSet();

    return _sameSet(foreignKeys('study_session_participants'), const <String>{
          'session_id|study_sessions|id|no action|cascade',
          'person_id|persons|id|no action|restrict',
        }) &&
        _sameSet(foreignKeys('study_session_materials'), const <String>{
          'session_id|study_sessions|id|no action|cascade',
          'material_id|study_materials|id|no action|restrict',
        });
  }

  bool _inspectStudyInvariants(Database database) {
    final invalidEnums = _scalar(
      database,
      '''SELECT
      (SELECT count(*) FROM study_sessions
        WHERE track NOT IN ('tarot', 'saju', 'mixed')
          OR status NOT IN ('planned', 'completed', 'cancelled')
          OR progress_status NOT IN
            ('not_started', 'in_progress', 'completed', 'deferred')) +
      (SELECT count(*) FROM study_session_participants
        WHERE attendance_status NOT IN
          ('planned', 'attended', 'absent', 'late', 'cancelled')) +
      (SELECT count(*) FROM study_materials
        WHERE type NOT IN
          ('handout', 'card_news', 'web_page', 'video', 'book', 'practice', 'other'))''',
    );
    final invalidValues = _scalar(database, '''SELECT
      (SELECT count(*) FROM study_sessions
        WHERE length(trim(id)) = 0 OR length(trim(title)) = 0
          OR length(trim(location)) = 0
          OR timezone_offset_minutes NOT BETWEEN -840 AND 840
          OR updated_at_utc_us < created_at_utc_us) +
      (SELECT count(*) FROM study_session_participants
        WHERE updated_at_utc_us < created_at_utc_us) +
      (SELECT count(*) FROM study_materials
        WHERE length(trim(id)) = 0 OR length(trim(title)) = 0
          OR updated_at_utc_us < created_at_utc_us)''');
    return invalidEnums == 0 && invalidValues == 0;
  }

  bool _inspectSajuSchemaContract(Database database) {
    const nullableColumns = <String>{
      'source_birth_profile_id',
      'input_local_time',
      'original_lunar_year',
      'original_lunar_month',
      'original_lunar_day',
      'original_lunar_leap_month',
      'birth_utc_instant_us',
      'effective_hour_calculation_time',
      'hour_pillar_canonical_id',
      'hour_pillar_cycle_index',
      'hour_pillar_stem_index',
      'hour_pillar_branch_index',
      'hour_pillar_hanja',
      'hour_pillar_korean_label',
    };
    final tableInfo = database
        .select('PRAGMA table_info("saju_chart_snapshots")')
        .toList(growable: false);
    if (tableInfo.length != 65) return false;
    for (final row in tableInfo) {
      final name = row['name'] as String;
      final notNull = row['notnull'] == 1;
      final primaryKeyOrder = row['pk'] as int;
      if (notNull == nullableColumns.contains(name) ||
          primaryKeyOrder != (name == 'id' ? 1 : 0)) {
        return false;
      }
    }

    final foreignKeys = database
        .select('PRAGMA foreign_key_list("saju_chart_snapshots")')
        .map(
          (row) =>
              '${row['from']}|${row['table']}|${row['to']}|'
                      '${row['on_update']}|${row['on_delete']}'
                  .toLowerCase(),
        )
        .toSet();
    final userIndexes = <String, String>{
      for (final row in database.select(
        "SELECT name, sql FROM sqlite_master WHERE type = 'index' "
        "AND tbl_name = 'saju_chart_snapshots' AND sql IS NOT NULL",
      ))
        row['name'] as String: _normalizeSchemaSql(row['sql'] as String),
    };
    const expectedIndexSql = <String, String>{
      'saju_snapshots_person_calculated_idx':
          'CREATE INDEX saju_snapshots_person_calculated_idx '
          'ON saju_chart_snapshots (person_id, calculated_at_utc_us DESC)',
      'saju_snapshots_person_group_revision_idx':
          'CREATE INDEX saju_snapshots_person_group_revision_idx '
          'ON saju_chart_snapshots '
          '(person_id, chart_group_id, revision_number DESC)',
      'saju_snapshots_person_birth_date_idx':
          'CREATE INDEX saju_snapshots_person_birth_date_idx '
          'ON saju_chart_snapshots (person_id, converted_solar_date)',
    };
    final uniqueContracts = database
        .select('PRAGMA index_list("saju_chart_snapshots")')
        .where((row) => row['unique'] == 1 && row['origin'] == 'u')
        .map((row) {
          final name = row['name'] as String;
          final escaped = name.replaceAll('"', '""');
          return database
              .select('PRAGMA index_info("$escaped")')
              .map((column) => column['name'] as String)
              .join(',');
        })
        .toSet();

    return _sameSet(uniqueContracts, const <String>{
          'chart_group_id,revision_number',
          'person_id,input_fingerprint_sha256,calculation_signature_sha256',
        }) &&
        _inspectSajuCheckContract(database) &&
        _sameSet(foreignKeys, const <String>{
          'person_id|persons|id|no action|restrict',
          'source_birth_profile_id|person_birth_profiles|id|no action|restrict',
        }) &&
        _sameSet(userIndexes.keys.toSet(), expectedIndexSql.keys.toSet()) &&
        expectedIndexSql.entries.every(
          (entry) =>
              userIndexes[entry.key] == _normalizeSchemaSql(entry.value),
        );
  }

  bool _inspectSajuCheckContract(Database database) {
    const expectedExpressions = <String>{
      'hour_unknown IN (0, 1)',
      'original_lunar_leap_month IN (0, 1)',
      'yaja_enabled IN (0, 1)',
      'converted_lunar_leap_month IN (0, 1)',
      'length(trim(id)) BETWEEN 1 AND 120',
      'length(trim(person_id)) BETWEEN 1 AND 120',
      'source_birth_profile_id IS NULL OR length(trim(source_birth_profile_id)) BETWEEN 1 AND 120',
      'length(trim(chart_group_id)) BETWEEN 1 AND 120',
      'revision_number >= 1',
      "revision_reason IN ('initial','inputCorrected','engineUpdated','policyUpdated','calculationErrorCorrected','birthPlaceProfileChanged')",
      "(revision_number = 1 AND revision_reason = 'initial') OR (revision_number > 1 AND revision_reason != 'initial')",
      'created_at_utc_us >= 0',
      'calculated_at_utc_us >= 0',
      "calendar_type IN ('solar','koreanLunar')",
      "gender_compatibility_value IN ('male','female','unspecified')",
      'length(trim(input_local_date)) > 0 AND length(trim(converted_solar_date)) > 0 AND length(trim(converted_lunar_date)) > 0',
      "(calendar_type = 'solar' AND original_lunar_year IS NULL AND original_lunar_month IS NULL AND original_lunar_day IS NULL AND original_lunar_leap_month IS NULL) OR (calendar_type = 'koreanLunar' AND original_lunar_year IS NOT NULL AND original_lunar_month BETWEEN 1 AND 12 AND original_lunar_day BETWEEN 1 AND 30 AND original_lunar_leap_month IS NOT NULL)",
      "timezone_id = 'Asia/Seoul'",
      "birth_place_profile = 'seoulCompatibilityV1'",
      'yaja_enabled = 0',
      'utc_offset_at_birth_minutes = 540',
      '(hour_unknown = 1 AND input_local_time IS NULL AND birth_utc_instant_us IS NULL AND effective_hour_calculation_time IS NULL AND hour_pillar_canonical_id IS NULL AND hour_pillar_cycle_index IS NULL AND hour_pillar_stem_index IS NULL AND hour_pillar_branch_index IS NULL AND hour_pillar_hanja IS NULL AND hour_pillar_korean_label IS NULL) OR (hour_unknown = 0 AND input_local_time IS NOT NULL AND birth_utc_instant_us IS NOT NULL AND effective_hour_calculation_time IS NOT NULL AND hour_pillar_canonical_id IS NOT NULL AND hour_pillar_cycle_index IS NOT NULL AND hour_pillar_stem_index IS NOT NULL AND hour_pillar_branch_index IS NOT NULL AND hour_pillar_hanja IS NOT NULL AND hour_pillar_korean_label IS NOT NULL)',
      'year_pillar_cycle_index BETWEEN 0 AND 59 AND year_pillar_stem_index = year_pillar_cycle_index % 10 AND year_pillar_branch_index = year_pillar_cycle_index % 12',
      'month_pillar_cycle_index BETWEEN 0 AND 59 AND month_pillar_stem_index = month_pillar_cycle_index % 10 AND month_pillar_branch_index = month_pillar_cycle_index % 12',
      'day_pillar_cycle_index BETWEEN 0 AND 59 AND day_pillar_stem_index = day_pillar_cycle_index % 10 AND day_pillar_branch_index = day_pillar_cycle_index % 12',
      'hour_pillar_cycle_index IS NULL OR (hour_pillar_cycle_index BETWEEN 0 AND 59 AND hour_pillar_stem_index = hour_pillar_cycle_index % 10 AND hour_pillar_branch_index = hour_pillar_cycle_index % 12)',
      'length(year_pillar_canonical_id) = 13 AND length(year_pillar_hanja) = 2 AND length(year_pillar_korean_label) = 2 AND length(month_pillar_canonical_id) = 13 AND length(month_pillar_hanja) = 2 AND length(month_pillar_korean_label) = 2 AND length(day_pillar_canonical_id) = 13 AND length(day_pillar_hanja) = 2 AND length(day_pillar_korean_label) = 2',
      'hour_pillar_canonical_id IS NULL OR (length(hour_pillar_canonical_id) = 13 AND length(hour_pillar_hanja) = 2 AND length(hour_pillar_korean_label) = 2)',
      'length(trim(engine_id)) > 0 AND length(trim(engine_version)) > 0 AND length(trim(policy_id)) > 0 AND length(trim(policy_version)) > 0 AND length(trim(day_rollover_policy)) > 0 AND length(trim(longitude_correction_policy)) > 0 AND length(trim(dst_correction_policy)) > 0 AND length(trim(supported_range_version)) > 0 AND length(trim(solar_term_algorithm_version)) > 0 AND length(trim(lunar_converter_version)) > 0 AND length(trim(day_anchor_version)) > 0 AND length(trim(time_scale_adapter_version)) > 0',
      'length(warnings_json) >= 2',
      "length(input_fingerprint_sha256) = 64 AND input_fingerprint_sha256 NOT GLOB '*[^0-9a-f]*'",
      "length(calculation_signature_sha256) = 64 AND calculation_signature_sha256 NOT GLOB '*[^0-9a-f]*'",
    };
    final rows = database.select(
      "SELECT sql FROM sqlite_master WHERE type = 'table' "
      "AND name = 'saju_chart_snapshots'",
    );
    if (rows.length != 1 || rows.single['sql'] is! String) return false;
    final actual = _extractCheckExpressions(rows.single['sql'] as String);
    if (actual == null) return false;
    final expected = expectedExpressions.map(_normalizeSchemaSql).toSet();
    return actual.length == expectedExpressions.length &&
        _sameSet(actual, expected);
  }

  Set<String>? _extractCheckExpressions(String tableSql) {
    final result = <String>{};
    final lower = tableSql.toLowerCase();
    var cursor = 0;
    while (true) {
      final match = RegExp(r'\bcheck\s*\(').firstMatch(lower.substring(cursor));
      if (match == null) break;
      final matchStart = cursor + match.start;
      final open = tableSql.indexOf('(', matchStart);
      var depth = 0;
      var quoted = false;
      var close = -1;
      for (var index = open; index < tableSql.length; index++) {
        final character = tableSql[index];
        if (character == "'") {
          if (quoted &&
              index + 1 < tableSql.length &&
              tableSql[index + 1] == "'") {
            index += 1;
            continue;
          }
          quoted = !quoted;
          continue;
        }
        if (quoted) continue;
        if (character == '(') depth += 1;
        if (character == ')') {
          depth -= 1;
          if (depth == 0) {
            close = index;
            break;
          }
        }
      }
      if (close < 0 || quoted) return null;
      final expression = _normalizeSchemaSql(
        tableSql.substring(open + 1, close),
      );
      if (!result.add(expression)) return null;
      cursor = close + 1;
    }
    return result;
  }

  String _normalizeSchemaSql(String value) => value
      .replaceAll('"', '')
      .replaceAll(RegExp(r'\s+'), '')
      .toLowerCase();

  bool _inspectSajuInvariants(Database database) {
    final invalidRelationships = _scalar(database, '''SELECT count(*)
      FROM saju_chart_snapshots s
      LEFT JOIN persons p ON p.id = s.person_id
      LEFT JOIN person_birth_profiles b ON b.id = s.source_birth_profile_id
      WHERE p.id IS NULL OR
        (s.source_birth_profile_id IS NOT NULL AND
          (b.id IS NULL OR b.person_id != s.person_id))''');
    final invalidRevisionChains = _scalar(database, '''SELECT count(*) FROM (
      SELECT chart_group_id
      FROM saju_chart_snapshots
      GROUP BY chart_group_id
      HAVING min(revision_number) != 1 OR
        max(revision_number) != count(*) OR
        sum(CASE WHEN revision_number = 1 AND revision_reason = 'initial'
          THEN 0 WHEN revision_number > 1 AND revision_reason != 'initial'
          THEN 0 ELSE 1 END) != 0
    )''');
    final invalidValues = _scalar(database, '''SELECT count(*)
      FROM saju_chart_snapshots
      WHERE length(trim(id)) NOT BETWEEN 1 AND 120 OR
        length(trim(person_id)) NOT BETWEEN 1 AND 120 OR
        length(trim(chart_group_id)) NOT BETWEEN 1 AND 120 OR
        revision_number < 1 OR created_at_utc_us < 0 OR
        calculated_at_utc_us < 0 OR
        timezone_id != 'Asia/Seoul' OR
        birth_place_profile != 'seoulCompatibilityV1' OR
        yaja_enabled != 0 OR
        calendar_type NOT IN ('solar', 'koreanLunar') OR
        length(input_fingerprint_sha256) != 64 OR
        input_fingerprint_sha256 GLOB '*[^0-9a-f]*' OR
        length(calculation_signature_sha256) != 64 OR
        calculation_signature_sha256 GLOB '*[^0-9a-f]*' OR
        (calendar_type = 'solar' AND
          (original_lunar_year IS NOT NULL OR original_lunar_month IS NOT NULL OR
           original_lunar_day IS NOT NULL OR original_lunar_leap_month IS NOT NULL)) OR
        (calendar_type = 'koreanLunar' AND
          (original_lunar_year IS NULL OR original_lunar_month IS NULL OR
           original_lunar_day IS NULL OR original_lunar_leap_month IS NULL)) OR
        (hour_unknown = 1 AND
          (input_local_time IS NOT NULL OR birth_utc_instant_us IS NOT NULL OR
           effective_hour_calculation_time IS NOT NULL OR
           hour_pillar_canonical_id IS NOT NULL OR
           hour_pillar_cycle_index IS NOT NULL OR
           hour_pillar_stem_index IS NOT NULL OR
           hour_pillar_branch_index IS NOT NULL OR
           hour_pillar_hanja IS NOT NULL OR
           hour_pillar_korean_label IS NOT NULL)) OR
        (hour_unknown = 0 AND
          (input_local_time IS NULL OR birth_utc_instant_us IS NULL OR
           effective_hour_calculation_time IS NULL OR
           hour_pillar_canonical_id IS NULL OR
           hour_pillar_cycle_index IS NULL OR
           hour_pillar_stem_index IS NULL OR
           hour_pillar_branch_index IS NULL OR
           hour_pillar_hanja IS NULL OR
           hour_pillar_korean_label IS NULL))''');
    if (invalidRelationships != 0 ||
        invalidRevisionChains != 0 ||
        invalidValues != 0) {
      return false;
    }
    try {
      const mapper = SajuSnapshotPersistenceMapper();
      for (final row in database.select('SELECT * FROM saju_chart_snapshots')) {
        mapper.fromRow(_sajuRow(row));
      }
      return true;
    } on Object {
      return false;
    }
  }

  bool _inspectQigongSchemaContract(Database database) {
    Set<String> foreignKeys(String table) => database
        .select('PRAGMA foreign_key_list("$table")')
        .map(
          (row) =>
              '${row['from']}|${row['table']}|${row['to']}|'
                      '${row['on_update']}|${row['on_delete']}'
                  .toLowerCase(),
        )
        .toSet();

    return _sameSet(foreignKeys('qigong_posts'), const <String>{
          'cover_media_id|qigong_media_assets|id|no action|restrict',
        }) &&
        _sameSet(foreignKeys('qigong_post_blocks'), const <String>{
          'post_id|qigong_posts|id|no action|cascade',
        }) &&
        _sameSet(foreignKeys('qigong_post_media'), const <String>{
          'post_id|qigong_posts|id|no action|cascade',
          'block_id|qigong_post_blocks|id|no action|cascade',
          'media_id|qigong_media_assets|id|no action|restrict',
        }) &&
        _sameSet(foreignKeys('qigong_post_tags'), const <String>{
          'post_id|qigong_posts|id|no action|cascade',
          'tag_id|qigong_tags|id|no action|restrict',
        }) &&
        _sameSet(foreignKeys('qigong_publications'), const <String>{
          'post_id|qigong_posts|id|no action|cascade',
        });
  }

  bool _inspectQigongInvariants(Database database) {
    final invalidEnums = _scalar(database, '''SELECT
      (SELECT count(*) FROM qigong_posts
        WHERE status NOT IN ('quickNote', 'drafting', 'final', 'archived')) +
      (SELECT count(*) FROM qigong_post_blocks
        WHERE type NOT IN ('paragraph', 'heading', 'subheading', 'quote',
          'divider', 'spacer', 'singleImage', 'imageGallery', 'imageCaption')) +
      (SELECT count(*) FROM qigong_publications
        WHERE platform NOT IN ('naverCafeQigongDoga',
          'daumCafeQigongVillage', 'naverBlogMyeongrinLab')
          OR status NOT IN
            ('notPublished', 'preparing', 'published', 'needsUpdate'))''');
    final invalidValues = _scalar(database, '''SELECT
      (SELECT count(*) FROM qigong_posts
        WHERE length(trim(id)) = 0 OR length(trim(title)) = 0
          OR updated_at_utc_us < created_at_utc_us) +
      (SELECT count(*) FROM qigong_post_blocks
        WHERE block_order < 0 OR gallery_columns NOT BETWEEN 1 AND 4) +
      (SELECT count(*) FROM qigong_media_assets
        WHERE length(sha256) != 64 OR sha256 GLOB '*[^0-9a-f]*'
          OR managed_relative_path NOT LIKE 'qigong_media/%'
          OR managed_relative_path LIKE '%..%'
          OR byte_size < 0)''');
    final invalidBlockOwnership = _scalar(database, '''SELECT count(*)
      FROM qigong_post_media pm
      JOIN qigong_post_blocks b ON b.id = pm.block_id
      WHERE pm.block_id IS NOT NULL AND b.post_id != pm.post_id''');
    final invalidCover = _scalar(database, '''SELECT
      (SELECT count(*) FROM qigong_posts p
        WHERE p.cover_media_id IS NOT NULL AND NOT EXISTS (
          SELECT 1 FROM qigong_post_media pm
          WHERE pm.post_id = p.id AND pm.media_id = p.cover_media_id
            AND pm.is_cover = 1 AND pm.block_id IS NULL)) +
      (SELECT count(*) FROM qigong_post_media pm
        JOIN qigong_posts p ON p.id = pm.post_id
        WHERE pm.is_cover = 1 AND
          (pm.block_id IS NOT NULL OR p.cover_media_id != pm.media_id))''');
    final invalidOrder = _scalar(database, '''SELECT count(*) FROM (
      SELECT post_id FROM qigong_post_blocks
      GROUP BY post_id HAVING min(block_order) != 0
        OR max(block_order) != count(*) - 1
        OR count(DISTINCT block_order) != count(*)
    )''');
    return invalidEnums == 0 &&
        invalidValues == 0 &&
        invalidBlockOwnership == 0 &&
        invalidCover == 0 &&
        invalidOrder == 0;
  }

  bool _inspectPersonCore(Database database) {
    final invalidEnums = _scalar(database, '''SELECT
      (SELECT count(*) FROM persons
        WHERE status NOT IN ('active', 'inactive')) +
      (SELECT count(*) FROM person_roles
        WHERE role_type NOT IN ('self', 'family', 'friend', 'studyMember',
          'client', 'student', 'instructor', 'practiceParticipant', 'other')) +
      (SELECT count(*) FROM person_birth_profiles
        WHERE birth_date_precision NOT IN ('exact', 'approximate', 'unknown')
          OR birth_time_precision NOT IN ('exact', 'approximate', 'unknown')
          OR calendar_system NOT IN ('solar', 'lunar', 'unknown')
          OR verification_state NOT IN ('unverified', 'confirmed', 'disputed')) +
      (SELECT count(*) FROM encounters
        WHERE occurred_precision NOT IN ('exact', 'approximate', 'dateOnly')
          OR encounter_type NOT IN ('inPersonCounseling', 'onlineCounseling',
            'phoneCall', 'studyMeeting', 'practiceInstruction',
            'followUpReview', 'selfReview', 'other')
          OR status NOT IN ('completed', 'voided')) +
      (SELECT count(*) FROM encounter_notes
        WHERE note_type NOT IN ('reportedFact', 'ownerObservation',
          'toolInterpretation', 'workingHypothesis', 'agreedAction',
          'privateReflection'))''');
    final invalidLifecycle = _scalar(database, '''SELECT
      (SELECT count(*) FROM person_roles
        WHERE effective_to_utc_us IS NOT NULL
          AND effective_to_utc_us < effective_from_utc_us) +
      (SELECT count(*) FROM person_relationships
        WHERE from_person_id = to_person_id OR
          (effective_to_utc_us IS NOT NULL
            AND effective_to_utc_us < effective_from_utc_us)) +
      (SELECT count(*) FROM person_birth_profiles
        WHERE revision_number < 1 OR
          (supersedes_birth_profile_id IS NOT NULL
            AND supersedes_birth_profile_id = id)) +
      (SELECT count(*) FROM encounter_notes
        WHERE (redacted_at_utc_us IS NULL AND length(trim(body)) = 0) OR
          (redacted_at_utc_us IS NOT NULL AND body != ''))''');
    final duplicateCurrentRoles = _scalar(database, '''SELECT count(*) FROM (
      SELECT person_id, role_type FROM person_roles
      WHERE effective_to_utc_us IS NULL
      GROUP BY person_id, role_type HAVING count(*) > 1
    )''');
    final duplicateActiveSelf = _scalar(database, '''SELECT count(*) FROM (
      SELECT role_type FROM person_roles
      WHERE role_type = 'self' AND effective_to_utc_us IS NULL
      GROUP BY role_type HAVING count(*) > 1
    )''');
    final duplicateCurrentBirthProfiles = _scalar(
      database,
      '''SELECT count(*) FROM (
      SELECT person_id FROM person_birth_profiles
      WHERE superseded_at_utc_us IS NULL
      GROUP BY person_id HAVING count(*) > 1
    )''',
    );
    return invalidEnums == 0 &&
        invalidLifecycle == 0 &&
        duplicateCurrentRoles == 0 &&
        duplicateActiveSelf == 0 &&
        duplicateCurrentBirthProfiles == 0;
  }

  bool _inspectPersonGroups(Database database) {
    final groups = database.select(
      'SELECT id, name, normalized_name, archived_at_utc_us, '
      'created_at_utc_us, updated_at_utc_us FROM person_groups',
    );
    for (final row in groups) {
      final id = row['id']! as String;
      final name = row['name']! as String;
      final normalizedName = row['normalized_name']! as String;
      final createdAt = row['created_at_utc_us']! as int;
      final updatedAt = row['updated_at_utc_us']! as int;
      final archivedAt = row['archived_at_utc_us'] as int?;
      if (id.trim().isEmpty ||
          name.trim().isEmpty ||
          name.runes.length > 60 ||
          normalizedName != _normalizeGroupName(name) ||
          updatedAt < createdAt ||
          (archivedAt != null && archivedAt < createdAt)) {
        return false;
      }
    }
    final duplicateNames = _scalar(database, '''SELECT count(*) FROM (
      SELECT normalized_name FROM person_groups
      GROUP BY normalized_name HAVING count(*) > 1
    )''');
    final orphanMemberships = _scalar(database, '''SELECT count(*)
      FROM person_group_memberships m
      LEFT JOIN person_groups g ON g.id = m.group_id
      LEFT JOIN persons p ON p.id = m.person_id
      WHERE g.id IS NULL OR p.id IS NULL''');
    return duplicateNames == 0 && orphanMemberships == 0;
  }

  bool _inspectPersonSchemaContract(
    Database database, {
    required bool includeGroups,
  }) {
    const expectedForeignKeys = <String, Set<String>>{
      'persons': <String>{},
      'person_roles': <String>{'person_id|persons|id|cascade'},
      'person_relationships': <String>{
        'from_person_id|persons|id|cascade',
        'to_person_id|persons|id|cascade',
      },
      'person_birth_profiles': <String>{
        'person_id|persons|id|cascade',
        'supersedes_birth_profile_id|person_birth_profiles|id|set null',
      },
      'encounters': <String>{'person_id|persons|id|cascade'},
      'encounter_notes': <String>{
        'encounter_id|encounters|id|cascade',
        'supersedes_note_id|encounter_notes|id|set null',
      },
    };
    const requiredChecks = <String, List<String>>{
      'persons': <String>[
        'CHECK (length(trim(id)) > 0)',
        'CHECK (length(trim(display_name)) > 0)',
        "CHECK (status IN ('active', 'inactive'))",
        'CHECK (updated_at_utc_us >= created_at_utc_us)',
      ],
      'person_roles': <String>[
        "CHECK (role_type IN ('self', 'family', 'friend', 'studyMember', 'client', 'student', 'instructor', 'practiceParticipant', 'other'))",
        'CHECK (effective_to_utc_us IS NULL OR effective_to_utc_us >= effective_from_utc_us)',
        'CHECK (updated_at_utc_us >= created_at_utc_us)',
      ],
      'person_relationships': <String>[
        'CHECK (from_person_id != to_person_id)',
        'CHECK (length(trim(relationship_type)) > 0)',
        'CHECK (effective_to_utc_us IS NULL OR effective_to_utc_us >= effective_from_utc_us)',
        'CHECK (updated_at_utc_us >= created_at_utc_us)',
      ],
      'person_birth_profiles': <String>[
        'CHECK (revision_number >= 1)',
        "CHECK (birth_date_precision IN ('exact', 'approximate', 'unknown'))",
        "CHECK (birth_time_precision IN ('exact', 'approximate', 'unknown'))",
        "CHECK (calendar_system IN ('solar', 'lunar', 'unknown'))",
        "CHECK (verification_state IN ('unverified', 'confirmed', 'disputed'))",
        'CHECK (utc_offset_minutes_at_birth IS NULL OR utc_offset_minutes_at_birth BETWEEN -840 AND 840)',
        "CHECK (calendar_system = 'lunar' OR is_leap_month IS NULL)",
        'CHECK (supersedes_birth_profile_id IS NULL OR supersedes_birth_profile_id != id)',
      ],
      'encounters': <String>[
        "CHECK (occurred_precision IN ('exact', 'approximate', 'dateOnly'))",
        "CHECK (encounter_type IN ('inPersonCounseling', 'onlineCounseling', 'phoneCall', 'studyMeeting', 'practiceInstruction', 'followUpReview', 'selfReview', 'other'))",
        'CHECK (length(trim(title)) > 0)',
        "CHECK (status IN ('completed', 'voided'))",
        'CHECK (updated_at_utc_us >= created_at_utc_us)',
      ],
      'encounter_notes': <String>[
        "CHECK (note_type IN ('reportedFact', 'ownerObservation', 'toolInterpretation', 'workingHypothesis', 'agreedAction', 'privateReflection'))",
        "CHECK ((redacted_at_utc_us IS NULL AND length(trim(body)) > 0) OR (redacted_at_utc_us IS NOT NULL AND body = ''))",
        'CHECK (supersedes_note_id IS NULL OR supersedes_note_id != id)',
        'CHECK (updated_at_utc_us >= recorded_at_utc_us)',
      ],
    };
    const requiredIndexes = <String, _IndexContract>{
      'persons_status_archive_idx': _IndexContract('persons', <String>[
        'status',
        'archived_at_utc_us',
      ]),
      'persons_display_name_idx': _IndexContract('persons', <String>[
        'display_name',
      ]),
      'person_roles_person_period_idx': _IndexContract('person_roles', <String>[
        'person_id',
        'effective_from_utc_us',
      ]),
      'person_roles_active_unique': _IndexContract(
        'person_roles',
        <String>['person_id', 'role_type'],
        unique: true,
        partialSql: 'WHERE effective_to_utc_us IS NULL',
      ),
      'person_roles_single_active_self': _IndexContract(
        'person_roles',
        <String>['role_type'],
        unique: true,
        partialSql: "WHERE role_type = 'self' AND effective_to_utc_us IS NULL",
      ),
      'person_relationships_from_idx': _IndexContract(
        'person_relationships',
        <String>['from_person_id', 'effective_from_utc_us'],
      ),
      'person_relationships_to_idx': _IndexContract(
        'person_relationships',
        <String>['to_person_id', 'effective_from_utc_us'],
      ),
      'person_birth_profiles_history_idx': _IndexContract(
        'person_birth_profiles',
        <String>['person_id', 'revision_number'],
      ),
      'person_birth_profiles_current_unique': _IndexContract(
        'person_birth_profiles',
        <String>['person_id'],
        unique: true,
        partialSql: 'WHERE superseded_at_utc_us IS NULL',
      ),
      'encounters_person_occurred_idx': _IndexContract('encounters', <String>[
        'person_id',
        'occurred_at_utc_us',
      ]),
      'encounters_person_follow_up_idx': _IndexContract('encounters', <String>[
        'person_id',
        'follow_up_at_utc_us',
      ]),
      'encounter_notes_encounter_recorded_idx': _IndexContract(
        'encounter_notes',
        <String>['encounter_id', 'recorded_at_utc_us'],
      ),
    };

    for (final entry in expectedForeignKeys.entries) {
      final primaryKeys = database
          .select('PRAGMA table_info("${entry.key}")')
          .where((row) => (row['pk']! as int) > 0)
          .map((row) => row['name']! as String)
          .toList(growable: false);
      if (!_sameList(primaryKeys, const <String>['id'])) return false;
      final actualForeignKeys = database
          .select('PRAGMA foreign_key_list("${entry.key}")')
          .map(
            (row) =>
                '${row['from']}|${row['table']}|${row['to']}|${row['on_delete']}'
                    .toLowerCase(),
          )
          .toSet();
      if (!_sameSet(actualForeignKeys, entry.value)) return false;

      final tableSql =
          database.select(
                "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = ?",
                <Object?>[entry.key],
              ).single['sql']!
              as String;
      final normalizedTableSql = _normalizeSchemaSql(tableSql);
      if (!requiredChecks[entry.key]!.every(
        (check) => normalizedTableSql.contains(_normalizeSchemaSql(check)),
      )) {
        return false;
      }
    }

    if (!_hasUniqueColumns(database, 'person_relationships', const <String>[
      'from_person_id',
      'to_person_id',
      'relationship_type',
      'effective_from_utc_us',
    ])) {
      return false;
    }
    if (!_hasUniqueColumns(database, 'person_birth_profiles', const <String>[
      'person_id',
      'revision_number',
    ])) {
      return false;
    }
    final baseMatches = requiredIndexes.entries.every(
      (entry) => _matchesIndex(database, entry.key, entry.value),
    );
    return baseMatches &&
        (!includeGroups || _inspectPersonGroupSchemaContract(database));
  }

  bool _inspectPersonGroupSchemaContract(Database database) {
    final groupPrimaryKeys = database
        .select('PRAGMA table_info("person_groups")')
        .where((row) => (row['pk']! as int) > 0)
        .map((row) => row['name']! as String)
        .toList(growable: false);
    final membershipPrimaryKeys = database
        .select('PRAGMA table_info("person_group_memberships")')
        .where((row) => (row['pk']! as int) > 0)
        .map((row) => row['name']! as String)
        .toList(growable: false);
    if (!_sameList(groupPrimaryKeys, const <String>['id']) ||
        !_sameList(membershipPrimaryKeys, const <String>[
          'group_id',
          'person_id',
        ])) {
      return false;
    }

    final membershipForeignKeys = database
        .select('PRAGMA foreign_key_list("person_group_memberships")')
        .map(
          (row) =>
              '${row['from']}|${row['table']}|${row['to']}|${row['on_delete']}'
                  .toLowerCase(),
        )
        .toSet();
    if (!_sameSet(membershipForeignKeys, const <String>{
      'group_id|person_groups|id|cascade',
      'person_id|persons|id|cascade',
    })) {
      return false;
    }

    final groupSql =
        database
                .select(
                  "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'person_groups'",
                )
                .single['sql']!
            as String;
    final normalizedSql = _normalizeSchemaSql(groupSql);
    for (final check in const <String>[
      'CHECK (length(trim(id)) > 0)',
      'CHECK (length(trim(name)) BETWEEN 1 AND 60)',
      'CHECK (length(normalized_name) BETWEEN 1 AND 60)',
      'CHECK (archived_at_utc_us IS NULL OR archived_at_utc_us >= created_at_utc_us)',
      'CHECK (updated_at_utc_us >= created_at_utc_us)',
    ]) {
      if (!normalizedSql.contains(_normalizeSchemaSql(check))) return false;
    }

    return _hasUniqueColumns(database, 'person_groups', const <String>[
          'normalized_name',
        ]) &&
        _matchesIndex(
          database,
          'person_groups_archive_name_idx',
          const _IndexContract('person_groups', <String>[
            'archived_at_utc_us',
            'normalized_name',
          ]),
        ) &&
        _matchesIndex(
          database,
          'person_group_memberships_person_idx',
          const _IndexContract('person_group_memberships', <String>[
            'person_id',
            'group_id',
          ]),
        );
  }
}

final class _IndexContract {
  const _IndexContract(
    this.table,
    this.columns, {
    this.unique = false,
    this.partialSql,
  });

  final String table;
  final List<String> columns;
  final bool unique;
  final String? partialSql;
}

SajuChartSnapshotRow _sajuRow(Row row) {
  String text(String name) => row[name]! as String;
  String? nullableText(String name) => row[name] as String?;
  int integer(String name) => row[name]! as int;
  int? nullableInteger(String name) => row[name] as int?;
  bool boolean(String name) => integer(name) != 0;
  bool? nullableBoolean(String name) {
    final value = nullableInteger(name);
    return value == null ? null : value != 0;
  }

  return SajuChartSnapshotRow(
    id: text('id'),
    personId: text('person_id'),
    sourceBirthProfileId: nullableText('source_birth_profile_id'),
    chartGroupId: text('chart_group_id'),
    revisionNumber: integer('revision_number'),
    revisionReason: text('revision_reason'),
    createdAtUtcUs: integer('created_at_utc_us'),
    calculatedAtUtcUs: integer('calculated_at_utc_us'),
    calendarType: text('calendar_type'),
    inputLocalDate: text('input_local_date'),
    inputLocalTime: nullableText('input_local_time'),
    hourUnknown: boolean('hour_unknown'),
    genderCompatibilityValue: text('gender_compatibility_value'),
    originalLunarYear: nullableInteger('original_lunar_year'),
    originalLunarMonth: nullableInteger('original_lunar_month'),
    originalLunarDay: nullableInteger('original_lunar_day'),
    originalLunarLeapMonth: nullableBoolean('original_lunar_leap_month'),
    timezoneId: text('timezone_id'),
    birthPlaceProfile: text('birth_place_profile'),
    yajaEnabled: boolean('yaja_enabled'),
    convertedSolarDate: text('converted_solar_date'),
    convertedLunarDate: text('converted_lunar_date'),
    convertedLunarLeapMonth: boolean('converted_lunar_leap_month'),
    birthUtcInstantUs: nullableInteger('birth_utc_instant_us'),
    utcOffsetAtBirthMinutes: integer('utc_offset_at_birth_minutes'),
    effectiveHourCalculationTime: nullableText(
      'effective_hour_calculation_time',
    ),
    yearPillarCanonicalId: text('year_pillar_canonical_id'),
    yearPillarCycleIndex: integer('year_pillar_cycle_index'),
    yearPillarStemIndex: integer('year_pillar_stem_index'),
    yearPillarBranchIndex: integer('year_pillar_branch_index'),
    yearPillarHanja: text('year_pillar_hanja'),
    yearPillarKoreanLabel: text('year_pillar_korean_label'),
    monthPillarCanonicalId: text('month_pillar_canonical_id'),
    monthPillarCycleIndex: integer('month_pillar_cycle_index'),
    monthPillarStemIndex: integer('month_pillar_stem_index'),
    monthPillarBranchIndex: integer('month_pillar_branch_index'),
    monthPillarHanja: text('month_pillar_hanja'),
    monthPillarKoreanLabel: text('month_pillar_korean_label'),
    dayPillarCanonicalId: text('day_pillar_canonical_id'),
    dayPillarCycleIndex: integer('day_pillar_cycle_index'),
    dayPillarStemIndex: integer('day_pillar_stem_index'),
    dayPillarBranchIndex: integer('day_pillar_branch_index'),
    dayPillarHanja: text('day_pillar_hanja'),
    dayPillarKoreanLabel: text('day_pillar_korean_label'),
    hourPillarCanonicalId: nullableText('hour_pillar_canonical_id'),
    hourPillarCycleIndex: nullableInteger('hour_pillar_cycle_index'),
    hourPillarStemIndex: nullableInteger('hour_pillar_stem_index'),
    hourPillarBranchIndex: nullableInteger('hour_pillar_branch_index'),
    hourPillarHanja: nullableText('hour_pillar_hanja'),
    hourPillarKoreanLabel: nullableText('hour_pillar_korean_label'),
    engineId: text('engine_id'),
    engineVersion: text('engine_version'),
    policyId: text('policy_id'),
    policyVersion: text('policy_version'),
    dayRolloverPolicy: text('day_rollover_policy'),
    longitudeCorrectionPolicy: text('longitude_correction_policy'),
    dstCorrectionPolicy: text('dst_correction_policy'),
    supportedRangeVersion: text('supported_range_version'),
    solarTermAlgorithmVersion: text('solar_term_algorithm_version'),
    lunarConverterVersion: text('lunar_converter_version'),
    dayAnchorVersion: text('day_anchor_version'),
    timeScaleAdapterVersion: text('time_scale_adapter_version'),
    warningsJson: text('warnings_json'),
    inputFingerprintSha256: text('input_fingerprint_sha256'),
    calculationSignatureSha256: text('calculation_signature_sha256'),
  );
}

final class TarotDatabaseEvidence {
  TarotDatabaseEvidence({
    required this.schemaVersion,
    required Map<String, bool> tableExistence,
    required Map<String, bool> requiredColumnResults,
    required Map<String, bool> exactColumnResults,
    required this.unexpectedTablesAbsent,
    required Map<String, int> tableRowCounts,
    required this.readingRowCount,
    required this.distinctReadingIdCount,
    required this.placementCount,
    required this.interpretationCount,
    required this.runtimeStateRowCount,
    required Map<String, int> lifecycleStateCounts,
    required this.activeHomeReadingIdPresent,
    required this.unsupportedTableRowsZero,
    required this.integrityCheckOk,
    required this.foreignKeyCheckOk,
    required this.schemaContractOk,
    required this.aggregateInvariantsOk,
    required this.freelistCount,
    required this.hasUnexpectedNonEmptySidecar,
  }) : tableExistence = Map.unmodifiable(tableExistence),
       requiredColumnResults = Map.unmodifiable(requiredColumnResults),
       exactColumnResults = Map.unmodifiable(exactColumnResults),
       tableRowCounts = Map.unmodifiable(tableRowCounts),
       lifecycleStateCounts = Map.unmodifiable(lifecycleStateCounts);

  final int schemaVersion;
  final Map<String, bool> tableExistence;
  final Map<String, bool> requiredColumnResults;
  final Map<String, bool> exactColumnResults;
  final bool unexpectedTablesAbsent;
  final Map<String, int> tableRowCounts;
  final int readingRowCount;
  final int distinctReadingIdCount;
  final int placementCount;
  final int interpretationCount;
  final int runtimeStateRowCount;
  final Map<String, int> lifecycleStateCounts;
  final bool activeHomeReadingIdPresent;
  final bool unsupportedTableRowsZero;
  final bool integrityCheckOk;
  final bool foreignKeyCheckOk;
  final bool schemaContractOk;
  final bool aggregateInvariantsOk;
  final int freelistCount;
  final bool hasUnexpectedNonEmptySidecar;

  bool get requiredTablesPresent =>
      tableExistence.values.every((value) => value);
  bool get requiredColumnsPresent =>
      requiredColumnResults.values.every((value) => value);
  bool get exactColumnsMatch =>
      exactColumnResults.values.every((value) => value);

  bool sameLogicalState(TarotDatabaseEvidence other) =>
      schemaVersion == other.schemaVersion &&
      _sameMap(tableRowCounts, other.tableRowCounts) &&
      readingRowCount == other.readingRowCount &&
      distinctReadingIdCount == other.distinctReadingIdCount &&
      placementCount == other.placementCount &&
      interpretationCount == other.interpretationCount &&
      runtimeStateRowCount == other.runtimeStateRowCount &&
      _sameMap(lifecycleStateCounts, other.lifecycleStateCounts) &&
      activeHomeReadingIdPresent == other.activeHomeReadingIdPresent &&
      unsupportedTableRowsZero == other.unsupportedTableRowsZero &&
      unexpectedTablesAbsent == other.unexpectedTablesAbsent &&
      exactColumnsMatch == other.exactColumnsMatch &&
      schemaContractOk == other.schemaContractOk &&
      aggregateInvariantsOk == other.aggregateInvariantsOk;

  TarotDatabaseEvidence withSidecarState(bool hasUnexpectedSidecar) =>
      TarotDatabaseEvidence(
        schemaVersion: schemaVersion,
        tableExistence: tableExistence,
        requiredColumnResults: requiredColumnResults,
        exactColumnResults: exactColumnResults,
        unexpectedTablesAbsent: unexpectedTablesAbsent,
        tableRowCounts: tableRowCounts,
        readingRowCount: readingRowCount,
        distinctReadingIdCount: distinctReadingIdCount,
        placementCount: placementCount,
        interpretationCount: interpretationCount,
        runtimeStateRowCount: runtimeStateRowCount,
        lifecycleStateCounts: lifecycleStateCounts,
        activeHomeReadingIdPresent: activeHomeReadingIdPresent,
        unsupportedTableRowsZero: unsupportedTableRowsZero,
        integrityCheckOk: integrityCheckOk,
        foreignKeyCheckOk: foreignKeyCheckOk,
        schemaContractOk: schemaContractOk,
        aggregateInvariantsOk: aggregateInvariantsOk,
        freelistCount: freelistCount,
        hasUnexpectedNonEmptySidecar: hasUnexpectedSidecar,
      );
}

final class TarotBackupInspectionException implements Exception {
  const TarotBackupInspectionException(
    this.code, {
    this.closeUnresolved = false,
  });
  final String code;
  final bool closeUnresolved;

  @override
  String toString() => 'TarotBackupInspectionException($code)';
}

final class _AggregateEvidence {
  const _AggregateEvidence({
    required this.distinctReadingIdCount,
    required this.lifecycleStateCounts,
    required this.activeHomeReadingIdPresent,
    required this.valid,
  });

  const _AggregateEvidence.invalid()
    : distinctReadingIdCount = 0,
      lifecycleStateCounts = const <String, int>{
        'continuing': 0,
        'finished': 0,
      },
      activeHomeReadingIdPresent = false,
      valid = false;

  final int distinctReadingIdCount;
  final Map<String, int> lifecycleStateCounts;
  final bool activeHomeReadingIdPresent;
  final bool valid;
}

String _normalizeGroupName(String value) =>
    value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

int _scalar(Database database, String sql) =>
    database.select(sql).first.values.first! as int;

bool _matchesIndex(
  Database database,
  String indexName,
  _IndexContract contract,
) {
  final indexRows = database.select('PRAGMA index_list("${contract.table}")');
  final matches = indexRows.where((row) => row['name'] == indexName).toList();
  if (matches.length != 1) return false;
  final row = matches.single;
  if ((row['unique']! as int) != (contract.unique ? 1 : 0)) return false;
  final expectsPartial = contract.partialSql != null;
  if ((row['partial']! as int) != (expectsPartial ? 1 : 0)) return false;
  final columns = database
      .select('PRAGMA index_info("$indexName")')
      .map((item) => item['name']! as String)
      .toList(growable: false);
  if (!_sameList(columns, contract.columns)) return false;
  if (contract.partialSql == null) return true;
  final indexSql =
      database.select(
            "SELECT sql FROM sqlite_master WHERE type = 'index' AND name = ?",
            <Object?>[indexName],
          ).single['sql']!
          as String;
  return _normalizeSchemaSql(
    indexSql,
  ).contains(_normalizeSchemaSql(contract.partialSql!));
}

bool _hasUniqueColumns(
  Database database,
  String table,
  List<String> expectedColumns,
) {
  for (final row in database.select('PRAGMA index_list("$table")')) {
    if ((row['unique']! as int) != 1 || (row['partial']! as int) != 0) {
      continue;
    }
    final name = row['name']! as String;
    final columns = database
        .select('PRAGMA index_info("$name")')
        .map((item) => item['name']! as String)
        .toList(growable: false);
    if (_sameList(columns, expectedColumns)) return true;
  }
  return false;
}

String _normalizeSchemaSql(String sql) =>
    sql.toLowerCase().replaceAll(RegExp(r'[\s"`\[\]]'), '');

bool _sameList<T>(List<T> left, List<T> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

bool _hasNonEmptySidecar(String path) {
  for (final suffix in const <String>['-wal', '-shm', '-journal']) {
    final sidecarPath = '$path$suffix';
    final type = FileSystemEntity.typeSync(sidecarPath, followLinks: false);
    if (type == FileSystemEntityType.notFound) continue;
    if (type != FileSystemEntityType.file) return true;
    if (File(sidecarPath).lengthSync() > 0) return true;
  }
  return false;
}

String _immutableReadOnlyUri(String path) => Uri.file(path, windows: true)
    .replace(
      queryParameters: const <String, String>{'mode': 'ro', 'immutable': '1'},
    )
    .toString();

Database _openInspectorDatabase(String filename, OpenMode mode, bool uri) =>
    sqlite3.open(filename, mode: mode, uri: uri);

void _closeInspectorDatabase(Database database) => database.close();

bool _sameMap<K, V>(Map<K, V> left, Map<K, V> right) {
  if (left.length != right.length) return false;
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) return false;
  }
  return true;
}

bool _sameSet<T>(Set<T> left, Set<T> right) =>
    left.length == right.length && left.containsAll(right);
