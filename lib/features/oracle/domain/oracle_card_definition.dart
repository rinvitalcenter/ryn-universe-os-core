final class OracleCardDefinition {
  factory OracleCardDefinition({
    required String cardId,
    required int sequence,
    required String title,
    String? originalTitle,
    required String imageAssetPath,
    List<String> keywords = const [],
    String? category,
    String? shortMessage,
  }) {
    final normalizedCardId = cardId.trim();
    final normalizedImageAssetPath = imageAssetPath.trim();
    if (normalizedCardId.isEmpty) {
      throw ArgumentError.value(cardId, 'cardId', 'must not be empty');
    }
    if (sequence <= 0) {
      throw ArgumentError.value(sequence, 'sequence', 'must be positive');
    }
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'must not be empty');
    }
    if (originalTitle != null && originalTitle.trim().isEmpty) {
      throw ArgumentError.value(
        originalTitle,
        'originalTitle',
        'must be null or non-empty',
      );
    }
    if (normalizedImageAssetPath.isEmpty) {
      throw ArgumentError.value(
        imageAssetPath,
        'imageAssetPath',
        'must not be empty',
      );
    }
    return OracleCardDefinition._(
      cardId: normalizedCardId,
      sequence: sequence,
      title: title,
      originalTitle: originalTitle,
      imageAssetPath: normalizedImageAssetPath,
      keywords: List.unmodifiable(keywords),
      category: category,
      shortMessage: shortMessage,
    );
  }

  const OracleCardDefinition._({
    required this.cardId,
    required this.sequence,
    required this.title,
    required this.originalTitle,
    required this.imageAssetPath,
    required this.keywords,
    required this.category,
    required this.shortMessage,
  });

  final String cardId;
  final int sequence;
  final String title;
  final String? originalTitle;
  final String imageAssetPath;
  final List<String> keywords;
  final String? category;
  final String? shortMessage;
}
