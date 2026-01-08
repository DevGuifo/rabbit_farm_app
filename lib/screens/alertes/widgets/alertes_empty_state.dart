import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Empty state "All Caught Up" - Design Stitch
class AlertesEmptyState extends StatelessWidget {
  const AlertesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceDimColor = isDark
        ? AppTheme.cardDark
        : AppTheme.backgroundLight;
    final textColor = isDark ? AppTheme.textLight : AppTheme.textPrimary;
    final textSubColor = isDark
        ? AppTheme.textSecondary
        : AppTheme.textSecondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: surfaceDimColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.done_all, size: 48, color: textSubColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).alertesAucune,
            style: AppTheme.titleMedium.copyWith(color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context).alertesAucuneDescription,
            style: AppTheme.bodyMedium.copyWith(color: textSubColor),
          ),
        ],
      ),
    );
  }
}
