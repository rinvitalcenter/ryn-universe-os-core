import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/people/domain/person_core_models.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_reading_context.dart';
import 'package:ryn_universe_os_core/features/tarot/tarot_person_entry_selector.dart';
import 'package:ryn_universe_os_core/features/tarot/tarot_spread_shell.dart';
import 'package:ryn_universe_os_core/main.dart' as app;

void main() {
  const options = <TarotPersonOption>[
    TarotPersonOption(
      personId: 'person-synthetic-ara',
      displayName: '김아라',
      relationshipSummary: '함께 공부하는 사람',
    ),
    TarotPersonOption(
      personId: 'person-synthetic-bora',
      displayName: '윤보라',
      relationshipSummary: '오래된 친구',
    ),
  ];

  test('main projection exposes active People only', () {
    final now = DateTime.utc(2026, 7, 26);
    final projected = app.projectActivePeopleForTarot(<Person>[
      Person(
        id: 'person-active',
        displayName: '활성 사람',
        status: PersonStatuses.active,
        createdAt: now,
        updatedAt: now,
      ),
      Person(
        id: 'person-archived',
        displayName: '보관된 사람',
        status: PersonStatuses.active,
        archivedAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    ]);

    expect(projected.map((option) => option.personId), <String>[
      'person-active',
    ]);
  });

  testWidgets('shows all target modes and keeps self and practice valid', (
    tester,
  ) async {
    final contexts = <TarotReadingContext>[];
    await _pumpShell(tester, options: options, contexts: contexts);

    expect(find.text('나를 위한 리딩'), findsOneWidget);
    expect(find.text('사람을 위한 리딩'), findsOneWidget);
    expect(find.text('연습 리딩'), findsOneWidget);
    expect(contexts.single.mode, TarotReadingMode.self);
    expect(contexts.single.personId, isNull);

    await tester.tap(find.byKey(const Key('tarot-target-mode-practice')));
    await tester.pumpAndSettle();

    expect(contexts.last.mode, TarotReadingMode.practice);
    expect(contexts.last.personId, isNull);
  });

  testWidgets('searches and selects one Person by canonical ID only', (
    tester,
  ) async {
    final contexts = <TarotReadingContext>[];
    await _pumpShell(tester, options: options, contexts: contexts);

    await tester.tap(find.byKey(const Key('tarot-target-mode-person')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tarot-person-picker')), findsOneWidget);
    expect(contexts.last.personId, isNull);

    await tester.enterText(find.byKey(const Key('tarot-person-search')), '보라');
    await tester.pumpAndSettle();

    expect(find.text('윤보라'), findsOneWidget);
    expect(find.text('김아라'), findsNothing);

    await tester.tap(
      find.byKey(const Key('tarot-person-option-person-synthetic-bora')),
    );
    await tester.pumpAndSettle();

    expect(contexts.last.mode, TarotReadingMode.person);
    expect(contexts.last.personId, 'person-synthetic-bora');
    expect(contexts.last.toString(), isNot(contains('윤보라')));
    expect(contexts.last.toString(), isNot(contains('오래된 친구')));
    expect(find.text('윤보라'), findsOneWidget);
    expect(find.text('오래된 친구'), findsOneWidget);
    expect(find.text('사람 변경'), findsOneWidget);
  });

  testWidgets(
    'cancel preserves valid context and explicit exits clear Person',
    (tester) async {
      final contexts = <TarotReadingContext>[];
      await _pumpShell(tester, options: options, contexts: contexts);

      await tester.tap(find.byKey(const Key('tarot-target-mode-person')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tarot-person-picker-cancel')));
      await tester.pumpAndSettle();

      expect(contexts.last.mode, TarotReadingMode.self);
      expect(contexts.last.personId, isNull);
      expect(find.text('리딩 전에 사람을 선택해 주세요.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('tarot-person-select-action')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('tarot-person-option-person-synthetic-ara')),
      );
      await tester.pumpAndSettle();
      expect(contexts.last.personId, 'person-synthetic-ara');

      await tester.tap(find.byKey(const Key('tarot-target-mode-self')));
      await tester.pumpAndSettle();
      expect(contexts.last.mode, TarotReadingMode.self);
      expect(contexts.last.personId, isNull);

      await tester.tap(find.byKey(const Key('tarot-target-mode-person')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('tarot-person-option-person-synthetic-bora')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tarot-target-mode-practice')));
      await tester.pumpAndSettle();
      expect(contexts.last.mode, TarotReadingMode.practice);
      expect(contexts.last.personId, isNull);
    },
  );

  testWidgets('target changes preserve question deck and spread selections', (
    tester,
  ) async {
    final contexts = <TarotReadingContext>[];
    await _pumpShell(tester, options: options, contexts: contexts);

    await tester.enterText(
      find.byKey(const Key('tarot-free-question-input')),
      '지금 지켜볼 흐름은 무엇일까요?',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tarot-rail-change-deck')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey('tarot-deck-carousel-card-golden_art_nouveau_tarot'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '1카드'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('tarot-preparation-progress-step-0')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tarot-target-mode-person')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('tarot-person-option-person-synthetic-ara')),
    );
    await tester.pumpAndSettle();

    final question = tester.widget<TextFormField>(
      find.byKey(const Key('tarot-free-question-input')),
    );
    expect(question.initialValue, '지금 지켜볼 흐름은 무엇일까요?');

    await tester.tap(find.byKey(const Key('tarot-rail-change-deck')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('tarot-coverflow-hero-card')),
        matching: find.byKey(const Key('tarot-selected-card-edge-glow')),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    final oneCard = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, '1카드'),
    );
    expect(oneCard.selected, isTrue);
  });

  testWidgets(
    'Person and question continue through Ritual Selection and Revelation chrome',
    (tester) async {
      final contexts = <TarotReadingContext>[];
      await _pumpShell(tester, options: options, contexts: contexts);

      await tester.enterText(
        find.byKey(const Key('tarot-free-question-input')),
        '지금 함께 바라볼 흐름은 무엇일까요?',
      );
      await tester.tap(find.byKey(const Key('tarot-target-mode-person')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('tarot-person-option-person-synthetic-ara')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tarot-rail-primary-cta')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('tarot-r2-reading-stage-chrome')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tarot-r2-stage-ritual')), findsOneWidget);
      expect(find.text('리딩 대상 · 김아라 · 함께 공부하는 사람'), findsOneWidget);
      expect(find.text('지금 함께 바라볼 흐름은 무엇일까요?'), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-r2-reading-metadata')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('tarot-shuffle-button')));
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tarot-r2-stage-selection')), findsOneWidget);
      expect(find.text('리딩 대상 · 김아라 · 함께 공부하는 사람'), findsOneWidget);
      expect(find.text('지금 함께 바라볼 흐름은 무엇일까요?'), findsOneWidget);
      final resultButton = tester.widget<FilledButton>(
        find.byKey(const Key('tarot-show-result-button')),
      );
      expect(resultButton.onPressed, isNull);

      await tester.tap(find.byKey(const Key('tarot-auto-draw-button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('tarot-r2-stage-revelation')),
        findsOneWidget,
      );
      expect(find.text('리딩 대상 · 김아라 · 함께 공부하는 사람'), findsOneWidget);
      expect(find.text('지금 함께 바라볼 흐름은 무엇일까요?'), findsOneWidget);
      expect(find.text('해석 시작'), findsOneWidget);
      expect(contexts.last.personId, 'person-synthetic-ara');
      expect(contexts.last.toString(), isNot(contains('김아라')));
    },
  );

  testWidgets('empty picker is truthful and unselected Person is fail-closed', (
    tester,
  ) async {
    final contexts = <TarotReadingContext>[];
    await _pumpShell(tester, options: const [], contexts: contexts);

    await tester.tap(find.byKey(const Key('tarot-target-mode-person')));
    await tester.pumpAndSettle();

    expect(find.text('등록된 사람이 없습니다.'), findsOneWidget);
    expect(find.text('사람 모듈에서 먼저 사람을 추가해 주세요.'), findsOneWidget);
    expect(find.textContaining('편집'), findsNothing);
    expect(find.textContaining('삭제'), findsNothing);
    expect(find.textContaining('관리'), findsNothing);

    await tester.tap(find.byKey(const Key('tarot-person-picker-cancel')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('tarot-rail-change-deck')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tarot-rail-change-deck')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('리딩할 사람을 선택해 주세요'), findsOneWidget);
    final blockedNext = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '리딩할 사람을 선택해 주세요'),
    );
    expect(blockedNext.onPressed, isNull);
    await tester.tap(
      find.byKey(const ValueKey('tarot-preparation-progress-step-0')),
    );
    await tester.pumpAndSettle();
    final railStart = tester.widget<FilledButton>(
      find.byKey(const Key('tarot-rail-primary-cta')),
    );
    expect(railStart.onPressed, isNotNull);
    await tester.tap(find.byKey(const Key('tarot-rail-primary-cta')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-person-picker')), findsOneWidget);
    expect(contexts.last.personId, isNull);
  });
}

Future<void> _pumpShell(
  WidgetTester tester, {
  required List<TarotPersonOption> options,
  required List<TarotReadingContext> contexts,
}) async {
  tester.view.physicalSize = const Size(1600, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final stream = StreamController<List<TarotPersonOption>>.broadcast();
  addTearDown(stream.close);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 1600,
          height: 1200,
          child: TarotSpreadShell(
            onBack: () {},
            personOptionsStream: stream.stream,
            onReadingContextInitialized: contexts.add,
            onReadingContextChanged: contexts.add,
          ),
        ),
      ),
    ),
  );
  stream.add(options);
  await tester.pumpAndSettle();
}
