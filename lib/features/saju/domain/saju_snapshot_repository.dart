import 'saju_snapshot.dart';

export 'saju_snapshot.dart';

enum SajuRevisionReason {
  initial,
  inputCorrected,
  engineUpdated,
  policyUpdated,
  calculationErrorCorrected,
  birthPlaceProfileChanged,
}

enum SajuSnapshotFailureCode {
  personNotFound,
  birthProfileNotFound,
  birthProfilePersonMismatch,
  duplicateSnapshot,
  revisionConflict,
  invalidSnapshot,
  unsupportedSnapshotVersion,
  persistenceFailure,
}

final class SajuSnapshotFailure {
  const SajuSnapshotFailure(this.code, this.safeMessage);

  final SajuSnapshotFailureCode code;
  final String safeMessage;
}

final class SajuSnapshotResult<T> {
  const SajuSnapshotResult._({this.value, this.failure});

  factory SajuSnapshotResult.success(T value) =>
      SajuSnapshotResult._(value: value);

  factory SajuSnapshotResult.failed(
    SajuSnapshotFailureCode code,
    String safeMessage,
  ) => SajuSnapshotResult._(
    failure: SajuSnapshotFailure(code, safeMessage),
  );

  final T? value;
  final SajuSnapshotFailure? failure;
  bool get isSuccess => failure == null;
}

final class SajuPersistedSnapshot {
  const SajuPersistedSnapshot({
    required this.id,
    required this.personId,
    required this.sourceBirthProfileId,
    required this.chartGroupId,
    required this.revisionNumber,
    required this.revisionReason,
    required this.createdAtUtcUs,
    required this.inputFingerprintSha256,
    required this.calculationSignatureSha256,
    required this.snapshot,
  });

  final String id;
  final String personId;
  final String? sourceBirthProfileId;
  final String chartGroupId;
  final int revisionNumber;
  final SajuRevisionReason revisionReason;
  final int createdAtUtcUs;
  final String inputFingerprintSha256;
  final String calculationSignatureSha256;
  final SajuChartSnapshot snapshot;
}

abstract interface class SajuSnapshotRepository {
  Future<SajuSnapshotResult<SajuPersistedSnapshot>> saveInitialSnapshot({
    required String snapshotId,
    required String personId,
    String? sourceBirthProfileId,
    required String chartGroupId,
    required SajuChartSnapshot snapshot,
    required int createdAtUtcUs,
  });

  Future<SajuSnapshotResult<SajuPersistedSnapshot>> createRevision({
    required String snapshotId,
    required String personId,
    String? sourceBirthProfileId,
    required String chartGroupId,
    required int expectedCurrentRevisionNumber,
    required SajuRevisionReason revisionReason,
    required SajuChartSnapshot snapshot,
    required int createdAtUtcUs,
  });

  Future<SajuSnapshotResult<SajuPersistedSnapshot>> getSnapshotById(String id);

  Future<SajuSnapshotResult<List<SajuPersistedSnapshot>>>
  listSnapshotsForPerson(String personId);

  Stream<List<SajuPersistedSnapshot>> watchSnapshotsForPerson(String personId);

  Future<SajuSnapshotResult<SajuPersistedSnapshot?>>
  getLatestSnapshotForPerson(String personId);
}
