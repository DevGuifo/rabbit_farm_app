import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/accouplement.dart';
import '../../models/enums/statut_accouplement.dart';
import '../../providers/reproduction_provider.dart';
import '../../theme/app_theme.dart';
import '../../screens/reproduction/planifier_accouplement_screen.dart';
import '../common/empty_state_widget.dart';

/// Widget optimisé pour les tâches à venir
/// Utilise Selector pour écouter uniquement les accouplements
class UpcomingTasksSection extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onNavigateToReproduction;

  const UpcomingTasksSection({
    super.key,
    required this.isDark,
    this.onNavigateToReproduction,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<ReproductionProvider, List<Accouplement>>(
      selector: (_, provider) => provider.accouplements
          .where((acc) => acc.statut == StatutAccouplement.enAttente)
          .take(3)
          .toList(),
      shouldRebuild: (prev, next) =>
          prev.length != next.length || prev.any((acc) => !next.contains(acc)),
      builder: (context, accouplementsPrevus, _) {
        if (accouplementsPrevus.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: EmptyStateVariants.alertesVide(),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Titre
                  Text(
                    AppLocalizations.of(context).dashTachesAVenir,
                    style: AppTheme.titleLarge.copyWith(
                      fontSize: 22,
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    ),
                  ),
                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PlanifierAccouplementScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: AppLocalizations.of(
                          context,
                        ).dashActionAccouplement,
                        color: AppTheme.accentPink,
                      ),
                      TextButton(
                        onPressed: onNavigateToReproduction,
                        child: Text(
                          AppLocalizations.of(context).dashVoirTout,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...accouplementsPrevus.map(
                (accouplement) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _TaskCard(accouplement: accouplement, isDark: isDark),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget const pour une carte de tâche individuelle
class _TaskCard extends StatelessWidget {
  final Accouplement accouplement;
  final bool isDark;

  const _TaskCard({required this.accouplement, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isDark ? AppTheme.neutral800 : AppTheme.neutral100,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: false,
            onChanged: (_) {
              // TODO: Implémenter la logique de complétion
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accouplement prévu',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: ${accouplement.dateAccouplement.toString().substring(0, 10)}',
                  style: AppTheme.caption.copyWith(
                    color:
                        (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                            .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
