import '../../tarot/models/tarot_reading_result_snapshot.dart';

final class SessionTarotResults {
  final List<TarotReadingResultSnapshot> _results = [];
  String? _activeReadingInstanceId;

  List<TarotReadingResultSnapshot> get results =>
      List<TarotReadingResultSnapshot>.unmodifiable(_results);

  String? get activeReadingInstanceId => _activeReadingInstanceId;

  TarotReadingResultSnapshot? get activeResult {
    final id = _activeReadingInstanceId;
    if (id == null) return null;
    for (final result in _results) {
      if (result.readingInstanceId == id) return result;
    }
    return null;
  }

  void hydrate(
    List<TarotReadingResultSnapshot> snapshots, {
    required String? activeReadingInstanceId,
  }) {
    final ids = <String>{};
    for (final snapshot in snapshots) {
      if (!ids.add(snapshot.readingInstanceId)) {
        throw ArgumentError.value(
          snapshot.readingInstanceId,
          'snapshots',
          'must not contain duplicate reading IDs',
        );
      }
    }
    if (activeReadingInstanceId != null &&
        !ids.contains(activeReadingInstanceId)) {
      throw ArgumentError.value(
        activeReadingInstanceId,
        'activeReadingInstanceId',
        'must identify a hydrated reading',
      );
    }
    _results
      ..clear()
      ..addAll(snapshots);
    _activeReadingInstanceId = activeReadingInstanceId;
  }

  void complete(TarotReadingResultSnapshot snapshot) {
    final index = _results.indexWhere(
      (item) => item.readingInstanceId == snapshot.readingInstanceId,
    );
    if (index == -1) {
      _results.insert(0, snapshot);
    } else {
      _results[index] = snapshot;
    }
    _activeReadingInstanceId = snapshot.readingInstanceId;
  }

  void hideFromHome() => _activeReadingInstanceId = null;

  bool showOnHome(String readingInstanceId) {
    if (!_results.any((item) => item.readingInstanceId == readingInstanceId)) {
      return false;
    }
    _activeReadingInstanceId = readingInstanceId;
    return true;
  }

  bool isActive(TarotReadingResultSnapshot snapshot) =>
      snapshot.readingInstanceId == _activeReadingInstanceId;
}
