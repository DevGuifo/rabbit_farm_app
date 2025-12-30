import 'package:flutter/material.dart';

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
          const Text('Importer des données'),
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
                backgroundColor: Colors.green.withValues(alpha: 0.2),
                child: const Icon(Icons.table_chart, color: Colors.green),
              ),
              title: const Text('Fichier CSV'),
              subtitle: const Text('Tableur Excel, Google Sheets...'),
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
                backgroundColor: Colors.blue.withValues(alpha: 0.2),
                child: const Icon(Icons.code, color: Colors.blue),
              ),
              title: const Text('Fichier JSON'),
              subtitle: const Text('Export d\'autres apps'),
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
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
