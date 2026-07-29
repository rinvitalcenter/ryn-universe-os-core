import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../people/domain/person_core_models.dart';
import '../../people/domain/person_core_repositories.dart';
import '../domain/study_operations_models.dart';
import '../domain/study_operations_repository.dart';

final class StudyOperationsController extends ChangeNotifier {
  StudyOperationsController({
    required this.repository,
    required this.peopleRepository,
  });

  final StudyOperationsRepository repository;
  final PersonRepository peopleRepository;
  StreamSubscription<List<StudySessionSummary>>? _sessionSubscription;
  StreamSubscription<List<StudyMaterial>>? _materialSubscription;
  StreamSubscription<List<Person>>? _peopleSubscription;

  List<StudySessionSummary> _sessions = const [];
  List<StudyMaterial> _materials = const [];
  List<Person> _people = const [];
  StudySessionFilter _filter = const StudySessionFilter();
  StudySessionRecord? _selectedRecord;
  bool _loading = true;
  String? _errorMessage;

  List<StudySessionSummary> get sessions => List.unmodifiable(_sessions);
  List<StudyMaterial> get materials => List.unmodifiable(_materials);
  List<Person> get people => List.unmodifiable(_people);
  List<Person> get activePeople => _people
      .where((person) => person.status == 'active' && person.archivedAt == null)
      .toList(growable: false);
  StudySessionFilter get filter => _filter;
  StudySessionRecord? get selectedRecord => _selectedRecord;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  List<StudySessionSummary> get filteredSessions {
    final query = _filter.query.trim().toLowerCase();
    final output = _sessions
        .where((item) {
          final session = item.session;
          if (_filter.track != null && session.track != _filter.track) {
            return false;
          }
          if (_filter.status != null && session.status != _filter.status) {
            return false;
          }
          if (_filter.personId != null &&
              !item.participantIds.contains(_filter.personId)) {
            return false;
          }
          if (_filter.attendance != null &&
              !item.attendanceStates.contains(_filter.attendance)) {
            return false;
          }
          final occurred = session.occurredAt.toLocal();
          if (_filter.from != null &&
              occurred.isBefore(_startOfDay(_filter.from!))) {
            return false;
          }
          if (_filter.to != null && occurred.isAfter(_endOfDay(_filter.to!))) {
            return false;
          }
          if (query.isNotEmpty) {
            final haystack = <String?>[
              session.title,
              session.location,
              session.summary,
              session.operationNotes,
              session.learningGoal,
              session.coveredContent,
              session.nextSteps,
            ].whereType<String>().join(' ').toLowerCase();
            if (!haystack.contains(query)) return false;
          }
          return true;
        })
        .toList(growable: true);
    output.sort((left, right) {
      final comparison = left.session.occurredAt.compareTo(
        right.session.occurredAt,
      );
      return _filter.sortOrder == StudySortOrder.newest
          ? -comparison
          : comparison;
    });
    return List.unmodifiable(output);
  }

  StudySessionSummary? get nextPlanned {
    final now = DateTime.now().toUtc();
    final planned =
        _sessions
            .where(
              (item) =>
                  item.session.status == StudySessionStatus.planned &&
                  !item.session.occurredAt.isBefore(now),
            )
            .toList()
          ..sort(
            (left, right) =>
                left.session.occurredAt.compareTo(right.session.occurredAt),
          );
    return planned.firstOrNull;
  }

  StudySessionSummary? get latestCompleted {
    final completed =
        _sessions
            .where(
              (item) => item.session.status == StudySessionStatus.completed,
            )
            .toList()
          ..sort(
            (left, right) =>
                right.session.occurredAt.compareTo(left.session.occurredAt),
          );
    return completed.firstOrNull;
  }

  int get recentAttendedCount => _sessions
      .take(5)
      .fold<int>(
        0,
        (total, item) =>
            total +
            (item.attendanceStates.contains(StudyAttendanceStatus.attended)
                ? 1
                : 0),
      );

  Future<void> bootstrap() async {
    await _sessionSubscription?.cancel();
    await _materialSubscription?.cancel();
    await _peopleSubscription?.cancel();
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    _sessionSubscription = repository.watchSessions().listen(
      (value) {
        _sessions = value;
        _loading = false;
        notifyListeners();
      },
      onError: (_) {
        _loading = false;
        _errorMessage = '운영 기록을 불러오지 못했습니다.';
        notifyListeners();
      },
    );
    _materialSubscription = repository.watchMaterials().listen(
      (value) {
        _materials = value;
        notifyListeners();
      },
      onError: (_) {
        _errorMessage = '운영 기록을 불러오지 못했습니다.';
        notifyListeners();
      },
    );
    _peopleSubscription = peopleRepository
        .watchPeople(includeArchived: true)
        .listen(
          (value) {
            _people = value;
            notifyListeners();
          },
          onError: (_) {
            _errorMessage = '운영 기록을 불러오지 못했습니다.';
            notifyListeners();
          },
        );
  }

  void updateFilter(StudySessionFilter value) {
    _filter = value;
    notifyListeners();
  }

  void clearFilters() {
    _filter = const StudySessionFilter();
    notifyListeners();
  }

  Future<bool> selectSession(String sessionId) async {
    final result = await repository.loadSession(sessionId);
    if (result.isFailure) {
      _errorMessage = result.error!.safeMessage;
      notifyListeners();
      return false;
    }
    _selectedRecord = result.value;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  void selectSaved(StudySessionRecord record) {
    final summary = StudySessionSummary(
      session: record.session,
      participantIds: record.participants
          .map((participant) => participant.personId)
          .toSet(),
      attendanceStates: record.participants
          .map((participant) => participant.attendance)
          .toSet(),
      materialCount: record.materialIds.length,
    );
    _sessions = [
      summary,
      ..._sessions.where((item) => item.session.id != record.session.id),
    ];
    _selectedRecord = record;
    _errorMessage = null;
    notifyListeners();
  }

  void selectSavedMaterial(StudyMaterial material) {
    _materials = [
      material,
      ..._materials.where((item) => item.id != material.id),
    ];
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_sessionSubscription?.cancel());
    unawaited(_materialSubscription?.cancel());
    unawaited(_peopleSubscription?.cancel());
    super.dispose();
  }
}

DateTime _startOfDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);
DateTime _endOfDay(DateTime value) =>
    DateTime(value.year, value.month, value.day, 23, 59, 59, 999, 999);
