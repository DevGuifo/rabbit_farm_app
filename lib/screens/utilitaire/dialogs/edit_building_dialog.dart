import 'package:flutter/material.dart';
import '../../../models/batiment.dart';
import '../../../services/database_helper.dart';
import '../../../utils/logger.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Dialog pour modifier un bâtiment
class EditBuildingDialog {
  static Future<bool> show(BuildContext context, Batiment batiment) async {
    final controller = TextEditingController(text: batiment.nom);
    final l10n = AppLocalizations.of(context);

    final nom = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.backgroundDark
            : AppTheme.cardLight,
        title: Text(l10n.modifierBatiment),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.hintBuildingName,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.annuler),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );

    if (nom == null || nom.isEmpty || nom == batiment.nom) return false;

    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'batiments',
        {'nom': nom},
        where: 'id = ?',
        whereArgs: [batiment.id],
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).msgBatimentModifie),
          ),
        );
      }
      return true;
    } catch (e) {
      logger.error('Erreur modification bâtiment: $e');
      return false;
    }
  }
}
