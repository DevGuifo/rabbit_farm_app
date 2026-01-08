import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

class BackupTipsCard extends StatelessWidget {
  const BackupTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.info.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.info),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Conseils de sauvegarde',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• Effectuez une sauvegarde complète au moins une fois par semaine\n'
              '• Conservez les sauvegardes sur un support externe (USB, Cloud)\n'
              '• Vérifiez régulièrement l\'intégrité de vos sauvegardes\n'
              '• La restauration écrase toutes les données actuelles\n'
              '• Les exports Excel peuvent être modifiés avant réimport',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
