import 'package:flutter/material.dart';
import '../../../models/tache.dart';
import '../../../theme/app_theme.dart';
import '../../../models/lapin.dart';
import '../../../l10n/app_localizations.dart';

/// Carte affichant une tâche
class TacheCard extends StatelessWidget {
  final Tache tache;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onToggleStatut;
  final VoidCallback onDelete;
  final Lapin? lapin; // Optionnel - pour afficher le nom du lapin

  const TacheCard({
    super.key,
    required this.tache,
    required this.isDark,
    required this.onTap,
    required this.onToggleStatut,
    required this.onDelete,
    this.lapin,
  });

  Color _getCouleurPriorite() {
    switch (tache.priorite) {
      case 'haute':
        return AppTheme.error;
      case 'normale':
        return AppTheme.warning;
      case 'basse':
        return AppTheme.info;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _getCouleurStatut() {
    switch (tache.statut) {
      case 'terminee':
        return AppTheme.primaryGreen;
      case 'en_cours':
        return AppTheme.info;
      case 'annulee':
        return AppTheme.textSecondary;
      case 'reportee':
        return AppTheme.warning;
      default:
        return AppTheme.textPrimary;
    }
  }

  IconData _getIconeStatut() {
    switch (tache.statut) {
      case 'terminee':
        return Icons.check_circle_rounded;
      case 'en_cours':
        return Icons.play_circle_rounded;
      case 'annulee':
        return Icons.cancel_rounded;
      case 'reportee':
        return Icons.schedule_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  String _getLabelStatut() {
    switch (tache.statut) {
      case 'terminee':
        return 'Terminée';
      case 'en_cours':
        return 'En cours';
      case 'annulee':
        return 'Annulée';
      case 'reportee':
        return 'Reportée';
      default:
        return 'À faire';
    }
  }

  String _getLabelCategorie(BuildContext context) {
    switch (tache.categorie) {
      case 'reproduction':
        return AppLocalizations.of(context).tachesCategorieReproduction;
      case 'sante':
        return AppLocalizations.of(context).santeTous;
      case 'alimentation':
        return AppLocalizations.of(context).tachesCategorieAlimentation;
      case 'entretien':
        return AppLocalizations.of(context).tachesEntretien;
      case 'administratif':
        return AppLocalizations.of(context).tachesAdministratif;
      default:
        return AppLocalizations.of(context).financesCategorieAutre;
    }
  }

  IconData _getIconeCategorie() {
    switch (tache.categorie) {
      case 'reproduction':
        return Icons.family_restroom_rounded;
      case 'sante':
        return Icons.medical_services_rounded;
      case 'alimentation':
        return Icons.restaurant_rounded;
      case 'entretien':
        return Icons.build_rounded;
      case 'administratif':
        return Icons.description_rounded;
      default:
        return Icons.task_rounded;
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return AppLocalizations.of(context).santeAujourdhui;
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return AppLocalizations.of(context).tachesDemain;
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return AppLocalizations.of(context).tachesHier;
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final couleurPriorite = _getCouleurPriorite();
    final couleurStatut = _getCouleurStatut();
    final estEnRetard = tache.estEnRetard;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: estEnRetard
            ? BorderSide(color: AppTheme.error, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Indicateur de priorité
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: couleurPriorite,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tache.titre,
                                style: AppTheme.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: tache.statut == 'terminee'
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: tache.statut == 'terminee'
                                      ? AppTheme.textSecondary
                                      : (isDark
                                            ? AppTheme.textLight
                                            : AppTheme.textPrimary),
                                ),
                              ),
                            ),
                            if (tache.estRecurrente)
                              Icon(
                                Icons.repeat_rounded,
                                size: 18,
                                color: AppTheme.textSecondary,
                              ),
                          ],
                        ),
                        if (tache.description != null &&
                            tache.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            tache.description!,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Catégorie
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNeonGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getIconeCategorie(),
                          size: 14,
                          color: AppTheme.primaryNeonGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getLabelCategorie(context),
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.primaryNeonGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Statut
                  GestureDetector(
                    onTap: onToggleStatut,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: couleurStatut.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getIconeStatut(),
                            size: 14,
                            color: couleurStatut,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getLabelStatut(),
                            style: AppTheme.caption.copyWith(
                              color: couleurStatut,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Lapin associé
                  if (lapin != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pets_rounded,
                            size: 14,
                            color: AppTheme.info,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lapin!.nom,
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.info,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: estEnRetard
                            ? AppTheme.error
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(context, tache.datePlanification),
                        style: AppTheme.caption.copyWith(
                          color: estEnRetard
                              ? AppTheme.error
                              : AppTheme.textSecondary,
                          fontWeight: estEnRetard
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (estEnRetard) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            ).tachesEnRetard.toUpperCase(),
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textOnPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: AppTheme.error,
                    iconSize: 20,
                    onPressed: onDelete,
                    tooltip: AppLocalizations.of(context).tachesSupprimer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
