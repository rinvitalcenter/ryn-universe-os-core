import 'qigong_blog_models.dart';

final class QigongRepositoryResult<T> {
  const QigongRepositoryResult._({this.value, this.error});

  const QigongRepositoryResult.success([T? value]) : this._(value: value);
  const QigongRepositoryResult.failure(Object error) : this._(error: error);

  final T? value;
  final Object? error;
  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

abstract interface class QigongBlogRepository {
  Future<QigongRepositoryResult<QigongMediaAsset>> saveMediaAsset(
    QigongMediaAsset asset,
  );

  Future<QigongRepositoryResult<QigongMediaAsset>> updateMediaMetadata(
    QigongMediaAsset asset,
  );

  Future<QigongRepositoryResult<QigongBlogDocument>> savePost(
    QigongBlogDocument document,
  );

  Future<QigongRepositoryResult<QigongBlogDocument>> loadPost(String postId);

  Future<QigongRepositoryResult<void>> archivePost(
    String postId, {
    required DateTime archivedAt,
  });

  Stream<List<QigongPostSummary>> watchPosts();
  Stream<List<QigongMediaAsset>> watchMediaAssets();
  Future<Map<String, List<String>>> loadMediaUsage();
  Future<List<QigongPostSummary>> searchPosts(QigongSearchQuery query);
}
