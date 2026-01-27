import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/pdf_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/error_service.dart';

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
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return ElevatedButton.icon(
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
                      ErrorService.showError(context, e);
                    }
                  }
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(l10n.genererRapport),
                style: AppTheme.primaryButtonStyle,
              );
            },
          ),
        ],
      ),
    );
  }
}
