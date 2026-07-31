import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../../core/persistence/app_database.dart';
import '../../domain/saju_snapshot_repository.dart';
import 'saju_snapshot_persistence_mapper.dart';

final class DriftSajuSnapshotRepository implements SajuSnapshotRepository {
  DriftSajuSnapshotRepository(
    this._database, {
    SajuSnapshotPersistenceMapper? mapper,
  }) : _mapper = mapper ?? const SajuSnapshotPersistenceMapper();

  final RynAppDatabase _database;
  final SajuSnapshotPersistenceMapper _mapper;

  @override
  Future<SajuSnapshotResult<SajuPersistedSnapshot>> saveInitialSnapshot({
    required String snapshotId,
    required String personId,
    String? sourceBirthProfileId,
    required String chartGroupId,
    required SajuChartSnapshot snapshot,
    required int createdAtUtcUs,
  }) async {
    try {
      final companion = _mapper.toCompanion(
        id: snapshotId,
        personId: personId,
        sourceBirthProfileId: sourceBirthProfileId,
        chartGroupId: chartGroupId,
        revisionNumber: 1,
        revisionReason: SajuRevisionReason.initial,
        createdAtUtcUs: createdAtUtcUs,
        snapshot: snapshot,
      );
      return await _database.transaction(() async {
        final identityFailure = await _validateIdentity(
          personId,
          sourceBirthProfileId,
        );
        if (identityFailure != null) return identityFailure;
        if (await _hasDuplicate(
          personId,
          companion.inputFingerprintSha256.value,
          companion.calculationSignatureSha256.value,
        )) {
          return _failure(
            SajuSnapshotFailureCode.duplicateSnapshot,
            'An identical immutable Saju snapshot already exists.',
          );
        }
        await _database.into(_database.sajuChartSnapshots).insert(companion);
        return _readInserted(snapshotId);
      });
    } on SajuSnapshotValidationException catch (error) {
      return _failure(SajuSnapshotFailureCode.invalidSnapshot, error.message);
    } on SqliteException catch (error) {
      if (_isConstraint(error)) {
        return _failure(
          SajuSnapshotFailureCode.duplicateSnapshot,
          'The immutable Saju snapshot conflicts with an existing row.',
        );
      }
      return _persistenceFailure();
    } catch (_) {
      return _persistenceFailure();
    }
  }

  @override
  Future<SajuSnapshotResult<SajuPersistedSnapshot>> createRevision({
    required String snapshotId,
    required String personId,
    String? sourceBirthProfileId,
    required String chartGroupId,
    required int expectedCurrentRevisionNumber,
    required SajuRevisionReason revisionReason,
    required SajuChartSnapshot snapshot,
    required int createdAtUtcUs,
  }) async {
    if (revisionReason == SajuRevisionReason.initial ||
        expectedCurrentRevisionNumber < 1) {
      return _failure(
        SajuSnapshotFailureCode.invalidSnapshot,
        'A revision requires a non-initial reason and expected revision.',
      );
    }
    try {
      return await _database.transaction(() async {
        final identityFailure = await _validateIdentity(
          personId,
          sourceBirthProfileId,
        );
        if (identityFailure != null) return identityFailure;
        final latest =
            await (_database.select(_database.sajuChartSnapshots)
                  ..where((table) => table.chartGroupId.equals(chartGroupId))
                  ..orderBy([
                    (table) => OrderingTerm.desc(table.revisionNumber),
                  ])
                  ..limit(1))
                .getSingleOrNull();
        if (latest == null ||
            latest.personId != personId ||
            latest.revisionNumber != expectedCurrentRevisionNumber) {
          return _failure(
            SajuSnapshotFailureCode.revisionConflict,
            'The Saju revision chain changed before this append.',
          );
        }
        final companion = _mapper.toCompanion(
          id: snapshotId,
          personId: personId,
          sourceBirthProfileId: sourceBirthProfileId,
          chartGroupId: chartGroupId,
          revisionNumber: latest.revisionNumber + 1,
          revisionReason: revisionReason,
          createdAtUtcUs: createdAtUtcUs,
          snapshot: snapshot,
        );
        if (await _hasDuplicate(
          personId,
          companion.inputFingerprintSha256.value,
          companion.calculationSignatureSha256.value,
        )) {
          return _failure(
            SajuSnapshotFailureCode.duplicateSnapshot,
            'An identical immutable Saju snapshot already exists.',
          );
        }
        await _database.into(_database.sajuChartSnapshots).insert(companion);
        return _readInserted(snapshotId);
      });
    } on SajuSnapshotValidationException catch (error) {
      return _failure(SajuSnapshotFailureCode.invalidSnapshot, error.message);
    } on SqliteException catch (error) {
      if (_isConstraint(error)) {
        return _failure(
          SajuSnapshotFailureCode.revisionConflict,
          'The Saju revision append conflicted with another transaction.',
        );
      }
      return _persistenceFailure();
    } catch (_) {
      return _persistenceFailure();
    }
  }

  @override
  Future<SajuSnapshotResult<SajuPersistedSnapshot>> getSnapshotById(
    String id,
  ) async {
    if (id.trim().isEmpty) {
      return _failure(
        SajuSnapshotFailureCode.invalidSnapshot,
        'Snapshot identity is required.',
      );
    }
    try {
      final row = await (_database.select(
        _database.sajuChartSnapshots,
      )..where((table) => table.id.equals(id))).getSingleOrNull();
      if (row == null) {
        return _failure(
          SajuSnapshotFailureCode.invalidSnapshot,
          'Saju snapshot was not found.',
        );
      }
      return SajuSnapshotResult.success(_mapper.fromRow(row));
    } on SajuSnapshotValidationException catch (error) {
      return _failure(SajuSnapshotFailureCode.invalidSnapshot, error.message);
    } catch (_) {
      return _persistenceFailure();
    }
  }

  @override
  Future<SajuSnapshotResult<List<SajuPersistedSnapshot>>>
  listSnapshotsForPerson(String personId) async {
    if (personId.trim().isEmpty) {
      return _failure(
        SajuSnapshotFailureCode.invalidSnapshot,
        'Person identity is required.',
      );
    }
    try {
      final rows =
          await (_database.select(_database.sajuChartSnapshots)
                ..where((table) => table.personId.equals(personId))
                ..orderBy([
                  (table) => OrderingTerm.desc(table.calculatedAtUtcUs),
                  (table) => OrderingTerm.desc(table.revisionNumber),
                ]))
              .get();
      return SajuSnapshotResult.success(
        List.unmodifiable(rows.map(_mapper.fromRow)),
      );
    } on SajuSnapshotValidationException catch (error) {
      return _failure(SajuSnapshotFailureCode.invalidSnapshot, error.message);
    } catch (_) {
      return _persistenceFailure();
    }
  }

  @override
  Stream<List<SajuPersistedSnapshot>> watchSnapshotsForPerson(String personId) {
    if (personId.trim().isEmpty) {
      return Stream.error(
        const SajuSnapshotValidationException('Person identity is required.'),
      );
    }
    final query = _database.select(_database.sajuChartSnapshots)
      ..where((table) => table.personId.equals(personId))
      ..orderBy([
        (table) => OrderingTerm.desc(table.calculatedAtUtcUs),
        (table) => OrderingTerm.desc(table.revisionNumber),
      ]);
    return query.watch().map(
      (rows) => List.unmodifiable(rows.map(_mapper.fromRow)),
    );
  }

  @override
  Future<SajuSnapshotResult<SajuPersistedSnapshot?>>
  getLatestSnapshotForPerson(String personId) async {
    if (personId.trim().isEmpty) {
      return _failure(
        SajuSnapshotFailureCode.invalidSnapshot,
        'Person identity is required.',
      );
    }
    try {
      final row =
          await (_database.select(_database.sajuChartSnapshots)
                ..where((table) => table.personId.equals(personId))
                ..orderBy([
                  (table) => OrderingTerm.desc(table.calculatedAtUtcUs),
                  (table) => OrderingTerm.desc(table.revisionNumber),
                ])
                ..limit(1))
              .getSingleOrNull();
      return SajuSnapshotResult.success(
        row == null ? null : _mapper.fromRow(row),
      );
    } on SajuSnapshotValidationException catch (error) {
      return _failure(SajuSnapshotFailureCode.invalidSnapshot, error.message);
    } catch (_) {
      return _persistenceFailure();
    }
  }

  Future<SajuSnapshotResult<SajuPersistedSnapshot>?> _validateIdentity(
    String personId,
    String? birthProfileId,
  ) async {
    final person = await (_database.select(
      _database.persons,
    )..where((table) => table.id.equals(personId))).getSingleOrNull();
    if (person == null) {
      return _failure(
        SajuSnapshotFailureCode.personNotFound,
        'The selected Person record was not found.',
      );
    }
    if (birthProfileId == null) return null;
    final profile = await (_database.select(
      _database.personBirthProfiles,
    )..where((table) => table.id.equals(birthProfileId))).getSingleOrNull();
    if (profile == null) {
      return _failure(
        SajuSnapshotFailureCode.birthProfileNotFound,
        'The selected Birth Profile was not found.',
      );
    }
    if (profile.personId != personId) {
      return _failure(
        SajuSnapshotFailureCode.birthProfilePersonMismatch,
        'The selected Birth Profile belongs to a different Person.',
      );
    }
    return null;
  }

  Future<bool> _hasDuplicate(
    String personId,
    String inputFingerprint,
    String calculationSignature,
  ) async =>
      await (_database.select(_database.sajuChartSnapshots)..where(
            (table) =>
                table.personId.equals(personId) &
                table.inputFingerprintSha256.equals(inputFingerprint) &
                table.calculationSignatureSha256.equals(calculationSignature),
          ))
          .getSingleOrNull() !=
      null;

  Future<SajuSnapshotResult<SajuPersistedSnapshot>> _readInserted(
    String id,
  ) async {
    final row = await (_database.select(
      _database.sajuChartSnapshots,
    )..where((table) => table.id.equals(id))).getSingle();
    return SajuSnapshotResult.success(_mapper.fromRow(row));
  }

  bool _isConstraint(SqliteException error) =>
      error.extendedResultCode == 1555 ||
      error.extendedResultCode == 2067 ||
      error.resultCode == 19;

  SajuSnapshotResult<T> _failure<T>(
    SajuSnapshotFailureCode code,
    String message,
  ) => SajuSnapshotResult.failed(code, message);

  SajuSnapshotResult<T> _persistenceFailure<T>() => _failure(
    SajuSnapshotFailureCode.persistenceFailure,
    'Saju persistence operation could not be completed.',
  );
}
