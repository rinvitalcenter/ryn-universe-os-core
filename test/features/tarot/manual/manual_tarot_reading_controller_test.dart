import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/people/domain/person_core_models.dart';
import 'package:ryn_universe_os_core/features/tarot/data/tarot_deck_registry.dart';
import 'package:ryn_universe_os_core/features/tarot/data/tarot_spread_registry.dart';

import 'package:ryn_universe_os_core/features/tarot/manual/application/manual_tarot_reading_controller.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_reading_result_snapshot.dart';

void main() {
  final activePerson = Person(
    id: 'person-active',
    displayName: '테스트 사용자',
    status: PersonStatuses.active,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
  final inactivePerson = Person(
    id: 'person-inactive',
    displayName: '비활성 사용자',
    status: PersonStatuses.inactive,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
  final archivedPerson = Person(
    id: 'person-archived',
    displayName: '보관 사용자',
    status: PersonStatuses.active,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    archivedAt: DateTime(2026, 6, 1),
  );

  test(
    'default form uses canonical three-card spread and local reading time',
    () {
      final now = DateTime(2026, 7, 28, 15, 20);
      final controller = ManualTarotReadingController(
        saveCommand: (_) async => true,
        clock: () => now,
        readingIdFactory: () => 'manual-1',
      );

      expect(controller.state.readingAt, now);
      expect(
        controller.state.readingTimezoneOffsetMinutes,
        now.timeZoneOffset.inMinutes,
      );
      expect(controller.state.spread.id, TarotSpreadRegistry.threeCard.id);
      expect(controller.state.entries, hasLength(3));
      expect(controller.state.saveStatus, ManualTarotSaveStatus.idle);
      expect(controller.state.isDirty, isFalse);
    },
  );

  test(
    'only active unarchived People are selectable and preselection resolves',
    () {
      final controller = ManualTarotReadingController(
        saveCommand: (_) async => true,
        initialPersonId: activePerson.id,
      );

      controller.setPeople([inactivePerson, archivedPerson, activePerson]);

      expect(controller.availablePeople, [activePerson]);
      expect(controller.state.selectedPerson?.id, activePerson.id);
      expect(controller.state.selectedPersonAvailable, isTrue);
    },
  );

  test('question trims outer whitespace while preserving original wording', () {
    final controller = ManualTarotReadingController(
      saveCommand: (_) async => true,
    );

    controller.setQuestion('  지금   흐름을 어떻게 볼까?  ');

    expect(controller.state.question, '  지금   흐름을 어떻게 볼까?  ');
    expect(controller.normalizedQuestion, '지금   흐름을 어떻게 볼까?');
  });

  test('spread change requires explicit discard when cards were entered', () {
    final controller = ManualTarotReadingController(
      saveCommand: (_) async => true,
    );
    controller.selectCard(
      TarotSpreadRegistry.threeCard.positions.first.id,
      TarotDeckRegistry.rwsPublicDomain.cards.first,
    );

    expect(controller.selectSpread(TarotSpreadRegistry.oneCard), isFalse);
    expect(controller.state.spread.id, TarotSpreadRegistry.threeCard.id);
    expect(
      controller.selectSpread(
        TarotSpreadRegistry.oneCard,
        discardExisting: true,
      ),
      isTrue,
    );
    expect(controller.state.entries, hasLength(1));
    expect(controller.state.entries.single.card, isNull);
  });

  test(
    'card replacement and orientation toggle preserve canonical position',
    () {
      final controller = ManualTarotReadingController(
        saveCommand: (_) async => true,
      );
      final position = TarotSpreadRegistry.threeCard.positions.first;
      final cards = TarotDeckRegistry.rwsPublicDomain.cards;

      controller.selectCard(position.id, cards[0]);
      controller.selectCard(position.id, cards[1]);
      controller.setOrientation(position.id, TarotCardOrientation.reversed);

      final entry = controller.state.entries.first;
      expect(entry.position, same(position));
      expect(entry.card, same(cards[1]));
      expect(entry.orientation, TarotCardOrientation.reversed);
    },
  );

  test(
    'valid save maps canonical manual request and initial interpretation',
    () async {
      ManualTarotReadingSaveRequest? captured;
      final readingAt = DateTime(2026, 7, 20, 18, 45);
      final controller = ManualTarotReadingController(
        saveCommand: (request) async {
          captured = request;
          return true;
        },
        readingIdFactory: () => 'manual-reading-1',
      );
      controller.setPeople([activePerson]);
      controller.selectPerson(activePerson);
      controller.setQuestion('  실제 상담 리딩  ');
      controller.setReadingAt(readingAt, timezoneOffsetMinutes: 540);
      _completeThreeCards(controller);
      controller.updateInterpretation(
        wholeImageObservation: '전체 이미지',
        flowInterpretation: '흐름 해석',
        coreMessage: '핵심 메시지',
        smallAction: '작은 실천',
      );

      final id = await controller.save();

      expect(id, 'manual-reading-1');
      expect(controller.state.saveStatus, ManualTarotSaveStatus.saved);
      expect(captured!.personId, activePerson.id);
      expect(captured!.readingTimezoneOffsetMinutes, 540);
      expect(captured!.snapshot.readingQuestionText, '실제 상담 리딩');
      expect(captured!.snapshot.readingAt, readingAt);
      expect(captured!.snapshot.spreadId, TarotSpreadRegistry.threeCard.id);
      expect(captured!.snapshot.placements, hasLength(3));
      expect(
        captured!.snapshot.placements[1].orientation,
        TarotCardOrientation.reversed,
      );
      expect(captured!.interpretation!.coreMessage, '핵심 메시지');
    },
  );

  test('duplicate save click invokes command once', () async {
    final completer = Completer<bool>();
    var calls = 0;
    final controller = ManualTarotReadingController(
      saveCommand: (_) {
        calls++;
        return completer.future;
      },
      readingIdFactory: () => 'manual-reading-duplicate',
    );
    controller.setPeople([activePerson]);
    controller.selectPerson(activePerson);
    controller.setQuestion('중복 저장 방지');
    _completeThreeCards(controller);

    final first = controller.save();
    final second = controller.save();
    expect(controller.state.saveStatus, ManualTarotSaveStatus.saving);
    expect(calls, 1);
    completer.complete(true);

    expect(await first, 'manual-reading-duplicate');
    expect(await second, 'manual-reading-duplicate');
    expect(calls, 1);
  });

  test(
    'failed save preserves form and retry reuses immutable reading ID',
    () async {
      final ids = <String>[];
      var succeed = false;
      final controller = ManualTarotReadingController(
        saveCommand: (request) async {
          ids.add(request.snapshot.readingInstanceId);
          return succeed;
        },
        readingIdFactory: () => 'manual-reading-retry',
      );
      controller.setPeople([activePerson]);
      controller.selectPerson(activePerson);
      controller.setQuestion('실패 뒤에도 남는 질문');
      _completeThreeCards(controller);
      controller.updateInterpretation(coreMessage: '남아야 하는 해석');

      expect(await controller.save(), isNull);
      expect(controller.state.saveStatus, ManualTarotSaveStatus.failed);
      expect(controller.state.question, '실패 뒤에도 남는 질문');
      expect(controller.state.interpretation.coreMessage, '남아야 하는 해석');
      succeed = true;

      expect(await controller.save(), 'manual-reading-retry');
      expect(ids, ['manual-reading-retry', 'manual-reading-retry']);
    },
  );

  test(
    'Person becoming unavailable blocks save without exposing canonical ID',
    () async {
      var calls = 0;
      final controller = ManualTarotReadingController(
        saveCommand: (_) async {
          calls++;
          return true;
        },
      );
      controller.setPeople([activePerson]);
      controller.selectPerson(activePerson);
      controller.setQuestion('상태 변경 검증');
      _completeThreeCards(controller);
      controller.setPeople([
        activePerson.copyWith(archivedAt: DateTime(2026, 7, 1)),
      ]);

      expect(await controller.save(), isNull);
      expect(calls, 0);
      expect(controller.state.saveStatus, ManualTarotSaveStatus.failed);
      expect(controller.state.formError, contains('사람 상태를 확인'));
      expect(controller.state.formError, isNot(contains(activePerson.id)));
      expect(
        controller.state.entries.where((entry) => entry.card != null),
        hasLength(3),
      );
    },
  );

  test(
    'duplicate card and incomplete position fail local validation',
    () async {
      var calls = 0;
      final controller = ManualTarotReadingController(
        saveCommand: (_) async {
          calls++;
          return true;
        },
      );
      controller.setPeople([activePerson]);
      controller.selectPerson(activePerson);
      controller.setQuestion('카드 검증');
      final positions = TarotSpreadRegistry.threeCard.positions;
      final card = TarotDeckRegistry.rwsPublicDomain.cards.first;
      controller.selectCard(positions[0].id, card);
      controller.selectCard(positions[1].id, card);

      expect(await controller.save(), isNull);
      expect(calls, 0);
      expect(controller.state.fieldErrors['placements'], isNotNull);
    },
  );
}

void _completeThreeCards(ManualTarotReadingController controller) {
  final cards = TarotDeckRegistry.rwsPublicDomain.cards;
  for (
    var index = 0;
    index < TarotSpreadRegistry.threeCard.positions.length;
    index++
  ) {
    final position = TarotSpreadRegistry.threeCard.positions[index];
    controller.selectCard(position.id, cards[index]);
    controller.setOrientation(
      position.id,
      index == 1 ? TarotCardOrientation.reversed : TarotCardOrientation.upright,
    );
  }
}
