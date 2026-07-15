import '../models/tarot_interpretation_session_draft.dart';
import '../models/tarot_reading_result_snapshot.dart';

enum TarotReadingOrigin { selfDrawn, manuallyRecorded }

enum TarotReadingLifecycle { continuing, finished }

final class CompletedTarotReadingPersistenceInput {
  CompletedTarotReadingPersistenceInput({
    required this.snapshot,
    required this.sourceType,
    required this.readingTimezoneOffsetMinutes,
    this.interpretation,
  }) {
    if (readingTimezoneOffsetMinutes < -840 ||
        readingTimezoneOffsetMinutes > 840) {
      throw ArgumentError.value(
        readingTimezoneOffsetMinutes,
        'readingTimezoneOffsetMinutes',
        'must be between -840 and 840',
      );
    }
    final draft = interpretation;
    if (draft != null &&
        draft.readingInstanceId.trim() != snapshot.readingInstanceId) {
      throw ArgumentError.value(
        draft.readingInstanceId,
        'interpretation.readingInstanceId',
        'must match snapshot.readingInstanceId',
      );
    }
  }

  final TarotReadingResultSnapshot snapshot;
  final TarotReadingOrigin sourceType;
  final int readingTimezoneOffsetMinutes;
  final TarotInterpretationSessionDraft? interpretation;
}

final class PersistedTarotReadingRecord {
  const PersistedTarotReadingRecord({
    required this.snapshot,
    required this.questionDisplayText,
    required this.sourceType,
    required this.lifecycle,
    required this.interpretation,
    required this.readingTimezoneOffsetMinutes,
    required this.createdAt,
    required this.updatedAt,
    required this.finishedAt,
  });

  final TarotReadingResultSnapshot snapshot;
  final String questionDisplayText;
  final TarotReadingOrigin sourceType;
  final TarotReadingLifecycle lifecycle;
  final TarotInterpretationSessionDraft? interpretation;
  final int readingTimezoneOffsetMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? finishedAt;
}

final class TarotInterpretationUpdate {
  TarotInterpretationUpdate({
    required String readingInstanceId,
    this.wholeImageObservation,
    this.flowInterpretation,
    this.coreMessage,
    this.smallAction,
  }) : readingInstanceId = _requiredText(
         readingInstanceId,
         'readingInstanceId',
       );

  final String readingInstanceId;
  final String? wholeImageObservation;
  final String? flowInterpretation;
  final String? coreMessage;
  final String? smallAction;
}

String _requiredText(String value, String fieldName) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(value, fieldName, 'must not be empty');
  }
  return normalized;
}
