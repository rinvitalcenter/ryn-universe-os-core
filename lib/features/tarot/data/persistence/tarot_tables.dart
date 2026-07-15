import 'package:drift/drift.dart';

class TarotReadings extends Table {
  TextColumn get readingInstanceId => text().named('reading_instance_id')();
  TextColumn get sourceType => text().named('source_type')();
  TextColumn get questionOriginalSnapshot =>
      text().named('question_original_snapshot')();
  TextColumn get questionDisplayText => text().named('question_display_text')();
  TextColumn get deckId => text().named('deck_id')();
  TextColumn get deckNameSnapshot => text().named('deck_name_snapshot')();
  TextColumn get spreadId => text().named('spread_id')();
  TextColumn get spreadNameSnapshot => text().named('spread_name_snapshot')();
  IntColumn get expectedPlacementCount =>
      integer().named('expected_placement_count')();
  IntColumn get readingAtUtcUs => integer().named('reading_at_utc_us')();
  IntColumn get readingTimezoneOffsetMin =>
      integer().named('reading_timezone_offset_min')();
  IntColumn get createdAtUtcUs => integer().named('created_at_utc_us')();
  IntColumn get updatedAtUtcUs => integer().named('updated_at_utc_us')();
  TextColumn get lifecycleStatus => text().named('lifecycle_status')();
  IntColumn get finishedAtUtcUs =>
      integer().named('finished_at_utc_us').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {readingInstanceId};

  @override
  List<String> get customConstraints => const <String>[
    "CHECK (length(trim(reading_instance_id)) > 0)",
    "CHECK (source_type IN ('self_drawn', 'manually_recorded'))",
    "CHECK (length(trim(question_original_snapshot)) > 0)",
    "CHECK (length(trim(question_display_text)) > 0)",
    "CHECK (length(trim(deck_id)) > 0)",
    "CHECK (length(trim(deck_name_snapshot)) > 0)",
    "CHECK (length(trim(spread_id)) > 0)",
    "CHECK (length(trim(spread_name_snapshot)) > 0)",
    'CHECK (expected_placement_count > 0)',
    'CHECK (reading_timezone_offset_min BETWEEN -840 AND 840)',
    "CHECK (lifecycle_status IN ('continuing', 'finished'))",
    "CHECK ((lifecycle_status = 'continuing' AND finished_at_utc_us IS NULL) OR "
        "(lifecycle_status = 'finished' AND finished_at_utc_us IS NOT NULL))",
  ];
}

class TarotCardPlacements extends Table {
  TextColumn get readingInstanceId => text()
      .named('reading_instance_id')
      .references(
        TarotReadings,
        #readingInstanceId,
        onDelete: KeyAction.restrict,
      )();
  IntColumn get placementOrder => integer().named('placement_order')();
  TextColumn get positionId => text().named('position_id')();
  TextColumn get positionNameSnapshot =>
      text().named('position_name_snapshot')();
  TextColumn get cardId => text().named('card_id')();
  TextColumn get cardNameSnapshot => text().named('card_name_snapshot')();
  TextColumn get orientation => text()();

  @override
  Set<Column<Object>> get primaryKey => {readingInstanceId, placementOrder};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {readingInstanceId, positionId},
  ];

  @override
  List<String> get customConstraints => const <String>[
    'CHECK (placement_order >= 1)',
    "CHECK (length(trim(position_id)) > 0)",
    "CHECK (length(trim(position_name_snapshot)) > 0)",
    "CHECK (length(trim(card_id)) > 0)",
    "CHECK (length(trim(card_name_snapshot)) > 0)",
    "CHECK (orientation IN ('not_used', 'upright', 'reversed'))",
  ];
}

class TarotInterpretations extends Table {
  TextColumn get readingInstanceId => text()
      .named('reading_instance_id')
      .references(
        TarotReadings,
        #readingInstanceId,
        onDelete: KeyAction.restrict,
      )();
  TextColumn get wholeImageObservation =>
      text().named('whole_image_observation').withDefault(const Constant(''))();
  TextColumn get flowInterpretation =>
      text().named('flow_interpretation').withDefault(const Constant(''))();
  TextColumn get coreMessage =>
      text().named('core_message').withDefault(const Constant(''))();
  TextColumn get smallAction =>
      text().named('small_action').withDefault(const Constant(''))();
  IntColumn get createdAtUtcUs => integer().named('created_at_utc_us')();
  IntColumn get updatedAtUtcUs => integer().named('updated_at_utc_us')();

  @override
  Set<Column<Object>> get primaryKey => {readingInstanceId};
}

class AppRuntimeState extends Table {
  TextColumn get stateKey => text().named('state_key')();
  TextColumn get activeHomeTarotReadingId => text()
      .named('active_home_tarot_reading_id')
      .nullable()
      .references(
        TarotReadings,
        #readingInstanceId,
        onDelete: KeyAction.restrict,
      )();
  IntColumn get updatedAtUtcUs => integer().named('updated_at_utc_us')();

  @override
  Set<Column<Object>> get primaryKey => {stateKey};

  @override
  List<String> get customConstraints => const <String>[
    "CHECK (state_key = 'main')",
  ];
}
