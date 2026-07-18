enum TarotRestoreOperationStatus {
  succeeded,
  failedBeforeMutation,
  failedRolledBack,
  fatalRecoveryRequired,
}

final class TarotRestoreOperationResult {
  const TarotRestoreOperationResult({
    required this.status,
    required this.failureCode,
    required this.safetyBackupPackagePath,
    required this.preservedEvidencePath,
    required this.originalRestored,
  });

  const TarotRestoreOperationResult.succeeded({
    required String safetyBackupPackagePath,
    required String preservedEvidencePath,
  }) : this(
         status: TarotRestoreOperationStatus.succeeded,
         failureCode: null,
         safetyBackupPackagePath: safetyBackupPackagePath,
         preservedEvidencePath: preservedEvidencePath,
         originalRestored: false,
       );

  const TarotRestoreOperationResult.failedBeforeMutation({
    required String failureCode,
    String? safetyBackupPackagePath,
  }) : this(
         status: TarotRestoreOperationStatus.failedBeforeMutation,
         failureCode: failureCode,
         safetyBackupPackagePath: safetyBackupPackagePath,
         preservedEvidencePath: null,
         originalRestored: false,
       );

  const TarotRestoreOperationResult.failedRolledBack({
    required String failureCode,
    required String safetyBackupPackagePath,
    required String preservedEvidencePath,
  }) : this(
         status: TarotRestoreOperationStatus.failedRolledBack,
         failureCode: failureCode,
         safetyBackupPackagePath: safetyBackupPackagePath,
         preservedEvidencePath: preservedEvidencePath,
         originalRestored: true,
       );

  const TarotRestoreOperationResult.fatalRecoveryRequired({
    required String failureCode,
    required String safetyBackupPackagePath,
    required String preservedEvidencePath,
  }) : this(
         status: TarotRestoreOperationStatus.fatalRecoveryRequired,
         failureCode: failureCode,
         safetyBackupPackagePath: safetyBackupPackagePath,
         preservedEvidencePath: preservedEvidencePath,
         originalRestored: false,
       );

  final TarotRestoreOperationStatus status;
  final String? failureCode;
  final String? safetyBackupPackagePath;
  final String? preservedEvidencePath;
  final bool originalRestored;

  bool get isSuccess => status == TarotRestoreOperationStatus.succeeded;
}
