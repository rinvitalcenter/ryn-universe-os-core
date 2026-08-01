import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/saju/domain/daeun_seun_calculation_engine.dart';
import 'package:ryn_universe_os_core/features/saju/domain/daeun_seun_models.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_calculation_engine.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_models.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_snapshot.dart';

void main() {
  final baseEngine = SajuCalculationEngine.production(
    utcNow: () => DateTime.utc(2026, 8, 1),
  );
  final engine = DaeunSeunCalculationEngine.production();

  SajuChartSnapshot known({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required SajuGender gender,
  }) => baseEngine.calculate(
    SajuBirthInput.solar(
      date: SajuLocalDate(year, month, day),
      time: SajuLocalTime(hour, minute),
      gender: gender,
    ),
  );

  group('CEG-DS direction captures', () {
    final fixtures =
        <
          ({
            String id,
            int year,
            int month,
            int day,
            SajuGender gender,
            DaeunDirection direction,
            int daeunNumber,
            String? firstPillar,
          })
        >[
          (
            id: 'D01',
            year: 1990,
            month: 3,
            day: 15,
            gender: SajuGender.male,
            direction: DaeunDirection.forward,
            daeunNumber: 7,
            firstPillar: '庚辰',
          ),
          (
            id: 'D02',
            year: 1990,
            month: 3,
            day: 15,
            gender: SajuGender.female,
            direction: DaeunDirection.reverse,
            daeunNumber: 3,
            firstPillar: '戊寅',
          ),
          (
            id: 'D03',
            year: 2023,
            month: 6,
            day: 15,
            gender: SajuGender.male,
            direction: DaeunDirection.reverse,
            daeunNumber: 3,
            firstPillar: '丁巳',
          ),
          (
            id: 'D04',
            year: 2023,
            month: 6,
            day: 15,
            gender: SajuGender.female,
            direction: DaeunDirection.forward,
            daeunNumber: 7,
            firstPillar: '己未',
          ),
        ];

    for (final fixture in fixtures) {
      test('${fixture.id} follows the general direction and cycle path', () {
        final result = engine.calculateDaeun(
          known(
            year: fixture.year,
            month: fixture.month,
            day: fixture.day,
            hour: 10,
            minute: 30,
            gender: fixture.gender,
          ),
        );
        expect(result.direction, fixture.direction);
        expect(result.daeunNumber, fixture.daeunNumber);
        expect(result.cycles.first.pillar.hanja, fixture.firstPillar);
      });
    }
  });

  group('CEG-DS boundary captures', () {
    final fixtures =
        <
          ({
            String id,
            int minute,
            SajuGender gender,
            DaeunDirection direction,
            int daeunNumber,
            String firstPillar,
          })
        >[
          (
            id: 'B01',
            minute: 21,
            gender: SajuGender.male,
            direction: DaeunDirection.forward,
            daeunNumber: 1,
            firstPillar: '丁卯',
          ),
          (
            id: 'B02',
            minute: 23,
            gender: SajuGender.male,
            direction: DaeunDirection.forward,
            daeunNumber: 10,
            firstPillar: '戊辰',
          ),
          (
            id: 'B03',
            minute: 21,
            gender: SajuGender.female,
            direction: DaeunDirection.reverse,
            daeunNumber: 10,
            firstPillar: '乙丑',
          ),
          (
            id: 'B04',
            minute: 23,
            gender: SajuGender.female,
            direction: DaeunDirection.reverse,
            daeunNumber: 1,
            firstPillar: '丙寅',
          ),
        ];

    for (final fixture in fixtures) {
      test('${fixture.id} preserves Jie-side boundary behavior', () {
        final result = engine.calculateDaeun(
          known(
            year: 2024,
            month: 3,
            day: 5,
            hour: 11,
            minute: fixture.minute,
            gender: fixture.gender,
          ),
        );
        expect(result.direction, fixture.direction);
        expect(result.daeunNumber, fixture.daeunNumber);
        expect(result.cycles.first.pillar.hanja, fixture.firstPillar);
      });
    }
  });

  test('U01 remains stable without inventing an hour pillar', () {
    final source = baseEngine.calculate(
      SajuBirthInput.solar(
        date: const SajuLocalDate(2023, 6, 15),
        gender: SajuGender.male,
      ),
    );
    final result = engine.calculateDaeun(source);
    expect(source.hourPillar, isNull);
    expect(result.direction, DaeunDirection.reverse);
    expect(result.daeunNumber, 3);
    expect(result.cycles.first.pillar.hanja, '丁巳');
    expect(result.evaluatedMinuteCandidates, 1440);
  });

  group('S01-S03 annual-label contract', () {
    test('S01 produces the captured annual sequence', () {
      final source = known(
        year: 1990,
        month: 3,
        day: 15,
        hour: 10,
        minute: 30,
        gender: SajuGender.male,
      );
      final entries = [
        for (var year = 2025; year <= 2031; year++)
          engine.seunForYear(source, year),
      ];
      expect(entries.map((entry) => entry.pillar.hanja), [
        '乙巳',
        '丙午',
        '丁未',
        '戊申',
        '己酉',
        '庚戌',
        '辛亥',
      ]);
    });

    test('S02 and S03 keep annual labels across natal Ipchun boundary', () {
      final before = known(
        year: 2024,
        month: 2,
        day: 4,
        hour: 17,
        minute: 26,
        gender: SajuGender.male,
      );
      final after = known(
        year: 2024,
        month: 2,
        day: 4,
        hour: 17,
        minute: 28,
        gender: SajuGender.male,
      );
      expect(before.yearPillar.hanja, '癸卯');
      expect(after.yearPillar.hanja, '甲辰');
      expect(before.monthPillar.hanja, '乙丑');
      expect(after.monthPillar.hanja, '丙寅');
      expect(
        engine.seunForYear(before, 2026).pillar.hanja,
        engine.seunForYear(after, 2026).pillar.hanja,
      );
      expect(engine.seunForYear(before, 2026).pillar.hanja, '丙午');
    });
  });
}
