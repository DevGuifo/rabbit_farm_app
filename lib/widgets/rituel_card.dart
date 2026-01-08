import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/rituel.dart';
import '../providers/rituel_provider.dart';
import '../screens/rituels/rituel_screen.dart';
import '../theme/app_theme.dart';

/// Widget carte pour afficher le statut des rituels quotidiens sur le dashboard
///
/// Affiche l'état des rituels matin et soir avec navigation 1-clic
/// Design optimisé pour visibilité rapide :
/// - ✅ Fait = vert
/// - 🔄 En cours = orange
/// - ⏳ À faire = gris
class RituelCard extends StatelessWidget {
  const RituelCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<RituelProvider>(
      builder: (context, provider, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? AppTheme.cardDark : AppTheme.cardLight,
                isDark
                    ? AppTheme.cardDark.withValues(alpha: 0.8)
                    : AppTheme.cardLight,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getBorderColor(provider), width: 2),
            boxShadow: [
              BoxShadow(
                color: _getBorderColor(provider).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
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
                    // Rituel matin
                    Expanded(
                      child: _buildRituelButton(
                        context: context,
                        type: TypeRituel.matin,
                        rituel: provider.rituelMatin,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Rituel soir
                    Expanded(
                      child: _buildRituelButton(
                        context: context,
                        type: TypeRituel.soir,
                        rituel: provider.rituelSoir,
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

  Color _getBorderColor(RituelProvider provider) {
    if (provider.matinTermine && provider.soirTermine) {
      return AppTheme.primaryGreen;
    } else if (provider.rituelMatin?.estEnCours == true ||
        provider.rituelSoir?.estEnCours == true) {
      return AppTheme.warning;
    }
    return AppTheme.textSecondary.withValues(alpha: 0.3);
  }

  Widget _buildHeader(
    BuildContext context,
    RituelProvider provider,
    bool isDark,
  ) {
    final tousTermines = provider.matinTermine && provider.soirTermine;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: tousTermines
                    ? [AppTheme.primaryGreen, AppTheme.primaryNeonGreen]
                    : [
                        AppTheme.warning.withValues(alpha: 0.8),
                        AppTheme.warning,
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
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
                  AppLocalizations.of(context).rituelsDuJour,
                  style: AppTheme.titleMedium.copyWith(
                    color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tousTermines
                      ? AppLocalizations.of(context).rituelTermine
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

  String _getStatusText(BuildContext context, RituelProvider provider) {
    final matin = provider.rituelMatin;
    final soir = provider.rituelSoir;
    final l10n = AppLocalizations.of(context);

    if (matin == null && soir == null) return l10n.rituelChargement;

    if (provider.matinTermine && !provider.soirTermine) {
      return l10n.rituelMatinFaitSoirAttente;
    } else if (!provider.matinTermine && provider.soirTermine) {
      return l10n.rituelMatinAttenteSoirFait;
    } else if (matin?.estEnCours == true) {
      return l10n.rituelMatinEnCours;
    } else if (soir?.estEnCours == true) {
      return l10n.rituelSoirEnCours;
    }
    return l10n.rituelAppuyerCommencer;
  }

  String _getProgressText(RituelProvider provider) {
    int total = 0;
    int fait = 0;

    final matin = provider.rituelMatin;
    final soir = provider.rituelSoir;

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
    required TypeRituel type,
    required Rituel? rituel,
    required bool isDark,
  }) {
    final estMatin = type == TypeRituel.matin;
    final estTermine = rituel?.estComplet ?? false;
    final estEnCours = rituel?.estEnCours ?? false;
    final progression = rituel?.pourcentageCompletion ?? 0.0;

    final couleurPrimaire = estMatin ? AppTheme.warning : AppTheme.info;
    final couleurFond = estTermine
        ? AppTheme.primaryGreen.withValues(alpha: 0.15)
        : couleurPrimaire.withValues(alpha: 0.1);

    return Material(
      color: couleurFond,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RituelScreen(typeRituel: type)),
          );
        },
        borderRadius: BorderRadius.circular(16),
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
                  Text(
                    estMatin ? '🌅' : '🌙',
                    style: const TextStyle(fontSize: 28),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Label
              Text(
                estMatin
                    ? AppLocalizations.of(context).rituelMatin
                    : AppLocalizations.of(context).rituelSoir,
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
                      ? AppLocalizations.of(context).rituelFait
                      : (estEnCours
                            ? AppLocalizations.of(context).rituelEnCours(
                                rituel?.nombreActionsFaites ?? 0,
                                rituel?.actions.length ?? 0,
                              )
                            : AppLocalizations.of(context).rituelAFaire),
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
    RituelProvider provider,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context);
    // Déterminer le nombre de rituels complétés aujourd'hui
    int rituelsCompletes = 0;
    if (provider.matinTermine) rituelsCompletes++;
    if (provider.soirTermine) rituelsCompletes++;

    // Message de félicitations si rituels terminés
    if (rituelsCompletes == 2) {
      return _buildMessageBanner(
        emoji: '🏆',
        message: l10n.rituelMessageDeuxFaits,
        astuce: l10n.rituelAstucePerformants,
        color: AppTheme.success,
        isDark: isDark,
      );
    }

    if (rituelsCompletes == 1) {
      return _buildMessageBanner(
        emoji: '✅',
        message: l10n.rituelMessagePremierValide,
        astuce: l10n.rituelAstuceComplet,
        color: AppTheme.info,
        isDark: isDark,
      );
    }

    // Message d'encouragement si rien n'est fait
    final heure = DateTime.now().hour;
    if (heure >= 10 && heure < 14) {
      // Matinée avancée, rituel matin pas fait
      return _buildMessageBanner(
        emoji: '🌅',
        message: l10n.rituelMessageMatinAttend,
        astuce: l10n.rituelAstuceObservation,
        color: AppTheme.warning.withValues(alpha: 0.8),
        isDark: isDark,
      );
    } else if (heure >= 18 && heure < 21) {
      // Soirée, rappel rituel soir
      return _buildMessageBanner(
        emoji: '🌙',
        message: l10n.rituelMessageHeureSoir,
        astuce: l10n.rituelAstuceObserverNuit,
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
              ).rituelAnomaliesAujourdhui(nombreAnomalies),
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
class RituelMiniCard extends StatelessWidget {
  final TypeRituel type;

  const RituelMiniCard({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final estMatin = type == TypeRituel.matin;

    return Consumer<RituelProvider>(
      builder: (context, provider, _) {
        final rituel = estMatin ? provider.rituelMatin : provider.rituelSoir;
        final estTermine = rituel?.estComplet ?? false;

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
                ? AppLocalizations.of(context).rituelDuMatinComplet
                : AppLocalizations.of(context).rituelDuSoirComplet,
            style: AppTheme.titleSmall.copyWith(
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
          subtitle: Text(
            estTermine
                ? AppLocalizations.of(context).rituelTermine
                : '${rituel?.nombreActionsFaites ?? 0}/${rituel?.actions.length ?? 0} actions',
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
              MaterialPageRoute(builder: (_) => RituelScreen(typeRituel: type)),
            );
          },
        );
      },
    );
  }
}
