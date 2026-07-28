import '../../tarot/domain/tarot_persistence_models.dart';
import '../../tarot/models/tarot_interpretation_session_draft.dart';
import '../../tarot/models/tarot_reading_result_snapshot.dart';
import '../application/record_summary_adapter.dart';
import '../domain/record_summary.dart';

final class TarotRecordProjection {
  const TarotRecordProjection({
    required this.summary,
    required this.snapshot,
    this.interpretation,
  });

  final RecordSummary summary;
  final TarotReadingResultSnapshot snapshot;
  final TarotInterpretationSessionDraft? interpretation;
}

final class TarotRecordSummaryAdapter implements RecordSummaryAdapter {
  const TarotRecordSummaryAdapter({
    this.recordsProvider,
    this.recordsLoader,
    this.sessionSnapshotsProvider,
    this.questionDisplayTextFor,
    this.interpretationFor,
  });

  final Iterable<PersistedTarotReadingRecord> Function()? recordsProvider;
  final Future<Iterable<PersistedTarotReadingRecord>> Function()? recordsLoader;
  final Iterable<TarotReadingResultSnapshot> Function()?
  sessionSnapshotsProvider;
  final String Function(String readingInstanceId)? questionDisplayTextFor;
  final TarotInterpretationSessionDraft? Function(String readingInstanceId)?
  interpretationFor;

  @override
  RecordModuleType get moduleType => RecordModuleType.tarot;

  @override
  Future<List<RecordSummary>> loadSummaries() async {
    final persisted =
        recordsProvider?.call() ??
        await recordsLoader?.call() ??
        const <PersistedTarotReadingRecord>[];
    final summaries = <RecordSummary>[];
    final persistedIds = <String>{};
    for (final record in persisted) {
      final projection = adapt(record);
      persistedIds.add(projection.summary.key.canonicalRecordId);
      summaries.add(projection.summary);
    }
    for (final snapshot
        in sessionSnapshotsProvider?.call() ??
            const <TarotReadingResultSnapshot>[]) {
      if (persistedIds.contains(snapshot.readingInstanceId)) continue;
      summaries.add(adaptSessionSnapshot(snapshot).summary);
    }
    return List.unmodifiable(summaries);
  }

  TarotRecordProjection adaptSessionSnapshot(
    TarotReadingResultSnapshot snapshot,
  ) {
    final interpretation = interpretationFor?.call(snapshot.readingInstanceId);
    final coreMessage = interpretation?.coreMessage.trim() ?? '';
    final visibleQuestion = questionDisplayTextFor?.call(
      snapshot.readingInstanceId,
    );
    final title = visibleQuestion == null || visibleQuestion.trim().isEmpty
        ? snapshot.readingQuestionText
        : visibleQuestion;
    return TarotRecordProjection(
      summary: RecordSummary(
        key: RecordKey(
          moduleType: RecordModuleType.tarot,
          canonicalRecordId: snapshot.readingInstanceId,
        ),
        moduleType: RecordModuleType.tarot,
        recordType: RecordType.tarotSelfReading,
        occurredAt: snapshot.readingAt,
        updatedAt: snapshot.readingAt,
        title: title,
        shortSummary: [
          snapshot.deckNameSnapshot,
          snapshot.spreadNameSnapshot,
          '${snapshot.placements.length}장',
          if (coreMessage.isNotEmpty) coreMessage,
        ].join(' · '),
        personId: null,
        status: RecordDisplayStatus.continuing,
        capabilities: const RecordCapabilities(
          canPreview: true,
          canOpenFullDetail: true,
          canShowOnHome: true,
          canEdit: false,
        ),
        searchTerms: [
          title,
          snapshot.readingQuestionText,
          snapshot.deckNameSnapshot,
          snapshot.spreadNameSnapshot,
          ...snapshot.placements.map((item) => item.cardNameSnapshot),
          if (coreMessage.isNotEmpty) coreMessage,
        ],
      ),
      snapshot: snapshot,
      interpretation: interpretation,
    );
  }

  TarotRecordProjection adapt(PersistedTarotReadingRecord record) {
    final snapshot = record.snapshot;
    final coreMessage = record.interpretation?.coreMessage.trim() ?? '';
    final parts = <String>[
      snapshot.deckNameSnapshot,
      snapshot.spreadNameSnapshot,
      '${snapshot.placements.length}장',
      if (coreMessage.isNotEmpty) coreMessage,
    ];
    return TarotRecordProjection(
      summary: RecordSummary(
        key: RecordKey(
          moduleType: RecordModuleType.tarot,
          canonicalRecordId: snapshot.readingInstanceId,
        ),
        moduleType: RecordModuleType.tarot,
        recordType: record.sourceType == TarotReadingOrigin.manuallyRecorded
            ? RecordType.tarotManualReading
            : RecordType.tarotSelfReading,
        occurredAt: snapshot.readingAt,
        updatedAt: record.updatedAt,
        title: record.questionDisplayText.trim().isEmpty
            ? snapshot.readingQuestionText
            : record.questionDisplayText,
        shortSummary: parts.join(' · '),
        personId: record.personId,
        status: record.lifecycle == TarotReadingLifecycle.finished
            ? RecordDisplayStatus.finished
            : RecordDisplayStatus.continuing,
        capabilities: const RecordCapabilities(
          canPreview: true,
          canOpenFullDetail: true,
          canShowOnHome: true,
          canEdit: false,
        ),
        searchTerms: [
          record.questionDisplayText,
          snapshot.readingQuestionText,
          snapshot.deckNameSnapshot,
          snapshot.spreadNameSnapshot,
          ...snapshot.placements.map((item) => item.cardNameSnapshot),
          if (coreMessage.isNotEmpty) coreMessage,
        ],
      ),
      snapshot: snapshot,
      interpretation: record.interpretation,
    );
  }
}
