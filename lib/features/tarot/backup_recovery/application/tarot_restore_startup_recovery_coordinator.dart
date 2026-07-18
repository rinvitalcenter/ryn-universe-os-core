import 'dart:io';

import 'package:path/path.dart' as p;

import '../domain/tarot_restore_operation_marker.dart';
import '../infrastructure/tarot_backup_database_inspector.dart';
import '../infrastructure/tarot_backup_path_contract.dart';
import '../infrastructure/tarot_restore_candidate_validator.dart';
import 'tarot_restore_coordinator.dart';

enum TarotRestoreStartupRecoveryStatus {
  noAction,
  finalizedPrepared,
  originalRecovered,
  replacementKept,
  fatalRecoveryRequired,
}

final class TarotRestoreStartupRecoveryResult {
  const TarotRestoreStartupRecoveryResult({
    required this.status,
    this.failureCode,
    this.evidencePath,
  });

  final TarotRestoreStartupRecoveryStatus status;
  final String? failureCode;
  final String? evidencePath;

  bool get requiresManualRecovery =>
      status == TarotRestoreStartupRecoveryStatus.fatalRecoveryRequired;
}

final class TarotRestoreStartupRecoveryCoordinator {
  TarotRestoreStartupRecoveryCoordinator({
    required this.candidateValidator,
    this.markerStore = const TarotRestoreOperationMarkerStore(),
    this.databaseInspector = const TarotBackupDatabaseInspector(),
    TarotRestoreFileRename? renameFile,
  }) : _renameFile = renameFile ?? _rename;

  final TarotRestoreCandidateValidator candidateValidator;
  final TarotRestoreOperationMarkerStore markerStore;
  final TarotBackupDatabaseInspector databaseInspector;
  final TarotRestoreFileRename _renameFile;

  Future<TarotRestoreStartupRecoveryResult> recoverIfNeeded({
    required String liveDatabasePath,
    required ResolvedBackupRecoveryPaths resolvedPaths,
    required TarotRestoreRuntimeLifecycle lifecycle,
  }) async {
    final liveFile = File(_absolute(liveDatabasePath));
    try {
      resolvedPaths.validateSourceDatabasePath(liveFile.path);
      await resolvedPaths.requireSafeAncestry(liveFile.parent.path);
    } on Object {
      return const TarotRestoreStartupRecoveryResult(
        status: TarotRestoreStartupRecoveryStatus.fatalRecoveryRequired,
        failureCode: 'recovery_path_invalid',
      );
    }

    late final List<Directory> operations;
    try {
      operations = await _operationDirectories(liveFile, resolvedPaths);
    } on Object {
      return const TarotRestoreStartupRecoveryResult(
        status: TarotRestoreStartupRecoveryStatus.fatalRecoveryRequired,
        failureCode: 'recovery_discovery_failed',
      );
    }
    if (operations.isEmpty) {
      return const TarotRestoreStartupRecoveryResult(
        status: TarotRestoreStartupRecoveryStatus.noAction,
      );
    }
    if (operations.length != 1) {
      return TarotRestoreStartupRecoveryResult(
        status: TarotRestoreStartupRecoveryStatus.fatalRecoveryRequired,
        failureCode: 'multiple_restore_markers',
        evidencePath: liveFile.parent.absolute.path,
      );
    }

    final operationDirectory = operations.single;
    late final TarotRestoreOperationMarker marker;
    try {
      marker = await markerStore.read(
        operationDirectory: operationDirectory,
        paths: resolvedPaths,
      );
      _requireMarkerIdentity(marker, operationDirectory, liveFile);
    } on Object {
      return TarotRestoreStartupRecoveryResult(
        status: TarotRestoreStartupRecoveryStatus.fatalRecoveryRequired,
        failureCode: 'restore_marker_invalid',
        evidencePath: operationDirectory.absolute.path,
      );
    }

    if (marker.stage == TarotRestoreMarkerStage.fatalPreserved) {
      return TarotRestoreStartupRecoveryResult(
        status: TarotRestoreStartupRecoveryStatus.fatalRecoveryRequired,
        failureCode: 'fatal_restore_evidence_preserved',
        evidencePath: operationDirectory.absolute.path,
      );
    }

    try {
      await candidateValidator.validate(marker.safetyBackupPackagePath);
    } on Object {
      return TarotRestoreStartupRecoveryResult(
        status: TarotRestoreStartupRecoveryStatus.fatalRecoveryRequired,
        failureCode: 'safety_backup_invalid',
        evidencePath: operationDirectory.absolute.path,
      );
    }

    return switch (marker.stage) {
      TarotRestoreMarkerStage.prepared => _finalizePrepared(
        marker,
        operationDirectory,
        liveFile,
        resolvedPaths,
      ),
      TarotRestoreMarkerStage.originalPreserved ||
      TarotRestoreMarkerStage.candidateInstalled ||
      TarotRestoreMarkerStage.rollbackStarted => _recoverOriginal(
        marker,
        operationDirectory,
        liveFile,
        resolvedPaths,
        lifecycle,
      ),
      TarotRestoreMarkerStage.replacementVerified => _keepReplacement(
        marker,
        operationDirectory,
        liveFile,
        resolvedPaths,
      ),
      TarotRestoreMarkerStage.rollbackCompleted => _finalizeRollback(
        marker,
        operationDirectory,
        liveFile,
        resolvedPaths,
        lifecycle,
      ),
      TarotRestoreMarkerStage.fatalPreserved => throw StateError(
        'handled above',
      ),
    };
  }

  Future<TarotRestoreStartupRecoveryResult> _finalizePrepared(
    TarotRestoreOperationMarker marker,
    Directory operationDirectory,
    File liveFile,
    ResolvedBackupRecoveryPaths paths,
  ) async {
    try {
      await _deleteExternalStaging(liveFile, marker.operationId, paths);
      await _deleteOperationDirectory(operationDirectory, paths);
      return const TarotRestoreStartupRecoveryResult(
        status: TarotRestoreStartupRecoveryStatus.finalizedPrepared,
      );
    } on Object {
      return _fatal(
        marker,
        operationDirectory,
        paths,
        'prepared_cleanup_failed',
      );
    }
  }

  Future<TarotRestoreStartupRecoveryResult> _recoverOriginal(
    TarotRestoreOperationMarker marker,
    Directory operationDirectory,
    File liveFile,
    ResolvedBackupRecoveryPaths paths,
    TarotRestoreRuntimeLifecycle lifecycle,
  ) async {
    try {
      marker = await _transition(
        marker,
        TarotRestoreMarkerStage.rollbackStarted,
        operationDirectory,
        paths,
      );
      if (marker.stage == TarotRestoreMarkerStage.rollbackStarted) {
        await lifecycle.close();
      }
      await _quarantineCurrentSet(
        liveFile,
        operationDirectory,
        marker.operationId,
        paths,
      );
      await _restoreOriginalSet(liveFile, operationDirectory, paths);
      await lifecycle.reopen();
      databaseInspector.inspectVerified(liveFile.path);
      await lifecycle.validateBasicRead();
      marker = await _transition(
        marker,
        TarotRestoreMarkerStage.rollbackCompleted,
        operationDirectory,
        paths,
      );
      await _deleteOperationDirectory(operationDirectory, paths);
      return const TarotRestoreStartupRecoveryResult(
        status: TarotRestoreStartupRecoveryStatus.originalRecovered,
      );
    } on Object {
      return _fatal(
        marker,
        operationDirectory,
        paths,
        'startup_rollback_failed',
      );
    }
  }

  Future<TarotRestoreStartupRecoveryResult> _keepReplacement(
    TarotRestoreOperationMarker marker,
    Directory operationDirectory,
    File liveFile,
    ResolvedBackupRecoveryPaths paths,
  ) async {
    try {
      databaseInspector.inspectVerified(liveFile.path);
      await _deleteExternalStaging(liveFile, marker.operationId, paths);
      await _deleteOperationDirectory(operationDirectory, paths);
      return const TarotRestoreStartupRecoveryResult(
        status: TarotRestoreStartupRecoveryStatus.replacementKept,
      );
    } on Object {
      return _fatal(
        marker,
        operationDirectory,
        paths,
        'replacement_finalize_failed',
      );
    }
  }

  Future<TarotRestoreStartupRecoveryResult> _finalizeRollback(
    TarotRestoreOperationMarker marker,
    Directory operationDirectory,
    File liveFile,
    ResolvedBackupRecoveryPaths paths,
    TarotRestoreRuntimeLifecycle lifecycle,
  ) async {
    try {
      await lifecycle.reopen();
      databaseInspector.inspectVerified(liveFile.path);
      await lifecycle.validateBasicRead();
      await _deleteOperationDirectory(operationDirectory, paths);
      return const TarotRestoreStartupRecoveryResult(
        status: TarotRestoreStartupRecoveryStatus.originalRecovered,
      );
    } on Object {
      return _fatal(
        marker,
        operationDirectory,
        paths,
        'rollback_finalize_failed',
      );
    }
  }

  Future<TarotRestoreStartupRecoveryResult> _fatal(
    TarotRestoreOperationMarker marker,
    Directory operationDirectory,
    ResolvedBackupRecoveryPaths paths,
    String code,
  ) async {
    try {
      await _transition(
        marker,
        TarotRestoreMarkerStage.fatalPreserved,
        operationDirectory,
        paths,
      );
    } on Object {
      // Preserve every artifact when even the marker cannot be updated.
    }
    return TarotRestoreStartupRecoveryResult(
      status: TarotRestoreStartupRecoveryStatus.fatalRecoveryRequired,
      failureCode: code,
      evidencePath: operationDirectory.absolute.path,
    );
  }

  Future<TarotRestoreOperationMarker> _transition(
    TarotRestoreOperationMarker marker,
    TarotRestoreMarkerStage stage,
    Directory operationDirectory,
    ResolvedBackupRecoveryPaths paths,
  ) async {
    final now = DateTime.now().toUtc();
    final updated = now.isBefore(marker.updatedAtUtc)
        ? marker.updatedAtUtc
        : now;
    final next = marker.copyWith(stage: stage, updatedAtUtc: updated);
    await markerStore.write(
      operationDirectory: operationDirectory,
      paths: paths,
      marker: next,
    );
    return next;
  }

  Future<List<Directory>> _operationDirectories(
    File liveFile,
    ResolvedBackupRecoveryPaths paths,
  ) async {
    const prefix = '.restore-';
    final pattern = RegExp(
      '^${RegExp.escape(prefix)}[0-9a-f]{8}'
      r'$',
    );
    final result = <Directory>[];
    await for (final entity in liveFile.parent.list(followLinks: false)) {
      if (entity is! Directory || !pattern.hasMatch(p.basename(entity.path))) {
        continue;
      }
      await paths.requireSafeAncestry(entity.path);
      final marker = File(
        p.join(entity.path, TarotRestoreOperationMarkerStore.filename),
      );
      if (FileSystemEntity.typeSync(marker.path, followLinks: false) ==
          FileSystemEntityType.file) {
        result.add(entity);
      }
    }
    return result;
  }

  void _requireMarkerIdentity(
    TarotRestoreOperationMarker marker,
    Directory operationDirectory,
    File liveFile,
  ) {
    final expectedDirectory = p.join(
      liveFile.parent.path,
      '.restore-${marker.operationId}',
    );
    if (!_same(marker.liveDatabasePath, liveFile.path) ||
        !_same(marker.preservedOriginalDirectory, operationDirectory.path) ||
        !_same(expectedDirectory, operationDirectory.path)) {
      throw StateError('restore marker identity mismatch');
    }
  }

  Future<void> _quarantineCurrentSet(
    File liveFile,
    Directory operationDirectory,
    String operationId,
    ResolvedBackupRecoveryPaths paths,
  ) async {
    final failed = Directory(
      p.join(operationDirectory.path, 'startup-failed-replacement'),
    );
    if (!failed.existsSync()) await failed.create();
    await paths.requireSafeAncestry(failed.path);
    final staging = File(
      p.join(
        liveFile.parent.path,
        '.${p.basename(liveFile.path)}.restore-$operationId.tmp',
      ),
    );
    for (final source in <File>[
      liveFile,
      for (final suffix in const <String>['-wal', '-shm', '-journal'])
        File('${liveFile.path}$suffix'),
      staging,
    ]) {
      final type = FileSystemEntity.typeSync(source.path, followLinks: false);
      if (type == FileSystemEntityType.notFound) continue;
      if (type != FileSystemEntityType.file) {
        throw StateError('unsafe live set');
      }
      await paths.requireSafeAncestry(source.path);
      final target = p.join(failed.path, p.basename(source.path));
      if (FileSystemEntity.typeSync(target, followLinks: false) !=
          FileSystemEntityType.notFound) {
        throw StateError('quarantine collision');
      }
      await paths.requireSafeAncestry(target);
      await _renameFile(source, target);
    }
  }

  Future<void> _restoreOriginalSet(
    File liveFile,
    Directory operationDirectory,
    ResolvedBackupRecoveryPaths paths,
  ) async {
    var restoredMain = false;
    for (final target in <File>[
      liveFile,
      for (final suffix in const <String>['-wal', '-shm', '-journal'])
        File('${liveFile.path}$suffix'),
    ]) {
      final source = File(
        p.join(operationDirectory.path, p.basename(target.path)),
      );
      final type = FileSystemEntity.typeSync(source.path, followLinks: false);
      if (type == FileSystemEntityType.notFound &&
          target.path != liveFile.path) {
        continue;
      }
      if (type != FileSystemEntityType.file || target.existsSync()) {
        throw StateError('preserved original unavailable');
      }
      await paths.requireSafeAncestry(source.path);
      await paths.requireSafeAncestry(target.path);
      await _renameFile(source, target.path);
      if (target.path == liveFile.path) restoredMain = true;
    }
    if (!restoredMain) throw StateError('original main not restored');
  }

  Future<void> _deleteExternalStaging(
    File liveFile,
    String operationId,
    ResolvedBackupRecoveryPaths paths,
  ) async {
    final staging = File(
      p.join(
        liveFile.parent.path,
        '.${p.basename(liveFile.path)}.restore-$operationId.tmp',
      ),
    );
    final type = FileSystemEntity.typeSync(staging.path, followLinks: false);
    if (type == FileSystemEntityType.notFound) return;
    if (type != FileSystemEntityType.file) throw StateError('unsafe staging');
    await paths.requireSafeAncestry(staging.path);
    await staging.delete();
  }

  Future<void> _deleteOperationDirectory(
    Directory directory,
    ResolvedBackupRecoveryPaths paths,
  ) async {
    final entities = await directory.list(followLinks: false).toList();
    for (final entity in entities) {
      await paths.requireSafeAncestry(entity.path);
      final type = FileSystemEntity.typeSync(entity.path, followLinks: false);
      if (type == FileSystemEntityType.file) {
        await File(entity.path).delete();
      } else if (type == FileSystemEntityType.directory) {
        await _deleteOperationDirectory(Directory(entity.path), paths);
      } else {
        throw StateError('unsafe operation residue');
      }
    }
    await paths.requireSafeAncestry(directory.path);
    await directory.delete();
  }
}

Future<void> _rename(File source, String targetPath) async {
  await source.rename(targetPath);
}

String _absolute(String value) => p.normalize(File(value).absolute.path);

bool _same(String left, String right) =>
    p.normalize(File(left).absolute.path).toLowerCase() ==
    p.normalize(File(right).absolute.path).toLowerCase();
