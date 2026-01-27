import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// AppBar personnalisée - Design Stitch Notifications
class AlertesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onSync;
  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;
  final bool hasUnreadNotifications;

  const AlertesAppBar({
    super.key,
    required this.onBack,
    required this.onSync,
    this.onNotifications,
    this.onSettings,
    this.hasUnreadNotifications = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.backgroundDark : AppTheme.cardLight;
    final textColor = isDark ? AppTheme.textLight : AppTheme.textPrimary;
    final hoverColor = isDark ? AppTheme.cardDark : AppTheme.backgroundLight;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.neutral800 : AppTheme.neutral100,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Back button
              _buildIconButton(
                context,
                icon: Icons.arrow_back,
                onPressed: onBack,
                hoverColor: hoverColor,
                iconColor: textColor,
              ),
              const SizedBox(width: 12),
              // Title
              Text(
                AppLocalizations.of(context).notifications,
                style: AppTheme.titleLarge.copyWith(color: textColor),
              ),
              const Spacer(),
              // Action buttons
              _buildIconButton(
                context,
                icon: Icons.sync,
                onPressed: onSync,
                hoverColor: hoverColor,
                iconColor: textColor,
              ),
              if (onNotifications != null) ...[
                const SizedBox(width: 4),
                _buildNotificationButton(
                  context,
                  onPressed: onNotifications!,
                  hoverColor: hoverColor,
                  iconColor: textColor,
                  hasUnread: hasUnreadNotifications,
                ),
              ],
              const SizedBox(width: 4),
              _buildIconButton(
                context,
                icon: Icons.settings,
                onPressed: onSettings ?? () {},
                hoverColor: hoverColor,
                iconColor: textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required Color hoverColor,
    required Color iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: Icon(icon, size: 24, color: iconColor),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required Color hoverColor,
    required Color iconColor,
    required bool hasUnread,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppTheme.surfaceDark
        : AppTheme.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Stack(
            children: [
              Center(
                child: Icon(Icons.notifications, size: 24, color: iconColor),
              ),
              if (hasUnread)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNeonGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: surfaceColor, width: 2),
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
