import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/saju/domain/daeun_seun_calculation_engine.dart';
import 'package:ryn_universe_os_core/features/saju/domain/daeun_seun_models.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_calculation_engine.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_models.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_snapshot.dart';
import 'package:ryn_universe_os_core/features/saju/domain/solar_term_calculator.dart';
import 'package:ryn_universe_os_core/features/saju/domain/ten_gods.dart';

void main() {
  final baseEngine = SajuCalculationEngine.production(
    utcNow: () => DateTime.utc(2026, 8, 1),
  );
  final engine = DaeunSeunCalculationEngine.production();

  SajuChartSnapshot snapshot({
    required int year,
    required int month,
    required int day,
    SajuLocalTime? time,
    required SajuGender gender,
  }) => baseEngine.calculate(
    SajuBirthInput.solar(
      date: SajuLocalDate(year, month, day),
      time: time,
      gender: gender,
    ),
  );

  SajuLocalTime timeFromWallClock(DateTime value) => SajuLocalTime(
    value.hour,
    value.minute,
    second: value.second,
    microsecond: value.millisecond * 1000 + value.microsecond,
  );

  group('direction and Daeun arithmetic', () {
    test('direction uses persisted year stem rather than day stem', () {
      final first = engine.calculateDaeun(
        snapshot(
          year: 1990,
          month: 3,
          day: 15,
          time: const SajuLocalTime(10, 30),
          gender: SajuGender.male,
        ),
      );
      final nextDay = engine.calculateDaeun(
        snapshot(
          year: 1990,
          month: 3,
          day: 16,
          time: const SajuLocalTime(10, 30),
          gender: SajuGender.male,
        ),
      );
      expect(first.direction, DaeunDirection.forward);
      expect(nextDay.direction, DaeunDirection.forward);
      expect(
        first.metadata.baseDayPillarId,
        isNot(nextDay.metadata.baseDayPillarId),
      );
    });

    test('unspecified gender fails closed', () {
      final value = snapshot(
        year: 2024,
        month: 3,
        day: 5,
        time: const SajuLocalTime(11, 21),
        gender: SajuGender.unspecified,
      );
      expect(
        () => engine.calculateDaeun(value),
        throwsA(
          isA<DaeunSeunCalculationException>().having(
            (error) => error.code,
            'code',
            DaeunSeunErrorCode.genderRequired,
          ),
        ),
      );
    });

    test('nearest integer, minimum one, and no maximum clamp are explicit', () {
      expect(
        DaeunSeunCalculationEngine.daeunNumberFromInterval(
          const Duration(days: 20, hours: 23, minutes: 42),
        ),
        7,
      );
      expect(
        DaeunSeunCalculationEngine.daeunNumberFromInterval(
          const Duration(seconds: 1),
        ),
        1,
      );
      expect(
        DaeunSeunCalculationEngine.daeunNumberFromInterval(
          const Duration(days: 33),
        ),
        11,
      );
      expect(
        () => DaeunSeunCalculationEngine.daeunNumberFromInterval(
          const Duration(microseconds: -1),
        ),
        throwsA(
          isA<DaeunSeunCalculationException>().having(
            (error) => error.code,
            'code',
            DaeunSeunErrorCode.invalidInterval,
          ),
        ),
      );
    });

    test('HHMM births cannot land on an exact rounding tie in range', () {
      final calculator = RynSolarTermCalculator.production();
      var termCount = 0;
      for (var year = 1989; year <= 2050; year++) {
        for (final term in SajuSolarTerm.values) {
          final instant = calculator.utcInstant(year, term);
          termCount++;
          expect(
            instant.second != 0 ||
                instant.millisecond != 0 ||
                instant.microsecond != 0,
            isTrue,
            reason: '$year ${term.name}',
          );
        }
      }
      expect(termCount, 744);
    });

    test(
      'eleven cycles wrap canonically and carry age, year, gods, elements',
      () {
        final result = engine.calculateDaeun(
          snapshot(
            year: 2023,
            month: 6,
            day: 15,
            time: const SajuLocalTime(10, 30),
            gender: SajuGender.female,
          ),
        );
        expect(result.cycles, hasLength(11));
        expect(result.cycles.first.sequence, 1);
        expect(result.cycles.first.pillar.hanja, '己未');
        expect(result.cycles.first.startTraditionalAge, 7);
        expect(result.cycles.first.startYear, 2029);
        expect(result.cycles.first.endYearExclusive, 2039);
        expect(result.cycles.first.heavenlyStemTenGod, SajuTenGod.properWealth);
        expect(
          result.cycles.first.earthlyBranchMainQiTenGod,
          SajuTenGod.properWealth,
        );
        expect(result.cycles.first.stemFiveElement, SajuFiveElement.earth);
        expect(result.cycles.first.branchFiveElement, SajuFiveElement.earth);
        expect(
          result.cycles.map((cycle) => cycle.startYear),
          orderedEquals([for (var year = 2029; year <= 2129; year += 10) year]),
        );
        expect(result.cycles[5].pillar.cycleIndex, 0);
        expect(result.cycles[5].pillar.hanja, '甲子');
        expect(result.cycles.last.startTraditionalAge, 107);
      },
    );

    test('repeated calculation has the same deterministic payload', () {
      final value = snapshot(
        year: 1990,
        month: 3,
        day: 15,
        time: const SajuLocalTime(10, 30),
        gender: SajuGender.male,
      );
      final first = engine.calculateDaeun(value);
      final second = engine.calculateDaeun(value);
      expect(first.toJson(), second.toJson());
      expect(first.sourceSnapshotReference, value.deterministicSignature);
      expect(first.selectedJieUtc.isUtc, isTrue);
      expect(first.intervalMicroseconds, greaterThanOrEqualTo(0));
    });
  });

  group('unknown birth time', () {
    test(
      'U01 evaluates all 1440 HHMM candidates and returns stable result',
      () {
        final stopwatch = Stopwatch()..start();
        final result = engine.calculateDaeun(
          snapshot(year: 2023, month: 6, day: 15, gender: SajuGender.male),
        );
        stopwatch.stop();
        expect(result.direction, DaeunDirection.reverse);
        expect(result.daeunNumber, 3);
        expect(result.cycles.first.pillar.hanja, '丁巳');
        expect(result.evaluatedMinuteCandidates, 1440);
        expect(result.intervalMicroseconds, isNull);
        expect(
          result.minimumIntervalMicroseconds,
          lessThan(result.maximumIntervalMicroseconds),
        );
        expect(
          result.warnings,
          contains(DaeunSeunWarningCode.unknownTimeStableCivilDay),
        );
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 10)));
      },
    );

    test('a civil day producing multiple rounded values fails closed', () {
      final value = snapshot(
        year: 2023,
        month: 6,
        day: 10,
        gender: SajuGender.male,
      );
      expect(
        () => engine.calculateDaeun(value),
        throwsA(
          isA<DaeunSeunCalculationException>().having(
            (error) => error.code,
            'code',
            DaeunSeunErrorCode.unknownTimeAmbiguous,
          ),
        ),
      );
    });

    test(
      'known rollover windows remain rejected by the base snapshot gate',
      () {
        expect(
          () => snapshot(
            year: 2024,
            month: 5,
            day: 10,
            time: const SajuLocalTime(23, 30),
            gender: SajuGender.male,
          ),
          throwsA(
            isA<SajuCalculationException>().having(
              (error) => error.code,
              'code',
              SajuErrorCode.unresolvedDayRolloverWindow,
            ),
          ),
        );
      },
    );
  });

  group('annual-label Seun', () {
    final value = SajuCalculationEngine.production().calculate(
      SajuBirthInput.solar(
        date: const SajuLocalDate(1990, 3, 15),
        time: const SajuLocalTime(10, 30),
        gender: SajuGender.male,
      ),
    );

    test('uses canonical annual pillar, gods, and main-qi elements', () {
      final entry = engine.seunForYear(value, 2026);
      expect(entry.gregorianYear, 2026);
      expect(entry.pillar.hanja, '丙午');
      expect(entry.heavenlyStemTenGod, SajuTenGod.properResource);
      expect(entry.earthlyBranchMainQiTenGod, SajuTenGod.indirectResource);
      expect(entry.stemFiveElement, SajuFiveElement.fire);
      expect(entry.branchFiveElement, SajuFiveElement.fire);
      expect(entry.toJson().keys, isNot(contains('effectiveFromIpchun')));
      expect(entry.toJson().keys, isNot(contains('effectiveUntilNextIpchun')));
      expect(entry.toJson().keys, isNot(contains('activeAtDate')));
    });

    test('supports inclusive 1990 and 2159 annual labels', () {
      expect(engine.seunForYear(value, 1990).gregorianYear, 1990);
      expect(engine.seunForYear(value, 2159).gregorianYear, 2159);
      for (final year in [1989, 2160]) {
        expect(
          () => engine.seunForYear(value, year),
          throwsA(
            isA<DaeunSeunCalculationException>().having(
              (error) => error.code,
              'code',
              DaeunSeunErrorCode.unsupportedSeunYear,
            ),
          ),
        );
      }
    });

    test('a selected Daeun never mutates the annual pillar', () {
      final selected = engine.calculateDaeun(value).cycles.first;
      final withoutSelection = engine.seunForYear(value, 2026);
      final withSelection = engine.seunForYear(
        value,
        2026,
        selectedDaeun: selected,
      );
      expect(withSelection.toJson(), withoutSelection.toJson());
    });
  });

  group('supported forecast range', () {
    test('the last microsecond before 2050 Daeseol is supported forward', () {
      final calculator = RynSolarTermCalculator.production();
      final daeseolUtc = calculator.utcInstant(2050, SajuSolarTerm.daeseol);
      final localBoundary = daeseolUtc.add(const Duration(hours: 9));
      final before = localBoundary.subtract(const Duration(microseconds: 1));
      final result = engine.calculateDaeun(
        snapshot(
          year: before.year,
          month: before.month,
          day: before.day,
          time: timeFromWallClock(before),
          gender: SajuGender.male,
        ),
      );
      expect(result.direction, DaeunDirection.forward);
      expect(result.selectedJieUtc, daeseolUtc);
    });

    test('at and after 2050 Daeseol fail closed for forward Daeun', () {
      final calculator = RynSolarTermCalculator.production();
      final boundary = calculator
          .utcInstant(2050, SajuSolarTerm.daeseol)
          .add(const Duration(hours: 9));
      for (final local in [
        boundary,
        boundary.add(const Duration(microseconds: 1)),
      ]) {
        final value = snapshot(
          year: local.year,
          month: local.month,
          day: local.day,
          time: timeFromWallClock(local),
          gender: SajuGender.male,
        );
        expect(
          () => engine.calculateDaeun(value),
          throwsA(
            isA<DaeunSeunCalculationException>().having(
              (error) => error.code,
              'code',
              DaeunSeunErrorCode.unsupportedForecastHorizon,
            ),
          ),
        );
      }
    });

    test('reverse Daeun supports the end of 2050', () {
      final result = engine.calculateDaeun(
        snapshot(
          year: 2050,
          month: 12,
          day: 31,
          time: const SajuLocalTime(12, 0),
          gender: SajuGender.female,
        ),
      );
      expect(result.direction, DaeunDirection.reverse);
      expect(result.selectedJieUtc.isUtc, isTrue);
    });
  });
}
