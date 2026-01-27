import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/tache_quotidienne.dart';
import '../providers/tache_provider.dart';
import '../screens/taches_quotidiennes/tache_screen.dart';
import '../theme/app_theme.dart';
import '../theme/theme_variations.dart';

/// Widget carte pour afficher le statut des rituels quotidiens sur le dashboard
///
/// Affiche l'état des rituels matin et soir avec navigation 1-clic
/// Design optimisé pour visibilité rapide :
/// - âœ… Fait = vert
/// - ðŸ”„ En cours = orange
/// - â³ À faire = gris
class TacheCard extends StatelessWidget {
  const TacheCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<TacheProvider>(
      builder: (context, provider, _) {
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing8,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
            borderRadius: AppTheme.borderRadiusLarge,
            border: Border.all(
              color: _getBorderColor(provider),
              width: _getBorderWidth(provider).toDouble(),
            ),
            boxShadow: AppTheme.cardShadow(isDark: isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              _buildHeader(context, provider, isDark),
              // Contenu
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    // TacheQuotidienne matin
                    Expanded(
                      child: _buildRituelButton(
                        context: context,
                        type: TypeTacheQuotidienne.matin,
                        tacheQuotidienne: provider.tacheMatin,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // TacheQuotidienne soir
                    Expanded(
                      child: _buildRituelButton(
                        context: context,
                        type: TypeTacheQuotidienne.soir,
                        tacheQuotidienne: provider.tacheSoir,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
              // Micro-message pédagogique
              _buildMicroMessage(context, provider, isDark),
              // Anomalies du jour si présentes
              if (provider.anomaliesJour > 0)
                _buildAnomaliesBanner(context, provider.anomaliesJour, isDark),
            ],
          ),
        );
      },
    );
  }

  Color _getBorderColor(TacheProvider provider) {
    if (provider.matinTermine && provider.soirTermine) {
      return AppTheme.primaryGreen;
    } else if (provider.tacheMatin?.estEnCours == true ||
        provider.tacheSoir?.estEnCours == true) {
      return AppTheme.warning;
    }
    return AppTheme.textSecondary.withValues(alpha: 0.3);
  }

  int _getBorderWidth(TacheProvider provider) {
    if (provider.matinTermine && provider.soirTermine) {
      return 2;
    }
    return 1;
  }

  Widget _buildHeader(
    BuildContext context,
    TacheProvider provider,
    bool isDark,
  ) {
    final tousTermines = provider.matinTermine && provider.soirTermine;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: tousTermines ? AppTheme.success : AppTheme.warning,
              borderRadius: AppTheme.borderRadiusMedium,
            ),
            child: Icon(
              tousTermines
                  ? Icons.check_circle_rounded
                  : Icons.pending_actions_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).tachesDuJour,
                  style: AppTheme.titleMedium.copyWith(
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tousTermines
                      ? AppLocalizations.of(context).tacheTermine
                      : _getStatusText(context, provider),
                  style: AppTheme.bodySmall.copyWith(
                    color: tousTermines
                        ? AppTheme.primaryGreen
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Badge de progression
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tousTermines
                  ? AppTheme.primaryGreen.withValues(alpha: 0.2)
                  : AppTheme.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getProgressText(provider),
              style: AppTheme.labelMedium.copyWith(
                color: tousTermines ? AppTheme.primaryGreen : AppTheme.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(BuildContext context, TacheProvider provider) {
    final matin = provider.tacheMatin;
    final soir = provider.tacheSoir;
    final l10n = AppLocalizations.of(context);

    if (matin == null && soir == null) return l10n.tacheChargement;

    if (provider.matinTermine && !provider.soirTermine) {
      return l10n.tacheMatinFaitSoirAttente;
    } else if (!provider.matinTermine && provider.soirTermine) {
      return l10n.tacheMatinAttenteSoirFait;
    } else if (matin?.estEnCours == true) {
      return l10n.tacheMatinEnCours;
    } else if (soir?.estEnCours == true) {
      return l10n.tacheSoirEnCours;
    }
    return l10n.tacheAppuyerCommencer;
  }

  String _getProgressText(TacheProvider provider) {
    int total = 0;
    int fait = 0;

    final matin = provider.tacheMatin;
    final soir = provider.tacheSoir;

    if (matin != null) {
      total += matin.actions.length;
      fait += matin.nombreActionsFaites;
    }
    if (soir != null) {
      total += soir.actions.length;
      fait += soir.nombreActionsFaites;
    }

    if (total == 0) return '0%';
    return '${((fait / total) * 100).round()}%';
  }

  Widget _buildRituelButton({
    required BuildContext context,
    required TypeTacheQuotidienne type,
    required TacheQuotidienne? tacheQuotidienne,
    required bool isDark,
  }) {
    final estMatin = type == TypeTacheQuotidienne.matin;
    final estTermine = tacheQuotidienne?.estComplet ?? false;
    final estEnCours = tacheQuotidienne?.estEnCours ?? false;
    final progression = tacheQuotidienne?.pourcentageCompletion ?? 0.0;

    final couleurPrimaire = estMatin ? AppTheme.warning : AppTheme.info;
    final couleurFond = estTermine
        ? AppTheme.primaryGreen.withValues(alpha: 0.15)
        : couleurPrimaire.withValues(alpha: 0.1);

    return Material(
      color: couleurFond,
      borderRadius: AppTheme.borderRadiusLarge,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TacheScreen(typeTache: type)),
          );
        },
        borderRadius: AppTheme.borderRadiusLarge,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Icône et statut
              Stack(
                alignment: Alignment.center,
                children: [
                  // Cercle de progression
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: progression,
                      strokeWidth: 4,
                      backgroundColor: isDark
                          ? AppTheme.textSecondary.withValues(alpha: 0.2)
                          : AppTheme.textSecondary.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        estTermine ? AppTheme.primaryGreen : couleurPrimaire,
                      ),
                    ),
                  ),
                  // Emoji central
                  Icon(
                    estMatin
                        ? ThemeVariations.tacheMatin.icon
                        : ThemeVariations.tacheSoir.icon,
                    size: 28,
                    color: estMatin
                        ? ThemeVariations.tacheMatin.accentColor
                        : ThemeVariations.tacheSoir.accentColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Label
              Text(
                estMatin
                    ? AppLocalizations.of(context).tacheMatin
                    : AppLocalizations.of(context).tacheSoir,
                style: AppTheme.titleSmall.copyWith(
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // Statut
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    estTermine,
                    estEnCours,
                  ).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  estTermine
                      ? AppLocalizations.of(context).tacheFait
                      : (estEnCours
                            ? AppLocalizations.of(context).tacheEnCours(
                                tacheQuotidienne?.nombreActionsFaites ?? 0,
                                tacheQuotidienne?.actions.length ?? 0,
                              )
                            : AppLocalizations.of(context).tacheAFaire),
                  style: AppTheme.labelSmall.copyWith(
                    color: _getStatusColor(estTermine, estEnCours),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(bool estTermine, bool estEnCours) {
    if (estTermine) return AppTheme.primaryGreen;
    if (estEnCours) return AppTheme.warning;
    return AppTheme.textSecondary;
  }

  /// Micro-message pédagogique contextuel
  Widget _buildMicroMessage(
    BuildContext context,
    TacheProvider provider,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context);
    // Déterminer le nombre de rituels complétés aujourd'hui
    int tachesCompletes = 0;
    if (provider.matinTermine) tachesCompletes++;
    if (provider.soirTermine) tachesCompletes++;

    // Message de félicitations si rituels terminés
    if (tachesCompletes == 2) {
      return _buildMessageBanner(
        emoji: '🏆',
        message: l10n.tacheMessageDeuxFaits,
        astuce: l10n.tacheAstucePerformants,
        color: AppTheme.success,
        isDark: isDark,
      );
    }

    if (tachesCompletes == 1) {
      return _buildMessageBanner(
        emoji: '✅',
        message: l10n.tacheMessagePremierValide,
        astuce: l10n.tacheAstuceComplet,
        color: AppTheme.info,
        isDark: isDark,
      );
    }

    // Message d'encouragement si rien n'est fait
    final heure = DateTime.now().hour;
    if (heure >= 10 && heure < 14) {
      // Matinée avancée, TacheQuotidienne matin pas fait
      return _buildMessageBanner(
        emoji: '🌅',
        message: l10n.tacheMessageMatinAttend,
        astuce: l10n.tacheAstuceObservation,
        color: AppTheme.warning.withValues(alpha: 0.8),
        isDark: isDark,
      );
    } else if (heure >= 18 && heure < 21) {
      // Soirée, rappel TacheQuotidienne soir
      return _buildMessageBanner(
        emoji: '🌙',
        message: l10n.tacheMessageHeureSoir,
        astuce: l10n.tacheAstuceObserverNuit,
        color: AppTheme.info,
        isDark: isDark,
      );
    }

    // Pas de message particulier
    return const SizedBox.shrink();
  }

  Widget _buildMessageBanner({
    required String emoji,
    required String message,
    required String astuce,
    required Color color,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: AppTheme.bodySmall.copyWith(
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    astuce,
                    style: AppTheme.caption.copyWith(
                      color:
                          (isDark ? AppTheme.textLight : AppTheme.textSecondary)
                              .withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
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

  Widget _buildAnomaliesBanner(
    BuildContext context,
    int nombreAnomalies,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: AppTheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(
                context,
              ).tacheAnomaliesAujourdhui(nombreAnomalies),
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.error,
            size: 20,
          ),
        ],
      ),
    );
  }
}

/// Widget compact pour afficher dans une liste ou un autre contexte
class TacheMiniCard extends StatelessWidget {
  final TypeTacheQuotidienne type;

  const TacheMiniCard({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final estMatin = type == TypeTacheQuotidienne.matin;

    return Consumer<TacheProvider>(
      builder: (context, provider, _) {
        final tacheQuotidienne = estMatin
            ? provider.tacheMatin
            : provider.tacheSoir;
        final estTermine = tacheQuotidienne?.estComplet ?? false;

        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: estTermine
                  ? AppTheme.primaryGreen.withValues(alpha: 0.2)
                  : (estMatin ? AppTheme.warning : AppTheme.info).withValues(
                      alpha: 0.2,
                    ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                estMatin ? '🌅' : '🌙',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          title: Text(
            estMatin
                ? AppLocalizations.of(context).tacheDuMatinComplet
                : AppLocalizations.of(context).tacheDuSoirComplet,
            style: AppTheme.titleSmall.copyWith(
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
          subtitle: Text(
            estTermine
                ? AppLocalizations.of(context).tacheTermine
                : '${tacheQuotidienne?.nombreActionsFaites ?? 0}/${tacheQuotidienne?.actions.length ?? 0} actions',
            style: AppTheme.bodySmall.copyWith(
              color: estTermine
                  ? AppTheme.primaryGreen
                  : AppTheme.textSecondary,
            ),
          ),
          trailing: Icon(
            estTermine
                ? Icons.check_circle_rounded
                : Icons.arrow_forward_ios_rounded,
            color: estTermine ? AppTheme.primaryGreen : AppTheme.textSecondary,
            size: 20,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TacheScreen(typeTache: type)),
            );
          },
        );
      },
    );
  }
}
