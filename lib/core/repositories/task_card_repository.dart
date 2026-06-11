import 'repository_context.dart';
import 'repository_result.dart';

/// Lightweight task card DTO for the approved `task_cards` schema surface.
///
/// Task cards represent intended work only. This DTO is not an Agent Run,
/// Approval Record, Activity Event, QA Evidence Link, or secret container.
final class TaskCardValue {
  const TaskCardValue({
    required this.id,
    required this.title,
    required this.lane,
    required this.status,
    required this.priority,
    required this.riskLevel,
    required this.createdAt,
    this.missionId,
    this.description,
    this.orderKey,
    this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String? missionId;
  final String title;
  final String? description;
  final String lane;
  final String status;
  final String priority;
  final String? orderKey;
  final String riskLevel;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;

  TaskCardValue copyWith({
    String? id,
    String? missionId,
    String? title,
    String? description,
    String? lane,
    String? status,
    String? priority,
    String? orderKey,
    String? riskLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
  }) {
    return TaskCardValue(
      id: id ?? this.id,
      missionId: missionId ?? this.missionId,
      title: title ?? this.title,
      description: description ?? this.description,
      lane: lane ?? this.lane,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      orderKey: orderKey ?? this.orderKey,
      riskLevel: riskLevel ?? this.riskLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }
}

/// Repository contract for task card metadata.
///
/// Implementations must not treat card movement as execution, approval, audit
/// append enforcement, or evidence verification. Those remain separate future
/// repository and transaction boundaries.
abstract interface class TaskCardRepository {
  Future<RepositoryResult<TaskCardValue?>> readTaskCard(String id);

  Stream<RepositoryResult<TaskCardValue?>> watchTaskCard(String id);

  Stream<RepositoryResult<List<TaskCardValue>>> watchTaskCardsForMission({
    String? missionId,
  });

  Future<RepositoryResult<List<TaskCardValue>>> listTaskCardsForMission({
    String? missionId,
  });

  Future<RepositoryResult<List<TaskCardValue>>> listTaskCardsByLane({
    required String lane,
  });

  Future<RepositoryResult<TaskCardValue>> saveTaskCard({
    required TaskCardValue card,
    required RepositoryContext context,
  });

  Future<RepositoryResult<TaskCardValue>> moveTaskCard({
    required String id,
    required String lane,
    String? orderKey,
    required RepositoryContext context,
  });

  Future<RepositoryResult<TaskCardValue>> archiveTaskCard({
    required String id,
    required DateTime archivedAt,
    required RepositoryContext context,
  });
}
