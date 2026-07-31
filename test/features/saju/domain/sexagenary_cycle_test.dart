import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_models.dart';
import 'package:ryn_universe_os_core/features/saju/domain/sexagenary_cycle.dart';

void main() {
  group('canonical sexagenary registry', () {
    test('contains the canonical stems, branches, and 60 unique entries', () {
      expect(SexagenaryRegistry.stems, hasLength(10));
      expect(SexagenaryRegistry.branches, hasLength(12));
      expect(
        SexagenaryRegistry.stems.map((stem) => stem.hanja).join(),
        '甲乙丙丁戊己庚辛壬癸',
      );
      expect(
        SexagenaryRegistry.branches.map((branch) => branch.hanja).join(),
        '子丑寅卯辰巳午未申酉戌亥',
      );
      expect(SexagenaryRegistry.cycle, hasLength(60));
      expect(SexagenaryRegistry.cycle.first.hanja, '甲子');
      expect(SexagenaryRegistry.cycle.first.canonicalId, 'sexagenary-00');
      expect(SexagenaryRegistry.cycle.last.hanja, '癸亥');
      expect(SexagenaryRegistry.cycle.last.canonicalId, 'sexagenary-59');
      expect(
        SexagenaryRegistry.cycle.map((entry) => entry.canonicalId).toSet(),
        hasLength(60),
      );
      expect(
        SexagenaryRegistry.cycle.map((entry) => entry.hanja).toSet(),
        hasLength(60),
      );
      expect(
        SexagenaryRegistry.cycle.map((entry) => entry.koreanLabel).toSet(),
        hasLength(60),
      );
      for (final entry in SexagenaryRegistry.cycle) {
        expect(entry.stemIndex, entry.cycleIndex % 10);
        expect(entry.branchIndex, entry.cycleIndex % 12);
      }
    });

    test('positive modulo normalizes negative values', () {
      expect(positiveModulo(-1, 60), 59);
      expect(positiveModulo(-61, 60), 59);
    });
  });

  group('day pillar', () {
    final calculator = SexagenaryCalculator();

    test('uses the explicit Gregorian JDN anchor and accepted dates', () {
      expect(calculator.dayPillar(const SajuLocalDate(2000, 1, 7)).hanja, '甲子');
      expect(
        calculator.dayPillar(const SajuLocalDate(1990, 3, 15)).hanja,
        '己卯',
      );
      expect(calculator.dayPillar(const SajuLocalDate(2024, 2, 4)).hanja, '戊戌');
      expect(calculator.dayPillar(const SajuLocalDate(2024, 3, 5)).hanja, '戊辰');
    });

    test('advances exactly one index across Gregorian leap day', () {
      final before = calculator.dayPillar(const SajuLocalDate(2024, 2, 28));
      final leap = calculator.dayPillar(const SajuLocalDate(2024, 2, 29));
      final after = calculator.dayPillar(const SajuLocalDate(2024, 3, 1));
      expect(leap.cycleIndex, (before.cycleIndex + 1) % 60);
      expect(after.cycleIndex, (leap.cycleIndex + 1) % 60);
    });
  });
}
