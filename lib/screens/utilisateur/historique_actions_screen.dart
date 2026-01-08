import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_provider.dart';
import '../../models/user_action_log.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

/// Écran d'affichage de l'historique des actions utilisateurs
class HistoriqueActionsScreen extends StatefulWidget {
  const HistoriqueActionsScreen({super.key});

  @override
  State<HistoriqueActionsScreen> createState() =>
      _HistoriqueActionsScreenState();
}

class _HistoriqueActionsScreenState extends State<HistoriqueActionsScreen> {
  List<UserActionLog> _logs = [];
  bool _isLoading = false;
  String _filterType = 'all'; // 'all', 'my', 'today', 'week'

  @override
  void initState() {
    super.initState();
    _chargerLogs();
  }

  Future<void> _chargerLogs() async {
    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();
    List<UserActionLog> logs;

    switch (_filterType) {
      case 'my':
        logs = await userProvider.getMyActionLogs(limit: 100);
        break;
      case 'today':
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        logs = await userProvider.getActionLogsByPeriod(today, now);
        break;
      case 'week':
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        logs = await userProvider.getActionLogsByPeriod(weekAgo, now);
        break;
      default:
        logs = await userProvider.getAllActionLogs(limit: 100);
    }

    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

  String _getActionIcon(ActionType type) {
    switch (type) {
      case ActionType.create:
        return '➕';
      case ActionType.update:
        return '✏️';
      case ActionType.delete:
        return '🗑️';
      case ActionType.view:
        return '👁️';
      case ActionType.export:
        return '📤';
      case ActionType.import:
        return '📥';
      case ActionType.login:
        return '🔐';
      case ActionType.logout:
        return '🚪';
      case ActionType.settings:
        return '⚙️';
    }
  }

  Color _getActionColor(ActionType type) {
    switch (type) {
      case ActionType.create:
        return AppTheme.success;
      case ActionType.update:
        return AppTheme.info;
      case ActionType.delete:
        return AppTheme.error;
      case ActionType.view:
        return AppTheme.textSecondary;
      case ActionType.export:
      case ActionType.import:
        return AppTheme.accentTeal;
      case ActionType.login:
      case ActionType.logout:
        return AppTheme.primaryNeonGreen;
      case ActionType.settings:
        return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDarkMode
          : AppTheme.backgroundLight,
      body: Column(
        children: [
          StandardHeader(
            title: AppLocalizations.of(context).screenHistoriqueActions,
            isDark: isDark,
            onSync: _chargerLogs,
            onNotifications: null,
            onSettings: null,
          ),
          // Filtres
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'all',
                        label: Text(AppLocalizations.of(context).labelTous),
                      ),
                      ButtonSegment(
                        value: 'my',
                        label: Text(
                          AppLocalizations.of(context).labelMesActions,
                        ),
                      ),
                      ButtonSegment(
                        value: 'today',
                        label: Text(
                          AppLocalizations.of(context).labelAujourdhui,
                        ),
                      ),
                      ButtonSegment(
                        value: 'week',
                        label: Text(AppLocalizations.of(context).label7Jours),
                      ),
                    ],
                    selected: {_filterType},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _filterType = newSelection.first;
                        _chargerLogs();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Liste des logs
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return _buildLogCard(log, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 80,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune action',
            style: AppTheme.titleLarge.copyWith(
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune action enregistrée pour cette période',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(UserActionLog log, bool isDark) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final actionColor = _getActionColor(log.actionType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icône de l'action
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: actionColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _getActionIcon(log.actionType),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.description ??
                        '${log.actionTypeString} ${log.entityType}',
                    style: AppTheme.titleSmall.copyWith(
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: actionColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          log.entityType,
                          style: AppTheme.bodySmall.copyWith(
                            color: actionColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (log.entityId != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '#${log.entityId}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(log.dateAction),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
