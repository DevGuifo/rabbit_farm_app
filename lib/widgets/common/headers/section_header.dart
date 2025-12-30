import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// En-tête de section avec titre et bouton "Voir plus"
/// 
/// Usage:
/// ```dart
/// SectionHeader(
///   title: 'Upcoming Tasks',
///   isDark: isDark,
///   icon: Icons.task,
///   onMoreTap: () => _showAllTasks(),
/// )
/// ```
class SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  final IconData? icon;
  final VoidCallback? onMoreTap;

  const SectionHeader({
    super.key,
    required this.title,
    required this.isDark,
    this.icon,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppTheme.primaryGreen, size: 20),
                const SizedBox(width: AppTheme.spacing8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          if (onMoreTap != null)
            GestureDetector(
              onTap: onMoreTap,
              child: const Text(
                'Voir plus',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

