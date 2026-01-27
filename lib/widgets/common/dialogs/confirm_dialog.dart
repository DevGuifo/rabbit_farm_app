import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🔔 CONFIRM DIALOG - Dialogue de confirmation standardisé
/// ═══════════════════════════════════════════════════════════════════════════
///
/// RÈGLES D'UTILISATION :
/// - Pour toutes les confirmations de suppression, annulation, etc.
/// - Couleurs sémantiques : rouge pour destructif, vert pour confirmer
/// - Libellés standardisés via AppLocalizations
///
/// USAGE :
/// ```dart
/// final confirmed = await ConfirmDialog.show(
///   context: context,
///   title: 'Supprimer le lapin ?',
///   message: 'Cette action est irréversible.',
///   confirmText: 'Supprimer',
///   isDestructive: true,
/// );
/// if (confirmed) { ... }
/// ```
///
/// USAGE AVEC UNDO (suppression avec annulation) :
/// ```dart
/// final confirmed = await ConfirmDialog.showWithUndo(
///   context: context,
///   title: 'Supprimer le lapin ?',
///   message: 'Cette action peut être annulée.',
///   onConfirm: () async { await _deleteItem(); },
///   onUndo: () async { await _restoreItem(); },
/// );
/// ```
/// ═══════════════════════════════════════════════════════════════════════════

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String? confirmText;
  final String? cancelText;
  final bool isDestructive;
  final IconData? icon;

  const ConfirmDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmText,
    this.cancelText,
    this.isDestructive = false,
    this.icon,
  });

  /// Affiche un dialogue de confirmation simple
  /// Retourne true si confirmé, false sinon
  static Future<bool> show({
    required BuildContext context,
    required String title,
    String? message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText:
            confirmText ??
            (isDestructive ? l10n.commonSupprimer : l10n.commonConfirmer),
        cancelText: cancelText ?? l10n.commonAnnuler,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  /// Affiche un dialogue avec possibilité d'annulation (Undo)
  /// Exécute l'action puis affiche une snackbar avec option d'annulation
  static Future<void> showWithUndo({
    required BuildContext context,
    required String title,
    String? message,
    required Future<void> Function() onConfirm,
    required Future<void> Function() onUndo,
    String? undoMessage,
    Duration undoDuration = const Duration(seconds: 5),
  }) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await show(
      context: context,
      title: title,
      message: message,
      isDestructive: true,
    );

    if (!confirmed) return;

    // Exécuter l'action
    await onConfirm();

    // Afficher la snackbar avec Undo
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(undoMessage ?? l10n.commonActionEffectuee),
          duration: undoDuration,
          action: SnackBarAction(
            label: l10n.commonAnnuler,
            textColor: AppTheme.accentAmber,
            onPressed: () async {
              await onUndo();
            },
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final effectiveIcon =
        icon ??
        (isDestructive
            ? Icons.warning_amber_rounded
            : Icons.help_outline_rounded);
    final iconColor = isDestructive ? AppTheme.error : AppTheme.info;
    final confirmColor = isDestructive ? AppTheme.error : AppTheme.primaryGreen;

    return AlertDialog(
      backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      icon: Icon(effectiveIcon, color: iconColor, size: 48),
      title: Text(
        title,
        style: AppTheme.titleMedium.copyWith(
          color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
      content: message != null
          ? Text(
              message!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            )
          : null,
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        // Bouton Annuler
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            cancelText ?? l10n.commonAnnuler,
            style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary),
          ),
        ),
        // Bouton Confirmer
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: AppTheme.textOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
          ),
          child: Text(
            confirmText ??
                (isDestructive ? l10n.commonSupprimer : l10n.commonConfirmer),
            style: AppTheme.labelLarge.copyWith(
              color: AppTheme.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
