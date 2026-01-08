import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class MedicamentsStatsRow extends StatelessWidget {
  final int total;
  final int alertes;
  final String valeurStock;

  const MedicamentsStatsRow({
    super.key,
    required this.total,
    required this.alertes,
    required this.valeurStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.accentPink.withValues(alpha: 0.08),
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatCard(
            label: AppLocalizations.of(context).labelTotal,
            value: '$total',
            icon: Icons.medication_rounded,
            color: AppTheme.info,
          ),
          _StatCard(
            label: AppLocalizations.of(context).labelAlertes,
            value: '$alertes',
            icon: Icons.warning_rounded,
            color: AppTheme.error,
          ),
          _StatCard(
            label: AppLocalizations.of(context).labelValue,
            value: valeurStock,
            icon: Icons.euro_rounded,
            color: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.titleLarge.copyWith(color: color)),
        Text(
          label,
          style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
