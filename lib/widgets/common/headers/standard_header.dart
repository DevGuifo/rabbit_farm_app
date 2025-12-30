import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Composant Header standard pour tous les écrans
/// Remplace les headers custom répétitifs
/// 
/// Usage:
/// ```dart
/// StandardHeader(
///   title: 'My Herd',
///   isDark: isDark,
///   onSync: () => _refresh(),
///   onNotifications: () => _showNotifications(),
///   onSettings: () => _openSettings(),
/// )
/// ```
class StandardHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  final VoidCallback? onSync;
  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;
  final bool showNotificationBadge;
  final int notificationCount;

  const StandardHeader({
    super.key,
    required this.title,
    required this.isDark,
    this.onSync,
    this.onNotifications,
    this.onSettings,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.headerDecoration(isDark: isDark),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  if (onSync != null)
                    IconButton(
                      icon: Icon(
                        Icons.sync,
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                      ),
                      onPressed: onSync,
                    ),
                  if (onNotifications != null)
                    Stack(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.notifications,
                            color: isDark
                                ? AppTheme.textLight
                                : AppTheme.textPrimary,
                          ),
                          onPressed: onNotifications,
                        ),
                        if (showNotificationBadge && notificationCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: AppTheme.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                notificationCount.toString(),
                                style: const TextStyle(
                                  color: AppTheme.textLight,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  if (onSettings != null)
                    IconButton(
                      icon: Icon(
                        Icons.settings,
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                      ),
                      onPressed: onSettings,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

