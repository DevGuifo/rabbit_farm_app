import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        child: Column(
          children: [
            FicheSanteHeader(
              onBack: () => Navigator.pop(context),
              onRefresh: _chargerDonnees,
              onNotification: () {},
              onSettings: () {},
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _chargerDonnees,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [AppTheme.success, AppTheme.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.success.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _afficherMenuAjout,
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: Icon(Icons.add, size: 24, color: AppTheme.backgroundDark),
        label: Text(
          'Add Record',
          style: AppTheme.titleSmall.copyWith(color: AppTheme.backgroundDark),
        ),
      ),
    );
  }

  void _afficherMenuAjout() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
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
              title: const Text('Ajouter une pesée'),
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
              title: const Text('Ajouter un soin'),
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
      title: 'Confirmer la suppression',
      message: 'Voulez-vous vraiment supprimer cette pesée ?',
      confirmLabel: 'Supprimer',
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
      title: 'Confirmer la suppression',
      message: 'Voulez-vous vraiment supprimer ce soin ?',
      confirmLabel: 'Supprimer',
      isDangerous: true,
    );

    if (confirm == true && mounted) {
      final santeProvider = Provider.of<SanteProvider>(context, listen: false);
      await santeProvider.supprimerSoin(soin.id!);
      _chargerDonnees();
    }
  }
}
