enum TarotCardOrientation { notUsed, upright, reversed }

final class TarotCardPlacementSnapshot {
  TarotCardPlacementSnapshot({
    required this.placementOrder,
    required String cardId,
    required String cardNameSnapshot,
    required String positionId,
    required String positionNameSnapshot,
    required this.orientation,
  }) : cardId = _requiredText(cardId, 'cardId'),
       cardNameSnapshot = _requiredText(cardNameSnapshot, 'cardNameSnapshot'),
       positionId = _requiredText(positionId, 'positionId'),
       positionNameSnapshot = _requiredText(
         positionNameSnapshot,
         'positionNameSnapshot',
       ) {
    if (placementOrder < 1) {
      throw ArgumentError.value(
        placementOrder,
        'placementOrder',
        'must start at 1',
      );
    }
  }

  final int placementOrder;
  final String cardId;
  final String cardNameSnapshot;
  final String positionId;
  final String positionNameSnapshot;
  final TarotCardOrientation orientation;
}

final class TarotReadingResultSnapshot {
  TarotReadingResultSnapshot._({
    required this.readingInstanceId,
    required this.readingQuestionText,
    required this.deckId,
    required this.deckNameSnapshot,
    required this.spreadId,
    required this.spreadNameSnapshot,
    required this.readingAt,
    required this.placements,
  });

  factory TarotReadingResultSnapshot.validated({
    required String readingInstanceId,
    required String readingQuestionText,
    required String deckId,
    required String deckNameSnapshot,
    required String spreadId,
    required String spreadNameSnapshot,
    required DateTime readingAt,
    required List<TarotCardPlacementSnapshot> placements,
    required int expectedPlacementCount,
    required Set<String> selectedDeckCardIds,
  }) {
    final normalizedIdentity = _requiredText(
      readingInstanceId,
      'readingInstanceId',
    );
    final normalizedQuestion = _requiredText(
      readingQuestionText,
      'readingQuestionText',
    );
    final normalizedDeckId = _requiredText(deckId, 'deckId');
    final normalizedDeckName = _requiredText(
      deckNameSnapshot,
      'deckNameSnapshot',
    );
    final normalizedSpreadId = _requiredText(spreadId, 'spreadId');
    final normalizedSpreadName = _requiredText(
      spreadNameSnapshot,
      'spreadNameSnapshot',
    );
    final frozenPlacements = List<TarotCardPlacementSnapshot>.unmodifiable(
      placements,
    );

    if (frozenPlacements.isEmpty) {
      throw ArgumentError.value(placements, 'placements', 'must not be empty');
    }
    if (expectedPlacementCount != frozenPlacements.length) {
      throw ArgumentError.value(
        expectedPlacementCount,
        'expectedPlacementCount',
        'must match completed placement count',
      );
    }

    final positionIds = <String>{};
    for (var index = 0; index < frozenPlacements.length; index++) {
      final placement = frozenPlacements[index];
      final expectedOrder = index + 1;
      if (placement.placementOrder != expectedOrder) {
        throw ArgumentError.value(
          placement.placementOrder,
          'placements[$index].placementOrder',
          'must be continuous from 1',
        );
      }
      if (!positionIds.add(placement.positionId)) {
        throw ArgumentError.value(
          placement.positionId,
          'placements[$index].positionId',
          'must be unique within a reading',
        );
      }
      if (!selectedDeckCardIds.contains(placement.cardId)) {
        throw ArgumentError.value(
          placement.cardId,
          'placements[$index].cardId',
          'must belong to the selected deck',
        );
      }
    }

    return TarotReadingResultSnapshot._(
      readingInstanceId: normalizedIdentity,
      readingQuestionText: normalizedQuestion,
      deckId: normalizedDeckId,
      deckNameSnapshot: normalizedDeckName,
      spreadId: normalizedSpreadId,
      spreadNameSnapshot: normalizedSpreadName,
      readingAt: readingAt,
      placements: frozenPlacements,
    );
  }

  final String readingInstanceId;
  final String readingQuestionText;
  final String deckId;
  final String deckNameSnapshot;
  final String spreadId;
  final String spreadNameSnapshot;
  final DateTime readingAt;
  final List<TarotCardPlacementSnapshot> placements;
}

String _requiredText(String value, String fieldName) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(value, fieldName, 'must not be empty');
  }
  return normalized;
}
