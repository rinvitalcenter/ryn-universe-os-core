import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/saju/domain/korean_lunar_calendar.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_models.dart';

void main() {
  group('corrected Korean lunar converter', () {
    final converter = KoreanLunarCalendarConverter();

    final fixtures = <SajuLocalDate, KoreanLunarDate>{
      const SajuLocalDate(2000, 1, 1): const KoreanLunarDate(1999, 11, 25),
      const SajuLocalDate(2022, 7, 10): const KoreanLunarDate(2022, 6, 12),
      const SajuLocalDate(2024, 2, 10): const KoreanLunarDate(2024, 1, 1),
      const SajuLocalDate(2006, 8, 24): const KoreanLunarDate(
        2006,
        7,
        1,
        isLeapMonth: true,
      ),
      const SajuLocalDate(2017, 6, 24): const KoreanLunarDate(
        2017,
        5,
        1,
        isLeapMonth: true,
      ),
      const SajuLocalDate(2020, 5, 23): const KoreanLunarDate(
        2020,
        4,
        1,
        isLeapMonth: true,
      ),
      const SajuLocalDate(2023, 3, 22): const KoreanLunarDate(
        2023,
        2,
        1,
        isLeapMonth: true,
      ),
      const SajuLocalDate(2050, 12, 31): const KoreanLunarDate(2050, 11, 18),
    };

    for (final fixture in fixtures.entries) {
      test('round trips ${fixture.key.iso8601}', () {
        final lunar = converter.solarToLunar(fixture.key);
        expect(lunar, fixture.value);
        expect(converter.lunarToSolar(lunar), fixture.key);
      });
    }

    test('rejects an invalid leap request without ordinary fallback', () {
      expect(
        () => converter.lunarToSolar(
          const KoreanLunarDate(2023, 3, 1, isLeapMonth: true),
        ),
        throwsA(
          isA<SajuCalculationException>().having(
            (error) => error.code,
            'code',
            SajuErrorCode.invalidLunarLeapMonth,
          ),
        ),
      );
    });

    test('instances do not share mutable calculation state', () {
      final first = KoreanLunarCalendarConverter();
      final second = KoreanLunarCalendarConverter();
      final expected = first.solarToLunar(const SajuLocalDate(2023, 3, 22));
      second.solarToLunar(const SajuLocalDate(2000, 1, 1));
      expect(first.solarToLunar(const SajuLocalDate(2023, 3, 22)), expected);
    });

    test(
      'supports exact modern profile endpoints and rejects outside them',
      () {
        expect(
          converter.solarToLunar(const SajuLocalDate(1990, 1, 1)),
          const KoreanLunarDate(1989, 12, 5),
        );
        expect(
          converter.solarToLunar(const SajuLocalDate(2050, 12, 31)),
          const KoreanLunarDate(2050, 11, 18),
        );
        expect(
          () => converter.solarToLunar(const SajuLocalDate(1989, 12, 31)),
          throwsA(
            isA<SajuCalculationException>().having(
              (error) => error.code,
              'code',
              SajuErrorCode.unsupportedRange,
            ),
          ),
        );
      },
    );
  });
}
