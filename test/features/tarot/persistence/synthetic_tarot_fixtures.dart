import 'package:ryn_universe_os_core/features/tarot/domain/tarot_persistence_models.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_interpretation_session_draft.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_reading_result_snapshot.dart';

const syntheticQuestionA = 'SYNTHETIC_QUESTION_A';
const syntheticQuestionDisplayA = 'SYNTHETIC_QUESTION_DISPLAY_A';
const syntheticObservationA = 'SYNTHETIC_OBSERVATION_A';
const syntheticFlowA = 'SYNTHETIC_FLOW_A';
const syntheticMessageA = 'SYNTHETIC_MESSAGE_A';
const syntheticActionA = 'SYNTHETIC_ACTION_A';

CompletedTarotReadingPersistenceInput syntheticInput({
  String readingId = 'reading.synthetic.01',
  int placementCount = 1,
  TarotReadingOrigin sourceType = TarotReadingOrigin.selfDrawn,
  int timezoneOffsetMinutes = 540,
  bool includeInterpretation = true,
  String question = syntheticQuestionA,
}) {
  final placements = List<TarotCardPlacementSnapshot>.generate(
    placementCount,
    (index) => TarotCardPlacementSnapshot(
      placementOrder: index + 1,
      positionId: 'position.test.${(index + 1).toString().padLeft(2, '0')}',
      positionNameSnapshot: 'POSITION_TEST_${index + 1}',
      cardId: 'card.test.${(index + 1).toString().padLeft(2, '0')}',
      cardNameSnapshot: 'CARD_TEST_${index + 1}',
      orientation: switch (index % 3) {
        0 => TarotCardOrientation.upright,
        1 => TarotCardOrientation.reversed,
        _ => TarotCardOrientation.notUsed,
      },
    ),
  );
  final snapshot = TarotReadingResultSnapshot.validated(
    readingInstanceId: readingId,
    readingQuestionText: question,
    deckId: 'deck.test',
    deckNameSnapshot: 'DECK_TEST',
    spreadId: placementCount == 10 ? 'spread.test.celtic' : 'spread.test',
    spreadNameSnapshot: placementCount == 10
        ? 'SPREAD_TEST_CELTIC'
        : 'SPREAD_TEST',
    readingAt: DateTime.utc(2026, 1, 2, 3, 4, 5, 600),
    placements: placements,
    expectedPlacementCount: placementCount,
    selectedDeckCardIds: placements.map((item) => item.cardId).toSet(),
  );
  return CompletedTarotReadingPersistenceInput(
    snapshot: snapshot,
    sourceType: sourceType,
    readingTimezoneOffsetMinutes: timezoneOffsetMinutes,
    interpretation: includeInterpretation
        ? TarotInterpretationSessionDraft(
            readingInstanceId: readingId,
            wholeImageObservation: syntheticObservationA,
            flowInterpretation: syntheticFlowA,
            coreMessage: syntheticMessageA,
            smallAction: syntheticActionA,
          )
        : null,
  );
}
