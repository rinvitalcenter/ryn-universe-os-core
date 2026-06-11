import 'dart:async';

import '../repository_context.dart';
import '../repository_result.dart';
import '../task_card_repository.dart';

/// In-memory fake for TaskCardRepository contract checks.
///
/// This fake models task card metadata only. It never opens a runtime database,
/// runs SQL, writes files, calls external services, or stores sensitive data.
final class FakeTaskCardRepository implements TaskCardRepository {
  FakeTaskCardRepository({Map<String, TaskCardValue>? seed})
      : _cards = Map<String, TaskCardValue>.of(seed ?? const {});

  final Map<String, TaskCardValue> _cards;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Future<RepositoryResult<TaskCardValue?>> readTaskCard(String id) async {
    return RepositoryResult.success(_cards[id]);
  }

  @override
  Stream<RepositoryResult<TaskCardValue?>> watchTaskCard(String id) async* {
    yield RepositoryResult.success(_cards[id]);
    await for (final _ in _changes.stream) {
      yield RepositoryResult.success(_cards[id]);
    }
  }

  @override
  Stream<RepositoryResult<List<TaskCardValue>>> watchTaskCardsForMission({
    String? missionId,
  }) async* {
    yield RepositoryResult.success(_cardsForMission(missionId));
    await for (final _ in _changes.stream) {
      yield RepositoryResult.success(_cardsForMission(missionId));
    }
  }

  @override
  Future<RepositoryResult<List<TaskCardValue>>> listTaskCardsForMission({
    String? missionId,
  }) async {
    return RepositoryResult.success(_cardsForMission(missionId));
  }

  @override
  Future<RepositoryResult<List<TaskCardValue>>> listTaskCardsByLane({
    required String lane,
  }) async {
    final cards = _cards.values
        .where((card) => card.archivedAt == null && card.lane == lane)
        .toList(growable: false);
    return RepositoryResult.success(cards);
  }

  @override
  Future<RepositoryResult<TaskCardValue>> saveTaskCard({
    required TaskCardValue card,
    required RepositoryContext context,
  }) async {
    final validationError = _validateTaskCard(card);
    if (validationError != null) {
      return RepositoryResult.failure(validationError);
    }

    final saved = card.copyWith(updatedAt: context.occurredAt);
    _cards[saved.id] = saved;
    _changes.add(null);
    return RepositoryResult.success(saved);
  }

  @override
  Future<RepositoryResult<TaskCardValue>> moveTaskCard({
    required String id,
    required String lane,
    String? orderKey,
    required RepositoryContext context,
  }) async {
    final existing = _cards[id];
    if (existing == null) {
      return RepositoryResult.failure(
        const RepositoryError(
          code: RepositoryErrorCode.notFound,
          safeMessage: 'Task card was not found.',
        ),
      );
    }

    if (lane.trim().isEmpty) {
      return RepositoryResult.failure(
        const RepositoryError(
          code: RepositoryErrorCode.validationFailed,
          safeMessage: 'Task card lane is required.',
        ),
      );
    }

    final moved = existing.copyWith(
      lane: lane,
      orderKey: orderKey,
      updatedAt: context.occurredAt,
    );
    _cards[id] = moved;
    _changes.add(null);
    return RepositoryResult.success(moved);
  }

  @override
  Future<RepositoryResult<TaskCardValue>> archiveTaskCard({
    required String id,
    required DateTime archivedAt,
    required RepositoryContext context,
  }) async {
    final existing = _cards[id];
    if (existing == null) {
      return RepositoryResult.failure(
        const RepositoryError(
          code: RepositoryErrorCode.notFound,
          safeMessage: 'Task card was not found.',
        ),
      );
    }

    final archived = existing.copyWith(
      status: 'archived',
      updatedAt: context.occurredAt,
      archivedAt: archivedAt,
    );
    _cards[id] = archived;
    _changes.add(null);
    return RepositoryResult.success(archived);
  }

  Future<void> close() => _changes.close();

  List<TaskCardValue> _cardsForMission(String? missionId) {
    final cards = _cards.values
        .where((card) => card.archivedAt == null && card.missionId == missionId)
        .toList(growable: false);
    return cards;
  }

  RepositoryError? _validateTaskCard(TaskCardValue card) {
    if (card.id.trim().isEmpty || card.title.trim().isEmpty) {
      return const RepositoryError(
        code: RepositoryErrorCode.validationFailed,
        safeMessage: 'Task card id and title are required.',
      );
    }

    if (card.lane.trim().isEmpty ||
        card.status.trim().isEmpty ||
        card.priority.trim().isEmpty ||
        card.riskLevel.trim().isEmpty) {
      return const RepositoryError(
        code: RepositoryErrorCode.validationFailed,
        safeMessage: 'Task card lane, status, priority, and risk level are required.',
      );
    }

    if (_containsSensitiveMarker(card.title) ||
        _containsSensitiveMarker(card.description)) {
      return const RepositoryError(
        code: RepositoryErrorCode.sensitiveDataBlocked,
        safeMessage: 'Task card metadata must not contain sensitive values.',
      );
    }

    return null;
  }

  bool _containsSensitiveMarker(String? value) {
    final lower = value?.toLowerCase();
    if (lower == null) {
      return false;
    }
    return lower.contains('api_key') ||
        lower.contains('secret') ||
        lower.contains('token') ||
        lower.contains('password') ||
        lower.contains('openrouter') ||
        lower.contains('botfather');
  }
}
