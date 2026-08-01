// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../people/domain/person_core_models.dart';
import '../../people/domain/person_core_repositories.dart';
import '../domain/saju_calculation_engine.dart';
import '../domain/saju_models.dart';
import '../domain/saju_snapshot_repository.dart';

enum SajuMansePhase {
  empty,
  input,
  calculating,
  resultUnsaved,
  saving,
  resultSaved,
  error,
}

typedef SajuCalculationExecutor =
    FutureOr<SajuChartSnapshot> Function(SajuBirthInput input);
typedef SajuManseIdFactory = String Function(String prefix);

@immutable
final class SajuBirthDraft {
  const SajuBirthDraft({
    this.calendarType = SajuCalendarType.solar,
    this.birthDate = const SajuLocalDate(1990, 1, 1),
    this.birthTime = const SajuLocalTime(10, 0),
    this.hourUnknown = false,
    this.lunarLeapMonth = false,
    this.gender = SajuGender.unspecified,
  });

  final SajuCalendarType calendarType;
  final SajuLocalDate birthDate;
  final SajuLocalTime birthTime;
  final bool hourUnknown;
  final bool lunarLeapMonth;
  final SajuGender gender;

  SajuBirthDraft copyWith({
    SajuCalendarType? calendarType,
    SajuLocalDate? birthDate,
    SajuLocalTime? birthTime,
    bool? hourUnknown,
    bool? lunarLeapMonth,
    SajuGender? gender,
  }) => SajuBirthDraft(
    calendarType: calendarType ?? this.calendarType,
    birthDate: birthDate ?? this.birthDate,
    birthTime: birthTime ?? this.birthTime,
    hourUnknown: hourUnknown ?? this.hourUnknown,
    lunarLeapMonth: lunarLeapMonth ?? this.lunarLeapMonth,
    gender: gender ?? this.gender,
  );

  SajuBirthInput toDomainInput() {
    final time = hourUnknown ? null : birthTime;
    return switch (calendarType) {
      SajuCalendarType.solar => SajuBirthInput.solar(
        date: birthDate,
        time: time,
        gender: gender,
      ),
      SajuCalendarType.koreanLunar => SajuBirthInput.koreanLunar(
        date: KoreanLunarDate(
          birthDate.year,
          birthDate.month,
          birthDate.day,
          isLeapMonth: lunarLeapMonth,
        ),
        time: time,
        gender: gender,
      ),
    };
  }
}

final class SajuManseController extends ChangeNotifier {
  SajuManseController({
    required PersonRepository peopleRepository,
    required SajuSnapshotRepository snapshotRepository,
    SajuCalculationEngine? calculationEngine,
    SajuCalculationExecutor? calculationExecutor,
    DateTime Function()? now,
    SajuManseIdFactory? idFactory,
  }) : _peopleRepository = peopleRepository,
       _snapshotRepository = snapshotRepository,
       _calculationExecutor =
           calculationExecutor ??
           (calculationEngine ?? SajuCalculationEngine.production()).calculate,
       _now = now ?? DateTime.now,
       _idFactory = idFactory;

  final PersonRepository _peopleRepository;
  final SajuSnapshotRepository _snapshotRepository;
  final SajuCalculationExecutor _calculationExecutor;
  final DateTime Function() _now;
  final SajuManseIdFactory? _idFactory;

  StreamSubscription<List<Person>>? _peopleSubscription;
  List<Person> _activePeople = const [];
  List<SajuPersistedSnapshot> _savedSnapshots = const [];
  Person? _selectedPerson;
  String? _preferredSelfId;
  SajuBirthDraft _draft = const SajuBirthDraft();
  SajuMansePhase _phase = SajuMansePhase.empty;
  SajuChartSnapshot? _currentCalculatedSnapshot;
  SajuPersistedSnapshot? _currentPersistedSnapshot;
  String? _errorMessage;
  String? _noticeMessage;
  int _loadSerial = 0;
  int _idSerial = 0;
  bool _stopped = false;

  SajuMansePhase get phase => _phase;
  List<Person> get activePeople => List.unmodifiable(_activePeople);
  Person? get selectedPerson => _selectedPerson;
  SajuBirthDraft get draft => _draft;
  SajuChartSnapshot? get currentCalculatedSnapshot =>
      _currentCalculatedSnapshot;
  SajuPersistedSnapshot? get currentPersistedSnapshot =>
      _currentPersistedSnapshot;
  List<SajuPersistedSnapshot> get savedSnapshots =>
      List.unmodifiable(_savedSnapshots);
  String? get errorMessage => _errorMessage;
  String? get noticeMessage => _noticeMessage;
  bool get isBusy =>
      _phase == SajuMansePhase.calculating || _phase == SajuMansePhase.saving;
  bool get canCalculate => _selectedPerson != null && !isBusy;
  bool get canSave =>
      _selectedPerson != null &&
      _currentCalculatedSnapshot != null &&
      _phase == SajuMansePhase.resultUnsaved;
  SajuChartSnapshot? get displayedSnapshot =>
      _currentPersistedSnapshot?.snapshot ?? _currentCalculatedSnapshot;

  void start() {
    if (_peopleSubscription != null) return;
    _stopped = false;
    _peopleSubscription = _peopleRepository
        .watchPeople(includeArchived: false)
        .listen(_acceptPeople, onError: _acceptPeopleFailure);
    unawaited(_resolvePreferredSelf());
  }

  Future<void> _resolvePreferredSelf() async {
    final result = await _peopleRepository.findActiveSelfPerson();
    if (_stopped || result.isFailure) return;
    final self = result.value;
    if (self == null ||
        self.archivedAt != null ||
        self.status != PersonStatuses.active) {
      return;
    }
    _preferredSelfId = self.id;
    final available = _activePeople.where((person) => person.id == self.id);
    if (available.isNotEmpty && _selectedPerson?.id != self.id) {
      await selectPerson(self.id);
    }
  }

  void _acceptPeople(List<Person> people) {
    if (_stopped) return;
    _activePeople = people
        .where(
          (person) =>
              person.status == PersonStatuses.active &&
              person.archivedAt == null,
        )
        .toList(growable: false);
    if (_activePeople.isEmpty) {
      _selectedPerson = null;
      _savedSnapshots = const [];
      _currentCalculatedSnapshot = null;
      _currentPersistedSnapshot = null;
      _phase = SajuMansePhase.empty;
      notifyListeners();
      return;
    }

    final currentId = _selectedPerson?.id;
    final currentStillAvailable =
        currentId != null &&
        _activePeople.any((person) => person.id == currentId);
    final nextId = currentStillAvailable
        ? currentId
        : (_preferredSelfId != null &&
              _activePeople.any((person) => person.id == _preferredSelfId))
        ? _preferredSelfId!
        : _activePeople.first.id;
    if (_selectedPerson?.id == nextId) {
      notifyListeners();
      return;
    }
    unawaited(selectPerson(nextId));
  }

  void _acceptPeopleFailure(Object _) {
    if (_stopped) return;
    _phase = SajuMansePhase.error;
    _errorMessage = '사람 목록을 불러오지 못했습니다. 다시 시도해 주세요.';
    notifyListeners();
  }

  Future<void> selectPerson(String personId) async {
    Person? person;
    for (final candidate in _activePeople) {
      if (candidate.id == personId) {
        person = candidate;
        break;
      }
    }
    if (person == null) return;
    final changed = _selectedPerson?.id != person.id;
    _selectedPerson = person;
    if (changed) {
      _currentCalculatedSnapshot = null;
      _currentPersistedSnapshot = null;
      _savedSnapshots = const [];
      _errorMessage = null;
      _noticeMessage = null;
      _phase = SajuMansePhase.input;
      notifyListeners();
    }
    await loadSnapshotsForPerson(person.id);
  }

  Future<void> loadSnapshotsForPerson(String personId) async {
    final serial = ++_loadSerial;
    final results = await Future.wait<Object>([
      _snapshotRepository.listSnapshotsForPerson(personId),
      _snapshotRepository.getLatestSnapshotForPerson(personId),
    ]);
    if (_stopped || serial != _loadSerial || _selectedPerson?.id != personId) {
      return;
    }
    final listResult =
        results[0] as SajuSnapshotResult<List<SajuPersistedSnapshot>>;
    final latestResult =
        results[1] as SajuSnapshotResult<SajuPersistedSnapshot?>;
    if (!listResult.isSuccess || !latestResult.isSuccess) {
      _phase = SajuMansePhase.error;
      _errorMessage = '저장된 명식을 불러오지 못했습니다. 다시 시도해 주세요.';
      notifyListeners();
      return;
    }
    _savedSnapshots = List.unmodifiable(listResult.value!);
    final latest = latestResult.value;
    if (_currentCalculatedSnapshot == null) {
      _currentPersistedSnapshot = latest;
      _phase = latest == null
          ? SajuMansePhase.input
          : SajuMansePhase.resultSaved;
    }
    notifyListeners();
  }

  void updateCalendarType(SajuCalendarType value) => _updateDraft(
    _draft.copyWith(
      calendarType: value,
      lunarLeapMonth: value == SajuCalendarType.koreanLunar
          ? _draft.lunarLeapMonth
          : false,
    ),
  );

  void updateBirthDate(SajuLocalDate value) =>
      _updateDraft(_draft.copyWith(birthDate: value));

  void updateBirthTime(SajuLocalTime value) =>
      _updateDraft(_draft.copyWith(birthTime: value));

  void setHourUnknown(bool value) =>
      _updateDraft(_draft.copyWith(hourUnknown: value));

  void setLunarLeapMonth(bool value) => _updateDraft(
    _draft.copyWith(
      lunarLeapMonth:
          _draft.calendarType == SajuCalendarType.koreanLunar && value,
    ),
  );

  void updateGender(SajuGender value) =>
      _updateDraft(_draft.copyWith(gender: value));

  void _updateDraft(SajuBirthDraft value) {
    if (isBusy) return;
    _draft = value;
    _currentCalculatedSnapshot = null;
    _currentPersistedSnapshot = null;
    _errorMessage = null;
    _noticeMessage = null;
    _phase = _selectedPerson == null
        ? SajuMansePhase.empty
        : SajuMansePhase.input;
    notifyListeners();
  }

  Future<void> calculate() async {
    if (!canCalculate || _phase == SajuMansePhase.calculating) return;
    if (!_draft.birthDate.isValid) {
      _setCalculationFailure('입력 정보를 다시 확인해 주세요.');
      return;
    }
    if (_draft.calendarType == SajuCalendarType.solar) {
      final date = _draft.birthDate.asUtcDate;
      if (date.isBefore(DateTime.utc(1990, 1, 1)) ||
          date.isAfter(DateTime.utc(2050, 12, 31))) {
        _setCalculationFailure('지원 가능한 날짜 범위를 벗어났습니다.');
        return;
      }
    }

    _phase = SajuMansePhase.calculating;
    _errorMessage = null;
    _noticeMessage = null;
    notifyListeners();
    try {
      final snapshot = await Future<SajuChartSnapshot>.sync(
        () => _calculationExecutor(_draft.toDomainInput()),
      );
      if (_stopped) return;
      _currentCalculatedSnapshot = snapshot;
      _currentPersistedSnapshot = null;
      _phase = SajuMansePhase.resultUnsaved;
      _noticeMessage = snapshot.hourUnknown
          ? '출생시간이 없어 시주를 제외한 세 기둥을 계산했습니다.'
          : null;
      notifyListeners();
    } on SajuCalculationException catch (error) {
      _setCalculationFailure(_messageForCalculationFailure(error.code));
    } catch (_) {
      _setCalculationFailure('명식을 계산하지 못했습니다. 입력 정보를 다시 확인해 주세요.');
    }
  }

  void _setCalculationFailure(String message) {
    if (_stopped) return;
    _currentCalculatedSnapshot = null;
    _currentPersistedSnapshot = null;
    _phase = SajuMansePhase.error;
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> save() async {
    if (!canSave) return;
    final person = _selectedPerson!;
    final snapshot = _currentCalculatedSnapshot!;
    _phase = SajuMansePhase.saving;
    _errorMessage = null;
    _noticeMessage = null;
    notifyListeners();

    final result = await _snapshotRepository.saveInitialSnapshot(
      snapshotId: _nextId('saju-snapshot'),
      personId: person.id,
      chartGroupId: _nextId('saju-chart'),
      snapshot: snapshot,
      createdAtUtcUs: _now().toUtc().microsecondsSinceEpoch,
    );
    if (_stopped || _selectedPerson?.id != person.id) return;
    if (!result.isSuccess) {
      _phase = SajuMansePhase.resultUnsaved;
      _errorMessage = _messageForSnapshotFailure(result.failure!.code);
      notifyListeners();
      return;
    }

    final persisted = result.value!;
    _currentPersistedSnapshot = persisted;
    _phase = SajuMansePhase.resultSaved;
    _noticeMessage = '명식을 안전하게 저장했습니다.';
    _savedSnapshots = [
      persisted,
      for (final item in _savedSnapshots)
        if (item.id != persisted.id) item,
    ];
    notifyListeners();
    await loadSnapshotsForPerson(person.id);
  }

  void selectSavedSnapshot(String snapshotId) {
    for (final persisted in _savedSnapshots) {
      if (persisted.id != snapshotId) continue;
      _currentCalculatedSnapshot = null;
      _currentPersistedSnapshot = persisted;
      _phase = SajuMansePhase.resultSaved;
      _errorMessage = null;
      _noticeMessage = '저장 당시의 명식을 표시하고 있습니다.';
      notifyListeners();
      return;
    }
  }

  void startNewChart() {
    if (isBusy) return;
    _draft = const SajuBirthDraft();
    _currentCalculatedSnapshot = null;
    _currentPersistedSnapshot = null;
    _errorMessage = null;
    _noticeMessage = null;
    _phase = _selectedPerson == null
        ? SajuMansePhase.empty
        : SajuMansePhase.input;
    notifyListeners();
  }

  String _nextId(String prefix) {
    final factory = _idFactory;
    if (factory != null) return factory(prefix);
    _idSerial += 1;
    final micros = _now().toUtc().microsecondsSinceEpoch;
    return '$prefix.$micros.$_idSerial';
  }

  Future<void> stop() async {
    _stopped = true;
    _loadSerial += 1;
    await _peopleSubscription?.cancel();
    _peopleSubscription = null;
  }
}

String _messageForCalculationFailure(SajuErrorCode code) => switch (code) {
  SajuErrorCode.unsupportedRange => '지원 가능한 날짜 범위를 벗어났습니다.',
  SajuErrorCode.unresolvedDayRolloverWindow => '현재 이 시간대의 자정 경계 정책을 확인 중입니다.',
  SajuErrorCode.invalidLunarLeapMonth => '해당 연월에는 선택한 윤달이 존재하지 않습니다.',
  SajuErrorCode.invalidDate ||
  SajuErrorCode.invalidTime ||
  SajuErrorCode.birthTimeRequiredAtSolarTermBoundary => '입력 정보를 다시 확인해 주세요.',
  SajuErrorCode.unsupportedTimezone ||
  SajuErrorCode.unsupportedPolicy => '현재 지원되는 계산 기준을 사용할 수 없습니다.',
};

String _messageForSnapshotFailure(
  SajuSnapshotFailureCode code,
) => switch (code) {
  SajuSnapshotFailureCode.personNotFound ||
  SajuSnapshotFailureCode.birthProfileNotFound ||
  SajuSnapshotFailureCode.birthProfilePersonMismatch => '저장할 회원을 다시 선택해 주세요.',
  SajuSnapshotFailureCode.duplicateSnapshot => '동일한 명식이 이미 저장돼 있습니다.',
  SajuSnapshotFailureCode.invalidSnapshot ||
  SajuSnapshotFailureCode.unsupportedSnapshotVersion => '계산 결과를 다시 확인해 주세요.',
  SajuSnapshotFailureCode.revisionConflict ||
  SajuSnapshotFailureCode.persistenceFailure => '명식을 저장하지 못했습니다. 다시 시도해 주세요.',
};
