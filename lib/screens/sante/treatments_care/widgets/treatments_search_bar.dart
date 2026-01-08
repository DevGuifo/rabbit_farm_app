import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Barre de recherche Stitch pour Treatments & Care
class TreatmentsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;

  const TreatmentsSearchBar({
    super.key,
    required this.controller,
    required this.isDark,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.backgroundDark.withValues(
                alpha: isDark ? 0.3 : 0.05,
              ),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          style: TextStyle(fontSize: 16, color: textPrimary),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).hintSearchRabbitTreatment,
            hintStyle: TextStyle(color: textSecondary),
            prefixIcon: Icon(Icons.search, color: textSecondary, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
