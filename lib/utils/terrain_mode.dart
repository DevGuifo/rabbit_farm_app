import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Configuration du mode terrain pour BunnyManager
/// Optimisé pour utilisation extérieure avec gros boutons et contraste élevé
class TerrainMode {
  // Activer/désactiver le mode terrain (persiste via SharedPreferences)
  static bool isEnabled = false;

  // ============================================
  // 📏 TAILLES TERRAIN
  // ============================================

  /// Hauteur minimale des boutons en mode terrain
  static const double buttonHeight = 64.0;

  /// Hauteur des cartes interactives
  static const double cardHeight = 80.0;

  /// Taille des icônes
  static const double iconSize = 32.0;

  /// Padding interne des boutons
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 20,
  );

  /// Espacement entre éléments
  static const double spacing = 20.0;

  // ============================================
  // 🎨 COULEURS HAUTE VISIBILITÉ
  // ============================================

  /// Couleur primaire haute visibilité
  static const Color primaryColor = Color(0xFF2E7D32); // Vert foncé

  /// Couleur secondaire contraste
  static const Color secondaryColor = Color(0xFF5D4037); // Brun foncé

  /// Couleur d'accent
  static const Color accentColor = Color(0xFFFF6F00); // Orange vif

  /// Fond clair haute luminosité
  static const Color backgroundLight = Color(0xFFFAFAFA);

  /// Texte contraste maximal
  static const Color textPrimary = Color(0xFF000000);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// États visuels
  static const Color success = Color(0xFF1B5E20); // Vert très foncé
  static const Color warning = Color(0xFFE65100); // Orange foncé
  static const Color error = Color(0xFFB71C1C); // Rouge foncé

  // ============================================
  // 📝 TYPOGRAPHIE TERRAIN
  // ============================================

  /// Style pour labels de boutons (grande taille)
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Style pour titres
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.3,
  );

  /// Style pour valeurs/compteurs
  static const TextStyle valueTextStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  // ============================================
  // 🔘 COMPOSANTS TERRAIN
  // ============================================

  /// Bouton primaire mode terrain
  static Widget primaryButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textOnPrimary,
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize),
              const SizedBox(width: 12),
            ],
            Text(label, style: buttonTextStyle),
          ],
        ),
      ),
    );
  }

  /// Bouton secondaire mode terrain
  static Widget secondaryButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: buttonPadding,
          side: const BorderSide(color: primaryColor, width: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize),
              const SizedBox(width: 12),
            ],
            Text(label, style: buttonTextStyle),
          ],
        ),
      ),
    );
  }

  /// Card interactive mode terrain
  static Widget actionCard({
    required String title,
    required String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final cardColor = color ?? primaryColor;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: cardHeight,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.textSecondary.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.textPrimary.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: iconSize, color: cardColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 32,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  /// Badge compteur XXL
  static Widget counterBadge({
    required String value,
    required String label,
    Color? color,
  }) {
    final badgeColor = color ?? primaryColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: valueTextStyle.copyWith(color: badgeColor)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Switch pour activer/désactiver le mode terrain
  static Widget modeToggle({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: const Text(
        'Mode Terrain',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      subtitle: const Text(
        'Gros boutons et contraste élevé pour utilisation extérieure',
        style: TextStyle(fontSize: 14),
      ),
      value: value,
      onChanged: onChanged,
      activeTrackColor: primaryColor.withValues(alpha: 0.5),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return null;
      }),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      secondary: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          value ? Icons.wb_sunny : Icons.wb_sunny_outlined,
          color: primaryColor,
          size: 28,
        ),
      ),
    );
  }

  // ============================================
  // 🎨 THEME TERRAIN COMPLET
  // ============================================

  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundLight,
        surfaceContainerHighest: backgroundLight,
        error: error,
        onPrimary: textOnPrimary,
        onSecondary: textOnPrimary,
        onSurface: textPrimary,
      ),

      scaffoldBackgroundColor: backgroundLight,

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textOnPrimary,
        ),
        iconTheme: IconThemeData(color: textOnPrimary, size: 28),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textOnPrimary,
          padding: buttonPadding,
          minimumSize: const Size(double.infinity, buttonHeight),
          textStyle: buttonTextStyle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: textOnPrimary,
        iconSize: iconSize,
        elevation: 6,
        sizeConstraints: const BoxConstraints.tightFor(width: 72, height: 72),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        color: AppTheme.cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppTheme.textSecondary.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}
