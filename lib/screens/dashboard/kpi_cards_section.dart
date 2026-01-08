import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/kpi_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glossaire/glossaire_cuniculture.dart';

/// Section de cartes KPI détaillées pour le dashboard
class KpiCardsSection extends StatelessWidget {
  final KpiData kpis;
  final bool isDark;

  const KpiCardsSection({super.key, required this.kpis, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).dashIndicateursPerformance,
            style: AppTheme.titleLarge.copyWith(
              fontSize: 22,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Grille de cartes KPI (2 colonnes)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildKpiCard(
                context: context,
                icon: Icons.trending_up_rounded,
                label: AppLocalizations.of(context).dashTauxReproductionLabel,
                value: '${kpis.tauxReproduction.toStringAsFixed(1)}%',
                color: AppTheme.success,
                isDark: isDark,
              ),
              _buildKpiCard(
                context: context,
                icon: Icons.child_care_rounded,
                label: AppLocalizations.of(context).dashTauxSevrageLabel,
                value: '${kpis.tauxSevrage.toStringAsFixed(1)}%',
                color: AppTheme.info,
                isDark: isDark,
                tooltipTerme: 'sevrage',
              ),
              _buildKpiCard(
                context: context,
                icon: Icons.warning_rounded,
                label: AppLocalizations.of(context).dashTauxMortaliteLabel,
                value: '${kpis.tauxMortalite.toStringAsFixed(2)}%',
                color: AppTheme.error,
                isDark: isDark,
              ),
              _buildKpiCard(
                context: context,
                icon: Icons.speed_rounded,
                label: AppLocalizations.of(context).dashGMQMoyenLabel,
                value: '${kpis.gmqMoyen.toStringAsFixed(1)} g/j',
                color: AppTheme.warning,
                isDark: isDark,
                tooltipTerme: 'gmq',
              ),
              _buildKpiCard(
                context: context,
                icon: Icons.family_restroom_rounded,
                label: AppLocalizations.of(context).dashPorteesActivesLabel,
                value: '${kpis.porteesActives}',
                color: AppTheme.accentPurple,
                isDark: isDark,
                tooltipTerme: 'portee',
              ),
              _buildKpiCard(
                context: context,
                icon: Icons.euro_rounded,
                label: AppLocalizations.of(context).dashBeneficeMensuelLabel,
                value: '${kpis.beneficeMensuel.toStringAsFixed(2)} €',
                color: kpis.beneficeMensuel >= 0
                    ? AppTheme.success
                    : AppTheme.error,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    String? tooltipTerme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark ? AppTheme.neutral800 : AppTheme.neutral100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: AppTheme.caption.copyWith(
                      color:
                          (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                              .withValues(alpha: 0.7),
                    ),
                  ),
                  if (tooltipTerme != null) ...[
                    const SizedBox(width: 4),
                    TooltipGlossaire(terme: tooltipTerme, iconSize: 12),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTheme.titleMedium.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textOnPrimary : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
