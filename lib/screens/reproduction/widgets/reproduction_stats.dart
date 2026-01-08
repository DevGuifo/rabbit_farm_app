import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import '../../../providers/reproduction_provider.dart';
import '../../../widgets/glossaire/glossaire_cuniculture.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Widget Stats Reproduction - 3 cartes KPI
/// Extracté de reproduction_screen pour modularité
class ReproductionStats extends StatelessWidget {
  final bool isDark;

  const ReproductionStats({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReproductionProvider>(
      builder: (context, provider, _) {
        final activePregnancies = provider.accouplements
            .where((a) => a.statut == 'confirme' || a.statut == 'en_cours')
            .length;

        final now = DateTime.now();
        final endOfWeek = now.add(Duration(days: 7 - now.weekday));
        final expectedThisWeek = provider.accouplements
            .where(
              (a) =>
                  a.dateMiseBasPrevue.isAfter(now) &&
                  a.dateMiseBasPrevue.isBefore(endOfWeek),
            )
            .length;

        final totalPortees = provider.portees.length;
        final porteesReussies = provider.portees
            .where((p) => p.nombreVivants > 0)
            .length;
        final successRate = totalPortees > 0
            ? ((porteesReussies / totalPortees) * 100).round()
            : 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  isDark,
                  AppLocalizations.of(context).reproActives,
                  '$activePregnancies',
                  AppLocalizations.of(context).reproGestations,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  isDark,
                  AppLocalizations.of(context).reproPrevues,
                  '$expectedThisWeek',
                  AppLocalizations.of(context).reproCetteSemaine,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  isDark,
                  AppLocalizations.of(context).reproReussite,
                  '$successRate%',
                  AppLocalizations.of(context).reproPortees,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    bool isDark,
    String label,
    String value,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.backgroundDark : AppTheme.cardLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.caption.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.titleLarge.copyWith(
              fontSize: 24,
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTheme.caption.copyWith(
              color: isDark ? AppTheme.textSecondary : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Alerte Palpation conditionnelle
class ReproductionPalpationAlert extends StatelessWidget {
  final bool isDark;

  const ReproductionPalpationAlert({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReproductionProvider>(
      builder: (context, provider, _) {
        final now = DateTime.now();
        final accouplementsAPalper = provider.accouplements.where((a) {
          if (a.statut != 'en_attente') return false;
          final joursDepuis = now.difference(a.dateAccouplement).inDays;
          return joursDepuis >= 10 && joursDepuis <= 14;
        }).toList();

        if (accouplementsAPalper.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.warning.withValues(alpha: 0.2)
                  : AppTheme.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? AppTheme.warning.withValues(alpha: 0.3)
                    : AppTheme.warning.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.medical_services,
                  color: isDark ? AppTheme.warning : AppTheme.warning,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context).reproPalpationRequise,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.warning.withValues(alpha: 0.2)
                                  : AppTheme.backgroundDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          TooltipGlossaire(terme: 'palpation', iconSize: 14),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(
                          context,
                        ).reproPalperCount(accouplementsAPalper.length),
                        style: AppTheme.bodyMedium.copyWith(
                          color: isDark
                              ? AppTheme.warning.withValues(alpha: 0.2)
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
