import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/tarot/domain/tarot_persistence_models.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_interpretation_session_draft.dart';

import 'synthetic_tarot_fixtures.dart';

void main() {
  group('CompletedTarotReadingPersistenceInput', () {
    test('accepts one, three, and ten card synthetic completed results', () {
      expect(syntheticInput().snapshot.placements, hasLength(1));
      expect(
        syntheticInput(placementCount: 3).snapshot.placements,
        hasLength(3),
      );
      expect(
        syntheticInput(placementCount: 10).snapshot.placements,
        hasLength(10),
      );
    });

    test('rejects interpretation draft for a different reading ID', () {
      final base = syntheticInput(includeInterpretation: false);

      expect(
        () => CompletedTarotReadingPersistenceInput(
          snapshot: base.snapshot,
          sourceType: TarotReadingOrigin.selfDrawn,
          personId: null,
          readingTimezoneOffsetMinutes: 540,
          interpretation: const TarotInterpretationSessionDraft(
            readingInstanceId: 'reading.synthetic.other',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rejects timezone offsets outside the supported range', () {
      final base = syntheticInput(includeInterpretation: false);

      expect(
        () => CompletedTarotReadingPersistenceInput(
          snapshot: base.snapshot,
          sourceType: TarotReadingOrigin.selfDrawn,
          personId: null,
          readingTimezoneOffsetMinutes: 841,
        ),
        throwsArgumentError,
      );
    });

    test('self reading rejects a Person link', () {
      expect(
        () => syntheticInput(personId: 'person.synthetic.001'),
        throwsArgumentError,
      );
    });

    test('manual reading requires a trimmed canonical Person ID', () {
      expect(
        () => syntheticInput(sourceType: TarotReadingOrigin.manuallyRecorded),
        throwsArgumentError,
      );
      expect(
        () => syntheticInput(
          sourceType: TarotReadingOrigin.manuallyRecorded,
          personId: '   ',
        ),
        throwsArgumentError,
      );

      final input = syntheticInput(
        sourceType: TarotReadingOrigin.manuallyRecorded,
        personId: '  person.synthetic.001  ',
      );
      expect(input.personId, 'person.synthetic.001');
    });
  });

  test('repository contract exposes no hard-delete operation', () {
    final source = File(
      'lib/features/tarot/data/persistence/tarot_reading_repository.dart',
    ).readAsStringSync();
    expect(source.contains('hardDeleteReading'), isFalse);
    expect(source.contains('deleteAll'), isFalse);
  });
}
