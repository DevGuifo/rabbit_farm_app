import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../validators/validation_result.dart';
import '../theme/app_theme.dart';

/// Widget helper pour afficher les messages de validation
class ValidationMessageWidget extends StatelessWidget {
  final List<ValidationResult> validationResults;

  const ValidationMessageWidget({super.key, required this.validationResults});

  @override
  Widget build(BuildContext context) {
    // Filtrer uniquement les résultats avec messages
    final messagesAfficher = validationResults
        .where((r) => r.errorMessage != null && r.errorMessage!.isNotEmpty)
        .toList();

    if (messagesAfficher.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: messagesAfficher.map((result) {
        return _buildMessage(context, result);
      }).toList(),
    );
  }

  Widget _buildMessage(BuildContext context, ValidationResult result) {
    Color couleur;
    IconData icone;
    Color backgroundColor;

    switch (result.severity) {
      case ValidationSeverity.bloquante:
        couleur = AppTheme.error;
        backgroundColor = AppTheme.error.withValues(alpha: 0.1);
        icone = Icons.error;
        break;
      case ValidationSeverity.avertissement:
        couleur = AppTheme.warning;
        backgroundColor = AppTheme.warning.withValues(alpha: 0.1);
        icone = Icons.warning;
        break;
      case ValidationSeverity.information:
        couleur = AppTheme.info;
        backgroundColor = AppTheme.info.withValues(alpha: 0.1);
        icone = Icons.info;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: couleur.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: couleur, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              result.errorMessage!,
              style: AppTheme.bodySmall.copyWith(color: couleur, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper pour vérifier si un bouton doit être désactivé
class ValidationHelper {
  /// Retourne true si au moins une validation est bloquante et échoue
  static bool hasBlockingError(List<ValidationResult> results) {
    return results.any(
      (r) => !r.isValid && r.severity == ValidationSeverity.bloquante,
    );
  }

  /// Retourne true si toutes les validations critiques sont OK
  static bool canProceed(List<ValidationResult> results) {
    return !hasBlockingError(results);
  }

  /// Obtenir le premier message d'erreur bloquant
  static String? getFirstBlockingError(List<ValidationResult> results) {
    final blockingError = results.firstWhere(
      (r) => !r.isValid && r.severity == ValidationSeverity.bloquante,
      orElse: () => const ValidationResult.success(),
    );

    return blockingError.errorMessage;
  }

  /// Afficher une snackbar pour les avertissements
  static void showWarningDialog(
    BuildContext context,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppTheme.warning),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).widgetAvertissement),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.warning),
            child: Text(AppLocalizations.of(context).widgetContinuerQuandMeme),
          ),
        ],
      ),
    );
  }
}
