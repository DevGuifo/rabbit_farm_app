import 'package:flutter/material.dart';

/// Système de design unifié BunnyManager - Style Simple et Professionnel
/// Fusion centralisée de toutes les constantes de thème
/// Utilisé dans tous les écrans et widgets pour cohérence visuelle
class AppTheme {
  // ============================================
  // 🎨 PALETTE DE COULEURS UNIFIÉE
  // ============================================

  // PRIMAIRES - Couleur principale (Vert naturel)
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryGreenLight = Color(0xFF81C784);
  static const Color primaryGreenDark = Color(0xFF388E3C);

  // SECONDAIRES
  static const Color primaryYellow = Color(0xFFF9F506); // FAB, accents
  static const Color primaryYellowDark = Color(0xFFE6E205);
  static const Color primaryNeonGreen = Color(0xFF13EC25); // Reproduction
  static const Color primaryNeonGreenDark = Color(0xFF10B01D);

  // TEXTES
  static const Color textPrimary = Color(0xFF181811); // Noir
  static const Color textSecondary = Color(0xFF616161); // Gris
  static const Color textTertiary = Color(0xFF9E9E9E); // Gris clair
  // textLight sera défini après les couleurs Stitch pour utiliser stitchTextMainDark
  static const Color textOnPrimary = Color(0xFF181811); // Noir sur jaune

  // FONDS - Light mode
  static const Color backgroundLight = Color(0xFFF8F8F5); // Beige clair
  static const Color bgLight = Color(0xFFF5F5F5);
  static const Color cardLight = Color(0xFFFFFFFF); // Blanc pur
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color backgroundWhite = Color(0xFFFFFFFF);

  // Variantes Stitch (définies en premier pour être utilisées par les alias)
  static const Color stitchBackgroundLight = Color(0xFFF6F8F6);
  static const Color stitchBackgroundDark = Color(0xFF102212);
  static const Color stitchSurfaceLight = Color(0xFFFFFFFF);
  static const Color stitchSurfaceDark = Color(0xFF1A331D);
  static const Color stitchTextMainLight = Color(0xFF111812);
  static const Color stitchTextMainDark = Color(0xFFE0E6E0);
  static const Color stitchTextSecLight = Color(0xFF618965);
  static const Color stitchTextSecDark = Color(0xFF8BA88E);
  static const Color stitchBorderLight = Color(0xFFF3F4F6);
  static const Color stitchBorderDark = Color(0xFF1F2937);

  // FONDS - Dark mode (utilise les couleurs Stitch pour cohérence avec la page localisation)
  static const Color backgroundDarkMode =
      stitchBackgroundDark; // Color(0xFF102212) - Stitch background-dark
  static const Color bgDark =
      stitchBackgroundDark; // Color(0xFF102212) - Stitch background-dark
  static const Color cardDark =
      stitchSurfaceDark; // Color(0xFF1A331D) - Stitch surface-dark

  // TEXTES - Dark mode (utilise les couleurs Stitch pour cohérence)
  static const Color textLight =
      stitchTextMainDark; // Color(0xFFE0E6E0) - Stitch text-main-dark

  // ÉTATS & ACCENTS
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF42A5F5);
  static const Color accentCyan = Color(0xFF42A5F5);
  static const Color accentOrange = Color(0xFFFFB84D);
  static const Color accentRed = Color(0xFFE74C3C);
  static const Color accentPink = Color(0xFFFF6B9D);
  static const Color accentAmber = Color(0xFFFFA726);
  static const Color accentTeal = Color(0xFF26A69A);

  // BORDURES & DIVIDERS
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // ALIASES RÉTROCOMPATIBILITÉ
  static const Color neonGreen = primaryGreen;
  static const Color neonGreenLight = primaryGreenLight;
  static const Color neonGreenDark = primaryGreenDark;
  static const Color softWhite = backgroundWhite;
  static const Color surfaceLight = surfaceWhite;
  static const Color secondaryGrey = Color(0xFF757575);
  static const Color secondaryGreyLight = Color(0xFF9E9E9E);
  static const Color secondaryGreyDark = Color(0xFF616161);
  static const Color secondaryBrown = secondaryGrey;
  static const Color backgroundDark = backgroundDarkMode;
  static const Color darkGrey = secondaryGreyDark;
  static const Color darkGreyLight = secondaryGreyLight;
  static const Color cardWhite = cardLight;

  // ============================================
  // 📏 ESPACEMENT STANDARDISÉ
  // ============================================
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;

  // ============================================
  // 🔘 BORDER RADIUS STANDARDISÉ
  // ============================================
  static const double radiusSmall = 12.0; // Petits éléments
  static const double radiusMedium = 20.0; // Inputs, boutons
  static const double radiusLarge = 32.0; // Cards principales
  static const double radiusXL = 40.0; // XL cards
  static const double radiusRound = 999.0; // Pills, search bar

  // ============================================
  // 💫 ÉLÉVATIONS (OMBRES LÉGÈRES)
  // ============================================
  static List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ============================================
  // 📝 TYPOGRAPHIE
  // ============================================
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
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
  // 🎨 THÈME FLUTTER COMPLET - MODE CLAIR
  // ============================================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Couleurs
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      primaryContainer: primaryGreenLight,
      secondary: secondaryGrey,
      secondaryContainer: secondaryGreyLight,
      tertiary: info,
      surface: surfaceWhite,
      surfaceContainerHighest: backgroundLight,
      error: error,
      onPrimary: textOnPrimary,
      onSecondary: textOnPrimary,
      onSurface: textPrimary,
      outline: border,
    ),

    // Scaffold
    scaffoldBackgroundColor: backgroundLight,

    // AppBar
    appBarTheme: AppBarThemeData(
      elevation: 0,
      centerTitle: false,
      backgroundColor: surfaceWhite,
      foregroundColor: textPrimary,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: primaryGreen, size: 24),
    ),

    // Card
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardWhite,
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
      fillColor: surfaceWhite,
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
      backgroundColor: surfaceWhite,
      indicatorColor: primaryGreenLight.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return labelMedium.copyWith(color: primaryGreen);
        }
        return labelMedium.copyWith(color: textSecondary);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
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
      backgroundColor: surfaceWhite,
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
  // 🌙 THÈME SOMBRE STITCH (identique à la page localisation)
  // ============================================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Couleurs mode sombre Stitch
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      primaryContainer: primaryGreenDark,
      secondary: secondaryGreyLight,
      secondaryContainer: secondaryGreyDark,
      tertiary: info,
      surface: stitchSurfaceDark,
      surfaceContainerHighest: stitchBackgroundDark,
      error: error,
      onPrimary: textPrimary,
      onSecondary: textPrimary,
      onSurface: stitchTextMainDark,
      outline: stitchBorderDark,
    ),

    // Scaffold
    scaffoldBackgroundColor: stitchBackgroundDark,

    // AppBar
    appBarTheme: AppBarThemeData(
      elevation: 0,
      centerTitle: false,
      backgroundColor: stitchSurfaceDark,
      foregroundColor: stitchTextMainDark,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: stitchTextMainDark,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: primaryGreen, size: 24),
    ),

    // Card
    cardTheme: CardThemeData(
      elevation: 0,
      color: stitchSurfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        side: const BorderSide(color: stitchBorderDark, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: spacing8),
    ),

    // Boutons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryGreen,
        foregroundColor: textPrimary,
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
        foregroundColor: textPrimary,
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
      fillColor: stitchSurfaceDark,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: stitchBorderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: stitchBorderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error),
      ),
      labelStyle: bodyMedium.copyWith(color: stitchTextSecDark),
      hintStyle: bodyMedium.copyWith(color: stitchTextSecDark),
    ),

    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: textPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),

    // Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: stitchSurfaceDark,
      indicatorColor: primaryGreen.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return labelMedium.copyWith(color: primaryGreen);
        }
        return labelMedium.copyWith(color: stitchTextSecDark);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryGreen, size: 24);
        }
        return const IconThemeData(color: stitchTextSecDark, size: 24);
      }),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: stitchBorderDark,
      thickness: 1,
      space: spacing16,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: stitchSurfaceDark,
      selectedColor: primaryGreenDark,
      labelStyle: labelMedium.copyWith(color: stitchTextMainDark),
      padding: const EdgeInsets.symmetric(
        horizontal: spacing12,
        vertical: spacing8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        side: const BorderSide(color: stitchBorderDark),
      ),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: stitchSurfaceDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        side: const BorderSide(color: stitchBorderDark, width: 1),
      ),
      titleTextStyle: headingMedium.copyWith(color: stitchTextMainDark),
      contentTextStyle: bodyMedium.copyWith(color: stitchTextMainDark),
    ),

    // Bottom Sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: stitchSurfaceDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLarge)),
      ),
      modalBackgroundColor: stitchSurfaceDark,
    ),
  );

  // ============================================
  // 🎨 DECORATIONS DE BOÎTE (Helper methods)
  // ============================================

  /// Card standard design (utilisé partout)
  static BoxDecoration cardDecoration({
    required bool isDark,
    Color? borderColor,
    double? borderRadius,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: isDark ? stitchSurfaceDark : cardLight,
      borderRadius: BorderRadius.circular(borderRadius ?? radiusLarge),
      border: Border.all(
        color:
            borderColor ??
            (isDark ? stitchBorderDark : Colors.black.withValues(alpha: 0.08)),
      ),
      boxShadow: shadows ?? shadowSmall,
    );
  }

  /// Header container (sticky pattern)
  static BoxDecoration headerDecoration({required bool isDark}) {
    return BoxDecoration(
      color: (isDark ? stitchBackgroundDark : backgroundLight).withValues(
        alpha: 0.95,
      ),
      border: Border(
        bottom: BorderSide(
          color: isDark ? stitchBorderDark : Colors.grey.shade100,
          width: 1,
        ),
      ),
    );
  }

  /// Action card avec icône colorée
  static BoxDecoration actionCardDecoration({required bool isDark}) {
    return BoxDecoration(
      color: isDark ? stitchSurfaceDark : cardLight,
      borderRadius: BorderRadius.circular(radiusLarge),
      border: Border.all(
        color: isDark ? stitchBorderDark : Colors.black.withValues(alpha: 0.08),
      ),
      boxShadow: shadowSmall,
    );
  }

  // ============================================
  // 🎨 OMBRES (Shadow helpers)
  // ============================================

  static List<BoxShadow> cardShadow({Color? color, bool isDark = false}) {
    return [
      BoxShadow(
        color: (color ?? Colors.black).withValues(alpha: isDark ? 0.15 : 0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> elevatedShadow({bool isDark = false}) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // ============================================
  // 🔘 STYLES DE BOUTONS (Helper methods)
  // ============================================

  static ButtonStyle primaryButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: spacing24,
        vertical: spacing12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    );
  }

  static ButtonStyle secondaryButtonStyle({required bool isDark}) {
    return OutlinedButton.styleFrom(
      foregroundColor: isDark ? textLight : textPrimary,
      side: BorderSide(
        color: isDark
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.1),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: spacing24,
        vertical: spacing12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    );
  }

  // ============================================
  // 📝 INPUT DECORATION (Helper method)
  // ============================================

  static InputDecoration modernInput({
    required String label,
    String? hint,
    IconData? prefixIcon,
    required bool isDark,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: primaryGreen)
          : null,
      filled: true,
      fillColor: isDark ? stitchSurfaceDark : const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(
          color: isDark ? stitchBorderDark : Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(
          color: isDark ? stitchBorderDark : Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      labelStyle: TextStyle(color: isDark ? stitchTextSecDark : textSecondary),
    );
  }

  // ============================================
  // Helper methods (pour rétrocompatibilité)
  // ============================================

  /// Styles de texte pour rétrocompatibilité
  static const TextStyle titleLarge = headingLarge;
  static const TextStyle titleMedium = headingMedium;
  static const TextStyle titleSmall = headingSmall;
  static const TextStyle caption = labelSmall;

  /// Border
  static BoxBorder cardBorder(Color color) {
    return Border.all(color: color.withValues(alpha: 0.3), width: 1);
  }

  /// Chip moderne
  static Widget modernChip({
    required String label,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Divider moderne
  static Widget modernDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.grey.shade300,
    );
  }

  /// Card moderne (rétrocompatibilité)
  static BoxDecoration modernCard({
    Color accentColor = primaryGreen,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      border: cardBorder(accentColor),
      boxShadow: cardShadow(color: accentColor),
    );
  }

  /// Button moderne (rétrocompatibilité)
  static ButtonStyle modernButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  /// Input decoration moderne (rétrocompatibilité)
  static InputDecoration modernInputDecoration({
    required String label,
    String? hint,
    IconData? icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: primaryGreen) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      labelStyle: const TextStyle(color: textSecondary),
    );
  }
}
