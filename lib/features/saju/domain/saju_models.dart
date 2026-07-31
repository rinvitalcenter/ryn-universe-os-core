enum SajuCalendarType { solar, koreanLunar }

enum SajuGender { male, female, unspecified }

enum SajuWarningCode {
  observedSeoulLongitudeCalibration,
  minuteLevelSolarTermCompatibility,
  dayRolloverPolicyPendingCapture,
  hourUnknown,
}

enum SajuErrorCode {
  invalidDate,
  invalidTime,
  invalidLunarLeapMonth,
  unsupportedRange,
  unsupportedTimezone,
  unsupportedPolicy,
  unresolvedDayRolloverWindow,
  birthTimeRequiredAtSolarTermBoundary,
}

final class SajuCalculationException implements Exception {
  const SajuCalculationException({
    required this.code,
    required this.userMessage,
    this.detail,
  });

  final SajuErrorCode code;
  final String userMessage;
  final String? detail;

  @override
  String toString() =>
      'SajuCalculationException(${code.name}): $userMessage${detail == null ? '' : ' ($detail)'}';
}

final class SajuLocalDate {
  const SajuLocalDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  bool get isValid {
    if (year < 1 || month < 1 || month > 12 || day < 1 || day > 31) {
      return false;
    }
    final normalized = DateTime.utc(year, month, day);
    return normalized.year == year &&
        normalized.month == month &&
        normalized.day == day;
  }

  DateTime get asUtcDate => DateTime.utc(year, month, day);

  String get iso8601 =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  Map<String, int> toJson() => {'year': year, 'month': month, 'day': day};

  @override
  bool operator ==(Object other) =>
      other is SajuLocalDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => iso8601;
}

final class SajuLocalTime {
  const SajuLocalTime(
    this.hour,
    this.minute, {
    this.second = 0,
    this.microsecond = 0,
  });

  final int hour;
  final int minute;
  final int second;
  final int microsecond;

  bool get isValid =>
      hour >= 0 &&
      hour <= 23 &&
      minute >= 0 &&
      minute <= 59 &&
      second >= 0 &&
      second <= 59 &&
      microsecond >= 0 &&
      microsecond <= 999999;

  int get microsecondsSinceMidnight =>
      (((hour * 60 + minute) * 60 + second) * 1000000) + microsecond;

  String get iso8601 {
    final base =
        '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:'
        '${second.toString().padLeft(2, '0')}';
    return microsecond == 0
        ? base
        : '$base.${microsecond.toString().padLeft(6, '0')}';
  }

  Map<String, int> toJson() => {
    'hour': hour,
    'minute': minute,
    'second': second,
    'microsecond': microsecond,
  };

  @override
  bool operator ==(Object other) =>
      other is SajuLocalTime &&
      hour == other.hour &&
      minute == other.minute &&
      second == other.second &&
      microsecond == other.microsecond;

  @override
  int get hashCode => Object.hash(hour, minute, second, microsecond);

  @override
  String toString() => iso8601;
}

final class KoreanLunarDate {
  const KoreanLunarDate(
    this.year,
    this.month,
    this.day, {
    this.isLeapMonth = false,
  });

  final int year;
  final int month;
  final int day;
  final bool isLeapMonth;

  String get iso8601 =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}'
      '${isLeapMonth ? '-leap' : ''}';

  Map<String, Object> toJson() => {
    'year': year,
    'month': month,
    'day': day,
    'isLeapMonth': isLeapMonth,
  };

  @override
  bool operator ==(Object other) =>
      other is KoreanLunarDate &&
      year == other.year &&
      month == other.month &&
      day == other.day &&
      isLeapMonth == other.isLeapMonth;

  @override
  int get hashCode => Object.hash(year, month, day, isLeapMonth);

  @override
  String toString() => iso8601;
}

final class SajuBirthInput {
  const SajuBirthInput._({
    required this.calendarType,
    required this.timezoneId,
    required this.policyId,
    required this.yajaEnabled,
    required this.gender,
    this.solarDate,
    this.lunarDate,
    this.localTime,
  });

  factory SajuBirthInput.solar({
    required SajuLocalDate date,
    SajuLocalTime? time,
    String timezoneId = 'Asia/Seoul',
    String policyId = 'cheonEulGwiInModernKstV1',
    bool yajaEnabled = false,
    SajuGender gender = SajuGender.unspecified,
  }) => SajuBirthInput._(
    calendarType: SajuCalendarType.solar,
    solarDate: date,
    localTime: time,
    timezoneId: timezoneId,
    policyId: policyId,
    yajaEnabled: yajaEnabled,
    gender: gender,
  );

  factory SajuBirthInput.koreanLunar({
    required KoreanLunarDate date,
    SajuLocalTime? time,
    String timezoneId = 'Asia/Seoul',
    String policyId = 'cheonEulGwiInModernKstV1',
    bool yajaEnabled = false,
    SajuGender gender = SajuGender.unspecified,
  }) => SajuBirthInput._(
    calendarType: SajuCalendarType.koreanLunar,
    lunarDate: date,
    localTime: time,
    timezoneId: timezoneId,
    policyId: policyId,
    yajaEnabled: yajaEnabled,
    gender: gender,
  );

  final SajuCalendarType calendarType;
  final SajuLocalDate? solarDate;
  final KoreanLunarDate? lunarDate;
  final SajuLocalTime? localTime;
  final String timezoneId;
  final String policyId;
  final bool yajaEnabled;
  final SajuGender gender;
}
