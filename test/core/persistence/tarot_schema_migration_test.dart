import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/core/persistence/migrations.dart';

void main() {
  group('Tarot schema v5', () {
    late RynAppDatabase database;

    setUp(() {
      database = RynAppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test(
      'fresh database creates schema version 5 and four Tarot tables',
      () async {
        expect(database.schemaVersion, 5);
        expect(plannedCurrentSchemaVersion, 5);

        final tables = await _tableNames(database);
        expect(
          tables,
          containsAll(<String>{
            'tarot_readings',
            'tarot_card_placements',
            'tarot_interpretations',
            'app_runtime_state',
          }),
        );
      },
    );

    test(
      'fresh database creates exactly one deterministic main state row',
      () async {
        final rows = await database
            .customSelect(
              'SELECT state_key, active_home_tarot_reading_id, updated_at_utc_us '
              'FROM app_runtime_state',
            )
            .get();

        expect(rows, hasLength(1));
        expect(rows.single.read<String>('state_key'), 'main');
        expect(
          rows.single.readNullable<String>('active_home_tarot_reading_id'),
          isNull,
        );
        expect(rows.single.read<int>('updated_at_utc_us'), 0);
      },
    );

    test('source type check rejects unsupported values', () async {
      await expectLater(
        _insertReading(database, sourceType: 'unsupported'),
        throwsA(anything),
      );
    });

    test(
      'lifecycle check and finish timestamp consistency are enforced',
      () async {
        await expectLater(
          _insertReading(database, lifecycle: 'paused'),
          throwsA(anything),
        );
        await expectLater(
          _insertReading(
            database,
            id: 'reading-finished-null',
            lifecycle: 'finished',
          ),
          throwsA(anything),
        );
        await expectLater(
          _insertReading(
            database,
            id: 'reading-continuing-finished',
            lifecycle: 'continuing',
            finishedAt: 20,
          ),
          throwsA(anything),
        );
      },
    );

    test('timezone offset is constrained to minus 840 through 840', () async {
      await expectLater(
        _insertReading(database, timezoneOffset: -841),
        throwsA(anything),
      );
      await expectLater(
        _insertReading(
          database,
          id: 'reading-offset-high',
          timezoneOffset: 841,
        ),
        throwsA(anything),
      );
      await _insertReading(
        database,
        id: 'reading-offset-low-edge',
        timezoneOffset: -840,
      );
      await _insertReading(
        database,
        id: 'reading-offset-high-edge',
        timezoneOffset: 840,
      );
    });

    test('orientation check rejects unsupported values', () async {
      await _insertReading(database);
      await expectLater(
        database.customStatement(
          'INSERT INTO tarot_card_placements '
          '(reading_instance_id, placement_order, position_id, '
          'position_name_snapshot, card_id, card_name_snapshot, orientation) '
          "VALUES ('reading.test', 1, 'position.test', 'POSITION_TEST', "
          "'card.test.01', 'CARD_TEST_01', 'sideways')",
        ),
        throwsA(anything),
      );
    });

    test(
      'placement composite primary key and unique position are enforced',
      () async {
        await _insertReading(database);
        await _insertPlacement(
          database,
          order: 1,
          positionId: 'position.test.1',
        );

        await expectLater(
          _insertPlacement(database, order: 1, positionId: 'position.test.2'),
          throwsA(anything),
        );
        await expectLater(
          _insertPlacement(database, order: 2, positionId: 'position.test.1'),
          throwsA(anything),
        );

        final info = await database
            .customSelect('PRAGMA table_info(tarot_card_placements)')
            .get();
        final pkColumns = <String, int>{
          for (final row in info) row.read<String>('name'): row.read<int>('pk'),
        };
        expect(pkColumns['reading_instance_id'], 1);
        expect(pkColumns['placement_order'], 2);
      },
    );

    test('foreign keys reject orphans and restrict parent deletion', () async {
      await expectLater(
        _insertPlacement(database, order: 1, positionId: 'position.orphan'),
        throwsA(anything),
      );
      await expectLater(
        database.customStatement(
          'INSERT INTO tarot_interpretations '
          '(reading_instance_id, created_at_utc_us, updated_at_utc_us) '
          "VALUES ('missing.reading', 1, 1)",
        ),
        throwsA(anything),
      );
      await expectLater(
        database.customStatement(
          "UPDATE app_runtime_state SET active_home_tarot_reading_id = 'missing.reading' "
          "WHERE state_key = 'main'",
        ),
        throwsA(anything),
      );

      await _insertReading(database);
      await _insertPlacement(database, order: 1, positionId: 'position.parent');
      await expectLater(
        database.customStatement(
          "DELETE FROM tarot_readings WHERE reading_instance_id = 'reading.test'",
        ),
        throwsA(anything),
      );
    });

    test(
      'trimmed non-empty identity and question constraints are enforced',
      () async {
        await expectLater(
          _insertReading(database, id: '   '),
          throwsA(anything),
        );
        await expectLater(
          database.customStatement(
            'INSERT INTO tarot_readings '
            '(reading_instance_id, source_type, question_original_snapshot, '
            'question_display_text, deck_id, deck_name_snapshot, spread_id, '
            'spread_name_snapshot, expected_placement_count, reading_at_utc_us, '
            'reading_timezone_offset_min, created_at_utc_us, updated_at_utc_us, '
            'lifecycle_status) VALUES '
            "('reading.blank.question', 'self_drawn', '   ', 'SYNTHETIC_QUESTION_A', "
            "'deck.test', 'DECK_TEST', 'spread.test', 'SPREAD_TEST', 1, 1, 0, 1, 1, "
            "'continuing')",
          ),
          throwsA(anything),
        );
      },
    );

    test(
      'singleton state key constraint rejects every key except main',
      () async {
        await expectLater(
          database.customStatement(
            "INSERT INTO app_runtime_state (state_key, updated_at_utc_us) VALUES ('other', 1)",
          ),
          throwsA(anything),
        );
      },
    );
  });

  group('Tarot add-only migration 4 to 5', () {
    test(
      'preserves governance data, adds four tables, and fabricates no Tarot rows',
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
        expect(
          tables,
          containsAll(<String>{
            'app_settings',
            'tarot_readings',
            'tarot_card_placements',
            'tarot_interpretations',
            'app_runtime_state',
          }),
        );
        expect(await _count(database, 'tarot_readings'), 0);
        expect(await _count(database, 'tarot_card_placements'), 0);
        expect(await _count(database, 'tarot_interpretations'), 0);
        expect(await _count(database, 'app_runtime_state'), 1);
      },
    );

    test(
      'unsupported older migration path fails without destructive recreation',
      () async {
        final database = RynAppDatabase(
          NativeDatabase.memory(
            setup: (raw) {
              raw.execute(_version4AppSettingsSql);
              raw.execute('PRAGMA user_version = 3');
            },
          ),
        );
        addTearDown(database.close);

        await expectLater(
          database.customSelect('SELECT 1').get(),
          throwsA(isA<StateError>()),
        );
      },
    );

    test(
      'unexpected newer schema fails instead of being silently accepted',
      () async {
        final database = RynAppDatabase(
          NativeDatabase.memory(
            setup: (raw) {
              raw.execute(_version4AppSettingsSql);
              raw.execute('PRAGMA user_version = 6');
            },
          ),
        );
        addTearDown(database.close);

        await expectLater(
          database.customSelect('SELECT 1').get(),
          throwsA(anything),
        );
      },
    );
  });
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

Future<void> _insertReading(
  RynAppDatabase database, {
  String id = 'reading.test',
  String sourceType = 'self_drawn',
  String lifecycle = 'continuing',
  int timezoneOffset = 540,
  int? finishedAt,
}) {
  return database.customStatement(
    'INSERT INTO tarot_readings '
    '(reading_instance_id, source_type, question_original_snapshot, '
    'question_display_text, deck_id, deck_name_snapshot, spread_id, '
    'spread_name_snapshot, expected_placement_count, reading_at_utc_us, '
    'reading_timezone_offset_min, created_at_utc_us, updated_at_utc_us, '
    'lifecycle_status, finished_at_utc_us) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    <Object?>[
      id,
      sourceType,
      'SYNTHETIC_QUESTION_A',
      'SYNTHETIC_QUESTION_A',
      'deck.test',
      'DECK_TEST',
      'spread.test',
      'SPREAD_TEST',
      1,
      1,
      timezoneOffset,
      10,
      10,
      lifecycle,
      finishedAt,
    ],
  );
}

Future<void> _insertPlacement(
  RynAppDatabase database, {
  required int order,
  required String positionId,
}) {
  return database.customStatement(
    'INSERT INTO tarot_card_placements '
    '(reading_instance_id, placement_order, position_id, '
    'position_name_snapshot, card_id, card_name_snapshot, orientation) '
    'VALUES (?, ?, ?, ?, ?, ?, ?)',
    <Object?>[
      'reading.test',
      order,
      positionId,
      'POSITION_TEST_$order',
      'card.test.${order.toString().padLeft(2, '0')}',
      'CARD_TEST_$order',
      'upright',
    ],
  );
}

void _createSyntheticVersion4Database(dynamic raw) {
  raw.execute(_version4AppSettingsSql);
  raw.execute(
    "INSERT INTO app_settings "
    "(key, value, value_type, redaction_state, updated_at) VALUES "
    "('synthetic.setting', 'SYNTHETIC_VALUE', 'string', 'none_required', 1)",
  );
  raw.execute('PRAGMA user_version = 4');
}

const String _version4AppSettingsSql = '''
CREATE TABLE app_settings (
  key TEXT NOT NULL PRIMARY KEY,
  value TEXT NULL,
  value_type TEXT NOT NULL DEFAULT 'string',
  redaction_state TEXT NOT NULL DEFAULT 'none_required',
  updated_at INTEGER NOT NULL
)
''';
