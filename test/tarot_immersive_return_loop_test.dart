import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/text/user_text.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_interpretation_session_draft.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_reading_result_snapshot.dart';
import 'package:ryn_universe_os_core/features/tarot/tarot_spread_shell.dart';

Future<void> openOneCardInterpretation(WidgetTester tester) async {
  await tester.pumpAndSettle();
  final skipIntro = find.text('바로 덱 선택');
  if (skipIntro.evaluate().isNotEmpty) {
    await tester.tap(skipIntro);
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text('다음'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ChoiceChip, UserText.tarotSpreadOne));
  await tester.pumpAndSettle();
  await tester.tap(find.text('다음'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(UserText.tarotAutoDraw));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('tarot-result-card-back-slot')).first);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('tarot-open-interpretation-button')));
  await tester.pumpAndSettle();
}

Future<void> enterInterpretationDraft(
  WidgetTester tester, {
  required String observation,
  required String flow,
  required String message,
  required String action,
}) async {
  await tester.enterText(
    find.byKey(const Key('tarot-interpretation-field-observation')),
    observation,
  );
  await tester.enterText(
    find.byKey(const Key('tarot-interpretation-field-flow')),
    flow,
  );
  await tester.enterText(
    find.byKey(const Key('tarot-interpretation-field-message')),
    message,
  );
  await tester.enterText(
    find.byKey(const Key('tarot-interpretation-field-action')),
    action,
  );
  await tester.pump();
}

void main() {
  test(
    'interpretation draft remains separate from immutable result snapshot',
    () {
      const draft = TarotInterpretationSessionDraft(
        readingInstanceId: 'reading-1',
        wholeImageObservation: '전체 장면',
        flowInterpretation: '흐름',
        coreMessage: '핵심',
        smallAction: '작은 행동',
      );

      expect(draft.hasMeaningfulText, isTrue);
      expect(
        draft.copyWith(coreMessage: '새 핵심').readingInstanceId,
        'reading-1',
      );
      final snapshotSource = File(
        'lib/features/tarot/models/tarot_reading_result_snapshot.dart',
      ).readAsStringSync();
      expect(
        snapshotSource.contains('TarotInterpretationSessionDraft'),
        isFalse,
      );
    },
  );

  testWidgets('setup exposes keyboard-reachable return without completing', (
    tester,
  ) async {
    var returned = false;
    final completed = <TarotReadingResultSnapshot>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TarotSpreadShell(
            onBack: () => returned = true,
            onResultCompleted: completed.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final returnAction = find.byKey(const Key('tarot-core-return-action'));
    expect(returnAction, findsOneWidget);
    final returnButton = find.descendant(
      of: returnAction,
      matching: find.byType(OutlinedButton),
    );
    expect(tester.widget<OutlinedButton>(returnButton).onPressed, isNotNull);
    await tester.tap(returnButton);
    await tester.pump();

    expect(returned, isTrue);
    expect(completed, isEmpty);
  });

  testWidgets(
    'completed interpretation routes typed snapshot to Home and Records',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final completed = <TarotReadingResultSnapshot>[];
      final home = <TarotReadingResultSnapshot>[];
      final records = <TarotReadingResultSnapshot>[];
      final drafts = <TarotInterpretationSessionDraft>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(
              onBack: () {},
              onResultCompleted: completed.add,
              onFinishToHome: home.add,
              onOpenInRecords: records.add,
              onInterpretationDraftChanged: drafts.add,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(ChoiceChip, UserText.tarotSpreadOne),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('tarot-result-card-back-slot')).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('tarot-open-interpretation-button')),
      );
      await tester.pumpAndSettle();

      expect(completed, hasLength(1));
      final first = completed.single;
      const observation = 'OBSERVATION_SENTINEL_가\n둘째 줄';
      const flow = 'FLOW_SENTINEL_나';
      const message = 'MESSAGE_SENTINEL_다';
      const action = 'ACTION_SENTINEL_라';
      await tester.enterText(
        find.byKey(const Key('tarot-interpretation-field-observation')),
        observation,
      );
      await tester.enterText(
        find.byKey(const Key('tarot-interpretation-field-flow')),
        flow,
      );
      await tester.enterText(
        find.byKey(const Key('tarot-interpretation-field-message')),
        message,
      );
      await tester.enterText(
        find.byKey(const Key('tarot-interpretation-field-action')),
        action,
      );
      await tester.pump();
      expect(
        find.byKey(const Key('tarot-interpretation-dirty-state')),
        findsOneWidget,
      );
      expect(drafts, isEmpty);
      await tester.ensureVisible(
        find.byKey(const Key('tarot-interpretation-apply-action')),
      );
      await tester.tap(
        find.byKey(const Key('tarot-interpretation-apply-action')),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('tarot-interpretation-applied-state')),
        findsOneWidget,
      );
      expect(drafts.last.readingInstanceId, first.readingInstanceId);
      expect(drafts.last.wholeImageObservation, observation);
      expect(drafts.last.flowInterpretation, flow);
      expect(drafts.last.coreMessage, message);
      expect(drafts.last.smallAction, action);

      await tester.tap(
        find.byKey(const Key('tarot-interpretation-back-to-result')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('tarot-open-interpretation-button')),
      );
      await tester.pumpAndSettle();
      expect(find.text(observation), findsOneWidget);
      expect(find.text(flow), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      expect(find.text(action), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('tarot-interpretation-field-message')),
        'MESSAGE_SENTINEL_다_UPDATED',
      );
      await tester.pump();
      final beforeAutoApply = drafts.length;

      await tester.ensureVisible(
        find.byKey(const Key('tarot-finish-home-action')),
      );
      await tester.tap(find.byKey(const Key('tarot-finish-home-action')));
      await tester.pump();
      expect(home.single.readingInstanceId, first.readingInstanceId);
      expect(drafts, hasLength(beforeAutoApply + 1));
      expect(drafts.last.wholeImageObservation, observation);
      expect(drafts.last.flowInterpretation, flow);
      expect(drafts.last.coreMessage, 'MESSAGE_SENTINEL_다_UPDATED');
      expect(drafts.last.smallAction, action);

      await tester.tap(find.byKey(const Key('tarot-open-records-action')));
      await tester.pump();
      expect(records.single.readingInstanceId, first.readingInstanceId);
    },
  );

  testWidgets('confirmed Core exit retains the latest live four-field draft', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    var returned = false;
    final completed = <TarotReadingResultSnapshot>[];
    final retained = <TarotInterpretationSessionDraft>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TarotSpreadShell(
            onBack: () => returned = true,
            onResultCompleted: completed.add,
            onInterpretationDraftChanged: retained.add,
          ),
        ),
      ),
    );
    await openOneCardInterpretation(tester);
    const observation = 'EXIT_OBSERVATION_가\n둘째 줄';
    const flow = 'EXIT_FLOW_나';
    const message = 'EXIT_MESSAGE_다';
    const action = 'EXIT_ACTION_라';
    await enterInterpretationDraft(
      tester,
      observation: observation,
      flow: flow,
      message: message,
      action: action,
    );

    await tester.tap(find.byKey(const Key('tarot-core-return-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('계속 해석하기'));
    await tester.pumpAndSettle();
    expect(returned, isFalse);
    expect(retained, isEmpty);
    expect(
      find.byKey(const Key('tarot-interpretation-dirty-state')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('tarot-core-return-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('리딩으로 나가기'));
    await tester.pumpAndSettle();

    expect(returned, isTrue);
    expect(retained, hasLength(1));
    expect(
      retained.single.readingInstanceId,
      completed.single.readingInstanceId,
    );
    expect(retained.single.wholeImageObservation, observation);
    expect(retained.single.flowInterpretation, flow);
    expect(retained.single.coreMessage, message);
    expect(retained.single.smallAction, action);
  });

  testWidgets('new reading starts with isolated clean interpretation state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final completed = <TarotReadingResultSnapshot>[];
    final retained = <TarotInterpretationSessionDraft>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TarotSpreadShell(
            onBack: () {},
            onResultCompleted: completed.add,
            onInterpretationDraftChanged: retained.add,
          ),
        ),
      ),
    );
    await openOneCardInterpretation(tester);
    await enterInterpretationDraft(
      tester,
      observation: 'READING_A_OBSERVATION',
      flow: 'READING_A_FLOW',
      message: 'READING_A_MESSAGE',
      action: 'READING_A_ACTION',
    );
    await tester.ensureVisible(
      find.byKey(const Key('tarot-interpretation-apply-action')),
    );
    await tester.tap(
      find.byKey(const Key('tarot-interpretation-apply-action')),
    );
    await tester.pump();
    final readingA = completed.single.readingInstanceId;
    final retainedA = retained.single;

    await tester.tap(find.byKey(const Key('tarot-start-new-reading-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '새 리딩 시작'));
    await tester.pumpAndSettle();
    await openOneCardInterpretation(tester);

    expect(completed, hasLength(2));
    expect(completed.last.readingInstanceId, isNot(readingA));
    expect(find.text('READING_A_OBSERVATION'), findsNothing);
    expect(
      find.byKey(const Key('tarot-interpretation-clean-state')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('tarot-interpretation-dirty-state')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('tarot-interpretation-applied-state')),
      findsNothing,
    );

    await tester.enterText(
      find.byKey(const Key('tarot-interpretation-field-message')),
      'READING_B_MESSAGE',
    );
    await tester.pump();
    expect(
      find.byKey(const Key('tarot-interpretation-dirty-state')),
      findsOneWidget,
    );
    await tester.ensureVisible(
      find.byKey(const Key('tarot-interpretation-apply-action')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('tarot-interpretation-apply-action')),
    );
    await tester.pump();
    expect(retained.first, same(retainedA));
    expect(retained.first.readingInstanceId, readingA);
    expect(retained.first.coreMessage, 'READING_A_MESSAGE');
    expect(retained.last.readingInstanceId, completed.last.readingInstanceId);
    expect(retained.last.coreMessage, 'READING_B_MESSAGE');
  });

  for (final destination in ['Home', 'Records']) {
    testWidgets(
      'completed result emits once when interpretation opens and routes to $destination',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        final completed = <TarotReadingResultSnapshot>[];
        final navigated = <TarotReadingResultSnapshot>[];
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TarotSpreadShell(
                onBack: () {},
                onResultCompleted: completed.add,
                onFinishToHome: destination == 'Home' ? navigated.add : null,
                onOpenInRecords: destination == 'Records'
                    ? navigated.add
                    : null,
              ),
            ),
          ),
        );
        await openOneCardInterpretation(tester);
        expect(completed, hasLength(1));
        final readingId = completed.single.readingInstanceId;
        final actionKey = destination == 'Home'
            ? const Key('tarot-finish-home-action')
            : const Key('tarot-open-records-action');

        await tester.tap(find.byKey(actionKey));
        await tester.pump();
        await tester.tap(find.byKey(actionKey));
        await tester.pump();

        expect(completed, hasLength(1));
        expect(completed.single.readingInstanceId, readingId);
        expect(navigated, hasLength(2));
        expect(
          navigated.every(
            (snapshot) => snapshot.readingInstanceId == readingId,
          ),
          isTrue,
        );
      },
    );
  }

  test('return-loop copy does not claim restart persistence', () {
    final source = File(
      'lib/features/tarot/tarot_spread_shell.dart',
    ).readAsStringSync();
    expect(source.contains('결과와 작성 중인 해석은 앱을 닫기 전까지 이어집니다.'), isTrue);
    expect(source.contains('앱을 다시 열어도'), isFalse);
    expect(source.contains('영구 저장'), isFalse);
  });
}
