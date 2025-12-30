import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

class SevrageConfirmationDialog {
  static Future<bool?> show(
    BuildContext context, {
    required int totalPetits,
    required int nbMales,
    required int nbFemelles,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Confirmer le sevrage',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vous allez sevrer :',
                style: TextStyle(color: Color(0xFF757575)),
              ),
              const SizedBox(height: 12),
              Text(
                '• $totalPetits lapereaux ($nbMales mâles, $nbFemelles femelles)',
                style: AppTheme.bodyMedium.copyWith(color: Color(0xFF212121)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cette action va :',
                style: TextStyle(color: Color(0xFF757575)),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Changer le statut des lapereaux en "Sevré"',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              const Text(
                '• Déplacer chaque lapereau dans sa cage',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              const Text(
                '• Mettre à jour le statut de la mère',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              const Text(
                '• Enregistrer le sevrage dans l\'historique',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }
}
