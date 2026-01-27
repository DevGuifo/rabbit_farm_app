import 'package:flutter/material.dart';
import '../../core/services/error_service.dart';

/// Helper pour afficher des SnackBars améliorés avec feedback utilisateur
///
/// Cette classe fournit des méthodes statiques pour afficher des notifications
/// contextuelles avec des styles adaptés au type de message.
///
/// ## Exemple d'utilisation
///
/// ```dart
/// // Succès
/// SnackBarHelper.success(context, 'Lapin ajouté avec succès');
///
/// // Erreur avec ErrorInfo
/// SnackBarHelper.fromError(context, errorInfo);
///
/// // Warning
/// SnackBarHelper.warning(context, 'Attention: cette action est irréversible');
/// ```
class SnackBarHelper {
  /// Afficher un message de succès
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.green.shade700,
      icon: Icons.check_circle,
      duration: duration,
    );
  }

  /// Afficher un message d'erreur
  static void error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 5),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.red.shade700,
      icon: Icons.error,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  /// Afficher un message d'erreur depuis ErrorInfo
  static void fromError(
    BuildContext context,
    ErrorInfo errorInfo, {
    VoidCallback? onRetry,
  }) {
    _show(
      context,
      message: errorInfo.userMessage,
      backgroundColor: _getColorForCategory(errorInfo.category),
      icon: _getIconForCategory(errorInfo.category),
      actionLabel: errorInfo.isRecoverable && onRetry != null
          ? 'Réessayer'
          : null,
      onAction: onRetry,
      duration: const Duration(seconds: 5),
    );
  }

  /// Afficher un avertissement
  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.orange.shade700,
      icon: Icons.warning,
      duration: duration,
    );
  }

  /// Afficher une information
  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.blue.shade700,
      icon: Icons.info,
      duration: duration,
    );
  }

  /// Afficher un SnackBar avec confirmation d'action
  static void actionConfirmation(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    Duration duration = const Duration(seconds: 5),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      icon: Icons.undo,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  static Color _getColorForCategory(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.network:
        return Colors.orange.shade700;
      case ErrorCategory.database:
        return Colors.red.shade700;
      case ErrorCategory.validation:
        return Colors.amber.shade700;
      case ErrorCategory.permission:
        return Colors.purple.shade700;
      case ErrorCategory.notFound:
        return Colors.grey.shade700;
      case ErrorCategory.unknown:
        return Colors.red.shade700;
    }
  }

  static IconData _getIconForCategory(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.network:
        return Icons.wifi_off;
      case ErrorCategory.database:
        return Icons.storage;
      case ErrorCategory.validation:
        return Icons.text_fields;
      case ErrorCategory.permission:
        return Icons.lock;
      case ErrorCategory.notFound:
        return Icons.search_off;
      case ErrorCategory.unknown:
        return Icons.error;
    }
  }
}
