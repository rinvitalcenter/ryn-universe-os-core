import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/people/domain/person_core_models.dart';
import 'package:ryn_universe_os_core/features/tarot/data/tarot_spread_registry.dart';
import 'package:ryn_universe_os_core/features/tarot/manual/application/manual_tarot_reading_controller.dart';
import 'package:ryn_universe_os_core/features/tarot/manual/presentation/manual_tarot_reading_page.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_reading_result_snapshot.dart';

void main() {
  final active = Person(
    id: 'person-active',
    displayName: '합성 활성 사용자',
    status: PersonStatuses.active,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
  final archived = Person(
    id: 'person-archived',
    displayName: '합성 보관 사용자',
    status: PersonStatuses.active,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    archivedAt: DateTime(2026, 7, 1),
  );

  testWidgets('wide workspace keeps context cards and save summary visible', (
    tester,
  ) async {
    await _pumpRecorder(
      tester,
      size: const Size(1600, 1000),
      people: [active, archived],
    );

    expect(find.byKey(const Key('manual-tarot-recorder')), findsOneWidget);
    expect(
      find.byKey(const Key('manual-tarot-wide-workspace')),
      findsOneWidget,
    );
    expect(find.text('수동 타로 기록'), findsWidgets);
    expect(find.text('대상 · 기본 정보'), findsOneWidget);
    expect(find.text('카드 배치'), findsOneWidget);
    expect(find.text('기록 요약 · 저장'), findsOneWidget);
    expect(find.text(active.displayName), findsOneWidget);
    expect(find.text(archived.displayName), findsNothing);
    expect(find.byKey(const Key('manual-save')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'local validation preserves entered question and shows safe Person message',
    (tester) async {
      late ManualTarotReadingController controller;
      await _pumpRecorder(
        tester,
        size: const Size(1366, 768),
        people: [active],
        onController: (value) => controller = value,
      );
      await tester.enterText(
        find.byKey(const Key('manual-question')),
        '실패 뒤에도 유지되는 질문',
      );
      await controller.save();
      await tester.pump();

      expect(find.text('실패 뒤에도 유지되는 질문'), findsWidgets);
      expect(find.textContaining('사람 상태를 확인'), findsWidgets);
      expect(find.textContaining(active.id), findsNothing);
      expect(
        find.byKey(const Key('manual-tarot-intermediate-workspace')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('controller completion and orientation are visible before save', (
    tester,
  ) async {
    late ManualTarotReadingController controller;
    await _pumpRecorder(
      tester,
      size: const Size(1600, 1000),
      people: [active],
      onController: (value) => controller = value,
    );
    controller.selectPerson(active);
    controller.setQuestion('완성된 합성 질문');
    final cards = controller.state.deck.cards;
    for (
      var index = 0;
      index < TarotSpreadRegistry.threeCard.positions.length;
      index++
    ) {
      final position = TarotSpreadRegistry.threeCard.positions[index];
      controller.selectCard(position.id, cards[index]);
      if (index == 1) {
        controller.setOrientation(position.id, TarotCardOrientation.reversed);
      }
    }
    await tester.pump();

    expect(find.byKey(const Key('manual-progress')), findsOneWidget);
    final orientation = tester.widget<SegmentedButton<TarotCardOrientation>>(
      find.byKey(const ValueKey('manual-orientation-three_present')),
    );
    expect(orientation.selected, {TarotCardOrientation.reversed});
    expect(find.text('완성된 합성 질문'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('manual-save')))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('card picker supports keyboard search and canonical replacement', (
    tester,
  ) async {
    late ManualTarotReadingController controller;
    await _pumpRecorder(
      tester,
      size: const Size(1600, 1000),
      people: [active],
      onController: (value) => controller = value,
    );

    await tester.tap(
      find.byKey(const ValueKey('manual-card-picker-three_past')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('manual-card-search')),
      'Fool',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('manual-card-option-major_00')),
    );
    await tester.pumpAndSettle();

    expect(controller.state.entries.first.card?.id, 'major_00');
    expect(find.textContaining('The Fool'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final scale in [1.0, 1.25, 1.5, 2.0]) {
      testWidgets('finite responsive recorder ${mode.name} scale $scale', (
        tester,
      ) async {
        await _pumpRecorder(
          tester,
          size: const Size(1000, 760),
          people: [active],
          themeMode: mode,
          textScale: scale,
        );
        expect(
          find.byKey(const Key('manual-tarot-intermediate-workspace')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('manual-recorder-scroll')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

Future<void> _pumpRecorder(
  WidgetTester tester, {
  required Size size,
  required List<Person> people,
  ThemeMode themeMode = ThemeMode.light,
  double textScale = 1,
  ValueChanged<ManualTarotReadingController>? onController,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final controller = ManualTarotReadingController(
    saveCommand: (_) async => true,
    clock: () => DateTime(2026, 7, 28, 14, 30),
    readingIdFactory: () => 'manual-widget-reading',
  );
  controller.setPeople(people);
  onController?.call(controller);
  addTearDown(controller.dispose);
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
          body: ManualTarotReadingPage(
            controller: controller,
            onClose: () {},
            onSaved: (_) async {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
