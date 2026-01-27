import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Cartes de statistiques pour l'écran de localisation
/// Affiche: Total Cages, Barns, Clean Status
class LocalisationStatsCards extends StatelessWidget {
  final int totalCages;
  final int totalBatiments;
  final double cleanStatusPercent;

  const LocalisationStatsCards({
    super.key,
    required this.totalCages,
    required this.totalBatiments,
    required this.cleanStatusPercent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              value: totalCages.toString(),
              label: AppLocalizations.of(context).labelTotalCages,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              value: totalBatiments.toString(),
              label: AppLocalizations.of(context).labelBatiments,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildCleanStatusCard(
              context,
              percent: cleanStatusPercent,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.textOnPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.greyDarkest : AppTheme.greyE5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.divider,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppTheme.textOnPrimary
                  : AppTheme.textPrimary,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isDark
                  ? AppTheme.accentGreen
                  : AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCleanStatusCard(
    BuildContext context, {
    required double percent,
    required bool isDark,
  }) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.textOnPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.greyDarkest : AppTheme.greyE5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.divider,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 22,
              color: isDark ? AppTheme.success400 : AppTheme.success500,
            ),
            const SizedBox(height: 4),
            Text(
              '${percent.toInt()}%',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppTheme.textOnPrimary
                    : AppTheme.textPrimary,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'CLEAN\nSTATUS',
              style: AppTheme.caption.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: isDark
                    ? AppTheme.accentGreen
                    : AppTheme.textSecondary,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
