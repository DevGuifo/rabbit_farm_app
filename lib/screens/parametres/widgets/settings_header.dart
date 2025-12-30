import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Widget pour l'en-tête des paramètres avec titre et boutons d'action
class SettingsHeader extends StatelessWidget {
  final VoidCallback? onSyncPressed;
  final VoidCallback? onNotificationsPressed;
  final int notificationCount;

  const SettingsHeader({
    super.key,
    this.onSyncPressed,
    this.onNotificationsPressed,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: (isDark
                ? AppTheme.stitchBackgroundDark
                : AppTheme.stitchBackgroundLight)
            .withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Titre
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDark
                    ? Colors.white
                    : const Color(0xFF111812),
              ),
            ),

            // Boutons d'action
            Row(
              children: [
                // Bouton Sync
                IconButton(
                  onPressed: onSyncPressed,
                  icon: Icon(
                    Icons.sync,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF111812),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: const CircleBorder(),
                  ),
                ),

                // Bouton Notifications avec badge
                Stack(
                  children: [
                    IconButton(
                      onPressed: onNotificationsPressed,
                      icon: Icon(
                        Icons.notifications,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF111812),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: const CircleBorder(),
                      ),
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.stitchBackgroundDark
                                  : Colors.white,
                              width: 1.5,
                            ),
                          ),
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

