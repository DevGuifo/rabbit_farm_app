import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

class ExportOptionsSection extends StatelessWidget {
  final VoidCallback? onExportDatabase;
  final VoidCallback? onExportExcel;
  final VoidCallback? onExportJson;
  final VoidCallback? onExportCsv;
  final bool isExporting;

  const ExportOptionsSection({
    super.key,
    this.onExportDatabase,
    this.onExportExcel,
    this.onExportJson,
    this.onExportCsv,
    this.isExporting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).exportDonnees,
          style: AppTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        _buildExportCard(
          title: AppLocalizations.of(context).titleSauvegardeComplete,
          description: 'Base de données SQLite + toutes les photos',
          icon: Icons.backup,
          color: AppTheme.info,
          onTap: isExporting ? null : onExportDatabase,
        ),
        const SizedBox(height: 12),
        _buildExportCard(
          title: AppLocalizations.of(context).titleExportExcel,
          description: 'Tableaux Excel par table (lapins, accouplements, etc.)',
          icon: Icons.table_chart,
          color: AppTheme.success,
          onTap: isExporting ? null : onExportExcel,
        ),
        const SizedBox(height: 12),
        _buildExportCard(
          title: AppLocalizations.of(context).titleExportJSON,
          description: 'Format JSON pour API ou développeurs',
          icon: Icons.code,
          color: AppTheme.warning,
          onTap: isExporting ? null : onExportJson,
        ),
        const SizedBox(height: 12),
        _buildExportCard(
          title: AppLocalizations.of(context).titleExportCSV,
          description: 'Format CSV pour tableurs (Excel, LibreOffice)',
          icon: Icons.grid_on,
          color: AppTheme.accentAmber,
          onTap: isExporting ? null : onExportCsv,
        ),
      ],
    );
  }

  Widget _buildExportCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
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
                    Text(title, style: AppTheme.titleSmall),
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
