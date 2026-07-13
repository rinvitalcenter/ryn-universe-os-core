import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/records/presentation/records_session_page.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_reading_result_snapshot.dart';

void main() {
  testWidgets('index preview represents every ordered placement by scale', (
    tester,
  ) async {
    for (final count in [1, 3, 5, 7]) {
      final snapshot = _snapshot(count: count);
      await _pumpIndex(tester, snapshot: snapshot);

      expect(
        find.byKey(const Key('tarot-record-index-preview')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          Key(
            count == 1
                ? 'tarot-record-index-preview-one'
                : count <= 5
                ? 'tarot-record-index-preview-linear'
                : 'tarot-record-index-preview-multi',
          ),
        ),
        findsOneWidget,
      );
      for (var order = 1; order <= count; order++) {
        expect(
          find.byKey(Key('tarot-record-index-preview-placement-$order')),
          findsOneWidget,
        );
      }
      expect(
        find.byKey(Key('tarot-record-index-preview-placement-${count + 1}')),
        findsNothing,
      );
    }
  });

  testWidgets('Celtic preview preserves cross and right-side staff', (
    tester,
  ) async {
    final snapshot = _snapshot(count: 10, celtic: true);
    await _pumpIndex(tester, snapshot: snapshot);

    expect(
      find.byKey(const Key('tarot-record-index-preview-complex')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('tarot-record-index-preview-celtic-cross')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('tarot-record-index-preview-celtic-staff')),
      findsOneWidget,
    );
    for (var order = 1; order <= 10; order++) {
      expect(
        find.byKey(Key('tarot-record-index-preview-placement-$order')),
        findsOneWidget,
      );
    }
    expect(find.text('켈틱 크로스 · 10장'), findsWidgets);
  });

  testWidgets('preview preserves reversed orientation and neutral fallback', (
    tester,
  ) async {
    await _pumpIndex(tester, snapshot: _snapshot(count: 5));

    expect(
      find.byKey(const Key('records-card-reversed-rotation')),
      findsOneWidget,
    );
    final semantics = tester.getSemantics(
      find.byKey(const Key('tarot-record-index-preview-placement-2')),
    );
    expect(semantics.label, contains('역방향'));

    await _pumpIndex(tester, snapshot: _snapshot(count: 5, unknownCards: true));
    expect(
      find.byKey(const Key('records-card-neutral-fallback')),
      findsNWidgets(5),
    );
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('record narrative and actions remain primary and functional', (
    tester,
  ) async {
    final snapshot = _snapshot(count: 5);
    TarotReadingResultSnapshot? opened;
    TarotReadingResultSnapshot? shown;
    await _pumpIndex(
      tester,
      snapshot: snapshot,
      activeReadingInstanceId: snapshot.readingInstanceId,
      onOpenDetail: (value) => opened = value,
      onShowOnHome: (value) => shown = value,
    );

    expect(find.text(snapshot.readingQuestionText), findsOneWidget);
    expect(find.text('Universal Waite · 5카드 · 5장'), findsOneWidget);
    expect(find.text('현재 홈에 표시 중'), findsOneWidget);
    expect(find.text('홈에 표시'), findsNothing);
    await tester.tap(find.text('상세 보기'));
    expect(opened, same(snapshot));
    expect(shown, isNull);
  });

  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    for (final size in [
      const Size(1440, 900),
      const Size(1280, 800),
      const Size(680, 900),
    ]) {
      testWidgets(
        'complex preview has no overflow at ${size.width} in ${themeMode.name}',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          addTearDown(tester.view.reset);

          await _pumpIndex(
            tester,
            snapshot: _snapshot(count: 10, celtic: true),
            themeMode: themeMode,
          );

          expect(tester.takeException(), isNull);
          for (var order = 1; order <= 10; order++) {
            expect(
              find.byKey(Key('tarot-record-index-preview-placement-$order')),
              findsOneWidget,
            );
          }
        },
      );
    }
  }
}

Future<void> _pumpIndex(
  WidgetTester tester, {
  required TarotReadingResultSnapshot snapshot,
  ThemeMode themeMode = ThemeMode.light,
  String? activeReadingInstanceId,
  ValueChanged<TarotReadingResultSnapshot>? onOpenDetail,
  ValueChanged<TarotReadingResultSnapshot>? onShowOnHome,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: Scaffold(
        body: RecordsSessionPage(
          results: [snapshot],
          activeReadingInstanceId: activeReadingInstanceId,
          onOpenDetail: onOpenDetail ?? (_) {},
          onShowOnHome: onShowOnHome ?? (_) {},
          onStartSelfTarot: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TarotReadingResultSnapshot _snapshot({
  required int count,
  bool celtic = false,
  bool unknownCards = false,
}) {
  const knownCards = [
    ('major_00', 'The Fool'),
    ('major_01', 'The Magician'),
    ('major_02', 'The High Priestess'),
    ('major_03', 'The Empress'),
    ('major_04', 'The Emperor'),
    ('major_05', 'The Hierophant'),
    ('major_06', 'The Lovers'),
    ('major_07', 'The Chariot'),
    ('major_08', 'Strength'),
    ('major_09', 'The Hermit'),
  ];
  final cards = [
    for (var index = 0; index < count; index++)
      unknownCards
          ? ('unknown-${index + 1}', '미확인 카드 ${index + 1}')
          : knownCards[index],
  ];
  return TarotReadingResultSnapshot.validated(
    readingInstanceId: 'index-preview-$count-${celtic ? 'celtic' : 'regular'}',
    readingQuestionText: '지금 선택의 흐름은?',
    deckId: unknownCards ? 'unknown-deck' : 'rws_public_domain',
    deckNameSnapshot: 'Universal Waite',
    spreadId: celtic ? 'celtic_cross' : '$count-card',
    spreadNameSnapshot: celtic ? '켈틱 크로스' : '$count카드',
    readingAt: DateTime(2026, 7, 12, 10, 30),
    placements: [
      for (var index = 0; index < cards.length; index++)
        TarotCardPlacementSnapshot(
          placementOrder: index + 1,
          cardId: cards[index].$1,
          cardNameSnapshot: cards[index].$2,
          positionId: 'position-${index + 1}',
          positionNameSnapshot: '위치 ${index + 1}',
          orientation: index == 1
              ? TarotCardOrientation.reversed
              : TarotCardOrientation.upright,
        ),
    ],
    expectedPlacementCount: count,
    selectedDeckCardIds: cards.map((card) => card.$1).toSet(),
  );
}
