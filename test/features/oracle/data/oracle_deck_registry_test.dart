import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/oracle/data/oracle_deck_registry.dart';
import 'package:ryn_universe_os_core/features/oracle/domain/oracle_card_definition.dart';
import 'package:ryn_universe_os_core/features/oracle/domain/oracle_deck_definition.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registry exposes exactly the approved available Oracle deck', () {
    expect(OracleDeckRegistry.decks, hasLength(1));
    expect(OracleDeckRegistry.availableDecks, hasLength(1));

    final deck = OracleDeckRegistry.deckById('horoscope_belline');
    expect(deck, isNotNull);
    expect(deck!.deckId, 'horoscope_belline');
    expect(deck.displayName, '호로스코프 벨린 오라클');
    expect(deck.cardCount, 52);
    expect(deck.cards, hasLength(52));
    expect(deck.recommendedDrawCounts, [1, 3]);
    expect(deck.supportsReversal, isFalse);
    expect(deck.isAvailable, isTrue);
    expect(OracleDeckRegistry.firstAvailable, same(deck));
  });

  test('approved card mapping preserves sequence titles and qualified IDs', () {
    final deck = OracleDeckRegistry.deckById('horoscope_belline')!;
    expect(
      deck.cards.map((card) => card.sequence),
      List.generate(52, (i) => i + 1),
    );
    expect(deck.cards.map((card) => card.cardId).toSet(), hasLength(52));
    expect(
      deck.cards
          .map((card) => card.title)
          .every((value) => value.trim().isNotEmpty),
      isTrue,
    );
    expect(
      deck.cards
          .map((card) => card.originalTitle)
          .every((value) => value != null && value.trim().isNotEmpty),
      isTrue,
    );

    final qualifiedIds = deck.cards
        .map((card) => deck.qualifiedCardId(card.cardId))
        .toSet();
    expect(qualifiedIds, hasLength(52));
    expect(
      deck.qualifiedCardId('001_la_pensee_de_l_homme'),
      'oracle.horoscope_belline.001_la_pensee_de_l_homme',
    );
    expect(
      deck.qualifiedCardId('023_le_message'),
      'oracle.horoscope_belline.023_le_message',
    );
    expect(
      deck.qualifiedCardId('052_le_labyrinthe'),
      'oracle.horoscope_belline.052_le_labyrinthe',
    );
  });

  test('approved Oracle assets exist and every image is readable', () async {
    final deck = OracleDeckRegistry.deckById('horoscope_belline')!;
    final assetPaths = <String>[
      deck.coverAssetPath,
      deck.cardBackAssetPath,
      ...deck.cards.map((card) => card.imageAssetPath),
    ];
    expect(assetPaths, hasLength(54));
    expect(assetPaths.toSet(), hasLength(54));

    for (final assetPath in assetPaths) {
      final file = File(assetPath);
      expect(file.existsSync(), isTrue, reason: assetPath);
      final codec = await ui.instantiateImageCodec(await file.readAsBytes());
      expect(codec.frameCount, greaterThanOrEqualTo(1), reason: assetPath);
      codec.dispose();
    }
  });

  test('approved source and destination image contents match', () {
    final sourceRoot = Platform.environment['RYN_ORACLE_SOURCE_ROOT'];
    if (sourceRoot == null || sourceRoot.trim().isEmpty) return;

    final deck = OracleDeckRegistry.deckById('horoscope_belline')!;
    final sourceDirectory = Directory(sourceRoot);
    expect(sourceDirectory.existsSync(), isTrue);

    final sourceFiles = sourceDirectory.listSync().whereType<File>().toList();
    File sourceNamed(String name) =>
        sourceFiles.singleWhere((file) => file.uri.pathSegments.last == name);

    var mismatchCount = 0;
    for (final card in deck.cards) {
      final prefix = 'HB_${card.sequence.toString().padLeft(2, '0')}_';
      final source = sourceFiles.singleWhere(
        (file) => file.uri.pathSegments.last.startsWith(prefix),
      );
      final destination = File(card.imageAssetPath);
      if (!listEquals(
        source.readAsBytesSync(),
        destination.readAsBytesSync(),
      )) {
        mismatchCount++;
      }
    }
    final cover = sourceNamed('HB_Oracle_Tarot_Card_cover.jpg');
    final back = sourceNamed('HB_Oracle_Tarot_Card_back.jpg');
    if (!listEquals(
      cover.readAsBytesSync(),
      File(deck.coverAssetPath).readAsBytesSync(),
    )) {
      mismatchCount++;
    }
    if (!listEquals(
      back.readAsBytesSync(),
      File(deck.cardBackAssetPath).readAsBytesSync(),
    )) {
      mismatchCount++;
    }
    expect(mismatchCount, 0);
  });

  test('unknown IDs fail closed and Oracle code has no Tarot dependency', () {
    expect(OracleDeckRegistry.deckById('unknown'), isNull);
    expect(OracleDeckRegistry.cardById('unknown', '001_anything'), isNull);
    expect(OracleDeckRegistry.cardById('horoscope_belline', 'unknown'), isNull);
    expect(
      OracleDeckRegistry.qualifiedCardId('unknown', '001_anything'),
      isNull,
    );

    final oracleFiles = Directory('lib/features/oracle')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in oracleFiles) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('/tarot/')), reason: file.path);
      expect(source, isNot(contains('features.tarot')), reason: file.path);
    }
  });

  test('Oracle contracts reject invalid card and deck definitions', () {
    expect(
      () => OracleCardDefinition(
        cardId: ' ',
        sequence: 1,
        title: 'Valid title',
        imageAssetPath: 'asset.jpg',
      ),
      throwsArgumentError,
    );
    expect(
      () => OracleDeckDefinition(
        deckId: 'invalid',
        displayName: 'Invalid',
        description: 'Invalid deck',
        cardCount: 2,
        coverAssetPath: 'cover.jpg',
        cardBackAssetPath: 'back.jpg',
        supportsReversal: false,
        recommendedDrawCounts: const [1],
        cards: [
          OracleCardDefinition(
            cardId: '001',
            sequence: 1,
            title: 'One',
            imageAssetPath: 'one.jpg',
          ),
        ],
      ),
      throwsArgumentError,
    );
  });
}
