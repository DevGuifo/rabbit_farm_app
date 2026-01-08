import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../services/kpi_service.dart';
import '../../theme/app_theme.dart';
import '../../screens/finance/finance_screen.dart';
import '../../screens/cheptel/cheptel_screen.dart';

/// Section des indicateurs de performance globale
/// Affiche les KPIs clés pour un aperçu rapide (<5 secondes)
class PerformanceIndicatorsSection extends StatelessWidget {
  final KpiData kpis;
  final bool isDark;

  const PerformanceIndicatorsSection({
    super.key,
    required this.kpis,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final euroFormat = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            AppLocalizations.of(context).dashPerformanceGlobale,
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
        ),

        // Grille responsive des indicateurs principaux
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Adapter selon la largeur disponible
              final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              final childAspectRatio = constraints.maxWidth > 600 ? 1.1 : 1.15;

              return GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  // Cheptel actif
                  _buildPerformanceCard(
                    context: context,
                    icon: Icons.pets,
                    label: AppLocalizations.of(context).dashLapinsActifs,
                    value: '${kpis.totalLapins}',
                    subtitle: AppLocalizations.of(
                      context,
                    ).dashFemellesRepro(kpis.femellesReproductrices),
                    color: AppTheme.info,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CheptelScreen(),
                        ),
                      );
                    },
                  ),

                  // GMQ (Gain Moyen Quotidien)
                  _buildPerformanceCard(
                    context: context,
                    icon: Icons.trending_up,
                    label: AppLocalizations.of(context).dashGMQMoyen,
                    value: '${kpis.gmqMoyen.toStringAsFixed(1)}g',
                    subtitle: AppLocalizations.of(
                      context,
                    ).dashPeseesMois(kpis.peseesCeMois),
                    color: AppTheme.success,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CheptelScreen(),
                        ),
                      );
                    },
                  ),

                  // Taux de reproduction
                  _buildPerformanceCard(
                    context: context,
                    icon: Icons.family_restroom,
                    label: AppLocalizations.of(context).dashTauxReproduction,
                    value: '${kpis.tauxReproduction.toStringAsFixed(0)}%',
                    subtitle: AppLocalizations.of(
                      context,
                    ).dashAccouplementsActifs(kpis.accouplementsActifs),
                    color: AppTheme.accentPurple,
                    onTap: null, // Pas de navigation spécifique
                  ),

                  // Bénéfice mensuel
                  _buildPerformanceCard(
                    context: context,
                    icon: kpis.beneficeMensuel >= 0
                        ? Icons.attach_money
                        : Icons.money_off,
                    label: AppLocalizations.of(context).dashBeneficeMensuel,
                    value: euroFormat.format(kpis.beneficeMensuel),
                    subtitle: AppLocalizations.of(
                      context,
                    ).dashRecettes(euroFormat.format(kpis.recettesMensuelles)),
                    color: kpis.beneficeMensuel >= 0
                        ? AppTheme.success
                        : AppTheme.error,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FinanceScreen(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Barre de détails financiers
        _buildFinancialDetails(context, euroFormat),
      ],
    );
  }

  /// Carte individuelle de performance
  Widget _buildPerformanceCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icône
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),

            // Valeur (responsive)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: AppTheme.titleLarge.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textOnPrimary : AppTheme.textPrimary,
                ),
              ),
            ),

            // Label + Sous-titre (flexible)
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                              .withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.caption.copyWith(
                      color: color.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Détails financiers en barre horizontale
  Widget _buildFinancialDetails(BuildContext context, NumberFormat euroFormat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.neutral900.withValues(alpha: 0.5)
              : AppTheme.neutral50,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isDark ? AppTheme.neutral800 : AppTheme.neutral200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Dépenses mensuelles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_down,
                        size: 16,
                        color: AppTheme.error600,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context).dashDepenses,
                          style: AppTheme.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                (isDark
                                        ? AppTheme.textLight
                                        : AppTheme.textSecondary)
                                    .withValues(alpha: 0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      euroFormat.format(kpis.depensesMensuelles),
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.error600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Séparateur vertical
            Container(
              height: 40,
              width: 1,
              color: isDark ? AppTheme.neutral700 : AppTheme.borderLight,
            ),
            const SizedBox(width: 16),

            // Coût alimentation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 16,
                        color: AppTheme.warning600,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context).dashAlimentation,
                          style: AppTheme.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                (isDark
                                        ? AppTheme.textLight
                                        : AppTheme.textSecondary)
                                    .withValues(alpha: 0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      euroFormat.format(kpis.coutAlimentationMensuel),
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.warning600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
