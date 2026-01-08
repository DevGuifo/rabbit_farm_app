import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

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
      color: AppTheme.success.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.success,
                  size: 32,
                ),
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
                        style: TextStyle(color: AppTheme.textPrimary),
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
                  label: Text(AppLocalizations.of(context).partagerSauvegarde),
                  style: AppTheme.primaryButtonStyle.copyWith(
                    backgroundColor: WidgetStateProperty.all(AppTheme.success),
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
