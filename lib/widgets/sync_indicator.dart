import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';

/// Widget indicateur de synchronisation pour l'AppBar
///
/// Affiche l'état de connexion et le nombre d'opérations en attente :
/// - ✓ Vert : Connecté, tout synchronisé
/// - 🔄 (N) Orange : N opérations en attente
/// - ⚠️ Gris : Mode hors-ligne
/// - ❌ Rouge : Erreur de synchronisation
class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, _) {
        final isOnline = connectivity.isOnline;

        return StreamBuilder<int>(
          stream: SyncService().pendingCountStream,
          initialData: 0,
          builder: (context, snapshot) {
            final pendingCount = snapshot.data ?? 0;
            final hasError = snapshot.hasError;

            return _buildIndicator(
              context: context,
              isOnline: isOnline,
              pendingCount: pendingCount,
              hasError: hasError,
            );
          },
        );
      },
    );
  }

  Widget _buildIndicator({
    required BuildContext context,
    required bool isOnline,
    required int pendingCount,
    required bool hasError,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Déterminer l'état et la couleur
    IconData icon;
    Color color;
    String? badge;
    String tooltip;

    if (!isOnline) {
      // Hors-ligne
      icon = Icons.cloud_off_rounded;
      color = isDark ? AppTheme.stitchTextSecDark : AppTheme.textSecondary;
      tooltip = 'Mode hors-ligne';
    } else if (hasError) {
      // Erreur sync
      icon = Icons.sync_problem_rounded;
      color = AppTheme.error;
      tooltip = 'Erreur de synchronisation';
    } else if (pendingCount > 0) {
      // Opérations en attente
      icon = Icons.sync_rounded;
      color = AppTheme.warning;
      badge = pendingCount > 99 ? '99+' : pendingCount.toString();
      tooltip = '$pendingCount opération(s) en attente';
    } else {
      // Tout synchronisé
      icon = Icons.cloud_done_rounded;
      color = AppTheme.success;
      tooltip = 'Synchronisé';
    }

    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: color, size: 24),
            if (badge != null)
              Positioned(
                right: -6,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warning,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.surfaceDark
                          : AppTheme.backgroundLight,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
