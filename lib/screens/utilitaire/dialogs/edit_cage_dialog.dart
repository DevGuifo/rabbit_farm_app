import 'package:flutter/material.dart';
import '../../../models/cage.dart';
import '../../../services/database_helper.dart';
import '../../../utils/logger.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Dialog pour modifier une cage
class EditCageDialog {
  static Future<bool> show(BuildContext context, Cage cage) async {
    final numeroController = TextEditingController(text: cage.numero);
    final capaciteController = TextEditingController(
      text: cage.capacite.toString(),
    );
    String typeSelectionne = cage.type;
    final l10n = AppLocalizations.of(context);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.backgroundDark
              : AppTheme.cardLight,
          title: Text(l10n.modifierCage),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: numeroController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de cage',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: typeSelectionne,
                  decoration: const InputDecoration(
                    labelText: 'Type de cage',
                    border: OutlineInputBorder(),
                  ),
                  items: ['individuelle', 'collective', 'maternité']
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => typeSelectionne = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: capaciteController,
                  decoration: const InputDecoration(
                    labelText: 'Capacité (nombre de lapins)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.annuler),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'numero': numeroController.text,
                  'type': typeSelectionne,
                  'capacite': int.tryParse(capaciteController.text) ?? 1,
                });
              },
              child: Text(l10n.modifier),
            ),
          ],
        ),
      ),
    );

    if (result == null) return false;

    final cageModifiee = Cage(
      id: cage.id,
      clapierId: cage.clapierId,
      numero: result['numero'] as String,
      type: result['type'] as String,
      capacite: result['capacite'] as int,
    );

    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'cages',
        cageModifiee.toMap(),
        where: 'id = ?',
        whereArgs: [cageModifiee.id],
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).msgCageModifiee)),
        );
      }
      return true;
    } catch (e) {
      logger.error('Erreur modification cage: $e');
      return false;
    }
  }
}
