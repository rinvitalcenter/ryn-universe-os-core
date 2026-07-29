final class TarotSpreadPositionDefinition {
  const TarotSpreadPositionDefinition({
    required this.id,
    required this.displayName,
  });

  final String id;
  final String displayName;
}

final class TarotSpreadDefinition {
  const TarotSpreadDefinition({
    required this.id,
    required this.displayName,
    required this.positions,
  });

  final String id;
  final String displayName;
  final List<TarotSpreadPositionDefinition> positions;
}

/// Canonical semantic identities shared by self-reading and manual recording.
/// Visual geometry remains owned by the immersive self-reading surface.
abstract final class TarotSpreadRegistry {
  static const oneCardId = 'one_card';
  static const oneCardName = '1카드';
  static const oneCardPositionId = 'one_center';
  static const oneCardPositionName = '핵심';
  static const threeCardId = 'three_card';
  static const threeCardName = '3카드';
  static const threePastPositionId = 'three_past';
  static const threePastPositionName = '과거';
  static const threePresentPositionId = 'three_present';
  static const threePresentPositionName = '현재';
  static const threeFuturePositionId = 'three_future';
  static const threeFuturePositionName = '미래';

  static const oneCard = TarotSpreadDefinition(
    id: oneCardId,
    displayName: oneCardName,
    positions: [
      TarotSpreadPositionDefinition(
        id: oneCardPositionId,
        displayName: oneCardPositionName,
      ),
    ],
  );

  static const threeCard = TarotSpreadDefinition(
    id: threeCardId,
    displayName: threeCardName,
    positions: [
      TarotSpreadPositionDefinition(
        id: threePastPositionId,
        displayName: threePastPositionName,
      ),
      TarotSpreadPositionDefinition(
        id: threePresentPositionId,
        displayName: threePresentPositionName,
      ),
      TarotSpreadPositionDefinition(
        id: threeFuturePositionId,
        displayName: threeFuturePositionName,
      ),
    ],
  );

  static const manualRecordingSpreads = [oneCard, threeCard];
}
