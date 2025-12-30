import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// État de chargement standardisé
/// 
/// Usage:
/// ```dart
/// LoadingState(
///   isDark: isDark,
///   message: 'Chargement des données...',
/// )
/// ```
class LoadingState extends StatelessWidget {
  final bool isDark;
  final String? message;

  const LoadingState({
    super.key,
    required this.isDark,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryGreen,
          ),
          if (message != null) ...[
            const SizedBox(height: AppTheme.spacing16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

