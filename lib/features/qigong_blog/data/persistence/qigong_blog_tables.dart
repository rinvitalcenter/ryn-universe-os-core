import 'package:drift/drift.dart';

@DataClassName('QigongMediaAssetRow')
class QigongMediaAssets extends Table {
  TextColumn get id => text()();
  TextColumn get sha256 => text().withLength(min: 64, max: 64).unique()();
  TextColumn get managedRelativePath => text().unique()();
  TextColumn get originalFileName => text()();
  TextColumn get mimeType => text()();
  IntColumn get byteSize =>
      integer().customConstraint('NOT NULL CHECK (byte_size >= 0)')();
  TextColumn get caption => text().withDefault(const Constant(''))();
  TextColumn get altText => text().withDefault(const Constant(''))();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get createdAtUtcUs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('QigongPostRow')
class QigongPosts extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get status => text().customConstraint(
    "NOT NULL CHECK (status IN ('quickNote','drafting','final','archived'))",
  )();
  IntColumn get practiceDayNumber => integer().nullable()();
  IntColumn get occurredAtUtcUs => integer().nullable()();
  IntColumn get durationMinutes => integer().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get excerpt => text().nullable()();
  TextColumn get rawMemo => text().withDefault(const Constant(''))();
  TextColumn get personalDraft => text().withDefault(const Constant(''))();
  TextColumn get aiWorkingDraft => text().withDefault(const Constant(''))();
  TextColumn get imagePrompt => text().withDefault(const Constant(''))();
  TextColumn get promptHistoryJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get keywordsJson => text().withDefault(const Constant('[]'))();
  TextColumn get coverMediaId => text().nullable().references(
    QigongMediaAssets,
    #id,
    onDelete: KeyAction.restrict,
  )();
  IntColumn get createdAtUtcUs => integer()();
  IntColumn get updatedAtUtcUs => integer()();
  IntColumn get archivedAtUtcUs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('QigongPostBlockRow')
class QigongPostBlocks extends Table {
  TextColumn get id => text()();
  TextColumn get postId =>
      text().references(QigongPosts, #id, onDelete: KeyAction.cascade)();
  IntColumn get blockOrder =>
      integer().customConstraint('NOT NULL CHECK (block_order >= 0)')();
  TextColumn get type => text().customConstraint(
    "NOT NULL CHECK (type IN ('paragraph','heading','subheading','quote',"
    "'divider','spacer','singleImage','imageGallery','imageCaption'))",
  )();
  TextColumn get textContent => text().withDefault(const Constant(''))();
  IntColumn get galleryColumns => integer().customConstraint(
    'NOT NULL DEFAULT 1 CHECK (gallery_columns BETWEEN 1 AND 4)',
  )();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {postId, blockOrder},
  ];
}

@DataClassName('QigongPostMediaRow')
class QigongPostMedia extends Table {
  TextColumn get id => text()();
  TextColumn get postId =>
      text().references(QigongPosts, #id, onDelete: KeyAction.cascade)();
  TextColumn get blockId => text().nullable().references(
    QigongPostBlocks,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get mediaId =>
      text().references(QigongMediaAssets, #id, onDelete: KeyAction.restrict)();
  IntColumn get mediaOrder => integer()();
  BoolColumn get isCover => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('QigongTagRow')
class QigongTags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text().unique()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('QigongPostTagRow')
class QigongPostTags extends Table {
  TextColumn get postId =>
      text().references(QigongPosts, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(QigongTags, #id, onDelete: KeyAction.restrict)();

  @override
  Set<Column<Object>> get primaryKey => {postId, tagId};
}

@DataClassName('QigongPublicationRow')
class QigongPublications extends Table {
  TextColumn get postId =>
      text().references(QigongPosts, #id, onDelete: KeyAction.cascade)();
  TextColumn get platform => text().customConstraint(
    "NOT NULL CHECK (platform IN ('naverCafeQigongDoga',"
    "'daumCafeQigongVillage','naverBlogMyeongrinLab'))",
  )();
  TextColumn get status => text().customConstraint(
    "NOT NULL CHECK (status IN ('notPublished','preparing','published',"
    "'needsUpdate'))",
  )();
  TextColumn get externalTitle => text().nullable()();
  TextColumn get externalUrl => text().nullable()();
  IntColumn get publishedAtUtcUs => integer().nullable()();
  TextColumn get platformNote => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {postId, platform};
}
