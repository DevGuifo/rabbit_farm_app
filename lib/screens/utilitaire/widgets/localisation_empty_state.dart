import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// État vide pour l'écran de localisation
/// Affiché quand aucune donnée n'est disponible
class LocalisationEmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const LocalisationEmptyState({super.key, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A2C1E)
                  : AppTheme.stitchBackgroundLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cottage_rounded,
              size: 64,
              color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFCCCCCC),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Buildings Yet',
            style: AppTheme.titleLarge.copyWith(
              color: isDark
                  ? const Color(0xFFE0E6E0)
                  : AppTheme.stitchTextMainLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first building',
            style: AppTheme.bodyMedium.copyWith(
              color: isDark
                  ? const Color(0xFF8BA88E)
                  : AppTheme.stitchTextSecLight,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Add Building'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNeonGreen,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
