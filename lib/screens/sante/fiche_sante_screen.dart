import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/lapin.dart';
import '../../models/pesee.dart';
import '../../models/soin.dart';
import '../../providers/sante_provider.dart';
import '../../utils/dialog_helper.dart';
import 'ajouter_pesee_screen.dart';
import 'ajouter_soin_screen.dart';
import 'edit_pesee_screen.dart';
import 'edit_soin_screen.dart';
import 'pesee_tracking_screen.dart';
import 'widgets/fiche_sante_header.dart';
import 'widgets/fiche_sante_rabbit_card.dart';
import 'widgets/fiche_sante_filters.dart';
import 'widgets/fiche_sante_records_list.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

/// Fiche de santé détaillée d'un lapin - Design Stitch "Health Details"
class FicheSanteScreen extends StatefulWidget {
  final Lapin lapin;

  const FicheSanteScreen({super.key, required this.lapin});

  @override
  State<FicheSanteScreen> createState() => _FicheSanteScreenState();
}

class _FicheSanteScreenState extends State<FicheSanteScreen> {
  List<Pesee> _pesees = [];
  List<Soin> _soins = [];
  String _filtreActif = 'All';

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    final santeProvider = Provider.of<SanteProvider>(context, listen: false);
    final pesees = await santeProvider.getPeseesByLapin(widget.lapin.id!);
    final soins = await santeProvider.getSoinsByLapin(widget.lapin.id!);

    if (mounted) {
      setState(() {
        _pesees = pesees;
        _soins = soins;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppTheme.backgroundDarkMode
        : AppTheme.backgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _chargerDonnees,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header fixe
              SliverToBoxAdapter(
                child: FicheSanteHeader(
                  onBack: () => Navigator.pop(context),
                  onRefresh: _chargerDonnees,
                  onNotification:
                      null, // Masquer car pas de fonctionnalité spécifique
                  onSettings:
                      null, // Masquer car pas de fonctionnalité spécifique
                ),
              ),
              // Contenu scrollable
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    FicheSanteRabbitCard(
                      lapin: widget.lapin,
                      pesees: _pesees,
                      onEdit: () {},
                    ),
                    FicheSanteFilters(
                      activeFilter: _filtreActif,
                      onFilterChanged: (filter) =>
                          setState(() => _filtreActif = filter),
                      onSort: () {},
                    ),
                    FicheSanteRecordsList(
                      soins: _soins,
                      pesees: _pesees,
                      activeFilter: _filtreActif,
                      onEditSoin: _modifierSoin,
                      onDeleteSoin: _supprimerSoin,
                      onEditPesee: _modifierPesee,
                      onDeletePesee: _supprimerPesee,
                      onPeseeCardTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PeseeTrackingScreen(lapin: widget.lapin),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFAB() {
    return UnifiedFAB.extended(
      onPressed: _afficherMenuAjout,
      label: AppLocalizations.of(context).santeAddRecord,
      tooltip: AppLocalizations.of(context).santeAddRecord,
    );
  }

  void _afficherMenuAjout() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      builder: (context) => Container(
        padding: AppTheme.paddingAllLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.scale, color: AppTheme.warning),
              ),
              title: Text(AppLocalizations.of(context).santeAjouterPesee),
              onTap: () {
                Navigator.pop(context);
                _ajouterPesee();
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.info.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.medical_services, color: AppTheme.info),
              ),
              title: Text(AppLocalizations.of(context).santeAjouterSoin),
              onTap: () {
                Navigator.pop(context);
                _ajouterSoin();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _ajouterPesee() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AjouterPeseeScreen(lapin: widget.lapin),
      ),
    ).then((_) => _chargerDonnees());
  }

  void _ajouterSoin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AjouterSoinScreen(lapin: widget.lapin)),
    ).then((_) => _chargerDonnees());
  }

  void _modifierPesee(Pesee pesee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPeseeScreen(lapin: widget.lapin, pesee: pesee),
      ),
    ).then((_) => _chargerDonnees());
  }

  void _modifierSoin(Soin soin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditSoinScreen(lapin: widget.lapin, soin: soin),
      ),
    ).then((_) => _chargerDonnees());
  }

  Future<void> _supprimerPesee(Pesee pesee) async {
    final confirm = await DialogHelper.showConfirmation(
      context: context,
      title: AppLocalizations.of(context).titleConfirmerSuppression,
      message: AppLocalizations.of(context).confirmSupprimerPesee,
      confirmLabel: AppLocalizations.of(context).btnSupprimer,
      isDangerous: true,
    );

    if (confirm == true && mounted) {
      final santeProvider = Provider.of<SanteProvider>(context, listen: false);
      await santeProvider.supprimerPesee(pesee.id!);
      _chargerDonnees();
    }
  }

  Future<void> _supprimerSoin(Soin soin) async {
    final confirm = await DialogHelper.showConfirmation(
      context: context,
      title: AppLocalizations.of(context).titleConfirmerSuppression,
      message: AppLocalizations.of(context).confirmSupprimerSoin,
      confirmLabel: AppLocalizations.of(context).btnSupprimer,
      isDangerous: true,
    );

    if (confirm == true && mounted) {
      final santeProvider = Provider.of<SanteProvider>(context, listen: false);
      await santeProvider.supprimerSoin(soin.id!);
      _chargerDonnees();
    }
  }
}
