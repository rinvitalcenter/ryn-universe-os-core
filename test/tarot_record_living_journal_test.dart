import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/records/presentation/tarot_result_detail_page.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_interpretation_session_draft.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_reading_result_snapshot.dart';

TarotReadingResultSnapshot snapshot({
  String id = 'reading-a',
  String spreadId = 'three_card',
  String spreadName = '세 장 리딩',
  int count = 3,
  String deckId = 'rws_public_domain',
  bool reversed = false,
}) {
  final placements = List.generate(count, (index) {
    final names = count == 10
        ? ['현재', '교차', '위', '아래', '과거', '미래', '내면', '주변', '희망', '결과']
        : List.generate(count, (i) => '${i + 1}번째 자리');
    return TarotCardPlacementSnapshot(
      placementOrder: index + 1,
      cardId: 'major_${index.toString().padLeft(2, '0')}',
      cardNameSnapshot: '카드 ${index + 1}',
      positionId: 'position-${index + 1}',
      positionNameSnapshot: names[index],
      orientation: reversed && index == 0
          ? TarotCardOrientation.reversed
          : TarotCardOrientation.upright,
    );
  });
  return TarotReadingResultSnapshot.validated(
    readingInstanceId: id,
    readingQuestionText: '이 선택에서 무엇을 먼저 보아야 할까요?',
    deckId: deckId,
    deckNameSnapshot: 'RWS 퍼블릭 도메인',
    spreadId: spreadId,
    spreadNameSnapshot: spreadName,
    readingAt: DateTime(2026, 7, 11, 20, 16),
    placements: placements,
    expectedPlacementCount: count,
    selectedDeckCardIds: placements.map((item) => item.cardId).toSet(),
  );
}

Future<void> pumpDetail(
  WidgetTester tester, {
  required TarotReadingResultSnapshot result,
  TarotInterpretationSessionDraft? draft,
  ThemeMode themeMode = ThemeMode.light,
  Size size = const Size(1440, 1000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: Scaffold(
        body: TarotResultDetailPage(
          snapshot: result,
          interpretationDraft: draft,
          isActiveOnHome: false,
          onBack: () {},
          onShowOnHome: () {},
          onHideFromHome: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> expandCardDetails(WidgetTester tester) async {
  final toggle = find.byKey(const Key('tarot-record-card-detail-toggle'));
  await tester.ensureVisible(toggle);
  await tester.tap(toggle);
  await tester.pumpAndSettle();
}

void main() {
  test('interpretation remains outside immutable result snapshot', () {
    final source = File(
      'lib/features/tarot/models/tarot_reading_result_snapshot.dart',
    ).readAsStringSync();
    expect(source.contains('TarotInterpretationSessionDraft'), isFalse);
    expect(source.contains('wholeImageObservation'), isFalse);
    expect(source.contains('flowInterpretation'), isFalse);
    expect(source.contains('coreMessage'), isFalse);
    expect(source.contains('smallAction'), isFalse);
  });

  testWidgets('result without a draft keeps a valid empty journal', (
    tester,
  ) async {
    await pumpDetail(tester, result: snapshot());

    expect(find.text('이번 리딩에서 작성한 해석이 없습니다.'), findsOneWidget);
    expect(find.byKey(const Key('tarot-record-spread-scene')), findsOneWidget);
    expect(find.text('카드별 상세 · 3장'), findsOneWidget);
    expect(find.text('전체 카드 · 3장'), findsNothing);
    expect(find.text('각 카드의 이름, 위치, 방향을 개별적으로 확인합니다.'), findsOneWidget);
    expect(
      find.byKey(const Key('tarot-record-card-detail-panel')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('tarot-record-card-detail-item-1')),
      findsNothing,
    );
    final toggle = tester.widget<TextButton>(
      find.descendant(
        of: find.byKey(const Key('tarot-record-card-detail-toggle')),
        matching: find.byType(TextButton),
      ),
    );
    expect(toggle.onPressed, isNotNull);
    final semantics = tester.getSemantics(
      find.byKey(const Key('tarot-record-card-detail-toggle')),
    );
    expect(semantics.label, contains('접힘'));
  });

  testWidgets(
    'card detail expands in order and collapses without a second scene',
    (tester) async {
      for (final count in [1, 3, 5, 10]) {
        final result = snapshot(
          spreadId: count == 10 ? 'celtic_cross' : 'spread-$count',
          spreadName: count == 10 ? '켈틱 크로스' : '$count장 리딩',
          count: count,
        );
        await pumpDetail(tester, result: result);
        await expandCardDetails(tester);

        expect(
          find.byKey(const Key('tarot-record-card-detail-panel')),
          findsOneWidget,
        );
        expect(
          tester
              .getSemantics(
                find.byKey(const Key('tarot-record-card-detail-toggle')),
              )
              .label,
          contains('펼침'),
        );
        for (var order = 1; order <= count; order++) {
          expect(
            find.byKey(Key('tarot-record-card-detail-item-$order')),
            findsOneWidget,
          );
          expect(find.byKey(Key('detail-placement-$order')), findsOneWidget);
          expect(find.text('$order · 카드 $order'), findsOneWidget);
          expect(
            find.text(result.placements[order - 1].positionNameSnapshot),
            findsWidgets,
          );
        }
        expect(
          find.descendant(
            of: find.byKey(const Key('tarot-record-card-detail-panel')),
            matching: find.byKey(const Key('tarot-record-celtic-cross')),
          ),
          findsNothing,
        );

        await tester.ensureVisible(
          find.byKey(const Key('tarot-record-card-detail-toggle')),
        );
        await tester.tap(
          find.byKey(const Key('tarot-record-card-detail-toggle')),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('tarot-record-card-detail-item-1')),
          findsNothing,
        );
      }
    },
  );

  testWidgets('card detail toggle expands and collapses from the keyboard', (
    tester,
  ) async {
    await pumpDetail(tester, result: snapshot());
    final button = find.descendant(
      of: find.byKey(const Key('tarot-record-card-detail-toggle')),
      matching: find.byType(TextButton),
    );
    final focusNode = tester.widget<TextButton>(button).focusNode!;
    focusNode.requestFocus();
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tarot-record-card-detail-panel')),
      findsOneWidget,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tarot-record-card-detail-panel')),
      findsNothing,
    );
  });

  testWidgets('selected result renders only matching interpretation draft', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      result: snapshot(),
      draft: const TarotInterpretationSessionDraft(
        readingInstanceId: 'reading-b',
        wholeImageObservation: '다른 리딩의 문장',
      ),
    );

    expect(find.text('다른 리딩의 문장'), findsNothing);
    expect(find.text('이번 리딩에서 작성한 해석이 없습니다.'), findsOneWidget);
  });

  testWidgets('partial draft shows only actual entered journal sections', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      result: snapshot(),
      draft: const TarotInterpretationSessionDraft(
        readingInstanceId: 'reading-a',
        wholeImageObservation: '첫 장면\n두 번째 줄',
        coreMessage: '지금은 속도를 늦춘다.',
      ),
    );

    expect(find.text('전체 이미지 관찰'), findsOneWidget);
    expect(find.text('첫 장면\n두 번째 줄'), findsOneWidget);
    expect(find.text('핵심 메시지'), findsOneWidget);
    expect(find.text('지금은 속도를 늦춘다.'), findsOneWidget);
    expect(find.text('흐름 해석'), findsNothing);
    expect(find.text('오늘의 조언 / 작은 실천'), findsNothing);
    expect(find.text('작성한 해석은 현재 앱 실행 동안 이어집니다.'), findsOneWidget);
  });

  testWidgets('all four real interpretation fields render read only', (
    tester,
  ) async {
    const values = ['장면 기록', '흐름 기록', '핵심 기록', '작은 행동 기록'];
    await pumpDetail(
      tester,
      result: snapshot(),
      draft: const TarotInterpretationSessionDraft(
        readingInstanceId: 'reading-a',
        wholeImageObservation: '장면 기록',
        flowInterpretation: '흐름 기록',
        coreMessage: '핵심 기록',
        smallAction: '작은 행동 기록',
      ),
    );

    for (final value in values) {
      expect(find.text(value), findsOneWidget);
    }
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets(
    'one and three card scenes preserve intentional placement order',
    (tester) async {
      await pumpDetail(
        tester,
        result: snapshot(spreadId: 'one_card', spreadName: '한 장 리딩', count: 1),
      );
      expect(
        find.byKey(const Key('tarot-record-spread-scene')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-record-scene-placement-1')),
        findsOneWidget,
      );

      await pumpDetail(tester, result: snapshot());
      final rects = List.generate(
        3,
        (index) => tester.getRect(
          find.byKey(Key('tarot-record-scene-placement-${index + 1}')),
        ),
      );
      expect(rects[0].left, lessThan(rects[1].left));
      expect(rects[1].left, lessThan(rects[2].left));
    },
  );

  testWidgets(
    'Celtic Cross keeps cross and right-side staff spatial identity',
    (tester) async {
      await pumpDetail(
        tester,
        result: snapshot(
          spreadId: 'celtic_cross',
          spreadName: '켈틱 크로스',
          count: 10,
        ),
      );

      expect(
        find.byKey(const Key('tarot-record-celtic-cross')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-record-celtic-staff')),
        findsOneWidget,
      );
      final center = tester.getCenter(
        find.byKey(const Key('tarot-record-scene-placement-1')),
      );
      final crossing = tester.getCenter(
        find.byKey(const Key('tarot-record-scene-placement-2')),
      );
      expect((center - crossing).distance, lessThan(45));
      final staffX = List.generate(
        4,
        (index) => tester
            .getCenter(
              find.byKey(Key('tarot-record-scene-placement-${index + 7}')),
            )
            .dx,
      );
      expect(staffX.toSet().length, 1);
    },
  );

  testWidgets('reversed card has visual rotation and textual orientation', (
    tester,
  ) async {
    await pumpDetail(tester, result: snapshot(reversed: true));
    await expandCardDetails(tester);

    expect(find.text('역방향'), findsWidgets);
    expect(
      find.byKey(const Key('records-card-reversed-rotation')),
      findsWidgets,
    );
  });

  testWidgets(
    'Registry failure remains neutral and full list keeps every card',
    (tester) async {
      final result = snapshot(deckId: 'missing-deck');
      await pumpDetail(tester, result: result);
      await expandCardDetails(tester);

      expect(
        find.byKey(const Key('detail-card-neutral-fallback')),
        findsWidgets,
      );
      expect(
        find.byKey(const Key('tarot-record-card-detail-panel')),
        findsOneWidget,
      );
      for (var order = 1; order <= result.placements.length; order++) {
        expect(find.byKey(Key('detail-placement-$order')), findsOneWidget);
      }
      expect(find.text('카드별 상세 · 3장'), findsOneWidget);
      expect(find.textContaining('2026년 7월 11일'), findsOneWidget);
    },
  );

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Living Journal has no overflow at 1280px in ${mode.name}', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        result: snapshot(
          spreadId: 'celtic_cross',
          spreadName: '켈틱 크로스',
          count: 10,
        ),
        draft: const TarotInterpretationSessionDraft(
          readingInstanceId: 'reading-a',
          flowInterpretation: '리딩의 흐름을 기록한 실제 문장입니다.',
        ),
        themeMode: mode,
        size: const Size(1280, 800),
      );
      await expandCardDetails(tester);

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const Key('tarot-record-interpretation-journal')),
        findsOneWidget,
      );
    });
  }
}
