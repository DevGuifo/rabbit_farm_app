import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Helper pour navigation modale avec bottom sheets
/// Remplace Navigator.push() pour une meilleure UX avec bottom bar persistante
class NavigationHelper {
  /// Ouvre un écran dans un bottom sheet modal
  static Future<T?> openModal<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barre de glissement
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.spacing8),
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.textSecondary.withValues(alpha: 0.3)
                      : AppTheme.textSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Contenu
            Flexible(
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  /// Ouvre un écran dans un bottom sheet avec hauteur définie
  static Future<T?> openModalWithHeight<T>({
    required BuildContext context,
    required Widget child,
    double maxHeight = 0.9,
    bool isDismissible = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: true,
      constraints: BoxConstraints(
        maxHeight: screenHeight * maxHeight,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barre de glissement
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.spacing8),
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.textSecondary.withValues(alpha: 0.3)
                      : AppTheme.textSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Contenu avec scroll si nécessaire
            Flexible(
              child: SingleChildScrollView(
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ferme le modal bottom sheet
  static void closeModal<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }
}
