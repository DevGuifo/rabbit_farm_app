import 'package:flutter/material.dart';
import '../../services/kpi_service.dart';
import '../../theme/app_theme.dart';

/// Section de cartes KPI détaillées pour le dashboard
class KpiCardsSection extends StatelessWidget {
  final KpiData kpis;
  final bool isDark;

  const KpiCardsSection({
    super.key,
    required this.kpis,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Indicateurs de Performance',
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
                icon: Icons.trending_up_rounded,
                label: 'Taux Reproduction',
                value: '${kpis.tauxReproduction.toStringAsFixed(1)}%',
                color: Colors.green,
                isDark: isDark,
              ),
              _buildKpiCard(
                icon: Icons.child_care_rounded,
                label: 'Taux Sevrage',
                value: '${kpis.tauxSevrage.toStringAsFixed(1)}%',
                color: Colors.blue,
                isDark: isDark,
              ),
              _buildKpiCard(
                icon: Icons.warning_rounded,
                label: 'Taux Mortalité',
                value: '${kpis.tauxMortalite.toStringAsFixed(2)}%',
                color: Colors.red,
                isDark: isDark,
              ),
              _buildKpiCard(
                icon: Icons.speed_rounded,
                label: 'GMQ Moyen',
                value: '${kpis.gmqMoyen.toStringAsFixed(1)} g/j',
                color: Colors.orange,
                isDark: isDark,
              ),
              _buildKpiCard(
                icon: Icons.family_restroom_rounded,
                label: 'Portées Actives',
                value: '${kpis.porteesActives}',
                color: Colors.purple,
                isDark: isDark,
              ),
              _buildKpiCard(
                icon: Icons.euro_rounded,
                label: 'Bénéfice Mensuel',
                value: '${kpis.beneficeMensuel.toStringAsFixed(2)} €',
                color: kpis.beneficeMensuel >= 0 ? Colors.green : Colors.red,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.caption.copyWith(
                  color: (isDark
                          ? AppTheme.textLight
                          : AppTheme.textSecondary)
                      .withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTheme.titleMedium.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

