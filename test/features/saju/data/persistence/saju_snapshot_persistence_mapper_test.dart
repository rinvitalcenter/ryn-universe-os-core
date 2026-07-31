import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/saju/data/persistence/saju_snapshot_persistence_mapper.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_calculation_engine.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_models.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_snapshot_repository.dart';
import 'package:ryn_universe_os_core/features/saju/domain/sexagenary_cycle.dart';

void main() {
  const mapper = SajuSnapshotPersistenceMapper();
  final engine = SajuCalculationEngine.production(
    utcNow: () => DateTime.utc(2026, 7, 31),
  );

  test('unknown hour maps every time-derived field to null', () {
    final snapshot = engine.calculate(
      SajuBirthInput.solar(
        date: const SajuLocalDate(2024, 2, 10),
        gender: SajuGender.female,
      ),
      calculatedAt: DateTime.utc(2026, 7, 31),
    );

    final row = mapper.toCompanion(
      id: 'snapshot-unknown',
      personId: 'person-a',
      sourceBirthProfileId: null,
      chartGroupId: 'chart-unknown',
      revisionNumber: 1,
      revisionReason: SajuRevisionReason.initial,
      createdAtUtcUs: 0,
      snapshot: snapshot,
    );

    expect(row.inputLocalTime.value, isNull);
    expect(row.birthUtcInstantUs.value, isNull);
    expect(row.effectiveHourCalculationTime.value, isNull);
    expect(row.hourPillarCanonicalId.value, isNull);
    expect(row.hourPillarCycleIndex.value, isNull);
    expect(row.hourPillarStemIndex.value, isNull);
    expect(row.hourPillarBranchIndex.value, isNull);
    expect(row.hourPillarHanja.value, isNull);
    expect(row.hourPillarKoreanLabel.value, isNull);
  });

  test('leap lunar input preserves original and converted normalized fields', () {
    final snapshot = engine.calculate(
      SajuBirthInput.koreanLunar(
        date: const KoreanLunarDate(2023, 2, 1, isLeapMonth: true),
        time: const SajuLocalTime(10, 0),
        gender: SajuGender.male,
      ),
      calculatedAt: DateTime.utc(2026, 7, 31),
    );

    final row = mapper.toCompanion(
      id: 'snapshot-leap',
      personId: 'person-a',
      sourceBirthProfileId: null,
      chartGroupId: 'chart-leap',
      revisionNumber: 1,
      revisionReason: SajuRevisionReason.initial,
      createdAtUtcUs: 0,
      snapshot: snapshot,
    );

    expect(row.originalLunarYear.value, 2023);
    expect(row.originalLunarMonth.value, 2);
    expect(row.originalLunarDay.value, 1);
    expect(row.originalLunarLeapMonth.value, isTrue);
    expect(row.convertedLunarDate.value, '2023-02-01');
    expect(row.convertedLunarLeapMonth.value, isTrue);
    expect(row.convertedSolarDate.value, '2023-03-22');
  });

  test('calculation signature excludes calculated and created timestamps', () {
    final input = SajuBirthInput.solar(
      date: const SajuLocalDate(2024, 2, 10),
      time: const SajuLocalTime(10, 0),
      gender: SajuGender.female,
    );
    final first = engine.calculate(
      input,
      calculatedAt: DateTime.utc(2026, 7, 31),
    );
    final second = engine.calculate(
      input,
      calculatedAt: DateTime.utc(2026, 8, 1),
    );

    expect(
      mapper.calculationSignature(first),
      mapper.calculationSignature(second),
    );
    final firstRow = mapper.toCompanion(
      id: 'snapshot-first',
      personId: 'person-a',
      sourceBirthProfileId: null,
      chartGroupId: 'chart-first',
      revisionNumber: 1,
      revisionReason: SajuRevisionReason.initial,
      createdAtUtcUs: 0,
      snapshot: first,
    );
    final secondRow = mapper.toCompanion(
      id: 'snapshot-second',
      personId: 'person-a',
      sourceBirthProfileId: null,
      chartGroupId: 'chart-second',
      revisionNumber: 1,
      revisionReason: SajuRevisionReason.initial,
      createdAtUtcUs: 999,
      snapshot: second,
    );
    expect(
      firstRow.calculationSignatureSha256.value,
      secondRow.calculationSignatureSha256.value,
    );
  });

  test('pillar registry mismatch and duplicate warnings fail closed', () {
    final source = engine.calculate(
      SajuBirthInput.solar(
        date: const SajuLocalDate(2024, 2, 10),
        time: const SajuLocalTime(10, 30),
        gender: SajuGender.female,
      ),
      calculatedAt: DateTime.utc(2026, 7, 31),
    );
    final wrongPillar = SexagenaryEntry(
      cycleIndex: source.yearPillar.cycleIndex,
      stemIndex: source.yearPillar.stemIndex,
      branchIndex: source.yearPillar.branchIndex,
      canonicalId: source.yearPillar.canonicalId,
      hanja: '錯誤',
      koreanLabel: source.yearPillar.koreanLabel,
    );

    expect(
      () => _map(mapper, _copy(source, yearPillar: wrongPillar)),
      throwsA(isA<SajuSnapshotValidationException>()),
    );
    expect(
      () => _map(
        mapper,
        _copy(
          source,
          warnings: <SajuWarningCode>[
            ...source.warnings,
            source.warnings.first,
          ],
        ),
      ),
      throwsA(isA<SajuSnapshotValidationException>()),
    );
  });
}

SajuChartSnapshot _copy(
  SajuChartSnapshot source, {
  SexagenaryEntry? yearPillar,
  List<SajuWarningCode>? warnings,
}) => SajuChartSnapshot(
  engineId: source.engineId,
  engineVersion: source.engineVersion,
  policyId: source.policyId,
  policyVersion: source.policyVersion,
  solarTermAlgorithmVersion: source.solarTermAlgorithmVersion,
  lunarConverterVersion: source.lunarConverterVersion,
  dayAnchorVersion: source.dayAnchorVersion,
  supportedRangeVersion: source.supportedRangeVersion,
  timeScaleAdapterVersion: source.timeScaleAdapterVersion,
  originalInputDate: source.originalInputDate,
  inputLocalTime: source.inputLocalTime,
  gender: source.gender,
  birthPlaceProfile: source.birthPlaceProfile,
  convertedLunarDate: source.convertedLunarDate,

  birthUtcInstant: source.birthUtcInstant,
  effectiveHourCalculationTime: source.effectiveHourCalculationTime,
  calendarType: source.calendarType,
  originalLunarDate: source.originalLunarDate,
  lunarLeapMonth: source.lunarLeapMonth,
  convertedSolarDate: source.convertedSolarDate,
  inputLocalDateTime: source.inputLocalDateTime,
  hourUnknown: source.hourUnknown,
  timezoneId: source.timezoneId,
  utcOffsetAtBirthMinutes: source.utcOffsetAtBirthMinutes,
  yearPillar: yearPillar ?? source.yearPillar,
  monthPillar: source.monthPillar,
  dayPillar: source.dayPillar,
  hourPillar: source.hourPillar,
  dayRolloverPolicy: source.dayRolloverPolicy,
  longitudeCorrectionPolicy: source.longitudeCorrectionPolicy,
  dstCorrectionPolicy: source.dstCorrectionPolicy,
  yajaEnabled: source.yajaEnabled,
  calculatedAt: source.calculatedAt,
  warnings: warnings ?? source.warnings,
);

void _map(
  SajuSnapshotPersistenceMapper mapper,
  SajuChartSnapshot snapshot,
) => mapper.toCompanion(
  id: 'snapshot-validation',
  personId: 'person-a',
  sourceBirthProfileId: null,
  chartGroupId: 'chart-validation',
  revisionNumber: 1,
  revisionReason: SajuRevisionReason.initial,
  createdAtUtcUs: 0,
  snapshot: snapshot,
);