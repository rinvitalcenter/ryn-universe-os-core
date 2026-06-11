import 'dart:async';

import '../mission_repository.dart';
import '../repository_context.dart';
import '../repository_result.dart';

/// In-memory fake for MissionRepository contract checks.
///
/// This fake never opens a runtime database, never calls external services, and
/// must be seeded only with synthetic, non-sensitive data.
final class FakeMissionRepository implements MissionRepository {
  FakeMissionRepository({Map<String, MissionValue>? seed})
      : _missions = Map<String, MissionValue>.of(seed ?? const {});

  final Map<String, MissionValue> _missions;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Future<RepositoryResult<MissionValue?>> readMission(String id) async {
    return RepositoryResult.success(_missions[id]);
  }

  @override
  Stream<RepositoryResult<MissionValue?>> watchMission(String id) async* {
    yield RepositoryResult.success(_missions[id]);
    await for (final _ in _changes.stream) {
      yield RepositoryResult.success(_missions[id]);
    }
  }

  @override
  Stream<RepositoryResult<List<MissionValue>>> watchActiveMissions() async* {
    yield RepositoryResult.success(_activeMissions());
    await for (final _ in _changes.stream) {
      yield RepositoryResult.success(_activeMissions());
    }
  }

  @override
  Future<RepositoryResult<List<MissionValue>>> listActiveMissions() async {
    return RepositoryResult.success(_activeMissions());
  }

  @override
  Future<RepositoryResult<MissionValue>> saveMission({
    required MissionValue mission,
    required RepositoryContext context,
  }) async {
    final validationError = _validateMission(mission);
    if (validationError != null) {
      return RepositoryResult.failure(validationError);
    }

    final saved = mission.copyWith(updatedAt: context.occurredAt);
    _missions[saved.id] = saved;
    _changes.add(null);
    return RepositoryResult.success(saved);
  }

  @override
  Future<RepositoryResult<MissionValue>> archiveMission({
    required String id,
    required DateTime archivedAt,
    required RepositoryContext context,
  }) async {
    final existing = _missions[id];
    if (existing == null) {
      return RepositoryResult.failure(
        const RepositoryError(
          code: RepositoryErrorCode.notFound,
          safeMessage: 'Mission was not found.',
        ),
      );
    }

    final archived = existing.copyWith(
      status: 'archived',
      updatedAt: context.occurredAt,
      archivedAt: archivedAt,
    );
    _missions[id] = archived;
    _changes.add(null);
    return RepositoryResult.success(archived);
  }

  Future<void> close() => _changes.close();

  List<MissionValue> _activeMissions() {
    final missions = _missions.values
        .where((mission) => mission.archivedAt == null)
        .toList(growable: false);
    return missions;
  }

  RepositoryError? _validateMission(MissionValue mission) {
    if (mission.id.trim().isEmpty || mission.title.trim().isEmpty) {
      return const RepositoryError(
        code: RepositoryErrorCode.validationFailed,
        safeMessage: 'Mission id and title are required.',
      );
    }

    if (_containsSensitiveMarker(mission.title) ||
        _containsSensitiveMarker(mission.description)) {
      return const RepositoryError(
        code: RepositoryErrorCode.sensitiveDataBlocked,
        safeMessage: 'Mission metadata must not contain sensitive values.',
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
