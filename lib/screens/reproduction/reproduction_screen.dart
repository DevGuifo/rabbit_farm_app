import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/accouplement.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/dialog_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import '../parametres/parametres_screen.dart';
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
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Pregnant',
    'Nursing',
    'Weaned',
    'Ready to Wean',
  ];
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

    switch (_selectedFilter) {
      case 'All':
        filtres = filtres.where((a) => a.statut != 'termine').toList();
        break;
      case 'Pregnant':
        filtres = filtres
            .where((a) => a.statut == 'en_attente' || a.statut == 'confirme')
            .toList();
        break;
      case 'Ready to Wean':
        filtres = filtres.where((a) {
          if (a.statut != 'termine') return false;
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
        break;
    }

    return filtres;
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
        child: Consumer<ReproductionProvider>(
          builder: (context, reproProvider, _) {
            final displayedAccouplements = _appliquerFiltres(
              reproProvider.accouplements,
            );
            final toDisplay = _showAllPairings
                ? displayedAccouplements
                : displayedAccouplements.take(3).toList();

            return SingleChildScrollView(
              child: Column(
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
              ),
            );
          },
        ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  /// Header - Utilise StandardHeader
  Widget _buildHeader(bool isDark) {
    return StandardHeader(
      title: 'Reproduction',
      isDark: isDark,
      onSync: _chargerDonnees,
      onNotifications: () {},
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
    return SizedBox(
      height: 52,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: EdgeInsets.only(
              right: index < _filters.length - 1 ? 12 : 0,
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
      title: 'Active Pairings',
      isDark: isDark,
      onMoreTap: () {
        setState(() {
          _showAllPairings = !_showAllPairings;
        });
      },
    );
  }

  Widget _buildFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          mini: true,
          backgroundColor: AppTheme.warning,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SevrageScreen()),
            );
          },
          tooltip: 'Weaning',
          child: const Icon(Icons.pets),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          mini: true,
          backgroundColor: AppTheme.info,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PreparationNidScreen()),
            );
          },
          tooltip: 'Nesting',
          child: const Icon(Icons.home_work),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          backgroundColor: AppTheme.primaryNeonGreen,
          onPressed: _planifierAccouplement,
          tooltip: 'Schedule Pairing',
          child: const Icon(Icons.add),
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

  void _deleteAccouplement(int accouplementId) {
    DialogHelper.showConfirmDialog(
      context,
      'Delete Pairing',
      'Are you sure you want to delete this pairing?',
      () async {
        try {
          await context.read<ReproductionProvider>().supprimerAccouplement(
            accouplementId,
          );
          if (!mounted) return;
          SnackbarHelper.show(context, 'Pairing deleted');
        } catch (e) {
          if (!mounted) return;
          SnackbarHelper.showError(context, 'Error deleting pairing: $e');
        }
      },
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
                        'Palpation Required',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.warning.withValues(alpha: 0.2)
                              : AppTheme.backgroundDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Check ${accouplementsAPalper.length} doe(s) for pregnancy',
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
