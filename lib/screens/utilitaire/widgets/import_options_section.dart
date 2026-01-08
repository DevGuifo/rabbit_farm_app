import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

class ImportOptionsSection extends StatelessWidget {
  final VoidCallback? onImportDatabase;
  final VoidCallback? onImportExcel;
  final VoidCallback? onImportJson;
  final bool isImporting;

  const ImportOptionsSection({
    super.key,
    this.onImportDatabase,
    this.onImportExcel,
    this.onImportJson,
    this.isImporting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).importRestauration,
          style: AppTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Card(
          color: AppTheme.warning.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: AppTheme.warning, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Faites toujours une sauvegarde avant d\'importer des données',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildImportCard(
          title: AppLocalizations.of(context).titleRestaurerSauvegarde,
          description: 'Remplacer les données actuelles par une sauvegarde',
          icon: Icons.restore,
          color: AppTheme.error,
          danger: true,
          onTap: isImporting ? null : onImportDatabase,
        ),
        const SizedBox(height: 12),
        _buildImportCard(
          title: AppLocalizations.of(context).titleImporterExcel,
          description: 'Ajouter des données depuis un fichier Excel',
          icon: Icons.upload_file,
          color: AppTheme.info,
          onTap: isImporting ? null : onImportExcel,
        ),
        const SizedBox(height: 12),
        _buildImportCard(
          title: AppLocalizations.of(context).titleImporterJSON,
          description: 'Importer des données au format JSON',
          icon: Icons.code,
          color: AppTheme.accentAmber,
          onTap: isImporting ? null : onImportJson,
        ),
      ],
    );
  }

  Widget _buildImportCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    bool danger = false,
  }) {
    return Card(
      elevation: 2,
      color: danger ? AppTheme.error.withValues(alpha: 0.1) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(title, style: AppTheme.titleSmall),
                        if (danger)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ATTENTION',
                              style: TextStyle(
                                color: AppTheme.textOnPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: onTap == null
                    ? AppTheme.neutral200
                    : AppTheme.neutral300,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
