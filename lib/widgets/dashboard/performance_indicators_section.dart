import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../services/kpi_service.dart';
import '../../services/preferences_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/kpi_thresholds.dart';
import '../../screens/finance/finance_screen.dart';
import '../../screens/cheptel/cheptel_screen.dart';

/// Section des indicateurs de performance globale
/// Affiche les KPIs clés pour un aperçu rapide (<5 secondes)
class PerformanceIndicatorsSection extends StatefulWidget {
  final KpiData kpis;
  final bool isDark;

  const PerformanceIndicatorsSection({
    super.key,
    required this.kpis,
    required this.isDark,
  });

  @override
  State<PerformanceIndicatorsSection> createState() => _PerformanceIndicatorsSectionState();
}

class _PerformanceIndicatorsSectionState extends State<PerformanceIndicatorsSection> {
  NumberFormat? _moneyFormat;

  @override
  void initState() {
    super.initState();
    _initFormatter();
  }

  Future<void> _initFormatter() async {
    final formatter = await PreferencesService().getMoneyFormatter();
    if (mounted) setState(() => _moneyFormat = formatter);
  }

  NumberFormat get euroFormat => _moneyFormat ?? NumberFormat.currency(locale: 'fr_FR', symbol: '€');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            AppLocalizations.of(context).dashPerformanceGlobale,
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.isDark ? AppTheme.textLight : AppTheme.textPrimary,
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
                    value: '${widget.kpis.totalLapins}',
                    subtitle: AppLocalizations.of(
                      context,
                    ).dashFemellesRepro(widget.kpis.femellesReproductrices),
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
                    value: '${widget.kpis.gmqMoyen.toStringAsFixed(1)}g',
                    subtitle: AppLocalizations.of(
                      context,
                    ).dashPeseesMois(widget.kpis.peseesCeMois),
                    color: AppTheme.success,
                    statusOverride: KpiThresholds.gmqStatus(
                      widget.kpis.gmqMoyen,
                    ), // ✅ PHASE 3
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
                    value: '${widget.kpis.tauxReproduction.toStringAsFixed(0)}%',
                    subtitle: AppLocalizations.of(
                      context,
                    ).dashAccouplementsActifs(widget.kpis.accouplementsActifs),
                    statusOverride: KpiThresholds.reproductionStatus(
                      widget.kpis.tauxReproduction,
                    ), // ✅ PHASE 3
                    color: AppTheme.accentPurple,
                    onTap: null, // Pas de navigation spécifique
                  ),

                  // Bénéfice mensuel
                  _buildPerformanceCard(
                    context: context,
                    icon: widget.kpis.beneficeMensuel >= 0
                        ? Icons.attach_money
                        : Icons.money_off,
                    label: AppLocalizations.of(context).dashBeneficeMensuel,
                    value: euroFormat.format(widget.kpis.beneficeMensuel),
                    subtitle: AppLocalizations.of(
                      context,
                    ).dashRecettes(euroFormat.format(widget.kpis.recettesMensuelles)),
                    color: widget.kpis.beneficeMensuel >= 0
                        ? AppTheme.success
                        : AppTheme.error,
                    statusOverride: KpiThresholds.beneficeStatus(
                      widget.kpis.beneficeMensuel,
                    ), // ✅ PHASE 3
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
        // Note: Détails financiers supprimés car déjà dans RoiPerformanceSection
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
    String? statusOverride, // ✅ PHASE 3: Statut personnalisé
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: widget.isDark ? AppTheme.neutral800 : AppTheme.neutral100,
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
            // Icône + Badge statut (✅ PHASE 3)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                if (statusOverride != null)
                  KpiThresholds.buildStatusBadge(
                    statusOverride,
                    isDark: widget.isDark,
                  ),
              ],
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
                  color: widget.isDark ? AppTheme.textOnPrimary : AppTheme.textPrimary,
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
                          (widget.isDark ? AppTheme.textLight : AppTheme.textSecondary)
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
}
