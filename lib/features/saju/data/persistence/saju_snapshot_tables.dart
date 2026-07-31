import 'package:drift/drift.dart';

import '../../../people/data/persistence/person_tables.dart';

@DataClassName('SajuChartSnapshotRow')
class SajuChartSnapshots extends Table {
  TextColumn get id => text().withLength(min: 1, max: 120)();
  TextColumn get personId => text()
      .named('person_id')
      .withLength(min: 1, max: 120)
      .references(Persons, #id, onDelete: KeyAction.restrict)();
  TextColumn get sourceBirthProfileId => text()
      .named('source_birth_profile_id')
      .withLength(min: 1, max: 120)
      .nullable()
      .references(PersonBirthProfiles, #id, onDelete: KeyAction.restrict)();
  TextColumn get chartGroupId =>
      text().named('chart_group_id').withLength(min: 1, max: 120)();
  IntColumn get revisionNumber => integer().named('revision_number')();
  TextColumn get revisionReason =>
      text().named('revision_reason').withLength(min: 1, max: 40)();
  IntColumn get createdAtUtcUs => integer().named('created_at_utc_us')();
  IntColumn get calculatedAtUtcUs => integer().named('calculated_at_utc_us')();

  TextColumn get calendarType =>
      text().named('calendar_type').withLength(min: 1, max: 20)();
  TextColumn get inputLocalDate =>
      text().named('input_local_date').withLength(min: 10, max: 15)();
  TextColumn get inputLocalTime => text()
      .named('input_local_time')
      .withLength(min: 8, max: 15)
      .nullable()();
  BoolColumn get hourUnknown => boolean().named('hour_unknown')();
  TextColumn get genderCompatibilityValue => text()
      .named('gender_compatibility_value')
      .withLength(min: 1, max: 20)();
  IntColumn get originalLunarYear =>
      integer().named('original_lunar_year').nullable()();
  IntColumn get originalLunarMonth =>
      integer().named('original_lunar_month').nullable()();
  IntColumn get originalLunarDay =>
      integer().named('original_lunar_day').nullable()();
  BoolColumn get originalLunarLeapMonth =>
      boolean().named('original_lunar_leap_month').nullable()();
  TextColumn get timezoneId =>
      text().named('timezone_id').withLength(min: 1, max: 120)();
  TextColumn get birthPlaceProfile =>
      text().named('birth_place_profile').withLength(min: 1, max: 80)();
  BoolColumn get yajaEnabled => boolean().named('yaja_enabled')();

  TextColumn get convertedSolarDate =>
      text().named('converted_solar_date').withLength(min: 10, max: 10)();
  TextColumn get convertedLunarDate =>
      text().named('converted_lunar_date').withLength(min: 10, max: 10)();
  BoolColumn get convertedLunarLeapMonth =>
      boolean().named('converted_lunar_leap_month')();
  IntColumn get birthUtcInstantUs =>
      integer().named('birth_utc_instant_us').nullable()();
  IntColumn get utcOffsetAtBirthMinutes =>
      integer().named('utc_offset_at_birth_minutes')();
  TextColumn get effectiveHourCalculationTime => text()
      .named('effective_hour_calculation_time')
      .withLength(min: 19, max: 27)
      .nullable()();

  TextColumn get yearPillarCanonicalId => text()
      .named('year_pillar_canonical_id')
      .withLength(min: 13, max: 13)();
  IntColumn get yearPillarCycleIndex =>
      integer().named('year_pillar_cycle_index')();
  IntColumn get yearPillarStemIndex =>
      integer().named('year_pillar_stem_index')();
  IntColumn get yearPillarBranchIndex =>
      integer().named('year_pillar_branch_index')();
  TextColumn get yearPillarHanja =>
      text().named('year_pillar_hanja').withLength(min: 2, max: 2)();
  TextColumn get yearPillarKoreanLabel =>
      text().named('year_pillar_korean_label').withLength(min: 2, max: 2)();

  TextColumn get monthPillarCanonicalId => text()
      .named('month_pillar_canonical_id')
      .withLength(min: 13, max: 13)();
  IntColumn get monthPillarCycleIndex =>
      integer().named('month_pillar_cycle_index')();
  IntColumn get monthPillarStemIndex =>
      integer().named('month_pillar_stem_index')();
  IntColumn get monthPillarBranchIndex =>
      integer().named('month_pillar_branch_index')();
  TextColumn get monthPillarHanja =>
      text().named('month_pillar_hanja').withLength(min: 2, max: 2)();
  TextColumn get monthPillarKoreanLabel =>
      text().named('month_pillar_korean_label').withLength(min: 2, max: 2)();

  TextColumn get dayPillarCanonicalId => text()
      .named('day_pillar_canonical_id')
      .withLength(min: 13, max: 13)();
  IntColumn get dayPillarCycleIndex =>
      integer().named('day_pillar_cycle_index')();
  IntColumn get dayPillarStemIndex =>
      integer().named('day_pillar_stem_index')();
  IntColumn get dayPillarBranchIndex =>
      integer().named('day_pillar_branch_index')();
  TextColumn get dayPillarHanja =>
      text().named('day_pillar_hanja').withLength(min: 2, max: 2)();
  TextColumn get dayPillarKoreanLabel =>
      text().named('day_pillar_korean_label').withLength(min: 2, max: 2)();

  TextColumn get hourPillarCanonicalId => text()
      .named('hour_pillar_canonical_id')
      .withLength(min: 13, max: 13)
      .nullable()();
  IntColumn get hourPillarCycleIndex =>
      integer().named('hour_pillar_cycle_index').nullable()();
  IntColumn get hourPillarStemIndex =>
      integer().named('hour_pillar_stem_index').nullable()();
  IntColumn get hourPillarBranchIndex =>
      integer().named('hour_pillar_branch_index').nullable()();
  TextColumn get hourPillarHanja => text()
      .named('hour_pillar_hanja')
      .withLength(min: 2, max: 2)
      .nullable()();
  TextColumn get hourPillarKoreanLabel => text()
      .named('hour_pillar_korean_label')
      .withLength(min: 2, max: 2)
      .nullable()();

  TextColumn get engineId =>
      text().named('engine_id').withLength(min: 1, max: 120)();
  TextColumn get engineVersion =>
      text().named('engine_version').withLength(min: 1, max: 40)();
  TextColumn get policyId =>
      text().named('policy_id').withLength(min: 1, max: 120)();
  TextColumn get policyVersion =>
      text().named('policy_version').withLength(min: 1, max: 40)();
  TextColumn get dayRolloverPolicy =>
      text().named('day_rollover_policy').withLength(min: 1, max: 120)();
  TextColumn get longitudeCorrectionPolicy => text()
      .named('longitude_correction_policy')
      .withLength(min: 1, max: 120)();
  TextColumn get dstCorrectionPolicy =>
      text().named('dst_correction_policy').withLength(min: 1, max: 120)();
  TextColumn get supportedRangeVersion =>
      text().named('supported_range_version').withLength(min: 1, max: 120)();
  TextColumn get solarTermAlgorithmVersion => text()
      .named('solar_term_algorithm_version')
      .withLength(min: 1, max: 160)();
  TextColumn get lunarConverterVersion =>
      text().named('lunar_converter_version').withLength(min: 1, max: 120)();
  TextColumn get dayAnchorVersion =>
      text().named('day_anchor_version').withLength(min: 1, max: 120)();
  TextColumn get timeScaleAdapterVersion => text()
      .named('time_scale_adapter_version')
      .withLength(min: 1, max: 120)();

  TextColumn get warningsJson => text().named('warnings_json')();
  TextColumn get inputFingerprintSha256 => text()
      .named('input_fingerprint_sha256')
      .withLength(min: 64, max: 64)();
  TextColumn get calculationSignatureSha256 => text()
      .named('calculation_signature_sha256')
      .withLength(min: 64, max: 64)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {chartGroupId, revisionNumber},
    {personId, inputFingerprintSha256, calculationSignatureSha256},
  ];

  @override
  List<String> get customConstraints => const [
    'CHECK (length(trim(id)) BETWEEN 1 AND 120)',
    'CHECK (length(trim(person_id)) BETWEEN 1 AND 120)',
    'CHECK (source_birth_profile_id IS NULL OR length(trim(source_birth_profile_id)) BETWEEN 1 AND 120)',
    'CHECK (length(trim(chart_group_id)) BETWEEN 1 AND 120)',
    'CHECK (revision_number >= 1)',
    "CHECK (revision_reason IN ('initial','inputCorrected','engineUpdated','policyUpdated','calculationErrorCorrected','birthPlaceProfileChanged'))",
    "CHECK ((revision_number = 1 AND revision_reason = 'initial') OR (revision_number > 1 AND revision_reason != 'initial'))",
    'CHECK (created_at_utc_us >= 0)',
    'CHECK (calculated_at_utc_us >= 0)',
    "CHECK (calendar_type IN ('solar','koreanLunar'))",
    "CHECK (gender_compatibility_value IN ('male','female','unspecified'))",
    "CHECK (length(trim(input_local_date)) > 0 AND length(trim(converted_solar_date)) > 0 AND length(trim(converted_lunar_date)) > 0)",
    "CHECK ((calendar_type = 'solar' AND original_lunar_year IS NULL AND original_lunar_month IS NULL AND original_lunar_day IS NULL AND original_lunar_leap_month IS NULL) OR (calendar_type = 'koreanLunar' AND original_lunar_year IS NOT NULL AND original_lunar_month BETWEEN 1 AND 12 AND original_lunar_day BETWEEN 1 AND 30 AND original_lunar_leap_month IS NOT NULL))",
    "CHECK (timezone_id = 'Asia/Seoul')",
    "CHECK (birth_place_profile = 'seoulCompatibilityV1')",
    'CHECK (yaja_enabled = 0)',
    'CHECK (utc_offset_at_birth_minutes = 540)',
    "CHECK ((hour_unknown = 1 AND input_local_time IS NULL AND birth_utc_instant_us IS NULL AND effective_hour_calculation_time IS NULL AND hour_pillar_canonical_id IS NULL AND hour_pillar_cycle_index IS NULL AND hour_pillar_stem_index IS NULL AND hour_pillar_branch_index IS NULL AND hour_pillar_hanja IS NULL AND hour_pillar_korean_label IS NULL) OR (hour_unknown = 0 AND input_local_time IS NOT NULL AND birth_utc_instant_us IS NOT NULL AND effective_hour_calculation_time IS NOT NULL AND hour_pillar_canonical_id IS NOT NULL AND hour_pillar_cycle_index IS NOT NULL AND hour_pillar_stem_index IS NOT NULL AND hour_pillar_branch_index IS NOT NULL AND hour_pillar_hanja IS NOT NULL AND hour_pillar_korean_label IS NOT NULL))",
    'CHECK (year_pillar_cycle_index BETWEEN 0 AND 59 AND year_pillar_stem_index = year_pillar_cycle_index % 10 AND year_pillar_branch_index = year_pillar_cycle_index % 12)',
    'CHECK (month_pillar_cycle_index BETWEEN 0 AND 59 AND month_pillar_stem_index = month_pillar_cycle_index % 10 AND month_pillar_branch_index = month_pillar_cycle_index % 12)',
    'CHECK (day_pillar_cycle_index BETWEEN 0 AND 59 AND day_pillar_stem_index = day_pillar_cycle_index % 10 AND day_pillar_branch_index = day_pillar_cycle_index % 12)',
    'CHECK (hour_pillar_cycle_index IS NULL OR (hour_pillar_cycle_index BETWEEN 0 AND 59 AND hour_pillar_stem_index = hour_pillar_cycle_index % 10 AND hour_pillar_branch_index = hour_pillar_cycle_index % 12))',
    'CHECK (length(year_pillar_canonical_id) = 13 AND length(year_pillar_hanja) = 2 AND length(year_pillar_korean_label) = 2 AND length(month_pillar_canonical_id) = 13 AND length(month_pillar_hanja) = 2 AND length(month_pillar_korean_label) = 2 AND length(day_pillar_canonical_id) = 13 AND length(day_pillar_hanja) = 2 AND length(day_pillar_korean_label) = 2)',
    'CHECK (hour_pillar_canonical_id IS NULL OR (length(hour_pillar_canonical_id) = 13 AND length(hour_pillar_hanja) = 2 AND length(hour_pillar_korean_label) = 2))',
    'CHECK (length(trim(engine_id)) > 0 AND length(trim(engine_version)) > 0 AND length(trim(policy_id)) > 0 AND length(trim(policy_version)) > 0 AND length(trim(day_rollover_policy)) > 0 AND length(trim(longitude_correction_policy)) > 0 AND length(trim(dst_correction_policy)) > 0 AND length(trim(supported_range_version)) > 0 AND length(trim(solar_term_algorithm_version)) > 0 AND length(trim(lunar_converter_version)) > 0 AND length(trim(day_anchor_version)) > 0 AND length(trim(time_scale_adapter_version)) > 0)',
    'CHECK (length(warnings_json) >= 2)',
    "CHECK (length(input_fingerprint_sha256) = 64 AND input_fingerprint_sha256 NOT GLOB '*[^0-9a-f]*')",
    "CHECK (length(calculation_signature_sha256) = 64 AND calculation_signature_sha256 NOT GLOB '*[^0-9a-f]*')",
  ];
}
