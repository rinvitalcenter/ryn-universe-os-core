import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';

void main() {
  test(
    'Tarot schema persists no assets, identity, blobs, or external fields',
    () async {
      final database = RynAppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final rows = await database
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE type = 'table' "
            "AND name IN ('tarot_readings', 'tarot_card_placements', "
            "'tarot_interpretations', 'app_runtime_state')",
          )
          .get();
      final schema = rows
          .map((row) => row.read<String>('sql').toLowerCase())
          .join('\n');

      for (final forbidden in <String>[
        'person_id',
        'member_id',
        'study_session_id',
        'phone',
        'email',
        'birth_date',
        'birth_time',
        'asset_path',
        'image_blob',
        'audio_blob',
        'external_url',
        'api_url',
      ]) {
        expect(schema.contains(forbidden), isFalse, reason: forbidden);
      }
    },
  );

  test('synthetic fixtures contain no personal identity data', () {
    final fixture = File(
      'test/features/tarot/persistence/synthetic_tarot_fixtures.dart',
    ).readAsStringSync().toLowerCase();

    for (final forbidden in <String>[
      'person_id',
      'member_id',
      'phone',
      'email',
      'birth',
      'consultation',
    ]) {
      expect(fixture.contains(forbidden), isFalse, reason: forbidden);
    }
    expect(fixture.contains('synthetic_question_a'), isTrue);
    expect(fixture.contains('deck.test'), isTrue);
    expect(fixture.contains('card.test.'), isTrue);
  });

  test(
    'persistence implementation has no production path or asset resolution',
    () {
      final sourceFiles = <String>[
        'lib/features/tarot/data/persistence/tarot_tables.dart',
        'lib/features/tarot/data/persistence/tarot_persistence_mapper.dart',
        'lib/features/tarot/data/persistence/tarot_reading_repository.dart',
        'lib/features/tarot/data/persistence/drift_tarot_reading_repository.dart',
      ];
      final source = sourceFiles
          .map((path) => File(path).readAsStringSync())
          .join('\n')
          .toLowerCase();

      expect(source.contains('getapplicationsupportdirectory'), isFalse);
      expect(source.contains('rynappdatabase.open('), isFalse);
      expect(source.contains('assetpath'), isFalse);
      expect(source.contains('imagebytes'), isFalse);
    },
  );
}
