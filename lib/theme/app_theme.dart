import 'package:flutter/material.dart';

/// Arabic-first theme with a bundled Naskh font (Amiri) for correct tashkīl
/// rendering at large sizes.
class AppTheme {
  static const fontFamily = 'Amiri';

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF1B6B5A),
      brightness: Brightness.light,
      fontFamily: fontFamily,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: fontFamily),
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }
}
