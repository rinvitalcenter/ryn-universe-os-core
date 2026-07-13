import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/formatters/korean_date_time_formatter.dart';
import 'package:ryn_universe_os_core/features/records/models/session_tarot_results.dart';
import 'package:ryn_universe_os_core/features/records/presentation/records_session_page.dart';
import 'package:ryn_universe_os_core/features/records/presentation/tarot_result_detail_page.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_reading_result_snapshot.dart';

void main() {
  group('Session Home Records loop', () {
    test(
      'completion retains one result and activates it without duplicates',
      () {
        final session = SessionTarotResults();
        final original = _snapshot(id: 'reading-1');
        final replacement = _snapshot(id: 'reading-1', question: '교체된 질문');

        session.complete(original);
        session.complete(replacement);

        expect(session.results, hasLength(1));
        expect(session.results.single, same(replacement));
        expect(session.activeResult, same(replacement));
        expect(session.results.single.readingAt, replacement.readingAt);
      },
    );

    test(
      'hiding Home keeps the session result and reactivation restores it',
      () {
        final session = SessionTarotResults()..complete(_snapshot());

        session.hideFromHome();
        expect(session.activeResult, isNull);
        expect(session.results, hasLength(1));

        expect(session.showOnHome('reading-1'), isTrue);
        expect(session.activeResult?.readingInstanceId, 'reading-1');
      },
    );

    test('Korean date formatter includes localized date and period', () {
      final date = DateTime(2026, 7, 11, 11, 17);

      expect(KoreanDateTimeFormatter.compact(date), '7월 11일 · 오전 11:17');
      expect(KoreanDateTimeFormatter.full(date), '2026년 7월 11일 · 오전 11:17');
      expect(
        KoreanDateTimeFormatter.full(date),
        isNot(contains('2026-07-11T')),
      );
    });

    testWidgets(
      'Records renders only actual session result and restores Home',
      (tester) async {
        final snapshot = _snapshot();
        TarotReadingResultSnapshot? shown;
        TarotReadingResultSnapshot? opened;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecordsSessionPage(
                results: [snapshot],
                activeReadingInstanceId: null,
                onOpenDetail: (value) => opened = value,
                onShowOnHome: (value) => shown = value,
                onStartSelfTarot: () {},
              ),
            ),
          ),
        );

        expect(find.text('나의 성장 기록'), findsOneWidget);
        expect(find.text('2026년 7월 11일 · 오전 11:17'), findsOneWidget);
        expect(find.text('샘플 사람 A'), findsNothing);
        expect(find.textContaining('2026-07-11T'), findsNothing);
        expect(find.text('이번 실행에서만 표시'), findsNothing);
        expect(find.text('홈에 표시'), findsOneWidget);

        await tester.tap(find.text('홈에 표시'));
        expect(shown, same(snapshot));
        await tester.tap(find.text('상세 보기'));
        expect(opened, same(snapshot));
      },
    );

    testWidgets('Records empty state starts self Tarot without fake rows', (
      tester,
    ) async {
      var started = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecordsSessionPage(
              results: const [],
              activeReadingInstanceId: null,
              onOpenDetail: (_) {},
              onShowOnHome: (_) {},
              onStartSelfTarot: () => started = true,
            ),
          ),
        ),
      );

      expect(find.text('아직 완료한 리딩이 없습니다'), findsOneWidget);
      expect(find.text('만남 기록'), findsNothing);
      expect(find.text('리딩 기록'), findsNothing);
      await tester.tap(find.text('새 셀프 타로 시작'));
      expect(started, isTrue);
    });

    testWidgets('detail shows all ordered cards and reversed orientation', (
      tester,
    ) async {
      final snapshot = _snapshot();
      var hidden = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotResultDetailPage(
              snapshot: snapshot,
              isActiveOnHome: true,
              onBack: () {},
              onShowOnHome: () {},
              onHideFromHome: () => hidden = true,
            ),
          ),
        ),
      );

      expect(find.text(snapshot.readingQuestionText), findsOneWidget);
      expect(find.text('2026년 7월 11일 · 오전 11:17'), findsOneWidget);
      final detailToggle = find.byKey(
        const Key('tarot-record-card-detail-toggle'),
      );
      await tester.ensureVisible(detailToggle);
      await tester.tap(detailToggle);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('detail-placement-1')), findsOneWidget);
      expect(find.byKey(const Key('detail-placement-2')), findsOneWidget);
      expect(find.byKey(const Key('detail-placement-3')), findsOneWidget);
      expect(find.text('역방향'), findsOneWidget);
      expect(find.textContaining('2026-07-11T'), findsNothing);

      final hideFromHome = find.text('홈에서 닫기');
      await tester.ensureVisible(hideFromHome);
      await tester.tap(hideFromHome);
      expect(hidden, isTrue);
    });

    testWidgets('detail uses neutral fallback for unknown Registry identity', (
      tester,
    ) async {
      final snapshot = _snapshot(deckId: 'unknown-deck', unknownCards: true);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotResultDetailPage(
              snapshot: snapshot,
              isActiveOnHome: false,
              onBack: () {},
              onShowOnHome: () {},
              onHideFromHome: () {},
            ),
          ),
        ),
      );

      final detailToggle = find.byKey(
        const Key('tarot-record-card-detail-toggle'),
      );
      await tester.ensureVisible(detailToggle);
      await tester.tap(detailToggle);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('detail-card-neutral-fallback')),
        findsNWidgets(3),
      );
      expect(find.byType(Image), findsNothing);
      expect(find.text('홈에 표시'), findsOneWidget);
    });
  });
}

TarotReadingResultSnapshot _snapshot({
  String id = 'reading-1',
  String question = '지금 선택의 기준은?',
  String deckId = 'rws_public_domain',
  bool unknownCards = false,
}) {
  final cards = unknownCards
      ? const [
          ('unknown-1', '첫 카드'),
          ('unknown-2', '둘째 카드'),
          ('unknown-3', '셋째 카드'),
        ]
      : const [
          ('ace_of_swords', 'Ace of Swords'),
          ('nine_of_swords', '9 of Swords'),
          ('seven_of_wands', '7 of Wands'),
        ];
  return TarotReadingResultSnapshot.validated(
    readingInstanceId: id,
    readingQuestionText: question,
    deckId: deckId,
    deckNameSnapshot: 'Universal Waite',
    spreadId: 'three-card',
    spreadNameSnapshot: '3카드',
    readingAt: DateTime(2026, 7, 11, 11, 17),
    placements: [
      for (var index = 0; index < cards.length; index++)
        TarotCardPlacementSnapshot(
          placementOrder: index + 1,
          cardId: cards[index].$1,
          cardNameSnapshot: cards[index].$2,
          positionId: 'position-${index + 1}',
          positionNameSnapshot: ['과거', '현재', '미래'][index],
          orientation: index == 1
              ? TarotCardOrientation.reversed
              : TarotCardOrientation.upright,
        ),
    ],
    expectedPlacementCount: cards.length,
    selectedDeckCardIds: cards.map((card) => card.$1).toSet(),
  );
}
