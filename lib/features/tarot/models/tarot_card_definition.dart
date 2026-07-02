class TarotCardDefinition {
  const TarotCardDefinition(
    this.semanticId,
    this.displayName,
    this.assetPath, {
    this.displayNameKo,
    this.arcana,
    this.suit,
    this.number,
    this.keywordsPreview = const [],
    this.availabilityStatus = 'front_cards_ready',
  });

  final String semanticId;
  final String displayName;
  final String assetPath;
  final String? displayNameKo;
  final String? arcana;
  final String? suit;
  final int? number;
  final List<String> keywordsPreview;
  final String availabilityStatus;

  String get id => semanticId;
  String get label => displayName;
  String get imagePath => assetPath;
}
