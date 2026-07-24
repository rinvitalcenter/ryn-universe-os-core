import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:ryn_universe_os_core/core/backup_recovery/sha256_digest_service.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/domain/tarot_backup_manifest.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_backup_database_inspector.dart';
import 'package:ryn_universe_os_core/features/tarot/backup_recovery/infrastructure/tarot_backup_manifest_codec.dart';
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

  void insertSyntheticPersonCore(Database database) {
    final now = DateTime.utc(2026, 7, 17).microsecondsSinceEpoch;
    database.execute(
      '''INSERT INTO persons (
        id, display_name, status, relationship_summary,
        created_at_utc_us, updated_at_utc_us
      ) VALUES (?, ?, 'active', ?, ?, ?)''',
      <Object?>[
        'person.synthetic.study.01',
        '합성 인물 A',
        'SYNTHETIC_RELATIONSHIP_SUMMARY',
        now,
        now,
      ],
    );
    database.execute(
      '''INSERT INTO person_roles (
        id, person_id, role_type, effective_from_utc_us,
        created_at_utc_us, updated_at_utc_us
      ) VALUES (?, ?, 'studyMember', ?, ?, ?)''',
      <Object?>[
        'person-role.synthetic.study.01',
        'person.synthetic.study.01',
        now,
        now,
        now,
      ],
    );
    database.execute(
      '''INSERT INTO person_birth_profiles (
        id, person_id, revision_number, birth_date_precision,
        birth_time_precision, calendar_system, verification_state,
        created_at_utc_us
      ) VALUES (?, ?, 1, 'unknown', 'unknown', 'unknown', 'unverified', ?)''',
      <Object?>[
        'birth-profile.synthetic.study.01.r1',
        'person.synthetic.study.01',
        now,
      ],
    );
    database.execute(
      '''INSERT INTO encounters (
        id, person_id, occurred_at_utc_us, occurred_precision,
        encounter_type, title, status, created_at_utc_us, updated_at_utc_us
      ) VALUES (?, ?, ?, 'exact', 'studyMeeting', ?, 'completed', ?, ?)''',
      <Object?>[
        'encounter.synthetic.study.01',
        'person.synthetic.study.01',
        now,
        'SYNTHETIC_STUDY_MEETING',
        now,
        now,
      ],
    );
    database.execute(
      '''INSERT INTO encounter_notes (
        id, encounter_id, note_type, body, recorded_at_utc_us, updated_at_utc_us
      ) VALUES (?, ?, 'ownerObservation', ?, ?, ?)''',
      <Object?>[
        'encounter-note.synthetic.study.01',
        'encounter.synthetic.study.01',
        'SYNTHETIC_PERSON_NOTE',
        now,
        now,
      ],
    );
  }

  void insertSyntheticPersonGroups(Database database) {
    final now = DateTime.utc(2026, 7, 17).microsecondsSinceEpoch;
    database.execute(
      '''INSERT INTO person_groups (
        id, name, normalized_name, created_at_utc_us, updated_at_utc_us
      ) VALUES (?, ?, ?, ?, ?)''',
      <Object?>['group.synthetic.a', '테스트 그룹 A', '테스트 그룹 a', now, now],
    );
    database.execute(
      '''INSERT INTO person_groups (
        id, name, normalized_name, created_at_utc_us, updated_at_utc_us
      ) VALUES (?, ?, ?, ?, ?)''',
      <Object?>['group.synthetic.b', '테스트 그룹 B', '테스트 그룹 b', now, now],
    );
    database.execute(
      '''INSERT INTO person_group_memberships (
        group_id, person_id, created_at_utc_us
      ) VALUES (?, ?, ?)''',
      <Object?>['group.synthetic.a', 'person.synthetic.study.01', now],
    );
    database.execute(
      '''INSERT INTO person_group_memberships (
        group_id, person_id, created_at_utc_us
      ) VALUES (?, ?, ?)''',
      <Object?>['group.synthetic.b', 'person.synthetic.study.01', now],
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

  Future<Directory> createRestoreCandidate({
    DateTime? createdAtUtc,
    String operationId = 'a1b2c3d4',
    int schemaVersion = TarotBackupManifest.schemaVersion,
  }) async {
    final createdAt = createdAtUtc ?? DateTime.utc(2026, 7, 17, 1, 2, 3);
    final package = resolvedPaths()
        .packagePaths(createdAtUtc: createdAt, operationId: operationId)
        .finalDirectory;
    final data = Directory('${package.path}${Platform.pathSeparator}data');
    final checksums = Directory(
      '${package.path}${Platform.pathSeparator}checksums',
    );
    await data.create(recursive: true);
    await checksums.create();
    final snapshot = File(
      '${package.path}${Platform.pathSeparator}'
      '${TarotBackupManifest.databasePayloadFilename.replaceAll('/', Platform.pathSeparator)}',
    );
    await sourceFile.copy(snapshot.path);
    if (schemaVersion == TarotBackupManifest.legacySchemaVersion) {
      final legacy = sqlite3.open(snapshot.path);
      legacy.execute('DROP TABLE person_group_memberships');
      legacy.execute('DROP TABLE person_groups');
      legacy.execute('VACUUM');
      legacy.userVersion = TarotBackupManifest.legacySchemaVersion;
      legacy.close();
    }
    final evidence = const TarotBackupDatabaseInspector().inspectVerified(
      snapshot.path,
      policy: TarotDatabaseInspectionPolicy.immutableReadOnlyFrozenTarget,
      requireAcceptableSidecars: true,
      acceptedSchemaVersions: <int>{schemaVersion},
    );
    const digest = DartSha256DigestService();
    final payloadHash = await digest.digestFile(snapshot);
    final manifest = TarotBackupManifest(
      applicationVersion: '1.0.0+1',
      sourceRuntimeMode: 'tarot_backup_recovery_qa',
      sourceEnvironment: 'development',
      sourcePurpose: 'core_tarot_backup_recovery_v0_2',
      createdAtUtc: createdAt,
      databasePayloadSizeBytes: await snapshot.length(),
      databasePayloadSha256: payloadHash,
      requiredTables: TarotBackupManifest.requiredTablesFor(schemaVersion),
      requiredColumnsByTable: TarotBackupManifest.requiredColumnsFor(
        schemaVersion,
      ),
      tableRowCounts: evidence.tableRowCounts,
      readingIdCount: evidence.distinctReadingIdCount,
      placementCount: evidence.placementCount,
      interpretationCount: evidence.interpretationCount,
      runtimeStateRowCount: evidence.runtimeStateRowCount,
      activeHomeReadingIdPresent: evidence.activeHomeReadingIdPresent,
      lifecycleStateCounts: evidence.lifecycleStateCounts,
      unsupportedTableRowsZero: evidence.unsupportedTableRowsZero,
      verifiedAtUtc: createdAt,
      payloadSchemaVersion: schemaVersion,
    );
    await _writeRestoreCandidateIntegrity(package, manifest);
    return package;
  }

  Future<void> refreshRestoreCandidateIntegrity(Directory package) async {
    final manifestFile = File('${package.path}/manifest.json');
    final previous = const TarotBackupManifestCodec().decode(
      await manifestFile.readAsBytes(),
    );
    const digest = DartSha256DigestService();
    final snapshot = File(
      '${package.path}/${TarotBackupManifest.databasePayloadFilename}',
    );
    final refreshed = TarotBackupManifest(
      applicationVersion: previous.applicationVersion,
      sourceRuntimeMode: previous.sourceRuntimeMode,
      sourceEnvironment: previous.sourceEnvironment,
      sourcePurpose: previous.sourcePurpose,
      createdAtUtc: previous.createdAtUtc,
      databasePayloadSizeBytes: await snapshot.length(),
      databasePayloadSha256: await digest.digestFile(snapshot),
      requiredTables: previous.requiredTables,
      requiredColumnsByTable: previous.requiredColumnsByTable,
      tableRowCounts: previous.tableRowCounts,
      readingIdCount: previous.readingIdCount,
      placementCount: previous.placementCount,
      interpretationCount: previous.interpretationCount,
      runtimeStateRowCount: previous.runtimeStateRowCount,
      activeHomeReadingIdPresent: previous.activeHomeReadingIdPresent,
      lifecycleStateCounts: previous.lifecycleStateCounts,
      unsupportedTableRowsZero: previous.unsupportedTableRowsZero,
      verifiedAtUtc: previous.verifiedAtUtc,
      payloadSchemaVersion: previous.payloadSchemaVersion,
    );
    await _writeRestoreCandidateIntegrity(package, refreshed);
  }

  Future<void> _writeRestoreCandidateIntegrity(
    Directory package,
    TarotBackupManifest manifest,
  ) async {
    const codec = TarotBackupManifestCodec();
    const digest = DartSha256DigestService();
    final manifestFile = File('${package.path}/manifest.json');
    await manifestFile.writeAsBytes(codec.encode(manifest), flush: true);
    final manifestHash = await digest.digestFile(manifestFile);
    final checksum = File(
      '${package.path}/${TarotBackupManifest.checksumFilename}',
    );
    await checksum.writeAsString(
      '$manifestHash  manifest.json\n'
      '${manifest.databasePayloadSha256}  '
      '${TarotBackupManifest.databasePayloadFilename}',
      encoding: utf8,
      flush: true,
    );
  }

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
