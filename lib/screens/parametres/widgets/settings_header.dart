import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
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
        color:
            (isDark
                    ? AppTheme.backgroundDark
                    : AppTheme.backgroundLight)
                .withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppTheme.textOnPrimary.withValues(alpha: 0.05)
                : AppTheme.textPrimary.withValues(alpha: 0.05),
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
              AppLocalizations.of(context).parametresSettings,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDark
                    ? AppTheme.textOnPrimary
                    : AppTheme.textPrimary,
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
                        ? AppTheme.textOnPrimary
                        : AppTheme.textPrimary,
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
                            ? AppTheme.textOnPrimary
                            : AppTheme.textPrimary,
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
                            color: AppTheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.backgroundDark
                                  : AppTheme.textOnPrimary,
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
