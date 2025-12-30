import 'package:flutter/material.dart';
import '../../../models/batiment.dart';
import '../../../services/database_helper.dart';
import '../../../utils/logger.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Dialog pour modifier un bâtiment
class EditBuildingDialog {
  static Future<bool> show(BuildContext context, Batiment batiment) async {
    final controller = TextEditingController(text: batiment.nom);

    final nom = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.backgroundDark
            : AppTheme.cardLight,
        title: const Text('Modifier bâtiment'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nom du bâtiment',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✓ Bâtiment modifié')));
      }
      return true;
    } catch (e) {
      logger.error('Erreur modification bâtiment: $e');
      return false;
    }
  }
}
