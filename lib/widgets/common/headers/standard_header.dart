import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/sync_provider.dart';
import '../../../providers/connectivity_provider.dart';

/// Composant Header standard unifié pour tous les écrans principaux
/// 
/// Référence : En-tête de l'écran Cheptel
/// 
/// Fonctionnalités :
/// - État de synchronisation en temps réel (vert/jaune/rouge)
/// - Badge avec nombre d'éléments en attente de synchronisation
/// - Navigation cohérente sur tous les écrans
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
  final IconData? settingsIcon; // Permet de personnaliser l'icône settings
  final bool showNotificationBadge;
  final int notificationCount;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const StandardHeader({
    super.key,
    required this.title,
    required this.isDark,
    this.onSync,
    this.onNotifications,
    this.onSettings,
    this.settingsIcon,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.headerDecoration(isDark: isDark),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing16,
                vertical: AppTheme.spacing12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Titre et bouton retour facultatif
                  Expanded(
                    child: Row(
                      children: [
                        if (showBackButton)
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                              size: 20,
                            ),
                            onPressed: onBackPressed ?? () => Navigator.pop(context),
                          ),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  Row(
                    children: [
                      // Actions personnalisées transmises
                      if (actions != null) ...actions!,
                      
                      // Bouton de synchronisation avec état visuel
                      if (onSync != null)
                        Consumer2<SyncProvider, ConnectivityProvider>(
                          builder: (context, syncProvider, connectivityProvider, _) {
                            return _buildSyncButton(
                              context,
                              syncProvider,
                              connectivityProvider,
                            );
                          },
                        ),
                      // Bouton de notifications
                      if (onNotifications != null)
                        _buildNotificationButton(context),
                      // Bouton de paramètres
                      if (onSettings != null)
                        IconButton(
                          icon: Icon(
                            settingsIcon ?? Icons.settings,
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
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }

  /// Construit le bouton de synchronisation avec état visuel
  Widget _buildSyncButton(
    BuildContext context,
    SyncProvider syncProvider,
    ConnectivityProvider connectivityProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Déterminer l'état et la couleur
    Color syncColor;
    IconData syncIcon;
    String? tooltip;
    bool showBadge = false;
    int badgeCount = 0;

    if (connectivityProvider.isOffline) {
      // 🔴 Hors ligne
      syncColor = AppTheme.error;
      syncIcon = Icons.cloud_off_rounded;
      tooltip = 'Hors ligne';
    } else if (syncProvider.isSyncing) {
      // 🟡 Synchronisation en cours
      syncColor = AppTheme.warning;
      syncIcon = Icons.cloud_sync_rounded;
      tooltip = 'Synchronisation en cours...';
    } else if (syncProvider.pendingChanges > 0) {
      // 🟡 En ligne mais éléments en attente
      syncColor = AppTheme.warning;
      syncIcon = Icons.cloud_sync_rounded;
      tooltip = '${syncProvider.pendingChanges} élément(s) en attente';
      showBadge = true;
      badgeCount = syncProvider.pendingChanges;
    } else {
      // 🟢 En ligne et synchronisé
      syncColor = AppTheme.success;
      syncIcon = Icons.cloud_done_rounded;
      tooltip = 'Synchronisé';
    }

    return Stack(
      children: [
        // Animation de rotation si synchronisation en cours
        if (syncProvider.isSyncing)
          _AnimatedSyncIcon(
            icon: syncIcon,
            color: syncColor,
            onPressed: onSync,
            tooltip: tooltip,
          )
        else
          IconButton(
            icon: Icon(syncIcon, color: syncColor),
            onPressed: onSync,
            tooltip: tooltip,
          ),
        // Badge avec nombre d'éléments en attente
        if (showBadge && badgeCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: syncColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppTheme.backgroundDarkMode : AppTheme.backgroundLight,
                  width: 2,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Center(
                child: Text(
                  badgeCount > 99 ? '99+' : badgeCount.toString(),
                  style: const TextStyle(
                    color: AppTheme.textOnPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Construit le bouton de notifications
  Widget _buildNotificationButton(BuildContext context) {
    return Stack(
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
                notificationCount > 99 ? '99+' : notificationCount.toString(),
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
    );
  }
}

/// Widget pour l'icône de synchronisation animée
class _AnimatedSyncIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final String? tooltip;

  const _AnimatedSyncIcon({
    required this.icon,
    required this.color,
    this.onPressed,
    this.tooltip,
  });

  @override
  State<_AnimatedSyncIcon> createState() => _AnimatedSyncIconState();
}

class _AnimatedSyncIconState extends State<_AnimatedSyncIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Répéter indéfiniment
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: IconButton(
        icon: Icon(widget.icon, color: widget.color),
        onPressed: widget.onPressed,
        tooltip: widget.tooltip,
      ),
    );
  }
}
