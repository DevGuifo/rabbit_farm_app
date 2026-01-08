import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

/// État d'erreur standardisé avec bouton de retry
///
/// Usage:
/// ```dart
/// ErrorState(
///   isDark: isDark,
///   message: 'Une erreur est survenue',
///   onRetry: () => _loadData(),
/// )
/// ```
class ErrorState extends StatelessWidget {
  final bool isDark;
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.isDark,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.error.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            AppLocalizations.of(context).widgetErreur,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppTheme.spacing24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).widgetReessayer),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.textOnPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
