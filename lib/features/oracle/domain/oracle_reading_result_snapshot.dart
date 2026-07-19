import 'oracle_reading_session.dart';

final class OracleReadingResultSnapshot {
  factory OracleReadingResultSnapshot.validated({
    required String readingInstanceId,
    required String questionText,
    required String deckId,
    required String deckName,
    required int drawCount,
    required DateTime createdAt,
    required List<OracleCardPlacement> placements,
    required String messageNote,
    required String smallAction,
    required OracleReadingStatus status,
  }) {
    final normalizedId = readingInstanceId.trim();
    final normalizedQuestion = questionText.trim();
    final normalizedDeckId = deckId.trim();
    final normalizedDeckName = deckName.trim();
    if (normalizedId.isEmpty ||
        normalizedQuestion.isEmpty ||
        normalizedDeckId.isEmpty ||
        normalizedDeckName.isEmpty) {
      throw ArgumentError('Oracle result identity fields must not be empty.');
    }
    if (drawCount != 1 && drawCount != 3) {
      throw ArgumentError.value(drawCount, 'drawCount', 'must be 1 or 3');
    }
    if (placements.length != drawCount) {
      throw ArgumentError('placements must match drawCount');
    }
    final orders = placements.map((item) => item.placementOrder).toList();
    final expectedOrders = List.generate(drawCount, (index) => index + 1);
    if (!_sameValues(orders, expectedOrders) ||
        placements.map((item) => item.positionId).toSet().length != drawCount ||
        placements.map((item) => item.cardId).toSet().length != drawCount ||
        placements.any(
          (item) => item.orientation != OracleCardOrientation.notUsed,
        )) {
      throw ArgumentError('Oracle placements violate the fixed v0.1 contract.');
    }
    return OracleReadingResultSnapshot._(
      readingInstanceId: normalizedId,
      questionText: normalizedQuestion,
      deckId: normalizedDeckId,
      deckName: normalizedDeckName,
      drawCount: drawCount,
      createdAt: createdAt,
      placements: List.unmodifiable(placements),
      messageNote: messageNote.trim(),
      smallAction: smallAction.trim(),
      status: status,
    );
  }

  const OracleReadingResultSnapshot._({
    required this.readingInstanceId,
    required this.questionText,
    required this.deckId,
    required this.deckName,
    required this.drawCount,
    required this.createdAt,
    required this.placements,
    required this.messageNote,
    required this.smallAction,
    required this.status,
  });

  final String readingInstanceId;
  final String questionText;
  final String deckId;
  final String deckName;
  final int drawCount;
  final DateTime createdAt;
  final List<OracleCardPlacement> placements;
  final String messageNote;
  final String smallAction;
  final OracleReadingStatus status;

  static bool _sameValues(List<int> actual, List<int> expected) {
    if (actual.length != expected.length) return false;
    for (var index = 0; index < actual.length; index++) {
      if (actual[index] != expected[index]) return false;
    }
    return true;
  }
}
