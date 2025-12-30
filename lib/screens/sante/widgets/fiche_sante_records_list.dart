import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/soin.dart';
import '../../../models/pesee.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

class FicheSanteRecordsList extends StatelessWidget {
  final List<Soin> soins;
  final List<Pesee> pesees;
  final String activeFilter;
  final Function(Soin)? onEditSoin;
  final Function(Soin)? onDeleteSoin;
  final Function(Pesee)? onEditPesee;
  final Function(Pesee)? onDeletePesee;
  final VoidCallback? onPeseeCardTap;

  const FicheSanteRecordsList({
    super.key,
    required this.soins,
    required this.pesees,
    required this.activeFilter,
    this.onEditSoin,
    this.onDeleteSoin,
    this.onEditPesee,
    this.onDeletePesee,
    this.onPeseeCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final textMain = isDark ? AppTheme.textLight : AppTheme.backgroundDarkMode;
    final textSub = isDark ? AppTheme.border : AppTheme.textSecondary;

    final records = _buildRecordsList();
    final filteredRecords = _filterRecords(records);

    if (filteredRecords.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: textSub.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun enregistrement',
                style: TextStyle(color: textSub, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: filteredRecords.map((record) {
          if (record['type'] == 'soin') {
            return _SoinCard(
              soin: record['data'] as Soin,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textMain: textMain,
              textSub: textSub,
              onEdit: onEditSoin,
              onDelete: onDeleteSoin,
            );
          } else {
            return _PeseeCard(
              pesee: record['data'] as Pesee,
              pesees: pesees,
              isDark: isDark,
              surfaceColor: surfaceColor,
              textMain: textMain,
              textSub: textSub,
              onEdit: onEditPesee,
              onDelete: onDeletePesee,
              onTap: onPeseeCardTap,
            );
          }
        }).toList(),
      ),
    );
  }

  List<Map<String, dynamic>> _buildRecordsList() {
    final List<Map<String, dynamic>> records = [];

    for (var soin in soins) {
      records.add({'type': 'soin', 'data': soin, 'date': soin.date});
    }

    for (var pesee in pesees) {
      records.add({'type': 'pesee', 'data': pesee, 'date': pesee.date});
    }

    records.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );
    return records;
  }

  List<Map<String, dynamic>> _filterRecords(
    List<Map<String, dynamic>> records,
  ) {
    return records.where((record) {
      if (activeFilter == 'Medical') return record['type'] == 'soin';
      if (activeFilter == 'Weight') return record['type'] == 'pesee';
      return true;
    }).toList();
  }
}

class _SoinCard extends StatelessWidget {
  final Soin soin;
  final bool isDark;
  final Color surfaceColor;
  final Color textMain;
  final Color textSub;
  final Function(Soin)? onEdit;
  final Function(Soin)? onDelete;

  const _SoinCard({
    required this.soin,
    required this.isDark,
    required this.surfaceColor,
    required this.textMain,
    required this.textSub,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy', 'en_US');
    final timeFormat = DateFormat('hh:mm a', 'en_US');

    Color typeColor;
    IconData typeIcon;
    String typeLabel;
    double opacity = 1.0;

    switch (soin.type.toLowerCase()) {
      case 'vaccination':
        typeColor = AppTheme.info;
        typeIcon = Icons.vaccines;
        typeLabel = 'Vaccine';
        break;
      case 'traitement':
        typeColor = AppTheme.error;
        typeIcon = Icons.healing;
        typeLabel = 'Treatment';
        break;
      case 'observation':
        typeColor = AppTheme.primaryGreen;
        typeIcon = Icons.visibility;
        typeLabel = 'Observation';
        opacity = 0.8;
        break;
      default:
        typeColor = AppTheme.textSecondary;
        typeIcon = Icons.medical_services;
        typeLabel = 'Medical';
    }

    return GestureDetector(
      onTap: () => _showSoinDetails(context),
      onLongPress: () => _showSoinActions(context),
      child: Opacity(
        opacity: opacity,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.backgroundDark.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
            border: isDark
                ? Border.all(color: AppTheme.cardLight.withValues(alpha: 0.05))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${dateFormat.format(soin.date)} • ${timeFormat.format(soin.date)}',
                          style: TextStyle(
                            color: textSub,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          soin.description,
                          style: TextStyle(
                            color: textMain,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      typeLabel,
                      style: TextStyle(
                        color: isDark
                            ? typeColor.withValues(alpha: 0.8)
                            : typeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (soin.notes != null && soin.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Text(
                    soin.notes!,
                    style: TextStyle(color: textMain, fontSize: 14),
                  ),
                ),
              ],
              if (soin.type.toLowerCase() == 'vaccination') ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Completed Successfully',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showSoinDetails(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(soin.description),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Type', soin.type),
              _buildInfoRow('Date', dateFormat.format(soin.date)),
              if (soin.medicament != null)
                _buildInfoRow('Médicament', soin.medicament!),
              if (soin.dosage != null) _buildInfoRow('Dosage', soin.dosage!),
              if (soin.dateRappel != null)
                _buildInfoRow('Rappel', dateFormat.format(soin.dateRappel!)),
              if (soin.notes != null && soin.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    soin.notes!,
                    style: AppTheme.bodyMedium.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showSoinActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              ListTile(
                leading: const Icon(Icons.edit, color: AppTheme.info),
                title: const Text('Éditer'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit!(soin);
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.error),
                title: const Text('Supprimer'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete!(soin);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PeseeCard extends StatelessWidget {
  final Pesee pesee;
  final List<Pesee> pesees;
  final bool isDark;
  final Color surfaceColor;
  final Color textMain;
  final Color textSub;
  final Function(Pesee)? onEdit;
  final Function(Pesee)? onDelete;
  final VoidCallback? onTap;

  const _PeseeCard({
    required this.pesee,
    required this.pesees,
    required this.isDark,
    required this.surfaceColor,
    required this.textMain,
    required this.textSub,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy', 'en_US');

    double? diff;
    int index = pesees.indexOf(pesee);
    if (index > 0) {
      diff = pesee.poids - pesees[index - 1].poids;
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showPeseeActions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
          border: isDark
              ? Border.all(color: AppTheme.cardLight.withValues(alpha: 0.05))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(
                      alpha: isDark ? 0.2 : 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.scale,
                    color: AppTheme.warning,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(pesee.date),
                        style: TextStyle(
                          color: textSub,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Routine Weigh-in',
                        style: AppTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(
                      alpha: isDark ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Weight',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.warning.withValues(alpha: 0.8)
                          : AppTheme.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 52),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${pesee.poids.toStringAsFixed(1)} kg',
                    style: AppTheme.titleLarge.copyWith(
                      color: textMain,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (diff != null) ...[
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Icon(
                          diff > 0 ? Icons.trending_up : Icons.trending_down,
                          color: diff > 0
                              ? AppTheme.primaryGreen
                              : AppTheme.error,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)}kg',
                          style: TextStyle(
                            color: diff > 0
                                ? AppTheme.primaryGreen
                                : AppTheme.error,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (pesee.notes != null && pesee.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 52),
                child: Text(
                  pesee.notes!,
                  style: TextStyle(color: textSub, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPeseeActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              ListTile(
                leading: const Icon(Icons.edit, color: AppTheme.info),
                title: const Text('Éditer'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit!(pesee);
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.error),
                title: const Text('Supprimer'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete!(pesee);
                },
              ),
          ],
        ),
      ),
    );
  }
}
