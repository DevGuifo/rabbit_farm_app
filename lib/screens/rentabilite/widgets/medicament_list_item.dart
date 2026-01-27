import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/medicament.dart';
import '../../../theme/app_theme.dart';

class MedicamentListItem extends StatelessWidget {
  final Medicament medicament;
  final void Function(String action) onActionSelected;

  const MedicamentListItem({
    super.key,
    required this.medicament,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final hasAlerte =
        medicament.estEnRupture ||
        medicament.estSousSeuilAlerte ||
        medicament.estPerime ||
        medicament.expireSoon;

    Color backgroundColor = hasAlerte
        ? AppTheme.error.withValues(alpha: 0.08)
        : Theme.of(context).colorScheme.surface;
    Color borderColor = hasAlerte
        ? AppTheme.error.withValues(alpha: 0.3)
        : AppTheme.border;
    String? alerteText;

    if (medicament.estPerime) {
      alerteText = '⚠️ PÉRIMÉ';
    } else if (medicament.estEnRupture) {
      alerteText = '⚠️ RUPTURE DE STOCK';
    } else if (medicament.expireSoon) {
      alerteText = '⚠️ Expire bientôt';
    } else if (medicament.estSousSeuilAlerte) {
      alerteText = '⚠️ Stock faible';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(medicament.type.value),
          child: Icon(
            _getTypeIcon(medicament.type.value),
            color: AppTheme.textOnPrimary,
          ),
        ),
        title: Text(
          medicament.nom,
          style: AppTheme.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  medicament.quantiteStock > 0
                      ? Icons.check_circle
                      : Icons.cancel,
                  size: 16,
                  color: medicament.quantiteStock > 0
                      ? AppTheme.primaryGreen
                      : AppTheme.error,
                ),
                const SizedBox(width: 4),
                Text(
                  '${medicament.quantiteStock} ${medicament.unite}',
                  style: AppTheme.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: medicament.quantiteStock > 0
                        ? AppTheme.primaryGreen
                        : AppTheme.error,
                  ),
                ),
                if (medicament.seuilAlerte != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(seuil: ${medicament.seuilAlerte} ${medicament.unite})',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            if (alerteText != null) ...[
              const SizedBox(height: 4),
              Text(
                alerteText,
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: onActionSelected,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'utiliser',
              child: _MenuRow(
                icon: Icons.remove_circle,
                color: AppTheme.warning,
                text: AppLocalizations.of(context).medicamentUtiliser,
              ),
            ),
            PopupMenuItem(
              value: 'reapprovisionner',
              child: _MenuRow(
                icon: Icons.add_circle,
                color: AppTheme.success,
                text: AppLocalizations.of(context).medicamentReapprovisionner,
              ),
            ),
            PopupMenuItem(
              value: 'modifier',
              child: _MenuRow(
                icon: Icons.edit,
                color: AppTheme.info,
                text: AppLocalizations.of(context).modifier,
              ),
            ),
            PopupMenuItem(
              value: 'supprimer',
              child: _MenuRow(
                icon: Icons.delete,
                color: AppTheme.error,
                text: AppLocalizations.of(context).supprimer,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow('Type', medicament.type.label),
                if (medicament.dateExpiration != null)
                  _InfoRow(
                    'Expiration',
                    dateFormat.format(medicament.dateExpiration!),
                    icon: Icons.calendar_today,
                  ),
                if (medicament.prixUnitaire != null)
                  _InfoRow(
                    'Prix unitaire',
                    '${medicament.prixUnitaire!.toStringAsFixed(2)} €',
                    icon: Icons.euro,
                  ),
                if (medicament.posologie != null)
                  _InfoRow(
                    'Posologie',
                    medicament.posologie!,
                    icon: Icons.medical_information,
                  ),
                if (medicament.notes != null && medicament.notes!.isNotEmpty)
                  _InfoRow('Notes', medicament.notes!, icon: Icons.note),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'antibiotique':
        return AppTheme.error;
      case 'antiparasitaire':
        return AppTheme.warning;
      case 'vaccin':
        return AppTheme.info;
      case 'vitamine':
        return AppTheme.primaryGreen;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'antibiotique':
        return Icons.coronavirus_rounded;
      case 'antiparasitaire':
        return Icons.bug_report_rounded;
      case 'vaccin':
        return Icons.vaccines_rounded;
      case 'vitamine':
        return Icons.energy_savings_leaf_rounded;
      default:
        return Icons.medication_rounded;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _InfoRow(this.label, this.value, {this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: AppTheme.spacing8),
          ],
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTheme.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _MenuRow({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
