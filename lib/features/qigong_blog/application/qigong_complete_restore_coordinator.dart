import 'dart:io';

import 'package:path/path.dart' as p;

import '../../tarot/backup_recovery/domain/tarot_backup_manifest.dart';
import '../domain/qigong_complete_restore_operation_marker.dart';
import '../infrastructure/qigong_complete_backup_service.dart';

typedef QigongRestoreClock = DateTime Function();
typedef QigongRestoreOperationIdGenerator = String Function();
typedef QigongRestoreFileRename =
    Future<File> Function(File source, String targetPath);
typedef QigongRestoreDirectoryRename =
    Future<Directory> Function(Directory source, String targetPath);

abstract interface class QigongCompleteRestoreRuntimeLifecycle {
  Future<void> enterMaintenance();
  Future<void> close();
  Future<void> reopen();
  Future<void> validateBasicRead();
  Future<void> rehydrate();
  Future<void> leaveMaintenance();
}

enum QigongCompleteRestoreStatus {
  succeeded,
  failedBeforeMutation,
  failedRolledBack,
  fatalPreserved,
}

final class QigongCompleteRestoreResult {
  const QigongCompleteRestoreResult({
    required this.status,
    this.failureCode,
    this.safetyBackupPackagePath,
    this.operationDirectoryPath,
    this.rawRollbackEvidencePath,
  });

  final QigongCompleteRestoreStatus status;
  final String? failureCode;
  final String? safetyBackupPackagePath;
  final String? operationDirectoryPath;
  final String? rawRollbackEvidencePath;
}

final class QigongCompleteRestoreCoordinator {
  QigongCompleteRestoreCoordinator({
    required this.backupService,
    required this.clock,
    required this.safetyOperationIdGenerator,
    this.markerStore = const QigongCompleteRestoreOperationMarkerStore(),
    this.allowRawRollbackFallback = false,
    QigongRestoreFileRename? renameFile,
    QigongRestoreDirectoryRename? renameDirectory,
  }) : _renameFile = renameFile ?? _defaultRenameFile,
       _renameDirectory = renameDirectory ?? _defaultRenameDirectory;

  final QigongCompleteBackupService backupService;
  final QigongRestoreClock clock;
  final QigongRestoreOperationIdGenerator safetyOperationIdGenerator;
  final QigongCompleteRestoreOperationMarkerStore markerStore;
  final bool allowRawRollbackFallback;
  final QigongRestoreFileRename _renameFile;
  final QigongRestoreDirectoryRename _renameDirectory;
  static const Set<String> _rawFallbackAllowedCodes = <String>{
    'source_database_invalid',
    'media_manifest_database_read_failed',
    'managed_media_missing',
    'managed_media_hash_mismatch',
  };

  Future<QigongCompleteRestoreResult> restore({
    required Directory candidatePackage,
    required String operationId,
    required QigongCompleteRestoreRuntimeLifecycle lifecycle,
  }) async {
    if (!RegExp(r'^[0-9a-f]{8}$').hasMatch(operationId)) {
      return const QigongCompleteRestoreResult(
        status: QigongCompleteRestoreStatus.failedBeforeMutation,
        failureCode: 'invalid_restore_operation_id',
      );
    }
    final operationRoot = Directory(
      p.join(
        backupService.profileRoot.path,
        '.qigong-complete-restore-$operationId',
      ),
    );
    final stagedRoot = Directory(p.join(operationRoot.path, 'staged'));
    final rollbackRoot = Directory(p.join(operationRoot.path, 'rollback'));
    Directory? safetyPackage;
    QigongCompleteRestoreOperationMarker? marker;
    var maintenanceEntered = false;
    var runtimeClosed = false;
    var liveMutationStarted = false;
    var validatedDurable = false;
    var rawFallbackUsed = false;
    Directory? rawRollbackEvidence;
    try {
      if (operationRoot.existsSync()) {
        throw const QigongBackupException('restore_operation_collision');
      }
      final evidence = await backupService.validateBackup(candidatePackage);
      if (!const <int>{
        TarotBackupManifest.schemaVersionV10,
        TarotBackupManifest.schemaVersion,
      }.contains(evidence.schemaVersion)) {
        throw const QigongBackupException('unsupported_schema_version');
      }
      final identity = await backupService.packageIdentitySha256(
        candidatePackage,
      );
      await operationRoot.create();
      await backupService.requireSafeRestorePath(operationRoot.path);
      final startedAt = clock().toUtc();
      marker = QigongCompleteRestoreOperationMarker(
        operationId: operationId,
        phase: QigongCompleteRestorePhase.prepared,
        startedAtUtc: startedAt,
        updatedAtUtc: startedAt,
        candidatePackageIdentitySha256: identity,
        stagedDirectoryName: 'staged',
        rollbackDirectoryName: 'rollback',
        sourceSchemaVersion: evidence.schemaVersion,
        expectedTargetSchemaVersion: TarotBackupManifest.schemaVersion,
        lastCompletedStep: QigongCompleteRestorePhase.prepared.name,
        originalMediaDirectoryPresent: backupService.liveMediaDirectory
            .existsSync(),
      );
      await markerStore.write(
        operationDirectory: operationRoot,
        marker: marker,
      );
      await backupService.stageValidatedBackup(
        package: candidatePackage,
        stagedRoot: stagedRoot,
      );
      marker = await _transition(
        operationRoot,
        marker,
        QigongCompleteRestorePhase.candidateStaged,
      );
      try {
        safetyPackage = await backupService.createBackup(
          createdAtUtc: clock().toUtc(),
          operationId: safetyOperationIdGenerator(),
        );
        await backupService.validateBackup(safetyPackage);
      } on QigongBackupException catch (error) {
        if (!allowRawRollbackFallback ||
            !_rawFallbackAllowedCodes.contains(error.code)) {
          rethrow;
        }
        safetyPackage = null;
        rawFallbackUsed = true;
        rawRollbackEvidence = Directory(
          p.join(
            backupService.backupRoot.path,
            '.qigong-raw-rollback-$operationId',
          ),
        );
        if (rawRollbackEvidence.existsSync()) {
          throw const QigongBackupException('raw_rollback_evidence_collision');
        }
        await backupService.requireSafeRestorePath(rawRollbackEvidence.path);
      }
      await lifecycle.enterMaintenance();
      maintenanceEntered = true;
      await lifecycle.close();
      runtimeClosed = true;
      marker = await _transition(
        operationRoot,
        marker,
        QigongCompleteRestorePhase.runtimeClosed,
      );

      liveMutationStarted = true;
      marker = await _transition(
        operationRoot,
        marker,
        QigongCompleteRestorePhase.rollbackInProgress,
      );
      await _captureRollbackPair(rollbackRoot);
      marker = await _transition(
        operationRoot,
        marker,
        QigongCompleteRestorePhase.rollbackCaptured,
      );

      await _renameFile(
        backupService.stagedDatabaseFile(stagedRoot),
        backupService.sourceDatabaseFile.path,
      );
      marker = await _transition(
        operationRoot,
        marker,
        QigongCompleteRestorePhase.databaseReplaced,
      );
      final stagedMedia = Directory(p.join(stagedRoot.path, 'qigong_media'));
      await _renameDirectory(
        stagedMedia,
        backupService.liveMediaDirectory.path,
      );
      marker = await _transition(
        operationRoot,
        marker,
        QigongCompleteRestorePhase.mediaReplaced,
      );

      await lifecycle.reopen();
      runtimeClosed = false;
      marker = await _transition(
        operationRoot,
        marker,
        QigongCompleteRestorePhase.databaseReopened,
      );
      await lifecycle.validateBasicRead();
      await backupService.validateDatabaseMediaPair(
        databaseFile: backupService.sourceDatabaseFile,
        pairRoot: backupService.profileRoot,
      );
      await lifecycle.rehydrate();
      marker = await _transition(
        operationRoot,
        marker,
        QigongCompleteRestorePhase.validated,
      );
      validatedDurable = true;
      if (rawFallbackUsed) {
        await _renameDirectory(rollbackRoot, rawRollbackEvidence!.path);
      } else {
        await _deleteSafeDirectoryIfExists(rollbackRoot);
      }
      await _deleteSafeDirectoryIfExists(stagedRoot);
      marker = await _transition(
        operationRoot,
        marker,
        QigongCompleteRestorePhase.completed,
      );
      await lifecycle.leaveMaintenance();
      maintenanceEntered = false;
      await _deleteSafeDirectoryIfExists(operationRoot);
      return QigongCompleteRestoreResult(
        status: QigongCompleteRestoreStatus.succeeded,
        safetyBackupPackagePath: safetyPackage?.path,
        rawRollbackEvidencePath: rawRollbackEvidence?.path,
      );
    } on Object catch (error) {
      final failureCode = error is QigongBackupException
          ? error.code
          : 'qigong_complete_restore_failed';
      if (validatedDurable) {
        return _finishAfterValidatedFailure(
          lifecycle: lifecycle,
          maintenanceEntered: maintenanceEntered,
          operationRoot: operationRoot,
          safetyPackage: safetyPackage,
          rawRollbackEvidence: rawRollbackEvidence,
        );
      }
      if (!liveMutationStarted) {
        final runtimeRecovered = await _recoverUnmutatedRuntime(
          lifecycle: lifecycle,
          maintenanceEntered: maintenanceEntered,
          runtimeClosed: runtimeClosed,
        );
        if (runtimeRecovered) {
          await _deleteSafeDirectoryIfExists(operationRoot);
          return QigongCompleteRestoreResult(
            status: QigongCompleteRestoreStatus.failedBeforeMutation,
            failureCode: failureCode,
            safetyBackupPackagePath: safetyPackage?.path,
          );
        }
        if (marker != null && operationRoot.existsSync()) {
          await _tryMarkFatal(operationRoot, marker);
        }
        return QigongCompleteRestoreResult(
          status: QigongCompleteRestoreStatus.fatalPreserved,
          failureCode: 'runtime_recovery_failed',
          safetyBackupPackagePath: safetyPackage?.path,
          operationDirectoryPath: operationRoot.path,
        );
      }
      final rolledBack = await _rollback(
        operationRoot: operationRoot,
        rollbackRoot: rollbackRoot,
        marker: marker!,
        lifecycle: lifecycle,
        runtimeClosed: runtimeClosed,
      );
      if (rolledBack) {
        return QigongCompleteRestoreResult(
          status: QigongCompleteRestoreStatus.failedRolledBack,
          failureCode: failureCode,
          safetyBackupPackagePath: safetyPackage?.path,
        );
      }
      return QigongCompleteRestoreResult(
        status: QigongCompleteRestoreStatus.fatalPreserved,
        failureCode: 'restore_rollback_failed',
        safetyBackupPackagePath: safetyPackage?.path,
        operationDirectoryPath: operationRoot.path,
      );
    }
  }

  Future<QigongCompleteRestoreOperationMarker> _transition(
    Directory operationRoot,
    QigongCompleteRestoreOperationMarker marker,
    QigongCompleteRestorePhase phase,
  ) async {
    final next = marker.copyWith(phase: phase, updatedAtUtc: clock().toUtc());
    await markerStore.write(operationDirectory: operationRoot, marker: next);
    return next;
  }

  Future<void> _captureRollbackPair(Directory rollbackRoot) async {
    await rollbackRoot.create(recursive: true);
    await backupService.requireSafeRestorePath(rollbackRoot.path);
    final databaseRoot = await Directory(
      p.join(rollbackRoot.path, 'database'),
    ).create();
    for (final source in _liveDatabaseSet()) {
      final type = FileSystemEntity.typeSync(source.path, followLinks: false);
      if (type == FileSystemEntityType.notFound) continue;
      if (type != FileSystemEntityType.file) {
        throw const QigongBackupException('unsafe_live_database_set');
      }
      await backupService.requireSafeRestorePath(source.path);
      final target = p.join(databaseRoot.path, p.basename(source.path));
      await backupService.requireSafeRestorePath(target);
      await _renameFile(source, target);
    }
    final liveMedia = backupService.liveMediaDirectory;
    final mediaType = FileSystemEntity.typeSync(
      liveMedia.path,
      followLinks: false,
    );
    if (mediaType != FileSystemEntityType.notFound) {
      if (mediaType != FileSystemEntityType.directory) {
        throw const QigongBackupException('unsafe_live_media_directory');
      }
      await backupService.requireSafeRestorePath(liveMedia.path);
      await _renameDirectory(
        liveMedia,
        p.join(rollbackRoot.path, 'qigong_media'),
      );
    }
  }

  List<File> _liveDatabaseSet() => <File>[
    backupService.sourceDatabaseFile,
    for (final suffix in const <String>['-wal', '-shm', '-journal'])
      File('${backupService.sourceDatabaseFile.path}$suffix'),
  ];

  Future<bool> _recoverUnmutatedRuntime({
    required QigongCompleteRestoreRuntimeLifecycle lifecycle,
    required bool maintenanceEntered,
    required bool runtimeClosed,
  }) async {
    try {
      if (runtimeClosed) {
        await lifecycle.reopen();
        await lifecycle.validateBasicRead();
        await lifecycle.rehydrate();
      }
      if (maintenanceEntered) await lifecycle.leaveMaintenance();
      return true;
    } on Object {
      return false;
    }
  }

  Future<QigongCompleteRestoreResult> _finishAfterValidatedFailure({
    required QigongCompleteRestoreRuntimeLifecycle lifecycle,
    required bool maintenanceEntered,
    required Directory operationRoot,
    required Directory? safetyPackage,
    required Directory? rawRollbackEvidence,
  }) async {
    try {
      if (maintenanceEntered) await lifecycle.leaveMaintenance();
      return QigongCompleteRestoreResult(
        status: QigongCompleteRestoreStatus.succeeded,
        failureCode: 'post_validation_cleanup_deferred',
        safetyBackupPackagePath: safetyPackage?.path,
        operationDirectoryPath: operationRoot.path,
        rawRollbackEvidencePath: rawRollbackEvidence?.path,
      );
    } on Object {
      return QigongCompleteRestoreResult(
        status: QigongCompleteRestoreStatus.fatalPreserved,
        failureCode: 'post_validation_maintenance_release_failed',
        safetyBackupPackagePath: safetyPackage?.path,
        operationDirectoryPath: operationRoot.path,
        rawRollbackEvidencePath: rawRollbackEvidence?.path,
      );
    }
  }

  Future<void> _deleteSafeDirectoryIfExists(Directory directory) async {
    final type = FileSystemEntity.typeSync(directory.path, followLinks: false);
    if (type == FileSystemEntityType.notFound) return;
    if (type != FileSystemEntityType.directory) {
      throw const QigongBackupException('unsafe_restore_cleanup_path');
    }
    await backupService.requireSafeRestorePath(directory.path);
    await directory.delete(recursive: true);
  }

  Future<bool> _rollback({
    required Directory operationRoot,
    required Directory rollbackRoot,
    required QigongCompleteRestoreOperationMarker marker,
    required QigongCompleteRestoreRuntimeLifecycle lifecycle,
    required bool runtimeClosed,
  }) async {
    try {
      await _transition(
        operationRoot,
        marker,
        QigongCompleteRestorePhase.rollbackInProgress,
      );
      if (!runtimeClosed) await lifecycle.close();
      await restoreRollbackPair(
        backupService: backupService,
        rollbackRoot: rollbackRoot,
        originalMediaDirectoryPresent: marker.originalMediaDirectoryPresent,
        renameFile: _renameFile,
        renameDirectory: _renameDirectory,
      );
      await lifecycle.reopen();
      await lifecycle.validateBasicRead();
      await lifecycle.rehydrate();
      await lifecycle.leaveMaintenance();
      await _deleteSafeDirectoryIfExists(operationRoot);
      return true;
    } on Object {
      await _tryMarkFatal(operationRoot, marker);
      return false;
    }
  }

  Future<void> _tryMarkFatal(
    Directory operationRoot,
    QigongCompleteRestoreOperationMarker marker,
  ) async {
    try {
      await _transition(
        operationRoot,
        marker,
        QigongCompleteRestorePhase.fatalPreserved,
      );
    } on Object {
      // Existing marker and filesystem evidence remain untouched.
    }
  }
}

Future<void> restoreRollbackPair({
  required QigongCompleteBackupService backupService,
  required Directory rollbackRoot,
  required bool originalMediaDirectoryPresent,
  QigongRestoreFileRename renameFile = _defaultRenameFile,
  QigongRestoreDirectoryRename renameDirectory = _defaultRenameDirectory,
}) async {
  final databaseRoot = Directory(p.join(rollbackRoot.path, 'database'));
  final preservedMain = File(
    p.join(
      databaseRoot.path,
      p.basename(backupService.sourceDatabaseFile.path),
    ),
  );
  if (FileSystemEntity.typeSync(preservedMain.path, followLinks: false) !=
      FileSystemEntityType.file) {
    throw const QigongBackupException('rollback_database_missing');
  }
  for (final live in <File>[
    backupService.sourceDatabaseFile,
    for (final suffix in const <String>['-wal', '-shm', '-journal'])
      File('${backupService.sourceDatabaseFile.path}$suffix'),
  ]) {
    final preserved = File(p.join(databaseRoot.path, p.basename(live.path)));
    final liveType = FileSystemEntity.typeSync(live.path, followLinks: false);
    if (liveType != FileSystemEntityType.notFound) {
      if (liveType != FileSystemEntityType.file) {
        throw const QigongBackupException('unsafe_live_database_set');
      }
      await backupService.requireSafeRestorePath(live.path);
      await live.delete();
    }
    final preservedType = FileSystemEntity.typeSync(
      preserved.path,
      followLinks: false,
    );
    if (preservedType != FileSystemEntityType.notFound) {
      if (preservedType != FileSystemEntityType.file) {
        throw const QigongBackupException('unsafe_rollback_database_set');
      }
      await backupService.requireSafeRestorePath(preserved.path);
      await renameFile(preserved, live.path);
    }
  }
  final liveMedia = backupService.liveMediaDirectory;
  final preservedMedia = Directory(p.join(rollbackRoot.path, 'qigong_media'));
  final preservedMediaType = FileSystemEntity.typeSync(
    preservedMedia.path,
    followLinks: false,
  );
  if (originalMediaDirectoryPresent &&
      preservedMediaType == FileSystemEntityType.notFound) {
    throw const QigongBackupException('rollback_media_missing');
  }
  if (preservedMediaType != FileSystemEntityType.notFound &&
      preservedMediaType != FileSystemEntityType.directory) {
    throw const QigongBackupException('unsafe_rollback_media_directory');
  }
  final liveMediaType = FileSystemEntity.typeSync(
    liveMedia.path,
    followLinks: false,
  );
  if (liveMediaType != FileSystemEntityType.notFound) {
    if (liveMediaType != FileSystemEntityType.directory) {
      throw const QigongBackupException('unsafe_live_media_directory');
    }
    await backupService.requireSafeRestorePath(liveMedia.path);
    await liveMedia.delete(recursive: true);
  }
  if (preservedMediaType != FileSystemEntityType.notFound) {
    await backupService.requireSafeRestorePath(preservedMedia.path);
    await renameDirectory(preservedMedia, liveMedia.path);
  }
}

Future<File> _defaultRenameFile(File source, String targetPath) =>
    source.rename(targetPath);

Future<Directory> _defaultRenameDirectory(
  Directory source,
  String targetPath,
) => source.rename(targetPath);
