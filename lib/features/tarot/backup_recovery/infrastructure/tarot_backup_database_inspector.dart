import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

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
      final tableNames = database
          .select("SELECT name FROM sqlite_master WHERE type = 'table'")
          .map((row) => row['name']! as String)
          .toSet();
      final tableExistence = <String, bool>{
        for (final table in TarotBackupManifest.requiredTablesV1)
          table: tableNames.contains(table),
      };
      final columnResults = <String, bool>{};
      final exactColumnResults = <String, bool>{};
      for (final table in TarotBackupManifest.requiredTablesV1) {
        if (!tableNames.contains(table)) {
          columnResults[table] = false;
          exactColumnResults[table] = false;
          continue;
        }
        final actual = database
            .select('PRAGMA table_info("$table")')
            .map((row) => row['name']! as String)
            .toSet();
        final required = TarotBackupManifest.requiredColumnsByTableV1[table]!;
        columnResults[table] = required.every(actual.contains);
        exactColumnResults[table] = _sameSet(actual, required.toSet());
      }
      final applicationTables = tableNames
          .where((table) => !table.toLowerCase().startsWith('sqlite_'))
          .toSet();
      final unexpectedTablesAbsent = _sameSet(
        applicationTables,
        TarotBackupManifest.requiredTablesV1.toSet(),
      );

      final rowCounts = <String, int>{};
      for (final table in TarotBackupManifest.requiredTablesV1) {
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
      final aggregate = hasTarotTables
          ? _inspectAggregate(database)
          : const _AggregateEvidence.invalid();
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
        distinctReadingIdCount: aggregate.distinctReadingIdCount,
        placementCount: rowCounts['tarot_card_placements'] ?? 0,
        interpretationCount: rowCounts['tarot_interpretations'] ?? 0,
        runtimeStateRowCount: rowCounts['app_runtime_state'] ?? 0,
        lifecycleStateCounts: aggregate.lifecycleStateCounts,
        activeHomeReadingIdPresent: aggregate.activeHomeReadingIdPresent,
        unsupportedTableRowsZero: unsupportedRowsZero,
        integrityCheckOk: integrityCheckOk,
        foreignKeyCheckOk: foreignKeyCheckOk,
        aggregateInvariantsOk: aggregate.valid,
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
  }) {
    final evidence = inspect(databasePath, policy: policy);
    if (evidence.schemaVersion != TarotBackupManifest.schemaVersion) {
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

  _AggregateEvidence _inspectAggregate(Database database) {
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
          duplicateInterpretations == 0 &&
          runtimeCount == 1 &&
          invalidRuntimeState == 0 &&
          invalidActiveHome == 0,
    );
  }
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

int _scalar(Database database, String sql) =>
    database.select(sql).first.values.first! as int;

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
