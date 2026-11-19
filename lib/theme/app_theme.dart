import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_text.dart';

/// Warm Ember themes. `bangla: true` switches the base font family to
/// AnekBangla (Bricolage/Geist have no Bengali glyphs); AnekBangla is always
/// in `fontFamilyFallback` so Bangla text renders in every style.
class AppTheme {
  AppTheme._();

  static ThemeData light({bool bangla = false}) =>
      _build(Brightness.light, bangla: bangla);

  static ThemeData dark({bool bangla = false}) =>
      _build(Brightness.dark, bangla: bangla);

  /// Convenience for app.dart: pick theme by locale + brightness.
  static ThemeData forLocale(Locale locale, Brightness brightness) {
    final bangla = locale.languageCode == 'bn';
    return brightness == Brightness.dark
        ? dark(bangla: bangla)
        : light(bangla: bangla);
  }

  static ThemeData _build(Brightness brightness, {required bool bangla}) {
    final isDark = brightness == Brightness.dark;
    final cs = isDark ? CsScheme.dark() : CsScheme.light();
    final fontFamily = bangla ? AppFonts.bangla : AppFonts.ui;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      fontFamilyFallback: const [AppFonts.bangla, AppFonts.ui],
      scaffoldBackgroundColor: cs.canvas,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: cs.primary,
        onPrimary: cs.onPrimary,
        secondary: cs.teal,
        onSecondary: AppColors.ink,
        surface: cs.surface,
        onSurface: cs.textPrimary,
        error: cs.danger,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cs.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.h3.copyWith(color: cs.textPrimary),
        iconTheme: IconThemeData(color: cs.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.sunken,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.borderHairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.borderHairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.danger),
        ),
        hintStyle: AppText.body.copyWith(color: cs.textTertiary),
        labelStyle: AppText.bodySmall.copyWith(color: cs.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          textStyle: AppText.button,
          // NOTE: min width must be FINITE. Size.fromHeight(56) is
          // Size(infinity, 56): any non-full-width button in a Row
          // (editor Run, checkout Apply, dialog actions) then gets
          // infinite-width constraints and throws during layout.
          minimumSize: const Size(64, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.accent,
          textStyle: AppText.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.textPrimary,
          side: BorderSide(color: cs.border),
          textStyle: AppText.button,
          // Finite min width (see the elevatedButtonTheme note above).
          minimumSize: const Size(64, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cs.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: cs.borderHairline),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.surface,
        selectedColor: AppColors.peachLight,
        labelStyle: AppText.label.copyWith(color: cs.textPrimary),
        side: BorderSide(color: cs.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      dividerTheme: DividerThemeData(color: cs.borderHairline, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: AppColors.peachLight,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppText.caption.copyWith(
            color: states.contains(WidgetState.selected)
                ? cs.accent
                : cs.textSecondary,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? cs.accent
                : cs.textSecondary,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? cs.onPrimary
              : cs.textTertiary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? cs.primary
              : cs.border,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: cs.primary),
      sliderTheme: SliderThemeData(
        activeTrackColor: cs.primary,
        inactiveTrackColor: cs.border,
        thumbColor: cs.primary,
      ),
    );
  }
}
