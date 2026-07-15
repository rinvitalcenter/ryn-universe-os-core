import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/core/repositories/repository_result.dart';
import 'package:ryn_universe_os_core/features/tarot/data/persistence/tarot_persistence_mapper.dart';

import 'synthetic_tarot_fixtures.dart';

const nowUs = 1767225600000000;

void main() {
  const mapper = TarotPersistenceMapper();

  group('TarotPersistenceMapper write mapping', () {
    test('first display question equals immutable original question', () {
      final result = mapper.toWriteSet(syntheticInput(), nowUtcUs: nowUs);

      expect(result.isSuccess, isTrue);
      expect(
        result.value!.reading.questionOriginalSnapshot.value,
        syntheticQuestionA,
      );
      expect(
        result.value!.reading.questionDisplayText.value,
        syntheticQuestionA,
      );
    });

    test('timezone offset is passed through without device recomputation', () {
      final result = mapper.toWriteSet(
        syntheticInput(timezoneOffsetMinutes: -480),
        nowUtcUs: nowUs,
      );

      expect(result.value!.reading.readingTimezoneOffsetMin.value, -480);
    });

    test('orientation mapping is exhaustive for reversed and notUsed', () {
      final result = mapper.toWriteSet(
        syntheticInput(placementCount: 3),
        nowUtcUs: nowUs,
      );

      expect(
        result.value!.placements.map((row) => row.orientation.value),
        <String>['upright', 'reversed', 'not_used'],
      );
    });

    test('interpretation maps outside the immutable Snapshot', () {
      final result = mapper.toWriteSet(syntheticInput(), nowUtcUs: nowUs);

      expect(result.value!.interpretation, isNotNull);
      expect(
        result.value!.interpretation!.wholeImageObservation.value,
        syntheticObservationA,
      );
      expect(
        result.value!.reading.toString().contains(syntheticObservationA),
        isFalse,
      );
    });
  });

  group('TarotPersistenceMapper hydration', () {
    for (final count in <int>[1, 3, 10]) {
      test('$count-card persisted rows round trip', () {
        final input = syntheticInput(placementCount: count);
        final rows = mapper.toWriteSet(input, nowUtcUs: nowUs).value!;
        final hydrated = mapper.hydrate(
          reading: _readingFrom(rows),
          placements: _placementsFrom(rows),
          interpretation: _interpretationFrom(rows),
        );

        expect(hydrated.isSuccess, isTrue);
        expect(hydrated.value!.snapshot.placements, hasLength(count));
        expect(
          hydrated.value!.snapshot.readingInstanceId,
          input.snapshot.readingInstanceId,
        );
      });
    }

    test('original and display questions remain distinct', () {
      final reading = _validReading(questionDisplay: syntheticQuestionDisplayA);
      final hydrated = mapper.hydrate(
        reading: reading,
        placements: <TarotCardPlacement>[_validPlacement()],
        interpretation: null,
      );

      expect(hydrated.value!.snapshot.readingQuestionText, syntheticQuestionA);
      expect(hydrated.value!.questionDisplayText, syntheticQuestionDisplayA);
    });

    test('missing interpretation row is valid', () {
      final hydrated = mapper.hydrate(
        reading: _validReading(),
        placements: <TarotCardPlacement>[_validPlacement()],
        interpretation: null,
      );

      expect(hydrated.isSuccess, isTrue);
      expect(hydrated.value!.interpretation, isNull);
    });

    test(
      'discontinuous placement order is a controlled validation failure',
      () {
        final hydrated = mapper.hydrate(
          reading: _validReading(expectedCount: 2),
          placements: <TarotCardPlacement>[
            _validPlacement(),
            _validPlacement(order: 3, positionId: 'position.test.03'),
          ],
          interpretation: null,
        );

        expect(hydrated.error?.code, RepositoryErrorCode.validationFailed);
      },
    );

    test('duplicate position ID is a controlled validation failure', () {
      final hydrated = mapper.hydrate(
        reading: _validReading(expectedCount: 2),
        placements: <TarotCardPlacement>[
          _validPlacement(),
          _validPlacement(order: 2),
        ],
        interpretation: null,
      );

      expect(hydrated.error?.code, RepositoryErrorCode.validationFailed);
    });

    test('unknown persisted enum values are controlled failures', () {
      final unknownSource = mapper.hydrate(
        reading: _validReading(sourceType: 'future_source'),
        placements: <TarotCardPlacement>[_validPlacement()],
        interpretation: null,
      );
      final unknownLifecycle = mapper.hydrate(
        reading: _validReading(lifecycle: 'future_lifecycle'),
        placements: <TarotCardPlacement>[_validPlacement()],
        interpretation: null,
      );
      final unknownOrientation = mapper.hydrate(
        reading: _validReading(),
        placements: <TarotCardPlacement>[
          _validPlacement(orientation: 'future_orientation'),
        ],
        interpretation: null,
      );

      expect(unknownSource.error?.code, RepositoryErrorCode.validationFailed);
      expect(
        unknownLifecycle.error?.code,
        RepositoryErrorCode.validationFailed,
      );
      expect(
        unknownOrientation.error?.code,
        RepositoryErrorCode.validationFailed,
      );
    });

    test('mismatched interpretation reading ID is rejected', () {
      final hydrated = mapper.hydrate(
        reading: _validReading(),
        placements: <TarotCardPlacement>[_validPlacement()],
        interpretation: const TarotInterpretation(
          readingInstanceId: 'reading.synthetic.other',
          wholeImageObservation: '',
          flowInterpretation: '',
          coreMessage: '',
          smallAction: '',
          createdAtUtcUs: nowUs,
          updatedAtUtcUs: nowUs,
        ),
      );

      expect(hydrated.error?.code, RepositoryErrorCode.validationFailed);
    });
  });
}

TarotReading _readingFrom(TarotPersistenceWriteSet rows) => TarotReading(
  readingInstanceId: rows.reading.readingInstanceId.value,
  sourceType: rows.reading.sourceType.value,
  questionOriginalSnapshot: rows.reading.questionOriginalSnapshot.value,
  questionDisplayText: rows.reading.questionDisplayText.value,
  deckId: rows.reading.deckId.value,
  deckNameSnapshot: rows.reading.deckNameSnapshot.value,
  spreadId: rows.reading.spreadId.value,
  spreadNameSnapshot: rows.reading.spreadNameSnapshot.value,
  expectedPlacementCount: rows.reading.expectedPlacementCount.value,
  readingAtUtcUs: rows.reading.readingAtUtcUs.value,
  readingTimezoneOffsetMin: rows.reading.readingTimezoneOffsetMin.value,
  createdAtUtcUs: rows.reading.createdAtUtcUs.value,
  updatedAtUtcUs: rows.reading.updatedAtUtcUs.value,
  lifecycleStatus: rows.reading.lifecycleStatus.value,
  finishedAtUtcUs: rows.reading.finishedAtUtcUs.value,
);

List<TarotCardPlacement> _placementsFrom(TarotPersistenceWriteSet rows) => rows
    .placements
    .map(
      (row) => TarotCardPlacement(
        readingInstanceId: row.readingInstanceId.value,
        placementOrder: row.placementOrder.value,
        positionId: row.positionId.value,
        positionNameSnapshot: row.positionNameSnapshot.value,
        cardId: row.cardId.value,
        cardNameSnapshot: row.cardNameSnapshot.value,
        orientation: row.orientation.value,
      ),
    )
    .toList();

TarotInterpretation? _interpretationFrom(TarotPersistenceWriteSet rows) {
  final row = rows.interpretation;
  if (row == null) return null;
  return TarotInterpretation(
    readingInstanceId: row.readingInstanceId.value,
    wholeImageObservation: row.wholeImageObservation.value,
    flowInterpretation: row.flowInterpretation.value,
    coreMessage: row.coreMessage.value,
    smallAction: row.smallAction.value,
    createdAtUtcUs: row.createdAtUtcUs.value,
    updatedAtUtcUs: row.updatedAtUtcUs.value,
  );
}

TarotReading _validReading({
  int expectedCount = 1,
  String sourceType = 'self_drawn',
  String lifecycle = 'continuing',
  String questionDisplay = syntheticQuestionA,
}) => TarotReading(
  readingInstanceId: 'reading.synthetic.01',
  sourceType: sourceType,
  questionOriginalSnapshot: syntheticQuestionA,
  questionDisplayText: questionDisplay,
  deckId: 'deck.test',
  deckNameSnapshot: 'DECK_TEST',
  spreadId: 'spread.test',
  spreadNameSnapshot: 'SPREAD_TEST',
  expectedPlacementCount: expectedCount,
  readingAtUtcUs: nowUs,
  readingTimezoneOffsetMin: 540,
  createdAtUtcUs: nowUs,
  updatedAtUtcUs: nowUs,
  lifecycleStatus: lifecycle,
  finishedAtUtcUs: lifecycle == 'finished' ? nowUs : null,
);

TarotCardPlacement _validPlacement({
  int order = 1,
  String positionId = 'position.test.01',
  String orientation = 'upright',
}) => TarotCardPlacement(
  readingInstanceId: 'reading.synthetic.01',
  placementOrder: order,
  positionId: positionId,
  positionNameSnapshot: 'POSITION_TEST_$order',
  cardId: 'card.test.${order.toString().padLeft(2, '0')}',
  cardNameSnapshot: 'CARD_TEST_$order',
  orientation: orientation,
);
