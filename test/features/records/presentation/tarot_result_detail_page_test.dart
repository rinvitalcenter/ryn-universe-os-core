import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/records/domain/record_summary.dart';
import 'package:ryn_universe_os_core/features/records/presentation/tarot_result_detail_page.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_reading_result_snapshot.dart';

void main() {
  testWidgets(
    'manual detail shows manual identity and linked Person without Home action',
    (tester) async {
      var showOnHomeCalls = 0;

      await _pumpDetail(
        tester,
        recordType: RecordType.tarotManualReading,
        linkedPersonDisplayName: '합성 상담 대상',
        canShowOnHome: false,
        onShowOnHome: () => showOnHomeCalls++,
      );

      expect(find.text('수동 타로 기록'), findsOneWidget);
      expect(find.text('셀프 타로 저널'), findsNothing);
      expect(
        find.byKey(const Key('tarot-detail-linked-person')),
        findsOneWidget,
      );
      expect(find.text('대상 · 합성 상담 대상'), findsOneWidget);
      expect(find.byKey(const Key('detail-show-on-home')), findsNothing);
      expect(find.text('홈에 표시'), findsNothing);
      expect(showOnHomeCalls, 0);
    },
  );

  testWidgets(
    'eligible self detail preserves Home action and invokes it once',
    (tester) async {
      var showOnHomeCalls = 0;

      await _pumpDetail(
        tester,
        recordType: RecordType.tarotSelfReading,
        canShowOnHome: true,
        onShowOnHome: () => showOnHomeCalls++,
      );

      expect(find.text('셀프 타로 저널'), findsOneWidget);
      expect(find.text('수동 타로 기록'), findsNothing);
      expect(find.byKey(const Key('tarot-detail-linked-person')), findsNothing);
      expect(find.byKey(const Key('detail-show-on-home')), findsOneWidget);

      await tester.tap(find.byKey(const Key('detail-show-on-home')));
      await tester.pump();

      expect(showOnHomeCalls, 1);
    },
  );

  testWidgets('manual detail uses neutral Person fallback when lookup misses', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      recordType: RecordType.tarotManualReading,
      canShowOnHome: false,
      onShowOnHome: () {},
    );

    expect(find.text('수동 타로 기록'), findsOneWidget);
    expect(find.text('대상 · 연결된 사람'), findsOneWidget);
    expect(find.byKey(const Key('detail-show-on-home')), findsNothing);
  });
}

Future<void> _pumpDetail(
  WidgetTester tester, {
  required RecordType recordType,
  required bool canShowOnHome,
  required VoidCallback onShowOnHome,
  String? linkedPersonDisplayName,
}) async {
  tester.view.physicalSize = const Size(1440, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TarotResultDetailPage(
          snapshot: _snapshot(),
          recordType: recordType,
          linkedPersonDisplayName: linkedPersonDisplayName,
          canShowOnHome: canShowOnHome,
          isActiveOnHome: false,
          onBack: () {},
          onShowOnHome: onShowOnHome,
          onHideFromHome: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TarotReadingResultSnapshot _snapshot() {
  final placements = [
    TarotCardPlacementSnapshot(
      placementOrder: 1,
      cardId: 'cups_01',
      cardNameSnapshot: 'Ace of Cups',
      positionId: 'one_center',
      positionNameSnapshot: '중심',
      orientation: TarotCardOrientation.upright,
    ),
  ];
  return TarotReadingResultSnapshot.validated(
    readingInstanceId: 'detail-correction-reading',
    readingQuestionText: '합성 상세 질문',
    deckId: 'rws_public_domain',
    deckNameSnapshot: 'RWS Public Domain',
    spreadId: 'one_card',
    spreadNameSnapshot: '1카드',
    readingAt: DateTime(2026, 7, 20, 14, 30),
    placements: placements,
    expectedPlacementCount: placements.length,
    selectedDeckCardIds: placements.map((item) => item.cardId).toSet(),
  );
}
