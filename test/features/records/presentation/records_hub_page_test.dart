import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/records/application/record_hub_controller.dart';
import 'package:ryn_universe_os_core/features/records/domain/record_summary.dart';
import 'package:ryn_universe_os_core/features/records/presentation/records_hub_page.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_reading_result_snapshot.dart';

void main() {
  testWidgets('Galaxy workspace renders navigation list and selected preview', (
    tester,
  ) async {
    await _pumpHub(tester, size: const Size(1600, 1000));

    expect(find.byKey(const Key('records-hub-three-region')), findsOneWidget);
    expect(find.text('기록 탐색'), findsOneWidget);
    expect(find.text('전체 기록'), findsWidgets);
    expect(find.text('최근 기록'), findsOneWidget);
    expect(find.text('타로'), findsWidgets);
    expect(find.text('날짜별'), findsOneWidget);
    expect(find.byKey(const Key('records-hub-center-scroll')), findsOneWidget);
    expect(find.byKey(const Key('records-hub-preview-scroll')), findsOneWidget);
    expect(find.text('2개의 기록'), findsOneWidget);
    expect(find.text('첫 번째 질문'), findsWidgets);
    expect(
      find.byKey(const Key('records-hub-selected-preview')),
      findsOneWidget,
    );
    expect(find.text('전체 기록 열기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search and status filters compose and clear', (tester) async {
    await _pumpHub(tester, size: const Size(1600, 1000));

    await tester.enterText(
      find.byKey(const Key('records-hub-search-field')),
      '없는 검색어',
    );
    await tester.pump();
    expect(find.text('조건에 맞는 기록이 없습니다'), findsOneWidget);
    expect(find.text('필터 지우기'), findsWidgets);

    await tester.tap(find.text('필터 지우기').last);
    await tester.pump();
    expect(find.text('2개의 기록'), findsOneWidget);
    expect(find.text('조건에 맞는 기록이 없습니다'), findsNothing);
  });

  testWidgets('intermediate workspace uses two regions and explicit detail', (
    tester,
  ) async {
    await _pumpHub(tester, size: const Size(1000, 850));

    expect(find.byKey(const Key('records-hub-two-region')), findsOneWidget);
    expect(find.byKey(const Key('records-hub-selected-preview')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('record-row-reading-2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('records-hub-detail-mode')), findsOneWidget);
    expect(find.text('목록으로'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'narrow fallback uses explicit modes without horizontal overflow',
    (tester) async {
      await _pumpHub(tester, size: const Size(680, 820));

      expect(find.byKey(const Key('records-hub-compact')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('record-row-reading-2')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('records-hub-detail-mode')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    for (final scale in [1.0, 1.25, 1.5, 2.0]) {
      testWidgets(
        'Hub remains finite at text scale $scale in ${themeMode.name}',
        (tester) async {
          await _pumpHub(
            tester,
            size: const Size(1600, 1000),
            themeMode: themeMode,
            textScale: scale,
          );
          expect(
            find.byKey(const Key('records-hub-three-region')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('true empty state offers self Tarot without fake modules', (
    tester,
  ) async {
    var started = false;
    await _pumpHub(
      tester,
      size: const Size(1600, 1000),
      summaries: const [],
      snapshots: const {},
      onStartSelfTarot: () => started = true,
    );

    expect(find.text('아직 남긴 기록이 없습니다'), findsOneWidget);
    expect(find.text('첫 리딩이나 수련 기록을 남기면 이곳에서 다시 살펴볼 수 있어요.'), findsOneWidget);
    expect(find.text('사주'), findsNothing);
    expect(find.text('수련'), findsNothing);
    expect(find.text('스터디'), findsNothing);
    await tester.tap(find.text('셀프 타로 시작'));
    expect(started, isTrue);
  });
}

Future<void> _pumpHub(
  WidgetTester tester, {
  required Size size,
  ThemeMode themeMode = ThemeMode.light,
  double textScale = 1,
  List<RecordSummary>? summaries,
  Map<String, TarotReadingResultSnapshot>? snapshots,
  VoidCallback? onStartSelfTarot,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final fixtureSnapshots =
      snapshots ??
      {
        'reading-1': _snapshot('reading-1', '첫 번째 질문', DateTime(2026, 7, 12)),
        'reading-2': _snapshot('reading-2', '두 번째 질문', DateTime(2026, 7, 11)),
      };
  final controller = RecordHubController();
  controller.replaceSummaries(
    summaries ??
        fixtureSnapshots.values
            .map(
              (snapshot) => RecordSummary(
                key: RecordKey(
                  moduleType: RecordModuleType.tarot,
                  canonicalRecordId: snapshot.readingInstanceId,
                ),
                moduleType: RecordModuleType.tarot,
                recordType: RecordType.tarotSelfReading,
                occurredAt: snapshot.readingAt,
                updatedAt: snapshot.readingAt,
                title: snapshot.readingQuestionText,
                shortSummary: 'RWS · 3카드 · 3장',
                status: snapshot.readingInstanceId == 'reading-2'
                    ? RecordDisplayStatus.finished
                    : RecordDisplayStatus.continuing,
                capabilities: const RecordCapabilities(
                  canPreview: true,
                  canOpenFullDetail: true,
                  canShowOnHome: true,
                ),
                searchTerms: const ['RWS', 'The Hermit'],
              ),
            )
            .toList(),
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: RecordsHubPage(
            controller: controller,
            snapshotFor: (key) => fixtureSnapshots[key.canonicalRecordId],
            interpretationFor: (_) => null,
            activeReadingInstanceId: null,
            onOpenFullDetail: (_) {},
            onShowOnHome: (_) {},
            onStartSelfTarot: onStartSelfTarot ?? () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TarotReadingResultSnapshot _snapshot(
  String id,
  String question,
  DateTime date,
) {
  final placements = List.generate(
    3,
    (index) => TarotCardPlacementSnapshot(
      placementOrder: index + 1,
      cardId: 'major_0$index',
      cardNameSnapshot: ['The Fool', 'The Magician', 'The Hermit'][index],
      positionId: 'position-${index + 1}',
      positionNameSnapshot: '위치 ${index + 1}',
      orientation: index == 1
          ? TarotCardOrientation.reversed
          : TarotCardOrientation.upright,
    ),
  );
  return TarotReadingResultSnapshot.validated(
    readingInstanceId: id,
    readingQuestionText: question,
    deckId: 'rws_public_domain',
    deckNameSnapshot: 'RWS',
    spreadId: 'three_card',
    spreadNameSnapshot: '3카드',
    readingAt: date,
    placements: placements,
    expectedPlacementCount: placements.length,
    selectedDeckCardIds: placements.map((item) => item.cardId).toSet(),
  );
}
