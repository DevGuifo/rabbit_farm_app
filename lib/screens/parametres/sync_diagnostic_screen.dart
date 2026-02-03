import 'package:flutter/material.dart';
import '../../services/sync_service.dart';
import '../../config/supabase_config.dart';
import '../../theme/app_theme.dart';

/// Écran de diagnostic pour tester la synchronisation Supabase
///
/// Permet de :
/// - Vérifier l'état de connexion Supabase
/// - Voir les éléments en attente de sync
/// - Lancer une synchronisation manuelle
/// - Réinitialiser la queue de sync
class SyncDiagnosticScreen extends StatefulWidget {
  const SyncDiagnosticScreen({super.key});

  @override
  State<SyncDiagnosticScreen> createState() => _SyncDiagnosticScreenState();
}

class _SyncDiagnosticScreenState extends State<SyncDiagnosticScreen> {
  final SyncService _syncService = SyncService();

  bool _isLoading = false;
  bool? _isConnected;
  String _statusMessage = '';
  List<SyncQueueItem> _pendingItems = [];
  SyncResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);

    try {
      await _syncService.initialize();
      await _refreshStatus();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshStatus() async {
    setState(() => _isLoading = true);

    try {
      _isConnected = await _syncService.checkConnectivity();
      _pendingItems = await _syncService.getPendingItems();

      setState(() {
        _statusMessage = _isConnected == true
            ? '✅ Connecté à Supabase'
            : '❌ Non connecté à Supabase';
      });
    } catch (e) {
      setState(() => _statusMessage = '❌ Erreur: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _runSync() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '🔄 Synchronisation en cours...';
    });

    try {
      _lastResult = await _syncService.syncNow();
      await _refreshStatus();

      setState(() {
        if (_lastResult!.success) {
          _statusMessage =
              '✅ Sync réussie: ${_lastResult!.syncedCount} éléments';
        } else {
          _statusMessage =
              '⚠️ Sync partielle: ${_lastResult!.syncedCount} OK, ${_lastResult!.failedCount} échecs';
        }
      });
    } catch (e) {
      setState(() => _statusMessage = '❌ Erreur sync: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _runFullSync() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '🔄 Synchronisation complète en cours...';
    });

    try {
      _lastResult = await _syncService.fullSync();
      await _refreshStatus();

      setState(() {
        _statusMessage =
            '✅ Full sync: ${_lastResult!.syncedCount} éléments en ${_lastResult!.duration.inMilliseconds}ms';
      });
    } catch (e) {
      setState(() => _statusMessage = '❌ Erreur full sync: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetQueue() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Réinitialiser la queue?'),
        content: const Text(
          'Cela supprimera tous les éléments en attente de sync.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _syncService.resetSync();
      await _refreshStatus();
      setState(() => _statusMessage = '🗑️ Queue réinitialisée');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic Sync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshStatus,
          ),
        ],
      ),
      body: _isLoading && _pendingItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshStatus,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status Card
                    _buildStatusCard(isDark),
                    const SizedBox(height: 16),

                    // Info Cards
                    _buildInfoCards(isDark),
                    const SizedBox(height: 16),

                    // Actions
                    _buildActionButtons(),
                    const SizedBox(height: 24),

                    // Pending Items
                    _buildPendingItemsList(isDark),

                    // Last Result
                    if (_lastResult != null) ...[
                      const SizedBox(height: 24),
                      _buildLastResultCard(isDark),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    return Card(
      color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              _isConnected == true ? Icons.cloud_done : Icons.cloud_off,
              size: 48,
              color: _isConnected == true
                  ? AppTheme.primaryGreen
                  : AppTheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            isDark,
            'En attente',
            '${_pendingItems.length}',
            Icons.pending_actions,
            AppTheme.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            isDark,
            'Supabase',
            supabaseConfig.isInitialized ? 'Actif' : 'Inactif',
            Icons.cloud,
            supabaseConfig.isInitialized
                ? AppTheme.primaryGreen
                : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            isDark,
            'Auto-sync',
            _syncService.isSyncing ? 'En cours' : 'Prêt',
            Icons.sync,
            _syncService.isSyncing ? AppTheme.info : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    bool isDark,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _runSync,
          icon: const Icon(Icons.sync),
          label: const Text('Sync Push'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _runFullSync,
          icon: const Icon(Icons.sync_alt),
          label: const Text('Full Sync'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.info,
            foregroundColor: Colors.white,
          ),
        ),
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _resetQueue,
          icon: const Icon(Icons.delete_sweep),
          label: const Text('Reset'),
          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error),
        ),
      ],
    );
  }

  Widget _buildPendingItemsList(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Éléments en attente (${_pendingItems.length})',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (_pendingItems.isEmpty)
          Card(
            color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryGreen,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tout est synchronisé !',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...(_pendingItems
              .take(10)
              .map(
                (item) => Card(
                  color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getOperationColor(
                        item.operation,
                      ).withValues(alpha: 0.2),
                      child: Icon(
                        _getOperationIcon(item.operation),
                        color: _getOperationColor(item.operation),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      '${item.tableName} #${item.localId}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${item.operation.name.toUpperCase()} • Retry: ${item.retryCount}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Text(
                      _formatTime(item.createdAt),
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              )),
        if (_pendingItems.length > 10)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '... et ${_pendingItems.length - 10} autres',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
      ],
    );
  }

  Widget _buildLastResultCard(bool isDark) {
    final result = _lastResult!;
    return Card(
      color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  result.success ? Icons.check_circle : Icons.warning,
                  color: result.success
                      ? AppTheme.primaryGreen
                      : AppTheme.warning,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dernière synchronisation',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildResultRow(
              'Synchronisés',
              '${result.syncedCount}',
              AppTheme.primaryGreen,
            ),
            _buildResultRow('Échecs', '${result.failedCount}', AppTheme.error),
            _buildResultRow(
              'Conflits',
              '${result.conflictCount}',
              AppTheme.warning,
            ),
            _buildResultRow(
              'Durée',
              '${result.duration.inMilliseconds}ms',
              AppTheme.info,
            ),
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Erreurs:',
                style: TextStyle(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ...result.errors
                  .take(3)
                  .map(
                    (e) => Text(
                      '• $e',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  IconData _getOperationIcon(SyncOperation op) {
    switch (op) {
      case SyncOperation.insert:
        return Icons.add_circle;
      case SyncOperation.update:
        return Icons.edit;
      case SyncOperation.delete:
        return Icons.delete;
    }
  }

  Color _getOperationColor(SyncOperation op) {
    switch (op) {
      case SyncOperation.insert:
        return AppTheme.primaryGreen;
      case SyncOperation.update:
        return AppTheme.info;
      case SyncOperation.delete:
        return AppTheme.error;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return '${dt.day}/${dt.month}';
  }
}
