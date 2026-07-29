import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/ryn_tokens.dart';
import '../domain/qigong_blog_models.dart';
import '../infrastructure/qigong_managed_media_store.dart';

typedef QigongImageImporter = Future<List<QigongMediaAsset>> Function();

enum QigongStudioPane { document, notes, ai, media }

final class QigongDocumentStudio extends StatefulWidget {
  const QigongDocumentStudio({
    super.key,
    required this.document,
    required this.mediaAssets,
    required this.mediaStore,
    required this.onChanged,
    required this.onImportImages,
  });

  final QigongBlogDocument document;
  final List<QigongMediaAsset> mediaAssets;
  final QigongManagedMediaStore? mediaStore;
  final ValueChanged<QigongBlogDocument> onChanged;
  final QigongImageImporter onImportImages;

  @override
  State<QigongDocumentStudio> createState() => _QigongDocumentStudioState();
}

class _QigongDocumentStudioState extends State<QigongDocumentStudio> {
  late final TextEditingController _title;
  final Map<String, TextEditingController> _blockControllers = {};
  QigongStudioPane _pane = QigongStudioPane.document;
  int _serial = 0;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.document.post.title);
    _syncBlocks();
  }

  @override
  void didUpdateWidget(covariant QigongDocumentStudio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.post.id != widget.document.post.id) {
      _title.text = widget.document.post.title;
      for (final controller in _blockControllers.values) {
        controller.dispose();
      }
      _blockControllers.clear();
    } else if (_title.text != widget.document.post.title &&
        !_title.selection.isValid) {
      _title.text = widget.document.post.title;
    }
    _syncBlocks();
  }

  void _syncBlocks() {
    final liveIds = widget.document.blocks.map((block) => block.id).toSet();
    for (final id in _blockControllers.keys.toList()) {
      if (!liveIds.contains(id)) _blockControllers.remove(id)?.dispose();
    }
    for (final block in widget.document.blocks) {
      _blockControllers.putIfAbsent(
        block.id,
        () => TextEditingController(text: block.text),
      );
    }
  }

  @override
  void dispose() {
    _title.dispose();
    for (final controller in _blockControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updatePost(QigongPost post) {
    widget.onChanged(widget.document.copyWith(post: post));
  }

  void _updateBlock(int index, QigongPostBlock block) {
    final blocks = [...widget.document.blocks];
    blocks[index] = block.copyWith(order: index);
    widget.onChanged(widget.document.copyWith(blocks: blocks));
  }

  void _addBlock(QigongBlockType type) {
    final blocks = [...widget.document.blocks];
    blocks.add(
      QigongPostBlock(
        id: 'qigong-block-${DateTime.now().microsecondsSinceEpoch}-${_serial++}',
        type: type,
        order: blocks.length,
        galleryColumns: type == QigongBlockType.imageGallery ? 4 : 1,
      ),
    );
    widget.onChanged(widget.document.copyWith(blocks: blocks));
  }

  void _deleteBlock(int index) {
    if (widget.document.blocks.length == 1) return;
    final blocks = [...widget.document.blocks]..removeAt(index);
    widget.onChanged(
      widget.document.copyWith(
        blocks: [
          for (final item in blocks.indexed) item.$2.copyWith(order: item.$1),
        ],
      ),
    );
  }

  void _moveBlock(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= widget.document.blocks.length) return;
    final blocks = [...widget.document.blocks];
    final block = blocks.removeAt(index);
    blocks.insert(target, block);
    widget.onChanged(
      widget.document.copyWith(
        blocks: [
          for (final item in blocks.indexed) item.$2.copyWith(order: item.$1),
        ],
      ),
    );
  }

  Future<void> _importIntoBlock(int index) async {
    final imported = await widget.onImportImages();
    if (!mounted || imported.isEmpty) return;
    final block = widget.document.blocks[index];
    _updateBlock(
      index,
      block.copyWith(
        mediaIds: [...block.mediaIds, ...imported.map((e) => e.id)],
      ),
    );
  }

  Future<void> _copy(String value, String notice) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(notice)));
  }

  void _appendAiDraft() {
    final value = widget.document.post.aiWorkingDraft.trim();
    if (value.isEmpty) return;
    final blocks = [...widget.document.blocks];
    blocks.add(
      QigongPostBlock(
        id: 'qigong-block-${DateTime.now().microsecondsSinceEpoch}-${_serial++}',
        type: QigongBlockType.paragraph,
        order: blocks.length,
        text: value,
      ),
    );
    widget.onChanged(widget.document.copyWith(blocks: blocks));
    setState(() => _pane = QigongStudioPane.document);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return ColoredBox(
      color: colors.primarySurface,
      child: Column(
        children: [
          _StudioHeader(
            document: widget.document,
            pane: _pane,
            onPaneChanged: (value) => setState(() => _pane = value),
            onStatusChanged: (status) =>
                _updatePost(widget.document.post.copyWith(status: status)),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              child: switch (_pane) {
                QigongStudioPane.document => _documentEditor(),
                QigongStudioPane.notes => _notesWorkbench(),
                QigongStudioPane.ai => _aiWorkbench(),
                QigongStudioPane.media => _mediaWorkbench(),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentEditor() {
    final colors = context.rynColors;
    return ListView(
      key: const ValueKey('qigong-document-editor'),
      padding: const EdgeInsets.fromLTRB(42, 34, 42, 120),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: TextField(
            key: const Key('qigong-title-field'),
            controller: _title,
            maxLines: null,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 38,
              height: 1.12,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
            ),
            decoration: const InputDecoration(
              hintText: '오늘의 수련에 제목을 붙여보세요',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) =>
                _updatePost(widget.document.post.copyWith(title: value)),
          ),
        ),
        const SizedBox(height: 16),
        _DocumentMetaLine(post: widget.document.post, onChanged: _updatePost),
        const SizedBox(height: 32),
        for (final indexed in widget.document.blocks.indexed)
          _BlockEditorCard(
            key: ValueKey(indexed.$2.id),
            block: indexed.$2,
            controller: _blockControllers[indexed.$2.id]!,
            index: indexed.$1,
            total: widget.document.blocks.length,
            mediaAssets: widget.mediaAssets,
            mediaStore: widget.mediaStore,
            coverMediaId: widget.document.post.coverMediaId,
            onTextChanged: (value) =>
                _updateBlock(indexed.$1, indexed.$2.copyWith(text: value)),
            onColumnsChanged: (columns) => _updateBlock(
              indexed.$1,
              indexed.$2.copyWith(galleryColumns: columns),
            ),
            onMove: (delta) => _moveBlock(indexed.$1, delta),
            onDelete: () => _deleteBlock(indexed.$1),
            onImport: () => _importIntoBlock(indexed.$1),
            onSetCover: (mediaId) => _updatePost(
              widget.document.post.copyWith(coverMediaId: mediaId),
            ),
          ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: PopupMenuButton<QigongBlockType>(
            tooltip: '블록 추가',
            onSelected: _addBlock,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: QigongBlockType.paragraph,
                child: Text('문단'),
              ),
              PopupMenuItem(
                value: QigongBlockType.heading,
                child: Text('큰 제목'),
              ),
              PopupMenuItem(
                value: QigongBlockType.subheading,
                child: Text('작은 제목'),
              ),
              PopupMenuItem(value: QigongBlockType.quote, child: Text('인용')),
              PopupMenuItem(value: QigongBlockType.divider, child: Text('구분선')),
              PopupMenuItem(value: QigongBlockType.spacer, child: Text('여백')),
              PopupMenuItem(
                value: QigongBlockType.singleImage,
                child: Text('이미지'),
              ),
              PopupMenuItem(
                value: QigongBlockType.imageGallery,
                child: Text('이미지 갤러리'),
              ),
              PopupMenuItem(
                value: QigongBlockType.imageCaption,
                child: Text('이미지 캡션'),
              ),
            ],
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.add_rounded),
              label: const Text('블록 추가'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _notesWorkbench() {
    final post = widget.document.post;
    return _WorkbenchScroll(
      key: const ValueKey('qigong-notes-workbench'),
      storageId: 'notes-${post.id}',
      eyebrow: 'CAPTURE',
      title: '수련 직후의 결을 잃지 않게',
      description: '형식을 정하지 않고 원문과 개인 초안을 나란히 보관합니다.',
      children: [
        _LongField(
          key: const Key('qigong-raw-memo-field'),
          label: '수련 직후 메모',
          hint: '몸과 마음에 남아 있는 것을 자유롭게 적으세요.',
          value: post.rawMemo,
          minLines: 7,
          onChanged: (value) => _updatePost(post.copyWith(rawMemo: value)),
        ),
        _LongField(
          label: '개인 초안',
          hint: '문장으로 이어가며 직접 보완합니다.',
          value: post.personalDraft,
          minLines: 10,
          onChanged: (value) =>
              _updatePost(post.copyWith(personalDraft: value)),
        ),
      ],
    );
  }

  Widget _aiWorkbench() {
    final post = widget.document.post;
    final source = [
      post.rawMemo,
      post.personalDraft,
    ].where((value) => value.trim().isNotEmpty).join('\n\n');
    return _WorkbenchScroll(
      key: const ValueKey('qigong-ai-workbench'),
      storageId: 'ai-${post.id}',
      eyebrow: 'AI BRIDGE · COPY / PASTE',
      title: '정리는 맡겨도, 최종 선택은 린님이',
      description: 'API 연결 없이 원문을 복사하고 결과를 붙여넣습니다. 자동 확정하지 않습니다.',
      children: [
        _WorkbenchAction(
          icon: Icons.content_copy_rounded,
          title: 'AI 정리용 원문',
          description: source.isEmpty ? '수련 직후 메모 또는 개인 초안을 먼저 작성하세요.' : source,
          actionLabel: '원문 복사',
          onPressed: source.isEmpty
              ? null
              : () => _copy(source, 'AI 정리용 원문을 복사했습니다.'),
        ),
        _LongField(
          key: const Key('qigong-ai-draft-field'),
          label: 'AI working draft',
          hint: 'ChatGPT 또는 Gemini의 정리 결과를 붙여넣으세요.',
          value: post.aiWorkingDraft,
          minLines: 11,
          onChanged: (value) =>
              _updatePost(post.copyWith(aiWorkingDraft: value)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: post.aiWorkingDraft.trim().isEmpty
                ? null
                : _appendAiDraft,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('본문에 문단으로 선택 반영'),
          ),
        ),
      ],
    );
  }

  Widget _mediaWorkbench() {
    final post = widget.document.post;
    return _WorkbenchScroll(
      key: const ValueKey('qigong-media-workbench'),
      storageId: 'media-${post.id}',
      eyebrow: 'IMAGE PROMPT DESK',
      title: '이미지의 생각도 글과 함께 보관',
      description: '프롬프트는 자동 실행되지 않으며 복사 후 생성 결과를 직접 가져옵니다.',
      children: [
        _LongField(
          key: const Key('qigong-image-prompt-field'),
          label: '이미지 생성 프롬프트',
          hint: '장면, 빛, 질감, 구도를 자유롭게 적으세요.',
          value: post.imagePrompt,
          minLines: 8,
          onChanged: (value) => _updatePost(post.copyWith(imagePrompt: value)),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: post.imagePrompt.trim().isEmpty
                  ? null
                  : () {
                      final nextHistory = <String>[
                        ...post.promptHistory.where(
                          (item) => item != post.imagePrompt.trim(),
                        ),
                        post.imagePrompt.trim(),
                      ];
                      _updatePost(post.copyWith(promptHistory: nextHistory));
                      _copy(post.imagePrompt, '이미지 프롬프트를 복사했습니다.');
                    },
              icon: const Icon(Icons.content_copy_rounded),
              label: const Text('프롬프트 복사'),
            ),
            FilledButton.tonalIcon(
              onPressed: widget.onImportImages,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('생성 이미지 가져오기'),
            ),
          ],
        ),
        if (post.promptHistory.isNotEmpty)
          _PromptHistory(
            storageId: post.id,
            items: post.promptHistory.reversed.take(8).toList(),
          ),
      ],
    );
  }
}

final class _StudioHeader extends StatelessWidget {
  const _StudioHeader({
    required this.document,
    required this.pane,
    required this.onPaneChanged,
    required this.onStatusChanged,
  });

  final QigongBlogDocument document;
  final QigongStudioPane pane;
  final ValueChanged<QigongStudioPane> onPaneChanged;
  final ValueChanged<QigongPostStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 14),
      decoration: BoxDecoration(
        color: colors.secondarySurface,
        border: Border(bottom: BorderSide(color: colors.hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<QigongStudioPane>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: QigongStudioPane.document,
                  icon: Icon(Icons.edit_note_rounded),
                  label: Text('글 편집'),
                ),
                ButtonSegment(
                  value: QigongStudioPane.notes,
                  icon: Icon(Icons.flash_on_outlined),
                  label: Text('바로 메모'),
                ),
                ButtonSegment(
                  value: QigongStudioPane.ai,
                  icon: Icon(Icons.auto_fix_high_outlined),
                  label: Text('AI 작업'),
                ),
                ButtonSegment(
                  value: QigongStudioPane.media,
                  icon: Icon(Icons.image_outlined),
                  label: Text('이미지'),
                ),
              ],
              selected: {pane},
              onSelectionChanged: (value) => onPaneChanged(value.single),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<QigongPostStatus>(
            value: document.post.status,
            underline: const SizedBox.shrink(),
            onChanged: (value) {
              if (value != null) onStatusChanged(value);
            },
            items: QigongPostStatus.values
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.userLabel),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

final class _DocumentMetaLine extends StatelessWidget {
  const _DocumentMetaLine({required this.post, required this.onChanged});
  final QigongPost post;
  final ValueChanged<QigongPost> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(Icons.calendar_today_outlined, size: 15, color: colors.mutedText),
        Text(
          post.occurredAt == null ? '날짜 미지정' : _date(post.occurredAt!),
          style: TextStyle(
            color: colors.secondaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        _InlineNumber(
          label: '수련일',
          value: post.practiceDayNumber,
          onChanged: (value) =>
              onChanged(post.copyWith(practiceDayNumber: value)),
        ),
        _InlineNumber(
          label: '분',
          value: post.durationMinutes,
          onChanged: (value) =>
              onChanged(post.copyWith(durationMinutes: value)),
        ),
      ],
    );
  }
}

final class _InlineNumber extends StatelessWidget {
  const _InlineNumber({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 104,
    child: TextFormField(
      key: ValueKey('$label-$value'),
      initialValue: value?.toString() ?? '',
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, isDense: true),
      onChanged: (text) => onChanged(int.tryParse(text)),
    ),
  );
}

final class _BlockEditorCard extends StatelessWidget {
  const _BlockEditorCard({
    super.key,
    required this.block,
    required this.controller,
    required this.index,
    required this.total,
    required this.mediaAssets,
    required this.mediaStore,
    required this.coverMediaId,
    required this.onTextChanged,
    required this.onColumnsChanged,
    required this.onMove,
    required this.onDelete,
    required this.onImport,
    required this.onSetCover,
  });

  final QigongPostBlock block;
  final TextEditingController controller;
  final int index;
  final int total;
  final List<QigongMediaAsset> mediaAssets;
  final QigongManagedMediaStore? mediaStore;
  final String? coverMediaId;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<int> onColumnsChanged;
  final ValueChanged<int> onMove;
  final VoidCallback onDelete;
  final VoidCallback onImport;
  final ValueChanged<String> onSetCover;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Focus(
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
          decoration: BoxDecoration(
            color: colors.primarySurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.hairline.withValues(alpha: 0.72)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: switch (block.type) {
                  QigongBlockType.divider => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    child: Divider(color: colors.divider),
                  ),
                  QigongBlockType.spacer => SizedBox(
                    height: 72,
                    child: Center(
                      child: Text(
                        '여백',
                        style: TextStyle(color: colors.mutedText),
                      ),
                    ),
                  ),
                  QigongBlockType.singleImage ||
                  QigongBlockType.imageGallery => _BlockMediaGrid(
                    block: block,
                    assets: mediaAssets,
                    store: mediaStore,
                    coverMediaId: coverMediaId,
                    onImport: onImport,
                    onSetCover: onSetCover,
                  ),
                  _ => TextField(
                    controller: controller,
                    maxLines: null,
                    minLines: block.type == QigongBlockType.quote ? 2 : 1,
                    onChanged: onTextChanged,
                    style: _blockStyle(context, block.type),
                    decoration: InputDecoration(
                      hintText: _blockHint(block.type),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                },
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  if (block.type == QigongBlockType.imageGallery)
                    PopupMenuButton<int>(
                      tooltip: '갤러리 열 수',
                      initialValue: block.galleryColumns,
                      onSelected: onColumnsChanged,
                      itemBuilder: (_) => [
                        for (var columns = 1; columns <= 4; columns++)
                          PopupMenuItem(
                            value: columns,
                            child: Text('$columns열'),
                          ),
                      ],
                      child: _TinyLabel('${block.galleryColumns}열'),
                    ),
                  IconButton(
                    tooltip: '위로 이동',
                    onPressed: index == 0 ? null : () => onMove(-1),
                    icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 20),
                  ),
                  IconButton(
                    tooltip: '아래로 이동',
                    onPressed: index == total - 1 ? null : () => onMove(1),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    tooltip: '블록 삭제',
                    onPressed: total == 1 ? null : onDelete,
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _BlockMediaGrid extends StatelessWidget {
  const _BlockMediaGrid({
    required this.block,
    required this.assets,
    required this.store,
    required this.coverMediaId,
    required this.onImport,
    required this.onSetCover,
  });
  final QigongPostBlock block;
  final List<QigongMediaAsset> assets;
  final QigongManagedMediaStore? store;
  final String? coverMediaId;
  final VoidCallback onImport;
  final ValueChanged<String> onSetCover;

  @override
  Widget build(BuildContext context) {
    final selected = [
      for (final id in block.mediaIds)
        ?assets.where((asset) => asset.id == id).firstOrNull,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selected.isEmpty)
          _ImageDropPlaceholder(onPressed: onImport)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = block.type == QigongBlockType.singleImage
                  ? 1
                  : block.galleryColumns;
              final gap = 10.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return AnimatedSize(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 240),
                child: Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final asset in selected)
                      SizedBox(
                        width: width,
                        child: _ManagedImageTile(
                          asset: asset,
                          store: store,
                          isCover: coverMediaId == asset.id,
                          onSetCover: () => onSetCover(asset.id),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: onImport,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(selected.isEmpty ? '이미지 선택' : '이미지 더하기'),
        ),
      ],
    );
  }
}

final class _ManagedImageTile extends StatelessWidget {
  const _ManagedImageTile({
    required this.asset,
    required this.store,
    required this.isCover,
    required this.onSetCover,
  });
  final QigongMediaAsset asset;
  final QigongManagedMediaStore? store;
  final bool isCover;
  final VoidCallback onSetCover;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    final File? file = store?.resolve(asset);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: file != null && file.existsSync()
                ? Image.file(file, fit: BoxFit.cover, cacheWidth: 1000)
                : ColoredBox(
                    color: colors.tertiarySurface,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: colors.mutedText,
                    ),
                  ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: colors.primarySurface.withValues(alpha: 0.9),
              shape: const StadiumBorder(),
              child: InkWell(
                onTap: onSetCover,
                customBorder: const StadiumBorder(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCover
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCover ? '커버' : '커버로',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
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

final class _ImageDropPlaceholder extends StatelessWidget {
  const _ImageDropPlaceholder({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: colors.secondarySurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.hairline),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 30,
                color: colors.primaryAction,
              ),
              const SizedBox(height: 10),
              const Text(
                '이미지를 안전한 보관함으로 가져오기',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _WorkbenchScroll extends StatelessWidget {
  const _WorkbenchScroll({
    super.key,
    required this.storageId,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.children,
  });
  final String storageId;
  final String eyebrow;
  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return ListView(
      key: PageStorageKey<String>('qigong-workbench-scroll-$storageId'),
      padding: const EdgeInsets.fromLTRB(42, 38, 42, 120),
      children: [
        Text(
          eyebrow,
          style: TextStyle(
            color: colors.primaryAction,
            fontSize: 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            color: colors.primaryText,
            fontSize: 30,
            height: 1.2,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            color: colors.secondaryText,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 30),
        ...children.expand((child) => [child, const SizedBox(height: 22)]),
      ],
    );
  }
}

final class _LongField extends StatefulWidget {
  const _LongField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.minLines,
    required this.onChanged,
  });
  final String label;
  final String hint;
  final String value;
  final int minLines;
  final ValueChanged<String> onChanged;

  @override
  State<_LongField> createState() => _LongFieldState();
}

class _LongFieldState extends State<_LongField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );
  @override
  void didUpdateWidget(covariant _LongField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value && !_controller.selection.isValid) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    minLines: widget.minLines,
    maxLines: null,
    onChanged: widget.onChanged,
    decoration: InputDecoration(
      labelText: widget.label,
      hintText: widget.hint,
      alignLabelWithHint: true,
    ),
  );
}

final class _WorkbenchAction extends StatelessWidget {
  const _WorkbenchAction({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onPressed,
  });
  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.secondarySurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primaryAction),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.secondaryText, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton(onPressed: onPressed, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

final class _PromptHistory extends StatelessWidget {
  const _PromptHistory({required this.storageId, required this.items});
  final String storageId;
  final List<String> items;
  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: ExpansionTile(
      key: PageStorageKey<String>('qigong-prompt-history-$storageId'),
      title: Text('최근 프롬프트 ${items.length}개'),
      children: [
        for (final item in items)
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: Text(item, maxLines: 3, overflow: TextOverflow.ellipsis),
          ),
      ],
    ),
  );
}

final class _TinyLabel extends StatelessWidget {
  const _TinyLabel(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: context.rynColors.tertiarySurface,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      value,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
    ),
  );
}

TextStyle _blockStyle(BuildContext context, QigongBlockType type) {
  final colors = context.rynColors;
  return switch (type) {
    QigongBlockType.heading => TextStyle(
      color: colors.primaryText,
      fontSize: 28,
      height: 1.25,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.5,
    ),
    QigongBlockType.subheading => TextStyle(
      color: colors.primaryText,
      fontSize: 21,
      height: 1.35,
      fontWeight: FontWeight.w800,
    ),
    QigongBlockType.quote => TextStyle(
      color: colors.secondaryText,
      fontSize: 18,
      height: 1.65,
      fontStyle: FontStyle.italic,
    ),
    QigongBlockType.imageCaption => TextStyle(
      color: colors.mutedText,
      fontSize: 13,
      height: 1.5,
    ),
    _ => TextStyle(color: colors.primaryText, fontSize: 17, height: 1.75),
  };
}

String _blockHint(QigongBlockType type) => switch (type) {
  QigongBlockType.heading => '큰 제목',
  QigongBlockType.subheading => '작은 제목',
  QigongBlockType.quote => '기억하고 싶은 문장',
  QigongBlockType.imageCaption => '이미지 설명',
  _ => '이어서 적어보세요…',
};

String _date(DateTime value) =>
    '${value.year}.${value.month.toString().padLeft(2, '0')}.${value.day.toString().padLeft(2, '0')}';
