import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../providers/reforme_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../models/reforme.dart';
import '../../models/enums/reforme_enums.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';

class ReformeScreen extends StatefulWidget {
  const ReformeScreen({super.key});

  @override
  State<ReformeScreen> createState() => _ReformeScreenState();
}

class _ReformeScreenState extends State<ReformeScreen> {
  String _filtreMotif = 'tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReformeProvider>().chargerReformes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniformAppBar(
        title: AppLocalizations.of(context).screenReforme,
        icon: Icons.logout_rounded,
        iconColor: AppTheme.textSecondary,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filtreMotif = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'tous',
                child: Text(AppLocalizations.of(context).filterTous),
              ),
              PopupMenuItem(
                value: 'age',
                child: Text(AppLocalizations.of(context).motifAge),
              ),
              PopupMenuItem(
                value: 'improductif',
                child: Text(AppLocalizations.of(context).motifImproductif),
              ),
              PopupMenuItem(
                value: 'maladie',
                child: Text(AppLocalizations.of(context).motifMaladie),
              ),
              PopupMenuItem(
                value: 'genetique',
                child: Text(AppLocalizations.of(context).motifGenetique),
              ),
              PopupMenuItem(
                value: 'comportement',
                child: Text(AppLocalizations.of(context).motifComportement),
              ),
            ],
          ),
        ],
      ),
      body: Consumer3<ReformeProvider, LapinProvider, ReproductionProvider>(
        builder: (context, reformeProvider, lapinProvider, reproProvider, child) {
          if (reformeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filtrer
          List<Reforme> reformesFiltrees = _filtreMotif == 'tous'
              ? reformeProvider.reformes
              : reformeProvider.reformes
                    .where((r) => r.motif.value == _filtreMotif)
                    .toList();

          // Statistiques
          final total = reformesFiltrees.length;
          final revenusTotal = reformeProvider.getRevenusTotal();

          return Column(
            children: [
              // Statistiques
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.infoGrey50,
                  border: Border(
                    bottom: BorderSide(color: AppTheme.borderLight),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      AppLocalizations.of(context).commonTotal,
                      '$total',
                      Icons.format_list_numbered,
                      AppTheme.info,
                    ),
                    _buildStatCard(
                      'Ce mois',
                      '${reformeProvider.getReformesParPeriode(30).length}',
                      Icons.calendar_month,
                      AppTheme.warning,
                    ),
                    _buildStatCard(
                      'Revenus',
                      '${revenusTotal.toStringAsFixed(0)}€',
                      Icons.euro,
                      AppTheme.success,
                    ),
                  ],
                ),
              ),

              // Liste
              Expanded(
                child: reformesFiltrees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.trending_down,
                              size: 80,
                              color: AppTheme.infoGrey200,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _filtreMotif == 'tous'
                                  ? 'Aucune réforme'
                                  : 'Aucune réforme pour motif $_filtreMotif',
                              style: AppTheme.bodyMedium.copyWith(
                                fontSize: 18,
                                color: AppTheme.neutral500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Appuyez sur + pour en ajouter',
                              style: TextStyle(color: AppTheme.neutral500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: reformesFiltrees.length,
                        itemBuilder: (context, index) {
                          final reforme = reformesFiltrees[index];
                          final lapin = lapinProvider.lapins.firstWhere(
                            (l) => l.id == reforme.lapinId,
                            orElse: () => lapinProvider.lapins.first,
                          );
                          return _buildReformeCard(
                            reforme,
                            lapin.nom,
                            reproProvider,
                            reformeProvider,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_reforme',
        onPressed: () => _showAjouterReformeDialog(context),
        backgroundColor: AppTheme.textSecondary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.titleLarge.copyWith(color: color)),
        Text(
          label,
          style: AppTheme.caption.copyWith(color: AppTheme.neutral600),
        ),
      ],
    );
  }

  Widget _buildReformeCard(
    Reforme reforme,
    String nomLapin,
    ReproductionProvider reproProvider,
    ReformeProvider reformeProvider,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Calculer le bilan de carrière
    final accouplements = reproProvider.accouplements
        .where((a) => a.femelleId == reforme.lapinId)
        .toList();
    final portees = reproProvider.portees
        .where((p) => accouplements.any((a) => a.id == p.accouplementId))
        .toList();
    final totalPortees = portees.length;
    final totalLapereaux = portees.fold<int>(
      0,
      (sum, portee) => sum + portee.nombreVivants,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.borderLight, width: 1),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getMotifColor(reforme.motif),
          child: Icon(
            _getMotifIcon(reforme.motif),
            color: AppTheme.textOnPrimary,
          ),
        ),
        title: Text(
          nomLapin,
          style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${_getMotifLabel(reforme.motif)} • ${dateFormat.format(reforme.dateReforme)}',
              style: AppTheme.caption.copyWith(color: AppTheme.neutral600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: AppTheme.neutral600),
                const SizedBox(width: 4),
                Text(
                  _getDestinationLabel(reforme.destination),
                  style: AppTheme.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.infoGrey700,
                  ),
                ),
                if (reforme.prixVente != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${reforme.prixVente!.toStringAsFixed(2)} €',
                    style: AppTheme.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.success,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: AppTheme.neutral500),
          onPressed: () => _confirmerSuppression(context, reforme),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bilan de carrière
                if (totalPortees > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.info50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.info200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.assessment, color: AppTheme.info700),
                            const SizedBox(width: 8),
                            Text(
                              'Bilan de carrière',
                              style: AppTheme.titleSmall.copyWith(
                                color: AppTheme.info900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '$totalPortees',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.info700,
                                  ),
                                ),
                                Text(
                                  'Portées',
                                  style: AppTheme.caption.copyWith(
                                    color: AppTheme.neutral600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '$totalLapereaux',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.success700,
                                  ),
                                ),
                                Text(
                                  'Lapereaux nés',
                                  style: AppTheme.caption.copyWith(
                                    color: AppTheme.neutral600,
                                  ),
                                ),
                              ],
                            ),
                            if (totalPortees > 0)
                              Column(
                                children: [
                                  Text(
                                    (totalLapereaux / totalPortees)
                                        .toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.warning700,
                                    ),
                                  ),
                                  Text(
                                    'Moy./portée',
                                    style: AppTheme.caption.copyWith(
                                      color: AppTheme.neutral600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Informations détaillées
                _buildInfoRow('Motif', _getMotifLabel(reforme.motif)),
                _buildInfoRow(
                  'Destination',
                  _getDestinationLabel(reforme.destination),
                ),
                _buildInfoRow('Date', dateFormat.format(reforme.dateReforme)),
                if (reforme.poidsVif != null)
                  _buildInfoRow('Poids vif', '${reforme.poidsVif} g'),
                if (reforme.prixVente != null)
                  _buildInfoRow(
                    'Prix vente',
                    '${reforme.prixVente!.toStringAsFixed(2)} €',
                  ),
                if (reforme.notes != null && reforme.notes!.isNotEmpty)
                  _buildInfoRow('Notes', reforme.notes!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMotifColor(MotifReforme motif) {
    switch (motif) {
      case MotifReforme.age:
        return AppTheme.neutral500;
      case MotifReforme.improductif:
        return AppTheme.warning;
      case MotifReforme.maladie:
        return AppTheme.error;
      case MotifReforme.genetique:
        return AppTheme.accentPurple;
      case MotifReforme.comportement:
        return AppTheme.accentOrange;
      case MotifReforme.autre:
        return AppTheme.infoGrey;
    }
  }

  IconData _getMotifIcon(MotifReforme motif) {
    switch (motif) {
      case MotifReforme.age:
        return Icons.cake;
      case MotifReforme.improductif:
        return Icons.trending_down;
      case MotifReforme.maladie:
        return Icons.local_hospital;
      case MotifReforme.genetique:
        return Icons.science;
      case MotifReforme.comportement:
        return Icons.psychology;
      case MotifReforme.autre:
        return Icons.info;
    }
  }

  String _getMotifLabel(MotifReforme motif) {
    return motif.label;
  }

  String _getDestinationLabel(DestinationReforme destination) {
    return destination.label;
  }

  void _showAjouterReformeDialog(BuildContext context) {
    final lapinProvider = context.read<LapinProvider>();
    int? lapinSelectionne;
    String motif = 'age';
    String destination = 'vente';
    final poidsController = TextEditingController();
    final prixController = TextEditingController();
    final notesController = TextEditingController();
    DateTime dateReforme = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).titleReformerLapin),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: lapinSelectionne,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).rentabiliteFormLapin,
                    border: const OutlineInputBorder(),
                  ),
                  items: lapinProvider.lapins.map((lapin) {
                    return DropdownMenuItem(
                      value: lapin.id,
                      child: Text('${lapin.nom} (${lapin.sexe})'),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => lapinSelectionne = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: motif,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).rentabiliteFormMotif,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'age',
                      child: Text(AppLocalizations.of(context).motifAge),
                    ),
                    DropdownMenuItem(
                      value: 'improductif',
                      child: Text(
                        AppLocalizations.of(context).motifImproductif,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'maladie',
                      child: Text(AppLocalizations.of(context).motifMaladie),
                    ),
                    DropdownMenuItem(
                      value: 'genetique',
                      child: Text(AppLocalizations.of(context).motifGenetique),
                    ),
                    DropdownMenuItem(
                      value: 'comportement',
                      child: Text(
                        AppLocalizations.of(context).motifComportement,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'autre',
                      child: Text(AppLocalizations.of(context).typeAutre),
                    ),
                  ],
                  onChanged: (value) => setState(() => motif = value!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: destination,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).rentabiliteFormDestination,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'vente',
                      child: Text(
                        AppLocalizations.of(context).destinationVente,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'abattage',
                      child: Text(
                        AppLocalizations.of(context).destinationAbattage,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'don',
                      child: Text(AppLocalizations.of(context).destinationDon),
                    ),
                    DropdownMenuItem(
                      value: 'autre',
                      child: Text(AppLocalizations.of(context).typeAutre),
                    ),
                  ],
                  onChanged: (value) => setState(() => destination = value!),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    'Date: ${DateFormat('dd/MM/yyyy').format(dateReforme)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppTheme.neutral400),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: dateReforme,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 90),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => dateReforme = date);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: poidsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).rentabiliteFormPoidsVif,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: prixController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).rentabiliteFormPrixVente,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).rentabiliteFormNotes,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).commonCancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.textSecondary,
              ),
              onPressed: () {
                if (lapinSelectionne == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez sélectionner un lapin'),
                    ),
                  );
                  return;
                }

                final reforme = Reforme(
                  lapinId: lapinSelectionne!,
                  dateReforme: dateReforme,
                  motif: MotifReforme.fromString(motif),
                  destination: DestinationReforme.fromString(destination),
                  poidsVif: poidsController.text.isNotEmpty
                      ? double.parse(poidsController.text)
                      : null,
                  prixVente: prixController.text.isNotEmpty
                      ? double.parse(prixController.text)
                      : null,
                  notes: notesController.text.isNotEmpty
                      ? notesController.text
                      : null,
                );

                context.read<ReformeProvider>().ajouterReforme(reforme);
                Navigator.pop(context);
              },
              child: const Text('Réformer'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmerSuppression(BuildContext context, Reforme reforme) async {
    final confirm = await DialogHelper.showConfirmation(
      context: context,
      title: AppLocalizations.of(context).titleConfirmerSuppression,
      message: 'Supprimer cette réforme ?',
      isDangerous: true,
    );

    if (confirm == true && context.mounted) {
      context.read<ReformeProvider>().supprimerReforme(reforme.id!);
    }
  }
}
