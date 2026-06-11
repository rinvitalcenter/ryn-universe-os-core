/// Safe repository result wrapper for interface-only repository skeletons.
///
/// Errors must be safe for UI/reporting and must never include raw secrets,
/// private payloads, raw prompts, provider tokens, or unredacted logs.
final class RepositoryResult<T> {
  const RepositoryResult._({this.value, this.error});

  factory RepositoryResult.success(T value) => RepositoryResult._(value: value);

  factory RepositoryResult.failure(RepositoryError error) =>
      RepositoryResult._(error: error);

  final T? value;
  final RepositoryError? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

enum RepositoryErrorCode {
  validationFailed,
  notFound,
  conflict,
  approvalRequired,
  stopConditionTriggered,
  persistenceUnavailable,
  sensitiveDataBlocked,
  externalActionNotApproved,
}

final class RepositoryError {
  const RepositoryError({
    required this.code,
    required this.safeMessage,
    this.safeDetails = const <String, String>{},
  });

  final RepositoryErrorCode code;
  final String safeMessage;
  final Map<String, String> safeDetails;
}
