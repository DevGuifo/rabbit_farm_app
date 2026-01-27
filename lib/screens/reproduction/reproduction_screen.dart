import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import '../../models/accouplement.dart';
import '../../models/enums/statut_accouplement.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/sync_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/dialog_helper.dart';
import '../../theme/app_theme.dart';
import '../../repositories/reproduction_repository.dart';
import '../../widgets/common/common_widgets.dart';
import '../parametres/parametres_screen.dart';
import '../alertes/alertes_screen.dart';
import '../optimisation/sevrage_screen.dart';
import '../optimisation/preparation_nid_screen.dart';
import 'planifier_accouplement_screen.dart';
import 'edit_accouplement_screen.dart';
import 'widgets/reproduction_stats.dart';
import 'widgets/reproduction_pairings_list.dart';

/// Écran Reproduction - Design System Unifié
/// Orchestrateur léger qui compose les widgets modulaires
/// <400 lignes: logique centralisée, pas de custom UI

class ReproductionScreen extends StatefulWidget {
  const ReproductionScreen({super.key});

  @override
  State<ReproductionScreen> createState() => _ReproductionScreenState();
}

class _ReproductionScreenState extends State<ReproductionScreen> {
  String _selectedFilter = '';

  List<String> _getFilters(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return [
      loc.reproTous,
      loc.reproGestantes,
      loc.reproAllaitantes,
      loc.reproSevrees,
      loc.reproSevrageReady,
    ];
  }

  bool _showAllPairings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerDonnees();
    });
  }

  Future<void> _chargerDonnees() async {
    final repro = context.read<ReproductionProvider>();
    final lapins = context.read<LapinProvider>();
    await repro.chargerTout();
    await lapins.chargerLapins();
  }

  List<Accouplement> _appliquerFiltres(List<Accouplement> accouplements) {
    var filtres = accouplements;
    final filters = _getFilters(context);

    if (_selectedFilter == '' || _selectedFilter == filters[0]) {
      // Tous
      filtres = filtres.where((a) => a.statut != StatutAccouplement.termine).toList();
    } else if (_selectedFilter == filters[1]) {
      // Gestantes
      filtres = filtres
          .where((a) => a.statut == StatutAccouplement.enAttente || a.statut == StatutAccouplement.confirme)
          .toList();
    } else if (_selectedFilter == filters[4]) {
      // Prêtes à sevrer
      filtres = filtres.where((a) {
        if (a.statut != StatutAccouplement.termine) return false;
        final provider = context.read<ReproductionProvider>();
        try {
          final portee = provider.portees.firstWhere(
            (p) => p.accouplementId == a.id,
          );
          final ageEnJours = DateTime.now()
              .difference(portee.dateMiseBasReelle)
              .inDays;
          return ageEnJours >= 28 && ageEnJours <= 56;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    return filtres;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: Column(
        children: [
          // Fixed header (like cheptel_screen)
          _buildHeader(isDark),
          // Indicateur mode hors-ligne fixe
          const OfflineBanner(),
          // Scrollable content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _chargerDonnees,
              color: AppTheme.primaryGreen,
              child: CustomScrollView(
                slivers: [
                  // Contenu scrollable
                  SliverToBoxAdapter(
                    child: Consumer<ReproductionProvider>(
                      builder: (context, reproProvider, _) {
                        final displayedAccouplements = _appliquerFiltres(
                          reproProvider.accouplements,
                        );
                        final toDisplay = _showAllPairings
                            ? displayedAccouplements
                            : displayedAccouplements.take(3).toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            ReproductionStats(isDark: isDark),
                            const SizedBox(height: 16),
                            ReproductionPalpationAlert(isDark: isDark),
                            const SizedBox(height: 8),
                            _buildFilterPills(isDark),
                            const SizedBox(height: 16),
                            _buildSectionHeader(isDark),
                            const SizedBox(height: 12),
                            ReproductionPairingsList(
                              isDark: isDark,
                              accouplements: toDisplay,
                              showAll: _showAllPairings,
                              onEditTap: _editAccouplement,
                              onDeleteTap: _deleteAccouplement,
                            ),
                            const SizedBox(height: 150),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  /// Header - Utilise StandardHeader unifié
  Widget _buildHeader(bool isDark) {
    return StandardHeader(
      title: AppLocalizations.of(context).reproduction,
      isDark: isDark,
      onSync: () async {
        // Synchroniser puis recharger
        final syncProvider = context.read<SyncProvider>();
        await syncProvider.syncNow();
        _chargerDonnees();
      },
      onNotifications: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AlertesScreen()),
        );
      },
      onSettings: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ParametresScreen()),
        );
      },
    );
  }

  /// Filter Pills - Utilise FilterPill
  Widget _buildFilterPills(bool isDark) {
    final filters = _getFilters(context);
    return SizedBox(
      height: 52,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: EdgeInsets.only(
              right: index < filters.length - 1 ? 12 : 0,
            ),
            child: FilterPill(
              label: filter,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }

  /// Section Header - Utilise SectionHeader
  Widget _buildSectionHeader(bool isDark) {
    return SectionHeader(
      title: AppLocalizations.of(context).reproAccouplementsActifs,
      isDark: isDark,
      onMoreTap: () {
        setState(() {
          _showAllPairings = !_showAllPairings;
        });
      },
    );
  }

  /// FAB SpeedDial avec actions multiples
  Widget _buildFAB() {
    return UnifiedFABSpeedDial(
      actions: [
        UnifiedFABAction(
          icon: Icons.pets,
          label: AppLocalizations.of(context).reproSevrage,
          tooltip: AppLocalizations.of(context).reproSevrage,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SevrageScreen()),
            );
          },
        ),
        UnifiedFABAction(
          icon: Icons.home_work,
          label: AppLocalizations.of(context).reproPreparationNid,
          tooltip: AppLocalizations.of(context).reproPreparationNid,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PreparationNidScreen()),
            );
          },
        ),
        UnifiedFABAction(
          icon: Icons.favorite_rounded,
          label: AppLocalizations.of(context).reproPlanifierSaillie,
          tooltip: AppLocalizations.of(context).reproPlanifierSaillie,
          onPressed: _planifierAccouplement,
        ),
      ],
    );
  }

  void _editAccouplement(Accouplement accouplement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAccouplementScreen(accouplement: accouplement),
      ),
    );
  }

  void _deleteAccouplement(int accouplementId) async {
    // Récupérer l'élément avant suppression pour permettre "Annuler"
    final accouplement = await ReproductionRepository.instance
        .getAccouplementById(accouplementId);

    if (!mounted) return;
    DialogHelper.showConfirmDialog(
      context,
      AppLocalizations.of(context).confirmDeleteGeneric,
      AppLocalizations.of(context).commonDeleteQuestion,
      () async {
        try {
          await context.read<ReproductionProvider>().supprimerAccouplement(
            accouplementId,
          );
          if (!mounted) return;
          SnackbarHelper.showSuccess(
            context,
            AppLocalizations.of(context).msgSuccessDeleted,
            action: SnackBarAction(
              label: AppLocalizations.of(context).annuler,
              onPressed: () async {
                if (accouplement != null && context.mounted) {
                  // Réinsérer l'élément (nouvel ID sera attribué)
                  await context
                      .read<ReproductionProvider>()
                      .ajouterAccouplement(accouplement.copyWith(id: null));
                }
              },
            ),
          );
        } catch (e) {
          if (!mounted) return;
          SnackbarHelper.showError(
            context,
            'Erreur lors de la suppression: $e',
          );
        }
      },
      confirmLabel: AppLocalizations.of(context).btnSupprimer,
      cancelLabel: AppLocalizations.of(context).annuler,
      isDangerous: true,
    );
  }

  void _planifierAccouplement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlanifierAccouplementScreen()),
    );
  }
}

/// Widget Stats Reproduction - 3 cartes KPI
class ReproductionPalpationAlert extends StatelessWidget {
  final bool isDark;

  const ReproductionPalpationAlert({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<ReproductionProvider>(
      builder: (context, provider, _) {
        final now = DateTime.now();
        final accouplementsAPalper = provider.accouplements.where((a) {
          if (a.statut != StatutAccouplement.enAttente) return false;
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
                  ? AppTheme.warning.withValues(alpha: 0.3)
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
                Icon(Icons.medical_services, color: AppTheme.warning, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.reproPalpationRequise,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.warning.withValues(alpha: 0.8)
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.reproPalperCount(accouplementsAPalper.length),
                        style: AppTheme.bodyMedium.copyWith(
                          color: isDark
                              ? AppTheme.warning.withValues(alpha: 0.85)
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
