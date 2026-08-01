import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ryn_universe_os_core/features/saju/domain/ten_gods.dart';
import 'package:ryn_universe_os_core/features/saju/presentation/saju_element_palette.dart';

void main() {
  double contrastRatio(Color foreground, Color background) {
    final lighter =
        foreground.computeLuminance() > background.computeLuminance()
        ? foreground.computeLuminance()
        : background.computeLuminance();
    final darker = foreground.computeLuminance() > background.computeLuminance()
        ? background.computeLuminance()
        : foreground.computeLuminance();
    return (lighter + 0.05) / (darker + 0.05);
  }

  test(
    'five-element palette keeps explicit labels and accessible contrast',
    () {
      expect(SajuFiveElement.values.map((element) => element.label), [
        '목',
        '화',
        '토',
        '금',
        '수',
      ]);

      for (final brightness in Brightness.values) {
        for (final element in SajuFiveElement.values) {
          final colors = SajuElementPalette.resolve(element, brightness);
          expect(
            contrastRatio(colors.foreground, colors.background),
            greaterThanOrEqualTo(4.5),
            reason: '${brightness.name} ${element.label}',
          );
          expect(colors.border.a, greaterThan(0));
        }
      }
    },
  );

  test('metal and water retain their owner-defined visual identities', () {
    for (final brightness in Brightness.values) {
      final metal = SajuElementPalette.resolve(
        SajuFiveElement.metal,
        brightness,
      );
      final water = SajuElementPalette.resolve(
        SajuFiveElement.water,
        brightness,
      );

      expect(metal.background.computeLuminance(), greaterThan(0.65));
      expect(metal.foreground.computeLuminance(), lessThan(0.08));
      expect(water.background.computeLuminance(), lessThan(0.03));
      expect(water.foreground.computeLuminance(), greaterThan(0.75));
    }
  });
}
