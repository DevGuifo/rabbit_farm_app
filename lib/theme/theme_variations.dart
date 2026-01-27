/// Theme Variations - Extension du Design System
///
/// Ce fichier définit les variations thématiques contrôlées pour chaque
/// fonctionnalité de l'application.
library;

import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Définition d'une variation thématique
class ThemeVariation {
  /// Couleur d'accent principale du thème
  final Color accentColor;

  /// Couleur d'accent claire (pour fonds, badges)
  final Color accentLight;

  /// Couleur d'accent foncée (pour textes sur fond clair)
  final Color accentDark;

  /// Icône Material représentative du thème
  final IconData icon;

  /// Icône alternative (optionnelle)
  final IconData? iconAlt;

  /// Nom du thème pour le debugging
  final String name;

  const ThemeVariation({
    required this.accentColor,
    required this.accentLight,
    required this.accentDark,
    required this.icon,
    required this.name,
    this.iconAlt,
  });

  /// Génère une décoration de carte avec l'accent du thème
  BoxDecoration cardDecoration({
    required bool isDark,
    bool highlighted = false,
  }) {
    return BoxDecoration(
      color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceWhite,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      border: Border.all(
        color: highlighted
            ? accentColor.withValues(alpha: 0.3)
            : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
        width: highlighted ? 2 : 1,
      ),
    );
  }

  /// Génère un badge/chip avec les couleurs du thème
  Widget buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        color: accentLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accentColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.labelMedium.copyWith(
              color: accentDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Génère un conteneur d'icône circulaire
  Widget buildIconCircle({double size = 48, bool isDark = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? accentColor.withValues(alpha: 0.2) : accentLight,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: accentColor, size: size * 0.5),
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════════
/// 🎯 VARIATIONS THÉMATIQUES PAR FONCTIONNALITÉ
/// ════════════════════════════════════════════════════════════════════════════
class ThemeVariations {
  ThemeVariations._();

  // ─────────────────────────────────────────────────────────────────────────
  // CHEPTEL - Gestion du troupeau
  // ─────────────────────────────────────────────────────────────────────────
  static const ThemeVariation cheptel = ThemeVariation(
    name: 'Cheptel',
    accentColor: AppTheme.primaryGreen,
    accentLight: AppTheme.green50,
    accentDark: AppTheme.primaryGreenDark,
    icon: Icons.pets_rounded,
    iconAlt: Icons.cruelty_free_rounded,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SANTÉ - Suivi médical
  // ─────────────────────────────────────────────────────────────────────────
  static const ThemeVariation sante = ThemeVariation(
    name: 'Santé',
    accentColor: AppTheme.success,
    accentLight: AppTheme.success50,
    accentDark: AppTheme.success900,
    icon: Icons.medical_services_rounded,
    iconAlt: Icons.healing_rounded,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // REPRODUCTION - Accouplements et portées
  // ─────────────────────────────────────────────────────────────────────────
  static const ThemeVariation reproduction = ThemeVariation(
    name: 'Reproduction',
    accentColor: AppTheme.accentPurple,
    accentLight: AppTheme.accentPurple50,
    accentDark: AppTheme.accentPurple900,
    icon: Icons.family_restroom_rounded,
    iconAlt: Icons.favorite_rounded,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // FINANCE - Recettes et dépenses
  // ─────────────────────────────────────────────────────────────────────────
  static const ThemeVariation finance = ThemeVariation(
    name: 'Finance',
    accentColor: AppTheme.success,
    accentLight: AppTheme.success50,
    accentDark: AppTheme.success900,
    icon: Icons.account_balance_wallet_rounded,
    iconAlt: Icons.euro_rounded,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // TÂCHE MATIN - Tâches quotidiennes du matin
  // ─────────────────────────────────────────────────────────────────────────
  static const ThemeVariation tacheMatin = ThemeVariation(
    name: 'Tâche Matin',
    accentColor: AppTheme.warning,
    accentLight: AppTheme.warning50,
    accentDark: AppTheme.warning900,
    icon: Icons.wb_sunny_rounded, // Remplace emoji 🌅
    iconAlt: Icons.light_mode_rounded,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // TÂCHE SOIR - Tâches quotidiennes du soir
  // ─────────────────────────────────────────────────────────────────────────
  static const ThemeVariation tacheSoir = ThemeVariation(
    name: 'Tâche Soir',
    accentColor: AppTheme.info,
    accentLight: AppTheme.info50,
    accentDark: AppTheme.info900,
    icon: Icons.nights_stay_rounded, // Remplace emoji 🌙
    iconAlt: Icons.dark_mode_rounded,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // ALERTES - Notifications et urgences
  // ─────────────────────────────────────────────────────────────────────────
  static const ThemeVariation alertes = ThemeVariation(
    name: 'Alertes',
    accentColor: AppTheme.error,
    accentLight: AppTheme.error50,
    accentDark: AppTheme.error900,
    icon: Icons.notifications_active_rounded,
    iconAlt: Icons.warning_rounded,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // PARAMÈTRES - Configuration
  // ─────────────────────────────────────────────────────────────────────────
  static const ThemeVariation parametres = ThemeVariation(
    name: 'Paramètres',
    accentColor: AppTheme.neutral600,
    accentLight: AppTheme.neutral100,
    accentDark: AppTheme.neutral900,
    icon: Icons.settings_rounded,
    iconAlt: Icons.tune_rounded,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // ALIMENTATION - Nourriture et stock
  // ─────────────────────────────────────────────────────────────────────────
  static const ThemeVariation alimentation = ThemeVariation(
    name: 'Alimentation',
    accentColor: AppTheme.accentOrange,
    accentLight: AppTheme.accentOrange50,
    accentDark: AppTheme.accentOrange700,
    icon: Icons.restaurant_rounded,
    iconAlt: Icons.grass_rounded,
  );

  /// Obtenir la variation pour un type de tâche (matin/soir)
  static ThemeVariation getTacheVariation(bool estMatin) {
    return estMatin ? tacheMatin : tacheSoir;
  }

  /// Alias pour compatibilité avec l'ancien nom "Rituel"
  @Deprecated('Utilisez getTacheVariation à la place')
  static ThemeVariation getRituelVariation(bool estMatin) {
    return getTacheVariation(estMatin);
  }

  /// Alias pour compatibilité - rituelMatin
  @Deprecated('Utilisez tacheMatin à la place')
  static ThemeVariation get rituelMatin => tacheMatin;

  /// Alias pour compatibilité - rituelSoir
  @Deprecated('Utilisez tacheSoir à la place')
  static ThemeVariation get rituelSoir => tacheSoir;

  /// Liste de toutes les variations (pour itération)
  static List<ThemeVariation> get all => [
    cheptel,
    sante,
    reproduction,
    finance,
    tacheMatin,
    tacheSoir,
    alertes,
    parametres,
    alimentation,
  ];
}

/// ════════════════════════════════════════════════════════════════════════════
/// 🔄 MAPPING EMOJIS → ICONS (pour migration progressive)
/// ════════════════════════════════════════════════════════════════════════════
class EmojiToIconMapper {
  EmojiToIconMapper._();

  static const Map<String, IconData> mapping = {
    // Rituels
    '🌅': Icons.wb_sunny_rounded,
    '🌙': Icons.nights_stay_rounded,
    '🎉': Icons.celebration_rounded,

    // Actions rituel
    '💧': Icons.water_drop_rounded,
    '🥤': Icons.local_drink_rounded,
    '🍽️': Icons.restaurant_rounded,
    '🔍': Icons.search_rounded,
    '🧹': Icons.cleaning_services_rounded,
    '📊': Icons.analytics_rounded,
    '✅': Icons.check_circle_rounded,
    '⚠️': Icons.warning_rounded,
    '⏰': Icons.schedule_rounded,

    // Animaux
    '🐰': Icons.cruelty_free_rounded,
    '🐇': Icons.pets_rounded,

    // Santé
    '💊': Icons.medication_rounded,
    '💉': Icons.vaccines_rounded,
    '🩺': Icons.medical_services_rounded,
    '🌡️': Icons.thermostat_rounded,

    // Finance
    '💰': Icons.attach_money_rounded,
    '📈': Icons.trending_up_rounded,
    '📉': Icons.trending_down_rounded,
  };

  /// Convertit un emoji en IconData Material
  static IconData? getIcon(String emoji) {
    return mapping[emoji];
  }

  /// Convertit avec fallback
  static IconData getIconOrDefault(
    String emoji, {
    IconData fallback = Icons.circle,
  }) {
    return mapping[emoji] ?? fallback;
  }
}
