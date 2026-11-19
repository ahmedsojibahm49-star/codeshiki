import 'package:material_ui/material_ui.dart';

/// Warm Ember design tokens — EXACT values from the Figma design system.
/// Feature builders MUST use [CsScheme] via `context.cs.*` — never hardcode
/// hex in screens.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFF97316);
  static const Color primaryDark = Color(0xFFFF8A2A); // Dark-mode button bg
  static const Color primaryHoverLight = Color(0xFFE85D04);
  static const Color ink = Color(0xFF1C1917);
  static const Color teal = Color(0xFF2DD4BF);
  static const Color tealDark = Color(0xFF0D9488);
  static const Color peach = Color(0xFFFFD2AC);
  static const Color peachLight = Color(0xFFFFF1E6);

  // Light surfaces
  static const Color canvasLight = Color(0xFFFFF7F0);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color raisedLight = Color(0xFFFFF9F3);
  static const Color sunkenLight = Color(0xFFFDE8D8);
  static const Color textPrimaryLight = Color(0xFF1C1917);
  static const Color textSecondaryLight = Color(0xFF6E6862);
  static const Color textTertiaryLight = Color(0xFF756F69);
  static const Color accentLight = Color(0xFFC2410C);
  static const Color borderLight = Color(0xFFF5D9C4);
  static const Color borderHairlineLight = Color(0xFFFDE8D8);

  // Dark surfaces
  static const Color canvasDark = Color(0xFF1C1917);
  static const Color surfaceDark = Color(0xFF292524);
  static const Color raisedDark = Color(0xFF322D2A);
  static const Color sunkenDark = Color(0xFF171512);
  static const Color textPrimaryDark = Color(0xFFFAFAF9);
  static const Color textSecondaryDark = Color(0xFFB8B2AD);
  static const Color textTertiaryDark = Color(0xFFA8A29E);
  static const Color accentDark = Color(0xFFFF8A2A);
  static const Color borderDark = Color(0xFF3D3833);
  static const Color borderHairlineDark = Color(0xFF292524);

  // Status
  static const Color success = Color(0xFF0E7A3D);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color danger = Color(0xFFB42318);
  static const Color dangerSoft = Color(0xFFFEE4E2);
  static const Color warning = Color(0xFF8A5A00);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF1D4ED8);
  static const Color infoSoft = Color(0xFFDBEAFE);

  /// The ONLY gradient allowed in the app (Pro surfaces).
  static const Color proGradientStart = Color(0xFFFF8A2A);
  static const Color proGradientEnd = Color(0xFFE85D04);

  // Code-editor syntax colors
  static const Color synKeywordLight = Color(0xFFC2410C);
  static const Color synStringLight = Color(0xFF0F766E);
  static const Color synFunctionLight = Color(0xFF7C3AED);
  static const Color synNumberLight = Color(0xFFB45309);
  static const Color synCommentLight = Color(0xFF756F69);
  static const Color synKeywordDark = Color(0xFFFF8A2A);
  static const Color synStringDark = Color(0xFF2DD4BF);
  static const Color synFunctionDark = Color(0xFFC4B5FD);
  static const Color synNumberDark = Color(0xFFFBBF24);
  static const Color synCommentDark = Color(0xFFA8A29E);
  static const Color synEditorBgLight = Color(0xFFFFFFFF);
  static const Color synEditorBgDark = Color(0xFF1C1917);
}

/// Brightness-resolved color scheme. Access via `context.cs`.
class CsScheme {
  const CsScheme({
    required this.isDark,
    required this.canvas,
    required this.surface,
    required this.raised,
    required this.sunken,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.border,
    required this.borderHairline,
    required this.primary,
    required this.onPrimary,
    required this.teal,
    required this.success,
    required this.successSoft,
    required this.danger,
    required this.dangerSoft,
    required this.warning,
    required this.warningSoft,
    required this.info,
    required this.infoSoft,
    required this.synKeyword,
    required this.synString,
    required this.synFunction,
    required this.synNumber,
    required this.synComment,
    required this.synEditorBg,
  });

  factory CsScheme.light() => const CsScheme(
        isDark: false,
        canvas: AppColors.canvasLight,
        surface: AppColors.surfaceLight,
        raised: AppColors.raisedLight,
        sunken: AppColors.sunkenLight,
        textPrimary: AppColors.textPrimaryLight,
        textSecondary: AppColors.textSecondaryLight,
        textTertiary: AppColors.textTertiaryLight,
        accent: AppColors.accentLight,
        border: AppColors.borderLight,
        borderHairline: AppColors.borderHairlineLight,
        primary: AppColors.primary,
        onPrimary: AppColors.ink,
        teal: AppColors.tealDark,
        success: AppColors.success,
        successSoft: AppColors.successSoft,
        danger: AppColors.danger,
        dangerSoft: AppColors.dangerSoft,
        warning: AppColors.warning,
        warningSoft: AppColors.warningSoft,
        info: AppColors.info,
        infoSoft: AppColors.infoSoft,
        synKeyword: AppColors.synKeywordLight,
        synString: AppColors.synStringLight,
        synFunction: AppColors.synFunctionLight,
        synNumber: AppColors.synNumberLight,
        synComment: AppColors.synCommentLight,
        synEditorBg: AppColors.synEditorBgLight,
      );

  factory CsScheme.dark() => const CsScheme(
        isDark: true,
        canvas: AppColors.canvasDark,
        surface: AppColors.surfaceDark,
        raised: AppColors.raisedDark,
        sunken: AppColors.sunkenDark,
        textPrimary: AppColors.textPrimaryDark,
        textSecondary: AppColors.textSecondaryDark,
        textTertiary: AppColors.textTertiaryDark,
        accent: AppColors.accentDark,
        border: AppColors.borderDark,
        borderHairline: AppColors.borderHairlineDark,
        primary: AppColors.primaryDark,
        onPrimary: AppColors.ink,
        teal: AppColors.teal,
        success: AppColors.success,
        successSoft: AppColors.successSoft,
        danger: AppColors.danger,
        dangerSoft: AppColors.dangerSoft,
        warning: AppColors.warning,
        warningSoft: AppColors.warningSoft,
        info: AppColors.info,
        infoSoft: AppColors.infoSoft,
        synKeyword: AppColors.synKeywordDark,
        synString: AppColors.synStringDark,
        synFunction: AppColors.synFunctionDark,
        synNumber: AppColors.synNumberDark,
        synComment: AppColors.synCommentDark,
        synEditorBg: AppColors.synEditorBgDark,
      );

  static CsScheme of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? CsScheme.dark()
          : CsScheme.light();

  final bool isDark;
  final Color canvas;
  final Color surface;
  final Color raised;
  final Color sunken;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color border;
  final Color borderHairline;
  final Color primary;

  /// Text/icon color ON a primary (orange) background — always INK.
  /// White text on orange FAILS contrast; never use white on orange.
  final Color onPrimary;
  final Color teal;
  final Color success;
  final Color successSoft;
  final Color danger;
  final Color dangerSoft;
  final Color warning;
  final Color warningSoft;
  final Color info;
  final Color infoSoft;
  final Color synKeyword;
  final Color synString;
  final Color synFunction;
  final Color synNumber;
  final Color synComment;
  final Color synEditorBg;

  /// The ONLY gradient allowed (Pro surfaces).
  static const LinearGradient proGradient = LinearGradient(
    colors: [AppColors.proGradientStart, AppColors.proGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// `context.cs.canvas`, `.surface`, `.textPrimary`, ... — the ONLY way
/// feature screens should access colors.
extension CsSchemeExtension on BuildContext {
  CsScheme get cs => CsScheme.of(this);
}
