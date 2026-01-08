import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../../providers/sante_provider.dart';
import '../../../../l10n/app_localizations.dart';

/// Cartes statistiques (Active, Scheduled, History)
/// Design: Horizontal scroll avec cartes cliquables
class TreatmentsStatsCards extends StatelessWidget {
  final String selectedTab;
  final Function(String) onTabChanged;
  final bool isDark;
  final Color surfaceColor;
  final Color primaryColor;
  final Color textPrimary;
  final Color textSecondary;

  const TreatmentsStatsCards({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    required this.isDark,
    required this.surfaceColor,
    required this.primaryColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SanteProvider>(
      builder: (context, santeProvider, _) {
        final soins = santeProvider.soins;
        final activeTreatments = soins
            .where(
              (s) =>
                  s.dateRappel != null && s.dateRappel!.isAfter(DateTime.now()),
            )
            .length;
        final scheduledCount = soins.where((s) => s.dateRappel != null).length;
        final historyCount = soins.length;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => onTabChanged('active'),
                child: _buildStatCard(
                  icon: Icons.healing,
                  label: AppLocalizations.of(context).labelActifs,
                  value: activeTreatments.toString(),
                  isHighlighted: selectedTab == 'active',
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => onTabChanged('scheduled'),
                child: _buildStatCard(
                  icon: Icons.calendar_month_outlined,
                  iconColor: AppTheme.warning,
                  label: AppLocalizations.of(context).labelPlanifies,
                  value: scheduledCount.toString(),
                  isHighlighted: selectedTab == 'scheduled',
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => onTabChanged('history'),
                child: _buildStatCard(
                  icon: Icons.history,
                  iconColor: AppTheme.textSecondary,
                  label: AppLocalizations.of(context).labelHistorique,
                  value: historyCount.toString(),
                  isHighlighted: selectedTab == 'history',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    Color? iconColor,
    required String label,
    required String value,
    required bool isHighlighted,
  }) {
    final bgColor = isHighlighted
        ? primaryColor.withValues(alpha: isDark ? 0.1 : 0.2)
        : surfaceColor;
    final borderColor = isHighlighted
        ? primaryColor.withValues(alpha: 0.3)
        : isDark
        ? AppTheme.cardLight.withValues(alpha: 0.05)
        : AppTheme.backgroundDark.withValues(alpha: 0.05);

    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (iconColor ?? primaryColor).withValues(
                alpha: isDark ? 0.3 : 0.2,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color:
                  iconColor ??
                  (isHighlighted ? AppTheme.backgroundDark : primaryColor),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTheme.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                value,
                style: AppTheme.titleMedium.copyWith(
                  color: textPrimary,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
