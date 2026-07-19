import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ryn_universe_os_core/core/text/user_text.dart';
import 'package:ryn_universe_os_core/features/home/presentation/home_cinematic_scene.dart';
import 'package:ryn_universe_os_core/features/tarot/data/tarot_card_meaning_registry.dart';
import 'package:ryn_universe_os_core/features/tarot/data/tarot_deck_registry.dart';
import 'package:ryn_universe_os_core/features/tarot/models/tarot_reading_result_snapshot.dart';
import 'package:ryn_universe_os_core/features/tarot/tarot_spread_shell.dart';
import 'package:ryn_universe_os_core/main.dart';

TarotReadingResultSnapshot _homeSnapshot({
  int cardCount = 3,
  String? question,
  String deckId = TarotDeckRegistry.rwsPublicDomainDeckId,
  bool missingRegistryCard = false,
}) {
  final registryCards = TarotDeckRegistry.rwsPublicDomain.cards;
  final placements = List.generate(cardCount, (index) {
    final registryCard = registryCards[index];
    return TarotCardPlacementSnapshot(
      placementOrder: index + 1,
      cardId: missingRegistryCard && index == 0
          ? 'missing-card'
          : registryCard.semanticId,
      cardNameSnapshot: missingRegistryCard && index == 0
          ? 'Missing Snapshot Card'
          : registryCard.displayName,
      positionId: 'position-${index + 1}',
      positionNameSnapshot: '자리 ${index + 1}',
      orientation: index == 1
          ? TarotCardOrientation.reversed
          : TarotCardOrientation.upright,
    );
  });
  return TarotReadingResultSnapshot.validated(
    readingInstanceId: 'home-scene-$cardCount-$deckId',
    readingQuestionText: question ?? '지금 내 성장에서 가장 먼저 바라볼 것은?',
    deckId: deckId,
    deckNameSnapshot: '테스트 덱',
    spreadId: 'test-spread-$cardCount',
    spreadNameSnapshot: '$cardCount장 흐름',
    readingAt: DateTime(2026, 7, 11, 10, 20),
    placements: placements,
    expectedPlacementCount: placements.length,
    selectedDeckCardIds: placements
        .map((placement) => placement.cardId)
        .toSet(),
  );
}

void main() {
  test('tarot deck registry preserves existing RWS asset baseline', () {
    final rwsDeck = TarotDeckRegistry.rwsPublicDomain;

    expect(TarotDeckRegistry.decks, contains(rwsDeck));
    expect(rwsDeck.deckId, 'rws_public_domain');
    expect(rwsDeck.cards, hasLength(78));
    expect(
      rwsDeck.representativeAssetPath,
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_00_Fool.jpg',
    );
    expect(
      rwsDeck.coverAssetPath,
      'assets/tarot/decks/rws_public_domain/cover/cover.jpg',
    );
    expect(
      rwsDeck.cardBackAssetPath,
      'assets/tarot/decks/rws_public_domain/back/back.png',
    );
    expect(
      rwsDeck.cards.first.assetPath,
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups01.jpg',
    );
    expect(
      rwsDeck.cards
          .firstWhere((card) => card.semanticId == 'pents_01')
          .assetPath,
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents01.jpg',
    );
  });

  test(
    'tarot deck registry integrates Universal Waite and Golden Art Nouveau',
    () {
      final rwsDeck = TarotDeckRegistry.rwsPublicDomain;
      final rwsIds = rwsDeck.cards.map((card) => card.semanticId).toSet();

      final integratedDecks = <String, String>{
        'universal_waite': 'assets/tarot/decks/universal_waite/',
        'golden_art_nouveau_tarot':
            'assets/tarot/decks/golden_art_nouveau_tarot/',
      };

      for (final entry in integratedDecks.entries) {
        final deck = TarotDeckRegistry.decks.firstWhere(
          (candidate) => candidate.deckId == entry.key,
        );
        final ids = deck.cards.map((card) => card.semanticId).toSet();

        expect(deck.cards, hasLength(78), reason: entry.key);
        expect(ids, rwsIds, reason: entry.key);
        expect(deck.representativeAssetPath, isNotNull, reason: entry.key);
        expect(deck.cardBackAssetPath, isNotNull, reason: entry.key);
        expect(deck.coverAssetPath, isNotNull, reason: entry.key);
        expect(deck.representativeAssetPath, startsWith(entry.value));
        expect(deck.cardBackAssetPath, startsWith('${entry.value}back/'));
        expect(deck.coverAssetPath, startsWith('${entry.value}cover/'));
        expect(
          deck.cards
              .firstWhere((card) => card.semanticId == 'pents_05')
              .assetPath,
          startsWith(entry.value),
          reason:
              '${entry.key} pents_05 must resolve inside selected deck assets',
        );
        expect(
          deck.cards
              .firstWhere((card) => card.semanticId == 'pents_05')
              .assetPath,
          isNot(contains('rws_public_domain')),
          reason: '${entry.key} pents_05 must not fall back to RWS assets',
        );
        expect(
          deck.cards.where((card) => card.semanticId.startsWith('major_')),
          hasLength(22),
          reason: entry.key,
        );
        for (final suit in ['cups', 'pents', 'swords', 'wands']) {
          expect(
            deck.cards.where((card) => card.semanticId.startsWith('${suit}_')),
            hasLength(14),
            reason: '${entry.key} $suit',
          );
        }
      }

      expect(
        TarotDeckRegistry.decks.where((deck) => deck.deckId.contains('oracle')),
        hasLength(1),
      );
    },
  );

  test('pubspec registers integrated tarot deck asset folders only', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    for (final deckRoot in [
      'assets/tarot/decks/rws_public_domain',
      'assets/tarot/decks/universal_waite',
      'assets/tarot/decks/golden_art_nouveau_tarot',
    ]) {
      expect(pubspec.contains('- $deckRoot/'), isTrue, reason: deckRoot);
      expect(pubspec.contains('- $deckRoot/major/'), isTrue, reason: deckRoot);
      expect(pubspec.contains('- $deckRoot/minor/'), isTrue, reason: deckRoot);
      expect(pubspec.contains('- $deckRoot/back/'), isTrue, reason: deckRoot);
      expect(pubspec.contains('- $deckRoot/cover/'), isTrue, reason: deckRoot);
    }

    expect(pubspec.contains('horoscope_belline_oracle'), isFalse);
  });

  test('Tarot runtime binding source keeps deck-first image resolution', () {
    final tarotShell = File(
      'lib/features/tarot/tarot_spread_shell.dart',
    ).readAsStringSync();

    expect(
      tarotShell.contains(
        'deck.coverAssetPath ?? deck.representativeAssetPath',
      ),
      isTrue,
    );
    expect(
      tarotShell.contains(
        '_remainingDeck = List<TarotCardDefinition>.of(_selectedDeck.cards)',
      ),
      isTrue,
    );
    expect(
      tarotShell.contains(
        '_selectedDeck.cards.isEmpty ? _rwsCards : _selectedDeck.cards',
      ),
      isFalse,
    );
    expect(tarotShell.contains('_selectedCardBackOverrideId ??'), isTrue);
    expect(tarotShell.contains('_selectedDeckCardBack?.id'), isTrue);
    expect(tarotShell.contains('_selectedCardBackOverrideId = null;'), isTrue);
    expect(tarotShell.contains('..._cardBackDefinitions'), isTrue);
    expect(tarotShell.contains("id: 'deck-\${_selectedDeck.id}'"), isTrue);
  });

  test(
    'Tarot hidden card backs render deck image without purple shimmer masking',
    () {
      final tarotShell = File(
        'lib/features/tarot/tarot_spread_shell.dart',
      ).readAsStringSync();
      final cardBackStart = tarotShell.indexOf('class _TarotCardBack extends');
      final cardBackEnd = tarotShell.indexOf('class _TarotFxBurst extends');
      final faceDownStart = tarotShell.indexOf(
        'class _TarotFullDeckCard extends',
      );
      final faceDownEnd = tarotShell.indexOf('class _TarotResultStage extends');

      expect(cardBackStart, isNonNegative);
      expect(cardBackEnd, greaterThan(cardBackStart));
      expect(faceDownStart, isNonNegative);
      expect(faceDownEnd, greaterThan(faceDownStart));

      final cardBackSource = tarotShell.substring(cardBackStart, cardBackEnd);
      final faceDownSource = tarotShell.substring(faceDownStart, faceDownEnd);

      expect(
        cardBackSource.indexOf("key: const Key('tarot-card-back-image')"),
        lessThan(cardBackSource.indexOf('Shimmer.fromColors')),
      );
      expect(cardBackSource.contains('errorBuilder:'), isTrue);
      expect(faceDownSource.contains('.shimmer('), isFalse);
    },
  );

  test(
    'Tarot shuffle pile starts idle and unavailable deck previews stay isolated',
    () {
      final tarotShell = File(
        'lib/features/tarot/tarot_spread_shell.dart',
      ).readAsStringSync();
      final shuffleStart = tarotShell.indexOf(
        'class _ShuffleDeckStack extends',
      );
      final shuffleEnd = tarotShell.indexOf(
        'class _TarotCardBackChoice extends',
      );
      final artworkStart = tarotShell.indexOf(
        'class _TarotRepresentativeDeckArtwork extends',
      );
      final artworkEnd = tarotShell.indexOf(
        'class _TarotCardBackChoiceSection extends',
      );

      expect(shuffleStart, isNonNegative);
      expect(shuffleEnd, greaterThan(shuffleStart));
      expect(artworkStart, isNonNegative);
      expect(artworkEnd, greaterThan(artworkStart));

      final shuffleSource = tarotShell.substring(shuffleStart, shuffleEnd);
      final artworkSource = tarotShell.substring(artworkStart, artworkEnd);

      expect(
        shuffleSource.contains('glowing: isShuffling || index == 0'),
        isFalse,
      );
      expect(shuffleSource.contains('glowing: active,'), isTrue);
      expect(shuffleSource.contains('if (widget.isShuffling)'), isTrue);
      expect(
        artworkSource.contains(
          'deck.coverAssetPath ?? deck.representativeAssetPath',
        ),
        isTrue,
      );
      expect(artworkSource.contains('assetPath: cardBack.assetPath'), isFalse);
      expect(artworkSource.contains('tarot-unavailable-deck-preview'), isTrue);
    },
  );

  test(
    'Tarot premium shuffle ritual motion keeps idle still and active one-shot',
    () {
      final tarotShell = File(
        'lib/features/tarot/tarot_spread_shell.dart',
      ).readAsStringSync();
      final preparationStart = tarotShell.indexOf(
        'class _TarotPreparationPanel extends StatelessWidget',
      );
      final preparationEnd = tarotShell.indexOf(
        'class _TarotFullDeckDrawStage extends StatelessWidget',
      );
      final shuffleStart = tarotShell.indexOf(
        'class _ShuffleDeckStack extends',
      );
      final shuffleEnd = tarotShell.indexOf(
        'class _TarotCardBackChoice extends',
      );

      expect(preparationStart, isNonNegative);
      expect(preparationEnd, greaterThan(preparationStart));
      expect(shuffleStart, isNonNegative);
      expect(shuffleEnd, greaterThan(shuffleStart));

      final preparationSource = tarotShell.substring(
        preparationStart,
        preparationEnd,
      );
      final shuffleSource = tarotShell.substring(shuffleStart, shuffleEnd);

      expect(tarotShell.contains('enum _ShuffleRitualMotionPhase'), isTrue);
      expect(shuffleSource.contains('Still Altar idle'), isTrue);
      expect(shuffleSource.contains('Ritual Cut active'), isTrue);
      expect(shuffleSource.contains('Settle signal'), isTrue);
      expect(shuffleSource.contains('transitionToFan'), isTrue);
      expect(shuffleSource.contains('repeat('), isFalse);
      expect(shuffleSource.contains('TweenAnimationBuilder<double>'), isTrue);
      expect(shuffleSource.contains('duration: 1080.ms'), isTrue);
      expect(shuffleSource.contains('_ritualCutOffset'), isTrue);
      expect(shuffleSource.contains('_ritualCutAngle'), isTrue);
      expect(shuffleSource.contains('_ritualCutScale'), isTrue);
      expect(shuffleSource.contains('RepaintBoundary'), isTrue);
      expect(shuffleSource.contains('MouseRegion'), isTrue);
      expect(
        shuffleSource.contains('assetPath: widget.cardBack.assetPath'),
        isTrue,
      );
      expect(
        preparationSource.contains('tarot-premium-static-ambient'),
        isTrue,
      );
      expect(
        preparationSource.contains('tarot-premium-active-ambient'),
        isTrue,
      );
    },
  );

  test('Tarot shuffle idle stillness uses stable altar transforms only', () {
    final tarotShell = File(
      'lib/features/tarot/tarot_spread_shell.dart',
    ).readAsStringSync();
    final shuffleStart = tarotShell.indexOf('class _ShuffleDeckStack extends');
    final shuffleEnd = tarotShell.indexOf('class _TarotCardBackChoice extends');

    expect(shuffleStart, isNonNegative);
    expect(shuffleEnd, greaterThan(shuffleStart));

    final shuffleSource = tarotShell.substring(shuffleStart, shuffleEnd);

    expect(shuffleSource.contains('_stableAltarOffset'), isTrue);
    expect(shuffleSource.contains('_stableAltarAngle'), isTrue);
    expect(shuffleSource.contains('_stableAltarOpacity'), isTrue);
    expect(shuffleSource.contains('final idle = !widget.isShuffling;'), isTrue);
    expect(
      shuffleSource.contains(
        'offset: idle ? _stableAltarOffset(index) : _ritualCutOffset(index, progress)',
      ),
      isTrue,
    );
    expect(
      shuffleSource.contains(
        'angle: idle ? _stableAltarAngle(index) : _ritualCutAngle(index, progress)',
      ),
      isTrue,
    );
    expect(
      shuffleSource.contains(
        'opacity: idle ? _stableAltarOpacity(index) : 0.62 + index * 0.035',
      ),
      isTrue,
    );
    expect(shuffleSource.contains('tarot-stable-altar-idle-marker'), isTrue);
    expect(shuffleSource.contains('glowing: active,'), isTrue);
    expect(shuffleSource.contains('repeat('), isFalse);
    expect(shuffleSource.contains('Shimmer.fromColors'), isFalse);
  });

  test(
    'tarot card meaning registry resolves semantic content and fallback',
    () {
      final registrySource = File(
        'lib/features/tarot/data/tarot_card_meaning_registry.dart',
      ).readAsStringSync();
      expect(
        RegExp(
          r"'((major|wands|cups|swords|pents)_\d{2})': TarotCardMeaning",
        ).allMatches(registrySource),
        hasLength(78),
      );

      final semanticIds = TarotDeckRegistry.rwsPublicDomain.cards
          .map((card) => card.semanticId)
          .toSet();
      expect(semanticIds, hasLength(78));
      for (final semanticId in semanticIds) {
        final meaning = TarotCardMeaningRegistry.resolve(semanticId);
        expect(meaning.semanticId, semanticId);
        expect(meaning.titleKo, isNot('카드 메시지'));
        expect(meaning.titleKo.trim(), isNotEmpty);
        expect(meaning.keywords, hasLength(greaterThanOrEqualTo(3)));
        expect(meaning.upright.trim(), isNotEmpty);
        expect(meaning.reversed.trim(), isNotEmpty);
        expect(meaning.questionLens.trim(), isNotEmpty);
        expect(meaning.positionLens.trim(), isNotEmpty);
        expect(meaning.smallAction.trim(), isNotEmpty);
      }

      const representative = <String, String>{
        'major_00': '바보',
        'major_13': '죽음',
        'major_16': '탑',
        'swords_02': '소드 2',
        'swords_10': '소드 10',
        'pents_14': '펜타클 왕',
      };
      for (final entry in representative.entries) {
        expect(
          TarotCardMeaningRegistry.resolve(entry.key).titleKo,
          entry.value,
        );
      }

      for (final forbidden in [
        'DB',
        'snapshot',
        'storage',
        'persistence',
        'schema',
        '반드시',
        '무조건',
        '틀림없이',
        '운명적으로',
      ]) {
        expect(registrySource.contains(forbidden), isFalse);
      }

      final fool = TarotCardMeaningRegistry.resolve('major_00');
      expect(fool.titleKo, isNotEmpty);
      expect(fool.keywords, isNotEmpty);
      expect(fool.upright, isNotEmpty);
      expect(fool.reversed, isNotEmpty);
      expect(fool.questionLens, isNotEmpty);
      expect(fool.positionLens, isNotEmpty);
      expect(fool.smallAction, isNotEmpty);

      final pentsKing = TarotCardMeaningRegistry.resolve('pents_14');
      expect(pentsKing.titleKo, contains('펜타클'));

      final fallback = TarotCardMeaningRegistry.resolve('unknown_99');
      expect(fallback.titleKo, '카드 메시지');
      expect(fallback.keywords, isNotEmpty);
    },
  );

  testWidgets('Tarot runtime binds integrated deck cover, back, and fronts', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();

    final deckSelectorAssets = tester
        .widgetList<Image>(
          find.byKey(const Key('tarot-representative-deck-image')),
        )
        .map((image) => (image.image as AssetImage).assetName)
        .toSet();
    expect(deckSelectorAssets.length, inInclusiveRange(1, 7));
    expect(
      deckSelectorAssets,
      contains('assets/tarot/decks/rws_public_domain/cover/cover.jpg'),
    );

    expect(
      find.byKey(const ValueKey('tarot-deck-carousel-card-rws_public_domain')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('tarot-jukebox-center-card')), findsOneWidget);

    final previousDeck = find.byKey(const Key('tarot-deck-fan-left'));
    await tester.ensureVisible(previousDeck);
    await tester.pumpAndSettle();
    for (var step = 0; step < 6; step++) {
      await tester.tap(previousDeck);
      await tester.pumpAndSettle();
    }

    final goldenDeck = find.byKey(
      const ValueKey('tarot-deck-carousel-card-golden_art_nouveau_tarot'),
    );
    expect(goldenDeck, findsOneWidget);
    expect(
      find.descendant(
        of: goldenDeck,
        matching: find.byKey(const Key('tarot-selected-card-edge-glow')),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('tarot-deck-carousel-card-universal_waite')),
      findsOneWidget,
    );
    final selectedCover = tester.widget<Image>(
      find.descendant(
        of: goldenDeck,
        matching: find.byKey(const Key('tarot-representative-deck-image')),
      ),
    );
    expect(
      (selectedCover.image as AssetImage).assetName,
      'assets/tarot/decks/golden_art_nouveau_tarot/cover/Golden_Art_Nouveau_Tarot_Cover.jpg',
    );

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(
        const ValueKey('tarot-card-back-option-deck-golden_art_nouveau_tarot'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('tarot-card-back-option-cosmic_gate')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('tarot-card-back-option-inner_lotus')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('tarot-card-back-option-life_tree')),
      findsOneWidget,
    );

    final setupBackAssets = tester
        .widgetList<Image>(find.byKey(const Key('tarot-card-back-image')))
        .map((image) => (image.image as AssetImage).assetName)
        .toSet();
    expect(
      setupBackAssets,
      contains(
        'assets/tarot/decks/golden_art_nouveau_tarot/back/Golden_Art_Nouveau_Tarot_Back.jpg',
      ),
    );

    await tester.ensureVisible(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-shuffle-button')), findsOneWidget);
    var runtimeBackAssets = tester
        .widgetList<Image>(find.byKey(const Key('tarot-card-back-image')))
        .map((image) => (image.image as AssetImage).assetName)
        .toSet();
    expect(runtimeBackAssets, {
      'assets/tarot/decks/golden_art_nouveau_tarot/back/Golden_Art_Nouveau_Tarot_Back.jpg',
    });

    await tester.tap(find.byKey(const Key('tarot-shuffle-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-full-deck-stage')), findsOneWidget);
    runtimeBackAssets = tester
        .widgetList<Image>(find.byKey(const Key('tarot-card-back-image')))
        .map((image) => (image.image as AssetImage).assetName)
        .toSet();
    expect(runtimeBackAssets, {
      'assets/tarot/decks/golden_art_nouveau_tarot/back/Golden_Art_Nouveau_Tarot_Back.jpg',
    });

    await tester.tap(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();
    await tester.tap(find.text('모두 펼치기'));
    await tester.pumpAndSettle();
    final revealedAssets = tester
        .widgetList<Image>(find.byKey(const Key('tarot-rws-card-image')))
        .map((image) => (image.image as AssetImage).assetName)
        .toSet();
    expect(revealedAssets, isNotEmpty);
    expect(
      revealedAssets.every(
        (asset) =>
            asset.startsWith('assets/tarot/decks/golden_art_nouveau_tarot/'),
      ),
      isTrue,
    );
    expect(
      revealedAssets.any((asset) => asset.contains('rws_public_domain')),
      isFalse,
    );

    await tester.tap(find.byKey(const Key('tarot-focusable-result-card-0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-focus-detail-overlay')), findsOneWidget);
    final focusedCard = tester.widget<Image>(
      find.byKey(const Key('tarot-focus-card-image')),
    );
    expect(
      (focusedCard.image as AssetImage).assetName,
      startsWith('assets/tarot/decks/golden_art_nouveau_tarot/'),
    );
    expect(find.byKey(const Key('tarot-focus-meaning-title')), findsOneWidget);
    expect(
      find.byKey(const Key('tarot-focus-meaning-orientation-text')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('tarot-focus-meaning-question-lens')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('tarot-focus-meaning-position-lens')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('tarot-focus-meaning-small-action')),
      findsOneWidget,
    );
  });

  testWidgets(
    'Tarot completed result freezes one validated snapshot per reading',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final delivered = <TarotReadingResultSnapshot>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(
              onBack: () {},
              onResultCompleted: delivered.add,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      Future<void> completeOneCardReading({bool uprightOnly = false}) async {
        final deliveriesBefore = delivered.length;
        await tester.tap(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(ChoiceChip, UserText.tarotSpreadOne),
        );
        await tester.pumpAndSettle();
        if (uprightOnly) {
          final uprightChoice = find.text('정방향만');
          await tester.ensureVisible(uprightChoice);
          await tester.pumpAndSettle();
          await tester.tap(uprightChoice);
          await tester.pumpAndSettle();
        }
        final detailNext = find.text('다음');
        await tester.ensureVisible(detailNext);
        await tester.pumpAndSettle();
        await tester.tap(detailNext);
        await tester.pumpAndSettle();
        await tester.tap(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
        expect(delivered, hasLength(deliveriesBefore));
        await tester.tap(
          find.byKey(const Key('tarot-result-card-back-slot')).first,
        );
        await tester.pumpAndSettle();
        if (uprightOnly) {
          expect(
            find.byKey(const Key('tarot-result-direction-toggle-0')),
            findsNothing,
          );
        }
        await tester.tap(
          find.byKey(const Key('tarot-open-interpretation-button')),
        );
        await tester.pumpAndSettle();
      }

      await completeOneCardReading();
      expect(delivered, hasLength(1));
      final first = delivered.single;
      expect(first.readingInstanceId, isNotEmpty);
      expect(first.readingQuestionText, '오늘 가장 먼저 비춰볼 질문');
      expect(first.deckId, TarotDeckRegistry.rwsPublicDomainDeckId);
      expect(first.spreadId, 'one_card');
      expect(first.spreadNameSnapshot, UserText.tarotSpreadOne);
      expect(first.placements, hasLength(1));
      expect(first.placements.single.placementOrder, 1);
      expect(first.placements.single.positionId, 'one_center');
      expect(
        TarotDeckRegistry.rwsPublicDomain.cards.map((card) => card.id),
        contains(first.placements.single.cardId),
      );
      expect(
        first.placements.single.orientation,
        anyOf(TarotCardOrientation.upright, TarotCardOrientation.reversed),
      );

      await tester.tap(find.text('공개로 돌아가기'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('tarot-open-interpretation-button')),
      );
      await tester.pumpAndSettle();
      expect(delivered, hasLength(1));
      expect(identical(delivered.single, first), isTrue);
      expect(delivered.single.readingInstanceId, first.readingInstanceId);
      expect(delivered.single.readingAt, first.readingAt);

      await tester.tap(find.text(UserText.tarotResetDraw));
      await tester.pumpAndSettle();
      await completeOneCardReading(uprightOnly: true);
      expect(delivered, hasLength(2));
      expect(delivered.last.readingInstanceId, isNot(first.readingInstanceId));
      expect(
        delivered.last.placements.single.orientation,
        TarotCardOrientation.notUsed,
      );
    },
  );

  testWidgets(
    'Tarot result orientation becomes read-only after snapshot freeze',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final delivered = <TarotReadingResultSnapshot>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(
              onBack: () {},
              onResultCompleted: delivered.add,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      Future<void> openOneCardResult() async {
        await tester.tap(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(ChoiceChip, UserText.tarotSpreadOne),
        );
        await tester.pumpAndSettle();
        final detailNext = find.text('다음');
        await tester.ensureVisible(detailNext);
        await tester.pumpAndSettle();
        await tester.tap(detailNext);
        await tester.pumpAndSettle();
        await tester.tap(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('tarot-result-card-back-slot')).first,
        );
        await tester.pumpAndSettle();
      }

      String visibleOrientation() {
        final focusableCard = find.byKey(
          const Key('tarot-focusable-result-card-0'),
        );
        final tooltip = find.ancestor(
          of: focusableCard,
          matching: find.byType(Tooltip),
        );
        return tester.widget<Tooltip>(tooltip).message ?? '';
      }

      await openOneCardResult();
      final toggle = find.byKey(const Key('tarot-result-direction-toggle-0'));
      expect(toggle, findsOneWidget);
      expect(tester.widget<IconButton>(toggle).onPressed, isNotNull);
      final beforeToggle = visibleOrientation();
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      final frozenVisibleOrientation = visibleOrientation();
      expect(frozenVisibleOrientation, isNot(beforeToggle));

      await tester.tap(
        find.byKey(const Key('tarot-open-interpretation-button')),
      );
      await tester.pumpAndSettle();
      expect(delivered, hasLength(1));
      final first = delivered.single;
      final frozenOrientation = first.placements.single.orientation;
      expect(
        frozenVisibleOrientation,
        contains(
          frozenOrientation == TarotCardOrientation.reversed
              ? UserText.tarotReversed
              : UserText.tarotUpright,
        ),
      );

      await tester.tap(find.text('공개로 돌아가기'));
      await tester.pumpAndSettle();
      expect(toggle, findsOneWidget);
      expect(tester.widget<IconButton>(toggle).onPressed, isNull);
      await tester.tap(toggle, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(visibleOrientation(), frozenVisibleOrientation);

      await tester.tap(
        find.byKey(const Key('tarot-open-interpretation-button')),
      );
      await tester.pumpAndSettle();
      expect(delivered, hasLength(1));
      expect(identical(delivered.single, first), isTrue);
      expect(delivered.single.readingInstanceId, first.readingInstanceId);
      expect(delivered.single.placements.single.orientation, frozenOrientation);

      await tester.tap(find.text(UserText.tarotResetDraw));
      await tester.pumpAndSettle();
      await openOneCardResult();
      expect(toggle, findsOneWidget);
      expect(tester.widget<IconButton>(toggle).onPressed, isNotNull);
      await tester.tap(
        find.byKey(const Key('tarot-open-interpretation-button')),
      );
      await tester.pumpAndSettle();
      expect(delivered, hasLength(2));
      expect(delivered.last.readingInstanceId, isNot(first.readingInstanceId));
    },
  );

  testWidgets('unsupported Tarot deck cannot start a recordable draw', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final delivered = <TarotReadingResultSnapshot>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TarotSpreadShell(
            onBack: () {},
            onResultCompleted: delivered.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('tarot-deck-carousel-card-thoth')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('tarot-unsupported-deck-message')),
      findsOneWidget,
    );
    expect(find.text(UserText.tarotDeckUnavailable), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('tarot-shuffle-button')))
          .onPressed,
      isNull,
    );
    expect(delivered, isEmpty);
    expect(find.byKey(const Key('tarot-full-deck-stage')), findsNothing);
  });

  testWidgets('actual Tarot result callback reaches Core Home summary', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.navReading).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('atelier-tarot-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, UserText.tarotSpreadOne));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tarot-open-interpretation-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tarot-back-button-strong')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.navHome).first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-actual-result-hero')), findsOneWidget);
    expect(
      find.textContaining(UserText.tarotSpreadOne),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('오늘 가장 먼저 비춰볼 질문'), findsOneWidget);
    expect(find.byKey(const Key('home-card-layout-one')), findsOneWidget);
    expect(find.textContaining('월'), findsWidgets);

    await tester.tap(find.byKey(const Key('home-primary-cta')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-result-detail-page')), findsOneWidget);
    expect(find.byKey(const Key('records-session-page')), findsNothing);

    await tester.tap(find.byKey(const Key('tarot-result-detail-back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('records-session-page')), findsOneWidget);
    expect(find.text('현재 홈에 표시 중'), findsOneWidget);

    await tester.tap(find.text(UserText.navHome).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-hide-result')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-empty-scene')), findsOneWidget);

    await tester.tap(find.text(UserText.navRecord).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('records-session-page')), findsOneWidget);
    expect(find.text('오늘 가장 먼저 비춰볼 질문'), findsOneWidget);
    expect(find.text('홈에 표시'), findsOneWidget);

    await tester.tap(find.text('상세 보기'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-result-detail-page')), findsOneWidget);
    await tester.tap(find.byKey(const Key('detail-show-on-home')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-actual-result-hero')), findsOneWidget);
  });

  test('Tarot snapshot bridge uses stable spread and selected-deck facts', () {
    final tarotSource = File(
      'lib/features/tarot/tarot_spread_shell.dart',
    ).readAsStringSync();
    final mainSource = File('lib/main.dart').readAsStringSync();
    final homeSource = File(
      'lib/features/home/presentation/home_tarot_hero.dart',
    ).readAsStringSync();

    expect(tarotSource.contains('String _selectedSpreadId'), isTrue);
    expect(tarotSource.contains('spread.id == selected'), isTrue);
    expect(tarotSource.contains('onSelected(spread.id)'), isTrue);
    expect(tarotSource.contains('spread.label == selected'), isFalse);
    expect(
      tarotSource.contains('_selectedDeck.cards.isEmpty ? _rwsCards'),
      isFalse,
    );
    expect(tarotSource.contains('selectedDeckCardIds:'), isTrue);
    expect(
      mainSource.contains('SessionTarotResults _sessionOnlyTarotResults'),
      isTrue,
    );
    expect(
      mainSource.contains(
        'widget.runtimeController?.sessionResults ?? _sessionOnlyTarotResults',
      ),
      isTrue,
    );
    expect(homeSource.contains('placement.cardNameSnapshot'), isTrue);
    expect(
      homeSource.contains('_resolveCard(deckId, placement.cardId)'),
      isTrue,
    );
    expect(homeSource.contains('The Hermit'), isFalse);
    expect(homeSource.contains('Justice'), isFalse);
    expect(homeSource.contains('The Star'), isFalse);
  });

  test('Tarot setup flow uses honest visible step keys only', () {
    final tarotShell = File(
      'lib/features/tarot/tarot_spread_shell.dart',
    ).readAsStringSync();

    expect(tarotShell.contains('tarot-global-flow-정리'), isFalse);
    expect(
      tarotShell.contains("key: Key('tarot-active-setup-step-1')"),
      isFalse,
    );
    expect(
      tarotShell.contains("key: Key('tarot-active-setup-step-2')"),
      isFalse,
    );
    expect(
      tarotShell.contains("key: Key('tarot-active-setup-step-3')"),
      isFalse,
    );
    expect(tarotShell.contains('stepIndex == 0 ? 5 : stepIndex + 1'), isFalse);
  });

  test('Tarot intake follows Midnight Atelier design-system markers', () {
    final tarotShell = File(
      'lib/features/tarot/tarot_spread_shell.dart',
    ).readAsStringSync();

    expect(tarotShell.contains('tarot-midnight-atelier-stepper'), isTrue);
    expect(tarotShell.contains('질문 준비'), isTrue);
    expect(tarotShell.contains('테이블'), isTrue);
    expect(tarotShell.contains('해석'), isTrue);
    expect(tarotShell.contains('tarot-free-question-hero-surface'), isTrue);
    expect(tarotShell.contains('tarot-reading-intake-receipt-card'), isTrue);
    expect(tarotShell.contains('오늘의 리딩 준비'), isTrue);
    expect(tarotShell.contains('프리미엄 리딩 준비'), isFalse);
    expect(tarotShell.contains('준비된 덱 자리'), isFalse);
    expect(tarotShell.contains('Icons.monetization_on_rounded'), isFalse);
    expect(tarotShell.contains('가능성과 조건을 봅니다'), isTrue);
    expect(tarotShell.contains('방향과 선택을 봅니다'), isTrue);
    expect(tarotShell.contains('내면의 신호를 봅니다'), isTrue);
    expect(
      tarotShell.contains('tarotAppBackground(BuildContext context)'),
      isTrue,
    );
    expect(tarotShell.contains('tarotPageShell(BuildContext context)'), isTrue);
    expect(
      tarotShell.contains('tarotReadingStage(BuildContext context)'),
      isTrue,
    );
    expect(
      tarotShell.contains('tarotInputField(BuildContext context)'),
      isTrue,
    );
    expect(
      tarotShell.contains('tarotSummaryPanel(BuildContext context)'),
      isTrue,
    );
    expect(
      tarotShell.contains('tarotPurpleAccent(BuildContext context)'),
      isTrue,
    );
    expect(
      tarotShell.contains('tarotLightBackground = Color(0xFFF7F3EC)'),
      isTrue,
    );
    expect(tarotShell.contains('tarotLightStage = Color(0xFFF1EDF8)'), isTrue);
    expect(tarotShell.contains('tarotLightPurple = Color(0xFF6E56A3)'), isTrue);
    expect(tarotShell.contains('tarot-light-intake-shell-surface'), isTrue);
    expect(tarotShell.contains('tarot-dark-reading-table-surface'), isTrue);
    expect(
      tarotShell.contains('tarot-reading-table-forced-dark-theme'),
      isTrue,
    );
    expect(
      tarotShell.contains('color: RynPalette.tarotTextPrimary(context)'),
      isTrue,
      reason: 'Light intake hero copy must use warm ink, not white text.',
    );
    expect(
      tarotShell.contains(
        'color: Colors.white,\n                  fontSize: 32',
      ),
      isFalse,
      reason: 'The light intake hero title must not remain white-on-pale.',
    );
    expect(
      tarotShell.contains("key: const Key('tarot-global-flow-nav')"),
      isFalse,
    );
  });

  test('Tarot table chrome polish keeps visual hierarchy markers', () {
    final tarotShell = File(
      'lib/features/tarot/tarot_spread_shell.dart',
    ).readAsStringSync();

    expect(tarotShell.contains('TAROT-TABLE-CHROME-POLISH1'), isTrue);
    expect(tarotShell.contains('tarot-table-chrome-polish-marker'), isTrue);
    expect(tarotShell.contains('tarot-status-chip-unified'), isTrue);
    expect(
      tarotShell.contains('primary reading-table action hierarchy'),
      isTrue,
    );
    expect(
      tarotShell.contains('secondary actions stay dark translucent'),
      isTrue,
    );
    expect(
      tarotShell.contains('context ribbon retained, readable, subdued'),
      isTrue,
    );
    expect(
      tarotShell.contains('tarot-reading-table-forced-dark-theme'),
      isTrue,
    );
    expect(tarotShell.contains('tarot-reading-context-ribbon'), isTrue);
    expect(tarotShell.contains('tarot-reading-command-bar'), isTrue);
    expect(tarotShell.contains('tarot-layout-adjustment-toolbar'), isTrue);
    expect(tarotShell.contains('AppData'), isFalse);
    expect(tarotShell.contains('schema'), isFalse);
    expect(tarotShell.contains('migration'), isFalse);
    expect(
      RegExp(
        r'''(?:Text\(|message:\s*|tooltip:\s*|semanticLabel:\s*)['"][^'"]*export''',
        caseSensitive: false,
      ).hasMatch(tarotShell),
      isFalse,
    );
    expect(tarotShell.contains('PDF'), isFalse);
    expect(tarotShell.contains('http'), isFalse);
  });

  test('Tarot result label polish is label-only and keeps table surface', () {
    final tarotShell = File(
      'lib/features/tarot/tarot_spread_shell.dart',
    ).readAsStringSync();

    expect(tarotShell.contains('TAROT-RESULT-LABEL-POLISH1'), isTrue);
    expect(tarotShell.contains('label-only polish'), isTrue);
    expect(tarotShell.contains('table surface unchanged'), isTrue);
    expect(
      tarotShell.contains("key: const Key('tarot-position-label')"),
      isTrue,
    );
    expect(
      tarotShell.contains('tarot-result-dark-table-retained-marker'),
      isFalse,
    );
    expect(tarotShell.contains('premium result spread table frame'), isFalse);
    expect(tarotShell.contains('AppData'), isFalse);
    expect(tarotShell.contains('schema'), isFalse);
    expect(tarotShell.contains('migration'), isFalse);
    expect(
      RegExp(
        r'''(?:Text\(|message:\s*|tooltip:\s*|semanticLabel:\s*)['"][^'"]*export''',
        caseSensitive: false,
      ).hasMatch(tarotShell),
      isFalse,
    );
    expect(tarotShell.contains('PDF'), isFalse);
    expect(tarotShell.contains('http'), isFalse);
  });

  test('Tarot card focus panel keeps selected card detail shell markers', () {
    final tarotShell = File(
      'lib/features/tarot/tarot_spread_shell.dart',
    ).readAsStringSync();

    expect(tarotShell.contains('TAROT-CARD-FOCUS-PANEL1'), isTrue);
    expect(tarotShell.contains('tarot-card-focus-panel-marker'), isTrue);
    expect(tarotShell.contains('focused card detail panel'), isTrue);
    expect(tarotShell.contains('selected card preview retained'), isTrue);
    expect(tarotShell.contains('tarot-card-focus-reading-prompt'), isTrue);
    expect(tarotShell.contains('RWS 계열 ·'), isTrue);
    expect(tarotShell.contains('RWS 이미지 ·'), isFalse);
    expect(tarotShell.contains('tarot-reading-context-ribbon'), isTrue);
    expect(tarotShell.contains('AppData'), isFalse);
    expect(tarotShell.contains('schema'), isFalse);
    expect(tarotShell.contains('migration'), isFalse);
    expect(
      RegExp(
        r'''(?:Text\(|message:\s*|tooltip:\s*|semanticLabel:\s*)['"][^'"]*export''',
        caseSensitive: false,
      ).hasMatch(tarotShell),
      isFalse,
    );
    expect(tarotShell.contains('PDF'), isFalse);
    expect(tarotShell.contains('http'), isFalse);
  });

  test(
    'Tarot interpretation story workspace removes duplicate question and expands preview',
    () {
      final tarotShell = File(
        'lib/features/tarot/tarot_spread_shell.dart',
      ).readAsStringSync();
      final interpretationStageStart = tarotShell.indexOf(
        'class _TarotInterpretationStage',
      );
      final interpretationShellStart = tarotShell.indexOf(
        'class _TarotInterpretationShell',
      );
      final interpretationStageSource = tarotShell.substring(
        interpretationStageStart,
        interpretationShellStart,
      );

      expect(
        tarotShell.contains('tarot-interpretation-story-workspace'),
        isTrue,
      );
      expect(
        tarotShell.contains('tarot-interpretation-spread-snapshot-preview'),
        isTrue,
      );
      expect(
        tarotShell.contains('tarot-interpretation-snapshot-image'),
        isTrue,
      );
      expect(
        tarotShell.contains('tarot-interpretation-deduped-question-context'),
        isTrue,
      );
      expect(
        tarotShell.contains('tarot-interpretation-expanded-workspace'),
        isTrue,
      );
      expect(tarotShell.contains('tarot-interpretation-font-audit'), isTrue);
      expect(
        interpretationStageSource.contains('_TarotReadingContextRibbon'),
        isFalse,
      );
      expect(tarotShell.contains('height: 660'), isTrue);
      expect(
        tarotShell.contains('const BoxConstraints(minHeight: 660)'),
        isTrue,
      );
      expect(tarotShell.contains('this.bounded = false'), isTrue);
      expect(
        tarotShell.contains('tarot-interpretation-story-notes-panel'),
        isTrue,
      );
      expect(
        tarotShell.contains('tarot-interpretation-in-memory-note'),
        isTrue,
      );
      expect(tarotShell.contains('no-persistence-interpretation-note'), isTrue);
      expect(tarotShell.contains('Image.memory'), isTrue);
      expect(tarotShell.contains('BoxFit.contain'), isTrue);
      expect(tarotShell.contains('spreadSnapshotBytes'), isTrue);
      expect(
        tarotShell.contains('Uint8List? _interpretationSnapshotBytes'),
        isTrue,
      );
      expect(tarotShell.contains('_captureTarotResultBoardPng'), isTrue);
      expect(tarotShell.contains('스프레드 이미지를 준비하지 못했습니다'), isTrue);
      expect(
        tarotShell.contains('tarot-interpretation-spread-preview-card'),
        isFalse,
      );
      expect(
        tarotShell.contains('_PositionedInterpretationPreviewCard'),
        isFalse,
      );
      expect(tarotShell.contains('interpretation_history'), isFalse);
      expect(tarotShell.contains('saveInterpretation'), isFalse);
      expect(tarotShell.contains('writeInterpretation'), isFalse);
      expect(tarotShell.contains('_writeTarotResultBoardPng'), isTrue);
      expect(tarotShell.contains('Downloads'), isTrue);
      expect(tarotShell.contains('오늘의 질문'), isTrue);
      expect(tarotShell.contains('이번 리딩의 주제'), isTrue);
      expect(tarotShell.contains('전체 이미지 관찰'), isTrue);
      expect(tarotShell.contains('흐름 해석'), isTrue);
      expect(tarotShell.contains('핵심 메시지'), isTrue);
      expect(tarotShell.contains('오늘의 조언 / 작은 실천'), isTrue);
      expect(
        tarotShell.contains('결과와 해석 화면을 오가는 동안 유지되며, 앱을 닫으면 비워집니다'),
        isTrue,
      );
      expect(
        tarotShell.contains('각 카드를 자세히 보려면 결과 보드에서 카드를 눌러 집중 보기를 여세요'),
        isTrue,
      );
      expect(tarotShell.contains('카드별 상세 의미 보기는 다음 업데이트에서 열립니다'), isFalse);
      expect(tarotShell.contains('카드별 상세 의미는 이후 DB 연결 뒤 팝업'), isFalse);
      expect(tarotShell.contains('결과 보드 snapshot의 장면'), isFalse);
      expect(tarotShell.contains('이후 DB 연결'), isFalse);
      expect(tarotShell.contains('AppData'), isFalse);
      expect(tarotShell.contains('schema'), isFalse);
      expect(tarotShell.contains('migration'), isFalse);
      expect(tarotShell.contains('PDF'), isFalse);
      expect(tarotShell.contains('http'), isFalse);
    },
  );

  test('Tarot result board PNG save keeps board-only capture markers', () {
    final tarotShell = File(
      'lib/features/tarot/tarot_spread_shell.dart',
    ).readAsStringSync();

    expect(tarotShell.contains('TAROT-READING-IMAGE-EXPORT1'), isTrue);
    expect(tarotShell.contains('tarot-save-result-image-button'), isTrue);
    expect(tarotShell.contains('이미지 저장'), isTrue);
    expect(tarotShell.contains('tarot-result-export-boundary'), isTrue);
    expect(tarotShell.contains('RenderRepaintBoundary'), isTrue);
    expect(tarotShell.contains('ui.ImageByteFormat.png'), isTrue);
    expect(tarotShell.contains('tarot_result_'), isTrue);
    expect(tarotShell.contains('Downloads'), isTrue);
    expect(tarotShell.contains('tarot-reading-context-ribbon'), isTrue);
    expect(tarotShell.contains('tarot-focus-detail-overlay'), isTrue);
    expect(
      tarotShell.contains('TAROT-READING-IMAGE-EXPORT1-R3-FLICKER-FIX'),
      isTrue,
    );
    expect(tarotShell.contains('class _TarotResultStageState'), isTrue);
    expect(tarotShell.contains('final GlobalKey _imageBoundaryKey'), isTrue);
    expect(
      tarotShell.contains('captureBoundaryKey: _imageBoundaryKey'),
      isTrue,
    );
    expect(tarotShell.contains('boundaryKey: _imageBoundaryKey'), isTrue);
    expect(tarotShell.contains('final imageBoundaryKey = GlobalKey'), isFalse);
    final captureMarker = tarotShell.indexOf(
      "key: const Key('tarot-result-export-boundary')",
    );
    final adjustmentToolbar = tarotShell.indexOf(
      'child: _TarotFloatingAdjustmentControls(',
    );
    expect(captureMarker, isNonNegative);
    expect(adjustmentToolbar, isNonNegative);
    expect(captureMarker, lessThan(adjustmentToolbar));
    expect(tarotShell.contains('AppData'), isFalse);
    expect(tarotShell.contains('schema'), isFalse);
    expect(tarotShell.contains('migration'), isFalse);
    expect(tarotShell.contains('PDF'), isFalse);
    expect(tarotShell.contains('http'), isFalse);
  });

  testWidgets(
    'Tarot result export boundary contains artwork but excludes interactive UI',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TarotSpreadShell(onBack: () {})),
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
      await tester.ensureVisible(find.text('다음'));
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('tarot-result-card-back-slot')).first,
      );
      await tester.pumpAndSettle();

      final boundary = find.byKey(const Key('tarot-result-export-boundary'));
      final overlay = find.byKey(const Key('tarot-result-interactive-overlay'));
      final directionControl = find.byKey(
        const Key('tarot-result-direction-toggle-0'),
      );
      final artwork = find.byKey(const Key('tarot-export-card-artwork-0'));
      final positionLabel = find.byKey(
        const Key('tarot-export-position-label-one_center'),
      );

      expect(boundary, findsOneWidget);
      expect(overlay, findsOneWidget);
      expect(directionControl, findsOneWidget);
      expect(artwork, findsOneWidget);
      expect(positionLabel, findsOneWidget);
      expect(
        find.descendant(of: boundary, matching: directionControl),
        findsNothing,
      );
      expect(find.descendant(of: boundary, matching: overlay), findsNothing);
      expect(find.descendant(of: boundary, matching: artwork), findsOneWidget);
      expect(
        find.descendant(of: boundary, matching: positionLabel),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: boundary,
          matching: find.byKey(const Key('tarot-layout-adjustment-toolbar')),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: boundary,
          matching: find.byKey(const Key('tarot-save-result-image-button')),
        ),
        findsNothing,
      );
      expect(
        find.descendant(of: boundary, matching: find.byType(Tooltip)),
        findsNothing,
      );

      final repaintBoundary = find
          .ancestor(of: boundary, matching: find.byType(RepaintBoundary))
          .first;
      expect(repaintBoundary, findsOneWidget);
      final renderBoundary = tester.renderObject<RenderRepaintBoundary>(
        repaintBoundary,
      );
      final image = await renderBoundary.toImage(pixelRatio: 1);
      expect(image.width, greaterThan(0));
      expect(image.height, greaterThan(0));
      image.dispose();

      final beforeToggleRect = tester.getRect(artwork);
      await tester.tap(directionControl);
      await tester.pumpAndSettle();
      expect(directionControl, findsOneWidget);
      expect(tester.getRect(artwork), beforeToggleRect);
    },
  );

  test('text registries keep user copy separated from developer copy', () {
    final userTextFile = File('lib/core/text/user_text.dart');
    final devTextFile = File('lib/core/text/dev_text.dart');
    final internalTextFile = File('lib/core/text/internal_text.dart');
    expect(userTextFile.existsSync(), isTrue);
    expect(devTextFile.existsSync(), isTrue);
    expect(internalTextFile.existsSync(), isTrue);

    final userText = userTextFile.readAsStringSync();
    final userVisibleStrings =
        RegExp(
              r'''static const (?:\w+\s+)?\w+\s*=\s*('(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*")\s*;''',
            )
            .allMatches(userText)
            .map((match) {
              final literal = match.group(1) ?? '';
              return literal.substring(1, literal.length - 1);
            })
            .join('\n');
    const rawDeveloperTerms = <String>[
      'DB',
      'schema',
      'migration',
      'runtime',
      'AppData',
      'Drift',
      'CRUD',
      'HOLD',
      'guard',
      'Git',
      'Codex',
      'Hermes',
      'token',
      'QA',
      'shell',
      'static',
      'implementation',
      'persistence',
      'Minimum Viable Core',
      '화면 구성',
      '선택한 화면',
      '9개 화면',
      '보관 전',
    ];
    for (final term in rawDeveloperTerms) {
      expect(
        userVisibleStrings.contains(term),
        isFalse,
        reason: 'UserText visible string contains $term',
      );
    }

    expect(UserText.navHome, '홈');
    expect(UserText.navPeople, '사람');
    expect(UserText.navReading, '리딩');
    expect(UserText.studyOsTitle, 'Ryn Study OS 2.0');

    final studyShell = File(
      'lib/features/study_os/study_os_shell.dart',
    ).readAsStringSync();
    expect(studyShell.contains('dev_text.dart'), isFalse);
  });

  test('production typography uses bundled Pretendard', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(RynFonts.text, 'Pretendard');
    expect(RynFonts.display, 'Pretendard');
    expect(RynFonts.rounded, 'Pretendard');
    expect(RynFonts.textFallback, contains('Malgun Gothic'));
    expect(pubspec.contains('family: Pretendard'), isTrue);
    expect(
      pubspec.contains('assets/fonts/pretendard/Pretendard-Regular.otf'),
      isTrue,
    );
    expect(
      File('assets/fonts/pretendard/Pretendard-Regular.otf').existsSync(),
      isTrue,
    );
  });

  group('Cinematic Home scene', () {
    Future<void> pumpScene(
      WidgetTester tester, {
      TarotReadingResultSnapshot? result,
      Brightness brightness = Brightness.light,
      Size size = const Size(1440, 900),
      VoidCallback? onOpenRecords,
      VoidCallback? onStartSelfTarot,
      VoidCallback? onOpenPeople,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness, useMaterial3: true),
          home: Scaffold(
            body: HomeCinematicScene(
              activeTarotResult: result,
              onOpenRecords: onOpenRecords ?? () {},
              onStartSelfTarot: onStartSelfTarot ?? () {},
              onOpenPeople: onOpenPeople ?? () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders actual result as the dominant ordered Tarot Hero', (
      tester,
    ) async {
      final snapshot = _homeSnapshot();
      var recordsOpened = false;
      await pumpScene(
        tester,
        result: snapshot,
        onOpenRecords: () => recordsOpened = true,
      );

      expect(find.byKey(const Key('home-actual-result-hero')), findsOneWidget);
      expect(find.text('방금 완료한 셀프 타로'), findsOneWidget);
      expect(find.text(snapshot.readingQuestionText), findsOneWidget);
      expect(find.text(snapshot.deckNameSnapshot), findsOneWidget);
      expect(find.text(snapshot.spreadNameSnapshot), findsOneWidget);
      expect(find.byKey(const Key('home-card-layout-three')), findsOneWidget);
      for (final placement in snapshot.placements) {
        expect(
          find.byKey(Key('home-card-placement-${placement.placementOrder}')),
          findsOneWidget,
        );
        expect(find.text(placement.positionNameSnapshot), findsOneWidget);
      }
      expect(find.text('역방향'), findsOneWidget);
      expect(find.byKey(const Key('home-primary-cta')), findsOneWidget);
      expect(find.text('결과 자세히 보기'), findsOneWidget);
      await tester.tap(find.byKey(const Key('home-primary-cta')));
      expect(recordsOpened, isTrue);
    });

    testWidgets('renders one and multi-card policies without a dashboard row', (
      tester,
    ) async {
      await pumpScene(tester, result: _homeSnapshot(cardCount: 1));
      expect(find.byKey(const Key('home-card-layout-one')), findsOneWidget);
      expect(find.text('오늘 볼 사람'), findsNothing);
      expect(find.text('이어보기'), findsNothing);
      expect(find.text('작은 메모'), findsNothing);
      expect(find.text('사람을 먼저 고르고, 질문과 렌즈로 오늘의 흐름을 엽니다.'), findsNothing);

      await pumpScene(tester, result: _homeSnapshot(cardCount: 8));
      expect(find.byKey(const Key('home-card-layout-multi')), findsOneWidget);
      expect(find.text('전체 배열 보기'), findsOneWidget);
      expect(find.byKey(const Key('home-card-placement-8')), findsOneWidget);
    });

    testWidgets('uses neutral snapshot fallback when Registry lookup fails', (
      tester,
    ) async {
      await pumpScene(tester, result: _homeSnapshot(missingRegistryCard: true));
      expect(
        find.byKey(const Key('home-card-neutral-fallback')),
        findsOneWidget,
      );
      expect(find.text('Missing Snapshot Card'), findsOneWidget);
    });

    testWidgets('renders one coherent no-result scene and opens self Tarot', (
      tester,
    ) async {
      var selfTarotOpened = false;
      var peopleOpened = false;
      await pumpScene(
        tester,
        onStartSelfTarot: () => selfTarotOpened = true,
        onOpenPeople: () => peopleOpened = true,
      );

      expect(find.byKey(const Key('home-empty-scene')), findsOneWidget);
      expect(find.text('오늘의 성장 흐름'), findsOneWidget);
      expect(find.text('오늘의 흐름을 천천히 열어보세요'), findsOneWidget);
      expect(find.text('새 셀프 타로 시작'), findsOneWidget);
      expect(find.byKey(const Key('home-primary-cta')), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
      expect(find.textContaining('통계'), findsNothing);
      expect(find.textContaining('이전 리딩'), findsNothing);
      await tester.tap(find.byKey(const Key('home-primary-cta')));
      expect(selfTarotOpened, isTrue);
      await tester.tap(find.text('사람과 만남'));
      expect(peopleOpened, isTrue);
    });

    testWidgets('handles long questions, compact desktop, Light and Dark', (
      tester,
    ) async {
      const longQuestion =
          '지금 내가 오랫동안 놓치고 있던 마음의 방향을 다시 바라보고 앞으로의 작은 선택을 어떻게 이어가면 좋을까?';
      await pumpScene(
        tester,
        result: _homeSnapshot(question: longQuestion),
        size: const Size(1280, 720),
      );
      expect(find.text(longQuestion), findsOneWidget);
      expect(find.text('질문 전체 보기'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await pumpScene(
        tester,
        result: _homeSnapshot(),
        brightness: Brightness.dark,
        size: const Size(1280, 720),
      );
      expect(find.byKey(const Key('home-cinematic-scene')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('renders clean action Home, practical menu, and theme control', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();

    const menuLabels = <String>[
      UserText.navHome,
      UserText.navOperating,
      UserText.navPeople,
      UserText.navStudy,
      UserText.navReading,
      UserText.navPractice,
      UserText.navContent,
      UserText.navRecord,
      UserText.navOutput,
      UserText.navAi,
      UserText.navSettings,
    ];

    for (final label in menuLabels) {
      expect(find.text(label), findsAtLeastNWidgets(1));
    }

    expect(find.byKey(const Key('home-cinematic-scene')), findsOneWidget);
    expect(find.text('오늘의 성장 흐름'), findsOneWidget);
    expect(find.text('오늘의 흐름을 천천히 열어보세요'), findsOneWidget);
    expect(find.text('새 셀프 타로 시작'), findsOneWidget);
    expect(find.text('오늘 볼 사람'), findsNothing);
    expect(find.text('이어보기'), findsNothing);
    expect(find.text('작은 메모'), findsNothing);
    expect(find.text(UserText.homeToday), findsNothing);
    expect(find.text(UserText.homeThisWeek), findsNothing);
    expect(find.text(UserText.homeQuickLinks), findsNothing);
    expect(find.text(UserText.homeStudyOps), findsNothing);
    expect(find.text(UserText.homeReadingPractice), findsNothing);
    expect(find.text('Ryn Business OS'), findsNothing);
    expect(
      find.text('수업, 상담, 자료, 기록, 산출물을 한 화면에서 준비하는 개인 운영 허브'),
      findsNothing,
    );
    expect(find.text('운영 모듈'), findsNothing);
    expect(find.text('Calm'), findsNothing);
    expect(find.text('Control'), findsNothing);
    expect(find.text('Continuity'), findsNothing);
    expect(find.text('Local-First'), findsNothing);
    expect(find.text('AI-Native'), findsNothing);
    expect(find.text('AI Command Center'), findsNothing);

    await tester.tap(find.text(UserText.navSettings).first);
    await tester.pumpAndSettle();

    expect(find.textContaining('검색 / 자료 / 기록 / 일정'), findsOneWidget);
    expect(find.text(UserText.themeSettingTitle), findsOneWidget);
    expect(find.text(UserText.themeLight), findsAtLeastNWidgets(1));
    expect(find.text(UserText.themeDark), findsAtLeastNWidgets(1));
    expect(find.text(UserText.themeSystem), findsAtLeastNWidgets(1));
  });

  testWidgets('native people session flow and records archive follow v0.2 IA', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text(UserText.navPeople).first);
    await tester.pumpAndSettle();

    expect(find.text('샘플 사람 A'), findsAtLeastNWidgets(1));
    expect(find.text('이해 지도'), findsAtLeastNWidgets(1));
    expect(find.text('타고난 기질'), findsOneWidget);
    expect(find.text('현재의 흐름'), findsOneWidget);
    expect(find.text('성장 여정'), findsOneWidget);

    await tester.tap(find.text('새 만남 시작').first);
    await tester.pumpAndSettle();

    expect(find.text('새 만남 빠른 시작'), findsOneWidget);
    expect(find.text(UserText.quickStartGuidance), findsOneWidget);
    expect(find.text('샘플 사람 A'), findsAtLeastNWidgets(1));
    expect(find.text('타로 리딩'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('quick-start-question-field')), findsOneWidget);
    expect(find.text('자세히 설정'), findsOneWidget);
    expect(find.byKey(const Key('quick-start-begin-button')), findsOneWidget);
    expect(find.text('오늘 어떤 만남을 시작할까요?'), findsNothing);
    expect(find.text('누구와 만날까요?'), findsNothing);

    await tester.tap(find.byKey(const Key('quick-start-begin-button')));
    await tester.pumpAndSettle();
    expect(find.text('타로 리딩 미리보기'), findsOneWidget);
    expect(find.text('흐름에 반영'), findsOneWidget);
    expect(find.textContaining('아직 저장하지 않음'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text(UserText.navRecord).first);
    await tester.pumpAndSettle();

    expect(find.text('나의 성장 기록'), findsOneWidget);
    expect(find.text('이번 실행에서 완료한 리딩을 살펴봅니다.'), findsOneWidget);
    expect(find.text('아직 완료한 리딩이 없습니다'), findsOneWidget);
    expect(find.text('새 셀프 타로 시작'), findsOneWidget);
    expect(find.text('샘플 사람 A'), findsNothing);
    expect(find.text('만남 기록'), findsNothing);
    expect(find.text('리딩 기록'), findsNothing);
    expect(find.text('기록 홈'), findsNothing);
    expect(find.text('Group Session'), findsNothing);
  });

  testWidgets(
    'quick start sheet uses nav context defaults without 5 step wizard',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const RynUniverseApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text(UserText.navPeople).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('새 만남 시작').first);
      await tester.pumpAndSettle();
      expect(find.text(UserText.quickStartGuidance), findsOneWidget);
      expect(find.text('오늘 어떤 만남을 시작할까요?'), findsNothing);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text(UserText.navReading).first);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('reading-atelier-page')), findsOneWidget);
      expect(find.byKey(const Key('reading-atelier-scene')), findsOneWidget);
      expect(find.byKey(const Key('atelier-tarot-doorway')), findsOneWidget);
      expect(find.byKey(const Key('atelier-oracle-doorway')), findsOneWidget);
      expect(find.byKey(const Key('atelier-tarot-action')), findsOneWidget);
      expect(find.byKey(const Key('atelier-oracle-action')), findsOneWidget);
      expect(find.text(UserText.quickStartGuidance), findsNothing);
    },
  );

  testWidgets('in-memory tarot loop reflects into Home People and Records', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text(UserText.navPeople).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('새 만남 시작').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('quick-start-question-field')),
      '지금 선택의 기준은?',
    );
    await tester.tap(find.byKey(const Key('quick-start-begin-button')));
    await tester.pumpAndSettle();

    expect(find.text('타로 리딩 미리보기'), findsOneWidget);
    expect(find.textContaining('The Hermit'), findsOneWidget);
    expect(find.textContaining('Justice'), findsOneWidget);
    expect(find.textContaining('The Star'), findsOneWidget);
    expect(find.byKey(const Key('tarot-loop-memo-field')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('tarot-loop-memo-field')),
      '오늘은 기준을 좁혀본다.',
    );
    await tester.tap(find.byKey(const Key('tarot-loop-reflect-button')));
    await tester.pumpAndSettle();

    expect(find.textContaining('현재의 흐름에 표시했습니다'), findsOneWidget);
    expect(find.textContaining('이번 실행에서만 이어집니다'), findsOneWidget);
    expect(find.text('저장되었습니다'), findsNothing);
    expect(find.textContaining('DB', findRichText: true), findsNothing);
    expect(find.textContaining('schema', findRichText: true), findsNothing);
    expect(find.textContaining('CRUD', findRichText: true), findsNothing);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('현재의 흐름'), findsOneWidget);
    expect(find.text('현재 질문 · 지금 선택의 기준은?'), findsOneWidget);

    await tester.tap(find.text(UserText.navPeople).first);
    await tester.pumpAndSettle();

    expect(find.text('현재의 흐름'), findsOneWidget);
    expect(find.text('타로 리딩 · 방금 이어본 질문 있음'), findsOneWidget);
    expect(find.text('현재 질문 · 지금 선택의 기준은?'), findsOneWidget);
    expect(find.text('다음에 볼 것 · 현재의 흐름 다시 보기'), findsOneWidget);

    await tester.tap(find.text(UserText.navRecord).first);
    await tester.pumpAndSettle();

    expect(find.text('아직 완료한 리딩이 없습니다'), findsOneWidget);
    expect(find.textContaining('대상: 샘플 사람 A'), findsNothing);
    expect(find.textContaining('아직 저장하지 않음 / preview'), findsNothing);
    expect(find.text('오늘 어떤 만남을 시작할까요?'), findsNothing);
  });

  testWidgets('People Quick Start reflects each available selected target', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const targets = ['샘플 사람 A', '샘플 사람 B', '나의 기록', '스터디 참여자'];
    for (final target in targets) {
      await tester.pumpWidget(const RynUniverseApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.navPeople).first);
      await tester.pumpAndSettle();

      final peopleList = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_PeopleListPanel',
      );
      await tester.tap(
        find.descendant(of: peopleList, matching: find.text(target)).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('새 만남 시작').first);
      await tester.pumpAndSettle();

      final dialog = find.byType(Dialog);
      expect(
        find.descendant(of: dialog, matching: find.text(target)),
        findsOneWidget,
        reason: target,
      );
      await tester.enterText(
        find.byKey(const Key('quick-start-question-field')),
        '$target 확인',
      );
      await tester.tap(find.byKey(const Key('quick-start-begin-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tarot-loop-reflect-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('현재 질문 · $target 확인'), findsOneWidget);
      await tester.tap(find.text(UserText.navHome).first);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('home-empty-scene')), findsOneWidget);
      expect(find.textContaining('$target · 타로 리딩'), findsNothing);

      await tester.tap(find.text(UserText.navRecord).first);
      await tester.pumpAndSettle();
      expect(find.text('아직 완료한 리딩이 없습니다'), findsOneWidget);
      expect(find.textContaining('대상: $target'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });

  testWidgets(
    'unsupported Quick Start lens stays disabled and preserves prior preview',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const RynUniverseApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.navPeople).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('새 만남 시작').first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('quick-start-question-field')),
        '기존 질문 유지',
      );
      await tester.tap(find.byKey(const Key('quick-start-begin-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tarot-loop-reflect-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.text('현재 질문 · 기존 질문 유지'), findsOneWidget);

      await tester.tap(find.text('새 만남 시작').first);
      await tester.pumpAndSettle();
      final dialog = find.byType(Dialog);
      await tester.tap(
        find.descendant(of: dialog, matching: find.text('샘플 사람 A')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('샘플 사람 B').last);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: dialog, matching: find.text('타로 리딩')).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('상담 메모').last);
      await tester.pumpAndSettle();

      expect(find.text(UserText.quickStartUnsupportedLens), findsOneWidget);
      final begin = tester.widget<FilledButton>(
        find.byKey(const Key('quick-start-begin-button')),
      );
      expect(begin.onPressed, isNull);
      expect(find.text('타로 리딩 미리보기'), findsNothing);
      expect(find.text('흐름에 반영'), findsNothing);
      expect(find.textContaining('현재의 흐름에 표시했습니다'), findsNothing);

      await tester.tap(find.text('자세히 설정'));
      await tester.pumpAndSettle();
      expect(find.text(UserText.quickStartGuidance), findsOneWidget);
      expect(find.textContaining('wizard'), findsNothing);
      expect(find.textContaining('UX'), findsNothing);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.text('타로 리딩 · 방금 이어본 질문 있음'), findsOneWidget);
      expect(find.text('현재 질문 · 기존 질문 유지'), findsOneWidget);
      expect(find.textContaining('샘플 사람 B · 상담 메모'), findsNothing);
    },
  );

  testWidgets('keeps normal user surfaces free of developer wording', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();

    expect(find.text('오늘의 성장 흐름'), findsAtLeastNWidgets(1));
    expect(find.text('AI Command Center'), findsNothing);
    expect(find.text('Chief / Governance Deck'), findsNothing);
    expect(find.text('Safety Status Strip'), findsNothing);
    expect(find.text('DB CLOSED / NO WRITE'), findsNothing);
    expect(find.textContaining('HOLD', findRichText: true), findsNothing);
    expect(find.textContaining('runtime', findRichText: true), findsNothing);
    expect(find.textContaining('CRUD', findRichText: true), findsNothing);

    await tester.tap(find.text(UserText.navOperating).first);
    await tester.pumpAndSettle();

    expect(find.text(UserText.operatingAreaTitle), findsAtLeastNWidgets(1));
    expect(find.text('AI Command Center'), findsNothing);
    expect(find.textContaining('DB', findRichText: true), findsNothing);
  });

  testWidgets('renders compact 364px client layout without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(364, 1129);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.navAi).first);
    await tester.pumpAndSettle();

    expect(find.text(UserText.aiWorkbenchTitle), findsAtLeastNWidgets(1));
    expect(find.text(UserText.aiWorkbenchCue), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text(UserText.aiWorkbenchReview));
    await tester.pumpAndSettle();

    expect(find.text(UserText.aiWorkbenchReview), findsAtLeastNWidgets(1));
    expect(find.text(UserText.aiWorkbenchApproved), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'contains Home canvas inside desktop capture while staying wider than mobile cap',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(2400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const RynUniverseApp());
      await tester.pumpAndSettle();

      final businessHomeRect = tester.getRect(
        find.byKey(const Key('home-cinematic-scene')),
      );

      expect(businessHomeRect.width, greaterThan(1100));
      expect(businessHomeRect.width, lessThanOrEqualTo(1700));
      expect(businessHomeRect.right, lessThanOrEqualTo(2400));
      expect(find.text('오늘의 성장 흐름'), findsAtLeastNWidgets(1));
      expect(find.text('오늘 볼 사람'), findsNothing);
      expect(find.text('이어보기'), findsNothing);
      expect(find.text('작은 메모'), findsNothing);

      await tester.tap(find.text(UserText.navOperating).first);
      await tester.pumpAndSettle();
      final workspaceRect = tester.getRect(
        find
            .byWidgetPredicate(
              (widget) => widget.runtimeType.toString() == '_BusinessAreaPage',
            )
            .first,
      );
      expect((businessHomeRect.width - workspaceRect.width).abs(), lessThan(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('primary navigation opens study and reading homes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(UserText.navStudy).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.navStudy).last);
    await tester.pumpAndSettle();
    expect(find.text(UserText.studyWorkspaceTitle), findsAtLeastNWidgets(1));
    expect(find.text('새 만남 시작'), findsOneWidget);

    await tester.ensureVisible(find.text(UserText.navHome).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.navHome).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(UserText.navReading).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.navReading).last);
    await tester.pumpAndSettle();
    expect(find.text(UserText.readingWorkspaceTitle), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('reading-atelier-page')), findsOneWidget);
    expect(find.byKey(const Key('reading-atelier-scene')), findsOneWidget);
    expect(find.byKey(const Key('atelier-tarot-doorway')), findsOneWidget);
    expect(find.byKey(const Key('atelier-oracle-doorway')), findsOneWidget);
    expect(find.byKey(const Key('atelier-tarot-action')), findsOneWidget);
    expect(find.byKey(const Key('atelier-oracle-action')), findsOneWidget);
  });

  testWidgets(
    'Tarot intake navigation preserves values and summarizes caution',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('tarot-active-setup-step-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-midnight-atelier-stepper')),
        findsOneWidget,
      );
      expect(find.text('질문 준비'), findsOneWidget);
      expect(find.text('테이블'), findsOneWidget);
      expect(find.text('해석'), findsAtLeastNWidgets(1));
      expect(find.byKey(const Key('tarot-intro-panel')), findsOneWidget);
      expect(find.text('바로 덱 선택'), findsOneWidget);
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('tarot-active-setup-step-1')),
        findsOneWidget,
      );
      expect(find.text('연애'), findsOneWidget);
      expect(find.text('자유 질문'), findsOneWidget);
      for (final categoryLabel in [
        '연애',
        '금전',
        '일·승진·진로',
        '관계',
        '가족',
        '영적 성장',
        '예·아니오',
        '시기',
        '선택',
        '자유 질문',
      ]) {
        expect(find.text(categoryLabel), findsOneWidget);
      }
      final stageRect = tester.getRect(
        find.byKey(const Key('tarot-unified-intake-stage-frame')),
      );
      final freeQuestionCardRect = tester.getRect(
        find.byKey(const ValueKey('tarot-question-category-open_question')),
      );
      expect(freeQuestionCardRect.bottom <= stageRect.bottom, isTrue);
      await tester.tap(
        find.byKey(const ValueKey('tarot-question-category-money')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('tarot-active-setup-step-2')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-free-question-hero-surface')),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const Key('tarot-free-question-input')),
        '내 마음이 제일 먼저 묻고 싶은 것은 무엇일까요?',
      );
      await tester.enterText(
        find.byKey(const Key('tarot-question-title-input')),
        '이번 선택의 핵심',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-active-setup-step-3')),
        findsOneWidget,
      );
      await tester.tap(find.text('이전'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-active-setup-step-2')),
        findsOneWidget,
      );
      expect(find.text('내 마음이 제일 먼저 묻고 싶은 것은 무엇일까요?'), findsOneWidget);
      expect(find.text('이번 선택의 핵심'), findsOneWidget);

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('tarot-session-context-input')),
        '짧고 차분한 상담 흐름이 필요합니다.',
      );
      await tester.enterText(
        find.byKey(const Key('tarot-sensitivity-note-input')),
        '확정적으로 단정하지 않기',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('tarot-active-setup-step-4')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-reading-intake-receipt-card')),
        findsOneWidget,
      );
      expect(find.text('금전'), findsAtLeastNWidgets(1));
      expect(find.text('내 마음이 제일 먼저 묻고 싶은 것은 무엇일까요?'), findsAtLeastNWidgets(1));
      expect(find.text('이번 선택의 핵심'), findsAtLeastNWidgets(1));
      expect(find.text('짧고 차분한 상담 흐름이 필요합니다.'), findsAtLeastNWidgets(1));
      expect(find.text('확정적으로 단정하지 않기'), findsAtLeastNWidgets(1));
      await tester.ensureVisible(find.text('덱과 스프레드 선택하기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('덱과 스프레드 선택하기'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-active-setup-step-5')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tarot-deck-carousel')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Tarot reading context follows the question into later flow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('tarot-question-category-money')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('tarot-free-question-input')),
      '지금 선택에서 가장 조심해서 볼 흐름은 무엇일까요?',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('tarot-querent-alias-input')),
      '린',
    );
    await tester.enterText(
      find.byKey(const Key('tarot-sensitivity-note-input')),
      '결과를 단정하지 않기',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('덱과 스프레드 선택하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('덱과 스프레드 선택하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('tarot-reading-context-ribbon')),
      findsOneWidget,
    );
    expect(find.text('오늘의 질문'), findsOneWidget);
    expect(find.text('“지금 선택에서 가장 조심해서 볼 흐름은 무엇일까요?”'), findsOneWidget);
    expect(find.textContaining('금전'), findsWidgets);
    expect(find.textContaining('린'), findsWidgets);
    expect(find.textContaining('결과를 단정하지 않기'), findsWidgets);
    expect(find.textContaining('AppData'), findsNothing);
    expect(find.textContaining('persistence'), findsNothing);

    await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('tarot-reading-context-ribbon')),
      findsOneWidget,
    );
    expect(find.text('“지금 선택에서 가장 조심해서 볼 흐름은 무엇일까요?”'), findsOneWidget);

    await tester.tap(find.text('해석 보기'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tarot-reading-context-ribbon')), findsNothing);
    expect(
      find.byKey(const Key('tarot-interpretation-context-summary')),
      findsOneWidget,
    );
    expect(
      find.text('“지금 선택에서 가장 조심해서 볼 흐름은 무엇일까요?”'),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('Reading workspace opens RWS Tarot draw flow without storage', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();

    const menuLabels = <String>[
      UserText.navHome,
      UserText.navOperating,
      UserText.navPeople,
      UserText.navStudy,
      UserText.navReading,
      UserText.navPractice,
      UserText.navContent,
      UserText.navRecord,
      UserText.navOutput,
      UserText.navAi,
      UserText.navSettings,
    ];
    for (final label in menuLabels) {
      expect(find.text(label), findsAtLeastNWidgets(1));
    }

    await tester.tap(find.text(UserText.navReading).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reading-atelier-page')), findsOneWidget);
    expect(find.byKey(const Key('reading-atelier-scene')), findsOneWidget);
    expect(find.byKey(const Key('atelier-tarot-doorway')), findsOneWidget);
    expect(find.byKey(const Key('atelier-oracle-doorway')), findsOneWidget);

    await tester.tap(find.byKey(const Key('atelier-tarot-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tarot-active-setup-step-0')), findsOneWidget);
    expect(find.byKey(const Key('tarot-intro-panel')), findsOneWidget);
    expect(find.text('바로 덱 선택'), findsOneWidget);
    expect(find.text(UserText.tarotDeckSelect), findsNothing);
    expect(find.text(UserText.tarotSpreadSelect), findsNothing);
    expect(find.byKey(const Key('tarot-shuffle-button')), findsNothing);
    expect(find.byKey(const Key('tarot-rws-card-image')), findsNothing);
    expect(find.byKey(const Key('tarot-empty-slot')), findsNothing);

    await tester.tap(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tarot-active-setup-step-5')), findsOneWidget);
    expect(find.text('2 덱 선택'), findsOneWidget);
    expect(find.byKey(const Key('tarot-deck-carousel')), findsOneWidget);
    expect(find.byKey(const Key('tarot-deck-fan-carousel')), findsOneWidget);
    expect(find.byKey(const Key('tarot-deck-fan-left')), findsOneWidget);
    expect(find.byKey(const Key('tarot-deck-fan-right')), findsOneWidget);
    expect(find.byKey(const Key('tarot-deck-fan-dot-0')), findsOneWidget);
    final centerDeckRect = tester.getRect(
      find.byKey(const ValueKey('tarot-deck-carousel-card-rws_public_domain')),
    );
    final neighborDeckRect = tester.getRect(
      find.byKey(const ValueKey('tarot-deck-carousel-card-thoth')),
    );
    expect(centerDeckRect.width, greaterThan(neighborDeckRect.width));
    expect(centerDeckRect.top, lessThan(neighborDeckRect.top));
    for (var index = 0; index < TarotDeckRegistry.decks.length; index++) {
      expect(find.byKey(Key('tarot-deck-fan-dot-$index')), findsOneWidget);
    }
    expect(find.byKey(const Key('tarot-coverflow-hero-card')), findsOneWidget);
    expect(
      find.byKey(const Key('tarot-selected-card-edge-glow')),
      findsOneWidget,
    );
    final rwsDeck = find.byKey(
      const ValueKey('tarot-deck-carousel-card-rws_public_domain'),
    );
    final thothDeck = find.byKey(
      const ValueKey('tarot-deck-carousel-card-thoth'),
    );
    final marseilleDeck = find.byKey(
      const ValueKey('tarot-deck-carousel-card-marseille'),
    );
    expect(rwsDeck, findsOneWidget);
    expect(thothDeck, findsOneWidget);
    expect(marseilleDeck, findsOneWidget);
    expect(
      find.descendant(
        of: rwsDeck,
        matching: find.byKey(const Key('tarot-jukebox-center-card')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: rwsDeck,
        matching: find.byKey(const Key('tarot-selected-card-edge-glow')),
      ),
      findsOneWidget,
    );
    expect(find.text(UserText.tarotSpreadSelect), findsNothing);

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tarot-active-setup-step-6')), findsOneWidget);
    expect(find.text(UserText.tarotSpreadSelect), findsOneWidget);
    expect(find.text(UserText.tarotSpreadGroupFixed), findsOneWidget);
    for (final spread in [
      UserText.tarotSpreadOne,
      UserText.tarotSpreadThree,
      UserText.tarotSpreadFour,
      UserText.tarotSpreadFive,
      UserText.tarotSpreadBinary,
      UserText.tarotSpreadCeltic,
    ]) {
      expect(find.text(spread), findsAtLeastNWidgets(1));
    }
    expect(find.text('관계 리딩'), findsNothing);
    expect(find.text('문제-원인-해결'), findsNothing);

    expect(find.text('카드 뒷면 선택'), findsOneWidget);
    expect(find.text('코스믹 게이트'), findsOneWidget);
    expect(find.text('이너 로터스'), findsOneWidget);
    expect(find.text('생명의 나무'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('tarot-card-back-option-cosmic_gate')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('tarot-card-back-option-inner_lotus')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('tarot-card-back-option-life_tree')),
      findsOneWidget,
    );
    var setupBackImages = tester.widgetList<Image>(
      find.byKey(const Key('tarot-card-back-image')),
    );
    expect(
      setupBackImages
          .map((image) => (image.image as AssetImage).assetName)
          .where(
            (assetName) =>
                assetName ==
                'assets/tarot/card_backs/ryn_cosmic_gate_back_v1.png',
          ),
      isNotEmpty,
    );

    await tester.tap(
      find.byKey(const ValueKey('tarot-card-back-option-inner_lotus')),
    );
    await tester.pumpAndSettle();
    setupBackImages = tester.widgetList<Image>(
      find.byKey(const Key('tarot-card-back-image')),
    );
    expect(
      setupBackImages
          .map((image) => (image.image as AssetImage).assetName)
          .where(
            (assetName) =>
                assetName ==
                'assets/tarot/card_backs/ryn_inner_lotus_back_v1.png',
          ),
      isNotEmpty,
    );

    await tester.tap(
      find.byKey(const ValueKey('tarot-card-back-option-life_tree')),
    );
    await tester.pumpAndSettle();
    setupBackImages = tester.widgetList<Image>(
      find.byKey(const Key('tarot-card-back-image')),
    );
    expect(
      setupBackImages
          .map((image) => (image.image as AssetImage).assetName)
          .where(
            (assetName) =>
                assetName ==
                'assets/tarot/card_backs/ryn_life_tree_back_v1.png',
          ),
      isNotEmpty,
    );

    expect(find.text(UserText.tarotPositionSetup), findsOneWidget);
    expect(find.text(UserText.tarotPositionSetupHelper), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('과거'), findsWidgets);
    expect(find.text('현재'), findsWidgets);
    expect(find.text('미래'), findsWidgets);

    await tester.enterText(
      find.byKey(const ValueKey('tarot-position-label-input-3카드-1')),
      '중심',
    );
    await tester.pumpAndSettle();
    expect(find.text('중심'), findsOneWidget);

    await tester.tap(find.text(UserText.tarotSpreadFive));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(find.text('1'), findsWidgets);
    expect(find.text('5'), findsWidgets);

    await tester.tap(find.text(UserText.tarotSpreadThree));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('과거'), findsWidgets);
    expect(find.text('현재'), findsWidgets);
    expect(find.text('미래'), findsWidgets);
    await tester.enterText(
      find.byKey(const ValueKey('tarot-position-label-input-3카드-1')),
      '중심',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-active-setup-step-7')), findsOneWidget);
    expect(find.byKey(const Key('tarot-shuffle-button')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('tarot-shuffle-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tarot-shuffle-button')));
    await tester.pumpAndSettle();

    expect(find.text(UserText.tarotDrawPreparation), findsOneWidget);
    expect(find.byKey(const Key('tarot-full-deck-stage')), findsOneWidget);
    expect(find.byKey(const Key('tarot-full-deck-card-0')), findsOneWidget);
    expect(find.byKey(const Key('tarot-full-deck-card-77')), findsOneWidget);
    expect(find.byKey(const Key('tarot-card-back-image')), findsNWidgets(78));
    final drawTableBackAssetNames = tester
        .widgetList<Image>(find.byKey(const Key('tarot-card-back-image')))
        .map((image) => (image.image as AssetImage).assetName)
        .toSet();
    expect(drawTableBackAssetNames, {
      'assets/tarot/card_backs/ryn_life_tree_back_v1.png',
    });
    expect(find.byKey(const Key('tarot-rws-card-image')), findsNothing);
    expect(find.byKey(const Key('tarot-show-result-button')), findsOneWidget);

    final deckStageTopLeft = tester.getTopLeft(
      find.byKey(const Key('tarot-full-deck-stage')),
    );
    final deckStageSize = tester.getSize(
      find.byKey(const Key('tarot-full-deck-stage')),
    );
    Future<void> tapArcCard(double xRatio) async {
      await tester.tapAt(
        deckStageTopLeft + Offset(deckStageSize.width * xRatio, 250),
      );
      await tester.pumpAndSettle();
    }

    await tapArcCard(0.5);
    expect(find.text('1 / 3 선택'), findsOneWidget);
    expect(find.byKey(const Key('tarot-rws-card-image')), findsNothing);

    await tapArcCard(0.62);
    await tapArcCard(0.38);
    expect(find.text('3 / 3 선택'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tarot-show-result-button')));
    await tester.pumpAndSettle();
    expect(find.text(UserText.tarotResultTable), findsOneWidget);
    expect(find.text('카드를 펼쳐보세요'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('tarot-drawn-card')), findsNWidgets(3));
    expect(find.byKey(const Key('tarot-empty-slot')), findsNothing);
    expect(find.byKey(const Key('tarot-rws-card-image')), findsNothing);
    expect(find.byKey(const Key('tarot-card-back-image')), findsNWidgets(3));
    final resultBackAssetNames = tester
        .widgetList<Image>(find.byKey(const Key('tarot-card-back-image')))
        .map((image) => (image.image as AssetImage).assetName)
        .toSet();
    expect(resultBackAssetNames, {
      'assets/tarot/card_backs/ryn_life_tree_back_v1.png',
    });
    expect(
      find.byKey(const Key('tarot-result-card-back-slot')),
      findsNWidgets(3),
    );
    final resultCardSize = tester.getSize(
      find.byKey(const Key('tarot-drawn-card')).first,
    );
    final resultBackSize = tester.getSize(
      find.byKey(const Key('tarot-card-back-image')).first,
    );
    expect(
      (resultCardSize.width - resultBackSize.width).abs(),
      lessThanOrEqualTo(1),
    );
    expect(
      (resultCardSize.height - resultBackSize.height).abs(),
      lessThanOrEqualTo(1),
    );
    expect(find.text('중심'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('tarot-reveal-all-button')), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('tarot-result-card-back-slot')).first,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-rws-card-image')), findsOneWidget);
    expect(find.byKey(const Key('tarot-card-back-image')), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('tarot-reveal-all-button')));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
    expect(find.text('해석 보기로 이어가세요'), findsOneWidget);
    expect(find.text('카드를 펼쳐보세요'), findsNothing);
    final firstImage = tester.widget<Image>(
      find.byKey(const Key('tarot-rws-card-image')).first,
    );
    expect(firstImage.image, isA<AssetImage>());
    expect(firstImage.fit, BoxFit.contain);
    expect(
      (firstImage.image as AssetImage).assetName,
      startsWith('assets/tarot/decks/rws_public_domain/'),
    );
    expect(find.text(UserText.tarotUpright), findsNothing);
    expect(find.text(UserText.tarotReversed), findsNothing);
    final drawnAssetNames = tester
        .widgetList<Image>(find.byKey(const Key('tarot-rws-card-image')))
        .map((image) => (image.image as AssetImage).assetName)
        .toSet();
    expect(drawnAssetNames, hasLength(3));

    await tester.tap(find.text(UserText.tarotResetDraw));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-active-setup-step-0')), findsOneWidget);
    expect(find.byKey(const Key('tarot-rws-card-image')), findsNothing);

    await tester.ensureVisible(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.tarotSpreadOne));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-drawn-card')), findsOneWidget);
    expect(find.byKey(const Key('tarot-empty-slot')), findsNothing);

    expect(find.textContaining('DB', findRichText: true), findsNothing);
    expect(find.textContaining('runtime', findRichText: true), findsNothing);
    expect(
      find.textContaining('persistence', findRichText: true),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Tarot setup keeps primary actions visible in constrained desktop size',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 820);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const RynUniverseApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.navReading).first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('atelier-tarot-action')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('atelier-tarot-action')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tarot-shuffle-button')), findsOneWidget);
      expect(find.text(UserText.tarotAutoDraw), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('tarot-shuffle-button')));
      await tester.pumpAndSettle();
      final shuffleRect = tester.getRect(
        find.byKey(const Key('tarot-shuffle-button')),
      );
      final autoDrawRect = tester.getRect(find.text(UserText.tarotAutoDraw));
      const logicalHeight = 410.0;
      expect(shuffleRect.top, greaterThanOrEqualTo(0));
      expect(shuffleRect.bottom, lessThanOrEqualTo(logicalHeight));
      expect(autoDrawRect.top, greaterThanOrEqualTo(0));
      expect(autoDrawRect.bottom, lessThanOrEqualTo(logicalHeight));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Tarot result surface keeps actions reachable with reflection shell',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 820);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const RynUniverseApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.navReading).first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('atelier-tarot-action')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('atelier-tarot-action')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(UserText.tarotSpreadOne));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotSpreadOne));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();

      expect(find.text(UserText.tarotResultTable), findsOneWidget);
      expect(find.byKey(const Key('tarot-reveal-all-button')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-save-result-image-button')),
        findsOneWidget,
      );
      expect(find.text('이미지 저장'), findsOneWidget);
      expect(find.byKey(const Key('tarot-interpretation-shell')), findsNothing);
      expect(find.text('해석 패널'), findsNothing);
      expect(find.text('해석 보기'), findsOneWidget);

      final revealAllRect = tester.getRect(
        find.byKey(const Key('tarot-reveal-all-button')),
      );
      expect(revealAllRect.right, lessThanOrEqualTo(1200));
      expect(revealAllRect.left, greaterThanOrEqualTo(0));
      await tester.ensureVisible(find.text('해석 보기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('해석 보기'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-interpretation-shell')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-workspace-shell')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-spread-snapshot-preview')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-deduped-question-context')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-expanded-workspace')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-font-audit')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-whole-spread-reading')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-story-notes-panel')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-in-memory-note')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-context-summary')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-interpretation-two-column-layout')),
        findsOneWidget,
      );
      expect(find.text('오늘의 질문'), findsAtLeastNWidgets(1));
      expect(find.textContaining('이번 리딩의 주제'), findsAtLeastNWidgets(1));
      expect(find.text('전체 스프레드 보기'), findsOneWidget);
      expect(find.text('전체 이미지 관찰'), findsOneWidget);
      expect(find.text('흐름 해석'), findsOneWidget);
      expect(find.text('핵심 메시지'), findsOneWidget);
      expect(find.text('오늘의 조언 / 작은 실천'), findsOneWidget);
      expect(
        find.textContaining('결과와 해석 화면을 오가는 동안 유지되며, 앱을 닫으면 비워집니다'),
        findsOneWidget,
      );
      expect(find.textContaining('PDF', findRichText: true), findsNothing);
      expect(find.textContaining('AI', findRichText: true), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Tarot table cloth color applies through reading flow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tarot-table-cloth-selector')), findsOneWidget);
    for (final label in [
      '미드나잇 바이올렛',
      '딥 그린',
      '로즈 와인',
      '미드나잇 네이비',
      '차콜 블랙',
      '뮤티드 골드',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.ensureVisible(
      find.byKey(const Key('tarot-table-cloth-muted_gold')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tarot-table-cloth-muted_gold')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tarot-selected-table-cloth-muted_gold')),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-shuffle-button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tarot-shuffle-button')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tarot-draw-table-cloth-muted_gold')),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.tarotAutoDraw));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tarot-result-table-cloth-muted_gold')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('tarot-result-layout-3')), findsOneWidget);
    expect(
      find.byKey(const Key('tarot-layout-adjustment-toolbar')),
      findsOneWidget,
    );
    expect(find.text('해석 보기'), findsOneWidget);

    await tester.tap(find.text('모두 펼치기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tarot-focusable-result-card-0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tarot-focus-detail-overlay')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tarot-focus-close-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('해석 보기'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tarot-interpretation-table-cloth-muted_gold')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('tarot-interpretation-workspace-shell')),
      findsOneWidget,
    );
    expect(
      find.textContaining('결과와 해석 화면을 오가는 동안 유지되며, 앱을 닫으면 비워집니다'),
      findsOneWidget,
    );
    expect(find.textContaining('export', findRichText: true), findsNothing);
    expect(find.textContaining('PDF', findRichText: true), findsNothing);
    expect(find.textContaining('AI', findRichText: true), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tarot compact spreads use tall centered muted-gold tables', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Future<({Rect board, Rect card})> renderSpread({
      required String label,
      required String spreadId,
      required int count,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('tarot-table-cloth-muted_gold')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tarot-table-cloth-muted_gold')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(label).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tarot-shuffle-button')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text('모두 펼치기'));
      await tester.pumpAndSettle();

      final board = tester.getRect(
        find.byKey(Key('tarot-result-layout-$count')),
      );
      final card = tester.getRect(
        find.byKey(const Key('tarot-focusable-result-card-0')),
      );
      expect(
        find.byKey(const Key('tarot-result-table-cloth-muted_gold')),
        findsOneWidget,
        reason: spreadId,
      );
      expect(
        find.byKey(const Key('tarot-layout-adjustment-toolbar')),
        findsOneWidget,
        reason: spreadId,
      );
      expect(tester.takeException(), isNull, reason: spreadId);
      return (board: board, card: card);
    }

    final seven = await renderSpread(
      label: '7카드',
      spreadId: 'seven_card',
      count: 7,
    );
    final compactSpreads =
        <({String label, String spreadId, int count, double minCardWidth})>[
          (
            label: UserText.tarotSpreadOne,
            spreadId: 'one_card',
            count: 1,
            minCardWidth: 360,
          ),
          (
            label: UserText.tarotSpreadThree,
            spreadId: 'three_card',
            count: 3,
            minCardWidth: 270,
          ),
          (
            label: UserText.tarotSpreadFive,
            spreadId: 'five_card',
            count: 5,
            minCardWidth: 210,
          ),
        ];

    for (final spread in compactSpreads) {
      final rendered = await renderSpread(
        label: spread.label,
        spreadId: spread.spreadId,
        count: spread.count,
      );
      expect(
        rendered.board.height,
        greaterThanOrEqualTo(seven.board.height - 4),
        reason: '${spread.spreadId} table should align with seven-card height',
      );
      expect(
        rendered.card.width,
        greaterThanOrEqualTo(spread.minCardWidth),
        reason: '${spread.spreadId} card size must not be reduced',
      );
      final cardCenterRatio =
          (rendered.card.center.dy - rendered.board.top) /
          rendered.board.height;
      expect(
        cardCenterRatio,
        inInclusiveRange(0.46, 0.58),
        reason: '${spread.spreadId} card should sit in the visual middle zone',
      );
    }
  });

  testWidgets(
    'Tarot owner review flow exposes step panels and dedicated result layouts',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-active-setup-step-0')),
        findsOneWidget,
      );
      expect(find.text('1 질문과 목적'), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-midnight-atelier-stepper')),
        findsOneWidget,
      );
      for (final label in [
        '인트로',
        '카테고리',
        '질문',
        '상담 정보',
        '요약',
        '덱',
        '세부 설정',
        '셔플',
        '공개',
        '해석',
      ]) {
        expect(find.byKey(Key('tarot-global-flow-$label')), findsOneWidget);
      }
      expect(
        find.byKey(const Key('tarot-setup-guidance-layout')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tarot-deck-carousel')), findsNothing);
      expect(find.text(UserText.tarotSpreadSelect), findsNothing);
      expect(find.byKey(const Key('tarot-shuffle-button')), findsNothing);
      expect(find.text('리딩 포인트'), findsNothing);

      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-active-setup-step-5')),
        findsOneWidget,
      );
      expect(find.text('2 덱 선택'), findsOneWidget);
      expect(find.text('덱 선택'), findsNothing);
      expect(find.byKey(const Key('tarot-global-flow-덱')), findsOneWidget);
      expect(find.byKey(const Key('tarot-deck-carousel')), findsOneWidget);
      expect(find.byKey(const Key('tarot-jukebox-deck-stage')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-jukebox-center-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-coverflow-hero-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-selected-card-edge-glow')),
        findsOneWidget,
      );
      final rwsDeck = find.byKey(
        const ValueKey('tarot-deck-carousel-card-rws_public_domain'),
      );
      final thothDeck = find.byKey(
        const ValueKey('tarot-deck-carousel-card-thoth'),
      );
      final marseilleDeck = find.byKey(
        const ValueKey('tarot-deck-carousel-card-marseille'),
      );
      expect(rwsDeck, findsOneWidget);
      expect(thothDeck, findsOneWidget);
      expect(marseilleDeck, findsOneWidget);
      expect(
        find.descendant(
          of: rwsDeck,
          matching: find.byKey(const Key('tarot-jukebox-center-card')),
        ),
        findsOneWidget,
      );

      final nextDeck = find.byKey(const Key('tarot-deck-fan-right'));
      await tester.ensureVisible(nextDeck);
      await tester.pumpAndSettle();
      await tester.tap(nextDeck);
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: thothDeck,
          matching: find.byKey(const Key('tarot-jukebox-center-card')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: thothDeck,
          matching: find.byKey(const Key('tarot-selected-card-edge-glow')),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('tarot-deck-fan-left')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: rwsDeck,
          matching: find.byKey(const Key('tarot-jukebox-center-card')),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-immersive-deck-stage')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tarot-deck-fan-carousel')), findsOneWidget);
      expect(find.byKey(const Key('tarot-deck-bento-tile')), findsNothing);
      expect(find.text(UserText.tarotSpreadSelect), findsNothing);
      expect(find.byKey(const Key('tarot-shuffle-button')), findsNothing);

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-active-setup-step-6')),
        findsOneWidget,
      );
      expect(find.text('3 카드 세부 설정'), findsOneWidget);
      expect(find.byKey(const Key('tarot-global-flow-세부 설정')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-card-detail-balanced-layout')),
        findsOneWidget,
      );
      expect(find.text(UserText.tarotSpreadSelect), findsOneWidget);
      expect(find.byKey(const Key('tarot-deck-carousel')), findsNothing);
      expect(find.byKey(const Key('tarot-shuffle-button')), findsNothing);

      await tester.tap(find.text(UserText.tarotSpreadFour));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-active-setup-step-7')),
        findsOneWidget,
      );
      expect(find.text('4 셔플과 드로우'), findsOneWidget);
      expect(find.byKey(const Key('tarot-global-flow-셔플')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-ritual-shuffle-stage')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-unified-ritual-layout')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-ritual-deck-preview')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-ritual-hero-deck-stack')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tarot-shuffle-button')), findsOneWidget);
      expect(find.byKey(const Key('tarot-deck-carousel')), findsNothing);
      expect(find.text(UserText.tarotSpreadSelect), findsNothing);
      await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tarot-shuffle-button')));
      await tester.pumpAndSettle();
      expect(find.text(UserText.tarotDrawPreparation), findsOneWidget);
      expect(find.byKey(const Key('tarot-full-deck-stage')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-face-down-card-identity-major_00')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-draw-face-down-card-back-image-0')),
        findsOneWidget,
      );
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tarot-result-layout-4')), findsOneWidget);
      expect(find.byKey(const Key('tarot-reading-workspace')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-reading-command-bar')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tarot-interpretation-shell')), findsNothing);
      expect(find.text('배치 조정'), findsOneWidget);
      expect(find.text('기본 배치로'), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-layout-adjustment-toolbar')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-adjustable-result-card-0')),
        findsOneWidget,
      );
      final fixedSlotBefore = tester.getRect(
        find.byKey(const Key('tarot-result-slot-4-0')),
      );
      await tester.drag(
        find.byKey(const Key('tarot-adjustable-result-card-0')),
        const Offset(96, 42),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(const Key('tarot-result-slot-4-0'))),
        fixedSlotBefore,
      );
      await tester.tap(find.text('배치 조정'));
      await tester.pumpAndSettle();
      expect(find.text('배치 완료'), findsOneWidget);
      await tester.drag(
        find.byKey(const Key('tarot-adjustable-result-card-0')),
        const Offset(96, 42),
      );
      await tester.pumpAndSettle();
      final fixedSlotMoved = tester.getRect(
        find.byKey(const Key('tarot-result-slot-4-0')),
      );
      expect(fixedSlotMoved.center.dx, greaterThan(fixedSlotBefore.center.dx));
      expect(
        find.byKey(const Key('tarot-slot-label-anchor-bottom-four_1')),
        findsAtLeastNWidgets(1),
      );
      await tester.tap(find.text('배치 완료'));
      await tester.pumpAndSettle();
      expect(find.text('배치 조정'), findsOneWidget);
      expect(
        tester.getRect(find.byKey(const Key('tarot-result-slot-4-0'))),
        fixedSlotMoved,
      );
      await tester.tap(find.text('기본 배치로'));
      await tester.pumpAndSettle();
      final fixedSlotReset = tester.getRect(
        find.byKey(const Key('tarot-result-slot-4-0')),
      );
      expect(
        (fixedSlotReset.center.dx - fixedSlotBefore.center.dx).abs(),
        lessThan(1),
      );
      expect(
        (fixedSlotReset.center.dy - fixedSlotBefore.center.dy).abs(),
        lessThan(1),
      );
      expect(find.text('해석 패널'), findsNothing);
      expect(find.text('해석 보기'), findsOneWidget);
      expect(find.text('이미지 저장'), findsOneWidget);
      expect(find.textContaining('export', findRichText: true), findsNothing);
      expect(find.textContaining('history', findRichText: true), findsNothing);
      expect(find.textContaining('AI', findRichText: true), findsNothing);

      final rowRects = List<Rect>.generate(
        4,
        (index) =>
            tester.getRect(find.byKey(Key('tarot-result-slot-4-$index'))),
      );
      final maxTopDelta = rowRects
          .map((rect) => (rect.top - rowRects.first.top).abs())
          .reduce(math.max);
      expect(maxTopDelta, lessThan(28));
      await tester.tap(find.text('해석 보기'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('tarot-interpretation-shell')),
        findsOneWidget,
      );
      expect(find.text('해석 패널'), findsAtLeastNWidgets(1));
      expect(find.byKey(const Key('tarot-result-layout-4')), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotSpreadFive));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tarot-result-layout-5')), findsOneWidget);
      for (var index = 0; index < 5; index++) {
        final slotRect = tester.getRect(
          find.byKey(Key('tarot-result-slot-5-$index')),
        );
        expect(slotRect.left, greaterThanOrEqualTo(0));
        expect(slotRect.right, lessThanOrEqualTo(1920));
        expect(slotRect.bottom, lessThanOrEqualTo(1080));
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotSpreadCeltic));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tarot-result-layout-10')), findsOneWidget);
      final rightColumnRects = [
        for (var index = 6; index < 10; index++)
          tester.getRect(find.byKey(Key('tarot-result-slot-10-$index'))),
      ];
      for (var index = 1; index < rightColumnRects.length; index++) {
        expect(
          (rightColumnRects[index].center.dx -
                  rightColumnRects[index - 1].center.dx)
              .abs(),
          lessThan(12),
        );
        expect(
          (rightColumnRects[index].center.dy -
                  rightColumnRects[index - 1].center.dy)
              .abs(),
          greaterThan(rightColumnRects[index].height * 0.55),
        );
      }

      expect(find.text('관계 리딩'), findsNothing);
      expect(find.text('문제-원인-해결'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Tarot focus cleanup is safe when app tree disposes', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.navReading).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('atelier-tarot-action')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('바로 덱 선택'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('tarot-shuffle-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tarot-shuffle-button')));
    await tester.pumpAndSettle();

    expect(find.text(UserText.tarotDrawPreparation), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'final IA workspaces expose operating, practice, and content tools',
    (WidgetTester tester) async {
      await tester.pumpWidget(const RynUniverseApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text(UserText.navOperating).first);
      await tester.pumpAndSettle();
      expect(find.text(UserText.operatingTodo), findsOneWidget);
      expect(find.text(UserText.operatingSchedule), findsOneWidget);
      expect(find.text(UserText.operatingQuickMemo), findsOneWidget);

      await tester.tap(find.text(UserText.navPractice).first);
      await tester.pumpAndSettle();
      expect(find.text(UserText.practiceQigong), findsOneWidget);
      expect(find.text(UserText.practiceYoga), findsOneWidget);
      expect(find.text(UserText.practiceMeditation), findsOneWidget);
      expect(find.text(UserText.practiceJournal), findsOneWidget);

      await tester.tap(find.text(UserText.navContent).first);
      await tester.pumpAndSettle();
      expect(find.text(UserText.contentLessonPlan), findsOneWidget);
      expect(find.text(UserText.contentEbook), findsOneWidget);
      expect(find.text(UserText.contentLectureDraft), findsOneWidget);
      expect(find.text(UserText.contentSnsDraft), findsOneWidget);
    },
  );

  testWidgets('renders Study OS 2.0 shell without runtime persistence', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text(UserText.navStudy).first);
    await tester.pumpAndSettle();

    expect(find.text(UserText.studyOsTitle), findsOneWidget);
    expect(find.text(UserText.studyUserSubtitle), findsOneWidget);
    expect(find.text(UserText.studyActionToday), findsOneWidget);
    expect(find.text(UserText.studyActionAttendance), findsOneWidget);
    expect(find.text(UserText.studyActionMaterials), findsOneWidget);
    expect(find.text(UserText.studyActionJournal), findsOneWidget);
    expect(find.text(UserText.studyActionReports), findsOneWidget);
    expect(find.text(UserText.studyActionMembers), findsOneWidget);
    expect(find.text(UserText.studyActionSessions), findsOneWidget);
    expect(find.textContaining(UserText.studyEmptyRegistered), findsOneWidget);
    expect(
      find.textContaining(UserText.studyPickNeededItem),
      findsAtLeastNWidgets(1),
    );

    final studyCards = find.byWidgetPredicate(
      (widget) => widget.runtimeType.toString() == '_StudyUserActionCard',
    );
    expect(studyCards, findsWidgets);
    final firstStudyCard = tester.getRect(studyCards.at(0));
    final secondStudyCard = tester.getRect(studyCards.at(1));
    expect((firstStudyCard.width - secondStudyCard.width).abs(), lessThan(0.1));
    expect(firstStudyCard.height, lessThanOrEqualTo(150));

    await tester.tap(find.text(UserText.studyActionAttendance).first);
    await tester.pumpAndSettle();
    expect(
      find.text('${UserText.navStudy} > ${UserText.studyActionAttendance}'),
      findsOneWidget,
    );
    expect(find.text(UserText.backToWorkspace), findsOneWidget);
    expect(find.text(UserText.emptyItems), findsOneWidget);
    await tester.tap(find.text(UserText.backToWorkspace));
    await tester.pumpAndSettle();
    expect(find.text(UserText.studyWorkspaceTitle), findsOneWidget);

    const forbiddenStudyLabels = <String>[
      '화면 구성',
      '선택한 화면',
      '보관 전',
      '화면 흐름 확인 단계',
      '아직 입력한 내용은 보관되지 않습니다.',
      '정적 화면 shell',
      'DB 연결 없음',
      '저장/수정 없음',
    ];
    for (final label in forbiddenStudyLabels) {
      expect(find.text(label), findsNothing);
    }
    expect(find.textContaining('runtime', findRichText: true), findsNothing);
    expect(find.textContaining('CRUD', findRichText: true), findsNothing);
    expect(find.textContaining('shell', findRichText: true), findsNothing);
    expect(find.textContaining('static', findRichText: true), findsNothing);
    expect(
      find.textContaining('implementation', findRichText: true),
      findsNothing,
    );
    expect(
      find.textContaining('persistence', findRichText: true),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark mode keeps user navigation and Study surface readable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text(UserText.navSettings).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.themeDark).first);
    await tester.pumpAndSettle();

    expect(find.text(UserText.themeDark), findsAtLeastNWidgets(1));
    await tester.tap(find.text(UserText.navHome).first);
    await tester.pumpAndSettle();
    expect(find.text(UserText.navHome), findsAtLeastNWidgets(1));

    expect(find.byKey(const Key('home-cinematic-scene')), findsOneWidget);
    expect(find.text('오늘의 성장 흐름'), findsAtLeastNWidgets(1));

    await tester.tap(find.text(UserText.navStudy).first);
    await tester.pumpAndSettle();

    expect(find.text(UserText.studyOsTitle), findsOneWidget);
    expect(find.text(UserText.studyActionAttendance), findsOneWidget);
    final studyCardColors = tester
        .widgetList<Container>(find.byKey(const Key('study-user-action-card')))
        .map((container) => container.decoration)
        .whereType<BoxDecoration>()
        .map((decoration) => decoration.color)
        .whereType<Color>()
        .toList();
    expect(studyCardColors, isNotEmpty);
    expect(studyCardColors.contains(Colors.white), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AI Workbench stays lightweight and user-facing', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const RynUniverseApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text(UserText.navAi).first);
    await tester.pumpAndSettle();

    expect(find.text(UserText.aiWorkbenchTitle), findsAtLeastNWidgets(1));
    expect(find.text(UserText.aiWorkbenchCue), findsOneWidget);
    expect(find.text(UserText.aiWorkbenchRequest), findsOneWidget);
    expect(find.text(UserText.aiWorkbenchReview), findsOneWidget);
    expect(find.text(UserText.aiWorkbenchApproved), findsOneWidget);
    expect(find.text('AI Command Center'), findsNothing);
    expect(find.text('Kanban Orchestra'), findsNothing);
    expect(find.textContaining('DB', findRichText: true), findsNothing);
    expect(find.textContaining('HOLD', findRichText: true), findsNothing);
  });

  test(
    'Tarot spread registry source defines corrected family meanings and anchors',
    () {
      final source = File(
        'lib/features/tarot/tarot_spread_shell.dart',
      ).readAsStringSync();
      final registrySource = File(
        'lib/features/tarot/data/tarot_deck_registry.dart',
      ).readAsStringSync();
      final expectedLiteralLabels = <String>[
        '자유 드로우',
        '2카드',
        '7카드',
        '그리드 6',
        '그리드 8',
        '그리드 9',
        '미니 켈틱 크로스',
        '십자',
        '말발굽',
        '매직 세븐',
        '리딩 마인드',
        '탄뎀',
        '릴레이션십',
        '컵 오브 릴레이션십',
        '호로스코프',
        '1년 운세',
      ];
      final expectedIds = <String>[
        'free_draw',
        'one_card',
        'two_card',
        'three_card',
        'four_card',
        'five_card',
        'seven_card',
        'grid_6',
        'grid_8',
        'grid_9',
        'celtic_cross',
        'mini_celtic_cross',
        'cross',
        'horseshoe',
        'magic_seven',
        'binary_choice',
        'reading_mind',
        'tandem',
        'relationship',
        'cup_of_relationship',
        'horoscope',
        'year_ahead',
      ];

      for (final label in expectedLiteralLabels) {
        expect(source, contains("label: '$label'"), reason: label);
      }
      for (final id in expectedIds) {
        expect(source, contains("id: '$id'"), reason: id);
      }
      expect(source, contains('id: \'free_draw\''));
      for (final id in <String>[
        'free_draw',
        'one_card',
        'two_card',
        'three_card',
        'four_card',
        'five_card',
        'seven_card',
        'grid_6',
        'grid_8',
        'grid_9',
      ]) {
        expect(
          source,
          contains("id: '$id',"),
          reason: 'freeLayout id missing: $id',
        );
      }
      expect(source, contains('_TarotSpreadFamily.freeLayout'));
      expect(source, contains('_TarotSpreadFamily.fixedMeaning'));
      expect(source, contains('_TarotPositionMeaningMode.userDefined'));
      expect(source, contains('_TarotPositionMeaningMode.predefined'));
      expect(source, contains('supportsDrag: true'));
      expect(RegExp(r'supportsDrag: true').allMatches(source), hasLength(1));
      expect(source, contains('int _selectedFreeDrawCount = 5'));
      expect(
        source,
        contains('_freeDrawSlotsForCount(_selectedFreeDrawCount)'),
      );
      expect(source, contains('tarot-free-draw-count-selector'));
      expect(source, contains('static const List<int> _quickCounts'));
      expect(source, contains('[1, 3, 5, 7, 10, 13, 22]'));
      expect(source, contains(r'tarot-free-draw-count-option-$count'));
      expect(source, contains('count.clamp(1, 30)'));
      expect(source, contains('_TarotResultCanvasStyle.freeBoard'));
      expect(source, contains('_TarotResultCanvasStyle.radial'));
      expect(source, contains('variantCount: 3'));
      expect(source, contains('overlapTargetSlotId: \'mini_center\''));
      expect(source, contains('overlapTargetSlotId: \'cup_center\''));
      expect(source, contains("slotId: '\${prefix}_center'"));
      expect(source, contains('tarot-free-draw-draggable-card-'));
      expect(source, contains('tarot-fixed-spread-board-'));
      expect(source, contains('tarot-reading-workspace'));
      expect(source, contains('tarot-reading-command-bar'));
      expect(source, contains('fillAvailable: true'));
      expect(source, contains('tarot-layout-adjustment-toolbar'));
      expect(source, contains('tarot-floating-layout-controls'));
      expect(source, contains('tarot-layout-adjustment-enter'));
      expect(source, contains('tarot-layout-adjustment-done'));
      expect(source, contains('tarot-layout-adjustment-reset'));
      expect(source, contains('tarot-representative-deck-image'));
      expect(source, contains('representativeAssetPath'));
      expect(registrySource, contains('RWS_Tarot_00_Fool.jpg'));
      expect(source, contains('tarot-adjustable-result-card-'));
      expect(source, contains('final Map<int, Offset> _temporaryOffsets'));
      expect(source, contains('bool _adjustmentMode = false'));
      expect(source, contains('bool get _canMoveCards'));
      expect(source, contains('bool get _shouldShowPersistentCaptions'));
      expect(source, contains('static const Set<String> _denseSpreadIds'));
      expect(source, contains('_cardSizeForSpreadType'));
      expect(source, contains('_layoutForSpread'));
      expect(source, contains('_boardPaddingForSpread'));
      expect(source, contains('_spreadOccupancyTarget'));
      expect(source, contains('_overlapPolicyForSpread'));
      expect(source, contains('SPREAD-LAYOUT-TEMPLATE1'));
      expect(source, contains('const _manualSpreadGeometryBlueprints'));
      expect(source, contains('class _TarotSpreadGeometryBlueprint'));
      expect(source, contains('class _EffectiveSpreadLayout'));
      expect(source, contains('enum _TarotOverlapPolicy'));
      expect(source, contains('R7: keep the hit/label halo compact'));
      expect(source, contains('return _TarotSlotAnchor.hidden'));
      expect(source, contains('enum _TarotSlotAnchor'));
      expect(source, contains('labelAnchor:'));
      expect(source, contains('infoAnchor:'));
      expect(source, contains('labelOffsetX:'));
      expect(source, contains('avoidOverlap:'));
      expect(source, contains('allowAutoFlipAnchor:'));
      expect(source, contains('preferredSide:'));
      expect(source, contains('_radialAnchorForIndex'));
      expect(source, contains('tarot-slot-label-anchor-'));
      expect(source, contains('_TarotSlotAnchor.bottom'));
      expect(source, contains('_TarotSlotAnchor.left'));
      expect(source, contains('_TarotSlotAnchor.right'));
      expect(source, contains('tarot-reading-back-command'));
      expect(source, contains('UserText.backToWorkspace'));
      expect(source, contains('selected card-back labels must stay readable'));
      expect(source, contains('gold remains in the rim/glow, not text'));
      expect(
        source,
        contains("'celtic_cross': _TarotSpreadGeometryBlueprint("),
      );
      expect(
        source,
        contains('layout: _EffectiveSpreadLayout(columns: 4.70, rows: 3.45)'),
      );
      expect(
        source,
        contains("'mini_celtic_cross': _TarotSpreadGeometryBlueprint("),
      );
      expect(source, contains("'cross': _TarotSpreadGeometryBlueprint("));
      expect(source, contains("'horseshoe': _TarotSpreadGeometryBlueprint("));
      expect(source, contains("'magic_seven': _TarotSpreadGeometryBlueprint("));
      expect(
        source,
        contains("'binary_choice': _TarotSpreadGeometryBlueprint("),
      );
      expect(
        source,
        contains("'reading_mind': _TarotSpreadGeometryBlueprint("),
      );
      expect(source, contains("'tandem': _TarotSpreadGeometryBlueprint("));
      expect(
        source,
        contains("'relationship': _TarotSpreadGeometryBlueprint("),
      );
      expect(
        source,
        contains("'cup_of_relationship': _TarotSpreadGeometryBlueprint("),
      );
      expect(source, contains("'horoscope': _TarotSpreadGeometryBlueprint("));
      expect(source, contains("'year_ahead': _TarotSpreadGeometryBlueprint("));
      expect(source, isNot(contains('관계 리딩')));
      expect(source, isNot(contains('문제-원인-해결')));
      expect(source, isNot(contains('history')));
      expect(source, contains("id: 'one_card',"));
      expect(source, contains('family: _TarotSpreadFamily.freeLayout'));
      expect(source, contains("id: 'celtic_cross',"));
      expect(source, contains('family: _TarotSpreadFamily.fixedMeaning'));

      String definitionBlock(String id) {
        final start = source.indexOf("id: '$id'");
        expect(start, isNonNegative, reason: id);
        final next = source.indexOf(
          '  const _TarotSpreadDefinition(',
          start + 1,
        );
        final nextDynamic = source.indexOf(
          '  _TarotSpreadDefinition(',
          start + 1,
        );
        final candidates = [
          if (next > start) next,
          if (nextDynamic > start) nextDynamic,
        ]..sort();
        final end = candidates.isEmpty
            ? source.indexOf('];', start)
            : candidates.first;
        return source.substring(start, end);
      }

      for (final id in <String>[
        'free_draw',
        'one_card',
        'two_card',
        'three_card',
        'four_card',
        'five_card',
        'seven_card',
        'grid_6',
        'grid_8',
        'grid_9',
      ]) {
        final block = definitionBlock(id);
        expect(block, contains('_TarotSpreadFamily.freeLayout'), reason: id);
        expect(
          block,
          contains('_TarotPositionMeaningMode.userDefined'),
          reason: id,
        );
      }
      for (final id in <String>[
        'celtic_cross',
        'mini_celtic_cross',
        'cross',
        'horseshoe',
        'magic_seven',
        'binary_choice',
        'reading_mind',
        'tandem',
        'relationship',
        'cup_of_relationship',
        'horoscope',
        'year_ahead',
      ]) {
        final block = definitionBlock(id);
        expect(block, contains('_TarotSpreadFamily.fixedMeaning'), reason: id);
        expect(
          block,
          contains('_TarotPositionMeaningMode.predefined'),
          reason: id,
        );
      }
      expect(
        definitionBlock('one_card'),
        isNot(contains('supportsDrag: true')),
      );
      expect(source, contains('labelAnchor: _TarotSlotAnchor.right'));
      expect(source, contains('infoAnchor: _TarotSlotAnchor.right'));
      for (final slotId in <String>[
        'free_1',
        'two_left',
        'three_present',
        'four_3',
      ]) {
        final slotStart = source.indexOf("slotId: '$slotId'");
        expect(slotStart, isNonNegative, reason: slotId);
        final slotEnd = source.indexOf('),', slotStart);
        final slotBlock = source.substring(slotStart, slotEnd);
        expect(
          slotBlock,
          contains('labelAnchor: _TarotSlotAnchor.bottom'),
          reason: '$slotId label must sit outside card art',
        );
      }
      expect(source, contains("slotId: 'five_1'"));
      expect(source, contains("slotId: 'five_3'"));
      expect(source, contains("slotId: 'five_5'"));
      expect(source, contains("slotId: 'celtic_result'"));
      expect(
        source,
        matches(RegExp(r"0\.84,\s+0\.03,\s+slotId: 'celtic_result'")),
      );
      expect(source, contains("rotationDeg: 90"));
      expect(source, contains("slotId: 'cup_left_top'"));
      expect(source, contains("slotId: 'cup_right_top'"));
      expect(source, contains("slotId: 'cup_overlap'"));
      expect(source, contains('preferredSide: _TarotSlotAnchor.outside'));
      expect(source, contains('labelAnchor: _TarotSlotAnchor.outside'));
    },
  );

  testWidgets(
    'Tarot expanded spreads render free, overlap, and radial boards',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Future<void> mountAtSpreadStep() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('tarot-active-setup-step-6')),
          findsOneWidget,
        );
      }

      Future<void> selectSpreadAndAutoDraw(
        String label, {
        Future<void> Function()? beforeDrawStep,
      }) async {
        await tester.ensureVisible(find.text(label).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        if (beforeDrawStep != null) await beforeDrawStep();
        await tester.ensureVisible(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
        await tester.tap(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
      }

      await mountAtSpreadStep();
      expect(find.text(UserText.tarotSpreadGroupFree), findsOneWidget);
      expect(find.text(UserText.tarotSpreadGroupFixed), findsOneWidget);
      for (final label in <String>[
        '자유 드로우',
        '2카드',
        '7카드',
        '그리드 6',
        '그리드 8',
        '그리드 9',
        '미니 켈틱 크로스',
        '십자',
        '말발굽',
        '매직 세븐',
        '리딩 마인드',
        '탄뎀',
        '릴레이션십',
        '컵 오브 릴레이션십',
        '호로스코프',
        '1년 운세',
      ]) {
        await tester.ensureVisible(find.text(label).first);
        await tester.pumpAndSettle();
        expect(find.text(label), findsAtLeastNWidgets(1), reason: label);
      }
      expect(find.text('관계 리딩'), findsNothing);
      expect(find.text('문제-원인-해결'), findsNothing);

      await selectSpreadAndAutoDraw(
        '자유 드로우',
        beforeDrawStep: () async {
          expect(
            find.byKey(const Key('tarot-free-draw-count-selector')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('tarot-free-draw-count-current')),
            findsOneWidget,
          );
          expect(find.text('5 / 30'), findsOneWidget);
          await tester.tap(
            find.byKey(const Key('tarot-free-draw-count-option-10')),
          );
          await tester.pumpAndSettle();
          expect(find.text('10 / 30'), findsOneWidget);
        },
      );
      expect(find.byKey(const Key('tarot-result-layout-10')), findsOneWidget);
      expect(find.byKey(const Key('tarot-free-draw-board')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-free-draw-top-strip')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-free-draw-draggable-card-0')),
        findsOneWidget,
      );

      void expectTrueGridGeometry({
        required String spreadId,
        required int count,
        required int columns,
        required int rows,
        required double minSlotHeight,
      }) {
        final rects = [
          for (var index = 0; index < count; index++)
            tester.getRect(find.byKey(Key('tarot-result-slot-$count-$index'))),
        ];
        expect(rects, hasLength(count));
        expect(rects.first.height, greaterThan(minSlotHeight));
        for (var row = 0; row < rows; row++) {
          final rowRects = rects.skip(row * columns).take(columns).toList();
          final y = rowRects.first.center.dy;
          for (final rect in rowRects) {
            expect((rect.center.dy - y).abs(), lessThan(3), reason: spreadId);
          }
          for (var column = 1; column < rowRects.length; column++) {
            expect(
              rowRects[column].center.dx,
              greaterThan(rowRects[column - 1].center.dx),
              reason: '$spreadId column order',
            );
          }
        }
        for (var row = 1; row < rows; row++) {
          expect(
            rects[row * columns].center.dy,
            greaterThan(rects[(row - 1) * columns].center.dy),
            reason: '$spreadId row order',
          );
        }
      }

      await mountAtSpreadStep();
      await selectSpreadAndAutoDraw('그리드 6');
      expect(find.byKey(const Key('tarot-result-layout-6')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-fixed-spread-board-grid_6')),
        findsOneWidget,
      );
      expectTrueGridGeometry(
        spreadId: 'grid_6',
        count: 6,
        columns: 3,
        rows: 2,
        minSlotHeight: 280,
      );

      await mountAtSpreadStep();
      await selectSpreadAndAutoDraw('그리드 9');
      expect(find.byKey(const Key('tarot-result-layout-9')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-fixed-spread-board-grid_9')),
        findsOneWidget,
      );
      expectTrueGridGeometry(
        spreadId: 'grid_9',
        count: 9,
        columns: 3,
        rows: 3,
        minSlotHeight: 220,
      );

      await mountAtSpreadStep();
      await selectSpreadAndAutoDraw('미니 켈틱 크로스');
      expect(find.byKey(const Key('tarot-result-layout-6')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-fixed-spread-board-mini_celtic_cross')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('tarot-spread-slot-mini_celtic_cross-mini_overlay'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tarot-free-draw-board')), findsNothing);

      await mountAtSpreadStep();
      await selectSpreadAndAutoDraw('호로스코프');
      expect(find.byKey(const Key('tarot-result-layout-13')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-fixed-spread-board-horoscope')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-spread-slot-horoscope-house_center')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-spread-slot-horoscope-house_12')),
        findsOneWidget,
      );
      expect(find.text('이미지 저장'), findsOneWidget);
      expect(find.textContaining('export', findRichText: true), findsNothing);
      expect(find.textContaining('history', findRichText: true), findsNothing);
      expect(find.textContaining('AI', findRichText: true), findsNothing);
    },
  );

  testWidgets(
    'Tarot grid spreads keep real cards inside non-overlapping cells',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Future<void> mountAtSpreadStep() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
      }

      Future<void> selectSpreadAndAutoDraw(String label) async {
        await tester.ensureVisible(find.text(label).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
        await tester.tap(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
      }

      bool overlaps(Rect a, Rect b) =>
          a.left < b.right &&
          a.right > b.left &&
          a.top < b.bottom &&
          a.bottom > b.top;

      void expectCellGrid({
        required String spreadId,
        required String label,
        required int count,
        required int columns,
        required int rows,
        required double minHorizontalGap,
        required double minVerticalGap,
        required double minCardWidth,
      }) {
        final board = tester.getRect(
          find.byKey(Key('tarot-fixed-spread-board-$spreadId')),
        );
        final cardRects = [
          for (var index = 0; index < count; index++)
            tester.getRect(
              find.byKey(Key('tarot-grid-card-visual-$spreadId-$index')),
            ),
        ];
        expect(cardRects, hasLength(count), reason: spreadId);
        for (final rect in cardRects) {
          expect(
            rect.width,
            greaterThanOrEqualTo(minCardWidth),
            reason: '$spreadId readable card width',
          );
          expect(
            rect.left,
            greaterThanOrEqualTo(board.left + 16),
            reason: '$spreadId inside left',
          );
          expect(
            rect.right,
            lessThanOrEqualTo(board.right - 16),
            reason: '$spreadId inside right',
          );
          expect(
            rect.top,
            greaterThanOrEqualTo(board.top + 16),
            reason: '$spreadId inside top',
          );
          expect(
            rect.bottom,
            lessThanOrEqualTo(board.bottom - 16),
            reason: '$spreadId inside bottom',
          );
        }
        for (var a = 0; a < cardRects.length; a++) {
          for (var b = a + 1; b < cardRects.length; b++) {
            expect(
              overlaps(cardRects[a], cardRects[b]),
              isFalse,
              reason: '$spreadId card $a overlaps $b',
            );
          }
        }
        for (var row = 0; row < rows; row++) {
          final rowRects = cardRects.skip(row * columns).take(columns).toList();
          final y = rowRects.first.center.dy;
          for (final rect in rowRects) {
            expect(
              (rect.center.dy - y).abs(),
              lessThan(2),
              reason: '$spreadId row alignment',
            );
          }
          for (var column = 1; column < columns; column++) {
            final gap = rowRects[column].left - rowRects[column - 1].right;
            expect(
              gap,
              greaterThanOrEqualTo(minHorizontalGap),
              reason: '$spreadId horizontal gap',
            );
          }
        }
        for (var row = 1; row < rows; row++) {
          final upper = cardRects
              .skip((row - 1) * columns)
              .take(columns)
              .toList();
          final lower = cardRects.skip(row * columns).take(columns).toList();
          final gap =
              lower.map((r) => r.top).reduce(math.min) -
              upper.map((r) => r.bottom).reduce(math.max);
          expect(
            gap,
            greaterThanOrEqualTo(minVerticalGap),
            reason: '$spreadId vertical gap',
          );
        }
        expect(
          find.byKey(const Key('tarot-layout-adjustment-toolbar')),
          findsOneWidget,
          reason: label,
        );
        expect(tester.takeException(), isNull, reason: spreadId);
      }

      for (final spread
          in <
            ({
              String id,
              String label,
              int count,
              int columns,
              int rows,
              double minWidth,
            })
          >[
            (
              id: 'grid_6',
              label: '그리드 6',
              count: 6,
              columns: 3,
              rows: 2,
              minWidth: 180,
            ),
            (
              id: 'grid_8',
              label: '그리드 8',
              count: 8,
              columns: 4,
              rows: 2,
              minWidth: 158,
            ),
            (
              id: 'grid_9',
              label: '그리드 9',
              count: 9,
              columns: 3,
              rows: 3,
              minWidth: 150,
            ),
          ]) {
        await mountAtSpreadStep();
        await selectSpreadAndAutoDraw(spread.label);
        expectCellGrid(
          spreadId: spread.id,
          label: spread.label,
          count: spread.count,
          columns: spread.columns,
          rows: spread.rows,
          minHorizontalGap: 20,
          minVerticalGap: 26,
          minCardWidth: spread.minWidth,
        );
      }
    },
  );

  testWidgets('Tarot Celtic and cross spreads avoid accidental card overlap', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    Future<void> mountAtSpreadStep() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
    }

    Future<void> selectSpreadAndAutoDraw(String label) async {
      await tester.ensureVisible(find.text(label).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
    }

    bool overlaps(Rect a, Rect b) =>
        a.left < b.right &&
        a.right > b.left &&
        a.top < b.bottom &&
        a.bottom > b.top;

    double horizontalGap(Rect a, Rect b) {
      if (a.right <= b.left) return b.left - a.right;
      if (b.right <= a.left) return a.left - b.right;
      return 0;
    }

    double verticalGap(Rect a, Rect b) {
      if (a.bottom <= b.top) return b.top - a.bottom;
      if (b.bottom <= a.top) return a.top - b.bottom;
      return 0;
    }

    void expectSpreadGeometry({
      required String spreadId,
      required String label,
      required int count,
      required double minCardWidth,
      required Set<String> intentionalOverlapPairs,
    }) {
      final board = tester.getRect(
        find.byKey(Key('tarot-fixed-spread-board-$spreadId')),
      );
      final cardRects = [
        for (var index = 0; index < count; index++)
          tester.getRect(
            find.byKey(Key('tarot-fixed-card-visual-$spreadId-$index')),
          ),
      ];
      expect(cardRects, hasLength(count), reason: spreadId);
      for (final rect in cardRects) {
        expect(
          rect.width,
          greaterThanOrEqualTo(minCardWidth),
          reason: '$spreadId readable card width',
        );
        expect(
          rect.left,
          greaterThanOrEqualTo(board.left + 12),
          reason: '$spreadId inside left',
        );
        expect(
          rect.right,
          lessThanOrEqualTo(board.right - 12),
          reason: '$spreadId inside right',
        );
        expect(
          rect.top,
          greaterThanOrEqualTo(board.top + 12),
          reason: '$spreadId inside top',
        );
        expect(
          rect.bottom,
          lessThanOrEqualTo(board.bottom - 12),
          reason: '$spreadId inside bottom',
        );
      }
      for (var a = 0; a < cardRects.length; a++) {
        for (var b = a + 1; b < cardRects.length; b++) {
          final pair = '$a:$b';
          if (intentionalOverlapPairs.contains(pair)) {
            expect(
              overlaps(cardRects[a], cardRects[b]),
              isTrue,
              reason: '$spreadId intentional crossing $pair',
            );
            continue;
          }
          expect(
            overlaps(cardRects[a], cardRects[b]),
            isFalse,
            reason: '$spreadId accidental overlap $pair',
          );
          expect(
            math.max(
              horizontalGap(cardRects[a], cardRects[b]),
              verticalGap(cardRects[a], cardRects[b]),
            ),
            greaterThanOrEqualTo(18),
            reason: '$spreadId near-overlap $pair',
          );
        }
      }
      expect(
        find.byKey(const Key('tarot-layout-adjustment-toolbar')),
        findsOneWidget,
        reason: label,
      );
      expect(
        find.byKey(const Key('tarot-reading-back-command')),
        findsOneWidget,
        reason: label,
      );
      expect(tester.takeException(), isNull, reason: spreadId);
    }

    for (final spread
        in <
          ({
            String id,
            String label,
            int count,
            double minWidth,
            Set<String> intentionalPairs,
          })
        >[
          (
            id: 'mini_celtic_cross',
            label: '미니 켈틱 크로스',
            count: 6,
            minWidth: 148,
            intentionalPairs: {'2:5'},
          ),
          (
            id: 'celtic_cross',
            label: UserText.tarotSpreadCeltic,
            count: 10,
            minWidth: 122,
            intentionalPairs: {'0:1'},
          ),
          (
            id: 'cross',
            label: '십자',
            count: 5,
            minWidth: 150,
            intentionalPairs: {},
          ),
        ]) {
      await mountAtSpreadStep();
      await selectSpreadAndAutoDraw(spread.label);
      expectSpreadGeometry(
        spreadId: spread.id,
        label: spread.label,
        count: spread.count,
        minCardWidth: spread.minWidth,
        intentionalOverlapPairs: spread.intentionalPairs,
      );
    }
  });

  testWidgets(
    'Tarot relationship cluster spreads keep intentional groups readable',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Future<void> mountAtSpreadStep() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
      }

      Future<void> selectSpreadAndAutoDraw(String label) async {
        await tester.ensureVisible(find.text(label).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
        await tester.tap(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
      }

      bool overlaps(Rect a, Rect b) =>
          a.left < b.right &&
          a.right > b.left &&
          a.top < b.bottom &&
          a.bottom > b.top;

      double horizontalGap(Rect a, Rect b) {
        if (a.right <= b.left) return b.left - a.right;
        if (b.right <= a.left) return a.left - b.right;
        return 0;
      }

      double verticalGap(Rect a, Rect b) {
        if (a.bottom <= b.top) return b.top - a.bottom;
        if (b.bottom <= a.top) return a.top - b.bottom;
        return 0;
      }

      void expectClusterGeometry({
        required String spreadId,
        required String label,
        required int count,
        required double minCardWidth,
        required Set<String> intentionalOverlapPairs,
      }) {
        final board = tester.getRect(
          find.byKey(Key('tarot-fixed-spread-board-$spreadId')),
        );
        final cardRects = [
          for (var index = 0; index < count; index++)
            tester.getRect(
              find.byKey(Key('tarot-fixed-card-visual-$spreadId-$index')),
            ),
        ];
        expect(cardRects, hasLength(count), reason: spreadId);
        for (final rect in cardRects) {
          expect(
            rect.width,
            greaterThanOrEqualTo(minCardWidth),
            reason: '$spreadId readable card width',
          );
          expect(
            rect.left,
            greaterThanOrEqualTo(board.left + 12),
            reason: '$spreadId inside left',
          );
          expect(
            rect.right,
            lessThanOrEqualTo(board.right - 12),
            reason: '$spreadId inside right',
          );
          expect(
            rect.top,
            greaterThanOrEqualTo(board.top + 12),
            reason: '$spreadId inside top',
          );
          expect(
            rect.bottom,
            lessThanOrEqualTo(board.bottom - 12),
            reason: '$spreadId inside bottom',
          );
        }
        for (var a = 0; a < cardRects.length; a++) {
          for (var b = a + 1; b < cardRects.length; b++) {
            final pair = '$a:$b';
            if (intentionalOverlapPairs.contains(pair)) {
              expect(
                overlaps(cardRects[a], cardRects[b]),
                isTrue,
                reason: '$spreadId intentional cluster overlap $pair',
              );
              continue;
            }
            expect(
              overlaps(cardRects[a], cardRects[b]),
              isFalse,
              reason: '$spreadId accidental overlap $pair',
            );
            expect(
              math.max(
                horizontalGap(cardRects[a], cardRects[b]),
                verticalGap(cardRects[a], cardRects[b]),
              ),
              greaterThanOrEqualTo(16),
              reason: '$spreadId near-overlap $pair',
            );
          }
        }
        expect(
          find.byKey(const Key('tarot-layout-adjustment-toolbar')),
          findsOneWidget,
          reason: label,
        );
        expect(
          find.byKey(const Key('tarot-reading-back-command')),
          findsOneWidget,
          reason: label,
        );
        expect(tester.takeException(), isNull, reason: spreadId);
      }

      for (final spread
          in <
            ({
              String id,
              String label,
              int count,
              double minWidth,
              Set<String> intentionalPairs,
            })
          >[
            (
              id: 'reading_mind',
              label: '리딩 마인드',
              count: 9,
              minWidth: 124,
              intentionalPairs: {},
            ),
            (
              id: 'tandem',
              label: '탄뎀',
              count: 6,
              minWidth: 146,
              intentionalPairs: {},
            ),
            (
              id: 'relationship',
              label: '릴레이션십',
              count: 7,
              minWidth: 138,
              intentionalPairs: {},
            ),
            (
              id: 'cup_of_relationship',
              label: '컵 오브 릴레이션십',
              count: 9,
              minWidth: 116,
              intentionalPairs: {'4:6'},
            ),
          ]) {
        await mountAtSpreadStep();
        await selectSpreadAndAutoDraw(spread.label);
        expectClusterGeometry(
          spreadId: spread.id,
          label: spread.label,
          count: spread.count,
          minCardWidth: spread.minWidth,
          intentionalOverlapPairs: spread.intentionalPairs,
        );
      }
    },
  );

  testWidgets(
    'Tarot remaining owner-polish spreads keep readable default geometry',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Future<void> mountAtSpreadStep() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('바로 덱 선택'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
      }

      Future<void> selectSpreadAndAutoDraw(String label) async {
        await tester.ensureVisible(find.text(label).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
        await tester.tap(find.text(UserText.tarotAutoDraw));
        await tester.pumpAndSettle();
      }

      bool overlaps(Rect a, Rect b) =>
          a.left < b.right &&
          a.right > b.left &&
          a.top < b.bottom &&
          a.bottom > b.top;

      double horizontalGap(Rect a, Rect b) {
        if (a.right <= b.left) return b.left - a.right;
        if (b.right <= a.left) return a.left - b.right;
        return 0;
      }

      double verticalGap(Rect a, Rect b) {
        if (a.bottom <= b.top) return b.top - a.bottom;
        if (b.bottom <= a.top) return a.top - b.bottom;
        return 0;
      }

      void expectPolishedGeometry({
        required String spreadId,
        required String label,
        required int count,
        required double minCardWidth,
        required double minSeparation,
      }) {
        final board = tester.getRect(
          find.byKey(Key('tarot-fixed-spread-board-$spreadId')),
        );
        final cardRects = [
          for (var index = 0; index < count; index++)
            tester.getRect(
              find.byKey(Key('tarot-fixed-card-visual-$spreadId-$index')),
            ),
        ];
        expect(cardRects, hasLength(count), reason: spreadId);
        for (final rect in cardRects) {
          expect(
            rect.width,
            greaterThanOrEqualTo(minCardWidth),
            reason: '$spreadId readable card width',
          );
          expect(
            rect.left,
            greaterThanOrEqualTo(board.left + 8),
            reason: '$spreadId inside left',
          );
          expect(
            rect.right,
            lessThanOrEqualTo(board.right - 8),
            reason: '$spreadId inside right',
          );
          expect(
            rect.top,
            greaterThanOrEqualTo(board.top + 8),
            reason: '$spreadId inside top',
          );
          expect(
            rect.bottom,
            lessThanOrEqualTo(board.bottom - 8),
            reason: '$spreadId inside bottom',
          );
        }
        for (var a = 0; a < cardRects.length; a++) {
          for (var b = a + 1; b < cardRects.length; b++) {
            expect(
              overlaps(cardRects[a], cardRects[b]),
              isFalse,
              reason: '$spreadId accidental overlap $a:$b',
            );
            expect(
              math.max(
                horizontalGap(cardRects[a], cardRects[b]),
                verticalGap(cardRects[a], cardRects[b]),
              ),
              greaterThanOrEqualTo(minSeparation),
              reason: '$spreadId near-overlap $a:$b',
            );
          }
        }
        expect(
          find.byKey(const Key('tarot-layout-adjustment-toolbar')),
          findsOneWidget,
          reason: label,
        );
        expect(
          find.byKey(const Key('tarot-reading-back-command')),
          findsOneWidget,
          reason: label,
        );
        expect(tester.takeException(), isNull, reason: spreadId);
      }

      for (final spread
          in <
            ({
              String id,
              String label,
              int count,
              double minWidth,
              double minSeparation,
            })
          >[
            (
              id: 'seven_card',
              label: '7카드',
              count: 7,
              minWidth: 168,
              minSeparation: 16,
            ),
            (
              id: 'binary_choice',
              label: UserText.tarotSpreadBinary,
              count: 5,
              minWidth: 152,
              minSeparation: 16,
            ),
            (
              id: 'horseshoe',
              label: '말발굽',
              count: 5,
              minWidth: 154,
              minSeparation: 16,
            ),
            (
              id: 'horoscope',
              label: '호로스코프',
              count: 13,
              minWidth: 112,
              minSeparation: 4,
            ),
            (
              id: 'year_ahead',
              label: '1년 운세',
              count: 13,
              minWidth: 112,
              minSeparation: 4,
            ),
          ]) {
        await mountAtSpreadStep();
        await selectSpreadAndAutoDraw(spread.label);
        expectPolishedGeometry(
          spreadId: spread.id,
          label: spread.label,
          count: spread.count,
          minCardWidth: spread.minWidth,
          minSeparation: spread.minSeparation,
        );
      }
    },
  );

  testWidgets(
    'Tarot revealed result card opens and closes focus detail overlay',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.2)),
            child: child!,
          ),
          home: Scaffold(
            body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();

      await tester.tap(find.text('모두 펼치기'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tarot-focus-detail-overlay')), findsNothing);

      final boardCardRect = tester.getRect(
        find.byKey(const Key('tarot-focusable-result-card-0')),
      );
      await tester.tap(find.byKey(const Key('tarot-focusable-result-card-0')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const Key('tarot-focus-detail-overlay')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('tarot-focus-reading-scroll')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-card-focus-panel-marker')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tarot-focus-card-image')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-card-focus-reading-prompt')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-focus-meaning-title')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-focus-meaning-orientation-text')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-focus-panel-guidance')),
        findsOneWidget,
      );
      final focusedCardRect = tester.getRect(
        find.byKey(const Key('tarot-focus-card-image')),
      );
      expect(focusedCardRect.height, greaterThan(boardCardRect.height * 1.25));
      expect(find.byKey(const Key('tarot-focus-card-name')), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-focus-card-orientation')),
        findsOneWidget,
      );
      expect(find.text(UserText.tarotUpright), findsWidgets);
      expect(find.text('과거'), findsWidgets);
      expect(find.text(UserText.tarotDeckUniversalWaite), findsOneWidget);
      expect(
        find.byKey(const Key('tarot-layout-adjustment-toolbar')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-reading-back-command')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-fixed-spread-board-three_card')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('tarot-focus-close-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tarot-focus-detail-overlay')), findsNothing);
      expect(
        find.byKey(const Key('tarot-fixed-spread-board-three_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-layout-adjustment-toolbar')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('tarot-reading-back-command')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Tarot all 22 spreads render from manual geometry blueprints', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const spreads = <({String id, String label, int count, bool freeDraw})>[
      (id: 'free_draw', label: '자유 드로우', count: 5, freeDraw: true),
      (
        id: 'one_card',
        label: UserText.tarotSpreadOne,
        count: 1,
        freeDraw: false,
      ),
      (id: 'two_card', label: '2카드', count: 2, freeDraw: false),
      (
        id: 'three_card',
        label: UserText.tarotSpreadThree,
        count: 3,
        freeDraw: false,
      ),
      (
        id: 'four_card',
        label: UserText.tarotSpreadFour,
        count: 4,
        freeDraw: false,
      ),
      (
        id: 'five_card',
        label: UserText.tarotSpreadFive,
        count: 5,
        freeDraw: false,
      ),
      (id: 'seven_card', label: '7카드', count: 7, freeDraw: false),
      (id: 'grid_6', label: '그리드 6', count: 6, freeDraw: false),
      (id: 'grid_8', label: '그리드 8', count: 8, freeDraw: false),
      (id: 'grid_9', label: '그리드 9', count: 9, freeDraw: false),
      (
        id: 'celtic_cross',
        label: UserText.tarotSpreadCeltic,
        count: 10,
        freeDraw: false,
      ),
      (id: 'mini_celtic_cross', label: '미니 켈틱 크로스', count: 6, freeDraw: false),
      (id: 'cross', label: '십자', count: 5, freeDraw: false),
      (id: 'horseshoe', label: '말발굽', count: 5, freeDraw: false),
      (id: 'magic_seven', label: '매직 세븐', count: 7, freeDraw: false),
      (
        id: 'binary_choice',
        label: UserText.tarotSpreadBinary,
        count: 5,
        freeDraw: false,
      ),
      (id: 'reading_mind', label: '리딩 마인드', count: 9, freeDraw: false),
      (id: 'tandem', label: '탄뎀', count: 6, freeDraw: false),
      (id: 'relationship', label: '릴레이션십', count: 7, freeDraw: false),
      (
        id: 'cup_of_relationship',
        label: '컵 오브 릴레이션십',
        count: 9,
        freeDraw: false,
      ),
      (id: 'horoscope', label: '호로스코프', count: 13, freeDraw: false),
      (id: 'year_ahead', label: '1년 운세', count: 13, freeDraw: false),
    ];

    for (final spread in spreads) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TarotSpreadShell(key: UniqueKey(), onBack: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바로 덱 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(spread.label).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(spread.label).first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.tarotAutoDraw));
      await tester.pumpAndSettle();

      expect(
        find.byKey(Key('tarot-result-layout-${spread.count}')),
        findsOneWidget,
        reason: spread.id,
      );
      expect(
        find.byKey(
          Key(
            spread.freeDraw
                ? 'tarot-free-draw-board'
                : 'tarot-fixed-spread-board-${spread.id}',
          ),
        ),
        findsOneWidget,
        reason: spread.id,
      );
      expect(
        find.byKey(const Key('tarot-reading-back-command')),
        findsOneWidget,
        reason: spread.id,
      );
      expect(
        find.byKey(const Key('tarot-layout-adjustment-toolbar')),
        findsOneWidget,
        reason: spread.id,
      );
      expect(
        find.byKey(const Key('tarot-result-card-back-slot')),
        findsAtLeastNWidgets(spread.count),
        reason: spread.id,
      );
      final firstRect = tester.getRect(
        find.byKey(Key('tarot-result-slot-${spread.count}-0')),
      );
      expect(firstRect.width, greaterThan(95), reason: spread.id);
      expect(firstRect.height, greaterThan(160), reason: spread.id);
      expect(tester.takeException(), isNull, reason: spread.id);
    }
  });

  testWidgets(
    'Records nav hides old ledger dashboard while people nav keeps insight map',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1500, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const RynUniverseApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text(UserText.navRecord).first);
      await tester.pumpAndSettle();

      expect(find.text('나의 성장 기록'), findsOneWidget);
      expect(find.text('이번 실행에서 완료한 리딩을 살펴봅니다.'), findsOneWidget);
      expect(find.text('아직 완료한 리딩이 없습니다'), findsOneWidget);
      expect(find.text('새 셀프 타로 시작'), findsOneWidget);
      expect(find.text('사람 이해 중심 기록 홈'), findsNothing);
      expect(find.text('기록 홈'), findsNothing);
      expect(find.text('새 만남 시작'), findsNothing);
      expect(find.text('Group Session'), findsNothing);

      await tester.tap(find.text(UserText.navPeople).first);
      await tester.pumpAndSettle();

      expect(find.text('샘플 사람 A'), findsAtLeastNWidgets(1));
      expect(find.text('이해 지도'), findsAtLeastNWidgets(1));
      expect(find.text('타고난 기질'), findsOneWidget);
      expect(find.text('현재의 흐름'), findsOneWidget);
      expect(find.text('성장 여정'), findsOneWidget);
      expect(find.textContaining('사주 정보 · 아직 연결하지 않음'), findsOneWidget);
      expect(find.textContaining('타로 리딩 · 최근 리딩 있음'), findsOneWidget);
      expect(find.textContaining('타로 스터디 4회차 참여'), findsOneWidget);

      final visibleText = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .join('\n');
      for (final forbidden in [
        'DB',
        'schema',
        'CRUD',
        'migration',
        'prediction engine',
        'diagnosis',
        'fortune guarantee',
        'analysis engine',
        'payload',
        'entity',
        'table',
        'repository',
        'internal ID',
        'developer',
        'governance',
        '레저',
      ]) {
        expect(visibleText.contains(forbidden), isFalse, reason: forbidden);
      }
    },
  );
}
