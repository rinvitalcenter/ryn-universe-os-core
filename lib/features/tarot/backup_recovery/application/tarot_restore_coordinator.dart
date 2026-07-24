import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../../../../../core/backup_recovery/sha256_digest_service.dart';
import '../../../../../core/persistence/app_database.dart';
import '../domain/tarot_backup_manifest.dart';
import '../domain/tarot_restore_candidate.dart';
import '../domain/tarot_restore_operation_marker.dart';
import '../domain/tarot_restore_operation_result.dart';
import '../infrastructure/tarot_backup_database_inspector.dart';
import '../infrastructure/tarot_backup_package_store.dart';
import '../infrastructure/tarot_backup_path_contract.dart';
import '../infrastructure/tarot_restore_candidate_validator.dart';
import 'tarot_backup_snapshot_coordinator.dart';

typedef TarotSafetyBackupCreator =
    Future<VerifiedTarotBackupPackage> Function(
      String sourceDatabasePath,
      ResolvedBackupRecoveryPaths resolvedPaths,
      TarotBackupSourceProfileEvidence sourceProfileEvidence,
      String applicationVersion,
    );
typedef TarotRestoreFileCopy = Future<void> Function(File source, File target);
typedef TarotRestoreFileRename =
    Future<void> Function(File source, String targetPath);

abstract interface class TarotRestoreRuntimeLifecycle {
  Future<void> close();

  Future<void> reopen();

  Future<void> validateBasicRead();
}

final class TarotRestoreCoordinator {
  TarotRestoreCoordinator({
    required this.candidateValidator,
    required this.backupCoordinator,
    this.databaseInspector = const TarotBackupDatabaseInspector(),
    this.digestService = const DartSha256DigestService(),
    this.markerStore = const TarotRestoreOperationMarkerStore(),
    this.createSafetyBackup,
    TarotRestoreFileCopy? copyFile,
    TarotRestoreFileRename? renameFile,
  }) : _copyFile = copyFile ?? _copyFileFlushed,
       _renameFile = renameFile ?? _rename;

  final TarotRestoreCandidateValidator candidateValidator;
  final TarotBackupSnapshotCoordinator backupCoordinator;
  final TarotBackupDatabaseInspector databaseInspector;
  final Sha256DigestService digestService;
  final TarotRestoreOperationMarkerStore markerStore;
  final TarotSafetyBackupCreator? createSafetyBackup;
  final TarotRestoreFileCopy _copyFile;
  final TarotRestoreFileRename _renameFile;

  Future<TarotRestoreOperationResult> restore({
    required String candidatePackagePath,
    required String liveDatabasePath,
    required ResolvedBackupRecoveryPaths resolvedPaths,
    required TarotBackupSourceProfileEvidence sourceProfileEvidence,
    required String applicationVersion,
    required String operationId,
    required TarotRestoreRuntimeLifecycle lifecycle,
  }) async {
    if (!RegExp(r'^[0-9a-f]{8}$').hasMatch(operationId)) {
      return const TarotRestoreOperationResult.failedBeforeMutation(
        failureCode: 'operation_id_invalid',
      );
    }

    late final TarotRestoreCandidate candidate;
    try {
      candidate = await candidateValidator.validate(candidatePackagePath);
      resolvedPaths.validateSourceDatabasePath(liveDatabasePath);
    } on Object {
      return const TarotRestoreOperationResult.failedBeforeMutation(
        failureCode: 'candidate_invalid',
      );
    }

    late final VerifiedTarotBackupPackage safetyPackage;
    try {
      safetyPackage = await _safetyBackup(
        liveDatabasePath,
        resolvedPaths,
        sourceProfileEvidence,
        applicationVersion,
      );
      if (!safetyPackage.finalReadbackVerified ||
          !safetyPackage.finalDirectory.existsSync()) {
        throw StateError('safety package not verified');
      }
    } on Object {
      return const TarotRestoreOperationResult.failedBeforeMutation(
        failureCode: 'safety_backup_failed',
      );
    }
    final safetyPath = safetyPackage.finalDirectory.absolute.path;

    try {
      final freshCandidate = await candidateValidator.validate(
        candidatePackagePath,
      );
      if (!_sameCandidate(candidate, freshCandidate)) {
        throw StateError('candidate changed');
      }
    } on Object {
      return TarotRestoreOperationResult.failedBeforeMutation(
        failureCode: 'candidate_changed',
        safetyBackupPackagePath: safetyPath,
      );
    }

    final liveFile = File(_absolute(liveDatabasePath));
    final parent = liveFile.parent;
    final rollbackDirectory = Directory(
      p.join(parent.path, '.restore-$operationId'),
    );
    final stagingFile = File(
      p.join(
        parent.path,
        '.${p.basename(liveFile.path)}.restore-$operationId.tmp',
      ),
    );
    if (FileSystemEntity.typeSync(rollbackDirectory.path, followLinks: false) !=
            FileSystemEntityType.notFound ||
        FileSystemEntity.typeSync(stagingFile.path, followLinks: false) !=
            FileSystemEntityType.notFound) {
      return TarotRestoreOperationResult.failedBeforeMutation(
        failureCode: 'operation_path_collision',
        safetyBackupPackagePath: safetyPath,
      );
    }

    final legacyCandidate =
        candidate.schemaVersion == TarotBackupManifest.legacySchemaVersion;
    if (legacyCandidate) {
      try {
        await resolvedPaths.requireSafeAncestry(stagingFile.path);
        await _copyFile(File(candidate.snapshotPath), stagingFile);
        await resolvedPaths.requireSafeAncestry(stagingFile.path);
        final stagedSize = await stagingFile.length();
        final stagedHash = await digestService.digestFile(stagingFile);
        if (stagedSize != candidate.snapshotSizeBytes ||
            stagedHash != candidate.snapshotSha256) {
          throw StateError('staged candidate mismatch');
        }
        await _migrateLegacyCandidate(
          sourceSnapshotPath: candidate.snapshotPath,
          stagedFile: stagingFile,
        );
      } on Object {
        try {
          if (stagingFile.existsSync()) await stagingFile.delete();
        } on Object {
          // No live database mutation occurred. Leave evidence fail-closed.
        }
        return TarotRestoreOperationResult.failedBeforeMutation(
          failureCode: 'candidate_migration_failed',
          safetyBackupPackagePath: safetyPath,
        );
      }
    }

    late TarotRestoreOperationMarker marker;
    try {
      await resolvedPaths.requireSafeAncestry(rollbackDirectory.path);
      await rollbackDirectory.create();
      final startedAt = DateTime.now().toUtc();
      marker = TarotRestoreOperationMarker(
        operationId: operationId,
        stage: TarotRestoreMarkerStage.prepared,
        liveDatabasePath: liveFile.absolute.path,
        preservedOriginalDirectory: rollbackDirectory.absolute.path,
        candidatePackagePath: candidate.packagePath,
        safetyBackupPackagePath: safetyPath,
        startedAtUtc: startedAt,
        updatedAtUtc: startedAt,
      );
      await markerStore.write(
        operationDirectory: rollbackDirectory,
        paths: resolvedPaths,
        marker: marker,
      );
    } on Object {
      return TarotRestoreOperationResult.failedBeforeMutation(
        failureCode: 'restore_marker_prepare_failed',
        safetyBackupPackagePath: safetyPath,
      );
    }

    try {
      await lifecycle.close();
    } on Object {
      return TarotRestoreOperationResult.failedBeforeMutation(
        failureCode: 'runtime_close_failed',
        safetyBackupPackagePath: safetyPath,
      );
    }

    final preserved = <_PreservedFile>[];
    var candidateInstalled = false;
    var reopenAttempted = false;
    var failureCode = 'replacement_failed';
    try {
      await resolvedPaths.requireSafeAncestry(rollbackDirectory.path);
      await _preserveOriginalSet(
        liveFile: liveFile,
        rollbackDirectory: rollbackDirectory,
        resolvedPaths: resolvedPaths,
        preserved: preserved,
      );
      marker = await _transitionMarker(
        marker,
        TarotRestoreMarkerStage.originalPreserved,
        rollbackDirectory,
        resolvedPaths,
      );

      if (!legacyCandidate) {
        await resolvedPaths.requireSafeAncestry(stagingFile.path);
        await _copyFile(File(candidate.snapshotPath), stagingFile);
        await resolvedPaths.requireSafeAncestry(stagingFile.path);
        final stagedSize = await stagingFile.length();
        final stagedHash = await digestService.digestFile(stagingFile);
        if (stagedSize != candidate.snapshotSizeBytes ||
            stagedHash != candidate.snapshotSha256) {
          throw StateError('staged candidate mismatch');
        }
      }
      await _renameFile(stagingFile, liveFile.path);
      candidateInstalled = true;
      marker = await _transitionMarker(
        marker,
        TarotRestoreMarkerStage.candidateInstalled,
        rollbackDirectory,
        resolvedPaths,
      );

      failureCode = 'replacement_reopen_failed';
      reopenAttempted = true;
      await lifecycle.reopen();
      failureCode = 'replacement_validation_failed';
      databaseInspector.inspectVerified(liveFile.path);
      await lifecycle.validateBasicRead();
      marker = await _transitionMarker(
        marker,
        TarotRestoreMarkerStage.replacementVerified,
        rollbackDirectory,
        resolvedPaths,
      );

      return TarotRestoreOperationResult.succeeded(
        safetyBackupPackagePath: safetyPath,
        preservedEvidencePath: rollbackDirectory.absolute.path,
      );
    } on Object {
      return _rollback(
        failureCode: failureCode,
        safetyPackage: safetyPackage,
        liveFile: liveFile,
        stagingFile: stagingFile,
        rollbackDirectory: rollbackDirectory,
        preserved: preserved,
        resolvedPaths: resolvedPaths,
        lifecycle: lifecycle,
        closeReplacementRuntime: candidateInstalled || reopenAttempted,
        marker: marker,
      );
    }
  }

  Future<VerifiedTarotBackupPackage> _safetyBackup(
    String liveDatabasePath,
    ResolvedBackupRecoveryPaths resolvedPaths,
    TarotBackupSourceProfileEvidence sourceProfileEvidence,
    String applicationVersion,
  ) {
    final override = createSafetyBackup;
    if (override != null) {
      return override(
        liveDatabasePath,
        resolvedPaths,
        sourceProfileEvidence,
        applicationVersion,
      );
    }
    return backupCoordinator.createVerifiedBackup(
      sourceDatabasePath: liveDatabasePath,
      resolvedPaths: resolvedPaths,
      sourceProfileEvidence: sourceProfileEvidence,
      applicationVersion: applicationVersion,
    );
  }

  Future<void> _migrateLegacyCandidate({
    required String sourceSnapshotPath,
    required File stagedFile,
  }) async {
    final before = databaseInspector.inspectVerified(
      sourceSnapshotPath,
      policy: TarotDatabaseInspectionPolicy.immutableReadOnlyFrozenTarget,
      requireAcceptableSidecars: true,
      acceptedSchemaVersions: const <int>{
        TarotBackupManifest.legacySchemaVersion,
      },
    );
    final database = RynAppDatabase(NativeDatabase(stagedFile));
    try {
      await database.customSelect('SELECT 1').get();
    } finally {
      await database.close();
    }
    final after = databaseInspector.inspectVerified(
      stagedFile.path,
      policy: TarotDatabaseInspectionPolicy.immutableReadOnlyFrozenTarget,
      requireAcceptableSidecars: true,
    );
    for (final table in TarotBackupManifest.requiredTablesV6) {
      if (after.tableRowCounts[table] != before.tableRowCounts[table]) {
        throw StateError('legacy migration changed table rows');
      }
    }
    if ((after.tableRowCounts['person_groups'] ?? -1) != 0 ||
        (after.tableRowCounts['person_group_memberships'] ?? -1) != 0) {
      throw StateError('legacy migration fabricated group rows');
    }
  }

  Future<void> _preserveOriginalSet({
    required File liveFile,
    required Directory rollbackDirectory,
    required ResolvedBackupRecoveryPaths resolvedPaths,
    required List<_PreservedFile> preserved,
  }) async {
    for (final source in <File>[
      liveFile,
      for (final suffix in const <String>['-wal', '-shm', '-journal'])
        File('${liveFile.path}$suffix'),
    ]) {
      final type = FileSystemEntity.typeSync(source.path, followLinks: false);
      if (type == FileSystemEntityType.notFound &&
          source.path != liveFile.path) {
        continue;
      }
      if (type != FileSystemEntityType.file) {
        throw StateError('original database set is unsafe');
      }
      await resolvedPaths.requireSafeAncestry(source.path);
      final preservedFile = File(
        p.join(rollbackDirectory.path, p.basename(source.path)),
      );
      await resolvedPaths.requireSafeAncestry(preservedFile.path);
      await _renameFile(source, preservedFile.path);
      preserved.add(_PreservedFile(original: source, preserved: preservedFile));
    }
  }

  Future<TarotRestoreOperationResult> _rollback({
    required String failureCode,
    required VerifiedTarotBackupPackage safetyPackage,
    required File liveFile,
    required File stagingFile,
    required Directory rollbackDirectory,
    required List<_PreservedFile> preserved,
    required ResolvedBackupRecoveryPaths resolvedPaths,
    required TarotRestoreRuntimeLifecycle lifecycle,
    required bool closeReplacementRuntime,
    required TarotRestoreOperationMarker marker,
  }) async {
    var rollbackFailed = false;
    try {
      marker = await _transitionMarker(
        marker,
        TarotRestoreMarkerStage.rollbackStarted,
        rollbackDirectory,
        resolvedPaths,
      );
    } on Object {
      rollbackFailed = true;
    }
    if (closeReplacementRuntime) {
      try {
        await lifecycle.close();
      } on Object {
        rollbackFailed = true;
      }
    }

    final failedDirectory = Directory(
      p.join(rollbackDirectory.path, 'failed-replacement'),
    );
    try {
      if (!failedDirectory.existsSync()) await failedDirectory.create();
      await _quarantineReplacementSet(
        liveFile: liveFile,
        stagingFile: stagingFile,
        failedDirectory: failedDirectory,
        resolvedPaths: resolvedPaths,
      );
    } on Object {
      rollbackFailed = true;
    }

    for (final item in preserved) {
      try {
        if (!item.preserved.existsSync()) {
          rollbackFailed = true;
          continue;
        }
        if (item.original.existsSync()) {
          rollbackFailed = true;
          continue;
        }
        await resolvedPaths.requireSafeAncestry(item.preserved.path);
        await resolvedPaths.requireSafeAncestry(item.original.path);
        await _renameFile(item.preserved, item.original.path);
      } on Object {
        rollbackFailed = true;
      }
    }

    if (!rollbackFailed &&
        preserved.any(
          (item) =>
              item.original.path == liveFile.path && item.original.existsSync(),
        )) {
      try {
        await lifecycle.reopen();
        final evidence = databaseInspector.inspectVerified(liveFile.path);
        _requireSafetyEvidence(evidence, safetyPackage);
        await lifecycle.validateBasicRead();
        marker = await _transitionMarker(
          marker,
          TarotRestoreMarkerStage.rollbackCompleted,
          rollbackDirectory,
          resolvedPaths,
        );
      } on Object {
        rollbackFailed = true;
      }
    } else {
      rollbackFailed = true;
    }

    final safetyPath = safetyPackage.finalDirectory.absolute.path;
    final evidencePath = rollbackDirectory.absolute.path;
    if (rollbackFailed) {
      try {
        await _transitionMarker(
          marker,
          TarotRestoreMarkerStage.fatalPreserved,
          rollbackDirectory,
          resolvedPaths,
        );
      } on Object {
        // Keep all evidence when even the fatal marker cannot be updated.
      }
      return TarotRestoreOperationResult.fatalRecoveryRequired(
        failureCode: '${failureCode}_rollback_failed',
        safetyBackupPackagePath: safetyPath,
        preservedEvidencePath: evidencePath,
      );
    }
    return TarotRestoreOperationResult.failedRolledBack(
      failureCode: failureCode,
      safetyBackupPackagePath: safetyPath,
      preservedEvidencePath: evidencePath,
    );
  }

  Future<void> _quarantineReplacementSet({
    required File liveFile,
    required File stagingFile,
    required Directory failedDirectory,
    required ResolvedBackupRecoveryPaths resolvedPaths,
  }) async {
    for (final source in <File>[
      liveFile,
      for (final suffix in const <String>['-wal', '-shm', '-journal'])
        File('${liveFile.path}$suffix'),
      stagingFile,
    ]) {
      final type = FileSystemEntity.typeSync(source.path, followLinks: false);
      if (type == FileSystemEntityType.notFound) continue;
      if (type != FileSystemEntityType.file) {
        throw StateError('failed replacement set is unsafe');
      }
      await resolvedPaths.requireSafeAncestry(source.path);
      final target = p.join(failedDirectory.path, p.basename(source.path));
      await resolvedPaths.requireSafeAncestry(target);
      await _renameFile(source, target);
    }
  }

  Future<TarotRestoreOperationMarker> _transitionMarker(
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
}

final class _PreservedFile {
  const _PreservedFile({required this.original, required this.preserved});

  final File original;
  final File preserved;
}

Future<void> _copyFileFlushed(File source, File target) async {
  final input = await source.open();
  final output = await target.open(mode: FileMode.write);
  try {
    while (true) {
      final bytes = await input.read(64 * 1024);
      if (bytes.isEmpty) break;
      await output.writeFrom(bytes);
    }
    await output.flush();
  } finally {
    await input.close();
    await output.close();
  }
}

Future<void> _rename(File source, String targetPath) async {
  await source.rename(targetPath);
}

bool _sameCandidate(TarotRestoreCandidate left, TarotRestoreCandidate right) =>
    left.packagePath == right.packagePath &&
    left.snapshotPath == right.snapshotPath &&
    left.snapshotSha256 == right.snapshotSha256 &&
    left.snapshotSizeBytes == right.snapshotSizeBytes &&
    left.schemaVersion == right.schemaVersion &&
    left.backupFormatVersion == right.backupFormatVersion;

void _requireSafetyEvidence(
  TarotDatabaseEvidence evidence,
  VerifiedTarotBackupPackage safetyPackage,
) {
  final manifest = safetyPackage.manifest;
  if (!_sameMap(evidence.tableRowCounts, manifest.tableRowCounts) ||
      evidence.distinctReadingIdCount != manifest.readingIdCount ||
      evidence.placementCount != manifest.placementCount ||
      evidence.interpretationCount != manifest.interpretationCount ||
      evidence.runtimeStateRowCount != manifest.runtimeStateRowCount ||
      evidence.activeHomeReadingIdPresent !=
          manifest.activeHomeReadingIdPresent ||
      !_sameMap(evidence.lifecycleStateCounts, manifest.lifecycleStateCounts)) {
    throw StateError('restored original differs from safety evidence');
  }
}

bool _sameMap<K, V>(Map<K, V> left, Map<K, V> right) {
  if (left.length != right.length) return false;
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) return false;
  }
  return true;
}

String _absolute(String value) => p.normalize(File(value).absolute.path);
