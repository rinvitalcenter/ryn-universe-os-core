import 'package:drift/drift.dart';

import '../../../../core/persistence/app_database.dart';
import '../../../../core/repositories/repository_result.dart';
import '../../domain/tarot_persistence_models.dart';
import '../../models/tarot_reading_result_snapshot.dart';
import 'tarot_persistence_mapper.dart';
import 'tarot_reading_repository.dart';

typedef TarotPersistenceClock = DateTime Function();

final class DriftTarotReadingRepository implements TarotReadingRepository {
  DriftTarotReadingRepository(this._database, {TarotPersistenceClock? clock})
    : _clock = clock ?? DateTime.now;

  final RynAppDatabase _database;
  final TarotPersistenceClock _clock;
  final TarotPersistenceMapper _mapper = const TarotPersistenceMapper();

  @override
  Future<RepositoryResult<PersistedTarotReadingRecord>> createCompletedReading(
    CompletedTarotReadingPersistenceInput input,
  ) async {
    final nowUs = _nowUtcUs();
    final mapped = _mapper.toWriteSet(input, nowUtcUs: nowUs);
    if (mapped.isFailure) {
      return RepositoryResult.failure(mapped.error!);
    }

    try {
      return await _database.transaction(() async {
        final existing = await _readingRow(input.snapshot.readingInstanceId);
        if (existing != null) {
          final hydrated = await _hydrate(existing);
          if (hydrated.isFailure) return hydrated;
          if (_hasSameImmutableResult(hydrated.value!, input)) {
            return hydrated;
          }
          return RepositoryResult.failure(
            _error(
              RepositoryErrorCode.conflict,
              'A different immutable Tarot result already uses this ID.',
            ),
          );
        }

        final rows = mapped.value!;
        await _database.into(_database.tarotReadings).insert(rows.reading);
        for (final placement in rows.placements) {
          await _database.into(_database.tarotCardPlacements).insert(placement);
        }
        final actualPlacementCount = await _placementCount(
          input.snapshot.readingInstanceId,
        );
        if (actualPlacementCount != input.snapshot.placements.length) {
          throw StateError(
            'Synthetic aggregate placement verification failed.',
          );
        }
        final interpretation = rows.interpretation;
        if (interpretation != null) {
          await _database
              .into(_database.tarotInterpretations)
              .insert(interpretation);
        }
        await _setActiveHomeId(
          input.snapshot.readingInstanceId,
          updatedAtUtcUs: nowUs,
        );
        final created = await _readingRow(input.snapshot.readingInstanceId);
        return _hydrate(created!);
      });
    } catch (_) {
      return RepositoryResult.failure(_persistenceFailure());
    }
  }

  @override
  Future<RepositoryResult<PersistedTarotReadingRecord>> getReadingById(
    String readingInstanceId,
  ) async {
    final normalized = readingInstanceId.trim();
    if (normalized.isEmpty) {
      return RepositoryResult.failure(
        _validationFailure('Reading ID is required.'),
      );
    }
    try {
      final row = await _readingRow(normalized);
      if (row == null) return RepositoryResult.failure(_notFound());
      return _hydrate(row);
    } catch (_) {
      return RepositoryResult.failure(_persistenceFailure());
    }
  }

  @override
  Future<RepositoryResult<List<PersistedTarotReadingRecord>>>
  loadAllReadings() async {
    try {
      final rows =
          await (_database.select(_database.tarotReadings)..orderBy([
                (table) => OrderingTerm.desc(table.readingAtUtcUs),
                (table) => OrderingTerm.asc(table.readingInstanceId),
              ]))
              .get();
      final records = <PersistedTarotReadingRecord>[];
      for (final row in rows) {
        final hydrated = await _hydrate(row);
        if (hydrated.isFailure) {
          return RepositoryResult.failure(hydrated.error!);
        }
        records.add(hydrated.value!);
      }
      return RepositoryResult.success(List.unmodifiable(records));
    } catch (_) {
      return RepositoryResult.failure(_persistenceFailure());
    }
  }

  @override
  Future<RepositoryResult<PersistedTarotReadingRecord>> saveInterpretation(
    TarotInterpretationUpdate update,
  ) async {
    final nowUs = _nowUtcUs();
    try {
      return await _database.transaction(() async {
        final reading = await _readingRow(update.readingInstanceId);
        if (reading == null) return RepositoryResult.failure(_notFound());
        final existing =
            await (_database.select(_database.tarotInterpretations)..where(
                  (table) =>
                      table.readingInstanceId.equals(update.readingInstanceId),
                ))
                .getSingleOrNull();
        final row = TarotInterpretationsCompanion.insert(
          readingInstanceId: update.readingInstanceId,
          wholeImageObservation: Value(
            update.wholeImageObservation ??
                existing?.wholeImageObservation ??
                '',
          ),
          flowInterpretation: Value(
            update.flowInterpretation ?? existing?.flowInterpretation ?? '',
          ),
          coreMessage: Value(update.coreMessage ?? existing?.coreMessage ?? ''),
          smallAction: Value(update.smallAction ?? existing?.smallAction ?? ''),
          createdAtUtcUs: existing?.createdAtUtcUs ?? nowUs,
          updatedAtUtcUs: nowUs,
        );
        await _database
            .into(_database.tarotInterpretations)
            .insertOnConflictUpdate(row);
        await (_database.update(_database.tarotReadings)..where(
              (table) =>
                  table.readingInstanceId.equals(update.readingInstanceId),
            ))
            .write(TarotReadingsCompanion(updatedAtUtcUs: Value(nowUs)));
        return _hydrate((await _readingRow(update.readingInstanceId))!);
      });
    } catch (_) {
      return RepositoryResult.failure(_persistenceFailure());
    }
  }

  @override
  Future<RepositoryResult<PersistedTarotReadingRecord>> updateDisplayQuestion(
    String readingInstanceId,
    String questionDisplayText,
  ) async {
    final id = readingInstanceId.trim();
    final display = questionDisplayText.trim();
    if (id.isEmpty || display.isEmpty) {
      return RepositoryResult.failure(
        _validationFailure('Reading ID and display question are required.'),
      );
    }
    final nowUs = _nowUtcUs();
    try {
      return await _database.transaction(() async {
        if (await _readingRow(id) == null) {
          return RepositoryResult.failure(_notFound());
        }
        await (_database.update(
          _database.tarotReadings,
        )..where((table) => table.readingInstanceId.equals(id))).write(
          TarotReadingsCompanion(
            questionDisplayText: Value(display),
            updatedAtUtcUs: Value(nowUs),
          ),
        );
        return _hydrate((await _readingRow(id))!);
      });
    } catch (_) {
      return RepositoryResult.failure(_persistenceFailure());
    }
  }

  @override
  Future<RepositoryResult<String?>> getActiveHomeReadingId() async {
    try {
      final row = await (_database.select(
        _database.appRuntimeState,
      )..where((table) => table.stateKey.equals('main'))).getSingle();
      return RepositoryResult.success(row.activeHomeTarotReadingId);
    } catch (_) {
      return RepositoryResult.failure(_persistenceFailure());
    }
  }

  @override
  Future<RepositoryResult<bool>> hideActiveHomeReading() async {
    try {
      await _setActiveHomeId(null, updatedAtUtcUs: _nowUtcUs());
      return RepositoryResult.success(true);
    } catch (_) {
      return RepositoryResult.failure(_persistenceFailure());
    }
  }

  @override
  Future<RepositoryResult<bool>> activateHomeReading(
    String readingInstanceId,
  ) async {
    final id = readingInstanceId.trim();
    if (id.isEmpty) {
      return RepositoryResult.failure(
        _validationFailure('Reading ID is required.'),
      );
    }
    try {
      return await _database.transaction(() async {
        final row = await _readingRow(id);
        if (row == null) return RepositoryResult.failure(_notFound());
        if (row.lifecycleStatus != 'continuing') {
          return RepositoryResult.failure(
            _validationFailure(
              'Only continuing readings can be active on Home.',
            ),
          );
        }
        await _setActiveHomeId(id, updatedAtUtcUs: _nowUtcUs());
        return RepositoryResult.success(true);
      });
    } catch (_) {
      return RepositoryResult.failure(_persistenceFailure());
    }
  }

  @override
  Future<RepositoryResult<PersistedTarotReadingRecord>> finishReading(
    String readingInstanceId,
  ) async {
    final id = readingInstanceId.trim();
    if (id.isEmpty) {
      return RepositoryResult.failure(
        _validationFailure('Reading ID is required.'),
      );
    }
    final nowUs = _nowUtcUs();
    try {
      return await _database.transaction(() async {
        final row = await _readingRow(id);
        if (row == null) return RepositoryResult.failure(_notFound());
        if (row.lifecycleStatus != 'finished') {
          await (_database.update(
            _database.tarotReadings,
          )..where((table) => table.readingInstanceId.equals(id))).write(
            TarotReadingsCompanion(
              lifecycleStatus: const Value('finished'),
              finishedAtUtcUs: Value(nowUs),
              updatedAtUtcUs: Value(nowUs),
            ),
          );
        }
        final state = await (_database.select(
          _database.appRuntimeState,
        )..where((table) => table.stateKey.equals('main'))).getSingle();
        if (state.activeHomeTarotReadingId == id) {
          await _setActiveHomeId(null, updatedAtUtcUs: nowUs);
        }
        return _hydrate((await _readingRow(id))!);
      });
    } catch (_) {
      return RepositoryResult.failure(_persistenceFailure());
    }
  }

  @override
  Future<RepositoryResult<PersistedTarotReadingRecord>>
  reactivateAndFeatureReading(String readingInstanceId) async {
    final id = readingInstanceId.trim();
    if (id.isEmpty) {
      return RepositoryResult.failure(
        _validationFailure('Reading ID is required.'),
      );
    }
    final nowUs = _nowUtcUs();
    try {
      return await _database.transaction(() async {
        final row = await _readingRow(id);
        if (row == null) return RepositoryResult.failure(_notFound());
        if (row.lifecycleStatus == 'finished') {
          await (_database.update(
            _database.tarotReadings,
          )..where((table) => table.readingInstanceId.equals(id))).write(
            TarotReadingsCompanion(
              lifecycleStatus: const Value('continuing'),
              finishedAtUtcUs: const Value(null),
              updatedAtUtcUs: Value(nowUs),
            ),
          );
        }
        await _setActiveHomeId(id, updatedAtUtcUs: nowUs);
        return _hydrate((await _readingRow(id))!);
      });
    } catch (_) {
      return RepositoryResult.failure(_persistenceFailure());
    }
  }

  Future<TarotReading?> _readingRow(String id) => (_database.select(
    _database.tarotReadings,
  )..where((table) => table.readingInstanceId.equals(id))).getSingleOrNull();

  Future<RepositoryResult<PersistedTarotReadingRecord>> _hydrate(
    TarotReading reading,
  ) async {
    final placements =
        await (_database.select(_database.tarotCardPlacements)
              ..where(
                (table) =>
                    table.readingInstanceId.equals(reading.readingInstanceId),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.placementOrder)]))
            .get();
    final interpretation =
        await (_database.select(_database.tarotInterpretations)..where(
              (table) =>
                  table.readingInstanceId.equals(reading.readingInstanceId),
            ))
            .getSingleOrNull();
    return _mapper.hydrate(
      reading: reading,
      placements: placements,
      interpretation: interpretation,
    );
  }

  Future<int> _placementCount(String id) async {
    final expression = _database.tarotCardPlacements.placementOrder.count();
    final query = _database.selectOnly(_database.tarotCardPlacements)
      ..addColumns([expression])
      ..where(_database.tarotCardPlacements.readingInstanceId.equals(id));
    return (await query.getSingle()).read(expression) ?? 0;
  }

  Future<void> _setActiveHomeId(String? id, {required int updatedAtUtcUs}) =>
      (_database.update(
        _database.appRuntimeState,
      )..where((table) => table.stateKey.equals('main'))).write(
        AppRuntimeStateCompanion(
          activeHomeTarotReadingId: Value(id),
          updatedAtUtcUs: Value(updatedAtUtcUs),
        ),
      );

  bool _hasSameImmutableResult(
    PersistedTarotReadingRecord stored,
    CompletedTarotReadingPersistenceInput input,
  ) {
    final expected = input.snapshot;
    final actual = stored.snapshot;
    if (stored.sourceType != input.sourceType ||
        stored.readingTimezoneOffsetMinutes !=
            input.readingTimezoneOffsetMinutes ||
        actual.readingInstanceId != expected.readingInstanceId ||
        actual.readingQuestionText != expected.readingQuestionText ||
        actual.deckId != expected.deckId ||
        actual.deckNameSnapshot != expected.deckNameSnapshot ||
        actual.spreadId != expected.spreadId ||
        actual.spreadNameSnapshot != expected.spreadNameSnapshot ||
        actual.readingAt.microsecondsSinceEpoch !=
            expected.readingAt.microsecondsSinceEpoch ||
        actual.placements.length != expected.placements.length) {
      return false;
    }
    for (var index = 0; index < actual.placements.length; index++) {
      final left = actual.placements[index];
      final right = expected.placements[index];
      if (!_samePlacement(left, right)) return false;
    }
    return true;
  }

  int _nowUtcUs() => _clock().toUtc().microsecondsSinceEpoch;
}

bool _samePlacement(
  TarotCardPlacementSnapshot left,
  TarotCardPlacementSnapshot right,
) =>
    left.placementOrder == right.placementOrder &&
    left.positionId == right.positionId &&
    left.positionNameSnapshot == right.positionNameSnapshot &&
    left.cardId == right.cardId &&
    left.cardNameSnapshot == right.cardNameSnapshot &&
    left.orientation == right.orientation;

RepositoryError _error(RepositoryErrorCode code, String message) =>
    RepositoryError(code: code, safeMessage: message);

RepositoryError _validationFailure(String message) =>
    _error(RepositoryErrorCode.validationFailed, message);

RepositoryError _notFound() =>
    _error(RepositoryErrorCode.notFound, 'Tarot reading was not found.');

RepositoryError _persistenceFailure() => _error(
  RepositoryErrorCode.persistenceUnavailable,
  'Tarot persistence operation could not be completed.',
);
