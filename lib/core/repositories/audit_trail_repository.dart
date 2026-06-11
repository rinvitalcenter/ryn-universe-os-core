import 'repository_context.dart';
import 'repository_result.dart';
import 'redaction_state.dart';

/// Append-only audit event contract DTO for the approved `audit_trail` schema.
///
/// `redactedSnapshot`, `beforeHash`, and `afterHash` must be derived only from
/// canonical redacted metadata. Raw secrets must never be stored or hashed.
final class AuditTrailEntry {
  const AuditTrailEntry({
    required this.id,
    required this.occurredAt,
    required this.actorType,
    required this.action,
    required this.targetType,
    required this.redactionState,
    required this.createdAt,
    this.actorId,
    this.targetId,
    this.beforeHash,
    this.afterHash,
    this.redactedSnapshot,
    this.reason,
    this.correlationId,
  });

  final String id;
  final DateTime occurredAt;
  final String actorType;
  final String? actorId;
  final String action;
  final String targetType;
  final String? targetId;
  final String? beforeHash;
  final String? afterHash;
  final String? redactedSnapshot;
  final RedactionState redactionState;
  final String? reason;
  final String? correlationId;
  final DateTime createdAt;
}

/// Repository contract for append-only audit events.
///
/// Normal implementations must not expose update/delete audit operations.
abstract interface class AuditTrailRepository {
  Future<RepositoryResult<AuditTrailEntry>> appendAuditEvent({
    required AuditTrailEntry event,
    required RepositoryContext context,
  });

  Future<RepositoryResult<AuditTrailEntry?>> readAuditById(String id);

  Stream<RepositoryResult<List<AuditTrailEntry>>> watchAuditForTarget({
    required String targetType,
    String? targetId,
  });

  Future<RepositoryResult<List<AuditTrailEntry>>> listRecentAudit({
    int limit = 50,
  });
}
