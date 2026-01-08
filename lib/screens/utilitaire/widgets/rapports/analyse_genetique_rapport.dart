import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/pdf_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../theme/app_theme.dart';

/// Widget pour générer le rapport d'analyse génétique
class AnalyseGenetiqueRapport extends StatelessWidget {
  const AnalyseGenetiqueRapport({super.key});

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
                    Icons.psychology_rounded,
                    size: 64,
                    color: AppTheme.accentTeal,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Analyse Génétique',
                    style: AppTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Analyse de la consanguinité du cheptel',
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
                    await pdfService.genererRapportAnalyseGenetique();
                    if (context.mounted) {
                      SnackbarHelper.showSuccess(
                        context,
                        '✅ Rapport analyse génétique généré',
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
