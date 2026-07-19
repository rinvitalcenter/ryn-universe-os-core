import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/oracle_deck_registry.dart';
import '../domain/oracle_card_definition.dart';
import '../domain/oracle_deck_definition.dart';
import '../domain/oracle_reading_result_snapshot.dart';
import '../domain/oracle_reading_session.dart';

final class OracleReadingController extends ChangeNotifier {
  OracleReadingController({OracleDeckDefinition? deck})
    : deck = deck ?? OracleDeckRegistry.horoscopeBelline {
    if (this.deck.deckId != OracleDeckRegistry.horoscopeBelline.deckId ||
        !this.deck.isAvailable ||
        this.deck.cardCount != 52 ||
        this.deck.supportsReversal ||
        !_sameDrawCounts(this.deck.recommendedDrawCounts, const [1, 3])) {
      throw ArgumentError(
        'Oracle v0.1 requires the approved Horoscope Belline deck.',
      );
    }
  }

  final OracleDeckDefinition deck;

  OracleReadingStage _stage = OracleReadingStage.setup;
  String _questionText = '';
  int _drawCount = 1;
  List<OracleCardDefinition> _shuffledCards = const [];
  final List<OracleCardDefinition> _selectedCards = [];
  List<OracleCardPlacement> _placements = const [];
  String _messageNote = '';
  String _smallAction = '';
  OracleReadingResultSnapshot? _latestResult;

  OracleReadingStage get stage => _stage;
  String get questionText => _questionText;
  int get drawCount => _drawCount;
  List<int> get supportedDrawCounts => const [1, 3];
  List<OracleCardDefinition> get shuffledCards =>
      List.unmodifiable(_shuffledCards);
  List<OracleCardDefinition> get selectedCards =>
      List.unmodifiable(_selectedCards);
  List<OracleCardPlacement> get placements => List.unmodifiable(_placements);
  String get messageNote => _messageNote;
  String get smallAction => _smallAction;
  OracleReadingResultSnapshot? get latestResult => _latestResult;
  bool get canConfirmSelection => _selectedCards.length == _drawCount;

  OracleReadingDraft get draft => OracleReadingDraft(
    questionText: _questionText,
    deckId: deck.deckId,
    drawCount: _drawCount,
    shuffledCards: _shuffledCards,
    placements: _placements,
    messageNote: _messageNote,
    smallAction: _smallAction,
    stage: _stage,
  );

  void start({required String questionText, required int drawCount}) {
    final normalizedQuestion = questionText.trim();
    if (normalizedQuestion.isEmpty) {
      throw ArgumentError.value(
        questionText,
        'questionText',
        'must not be empty',
      );
    }
    if (!supportedDrawCounts.contains(drawCount)) {
      throw ArgumentError.value(drawCount, 'drawCount', 'must be 1 or 3');
    }
    _questionText = normalizedQuestion;
    _drawCount = drawCount;
    _shuffledCards = const [];
    _selectedCards.clear();
    _placements = const [];
    _messageNote = '';
    _smallAction = '';
    _stage = OracleReadingStage.shuffle;
    notifyListeners();
  }

  void shuffle({Random? random}) {
    _requireStage(OracleReadingStage.shuffle);
    final cards = List<OracleCardDefinition>.of(deck.cards)
      ..shuffle(random ?? Random());
    _shuffledCards = List.unmodifiable(cards);
    _selectedCards.clear();
    _placements = const [];
    _stage = OracleReadingStage.draw;
    notifyListeners();
  }

  bool selectCard(String cardId) {
    if (_stage != OracleReadingStage.draw ||
        _selectedCards.length >= _drawCount ||
        _selectedCards.any((card) => card.cardId == cardId)) {
      return false;
    }
    final card = _shuffledCards.cast<OracleCardDefinition?>().firstWhere(
      (candidate) => candidate?.cardId == cardId,
      orElse: () => null,
    );
    if (card == null) return false;
    _selectedCards.add(card);
    notifyListeners();
    return true;
  }

  bool deselectCard(String cardId) {
    if (_stage != OracleReadingStage.draw) return false;
    final before = _selectedCards.length;
    _selectedCards.removeWhere((card) => card.cardId == cardId);
    if (_selectedCards.length == before) return false;
    notifyListeners();
    return true;
  }

  void confirmSelection() {
    _requireStage(OracleReadingStage.draw);
    if (!canConfirmSelection) {
      throw StateError('Select exactly $_drawCount cards before revealing.');
    }
    final roles = _drawCount == 1
        ? const [('message', '지금 나에게 온 메시지')]
        : const [('now', '지금'), ('notice', '알아차릴 것'), ('practice', '작은 실천')];
    _placements = List.unmodifiable([
      for (var index = 0; index < _selectedCards.length; index++)
        OracleCardPlacement(
          placementOrder: index + 1,
          positionId: roles[index].$1,
          positionName: roles[index].$2,
          qualifiedCardId: deck.qualifiedCardId(_selectedCards[index].cardId)!,
          cardId: _selectedCards[index].cardId,
          cardTitle: _selectedCards[index].title,
          originalTitle: _selectedCards[index].originalTitle,
          imageAssetPath: _selectedCards[index].imageAssetPath,
        ),
    ]);
    _stage = OracleReadingStage.result;
    notifyListeners();
  }

  void openInterpretation() {
    _requireStage(OracleReadingStage.result);
    _stage = OracleReadingStage.interpretation;
    notifyListeners();
  }

  void updateInterpretation({
    required String messageNote,
    required String smallAction,
  }) {
    if (_stage != OracleReadingStage.interpretation) {
      throw StateError('Interpretation is not open.');
    }
    _messageNote = messageNote;
    _smallAction = smallAction;
    notifyListeners();
  }

  OracleReadingResultSnapshot complete({DateTime? now}) {
    if (_stage != OracleReadingStage.interpretation) {
      throw StateError('Interpretation must be open before completion.');
    }
    final createdAt = now ?? DateTime.now();
    final snapshot = OracleReadingResultSnapshot.validated(
      readingInstanceId:
          'oracle-${createdAt.microsecondsSinceEpoch}-${_placements.first.cardId}',
      questionText: _questionText,
      deckId: deck.deckId,
      deckName: deck.displayName,
      drawCount: _drawCount,
      createdAt: createdAt,
      placements: _placements,
      messageNote: _messageNote,
      smallAction: _smallAction,
      status: OracleReadingStatus.completed,
    );
    _latestResult = snapshot;
    _stage = OracleReadingStage.completed;
    notifyListeners();
    return snapshot;
  }

  void startNewReading() {
    _questionText = '';
    _drawCount = 1;
    _shuffledCards = const [];
    _selectedCards.clear();
    _placements = const [];
    _messageNote = '';
    _smallAction = '';
    _stage = OracleReadingStage.setup;
    notifyListeners();
  }

  bool resumeLatest() {
    final result = _latestResult;
    if (result == null) return false;
    _questionText = result.questionText;
    _drawCount = result.drawCount;
    _placements = result.placements;
    _messageNote = result.messageNote;
    _smallAction = result.smallAction;
    _selectedCards.clear();
    _shuffledCards = const [];
    _stage = OracleReadingStage.completed;
    notifyListeners();
    return true;
  }

  bool reopenLatestInterpretation() {
    if (!resumeLatest()) return false;
    _stage = OracleReadingStage.interpretation;
    notifyListeners();
    return true;
  }

  void _requireStage(OracleReadingStage expected) {
    if (_stage != expected) {
      throw StateError('Expected $expected but was $_stage.');
    }
  }

  static bool _sameDrawCounts(List<int> actual, List<int> expected) {
    if (actual.length != expected.length) return false;
    for (var index = 0; index < actual.length; index++) {
      if (actual[index] != expected[index]) return false;
    }
    return true;
  }
}
