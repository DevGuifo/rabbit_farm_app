import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// État vide pour l'écran de localisation
/// Affiché quand aucune donnée n'est disponible
class LocalisationEmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const LocalisationEmptyState({super.key, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.surfaceDark
                  : AppTheme.backgroundLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cottage_rounded,
              size: 64,
              color: isDark ? AppTheme.greyDarkAlt : AppTheme.greyMedium,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noBuildingsYet,
            style: AppTheme.titleLarge.copyWith(
              color: isDark
                  ? AppTheme.textOnPrimary
                  : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startByAddingBuilding,
            style: AppTheme.bodyMedium.copyWith(
              color: isDark
                  ? AppTheme.accentGreen
                  : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(l10n.ajouterBatiment),
            style: AppTheme.primaryButtonStyle,
          ),
        ],
      ),
    );
  }
}
