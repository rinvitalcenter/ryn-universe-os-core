import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/records/data/tarot_record_summary_adapter.dart';
import 'package:ryn_universe_os_core/features/records/domain/record_summary.dart';
import 'package:ryn_universe_os_core/features/tarot/domain/tarot_persistence_models.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_interpretation_session_draft.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_reading_result_snapshot.dart';

void main() {
  test('persisted Tarot maps to a derived read-only summary', () {
    final snapshot = _snapshot();
    final record = PersistedTarotReadingRecord(
      snapshot: snapshot,
      questionDisplayText: '보이는 질문',
      sourceType: TarotReadingOrigin.selfDrawn,
      lifecycle: TarotReadingLifecycle.continuing,
      interpretation: const TarotInterpretationSessionDraft(
        readingInstanceId: 'reading-1',
        coreMessage: '속도를 늦추고 기준을 본다.',
      ),
      readingTimezoneOffsetMinutes: 540,
      createdAt: DateTime.utc(2026, 7, 10),
      updatedAt: DateTime.utc(2026, 7, 13),
      finishedAt: null,
    );

    final projection = const TarotRecordSummaryAdapter().adapt(record);
    final summary = projection.summary;

    expect(
      summary.key,
      const RecordKey(
        moduleType: RecordModuleType.tarot,
        canonicalRecordId: 'reading-1',
      ),
    );
    expect(summary.recordType, RecordType.tarotSelfReading);
    expect(summary.occurredAt, same(snapshot.readingAt));
    expect(summary.updatedAt, record.updatedAt);
    expect(summary.title, '보이는 질문');
    expect(summary.shortSummary, 'RWS · 세 장 · 3장 · 속도를 늦추고 기준을 본다.');
    expect(summary.personId, isNull);
    expect(summary.status, RecordDisplayStatus.continuing);
    expect(summary.capabilities.canPreview, isTrue);
    expect(summary.capabilities.canOpenFullDetail, isTrue);
    expect(summary.capabilities.canShowOnHome, isTrue);
    expect(summary.capabilities.canEdit, isFalse);
    expect(summary.searchTerms, contains('The Hermit'));
    expect(summary.searchTerms, contains('속도를 늦추고 기준을 본다.'));
    expect(projection.snapshot, same(snapshot));
    expect(projection.interpretation, same(record.interpretation));
  });

  test(
    'session fallback derives a summary without creating persistence data',
    () async {
      final snapshot = _snapshot();
      final adapter = TarotRecordSummaryAdapter(
        sessionSnapshotsProvider: () => [snapshot],
        questionDisplayTextFor: (_) => '세션 질문',
        interpretationFor: (_) => const TarotInterpretationSessionDraft(
          readingInstanceId: 'reading-1',
          coreMessage: '세션 핵심',
        ),
      );

      final summaries = await adapter.loadSummaries();

      expect(summaries, hasLength(1));
      expect(summaries.single.title, '세션 질문');
      expect(summaries.single.personId, isNull);
      expect(summaries.single.shortSummary, contains('세션 핵심'));
      expect(summaries.single.capabilities.canEdit, isFalse);
    },
  );

  test(
    'finished lifecycle and manual origin map without mutating snapshot',
    () {
      final snapshot = _snapshot();
      final record = PersistedTarotReadingRecord(
        snapshot: snapshot,
        questionDisplayText: snapshot.readingQuestionText,
        sourceType: TarotReadingOrigin.manuallyRecorded,
        lifecycle: TarotReadingLifecycle.finished,
        interpretation: null,
        readingTimezoneOffsetMinutes: 540,
        createdAt: DateTime.utc(2026, 7, 10),
        updatedAt: DateTime.utc(2026, 7, 14),
        finishedAt: DateTime.utc(2026, 7, 14),
      );

      final projection = const TarotRecordSummaryAdapter().adapt(record);
      final summary = projection.summary;

      expect(summary.recordType, RecordType.tarotManualReading);
      expect(summary.status, RecordDisplayStatus.finished);
      expect(projection.snapshot, same(snapshot));
      expect(summary.personId, isNull);
      expect(summary.capabilities.canEdit, isFalse);
    },
  );
}

TarotReadingResultSnapshot _snapshot() {
  final placements = [
    TarotCardPlacementSnapshot(
      placementOrder: 1,
      cardId: 'major_09',
      cardNameSnapshot: 'The Hermit',
      positionId: 'present',
      positionNameSnapshot: '현재',
      orientation: TarotCardOrientation.upright,
    ),
    TarotCardPlacementSnapshot(
      placementOrder: 2,
      cardId: 'major_02',
      cardNameSnapshot: 'The High Priestess',
      positionId: 'focus',
      positionNameSnapshot: '초점',
      orientation: TarotCardOrientation.reversed,
    ),
    TarotCardPlacementSnapshot(
      placementOrder: 3,
      cardId: 'major_17',
      cardNameSnapshot: 'The Star',
      positionId: 'next',
      positionNameSnapshot: '다음',
      orientation: TarotCardOrientation.upright,
    ),
  ];
  return TarotReadingResultSnapshot.validated(
    readingInstanceId: 'reading-1',
    readingQuestionText: '원래 질문',
    deckId: 'rws_public_domain',
    deckNameSnapshot: 'RWS',
    spreadId: 'three_card',
    spreadNameSnapshot: '세 장',
    readingAt: DateTime(2026, 7, 12, 10),
    placements: placements,
    expectedPlacementCount: placements.length,
    selectedDeckCardIds: placements.map((item) => item.cardId).toSet(),
  );
}
