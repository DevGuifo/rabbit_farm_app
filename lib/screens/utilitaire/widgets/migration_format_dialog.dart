import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

class MigrationFormatDialog extends StatelessWidget {
  final VoidCallback onSelectCsv;
  final VoidCallback onSelectJson;
  const MigrationFormatDialog({
    super.key,
    required this.onSelectCsv,
    required this.onSelectJson,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.sync_alt, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Importer des données',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choisissez le format de fichier à importer :',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.success.withValues(alpha: 0.2),
                child: const Icon(Icons.table_chart, color: AppTheme.success),
              ),
              title: Text(AppLocalizations.of(context).fichierCsv),
              subtitle: Text(AppLocalizations.of(context).tableurExcel),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                onSelectCsv();
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.info.withValues(alpha: 0.2),
                child: const Icon(Icons.code, color: AppTheme.info),
              ),
              title: Text(AppLocalizations.of(context).fichierJson),
              subtitle: Text(AppLocalizations.of(context).exportAutresApps),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                onSelectJson();
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Les données seront validées avant import',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.annuler),
            );
          },
        ),
      ],
    );
  }
}
