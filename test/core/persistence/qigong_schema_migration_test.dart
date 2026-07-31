import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/core/persistence/migrations.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  const qigongTables = <String>{
    'qigong_posts',
    'qigong_post_blocks',
    'qigong_media_assets',
    'qigong_post_media',
    'qigong_tags',
    'qigong_post_tags',
    'qigong_publications',
  };

  test(
    'fresh schema 11 preserves exact Qigong document and media foundation',
    () async {
      final database = RynAppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      expect(database.schemaVersion, 11);
      expect(plannedCurrentSchemaVersion, 11);
      expect(await _tableNames(database), containsAll(qigongTables));
      expect(
        await database.customSelect('PRAGMA foreign_key_check').get(),
        isEmpty,
      );
    },
  );

  test('file-backed schema 9 to 11 preserves Person Tarot and Study rows', () async {
    final root = await Directory.systemTemp.createTemp('ryn-qigong-v9-v11-');
    addTearDown(() async {
      if (root.existsSync()) await root.delete(recursive: true);
    });
    final file = File('${root.path}${Platform.pathSeparator}migration.sqlite');
    var database = RynAppDatabase(NativeDatabase(file));
    await database.customSelect('SELECT 1').get();
    await database.customStatement(
      "INSERT INTO persons (id, display_name, status, created_at_utc_us, updated_at_utc_us) "
      "VALUES ('person.keep', '보존 인물', 'active', 1, 1)",
    );
    await database.customStatement(
      "INSERT INTO tarot_readings "
      "(reading_instance_id, source_type, person_id, question_original_snapshot, "
      "question_display_text, deck_id, deck_name_snapshot, spread_id, "
      "spread_name_snapshot, expected_placement_count, reading_at_utc_us, "
      "reading_timezone_offset_min, created_at_utc_us, updated_at_utc_us, "
      "lifecycle_status) VALUES "
      "('tarot.keep', 'self_drawn', 'person.keep', '보존 질문 원문', "
      "'보존 질문', 'rws', 'RWS', 'one_card', '한 장', 1, 1, 540, 1, 1, "
      "'continuing')",
    );
    await database.customStatement(
      "INSERT INTO study_sessions (id, title, occurred_at_utc_us, timezone_offset_minutes, location, track, status, progress_status, created_at_utc_us, updated_at_utc_us) "
      "VALUES ('study.keep', '보존 회차', 1, 540, '합성 공간', 'tarot', 'planned', 'not_started', 1, 1)",
    );
    await database.close();

    final raw = sqlite3.open(file.path);
    for (final table in qigongTables) {
      raw.execute('DROP TABLE $table');
    }
    raw.execute('DROP TABLE saju_chart_snapshots');
    raw.userVersion = 9;
    raw.close();

    database = RynAppDatabase(NativeDatabase(file));
    expect(await _count(database, 'persons'), 1);
    expect(await _count(database, 'tarot_readings'), 1);
    expect(await _count(database, 'study_sessions'), 1);
    expect(
      (await database
              .customSelect(
                "SELECT display_name FROM persons WHERE id = 'person.keep'",
              )
              .getSingle())
          .read<String>('display_name'),
      '보존 인물',
    );
    expect(
      (await database
              .customSelect(
                "SELECT question_display_text FROM tarot_readings "
                "WHERE reading_instance_id = 'tarot.keep'",
              )
              .getSingle())
          .read<String>('question_display_text'),
      '보존 질문',
    );
    expect(
      (await database
              .customSelect(
                "SELECT title FROM study_sessions WHERE id = 'study.keep'",
              )
              .getSingle())
          .read<String>('title'),
      '보존 회차',
    );
    for (final table in qigongTables) {
      expect(await _count(database, table), 0, reason: table);
    }
    expect(
      (await database.customSelect('PRAGMA user_version').getSingle())
          .read<int>('user_version'),
      11,
    );
    expect(
      await database.customSelect('PRAGMA foreign_key_check').get(),
      isEmpty,
    );
    await database.close();
  });

  test(
    'schema constraints reject orphan block media and duplicate relations',
    () async {
      final database = RynAppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await expectLater(
        database.customStatement(
          "INSERT INTO qigong_post_blocks (id, post_id, block_order, type) "
          "VALUES ('orphan', 'missing', 0, 'paragraph')",
        ),
        throwsA(anything),
      );
      await expectLater(
        database.customStatement(
          "INSERT INTO qigong_post_media (id, post_id, media_id, media_order, is_cover) "
          "VALUES ('orphan', 'missing', 'missing', 0, 0)",
        ),
        throwsA(anything),
      );
    },
  );
}

Future<Set<String>> _tableNames(RynAppDatabase database) async =>
    (await database
            .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
            .get())
        .map((row) => row.read<String>('name'))
        .toSet();

Future<int> _count(RynAppDatabase database, String table) async =>
    (await database
            .customSelect('SELECT count(*) AS total FROM $table')
            .getSingle())
        .read<int>('total');
