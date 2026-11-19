import 'package:material_ui/material_ui.dart';

/// Font family names — the single source of truth for the UI font.
/// `ui` is 'Geist' (bundled static TTFs). If Geist ever becomes
/// unobtainable, swap this one line to 'Inter' and re-register in pubspec.
class AppFonts {
  AppFonts._();

  static const String display = 'BricolageGrotesque';
  static const String ui = 'Geist';
  static const String mono = 'JetBrainsMono';
  static const String bangla = 'AnekBangla';
}

/// Type scale. Colors are intentionally NOT baked in — screens apply
/// `context.cs.*` colors via `.copyWith(color: ...)`, so every style works
/// in Light and Dark.
class AppText {
  AppText._();

  static const TextStyle display = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w800,
    fontSize: 32,
    height: 40 / 32,
  );
  static const TextStyle h1 = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 34 / 28,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 22,
    height: 28 / 22,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 24 / 18,
  );
  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.ui,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 24 / 16,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: AppFonts.ui,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.ui,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 16 / 12,
  );
  static const TextStyle label = TextStyle(
    fontFamily: AppFonts.ui,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 20 / 14,
  );
  static const TextStyle button = TextStyle(
    fontFamily: AppFonts.ui,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 24 / 16,
  );
  static const TextStyle code = TextStyle(
    fontFamily: AppFonts.mono,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
  );
}
