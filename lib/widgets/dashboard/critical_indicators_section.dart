import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/kpi_service.dart';
import '../../theme/app_theme.dart';
import 'actionable_kpi_card.dart';
import '../../screens/reproduction/reproduction_screen.dart';
import '../../screens/sante/sante_screen.dart';
import '../../screens/cheptel/cheptel_screen.dart';
import '../../screens/stock/stock_screen.dart';

/// Section des indicateurs critiques du dashboard
/// Affiche uniquement les cartes nécessitant une attention (orange/rouge)
class CriticalIndicatorsSection extends StatelessWidget {
  final KpiData kpis;
  final bool isDark;

  const CriticalIndicatorsSection({
    super.key,
    required this.kpis,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final criticalCards = _buildCriticalCards(context);

    if (criticalCards.isEmpty) {
      // Aucun problème détecté : message positif
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.success900.withValues(alpha: 0.2)
                : AppTheme.success50,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: isDark
                  ? AppTheme.success700.withValues(alpha: 0.4)
                  : AppTheme.success200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.success600, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).dashToutVaBien,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.success300
                            : AppTheme.success800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context).dashAucuneActionUrgente,
                      style: AppTheme.bodySmall.copyWith(
                        color:
                            (isDark
                                    ? AppTheme.textLight
                                    : AppTheme.textSecondary)
                                .withValues(alpha: 0.7),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.warning600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).dashPointsAttention,
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.warning100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${criticalCards.length}',
                  style: AppTheme.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warning800,
                  ),
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            // Adapter le nombre de colonnes selon la largeur
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            final childAspectRatio = constraints.maxWidth > 600 ? 1.0 : 0.85;

            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: criticalCards.length,
              itemBuilder: (context, index) => criticalCards[index],
            );
          },
        ),
      ],
    );
  }

  /// Construit la liste des cartes critiques (seulement celles avec problème)
  List<Widget> _buildCriticalCards(BuildContext context) {
    final cards = <Widget>[];

    // 🔴 Femelles gestantes (si > 0, nécessite suivi)
    if (kpis.femellesGestantes > 0) {
      cards.add(
        ActionableKpiCard(
          label: AppLocalizations.of(context).dashFemellesGestantes,
          value: '${kpis.femellesGestantes}',
          icon: Icons.pregnant_woman,
          status: kpis.femellesGestantes > 5
              ? KpiStatus.attention
              : KpiStatus.ok,
          subtitle: AppLocalizations.of(context).dashSuiviGestation,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReproductionScreen()),
            );
          },
        ),
      );
    }

    // 🟠 Prochaines mises bas (14 jours)
    if (kpis.prochainesMisesBas14Jours > 0) {
      cards.add(
        ActionableKpiCard(
          label: AppLocalizations.of(context).dashMisesBasPrevues,
          value: '${kpis.prochainesMisesBas14Jours}',
          icon: Icons.calendar_today,
          status: kpis.prochainesMisesBas14Jours > 3
              ? KpiStatus.attention
              : KpiStatus.ok,
          subtitle: AppLocalizations.of(context).dashDans14Jours,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReproductionScreen()),
            );
          },
        ),
      );
    }

    // 🔴 Soins urgents (< 3 jours)
    if (kpis.soinsUrgents > 0) {
      cards.add(
        ActionableKpiCard(
          label: AppLocalizations.of(context).dashSoinsUrgents,
          value: '${kpis.soinsUrgents}',
          icon: Icons.medical_services,
          status: KpiStatus.action, // Toujours rouge si > 0
          subtitle: AppLocalizations.of(context).dashDans3Jours,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SanteScreen()),
            );
          },
        ),
      );
    }

    // 🔴 Vaccinations en retard
    if (kpis.vaccinationsEnRetard > 0) {
      cards.add(
        ActionableKpiCard(
          label: AppLocalizations.of(context).dashVaccinsRetard,
          value: '${kpis.vaccinationsEnRetard}',
          icon: Icons.vaccines,
          status: KpiStatus.action, // Toujours rouge si > 0
          subtitle: AppLocalizations.of(context).dashActionRequise,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SanteScreen()),
            );
          },
        ),
      );
    }

    // 🟠 Médicaments critiques (rupture ou seuil)
    if (kpis.medicamentsCritiques > 0) {
      cards.add(
        ActionableKpiCard(
          label: AppLocalizations.of(context).dashMedicamentsCritiques,
          value: '${kpis.medicamentsCritiques}',
          icon: Icons.medication,
          status: KpiStatus.action,
          subtitle: AppLocalizations.of(context).dashReapproUrgent,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StockScreen()),
            );
          },
        ),
      );
    }

    // 🟠 Aliments en alerte
    if (kpis.alimentsEnAlerte > 0) {
      cards.add(
        ActionableKpiCard(
          label: AppLocalizations.of(context).dashAlimentsSurveiller,
          value: '${kpis.alimentsEnAlerte}',
          icon: Icons.restaurant,
          status: KpiStatus.attention,
          subtitle: AppLocalizations.of(context).dashStockExpiration,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StockScreen()),
            );
          },
        ),
      );
    }

    // 🟠 Lapins sous-poids
    if (kpis.lapinsSousPoids > 0) {
      cards.add(
        ActionableKpiCard(
          label: AppLocalizations.of(context).dashLapinsSousPoids,
          value: '${kpis.lapinsSousPoids}',
          icon: Icons.trending_down,
          status: kpis.lapinsSousPoids > 3
              ? KpiStatus.action
              : KpiStatus.attention,
          subtitle: AppLocalizations.of(context).dashPoids80Attendu,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CheptelScreen()),
            );
          },
        ),
      );
    }

    // 🟠 Lapins malades
    if (kpis.lapinsMalades > 0) {
      cards.add(
        ActionableKpiCard(
          label: AppLocalizations.of(context).dashLapinsMalades,
          value: '${kpis.lapinsMalades}',
          icon: Icons.sick,
          status: kpis.lapinsMalades > 2
              ? KpiStatus.action
              : KpiStatus.attention,
          subtitle: AppLocalizations.of(context).dashQuarantaineMalades,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SanteScreen()),
            );
          },
        ),
      );
    }

    // 🔴 Taux de mortalité élevé (> 5%)
    if (kpis.tauxMortalite > 5.0) {
      cards.add(
        ActionableKpiCard(
          label: AppLocalizations.of(context).dashTauxMortaliteEleve,
          value: '${kpis.tauxMortalite.toStringAsFixed(1)}%',
          icon: Icons.emergency,
          status: kpis.tauxMortalite > 10.0
              ? KpiStatus.action
              : KpiStatus.attention,
          subtitle: AppLocalizations.of(context).dashCeMois,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SanteScreen()),
            );
          },
        ),
      );
    }

    return cards;
  }
}
