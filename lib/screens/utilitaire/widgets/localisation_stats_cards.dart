import 'package:flutter/material.dart';
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
              label: 'TOTAL CAGES',
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              value: totalBatiments.toString(),
              label: 'BARNS',
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
        color: isDark ? const Color(0xFF1A2C1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE5E5E5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              color: isDark ? const Color(0xFFE0E6E0) : AppTheme.stitchTextMainLight,
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
              color: isDark ? const Color(0xFF8BA88E) : AppTheme.stitchTextSecLight,
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
        color: isDark ? const Color(0xFF1A2C1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE5E5E5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E),
            ),
            const SizedBox(height: 4),
            Text(
              '${percent.toInt()}%',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFE0E6E0)
                    : AppTheme.stitchTextMainLight,
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
                    ? const Color(0xFF8BA88E)
                    : AppTheme.stitchTextSecLight,
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
