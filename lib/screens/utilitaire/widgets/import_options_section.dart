import 'package:flutter/material.dart';
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
        const Text('IMPORT / RESTAURATION', style: AppTheme.titleMedium),
        const SizedBox(height: 16),
        Card(
          color: Colors.orange[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[700], size: 28),
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
          title: 'Restaurer une sauvegarde',
          description: 'Remplacer les données actuelles par une sauvegarde',
          icon: Icons.restore,
          color: Colors.red,
          danger: true,
          onTap: isImporting ? null : onImportDatabase,
        ),
        const SizedBox(height: 12),
        _buildImportCard(
          title: 'Importer depuis Excel',
          description: 'Ajouter des données depuis un fichier Excel',
          icon: Icons.upload_file,
          color: Colors.blue,
          onTap: isImporting ? null : onImportExcel,
        ),
        const SizedBox(height: 12),
        _buildImportCard(
          title: 'Importer depuis JSON',
          description: 'Importer des données au format JSON',
          icon: Icons.code,
          color: Colors.teal,
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
      color: danger ? Colors.red[50] : null,
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
                    Row(
                      children: [
                        Text(title, style: AppTheme.titleSmall),
                        if (danger) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ATTENTION',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: onTap == null ? Colors.grey[300] : Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
