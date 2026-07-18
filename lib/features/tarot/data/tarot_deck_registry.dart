import 'package:ryn_universe_os_core/core/text/user_text.dart';

import '../models/tarot_card_definition.dart';
import '../models/tarot_deck_definition.dart';
import 'tarot_card_ids.dart';
import 'tarot_local_deck_cards.dart';

class TarotDeckRegistry {
  const TarotDeckRegistry._();

  static const String rwsPublicDomainDeckId = 'rws_public_domain';
  static const String universalWaiteDeckId = 'universal_waite';
  static const String goldenArtNouveauDeckId = 'golden_art_nouveau_tarot';
  static const String chubbyBunVer2DeckId = 'chubby_bun_ver_2_tarot';
  static const String heavenEarthDeckId = 'heaven_earth_tarot';
  static const String lightSeersDeckId = 'light_seers_tarot';
  static const String samramansangDeckId = 'samramansang_tarot';
  static const String tarotOfMysticalMomentsDeckId =
      'tarot_of_mystical_moments';

  static const List<TarotCardDefinition> rwsCards = [
    TarotCardDefinition(
      'cups_01',
      'Ace of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups01.jpg',
    ),
    TarotCardDefinition(
      'cups_02',
      '2 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups02.jpg',
    ),
    TarotCardDefinition(
      'cups_03',
      '3 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups03.jpg',
    ),
    TarotCardDefinition(
      'cups_04',
      '4 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups04.jpg',
    ),
    TarotCardDefinition(
      'cups_05',
      '5 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups05.jpg',
    ),
    TarotCardDefinition(
      'cups_06',
      '6 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups06.jpg',
    ),
    TarotCardDefinition(
      'cups_07',
      '7 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups07.jpg',
    ),
    TarotCardDefinition(
      'cups_08',
      '8 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups08.jpg',
    ),
    TarotCardDefinition(
      'cups_09',
      '9 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups09.jpg',
    ),
    TarotCardDefinition(
      'cups_10',
      '10 of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups10.jpg',
    ),
    TarotCardDefinition(
      'cups_11',
      'Page of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups11.jpg',
    ),
    TarotCardDefinition(
      'cups_12',
      'Knight of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups12.jpg',
    ),
    TarotCardDefinition(
      'cups_13',
      'Queen of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups13.jpg',
    ),
    TarotCardDefinition(
      'cups_14',
      'King of Cups',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Cups14.jpg',
    ),
    TarotCardDefinition(
      'major_00',
      'The Fool',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_00_Fool.jpg',
    ),
    TarotCardDefinition(
      'major_01',
      'The Magician',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_01_Magician.jpg',
    ),
    TarotCardDefinition(
      'major_02',
      'The High Priestess',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_02_High_Priestess.jpg',
    ),
    TarotCardDefinition(
      'major_03',
      'The Empress',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_03_Empress.jpg',
    ),
    TarotCardDefinition(
      'major_04',
      'The Emperor',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_04_Emperor.jpg',
    ),
    TarotCardDefinition(
      'major_05',
      'The Hierophant',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_05_Hierophant.jpg',
    ),
    TarotCardDefinition(
      'major_06',
      'The Lovers',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_06_Lovers.jpg',
    ),
    TarotCardDefinition(
      'major_07',
      'The Chariot',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_07_Chariot.jpg',
    ),
    TarotCardDefinition(
      'major_08',
      'Strength',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_08_Strength.jpg',
    ),
    TarotCardDefinition(
      'major_09',
      'The Hermit',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_09_Hermit.jpg',
    ),
    TarotCardDefinition(
      'major_10',
      'Wheel of Fortune',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_10_Wheel_of_Fortune.jpg',
    ),
    TarotCardDefinition(
      'major_11',
      'Justice',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_11_Justice.jpg',
    ),
    TarotCardDefinition(
      'major_12',
      'The Hanged Man',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_12_Hanged_Man.jpg',
    ),
    TarotCardDefinition(
      'major_13',
      'Death',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_13_Death.jpg',
    ),
    TarotCardDefinition(
      'major_14',
      'Temperance',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_14_Temperance.jpg',
    ),
    TarotCardDefinition(
      'major_15',
      'The Devil',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_15_Devil.jpg',
    ),
    TarotCardDefinition(
      'major_16',
      'The Tower',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_16_Tower.jpg',
    ),
    TarotCardDefinition(
      'major_17',
      'The Star',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_17_Star.jpg',
    ),
    TarotCardDefinition(
      'major_18',
      'The Moon',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_18_Moon.jpg',
    ),
    TarotCardDefinition(
      'major_19',
      'The Sun',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_19_Sun.jpg',
    ),
    TarotCardDefinition(
      'major_20',
      'Judgement',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_20_Judgement.jpg',
    ),
    TarotCardDefinition(
      'major_21',
      'The World',
      'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_21_World.jpg',
    ),
    TarotCardDefinition(
      'pents_01',
      'Ace of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents01.jpg',
    ),
    TarotCardDefinition(
      'pents_02',
      '2 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents02.jpg',
    ),
    TarotCardDefinition(
      'pents_03',
      '3 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents03.jpg',
    ),
    TarotCardDefinition(
      'pents_04',
      '4 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents04.jpg',
    ),
    TarotCardDefinition(
      'pents_05',
      '5 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents05.jpg',
    ),
    TarotCardDefinition(
      'pents_06',
      '6 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents06.jpg',
    ),
    TarotCardDefinition(
      'pents_07',
      '7 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents07.jpg',
    ),
    TarotCardDefinition(
      'pents_08',
      '8 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents08.jpg',
    ),
    TarotCardDefinition(
      'pents_09',
      '9 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents09.jpg',
    ),
    TarotCardDefinition(
      'pents_10',
      '10 of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents10.jpg',
    ),
    TarotCardDefinition(
      'pents_11',
      'Page of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents11.jpg',
    ),
    TarotCardDefinition(
      'pents_12',
      'Knight of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents12.jpg',
    ),
    TarotCardDefinition(
      'pents_13',
      'Queen of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents13.jpg',
    ),
    TarotCardDefinition(
      'pents_14',
      'King of Pentacles',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Pents14.jpg',
    ),
    TarotCardDefinition(
      'swords_01',
      'Ace of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords01.jpg',
    ),
    TarotCardDefinition(
      'swords_02',
      '2 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords02.jpg',
    ),
    TarotCardDefinition(
      'swords_03',
      '3 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords03.jpg',
    ),
    TarotCardDefinition(
      'swords_04',
      '4 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords04.jpg',
    ),
    TarotCardDefinition(
      'swords_05',
      '5 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords05.jpg',
    ),
    TarotCardDefinition(
      'swords_06',
      '6 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords06.jpg',
    ),
    TarotCardDefinition(
      'swords_07',
      '7 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords07.jpg',
    ),
    TarotCardDefinition(
      'swords_08',
      '8 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords08.jpg',
    ),
    TarotCardDefinition(
      'swords_09',
      '9 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords09.jpg',
    ),
    TarotCardDefinition(
      'swords_10',
      '10 of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords10.jpg',
    ),
    TarotCardDefinition(
      'swords_11',
      'Page of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords11.jpg',
    ),
    TarotCardDefinition(
      'swords_12',
      'Knight of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords12.jpg',
    ),
    TarotCardDefinition(
      'swords_13',
      'Queen of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords13.jpg',
    ),
    TarotCardDefinition(
      'swords_14',
      'King of Swords',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Swords14.jpg',
    ),
    TarotCardDefinition(
      'wands_01',
      'Ace of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands01.jpg',
    ),
    TarotCardDefinition(
      'wands_02',
      '2 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands02.jpg',
    ),
    TarotCardDefinition(
      'wands_03',
      '3 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands03.jpg',
    ),
    TarotCardDefinition(
      'wands_04',
      '4 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands04.jpg',
    ),
    TarotCardDefinition(
      'wands_05',
      '5 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands05.jpg',
    ),
    TarotCardDefinition(
      'wands_06',
      '6 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands06.jpg',
    ),
    TarotCardDefinition(
      'wands_07',
      '7 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands07.jpg',
    ),
    TarotCardDefinition(
      'wands_08',
      '8 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands08.jpg',
    ),
    TarotCardDefinition(
      'wands_09',
      '9 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands09.jpg',
    ),
    TarotCardDefinition(
      'wands_10',
      '10 of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands10.jpg',
    ),
    TarotCardDefinition(
      'wands_11',
      'Page of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands11.jpg',
    ),
    TarotCardDefinition(
      'wands_12',
      'Knight of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands12.jpg',
    ),
    TarotCardDefinition(
      'wands_13',
      'Queen of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands13.jpg',
    ),
    TarotCardDefinition(
      'wands_14',
      'King of Wands',
      'assets/tarot/decks/rws_public_domain/minor/RWS_Tarot_Wands14.jpg',
    ),
  ];

  static const List<TarotCardDefinition> universalWaiteCards = [
    TarotCardDefinition(
      'cups_01',
      'Ace of Cups',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Cups01.jpg',
    ),
    TarotCardDefinition(
      'cups_02',
      '2 of Cups',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Cups02.jpg',
    ),
    TarotCardDefinition(
      'cups_03',
      '3 of Cups',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Cups03.jpg',
    ),
    TarotCardDefinition(
      'cups_04',
      '4 of Cups',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Cups04.jpg',
    ),
    TarotCardDefinition(
      'cups_05',
      '5 of Cups',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Cups05.jpg',
    ),
    TarotCardDefinition(
      'cups_06',
      '6 of Cups',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Cups06.jpg',
    ),
    TarotCardDefinition(
      'cups_07',
      '7 of Cups',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Cups07.jpg',
    ),
    TarotCardDefinition(
      'cups_08',
      '8 of Cups',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Cups08.jpg',
    ),
    TarotCardDefinition(
      'cups_09',
      '9 of Cups',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Cups09.jpg',
    ),
    TarotCardDefinition(
      'cups_10',
      '10 of Cups',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Cups10.jpg',
    ),
    TarotCardDefinition(
      'cups_11',
      'Page of Cups',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Cups11.jpg',
    ),
    TarotCardDefinition(
      'cups_12',
      'Knight of Cups',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Cups12.jpg',
    ),
    TarotCardDefinition(
      'cups_13',
      'Queen of Cups',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Cups13.jpg',
    ),
    TarotCardDefinition(
      'cups_14',
      'King of Cups',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Cups14.jpg',
    ),
    TarotCardDefinition(
      'major_00',
      'The Fool',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_00_Fool.jpg',
    ),
    TarotCardDefinition(
      'major_01',
      'The Magician',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_01_Magician.jpg',
    ),
    TarotCardDefinition(
      'major_02',
      'The High Priestess',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_02_High_Priestess.jpg',
    ),
    TarotCardDefinition(
      'major_03',
      'The Empress',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_03_Empress.jpg',
    ),
    TarotCardDefinition(
      'major_04',
      'The Emperor',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_04_Emperor.jpg',
    ),
    TarotCardDefinition(
      'major_05',
      'The Hierophant',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_05_Hierophant.jpg',
    ),
    TarotCardDefinition(
      'major_06',
      'The Lovers',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_06_Lovers.jpg',
    ),
    TarotCardDefinition(
      'major_07',
      'The Chariot',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_07_Chariot.jpg',
    ),
    TarotCardDefinition(
      'major_08',
      'Strength',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_08_Strength.jpg',
    ),
    TarotCardDefinition(
      'major_09',
      'The Hermit',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_09_Hermit.jpg',
    ),
    TarotCardDefinition(
      'major_10',
      'Wheel of Fortune',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_10_Wheel_of_Fortune.jpg',
    ),
    TarotCardDefinition(
      'major_11',
      'Justice',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_11_Justice.jpg',
    ),
    TarotCardDefinition(
      'major_12',
      'The Hanged Man',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_12_Hanged_Man.jpg',
    ),
    TarotCardDefinition(
      'major_13',
      'Death',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_13_Death.jpg',
    ),
    TarotCardDefinition(
      'major_14',
      'Temperance',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_14_Temperance.jpg',
    ),
    TarotCardDefinition(
      'major_15',
      'The Devil',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_15_Devil.jpg',
    ),
    TarotCardDefinition(
      'major_16',
      'The Tower',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_16_Tower.jpg',
    ),
    TarotCardDefinition(
      'major_17',
      'The Star',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_17_Star.jpg',
    ),
    TarotCardDefinition(
      'major_18',
      'The Moon',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_18_Moon.jpg',
    ),
    TarotCardDefinition(
      'major_19',
      'The Sun',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_19_Sun.jpg',
    ),
    TarotCardDefinition(
      'major_20',
      'Judgement',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_20_Judgement.jpg',
    ),
    TarotCardDefinition(
      'major_21',
      'The World',
      'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_21_World.jpg',
    ),
    TarotCardDefinition(
      'pents_01',
      'Ace of Pentacles',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Pentacles01.jpg',
    ),
    TarotCardDefinition(
      'pents_02',
      '2 of Pentacles',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Pentacles02.jpg',
    ),
    TarotCardDefinition(
      'pents_03',
      '3 of Pentacles',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Pentacles03.jpg',
    ),
    TarotCardDefinition(
      'pents_04',
      '4 of Pentacles',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Pentacles04.jpg',
    ),
    TarotCardDefinition(
      'pents_05',
      '5 of Pentacles',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Pentacles05.jpg',
    ),
    TarotCardDefinition(
      'pents_06',
      '6 of Pentacles',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Pentacles06.jpg',
    ),
    TarotCardDefinition(
      'pents_07',
      '7 of Pentacles',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Pentacles07.jpg',
    ),
    TarotCardDefinition(
      'pents_08',
      '8 of Pentacles',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Pentacles08.jpg',
    ),
    TarotCardDefinition(
      'pents_09',
      '9 of Pentacles',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Pentacles09.jpg',
    ),
    TarotCardDefinition(
      'pents_10',
      '10 of Pentacles',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Pentacles10.jpg',
    ),
    TarotCardDefinition(
      'pents_11',
      'Page of Pentacles',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Pentacles11.jpg',
    ),
    TarotCardDefinition(
      'pents_12',
      'Knight of Pentacles',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Pentacles12.jpg',
    ),
    TarotCardDefinition(
      'pents_13',
      'Queen of Pentacles',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Pentacles13.jpg',
    ),
    TarotCardDefinition(
      'pents_14',
      'King of Pentacles',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Pentacles14.jpg',
    ),
    TarotCardDefinition(
      'swords_01',
      'Ace of Swords',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Swords01.jpg',
    ),
    TarotCardDefinition(
      'swords_02',
      '2 of Swords',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Swords02.jpg',
    ),
    TarotCardDefinition(
      'swords_03',
      '3 of Swords',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Swords03.jpg',
    ),
    TarotCardDefinition(
      'swords_04',
      '4 of Swords',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Swords04.jpg',
    ),
    TarotCardDefinition(
      'swords_05',
      '5 of Swords',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Swords05.jpg',
    ),
    TarotCardDefinition(
      'swords_06',
      '6 of Swords',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Swords06.jpg',
    ),
    TarotCardDefinition(
      'swords_07',
      '7 of Swords',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Swords07.jpg',
    ),
    TarotCardDefinition(
      'swords_08',
      '8 of Swords',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Swords08.jpg',
    ),
    TarotCardDefinition(
      'swords_09',
      '9 of Swords',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Swords09.jpg',
    ),
    TarotCardDefinition(
      'swords_10',
      '10 of Swords',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Swords10.jpg',
    ),
    TarotCardDefinition(
      'swords_11',
      'Page of Swords',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Swords11.jpg',
    ),
    TarotCardDefinition(
      'swords_12',
      'Knight of Swords',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Swords12.jpg',
    ),
    TarotCardDefinition(
      'swords_13',
      'Queen of Swords',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Swords13.jpg',
    ),
    TarotCardDefinition(
      'swords_14',
      'King of Swords',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Swords14.jpg',
    ),
    TarotCardDefinition(
      'wands_01',
      'Ace of Wands',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Wands01.jpg',
    ),
    TarotCardDefinition(
      'wands_02',
      '2 of Wands',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Wands02.jpg',
    ),
    TarotCardDefinition(
      'wands_03',
      '3 of Wands',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Wands03.jpg',
    ),
    TarotCardDefinition(
      'wands_04',
      '4 of Wands',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Wands04.jpg',
    ),
    TarotCardDefinition(
      'wands_05',
      '5 of Wands',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Wands05.jpg',
    ),
    TarotCardDefinition(
      'wands_06',
      '6 of Wands',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Wands06.jpg',
    ),
    TarotCardDefinition(
      'wands_07',
      '7 of Wands',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Wands07.jpg',
    ),
    TarotCardDefinition(
      'wands_08',
      '8 of Wands',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Wands08.jpg',
    ),
    TarotCardDefinition(
      'wands_09',
      '9 of Wands',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Wands09.jpg',
    ),
    TarotCardDefinition(
      'wands_10',
      '10 of Wands',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Wands10.jpg',
    ),
    TarotCardDefinition(
      'wands_11',
      'Page of Wands',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Wands11.jpg',
    ),
    TarotCardDefinition(
      'wands_12',
      'Knight of Wands',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Wands12.jpg',
    ),
    TarotCardDefinition(
      'wands_13',
      'Queen of Wands',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Wands13.jpg',
    ),
    TarotCardDefinition(
      'wands_14',
      'King of Wands',
      'assets/tarot/decks/universal_waite/minor/Universal_Waite_Tarot_Wands14.jpg',
    ),
  ];

  static const List<TarotCardDefinition> goldenArtNouveauCards = [
    TarotCardDefinition(
      'cups_01',
      'Ace of Cups',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Cups01.jpg',
    ),
    TarotCardDefinition(
      'cups_02',
      '2 of Cups',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Cups02.jpg',
    ),
    TarotCardDefinition(
      'cups_03',
      '3 of Cups',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Cups03.jpg',
    ),
    TarotCardDefinition(
      'cups_04',
      '4 of Cups',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Cups04.jpg',
    ),
    TarotCardDefinition(
      'cups_05',
      '5 of Cups',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Cups05.jpg',
    ),
    TarotCardDefinition(
      'cups_06',
      '6 of Cups',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Cups06.jpg',
    ),
    TarotCardDefinition(
      'cups_07',
      '7 of Cups',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Cups07.jpg',
    ),
    TarotCardDefinition(
      'cups_08',
      '8 of Cups',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Cups08.jpg',
    ),
    TarotCardDefinition(
      'cups_09',
      '9 of Cups',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Cups09.jpg',
    ),
    TarotCardDefinition(
      'cups_10',
      '10 of Cups',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Cups10.jpg',
    ),
    TarotCardDefinition(
      'cups_11',
      'Page of Cups',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Cups11.jpg',
    ),
    TarotCardDefinition(
      'cups_12',
      'Knight of Cups',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Cups12.jpg',
    ),
    TarotCardDefinition(
      'cups_13',
      'Queen of Cups',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Cups13.jpg',
    ),
    TarotCardDefinition(
      'cups_14',
      'King of Cups',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Cups14.jpg',
    ),
    TarotCardDefinition(
      'major_00',
      'The Fool',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_00_Fool.jpg',
    ),
    TarotCardDefinition(
      'major_01',
      'The Magician',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_01_Magician.jpg',
    ),
    TarotCardDefinition(
      'major_02',
      'The High Priestess',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_02_High_Priestess.jpg',
    ),
    TarotCardDefinition(
      'major_03',
      'The Empress',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_03_Empress.jpg',
    ),
    TarotCardDefinition(
      'major_04',
      'The Emperor',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_04_Emperor.jpg',
    ),
    TarotCardDefinition(
      'major_05',
      'The Hierophant',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_05_Hierophant.jpg',
    ),
    TarotCardDefinition(
      'major_06',
      'The Lovers',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_06_Lovers.jpg',
    ),
    TarotCardDefinition(
      'major_07',
      'The Chariot',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_07_Chariot.jpg',
    ),
    TarotCardDefinition(
      'major_08',
      'Strength',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_08_Strength.jpg',
    ),
    TarotCardDefinition(
      'major_09',
      'The Hermit',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_09_Hermit.jpg',
    ),
    TarotCardDefinition(
      'major_10',
      'Wheel of Fortune',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_10_Wheel_of_Fortune.jpg',
    ),
    TarotCardDefinition(
      'major_11',
      'Justice',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_11_Justice.jpg',
    ),
    TarotCardDefinition(
      'major_12',
      'The Hanged Man',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_12_Hanged_Man.jpg',
    ),
    TarotCardDefinition(
      'major_13',
      'Death',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_13_Death.jpg',
    ),
    TarotCardDefinition(
      'major_14',
      'Temperance',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_14_Temperance.jpg',
    ),
    TarotCardDefinition(
      'major_15',
      'The Devil',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_15_Devil.jpg',
    ),
    TarotCardDefinition(
      'major_16',
      'The Tower',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_16_Tower.jpg',
    ),
    TarotCardDefinition(
      'major_17',
      'The Star',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_17_Star.jpg',
    ),
    TarotCardDefinition(
      'major_18',
      'The Moon',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_18_Moon.jpg',
    ),
    TarotCardDefinition(
      'major_19',
      'The Sun',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_19_Sun.jpg',
    ),
    TarotCardDefinition(
      'major_20',
      'Judgement',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_20_Judgement.jpg',
    ),
    TarotCardDefinition(
      'major_21',
      'The World',
      'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_21_World.jpg',
    ),
    TarotCardDefinition(
      'pents_01',
      'Ace of Pentacles',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Pentacles01.jpg',
    ),
    TarotCardDefinition(
      'pents_02',
      '2 of Pentacles',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Pentacles02.jpg',
    ),
    TarotCardDefinition(
      'pents_03',
      '3 of Pentacles',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Pentacles03.jpg',
    ),
    TarotCardDefinition(
      'pents_04',
      '4 of Pentacles',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Pentacles04.jpg',
    ),
    TarotCardDefinition(
      'pents_05',
      '5 of Pentacles',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Pentacles05.jpg',
    ),
    TarotCardDefinition(
      'pents_06',
      '6 of Pentacles',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Pentacles06.jpg',
    ),
    TarotCardDefinition(
      'pents_07',
      '7 of Pentacles',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Pentacles07.jpg',
    ),
    TarotCardDefinition(
      'pents_08',
      '8 of Pentacles',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Pentacles08.jpg',
    ),
    TarotCardDefinition(
      'pents_09',
      '9 of Pentacles',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Pentacles09.jpg',
    ),
    TarotCardDefinition(
      'pents_10',
      '10 of Pentacles',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Pentacles10.jpg',
    ),
    TarotCardDefinition(
      'pents_11',
      'Page of Pentacles',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Pentacles11.jpg',
    ),
    TarotCardDefinition(
      'pents_12',
      'Knight of Pentacles',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Pentacles12.jpg',
    ),
    TarotCardDefinition(
      'pents_13',
      'Queen of Pentacles',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Pentacles13.jpg',
    ),
    TarotCardDefinition(
      'pents_14',
      'King of Pentacles',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Pentacles14.jpg',
    ),
    TarotCardDefinition(
      'swords_01',
      'Ace of Swords',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Swords01.jpg',
    ),
    TarotCardDefinition(
      'swords_02',
      '2 of Swords',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Swords02.jpg',
    ),
    TarotCardDefinition(
      'swords_03',
      '3 of Swords',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Swords03.jpg',
    ),
    TarotCardDefinition(
      'swords_04',
      '4 of Swords',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Swords04.jpg',
    ),
    TarotCardDefinition(
      'swords_05',
      '5 of Swords',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Swords05.jpg',
    ),
    TarotCardDefinition(
      'swords_06',
      '6 of Swords',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Swords06.jpg',
    ),
    TarotCardDefinition(
      'swords_07',
      '7 of Swords',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Swords07.jpg',
    ),
    TarotCardDefinition(
      'swords_08',
      '8 of Swords',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Swords08.jpg',
    ),
    TarotCardDefinition(
      'swords_09',
      '9 of Swords',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Swords09.jpg',
    ),
    TarotCardDefinition(
      'swords_10',
      '10 of Swords',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Swords10.jpg',
    ),
    TarotCardDefinition(
      'swords_11',
      'Page of Swords',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Swords11.jpg',
    ),
    TarotCardDefinition(
      'swords_12',
      'Knight of Swords',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Swords12.jpg',
    ),
    TarotCardDefinition(
      'swords_13',
      'Queen of Swords',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Swords13.jpg',
    ),
    TarotCardDefinition(
      'swords_14',
      'King of Swords',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Swords14.jpg',
    ),
    TarotCardDefinition(
      'wands_01',
      'Ace of Wands',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Wands01.jpg',
    ),
    TarotCardDefinition(
      'wands_02',
      '2 of Wands',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Wands02.jpg',
    ),
    TarotCardDefinition(
      'wands_03',
      '3 of Wands',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Wands03.jpg',
    ),
    TarotCardDefinition(
      'wands_04',
      '4 of Wands',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Wands04.jpg',
    ),
    TarotCardDefinition(
      'wands_05',
      '5 of Wands',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Wands05.jpg',
    ),
    TarotCardDefinition(
      'wands_06',
      '6 of Wands',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Wands06.jpg',
    ),
    TarotCardDefinition(
      'wands_07',
      '7 of Wands',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Wands07.jpg',
    ),
    TarotCardDefinition(
      'wands_08',
      '8 of Wands',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Wands08.jpg',
    ),
    TarotCardDefinition(
      'wands_09',
      '9 of Wands',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Wands09.jpg',
    ),
    TarotCardDefinition(
      'wands_10',
      '10 of Wands',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Wands10.jpg',
    ),
    TarotCardDefinition(
      'wands_11',
      'Page of Wands',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Wands11.jpg',
    ),
    TarotCardDefinition(
      'wands_12',
      'Knight of Wands',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Wands12.jpg',
    ),
    TarotCardDefinition(
      'wands_13',
      'Queen of Wands',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Wands13.jpg',
    ),
    TarotCardDefinition(
      'wands_14',
      'King of Wands',
      'assets/tarot/decks/golden_art_nouveau_tarot/minor/Golden_Art_Nouveau_Tarot_Wands14.jpg',
    ),
  ];

  static const TarotDeckDefinition rwsPublicDomain = TarotDeckDefinition(
    deckId: rwsPublicDomainDeckId,
    displayName: UserText.tarotDeckUniversalWaite,
    shortName: UserText.tarotDeckUniversalWaite,
    prefix: 'RWS',
    family: 'rws',
    cards: rwsCards,
    representativeAssetPath:
        'assets/tarot/decks/rws_public_domain/major/RWS_Tarot_00_Fool.jpg',
    coverAssetPath: 'assets/tarot/decks/rws_public_domain/cover/cover.jpg',
    cardBackAssetPath: 'assets/tarot/decks/rws_public_domain/back/back.png',
    availabilityStatus: 'front_cards_ready',
    notes:
        'Existing RWS app asset baseline with local personal study cover/back assets from C:/Pictures/tarot/rws/originals; preserve current filenames, including the Pents minor-suit filename exception such as RWS_Tarot_Pents01.jpg.',
  );

  static const TarotDeckDefinition universalWaite = TarotDeckDefinition(
    deckId: universalWaiteDeckId,
    displayName: UserText.tarotDeckUniversalWaiteStudy,
    shortName: UserText.tarotDeckUniversalWaiteStudy,
    prefix: 'Universal Waite',
    family: 'rws',
    cards: universalWaiteCards,
    representativeAssetPath:
        'assets/tarot/decks/universal_waite/major/Universal_Waite_Tarot_00_Fool.jpg',
    coverAssetPath:
        'assets/tarot/decks/universal_waite/cover/Universal_Waite_Tarot_Card_Cover.png',
    cardBackAssetPath:
        'assets/tarot/decks/universal_waite/back/Universal_Waite_Tarot_Card_Back.png',
    availabilityStatus: 'front_cards_ready',
    notes:
        'Local personal study tarot_78 asset copied from C:/Pictures/tarot/universal_waite; review rights again before distribution.',
  );

  static const TarotDeckDefinition goldenArtNouveau = TarotDeckDefinition(
    deckId: goldenArtNouveauDeckId,
    displayName: UserText.tarotDeckGoldenArtNouveau,
    shortName: UserText.tarotDeckGoldenArtNouveau,
    prefix: 'Golden Art Nouveau',
    family: 'rws',
    cards: goldenArtNouveauCards,
    representativeAssetPath:
        'assets/tarot/decks/golden_art_nouveau_tarot/major/Golden_Art_Nouveau_Tarot_00_Fool.jpg',
    coverAssetPath:
        'assets/tarot/decks/golden_art_nouveau_tarot/cover/Golden_Art_Nouveau_Tarot_Cover.jpg',
    cardBackAssetPath:
        'assets/tarot/decks/golden_art_nouveau_tarot/back/Golden_Art_Nouveau_Tarot_Back.jpg',
    availabilityStatus: 'front_cards_ready',
    notes:
        'Local personal study tarot_78 asset copied from C:/Pictures/tarot/golden_art_nouveau_tarot; review rights again before distribution.',
  );

  static const TarotDeckDefinition chubbyBunVer2 = TarotDeckDefinition(
    deckId: chubbyBunVer2DeckId,
    displayName: UserText.tarotDeckChubbyBunVer2,
    shortName: UserText.tarotDeckChubbyBunVer2,
    prefix: 'Chubby Bun Ver. 2',
    family: 'rws',
    cards: chubbyBunVer2Cards,
    representativeAssetPath:
        'assets/tarot/decks/chubby_bun_ver_2_tarot/major/Chubby_Bun_Ver_2_Tarot_00_Fool.jpg',
    coverAssetPath:
        'assets/tarot/decks/chubby_bun_ver_2_tarot/cover/Chubby_Bun_Ver_2_Tarot_Cover.jpg',
    cardBackAssetPath:
        'assets/tarot/decks/chubby_bun_ver_2_tarot/back/Chubby_Bun_Ver_2_Tarot_Back.jpg',
    availabilityStatus: 'front_cards_ready',
    notes:
        'Local personal study tarot_78 asset copied from C:/Pictures/tarot/chubby_bun_ver.2_tarot; noncanonical Happy Squirrel card excluded; review rights again before distribution.',
  );

  static const TarotDeckDefinition heavenEarth = TarotDeckDefinition(
    deckId: heavenEarthDeckId,
    displayName: UserText.tarotDeckHeavenEarth,
    shortName: UserText.tarotDeckHeavenEarth,
    prefix: 'Heaven & Earth',
    family: 'rws',
    cards: heavenEarthCards,
    representativeAssetPath:
        'assets/tarot/decks/heaven_earth_tarot/major/Heaven_Earth_Tarot_00_Fool.jpg',
    coverAssetPath:
        'assets/tarot/decks/heaven_earth_tarot/cover/Heaven_Earth_Tarot_Cover.jpg',
    cardBackAssetPath:
        'assets/tarot/decks/heaven_earth_tarot/back/Heaven_Earth_Tarot_Back.jpg',
    availabilityStatus: 'front_cards_ready',
    notes:
        'Local personal study tarot_78 asset copied from C:/Pictures/tarot/heaven&earth_tarot; review rights again before distribution.',
  );

  static const TarotDeckDefinition lightSeers = TarotDeckDefinition(
    deckId: lightSeersDeckId,
    displayName: UserText.tarotDeckLightSeers,
    shortName: UserText.tarotDeckLightSeers,
    prefix: "Light Seer's",
    family: 'rws',
    cards: lightSeersCards,
    representativeAssetPath:
        'assets/tarot/decks/light_seers_tarot/major/Light_Seers_Tarot_00_Fool.jpg',
    coverAssetPath:
        'assets/tarot/decks/light_seers_tarot/cover/Light_Seers_Tarot_Cover.jpg',
    cardBackAssetPath:
        'assets/tarot/decks/light_seers_tarot/back/Light_Seers_Tarot_Back.png',
    availabilityStatus: 'front_cards_ready',
    notes:
        'Local personal study tarot_78 asset copied from C:/Pictures/tarot/light_seers_tarot; review rights again before distribution.',
  );

  static const TarotDeckDefinition samramansang = TarotDeckDefinition(
    deckId: samramansangDeckId,
    displayName: UserText.tarotDeckSamramansang,
    shortName: UserText.tarotDeckSamramansang,
    prefix: 'Samramansang',
    family: 'rws',
    cards: samramansangCards,
    representativeAssetPath:
        'assets/tarot/decks/samramansang_tarot/major/Samramansang_Tarot_00_Fool.jpg',
    coverAssetPath:
        'assets/tarot/decks/samramansang_tarot/cover/Samramansang_Tarot_Cover.jpg',
    cardBackAssetPath:
        'assets/tarot/decks/samramansang_tarot/back/Samramansang_Tarot_Back.jpg',
    availabilityStatus: 'front_cards_ready',
    notes:
        'Local personal study tarot_78 asset copied from C:/Pictures/tarot/samramansang_tarot; guide PDF excluded; review rights again before distribution.',
  );

  static const TarotDeckDefinition tarotOfMysticalMoments = TarotDeckDefinition(
    deckId: tarotOfMysticalMomentsDeckId,
    displayName: UserText.tarotDeckMysticalMoments,
    shortName: UserText.tarotDeckMysticalMoments,
    prefix: 'Tarot of Mystical Moments',
    family: 'rws',
    cards: tarotOfMysticalMomentsCards,
    representativeAssetPath:
        'assets/tarot/decks/tarot_of_mystical_moments/major/Tarot_of_Mystical_Moments_Tarot_00_Fool.jpg',
    coverAssetPath:
        'assets/tarot/decks/tarot_of_mystical_moments/cover/Tarot_of_Mystical_Moments_Tarot_Cover.jpg',
    cardBackAssetPath:
        'assets/tarot/decks/tarot_of_mystical_moments/back/Tarot_of_Mystical_Moments_Tarot_Back.png',
    availabilityStatus: 'front_cards_ready',
    notes:
        'Local personal study tarot_78 asset copied from C:/Pictures/tarot/tarot_of_mystical_moments; review rights again before distribution.',
  );

  static const List<TarotDeckDefinition> decks = [
    rwsPublicDomain,
    TarotDeckDefinition(
      deckId: 'thoth',
      displayName: UserText.tarotDeckThoth,
      shortName: UserText.tarotDeckThoth,
    ),
    TarotDeckDefinition(
      deckId: 'marseille',
      displayName: UserText.tarotDeckMarseille,
      shortName: UserText.tarotDeckMarseille,
    ),
    TarotDeckDefinition(
      deckId: 'manshin_1',
      displayName: UserText.tarotDeckManshin1,
      shortName: UserText.tarotDeckManshin1,
    ),
    TarotDeckDefinition(
      deckId: 'manshin_2',
      displayName: UserText.tarotDeckManshin2,
      shortName: UserText.tarotDeckManshin2,
    ),
    TarotDeckDefinition(
      deckId: 'oracle',
      displayName: UserText.tarotDeckOracle,
      shortName: UserText.tarotDeckOracle,
    ),
    TarotDeckDefinition(
      deckId: 'lenormand',
      displayName: UserText.tarotDeckLenormand,
      shortName: UserText.tarotDeckLenormand,
    ),
    TarotDeckDefinition(
      deckId: 'personal_scan',
      displayName: UserText.tarotDeckPersonalScan,
      shortName: UserText.tarotDeckPersonalScan,
    ),
    universalWaite,
    goldenArtNouveau,
    chubbyBunVer2,
    heavenEarth,
    lightSeers,
    samramansang,
    tarotOfMysticalMoments,
  ];

  static TarotCardDefinition? cardBySemanticId(
    TarotDeckDefinition deck,
    String semanticId,
  ) {
    for (final card in deck.cards) {
      if (card.semanticId == semanticId) return card;
    }
    return null;
  }

  static TarotCardDefinition? rwsCardBySemanticId(String semanticId) =>
      cardBySemanticId(rwsPublicDomain, semanticId);

  static TarotCardDefinition? get legacyRwsPentsAce =>
      rwsCardBySemanticId(TarotCardIds.rwsPents01Legacy);
}
