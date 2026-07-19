import 'oracle_card_definition.dart';

/// Oracle v0.1 has no upright or reversed state.
enum OracleCardOrientation { notUsed }

enum OracleReadingStage {
  setup,
  shuffle,
  draw,
  result,
  interpretation,
  completed,
}

enum OracleReadingStatus { draft, completed }

final class OracleCardPlacement {
  const OracleCardPlacement({
    required this.placementOrder,
    required this.positionId,
    required this.positionName,
    required this.qualifiedCardId,
    required this.cardId,
    required this.cardTitle,
    required this.originalTitle,
    required this.imageAssetPath,
    this.orientation = OracleCardOrientation.notUsed,
  });

  final int placementOrder;
  final String positionId;
  final String positionName;
  final String qualifiedCardId;
  final String cardId;
  final String cardTitle;
  final String? originalTitle;
  final String imageAssetPath;
  final OracleCardOrientation orientation;
}

final class OracleReadingDraft {
  OracleReadingDraft({
    required this.questionText,
    required this.deckId,
    required this.drawCount,
    required List<OracleCardDefinition> shuffledCards,
    required List<OracleCardPlacement> placements,
    required this.messageNote,
    required this.smallAction,
    required this.stage,
  }) : shuffledCards = List.unmodifiable(shuffledCards),
       placements = List.unmodifiable(placements);

  final String questionText;
  final String deckId;
  final int drawCount;
  final List<OracleCardDefinition> shuffledCards;
  final List<OracleCardPlacement> placements;
  final String messageNote;
  final String smallAction;
  final OracleReadingStage stage;

  OracleReadingStatus get status => OracleReadingStatus.draft;
}
