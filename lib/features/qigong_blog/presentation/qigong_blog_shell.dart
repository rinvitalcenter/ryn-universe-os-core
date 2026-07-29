import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/ryn_tokens.dart';
import '../application/qigong_blog_controller.dart';
import '../domain/qigong_blog_models.dart';
import '../domain/qigong_blog_repository.dart';
import '../infrastructure/qigong_managed_media_store.dart';
import 'qigong_document_studio.dart';
import 'qigong_media_library_view.dart';
import 'qigong_publication_ledger.dart';
import 'qigong_reading_view.dart';

enum QigongWorkspaceSection { posts, media, publication }

enum QigongArchiveLayout { list, gallery }

final class QigongBlogShell extends StatefulWidget {
  const QigongBlogShell({
    super.key,
    required this.repository,
    required this.mediaStore,
    this.pickImages,
  });

  final QigongBlogRepository? repository;
  final QigongManagedMediaStore? mediaStore;
  final Future<List<File>> Function()? pickImages;

  @override
  State<QigongBlogShell> createState() => _QigongBlogShellState();
}

class _QigongBlogShellState extends State<QigongBlogShell> {
  QigongBlogController? _controller;
  QigongWorkspaceSection _section = QigongWorkspaceSection.posts;
  QigongArchiveLayout _layout = QigongArchiveLayout.list;
  bool _editing = true;
  QigongSearchQuery _query = const QigongSearchQuery();
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _createController();
  }

  @override
  void didUpdateWidget(covariant QigongBlogShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.mediaStore != widget.mediaStore) {
      _controller?.dispose();
      _createController();
    }
  }

  void _createController() {
    final repository = widget.repository;
    if (repository == null) {
      _controller = null;
      return;
    }
    _controller =
        QigongBlogController(
            repository: repository,
            mediaStore: widget.mediaStore,
          )
          ..addListener(_onControllerChanged)
          ..initialize();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _search.dispose();
    _controller
      ?..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const _QigongUnavailable();
    final colors = context.rynColors;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
            _save(controller),
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
            _newPost(controller),
      },
      child: Focus(
        autofocus: true,
        child: ColoredBox(
          color: colors.appCanvas,
          child: Column(
            children: [
              _WorkspaceHeader(
                section: _section,
                saveState: controller.saveState,
                hasDocument: controller.document != null,
                onSectionChanged: (section) =>
                    setState(() => _section = section),
                onNew: () => _newPost(controller),
                onSave: () => _save(controller),
              ),
              if (controller.errorMessage case final message?)
                _ErrorBanner(message: message, onClose: controller.clearError),
              Expanded(
                child: switch (_section) {
                  QigongWorkspaceSection.posts => _postsWorkspace(controller),
                  QigongWorkspaceSection.media => QigongMediaLibraryView(
                    assets: controller.mediaAssets,
                    usage: controller.mediaUsage,
                    posts: controller.posts,
                    mediaStore: widget.mediaStore,
                    onOpenSourcePost: (postId) async {
                      await controller.selectPost(postId);
                      if (!mounted) return;
                      setState(() {
                        _section = QigongWorkspaceSection.posts;
                        _editing = false;
                      });
                    },
                    onUpdateMetadata: controller.updateMediaMetadata,
                    onImport: () => _importImages(controller),
                  ),
                  QigongWorkspaceSection.publication => _publicationWorkspace(
                    controller,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _postsWorkspace(QigongBlogController controller) {
    final results =
        (_query.text?.trim().isNotEmpty ?? false) ||
            _hasStructuredFilter(_query)
        ? controller.searchResults
        : controller.posts;
    return LayoutBuilder(
      builder: (context, constraints) {
        final railWidth = constraints.maxWidth < 1050 ? 286.0 : 330.0;
        return Row(
          children: [
            SizedBox(
              width: railWidth,
              child: _ArchiveRail(
                posts: results,
                selectedId: controller.document?.post.id,
                searchController: _search,
                layout: _layout,
                query: _query,
                onLayoutChanged: (value) => setState(() => _layout = value),
                onSearch: (value) =>
                    _runSearch(controller, _query.copyWith(text: value)),
                onAdvancedSearch: () => _advancedSearch(controller),
                onSelect: (postId) async {
                  await controller.selectPost(postId);
                  if (!mounted) return;
                  setState(
                    () => _editing =
                        controller.document?.post.status !=
                        QigongPostStatus.finalPost,
                  );
                },
                onNew: () => _newPost(controller),
              ),
            ),
            VerticalDivider(width: 1, color: context.rynColors.hairline),
            Expanded(child: _documentCanvas(controller)),
          ],
        );
      },
    );
  }

  Widget _documentCanvas(QigongBlogController controller) {
    final document = controller.document;
    if (document == null) {
      return _WritingWelcome(onNew: () => _newPost(controller));
    }
    final posts = controller.posts;
    final index = posts.indexWhere((post) => post.id == document.post.id);
    return Column(
      children: [
        _DocumentCommandBar(
          editing: _editing,
          status: document.post.status,
          onEditingChanged: (value) => setState(() => _editing = value),
          onArchive: document.post.status == QigongPostStatus.archived
              ? null
              : controller.archiveSelected,
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 250),
            child: _editing
                ? QigongDocumentStudio(
                    key: ValueKey('studio-${document.post.id}'),
                    document: document,
                    mediaAssets: controller.mediaAssets,
                    mediaStore: widget.mediaStore,
                    onChanged: controller.updateDocument,
                    onImportImages: () => _importImages(controller),
                  )
                : QigongReadingView(
                    key: ValueKey('reading-${document.post.id}'),
                    document: document,
                    mediaAssets: controller.mediaAssets,
                    mediaStore: widget.mediaStore,
                    onEdit: () => setState(() => _editing = true),
                    onPrevious: index < 0 || index == posts.length - 1
                        ? null
                        : () => controller.selectPost(posts[index + 1].id),
                    onNext: index <= 0
                        ? null
                        : () => controller.selectPost(posts[index - 1].id),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _publicationWorkspace(QigongBlogController controller) {
    final selected = controller.document;
    final finalPosts = controller.posts
        .where((post) => post.status == QigongPostStatus.finalPost)
        .toList();
    return Row(
      children: [
        SizedBox(
          width: 310,
          child: _PublicationPostRail(
            posts: finalPosts,
            selectedId: selected?.post.id,
            onSelect: controller.selectPost,
          ),
        ),
        VerticalDivider(width: 1, color: context.rynColors.hairline),
        Expanded(
          child: selected == null
              ? const _PublicationEmpty()
              : QigongPublicationLedger(
                  document: selected,
                  onChanged: controller.updateDocument,
                ),
        ),
      ],
    );
  }

  void _newPost(QigongBlogController controller) {
    controller.createNewPost();
    setState(() {
      _section = QigongWorkspaceSection.posts;
      _editing = true;
    });
  }

  Future<void> _save(QigongBlogController controller) async {
    final success = await controller.save();
    if (!mounted || !success) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('수련기를 안전하게 저장했습니다.')));
  }

  Future<List<QigongMediaAsset>> _importImages(
    QigongBlogController controller,
  ) async {
    final files = widget.pickImages == null
        ? await _pickImages()
        : await widget.pickImages!();
    if (files.isEmpty) return const [];
    final imported = await controller.importImages(files);
    if (!mounted || imported.isEmpty) return imported;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${imported.length}개 이미지를 안전한 보관함에 가져왔습니다.')),
      );
    return imported;
  }

  Future<List<File>> _pickImages() async {
    const group = XTypeGroup(
      label: 'Images',
      extensions: ['png', 'jpg', 'jpeg', 'webp'],
    );
    final files = await openFiles(acceptedTypeGroups: const [group]);
    return files.map((file) => File(file.path)).toList(growable: false);
  }

  Future<void> _runSearch(
    QigongBlogController controller,
    QigongSearchQuery query,
  ) async {
    setState(() => _query = query);
    await controller.search(query);
  }

  Future<void> _advancedSearch(QigongBlogController controller) async {
    final result = await showDialog<QigongSearchQuery>(
      context: context,
      builder: (_) => _AdvancedSearchDialog(initial: _query),
    );
    if (result != null) {
      await _runSearch(controller, result.copyWith(text: _search.text));
    }
  }
}

final class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({
    required this.section,
    required this.saveState,
    required this.hasDocument,
    required this.onSectionChanged,
    required this.onNew,
    required this.onSave,
  });
  final QigongWorkspaceSection section;
  final QigongSaveState saveState;
  final bool hasDocument;
  final ValueChanged<QigongWorkspaceSection> onSectionChanged;
  final VoidCallback onNew;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: colors.primarySurface,
        border: Border(bottom: BorderSide(color: colors.hairline)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.primaryAction,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.air_rounded, color: colors.onPrimaryInteractive),
          ),
          const SizedBox(width: 13),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '수련 작업실',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              Text(
                'Private publishing studio',
                style: TextStyle(
                  color: colors.mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 34),
          SegmentedButton<QigongWorkspaceSection>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: QigongWorkspaceSection.posts,
                icon: Icon(Icons.article_outlined),
                label: Text('수련기'),
              ),
              ButtonSegment(
                value: QigongWorkspaceSection.media,
                icon: Icon(Icons.photo_library_outlined),
                label: Text('이미지'),
              ),
              ButtonSegment(
                value: QigongWorkspaceSection.publication,
                icon: Icon(Icons.public_outlined),
                label: Text('발행'),
              ),
            ],
            selected: {section},
            onSelectionChanged: (values) => onSectionChanged(values.single),
          ),
          const Spacer(),
          _SaveIndicator(state: saveState),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onNew,
            icon: const Icon(Icons.add_rounded),
            label: const Text('새 수련기'),
          ),
          const SizedBox(width: 9),
          FilledButton.icon(
            onPressed: hasDocument && saveState != QigongSaveState.saving
                ? onSave
                : null,
            icon: const Icon(Icons.check_rounded),
            label: Text(saveState == QigongSaveState.saving ? '저장 중' : '저장'),
          ),
        ],
      ),
    );
  }
}

final class _ArchiveRail extends StatelessWidget {
  const _ArchiveRail({
    required this.posts,
    required this.selectedId,
    required this.searchController,
    required this.layout,
    required this.query,
    required this.onLayoutChanged,
    required this.onSearch,
    required this.onAdvancedSearch,
    required this.onSelect,
    required this.onNew,
  });
  final List<QigongPostSummary> posts;
  final String? selectedId;
  final TextEditingController searchController;
  final QigongArchiveLayout layout;
  final QigongSearchQuery query;
  final ValueChanged<QigongArchiveLayout> onLayoutChanged;
  final ValueChanged<String> onSearch;
  final VoidCallback onAdvancedSearch;
  final ValueChanged<String> onSelect;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return ColoredBox(
      color: colors.secondarySurface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: onSearch,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: '수련기와 이미지 검색',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: onAdvancedSearch,
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: const Text('필터'),
                    ),
                    if (_hasStructuredFilter(query))
                      _ActiveFilterDot(
                        onClear: () => onSearch(searchController.text),
                      ),
                    const Spacer(),
                    IconButton(
                      tooltip: '목록',
                      onPressed: () =>
                          onLayoutChanged(QigongArchiveLayout.list),
                      isSelected: layout == QigongArchiveLayout.list,
                      icon: const Icon(Icons.view_list_rounded),
                    ),
                    IconButton(
                      tooltip: '갤러리',
                      onPressed: () =>
                          onLayoutChanged(QigongArchiveLayout.gallery),
                      isSelected: layout == QigongArchiveLayout.gallery,
                      icon: const Icon(Icons.grid_view_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: posts.isEmpty
                ? _EmptyArchive(onNew: onNew)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 40),
                    itemCount: posts.length,
                    itemBuilder: (context, index) => _ArchivePostTile(
                      post: posts[index],
                      selected: selectedId == posts[index].id,
                      gallery: layout == QigongArchiveLayout.gallery,
                      onTap: () => onSelect(posts[index].id),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

final class _ArchivePostTile extends StatelessWidget {
  const _ArchivePostTile({
    required this.post,
    required this.selected,
    required this.gallery,
    required this.onTap,
  });
  final QigongPostSummary post;
  final bool selected;
  final bool gallery;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = context.rynColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Material(
        color: selected ? colors.selectedState : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.all(gallery ? 15 : 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        post.title.isEmpty ? '제목 없는 수련기' : post.title,
                        maxLines: gallery ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _MiniStatus(post.status.userLabel),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  post.excerpt ??
                      '본문 ${post.imageCount > 0 ? '· 이미지 ${post.imageCount}' : ''}',
                  maxLines: gallery ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      post.occurredAt == null
                          ? '날짜 없음'
                          : '${post.occurredAt!.year}.${post.occurredAt!.month}.${post.occurredAt!.day}',
                      style: TextStyle(color: colors.mutedText, fontSize: 11),
                    ),
                    const Spacer(),
                    if (post.imageCount > 0)
                      Text(
                        '${post.imageCount} images',
                        style: TextStyle(
                          color: colors.mutedText,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _DocumentCommandBar extends StatelessWidget {
  const _DocumentCommandBar({
    required this.editing,
    required this.status,
    required this.onEditingChanged,
    required this.onArchive,
  });
  final bool editing;
  final QigongPostStatus status;
  final ValueChanged<bool> onEditingChanged;
  final VoidCallback? onArchive;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 22, 10),
    child: Row(
      children: [
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: true, label: Text('편집')),
            ButtonSegment(value: false, label: Text('읽기')),
          ],
          selected: {editing},
          onSelectionChanged: (values) => onEditingChanged(values.single),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onArchive,
          icon: const Icon(Icons.archive_outlined, size: 18),
          label: Text(status == QigongPostStatus.archived ? '보관됨' : '보관'),
        ),
      ],
    ),
  );
}

final class _PublicationPostRail extends StatelessWidget {
  const _PublicationPostRail({
    required this.posts,
    required this.selectedId,
    required this.onSelect,
  });
  final List<QigongPostSummary> posts;
  final String? selectedId;
  final Future<bool> Function(String) onSelect;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.rynColors.secondarySurface,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 8, 4, 14),
          child: Text(
            '최종본',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
        for (final post in posts)
          _ArchivePostTile(
            post: post,
            selected: selectedId == post.id,
            gallery: false,
            onTap: () => onSelect(post.id),
          ),
      ],
    ),
  );
}

final class _AdvancedSearchDialog extends StatefulWidget {
  const _AdvancedSearchDialog({required this.initial});
  final QigongSearchQuery initial;
  @override
  State<_AdvancedSearchDialog> createState() => _AdvancedSearchDialogState();
}

class _AdvancedSearchDialogState extends State<_AdvancedSearchDialog> {
  late QigongPostStatus? status = widget.initial.status;
  late int? year = widget.initial.year;
  late int? practiceDay = widget.initial.practiceDayNumber;
  late bool? hasImages = widget.initial.hasImages;
  late String keyword = widget.initial.keyword ?? '';
  late QigongPublicationPlatform? platform = widget.initial.publicationPlatform;
  late QigongPublicationStatus? publicationStatus =
      widget.initial.publicationStatus;
  DateTime? from;
  DateTime? to;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('수련기 필터'),
    content: SizedBox(
      width: 560,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<QigongPostStatus?>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: '상태'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('전체')),
                      ...QigongPostStatus.values.map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.userLabel),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => status = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: year?.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '연도'),
                    onChanged: (value) => year = int.tryParse(value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: practiceDay?.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '수련일'),
                    onChanged: (value) => practiceDay = int.tryParse(value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              initialValue: keyword,
              decoration: const InputDecoration(labelText: '키워드'),
              onChanged: (value) => keyword = value,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<bool?>(
              initialValue: hasImages,
              decoration: const InputDecoration(labelText: '이미지 포함'),
              items: const [
                DropdownMenuItem(value: null, child: Text('전체')),
                DropdownMenuItem(value: true, child: Text('이미지 있음')),
                DropdownMenuItem(value: false, child: Text('이미지 없음')),
              ],
              onChanged: (value) => setState(() => hasImages = value),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<QigongPublicationPlatform?>(
                    initialValue: platform,
                    decoration: const InputDecoration(labelText: '발행 플랫폼'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('전체')),
                      ...QigongPublicationPlatform.values.map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.userLabel),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => platform = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<QigongPublicationStatus?>(
                    initialValue: publicationStatus,
                    decoration: const InputDecoration(labelText: '발행 상태'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('전체')),
                      ...QigongPublicationStatus.values.map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.userLabel),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => publicationStatus = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final value = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDate: from ?? DateTime.now(),
                      );
                      if (value != null) setState(() => from = value);
                    },
                    child: Text(
                      from == null
                          ? '시작일'
                          : '${from!.year}.${from!.month}.${from!.day}',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final value = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDate: to ?? DateTime.now(),
                      );
                      if (value != null) setState(() => to = value);
                    },
                    child: Text(
                      to == null
                          ? '종료일'
                          : '${to!.year}.${to!.month}.${to!.day}',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, const QigongSearchQuery()),
        child: const Text('초기화'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(
          context,
          QigongSearchQuery(
            status: status,
            year: year,
            from: from,
            to: to,
            practiceDayNumber: practiceDay,
            keyword: keyword.trim().isEmpty ? null : keyword.trim(),
            hasImages: hasImages,
            publicationPlatform: platform,
            publicationStatus: publicationStatus,
          ),
        ),
        child: const Text('적용'),
      ),
    ],
  );
}

final class _SaveIndicator extends StatelessWidget {
  const _SaveIndicator({required this.state});
  final QigongSaveState state;
  @override
  Widget build(BuildContext context) {
    final value = switch (state) {
      QigongSaveState.dirty => '저장 전',
      QigongSaveState.saving => '저장 중…',
      QigongSaveState.saved => '저장됨',
      QigongSaveState.failed => '저장 실패 · 내용 보존',
      _ => '준비됨',
    };
    final color = switch (state) {
      QigongSaveState.failed => context.rynColors.destructive,
      QigongSaveState.saved => context.rynColors.success,
      _ => context.rynColors.mutedText,
    };
    return Text(
      value,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
    );
  }
}

final class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onClose});
  final String message;
  final VoidCallback onClose;
  @override
  Widget build(BuildContext context) => MaterialBanner(
    content: Text(message),
    actions: [TextButton(onPressed: onClose, child: const Text('닫기'))],
  );
}

final class _WritingWelcome extends StatelessWidget {
  const _WritingWelcome({required this.onNew});
  final VoidCallback onNew;
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 58,
            color: context.rynColors.primaryAction,
          ),
          const SizedBox(height: 22),
          const Text(
            '기억이 흐려지기 전에, 오늘의 수련을 엽니다.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 11),
          Text(
            '정해진 단계 없이 메모에서 긴 글과 이미지까지 이어가세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.rynColors.secondaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onNew,
            icon: const Icon(Icons.add_rounded),
            label: const Text('새 수련기'),
          ),
        ],
      ),
    ),
  );
}

final class _EmptyArchive extends StatelessWidget {
  const _EmptyArchive({required this.onNew});
  final VoidCallback onNew;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '아직 수련기가 없습니다.',
            style: TextStyle(
              color: context.rynColors.secondaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onNew, child: const Text('첫 글 시작')),
        ],
      ),
    ),
  );
}

final class _PublicationEmpty extends StatelessWidget {
  const _PublicationEmpty();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('최종본을 선택하면 세 채널의 발행 상태를 관리할 수 있습니다.'));
}

final class _QigongUnavailable extends StatelessWidget {
  const _QigongUnavailable();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('수련 작업실을 열 수 없습니다. 실행 데이터 상태를 확인해 주세요.'));
}

final class _MiniStatus extends StatelessWidget {
  const _MiniStatus(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: context.rynColors.tertiarySurface,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      value,
      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
    ),
  );
}

final class _ActiveFilterDot extends StatelessWidget {
  const _ActiveFilterDot({required this.onClear});
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: '필터 초기화',
    onPressed: onClear,
    icon: Icon(
      Icons.filter_alt_rounded,
      size: 18,
      color: context.rynColors.primaryAction,
    ),
  );
}

bool _hasStructuredFilter(QigongSearchQuery query) =>
    query.year != null ||
    query.from != null ||
    query.to != null ||
    query.practiceDayNumber != null ||
    query.status != null ||
    query.keyword != null ||
    query.hasImages != null ||
    query.publicationPlatform != null ||
    query.publicationStatus != null;
