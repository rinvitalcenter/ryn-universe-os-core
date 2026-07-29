import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../domain/qigong_blog_models.dart';
import '../domain/qigong_blog_repository.dart';
import '../infrastructure/qigong_managed_media_store.dart';

enum QigongSaveState { idle, dirty, saving, saved, failed }

final class QigongBlogController extends ChangeNotifier {
  QigongBlogController({
    required QigongBlogRepository repository,
    QigongManagedMediaStore? mediaStore,
  }) : this._(repository, mediaStore);

  QigongBlogController._(this._repository, this._mediaStore);

  final QigongBlogRepository _repository;
  final QigongManagedMediaStore? _mediaStore;
  StreamSubscription<List<QigongPostSummary>>? _postsSubscription;
  StreamSubscription<List<QigongMediaAsset>>? _mediaSubscription;
  int _idCounter = 0;

  List<QigongPostSummary> _posts = const [];
  List<QigongMediaAsset> _mediaAssets = const [];
  Map<String, List<String>> _mediaUsage = const {};
  QigongBlogDocument? _document;
  QigongSearchQuery _query = const QigongSearchQuery();
  List<QigongPostSummary> _searchResults = const [];
  QigongSaveState _saveState = QigongSaveState.idle;
  String? _errorMessage;
  bool _loading = true;

  List<QigongPostSummary> get posts => _posts;
  List<QigongMediaAsset> get mediaAssets => _mediaAssets;
  Map<String, List<String>> get mediaUsage => _mediaUsage;
  QigongBlogDocument? get document => _document;
  QigongSearchQuery get query => _query;
  List<QigongPostSummary> get searchResults => _searchResults;
  QigongSaveState get saveState => _saveState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loading;
  bool get isSaving => _saveState == QigongSaveState.saving;
  bool get canImportMedia => _mediaStore != null;

  Future<void> initialize() async {
    await _postsSubscription?.cancel();
    await _mediaSubscription?.cancel();
    _loading = true;
    notifyListeners();
    _postsSubscription = _repository.watchPosts().listen(
      (posts) {
        _posts = posts;
        _loading = false;
        notifyListeners();
      },
      onError: (_) {
        _loading = false;
        _errorMessage = '수련기 목록을 불러오지 못했습니다.';
        notifyListeners();
      },
    );
    _mediaSubscription = _repository.watchMediaAssets().listen(
      (assets) {
        _mediaAssets = assets;
        unawaited(_refreshMediaUsage());
        notifyListeners();
      },
      onError: (_) {
        _errorMessage = '이미지 보관함을 불러오지 못했습니다.';
        notifyListeners();
      },
    );
  }

  QigongBlogDocument createNewPost({DateTime? now}) {
    final timestamp = (now ?? DateTime.now().toUtc()).toUtc();
    final id = _newId('qigong-post', timestamp);
    _document = QigongBlogDocument(
      post: QigongPost(
        id: id,
        title: '',
        status: QigongPostStatus.quickNote,
        occurredAt: timestamp,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
      blocks: [
        QigongPostBlock(
          id: _newId('qigong-block', timestamp),
          type: QigongBlockType.paragraph,
          order: 0,
        ),
      ],
      tags: const [],
      publications: const [
        QigongPublication(
          platform: QigongPublicationPlatform.naverCafeQigongDoga,
          status: QigongPublicationStatus.notPublished,
        ),
        QigongPublication(
          platform: QigongPublicationPlatform.daumCafeQigongVillage,
          status: QigongPublicationStatus.notPublished,
        ),
        QigongPublication(
          platform: QigongPublicationPlatform.naverBlogMyeongrinLab,
          status: QigongPublicationStatus.notPublished,
        ),
      ],
    );
    _saveState = QigongSaveState.dirty;
    _errorMessage = null;
    notifyListeners();
    return _document!;
  }

  Future<bool> selectPost(String postId) async {
    final result = await _repository.loadPost(postId);
    if (result.isFailure || result.value == null) {
      _errorMessage = '수련기를 열지 못했습니다.';
      notifyListeners();
      return false;
    }
    _document = result.value;
    _saveState = QigongSaveState.idle;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  void updateDocument(QigongBlogDocument document) {
    _document = document;
    if (_saveState != QigongSaveState.saving) {
      _saveState = QigongSaveState.dirty;
    }
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> save() async {
    final pending = _document;
    if (pending == null || isSaving) return false;
    _saveState = QigongSaveState.saving;
    _errorMessage = null;
    notifyListeners();
    final updated = pending.copyWith(
      post: pending.post.copyWith(updatedAt: DateTime.now().toUtc()),
    );
    final result = await _repository.savePost(updated);
    if (result.isFailure) {
      _document = pending;
      _saveState = QigongSaveState.failed;
      _errorMessage = '저장하지 못했습니다. 작성 중인 내용은 그대로 보존됩니다.';
      notifyListeners();
      return false;
    }
    _document = result.value ?? updated;
    _saveState = QigongSaveState.saved;
    notifyListeners();
    return true;
  }

  Future<List<QigongMediaAsset>> importImages(List<File> files) async {
    final store = _mediaStore;
    if (store == null) {
      _errorMessage = '이 실행에서는 이미지 가져오기를 사용할 수 없습니다.';
      notifyListeners();
      return const [];
    }
    final imported = <QigongMediaAsset>[];
    for (final file in files) {
      try {
        final copy = await store.importImage(file);
        final saved = await _repository.saveMediaAsset(copy.asset);
        if (saved.isFailure || saved.value == null) {
          throw StateError('media_database_write_failed');
        }
        imported.add(saved.value!);
      } on Object {
        _errorMessage = '일부 이미지를 가져오지 못했습니다.';
        notifyListeners();
        break;
      }
    }
    if (imported.isNotEmpty) {
      _errorMessage = null;
      notifyListeners();
    }
    return imported;
  }

  Future<bool> updateMediaMetadata(QigongMediaAsset asset) async {
    final result = await _repository.updateMediaMetadata(asset);
    if (result.isFailure) {
      _errorMessage = '이미지 설명을 저장하지 못했습니다.';
      notifyListeners();
      return false;
    }
    _errorMessage = null;
    return true;
  }

  Future<void> search(QigongSearchQuery query) async {
    _query = query;
    _searchResults = await _repository.searchPosts(query);
    notifyListeners();
  }

  Future<bool> archiveSelected() async {
    final postId = _document?.post.id;
    if (postId == null || isSaving) return false;
    final archivedAt = DateTime.now().toUtc();
    final result = await _repository.archivePost(
      postId,
      archivedAt: archivedAt,
    );
    if (result.isFailure) {
      _errorMessage = '수련기를 보관하지 못했습니다.';
      notifyListeners();
      return false;
    }
    _document = _document!.copyWith(
      post: _document!.post.copyWith(
        status: QigongPostStatus.archived,
        archivedAt: archivedAt,
        updatedAt: archivedAt,
      ),
    );
    notifyListeners();
    return true;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _refreshMediaUsage() async {
    _mediaUsage = await _repository.loadMediaUsage();
    notifyListeners();
  }

  String _newId(String prefix, DateTime timestamp) =>
      '$prefix-${timestamp.microsecondsSinceEpoch}-${_idCounter++}';

  @override
  void dispose() {
    _postsSubscription?.cancel();
    _mediaSubscription?.cancel();
    super.dispose();
  }
}
