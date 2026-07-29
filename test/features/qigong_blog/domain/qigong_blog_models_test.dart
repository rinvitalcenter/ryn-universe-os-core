import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/qigong_blog/domain/qigong_blog_models.dart';

void main() {
  test(
    'document-first model preserves free block order and gallery density',
    () {
      final document = QigongBlogDocument(
        post: QigongPost(
          id: 'qigong.synthetic.1',
          title: '합성 수련기',
          status: QigongPostStatus.drafting,
          rawMemo: '호흡 뒤 짧은 합성 메모',
          createdAt: DateTime.utc(2026, 8, 4),
          updatedAt: DateTime.utc(2026, 8, 4),
        ),
        blocks: const [
          QigongPostBlock(
            id: 'block.heading',
            type: QigongBlockType.heading,
            order: 0,
            text: '고요한 시작',
          ),
          QigongPostBlock(
            id: 'block.gallery',
            type: QigongBlockType.imageGallery,
            order: 1,
            galleryColumns: 4,
            mediaIds: ['media.a', 'media.b'],
          ),
          QigongPostBlock(
            id: 'block.quote',
            type: QigongBlockType.quote,
            order: 2,
            text: '몸의 감각을 서두르지 않는다.',
          ),
        ],
        tags: const ['호흡', '저녁'],
        publications: const [],
      );

      expect(document.blocks.map((block) => block.order), [0, 1, 2]);
      expect(document.blocks[1].galleryColumns, 4);
      expect(document.plainText, contains('고요한 시작'));
      expect(document.plainText, contains('몸의 감각'));
    },
  );

  test('canonical lifecycle and publication storage values stay stable', () {
    expect(QigongPostStatus.quickNote.storageValue, 'quickNote');
    expect(QigongPostStatus.drafting.storageValue, 'drafting');
    expect(QigongPostStatus.finalPost.storageValue, 'final');
    expect(QigongPostStatus.archived.storageValue, 'archived');
    expect(
      QigongPublicationPlatform.naverCafeQigongDoga.storageValue,
      'naverCafeQigongDoga',
    );
    expect(QigongPublicationStatus.needsUpdate.storageValue, 'needsUpdate');
  });
}
