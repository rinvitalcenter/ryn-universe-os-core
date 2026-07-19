import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/oracle/application/oracle_reading_controller.dart';
import 'package:ryn_universe_os_core/features/oracle/domain/oracle_reading_session.dart';

void main() {
  group('OracleReadingController', () {
    test('uses only the approved 52-card non-reversing deck', () {
      final controller = OracleReadingController();

      expect(controller.deck.deckId, 'horoscope_belline');
      expect(controller.deck.cards, hasLength(52));
      expect(controller.deck.supportsReversal, isFalse);
      expect(controller.supportedDrawCounts, [1, 3]);
    });

    test('rejects an empty question and unsupported draw counts', () {
      final controller = OracleReadingController();

      expect(
        () => controller.start(questionText: '   ', drawCount: 1),
        throwsArgumentError,
      );
      for (final drawCount in [0, 2, 4, 52]) {
        expect(
          () => controller.start(
            questionText: 'SYNTHETIC_ORACLE_QUESTION',
            drawCount: drawCount,
          ),
          throwsArgumentError,
          reason: '$drawCount must be rejected',
        );
      }
    });

    for (final drawCount in [1, 3]) {
      test('supports an exact $drawCount-card manual draw', () {
        final controller = OracleReadingController();
        controller.start(
          questionText: '  SYNTHETIC_ORACLE_QUESTION  ',
          drawCount: drawCount,
        );

        expect(controller.stage, OracleReadingStage.shuffle);
        controller.shuffle(random: Random(19));
        expect(controller.stage, OracleReadingStage.draw);
        expect(controller.shuffledCards, hasLength(52));
        expect(
          controller.shuffledCards.map((card) => card.cardId).toSet(),
          hasLength(52),
        );

        for (final card in controller.shuffledCards.take(drawCount)) {
          expect(controller.selectCard(card.cardId), isTrue);
          expect(controller.selectCard(card.cardId), isFalse);
        }
        expect(
          controller.selectCard(controller.shuffledCards.last.cardId),
          isFalse,
        );

        controller.confirmSelection();
        expect(controller.stage, OracleReadingStage.result);
        expect(controller.placements, hasLength(drawCount));
        expect(
          controller.placements.map((placement) => placement.placementOrder),
          List.generate(drawCount, (index) => index + 1),
        );
        expect(
          controller.placements.map((placement) => placement.qualifiedCardId),
          everyElement(startsWith('oracle.horoscope_belline.')),
        );
        expect(
          controller.placements.map((placement) => placement.orientation),
          everyElement(OracleCardOrientation.notUsed),
        );
      });
    }

    test('uses the approved placement contract for one and three cards', () {
      final one = OracleReadingController()
        ..start(questionText: 'one', drawCount: 1)
        ..shuffle(random: Random(1));
      one.selectCard(one.shuffledCards.first.cardId);
      one.confirmSelection();
      expect(
        one.placements.map(
          (placement) => [placement.positionId, placement.positionName],
        ),
        [
          ['message', '지금 나에게 온 메시지'],
        ],
      );

      final three = OracleReadingController()
        ..start(questionText: 'three', drawCount: 3)
        ..shuffle(random: Random(2));
      for (final card in three.shuffledCards.take(3)) {
        three.selectCard(card.cardId);
      }
      three.confirmSelection();
      expect(
        three.placements.map(
          (placement) => [placement.positionId, placement.positionName],
        ),
        [
          ['now', '지금'],
          ['notice', '알아차릴 것'],
          ['practice', '작은 실천'],
        ],
      );
    });

    test(
      'completion freezes question cards and optional reflection fields',
      () {
        final controller = OracleReadingController()
          ..start(questionText: 'SYNTHETIC_ORACLE_QUESTION', drawCount: 1)
          ..shuffle(random: Random(7));
        controller.selectCard(controller.shuffledCards.first.cardId);
        controller.confirmSelection();
        controller.openInterpretation();
        controller.updateInterpretation(
          messageNote: '합성 메시지',
          smallAction: '합성 실천',
        );

        final result = controller.complete(now: DateTime(2026, 7, 19, 14, 30));

        expect(controller.stage, OracleReadingStage.completed);
        expect(controller.latestResult, same(result));
        expect(result.status, OracleReadingStatus.completed);
        expect(result.questionText, 'SYNTHETIC_ORACLE_QUESTION');
        expect(result.deckId, 'horoscope_belline');
        expect(result.drawCount, 1);
        expect(result.placements, hasLength(1));
        expect(result.messageNote, '합성 메시지');
        expect(result.smallAction, '합성 실천');
      },
    );

    test('latest completed result can resume and a new draft can reset', () {
      final controller = OracleReadingController()
        ..start(questionText: 'first', drawCount: 1)
        ..shuffle(random: Random(3));
      controller.selectCard(controller.shuffledCards.first.cardId);
      controller.confirmSelection();
      controller.openInterpretation();
      final completed = controller.complete(now: DateTime(2026, 7, 19));

      controller.startNewReading();
      expect(controller.stage, OracleReadingStage.setup);
      expect(controller.latestResult, same(completed));
      expect(controller.questionText, isEmpty);
      expect(controller.placements, isEmpty);

      expect(controller.resumeLatest(), isTrue);
      expect(controller.stage, OracleReadingStage.completed);
      expect(controller.placements, completed.placements);
    });
  });
}
