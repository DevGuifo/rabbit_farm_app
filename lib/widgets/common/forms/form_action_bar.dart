import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 📝 FORM ACTION BAR - Barre d'actions sticky pour les formulaires
/// ═══════════════════════════════════════════════════════════════════════════
///
/// RÈGLES D'UTILISATION :
/// - Utilisé en bas des formulaires d'ajout/modification
/// - Boutons standardisés : Annuler (secondaire) + Enregistrer (primaire)
/// - Position sticky (toujours visible)
///
/// USAGE :
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       Expanded(child: Form(...)),
///       FormActionBar(
///         onCancel: () => Navigator.pop(context),
///         onSave: _enregistrer,
///         isLoading: _isSaving,
///       ),
///     ],
///   ),
/// )
/// ```
///
/// USAGE AVEC BOTTOMSHEET :
/// ```dart
/// FormActionBar.inBottomSheet(
///   onCancel: () => Navigator.pop(context),
///   onSave: _enregistrer,
/// )
/// ```
/// ═══════════════════════════════════════════════════════════════════════════

class FormActionBar extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final String? cancelText;
  final String? saveText;
  final bool isLoading;
  final bool showCancel;
  final bool isEnabled;

  const FormActionBar({
    super.key,
    this.onCancel,
    this.onSave,
    this.cancelText,
    this.saveText,
    this.isLoading = false,
    this.showCancel = true,
    this.isEnabled = true,
  });

  /// Version pour utilisation dans un BottomSheet
  factory FormActionBar.inBottomSheet({
    VoidCallback? onCancel,
    VoidCallback? onSave,
    String? cancelText,
    String? saveText,
    bool isLoading = false,
    bool showCancel = true,
    bool isEnabled = true,
  }) {
    return FormActionBar(
      onCancel: onCancel,
      onSave: onSave,
      cancelText: cancelText,
      saveText: saveText,
      isLoading: isLoading,
      showCancel: showCancel,
      isEnabled: isEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppTheme.textSecondary.withValues(alpha: 0.3)
                : AppTheme.textSecondary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Bouton Annuler
            if (showCancel)
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                  ),
                  child: Text(
                    cancelText ?? l10n.commonAnnuler,
                    style: AppTheme.labelLarge.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            if (showCancel) const SizedBox(width: 16),
            // Bouton Enregistrer
            Expanded(
              flex: showCancel ? 1 : 2,
              child: ElevatedButton(
                onPressed: (isLoading || !isEnabled) ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: AppTheme.textOnPrimary,
                  disabledBackgroundColor: AppTheme.primaryGreen.withValues(
                    alpha: 0.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.textOnPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                      )
                    : Text(
                        saveText ?? l10n.commonEnregistrer,
                        style: AppTheme.labelLarge.copyWith(
                          color: AppTheme.textOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 📱 STICKY FORM WRAPPER - Wrapper pour formulaires avec actions sticky
/// ═══════════════════════════════════════════════════════════════════════════
///
/// USAGE :
/// ```dart
/// StickyFormWrapper(
///   onCancel: () => Navigator.pop(context),
///   onSave: _enregistrer,
///   child: Form(
///     child: ListView(
///       children: [...],
///     ),
///   ),
/// )
/// ```
/// ═══════════════════════════════════════════════════════════════════════════

class StickyFormWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final String? cancelText;
  final String? saveText;
  final bool isLoading;
  final bool showCancel;
  final bool isEnabled;

  const StickyFormWrapper({
    super.key,
    required this.child,
    this.onCancel,
    this.onSave,
    this.cancelText,
    this.saveText,
    this.isLoading = false,
    this.showCancel = true,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: child),
        FormActionBar(
          onCancel: onCancel,
          onSave: onSave,
          cancelText: cancelText,
          saveText: saveText,
          isLoading: isLoading,
          showCancel: showCancel,
          isEnabled: isEnabled,
        ),
      ],
    );
  }
}
