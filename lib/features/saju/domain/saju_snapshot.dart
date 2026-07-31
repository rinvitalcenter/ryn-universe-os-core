import 'dart:convert';

import 'saju_models.dart';
import 'sexagenary_cycle.dart';

final class SajuChartSnapshot {
  SajuChartSnapshot({
    required this.engineId,
    required this.engineVersion,
    required this.policyId,
    required this.policyVersion,
    required this.timezoneId,
    required this.calendarType,
    required this.lunarLeapMonth,
    required this.dayRolloverPolicy,
    required this.yajaEnabled,
    required this.longitudeCorrectionPolicy,
    required this.dstCorrectionPolicy,
    required this.supportedRangeVersion,
    required this.solarTermAlgorithmVersion,
    required this.lunarConverterVersion,
    required this.dayAnchorVersion,
    required this.timeScaleAdapterVersion,
    required this.inputLocalDateTime,
    required this.utcOffsetAtBirthMinutes,
    required this.convertedSolarDate,
    required this.originalLunarDate,
    required this.hourUnknown,
    required this.yearPillar,
    required this.monthPillar,
    required this.dayPillar,
    required this.hourPillar,
    required DateTime calculatedAt,
    required List<SajuWarningCode> warnings,
  }) : calculatedAt = calculatedAt.toUtc(),
       warnings = List.unmodifiable(warnings);

  final String engineId;
  final String engineVersion;
  final String policyId;
  final String policyVersion;
  final String timezoneId;
  final SajuCalendarType calendarType;
  final bool lunarLeapMonth;
  final String dayRolloverPolicy;
  final bool yajaEnabled;
  final String longitudeCorrectionPolicy;
  final String dstCorrectionPolicy;
  final String supportedRangeVersion;
  final String solarTermAlgorithmVersion;
  final String lunarConverterVersion;
  final String dayAnchorVersion;
  final String timeScaleAdapterVersion;
  final String inputLocalDateTime;
  final int utcOffsetAtBirthMinutes;
  final SajuLocalDate convertedSolarDate;
  final KoreanLunarDate? originalLunarDate;
  final bool hourUnknown;
  final SexagenaryEntry yearPillar;
  final SexagenaryEntry monthPillar;
  final SexagenaryEntry dayPillar;
  final SexagenaryEntry? hourPillar;
  final DateTime calculatedAt;
  final List<SajuWarningCode> warnings;

  Map<String, Object?> get deterministicPayload => {
    'engineId': engineId,
    'engineVersion': engineVersion,
    'policyId': policyId,
    'policyVersion': policyVersion,
    'timezoneId': timezoneId,
    'calendarType': calendarType.name,
    'lunarLeapMonth': lunarLeapMonth,
    'dayRolloverPolicy': dayRolloverPolicy,
    'yajaEnabled': yajaEnabled,
    'longitudeCorrectionPolicy': longitudeCorrectionPolicy,
    'dstCorrectionPolicy': dstCorrectionPolicy,
    'supportedRangeVersion': supportedRangeVersion,
    'solarTermAlgorithmVersion': solarTermAlgorithmVersion,
    'lunarConverterVersion': lunarConverterVersion,
    'dayAnchorVersion': dayAnchorVersion,
    'timeScaleAdapterVersion': timeScaleAdapterVersion,
    'inputLocalDateTime': inputLocalDateTime,
    'utcOffsetAtBirthMinutes': utcOffsetAtBirthMinutes,
    'convertedSolarDate': convertedSolarDate.toJson(),
    'originalLunarDate': originalLunarDate?.toJson(),
    'hourUnknown': hourUnknown,
    'yearPillar': yearPillar.toJson(),
    'monthPillar': monthPillar.toJson(),
    'dayPillar': dayPillar.toJson(),
    'hourPillar': hourPillar?.toJson(),
    'warnings': warnings.map((warning) => warning.name).toList(growable: false),
  };

  String get deterministicSignature => jsonEncode(deterministicPayload);

  Map<String, Object?> toJson() => {
    ...deterministicPayload,
    'calculatedAt': calculatedAt.toIso8601String(),
  };
}
