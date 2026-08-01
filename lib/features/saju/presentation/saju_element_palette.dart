import 'package:flutter/material.dart';

import '../domain/ten_gods.dart';

@immutable
final class SajuElementColors {
  const SajuElementColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

abstract final class SajuElementPalette {
  static SajuElementColors resolve(
    SajuFiveElement element,
    Brightness brightness,
  ) {
    final dark = brightness == Brightness.dark;
    return switch (element) {
      SajuFiveElement.wood => SajuElementColors(
        background: dark ? const Color(0xFF24533D) : const Color(0xFF2F6B4F),
        foreground: const Color(0xFFF7F3EA),
        border: dark ? const Color(0xFF6B9B7D) : const Color(0xFF173F2C),
      ),
      SajuFiveElement.fire => SajuElementColors(
        background: dark ? const Color(0xFF7E2927) : const Color(0xFF9D332E),
        foreground: const Color(0xFFFFF4EC),
        border: dark ? const Color(0xFFB86B63) : const Color(0xFF671E1B),
      ),
      SajuFiveElement.earth => SajuElementColors(
        background: dark ? const Color(0xFF764315) : const Color(0xFF9A5517),
        foreground: const Color(0xFFFFF5E8),
        border: dark ? const Color(0xFFB2824E) : const Color(0xFF63330B),
      ),
      SajuFiveElement.metal => SajuElementColors(
        background: dark ? const Color(0xFFDAD4C8) : const Color(0xFFEEE9DF),
        foreground: dark ? const Color(0xFF17201E) : const Color(0xFF19211F),
        border: dark ? const Color(0xFF8A8274) : const Color(0xFF8F8778),
      ),
      SajuFiveElement.water => SajuElementColors(
        background: dark ? const Color(0xFF080D10) : const Color(0xFF11171A),
        foreground: const Color(0xFFF4F1E8),
        border: dark ? const Color(0xFF66747A) : const Color(0xFF58666B),
      ),
    };
  }
}
