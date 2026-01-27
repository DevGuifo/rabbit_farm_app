import 'package:flutter/material.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// 🎨 DESIGN SYSTEM UNIFIÉ - BUNNYMANAGER
/// ════════════════════════════════════════════════════════════════════════════
///
/// RÈGLES STRICTES :
/// ❌ INTERDICTION de Colors.* (sauf Colors.transparent)
/// ❌ INTERDICTION de fontSize: avec valeurs numériques
/// ❌ INTERDICTION de EdgeInsets avec valeurs numériques
/// ❌ INTERDICTION de BorderRadius avec valeurs numériques
/// ❌ INTERDICTION de BoxDecoration custom par écran
///
/// ✅ Utiliser UNIQUEMENT les constantes AppTheme.*
/// ════════════════════════════════════════════════════════════════════════════

class AppTheme {
  // ════════════════════════════════════════════════════════════════════════════
  // 🎨 PALETTE DE COULEURS - SOBRE ET PROFESSIONNELLE
  // ════════════════════════════════════════════════════════════════════════════

  // PRIMAIRES - Vert naturel professionnel
  static const Color primaryGreen = Color(0xFF2E7D32); // Vert principal sobre
  static const Color primaryGreenLight = Color(0xFF4CAF50); // Vert clair
  static const Color primaryGreenDark = Color(0xFF1B5E20); // Vert foncé
  static const Color primaryNeonGreen = Color(
    0xFF4CAF50,
  ); // Accent (plus sobre)

  // SECONDAIRES - Accent professionnel
  static const Color accentGreen = Color(
    0xFF2E7D32,
  ); // Vert accent foncé (WCAG AA compliant)
  static const Color accentGreenDark = Color(0xFF1B5E20);

  // ALIAS DEPRECATED - Migration en cours
  @Deprecated('Use accentGreen instead')
  static const Color primaryYellow = accentGreen;
  @Deprecated('Use accentGreenDark instead')
  static const Color primaryYellowDark = accentGreenDark;

  // TEXTES
  static const Color textPrimary = Color(0xFF1A1A1A); // Noir profond lisible
  static const Color textSecondary = Color(0xFF5F6368); // Gris moyen
  static const Color textTertiary = Color(0xFF9AA0A6); // Gris clair
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Blanc
  static const Color textOnPrimary60 = Color(0x99FFFFFF); // Blanc 60% opacity
  static const Color textWhite = Color(0xFFFFFFFF); // Alias blanc

  // FONDS - Light mode
  static const Color backgroundLight = Color(0xFFFAFAFA); // Gris très clair
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Blanc pur
  static const Color surfaceLight = Color(0xFFF5F5F5); // Surface grise

  // FONDS - Dark mode
  static const Color backgroundDark = Color(0xFF121212); // Noir Material
  static const Color surfaceDark = Color(0xFF1E1E1E); // Surface sombre
  static const Color surfaceDarkElevated = Color(0xFF2D2D2D); // Carte sombre

  // TEXTES - Variantes d'opacité
  static const Color textPrimary12 = Color(0x1F1A1A1A); // 12% opacity
  static const Color textPrimary45 = Color(0x731A1A1A); // 45% opacity
  static const Color textPrimary54 = Color(0x8A1A1A1A); // 54% opacity
  static const Color textOnPrimary70 = Color(0xB3FFFFFF); // 70% opacity

  // ÉTATS - Couleurs sémantiques
  static const Color success = Color(0xFF2E7D32); // Vert succès
  static const Color successLight = Color(0xFFE8F5E9); // Fond succès
  static const Color warning = Color(0xFFED6C02); // Orange warning
  static const Color warningLight = Color(0xFFFFF3E0); // Fond warning
  static const Color error = Color(0xFFD32F2F); // Rouge erreur
  static const Color errorLight = Color(0xFFFFEBEE); // Fond erreur
  static const Color info = Color(0xFF0288D1); // Bleu info
  static const Color infoLight = Color(0xFFE1F5FE); // Fond info

  // ÉTATS - Nuances Success (vert)
  static const Color success50 = Color(0xFFE8F5E9);
  static const Color success100 = Color(0xFFC8E6C9);
  static const Color success200 = Color(0xFFA5D6A7);
  static const Color success300 = Color(0xFF81C784);
  static const Color success600 = Color(0xFF43A047);
  static const Color success700 = Color(0xFF388E3C);
  static const Color success800 = Color(0xFF2E7D32);
  static const Color success900 = Color(0xFF1B5E20);

  // ÉTATS - Nuances Warning (orange)
  static const Color warning50 = Color(0xFFFFF3E0);
  static const Color warning100 = Color(0xFFFFE0B2);
  static const Color warning200 = Color(0xFFFFCC80);
  static const Color warning300 = Color(0xFFFFB74D);
  static const Color warning600 = Color(0xFFFB8C00);
  static const Color warning700 = Color(0xFFF57C00);
  static const Color warning800 = Color(0xFFEF6C00);
  static const Color warning900 = Color(0xFFE65100);

  // ÉTATS - Nuances Error (rouge)
  static const Color error50 = Color(0xFFFFEBEE);
  static const Color error100 = Color(0xFFFFCDD2);
  static const Color error200 = Color(0xFFEF9A9A);
  static const Color error300 = Color(0xFFE57373);
  static const Color error600 = Color(0xFFE53935);
  static const Color error700 = Color(0xFFD32F2F);
  static const Color error800 = Color(0xFFC62828);
  static const Color error900 = Color(0xFFB71C1C);

  // ÉTATS - Nuances Info (bleu)
  static const Color info50 = Color(0xFFE1F5FE);
  static const Color info100 = Color(0xFFB3E5FC);
  static const Color info200 = Color(0xFF81D4FA);
  static const Color info300 = Color(0xFF4FC3F7);
  static const Color info600 = Color(0xFF039BE5);
  static const Color info700 = Color(0xFF0288D1);
  static const Color info800 = Color(0xFF0277BD);
  static const Color info900 = Color(0xFF01579B);

  // ACCENTS SOBRES (pour graphiques, badges)
  static const Color accentBlue = Color(0xFF1976D2);
  static const Color accentCyan = Color(0xFF0097A7);
  static const Color accentOrange = Color(0xFFE65100);
  static const Color accentRed = Color(0xFFC62828);
  static const Color accentTeal = Color(0xFF00796B);
  static const Color accentAmber = Color(0xFFF9A825);
  static const Color accentPink = Color(0xFFC2185B); // Rose sobre
  static const Color accentPurple = Color(0xFF7B1FA2); // Violet sobre

  // ACCENTS - Nuances Purple (violet)
  static const Color accentPurple50 = Color(0xFFF3E5F5);
  static const Color accentPurple100 = Color(0xFFE1BEE7);
  static const Color accentPurple200 = Color(0xFFCE93D8);
  static const Color accentPurple700 = Color(0xFF7B1FA2);
  static const Color accentPurple900 = Color(0xFF4A148C);

  // ACCENTS - Nuances Pink (rose)
  static const Color accentPink50 = Color(0xFFFCE4EC);
  static const Color accentPink100 = Color(0xFFF8BBD9);
  static const Color accentPink200 = Color(0xFFF48FB1);
  static const Color accentPink700 = Color(0xFFC2185B);
  static const Color accentPink900 = Color(0xFF880E4F);

  // ACCENTS - Nuances Orange (pour graphiques/états spéciaux)
  static const Color accentOrange50 = Color(0xFFFFF3E0);
  static const Color accentOrange100 = Color(0xFFFFE0B2);
  static const Color accentOrange200 = Color(0xFFFFCC80);
  static const Color accentOrange300 = Color(0xFFFFB74D);
  static const Color accentOrange700 = Color(0xFFE65100);

  // INFO GREY - Nuances gris informatif
  static const Color infoGrey = Color(0xFF607D8B); // Bleu-gris principal
  static const Color infoGrey50 = Color(0xFFECEFF1);
  static const Color infoGrey100 = Color(0xFFCFD8DC);
  static const Color infoGrey200 = Color(0xFFB0BEC5);
  static const Color infoGrey700 = Color(0xFF455A64);

  // TEXTES - Variantes d'opacité supplémentaires
  static const Color textPrimary87 = Color(0xDE1A1A1A); // 87% opacity

  // BORDURES
  static const Color borderLight = Color(0xFFE0E0E0); // Bordure claire
  static const Color borderDark = Color(0xFF424242); // Bordure sombre
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);

  // NEUTRES (échelle de gris)
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

  // ════════════════════════════════════════════════════════════════════════════
  // 🔄 ALIAS DE COMPATIBILITÉ (LEGACY) - À MIGRER PROGRESSIVEMENT
  // ════════════════════════════════════════════════════════════════════════════

  @Deprecated('Use backgroundLight instead')
  static const Color stitchBackgroundLight = backgroundLight;
  @Deprecated('Use backgroundDark instead')
  static const Color stitchBackgroundDark = backgroundDark;
  static const Color backgroundDarkMode = backgroundDark;
  @Deprecated('Use surfaceWhite instead')
  static const Color stitchSurfaceLight = surfaceWhite;
  @Deprecated('Use surfaceDark instead')
  static const Color stitchSurfaceDark = surfaceDark;
  @Deprecated('Use textPrimary instead')
  static const Color stitchTextMainLight = textPrimary;
  static const Color stitchTextMainDark = Color(0xFFE8E8E8);
  @Deprecated('Use textSecondary instead')
  static const Color stitchTextSecLight = textSecondary;
  static const Color stitchTextSecDark = Color(0xFFB0B0B0);
  @Deprecated('Use borderLight instead')
  static const Color stitchBorderLight = borderLight;
  @Deprecated('Use borderDark instead')
  static const Color stitchBorderDark = borderDark;

  static const Color bgLight = backgroundLight;
  static const Color bgDark = backgroundDark;
  static const Color cardLight = surfaceWhite;
  static const Color cardDark = surfaceDark;
  static const Color textLight = stitchTextMainDark;
  static const Color border = borderLight;
  static const Color divider = borderLight;

  // Palette verte legacy
  static const Color green50 = Color(0xFFE8F5E9);
  static const Color green100 = Color(0xFFC8E6C9);
  static const Color green300 = Color(0xFF81C784);
  static const Color green600 = Color(0xFF43A047);
  static const Color green700 = Color(0xFF388E3C);
  static const Color green900 = Color(0xFF1B5E20);

  static const Color neonGreen = primaryNeonGreen;
  static const Color darkGreyLight = neutral500;
  static const Color outlineLight = borderLight;
  static const Color outlineDark = borderDark;

  // ════════════════════════════════════════════════════════════════════════════
  // 🎨 COULEURS THÈME STITCHUI (Compatibilité) - DEPRECATED
  // ════════════════════════════════════════════════════════════════════════════

  // Verts stitchUI
  @Deprecated('Use accentGreen or primaryGreenLight instead')
  static const Color stitchGreen = Color(0xFF8BA88E); // Vert menthe doux
  @Deprecated('Use success100 instead')
  static const Color stitchGreenLight = Color(0xFFB4C4B7); // Vert très clair
  @Deprecated('Use primaryGreen instead')
  static const Color stitchGreenAccent = Color(0xFF618965); // Vert accent
  @Deprecated('Use primaryGreenDark instead')
  static const Color stitchGreenMuted = Color(0xFF4a704e); // Vert sourd
  @Deprecated('Use success400 instead')
  static const Color stitchGreenVivid = Color(0xFF84cc16); // Lime vif

  // Surfaces stitchUI
  @Deprecated('Use surfaceDark instead')
  static const Color stitchSurfaceDarkAlt = Color(0xFF1A2C1E); // Surface dark alt
  @Deprecated('Use surfaceDarkElevated instead')
  static const Color stitchSurfaceDarkCard = Color(0xFF2A422E); // Carte dark
  @Deprecated('Use surfaceDarkElevated instead')
  static const Color stitchSurfaceDarkElevated = Color(0xFF2a4e2d); // Elevated dark
  @Deprecated('Use surfaceLight instead')
  static const Color stitchSurfaceLightAlt = Color(0xFFDBE6DC); // Surface light alt
  @Deprecated('Use surfaceLight instead')
  static const Color stitchSurfaceLightCard = Color(0xFFdbe6dc); // Carte light

  // Textes stitchUI
  @Deprecated('Use textOnPrimary instead')
  static const Color stitchTextLight = Color(0xFFE0E6E0); // Texte clair
  @Deprecated('Use textPrimary instead')
  static const Color stitchTextDark = Color(0xFF111812); // Texte sombre
  static const Color textPrimary80 = Color(0xCC1A1A1A); // 80% opacity

  // Accents supplémentaires
  static const Color accentPurpleMaterial = Color(
    0xFF9C27B0,
  ); // Purple Material
  static const Color accentOrangeMaterial = Color(
    0xFFFF9800,
  ); // Orange Material
  static const Color accentPinkMaterial = Color(0xFFE91E63); // Pink Material
  static const Color accentOrangeVivid = Color(0xFFF97316); // Orange vif
  static const Color accentBrown = Color(0xFF8D6E63); // Marron

  // Neutres additionnels
  static const Color greyLight = Color(0xFFF3F4F6); // Gris très clair
  static const Color greyMedium = Color(0xFFCCCCCC); // Gris moyen
  static const Color greyDarkAlt = Color(0xFF3A3A3A); // Gris foncé alt
  static const Color greyDarkest = Color(0xFF1F1F1F); // Gris très foncé
  static const Color grey500 = Color(0xFF9CA3AF); // Tailwind gray-400
  static const Color grey600 = Color(0xFF6B7280); // Tailwind gray-500
  static const Color greyCard = Color(0xFF1A331D); // Card grise dark
  static const Color greyCardDark = Color(0xFF1F2937); // Card dark
  static const Color greyMuted = Color(0xFF666666);
  static const Color greyDark = Color(0xFF2A2A2A);
  static const Color greyE5 = Color(0xFFE5E5E5);

  // Success additionnels
  static const Color success400 = Color(0xFF4ADE80); // Vert clair tailwind
  static const Color success500 = Color(0xFF22C55E); // Vert tailwind
  static const Color successVivid = Color(0xFF10B01D); // Vert vif

  // Alias couleur primaire
  static const Color primary = primaryGreenLight;

  // ════════════════════════════════════════════════════════════════════════════
  // 🎨 COULEURS SPÉCIFIQUES UI
  // ════════════════════════════════════════════════════════════════════════════

  // Blancs et surfaces claires
  static const Color white = Color(0xFFFFFFFF);
  static const Color backgroundGreenVeryLight = Color(0xFFE8F5E9);
  static const Color warmLight = Color(0xFFFFF7ED); // Orange très clair
  static const Color lightF5 = Color(0xFFF5F5F5);
  static const Color purpleLight = Color(0xFFF3E5F5); // Violet très clair

  // Gris additionnels
  static const Color grey9E = Color(0xFF9E9E9E);
  static const Color grey999 = Color(0xFF999999);
  static const Color greySlate = Color(0xFF4A5568); // Slate

  // Accents UI
  static const Color accentBlue500 = Color(0xFF2196F3); // Blue Material
  static const Color accentCyan500 = Color(0xFF00BCD4); // Cyan Material
  static const Color accentPurple500 = Color(0xFFA855F7); // Purple Tailwind
  static const Color accentPink500 = Color(0xFFEC4899); // Pink Tailwind

  // Surfaces Dark spécifiques
  static const Color surfaceDarkOlive = Color(0xFF2E2D15); // Olive dark
  static const Color surfaceDarkGreen = Color(0xFF1E3A28); // Green dark
  static const Color surfaceDarkBrown = Color(0xFF3A2A1E); // Brown dark
  static const Color surfaceDarkForest = Color(0xFF1a2e1c); // Forest dark
  static const Color surfaceLightGrey = Color(0xFFe8ece8); // Grey light

  // Couleurs Auth
  static const Color authDark = Color(0xFF102212);
  static const Color authPrimary = Color(0xFF052e0a);
  static const Color authContent = Color(0xFF0a2e12);

  // ════════════════════════════════════════════════════════════════════════════
  // 🏥 COULEURS SANTÉ & UI SPÉCIFIQUES
  // ════════════════════════════════════════════════════════════════════════════

  // Splash screen
  static const Color splashGreen = Color(0xFFcfe7d1);

  // Santé - états
  static const Color santeSuccess = Color(0xFF10B981); // Emerald
  static const Color santeWarning = Color(0xFFF59E0B); // Amber
  static const Color santeError = Color(0xFFEF4444); // Red
  static const Color santeErrorAlt = Color(0xFFdc2626); // Red darker

  // Santé - surfaces
  static const Color santeSurfaceDark = Color(0xFF0F1F13);
  static const Color santeSurfaceLight = Color(0xFFF0F4F1);
  static const Color santeCardDark = Color(0xFF30342E);
  static const Color santeCardLight = Color(0xFFEFF2EB);
  static const Color santeChartDark = Color(0xFF262721);
  static const Color santeChartLight = Color(0xFFEFF1EA);
  static const Color santeChartAltDark = Color(0xFF32342a);

  // Santé - textes
  static const Color santeTextDark = Color(0xFFA0A490);
  static const Color santeTextLight = Color(0xFF5C6050);

  // Santé - graph
  static const Color santeGreenLight = Color(0xFFD9F99D); // Lime très clair
  static const Color santeGreen400 = Color(0xFF4ade80);
  static const Color santeGreen600 = Color(0xFF16a34a);

  // ════════════════════════════════════════════════════════════════════════════
  // 📏 ESPACEMENTS STANDARDISÉS
  // ════════════════════════════════════════════════════════════════════════════

  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // EdgeInsets préfabriqués
  static const EdgeInsets paddingAllSmall = EdgeInsets.all(spacing8);
  static const EdgeInsets paddingAllMedium = EdgeInsets.all(spacing16);
  static const EdgeInsets paddingAllLarge = EdgeInsets.all(spacing24);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(
    horizontal: spacing16,
  );
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(
    vertical: spacing16,
  );
  static const EdgeInsets paddingCard = EdgeInsets.all(spacing16);
  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(
    horizontal: spacing16,
    vertical: spacing8,
  );

  // SizedBox préfabriqués
  static const SizedBox verticalSpace4 = SizedBox(height: spacing4);
  static const SizedBox verticalSpace8 = SizedBox(height: spacing8);
  static const SizedBox verticalSpace12 = SizedBox(height: spacing12);
  static const SizedBox verticalSpace16 = SizedBox(height: spacing16);
  static const SizedBox verticalSpace24 = SizedBox(height: spacing24);
  static const SizedBox verticalSpace32 = SizedBox(height: spacing32);
  static const SizedBox horizontalSpace4 = SizedBox(width: spacing4);
  static const SizedBox horizontalSpace8 = SizedBox(width: spacing8);
  static const SizedBox horizontalSpace12 = SizedBox(width: spacing12);
  static const SizedBox horizontalSpace16 = SizedBox(width: spacing16);

  // ════════════════════════════════════════════════════════════════════════════
  // 🔘 BORDER RADIUS STANDARDISÉS
  // ════════════════════════════════════════════════════════════════════════════

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 999.0;
  static const double radiusFull = 999.0;
  static const double radiusDefault = 12.0;

  // BorderRadius préfabriqués
  static final BorderRadius borderRadiusSmall = BorderRadius.circular(
    radiusSmall,
  );
  static final BorderRadius borderRadiusMedium = BorderRadius.circular(
    radiusMedium,
  );
  static final BorderRadius borderRadiusLarge = BorderRadius.circular(
    radiusLarge,
  );
  static final BorderRadius borderRadiusRound = BorderRadius.circular(
    radiusRound,
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 📝 TYPOGRAPHIE STANDARDISÉE
  // ════════════════════════════════════════════════════════════════════════════

  // Display - Très grands titres
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  // Heading - Titres de sections
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body - Texte courant
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

  // Label - Boutons et champs
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Caption - Petits textes
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );

  // Alias pour compatibilité
  static const TextStyle titleLarge = headingLarge;
  static const TextStyle titleMedium = headingMedium;
  static const TextStyle titleSmall = headingSmall;

  // ════════════════════════════════════════════════════════════════════════════
  // 🎨 THÈME FLUTTER COMPLET - MODE CLAIR
  // ════════════════════════════════════════════════════════════════════════════

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      primaryContainer: green100,
      secondary: primaryGreenLight,
      secondaryContainer: green50,
      surface: surfaceWhite,
      surfaceContainerHighest: backgroundLight,
      error: error,
      onPrimary: textOnPrimary,
      onSecondary: textOnPrimary,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: borderLight,
    ),

    scaffoldBackgroundColor: backgroundLight,

    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: backgroundLight,
      foregroundColor: textPrimary,
      surfaceTintColor: backgroundLight,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      iconTheme: IconThemeData(color: textPrimary, size: 24),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: surfaceWhite,
      surfaceTintColor: surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        side: const BorderSide(color: borderLight, width: 1),
      ),
      margin: const EdgeInsets.symmetric(
        vertical: spacing8,
        horizontal: spacing16,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryGreen,
        foregroundColor: textOnPrimary,
        disabledBackgroundColor: neutral300,
        disabledForegroundColor: neutral500,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing12,
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
        side: const BorderSide(color: primaryGreen),
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing12,
        ),
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
          vertical: spacing8,
        ),
        textStyle: labelLarge,
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: textOnPrimary,
      elevation: 2,
      highlightElevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceWhite,
      contentPadding: const EdgeInsets.all(spacing16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: borderLight),
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

    chipTheme: ChipThemeData(
      backgroundColor: neutral100,
      selectedColor: green100,
      labelStyle: labelMedium,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusRound),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: spacing12,
        vertical: spacing4,
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: borderLight,
      thickness: 1,
      space: spacing16,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceWhite,
      selectedItemColor: primaryGreen,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: neutral900,
      contentTextStyle: bodyMedium.copyWith(color: textOnPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 🌙 THÈME FLUTTER COMPLET - MODE SOMBRE
  // ════════════════════════════════════════════════════════════════════════════

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: primaryGreenLight,
      primaryContainer: primaryGreenDark,
      secondary: primaryGreenLight,
      secondaryContainer: primaryGreenDark,
      surface: surfaceDark,
      surfaceContainerHighest: backgroundDark,
      error: error,
      onPrimary: textPrimary,
      onSecondary: textPrimary,
      onSurface: stitchTextMainDark,
      onSurfaceVariant: stitchTextSecDark,
      outline: borderDark,
    ),

    scaffoldBackgroundColor: backgroundDark,

    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: backgroundDark,
      foregroundColor: stitchTextMainDark,
      surfaceTintColor: backgroundDark,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: stitchTextMainDark,
      ),
      iconTheme: IconThemeData(color: stitchTextMainDark, size: 24),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: surfaceDark,
      surfaceTintColor: surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        side: const BorderSide(color: borderDark, width: 1),
      ),
      margin: const EdgeInsets.symmetric(
        vertical: spacing8,
        horizontal: spacing16,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryGreenLight,
        foregroundColor: textPrimary,
        disabledBackgroundColor: neutral800,
        disabledForegroundColor: neutral600,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing12,
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
        side: const BorderSide(color: primaryGreenLight),
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing12,
        ),
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
          vertical: spacing8,
        ),
        textStyle: labelLarge,
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryGreenLight,
      foregroundColor: textPrimary,
      elevation: 2,
      highlightElevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      contentPadding: const EdgeInsets.all(spacing16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryGreenLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error),
      ),
      labelStyle: bodyMedium.copyWith(color: stitchTextSecDark),
      hintStyle: bodyMedium.copyWith(color: neutral600),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: neutral800,
      selectedColor: primaryGreenDark,
      labelStyle: labelMedium.copyWith(color: stitchTextMainDark),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusRound),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: spacing12,
        vertical: spacing4,
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: borderDark,
      thickness: 1,
      space: spacing16,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primaryGreenLight,
      unselectedItemColor: stitchTextSecDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceDarkElevated,
      contentTextStyle: bodyMedium.copyWith(color: stitchTextMainDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 🛠️ MÉTHODES UTILITAIRES
  // ════════════════════════════════════════════════════════════════════════════

  /// Détermine si le mode sombre est actif
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Couleur de surface adaptative
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Couleur de fond adaptative
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  /// Couleur de bordure adaptative
  static Color getOutlineColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  /// Couleur de texte principale adaptative
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  /// Couleur de texte secondaire adaptative
  static Color getTextSecondaryColor(BuildContext context) {
    return isDarkMode(context) ? stitchTextSecDark : textSecondary;
  }

  /// Couleur de carte adaptative
  static Color getCardColor(BuildContext context) {
    return isDarkMode(context) ? surfaceDark : surfaceWhite;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 🎨 DÉCORATIONS STANDARDISÉES
  // ════════════════════════════════════════════════════════════════════════════

  /// Ombre légère pour cartes
  static List<BoxShadow> get shadowSmall => [
    BoxShadow(
      color: textPrimary.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  /// Ombre moyenne
  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: textPrimary.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Ombre pour FAB
  static List<BoxShadow> fabShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.25),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Ombre de carte adaptative
  static List<BoxShadow> cardShadow({bool isDark = false}) => [
    BoxShadow(
      color: (isDark ? surfaceWhite : textPrimary).withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  /// Décoration de carte standard
  static BoxDecoration cardDecoration({required bool isDark}) {
    return BoxDecoration(
      color: isDark ? surfaceDark : surfaceWhite,
      borderRadius: BorderRadius.circular(radiusMedium),
      border: Border.all(color: isDark ? borderDark : borderLight),
    );
  }

  /// Décoration de carte avec action
  static BoxDecoration actionCardDecoration({required bool isDark}) {
    return BoxDecoration(
      color: isDark ? surfaceDark : surfaceWhite,
      borderRadius: BorderRadius.circular(radiusMedium),
      border: Border.all(color: isDark ? borderDark : borderLight),
    );
  }

  /// Décoration de header
  static BoxDecoration headerDecoration({required bool isDark}) {
    return BoxDecoration(
      color: isDark ? backgroundDark : backgroundLight,
      border: Border(
        bottom: BorderSide(color: isDark ? borderDark : borderLight, width: 1),
      ),
    );
  }

  /// Bordure de carte
  static BoxBorder cardBorder(Color color) {
    return Border.all(color: color.withValues(alpha: 0.15));
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 🧩 WIDGETS UTILITAIRES
  // ════════════════════════════════════════════════════════════════════════════

  /// Chip/Badge moderne
  static Widget modernChip({
    required String label,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: spacing12,
        vertical: spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radiusRound),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            horizontalSpace4,
          ],
          Text(
            label,
            style: labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Divider moderne
  static Widget modernDivider({bool isDark = false}) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? borderDark : borderLight,
    );
  }

  /// Card moderne (décoration)
  static BoxDecoration modernCard({
    Color accentColor = primaryGreen,
    double borderRadius = radiusMedium,
    bool isDark = false,
  }) {
    return BoxDecoration(
      color: isDark ? surfaceDark : surfaceWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: isDark ? borderDark : borderLight),
    );
  }

  /// Style de bouton moderne
  static ButtonStyle modernButtonStyle(Color color, {bool isDark = false}) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: textOnPrimary,
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

  // ════════════════════════════════════════════════════════════════════════════
  // 🎯 STYLES DE BOUTONS UNIFORMES
  // ════════════════════════════════════════════════════════════════════════════

  /// Style bouton primaire (vert)
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryGreenLight,
    foregroundColor: textOnPrimary,
    elevation: 0,
    padding: const EdgeInsets.symmetric(
      horizontal: spacing24,
      vertical: spacing16,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  /// Style bouton secondaire (outline)
  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primaryGreenLight,
    side: const BorderSide(color: primaryGreenLight, width: 1.5),
    padding: const EdgeInsets.symmetric(
      horizontal: spacing24,
      vertical: spacing16,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  /// Style bouton texte (cancel/annuler)
  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    foregroundColor: textSecondary,
    padding: const EdgeInsets.symmetric(
      horizontal: spacing16,
      vertical: spacing12,
    ),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  );

  /// Style bouton danger (supprimer)
  static ButtonStyle get dangerButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: error,
    foregroundColor: textOnPrimary,
    elevation: 0,
    padding: const EdgeInsets.symmetric(
      horizontal: spacing24,
      vertical: spacing16,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  /// Style bouton danger outline
  static ButtonStyle get dangerOutlineButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: error,
    side: const BorderSide(color: error, width: 1.5),
    padding: const EdgeInsets.symmetric(
      horizontal: spacing24,
      vertical: spacing16,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 📝 STYLES DE FORMULAIRES UNIFORMES
  // ════════════════════════════════════════════════════════════════════════════

  /// InputDecoration standard pour tous les champs
  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? suffixText,
    bool isDark = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: textSecondary)
          : null,
      suffixIcon: suffixIcon,
      suffixText: suffixText,
      suffixStyle: caption.copyWith(color: textSecondary),
      filled: true,
      fillColor: isDark ? surfaceDark : surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: isDark ? borderDark : borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: isDark ? borderDark : borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryGreenLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing16,
      ),
      labelStyle: bodyMedium.copyWith(color: textSecondary),
      hintStyle: bodyMedium.copyWith(color: textTertiary),
    );
  }

  /// InputDecoration pour les champs de recherche
  static InputDecoration searchInputDecoration({
    String hint = 'Rechercher...',
    bool isDark = false,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search, color: textSecondary),
      filled: true,
      fillColor: isDark ? surfaceDark : surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusRound),
        borderSide: const BorderSide(color: primaryGreenLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing12,
      ),
      hintStyle: bodyMedium.copyWith(color: textTertiary),
    );
  }

  /// InputDecoration moderne
  static InputDecoration modernInputDecoration({
    required String label,
    String? hint,
    IconData? icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      suffixIcon: suffixIcon,
    );
  }

  /// Container de statut (succès, warning, erreur, info)
  static BoxDecoration statusDecoration(Color color, {bool isDark = false}) {
    return BoxDecoration(
      color: color.withValues(alpha: isDark ? 0.15 : 0.08),
      borderRadius: BorderRadius.circular(radiusSmall),
      border: Border.all(color: color.withValues(alpha: 0.25)),
    );
  }
}
