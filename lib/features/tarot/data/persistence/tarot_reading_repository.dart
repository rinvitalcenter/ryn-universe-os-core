import '../../../../core/repositories/repository_result.dart';
import '../../domain/tarot_persistence_models.dart';

abstract interface class TarotReadingRepository {
  Future<RepositoryResult<PersistedTarotReadingRecord>> createCompletedReading(
    CompletedTarotReadingPersistenceInput input,
  );

  Future<RepositoryResult<PersistedTarotReadingRecord>> getReadingById(
    String readingInstanceId,
  );

  Future<RepositoryResult<List<PersistedTarotReadingRecord>>> loadAllReadings();

  Future<RepositoryResult<PersistedTarotReadingRecord>> saveInterpretation(
    TarotInterpretationUpdate update,
  );

  /// Meaning-preserving wording is an Owner/UI policy. This repository enforces
  /// only non-empty text and preserves the immutable original question.
  Future<RepositoryResult<PersistedTarotReadingRecord>> updateDisplayQuestion(
    String readingInstanceId,
    String questionDisplayText,
  );

  Future<RepositoryResult<String?>> getActiveHomeReadingId();

  Future<RepositoryResult<bool>> hideActiveHomeReading();

  Future<RepositoryResult<bool>> activateHomeReading(String readingInstanceId);

  Future<RepositoryResult<PersistedTarotReadingRecord>> finishReading(
    String readingInstanceId,
  );

  Future<RepositoryResult<PersistedTarotReadingRecord>>
  reactivateAndFeatureReading(String readingInstanceId);
}
