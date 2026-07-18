final class TarotRestoreCandidate {
  const TarotRestoreCandidate({
    required this.packagePath,
    required this.snapshotPath,
    required this.createdAtUtc,
    required this.operationId,
    required this.backupFormatVersion,
    required this.schemaVersion,
    required this.snapshotSha256,
    required this.snapshotSizeBytes,
  });

  final String packagePath;
  final String snapshotPath;
  final DateTime createdAtUtc;
  final String operationId;
  final int backupFormatVersion;
  final int schemaVersion;
  final String snapshotSha256;
  final int snapshotSizeBytes;
}
