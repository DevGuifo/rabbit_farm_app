import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// État vide standardisé
/// 
/// Usage:
/// ```dart
/// EmptyState(
///   isDark: isDark,
///   icon: Icons.pets_outlined,
///   title: 'Aucun lapin trouvé',
///   subtitle: 'Ajoutez votre premier lapin',
/// )
/// ```
class EmptyState extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                .withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textLight : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

