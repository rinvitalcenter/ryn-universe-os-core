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

@immutable
final class SajuSelectionColors {
  const SajuSelectionColors({
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
        background: dark ? const Color(0xFF1C2C25) : const Color(0xFFEEF4EF),
        foreground: dark ? const Color(0xFF83B594) : const Color(0xFF2F654A),
        border: dark ? const Color(0xFF50755F) : const Color(0xFF71927C),
      ),
      SajuFiveElement.fire => SajuElementColors(
        background: dark ? const Color(0xFF30211F) : const Color(0xFFF8EFED),
        foreground: dark ? const Color(0xFFE08A7B) : const Color(0xFF93453B),
        border: dark ? const Color(0xFF8C5148) : const Color(0xFFAA7168),
      ),
      SajuFiveElement.earth => SajuElementColors(
        background: dark ? const Color(0xFF2B271F) : const Color(0xFFF5F0E8),
        foreground: dark ? const Color(0xFFC7A46E) : const Color(0xFF765B35),
        border: dark ? const Color(0xFF786545) : const Color(0xFF9A815C),
      ),
      SajuFiveElement.metal => SajuElementColors(
        background: dark ? const Color(0xFF292D2B) : const Color(0xFFF1F2F1),
        foreground: dark ? const Color(0xFFD5DDD7) : const Color(0xFF4D5953),
        border: dark ? const Color(0xFF7B8981) : const Color(0xFF89948E),
      ),
      SajuFiveElement.water => SajuElementColors(
        background: dark ? const Color(0xFF182B36) : const Color(0xFFEDF3F7),
        foreground: dark ? const Color(0xFF8CC2E0) : const Color(0xFF315F79),
        border: dark ? const Color(0xFF577F94) : const Color(0xFF6F91A5),
      ),
    };
  }

  static SajuSelectionColors selection(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return SajuSelectionColors(
      background: dark ? const Color(0xFF243741) : const Color(0xFFE7EEF2),
      foreground: dark ? const Color(0xFFDCECF4) : const Color(0xFF2C4D61),
      border: dark ? const Color(0xFF7295A8) : const Color(0xFF5F7F92),
    );
  }
}
