import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/saju/domain/saju_policy.dart';
import 'package:ryn_universe_os_core/features/saju/domain/solar_term_calculator.dart';

void main() {
  group('UTC solar-term calculator', () {
    final calculator = RynSolarTermCalculator.production();

    test('2024 Ipchun lies inside the Owner compatibility interval', () {
      final utc = calculator.utcInstant(2024, SajuSolarTerm.ipchun);
      final kst = CheonEulGwiInModernKstPolicy.localFromUtc(utc);
      expect(utc.isUtc, isTrue);
      expect(kst.isAfter(DateTime.utc(2024, 2, 4, 17, 26)), isTrue);
      expect(kst.isAfter(DateTime.utc(2024, 2, 4, 17, 28)), isFalse);
    });

    test('2024 Gyeongchip lies inside the Owner compatibility interval', () {
      final utc = calculator.utcInstant(2024, SajuSolarTerm.gyeongchip);
      final kst = CheonEulGwiInModernKstPolicy.localFromUtc(utc);
      expect(kst.isAfter(DateTime.utc(2024, 3, 5, 11, 21)), isTrue);
      expect(kst.isAfter(DateTime.utc(2024, 3, 5, 11, 23)), isFalse);
    });

    test('repeated results are deterministic to the microsecond', () {
      final first = calculator.utcInstant(2024, SajuSolarTerm.ipchun);
      for (var iteration = 0; iteration < 20; iteration++) {
        expect(calculator.utcInstant(2024, SajuSolarTerm.ipchun), first);
      }
    });
  });
}
