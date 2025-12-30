import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Header standard pour écrans principaux
/// Utilisé par Reproduction, Finance, etc.
class StandardScreenHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  final VoidCallback? onSync;
  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;

  const StandardScreenHeader({
    super.key,
    required this.title,
    required this.isDark,
    this.onSync,
    this.onNotifications,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isDark
          ? AppTheme.backgroundDark.withValues(alpha: 0.95)
          : AppTheme.cardLight.withValues(alpha: 0.95),
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: AppTheme.titleLarge.copyWith(
          color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
        ),
      ),
      actions: [
        if (onSync != null)
          IconButton(
            icon: Icon(
              Icons.sync,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
            onPressed: onSync,
          ),
        if (onNotifications != null)
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
            onPressed: onNotifications,
          ),
        if (onSettings != null)
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
            onPressed: onSettings,
          ),
      ],
    );
  }
}
