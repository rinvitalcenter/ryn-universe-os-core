import 'dart:async';

import '../audit_trail_repository.dart';
import '../repository_context.dart';
import '../repository_result.dart';
import '../redaction_state.dart';

/// In-memory append-only fake for audit trail contract tests.
///
/// This fake never opens a runtime database. It only stores synthetic, redacted
/// audit entries in memory.
final class FakeAuditTrailRepository implements AuditTrailRepository {
  FakeAuditTrailRepository({List<AuditTrailEntry>? seed})
      : _entries = List<AuditTrailEntry>.of(seed ?? const []);

  final List<AuditTrailEntry> _entries;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Future<RepositoryResult<AuditTrailEntry>> appendAuditEvent({
    required AuditTrailEntry event,
    required RepositoryContext context,
  }) async {
    if (event.redactionState == RedactionState.blocked) {
      return RepositoryResult.failure(
        const RepositoryError(
          code: RepositoryErrorCode.sensitiveDataBlocked,
          safeMessage: 'Blocked audit events must not be persisted.',
        ),
      );
    }

    if (_entries.any((entry) => entry.id == event.id)) {
      return RepositoryResult.failure(
        const RepositoryError(
          code: RepositoryErrorCode.conflict,
          safeMessage: 'Audit event id already exists.',
        ),
      );
    }

    _entries.add(event);
    _changes.add(null);
    return RepositoryResult.success(event);
  }

  @override
  Future<RepositoryResult<AuditTrailEntry?>> readAuditById(String id) async {
    for (final entry in _entries) {
      if (entry.id == id) {
        return RepositoryResult.success(entry);
      }
    }
    return RepositoryResult.success(null);
  }

  @override
  Stream<RepositoryResult<List<AuditTrailEntry>>> watchAuditForTarget({
    required String targetType,
    String? targetId,
  }) async* {
    yield RepositoryResult.success(_forTarget(targetType, targetId));
    await for (final _ in _changes.stream) {
      yield RepositoryResult.success(_forTarget(targetType, targetId));
    }
  }

  @override
  Future<RepositoryResult<List<AuditTrailEntry>>> listRecentAudit({
    int limit = 50,
  }) async {
    final sorted = List<AuditTrailEntry>.of(_entries)
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return RepositoryResult.success(sorted.take(limit).toList(growable: false));
  }

  Future<void> close() => _changes.close();

  List<AuditTrailEntry> _forTarget(String targetType, String? targetId) {
    return _entries
        .where(
          (entry) =>
              entry.targetType == targetType &&
              (targetId == null || entry.targetId == targetId),
        )
        .toList(growable: false);
  }
}
