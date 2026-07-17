import '../domain/tarot_backup_manifest.dart';
import '../domain/tarot_backup_operation_state.dart';
import '../infrastructure/tarot_backup_manifest_codec.dart';
import '../infrastructure/tarot_backup_package_store.dart';
import '../infrastructure/tarot_backup_path_contract.dart';
import '../infrastructure/tarot_sqlite_online_backup_service.dart';

typedef TarotBackupClock = DateTime Function();
typedef TarotBackupOperationIdGenerator = String Function();
typedef TarotBackupProgressListener =
    void Function(TarotBackupProgress progress);

final class TarotBackupSnapshotCoordinator {
  TarotBackupSnapshotCoordinator({
    this.onlineBackupService = const TarotSqliteOnlineBackupService(),
    this.packageStore = const TarotBackupPackageStore(),
    TarotBackupClock? clock,
    TarotBackupOperationIdGenerator? operationIdGenerator,
  }) : _clock = clock ?? DateTime.now,
       _operationIdGenerator = operationIdGenerator ?? _unsupportedIdGenerator;

  final TarotSqliteOnlineBackupService onlineBackupService;
  final TarotBackupPackageStore packageStore;
  final TarotBackupClock _clock;
  final TarotBackupOperationIdGenerator _operationIdGenerator;

  Future<VerifiedTarotBackupPackage> createVerifiedBackup({
    required String sourceDatabasePath,
    required ResolvedBackupRecoveryPaths resolvedPaths,
    required TarotBackupSourceProfileEvidence sourceProfileEvidence,
    required String applicationVersion,
    TarotBackupProgressListener? onProgress,
  }) async {
    _emitSafely(onProgress, TarotBackupStage.preparing);
    try {
      sourceProfileEvidence.validate();
      if (!TarotBackupManifestCodec.isValidApplicationVersion(
        applicationVersion,
      )) {
        throw const TarotBackupCoordinatorException(
          'application_version_invalid',
        );
      }
      final createdAt = _clock().toUtc();
      final packagePaths = _allocatePackagePaths(resolvedPaths, createdAt);
      var verifyingEmitted = false;
      final result = await packageStore.createVerifiedPackage(
        paths: resolvedPaths,
        packagePaths: packagePaths,
        snapshotWriter: (payload) async {
          _emitSafely(onProgress, TarotBackupStage.snapshotting);
          final snapshot = await onlineBackupService.createSnapshot(
            sourceDatabasePath: sourceDatabasePath,
            targetDatabasePath: payload.path,
            paths: resolvedPaths,
          );
          _emitSafely(onProgress, TarotBackupStage.verifying);
          verifyingEmitted = true;
          return snapshot.afterSanitation;
        },
        manifestFactory:
            ({
              required evidence,
              required payloadSha256,
              required payloadSizeBytes,
            }) => TarotBackupManifest(
              applicationVersion: applicationVersion,
              sourceRuntimeMode: sourceProfileEvidence.runtimeMode,
              sourceEnvironment: sourceProfileEvidence.environment,
              sourcePurpose: sourceProfileEvidence.purpose,
              createdAtUtc: createdAt,
              databasePayloadSizeBytes: payloadSizeBytes,
              databasePayloadSha256: payloadSha256,
              requiredTables: TarotBackupManifest.requiredTablesV1,
              requiredColumnsByTable:
                  TarotBackupManifest.requiredColumnsByTableV1,
              tableRowCounts: evidence.tableRowCounts,
              readingIdCount: evidence.distinctReadingIdCount,
              placementCount: evidence.placementCount,
              interpretationCount: evidence.interpretationCount,
              runtimeStateRowCount: evidence.runtimeStateRowCount,
              activeHomeReadingIdPresent: evidence.activeHomeReadingIdPresent,
              lifecycleStateCounts: evidence.lifecycleStateCounts,
              unsupportedTableRowsZero: evidence.unsupportedTableRowsZero,
              verifiedAtUtc: _clock().toUtc(),
            ),
      );
      if (!verifyingEmitted || !result.finalReadbackVerified) {
        throw const TarotBackupCoordinatorException(
          'final_verification_missing',
        );
      }
      _emitSafely(onProgress, TarotBackupStage.succeeded);
      return result;
    } on TarotBackupCoordinatorException catch (error) {
      _emitSafely(onProgress, TarotBackupStage.failed, failureCode: error.code);
      rethrow;
    } on Object {
      const error = TarotBackupCoordinatorException('backup_operation_failed');
      _emitSafely(onProgress, TarotBackupStage.failed, failureCode: error.code);
      throw error;
    }
  }

  TarotBackupPackagePaths _allocatePackagePaths(
    ResolvedBackupRecoveryPaths paths,
    DateTime createdAtUtc,
  ) => paths.packagePaths(
    createdAtUtc: createdAtUtc,
    operationId: _operationIdGenerator(),
  );

  void _emitSafely(
    TarotBackupProgressListener? listener,
    TarotBackupStage stage, {
    String? failureCode,
  }) {
    try {
      listener?.call(
        TarotBackupProgress(stage: stage, failureCode: failureCode),
      );
    } on Object {
      // Progress listeners are isolated observers, never operation owners.
    }
  }
}

final class TarotBackupSourceProfileEvidence {
  const TarotBackupSourceProfileEvidence({
    required this.runtimeMode,
    required this.environment,
    required this.purpose,
  });

  const TarotBackupSourceProfileEvidence.syntheticQa()
    : runtimeMode = 'tarot_backup_recovery_qa',
      environment = 'development',
      purpose = 'core_tarot_backup_recovery_v0_2';

  final String runtimeMode;
  final String environment;
  final String purpose;

  void validate() {
    if (runtimeMode != 'tarot_backup_recovery_qa' ||
        environment != 'development' ||
        purpose != 'core_tarot_backup_recovery_v0_2') {
      throw const TarotBackupCoordinatorException('source_profile_invalid');
    }
  }
}

final class TarotBackupCoordinatorException implements Exception {
  const TarotBackupCoordinatorException(this.code);
  final String code;

  @override
  String toString() => 'TarotBackupCoordinatorException($code)';
}

String _unsupportedIdGenerator() => throw const TarotBackupCoordinatorException(
  'operation_id_generator_required',
);
