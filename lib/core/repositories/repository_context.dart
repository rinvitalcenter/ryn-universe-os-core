/// Safe actor label passed from future Notifiers into repository use cases.
///
/// This object carries labels/aliases only. It must not contain raw credentials,
/// private prompt payloads, or provider/API tokens.
final class SafeActorRef {
  const SafeActorRef({required this.actorType, this.actorId});

  final String actorType;
  final String? actorId;
}

/// Shared repository operation context.
///
/// This is not a persistence implementation. It is a lightweight contract object
/// for future transaction/audit boundaries.
final class RepositoryContext {
  const RepositoryContext({
    required this.actor,
    required this.occurredAt,
    this.reason,
    this.correlationId,
    this.approvalRef,
  });

  final SafeActorRef actor;
  final DateTime occurredAt;
  final String? reason;
  final String? correlationId;
  final String? approvalRef;
}
