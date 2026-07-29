import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/core/persistence/app_database.dart';
import 'package:ryn_universe_os_core/core/runtime/ryn_runtime_services.dart';
import 'package:ryn_universe_os_core/features/qigong_blog/domain/qigong_blog_models.dart';

void main() {
  late RynAppDatabase database;
  late RynRuntimeServices services;

  setUp(() {
    database = RynAppDatabase(NativeDatabase.memory());
    services = RynRuntimeServices(database);
  });

  tearDown(() => database.close());

  test(
    'creates loads updates and archives one transactional blog document',
    () async {
      final media = _media('media.synthetic.a', 'aa' * 32);
      expect(
        (await services.qigongBlog.saveMediaAsset(media)).isSuccess,
        isTrue,
      );

      final original = _document(media.id);
      expect((await services.qigongBlog.savePost(original)).isSuccess, isTrue);
      final loaded = (await services.qigongBlog.loadPost(
        original.post.id,
      )).value!;

      expect(loaded.post.title, '합성 기공 수련기');
      expect(loaded.blocks.map((block) => block.id), [
        'block.heading',
        'block.gallery',
        'block.paragraph',
      ]);
      expect(loaded.blocks[1].galleryColumns, 4);
      expect(loaded.blocks[1].mediaIds, [media.id]);
      expect(loaded.post.coverMediaId, media.id);
      expect(loaded.tags, unorderedEquals(['호흡', '저녁']));
      expect(
        loaded.publications.single.status,
        QigongPublicationStatus.preparing,
      );

      final updated = loaded.copyWith(
        post: loaded.post.copyWith(
          title: '합성 기공 수련기 · 수정',
          status: QigongPostStatus.finalPost,
          updatedAt: _now.add(const Duration(hours: 2)),
        ),
        blocks: [
          loaded.blocks[2],
          loaded.blocks[0],
          loaded.blocks[1],
        ].indexed.map((entry) => entry.$2.copyWith(order: entry.$1)).toList(),
      );
      expect((await services.qigongBlog.savePost(updated)).isSuccess, isTrue);
      final reloaded = (await services.qigongBlog.loadPost(
        original.post.id,
      )).value!;
      expect(reloaded.post.status, QigongPostStatus.finalPost);
      expect(reloaded.blocks.first.id, 'block.paragraph');

      expect(
        (await services.qigongBlog.archivePost(
          original.post.id,
          archivedAt: _now.add(const Duration(days: 1)),
        )).isSuccess,
        isTrue,
      );
      final archived = (await services.qigongBlog.loadPost(
        original.post.id,
      )).value!;
      expect(archived.post.status, QigongPostStatus.archived);
      expect(archived.blocks, hasLength(3));
      expect(archived.blocks[2].mediaIds, [media.id]);
    },
  );

  test('rejects orphan media and rolls back the entire aggregate', () async {
    final invalid = _document('media.missing');
    final result = await services.qigongBlog.savePost(invalid);

    expect(result.isFailure, isTrue);
    expect(await _count(database, 'qigong_posts'), 0);
    expect(await _count(database, 'qigong_post_blocks'), 0);
    expect(await _count(database, 'qigong_post_media'), 0);
  });

  test(
    'preserves gallery columns relations captions tags and publication per platform',
    () async {
      await services.qigongBlog.saveMediaAsset(_media('media.a', 'ab' * 32));
      await services.qigongBlog.saveMediaAsset(_media('media.b', 'bc' * 32));
      final document = _document('media.a').copyWith(
        blocks: [
          const QigongPostBlock(
            id: 'block.gallery',
            type: QigongBlockType.imageGallery,
            order: 0,
            galleryColumns: 2,
            mediaIds: ['media.a', 'media.b'],
          ),
          const QigongPostBlock(
            id: 'block.caption',
            type: QigongBlockType.imageCaption,
            order: 1,
            text: '합성 이미지 두 장의 캡션',
          ),
        ],
        publications: const [
          QigongPublication(
            platform: QigongPublicationPlatform.naverCafeQigongDoga,
            status: QigongPublicationStatus.published,
            externalUrl: 'https://example.invalid/naver-cafe',
          ),
          QigongPublication(
            platform: QigongPublicationPlatform.daumCafeQigongVillage,
            status: QigongPublicationStatus.needsUpdate,
          ),
          QigongPublication(
            platform: QigongPublicationPlatform.naverBlogMyeongrinLab,
            status: QigongPublicationStatus.notPublished,
          ),
        ],
      );

      expect((await services.qigongBlog.savePost(document)).isSuccess, isTrue);
      final loaded = (await services.qigongBlog.loadPost(
        document.post.id,
      )).value!;
      expect(loaded.blocks.first.galleryColumns, 2);
      expect(loaded.blocks.first.mediaIds, ['media.a', 'media.b']);
      expect(loaded.publications, hasLength(3));
      expect(await _count(database, 'qigong_post_tags'), 2);
      expect(
        await _count(database, 'qigong_post_media'),
        3,
      ); // two block links + cover
    },
  );

  test('searches writing media prompts urls and filter dimensions', () async {
    await services.qigongBlog.saveMediaAsset(
      _media('media.search', 'cd' * 32).copyWith(caption: '푸른 호흡 합성 이미지'),
    );
    final document = _document('media.search').copyWith(
      post: _document('media.search').post.copyWith(
        occurredAt: DateTime.utc(2025, 12, 31),
        practiceDayNumber: 108,
        imagePrompt: 'deep blue breathing light',
        keywords: const ['호흡', '장기수련'],
      ),
    );
    await services.qigongBlog.savePost(document);

    final text = await services.qigongBlog.searchPosts(
      const QigongSearchQuery(text: 'deep blue'),
    );
    expect(text, hasLength(1));
    final filtered = await services.qigongBlog.searchPosts(
      const QigongSearchQuery(
        year: 2025,
        practiceDayNumber: 108,
        status: QigongPostStatus.drafting,
        keyword: '호흡',
        hasImages: true,
        publicationPlatform: QigongPublicationPlatform.naverCafeQigongDoga,
        publicationStatus: QigongPublicationStatus.preparing,
      ),
    );
    expect(filtered.single.id, document.post.id);
  });
}

Future<int> _count(RynAppDatabase database, String table) async =>
    (await database
            .customSelect('SELECT count(*) AS total FROM $table')
            .getSingle())
        .read<int>('total');

final _now = DateTime.utc(2026, 8, 4, 20);

QigongMediaAsset _media(String id, String hash) => QigongMediaAsset(
  id: id,
  sha256: hash,
  managedRelativePath: 'qigong_media/${hash.substring(0, 2)}/$hash.png',
  originalFileName: 'synthetic.png',
  mimeType: 'image/png',
  caption: '합성 이미지',
  altText: '실제 인물이 없는 합성 이미지',
  byteSize: 128,
  createdAt: _now,
);

QigongBlogDocument _document(String mediaId) => QigongBlogDocument(
  post: QigongPost(
    id: 'qigong.synthetic.1',
    title: '합성 기공 수련기',
    status: QigongPostStatus.drafting,
    practiceDayNumber: 42,
    occurredAt: _now,
    durationMinutes: 35,
    location: '합성 수련실',
    excerpt: '호흡을 서두르지 않았던 저녁',
    rawMemo: '수련 직후 원문',
    personalDraft: '직접 보완한 초안',
    aiWorkingDraft: '붙여넣은 AI 작업 초안',
    imagePrompt: 'quiet blue breath, editorial photograph',
    promptHistory: const ['first prompt', 'quiet blue breath'],
    keywords: const ['호흡', '저녁'],
    coverMediaId: mediaId,
    createdAt: _now,
    updatedAt: _now,
  ),
  blocks: [
    const QigongPostBlock(
      id: 'block.heading',
      type: QigongBlockType.heading,
      order: 0,
      text: '호흡의 첫 문장',
    ),
    QigongPostBlock(
      id: 'block.gallery',
      type: QigongBlockType.imageGallery,
      order: 1,
      galleryColumns: 4,
      mediaIds: [mediaId],
    ),
    const QigongPostBlock(
      id: 'block.paragraph',
      type: QigongBlockType.paragraph,
      order: 2,
      text: '긴 글을 위한 합성 본문입니다.',
    ),
  ],
  tags: const ['호흡', '저녁'],
  publications: const [
    QigongPublication(
      platform: QigongPublicationPlatform.naverCafeQigongDoga,
      status: QigongPublicationStatus.preparing,
      externalTitle: '외부 합성 제목',
    ),
  ],
);
