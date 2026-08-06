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

  test('Light metal and Dark water remain visibly calibrated', () {
    final metal = SajuElementPalette.resolve(
      SajuFiveElement.metal,
      Brightness.light,
    );
    final water = SajuElementPalette.resolve(
      SajuFiveElement.water,
      Brightness.dark,
    );

    expect(metal.background.computeLuminance(), greaterThan(0.75));
    expect(metal.foreground.computeLuminance(), lessThan(0.15));
    expect(water.background.computeLuminance(), lessThan(0.04));
    expect(water.foreground.computeLuminance(), greaterThan(0.45));
  });

  test('selection is accessible and independent from five elements', () {
    for (final brightness in Brightness.values) {
      final selection = SajuElementPalette.selection(brightness);
      expect(
        contrastRatio(selection.foreground, selection.background),
        greaterThanOrEqualTo(4.5),
      );
      for (final element in SajuFiveElement.values) {
        final colors = SajuElementPalette.resolve(element, brightness);
        expect(selection.background, isNot(colors.background));
        expect(selection.border, isNot(colors.border));
      }
    }
  });
}
