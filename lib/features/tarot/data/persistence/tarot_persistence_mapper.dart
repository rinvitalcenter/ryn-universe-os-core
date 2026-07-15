import 'package:drift/drift.dart';

import '../../../../core/persistence/app_database.dart';
import '../../../../core/repositories/repository_result.dart';
import '../../domain/tarot_persistence_models.dart';
import '../../models/tarot_interpretation_session_draft.dart';
import '../../models/tarot_reading_result_snapshot.dart';

const int _maxSupportedUtcMicroseconds = 8640000000000000;

final class TarotPersistenceWriteSet {
  const TarotPersistenceWriteSet({
    required this.reading,
    required this.placements,
    required this.interpretation,
  });

  final TarotReadingsCompanion reading;
  final List<TarotCardPlacementsCompanion> placements;
  final TarotInterpretationsCompanion? interpretation;
}

final class TarotPersistenceMapper {
  const TarotPersistenceMapper();

  RepositoryResult<TarotPersistenceWriteSet> toWriteSet(
    CompletedTarotReadingPersistenceInput input, {
    required int nowUtcUs,
  }) {
    final snapshot = input.snapshot;
    final validation = _validateSnapshot(snapshot);
    if (validation != null) return RepositoryResult.failure(validation);
    if (!_isSupportedTimestamp(nowUtcUs) ||
        !_isSupportedTimestamp(snapshot.readingAt.microsecondsSinceEpoch)) {
      return RepositoryResult.failure(
        _validationFailure('Timestamp is outside the supported range.'),
      );
    }
    final interpretation = input.interpretation;
    if (interpretation != null &&
        interpretation.readingInstanceId.trim() != snapshot.readingInstanceId) {
      return RepositoryResult.failure(
        _validationFailure('Interpretation reading ID does not match.'),
      );
    }

    final reading = TarotReadingsCompanion.insert(
      readingInstanceId: snapshot.readingInstanceId,
      sourceType: _originToStorage(input.sourceType),
      questionOriginalSnapshot: snapshot.readingQuestionText,
      questionDisplayText: snapshot.readingQuestionText,
      deckId: snapshot.deckId,
      deckNameSnapshot: snapshot.deckNameSnapshot,
      spreadId: snapshot.spreadId,
      spreadNameSnapshot: snapshot.spreadNameSnapshot,
      expectedPlacementCount: snapshot.placements.length,
      readingAtUtcUs: snapshot.readingAt.microsecondsSinceEpoch,
      readingTimezoneOffsetMin: input.readingTimezoneOffsetMinutes,
      createdAtUtcUs: nowUtcUs,
      updatedAtUtcUs: nowUtcUs,
      lifecycleStatus: _lifecycleToStorage(TarotReadingLifecycle.continuing),
      finishedAtUtcUs: const Value<int?>.absent(),
    );
    final placements = <TarotCardPlacementsCompanion>[
      for (final placement in snapshot.placements)
        TarotCardPlacementsCompanion.insert(
          readingInstanceId: snapshot.readingInstanceId,
          placementOrder: placement.placementOrder,
          positionId: placement.positionId,
          positionNameSnapshot: placement.positionNameSnapshot,
          cardId: placement.cardId,
          cardNameSnapshot: placement.cardNameSnapshot,
          orientation: _orientationToStorage(placement.orientation),
        ),
    ];
    final interpretationRow = interpretation == null
        ? null
        : TarotInterpretationsCompanion.insert(
            readingInstanceId: snapshot.readingInstanceId,
            wholeImageObservation: Value(interpretation.wholeImageObservation),
            flowInterpretation: Value(interpretation.flowInterpretation),
            coreMessage: Value(interpretation.coreMessage),
            smallAction: Value(interpretation.smallAction),
            createdAtUtcUs: nowUtcUs,
            updatedAtUtcUs: nowUtcUs,
          );

    return RepositoryResult.success(
      TarotPersistenceWriteSet(
        reading: reading,
        placements: List.unmodifiable(placements),
        interpretation: interpretationRow,
      ),
    );
  }

  RepositoryResult<PersistedTarotReadingRecord> hydrate({
    required TarotReading reading,
    required List<TarotCardPlacement> placements,
    required TarotInterpretation? interpretation,
  }) {
    final origin = _originFromStorage(reading.sourceType);
    final lifecycle = _lifecycleFromStorage(reading.lifecycleStatus);
    if (origin == null || lifecycle == null) {
      return RepositoryResult.failure(
        _validationFailure('Persisted Tarot enum value is unsupported.'),
      );
    }
    if (!_required(reading.readingInstanceId) ||
        !_required(reading.questionOriginalSnapshot) ||
        !_required(reading.questionDisplayText) ||
        !_required(reading.deckId) ||
        !_required(reading.deckNameSnapshot) ||
        !_required(reading.spreadId) ||
        !_required(reading.spreadNameSnapshot) ||
        reading.expectedPlacementCount <= 0 ||
        reading.readingTimezoneOffsetMin < -840 ||
        reading.readingTimezoneOffsetMin > 840 ||
        !_isSupportedTimestamp(reading.readingAtUtcUs) ||
        !_isSupportedTimestamp(reading.createdAtUtcUs) ||
        !_isSupportedTimestamp(reading.updatedAtUtcUs) ||
        (reading.finishedAtUtcUs != null &&
            !_isSupportedTimestamp(reading.finishedAtUtcUs!))) {
      return RepositoryResult.failure(
        _validationFailure('Persisted Tarot reading is invalid.'),
      );
    }
    if ((lifecycle == TarotReadingLifecycle.continuing &&
            reading.finishedAtUtcUs != null) ||
        (lifecycle == TarotReadingLifecycle.finished &&
            reading.finishedAtUtcUs == null)) {
      return RepositoryResult.failure(
        _validationFailure('Persisted lifecycle timestamps are inconsistent.'),
      );
    }
    if (placements.length != reading.expectedPlacementCount) {
      return RepositoryResult.failure(
        _validationFailure('Placement count does not match expected count.'),
      );
    }

    final ordered = [...placements]
      ..sort(
        (left, right) => left.placementOrder.compareTo(right.placementOrder),
      );
    final positionIds = <String>{};
    final snapshots = <TarotCardPlacementSnapshot>[];
    for (var index = 0; index < ordered.length; index++) {
      final row = ordered[index];
      final orientation = _orientationFromStorage(row.orientation);
      if (row.readingInstanceId != reading.readingInstanceId ||
          row.placementOrder != index + 1 ||
          !_required(row.positionId) ||
          !_required(row.positionNameSnapshot) ||
          !_required(row.cardId) ||
          !_required(row.cardNameSnapshot) ||
          !positionIds.add(row.positionId) ||
          orientation == null) {
        return RepositoryResult.failure(
          _validationFailure('Persisted Tarot placement is invalid.'),
        );
      }
      snapshots.add(
        TarotCardPlacementSnapshot(
          placementOrder: row.placementOrder,
          cardId: row.cardId,
          cardNameSnapshot: row.cardNameSnapshot,
          positionId: row.positionId,
          positionNameSnapshot: row.positionNameSnapshot,
          orientation: orientation,
        ),
      );
    }

    if (interpretation != null &&
        interpretation.readingInstanceId != reading.readingInstanceId) {
      return RepositoryResult.failure(
        _validationFailure(
          'Persisted interpretation reading ID does not match.',
        ),
      );
    }

    try {
      final snapshot = TarotReadingResultSnapshot.validated(
        readingInstanceId: reading.readingInstanceId,
        readingQuestionText: reading.questionOriginalSnapshot,
        deckId: reading.deckId,
        deckNameSnapshot: reading.deckNameSnapshot,
        spreadId: reading.spreadId,
        spreadNameSnapshot: reading.spreadNameSnapshot,
        readingAt: DateTime.fromMicrosecondsSinceEpoch(
          reading.readingAtUtcUs,
          isUtc: true,
        ),
        placements: snapshots,
        expectedPlacementCount: reading.expectedPlacementCount,
        selectedDeckCardIds: snapshots.map((item) => item.cardId).toSet(),
      );
      return RepositoryResult.success(
        PersistedTarotReadingRecord(
          snapshot: snapshot,
          questionDisplayText: reading.questionDisplayText,
          sourceType: origin,
          lifecycle: lifecycle,
          interpretation: interpretation == null
              ? null
              : TarotInterpretationSessionDraft(
                  readingInstanceId: interpretation.readingInstanceId,
                  wholeImageObservation: interpretation.wholeImageObservation,
                  flowInterpretation: interpretation.flowInterpretation,
                  coreMessage: interpretation.coreMessage,
                  smallAction: interpretation.smallAction,
                ),
          readingTimezoneOffsetMinutes: reading.readingTimezoneOffsetMin,
          createdAt: DateTime.fromMicrosecondsSinceEpoch(
            reading.createdAtUtcUs,
            isUtc: true,
          ),
          updatedAt: DateTime.fromMicrosecondsSinceEpoch(
            reading.updatedAtUtcUs,
            isUtc: true,
          ),
          finishedAt: reading.finishedAtUtcUs == null
              ? null
              : DateTime.fromMicrosecondsSinceEpoch(
                  reading.finishedAtUtcUs!,
                  isUtc: true,
                ),
        ),
      );
    } on ArgumentError {
      return RepositoryResult.failure(
        _validationFailure('Persisted Tarot aggregate failed validation.'),
      );
    }
  }

  RepositoryError? _validateSnapshot(TarotReadingResultSnapshot snapshot) {
    if (!_required(snapshot.readingInstanceId) ||
        !_required(snapshot.readingQuestionText) ||
        !_required(snapshot.deckId) ||
        !_required(snapshot.deckNameSnapshot) ||
        !_required(snapshot.spreadId) ||
        !_required(snapshot.spreadNameSnapshot) ||
        snapshot.placements.isEmpty) {
      return _validationFailure('Completed Tarot snapshot is invalid.');
    }
    final positions = <String>{};
    for (var index = 0; index < snapshot.placements.length; index++) {
      final placement = snapshot.placements[index];
      if (placement.placementOrder != index + 1 ||
          !_required(placement.positionId) ||
          !_required(placement.positionNameSnapshot) ||
          !_required(placement.cardId) ||
          !_required(placement.cardNameSnapshot) ||
          !positions.add(placement.positionId)) {
        return _validationFailure('Completed Tarot placement is invalid.');
      }
    }
    return null;
  }
}

String _originToStorage(TarotReadingOrigin value) => switch (value) {
  TarotReadingOrigin.selfDrawn => 'self_drawn',
  TarotReadingOrigin.manuallyRecorded => 'manually_recorded',
};

TarotReadingOrigin? _originFromStorage(String value) => switch (value) {
  'self_drawn' => TarotReadingOrigin.selfDrawn,
  'manually_recorded' => TarotReadingOrigin.manuallyRecorded,
  _ => null,
};

String _lifecycleToStorage(TarotReadingLifecycle value) => switch (value) {
  TarotReadingLifecycle.continuing => 'continuing',
  TarotReadingLifecycle.finished => 'finished',
};

TarotReadingLifecycle? _lifecycleFromStorage(String value) => switch (value) {
  'continuing' => TarotReadingLifecycle.continuing,
  'finished' => TarotReadingLifecycle.finished,
  _ => null,
};

String _orientationToStorage(TarotCardOrientation value) => switch (value) {
  TarotCardOrientation.notUsed => 'not_used',
  TarotCardOrientation.upright => 'upright',
  TarotCardOrientation.reversed => 'reversed',
};

TarotCardOrientation? _orientationFromStorage(String value) => switch (value) {
  'not_used' => TarotCardOrientation.notUsed,
  'upright' => TarotCardOrientation.upright,
  'reversed' => TarotCardOrientation.reversed,
  _ => null,
};

bool _required(String value) => value.trim().isNotEmpty;

bool _isSupportedTimestamp(int value) =>
    value >= -_maxSupportedUtcMicroseconds &&
    value <= _maxSupportedUtcMicroseconds;

RepositoryError _validationFailure(String safeMessage) => RepositoryError(
  code: RepositoryErrorCode.validationFailed,
  safeMessage: safeMessage,
);
