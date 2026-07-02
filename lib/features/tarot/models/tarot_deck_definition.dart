import 'tarot_card_definition.dart';

class TarotDeckDefinition {
  const TarotDeckDefinition({
    required this.deckId,
    required this.displayName,
    this.shortName,
    this.prefix,
    this.family,
    this.cards = const [],
    this.representativeAssetPath,
    this.coverAssetPath,
    this.cardBackAssetPath,
    this.availabilityStatus = 'placeholder_only',
    this.notes,
  });

  final String deckId;
  final String displayName;
  final String? shortName;
  final String? prefix;
  final String? family;
  final List<TarotCardDefinition> cards;
  final String? representativeAssetPath;
  final String? coverAssetPath;
  final String? cardBackAssetPath;
  final String availabilityStatus;
  final String? notes;

  String get id => deckId;
  String get label => shortName ?? displayName;
  int get cardCount => cards.length;
  bool get assetBacked => cards.isNotEmpty;
}
