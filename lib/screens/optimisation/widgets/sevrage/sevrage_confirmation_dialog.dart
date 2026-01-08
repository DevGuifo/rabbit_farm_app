import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';

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
          backgroundColor: AppTheme.textOnPrimary,
          title: Text(
            AppLocalizations.of(context).sevrageConfirmerLeSevrage,
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).sevrageVousAllezSevrer,
                style: const TextStyle(color: Color(0xFF757575)),
              ),
              const SizedBox(height: 12),
              Text(
                '• ${AppLocalizations.of(context).sevrageLapereaux(totalPetits, nbMales, nbFemelles)}',
                style: AppTheme.bodyMedium.copyWith(
                  color: const Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cette action va :',
                style: TextStyle(color: Color(0xFF757575)),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Changer le statut des lapereaux en "Sevré"',
                style: TextStyle(color: AppTheme.textOnPrimary, fontSize: 13),
              ),
              const Text(
                '• Déplacer chaque lapereau dans sa cage',
                style: TextStyle(color: AppTheme.textOnPrimary, fontSize: 13),
              ),
              const Text(
                '• Mettre à jour le statut de la mère',
                style: TextStyle(color: AppTheme.textOnPrimary, fontSize: 13),
              ),
              const Text(
                '• Enregistrer le sevrage dans l\'historique',
                style: TextStyle(color: AppTheme.textOnPrimary, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context).commonCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
              ),
              child: Text(AppLocalizations.of(context).commonConfirm),
            ),
          ],
        );
      },
    );
  }
}
