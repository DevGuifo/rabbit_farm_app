import 'package:flutter/material.dart';
import 'standard_header.dart';

/// Version Sliver de StandardHeader pour utilisation dans CustomScrollView
/// 
/// Utilise le même composant StandardHeader mais dans un SliverToBoxAdapter
class SliverStandardHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  final VoidCallback? onSync;
  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;
  final IconData? settingsIcon;
  final bool showNotificationBadge;
  final int notificationCount;
  final bool pinned;

  const SliverStandardHeader({
    super.key,
    required this.title,
    required this.isDark,
    this.onSync,
    this.onNotifications,
    this.onSettings,
    this.settingsIcon,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
    this.pinned = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: StandardHeader(
        title: title,
        isDark: isDark,
        onSync: onSync,
        onNotifications: onNotifications,
        onSettings: onSettings,
        settingsIcon: settingsIcon,
        showNotificationBadge: showNotificationBadge,
        notificationCount: notificationCount,
      ),
    );
  }
}

