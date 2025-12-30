import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BackupInfoCard extends StatelessWidget {
  final String? backupPath;
  final DateTime? backupDate;
  final VoidCallback? onShare;

  const BackupInfoCard({
    super.key,
    this.backupPath,
    this.backupDate,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    if (backupDate == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dernière sauvegarde',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy à HH:mm').format(backupDate!),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (onShare != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Partager la sauvegarde'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
