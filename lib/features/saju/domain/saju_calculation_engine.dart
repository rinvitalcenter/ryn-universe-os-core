import 'korean_lunar_calendar.dart';
import 'saju_models.dart';
import 'saju_policy.dart';
import 'saju_snapshot.dart';
import 'sexagenary_cycle.dart';
import 'solar_term_calculator.dart';

final class SajuCalculationEngine {
  SajuCalculationEngine._(
    this._solarTermCalculator,
    this._lunarConverter,
    this._sexagenaryCalculator,
    this._utcNow,
  );

  factory SajuCalculationEngine.production({DateTime Function()? utcNow}) =>
      SajuCalculationEngine._(
        RynSolarTermCalculator.production(),
        KoreanLunarCalendarConverter(),
        SexagenaryCalculator(),
        utcNow ?? () => DateTime.now().toUtc(),
      );

  final RynSolarTermCalculator _solarTermCalculator;
  final KoreanLunarCalendarConverter _lunarConverter;
  final SexagenaryCalculator _sexagenaryCalculator;
  final DateTime Function() _utcNow;

  SajuChartSnapshot calculate(SajuBirthInput input, {DateTime? calculatedAt}) {
    CheonEulGwiInModernKstPolicy.validate(input);
    final solarDate = _resolveSolarDate(input);
    final convertedLunarDate = input.calendarType == SajuCalendarType.koreanLunar
        ? input.lunarDate!
        : _lunarConverter.solarToLunar(solarDate);
    final localTime = input.localTime;
    final birthUtcInstant = localTime == null
        ? null
        : CheonEulGwiInModernKstPolicy.utcFromLocal(solarDate, localTime);
    final effectiveHourCalculationTime = localTime == null
        ? null
        : CheonEulGwiInModernKstPolicy.observedCompatibilityClock(
            solarDate,
            localTime,
          );
    final state = localTime == null
        ? _yearMonthStateForUnknownTime(solarDate)
        : _yearMonthStateAt(
            CheonEulGwiInModernKstPolicy.utcFromLocal(solarDate, localTime),
          );
    final dayPillar = _sexagenaryCalculator.dayPillar(solarDate);
    final hourPillar = localTime == null
        ? null
        : _sexagenaryCalculator.hourPillar(
            dayStemIndex: dayPillar.stemIndex,
            observedHour:
                CheonEulGwiInModernKstPolicy.observedCompatibilityClock(
                  solarDate,
                  localTime,
                ).hour,
          );

    final warnings = <SajuWarningCode>[
      SajuWarningCode.minuteLevelSolarTermCompatibility,
      if (localTime == null)
        SajuWarningCode.hourUnknown
      else ...[
        SajuWarningCode.observedSeoulLongitudeCalibration,
        SajuWarningCode.dayRolloverPolicyPendingCapture,
      ],
    ];

    final timestamp = (calculatedAt ?? _utcNow()).toUtc();
    return SajuChartSnapshot(
      engineId: CheonEulGwiInModernKstPolicy.engineId,
      engineVersion: CheonEulGwiInModernKstPolicy.engineVersion,
      policyId: CheonEulGwiInModernKstPolicy.policyId,
      policyVersion: CheonEulGwiInModernKstPolicy.policyVersion,
      timezoneId: CheonEulGwiInModernKstPolicy.timezoneId,
      calendarType: input.calendarType,
      lunarLeapMonth: input.lunarDate?.isLeapMonth ?? false,
      dayRolloverPolicy: CheonEulGwiInModernKstPolicy.dayRolloverPolicy,
      yajaEnabled: CheonEulGwiInModernKstPolicy.yajaEnabled,
      longitudeCorrectionPolicy:
          CheonEulGwiInModernKstPolicy.longitudeCorrectionPolicy,
      dstCorrectionPolicy: CheonEulGwiInModernKstPolicy.dstCorrectionPolicy,
      supportedRangeVersion: CheonEulGwiInModernKstPolicy.supportedRangeVersion,
      solarTermAlgorithmVersion: RynSolarTermCalculator.algorithmVersion,
      lunarConverterVersion: KoreanLunarCalendarConverter.version,
      dayAnchorVersion: SexagenaryCalculator.dayAnchorVersion,
      timeScaleAdapterVersion: _solarTermCalculator.timeScaleAdapterVersion,
      originalInputDate: input.calendarType == SajuCalendarType.solar
          ? input.solarDate!.iso8601
          : input.lunarDate!.iso8601,
      inputLocalTime: localTime,
      gender: input.gender,
      birthPlaceProfile: CheonEulGwiInModernKstPolicy.birthPlaceProfile,
      inputLocalDateTime: localTime == null
          ? '${solarDate.iso8601}Tunknown'
          : '${solarDate.iso8601}T${localTime.iso8601}',
      utcOffsetAtBirthMinutes: CheonEulGwiInModernKstPolicy.utcOffsetMinutes,
      convertedSolarDate: solarDate,
      convertedLunarDate: convertedLunarDate,
      birthUtcInstant: birthUtcInstant,
      effectiveHourCalculationTime: effectiveHourCalculationTime,
      originalLunarDate: input.lunarDate,
      hourUnknown: localTime == null,
      yearPillar: state.yearPillar,
      monthPillar: state.monthPillar,
      dayPillar: dayPillar,
      hourPillar: hourPillar,
      calculatedAt: timestamp,
      warnings: warnings,
    );
  }

  SajuLocalDate _resolveSolarDate(SajuBirthInput input) {
    if (input.calendarType == SajuCalendarType.koreanLunar) {
      final lunarDate = input.lunarDate;
      if (lunarDate == null) {
        throw const SajuCalculationException(
          code: SajuErrorCode.invalidDate,
          userMessage: '한국 음력 날짜가 필요합니다.',
        );
      }
      return _lunarConverter.lunarToSolar(lunarDate);
    }

    final solarDate = input.solarDate;
    if (solarDate == null || !solarDate.isValid) {
      throw const SajuCalculationException(
        code: SajuErrorCode.invalidDate,
        userMessage: '유효한 양력 날짜가 필요합니다.',
      );
    }
    if (solarDate.asUtcDate.isBefore(
          KoreanLunarCalendarConverter.minimumSolarDate.asUtcDate,
        ) ||
        solarDate.asUtcDate.isAfter(
          KoreanLunarCalendarConverter.maximumSolarDate.asUtcDate,
        )) {
      throw const SajuCalculationException(
        code: SajuErrorCode.unsupportedRange,
        userMessage: '양력은 1990-01-01부터 2050-12-31까지 지원합니다.',
      );
    }
    return solarDate;
  }

  _YearMonthState _yearMonthStateForUnknownTime(SajuLocalDate date) {
    final start = CheonEulGwiInModernKstPolicy.utcFromLocal(
      date,
      const SajuLocalTime(0, 0),
    );
    final nextDateTime = date.asUtcDate.add(const Duration(days: 1));
    final nextDate = SajuLocalDate(
      nextDateTime.year,
      nextDateTime.month,
      nextDateTime.day,
    );
    final end = CheonEulGwiInModernKstPolicy.utcFromLocal(
      nextDate,
      const SajuLocalTime(0, 0),
    ).subtract(const Duration(microseconds: 1));
    final atStart = _yearMonthStateAt(start);
    final atEnd = _yearMonthStateAt(end);
    if (atStart.yearPillar.cycleIndex != atEnd.yearPillar.cycleIndex ||
        atStart.monthPillar.cycleIndex != atEnd.monthPillar.cycleIndex) {
      throw const SajuCalculationException(
        code: SajuErrorCode.birthTimeRequiredAtSolarTermBoundary,
        userMessage: '절입이 있는 날짜는 연주·월주 확정을 위해 출생시간이 필요합니다.',
      );
    }
    return atStart;
  }

  _YearMonthState _yearMonthStateAt(DateTime birthUtc) {
    final local = CheonEulGwiInModernKstPolicy.localFromUtc(birthUtc);
    final calendarYear = local.year;
    final currentIpchun = _solarTermCalculator.utcInstant(
      calendarYear,
      SajuSolarTerm.ipchun,
    );
    final cycleYear = birthUtc.isBefore(currentIpchun)
        ? calendarYear - 1
        : calendarYear;
    final yearPillar = _sexagenaryCalculator.yearPillar(cycleYear);
    final boundaries = _monthBoundaries(cycleYear);
    var monthOffset = 0;
    for (final boundary in boundaries) {
      if (birthUtc.isBefore(boundary.instant)) break;
      monthOffset = boundary.monthOffset;
    }
    return _YearMonthState(
      yearPillar: yearPillar,
      monthPillar: _sexagenaryCalculator.monthPillar(
        yearStemIndex: yearPillar.stemIndex,
        monthOffset: monthOffset,
      ),
    );
  }

  List<_MonthBoundary> _monthBoundaries(int cycleYear) {
    final boundaries = <_MonthBoundary>[
      _MonthBoundary(
        _solarTermCalculator.utcInstant(cycleYear, SajuSolarTerm.ipchun),
        0,
      ),
      _MonthBoundary(
        _solarTermCalculator.utcInstant(cycleYear, SajuSolarTerm.gyeongchip),
        1,
      ),
      _MonthBoundary(
        _solarTermCalculator.utcInstant(cycleYear, SajuSolarTerm.cheongmyeong),
        2,
      ),
      _MonthBoundary(
        _solarTermCalculator.utcInstant(cycleYear, SajuSolarTerm.ipha),
        3,
      ),
      _MonthBoundary(
        _solarTermCalculator.utcInstant(cycleYear, SajuSolarTerm.mangjong),
        4,
      ),
      _MonthBoundary(
        _solarTermCalculator.utcInstant(cycleYear, SajuSolarTerm.soseo),
        5,
      ),
      _MonthBoundary(
        _solarTermCalculator.utcInstant(cycleYear, SajuSolarTerm.ipchu),
        6,
      ),
      _MonthBoundary(
        _solarTermCalculator.utcInstant(cycleYear, SajuSolarTerm.baengno),
        7,
      ),
      _MonthBoundary(
        _solarTermCalculator.utcInstant(cycleYear, SajuSolarTerm.hanno),
        8,
      ),
      _MonthBoundary(
        _solarTermCalculator.utcInstant(cycleYear, SajuSolarTerm.ipdong),
        9,
      ),
      _MonthBoundary(
        _solarTermCalculator.utcInstant(cycleYear, SajuSolarTerm.daeseol),
        10,
      ),
      if (cycleYear < 2050)
        _MonthBoundary(
          _solarTermCalculator.utcInstant(cycleYear + 1, SajuSolarTerm.sohan),
          11,
        ),
    ];
    return List.unmodifiable(boundaries);
  }
}

final class _YearMonthState {
  const _YearMonthState({required this.yearPillar, required this.monthPillar});

  final SexagenaryEntry yearPillar;
  final SexagenaryEntry monthPillar;
}

final class _MonthBoundary {
  const _MonthBoundary(this.instant, this.monthOffset);

  final DateTime instant;
  final int monthOffset;
}
