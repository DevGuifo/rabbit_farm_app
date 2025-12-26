import 'package:flutter/material.dart';

/// Système de design unifié BunnyManager
/// Palette moderne, cohérente et professionnelle
class AppTheme {
  // ============================================
  // 🎨 PALETTE DE COULEURS PRINCIPALE
  // ============================================

  // Couleurs primaires (vert futuriste)
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryGreenLight = Color(0xFF81C784);
  static const Color primaryGreenDark = Color(0xFF388E3C);

  // Couleurs secondaires (brun naturel)
  static const Color secondaryBrown = Color(0xFF8D6E63);
  static const Color secondaryBrownLight = Color(0xFFBCAAA4);
  static const Color secondaryBrownDark = Color(0xFF5D4037);

  // Couleurs d'accent
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color accentOrange = Color(0xFFFF9800);

  // Neutres modernes
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF1E2329);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2D3339);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2D3339);

  // Textes
  static const Color textPrimary = Color(0xFF1E2329);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // États
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Bordures et dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // ============================================
  // 📏 ESPACEMENT COHÉRENT
  // ============================================
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // ============================================
  // 🔘 BORDER RADIUS
  // ============================================
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusRound = 999.0;

  // ============================================
  // 💫 ÉLÉVATIONS (OMBRES)
  // ============================================
  static List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // ============================================
  // 📝 TYPOGRAPHIE
  // ============================================
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );

  // ============================================
  // 🎨 THÈME FLUTTER COMPLET
  // ============================================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Couleurs
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      primaryContainer: primaryGreenLight,
      secondary: secondaryBrown,
      secondaryContainer: secondaryBrownLight,
      surface: surfaceLight,
      background: backgroundLight,
      error: error,
      onPrimary: textOnPrimary,
      onSecondary: textOnPrimary,
      onSurface: textPrimary,
      onBackground: textPrimary,
    ),

    // Scaffold
    scaffoldBackgroundColor: backgroundLight,

    // AppBar
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: surfaceLight,
      foregroundColor: textPrimary,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: textPrimary, size: 24),
    ),

    // Card
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        side: const BorderSide(color: border, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: spacing8),
    ),

    // Boutons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryGreen,
        foregroundColor: textOnPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: labelLarge,
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryGreen,
        foregroundColor: textOnPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: labelLarge,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing16,
        ),
        side: const BorderSide(color: primaryGreen, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: labelLarge,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing12,
        ),
        textStyle: labelLarge,
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error),
      ),
      labelStyle: bodyMedium.copyWith(color: textSecondary),
      hintStyle: bodyMedium.copyWith(color: textTertiary),
    ),

    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: textOnPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),

    // Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: surfaceLight,
      indicatorColor: primaryGreenLight.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return labelMedium.copyWith(color: primaryGreen);
        }
        return labelMedium.copyWith(color: textSecondary);
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: primaryGreen, size: 24);
        }
        return const IconThemeData(color: textSecondary, size: 24);
      }),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: divider,
      thickness: 1,
      space: spacing16,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: surfaceLight,
      selectedColor: primaryGreenLight,
      labelStyle: labelMedium,
      padding: const EdgeInsets.symmetric(
        horizontal: spacing12,
        vertical: spacing8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        side: const BorderSide(color: border),
      ),
    ),
  );

  // ============================================
  // 🌙 THÈME SOMBRE
  // ============================================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Couleurs mode sombre
    colorScheme: const ColorScheme.dark(
      primary: primaryGreenLight,
      primaryContainer: primaryGreenDark,
      secondary: secondaryBrownLight,
      secondaryContainer: secondaryBrownDark,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      error: error,
      onPrimary: Color(0xFF000000),
      onSecondary: Color(0xFF000000),
      onSurface: Color(0xFFFFFFFF),
      onBackground: Color(0xFFFFFFFF),
    ),

    // Scaffold
    scaffoldBackgroundColor: const Color(0xFF121212),

    // AppBar
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Color(0xFFFFFFFF),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFFFFFF),
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: Color(0xFFFFFFFF), size: 24),
    ),

    // Card
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF2D3339),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        side: const BorderSide(color: Color(0xFF3D4349), width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: spacing8),
    ),

    // Boutons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryGreenLight,
        foregroundColor: const Color(0xFF000000),
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: labelLarge,
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryGreenLight,
        foregroundColor: const Color(0xFF000000),
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: labelLarge,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreenLight,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing16,
        ),
        side: const BorderSide(color: primaryGreenLight, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: labelLarge,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreenLight,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing12,
        ),
        textStyle: labelLarge,
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2D3339),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: Color(0xFF3D4349)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: Color(0xFF3D4349)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryGreenLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error),
      ),
      labelStyle: bodyMedium.copyWith(color: const Color(0xFFB0B0B0)),
      hintStyle: bodyMedium.copyWith(color: const Color(0xFF808080)),
    ),

    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryGreenLight,
      foregroundColor: const Color(0xFF000000),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),

    // Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: const Color(0xFF1E1E1E),
      indicatorColor: primaryGreenLight.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return labelMedium.copyWith(color: primaryGreenLight);
        }
        return labelMedium.copyWith(color: const Color(0xFFB0B0B0));
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: primaryGreenLight, size: 24);
        }
        return const IconThemeData(color: Color(0xFFB0B0B0), size: 24);
      }),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: Color(0xFF3D4349),
      thickness: 1,
      space: spacing16,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2D3339),
      selectedColor: primaryGreenDark,
      labelStyle: labelMedium.copyWith(color: const Color(0xFFFFFFFF)),
      padding: const EdgeInsets.symmetric(
        horizontal: spacing12,
        vertical: spacing8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        side: const BorderSide(color: Color(0xFF3D4349)),
      ),
    ),
  );
}
