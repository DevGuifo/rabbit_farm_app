import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Widget pour un élément avec toggle switch dans les paramètres
class SettingsToggleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingsToggleItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icône dans un conteneur coloré
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryNeonGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.primaryNeonGreen,
            ),
          ),
          const SizedBox(width: 12),

          // Titre
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppTheme.textOnPrimary
                    : AppTheme.textPrimary,
              ),
            ),
          ),

          // Toggle Switch
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.textOnPrimary,
            activeTrackColor: AppTheme.primaryNeonGreen,
            inactiveThumbColor: AppTheme.textOnPrimary,
            inactiveTrackColor: isDark
                ? AppTheme.textOnPrimary.withValues(alpha: 0.2)
                : AppTheme.borderLight,
          ),
        ],
      ),
    );
  }
}

