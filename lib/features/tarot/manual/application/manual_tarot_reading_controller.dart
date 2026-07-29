import 'package:flutter/foundation.dart';

import '../../../people/domain/person_core_models.dart';
import '../../data/tarot_deck_registry.dart';
import '../../data/tarot_spread_registry.dart';
import '../../models/tarot_card_definition.dart';
import '../../models/tarot_deck_definition.dart';
import '../../models/tarot_interpretation_session_draft.dart';
import '../../models/tarot_reading_result_snapshot.dart';

enum ManualTarotSaveStatus { idle, validating, saving, saved, failed }

final class ManualTarotInterpretationFields {
  const ManualTarotInterpretationFields({
    this.wholeImageObservation = '',
    this.flowInterpretation = '',
    this.coreMessage = '',
    this.smallAction = '',
  });

  final String wholeImageObservation;
  final String flowInterpretation;
  final String coreMessage;
  final String smallAction;

  ManualTarotInterpretationFields copyWith({
    String? wholeImageObservation,
    String? flowInterpretation,
    String? coreMessage,
    String? smallAction,
  }) => ManualTarotInterpretationFields(
    wholeImageObservation: wholeImageObservation ?? this.wholeImageObservation,
    flowInterpretation: flowInterpretation ?? this.flowInterpretation,
    coreMessage: coreMessage ?? this.coreMessage,
    smallAction: smallAction ?? this.smallAction,
  );
}

final class ManualTarotCardEntry {
  const ManualTarotCardEntry({
    required this.position,
    this.card,
    this.orientation = TarotCardOrientation.upright,
  });

  final TarotSpreadPositionDefinition position;
  final TarotCardDefinition? card;
  final TarotCardOrientation orientation;

  ManualTarotCardEntry copyWith({
    TarotCardDefinition? card,
    TarotCardOrientation? orientation,
  }) => ManualTarotCardEntry(
    position: position,
    card: card ?? this.card,
    orientation: orientation ?? this.orientation,
  );
}

final class ManualTarotReadingFormState {
  const ManualTarotReadingFormState({
    required this.selectedPerson,
    required this.selectedPersonAvailable,
    required this.question,
    required this.readingAt,
    required this.readingTimezoneOffsetMinutes,
    required this.deck,
    required this.spread,
    required this.entries,
    required this.interpretation,
    required this.saveStatus,
    required this.fieldErrors,
    required this.formError,
    required this.isDirty,
  });

  final Person? selectedPerson;
  final bool selectedPersonAvailable;
  final String question;
  final DateTime readingAt;
  final int readingTimezoneOffsetMinutes;
  final TarotDeckDefinition deck;
  final TarotSpreadDefinition spread;
  final List<ManualTarotCardEntry> entries;
  final ManualTarotInterpretationFields interpretation;
  final ManualTarotSaveStatus saveStatus;
  final Map<String, String> fieldErrors;
  final String? formError;
  final bool isDirty;
}

final class ManualTarotReadingSaveRequest {
  const ManualTarotReadingSaveRequest({
    required this.snapshot,
    required this.personId,
    required this.readingTimezoneOffsetMinutes,
    required this.interpretation,
  });

  final TarotReadingResultSnapshot snapshot;
  final String personId;
  final int readingTimezoneOffsetMinutes;
  final TarotInterpretationSessionDraft? interpretation;
}

typedef ManualTarotSaveCommand =
    Future<bool> Function(ManualTarotReadingSaveRequest request);
typedef ManualTarotClock = DateTime Function();
typedef ManualTarotReadingIdFactory = String Function();

final class ManualTarotReadingController extends ChangeNotifier {
  ManualTarotReadingController({
    required this.saveCommand,
    ManualTarotClock? clock,
    ManualTarotReadingIdFactory? readingIdFactory,
    String? initialPersonId,
    List<TarotDeckDefinition>? decks,
    List<TarotSpreadDefinition>? spreads,
  }) : _clock = clock ?? DateTime.now,
       _readingIdFactory =
           readingIdFactory ??
           (() => 'manual-${DateTime.now().toUtc().microsecondsSinceEpoch}'),
       _initialPersonId = initialPersonId?.trim(),
       availableDecks = List.unmodifiable(
         (decks ?? TarotDeckRegistry.decks).where(_isAvailableDeck),
       ),
       availableSpreads = List.unmodifiable(
         spreads ?? TarotSpreadRegistry.manualRecordingSpreads,
       ) {
    if (availableDecks.isEmpty) {
      throw StateError('Manual Tarot requires one complete asset-backed deck.');
    }
    if (availableSpreads.isEmpty) {
      throw StateError('Manual Tarot requires one canonical spread.');
    }
    _readingAt = _clock();
    _readingTimezoneOffsetMinutes = _readingAt.timeZoneOffset.inMinutes;
    _deck = availableDecks.first;
    _spread = availableSpreads.firstWhere(
      (item) => item.id == TarotSpreadRegistry.threeCard.id,
      orElse: () => availableSpreads.first,
    );
    _entries = _entriesFor(_spread);
  }

  final ManualTarotSaveCommand saveCommand;
  final ManualTarotClock _clock;
  final ManualTarotReadingIdFactory _readingIdFactory;
  final String? _initialPersonId;
  final List<TarotDeckDefinition> availableDecks;
  final List<TarotSpreadDefinition> availableSpreads;

  List<Person> _availablePeople = const [];
  Person? _selectedPerson;
  bool _selectedPersonAvailable = false;
  String _question = '';
  late DateTime _readingAt;
  late int _readingTimezoneOffsetMinutes;
  late TarotDeckDefinition _deck;
  late TarotSpreadDefinition _spread;
  late List<ManualTarotCardEntry> _entries;
  ManualTarotInterpretationFields _interpretation =
      const ManualTarotInterpretationFields();
  ManualTarotSaveStatus _saveStatus = ManualTarotSaveStatus.idle;
  Map<String, String> _fieldErrors = const {};
  String? _formError;
  bool _isDirty = false;
  String? _readingInstanceId;
  Future<String?>? _activeSave;

  List<Person> get availablePeople => List.unmodifiable(_availablePeople);
  String get normalizedQuestion => _question.trim();
  int get completedPositionCount =>
      _entries.where((entry) => entry.card != null).length;

  ManualTarotReadingFormState get state => ManualTarotReadingFormState(
    selectedPerson: _selectedPerson,
    selectedPersonAvailable: _selectedPersonAvailable,
    question: _question,
    readingAt: _readingAt,
    readingTimezoneOffsetMinutes: _readingTimezoneOffsetMinutes,
    deck: _deck,
    spread: _spread,
    entries: List.unmodifiable(_entries),
    interpretation: _interpretation,
    saveStatus: _saveStatus,
    fieldErrors: Map.unmodifiable(_fieldErrors),
    formError: _formError,
    isDirty: _isDirty,
  );

  void setPeople(Iterable<Person> people) {
    _availablePeople =
        people
            .where(
              (person) =>
                  person.status == PersonStatuses.active &&
                  person.archivedAt == null,
            )
            .toList(growable: false)
          ..sort(
            (left, right) => left.displayName.compareTo(right.displayName),
          );
    final selectedId = _selectedPerson?.id ?? _initialPersonId;
    final match = selectedId == null
        ? null
        : _firstWhereOrNull(
            _availablePeople,
            (person) => person.id == selectedId,
          );
    if (_selectedPerson == null && match != null) _selectedPerson = match;
    _selectedPersonAvailable = match != null;
    _clearTransientError();
    notifyListeners();
  }

  void selectPerson(Person person) {
    final match = _firstWhereOrNull(
      _availablePeople,
      (candidate) => candidate.id == person.id,
    );
    if (match == null) return;
    _selectedPerson = match;
    _selectedPersonAvailable = true;
    _markDirty();
  }

  void setQuestion(String value) {
    _question = value;
    _markDirty();
  }

  void setReadingAt(DateTime value, {int? timezoneOffsetMinutes}) {
    _readingAt = value;
    _readingTimezoneOffsetMinutes =
        timezoneOffsetMinutes ?? value.timeZoneOffset.inMinutes;
    _markDirty();
  }

  bool selectDeck(TarotDeckDefinition deck, {bool discardExisting = false}) {
    if (!availableDecks.any((item) => item.id == deck.id)) return false;
    if (_entries.any((entry) => entry.card != null) && !discardExisting) {
      return false;
    }
    _deck = deck;
    _entries = _entriesFor(_spread);
    _markDirty();
    return true;
  }

  bool selectSpread(
    TarotSpreadDefinition spread, {
    bool discardExisting = false,
  }) {
    if (!availableSpreads.any((item) => item.id == spread.id)) return false;
    if (_entries.any((entry) => entry.card != null) && !discardExisting) {
      return false;
    }
    _spread = spread;
    _entries = _entriesFor(spread);
    _markDirty();
    return true;
  }

  void selectCard(String positionId, TarotCardDefinition card) {
    if (!_deck.cards.any((item) => item.id == card.id)) return;
    final index = _entries.indexWhere(
      (entry) => entry.position.id == positionId,
    );
    if (index < 0) return;
    _entries = List.of(_entries)
      ..[index] = _entries[index].copyWith(card: card);
    _markDirty();
  }

  void setOrientation(String positionId, TarotCardOrientation orientation) {
    if (orientation == TarotCardOrientation.notUsed) return;
    final index = _entries.indexWhere(
      (entry) => entry.position.id == positionId,
    );
    if (index < 0) return;
    _entries = List.of(_entries)
      ..[index] = _entries[index].copyWith(orientation: orientation);
    _markDirty();
  }

  void updateInterpretation({
    String? wholeImageObservation,
    String? flowInterpretation,
    String? coreMessage,
    String? smallAction,
  }) {
    _interpretation = _interpretation.copyWith(
      wholeImageObservation: wholeImageObservation,
      flowInterpretation: flowInterpretation,
      coreMessage: coreMessage,
      smallAction: smallAction,
    );
    _markDirty();
  }

  Future<String?> save() {
    final active = _activeSave;
    if (active != null) return active;
    final future = _runSave();
    _activeSave = future;
    future.whenComplete(() {
      if (identical(_activeSave, future)) _activeSave = null;
    });
    return future;
  }

  Future<String?> _runSave() async {
    _saveStatus = ManualTarotSaveStatus.validating;
    _fieldErrors = const {};
    _formError = null;
    notifyListeners();
    final errors = _validate();
    if (errors.isNotEmpty) {
      _fieldErrors = errors;
      _formError = errors['person'];
      _saveStatus = ManualTarotSaveStatus.failed;
      notifyListeners();
      return null;
    }

    final id = _readingInstanceId ??= _readingIdFactory();
    final placements = <TarotCardPlacementSnapshot>[
      for (var index = 0; index < _entries.length; index++)
        TarotCardPlacementSnapshot(
          placementOrder: index + 1,
          cardId: _entries[index].card!.id,
          cardNameSnapshot: _entries[index].card!.label,
          positionId: _entries[index].position.id,
          positionNameSnapshot: _entries[index].position.displayName,
          orientation: _entries[index].orientation,
        ),
    ];
    final snapshot = TarotReadingResultSnapshot.validated(
      readingInstanceId: id,
      readingQuestionText: normalizedQuestion,
      deckId: _deck.id,
      deckNameSnapshot: _deck.label,
      spreadId: _spread.id,
      spreadNameSnapshot: _spread.displayName,
      readingAt: _readingAt,
      placements: placements,
      expectedPlacementCount: _spread.positions.length,
      selectedDeckCardIds: _deck.cards.map((card) => card.id).toSet(),
    );
    final interpretation = TarotInterpretationSessionDraft(
      readingInstanceId: id,
      wholeImageObservation: _interpretation.wholeImageObservation,
      flowInterpretation: _interpretation.flowInterpretation,
      coreMessage: _interpretation.coreMessage,
      smallAction: _interpretation.smallAction,
    );

    _saveStatus = ManualTarotSaveStatus.saving;
    notifyListeners();
    final success = await saveCommand(
      ManualTarotReadingSaveRequest(
        snapshot: snapshot,
        personId: _selectedPerson!.id,
        readingTimezoneOffsetMinutes: _readingTimezoneOffsetMinutes,
        interpretation: interpretation.hasMeaningfulText
            ? interpretation
            : null,
      ),
    );
    if (!success) {
      _saveStatus = ManualTarotSaveStatus.failed;
      _formError = '저장하지 못했어요. 작성한 내용은 화면에 그대로 남아 있어요.';
      notifyListeners();
      return null;
    }
    _saveStatus = ManualTarotSaveStatus.saved;
    _isDirty = false;
    _formError = null;
    notifyListeners();
    return id;
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (_selectedPerson == null || !_selectedPersonAvailable) {
      errors['person'] = '선택한 사람 기록을 연결할 수 없습니다. 사람 상태를 확인한 뒤 다시 시도해 주세요.';
    }
    if (normalizedQuestion.isEmpty) {
      errors['question'] = '질문을 입력해 주세요.';
    }
    if (_readingTimezoneOffsetMinutes < -840 ||
        _readingTimezoneOffsetMinutes > 840) {
      errors['readingAt'] = '읽은 날짜와 시간을 다시 확인해 주세요.';
    }
    final selectedCards = _entries
        .map((entry) => entry.card?.id)
        .whereType<String>()
        .toList(growable: false);
    if (selectedCards.length != _spread.positions.length) {
      errors['placements'] = '모든 위치에 카드를 입력해 주세요.';
    } else if (selectedCards.toSet().length != selectedCards.length) {
      errors['placements'] = '같은 카드는 한 번만 입력할 수 있어요.';
    }
    return errors;
  }

  void _markDirty() {
    _isDirty = true;
    _saveStatus = ManualTarotSaveStatus.idle;
    _clearTransientError();
    notifyListeners();
  }

  void _clearTransientError() {
    _fieldErrors = const {};
    _formError = null;
    if (_saveStatus == ManualTarotSaveStatus.failed) {
      _saveStatus = ManualTarotSaveStatus.idle;
    }
  }

  static List<ManualTarotCardEntry> _entriesFor(TarotSpreadDefinition spread) =>
      [
        for (final position in spread.positions)
          ManualTarotCardEntry(position: position),
      ];

  static bool _isAvailableDeck(TarotDeckDefinition deck) =>
      deck.assetBacked &&
      deck.cardCount == 78 &&
      deck.coverAssetPath != null &&
      deck.cardBackAssetPath != null &&
      deck.availabilityStatus == 'front_cards_ready';

  static T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }
}
