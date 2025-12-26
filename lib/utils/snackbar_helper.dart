import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Helper pour afficher des SnackBars standardisés
class SnackbarHelper {
  /// Durée par défaut des snackbars
  static const Duration _defaultDuration = Duration(seconds: 3);
  static const Duration _shortDuration = Duration(seconds: 2);
  static const Duration _longDuration = Duration(seconds: 5);

  /// Affiche un message de succès
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: AppTheme.success,
      duration: duration ?? _defaultDuration,
      action: action,
    );
  }

  /// Affiche un message d'erreur
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: AppTheme.error,
      duration: duration ?? _longDuration,
      action: action,
    );
  }

  /// Affiche un message d'avertissement
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.warning_rounded,
      backgroundColor: AppTheme.warning,
      duration: duration ?? _defaultDuration,
      action: action,
    );
  }

  /// Affiche un message d'information
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: AppTheme.info,
      duration: duration ?? _defaultDuration,
      action: action,
    );
  }

  /// Affiche un message neutre
  static void show(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
    IconData? icon,
  }) {
    _show(
      context,
      message: message,
      icon: icon,
      backgroundColor: AppTheme.textPrimary,
      duration: duration ?? _defaultDuration,
      action: action,
    );
  }

  /// Affiche un message de validation d'erreur
  static void showValidationError(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.warning_rounded,
      backgroundColor: AppTheme.warning,
      duration: duration ?? _shortDuration,
    );
  }

  /// Affiche un message de chargement
  static void showLoading(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.primaryGreen,
        duration: duration ?? _longDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  /// Méthode interne pour créer et afficher un SnackBar
  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration duration = _defaultDuration,
    SnackBarAction? action,
  }) {
    // Cacher les snackbars précédents
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Afficher le nouveau snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: AppTheme.spacing12),
            ],
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        margin: const EdgeInsets.all(AppTheme.spacing16),
      ),
    );
  }

  /// Affiche un SnackBar personnalisé
  static void showCustom(
    BuildContext context, {
    required Widget content,
    Color? backgroundColor,
    Duration duration = _defaultDuration,
    SnackBarAction? action,
    EdgeInsets? margin,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: content,
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        margin: margin ?? const EdgeInsets.all(AppTheme.spacing16),
      ),
    );
  }

  /// Cache le SnackBar actuel
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Cache tous les SnackBars
  static void hideAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}
