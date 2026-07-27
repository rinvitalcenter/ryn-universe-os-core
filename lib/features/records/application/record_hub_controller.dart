import 'package:flutter/foundation.dart';

import '../domain/record_summary.dart';
import 'record_summary_adapter.dart';

enum RecordHubSection { all, recent, tarot, byDate }

enum RecordAdapterLoadState { idle, loading, ready, error }

final class RecordHubController extends ChangeNotifier {
  RecordHubController({List<RecordSummaryAdapter> adapters = const []})
    : _adapters = List.unmodifiable(adapters);

  final List<RecordSummaryAdapter> _adapters;
  final Map<RecordModuleType, RecordAdapterLoadState> _adapterStates = {};
  final Map<RecordModuleType, Object> _adapterErrors = {};
  List<RecordSummary> _allSummaries = const [];
  RecordKey? _selectedKey;
  String _searchQuery = '';
  RecordModuleType? _moduleFilter;
  RecordDisplayStatus? _statusFilter;
  String? _personFilter;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  RecordHubSection _section = RecordHubSection.all;
  var _refreshGeneration = 0;
  var _disposed = false;

  List<RecordSummary> get allSummaries => List.unmodifiable(_allSummaries);
  RecordKey? get selectedKey => _selectedKey;
  String get searchQuery => _searchQuery;
  RecordModuleType? get moduleFilter => _moduleFilter;
  RecordDisplayStatus? get statusFilter => _statusFilter;
  String? get personFilter => _personFilter;
  DateTime? get dateFrom => _dateFrom;
  DateTime? get dateTo => _dateTo;
  RecordHubSection get section => _section;
  bool get isLoading =>
      _adapterStates.values.contains(RecordAdapterLoadState.loading);
  bool get hasErrors => _adapterErrors.isNotEmpty;
  Map<RecordModuleType, Object> get adapterErrors =>
      Map.unmodifiable(_adapterErrors);
  bool get hasCanonicalPersonLinks =>
      _allSummaries.any((item) => item.personId != null);

  bool get hasActiveFilters =>
      _searchQuery.trim().isNotEmpty ||
      _moduleFilter != null ||
      _statusFilter != null ||
      _personFilter != null ||
      _dateFrom != null ||
      _dateTo != null;

  List<RecordSummary> get visibleSummaries {
    final query = _normalize(_searchQuery);
    final result = _allSummaries.where((item) {
      if (_moduleFilter != null && item.moduleType != _moduleFilter) {
        return false;
      }
      if (_statusFilter != null && item.status != _statusFilter) return false;
      if (_personFilter != null && item.personId != _personFilter) return false;
      if (_dateFrom != null && item.occurredAt.isBefore(_dateFrom!)) {
        return false;
      }
      if (_dateTo != null && item.occurredAt.isAfter(_dateTo!)) return false;
      if (query.isEmpty) return true;
      final corpus = <String>[
        item.title,
        item.shortSummary,
        ...item.searchTerms,
      ].map(_normalize);
      return corpus.any((value) => value.contains(query));
    }).toList()..sort(_newestFirst);
    return List.unmodifiable(result);
  }

  RecordSummary? get selectedSummary => summaryFor(_selectedKey);

  RecordSummary? summaryFor(RecordKey? key) {
    if (key == null) return null;
    for (final summary in _allSummaries) {
      if (summary.key == key) return summary;
    }
    return null;
  }

  Future<void> refresh() async {
    if (_adapters.isEmpty || _disposed) return;
    final generation = ++_refreshGeneration;
    for (final adapter in _adapters) {
      _adapterStates[adapter.moduleType] = RecordAdapterLoadState.loading;
    }
    notifyListeners();

    final retainedByModule = <RecordModuleType, List<RecordSummary>>{
      for (final module in RecordModuleType.values)
        module: _allSummaries
            .where((item) => item.moduleType == module)
            .toList(),
    };
    for (final adapter in _adapters) {
      try {
        final summaries = await adapter.loadSummaries();
        if (_disposed || generation != _refreshGeneration) return;
        retainedByModule[adapter.moduleType] = summaries;
        _adapterStates[adapter.moduleType] = RecordAdapterLoadState.ready;
        _adapterErrors.remove(adapter.moduleType);
      } catch (error) {
        if (_disposed || generation != _refreshGeneration) return;
        _adapterStates[adapter.moduleType] = RecordAdapterLoadState.error;
        _adapterErrors[adapter.moduleType] = error;
      }
    }
    if (_disposed || generation != _refreshGeneration) return;
    replaceSummaries(retainedByModule.values.expand((items) => items));
  }

  void replaceSummaries(Iterable<RecordSummary> summaries) {
    _allSummaries = summaries.toList()..sort(_newestFirst);
    _reconcileSelection();
    notifyListeners();
  }

  void select(RecordKey key) {
    if (summaryFor(key) == null || _selectedKey == key) return;
    _selectedKey = key;
    notifyListeners();
  }

  void updateSection(RecordHubSection section) {
    _section = section;
    _moduleFilter = section == RecordHubSection.tarot
        ? RecordModuleType.tarot
        : null;
    _reconcileSelection();
    notifyListeners();
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    _reconcileSelection();
    notifyListeners();
  }

  void updateModuleFilter(RecordModuleType? value) {
    _moduleFilter = value;
    _reconcileSelection();
    notifyListeners();
  }

  void updateStatusFilter(RecordDisplayStatus? value) {
    _statusFilter = value;
    _reconcileSelection();
    notifyListeners();
  }

  void updatePersonFilter(String? value) {
    _personFilter = value;
    _reconcileSelection();
    notifyListeners();
  }

  void updateDateRange(DateTime? from, DateTime? to) {
    _dateFrom = from;
    _dateTo = to;
    _reconcileSelection();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _moduleFilter = null;
    _statusFilter = null;
    _personFilter = null;
    _dateFrom = null;
    _dateTo = null;
    _section = RecordHubSection.all;
    _reconcileSelection();
    notifyListeners();
  }

  void _reconcileSelection() {
    final visible = visibleSummaries;
    if (visible.isEmpty) {
      _selectedKey = null;
    } else if (!visible.any((item) => item.key == _selectedKey)) {
      _selectedKey = visible.first.key;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _refreshGeneration++;
    super.dispose();
  }

  static int _newestFirst(RecordSummary left, RecordSummary right) {
    final occurred = right.occurredAt.compareTo(left.occurredAt);
    if (occurred != 0) return occurred;
    final updated = right.updatedAt.compareTo(left.updatedAt);
    if (updated != 0) return updated;
    return left.key.canonicalRecordId.compareTo(right.key.canonicalRecordId);
  }

  static String _normalize(String value) => value.trim().toLowerCase();
}
