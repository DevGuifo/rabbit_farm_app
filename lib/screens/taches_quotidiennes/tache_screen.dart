import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/anomalie_tache.dart';
import '../../models/tache_quotidienne.dart';
import '../../providers/tache_provider.dart';
import '../../providers/anomalie_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';
import '../../widgets/anomalie_guidee_sheet.dart';

// Helper pour convertir emoji en icône
IconData _emojiToIcon(String emoji) {
  switch (emoji) {
    case '💧':
      return Icons.water_drop_rounded;
    case '🥕':
      return Icons.restaurant_rounded;
    case '🏥':
      return Icons.health_and_safety_rounded;
    case '🧹':
      return Icons.cleaning_services_rounded;
    case '🔒':
      return Icons.lock_rounded;
    default:
      return Icons.task_alt_rounded;
  }
}

/// Écran de validation d'un TacheQuotidienne quotidien
///
/// UX optimisée pour l'éleveur africain :
/// - 1 clic = 1 action enregistrée
/// - Aucune saisie texte obligatoire
/// - Feedback haptique et visuel immédiat
class TacheScreen extends StatefulWidget {
  final TypeTacheQuotidienne typeTache;

  const TacheScreen({super.key, required this.typeTache});

  @override
  State<TacheScreen> createState() => _RituelScreenState();
}

class _RituelScreenState extends State<TacheScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TacheProvider>().chargerTaches();
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final estMatin = widget.typeTache == TypeTacheQuotidienne.matin;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDarkMode
          : AppTheme.backgroundLight,
      appBar: SimpleAppBar(
        title: estMatin
            ? AppLocalizations.of(context).tacheDuMatin
            : AppLocalizations.of(context).tacheDuSoir,
      ),
      body: Consumer<TacheProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final tacheQuotidienne = estMatin
              ? provider.getTacheDuJour(TypeTacheQuotidienne.matin)
              : provider.getTacheDuJour(TypeTacheQuotidienne.soir);
          if (tacheQuotidienne == null) {
            return _buildEmptyState(isDark);
          }

          return Column(
            children: [
              _buildProgressHeader(tacheQuotidienne, isDark),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tacheQuotidienne.actions.length,
                  itemBuilder: (context, index) {
                    final action = tacheQuotidienne.actions[index];
                    return _buildActionCard(
                      action,
                      tacheQuotidienne.type,
                      isDark,
                    );
                  },
                ),
              ),
              if (tacheQuotidienne.estComplet) _buildCompletionBanner(isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            size: 80,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).tacheChargement,
            style: AppTheme.titleLarge.copyWith(
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Header avec barre de progression
  Widget _buildProgressHeader(TacheQuotidienne tacheQuotidienne, bool isDark) {
    final progression = tacheQuotidienne.pourcentageCompletion;
    final estMatin = tacheQuotidienne.type == TypeTacheQuotidienne.matin;
    // Couleurs selon le moment de la journée
    final couleurPrimaire = estMatin
        ? const Color(0xFFFFA726)
        : const Color(0xFF5C6BC0);
    final couleurClaire = couleurPrimaire.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: couleurClaire,
        border: Border(
          bottom: BorderSide(
            color: couleurPrimaire.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                estMatin ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                size: 36,
                color: couleurPrimaire,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      ).tacheLabel(tacheQuotidienne.labelType),
                      style: AppTheme.titleLarge.copyWith(
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tacheQuotidienne.statutTexte,
                      style: AppTheme.bodyMedium.copyWith(
                        color: tacheQuotidienne.estComplet
                            ? AppTheme.primaryGreen
                            : AppTheme.textSecondary,
                        fontWeight: tacheQuotidienne.estComplet
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (tacheQuotidienne.nombreAnomalies > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.2),
                    borderRadius: AppTheme.borderRadiusLarge,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_rounded,
                        color: AppTheme.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tacheQuotidienne.nombreAnomalies}',
                        style: AppTheme.labelLarge.copyWith(
                          color: AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            child: LinearProgressIndicator(
              value: progression,
              minHeight: 10,
              backgroundColor: isDark
                  ? AppTheme.textSecondary.withValues(alpha: 0.2)
                  : AppTheme.textSecondary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progression >= 1.0 ? AppTheme.primaryGreen : couleurPrimaire,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${tacheQuotidienne.nombreActionsFaites} / ${tacheQuotidienne.actions.length} actions',
            style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Carte d'action avec boutons 1-clic
  Widget _buildActionCard(
    ActionTache action,
    TypeTacheQuotidienne typeTacheQuotidienne,
    bool isDark,
  ) {
    final estFait = action.estFait;
    final aAnomalie = action.aAnomalie;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: AppTheme.borderRadiusLarge,
        border: Border.all(
          color: estFait
              ? (aAnomalie ? AppTheme.error : AppTheme.primaryGreen)
              : AppTheme.textSecondary.withValues(alpha: 0.2),
          width: estFait ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête de l'action
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Emoji de l'action
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: (isDark
                        ? AppTheme.backgroundDarkMode
                        : AppTheme.backgroundLight),
                    borderRadius: AppTheme.borderRadiusMedium,
                  ),
                  child: Center(
                    child: Icon(
                      _emojiToIcon(action.icone),
                      size: 28,
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Titre et description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.titre,
                        style: AppTheme.titleMedium.copyWith(
                          color: isDark
                              ? AppTheme.textLight
                              : AppTheme.textPrimary,
                          decoration: estFait && !aAnomalie
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.description,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Statut
                if (estFait)
                  Icon(
                    aAnomalie
                        ? Icons.warning_rounded
                        : Icons.check_circle_rounded,
                    color: aAnomalie ? AppTheme.error : AppTheme.primaryGreen,
                    size: 28,
                  ),
              ],
            ),
          ),
          // Boutons d'action (1 clic)
          if (!estFait || action.resultat == ResultatAction.plusTard)
            _buildActionButtons(action, typeTacheQuotidienne, isDark),
          // Note d'anomalie si présente
          if (aAnomalie &&
              action.noteAnomalie != null &&
              action.noteAnomalie!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notes_rounded,
                    color: AppTheme.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      action.noteAnomalie!,
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Boutons d'action rapide (1 clic = 1 action)
  Widget _buildActionButtons(
    ActionTache action,
    TypeTacheQuotidienne typeTacheQuotidienne,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: Row(
        children: [
          // âœ… Normal
          Expanded(
            child: _buildQuickActionButton(
              label: AppLocalizations.of(context).tacheNormal,
              icon: Icons.check_rounded,
              color: AppTheme.primaryGreen,
              onTap: () => _validerNormal(typeTacheQuotidienne, action.id),
            ),
          ),
          const SizedBox(width: 8),
          // âš ï¸ Anomalie
          Expanded(
            child: _buildQuickActionButton(
              label: AppLocalizations.of(context).tacheAnomalie,
              icon: Icons.warning_rounded,
              color: AppTheme.error,
              onTap: () => _validerAnomalie(typeTacheQuotidienne, action),
            ),
          ),
          const SizedBox(width: 8),
          // â° Plus tard
          Expanded(
            child: _buildQuickActionButton(
              label: AppLocalizations.of(context).tachePlusTard,
              icon: Icons.schedule_rounded,
              color: AppTheme.warning,
              onTap: () => _validerPlusTard(typeTacheQuotidienne, action.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: AppTheme.borderRadiusMedium,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: AppTheme.borderRadiusMedium,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTheme.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bannière de complétion
  Widget _buildCompletionBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.success50,
        border: Border(top: BorderSide(color: AppTheme.success, width: 2)),
      ),
      child: Row(
        children: [
          Icon(Icons.celebration_rounded, size: 32, color: AppTheme.success),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).tacheTermine,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppLocalizations.of(context).tacheBravo,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: AppTheme.primaryButtonStyle,
            child: Text(AppLocalizations.of(context).tacheBoutonTermine),
          ),
        ],
      ),
    );
  }

  // Actions
  void _validerNormal(TypeTacheQuotidienne type, String actionId) {
    context.read<TacheProvider>().validerNormal(type, actionId);
    _showFeedback(
      '✅ ${AppLocalizations.of(context).tacheSnackActionValidee}',
      AppTheme.primaryGreen,
    );
  }

  void _validerPlusTard(TypeTacheQuotidienne type, String actionId) {
    context.read<TacheProvider>().validerPlusTard(type, actionId);
    _showFeedback(
      'â° ${AppLocalizations.of(context).tacheSnackActionReportee}',
      AppTheme.warning,
    );
  }

  void _validerAnomalie(TypeTacheQuotidienne type, ActionTache action) {
    final tacheProvider = context.read<TacheProvider>();
    final tache = type == TypeTacheQuotidienne.matin
        ? tacheProvider.getTacheDuJour(TypeTacheQuotidienne.matin)
        : tacheProvider.getTacheDuJour(TypeTacheQuotidienne.soir);

    // 1 tap = enregistré : on marque l'action comme anomalie tout de suite
    tacheProvider.validerAnomalie(type, action.id);

    // On crée aussi une anomalie minimale (type "autre") pour ne pas perdre la trace
    // Les détails restent optionnels (bouton "Détails")
    () async {
      final anomalieProvider = context.read<AnomalieProvider>();
      final anomalie = await anomalieProvider.enregistrerAnomalie(
        tacheId: tache?.id,
        actionRituelId: action.id,
        actionRituelTitre: action.titre,
        typesSelectionnes: const [TypeAnomalie.autre],
        portee: PorteeAnomalie.lot,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'âš ï¸ ${AppLocalizations.of(context).tacheSnackProblemeEnregistre}',
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: AppLocalizations.of(context).labelDetails,
            textColor: Colors.white,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => ChangeNotifierProvider.value(
                  value: context.read<AnomalieProvider>(),
                  child: AnomalieGuideeSheet(
                    tacheId: tache?.id,
                    typeTache: type,
                    action: action,
                    anomalieInitiale: anomalie,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }();
  }

  void _showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
