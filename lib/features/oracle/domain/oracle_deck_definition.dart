import 'oracle_card_definition.dart';

final class OracleDeckDefinition {
  factory OracleDeckDefinition({
    required String deckId,
    required String displayName,
    required String description,
    required int cardCount,
    required String coverAssetPath,
    required String cardBackAssetPath,
    required bool supportsReversal,
    required List<int> recommendedDrawCounts,
    required List<OracleCardDefinition> cards,
  }) {
    final normalizedDeckId = deckId.trim();
    final normalizedDisplayName = displayName.trim();
    final normalizedDescription = description.trim();
    final normalizedCoverAssetPath = coverAssetPath.trim();
    final normalizedCardBackAssetPath = cardBackAssetPath.trim();

    if (normalizedDeckId.isEmpty) {
      throw ArgumentError.value(deckId, 'deckId', 'must not be empty');
    }
    if (normalizedDisplayName.isEmpty) {
      throw ArgumentError.value(
        displayName,
        'displayName',
        'must not be empty',
      );
    }
    if (normalizedDescription.isEmpty) {
      throw ArgumentError.value(
        description,
        'description',
        'must not be empty',
      );
    }
    if (cardCount <= 0) {
      throw ArgumentError.value(cardCount, 'cardCount', 'must be positive');
    }
    if (cards.length != cardCount) {
      throw ArgumentError(
        'cardCount ($cardCount) must match cards.length (${cards.length})',
      );
    }
    if (normalizedCoverAssetPath.isEmpty) {
      throw ArgumentError.value(
        coverAssetPath,
        'coverAssetPath',
        'must not be empty',
      );
    }
    if (normalizedCardBackAssetPath.isEmpty) {
      throw ArgumentError.value(
        cardBackAssetPath,
        'cardBackAssetPath',
        'must not be empty',
      );
    }

    final cardIds = cards.map((card) => card.cardId).toSet();
    if (cardIds.length != cards.length) {
      throw ArgumentError('cards must have unique cardId values');
    }
    final sequences = cards.map((card) => card.sequence).toList()..sort();
    final expectedSequences = List.generate(cardCount, (index) => index + 1);
    for (var index = 0; index < cardCount; index++) {
      if (sequences[index] != expectedSequences[index]) {
        throw ArgumentError('card sequences must be continuous from 1');
      }
    }

    if (recommendedDrawCounts.isEmpty ||
        recommendedDrawCounts.any((count) => count <= 0 || count > cardCount) ||
        recommendedDrawCounts.toSet().length != recommendedDrawCounts.length) {
      throw ArgumentError(
        'recommendedDrawCounts must be unique positive values within cardCount',
      );
    }

    return OracleDeckDefinition._(
      deckId: normalizedDeckId,
      displayName: normalizedDisplayName,
      description: normalizedDescription,
      cardCount: cardCount,
      coverAssetPath: normalizedCoverAssetPath,
      cardBackAssetPath: normalizedCardBackAssetPath,
      supportsReversal: supportsReversal,
      recommendedDrawCounts: List.unmodifiable(recommendedDrawCounts),
      cards: List.unmodifiable(cards),
    );
  }

  const OracleDeckDefinition._({
    required this.deckId,
    required this.displayName,
    required this.description,
    required this.cardCount,
    required this.coverAssetPath,
    required this.cardBackAssetPath,
    required this.supportsReversal,
    required this.recommendedDrawCounts,
    required this.cards,
  });

  final String deckId;
  final String displayName;
  final String description;
  final int cardCount;
  final String coverAssetPath;
  final String cardBackAssetPath;
  final bool supportsReversal;
  final List<int> recommendedDrawCounts;
  final List<OracleCardDefinition> cards;

  bool get isAvailable =>
      cards.length == cardCount &&
      coverAssetPath.isNotEmpty &&
      cardBackAssetPath.isNotEmpty;

  OracleCardDefinition? cardById(String cardId) {
    final normalizedCardId = cardId.trim();
    for (final card in cards) {
      if (card.cardId == normalizedCardId) return card;
    }
    return null;
  }

  String? qualifiedCardId(String cardId) {
    final card = cardById(cardId);
    return card == null ? null : 'oracle.$deckId.${card.cardId}';
  }
}
