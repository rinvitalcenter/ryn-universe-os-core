import '../../../core/repositories/repository_result.dart';
import 'study_operations_models.dart';

abstract interface class StudyOperationsRepository {
  Stream<List<StudySessionSummary>> watchSessions();

  Stream<List<StudyMaterial>> watchMaterials();

  Future<RepositoryResult<StudySessionRecord>> loadSession(String sessionId);

  Future<RepositoryResult<StudySessionRecord>> saveSession(
    StudySessionRecord record,
  );

  Future<RepositoryResult<StudyMaterial>> saveMaterial(StudyMaterial material);
}
