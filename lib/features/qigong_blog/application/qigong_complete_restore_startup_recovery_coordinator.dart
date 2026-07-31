import 'dart:io';

import 'package:path/path.dart' as p;

import '../domain/qigong_complete_restore_operation_marker.dart';
import '../infrastructure/qigong_complete_backup_service.dart';
import 'qigong_complete_restore_coordinator.dart';

enum QigongCompleteRestoreStartupRecoveryStatus {
  noAction,
  untouchedFinalized,
  originalRecovered,
  replacementKept,
  fatalRecoveryRequired,
}

final class QigongCompleteRestoreStartupRecoveryResult {
  const QigongCompleteRestoreStartupRecoveryResult({
    required this.status,
    this.failureCode,
    this.evidencePath,
  });

  final QigongCompleteRestoreStartupRecoveryStatus status;
  final String? failureCode;
  final String? evidencePath;

  bool get requiresManualRecovery =>
      status ==
      QigongCompleteRestoreStartupRecoveryStatus.fatalRecoveryRequired;
}

final class QigongCompleteRestoreStartupRecoveryCoordinator {
  QigongCompleteRestoreStartupRecoveryCoordinator({
    required this.backupService,
    this.markerStore = const QigongCompleteRestoreOperationMarkerStore(),
  });

  final QigongCompleteBackupService backupService;
  final QigongCompleteRestoreOperationMarkerStore markerStore;

  Future<QigongCompleteRestoreStartupRecoveryResult> recoverIfNeeded() async {
    late final List<Directory> qigongOperations;
    late final List<Directory> databaseOnlyOperations;
    try {
      qigongOperations = await _qigongOperationDirectories();
      databaseOnlyOperations = await _databaseOnlyOperationDirectories();
    } on QigongBackupException catch (error) {
      return QigongCompleteRestoreStartupRecoveryResult(
        status:
            QigongCompleteRestoreStartupRecoveryStatus.fatalRecoveryRequired,
        failureCode: 'recovery_discovery_${error.code}',
      );
    } on FileSystemException {
      return const QigongCompleteRestoreStartupRecoveryResult(
        status:
            QigongCompleteRestoreStartupRecoveryStatus.fatalRecoveryRequired,
        failureCode: 'recovery_discovery_filesystem_failed',
      );
    } on StateError {
      return const QigongCompleteRestoreStartupRecoveryResult(
        status:
            QigongCompleteRestoreStartupRecoveryStatus.fatalRecoveryRequired,
        failureCode: 'recovery_discovery_unsafe_entity',
      );
    } on Object {
      return const QigongCompleteRestoreStartupRecoveryResult(
        status:
            QigongCompleteRestoreStartupRecoveryStatus.fatalRecoveryRequired,
        failureCode: 'recovery_discovery_failed',
      );
    }
    if (qigongOperations.isEmpty) {
      return const QigongCompleteRestoreStartupRecoveryResult(
        status: QigongCompleteRestoreStartupRecoveryStatus.noAction,
      );
    }
    if (qigongOperations.length != 1 || databaseOnlyOperations.isNotEmpty) {
      return QigongCompleteRestoreStartupRecoveryResult(
        status:
            QigongCompleteRestoreStartupRecoveryStatus.fatalRecoveryRequired,
        failureCode: databaseOnlyOperations.isNotEmpty
            ? 'simultaneous_restore_markers'
            : 'multiple_qigong_restore_markers',
        evidencePath: backupService.profileRoot.absolute.path,
      );
    }

    final operationRoot = qigongOperations.single;
    late final QigongCompleteRestoreOperationMarker marker;
    try {
      marker = await markerStore.read(operationDirectory: operationRoot);
      final expected = p.join(
        backupService.profileRoot.path,
        '.qigong-complete-restore-${marker.operationId}',
      );
      if (!_samePath(expected, operationRoot.path)) {
        throw const FormatException('qigong_restore_marker_identity_mismatch');
      }
      await backupService.requireSafeRestorePath(operationRoot.path);
    } on Object {
      return QigongCompleteRestoreStartupRecoveryResult(
        status:
            QigongCompleteRestoreStartupRecoveryStatus.fatalRecoveryRequired,
        failureCode: 'qigong_restore_marker_invalid',
        evidencePath: operationRoot.absolute.path,
      );
    }

    if (marker.phase == QigongCompleteRestorePhase.fatalPreserved) {
      return QigongCompleteRestoreStartupRecoveryResult(
        status:
            QigongCompleteRestoreStartupRecoveryStatus.fatalRecoveryRequired,
        failureCode: 'fatal_restore_evidence_preserved',
        evidencePath: operationRoot.absolute.path,
      );
    }

    return switch (marker.phase) {
      QigongCompleteRestorePhase.prepared ||
      QigongCompleteRestorePhase.candidateStaged ||
      QigongCompleteRestorePhase.runtimeClosed => _finalizeUntouched(
        operationRoot,
        marker,
      ),
      QigongCompleteRestorePhase.rollbackCaptured ||
      QigongCompleteRestorePhase.databaseReplaced ||
      QigongCompleteRestorePhase.mediaReplaced ||
      QigongCompleteRestorePhase.databaseReopened ||
      QigongCompleteRestorePhase.rollbackInProgress => _recoverOriginal(
        operationRoot,
        marker,
      ),
      QigongCompleteRestorePhase.validated ||
      QigongCompleteRestorePhase.completed => _keepReplacement(
        operationRoot,
        marker,
      ),
      QigongCompleteRestorePhase.fatalPreserved => throw StateError(
        'handled above',
      ),
    };
  }

  Future<QigongCompleteRestoreStartupRecoveryResult> _finalizeUntouched(
    Directory operationRoot,
    QigongCompleteRestoreOperationMarker marker,
  ) async {
    try {
      await backupService.validateDatabaseMediaPair(
        databaseFile: backupService.sourceDatabaseFile,
        pairRoot: backupService.profileRoot,
      );
      await _deleteOperationRoot(operationRoot);
      return const QigongCompleteRestoreStartupRecoveryResult(
        status: QigongCompleteRestoreStartupRecoveryStatus.untouchedFinalized,
      );
    } on Object {
      return _fatal(operationRoot, marker, 'untouched_live_pair_invalid');
    }
  }

  Future<QigongCompleteRestoreStartupRecoveryResult> _recoverOriginal(
    Directory operationRoot,
    QigongCompleteRestoreOperationMarker marker,
  ) async {
    try {
      final rollbackRoot = Directory(
        p.join(operationRoot.path, marker.rollbackDirectoryName),
      );
      await restoreRollbackPair(
        backupService: backupService,
        rollbackRoot: rollbackRoot,
        originalMediaDirectoryPresent: marker.originalMediaDirectoryPresent,
      );
      await backupService.validateDatabaseMediaPair(
        databaseFile: backupService.sourceDatabaseFile,
        pairRoot: backupService.profileRoot,
      );
      await _deleteOperationRoot(operationRoot);
      return const QigongCompleteRestoreStartupRecoveryResult(
        status: QigongCompleteRestoreStartupRecoveryStatus.originalRecovered,
      );
    } on Object {
      return _fatal(operationRoot, marker, 'startup_pair_rollback_failed');
    }
  }

  Future<QigongCompleteRestoreStartupRecoveryResult> _keepReplacement(
    Directory operationRoot,
    QigongCompleteRestoreOperationMarker marker,
  ) async {
    try {
      await backupService.validateDatabaseMediaPair(
        databaseFile: backupService.sourceDatabaseFile,
        pairRoot: backupService.profileRoot,
      );
      await _deleteOperationRoot(operationRoot);
      return const QigongCompleteRestoreStartupRecoveryResult(
        status: QigongCompleteRestoreStartupRecoveryStatus.replacementKept,
      );
    } on Object {
      return _fatal(operationRoot, marker, 'replacement_pair_invalid');
    }
  }

  Future<QigongCompleteRestoreStartupRecoveryResult> _fatal(
    Directory operationRoot,
    QigongCompleteRestoreOperationMarker marker,
    String code,
  ) async {
    try {
      final fatal = marker.copyWith(
        phase: QigongCompleteRestorePhase.fatalPreserved,
        updatedAtUtc: DateTime.now().toUtc().isBefore(marker.updatedAtUtc)
            ? marker.updatedAtUtc
            : DateTime.now().toUtc(),
      );
      await markerStore.write(operationDirectory: operationRoot, marker: fatal);
    } on Object {
      // Preserve current marker and all filesystem evidence.
    }
    return QigongCompleteRestoreStartupRecoveryResult(
      status: QigongCompleteRestoreStartupRecoveryStatus.fatalRecoveryRequired,
      failureCode: code,
      evidencePath: operationRoot.absolute.path,
    );
  }

  Future<void> _deleteOperationRoot(Directory operationRoot) async {
    if (FileSystemEntity.typeSync(operationRoot.path, followLinks: false) !=
        FileSystemEntityType.directory) {
      throw StateError('unsafe operation cleanup entity');
    }
    await backupService.requireSafeRestorePath(operationRoot.path);
    await operationRoot.delete(recursive: true);
  }

  Future<List<Directory>> _qigongOperationDirectories() async {
    final root = backupService.profileRoot;
    if (!root.existsSync()) return const <Directory>[];
    final pattern = RegExp(r'^\.qigong-complete-restore-[0-9a-f]{8}$');
    final result = <Directory>[];
    await for (final entity in root.list(followLinks: false)) {
      if (!pattern.hasMatch(p.basename(entity.path))) continue;
      if (entity is! Directory) throw StateError('unsafe operation entity');
      await backupService.requireSafeRestorePath(entity.path);
      final marker = File(
        p.join(entity.path, QigongCompleteRestoreOperationMarkerStore.filename),
      );
      final previous = File('${marker.path}.previous');
      final markerType = FileSystemEntity.typeSync(
        marker.path,
        followLinks: false,
      );
      final previousType = FileSystemEntity.typeSync(
        previous.path,
        followLinks: false,
      );
      if ((markerType != FileSystemEntityType.notFound &&
              markerType != FileSystemEntityType.file) ||
          (previousType != FileSystemEntityType.notFound &&
              previousType != FileSystemEntityType.file)) {
        throw StateError('unsafe marker entity');
      }
      if (markerType == FileSystemEntityType.file ||
          previousType == FileSystemEntityType.file) {
        result.add(entity);
      }
    }
    return result;
  }

  Future<List<Directory>> _databaseOnlyOperationDirectories() async {
    final root = backupService.sourceDatabaseFile.parent;
    if (!root.existsSync()) return const <Directory>[];
    final pattern = RegExp(r'^\.restore-[0-9a-f]{8}$');
    final result = <Directory>[];
    await for (final entity in root.list(followLinks: false)) {
      if (entity is! Directory || !pattern.hasMatch(p.basename(entity.path))) {
        continue;
      }
      final marker = File(p.join(entity.path, 'restore-operation.json'));
      if (FileSystemEntity.typeSync(marker.path, followLinks: false) ==
          FileSystemEntityType.file) {
        result.add(entity);
      }
    }
    return result;
  }
}

bool _samePath(String left, String right) =>
    p.normalize(File(left).absolute.path).toLowerCase() ==
    p.normalize(File(right).absolute.path).toLowerCase();
