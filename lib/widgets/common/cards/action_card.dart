import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Card d'action avec icône colorée et cercle décoratif (Santé style)
/// 
/// Usage:
/// ```dart
/// ActionCard(
///   isDark: isDark,
///   icon: Icons.monitor_heart,
///   title: 'Health\nTracking',
///   subtitle: 'Vitals & Logs',
///   iconColor: AppTheme.primaryGreen,
///   onTap: () => _navigateToHealth(),
/// )
/// ```
class ActionCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;
  final double? height;

  const ActionCard({
    super.key,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        decoration: AppTheme.actionCardDecoration(isDark: isDark),
        child: Stack(
          children: [
            // Cercle décoratif
            Positioned(
              right: -16,
              top: -16,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.1 : 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: isDark ? 0.3 : 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.textSecondary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

