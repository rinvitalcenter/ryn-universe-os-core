import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/tarot/data/tarot_deck_registry.dart';

void main() {
  const newDeckRoots = <String, String>{
    'chubby_bun_ver_2_tarot': 'assets/tarot/decks/chubby_bun_ver_2_tarot/',
    'heaven_earth_tarot': 'assets/tarot/decks/heaven_earth_tarot/',
    'light_seers_tarot': 'assets/tarot/decks/light_seers_tarot/',
    'samramansang_tarot': 'assets/tarot/decks/samramansang_tarot/',
    'tarot_of_mystical_moments':
        'assets/tarot/decks/tarot_of_mystical_moments/',
  };

  test(
    'local tarot deck registry keeps unique complete canonical mappings',
    () {
      final registryIds = TarotDeckRegistry.decks
          .map((deck) => deck.deckId)
          .toList();
      expect(registryIds.toSet(), hasLength(registryIds.length));

      final canonicalIds = TarotDeckRegistry.rwsPublicDomain.cards
          .map((card) => card.semanticId)
          .toSet();
      expect(canonicalIds, hasLength(78));

      for (final entry in newDeckRoots.entries) {
        final deck = TarotDeckRegistry.decks.singleWhere(
          (candidate) => candidate.deckId == entry.key,
        );
        final ids = deck.cards.map((card) => card.semanticId).toList();
        final fallbackAssets = deck.cards
            .where((card) => !card.assetPath.startsWith(entry.value))
            .toList();

        expect(deck.displayName.trim(), isNotEmpty, reason: entry.key);
        expect(deck.cards, hasLength(78), reason: entry.key);
        expect(ids.toSet(), hasLength(78), reason: entry.key);
        expect(ids.toSet(), canonicalIds, reason: entry.key);
        expect(fallbackAssets, isEmpty, reason: entry.key);
        expect(deck.coverAssetPath, startsWith('${entry.value}cover/'));
        expect(deck.cardBackAssetPath, startsWith('${entry.value}back/'));
        expect(
          deck.representativeAssetPath,
          startsWith('${entry.value}major/'),
        );

        for (final path in <String>[
          deck.coverAssetPath!,
          deck.cardBackAssetPath!,
          deck.representativeAssetPath!,
          ...deck.cards.map((card) => card.assetPath),
        ]) {
          expect(File(path).existsSync(), isTrue, reason: '$entry / $path');
        }
      }
    },
  );

  test('local deck manifests and pubspec declare only deck-owned assets', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    for (final entry in newDeckRoots.entries) {
      final root = entry.value.substring(0, entry.value.length - 1);
      for (final suffix in ['', 'major/', 'minor/', 'back/', 'cover/']) {
        expect(pubspec, contains('- $root/$suffix'), reason: '$root/$suffix');
      }

      final manifestFile = File('${entry.value}deck_manifest.json');
      expect(manifestFile.existsSync(), isTrue, reason: entry.key);
      final manifest =
          jsonDecode(manifestFile.readAsStringSync()) as Map<String, Object?>;
      final cards = manifest['cards']! as List<Object?>;
      expect(manifest['deckId'], entry.key);
      expect(manifest['deckType'], 'tarot_78');
      expect(manifest['cardCount'], 78);
      expect(cards, hasLength(78));
      expect(
        cards.cast<Map<String, Object?>>().every(
          (card) => (card['image']! as String).startsWith(entry.value),
        ),
        isTrue,
        reason: entry.key,
      );
    }
  });

  test(
    'existing integrated decks remain complete and placeholders unavailable',
    () {
      for (final deck in <MapEntry<String, String>>[
        const MapEntry(
          'rws_public_domain',
          'assets/tarot/decks/rws_public_domain/',
        ),
        const MapEntry(
          'universal_waite',
          'assets/tarot/decks/universal_waite/',
        ),
        const MapEntry(
          'golden_art_nouveau_tarot',
          'assets/tarot/decks/golden_art_nouveau_tarot/',
        ),
      ]) {
        final definition = TarotDeckRegistry.decks.singleWhere(
          (candidate) => candidate.deckId == deck.key,
        );
        expect(definition.cards, hasLength(78), reason: deck.key);
        expect(
          definition.cards.every(
            (card) => card.assetPath.startsWith(deck.value),
          ),
          isTrue,
          reason: deck.key,
        );
      }

      for (final unavailableId in <String>[
        'thoth',
        'marseille',
        'manshin_1',
        'manshin_2',
        'oracle',
        'lenormand',
        'personal_scan',
      ]) {
        final deck = TarotDeckRegistry.decks.singleWhere(
          (candidate) => candidate.deckId == unavailableId,
        );
        expect(deck.cards, isEmpty, reason: unavailableId);
        expect(deck.assetBacked, isFalse, reason: unavailableId);
      }
    },
  );

  test('runtime source keeps selected-deck cover back and front binding', () {
    final source = File(
      'lib/features/tarot/tarot_spread_shell.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('deck.coverAssetPath ?? deck.representativeAssetPath'),
    );
    expect(source, contains('_selectedDeck.cardBackAssetPath'));
    expect(
      source,
      contains(
        '_remainingDeck = List<TarotCardDefinition>.of(_selectedDeck.cards)',
      ),
    );
    expect(
      source,
      isNot(contains('selectedDeckCardBack: selectedCardBack')),
      reason:
          'unavailable deck previews must not inherit the selected deck back',
    );
  });
}
