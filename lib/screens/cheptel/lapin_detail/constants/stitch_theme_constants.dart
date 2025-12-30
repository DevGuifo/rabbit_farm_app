import 'package:flutter/material.dart';

/// Constantes de thème Stitch Design System (Google Stitch)
/// Design: Rabbit Details - Yellow Primary Theme
class StitchTheme {
  // Primary Color
  static const Color primaryYellow = Color(0xFFF9F506);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF8F8F5);
  static const Color backgroundDark = Color(0xFF23220F);

  // Surfaces
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2E2D1A);

  // Outlines / Borders
  static const Color outlineLight = Color(0xFFE6E6DB);
  static const Color outlineDark = Color(0xFF403F2B);

  // Text Colors
  static const Color textLight = Color(0xFF181811);
  static const Color textDark = Color(0xFFFFFFFF);

  // Neutral Colors
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  // Status Colors
  static const Color green50 = Color(0xFFE8F5E9);
  static const Color green100 = Color(0xFFC8E6C9);
  static const Color green300 = Color(0xFF81C784);
  static const Color green600 = Color(0xFF43A047);
  static const Color green700 = Color(0xFF388E3C);
  static const Color green900 = Color(0xFF1B5E20);

  // Font Family (NOTE: Nécessite ajout dans pubspec.yaml)
  static const String fontFamily = 'Spline Sans';

  // Border Radius
  static const double radiusDefault = 16.0;
  static const double radiusLarge = 32.0;
  static const double radiusExtraLarge = 48.0;
  static const double radiusFull = 9999.0;

  // Shadows
  static List<BoxShadow> cardShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> fabShadow(Color primaryColor) {
    return [
      BoxShadow(
        color: primaryColor.withValues(alpha: 0.3),
        blurRadius: 30,
        spreadRadius: 8,
      ),
    ];
  }

  // Helper: Get background color based on theme
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }

  // Helper: Get surface color based on theme
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surfaceLight;
  }

  // Helper: Get outline color based on theme
  static Color getOutlineColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? outlineDark
        : outlineLight;
  }

  // Helper: Get text color based on theme
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textDark
        : textLight;
  }
}
