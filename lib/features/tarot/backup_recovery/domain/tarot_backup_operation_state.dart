enum TarotBackupStage { preparing, snapshotting, verifying, succeeded, failed }

final class TarotBackupProgress {
  const TarotBackupProgress({required this.stage, this.failureCode});

  final TarotBackupStage stage;
  final String? failureCode;
}
