import 'repository_context.dart';
import 'repository_result.dart';

/// Lightweight mission DTO for the approved `missions` schema surface.
///
/// This contract mirrors schema metadata only. It does not import Drift generated
/// classes, open a database, store raw secrets, or represent execution attempts.
final class MissionValue {
  const MissionValue({
    required this.id,
    required this.title,
    required this.status,
    required this.mode,
    required this.createdAt,
    this.description,
    this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String status;
  final String mode;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;

  MissionValue copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? mode,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
  }) {
    return MissionValue(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }
}

/// Repository contract for mission metadata.
///
/// Implementations must keep Mission as a high-level work grouping. Agent runs,
/// approvals, activity events, evidence records, and secrets belong to separate
/// future boundaries, not this repository contract.
abstract interface class MissionRepository {
  Future<RepositoryResult<MissionValue?>> readMission(String id);

  Stream<RepositoryResult<MissionValue?>> watchMission(String id);

  Stream<RepositoryResult<List<MissionValue>>> watchActiveMissions();

  Future<RepositoryResult<List<MissionValue>>> listActiveMissions();

  Future<RepositoryResult<MissionValue>> saveMission({
    required MissionValue mission,
    required RepositoryContext context,
  });

  Future<RepositoryResult<MissionValue>> archiveMission({
    required String id,
    required DateTime archivedAt,
    required RepositoryContext context,
  });
}
