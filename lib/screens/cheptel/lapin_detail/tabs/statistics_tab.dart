import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../models/pesee.dart';
import '../../../../models/soin.dart';
import '../../../../models/accouplement.dart';
import '../../../../models/portee.dart';
import '../../../../models/lapin.dart';
import '../../../../models/enums/statut_accouplement.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/rentabilite_service.dart';
import '../../../../services/preferences_service.dart';
import '../../../../providers/alimentation_provider.dart';
import '../../../../providers/medicament_provider.dart';

/// Onglet Statistics - Préserve la logique existante avec style Stitch
class StatisticsTab extends StatefulWidget {
  final List<Pesee> pesees;
  final List<Soin> soins;
  final List<Accouplement> accouplements;
  final List<Portee> portees;
  final Lapin lapin;

  const StatisticsTab({
    super.key,
    required this.pesees,
    required this.soins,
    required this.accouplements,
    required this.portees,
    required this.lapin,
  });

  @override
  State<StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {
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

  NumberFormat get formatMontant => _moneyFormat ?? NumberFormat.currency(symbol: '€', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dernierePesee = widget.pesees.isNotEmpty ? widget.pesees.first : null;
    final dernierSoin = widget.soins.isNotEmpty ? widget.soins.first : null;
    final formatDate = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Grille de statistiques
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _buildStatCard(
                context,
                isDark,
                Icons.monitor_weight,
                'Pesées',
                widget.pesees.length.toString(),
                AppTheme.info,
                subtitle: dernierePesee != null
                    ? 'Dernière: ${formatDate.format(dernierePesee.date)}'
                    : 'Aucune pesée',
              ),
              _buildStatCard(
                context,
                isDark,
                Icons.medical_services,
                'Soins',
                widget.soins.length.toString(),
                AppTheme.accentTeal,
                subtitle: dernierSoin != null
                    ? 'Dernier: ${formatDate.format(dernierSoin.date)}'
                    : 'Aucun soin',
              ),
              _buildStatCard(
                context,
                isDark,
                Icons.favorite,
                'Accouplements',
                widget.accouplements.length.toString(),
                AppTheme.accentPink,
                subtitle:
                    '${widget.accouplements.where((a) => a.statut == StatutAccouplement.confirme).length} ${AppLocalizations.of(context).cheptelConfirmes.toLowerCase()}',
              ),
              _buildStatCard(
                context,
                isDark,
                Icons.pets,
                'Portées',
                widget.portees.length.toString(),
                AppTheme.primaryGreen,
                subtitle:
                    '${widget.portees.fold(0, (sum, p) => sum + p.nombreVivants)} petits sevrés',
              ),
            ],
          ),

          if (widget.pesees.length >= 2) ...[
            const SizedBox(height: 24),
            _buildWeightEvolutionCard(context, isDark, formatDate),
          ],

          // Section Rentabilité
          if (widget.lapin.id != null) ...[
            const SizedBox(height: 24),
            _buildRentabiliteCard(context, isDark),
          ],

          const SizedBox(height: 120), // Espace pour FAB
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    bool isDark,
    IconData icon,
    String label,
    String value,
    Color color, {
    String? subtitle,
  }) {
    final surfaceColor = AppTheme.getSurfaceColor(context);
    final outlineColor = AppTheme.getOutlineColor(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: outlineColor),
        boxShadow: AppTheme.cardShadow(isDark: isDark),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.titleLarge.copyWith(
              fontSize: 28,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.neutral400 : AppTheme.neutral600,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: AppTheme.caption.copyWith(
                color: isDark ? AppTheme.neutral500 : AppTheme.neutral400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeightEvolutionCard(
    BuildContext context,
    bool isDark,
    DateFormat formatDate,
  ) {
    final surfaceColor = AppTheme.getSurfaceColor(context);
    final outlineColor = AppTheme.getOutlineColor(context);

    // Prendre les 5 dernières pesées
    final peseesTri = List<Pesee>.from(widget.pesees)
      ..sort((a, b) => a.date.compareTo(b.date));
    final dernieresPesees = peseesTri.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: outlineColor),
        boxShadow: AppTheme.cardShadow(isDark: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppTheme.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Évolution du poids',
                style: AppTheme.titleSmall.copyWith(
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...dernieresPesees.map((pesee) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    formatDate.format(pesee.date),
                    style: AppTheme.caption.copyWith(
                      color: isDark ? AppTheme.neutral400 : AppTheme.neutral600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.neutral800
                            : AppTheme.neutral200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (pesee.poids / 6).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${pesee.poids.toStringAsFixed(2)} kg',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRentabiliteCard(BuildContext context, bool isDark) {
    final surfaceColor = AppTheme.getSurfaceColor(context);
    final outlineColor = AppTheme.getOutlineColor(context);

    return Consumer2<AlimentationProvider, MedicamentProvider>(
      builder: (context, alimentationProvider, medicamentProvider, child) {
        final rentabiliteService = RentabiliteService(
          alimentationProvider: alimentationProvider,
          medicamentProvider: medicamentProvider,
        );

        return FutureBuilder<Map<String, dynamic>>(
          future: rentabiliteService.calculerRentabiliteLapin(widget.lapin.id!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(color: outlineColor),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            final rentabilite = snapshot.data!;
            final couts = rentabilite['couts'] as Map<String, double>;
            final revenus = rentabilite['revenus'] as Map<String, double>;
            final benefice = rentabilite['benefice'] as double;
            final tauxRentabilite = rentabilite['rentabilite'] as double;

            final beneficeColor = benefice >= 0
                ? AppTheme.primaryGreen
                : AppTheme.error;
            final rentabiliteColor = tauxRentabilite >= 0
                ? AppTheme.primaryGreen
                : AppTheme.error;

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(color: outlineColor),
                boxShadow: AppTheme.cardShadow(isDark: isDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.euro,
                        color: AppTheme.accentTeal,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rentabilité',
                        style: AppTheme.titleSmall.copyWith(
                          color: AppTheme.accentTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Résumé
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRentabiliteItem(
                        AppLocalizations.of(context).cheptelCoutTotal,
                        formatMontant.format(couts['total']!),
                        isDark,
                        AppTheme.textSecondary,
                      ),
                      _buildRentabiliteItem(
                        AppLocalizations.of(context).cheptelRevenusTotal,
                        formatMontant.format(revenus['total']!),
                        isDark,
                        AppTheme.primaryGreen,
                      ),
                      _buildRentabiliteItem(
                        AppLocalizations.of(context).cheptelBenefice,
                        formatMontant.format(benefice),
                        isDark,
                        beneficeColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Divider(color: outlineColor),
                  const SizedBox(height: 16),

                  // Taux de rentabilité
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: rentabiliteColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: rentabiliteColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Taux de rentabilité: ${tauxRentabilite.toStringAsFixed(1)}%',
                        style: AppTheme.titleSmall.copyWith(
                          color: rentabiliteColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Divider(color: outlineColor),
                  const SizedBox(height: 12),

                  // Détail des coûts
                  Text(
                    'Détail des coûts',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.neutral400 : AppTheme.neutral600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCoutRow(
                    'Achat',
                    couts['achat']!,
                    formatMontant,
                    isDark,
                  ),
                  _buildCoutRow(
                    'Alimentation',
                    couts['alimentation']!,
                    formatMontant,
                    isDark,
                  ),
                  _buildCoutRow(
                    'Soins',
                    couts['soins']!,
                    formatMontant,
                    isDark,
                  ),
                  _buildCoutRow(
                    'Médicaments',
                    couts['medicaments']!,
                    formatMontant,
                    isDark,
                  ),
                  if (couts['autres']! > 0)
                    _buildCoutRow(
                      'Autres',
                      couts['autres']!,
                      formatMontant,
                      isDark,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRentabiliteItem(
    String label,
    String value,
    bool isDark,
    Color color,
  ) {
    return Column(
      children: [
        Text(value, style: AppTheme.titleMedium.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: isDark ? AppTheme.neutral500 : AppTheme.neutral400,
          ),
        ),
      ],
    );
  }

  Widget _buildCoutRow(
    String label,
    double montant,
    NumberFormat format,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: isDark ? AppTheme.neutral400 : AppTheme.neutral600,
            ),
          ),
          Text(
            format.format(montant),
            style: AppTheme.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.neutral300 : AppTheme.neutral700,
            ),
          ),
        ],
      ),
    );
  }
}
