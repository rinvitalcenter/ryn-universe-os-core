import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_reading_result_snapshot.dart';

void main() {
  const allowedCardIds = {'major_00', 'major_01'};

  TarotCardPlacementSnapshot placement({
    int order = 1,
    String cardId = 'major_00',
    String cardName = 'The Fool',
    String positionId = 'present',
    String positionName = '현재',
    TarotCardOrientation orientation = TarotCardOrientation.upright,
  }) => TarotCardPlacementSnapshot(
    placementOrder: order,
    cardId: cardId,
    cardNameSnapshot: cardName,
    positionId: positionId,
    positionNameSnapshot: positionName,
    orientation: orientation,
  );

  TarotReadingResultSnapshot snapshot({
    String readingInstanceId = 'reading_opaque_1',
    String readingQuestionText = '오늘의 흐름은?',
    String deckId = 'rws_public_domain',
    String deckNameSnapshot = 'RWS Public Domain',
    String spreadId = 'three_card',
    String spreadNameSnapshot = '3카드',
    List<TarotCardPlacementSnapshot>? placements,
  }) => TarotReadingResultSnapshot.validated(
    readingInstanceId: readingInstanceId,
    readingQuestionText: readingQuestionText,
    deckId: deckId,
    deckNameSnapshot: deckNameSnapshot,
    spreadId: spreadId,
    spreadNameSnapshot: spreadNameSnapshot,
    readingAt: DateTime.utc(2026, 7, 11, 10),
    placements: placements ?? [placement()],
    expectedPlacementCount: placements?.length ?? 1,
    selectedDeckCardIds: allowedCardIds,
  );

  test('valid completed facts create an immutable snapshot', () {
    final result = snapshot();

    expect(result.readingInstanceId, 'reading_opaque_1');
    expect(result.readingQuestionText, '오늘의 흐름은?');
    expect(result.deckId, 'rws_public_domain');
    expect(result.spreadId, 'three_card');
    expect(result.placements.single.positionId, 'present');
    expect(
      () => result.placements.add(placement(order: 2)),
      throwsUnsupportedError,
    );
  });

  test('incoming placement list mutation cannot modify the snapshot', () {
    final source = [placement()];
    final result = snapshot(placements: source);

    source.clear();

    expect(result.placements, hasLength(1));
  });

  test('empty identity is rejected', () {
    expect(() => snapshot(readingInstanceId: '  '), throwsArgumentError);
  });

  test('empty question deck and spread facts are rejected', () {
    expect(() => snapshot(readingQuestionText: ''), throwsArgumentError);
    expect(() => snapshot(deckId: ''), throwsArgumentError);
    expect(() => snapshot(deckNameSnapshot: ''), throwsArgumentError);
    expect(() => snapshot(spreadId: ''), throwsArgumentError);
    expect(() => snapshot(spreadNameSnapshot: ''), throwsArgumentError);
  });

  test('no placements is rejected', () {
    expect(() => snapshot(placements: []), throwsArgumentError);
  });

  test('placement order starts at one and remains continuous', () {
    expect(
      () => snapshot(placements: [placement(order: 2)]),
      throwsArgumentError,
    );
    expect(
      () => snapshot(
        placements: [
          placement(),
          placement(
            order: 3,
            cardId: 'major_01',
            cardName: 'The Magician',
            positionId: 'future',
            positionName: '미래',
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('duplicate position ID is rejected', () {
    expect(
      () => snapshot(
        placements: [
          placement(),
          placement(
            order: 2,
            cardId: 'major_01',
            cardName: 'The Magician',
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('card membership is validated against the selected deck', () {
    expect(
      () => snapshot(placements: [placement(cardId: 'foreign_card')]),
      throwsArgumentError,
    );
  });

  test('orientation values remain explicit', () {
    final result = snapshot(
      placements: [
        placement(orientation: TarotCardOrientation.notUsed),
      ],
    );

    expect(result.placements.single.orientation, TarotCardOrientation.notUsed);
    expect(
      TarotCardOrientation.values,
      containsAll([
        TarotCardOrientation.notUsed,
        TarotCardOrientation.upright,
        TarotCardOrientation.reversed,
      ]),
    );
  });

  test('asset and growth fields are absent from the snapshot model', () {
    final source = File(
      'lib/features/tarot/models/tarot_reading_result_snapshot.dart',
    ).readAsStringSync();

    for (final forbidden in [
      'assetPath',
      'imageBytes',
      'growthText',
      'memoText',
      'personId',
      'personName',
      'copyWith',
      'toJson',
      'fromJson',
    ]) {
      expect(source.contains(forbidden), isFalse, reason: forbidden);
    }
  });
}
