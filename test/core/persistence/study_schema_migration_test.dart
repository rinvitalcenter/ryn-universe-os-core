import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/core/persistence/migrations.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('fresh v9 database creates exact Study relation foundation', () async {
    final database = RynAppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    expect(database.schemaVersion, 9);
    expect(plannedCurrentSchemaVersion, 9);
    final tables = await _tableNames(database);
    expect(
      tables,
      containsAll(<String>{
        'study_sessions',
        'study_session_participants',
        'study_materials',
        'study_session_materials',
      }),
    );

    final participantColumns = await database
        .customSelect('PRAGMA table_info(study_session_participants)')
        .get();
    expect(
      participantColumns.map((row) => row.read<String>('name')),
      isNot(contains('display_name')),
    );
    final participantKeys = await database
        .customSelect('PRAGMA foreign_key_list(study_session_participants)')
        .get();
    expect(
      participantKeys.any(
        (row) =>
            row.read<String>('from') == 'person_id' &&
            row.read<String>('table') == 'persons' &&
            row.read<String>('on_delete') == 'RESTRICT',
      ),
      isTrue,
    );
  });

  test('file-backed v8 to v9 preserves existing rows and fabricates no Study rows', () async {
    final root = await Directory.systemTemp.createTemp('ryn-study-v8-v9-');
    addTearDown(() async {
      if (root.existsSync()) await root.delete(recursive: true);
    });
    final file = File('${root.path}${Platform.pathSeparator}migration.sqlite');
    var database = RynAppDatabase(NativeDatabase(file));
    await database.customSelect('SELECT 1').get();
    await database.customStatement(
      "INSERT INTO persons (id, display_name, status, created_at_utc_us, updated_at_utc_us) "
      "VALUES ('person.preserved', '보존 인물', 'active', 1, 1)",
    );
    await database.close();

    final raw = sqlite3.open(file.path);
    raw.execute('DROP TABLE study_session_materials');
    raw.execute('DROP TABLE study_session_participants');
    raw.execute('DROP TABLE study_materials');
    raw.execute('DROP TABLE study_sessions');
    raw.userVersion = 8;
    raw.close();

    database = RynAppDatabase(NativeDatabase(file));
    expect(await _count(database, 'persons'), 1);
    expect(await _count(database, 'study_sessions'), 0);
    expect(await _count(database, 'study_session_participants'), 0);
    expect(await _count(database, 'study_materials'), 0);
    expect(await _count(database, 'study_session_materials'), 0);
    expect(
      (await database.customSelect('PRAGMA user_version').getSingle())
          .read<int>('user_version'),
      9,
    );
    expect(await database.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    expect(
      (await database.customSelect('PRAGMA integrity_check').getSingle())
          .read<String>('integrity_check'),
      'ok',
    );
    await database.close();
  });

  test('Study enum and relation constraints reject invalid or orphan data', () async {
    final database = RynAppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await expectLater(
      database.customStatement(
        "INSERT INTO study_sessions "
        "(id, title, occurred_at_utc_us, timezone_offset_minutes, location, track, status, progress_status, created_at_utc_us, updated_at_utc_us) "
        "VALUES ('bad', '잘못된 회차', 1, 0, '공간', 'cycle', 'planned', 'not_started', 1, 1)",
      ),
      throwsA(anything),
    );
    await expectLater(
      database.customStatement(
        "INSERT INTO study_session_materials (session_id, material_id, created_at_utc_us) "
        "VALUES ('missing-session', 'missing-material', 1)",
      ),
      throwsA(anything),
    );
  });
}

Future<Set<String>> _tableNames(RynAppDatabase database) async =>
    (await database.customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    ).get()).map((row) => row.read<String>('name')).toSet();

Future<int> _count(RynAppDatabase database, String table) async =>
    (await database.customSelect(
      'SELECT count(*) AS total FROM $table',
    ).getSingle()).read<int>('total');
