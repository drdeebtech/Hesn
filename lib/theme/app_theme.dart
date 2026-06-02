import 'package:flutter/material.dart';

/// Non-Material-3 semantic colors (completed/success, timeout/warning, skip),
/// carried as a [ThemeExtension] so widgets read
/// `Theme.of(context).extension<HesnColors>()!`.
@immutable
class HesnColors extends ThemeExtension<HesnColors> {
  const HesnColors({
    required this.success,
    required this.warning,
    required this.skip,
  });

  final Color success; // completed
  final Color warning; // timeout emphasis
  final Color skip; // تجاوز

  static const light = HesnColors(
    success: Color(0xFF1E9E5A),
    warning: Color(0xFFE08A00),
    skip: Color(0xFFB4533A),
  );
  static const dark = HesnColors(
    success: Color(0xFF39C97A),
    warning: Color(0xFFFFB23E),
    skip: Color(0xFFE07A5F),
  );

  @override
  HesnColors copyWith({Color? success, Color? warning, Color? skip}) =>
      HesnColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        skip: skip ?? this.skip,
      );

  @override
  HesnColors lerp(ThemeExtension<HesnColors>? other, double t) {
    if (other is! HesnColors) return this;
    return HesnColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      skip: Color.lerp(skip, other.skip, t)!,
    );
  }
}

/// Modern, bold, high-contrast Arabic-RTL theme with a first-class dark mode
/// for night driving. Azkar text uses bundled Amiri; UI chrome uses the
/// platform sans.
class AppTheme {
  static const fontFamily = 'Amiri';

  // Azkar text styles — referenced directly in the Session widgets.
  static const azkarDisplay = TextStyle(
      fontFamily: fontFamily,
      fontSize: 40,
      fontWeight: FontWeight.w700,
      height: 1.85);
  static const azkarQuran = TextStyle(
      fontFamily: fontFamily,
      fontSize: 34,
      fontWeight: FontWeight.w400,
      height: 2.0);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0E7A63),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFB7E6D8),
    onPrimaryContainer: Color(0xFF00251C),
    secondary: Color(0xFFC9A227),
    onSecondary: Color(0xFF1F1A00),
    tertiary: Color(0xFFB4533A),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFB4533A),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF10211C),
    surfaceContainerHighest: Color(0xFFE6EDE8),
    onSurfaceVariant: Color(0xFF5A6B64),
    outline: Color(0xFFC3D0CA),
    outlineVariant: Color(0xFFDCE6E0),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF3FBF9E),
    onPrimary: Color(0xFF03110D),
    primaryContainer: Color(0xFF0E5343),
    onPrimaryContainer: Color(0xFFB7E6D8),
    secondary: Color(0xFFE3C35A),
    onSecondary: Color(0xFF1F1A00),
    tertiary: Color(0xFFE07A5F),
    onTertiary: Color(0xFF2A0E06),
    error: Color(0xFFE07A5F),
    onError: Color(0xFF2A0E06),
    surface: Color(0xFF13201C),
    onSurface: Color(0xFFECF3EF),
    surfaceContainerHighest: Color(0xFF1E2F2A),
    onSurfaceVariant: Color(0xFF9DB0A8),
    outline: Color(0xFF34453F),
    outlineVariant: Color(0xFF26352F),
  );

  static TextTheme _text(ColorScheme cs) => TextTheme(
        titleLarge: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, height: 1.2, color: cs.onSurface),
        titleMedium: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700, height: 1.25, color: cs.onSurface),
        bodyLarge: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w400, height: 1.4, color: cs.onSurface),
        bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.35,
            letterSpacing: .1,
            color: cs.onSurfaceVariant),
        labelLarge: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, height: 1.0, letterSpacing: .3),
      );

  static ThemeData _build(ColorScheme cs, Color scaffold, HesnColors hesn) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: scaffold,
      fontFamily: null, // UI sans by default; Amiri applied explicitly
      textTheme: _text(cs),
      extensions: [hesn],
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: cs.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outline, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(72),
          textStyle: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: .3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(72),
          foregroundColor: hesn.skip,
          side: BorderSide(color: hesn.skip, width: 1.5),
          textStyle: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: .3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: hesn.success,
        linearTrackColor: cs.surfaceContainerHighest,
        linearMinHeight: 8,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: cs.primary,
        inactiveTrackColor: cs.surfaceContainerHighest,
        thumbColor: cs.primary,
        trackHeight: 6,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? cs.onPrimary : cs.outline),
        trackColor: WidgetStateProperty.resolveWith((s) => s
                .contains(WidgetState.selected)
            ? cs.primary
            : cs.surfaceContainerHighest),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        labelStyle: TextStyle(
            color: cs.secondary, fontSize: 18, fontWeight: FontWeight.w700),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
      dividerTheme: DividerThemeData(color: cs.outlineVariant, thickness: 1),
    );
  }

  static ThemeData light() =>
      _build(_lightScheme, const Color(0xFFF5F7F4), HesnColors.light);
  static ThemeData dark() =>
      _build(_darkScheme, const Color(0xFF0B1311), HesnColors.dark);
}
