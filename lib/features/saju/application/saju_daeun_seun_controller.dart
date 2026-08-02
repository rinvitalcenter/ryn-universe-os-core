import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/daeun_seun_calculation_engine.dart';
import '../domain/daeun_seun_models.dart';
import '../domain/daeun_seun_policy.dart';
import '../domain/saju_snapshot_repository.dart';

// Presentation state only. Nothing in this file is persisted.
enum SajuDaeunSeunSourceType { unsavedNatalResult, persistedNatalSnapshot }

enum SajuDerivedPhase { idle, calculating, ready, error }

enum SajuWorkspaceTab { natal, daeun, seun }

typedef DaeunCalculationExecutor =
    FutureOr<DaeunCalculationResult> Function(SajuChartSnapshot snapshot);
typedef SeunCalculationExecutor =
    FutureOr<SeunAnnualEntry> Function(
      SajuChartSnapshot snapshot,
      int gregorianYear, {
      DaeunCycle? selectedDaeun,
    });

@immutable
final class SajuDaeunSeunSourceProvenance {
  const SajuDaeunSeunSourceProvenance({
    required this.sourceType,
    required this.personId,
    required this.natalCalculationGeneration,
    required this.snapshotId,
    required this.chartGroupId,
    required this.revisionNumber,
    required this.sourceBirthProfileId,
    required this.provenanceSignature,
    required this.sourceCalculatedAt,
    required this.sourceEngineId,
    required this.sourceEngineVersion,
    required this.sourcePolicyId,
    required this.sourcePolicyVersion,
    required this.timezoneId,
    required this.birthPlaceProfile,
    required this.yajaEnabled,
    required this.solarTermAlgorithmVersion,
    required this.timeScaleAdapterVersion,
  });

  final SajuDaeunSeunSourceType sourceType;
  final String personId;
  final int? natalCalculationGeneration;
  final String? snapshotId;
  final String? chartGroupId;
  final int? revisionNumber;
  final String? sourceBirthProfileId;
  final String provenanceSignature;
  final DateTime sourceCalculatedAt;
  final String sourceEngineId;
  final String sourceEngineVersion;
  final String sourcePolicyId;
  final String sourcePolicyVersion;
  final String timezoneId;
  final String birthPlaceProfile;
  final bool yajaEnabled;
  final String solarTermAlgorithmVersion;
  final String timeScaleAdapterVersion;

  String get sourceLabel => switch (sourceType) {
    SajuDaeunSeunSourceType.unsavedNatalResult => '저장 전 원국',
    SajuDaeunSeunSourceType.persistedNatalSnapshot =>
      'Revision $revisionNumber',
  };
}

final class SajuDaeunSeunController extends ChangeNotifier {
  factory SajuDaeunSeunController({
    DaeunSeunCalculationEngine? calculationEngine,
    DaeunCalculationExecutor? daeunExecutor,
    SeunCalculationExecutor? seunExecutor,
    DateTime Function()? now,
  }) {
    final engine = calculationEngine ?? DaeunSeunCalculationEngine.production();
    return SajuDaeunSeunController._(
      daeunExecutor ?? engine.calculateDaeun,
      seunExecutor ?? engine.seunForYear,
      now ?? DateTime.now,
    );
  }

  SajuDaeunSeunController._(this._daeunExecutor, this._seunExecutor, this._now);

  final DaeunCalculationExecutor _daeunExecutor;
  final SeunCalculationExecutor _seunExecutor;
  final DateTime Function() _now;

  SajuDaeunSeunSourceType? _sourceType;
  SajuChartSnapshot? _sourceSnapshot;
  SajuDaeunSeunSourceProvenance? _sourceProvenance;
  String? _sourceDeduplicationKey;
  String? _compatiblePreviousSourceKey;
  SajuDerivedPhase _daeunPhase = SajuDerivedPhase.idle;
  DaeunCalculationResult? _daeunResult;
  String? _daeunWarning;
  String? _daeunError;
  int? _selectedDaeunSequence;
  SajuDerivedPhase _seunPhase = SajuDerivedPhase.idle;
  List<SeunAnnualEntry> _seunEntries = const [];
  String? _seunWarning;
  String? _seunError;
  int? _selectedSeunYear;
  SajuWorkspaceTab _currentTab = SajuWorkspaceTab.natal;
  DateTime? _derivedCalculatedAt;
  int _sourceSerial = 0;
  int _seunRequestSerial = 0;
  bool _disposed = false;

  SajuDaeunSeunSourceType? get sourceType => _sourceType;
  SajuChartSnapshot? get sourceSnapshot => _sourceSnapshot;
  SajuDaeunSeunSourceProvenance? get sourceProvenance => _sourceProvenance;
  String? get sourceDeduplicationKey => _sourceDeduplicationKey;
  SajuDerivedPhase get daeunPhase => _daeunPhase;
  DaeunCalculationResult? get daeunResult => _daeunResult;
  String? get daeunWarning => _daeunWarning;
  String? get daeunError => _daeunError;
  int? get selectedDaeunSequence => _selectedDaeunSequence;
  DaeunCycle? get selectedDaeunCycle {
    final sequence = _selectedDaeunSequence;
    if (sequence == null) return null;
    for (final cycle in _daeunResult?.cycles ?? const <DaeunCycle>[]) {
      if (cycle.sequence == sequence) return cycle;
    }
    return null;
  }

  SajuDerivedPhase get seunPhase => _seunPhase;
  List<SeunAnnualEntry> get seunEntries => List.unmodifiable(_seunEntries);
  String? get seunWarning => _seunWarning;
  String? get seunError => _seunError;
  int? get selectedSeunYear => _selectedSeunYear;
  SeunAnnualEntry? get selectedSeunEntry {
    final year = _selectedSeunYear;
    if (year == null) return null;
    for (final entry in _seunEntries) {
      if (entry.gregorianYear == year) return entry;
    }
    return null;
  }

  SajuWorkspaceTab get currentTab => _currentTab;
  DateTime? get derivedCalculatedAt => _derivedCalculatedAt;
  int get currentGregorianYear => _now().year;
  bool get isCalculatingDaeun => _daeunPhase == SajuDerivedPhase.calculating;
  bool get isGeneratingSeun => _seunPhase == SajuDerivedPhase.calculating;
  bool get hasSource => _sourceSnapshot != null;

  Future<void> loadUnsavedSource({
    required String personId,
    required int natalCalculationGeneration,
    required SajuChartSnapshot snapshot,
  }) {
    final provenance = _unsavedProvenance(
      personId: personId,
      generation: natalCalculationGeneration,
      snapshot: snapshot,
    );
    final key = [
      provenance.sourceType.name,
      personId,
      natalCalculationGeneration,
      snapshot.calculatedAt.toUtc().microsecondsSinceEpoch,
      snapshot.deterministicSignature,
    ].join('|');
    return _loadSource(snapshot: snapshot, provenance: provenance, key: key);
  }

  Future<void> loadPersistedSource(SajuPersistedSnapshot persisted) {
    final provenance = _persistedProvenance(persisted);
    final key = [
      provenance.sourceType.name,
      persisted.personId,
      persisted.id,
      persisted.chartGroupId,
      persisted.revisionNumber,
      persisted.calculationSignatureSha256,
    ].join('|');
    return _loadSource(
      snapshot: persisted.snapshot,
      provenance: provenance,
      key: key,
    );
  }

  Future<void> promoteToPersistedSource(SajuPersistedSnapshot persisted) async {
    final current = _sourceSnapshot;
    final currentProvenance = _sourceProvenance;
    if (current != null &&
        currentProvenance != null &&
        _sourceType == SajuDaeunSeunSourceType.unsavedNatalResult &&
        currentProvenance.personId == persisted.personId &&
        current.deterministicSignature ==
            persisted.snapshot.deterministicSignature) {
      final provenance = _persistedProvenance(persisted);
      _compatiblePreviousSourceKey = _sourceDeduplicationKey;
      _sourceType = provenance.sourceType;
      _sourceSnapshot = persisted.snapshot;
      _sourceProvenance = provenance;
      _sourceDeduplicationKey = [
        provenance.sourceType.name,
        persisted.personId,
        persisted.id,
        persisted.chartGroupId,
        persisted.revisionNumber,
        persisted.calculationSignatureSha256,
      ].join('|');
      _notify();
      return;
    }
    await loadPersistedSource(persisted);
  }

  Future<void> _loadSource({
    required SajuChartSnapshot snapshot,
    required SajuDaeunSeunSourceProvenance provenance,
    required String key,
  }) async {
    if (_sourceDeduplicationKey == key) return;
    _sourceSerial += 1;
    _compatiblePreviousSourceKey = null;
    _sourceType = provenance.sourceType;
    _sourceSnapshot = snapshot;
    _sourceProvenance = provenance;
    _sourceDeduplicationKey = key;
    resetDerivedState(notify: false);
    if (!_hasValidSourceProvenance()) {
      const message = '선택한 명식의 계산 정보를 확인할 수 없습니다. 원국을 다시 선택해 주세요.';
      _daeunPhase = SajuDerivedPhase.error;
      _seunPhase = SajuDerivedPhase.error;
      _daeunError = message;
      _seunError = message;
      _notify();
      return;
    }
    _notify();
    await calculateDaeun();
  }

  Future<void> calculateDaeun() async {
    final snapshot = _sourceSnapshot;
    final sourceKey = _sourceDeduplicationKey;
    if (snapshot == null ||
        sourceKey == null ||
        _daeunPhase == SajuDerivedPhase.calculating ||
        (_daeunPhase == SajuDerivedPhase.ready && _daeunResult != null)) {
      return;
    }
    final serial = _sourceSerial;
    _daeunPhase = SajuDerivedPhase.calculating;
    _daeunError = null;
    _daeunWarning = null;
    _notify();
    try {
      final result = await Future<DaeunCalculationResult>.sync(
        () => _daeunExecutor(snapshot),
      );
      if (!_isCurrent(serial, sourceKey)) return;
      _daeunResult = result;
      _daeunPhase = SajuDerivedPhase.ready;
      _selectedDaeunSequence = result.cycles.firstOrNull?.sequence;
      _daeunWarning =
          result.warnings.contains(
            DaeunSeunWarningCode.unknownTimeStableCivilDay,
          )
          ? '출생시간이 없지만 해당 날짜의 분 단위 후보에서 대운수가 동일하게 계산되어 결과를 표시합니다.'
          : null;
      _derivedCalculatedAt = _now().toUtc();
      _notify();
      await generateSeunYears(
        startYear:
            selectedDaeunCycle?.startYear ?? snapshot.convertedSolarDate.year,
      );
    } on DaeunSeunCalculationException catch (error) {
      if (!_isCurrent(serial, sourceKey)) return;
      _daeunResult = null;
      _selectedDaeunSequence = null;
      _daeunPhase = SajuDerivedPhase.error;
      _daeunError = _safeDaeunMessage(error.code);
      _notify();
      await generateSeunYears(startYear: snapshot.convertedSolarDate.year);
    } catch (_) {
      if (!_isCurrent(serial, sourceKey)) return;
      _daeunResult = null;
      _selectedDaeunSequence = null;
      _daeunPhase = SajuDerivedPhase.error;
      _daeunError = '대운을 계산하지 못했습니다. 원국 정보를 다시 확인해 주세요.';
      _notify();
      await generateSeunYears(startYear: snapshot.convertedSolarDate.year);
    }
  }

  Future<void> generateSeunYears({int? startYear}) async {
    final snapshot = _sourceSnapshot;
    final sourceKey = _sourceDeduplicationKey;
    if (snapshot == null || sourceKey == null) return;
    final serial = _sourceSerial;
    final requestSerial = ++_seunRequestSerial;
    final firstYear =
        startYear ??
        selectedDaeunCycle?.startYear ??
        snapshot.convertedSolarDate.year;
    final lastYear = firstYear + 9;
    if (firstYear < CheonEulGwiInV520DaeunSeunPolicy.minimumSeunYear ||
        lastYear > CheonEulGwiInV520DaeunSeunPolicy.maximumSeunYear) {
      _seunEntries = const [];
      _selectedSeunYear = null;
      _seunPhase = SajuDerivedPhase.error;
      _seunError = '세운 연도는 1990년부터 2159년까지 지원합니다.';
      _notify();
      return;
    }
    _seunPhase = SajuDerivedPhase.calculating;
    _seunError = null;
    _seunWarning = null;
    _notify();
    try {
      final entries = <SeunAnnualEntry>[];
      for (var year = firstYear; year <= lastYear; year++) {
        entries.add(
          await Future<SeunAnnualEntry>.sync(
            () => _seunExecutor(
              snapshot,
              year,
              selectedDaeun: selectedDaeunCycle,
            ),
          ),
        );
      }
      if (!_isCurrentSeun(serial, requestSerial, sourceKey)) return;
      _seunEntries = List.unmodifiable(entries);
      _selectedSeunYear =
          entries.any((entry) => entry.gregorianYear == _selectedSeunYear)
          ? _selectedSeunYear
          : entries.first.gregorianYear;
      _seunPhase = SajuDerivedPhase.ready;
      _seunWarning = '세운은 연도별 간지 라벨이며 특정 날짜의 활성 여부를 판정하지 않습니다.';
      _notify();
    } on DaeunSeunCalculationException catch (error) {
      if (!_isCurrentSeun(serial, requestSerial, sourceKey)) return;
      _seunEntries = const [];
      _selectedSeunYear = null;
      _seunPhase = SajuDerivedPhase.error;
      _seunError = _safeSeunMessage(error.code);
      _notify();
    } catch (_) {
      if (!_isCurrentSeun(serial, requestSerial, sourceKey)) return;
      _seunEntries = const [];
      _selectedSeunYear = null;
      _seunPhase = SajuDerivedPhase.error;
      _seunError = '세운 연도 라벨을 준비하지 못했습니다. 원국 정보를 다시 확인해 주세요.';
      _notify();
    }
  }

  Future<void> selectDaeunCycle(int sequence) async {
    final cycles = _daeunResult?.cycles ?? const <DaeunCycle>[];
    DaeunCycle? selected;
    for (final cycle in cycles) {
      if (cycle.sequence == sequence) {
        selected = cycle;
        break;
      }
    }
    if (selected == null || _selectedDaeunSequence == sequence) return;
    _selectedDaeunSequence = sequence;
    _selectedSeunYear = null;
    _notify();
    await generateSeunYears(startYear: selected.startYear);
  }

  void selectSeunYear(int year) {
    if (_selectedSeunYear == year ||
        !_seunEntries.any((entry) => entry.gregorianYear == year)) {
      return;
    }
    _selectedSeunYear = year;
    _notify();
  }

  void selectTab(SajuWorkspaceTab tab) {
    if (_currentTab == tab) return;
    _currentTab = tab;
    _notify();
  }

  void clearSource() {
    _sourceSerial += 1;
    _sourceType = null;
    _sourceSnapshot = null;
    _sourceProvenance = null;
    _sourceDeduplicationKey = null;
    _compatiblePreviousSourceKey = null;
    resetDerivedState(notify: false);
    _notify();
  }

  void resetDerivedState({bool notify = true}) {
    _daeunPhase = SajuDerivedPhase.idle;
    _daeunResult = null;
    _daeunWarning = null;
    _daeunError = null;
    _selectedDaeunSequence = null;
    _seunPhase = SajuDerivedPhase.idle;
    _seunEntries = const [];
    _seunWarning = null;
    _seunError = null;
    _selectedSeunYear = null;
    _derivedCalculatedAt = null;
    if (notify) _notify();
  }

  bool _hasValidSourceProvenance() {
    final provenance = _sourceProvenance;
    final snapshot = _sourceSnapshot;
    if (provenance == null ||
        snapshot == null ||
        provenance.personId.trim().isEmpty ||
        provenance.provenanceSignature.trim().isEmpty) {
      return false;
    }
    if (provenance.sourceType == SajuDaeunSeunSourceType.unsavedNatalResult) {
      return provenance.natalCalculationGeneration != null &&
          provenance.snapshotId == null &&
          provenance.chartGroupId == null &&
          provenance.revisionNumber == null;
    }
    return provenance.natalCalculationGeneration == null &&
        (provenance.snapshotId?.isNotEmpty ?? false) &&
        (provenance.chartGroupId?.isNotEmpty ?? false) &&
        (provenance.revisionNumber ?? 0) > 0;
  }

  bool _isCurrent(int serial, String key) =>
      !_disposed &&
      serial == _sourceSerial &&
      (key == _sourceDeduplicationKey || key == _compatiblePreviousSourceKey);

  bool _isCurrentSeun(int sourceSerial, int requestSerial, String key) =>
      _isCurrent(sourceSerial, key) && requestSerial == _seunRequestSerial;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  SajuDaeunSeunSourceProvenance _unsavedProvenance({
    required String personId,
    required int generation,
    required SajuChartSnapshot snapshot,
  }) => _baseProvenance(
    sourceType: SajuDaeunSeunSourceType.unsavedNatalResult,
    personId: personId,
    generation: generation,
    snapshot: snapshot,
    snapshotId: null,
    chartGroupId: null,
    revisionNumber: null,
    sourceBirthProfileId: null,
    provenanceSignature: snapshot.deterministicSignature,
  );

  SajuDaeunSeunSourceProvenance _persistedProvenance(
    SajuPersistedSnapshot persisted,
  ) => _baseProvenance(
    sourceType: SajuDaeunSeunSourceType.persistedNatalSnapshot,
    personId: persisted.personId,
    generation: null,
    snapshot: persisted.snapshot,
    snapshotId: persisted.id,
    chartGroupId: persisted.chartGroupId,
    revisionNumber: persisted.revisionNumber,
    sourceBirthProfileId: persisted.sourceBirthProfileId,
    provenanceSignature: persisted.calculationSignatureSha256,
  );

  SajuDaeunSeunSourceProvenance _baseProvenance({
    required SajuDaeunSeunSourceType sourceType,
    required String personId,
    required int? generation,
    required SajuChartSnapshot snapshot,
    required String? snapshotId,
    required String? chartGroupId,
    required int? revisionNumber,
    required String? sourceBirthProfileId,
    required String provenanceSignature,
  }) => SajuDaeunSeunSourceProvenance(
    sourceType: sourceType,
    personId: personId,
    natalCalculationGeneration: generation,
    snapshotId: snapshotId,
    chartGroupId: chartGroupId,
    revisionNumber: revisionNumber,
    sourceBirthProfileId: sourceBirthProfileId,
    provenanceSignature: provenanceSignature,
    sourceCalculatedAt: snapshot.calculatedAt,
    sourceEngineId: snapshot.engineId,
    sourceEngineVersion: snapshot.engineVersion,
    sourcePolicyId: snapshot.policyId,
    sourcePolicyVersion: snapshot.policyVersion,
    timezoneId: snapshot.timezoneId,
    birthPlaceProfile: snapshot.birthPlaceProfile,
    yajaEnabled: snapshot.yajaEnabled,
    solarTermAlgorithmVersion: snapshot.solarTermAlgorithmVersion,
    timeScaleAdapterVersion: snapshot.timeScaleAdapterVersion,
  );

  @override
  void dispose() {
    _disposed = true;
    _sourceSerial += 1;
    super.dispose();
  }
}

String _safeDaeunMessage(DaeunSeunErrorCode code) => switch (code) {
  DaeunSeunErrorCode.unknownTimeAmbiguous =>
    '출생시간에 따라 대운수가 달라질 수 있어 현재 대운 결과를 확정할 수 없습니다.',
  DaeunSeunErrorCode.genderRequired => '대운 방향 계산을 위해 원국에서 성별을 선택해 주세요.',
  DaeunSeunErrorCode.unsupportedForecastHorizon =>
    '현재 절입 계산 지원 범위를 넘어 대운수를 계산할 수 없습니다.',
  DaeunSeunErrorCode.invalidSnapshot || DaeunSeunErrorCode.invalidInterval =>
    '선택한 명식의 계산 정보를 확인할 수 없습니다. 원국을 다시 선택해 주세요.',
  DaeunSeunErrorCode.unsupportedSeunYear => '세운 연도는 1990년부터 2159년까지 지원합니다.',
};

String _safeSeunMessage(DaeunSeunErrorCode code) => switch (code) {
  DaeunSeunErrorCode.unsupportedSeunYear => '세운 연도는 1990년부터 2159년까지 지원합니다.',
  DaeunSeunErrorCode.invalidSnapshot || DaeunSeunErrorCode.invalidInterval =>
    '선택한 명식의 계산 정보를 확인할 수 없습니다. 원국을 다시 선택해 주세요.',
  DaeunSeunErrorCode.genderRequired ||
  DaeunSeunErrorCode.unknownTimeAmbiguous ||
  DaeunSeunErrorCode.unsupportedForecastHorizon =>
    '세운 연도 라벨을 준비하지 못했습니다. 원국 정보를 다시 확인해 주세요.',
};
