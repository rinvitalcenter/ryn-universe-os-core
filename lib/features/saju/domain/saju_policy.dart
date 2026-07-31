import 'saju_models.dart';

abstract final class CheonEulGwiInModernKstPolicy {
  static const engineId = 'rynSajuHybrid';
  static const engineVersion = '1.0.0';
  static const policyId = 'cheonEulGwiInModernKstV1';
  static const policyVersion = '1.0.0';
  static const timezoneId = 'Asia/Seoul';
  static const birthPlaceProfile = 'seoulCompatibilityV1';
  static const utcOffsetMinutes = 540;
  static const supportedRangeVersion = 'modern-seoul-1990-2050-v1';
  static const dayRolloverPolicy = 'pendingCheonEulCapture';
  static const longitudeCorrectionPolicy =
      'cheonEulObservedSeoulMinus30MinutesV1';
  static const dstCorrectionPolicy = 'modernRangeNoDst';
  static const yajaEnabled = false;

  static const _rolloverEndMicroseconds = 30 * 60 * 1000000;
  static const _rolloverStartMicroseconds = 23 * 60 * 60 * 1000000;

  static void validate(SajuBirthInput input) {
    if (input.timezoneId != timezoneId) {
      throw SajuCalculationException(
        code: SajuErrorCode.unsupportedTimezone,
        userMessage: '현재 계산 정책은 Asia/Seoul 시간대만 지원합니다.',
        detail: input.timezoneId,
      );
    }
    if (input.policyId != policyId || input.yajaEnabled) {
      throw SajuCalculationException(
        code: SajuErrorCode.unsupportedPolicy,
        userMessage: '현재는 천을귀인 Modern KST·야자시 OFF 정책만 지원합니다.',
        detail: 'policy=${input.policyId}, yaja=${input.yajaEnabled}',
      );
    }
    final time = input.localTime;
    if (time != null) {
      if (!time.isValid) {
        throw const SajuCalculationException(
          code: SajuErrorCode.invalidTime,
          userMessage: '유효한 출생시간을 입력해 주세요.',
        );
      }
      final value = time.microsecondsSinceMidnight;
      if (value >= _rolloverStartMicroseconds ||
          value < _rolloverEndMicroseconds) {
        throw const SajuCalculationException(
          code: SajuErrorCode.unresolvedDayRolloverWindow,
          userMessage: '23:00부터 00:29:59까지는 일주 경계 정책 확인 후 지원합니다.',
        );
      }
    }
  }

  static DateTime utcFromLocal(SajuLocalDate date, SajuLocalTime time) {
    final localWallClock = DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
      time.second,
      0,
      time.microsecond,
    );
    return localWallClock.subtract(const Duration(minutes: utcOffsetMinutes));
  }

  /// Returns a UTC-backed wall-clock value whose fields represent KST.
  /// This avoids dependence on the host machine timezone.
  static DateTime localFromUtc(DateTime utc) =>
      utc.toUtc().add(const Duration(minutes: utcOffsetMinutes));

  static DateTime observedCompatibilityClock(
    SajuLocalDate date,
    SajuLocalTime time,
  ) => DateTime.utc(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
    time.second,
    0,
    time.microsecond,
  ).subtract(const Duration(minutes: 30));
}
