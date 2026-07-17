import 'dart:io';

import 'package:drift/native.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_backup_path_contract.dart';
import 'package:sqlite3/sqlite3.dart';

final class TarotBackupRecoveryFixture {
  TarotBackupRecoveryFixture._({
    required this.root,
    required this.sourceRoot,
    required this.backupRoot,
    required this.sourceFile,
  });

  final Directory root;
  final Directory sourceRoot;
  final Directory backupRoot;
  final File sourceFile;
  final List<Database> _openDatabases = <Database>[];

  static Future<TarotBackupRecoveryFixture> create({
    bool validReading = true,
    bool walMode = false,
  }) async {
    final root = await Directory.systemTemp.createTemp('ryn-backup-fixture-');
    final sourceRoot = await Directory(
      '${root.path}${Platform.pathSeparator}source',
    ).create();
    final backupRoot = await Directory(
      '${root.path}${Platform.pathSeparator}backup',
    ).create();
    final sourceFile = File(
      '${sourceRoot.path}${Platform.pathSeparator}source.sqlite',
    );
    final drift = RynAppDatabase(NativeDatabase(sourceFile));
    await drift.customSelect('SELECT 1').get();
    await drift.close();

    final fixture = TarotBackupRecoveryFixture._(
      root: root,
      sourceRoot: sourceRoot,
      backupRoot: backupRoot,
      sourceFile: sourceFile,
    );
    final database = sqlite3.open(sourceFile.path);
    if (walMode) database.execute('PRAGMA journal_mode = WAL');
    if (validReading) fixture.insertValidReading(database, id: 'synthetic-r1');
    database.close();
    return fixture;
  }

  ResolvedBackupRecoveryPaths resolvedPaths({
    Future<bool> Function(String)? inspectPath,
  }) => TarotBackupPathContract(
    sourceRootPath: sourceRoot.path,
    backupRootPath: backupRoot.path,
    protectedRootPaths: const <String>[],
    inspectPath: inspectPath ?? (_) async => true,
  ).resolve();

  Database openSource({OpenMode mode = OpenMode.readWriteCreate}) {
    final database = sqlite3.open(sourceFile.path, mode: mode);
    _openDatabases.add(database);
    return database;
  }

  void release(Database database) {
    database.close();
    _openDatabases.remove(database);
  }

  void insertValidReading(Database database, {required String id}) {
    final now = DateTime.utc(2026, 7, 17).microsecondsSinceEpoch;
    database.execute(
      '''INSERT INTO tarot_readings (
        reading_instance_id, source_type, question_original_snapshot,
        question_display_text, deck_id, deck_name_snapshot, spread_id,
        spread_name_snapshot, expected_placement_count, reading_at_utc_us,
        reading_timezone_offset_min, created_at_utc_us, updated_at_utc_us,
        lifecycle_status, finished_at_utc_us
      ) VALUES (?, 'self_drawn', ?, ?, 'synthetic-deck', 'SYNTHETIC_DECK',
        'synthetic-spread', 'SYNTHETIC_SPREAD', 3, ?, 0, ?, ?,
        'continuing', NULL)''',
      <Object?>[
        id,
        'SYNTHETIC_QUESTION_$id',
        'SYNTHETIC_QUESTION_$id',
        now,
        now,
        now,
      ],
    );
    for (var order = 1; order <= 3; order++) {
      database.execute(
        '''INSERT INTO tarot_card_placements (
          reading_instance_id, placement_order, position_id,
          position_name_snapshot, card_id, card_name_snapshot, orientation
        ) VALUES (?, ?, ?, ?, ?, ?, ?)''',
        <Object?>[
          id,
          order,
          'synthetic-position-$order',
          'SYNTHETIC_POSITION_$order',
          'synthetic-card-$order',
          'SYNTHETIC_CARD_$order',
          order == 2 ? 'reversed' : 'upright',
        ],
      );
    }
    database.execute(
      '''INSERT INTO tarot_interpretations (
        reading_instance_id, whole_image_observation, flow_interpretation,
        core_message, small_action, created_at_utc_us, updated_at_utc_us
      ) VALUES (?, ?, ?, ?, ?, ?, ?)''',
      <Object?>[
        id,
        'SYNTHETIC_INTERPRETATION',
        'SYNTHETIC_FLOW',
        'SYNTHETIC_CORE',
        'SYNTHETIC_ACTION',
        now,
        now,
      ],
    );
    database.execute(
      '''UPDATE app_runtime_state
         SET active_home_tarot_reading_id = ?, updated_at_utc_us = ?
         WHERE state_key = 'main' ''',
      <Object?>[id, now],
    );
  }

  Map<String, Object?> logicalEvidence(Database database) => <String, Object?>{
    'userVersion': database.userVersion,
    'readingCount': _scalar(database, 'SELECT count(*) FROM tarot_readings'),
    'placementCount': _scalar(
      database,
      'SELECT count(*) FROM tarot_card_placements',
    ),
    'interpretationCount': _scalar(
      database,
      'SELECT count(*) FROM tarot_interpretations',
    ),
    'runtimeStateCount': _scalar(
      database,
      'SELECT count(*) FROM app_runtime_state',
    ),
  };

  Future<void> dispose() async {
    for (final database in List<Database>.from(_openDatabases)) {
      database.close();
    }
    _openDatabases.clear();
    if (await root.exists()) await root.delete(recursive: true);
  }
}

int _scalar(Database database, String sql) =>
    database.select(sql).first.values.first! as int;
