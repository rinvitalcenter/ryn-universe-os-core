enum QigongPostStatus { quickNote, drafting, finalPost, archived }

enum QigongBlockType {
  paragraph,
  heading,
  subheading,
  quote,
  divider,
  spacer,
  singleImage,
  imageGallery,
  imageCaption,
}

enum QigongPublicationPlatform {
  naverCafeQigongDoga,
  daumCafeQigongVillage,
  naverBlogMyeongrinLab,
}

enum QigongPublicationStatus { notPublished, preparing, published, needsUpdate }

extension QigongPostStatusStorage on QigongPostStatus {
  String get storageValue => switch (this) {
    QigongPostStatus.quickNote => 'quickNote',
    QigongPostStatus.drafting => 'drafting',
    QigongPostStatus.finalPost => 'final',
    QigongPostStatus.archived => 'archived',
  };

  String get userLabel => switch (this) {
    QigongPostStatus.quickNote => '빠른 메모',
    QigongPostStatus.drafting => '작성 중',
    QigongPostStatus.finalPost => '최종본',
    QigongPostStatus.archived => '보관',
  };
}

extension QigongBlockTypeStorage on QigongBlockType {
  String get storageValue => switch (this) {
    QigongBlockType.paragraph => 'paragraph',
    QigongBlockType.heading => 'heading',
    QigongBlockType.subheading => 'subheading',
    QigongBlockType.quote => 'quote',
    QigongBlockType.divider => 'divider',
    QigongBlockType.spacer => 'spacer',
    QigongBlockType.singleImage => 'singleImage',
    QigongBlockType.imageGallery => 'imageGallery',
    QigongBlockType.imageCaption => 'imageCaption',
  };
}

extension QigongPublicationPlatformStorage on QigongPublicationPlatform {
  String get storageValue => name;

  String get userLabel => switch (this) {
    QigongPublicationPlatform.naverCafeQigongDoga => '네이버 카페 · 기공도가',
    QigongPublicationPlatform.daumCafeQigongVillage => '다음 카페 · 기공마을',
    QigongPublicationPlatform.naverBlogMyeongrinLab => '네이버 블로그 · 명린연구소',
  };
}

extension QigongPublicationStatusStorage on QigongPublicationStatus {
  String get storageValue => name;

  String get userLabel => switch (this) {
    QigongPublicationStatus.notPublished => '미발행',
    QigongPublicationStatus.preparing => '준비 중',
    QigongPublicationStatus.published => '발행 완료',
    QigongPublicationStatus.needsUpdate => '업데이트 필요',
  };
}

QigongPostStatus qigongPostStatusFromStorage(String value) => switch (value) {
  'quickNote' => QigongPostStatus.quickNote,
  'drafting' => QigongPostStatus.drafting,
  'final' => QigongPostStatus.finalPost,
  'archived' => QigongPostStatus.archived,
  _ => throw FormatException('Unsupported Qigong post status: $value'),
};

QigongBlockType qigongBlockTypeFromStorage(String value) =>
    QigongBlockType.values.firstWhere(
      (candidate) => candidate.storageValue == value,
      orElse: () =>
          throw FormatException('Unsupported Qigong block type: $value'),
    );

QigongPublicationPlatform qigongPublicationPlatformFromStorage(String value) =>
    QigongPublicationPlatform.values.firstWhere(
      (candidate) => candidate.storageValue == value,
      orElse: () =>
          throw FormatException('Unsupported publication platform: $value'),
    );

QigongPublicationStatus qigongPublicationStatusFromStorage(String value) =>
    QigongPublicationStatus.values.firstWhere(
      (candidate) => candidate.storageValue == value,
      orElse: () =>
          throw FormatException('Unsupported publication status: $value'),
    );

const _unset = Object();

final class QigongPost {
  const QigongPost({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.practiceDayNumber,
    this.occurredAt,
    this.durationMinutes,
    this.location,
    this.excerpt,
    this.rawMemo = '',
    this.personalDraft = '',
    this.aiWorkingDraft = '',
    this.imagePrompt = '',
    this.promptHistory = const [],
    this.keywords = const [],
    this.coverMediaId,
    this.archivedAt,
  });

  final String id;
  final String title;
  final QigongPostStatus status;
  final int? practiceDayNumber;
  final DateTime? occurredAt;
  final int? durationMinutes;
  final String? location;
  final String? excerpt;
  final String rawMemo;
  final String personalDraft;
  final String aiWorkingDraft;
  final String imagePrompt;
  final List<String> promptHistory;
  final List<String> keywords;
  final String? coverMediaId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  QigongPost copyWith({
    String? id,
    String? title,
    QigongPostStatus? status,
    Object? practiceDayNumber = _unset,
    Object? occurredAt = _unset,
    Object? durationMinutes = _unset,
    Object? location = _unset,
    Object? excerpt = _unset,
    String? rawMemo,
    String? personalDraft,
    String? aiWorkingDraft,
    String? imagePrompt,
    List<String>? promptHistory,
    List<String>? keywords,
    Object? coverMediaId = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? archivedAt = _unset,
  }) => QigongPost(
    id: id ?? this.id,
    title: title ?? this.title,
    status: status ?? this.status,
    practiceDayNumber: identical(practiceDayNumber, _unset)
        ? this.practiceDayNumber
        : practiceDayNumber as int?,
    occurredAt: identical(occurredAt, _unset)
        ? this.occurredAt
        : occurredAt as DateTime?,
    durationMinutes: identical(durationMinutes, _unset)
        ? this.durationMinutes
        : durationMinutes as int?,
    location: identical(location, _unset) ? this.location : location as String?,
    excerpt: identical(excerpt, _unset) ? this.excerpt : excerpt as String?,
    rawMemo: rawMemo ?? this.rawMemo,
    personalDraft: personalDraft ?? this.personalDraft,
    aiWorkingDraft: aiWorkingDraft ?? this.aiWorkingDraft,
    imagePrompt: imagePrompt ?? this.imagePrompt,
    promptHistory: promptHistory ?? this.promptHistory,
    keywords: keywords ?? this.keywords,
    coverMediaId: identical(coverMediaId, _unset)
        ? this.coverMediaId
        : coverMediaId as String?,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: identical(archivedAt, _unset)
        ? this.archivedAt
        : archivedAt as DateTime?,
  );
}

final class QigongPostBlock {
  const QigongPostBlock({
    required this.id,
    required this.type,
    required this.order,
    this.text = '',
    this.galleryColumns = 1,
    this.mediaIds = const [],
  });

  final String id;
  final QigongBlockType type;
  final int order;
  final String text;
  final int galleryColumns;
  final List<String> mediaIds;

  QigongPostBlock copyWith({
    String? id,
    QigongBlockType? type,
    int? order,
    String? text,
    int? galleryColumns,
    List<String>? mediaIds,
  }) => QigongPostBlock(
    id: id ?? this.id,
    type: type ?? this.type,
    order: order ?? this.order,
    text: text ?? this.text,
    galleryColumns: galleryColumns ?? this.galleryColumns,
    mediaIds: mediaIds ?? this.mediaIds,
  );
}

final class QigongMediaAsset {
  const QigongMediaAsset({
    required this.id,
    required this.sha256,
    required this.managedRelativePath,
    required this.originalFileName,
    required this.mimeType,
    required this.byteSize,
    required this.createdAt,
    this.caption = '',
    this.altText = '',
    this.width,
    this.height,
  });

  final String id;
  final String sha256;
  final String managedRelativePath;
  final String originalFileName;
  final String mimeType;
  final int byteSize;
  final String caption;
  final String altText;
  final int? width;
  final int? height;
  final DateTime createdAt;

  QigongMediaAsset copyWith({
    String? id,
    String? sha256,
    String? managedRelativePath,
    String? originalFileName,
    String? mimeType,
    int? byteSize,
    String? caption,
    String? altText,
    Object? width = _unset,
    Object? height = _unset,
    DateTime? createdAt,
  }) => QigongMediaAsset(
    id: id ?? this.id,
    sha256: sha256 ?? this.sha256,
    managedRelativePath: managedRelativePath ?? this.managedRelativePath,
    originalFileName: originalFileName ?? this.originalFileName,
    mimeType: mimeType ?? this.mimeType,
    byteSize: byteSize ?? this.byteSize,
    caption: caption ?? this.caption,
    altText: altText ?? this.altText,
    width: identical(width, _unset) ? this.width : width as int?,
    height: identical(height, _unset) ? this.height : height as int?,
    createdAt: createdAt ?? this.createdAt,
  );
}

final class QigongPublication {
  const QigongPublication({
    required this.platform,
    required this.status,
    this.externalTitle,
    this.externalUrl,
    this.publishedAt,
    this.note,
  });

  final QigongPublicationPlatform platform;
  final QigongPublicationStatus status;
  final String? externalTitle;
  final String? externalUrl;
  final DateTime? publishedAt;
  final String? note;

  QigongPublication copyWith({
    QigongPublicationPlatform? platform,
    QigongPublicationStatus? status,
    Object? externalTitle = _unset,
    Object? externalUrl = _unset,
    Object? publishedAt = _unset,
    Object? note = _unset,
  }) => QigongPublication(
    platform: platform ?? this.platform,
    status: status ?? this.status,
    externalTitle: identical(externalTitle, _unset)
        ? this.externalTitle
        : externalTitle as String?,
    externalUrl: identical(externalUrl, _unset)
        ? this.externalUrl
        : externalUrl as String?,
    publishedAt: identical(publishedAt, _unset)
        ? this.publishedAt
        : publishedAt as DateTime?,
    note: identical(note, _unset) ? this.note : note as String?,
  );
}

final class QigongBlogDocument {
  const QigongBlogDocument({
    required this.post,
    required this.blocks,
    required this.tags,
    required this.publications,
  });

  final QigongPost post;
  final List<QigongPostBlock> blocks;
  final List<String> tags;
  final List<QigongPublication> publications;

  String get plainText => blocks
      .where((block) => block.text.trim().isNotEmpty)
      .map((block) => block.text.trim())
      .join('\n\n');

  List<String> get mediaIds => <String>{
    ?post.coverMediaId,
    for (final block in blocks) ...block.mediaIds,
  }.toList(growable: false);

  QigongBlogDocument copyWith({
    QigongPost? post,
    List<QigongPostBlock>? blocks,
    List<String>? tags,
    List<QigongPublication>? publications,
  }) => QigongBlogDocument(
    post: post ?? this.post,
    blocks: blocks ?? this.blocks,
    tags: tags ?? this.tags,
    publications: publications ?? this.publications,
  );
}

final class QigongPostSummary {
  const QigongPostSummary({
    required this.id,
    required this.title,
    required this.status,
    required this.updatedAt,
    required this.imageCount,
    required this.tags,
    required this.publications,
    this.excerpt,
    this.occurredAt,
    this.practiceDayNumber,
    this.coverMediaId,
  });

  final String id;
  final String title;
  final QigongPostStatus status;
  final String? excerpt;
  final DateTime? occurredAt;
  final int? practiceDayNumber;
  final String? coverMediaId;
  final DateTime updatedAt;
  final int imageCount;
  final List<String> tags;
  final List<QigongPublication> publications;
}

final class QigongSearchQuery {
  const QigongSearchQuery({
    this.text,
    this.year,
    this.from,
    this.to,
    this.practiceDayNumber,
    this.status,
    this.keyword,
    this.hasImages,
    this.publicationPlatform,
    this.publicationStatus,
  });

  final String? text;
  final int? year;
  final DateTime? from;
  final DateTime? to;
  final int? practiceDayNumber;
  final QigongPostStatus? status;
  final String? keyword;
  final bool? hasImages;
  final QigongPublicationPlatform? publicationPlatform;
  final QigongPublicationStatus? publicationStatus;

  QigongSearchQuery copyWith({
    Object? text = _unset,
    Object? year = _unset,
    Object? from = _unset,
    Object? to = _unset,
    Object? practiceDayNumber = _unset,
    Object? status = _unset,
    Object? keyword = _unset,
    Object? hasImages = _unset,
    Object? publicationPlatform = _unset,
    Object? publicationStatus = _unset,
  }) => QigongSearchQuery(
    text: identical(text, _unset) ? this.text : text as String?,
    year: identical(year, _unset) ? this.year : year as int?,
    from: identical(from, _unset) ? this.from : from as DateTime?,
    to: identical(to, _unset) ? this.to : to as DateTime?,
    practiceDayNumber: identical(practiceDayNumber, _unset)
        ? this.practiceDayNumber
        : practiceDayNumber as int?,
    status: identical(status, _unset)
        ? this.status
        : status as QigongPostStatus?,
    keyword: identical(keyword, _unset) ? this.keyword : keyword as String?,
    hasImages: identical(hasImages, _unset)
        ? this.hasImages
        : hasImages as bool?,
    publicationPlatform: identical(publicationPlatform, _unset)
        ? this.publicationPlatform
        : publicationPlatform as QigongPublicationPlatform?,
    publicationStatus: identical(publicationStatus, _unset)
        ? this.publicationStatus
        : publicationStatus as QigongPublicationStatus?,
  );
}
