import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/enums/tache_enums.dart';
import '../../providers/tache_generique_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/sync_provider.dart';
import '../../models/lapin.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import 'ajouter_tache_screen.dart';
import 'widgets/tache_card.dart';
import 'widgets/taches_filters.dart';

/// Écran principal du gestionnaire de tâches
class GestionnaireTachesScreen extends StatefulWidget {
  const GestionnaireTachesScreen({super.key});

  @override
  State<GestionnaireTachesScreen> createState() =>
      _GestionnaireTachesScreenState();
}

class _GestionnaireTachesScreenState extends State<GestionnaireTachesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerDonnees();
    });
  }

  Future<void> _chargerDonnees() async {
    final tacheProvider = context.read<TacheGeneriqueProvider>();
    final lapinProvider = context.read<LapinProvider>();
    await Future.wait([
      tacheProvider.chargerTaches(),
      lapinProvider.chargerLapins(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDarkMode
          : AppTheme.backgroundLight,
      body: Column(
        children: [
          _buildHeader(isDark),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _chargerDonnees,
              color: AppTheme.primaryNeonGreen,
              child: Consumer<TacheGeneriqueProvider>(
                builder: (context, tacheProvider, _) {
                  final lapinProvider = context.watch<LapinProvider>();
                  if (tacheProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final taches = tacheProvider.tachesFiltrees;

                  return Column(
                    children: [
                      TachesFilters(isDark: isDark),
                      Expanded(
                        child: taches.isEmpty
                            ? _buildEmptyState(isDark)
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: taches.length,
                                itemBuilder: (context, index) {
                                  final tache = taches[index];
                                  Lapin? lapin;
                                  if (tache.lapinId != null) {
                                    try {
                                      lapin = lapinProvider.lapins.firstWhere(
                                        (l) => l.id == tache.lapinId,
                                      );
                                    } catch (e) {
                                      // Lapin non trouvé, on laisse null
                                    }
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: TacheCard(
                                      tache: tache,
                                      isDark: isDark,
                                      lapin: lapin,
                                      onTap: () => _editerTache(context, tache),
                                      onToggleStatut: () =>
                                          _toggleStatut(tache),
                                      onDelete: () => _supprimerTache(tache),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ajouterTache(context),
        backgroundColor: AppTheme.primaryNeonGreen,
        icon: const Icon(Icons.add_rounded, color: AppTheme.textOnPrimary),
        label: Text(
          AppLocalizations.of(context).tachesNouvelleTache,
          style: AppTheme.labelLarge.copyWith(color: AppTheme.textOnPrimary),
        ),
      ),
    );
  }

  /// Header - Utilise StandardHeader unifié
  Widget _buildHeader(bool isDark) {
    return StandardHeader(
      title: AppLocalizations.of(context).tachesGestionnaire,
      isDark: isDark,
      onSync: () async {
        // Synchroniser puis recharger
        final syncProvider = context.read<SyncProvider>();
        await syncProvider.syncNow();
        _chargerDonnees();
      },
      onNotifications: null,
      onSettings: null,
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 80,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).tachesAucuneTache,
            style: AppTheme.titleLarge.copyWith(
              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).tachesCreezPremiere,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _ajouterTache(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AjouterTacheScreen()),
    );
    if (result == true) {
      _chargerDonnees();
    }
  }

  void _editerTache(BuildContext context, tache) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AjouterTacheScreen(tache: tache)),
    );
    if (result == true) {
      _chargerDonnees();
    }
  }

  void _toggleStatut(dynamic tache) {
    final provider = context.read<TacheGeneriqueProvider>();
    StatutTache nouveauStatut;
    if (tache.statut == StatutTache.aFaire) {
      nouveauStatut = StatutTache.enCours;
    } else if (tache.statut == StatutTache.enCours) {
      nouveauStatut = StatutTache.terminee;
    } else if (tache.statut == StatutTache.terminee) {
      nouveauStatut = StatutTache.aFaire;
    } else {
      nouveauStatut = StatutTache.aFaire;
    }
    provider.changerStatut(tache.id!, nouveauStatut);
  }

  void _supprimerTache(dynamic tache) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).tachesSupprimerTitre),
        content: Text(
          AppLocalizations.of(context).tachesSupprimerConfirmation(tache.titre),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).quarantaineAnnuler),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: Text(AppLocalizations.of(context).tachesSupprimer),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<TacheGeneriqueProvider>();
      await provider.supprimerTache(tache.id!);
    }
  }
}
