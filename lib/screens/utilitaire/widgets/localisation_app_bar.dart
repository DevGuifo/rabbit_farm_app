import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// AppBar Stitch Localisation avec backdrop blur + actions
/// Design: Sticky header, Material Symbols icons, neon green #13EC25
class LocalisationAppBar extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onSyncPressed;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onSettingsPressed;
  final bool hasUnreadNotifications;

  const LocalisationAppBar({
    super.key,
    required this.onBackPressed,
    required this.onSyncPressed,
    required this.onNotificationsPressed,
    required this.onSettingsPressed,
    this.hasUnreadNotifications = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        (isDark
                ? AppTheme.backgroundDark
                : AppTheme.backgroundLight)
            .withValues(alpha: 0.95);
    final borderColor = isDark
        ? AppTheme.borderDark
        : AppTheme.borderLight;
    final textColor = isDark
        ? AppTheme.stitchTextMainDark
        : AppTheme.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              _buildActionButton(
                context,
                icon: Icons.arrow_back_rounded,
                onPressed: onBackPressed,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Location',
                  style: AppTheme.titleLarge.copyWith(
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              _buildActionButton(
                context,
                icon: Icons.sync_rounded,
                onPressed: onSyncPressed,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildNotificationButton(context, isDark: isDark),
              const SizedBox(width: 12),
              _buildActionButton(
                context,
                icon: Icons.settings_rounded,
                onPressed: onSettingsPressed,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    final iconColor = isDark
        ? AppTheme.stitchTextMainDark
        : AppTheme.textPrimary;
    final hoverColor = isDark
        ? AppTheme.textOnPrimary.withValues(alpha: 0.05)
        : AppTheme.divider;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        splashColor: hoverColor,
        highlightColor: hoverColor,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: iconColor, size: 24),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(
    BuildContext context, {
    required bool isDark,
  }) {
    final iconColor = isDark
        ? AppTheme.stitchTextMainDark
        : AppTheme.textPrimary;
    final hoverColor = isDark
        ? AppTheme.textOnPrimary.withValues(alpha: 0.05)
        : AppTheme.divider;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onNotificationsPressed,
        borderRadius: BorderRadius.circular(999),
        splashColor: hoverColor,
        highlightColor: hoverColor,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_rounded, color: iconColor, size: 24),
              if (hasUnreadNotifications)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
