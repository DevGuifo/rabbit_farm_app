import 'package:flutter/material.dart';
import '../../../../services/pdf_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../theme/app_theme.dart';

/// Widget pour générer le rapport bilan sanitaire
class BilanSanitaireRapport extends StatelessWidget {
  const BilanSanitaireRapport({super.key});

  @override
  Widget build(BuildContext context) {
    final pdfService = PdfService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.medical_services_rounded,
                    size: 64,
                    color: AppTheme.accentPink,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bilan Sanitaire',
                    style: AppTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rapport complet sur l\'état sanitaire de votre élevage',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await pdfService.genererRapportBilanSanitaire();
                if (context.mounted) {
                  SnackbarHelper.showSuccess(
                    context,
                    '✅ Rapport bilan sanitaire généré',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  SnackbarHelper.showError(
                    context,
                    '❌ Erreur: ${e.toString()}',
                  );
                }
              }
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Générer le rapport'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

