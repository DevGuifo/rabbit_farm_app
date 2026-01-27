import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import '../../models/lapin.dart';
import '../../models/enums/sexe.dart';
import '../../models/accouplement.dart';
import '../../models/portee.dart';
import '../../models/pesee.dart';
import '../../models/soin.dart';
import '../../services/database_helper.dart';
import '../../services/pdf_service.dart';
import '../../utils/snackbar_helper.dart';
import '../../services/error_service.dart';
import '../../providers/lapin_provider.dart';
import '../../widgets/quarantaine/quarantaine_quick_dialog.dart';
import '../deces/enregistrer_deces_screen.dart';
import 'genealogie_screen.dart';
import 'edit_lapin_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/quick_add_pesee_dialog.dart';
import '../../widgets/quick_add_soin_dialog.dart';
import '../../widgets/common/common_widgets.dart';

// Stitch Design Components
import 'lapin_detail/widgets/detail_app_bar.dart';
import 'lapin_detail/widgets/detail_profile_header.dart';
import 'lapin_detail/widgets/detail_segmented_control.dart';
import 'lapin_detail/widgets/detail_floating_action_button.dart';
import 'lapin_detail/tabs/identity_tab.dart';
import 'lapin_detail/tabs/statistics_tab.dart';
import 'lapin_detail/tabs/reproduction_tab.dart';
import '../reproduction/quick_mating_screen.dart';
import '../reproduction/reproduction_screen.dart';
import '../optimisation/palpation_screen.dart';
import '../optimisation/preparation_nid_screen.dart';
import '../optimisation/sevrage_screen.dart';

/// Écran de détails d'un lapin - Design Stitch (Yellow Primary)
/// Architecture: Orchestrateur léger avec widgets dédiés
class LapinDetailScreen extends StatefulWidget {
  final Lapin lapin;

  const LapinDetailScreen({super.key, required this.lapin});

  @override
  State<LapinDetailScreen> createState() => _LapinDetailScreenState();
}

class _LapinDetailScreenState extends State<LapinDetailScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final PdfService _pdfService = PdfService();

  // Selected tab: 0=Identity, 1=Statistics, 2=Reproduction
  int _selectedTab = 0;

  final Map<String, Lapin?> _parents = {};
  List<Pesee> _pesees = [];
  List<Soin> _soins = [];
  List<Accouplement> _accouplements = [];
  final List<Portee> _portees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    setState(() => _isLoading = true);

    // Charger parents
    final relations = await _db.getRelationByLapinId(widget.lapin.id!);
    if (relations != null) {
      if (relations['pereId'] != null) {
        _parents['pere'] = await _db.getLapinById(relations['pereId']!);
      }
      if (relations['mereId'] != null) {
        _parents['mere'] = await _db.getLapinById(relations['mereId']!);
      }
    }

    // Charger pesées et soins
    _pesees = await _db.getPeseesByLapin(widget.lapin.id!);
    _soins = await _db.getSoinsByLapin(widget.lapin.id!);

    // Charger accouplements (mâle ou femelle)
    if (widget.lapin.sexe == Sexe.male) {
      _accouplements = await _db.getAccouplementsByMale(widget.lapin.id!);
    } else {
      _accouplements = await _db.getAccouplementsByFemelle(widget.lapin.id!);
    }

    // Charger portées
    for (var accouplement in _accouplements) {
      final portee = await _db.getPorteeByAccouplement(accouplement.id!);
      if (portee != null) {
        _portees.add(portee);
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppTheme.getBackgroundColor(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accentGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverToBoxAdapter(
              child: DetailAppBar(
                onBack: () => Navigator.pop(context),
                onSync: _chargerDonnees,
                onViewGenealogie: _voirGeneralogie,
                onExportPDF: _exporterPDF,
                onMarkQuarantaine: _mettreEnQuarantaine,
                onMarkDecede: _marquerCommeDecede,
              ),
            ),
            // Profile Header
            SliverToBoxAdapter(child: DetailProfileHeader(lapin: widget.lapin)),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            // Segmented Control (Sticky)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickySegmentedControlDelegate(
                child: Container(
                  color: backgroundColor,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: DetailSegmentedControl(
                    selectedIndex: _selectedTab,
                    onTabChanged: (index) {
                      setState(() => _selectedTab = index);
                    },
                    tabs: [
                      AppLocalizations.of(context).ongletIdentite,
                      AppLocalizations.of(context).ongletStatistiques,
                      AppLocalizations.of(context).ongletReproduction,
                    ],
                  ),
                ),
              ),
            ),
            // Tab Content
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentTab(),
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button contextuel selon l'onglet
      floatingActionButton: _buildContextualFAB(),
    );
  }

  /// FAB contextuel selon l'onglet actif
  Widget _buildContextualFAB() {
    switch (_selectedTab) {
      case 0: // Identity - Modifier
        return DetailFloatingActionButton(onPressed: _modifierLapin);
      case 1: // Statistics - Ajouter pesée/soin
        return _buildStatisticsFAB();
      case 2: // Reproduction - Accoupler
        return _buildReproductionFAB();
      default:
        return DetailFloatingActionButton(onPressed: _modifierLapin);
    }
  }

  /// FAB pour l'onglet Statistics avec menu pesée/soin
  Widget _buildStatisticsFAB() {
    return UnifiedFABSpeedDial(
      actions: [
        UnifiedFABAction(
          icon: Icons.medical_services,
          label: 'Soin',
          onPressed: _ajouterSoin,
          tooltip: AppLocalizations.of(context).santeAjouterSoin,
          backgroundColor: AppTheme.accentTeal,
        ),
        UnifiedFABAction(
          icon: Icons.monitor_weight,
          label: 'Pesée',
          onPressed: _ajouterPesee,
          tooltip: AppLocalizations.of(context).santeAjouterPesee,
          backgroundColor: AppTheme.info,
        ),
      ],
    );
  }

  /// FAB pour l'onglet Reproduction
  Widget _buildReproductionFAB() {
    final isFemelle = widget.lapin.sexe == Sexe.femelle;
    final isAdulte = widget.lapin.ageEnMois >= 5;

    if (!isAdulte ||
        widget.lapin.statut == 'vendu' ||
        widget.lapin.statut == 'decede') {
      return const SizedBox.shrink();
    }

    return UnifiedFAB.extended(
      onPressed: isFemelle
          ? _naviguerVersAccouplement
          : _naviguerVersReproductions,
      icon: Icons.favorite,
      label: isFemelle ? 'Accoupler' : 'Voir reproductions',
      tooltip: isFemelle ? 'Accoupler' : 'Voir reproductions',
    );
  }

  /// Ajouter une pesée
  Future<void> _ajouterPesee() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => QuickAddPeseeDialog(lapin: widget.lapin),
    );

    if (result != true) return;
    if (!mounted) return;
    await _chargerDonnees();
    if (!mounted) return;
    SnackbarHelper.showSuccess(context, 'Pesée enregistrée');
  }

  /// Ajouter un soin
  Future<void> _ajouterSoin() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => QuickAddSoinDialog(lapin: widget.lapin),
    );

    if (result != true) return;
    if (!mounted) return;
    await _chargerDonnees();
    if (!mounted) return;
    SnackbarHelper.showSuccess(context, 'Soin enregistré');
  }

  Widget _buildCurrentTab() {
    switch (_selectedTab) {
      case 0:
        return IdentityTab(
          key: const ValueKey('identity'),
          lapin: widget.lapin,
          parents: _parents,
          onParentTap: (parent) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LapinDetailScreen(lapin: parent),
              ),
            );
          },
          onViewGenealogie: _voirGeneralogie,
          onExportPDF: _exporterPDF,
          onMarkQuarantaine: widget.lapin.statut != 'quarantaine'
              ? _mettreEnQuarantaine
              : null,
          onMarkDecede: _marquerCommeDecede,
          onMatingPressed: _naviguerVersAccouplement,
          onPalpationPressed: _fairePalpation,
          onNestPrepPressed: _preparerNid,
          onWeaningPressed: _faireSevrage,
          onReproductionsPressed: _naviguerVersReproductions,
        );
      case 1:
        return StatisticsTab(
          key: const ValueKey('statistics'),
          pesees: _pesees,
          soins: _soins,
          accouplements: _accouplements,
          portees: _portees,
          lapin: widget.lapin,
        );
      case 2:
        return ReproductionTab(
          key: const ValueKey('reproduction'),
          accouplements: _accouplements,
          portees: _portees,
        );
      default:
        return const SizedBox();
    }
  }

  // ===== ACTIONS =====

  Future<void> _voirGeneralogie() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenealogieScreen(lapin: widget.lapin),
      ),
    );
  }

  Future<void> _modifierLapin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditLapinScreen(lapin: widget.lapin),
      ),
    );
    if (!mounted) return;
    if (result == true) {
      final provider = Provider.of<LapinProvider>(context, listen: false);
      await provider.chargerLapins();
      if (!mounted) return;
      await _chargerDonnees();
      if (!mounted) return;
      SnackbarHelper.showSuccess(context, 'Lapin modifié avec succès');
    }
  }

  Future<void> _exporterPDF() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: AppTheme.accentGreen),
        ),
      );

      await _pdfService.genererFicheLapin(widget.lapin);
      if (!mounted) return;
      Navigator.pop(context);
      SnackbarHelper.showSuccess(context, 'PDF généré avec succès');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ErrorService.showError(context, e);
    }
  }

  Future<void> _mettreEnQuarantaine() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => QuarantaineQuickDialog(lapin: widget.lapin),
    );

    if (result == true && mounted) {
      await Provider.of<LapinProvider>(context, listen: false).chargerLapins();
      if (mounted) {
        await _chargerDonnees();
      }
    }
  }

  Future<void> _marquerCommeDecede() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnregistrerDecesScreen(lapin: widget.lapin),
      ),
    );

    if (result != true) return;
    if (!mounted) return;
    await Provider.of<LapinProvider>(context, listen: false).chargerLapins();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  // ===== QUICK ACTIONS =====

  Future<void> _naviguerVersAccouplement() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuickMatingScreen(femelle: widget.lapin),
      ),
    );

    if (result != true) return;
    if (!mounted) return;
    await _chargerDonnees();
    if (!mounted) return;
    SnackbarHelper.showSuccess(context, 'Accouplement enregistré');
  }

  Future<void> _naviguerVersReproductions() async {
    // Pour les mâles : voir tous ses accouplements
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReproductionScreen()),
    );
  }

  void _fairePalpation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PalpationScreen()),
    );
  }

  void _preparerNid() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PreparationNidScreen()),
    );
  }

  void _faireSevrage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SevrageScreen()),
    );
  }
}

/// Delegate pour rendre le segmented control sticky
class _StickySegmentedControlDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickySegmentedControlDelegate({required this.child});

  @override
  double get minExtent => 76;

  @override
  double get maxExtent => 76;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickySegmentedControlDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
