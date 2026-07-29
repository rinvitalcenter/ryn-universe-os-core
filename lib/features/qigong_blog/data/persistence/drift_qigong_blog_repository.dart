import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../../../core/persistence/app_database.dart';
import '../../domain/qigong_blog_models.dart';
import '../../domain/qigong_blog_repository.dart';

final class DriftQigongBlogRepository implements QigongBlogRepository {
  DriftQigongBlogRepository(this._database);

  final RynAppDatabase _database;

  @override
  Future<QigongRepositoryResult<QigongMediaAsset>> saveMediaAsset(
    QigongMediaAsset asset,
  ) async {
    try {
      _validateMediaAsset(asset);
      final existing = await (_database.select(
        _database.qigongMediaAssets,
      )..where((table) => table.sha256.equals(asset.sha256))).getSingleOrNull();
      if (existing != null) {
        return QigongRepositoryResult.success(_mediaFromRow(existing));
      }
      await _database
          .into(_database.qigongMediaAssets)
          .insertOnConflictUpdate(
            QigongMediaAssetsCompanion(
              id: Value(asset.id),
              sha256: Value(asset.sha256),
              managedRelativePath: Value(asset.managedRelativePath),
              originalFileName: Value(asset.originalFileName),
              mimeType: Value(asset.mimeType),
              byteSize: Value(asset.byteSize),
              caption: Value(asset.caption),
              altText: Value(asset.altText),
              width: Value(asset.width),
              height: Value(asset.height),
              createdAtUtcUs: Value(
                asset.createdAt.toUtc().microsecondsSinceEpoch,
              ),
            ),
          );
      return QigongRepositoryResult.success(asset);
    } catch (error) {
      return QigongRepositoryResult.failure(error);
    }
  }

  @override
  Future<QigongRepositoryResult<QigongMediaAsset>> updateMediaMetadata(
    QigongMediaAsset asset,
  ) async {
    try {
      _validateMediaAsset(asset);
      final existing = await (_database.select(
        _database.qigongMediaAssets,
      )..where((table) => table.id.equals(asset.id))).getSingleOrNull();
      if (existing == null ||
          existing.sha256 != asset.sha256 ||
          existing.managedRelativePath != asset.managedRelativePath) {
        throw StateError('media_identity_mismatch');
      }
      await (_database.update(
        _database.qigongMediaAssets,
      )..where((table) => table.id.equals(asset.id))).write(
        QigongMediaAssetsCompanion(
          caption: Value(asset.caption),
          altText: Value(asset.altText),
          width: Value(asset.width),
          height: Value(asset.height),
        ),
      );
      return QigongRepositoryResult.success(asset);
    } catch (error) {
      return QigongRepositoryResult.failure(error);
    }
  }

  @override
  Future<QigongRepositoryResult<QigongBlogDocument>> savePost(
    QigongBlogDocument document,
  ) async {
    try {
      _validateDocument(document);
      await _database.transaction(() async {
        final mediaIds = document.mediaIds.toSet();
        if (mediaIds.isNotEmpty) {
          final rows = await (_database.select(
            _database.qigongMediaAssets,
          )..where((table) => table.id.isIn(mediaIds))).get();
          final existing = rows.map((row) => row.id).toSet();
          if (!existing.containsAll(mediaIds)) {
            throw StateError('관리 media library에 없는 이미지를 글에 연결할 수 없습니다.');
          }
        }

        final post = document.post;
        await _database
            .into(_database.qigongPosts)
            .insertOnConflictUpdate(
              QigongPostsCompanion(
                id: Value(post.id),
                title: Value(post.title.trim()),
                status: Value(post.status.storageValue),
                practiceDayNumber: Value(post.practiceDayNumber),
                occurredAtUtcUs: Value(
                  post.occurredAt?.toUtc().microsecondsSinceEpoch,
                ),
                durationMinutes: Value(post.durationMinutes),
                location: Value(_nullableText(post.location)),
                excerpt: Value(_nullableText(post.excerpt)),
                rawMemo: Value(post.rawMemo),
                personalDraft: Value(post.personalDraft),
                aiWorkingDraft: Value(post.aiWorkingDraft),
                imagePrompt: Value(post.imagePrompt),
                promptHistoryJson: Value(jsonEncode(post.promptHistory)),
                keywordsJson: Value(jsonEncode(post.keywords)),
                coverMediaId: Value(post.coverMediaId),
                createdAtUtcUs: Value(
                  post.createdAt.toUtc().microsecondsSinceEpoch,
                ),
                updatedAtUtcUs: Value(
                  post.updatedAt.toUtc().microsecondsSinceEpoch,
                ),
                archivedAtUtcUs: Value(
                  post.archivedAt?.toUtc().microsecondsSinceEpoch,
                ),
              ),
            );

        await (_database.delete(
          _database.qigongPostMedia,
        )..where((table) => table.postId.equals(post.id))).go();
        await (_database.delete(
          _database.qigongPostTags,
        )..where((table) => table.postId.equals(post.id))).go();
        await (_database.delete(
          _database.qigongPublications,
        )..where((table) => table.postId.equals(post.id))).go();
        await (_database.delete(
          _database.qigongPostBlocks,
        )..where((table) => table.postId.equals(post.id))).go();

        for (final indexed in document.blocks.indexed) {
          final block = indexed.$2;
          await _database
              .into(_database.qigongPostBlocks)
              .insert(
                QigongPostBlocksCompanion.insert(
                  id: block.id,
                  postId: post.id,
                  blockOrder: indexed.$1,
                  type: block.type.storageValue,
                  textContent: Value(block.text),
                  galleryColumns: Value(block.galleryColumns),
                ),
              );
          for (final media in block.mediaIds.indexed) {
            await _database
                .into(_database.qigongPostMedia)
                .insert(
                  QigongPostMediaCompanion.insert(
                    id: '${post.id}:${block.id}:${media.$1}:${media.$2}',
                    postId: post.id,
                    blockId: Value(block.id),
                    mediaId: media.$2,
                    mediaOrder: media.$1,
                  ),
                );
          }
        }

        if (post.coverMediaId case final coverId?) {
          await _database
              .into(_database.qigongPostMedia)
              .insert(
                QigongPostMediaCompanion.insert(
                  id: '${post.id}:cover:$coverId',
                  postId: post.id,
                  mediaId: coverId,
                  mediaOrder: -1,
                  isCover: const Value(true),
                ),
              );
        }

        for (final tagName in _normalizedTags(document.tags)) {
          final normalized = tagName.toLowerCase();
          final tagId = 'qigong-tag:$normalized';
          await _database
              .into(_database.qigongTags)
              .insertOnConflictUpdate(
                QigongTagsCompanion.insert(
                  id: tagId,
                  name: tagName,
                  normalizedName: normalized,
                ),
              );
          await _database
              .into(_database.qigongPostTags)
              .insert(
                QigongPostTagsCompanion.insert(postId: post.id, tagId: tagId),
              );
        }

        for (final publication in document.publications) {
          await _database
              .into(_database.qigongPublications)
              .insert(
                QigongPublicationsCompanion.insert(
                  postId: post.id,
                  platform: publication.platform.storageValue,
                  status: publication.status.storageValue,
                  externalTitle: Value(
                    _nullableText(publication.externalTitle),
                  ),
                  externalUrl: Value(_nullableText(publication.externalUrl)),
                  publishedAtUtcUs: Value(
                    publication.publishedAt?.toUtc().microsecondsSinceEpoch,
                  ),
                  platformNote: Value(_nullableText(publication.note)),
                ),
              );
        }
      });
      return QigongRepositoryResult.success(document);
    } catch (error) {
      return QigongRepositoryResult.failure(error);
    }
  }

  @override
  Future<QigongRepositoryResult<QigongBlogDocument>> loadPost(
    String postId,
  ) async {
    try {
      final postRow = await (_database.select(
        _database.qigongPosts,
      )..where((table) => table.id.equals(postId))).getSingleOrNull();
      if (postRow == null) {
        return QigongRepositoryResult.failure(StateError('수련기를 찾을 수 없습니다.'));
      }
      return QigongRepositoryResult.success(await _loadDocument(postRow));
    } catch (error) {
      return QigongRepositoryResult.failure(error);
    }
  }

  @override
  Future<QigongRepositoryResult<void>> archivePost(
    String postId, {
    required DateTime archivedAt,
  }) async {
    try {
      final changed =
          await (_database.update(
            _database.qigongPosts,
          )..where((table) => table.id.equals(postId))).write(
            QigongPostsCompanion(
              status: const Value('archived'),
              archivedAtUtcUs: Value(archivedAt.toUtc().microsecondsSinceEpoch),
              updatedAtUtcUs: Value(archivedAt.toUtc().microsecondsSinceEpoch),
            ),
          );
      if (changed != 1) throw StateError('보관할 수련기를 찾을 수 없습니다.');
      return const QigongRepositoryResult<void>.success();
    } catch (error) {
      return QigongRepositoryResult.failure(error);
    }
  }

  @override
  Stream<List<QigongPostSummary>> watchPosts() =>
      (_database.select(_database.qigongPosts)
            ..orderBy([(table) => OrderingTerm.desc(table.updatedAtUtcUs)]))
          .watch()
          .asyncMap((rows) async {
            final documents = await Future.wait(rows.map(_loadDocument));
            return documents.map(_summary).toList(growable: false);
          });

  @override
  Stream<List<QigongMediaAsset>> watchMediaAssets() =>
      (_database.select(_database.qigongMediaAssets)
            ..orderBy([(table) => OrderingTerm.desc(table.createdAtUtcUs)]))
          .watch()
          .map((rows) => rows.map(_mediaFromRow).toList(growable: false));

  @override
  Future<Map<String, List<String>>> loadMediaUsage() async {
    final rows = await _database.select(_database.qigongPostMedia).get();
    final usage = <String, Set<String>>{};
    for (final row in rows) {
      usage.putIfAbsent(row.mediaId, () => <String>{}).add(row.postId);
    }
    return <String, List<String>>{
      for (final entry in usage.entries)
        entry.key: (entry.value.toList()..sort()),
    };
  }

  @override
  Future<List<QigongPostSummary>> searchPosts(QigongSearchQuery query) async {
    final rows = await (_database.select(
      _database.qigongPosts,
    )..orderBy([(table) => OrderingTerm.desc(table.updatedAtUtcUs)])).get();
    final documents = await Future.wait(rows.map(_loadDocument));
    final mediaRows = await _database.select(_database.qigongMediaAssets).get();
    final mediaById = {for (final media in mediaRows) media.id: media};
    return documents
        .where((document) {
          final post = document.post;
          if (query.status != null && post.status != query.status) return false;
          if (query.practiceDayNumber != null &&
              post.practiceDayNumber != query.practiceDayNumber) {
            return false;
          }
          final occurred = post.occurredAt;
          if (query.year != null && occurred?.year != query.year) return false;
          if (query.from != null &&
              (occurred == null || occurred.isBefore(query.from!))) {
            return false;
          }
          if (query.to != null &&
              (occurred == null || occurred.isAfter(query.to!))) {
            return false;
          }
          if (query.keyword case final keyword?) {
            final normalized = keyword.trim().toLowerCase();
            if (normalized.isNotEmpty &&
                !<String>{
                  ...document.tags,
                  ...post.keywords,
                }.map((value) => value.toLowerCase()).contains(normalized)) {
              return false;
            }
          }
          if (query.hasImages != null &&
              document.mediaIds.isNotEmpty != query.hasImages) {
            return false;
          }
          if (query.publicationPlatform != null ||
              query.publicationStatus != null) {
            final matches = document.publications.any(
              (publication) =>
                  (query.publicationPlatform == null ||
                      publication.platform == query.publicationPlatform) &&
                  (query.publicationStatus == null ||
                      publication.status == query.publicationStatus),
            );
            if (!matches) return false;
          }
          final term = query.text?.trim().toLowerCase() ?? '';
          if (term.isEmpty) return true;
          final mediaText = document.mediaIds
              .map((id) => mediaById[id])
              .whereType<QigongMediaAssetRow>()
              .expand(
                (row) => [row.caption, row.altText, row.originalFileName],
              );
          final publicationText = document.publications.expand(
            (entry) => [
              entry.externalTitle ?? '',
              entry.externalUrl ?? '',
              entry.note ?? '',
            ],
          );
          final corpus = <String>[
            post.title,
            post.excerpt ?? '',
            post.rawMemo,
            post.personalDraft,
            post.aiWorkingDraft,
            post.imagePrompt,
            ...post.promptHistory,
            ...post.keywords,
            document.plainText,
            ...document.tags,
            ...mediaText,
            ...publicationText,
          ].join('\n').toLowerCase();
          return corpus.contains(term);
        })
        .map(_summary)
        .toList(growable: false);
  }

  Future<QigongBlogDocument> _loadDocument(QigongPostRow postRow) async {
    final blockRows =
        await (_database.select(_database.qigongPostBlocks)
              ..where((table) => table.postId.equals(postRow.id))
              ..orderBy([(table) => OrderingTerm.asc(table.blockOrder)]))
            .get();
    final mediaRows =
        await (_database.select(_database.qigongPostMedia)
              ..where((table) => table.postId.equals(postRow.id))
              ..orderBy([(table) => OrderingTerm.asc(table.mediaOrder)]))
            .get();
    final blockMedia = <String, List<String>>{};
    for (final relation in mediaRows) {
      if (relation.blockId case final blockId?) {
        blockMedia.putIfAbsent(blockId, () => []).add(relation.mediaId);
      }
    }
    final tagLinks = await (_database.select(
      _database.qigongPostTags,
    )..where((table) => table.postId.equals(postRow.id))).get();
    final tags = <String>[];
    for (final link in tagLinks) {
      final tag = await (_database.select(
        _database.qigongTags,
      )..where((table) => table.id.equals(link.tagId))).getSingle();
      tags.add(tag.name);
    }
    tags.sort();
    final publicationRows = await (_database.select(
      _database.qigongPublications,
    )..where((table) => table.postId.equals(postRow.id))).get();
    return QigongBlogDocument(
      post: QigongPost(
        id: postRow.id,
        title: postRow.title,
        status: qigongPostStatusFromStorage(postRow.status),
        practiceDayNumber: postRow.practiceDayNumber,
        occurredAt: _date(postRow.occurredAtUtcUs),
        durationMinutes: postRow.durationMinutes,
        location: postRow.location,
        excerpt: postRow.excerpt,
        rawMemo: postRow.rawMemo,
        personalDraft: postRow.personalDraft,
        aiWorkingDraft: postRow.aiWorkingDraft,
        imagePrompt: postRow.imagePrompt,
        promptHistory: _decodeStringList(postRow.promptHistoryJson),
        keywords: _decodeStringList(postRow.keywordsJson),
        coverMediaId: postRow.coverMediaId,
        createdAt: _date(postRow.createdAtUtcUs)!,
        updatedAt: _date(postRow.updatedAtUtcUs)!,
        archivedAt: _date(postRow.archivedAtUtcUs),
      ),
      blocks: blockRows
          .map(
            (row) => QigongPostBlock(
              id: row.id,
              type: qigongBlockTypeFromStorage(row.type),
              order: row.blockOrder,
              text: row.textContent,
              galleryColumns: row.galleryColumns,
              mediaIds: blockMedia[row.id] ?? const [],
            ),
          )
          .toList(growable: false),
      tags: tags,
      publications: publicationRows
          .map(
            (row) => QigongPublication(
              platform: qigongPublicationPlatformFromStorage(row.platform),
              status: qigongPublicationStatusFromStorage(row.status),
              externalTitle: row.externalTitle,
              externalUrl: row.externalUrl,
              publishedAt: _date(row.publishedAtUtcUs),
              note: row.platformNote,
            ),
          )
          .toList(growable: false),
    );
  }

  QigongPostSummary _summary(QigongBlogDocument document) => QigongPostSummary(
    id: document.post.id,
    title: document.post.title,
    status: document.post.status,
    excerpt: document.post.excerpt,
    occurredAt: document.post.occurredAt,
    practiceDayNumber: document.post.practiceDayNumber,
    coverMediaId: document.post.coverMediaId,
    updatedAt: document.post.updatedAt,
    imageCount: document.mediaIds.toSet().length,
    tags: document.tags,
    publications: document.publications,
  );

  QigongMediaAsset _mediaFromRow(QigongMediaAssetRow row) => QigongMediaAsset(
    id: row.id,
    sha256: row.sha256,
    managedRelativePath: row.managedRelativePath,
    originalFileName: row.originalFileName,
    mimeType: row.mimeType,
    byteSize: row.byteSize,
    caption: row.caption,
    altText: row.altText,
    width: row.width,
    height: row.height,
    createdAt: _date(row.createdAtUtcUs)!,
  );

  void _validateDocument(QigongBlogDocument document) {
    if (document.post.id.trim().isEmpty || document.post.title.trim().isEmpty) {
      throw ArgumentError('수련기 제목이 필요합니다.');
    }
    if (document.blocks.isEmpty ||
        !document.blocks.any(
          (block) => block.text.trim().isNotEmpty || block.mediaIds.isNotEmpty,
        )) {
      throw ArgumentError('수련기 본문이 필요합니다.');
    }
    final blockIds = document.blocks.map((block) => block.id).toList();
    if (blockIds.toSet().length != blockIds.length) {
      throw ArgumentError('본문 block ID가 중복되었습니다.');
    }
    for (final block in document.blocks) {
      if (block.galleryColumns < 1 || block.galleryColumns > 4) {
        throw ArgumentError('Gallery column은 1~4만 사용할 수 있습니다.');
      }
      if (block.mediaIds.toSet().length != block.mediaIds.length) {
        throw ArgumentError('한 block에 같은 이미지를 중복 배치할 수 없습니다.');
      }
    }
    final platforms = document.publications
        .map((entry) => entry.platform)
        .toList();
    if (platforms.toSet().length != platforms.length) {
      throw ArgumentError('플랫폼별 발행 상태는 하나만 저장할 수 있습니다.');
    }
  }

  void _validateMediaAsset(QigongMediaAsset asset) {
    if (asset.id.trim().isEmpty ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(asset.sha256)) {
      throw ArgumentError('유효한 media ID와 SHA-256이 필요합니다.');
    }
    final relative = asset.managedRelativePath;
    if (p.posix.isAbsolute(relative) ||
        !p.posix.isWithin('qigong_media', relative)) {
      throw ArgumentError('DB에는 qigong_media 아래 상대 경로만 저장할 수 있습니다.');
    }
  }
}

DateTime? _date(int? microseconds) => microseconds == null
    ? null
    : DateTime.fromMicrosecondsSinceEpoch(microseconds, isUtc: true);

String? _nullableText(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

List<String> _decodeStringList(String source) =>
    (jsonDecode(source) as List<dynamic>).cast<String>();

List<String> _normalizedTags(List<String> tags) {
  final byNormalized = <String, String>{};
  for (final raw in tags) {
    final clean = raw.trim();
    if (clean.isNotEmpty) byNormalized[clean.toLowerCase()] = clean;
  }
  final result = byNormalized.values.toList(growable: false)..sort();
  return result;
}
