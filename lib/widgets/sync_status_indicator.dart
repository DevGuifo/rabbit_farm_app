import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sync_provider.dart';

/// Widget indicateur de statut de synchronisation
///
/// Affiche un badge/icône indiquant l'état de la synchronisation :
/// - Icône sync avec badge de count si pending > 0
/// - Animation de rotation pendant la sync
/// - Icône check si sync réussie
/// - Icône erreur si échec
///
/// Usage :
/// ```dart
/// AppBar(
///   actions: [
///     SyncStatusIndicator(),
///   ],
/// )
/// ```
class SyncStatusIndicator extends StatelessWidget {
  /// Taille de l'icône
  final double iconSize;

  /// Afficher le tooltip au survol
  final bool showTooltip;

  /// Callback quand l'utilisateur appuie sur l'indicateur
  final VoidCallback? onTap;

  const SyncStatusIndicator({
    super.key,
    this.iconSize = 24.0,
    this.showTooltip = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        return Tooltip(
          message: showTooltip ? syncProvider.statusMessage : '',
          child: InkWell(
            onTap: onTap ?? () => _showSyncDialog(context, syncProvider),
            borderRadius: BorderRadius.circular(iconSize),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildIndicator(context, syncProvider),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndicator(BuildContext context, SyncProvider syncProvider) {
    final theme = Theme.of(context);

    switch (syncProvider.state) {
      case SyncState.syncing:
        return _SyncingIcon(size: iconSize);

      case SyncState.success:
        return Icon(Icons.cloud_done, size: iconSize, color: Colors.green);

      case SyncState.error:
        return Icon(
          Icons.cloud_off,
          size: iconSize,
          color: theme.colorScheme.error,
        );

      case SyncState.waitingForNetwork:
        return Icon(
          Icons.signal_wifi_off,
          size: iconSize,
          color: Colors.orange,
        );

      case SyncState.unavailable:
        return Icon(
          Icons.cloud_off,
          size: iconSize,
          color: theme.disabledColor,
        );

      case SyncState.idle:
        return _buildIdleIndicator(context, syncProvider);
    }
  }

  Widget _buildIdleIndicator(BuildContext context, SyncProvider syncProvider) {
    final theme = Theme.of(context);
    final pendingCount = syncProvider.pendingChanges;

    if (pendingCount == 0) {
      return Icon(
        Icons.cloud_done,
        size: iconSize,
        color: theme.colorScheme.primary.withValues(alpha: 0.7),
      );
    }

    // Badge avec le nombre de changements en attente
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          Icons.cloud_upload,
          size: iconSize,
          color: theme.colorScheme.primary,
        ),
        Positioned(
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              pendingCount > 99 ? '99+' : '$pendingCount',
              style: TextStyle(
                color: theme.colorScheme.onSecondary,
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

  void _showSyncDialog(BuildContext context, SyncProvider syncProvider) {
    showDialog(
      context: context,
      builder: (context) => SyncStatusDialog(syncProvider: syncProvider),
    );
  }
}

/// Icône animée pendant la synchronisation
class _SyncingIcon extends StatefulWidget {
  final double size;

  const _SyncingIcon({required this.size});

  @override
  State<_SyncingIcon> createState() => _SyncingIconState();
}

class _SyncingIconState extends State<_SyncingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
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
      child: Icon(
        Icons.sync,
        size: widget.size,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Dialog détaillé du statut de synchronisation
class SyncStatusDialog extends StatelessWidget {
  final SyncProvider syncProvider;

  const SyncStatusDialog({super.key, required this.syncProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(_getStatusIcon(), color: _getStatusColor(theme)),
          const SizedBox(width: 12),
          const Text('Synchronisation'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // État actuel
          Text(syncProvider.statusMessage, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),

          // Statistiques
          _buildStatRow(
            context,
            'Modifications en attente',
            '${syncProvider.pendingChanges}',
          ),
          if (syncProvider.lastSyncTime != null)
            _buildStatRow(
              context,
              'Dernière sync',
              _formatDateTime(syncProvider.lastSyncTime!),
            ),

          // Erreur si présente
          if (syncProvider.hasError && syncProvider.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      syncProvider.errorMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
        if (syncProvider.canSync && !syncProvider.isSyncing)
          FilledButton.icon(
            onPressed: () {
              syncProvider.syncNow();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('Synchroniser'),
          ),
      ],
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (syncProvider.state) {
      case SyncState.syncing:
        return Icons.sync;
      case SyncState.success:
        return Icons.cloud_done;
      case SyncState.error:
        return Icons.cloud_off;
      case SyncState.waitingForNetwork:
        return Icons.signal_wifi_off;
      case SyncState.unavailable:
        return Icons.cloud_off;
      case SyncState.idle:
        return syncProvider.pendingChanges > 0
            ? Icons.cloud_upload
            : Icons.cloud_done;
    }
  }

  Color _getStatusColor(ThemeData theme) {
    switch (syncProvider.state) {
      case SyncState.syncing:
        return theme.colorScheme.primary;
      case SyncState.success:
        return Colors.green;
      case SyncState.error:
        return theme.colorScheme.error;
      case SyncState.waitingForNetwork:
        return Colors.orange;
      case SyncState.unavailable:
        return theme.disabledColor;
      case SyncState.idle:
        return theme.colorScheme.primary;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'À l\'instant';
    } else if (diff.inHours < 1) {
      return 'Il y a ${diff.inMinutes} min';
    } else if (diff.inDays < 1) {
      return 'Il y a ${diff.inHours}h';
    } else {
      return '${dateTime.day}/${dateTime.month} à ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Widget compact pour afficher dans une ListTile (ex: Paramètres)
class SyncStatusTile extends StatelessWidget {
  const SyncStatusTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        return ListTile(
          leading: SyncStatusIndicator(
            iconSize: 28,
            showTooltip: false,
            onTap: null, // Le tile entier est cliquable
          ),
          title: const Text('Synchronisation'),
          subtitle: Text(syncProvider.statusMessage),
          trailing: syncProvider.canSync
              ? Switch(
                  value: syncProvider.isAutoSyncActive,
                  onChanged: (value) {
                    if (value) {
                      syncProvider.startAutoSync(
                        Provider.of(context, listen: false),
                      );
                    } else {
                      syncProvider.stopAutoSync();
                    }
                  },
                )
              : null,
          onTap: () => _showSyncSettings(context, syncProvider),
        );
      },
    );
  }

  void _showSyncSettings(BuildContext context, SyncProvider syncProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _SyncSettingsSheet(syncProvider: syncProvider),
    );
  }
}

/// Bottom sheet avec les paramètres de synchronisation
class _SyncSettingsSheet extends StatelessWidget {
  final SyncProvider syncProvider;

  const _SyncSettingsSheet({required this.syncProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Icon(Icons.cloud_sync, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Paramètres de synchronisation',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            // État actuel
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('État actuel'),
              subtitle: Text(syncProvider.statusMessage),
              trailing: _buildStatusChip(context),
            ),

            // Auto-sync toggle
            if (syncProvider.canSync)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Synchronisation automatique'),
                subtitle: const Text('Sync toutes les 5 minutes'),
                value: syncProvider.isAutoSyncActive,
                onChanged: (value) {
                  syncProvider.setSyncEnabled(value);
                },
              ),

            const SizedBox(height: 16),

            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
                if (syncProvider.canSync && !syncProvider.isSyncing) ...[
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () {
                      syncProvider.syncNow();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('Sync maintenant'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    Color chipColor;
    String label;

    switch (syncProvider.state) {
      case SyncState.syncing:
        chipColor = theme.colorScheme.primary;
        label = 'En cours';
        break;
      case SyncState.success:
        chipColor = Colors.green;
        label = 'OK';
        break;
      case SyncState.error:
        chipColor = theme.colorScheme.error;
        label = 'Erreur';
        break;
      case SyncState.waitingForNetwork:
        chipColor = Colors.orange;
        label = 'Hors ligne';
        break;
      case SyncState.unavailable:
        chipColor = theme.disabledColor;
        label = 'Désactivé';
        break;
      case SyncState.idle:
        chipColor = theme.colorScheme.primary;
        label = 'Prêt';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 12),
      ),
      backgroundColor: chipColor,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
