import 'saju_models.dart';

/// Corrected, instance-based modern profile port derived from the MIT-licensed
/// Korean Lunar Calendar data by usingsky and chunghha.
///
/// Only the immutable 1989-2050 table slice needed by the Ryn v1 supported
/// range is bundled. No global calculation state or upstream sexagenary logic
/// is retained.
final class KoreanLunarCalendarConverter {
  static const version = 'klc-kasi-instance-port-v1';
  static const minimumSolarDate = SajuLocalDate(1990, 1, 1);
  static const maximumSolarDate = SajuLocalDate(2050, 12, 31);
  static const minimumLunarDate = KoreanLunarDate(1989, 12, 5);
  static const maximumLunarDate = KoreanLunarDate(2050, 11, 18);

  static const _baseLunarYear = 1989;
  static const _epochSolarDate = SajuLocalDate(1990, 1, 1);
  static const _epochLunarDate = KoreanLunarDate(1989, 12, 5);

  static const List<int> _lunarData = [
    0x82c6095b,
    0x830054b7,
    0x82c40497,
    0xc2c4064b,
    0x82fe374a,
    0x82c60ea5,
    0x830086d9,
    0xc2c605ad,
    0x82c402b6,
    0x8300596e,
    0x82c4092e,
    0xc2c40c96,
    0x83004e95,
    0x82c40d4a,
    0x82c60da5,
    0xc3002755,
    0x82c4056c,
    0x83027abb,
    0x82c4025d,
    0xc2c4092d,
    0x83005cab,
    0x82c40a95,
    0x82c40b4a,
    0xc3013b4a,
    0x82c60b55,
    0x8300955d,
    0x82c404ba,
    0xc2c60a5b,
    0x83005557,
    0x82c4052b,
    0x82c40a95,
    0xc3004b95,
    0x82c406aa,
    0x82c60ad5,
    0x830026b5,
    0xc2c404b6,
    0x83006a6e,
    0x82c60a57,
    0x82c40527,
    0xc2fe56a6,
    0x82c60d93,
    0x82c405aa,
    0x83003b6a,
    0xc2c6096d,
    0x8300b4af,
    0x82c404ae,
    0x82c40a4d,
    0xc3016d0d,
    0x82c40d25,
    0x82c40d52,
    0x83005dd4,
    0xc2c60b6a,
    0x82c6096d,
    0x8300255b,
    0x82c4049b,
    0xc3007a57,
    0x82c40a4b,
    0x82c40b25,
    0x83015b25,
    0xc2c406d4,
    0x82c60ada,
    0x830138b6,
  ];

  KoreanLunarDate solarToLunar(SajuLocalDate solarDate) {
    _validateSolarDate(solarDate);
    var lunarOrdinal =
        _lunarOrdinal(_epochLunarDate) +
        solarDate.asUtcDate.difference(_epochSolarDate.asUtcDate).inDays;

    var year = _baseLunarYear;
    while (year <= 2050) {
      final yearDays = _lunarYearDays(year);
      if (lunarOrdinal < yearDays) break;
      lunarOrdinal -= yearDays;
      year++;
    }

    for (var month = 1; month <= 12; month++) {
      final ordinaryDays = _lunarMonthDays(year, month, false);
      if (lunarOrdinal < ordinaryDays) {
        return KoreanLunarDate(year, month, lunarOrdinal + 1);
      }
      lunarOrdinal -= ordinaryDays;

      if (_leapMonth(year) == month) {
        final leapDays = _lunarMonthDays(year, month, true);
        if (lunarOrdinal < leapDays) {
          return KoreanLunarDate(
            year,
            month,
            lunarOrdinal + 1,
            isLeapMonth: true,
          );
        }
        lunarOrdinal -= leapDays;
      }
    }

    throw const SajuCalculationException(
      code: SajuErrorCode.unsupportedRange,
      userMessage: '지원하는 한국 음력 범위를 벗어났습니다.',
    );
  }

  SajuLocalDate lunarToSolar(KoreanLunarDate lunarDate) {
    _validateLunarDate(lunarDate);
    final offset = _lunarOrdinal(lunarDate) - _lunarOrdinal(_epochLunarDate);
    final solar = _epochSolarDate.asUtcDate.add(Duration(days: offset));
    final result = SajuLocalDate(solar.year, solar.month, solar.day);
    _validateSolarDate(result);
    return result;
  }

  int _data(int year) {
    final index = year - _baseLunarYear;
    if (index < 0 || index >= _lunarData.length) {
      throw const SajuCalculationException(
        code: SajuErrorCode.unsupportedRange,
        userMessage: '지원하는 한국 음력 범위를 벗어났습니다.',
      );
    }
    return _lunarData[index];
  }

  int _leapMonth(int year) => (_data(year) >> 12) & 0x0f;

  int _lunarMonthDays(int year, int month, bool isLeapMonth) {
    final data = _data(year);
    if (isLeapMonth) {
      if (_leapMonth(year) != month) {
        throw SajuCalculationException(
          code: SajuErrorCode.invalidLunarLeapMonth,
          userMessage: '해당 연도와 월에는 윤달이 없습니다.',
          detail: '$year-$month',
        );
      }
      return ((data >> 16) & 1) == 1 ? 30 : 29;
    }
    return ((data >> (12 - month)) & 1) == 1 ? 30 : 29;
  }

  int _lunarYearDays(int year) {
    var days = 0;
    for (var month = 1; month <= 12; month++) {
      days += _lunarMonthDays(year, month, false);
      if (_leapMonth(year) == month) {
        days += _lunarMonthDays(year, month, true);
      }
    }
    return days;
  }

  int _lunarOrdinal(KoreanLunarDate date) {
    var days = 0;
    for (var year = _baseLunarYear; year < date.year; year++) {
      days += _lunarYearDays(year);
    }
    for (var month = 1; month < date.month; month++) {
      days += _lunarMonthDays(date.year, month, false);
      if (_leapMonth(date.year) == month) {
        days += _lunarMonthDays(date.year, month, true);
      }
    }
    if (date.isLeapMonth) {
      days += _lunarMonthDays(date.year, date.month, false);
    }
    return days + date.day - 1;
  }

  void _validateSolarDate(SajuLocalDate date) {
    if (!date.isValid) {
      throw const SajuCalculationException(
        code: SajuErrorCode.invalidDate,
        userMessage: '유효한 양력 날짜를 입력해 주세요.',
      );
    }
    if (_compareSolar(date, minimumSolarDate) < 0 ||
        _compareSolar(date, maximumSolarDate) > 0) {
      throw const SajuCalculationException(
        code: SajuErrorCode.unsupportedRange,
        userMessage: '양력은 1990-01-01부터 2050-12-31까지 지원합니다.',
      );
    }
  }

  void _validateLunarDate(KoreanLunarDate date) {
    if (date.year < _baseLunarYear ||
        date.year > 2050 ||
        date.month < 1 ||
        date.month > 12 ||
        date.day < 1) {
      throw const SajuCalculationException(
        code: SajuErrorCode.invalidDate,
        userMessage: '유효한 한국 음력 날짜를 입력해 주세요.',
      );
    }
    if (date.isLeapMonth && _leapMonth(date.year) != date.month) {
      throw SajuCalculationException(
        code: SajuErrorCode.invalidLunarLeapMonth,
        userMessage: '해당 연도와 월에는 윤달이 없습니다.',
        detail: '${date.year}-${date.month}',
      );
    }
    final maxDay = _lunarMonthDays(date.year, date.month, date.isLeapMonth);
    if (date.day > maxDay) {
      throw const SajuCalculationException(
        code: SajuErrorCode.invalidDate,
        userMessage: '유효한 한국 음력 날짜를 입력해 주세요.',
      );
    }
    if (_compareLunar(date, minimumLunarDate) < 0 ||
        _compareLunar(date, maximumLunarDate) > 0) {
      throw const SajuCalculationException(
        code: SajuErrorCode.unsupportedRange,
        userMessage: '한국 음력은 1989-12-05부터 2050-11-18까지 지원합니다.',
      );
    }
  }

  int _compareSolar(SajuLocalDate left, SajuLocalDate right) =>
      left.asUtcDate.compareTo(right.asUtcDate);

  int _compareLunar(KoreanLunarDate left, KoreanLunarDate right) {
    final leftKey = left.year * 10000 + left.month * 100 + left.day;
    final rightKey = right.year * 10000 + right.month * 100 + right.day;
    return leftKey.compareTo(rightKey);
  }
}
