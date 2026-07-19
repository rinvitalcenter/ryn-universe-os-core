import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../core/persistence/app_database.dart';
import '../../../core/persistence/migrations.dart';
import '../../../core/persistence/runtime_data_profile.dart';
import '../../../core/repositories/repository_result.dart';
import '../../../core/runtime/ryn_runtime_services.dart';
import '../../records/models/session_tarot_results.dart';
import '../backup_recovery/application/tarot_restore_coordinator.dart';
import '../backup_recovery/application/tarot_restore_startup_recovery_coordinator.dart';
import '../backup_recovery/infrastructure/tarot_backup_path_contract.dart';

import '../domain/tarot_persistence_models.dart';
import '../models/tarot_interpretation_session_draft.dart';
import '../models/tarot_reading_result_snapshot.dart';

enum TarotRuntimeStartupStatus {
  initializing,
  readyEmpty,
  readyWithData,
  recoveryRequired,
  unsupportedNewerSchema,
}

enum TarotRuntimeFailureCategory {
  databaseOpenFailed,
  unsupportedSchema,
  loadFailed,
  writeFailed,
  conflict,
  storageUnavailable,
  permissionDenied,
}

enum TarotDraftSaveStatus { clean, dirty, saving, saved, failed }

final class TarotRuntimeFailure {
  const TarotRuntimeFailure({
    required this.category,
    required this.userMessage,
    required this.technicalCode,
  });

  final TarotRuntimeFailureCategory category;
  final String userMessage;
  final String technicalCode;
}

final class _UnsupportedRuntimeSchema implements Exception {
  const _UnsupportedRuntimeSchema();
}

/// Application-owned lifecycle for the development Tarot database and commands.
/// Presentation widgets receive state and callbacks only; Drift rows never leave
/// this boundary.
final class TarotRuntimeController extends ChangeNotifier {
  TarotRuntimeController.development({
    RynRuntimeDataPathContract? pathContract,
    RynRuntimeDataMode? runtimeDataMode,
    this.startupRecoveryCoordinator,
  }) : _pathContract = pathContract ?? RynRuntimeDataPathContract(),
       _runtimeDataMode =
           runtimeDataMode ?? RynRuntimeDataModeContract.fromEnvironment();

  @visibleForTesting
  TarotRuntimeController.presentationTest({
    TarotRuntimeStartupStatus status = TarotRuntimeStartupStatus.readyEmpty,
  }) : assert(
         status != TarotRuntimeStartupStatus.initializing,
         'Presentation tests must provide a resolved state.',
       ),
       _pathContract = RynRuntimeDataPathContract.forApplicationSupportRoot(
         Directory.systemTemp,
       ),
       _runtimeDataMode = RynRuntimeDataMode.standardDevelopment,
       startupRecoveryCoordinator = null {
    _startupStatus = status;
    if (status == TarotRuntimeStartupStatus.recoveryRequired) {
      _failure = const TarotRuntimeFailure(
        category: TarotRuntimeFailureCategory.loadFailed,
        userMessage: '저장된 기록을 불러오지 못했어요.',
        technicalCode: 'presentation_test_load_failed',
      );
    } else if (status == TarotRuntimeStartupStatus.unsupportedNewerSchema) {
      _failure = const TarotRuntimeFailure(
        category: TarotRuntimeFailureCategory.unsupportedSchema,
        userMessage: '이 앱보다 새로운 형식의 기록입니다.',
        technicalCode: 'presentation_test_unsupported_schema',
      );
    }
  }

  final RynRuntimeDataPathContract _pathContract;
  final RynRuntimeDataMode _runtimeDataMode;
  final TarotRestoreStartupRecoveryCoordinator? startupRecoveryCoordinator;
  final SessionTarotResults _sessionResults = SessionTarotResults();
  final Map<String, TarotInterpretationSessionDraft> _drafts = {};
  final Map<String, TarotInterpretationSessionDraft> _lastSavedDrafts = {};
  final Map<String, TarotDraftSaveStatus> _saveStatuses = {};
  List<PersistedTarotReadingRecord> _records = const [];
  RynRuntimeServices? _runtimeServices;
  Future<void>? _databaseCloseFuture;
  TarotRuntimeStartupStatus _startupStatus =
      TarotRuntimeStartupStatus.initializing;
  TarotRuntimeFailure? _failure;
  String? _databasePath;
  TarotRestoreStartupRecoveryResult? _startupRecoveryResult;
  bool _closed = false;

  TarotRuntimeStartupStatus get startupStatus => _startupStatus;
  TarotRuntimeFailure? get failure => _failure;
  String? get databasePath => _databasePath;
  RynRuntimeDataMode get runtimeDataMode => _runtimeDataMode;
  TarotRestoreStartupRecoveryResult? get startupRecoveryResult =>
      _startupRecoveryResult;
  bool get isClosed => _closed;
  RynRuntimeServices? get runtimeServices => _runtimeServices;
  SessionTarotResults get sessionResults => _sessionResults;
  List<TarotReadingResultSnapshot> get snapshots => _sessionResults.results;
  String? get activeReadingInstanceId =>
      _sessionResults.activeReadingInstanceId;
  TarotReadingResultSnapshot? get activeSnapshot =>
      _sessionResults.activeResult;

  PersistedTarotReadingRecord? recordFor(String readingInstanceId) {
    for (final record in _records) {
      if (record.snapshot.readingInstanceId == readingInstanceId) return record;
    }
    return null;
  }

  TarotInterpretationSessionDraft? draftFor(String readingInstanceId) =>
      _drafts[readingInstanceId];

  String questionDisplayTextFor(String readingInstanceId) =>
      recordFor(readingInstanceId)?.questionDisplayText ?? '';

  TarotDraftSaveStatus saveStatusFor(String readingInstanceId) =>
      _saveStatuses[readingInstanceId] ?? TarotDraftSaveStatus.clean;

  Future<void> bootstrap() async {
    await _closeDatabase();
    _closed = false;
    _startupStatus = TarotRuntimeStartupStatus.initializing;
    _failure = null;
    _startupRecoveryResult = null;
    _records = const [];
    _drafts.clear();
    _lastSavedDrafts.clear();
    _saveStatuses.clear();
    _sessionResults.hydrate(const [], activeReadingInstanceId: null);
    notifyListeners();

    RynResolvedDatabasePath resolvedPath;
    try {
      resolvedPath = await _pathContract.requireRuntimeOpenableMode(
        _runtimeDataMode,
      );
      _databasePath = resolvedPath.databasePath;
      await _recoverInterruptedRestore(resolvedPath);
      if (_startupRecoveryResult?.requiresManualRecovery ?? false) {
        _setStartupFailure(
          TarotRuntimeFailureCategory.loadFailed,
          _startupRecoveryResult!.failureCode ??
              'startup_restore_recovery_required',
        );
        return;
      }
      _verifyExistingSchemaBeforeOpen(resolvedPath.databasePath);
      final database = await RynAppDatabase.openDevelopment(
        resolvedPath: resolvedPath,
      );
      _runtimeServices = RynRuntimeServices(database);
      await database.customSelect('PRAGMA user_version').getSingle();
      await _reload();
    } on _UnsupportedRuntimeSchema {
      await _closeDatabase();
      _startupStatus = TarotRuntimeStartupStatus.unsupportedNewerSchema;
      _failure = const TarotRuntimeFailure(
        category: TarotRuntimeFailureCategory.unsupportedSchema,
        userMessage: '이 앱보다 새로운 형식의 기록입니다. 앱 업데이트가 필요해요.',
        technicalCode: 'unsupported_schema',
      );
      notifyListeners();
    } on FileSystemException catch (error) {
      await _closeDatabase();
      _setStartupFailure(
        _fileSystemCategory(error),
        error.runtimeType.toString(),
      );
    } catch (error) {
      await _closeDatabase();
      _setStartupFailure(
        TarotRuntimeFailureCategory.loadFailed,
        error.runtimeType.toString(),
      );
    }
  }

  Future<bool> completeSelfReading({
    required TarotReadingResultSnapshot snapshot,
    required int readingTimezoneOffsetMinutes,
    TarotInterpretationSessionDraft? interpretation,
  }) async {
    final repository = _runtimeServices?.tarotReadings;
    if (repository == null) return _writeUnavailable();
    final result = await repository.createCompletedReading(
      CompletedTarotReadingPersistenceInput(
        snapshot: snapshot,
        sourceType: TarotReadingOrigin.selfDrawn,
        readingTimezoneOffsetMinutes: readingTimezoneOffsetMinutes,
        interpretation: interpretation,
      ),
    );
    if (result.isFailure) return _captureRepositoryWriteFailure(result.error!);
    await _reload();
    return true;
  }

  void retainDraft(TarotInterpretationSessionDraft draft) {
    _drafts[draft.readingInstanceId] = draft;
    final saved = _lastSavedDrafts[draft.readingInstanceId];
    _saveStatuses[draft.readingInstanceId] =
        saved != null && draft.hasSameContentAs(saved)
        ? TarotDraftSaveStatus.saved
        : TarotDraftSaveStatus.dirty;
    notifyListeners();
  }

  Future<bool> saveInterpretation(String readingInstanceId) async {
    final repository = _runtimeServices?.tarotReadings;
    final draft = _drafts[readingInstanceId];
    if (repository == null || draft == null) return _writeUnavailable();
    _saveStatuses[readingInstanceId] = TarotDraftSaveStatus.saving;
    _failure = null;
    notifyListeners();
    final result = await repository.saveInterpretation(
      TarotInterpretationUpdate(
        readingInstanceId: readingInstanceId,
        wholeImageObservation: draft.wholeImageObservation,
        flowInterpretation: draft.flowInterpretation,
        coreMessage: draft.coreMessage,
        smallAction: draft.smallAction,
      ),
    );
    if (result.isFailure) {
      _saveStatuses[readingInstanceId] = TarotDraftSaveStatus.failed;
      return _captureRepositoryWriteFailure(result.error!);
    }
    _lastSavedDrafts[readingInstanceId] = draft;
    _saveStatuses[readingInstanceId] = TarotDraftSaveStatus.saved;
    await _reload(preserveLiveDrafts: true);
    return true;
  }

  Future<bool> saveBeforeNavigation(String readingInstanceId) async {
    final status = saveStatusFor(readingInstanceId);
    if (status == TarotDraftSaveStatus.dirty ||
        status == TarotDraftSaveStatus.failed) {
      return saveInterpretation(readingInstanceId);
    }
    return true;
  }

  Future<bool> hideActiveFromHome() async {
    final repository = _runtimeServices?.tarotReadings;
    if (repository == null) return _writeUnavailable();
    final result = await repository.hideActiveHomeReading();
    if (result.isFailure) return _captureRepositoryWriteFailure(result.error!);
    await _reload(preserveLiveDrafts: true);
    return true;
  }

  Future<bool> featureReading(String readingInstanceId) async {
    final repository = _runtimeServices?.tarotReadings;
    if (repository == null) return _writeUnavailable();
    final record = recordFor(readingInstanceId);
    if (record == null) return _writeUnavailable();
    final result = record.lifecycle == TarotReadingLifecycle.finished
        ? await repository.reactivateAndFeatureReading(readingInstanceId)
        : await repository.activateHomeReading(readingInstanceId);
    if (result.isFailure) return _captureRepositoryWriteFailure(result.error!);
    await _reload(preserveLiveDrafts: true);
    return true;
  }

  TarotRestoreRuntimeLifecycle syntheticRestoreLifecycle(
    RynResolvedDatabasePath resolvedPath,
  ) {
    if (_runtimeDataMode != RynRuntimeDataMode.tarotBackupRecoveryQa ||
        !resolvedPath.isSyntheticOnly ||
        resolvedPath.databasePath != _databasePath) {
      throw StateError('restore lifecycle is unavailable outside synthetic QA');
    }
    return _RuntimeRestoreLifecycle(this, resolvedPath);
  }

  Future<void> close() async {
    await _closeDatabase();
    _closed = true;
  }

  Future<void> _recoverInterruptedRestore(
    RynResolvedDatabasePath resolvedPath,
  ) async {
    final coordinator = startupRecoveryCoordinator;
    if (coordinator == null ||
        _runtimeDataMode != RynRuntimeDataMode.tarotBackupRecoveryQa ||
        !Directory(resolvedPath.runtimeDirectoryPath).existsSync()) {
      return;
    }
    final recoveryPaths = TarotBackupPathContract(
      sourceRootPath: resolvedPath.runtimeDirectoryPath,
      backupRootPath: resolvedPath.backupOutputDirectoryPath,
      protectedRootPaths: const <String>[],
    ).resolve();
    _startupRecoveryResult = await coordinator.recoverIfNeeded(
      liveDatabasePath: resolvedPath.databasePath,
      resolvedPaths: recoveryPaths,
      lifecycle: _RuntimeRestoreLifecycle(this, resolvedPath),
    );
  }

  Future<void> _reopenForRestore(RynResolvedDatabasePath resolvedPath) async {
    await _closeDatabase();
    final database = await RynAppDatabase.openDevelopment(
      resolvedPath: resolvedPath,
    );
    _runtimeServices = RynRuntimeServices(database);
  }

  Future<void> _validateBasicRestoreRead() async {
    final database = _runtimeServices?.database;
    if (database == null) throw StateError('restore runtime is closed');
    await database.customSelect('PRAGMA user_version').getSingle();
  }

  void _verifyExistingSchemaBeforeOpen(String path) {
    final file = File(path);
    if (!file.existsSync()) return;
    final database = sqlite3.open(path, mode: OpenMode.readOnly);
    try {
      final rows = database.select('PRAGMA user_version');
      final version = rows.single.values.single as int;
      if (version > plannedCurrentSchemaVersion) {
        throw const _UnsupportedRuntimeSchema();
      }
    } finally {
      database.close();
    }
  }

  Future<void> _reload({bool preserveLiveDrafts = false}) async {
    final repository = _runtimeServices!.tarotReadings;
    final recordsResult = await repository.loadAllReadings();
    final activeResult = await repository.getActiveHomeReadingId();
    if (recordsResult.isFailure || activeResult.isFailure) {
      throw StateError('Tarot runtime hydration failed.');
    }
    final records = recordsResult.value!;
    final ids = <String>{};
    for (final record in records) {
      if (!ids.add(record.snapshot.readingInstanceId)) {
        throw StateError('Duplicate Tarot reading identity.');
      }
    }
    final activeId = activeResult.value;
    if (activeId != null) {
      final active = records.where(
        (record) => record.snapshot.readingInstanceId == activeId,
      );
      if (active.length != 1 ||
          active.single.lifecycle != TarotReadingLifecycle.continuing) {
        throw StateError('Invalid active Home Tarot identity.');
      }
    }
    final liveDrafts = preserveLiveDrafts
        ? Map<String, TarotInterpretationSessionDraft>.of(_drafts)
        : const <String, TarotInterpretationSessionDraft>{};
    _records = List.unmodifiable(records);
    _drafts.clear();
    _lastSavedDrafts.clear();
    _saveStatuses.clear();
    for (final record in records) {
      final saved = record.interpretation;
      if (saved != null) {
        _drafts[record.snapshot.readingInstanceId] = saved;
        _lastSavedDrafts[record.snapshot.readingInstanceId] = saved;
        _saveStatuses[record.snapshot.readingInstanceId] =
            TarotDraftSaveStatus.saved;
      }
    }
    for (final entry in liveDrafts.entries) {
      _drafts[entry.key] = entry.value;
      final saved = _lastSavedDrafts[entry.key];
      _saveStatuses[entry.key] =
          saved != null && entry.value.hasSameContentAs(saved)
          ? TarotDraftSaveStatus.saved
          : TarotDraftSaveStatus.dirty;
    }
    _sessionResults.hydrate(
      records.map((record) => record.snapshot).toList(growable: false),
      activeReadingInstanceId: activeId,
    );
    _startupStatus = records.isEmpty
        ? TarotRuntimeStartupStatus.readyEmpty
        : TarotRuntimeStartupStatus.readyWithData;
    _failure = null;
    notifyListeners();
  }

  void _setStartupFailure(
    TarotRuntimeFailureCategory category,
    String technicalCode,
  ) {
    _startupStatus = TarotRuntimeStartupStatus.recoveryRequired;
    _failure = TarotRuntimeFailure(
      category: category,
      userMessage: '저장된 기록을 불러오지 못했어요. 기존 데이터 파일은 변경하지 않았습니다.',
      technicalCode: technicalCode,
    );
    notifyListeners();
  }

  TarotRuntimeFailureCategory _fileSystemCategory(FileSystemException error) {
    final code = error.osError?.errorCode;
    if (code == 5 || code == 13) {
      return TarotRuntimeFailureCategory.permissionDenied;
    }
    if (code == 28 || code == 112) {
      return TarotRuntimeFailureCategory.storageUnavailable;
    }
    return TarotRuntimeFailureCategory.databaseOpenFailed;
  }

  bool _captureRepositoryWriteFailure(RepositoryError error) {
    final category = error.code == RepositoryErrorCode.conflict
        ? TarotRuntimeFailureCategory.conflict
        : TarotRuntimeFailureCategory.writeFailed;
    _failure = TarotRuntimeFailure(
      category: category,
      userMessage: category == TarotRuntimeFailureCategory.conflict
          ? '같은 기록 ID에 다른 결과가 있어 저장하지 못했어요.'
          : '저장하지 못했어요. 작성한 내용은 화면에 그대로 남아 있어요.',
      technicalCode: error.code.name,
    );
    notifyListeners();
    return false;
  }

  bool _writeUnavailable() {
    _failure = const TarotRuntimeFailure(
      category: TarotRuntimeFailureCategory.writeFailed,
      userMessage: '저장하지 못했어요. 작성한 내용은 화면에 그대로 남아 있어요.',
      technicalCode: 'repository_unavailable',
    );
    notifyListeners();
    return false;
  }

  Future<void> _closeDatabase() async {
    final closing = _databaseCloseFuture;
    if (closing != null) {
      await closing;
      return;
    }
    final database = _runtimeServices?.database;
    _runtimeServices = null;
    if (database == null) return;
    final closeFuture = database.close();
    _databaseCloseFuture = closeFuture;
    try {
      await closeFuture;
    } finally {
      if (identical(_databaseCloseFuture, closeFuture)) {
        _databaseCloseFuture = null;
      }
    }
  }
}

final class _RuntimeRestoreLifecycle implements TarotRestoreRuntimeLifecycle {
  const _RuntimeRestoreLifecycle(this.controller, this.resolvedPath);

  final TarotRuntimeController controller;
  final RynResolvedDatabasePath resolvedPath;

  @override
  Future<void> close() => controller._closeDatabase();

  @override
  Future<void> reopen() => controller._reopenForRestore(resolvedPath);

  @override
  Future<void> validateBasicRead() => controller._validateBasicRestoreRead();
}
