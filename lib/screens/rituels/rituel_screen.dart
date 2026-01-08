import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/anomalie_rituel.dart';
import '../../models/rituel.dart';
import '../../providers/rituel_provider.dart';
import '../../providers/anomalie_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';
import '../../widgets/anomalie_guidee_sheet.dart';

/// Écran de validation d'un rituel quotidien
///
/// UX optimisée pour l'éleveur africain :
/// - 1 clic = 1 action enregistrée
/// - Aucune saisie texte obligatoire
/// - Feedback haptique et visuel immédiat
class RituelScreen extends StatefulWidget {
  final TypeRituel typeRituel;

  const RituelScreen({super.key, required this.typeRituel});

  @override
  State<RituelScreen> createState() => _RituelScreenState();
}

class _RituelScreenState extends State<RituelScreen>
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
      context.read<RituelProvider>().chargerRituelsJour();
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
    final estMatin = widget.typeRituel == TypeRituel.matin;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDarkMode
          : AppTheme.backgroundLight,
      appBar: UniformAppBar(
        title: estMatin
            ? AppLocalizations.of(context).rituelDuMatin
            : AppLocalizations.of(context).rituelDuSoir,
        icon: estMatin ? Icons.wb_sunny_rounded : Icons.nightlight_rounded,
        iconColor: estMatin ? AppTheme.warning : AppTheme.info,
      ),
      body: Consumer<RituelProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final rituel = estMatin ? provider.rituelMatin : provider.rituelSoir;
          if (rituel == null) {
            return _buildEmptyState(isDark);
          }

          return Column(
            children: [
              _buildProgressHeader(rituel, isDark),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rituel.actions.length,
                  itemBuilder: (context, index) {
                    final action = rituel.actions[index];
                    return _buildActionCard(action, rituel.type, isDark);
                  },
                ),
              ),
              if (rituel.estComplet) _buildCompletionBanner(isDark),
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
            AppLocalizations.of(context).rituelChargement,
            style: AppTheme.titleLarge.copyWith(
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Header avec barre de progression
  Widget _buildProgressHeader(Rituel rituel, bool isDark) {
    final progression = rituel.pourcentageCompletion;
    final estMatin = rituel.type == TypeRituel.matin;
    final couleurPrimaire = estMatin ? AppTheme.warning : AppTheme.info;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            couleurPrimaire.withValues(alpha: 0.2),
            couleurPrimaire.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(rituel.emojiType, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      ).rituelLabel(rituel.labelType),
                      style: AppTheme.titleLarge.copyWith(
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rituel.statutTexte,
                      style: AppTheme.bodyMedium.copyWith(
                        color: rituel.estComplet
                            ? AppTheme.primaryGreen
                            : AppTheme.textSecondary,
                        fontWeight: rituel.estComplet
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (rituel.nombreAnomalies > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
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
                        '${rituel.nombreAnomalies}',
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
            borderRadius: BorderRadius.circular(10),
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
            '${rituel.nombreActionsFaites} / ${rituel.actions.length} actions',
            style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Carte d'action avec boutons 1-clic
  Widget _buildActionCard(
    ActionRituel action,
    TypeRituel typeRituel,
    bool isDark,
  ) {
    final estFait = action.estFait;
    final aAnomalie = action.aAnomalie;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      action.icone,
                      style: const TextStyle(fontSize: 28),
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
            _buildActionButtons(action, typeRituel, isDark),
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
    ActionRituel action,
    TypeRituel typeRituel,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: Row(
        children: [
          // ✅ Normal
          Expanded(
            child: _buildQuickActionButton(
              label: AppLocalizations.of(context).rituelNormal,
              icon: Icons.check_rounded,
              color: AppTheme.primaryGreen,
              onTap: () => _validerNormal(typeRituel, action.id),
            ),
          ),
          const SizedBox(width: 8),
          // ⚠️ Anomalie
          Expanded(
            child: _buildQuickActionButton(
              label: AppLocalizations.of(context).rituelAnomalie,
              icon: Icons.warning_rounded,
              color: AppTheme.error,
              onTap: () => _validerAnomalie(typeRituel, action),
            ),
          ),
          const SizedBox(width: 8),
          // ⏰ Plus tard
          Expanded(
            child: _buildQuickActionButton(
              label: AppLocalizations.of(context).rituelPlusTard,
              icon: Icons.schedule_rounded,
              color: AppTheme.warning,
              onTap: () => _validerPlusTard(typeRituel, action.id),
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
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
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withValues(alpha: 0.2),
            AppTheme.primaryNeonGreen.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Row(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).rituelTermine,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppLocalizations.of(context).rituelBravo,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context).rituelBoutonTermine),
          ),
        ],
      ),
    );
  }

  // Actions
  void _validerNormal(TypeRituel type, String actionId) {
    context.read<RituelProvider>().validerNormal(type, actionId);
    _showFeedback(
      '✅ ${AppLocalizations.of(context).rituelSnackActionValidee}',
      AppTheme.primaryGreen,
    );
  }

  void _validerPlusTard(TypeRituel type, String actionId) {
    context.read<RituelProvider>().validerPlusTard(type, actionId);
    _showFeedback(
      '⏰ ${AppLocalizations.of(context).rituelSnackActionReportee}',
      AppTheme.warning,
    );
  }

  void _validerAnomalie(TypeRituel type, ActionRituel action) {
    final rituelProvider = context.read<RituelProvider>();
    final rituel = type == TypeRituel.matin
        ? rituelProvider.rituelMatin
        : rituelProvider.rituelSoir;

    // 1 tap = enregistré : on marque l'action comme anomalie tout de suite
    rituelProvider.validerAnomalie(type, action.id);

    // On crée aussi une anomalie minimale (type "autre") pour ne pas perdre la trace
    // Les détails restent optionnels (bouton "Détails")
    () async {
      final anomalieProvider = context.read<AnomalieProvider>();
      final anomalie = await anomalieProvider.enregistrerAnomalie(
        rituelId: rituel?.id,
        actionRituelId: action.id,
        actionRituelTitre: action.titre,
        typesSelectionnes: const [TypeAnomalie.autre],
        portee: PorteeAnomalie.lot,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ ${AppLocalizations.of(context).rituelSnackProblemeEnregistre}',
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
                    rituelId: rituel?.id,
                    typeRituel: type,
                    actionRituel: action,
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
