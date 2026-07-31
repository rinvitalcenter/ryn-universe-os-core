import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/core/persistence/migrations.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  const table = 'saju_chart_snapshots';
  const expectedColumns = <String>[
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
  ];

  test('fresh schema 11 exposes the exact transparent Saju contract', () async {
    final database = RynAppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    expect(database.schemaVersion, 11);
    expect(plannedCurrentSchemaVersion, 11);
    final columns = await database
        .customSelect('PRAGMA table_info($table)')
        .get();
    expect(
      columns.map((row) => row.read<String>('name')).toList(),
      expectedColumns,
    );
    expect(columns, hasLength(65));
    expect(
      columns.where((row) => row.read<int>('notnull') == 0),
      hasLength(14),
    );

    final foreignKeys = await database
        .customSelect('PRAGMA foreign_key_list($table)')
        .get();
    expect(foreignKeys, hasLength(2));
    expect(
      foreignKeys
          .map(
            (row) => (
              row.read<String>('from'),
              row.read<String>('table'),
              row.read<String>('on_delete'),
            ),
          )
          .toSet(),
      {
        ('person_id', 'persons', 'RESTRICT'),
        ('source_birth_profile_id', 'person_birth_profiles', 'RESTRICT'),
      },
    );

    final indexes = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index' AND tbl_name = ?", variables: [Variable.withString(table)])
        .get();
    final names = indexes.map((row) => row.read<String>('name')).toSet();
    expect(
      names,
      containsAll({
        'saju_snapshots_person_calculated_idx',
        'saju_snapshots_person_group_revision_idx',
        'saju_snapshots_person_birth_date_idx',
      }),
    );
    expect(names, isNot(contains('saju_snapshots_source_birth_profile_idx')));
  });

  test('schema 10 to 11 preserves rows and creates an empty Saju table', () async {
    final root = await Directory.systemTemp.createTemp('ryn-saju-v10-v11-');
    addTearDown(() async {
      if (root.existsSync()) await root.delete(recursive: true);
    });
    final file = File('${root.path}${Platform.pathSeparator}migration.sqlite');
    var database = RynAppDatabase(NativeDatabase(file));
    await database.customSelect('SELECT 1').get();
    await database.customStatement(
      "INSERT INTO persons (id, display_name, status, created_at_utc_us, updated_at_utc_us) VALUES ('person.keep', '보존 인물', 'active', 1, 1)",
    );
    await database.customStatement(
      "INSERT INTO qigong_media_assets (id, sha256, managed_relative_path, original_file_name, mime_type, byte_size, created_at_utc_us) VALUES ('media.keep', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'qigong_media/keep.png', 'keep.png', 'image/png', 4, 1)",
    );
    await database.close();

    final raw = sqlite3.open(file.path);
    raw.execute('DROP TABLE $table');
    raw.userVersion = 10;
    raw.close();

    database = RynAppDatabase(NativeDatabase(file));
    expect(await _count(database, 'persons'), 1);
    expect(await _count(database, 'qigong_media_assets'), 1);
    expect(await _count(database, table), 0);
    expect(
      (await database.customSelect('PRAGMA user_version').getSingle())
          .read<int>('user_version'),
      11,
    );
    expect(
      await database.customSelect('PRAGMA foreign_key_check').get(),
      isEmpty,
    );
    expect(
      (await database.customSelect('PRAGMA integrity_check').getSingle())
          .read<String>('integrity_check'),
      'ok',
    );
    await database.close();
  });

  test('physical CHECK constraints reject invalid revision and timestamps', () async {
    final database = RynAppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.customStatement(
      "INSERT INTO persons (id, display_name, status, created_at_utc_us, updated_at_utc_us) VALUES ('person.1', '합성 인물', 'active', 1, 1)",
    );

    final valid = _validInsertValues();
    await database.customStatement(_insertSql(valid));
    expect(await _count(database, table), 1);

    for (final mutation in <Map<String, Object?>>[
      {...valid, 'id': 'bad.revision', 'revision_number': 0},
      {...valid, 'id': 'bad.reason', 'chart_group_id': 'group.bad.reason', 'revision_reason': 'unknown'},
      {...valid, 'id': 'bad.timestamp', 'chart_group_id': 'group.bad.timestamp', 'created_at_utc_us': -1},
      {...valid, 'id': 'bad.hash', 'chart_group_id': 'group.bad.hash', 'input_fingerprint_sha256': 'ABC'},
      {...valid, 'id': 'bad.engine', 'chart_group_id': 'group.bad.engine', 'engine_id': ''},
      {...valid, 'id': 'bad.pillar', 'chart_group_id': 'group.bad.pillar', 'year_pillar_hanja': ''},
    ]) {
      await expectLater(database.customStatement(_insertSql(mutation)), throwsA(anything));
    }
  });
}

Map<String, Object?> _validInsertValues() => {
  'id': 'snapshot.1',
  'person_id': 'person.1',
  'source_birth_profile_id': null,
  'chart_group_id': 'group.1',
  'revision_number': 1,
  'revision_reason': 'initial',
  'created_at_utc_us': 0,
  'calculated_at_utc_us': 0,
  'calendar_type': 'solar',
  'input_local_date': '2024-02-10',
  'input_local_time': '10:00:00.000000',
  'hour_unknown': 0,
  'gender_compatibility_value': 'unspecified',
  'original_lunar_year': null,
  'original_lunar_month': null,
  'original_lunar_day': null,
  'original_lunar_leap_month': null,
  'timezone_id': 'Asia/Seoul',
  'birth_place_profile': 'seoulCompatibilityV1',
  'yaja_enabled': 0,
  'converted_solar_date': '2024-02-10',
  'converted_lunar_date': '2024-01-01',
  'converted_lunar_leap_month': 0,
  'birth_utc_instant_us': 1707526800000000,
  'utc_offset_at_birth_minutes': 540,
  'effective_hour_calculation_time': '2024-02-10T09:30:00.000000',
  for (final prefix in ['year', 'month', 'day', 'hour']) ...{
    '${prefix}_pillar_canonical_id': 'sexagenary-00',
    '${prefix}_pillar_cycle_index': 0,
    '${prefix}_pillar_stem_index': 0,
    '${prefix}_pillar_branch_index': 0,
    '${prefix}_pillar_hanja': '甲子',
    '${prefix}_pillar_korean_label': '갑자',
  },
  'engine_id': 'rynSajuHybrid',
  'engine_version': '1.0.0',
  'policy_id': 'cheonEulGwiInModernKstV1',
  'policy_version': '1.0.0',
  'day_rollover_policy': 'pendingCheonEulCapture',
  'longitude_correction_policy': 'cheonEulObservedSeoulMinus30MinutesV1',
  'dst_correction_policy': 'modernRangeNoDst',
  'supported_range_version': 'modern-seoul-1990-2050-v1',
  'solar_term_algorithm_version': 'test',
  'lunar_converter_version': 'test',
  'day_anchor_version': 'gregorian-jdn-plus49-v1',
  'time_scale_adapter_version': 'test',
  'warnings_json': '[]',
  'input_fingerprint_sha256':
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  'calculation_signature_sha256':
      'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
};

String _insertSql(Map<String, Object?> values) {
  final columns = values.keys.join(', ');
  final encoded = values.values.map((value) {
    if (value == null) return 'NULL';
    if (value is num) return '$value';
    return "'${value.toString().replaceAll("'", "''")}'";
  }).join(', ');
  return 'INSERT INTO saju_chart_snapshots ($columns) VALUES ($encoded)';
}

Future<int> _count(RynAppDatabase database, String table) async =>
    (await database
            .customSelect('SELECT count(*) AS total FROM $table')
            .getSingle())
        .read<int>('total');
