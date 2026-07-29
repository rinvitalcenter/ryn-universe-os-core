import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/ryn_tokens.dart';
import '../domain/qigong_blog_models.dart';
import '../infrastructure/qigong_managed_media_store.dart';

final class QigongReadingView extends StatelessWidget {
  const QigongReadingView({
    super.key,
    required this.document,
    required this.mediaAssets,
    required this.mediaStore,
    required this.onEdit,
    this.onPrevious,
    this.onNext,
  });

  final QigongBlogDocument document;
  final List<QigongMediaAsset> mediaAssets;
  final QigongManagedMediaStore? mediaStore;
  final VoidCallback onEdit;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return ColoredBox(
      color: colors.primarySurface,
      child: CustomScrollView(
        key: const Key('qigong-reading-view'),
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(44, 58, 44, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _StatusPill(document.post.status.userLabel),
                          const Spacer(),
                          OutlinedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('편집'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        document.post.title,
                        style: TextStyle(
                          color: colors.primaryText,
                          fontSize: 44,
                          height: 1.12,
                          letterSpacing: -1.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _meta(document.post),
                        style: TextStyle(
                          color: colors.mutedText,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 46),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: document.blocks.length,
            itemBuilder: (context, index) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 44),
                  child: _ReadingBlock(
                    block: document.blocks[index],
                    assets: mediaAssets,
                    store: mediaStore,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(44, 72, 44, 90),
                  child: Column(
                    children: [
                      Divider(color: colors.hairline),
                      const SizedBox(height: 24),
                      _PublicationSummary(publications: document.publications),
                      const SizedBox(height: 34),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: onPrevious,
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('이전 수련기'),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: onNext,
                            iconAlignment: IconAlignment.end,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('다음 수련기'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _ReadingBlock extends StatelessWidget {
  const _ReadingBlock({
    required this.block,
    required this.assets,
    required this.store,
  });
  final QigongPostBlock block;
  final List<QigongMediaAsset> assets;
  final QigongManagedMediaStore? store;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final margin = switch (block.type) {
      QigongBlockType.heading => const EdgeInsets.only(top: 38, bottom: 16),
      QigongBlockType.subheading => const EdgeInsets.only(top: 28, bottom: 12),
      QigongBlockType.singleImage ||
      QigongBlockType.imageGallery => const EdgeInsets.symmetric(vertical: 30),
      _ => const EdgeInsets.only(bottom: 20),
    };
    return Padding(
      padding: margin,
      child: switch (block.type) {
        QigongBlockType.heading => Text(
          block.text,
          style: TextStyle(
            color: colors.primaryText,
            fontSize: 30,
            height: 1.25,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
        QigongBlockType.subheading => Text(
          block.text,
          style: TextStyle(
            color: colors.primaryText,
            fontSize: 23,
            height: 1.4,
            fontWeight: FontWeight.w800,
          ),
        ),
        QigongBlockType.quote => Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 8, 16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: colors.primaryAction, width: 3),
            ),
          ),
          child: Text(
            block.text,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 19,
              height: 1.7,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        QigongBlockType.divider => Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Divider(color: colors.divider),
        ),
        QigongBlockType.spacer => const SizedBox(height: 58),
        QigongBlockType.singleImage || QigongBlockType.imageGallery =>
          _ReadingGallery(block: block, assets: assets, store: store),
        QigongBlockType.imageCaption => Center(
          child: Text(
            block.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.mutedText,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        _ => SelectableText(
          block.text,
          style: TextStyle(
            color: colors.primaryText,
            fontSize: 18,
            height: 1.85,
            letterSpacing: -0.05,
          ),
        ),
      },
    );
  }
}

final class _ReadingGallery extends StatelessWidget {
  const _ReadingGallery({
    required this.block,
    required this.assets,
    required this.store,
  });
  final QigongPostBlock block;
  final List<QigongMediaAsset> assets;
  final QigongManagedMediaStore? store;

  @override
  Widget build(BuildContext context) {
    final selected = <QigongMediaAsset>[
      for (final id in block.mediaIds)
        ...assets.where((asset) => asset.id == id).take(1),
    ];
    if (selected.isEmpty) return const SizedBox.shrink();
    final columns = block.type == QigongBlockType.singleImage
        ? 1
        : block.galleryColumns;
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 12.0;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final asset in selected)
              SizedBox(
                width: itemWidth,
                child: _ReadingImage(asset: asset, store: store),
              ),
          ],
        );
      },
    );
  }
}

final class _ReadingImage extends StatelessWidget {
  const _ReadingImage({required this.asset, required this.store});
  final QigongMediaAsset asset;
  final QigongManagedMediaStore? store;

  @override
  Widget build(BuildContext context) {
    final file = store?.resolve(asset);
    final image = file != null && file.existsSync()
        ? Image.file(file, fit: BoxFit.cover, cacheWidth: 1500)
        : ColoredBox(
            color: context.rynColors.tertiarySurface,
            child: const Center(child: Icon(Icons.broken_image_outlined)),
          );
    return Semantics(
      image: true,
      label: asset.altText.isNotEmpty
          ? asset.altText
          : asset.caption.isNotEmpty
          ? asset.caption
          : '수련기 이미지',
      child: InkWell(
        onTap: file == null || !file.existsSync()
            ? null
            : () => _showLarge(context, file),
        borderRadius: BorderRadius.circular(14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            children: [
              AspectRatio(aspectRatio: 4 / 3, child: image),
              if (asset.caption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    asset.caption,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.rynColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLarge(BuildContext context, File file) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.7,
                maxScale: 5,
                child: Image.file(file, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 18,
              right: 18,
              child: IconButton.filledTonal(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _PublicationSummary extends StatelessWidget {
  const _PublicationSummary({required this.publications});
  final List<QigongPublication> publications;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final item in publications)
        Chip(
          avatar: Icon(
            item.status == QigongPublicationStatus.published
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 16,
          ),
          label: Text('${item.platform.userLabel} · ${item.status.userLabel}'),
        ),
    ],
  );
}

final class _StatusPill extends StatelessWidget {
  const _StatusPill(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: context.rynColors.selectedState,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      value,
      style: TextStyle(
        color: context.rynColors.primaryAction,
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

String _meta(QigongPost post) {
  final parts = <String>[];
  if (post.occurredAt case final date?) {
    parts.add(
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
    );
  }
  if (post.practiceDayNumber case final day?) parts.add('수련 $day일');
  if (post.durationMinutes case final minutes?) parts.add('$minutes분');
  if (post.location case final location?) parts.add(location);
  return parts.isEmpty ? '날짜 미지정' : parts.join('  ·  ');
}
