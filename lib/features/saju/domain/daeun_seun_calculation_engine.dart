import 'daeun_seun_models.dart';
import 'daeun_seun_policy.dart';
import 'saju_models.dart';
import 'saju_policy.dart';
import 'saju_snapshot.dart';
import 'sexagenary_cycle.dart';
import 'solar_term_calculator.dart';
import 'ten_gods.dart';

final class DaeunSeunCalculationEngine {
  DaeunSeunCalculationEngine._(
    this._solarTermCalculator,
    this._sexagenaryCalculator,
  );

  factory DaeunSeunCalculationEngine.production() =>
      DaeunSeunCalculationEngine._(
        RynSolarTermCalculator.production(),
        SexagenaryCalculator(),
      );

  static const _monthlyJie = <SajuSolarTerm>[
    SajuSolarTerm.sohan,
    SajuSolarTerm.ipchun,
    SajuSolarTerm.gyeongchip,
    SajuSolarTerm.cheongmyeong,
    SajuSolarTerm.ipha,
    SajuSolarTerm.mangjong,
    SajuSolarTerm.soseo,
    SajuSolarTerm.ipchu,
    SajuSolarTerm.baengno,
    SajuSolarTerm.hanno,
    SajuSolarTerm.ipdong,
    SajuSolarTerm.daeseol,
  ];

  final RynSolarTermCalculator _solarTermCalculator;
  final SexagenaryCalculator _sexagenaryCalculator;

  DaeunCalculationResult calculateDaeun(SajuChartSnapshot snapshot) {
    _validateSnapshot(snapshot);
    final direction = _directionFor(snapshot);
    final terms = _termWindow(snapshot.convertedSolarDate.year);

    if (!snapshot.hourUnknown) {
      final birthUtc = snapshot.birthUtcInstant;
      if (birthUtc == null || snapshot.inputLocalTime == null) {
        throw const DaeunSeunCalculationException(
          code: DaeunSeunErrorCode.invalidSnapshot,
          userMessage: '출생시각 snapshot provenance가 일치하지 않습니다.',
        );
      }
      final measurement = _measure(birthUtc.toUtc(), direction, terms);
      return _result(
        snapshot: snapshot,
        direction: direction,
        daeunNumber: measurement.daeunNumber,
        selectedJieUtc: measurement.selectedJieUtc,
        exactIntervalMicroseconds: measurement.intervalMicroseconds,
        minimumIntervalMicroseconds: measurement.intervalMicroseconds,
        maximumIntervalMicroseconds: measurement.intervalMicroseconds,
        evaluatedMinuteCandidates: 1,
        warnings: const [],
      );
    }

    if (snapshot.birthUtcInstant != null ||
        snapshot.inputLocalTime != null ||
        snapshot.hourPillar != null) {
      throw const DaeunSeunCalculationException(
        code: DaeunSeunErrorCode.invalidSnapshot,
        userMessage: '시간 미상 snapshot provenance가 일치하지 않습니다.',
      );
    }

    final values = <int>{};
    final selectedTerms = <int, DateTime>{};
    var minimumInterval = 1 << 62;
    var maximumInterval = 0;
    for (var minuteOfDay = 0; minuteOfDay < 1440; minuteOfDay++) {
      final birthUtc = CheonEulGwiInModernKstPolicy.utcFromLocal(
        snapshot.convertedSolarDate,
        SajuLocalTime(minuteOfDay ~/ 60, minuteOfDay % 60),
      );
      final measurement = _measure(birthUtc, direction, terms);
      values.add(measurement.daeunNumber);
      selectedTerms[measurement.selectedJieUtc.microsecondsSinceEpoch] =
          measurement.selectedJieUtc;
      if (measurement.intervalMicroseconds < minimumInterval) {
        minimumInterval = measurement.intervalMicroseconds;
      }
      if (measurement.intervalMicroseconds > maximumInterval) {
        maximumInterval = measurement.intervalMicroseconds;
      }
    }
    if (values.length != 1 || selectedTerms.length != 1) {
      throw DaeunSeunCalculationException(
        code: DaeunSeunErrorCode.unknownTimeAmbiguous,
        userMessage: '출생시간에 따라 대운수가 달라져 시간을 확인해야 합니다.',
        detail:
            'daeunNumbers=${values.toList()..sort()}, '
            'jieCount=${selectedTerms.length}',
      );
    }

    return _result(
      snapshot: snapshot,
      direction: direction,
      daeunNumber: values.single,
      selectedJieUtc: selectedTerms.values.single,
      exactIntervalMicroseconds: null,
      minimumIntervalMicroseconds: minimumInterval,
      maximumIntervalMicroseconds: maximumInterval,
      evaluatedMinuteCandidates: 1440,
      warnings: const [DaeunSeunWarningCode.unknownTimeStableCivilDay],
    );
  }

  SeunAnnualEntry seunForYear(
    SajuChartSnapshot snapshot,
    int gregorianYear, {
    DaeunCycle? selectedDaeun,
  }) {
    _validateBaseProvenance(snapshot);
    if (gregorianYear < CheonEulGwiInV520DaeunSeunPolicy.minimumSeunYear ||
        gregorianYear > CheonEulGwiInV520DaeunSeunPolicy.maximumSeunYear) {
      throw DaeunSeunCalculationException(
        code: DaeunSeunErrorCode.unsupportedSeunYear,
        userMessage: '세운 연도는 1990년부터 2159년까지 지원합니다.',
        detail: '$gregorianYear',
      );
    }
    final pillar = _sexagenaryCalculator.yearPillar(gregorianYear);
    return SeunAnnualEntry(
      gregorianYear: gregorianYear,
      pillar: pillar,
      heavenlyStemTenGod: SajuTenGodCalculator.calculate(
        dayStemIndex: snapshot.dayPillar.stemIndex,
        targetStemIndex: pillar.stemIndex,
      ),
      earthlyBranchMainQiTenGod: SajuTenGodCalculator.forBranchMainQi(
        dayStemIndex: snapshot.dayPillar.stemIndex,
        branchIndex: pillar.branchIndex,
      ),
      stemFiveElement: SajuStemNature.elementForStem(pillar.stemIndex),
      branchFiveElement: _branchElement(pillar.branchIndex),
      metadata: _metadata(snapshot),
    );
  }

  static int daeunNumberFromInterval(Duration interval) {
    if (interval.isNegative) {
      throw const DaeunSeunCalculationException(
        code: DaeunSeunErrorCode.invalidInterval,
        userMessage: '대운 계산 간격은 음수가 될 수 없습니다.',
      );
    }
    final rawYears =
        interval.inMicroseconds / (3 * Duration.microsecondsPerDay);
    final nearest = rawYears.round();
    return nearest < 1 ? 1 : nearest;
  }

  DaeunCalculationResult _result({
    required SajuChartSnapshot snapshot,
    required DaeunDirection direction,
    required int daeunNumber,
    required DateTime selectedJieUtc,
    required int? exactIntervalMicroseconds,
    required int minimumIntervalMicroseconds,
    required int maximumIntervalMicroseconds,
    required int evaluatedMinuteCandidates,
    required List<DaeunSeunWarningCode> warnings,
  }) {
    final firstStartYear = snapshot.convertedSolarDate.year + daeunNumber - 1;
    final directionSign = direction == DaeunDirection.forward ? 1 : -1;
    final cycles = <DaeunCycle>[
      for (
        var sequence = 1;
        sequence <= CheonEulGwiInV520DaeunSeunPolicy.daeunCycleCount;
        sequence++
      )
        _cycle(
          snapshot: snapshot,
          sequence: sequence,
          pillar: SexagenaryRegistry.byIndex(
            snapshot.monthPillar.cycleIndex + directionSign * sequence,
          ),
          daeunNumber: daeunNumber,
          firstStartYear: firstStartYear,
        ),
    ];
    return DaeunCalculationResult(
      direction: direction,
      daeunNumber: daeunNumber,
      firstStartTraditionalAge: daeunNumber,
      firstStartYear: firstStartYear,
      selectedJieUtc: selectedJieUtc,
      intervalMicroseconds: exactIntervalMicroseconds,
      minimumIntervalMicroseconds: minimumIntervalMicroseconds,
      maximumIntervalMicroseconds: maximumIntervalMicroseconds,
      cycles: cycles,
      warnings: warnings,
      metadata: _metadata(snapshot),
      sourceSnapshotReference: snapshot.deterministicSignature,
      evaluatedMinuteCandidates: evaluatedMinuteCandidates,
    );
  }

  DaeunCycle _cycle({
    required SajuChartSnapshot snapshot,
    required int sequence,
    required SexagenaryEntry pillar,
    required int daeunNumber,
    required int firstStartYear,
  }) {
    final offsetYears =
        (sequence - 1) * CheonEulGwiInV520DaeunSeunPolicy.daeunCycleYears;
    final startYear = firstStartYear + offsetYears;
    return DaeunCycle(
      sequence: sequence,
      pillar: pillar,
      startTraditionalAge: daeunNumber + offsetYears,
      startYear: startYear,
      endYearExclusive:
          startYear + CheonEulGwiInV520DaeunSeunPolicy.daeunCycleYears,
      heavenlyStemTenGod: SajuTenGodCalculator.calculate(
        dayStemIndex: snapshot.dayPillar.stemIndex,
        targetStemIndex: pillar.stemIndex,
      ),
      earthlyBranchMainQiTenGod: SajuTenGodCalculator.forBranchMainQi(
        dayStemIndex: snapshot.dayPillar.stemIndex,
        branchIndex: pillar.branchIndex,
      ),
      stemFiveElement: SajuStemNature.elementForStem(pillar.stemIndex),
      branchFiveElement: _branchElement(pillar.branchIndex),
    );
  }

  DaeunDirection _directionFor(SajuChartSnapshot snapshot) {
    if (snapshot.gender == SajuGender.unspecified) {
      throw const DaeunSeunCalculationException(
        code: DaeunSeunErrorCode.genderRequired,
        userMessage: '대운 방향 계산에는 성별이 필요합니다.',
      );
    }
    final yearStemIsYang = SajuStemNature.isYang(snapshot.yearPillar.stemIndex);
    final isMale = snapshot.gender == SajuGender.male;
    return yearStemIsYang == isMale
        ? DaeunDirection.forward
        : DaeunDirection.reverse;
  }

  _DaeunMeasurement _measure(
    DateTime birthUtc,
    DaeunDirection direction,
    List<_JieInstant> terms,
  ) {
    DateTime? selected;
    if (direction == DaeunDirection.forward) {
      for (final term in terms) {
        if (term.instant.isAfter(birthUtc)) {
          selected = term.instant;
          break;
        }
      }
    } else {
      for (final term in terms) {
        if (!term.instant.isAfter(birthUtc)) selected = term.instant;
      }
    }
    if (selected == null) {
      throw const DaeunSeunCalculationException(
        code: DaeunSeunErrorCode.unsupportedForecastHorizon,
        userMessage: '지원 범위 밖의 월절입이 필요해 대운 계산을 중단했습니다.',
      );
    }
    final interval = direction == DaeunDirection.forward
        ? selected.difference(birthUtc)
        : birthUtc.difference(selected);
    if (interval.isNegative) {
      throw const DaeunSeunCalculationException(
        code: DaeunSeunErrorCode.invalidInterval,
        userMessage: '월절입 간격이 음수여서 계산을 중단했습니다.',
      );
    }
    return _DaeunMeasurement(
      selectedJieUtc: selected,
      intervalMicroseconds: interval.inMicroseconds,
      daeunNumber: daeunNumberFromInterval(interval),
    );
  }

  List<_JieInstant> _termWindow(int birthYear) {
    final firstYear = birthYear > 1989 ? birthYear - 1 : 1989;
    final lastYear = birthYear < 2050 ? birthYear + 1 : 2050;
    final terms = <_JieInstant>[
      for (var year = firstYear; year <= lastYear; year++)
        for (final term in _monthlyJie)
          _JieInstant(_solarTermCalculator.utcInstant(year, term)),
    ]..sort((left, right) => left.instant.compareTo(right.instant));
    return List.unmodifiable(terms);
  }

  void _validateSnapshot(SajuChartSnapshot snapshot) {
    _validateBaseProvenance(snapshot);
    final date = snapshot.convertedSolarDate;
    if (!date.isValid ||
        date.year < CheonEulGwiInV520DaeunSeunPolicy.minimumBirthYear ||
        date.year > CheonEulGwiInV520DaeunSeunPolicy.maximumBirthYear) {
      throw const DaeunSeunCalculationException(
        code: DaeunSeunErrorCode.unsupportedForecastHorizon,
        userMessage: '대운 출생일은 1990년부터 2050년까지 지원합니다.',
      );
    }
  }

  void _validateBaseProvenance(SajuChartSnapshot snapshot) {
    if (snapshot.timezoneId != CheonEulGwiInModernKstPolicy.timezoneId ||
        snapshot.yajaEnabled ||
        snapshot.birthPlaceProfile !=
            CheonEulGwiInModernKstPolicy.birthPlaceProfile) {
      throw const DaeunSeunCalculationException(
        code: DaeunSeunErrorCode.invalidSnapshot,
        userMessage: 'Modern KST·서울 호환·야자시 OFF snapshot이 필요합니다.',
      );
    }
  }

  SajuFiveElement _branchElement(int branchIndex) =>
      SajuStemNature.elementForStem(
        SajuBranchMainQiRegistry.stemForBranch(branchIndex).index,
      );

  DaeunSeunMetadata _metadata(
    SajuChartSnapshot snapshot,
  ) => baseMetadataFromSnapshot(
    snapshot,
    engineId: CheonEulGwiInV520DaeunSeunPolicy.engineId,
    engineVersion: CheonEulGwiInV520DaeunSeunPolicy.engineVersion,
    policyId: CheonEulGwiInV520DaeunSeunPolicy.policyId,
    policyVersion: CheonEulGwiInV520DaeunSeunPolicy.policyVersion,
    referenceProductId: CheonEulGwiInV520DaeunSeunPolicy.referenceProductId,
    referenceVersion: CheonEulGwiInV520DaeunSeunPolicy.referenceVersion,
    fixtureSet: CheonEulGwiInV520DaeunSeunPolicy.fixtureSet,
    directionRuleVersion: CheonEulGwiInV520DaeunSeunPolicy.directionRuleVersion,
    termSelectionVersion: CheonEulGwiInV520DaeunSeunPolicy.termSelectionVersion,
    daeunNumberVersion: CheonEulGwiInV520DaeunSeunPolicy.daeunNumberVersion,
    firstCycleVersion: CheonEulGwiInV520DaeunSeunPolicy.firstCycleVersion,
    cycleSequenceVersion: CheonEulGwiInV520DaeunSeunPolicy.cycleSequenceVersion,
    ageModeVersion: CheonEulGwiInV520DaeunSeunPolicy.ageModeVersion,
    unknownTimeVersion: CheonEulGwiInV520DaeunSeunPolicy.unknownTimeVersion,
    seunVersion: CheonEulGwiInV520DaeunSeunPolicy.seunVersion,
    seunBoundaryVersion: CheonEulGwiInV520DaeunSeunPolicy.seunBoundaryVersion,
    tenGodVersion: CheonEulGwiInV520DaeunSeunPolicy.tenGodVersion,
  );
}

final class _JieInstant {
  const _JieInstant(this.instant);

  final DateTime instant;
}

final class _DaeunMeasurement {
  const _DaeunMeasurement({
    required this.selectedJieUtc,
    required this.intervalMicroseconds,
    required this.daeunNumber,
  });

  final DateTime selectedJieUtc;
  final int intervalMicroseconds;
  final int daeunNumber;
}
