import '../domain/oracle_card_definition.dart';
import '../domain/oracle_deck_definition.dart';
import 'horoscope_belline_oracle_cards.dart';

final class OracleDeckRegistry {
  const OracleDeckRegistry._();

  static final OracleDeckDefinition horoscopeBelline = OracleDeckDefinition(
    deckId: 'horoscope_belline',
    displayName: '호로스코프 벨린 오라클',
    description: '52장의 상징으로 지금 필요한 메시지를 살펴보는 오라클 덱입니다.',
    cardCount: 52,
    coverAssetPath:
        'assets/oracle/decks/horoscope_belline/cover/horoscope_belline_cover.jpg',
    cardBackAssetPath:
        'assets/oracle/decks/horoscope_belline/back/horoscope_belline_back.jpg',
    supportsReversal: false,
    recommendedDrawCounts: const [1, 3],
    cards: horoscopeBellineOracleCards,
  );

  static final List<OracleDeckDefinition> decks = List.unmodifiable([
    horoscopeBelline,
  ]);

  static List<OracleDeckDefinition> get availableDecks =>
      List.unmodifiable(decks.where((deck) => deck.isAvailable));

  static OracleDeckDefinition? get firstAvailable =>
      availableDecks.isEmpty ? null : availableDecks.first;

  static OracleDeckDefinition? deckById(String deckId) {
    final normalizedDeckId = deckId.trim();
    for (final deck in decks) {
      if (deck.deckId == normalizedDeckId) return deck;
    }
    return null;
  }

  static OracleCardDefinition? cardById(String deckId, String cardId) =>
      deckById(deckId)?.cardById(cardId);

  static String? qualifiedCardId(String deckId, String cardId) =>
      deckById(deckId)?.qualifiedCardId(cardId);
}
