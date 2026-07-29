import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/ryn_tokens.dart';
import '../domain/qigong_blog_models.dart';
import '../infrastructure/qigong_managed_media_store.dart';

enum QigongMediaUsageFilter { all, used, unused }

final class QigongMediaLibraryView extends StatefulWidget {
  const QigongMediaLibraryView({
    super.key,
    required this.assets,
    required this.usage,
    required this.posts,
    required this.mediaStore,
    required this.onOpenSourcePost,
    required this.onUpdateMetadata,
    required this.onImport,
  });

  final List<QigongMediaAsset> assets;
  final Map<String, List<String>> usage;
  final List<QigongPostSummary> posts;
  final QigongManagedMediaStore? mediaStore;
  final ValueChanged<String> onOpenSourcePost;
  final Future<bool> Function(QigongMediaAsset asset) onUpdateMetadata;
  final VoidCallback onImport;

  @override
  State<QigongMediaLibraryView> createState() => _QigongMediaLibraryViewState();
}

class _QigongMediaLibraryViewState extends State<QigongMediaLibraryView> {
  int _columns = 4;
  int? _year;
  String _keyword = '';
  QigongMediaUsageFilter _usageFilter = QigongMediaUsageFilter.all;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final filtered = widget.assets.where((asset) {
      final postIds = widget.usage[asset.id] ?? const [];
      if (_usageFilter == QigongMediaUsageFilter.used && postIds.isEmpty) {
        return false;
      }
      if (_usageFilter == QigongMediaUsageFilter.unused && postIds.isNotEmpty) {
        return false;
      }
      if (_year != null && asset.createdAt.year != _year) return false;
      final term = _keyword.trim().toLowerCase();
      if (term.isNotEmpty &&
          ![
            asset.caption,
            asset.altText,
            asset.originalFileName,
          ].join(' ').toLowerCase().contains(term)) {
        return false;
      }
      return true;
    }).toList();
    final years =
        widget.assets.map((asset) => asset.createdAt.year).toSet().toList()
          ..sort((a, b) => b.compareTo(a));
    return ColoredBox(
      color: colors.appCanvas,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 24, 30, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이미지 보관함',
                        style: TextStyle(
                          color: colors.primaryText,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${filtered.length}개의 이미지 · 안전한 관리 사본',
                        style: TextStyle(color: colors.secondaryText),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: widget.onImport,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('이미지 가져오기'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 18),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 230,
                  child: TextField(
                    key: const Key('qigong-media-keyword-filter'),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'caption · 키워드',
                      isDense: true,
                    ),
                    onChanged: (value) => setState(() => _keyword = value),
                  ),
                ),
                DropdownButton<int?>(
                  value: _year,
                  hint: const Text('전체 연도'),
                  onChanged: (value) => setState(() => _year = value),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('전체 연도'),
                    ),
                    ...years.map(
                      (year) => DropdownMenuItem<int?>(
                        value: year,
                        child: Text('$year'),
                      ),
                    ),
                  ],
                ),
                SegmentedButton<QigongMediaUsageFilter>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: QigongMediaUsageFilter.all,
                      label: Text('전체'),
                    ),
                    ButtonSegment(
                      value: QigongMediaUsageFilter.used,
                      label: Text('사용 중'),
                    ),
                    ButtonSegment(
                      value: QigongMediaUsageFilter.unused,
                      label: Text('미사용'),
                    ),
                  ],
                  selected: {_usageFilter},
                  onSelectionChanged: (value) =>
                      setState(() => _usageFilter = value.single),
                ),
                SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 1, label: Text('1')),
                    ButtonSegment(value: 2, label: Text('2')),
                    ButtonSegment(value: 3, label: Text('3')),
                    ButtonSegment(value: 4, label: Text('4')),
                  ],
                  selected: {_columns},
                  onSelectionChanged: (value) =>
                      setState(() => _columns = value.single),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const _EmptyMedia()
                : AnimatedSwitcher(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 230),
                    child: GridView.builder(
                      key: ValueKey(
                        'qigong-media-grid-$_columns-${filtered.length}',
                      ),
                      padding: const EdgeInsets.fromLTRB(30, 0, 30, 70),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _columns,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: _columns == 1 ? 2.2 : 0.86,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => _MediaArchiveTile(
                        asset: filtered[index],
                        sourcePostIds:
                            widget.usage[filtered[index].id] ?? const [],
                        posts: widget.posts,
                        store: widget.mediaStore,
                        onOpenPost: widget.onOpenSourcePost,
                        onEdit: () => _editMetadata(context, filtered[index]),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _editMetadata(
    BuildContext context,
    QigongMediaAsset asset,
  ) async {
    final caption = TextEditingController(text: asset.caption);
    final alt = TextEditingController(text: asset.altText);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 설명'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: caption,
                decoration: const InputDecoration(labelText: 'Caption'),
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: alt,
                decoration: const InputDecoration(
                  labelText: 'Alt / description',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    if (saved == true) {
      await widget.onUpdateMetadata(
        asset.copyWith(caption: caption.text.trim(), altText: alt.text.trim()),
      );
    }
    caption.dispose();
    alt.dispose();
  }
}

final class _MediaArchiveTile extends StatelessWidget {
  const _MediaArchiveTile({
    required this.asset,
    required this.sourcePostIds,
    required this.posts,
    required this.store,
    required this.onOpenPost,
    required this.onEdit,
  });
  final QigongMediaAsset asset;
  final List<String> sourcePostIds;
  final List<QigongPostSummary> posts;
  final QigongManagedMediaStore? store;
  final ValueChanged<String> onOpenPost;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final file = store?.resolve(asset);
    String? sourceTitle;
    if (sourcePostIds.isNotEmpty) {
      for (final post in posts) {
        if (post.id == sourcePostIds.first) {
          sourceTitle = post.title;
          break;
        }
      }
    }
    return Material(
      color: colors.primarySurface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: file != null && file.existsSync()
            ? () => _showLarge(context, file)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox.expand(
                child: file != null && file.existsSync()
                    ? Image.file(file, fit: BoxFit.cover, cacheWidth: 900)
                    : ColoredBox(
                        color: colors.tertiarySurface,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: colors.mutedText,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.caption.isEmpty ? '설명 없는 이미지' : asset.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          sourceTitle ?? '아직 글에 사용되지 않음',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'source' && sourcePostIds.isNotEmpty) {
                        onOpenPost(sourcePostIds.first);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('설명 편집')),
                      if (sourcePostIds.isNotEmpty)
                        const PopupMenuItem(
                          value: 'source',
                          child: Text('사용 중인 글로 이동'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

final class _EmptyMedia extends StatelessWidget {
  const _EmptyMedia();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.photo_library_outlined,
          size: 48,
          color: context.rynColors.mutedText,
        ),
        const SizedBox(height: 14),
        const Text(
          '조건에 맞는 이미지가 없습니다.',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}
