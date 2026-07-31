import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_calculation_engine.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_models.dart';

void main() {
  final engine = SajuCalculationEngine.production(
    utcNow: () => DateTime.utc(2026, 7, 30, 12),
  );

  group('CheonEulGwiIn V5.20 compatibility fixtures', () {
    final fixtures =
        <
          ({
            String id,
            SajuBirthInput input,
            List<String> canonicalIds,
            List<String> hanja,
            List<String> korean,
          })
        >[
          (
            id: 'CEG-R2-O01',
            input: SajuBirthInput.solar(
              date: const SajuLocalDate(1990, 3, 15),
              time: const SajuLocalTime(10, 30),
              gender: SajuGender.male,
            ),
            canonicalIds: const [
              'sexagenary-06',
              'sexagenary-15',
              'sexagenary-15',
              'sexagenary-05',
            ],
            hanja: const ['庚午', '己卯', '己卯', '己巳'],
            korean: const ['경오', '기묘', '기묘', '기사'],
          ),
          (
            id: 'CEG-R2-I01',
            input: SajuBirthInput.solar(
              date: const SajuLocalDate(2024, 2, 4),
              time: const SajuLocalTime(17, 26),
              gender: SajuGender.male,
            ),
            canonicalIds: const [
              'sexagenary-39',
              'sexagenary-01',
              'sexagenary-34',
              'sexagenary-56',
            ],
            hanja: const ['癸卯', '乙丑', '戊戌', '庚申'],
            korean: const ['계묘', '을축', '무술', '경신'],
          ),
          (
            id: 'CEG-R2-I02',
            input: SajuBirthInput.solar(
              date: const SajuLocalDate(2024, 2, 4),
              time: const SajuLocalTime(17, 28),
              gender: SajuGender.male,
            ),
            canonicalIds: const [
              'sexagenary-40',
              'sexagenary-02',
              'sexagenary-34',
              'sexagenary-56',
            ],
            hanja: const ['甲辰', '丙寅', '戊戌', '庚申'],
            korean: const ['갑진', '병인', '무술', '경신'],
          ),
          (
            id: 'CEG-R2-M01',
            input: SajuBirthInput.solar(
              date: const SajuLocalDate(2024, 3, 5),
              time: const SajuLocalTime(11, 21),
              gender: SajuGender.male,
            ),
            canonicalIds: const [
              'sexagenary-40',
              'sexagenary-02',
              'sexagenary-04',
              'sexagenary-53',
            ],
            hanja: const ['甲辰', '丙寅', '戊辰', '丁巳'],
            korean: const ['갑진', '병인', '무진', '정사'],
          ),
          (
            id: 'CEG-R2-M02',
            input: SajuBirthInput.solar(
              date: const SajuLocalDate(2024, 3, 5),
              time: const SajuLocalTime(11, 23),
              gender: SajuGender.male,
            ),
            canonicalIds: const [
              'sexagenary-40',
              'sexagenary-03',
              'sexagenary-04',
              'sexagenary-53',
            ],
            hanja: const ['甲辰', '丁卯', '戊辰', '丁巳'],
            korean: const ['갑진', '정묘', '무진', '정사'],
          ),
        ];

    for (final fixture in fixtures) {
      test('${fixture.id} follows the general calculation path', () {
        final result = engine.calculate(fixture.input);
        final pillars = [
          result.yearPillar,
          result.monthPillar,
          result.dayPillar,
          result.hourPillar!,
        ];
        expect(
          pillars.map((pillar) => pillar.canonicalId),
          fixture.canonicalIds,
        );
        expect(pillars.map((pillar) => pillar.hanja), fixture.hanja);
        expect(pillars.map((pillar) => pillar.koreanLabel), fixture.korean);
        expect(result.engineId, 'rynSajuHybrid');
        expect(result.engineVersion, '1.0.0');
        expect(result.policyId, 'cheonEulGwiInModernKstV1');
        expect(result.policyVersion, '1.0.0');
        expect(result.timezoneId, 'Asia/Seoul');
        expect(
          result.warnings,
          contains(SajuWarningCode.observedSeoulLongitudeCalibration),
        );
        expect(result.warnings, isNot(contains(SajuWarningCode.hourUnknown)));
      });
    }
  });

  group('policy safety', () {
    test(
      'unknown time returns no hour pillar and only applicable warnings',
      () {
        final result = engine.calculate(
          SajuBirthInput.solar(date: const SajuLocalDate(2024, 2, 10)),
        );
        expect(result.hourUnknown, isTrue);
        expect(result.hourPillar, isNull);
        expect(result.warnings, contains(SajuWarningCode.hourUnknown));
        expect(
          result.warnings,
          isNot(contains(SajuWarningCode.observedSeoulLongitudeCalibration)),
        );
      },
    );

    for (final time in const [
      SajuLocalTime(23, 0),
      SajuLocalTime(23, 59),
      SajuLocalTime(0, 0),
      SajuLocalTime(0, 29, second: 59, microsecond: 999999),
    ]) {
      test('rejects unresolved rollover time ${time.iso8601}', () {
        expect(
          () => engine.calculate(
            SajuBirthInput.solar(
              date: const SajuLocalDate(2024, 5, 10),
              time: time,
            ),
          ),
          throwsA(
            isA<SajuCalculationException>().having(
              (error) => error.code,
              'code',
              SajuErrorCode.unresolvedDayRolloverWindow,
            ),
          ),
        );
      });
    }

    test('allows times immediately outside the unresolved window', () {
      expect(
        () => engine.calculate(
          SajuBirthInput.solar(
            date: const SajuLocalDate(2024, 5, 10),
            time: const SajuLocalTime(22, 59),
          ),
        ),
        returnsNormally,
      );
      expect(
        () => engine.calculate(
          SajuBirthInput.solar(
            date: const SajuLocalDate(2024, 5, 10),
            time: const SajuLocalTime(0, 30),
          ),
        ),
        returnsNormally,
      );
    });

    test('rejects unsupported timezone and Yaja ON without fallback', () {
      for (final input in [
        SajuBirthInput.solar(
          date: const SajuLocalDate(2024, 2, 10),
          timezoneId: 'UTC',
        ),
        SajuBirthInput.solar(
          date: const SajuLocalDate(2024, 2, 10),
          yajaEnabled: true,
        ),
        SajuBirthInput.solar(
          date: const SajuLocalDate(2024, 2, 10),
          policyId: 'unsupportedPolicy',
        ),
      ]) {
        expect(
          () => engine.calculate(input),
          throwsA(isA<SajuCalculationException>()),
        );
      }
    });

    test('rejects unsupported solar and lunar dates', () {
      expect(
        () => engine.calculate(
          SajuBirthInput.solar(date: const SajuLocalDate(1989, 12, 31)),
        ),
        throwsA(
          isA<SajuCalculationException>().having(
            (error) => error.code,
            'code',
            SajuErrorCode.unsupportedRange,
          ),
        ),
      );
      expect(
        () => engine.calculate(
          SajuBirthInput.koreanLunar(date: const KoreanLunarDate(1989, 12, 4)),
        ),
        throwsA(isA<SajuCalculationException>()),
      );
    });

    test('calculates both inclusive solar endpoints', () {
      for (final date in const [
        SajuLocalDate(1990, 1, 1),
        SajuLocalDate(2050, 12, 31),
      ]) {
        final result = engine.calculate(
          SajuBirthInput.solar(date: date, time: const SajuLocalTime(12, 0)),
        );
        expect(result.convertedSolarDate, date);
        expect(result.yearPillar, isNotNull);
        expect(result.monthPillar, isNotNull);
        expect(result.dayPillar, isNotNull);
        expect(result.hourPillar, isNotNull);
      }
    });

    test('lunar input preserves original input and converted solar date', () {
      final result = engine.calculate(
        SajuBirthInput.koreanLunar(
          date: const KoreanLunarDate(2023, 2, 1, isLeapMonth: true),
          time: const SajuLocalTime(12, 0),
        ),
      );
      expect(result.calendarType, SajuCalendarType.koreanLunar);
      expect(result.lunarLeapMonth, isTrue);
      expect(
        result.originalLunarDate,
        const KoreanLunarDate(2023, 2, 1, isLeapMonth: true),
      );
      expect(result.convertedSolarDate, const SajuLocalDate(2023, 3, 22));
      expect(
        result.convertedLunarDate,
        const KoreanLunarDate(2023, 2, 1, isLeapMonth: true),
      );
      expect(result.convertedLunarLeapMonth, isTrue);
    });

    test('snapshot carries normalized time without persistence recalculation', () {
      final result = engine.calculate(
        SajuBirthInput.solar(
          date: const SajuLocalDate(2024, 2, 10),
          time: const SajuLocalTime(10, 0),
        ),
      );

      expect(result.convertedLunarDate, const KoreanLunarDate(2024, 1, 1));
      expect(result.convertedLunarLeapMonth, isFalse);
      expect(result.birthUtcInstant, DateTime.utc(2024, 2, 10, 1));
      expect(
        result.effectiveHourCalculationTime,
        DateTime.utc(2024, 2, 10, 9, 30),
      );

      final unknown = engine.calculate(
        SajuBirthInput.solar(date: const SajuLocalDate(2024, 2, 10)),
      );
      expect(unknown.birthUtcInstant, isNull);
      expect(unknown.effectiveHourCalculationTime, isNull);
    });

    test('calculatedAt is UTC and excluded from deterministic signature', () {
      final input = SajuBirthInput.solar(
        date: const SajuLocalDate(2024, 2, 10),
        time: const SajuLocalTime(10, 0),
      );
      final first = engine.calculate(
        input,
        calculatedAt: DateTime.utc(2026, 1, 1),
      );
      final second = engine.calculate(
        input,
        calculatedAt: DateTime.utc(2026, 2, 1),
      );
      expect(first.calculatedAt.isUtc, isTrue);
      expect(second.calculatedAt.isUtc, isTrue);
      expect(first.calculatedAt, isNot(second.calculatedAt));
      expect(first.deterministicSignature, second.deterministicSignature);
    });
  });
}
