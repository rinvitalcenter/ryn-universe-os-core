import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/text/user_text.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_interpretation_session_draft.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_reading_result_snapshot.dart';
import 'package:ryn_universe_os_core/features/tarot/tarot_spread_shell.dart';

Future<void> _openOneCardResult(WidgetTester tester) async {
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
}

Future<void> _openInterpretation(WidgetTester tester) async {
  await _openOneCardResult(tester);
  await tester.tap(find.byKey(const Key('tarot-open-interpretation-button')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('completion persistence succeeds before interpretation opens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final persisted = <TarotReadingResultSnapshot>[];
    final offsets = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TarotSpreadShell(
            onBack: () {},
            onPersistCompletedReading: (snapshot, offsetMinutes) async {
              persisted.add(snapshot);
              offsets.add(offsetMinutes);
              return true;
            },
          ),
        ),
      ),
    );

    await _openInterpretation(tester);

    expect(persisted, hasLength(1));
    expect(offsets.single, inInclusiveRange(-840, 840));
    expect(find.byKey(const Key('tarot-interpretation-shell')), findsOneWidget);
  });

  testWidgets(
    'completion persistence failure blocks interpretation transition',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(
              onBack: () {},
              onPersistCompletedReading: (_, _) async => false,
            ),
          ),
        ),
      );
      await _openOneCardResult(tester);

      await tester.tap(
        find.byKey(const Key('tarot-open-interpretation-button')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tarot-interpretation-shell')), findsNothing);
      expect(find.text('저장하지 못했어요. 다시 시도해 주세요.'), findsOneWidget);
    },
  );

  testWidgets('explicit interpretation save reports saving then saved', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final savedDrafts = <TarotInterpretationSessionDraft>[];
    final saveResult = Completer<bool>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TarotSpreadShell(
            onBack: () {},
            onPersistCompletedReading: (_, _) async => true,
            onSaveInterpretation: (draft) async {
              savedDrafts.add(draft);
              return saveResult.future;
            },
          ),
        ),
      ),
    );
    await _openInterpretation(tester);
    await tester.enterText(
      find.byKey(const Key('tarot-interpretation-field-observation')),
      'SYNTHETIC_OBSERVATION_A',
    );
    await tester.pump();
    expect(find.text('저장하지 않은 변경 사항이 있어요'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('tarot-interpretation-save-action')),
    );
    await tester.tap(find.byKey(const Key('tarot-interpretation-save-action')));
    await tester.pump();
    expect(find.text('저장 중'), findsOneWidget);
    saveResult.complete(true);
    await tester.pumpAndSettle();

    expect(savedDrafts.single.wholeImageObservation, 'SYNTHETIC_OBSERVATION_A');
    expect(find.text('저장됨'), findsOneWidget);
  });

  testWidgets('failed save preserves text and blocks Home navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final navigated = <TarotReadingResultSnapshot>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TarotSpreadShell(
            onBack: () {},
            onPersistCompletedReading: (_, _) async => true,
            onSaveInterpretation: (_) async => false,
            onFinishToHome: navigated.add,
          ),
        ),
      ),
    );
    await _openInterpretation(tester);
    await tester.enterText(
      find.byKey(const Key('tarot-interpretation-field-message')),
      'SYNTHETIC_MESSAGE_A',
    );
    await tester.pump();

    await tester.ensureVisible(
      find.byKey(const Key('tarot-finish-home-action')),
    );
    await tester.tap(find.byKey(const Key('tarot-finish-home-action')));
    await tester.pumpAndSettle();

    expect(navigated, isEmpty);
    expect(find.text('SYNTHETIC_MESSAGE_A'), findsOneWidget);
    expect(find.text('저장하지 못했어요. 작성한 내용은 화면에 그대로 남아 있어요.'), findsOneWidget);
  });
}
