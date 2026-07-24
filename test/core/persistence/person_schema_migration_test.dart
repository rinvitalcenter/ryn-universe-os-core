import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/core/persistence/migrations.dart';

const personTables = <String>{
  'persons',
  'person_roles',
  'person_relationships',
  'person_birth_profiles',
  'encounters',
  'encounter_notes',
};

void main() {
  test(
    'fresh database creates schema version 7 and all Person Core tables',
    () async {
      final database = RynAppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      expect(database.schemaVersion, 7);
      expect(plannedCurrentSchemaVersion, 7);
      expect(await _tableNames(database), containsAll(personTables));
    },
  );

  test(
    'schema 5 to 6 preserves Tarot data and adds empty Person tables',
    () async {
      final database = RynAppDatabase(
        NativeDatabase.memory(setup: _createSyntheticVersion5Database),
      );
      addTearDown(database.close);

      final reading = await database
          .customSelect(
            "SELECT question_display_text FROM tarot_readings WHERE reading_instance_id = 'reading.synthetic.v5'",
          )
          .getSingle();
      expect(
        reading.read<String>('question_display_text'),
        'SYNTHETIC_V5_QUESTION',
      );
      expect(await _tableNames(database), containsAll(personTables));
      expect(await _count(database, 'persons'), 0);
    },
  );

  test(
    'schema 4 to 5 to 6 preserves governance data and adds all tables',
    () async {
      final database = RynAppDatabase(
        NativeDatabase.memory(setup: _createSyntheticVersion4Database),
      );
      addTearDown(database.close);

      final setting = await database
          .customSelect(
            "SELECT value FROM app_settings WHERE key = 'synthetic.setting'",
          )
          .getSingle();
      expect(setting.read<String>('value'), 'SYNTHETIC_VALUE');
      final tables = await _tableNames(database);
      expect(tables, containsAll(personTables));
      expect(tables, contains('tarot_readings'));
      expect(await _count(database, 'persons'), 0);
      expect(await _count(database, 'tarot_readings'), 0);
    },
  );
}

Future<Set<String>> _tableNames(RynAppDatabase database) async {
  final rows = await database
      .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
      .get();
  return rows.map((row) => row.read<String>('name')).toSet();
}

Future<int> _count(RynAppDatabase database, String table) async {
  final row = await database
      .customSelect('SELECT COUNT(*) AS total FROM $table')
      .getSingle();
  return row.read<int>('total');
}

void _createSyntheticVersion4Database(dynamic raw) {
  raw.execute(_version4AppSettingsSql);
  raw.execute(
    "INSERT INTO app_settings (key, value, value_type, redaction_state, updated_at) "
    "VALUES ('synthetic.setting', 'SYNTHETIC_VALUE', 'string', 'none_required', 1)",
  );
  raw.execute('PRAGMA user_version = 4');
}

void _createSyntheticVersion5Database(dynamic raw) {
  _createSyntheticVersion4Database(raw);
  raw.execute(_tarotReadingsSql);
  raw.execute(_tarotCardPlacementsSql);
  raw.execute(_tarotInterpretationsSql);
  raw.execute(_appRuntimeStateSql);
  raw.execute("INSERT INTO app_runtime_state VALUES ('main', NULL, 0)");
  raw.execute(
    "INSERT INTO tarot_readings (reading_instance_id, source_type, "
    "question_original_snapshot, question_display_text, deck_id, deck_name_snapshot, "
    "spread_id, spread_name_snapshot, expected_placement_count, reading_at_utc_us, "
    "reading_timezone_offset_min, created_at_utc_us, updated_at_utc_us, lifecycle_status) "
    "VALUES ('reading.synthetic.v5', 'self_drawn', 'SYNTHETIC_V5_QUESTION', "
    "'SYNTHETIC_V5_QUESTION', 'deck.synthetic', 'SYNTHETIC_DECK', 'spread.synthetic', "
    "'SYNTHETIC_SPREAD', 1, 1, 0, 1, 1, 'continuing')",
  );
  raw.execute('PRAGMA user_version = 5');
}

const _version4AppSettingsSql = '''
CREATE TABLE app_settings (
  key TEXT NOT NULL PRIMARY KEY,
  value TEXT NULL,
  value_type TEXT NOT NULL DEFAULT 'string',
  redaction_state TEXT NOT NULL DEFAULT 'none_required',
  updated_at INTEGER NOT NULL
)
''';

const _tarotReadingsSql = '''
CREATE TABLE tarot_readings (
  reading_instance_id TEXT NOT NULL PRIMARY KEY,
  source_type TEXT NOT NULL,
  question_original_snapshot TEXT NOT NULL,
  question_display_text TEXT NOT NULL,
  deck_id TEXT NOT NULL,
  deck_name_snapshot TEXT NOT NULL,
  spread_id TEXT NOT NULL,
  spread_name_snapshot TEXT NOT NULL,
  expected_placement_count INTEGER NOT NULL,
  reading_at_utc_us INTEGER NOT NULL,
  reading_timezone_offset_min INTEGER NOT NULL,
  created_at_utc_us INTEGER NOT NULL,
  updated_at_utc_us INTEGER NOT NULL,
  lifecycle_status TEXT NOT NULL,
  finished_at_utc_us INTEGER NULL
)
''';
const _tarotCardPlacementsSql = '''
CREATE TABLE tarot_card_placements (
  reading_instance_id TEXT NOT NULL,
  placement_order INTEGER NOT NULL,
  position_id TEXT NOT NULL,
  position_name_snapshot TEXT NOT NULL,
  card_id TEXT NOT NULL,
  card_name_snapshot TEXT NOT NULL,
  orientation TEXT NOT NULL,
  PRIMARY KEY(reading_instance_id, placement_order)
)
''';
const _tarotInterpretationsSql = '''
CREATE TABLE tarot_interpretations (
  reading_instance_id TEXT NOT NULL PRIMARY KEY,
  whole_image_observation TEXT NOT NULL DEFAULT '',
  flow_interpretation TEXT NOT NULL DEFAULT '',
  core_message TEXT NOT NULL DEFAULT '',
  small_action TEXT NOT NULL DEFAULT '',
  created_at_utc_us INTEGER NOT NULL,
  updated_at_utc_us INTEGER NOT NULL
)
''';
const _appRuntimeStateSql = '''
CREATE TABLE app_runtime_state (
  state_key TEXT NOT NULL PRIMARY KEY,
  active_home_tarot_reading_id TEXT NULL,
  updated_at_utc_us INTEGER NOT NULL
)
''';
