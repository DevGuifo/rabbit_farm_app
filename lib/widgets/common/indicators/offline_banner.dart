import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/connectivity_provider.dart';
import '../../../theme/app_theme.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📡 OFFLINE BANNER - Indicateur de mode hors ligne
/// ═══════════════════════════════════════════════════════════════════════════
///
/// RÈGLES D'UTILISATION :
/// - Affiche automatiquement une bannière quand l'appareil est hors ligne
/// - Se cache automatiquement quand la connexion est rétablie
/// - Doit être placé en haut du body ou dans un Stack
///
/// USAGE :
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       const OfflineBanner(),
///       Expanded(child: content),
///     ],
///   ),
/// )
/// ```
///
/// USAGE DANS UN STACK :
/// ```dart
/// Stack(
///   children: [
///     content,
///     const Positioned(
///       top: 0,
///       left: 0,
///       right: 0,
///       child: OfflineBanner(),
///     ),
///   ],
/// )
/// ```
/// ═══════════════════════════════════════════════════════════════════════════

class OfflineBanner extends StatelessWidget {
  final bool showIcon;
  final bool compact;

  const OfflineBanner({super.key, this.showIcon = true, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        if (!connectivity.isOffline) {
          return const SizedBox.shrink();
        }

        return _OfflineBannerContent(showIcon: showIcon, compact: compact);
      },
    );
  }
}

class _OfflineBannerContent extends StatelessWidget {
  final bool showIcon;
  final bool compact;

  const _OfflineBannerContent({required this.showIcon, required this.compact});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: AppTheme.warning,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: compact ? 6 : 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showIcon) ...[
                Icon(
                  Icons.cloud_off_rounded,
                  color: AppTheme.textOnPrimary,
                  size: compact ? 16 : 20,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  l10n.commonModeHorsLigne,
                  style: (compact ? AppTheme.labelSmall : AppTheme.labelLarge)
                      .copyWith(
                        color: AppTheme.textOnPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 🔄 SYNC STATUS CHIP - Petit indicateur d'état de synchronisation
/// ═══════════════════════════════════════════════════════════════════════════
///
/// USAGE :
/// ```dart
/// SyncStatusChip() // Affiche automatiquement l'état
/// ```
/// ═══════════════════════════════════════════════════════════════════════════

class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, _) {
        final l10n = AppLocalizations.of(context);

        if (connectivity.isOffline) {
          return _buildChip(
            icon: Icons.cloud_off_rounded,
            label: l10n.commonHorsLigne,
            color: AppTheme.error,
          );
        }

        return _buildChip(
          icon: Icons.cloud_done_rounded,
          label: l10n.commonEnLigne,
          color: AppTheme.success,
        );
      },
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
