import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../providers/preparation_nid_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../models/preparation_nid.dart';
import '../../theme/app_theme.dart';
import '../../widgets/materiau_selector.dart';
import '../../widgets/uniform_app_bar.dart';

class PreparationNidScreen extends StatefulWidget {
  const PreparationNidScreen({super.key});

  @override
  State<PreparationNidScreen> createState() => _PreparationNidScreenState();
}

class _PreparationNidScreenState extends State<PreparationNidScreen> {
  String _filtreType = 'tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PreparationNidProvider>().chargerPreparations();
      context.read<ReproductionProvider>().chargerAccouplements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniformAppBar(
        title: AppLocalizations.of(context).screenPreparationNid,
        icon: Icons.nest_cam_wired_stand_rounded,
        iconColor: AppTheme.accentBrown,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filtreType = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'tous',
                child: Text(AppLocalizations.of(context).filterTous),
              ),
              PopupMenuItem(
                value: 'avec_boite',
                child: Text(AppLocalizations.of(context).filterAvecBoite),
              ),
              PopupMenuItem(
                value: 'sans_boite',
                child: Text(AppLocalizations.of(context).filterSansBoite),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showAideDialog(context),
          ),
        ],
      ),
      body: Consumer3<PreparationNidProvider, ReproductionProvider, LapinProvider>(
        builder:
            (
              context,
              preparationProvider,
              reproProvider,
              lapinProvider,
              child,
            ) {
              if (preparationProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Filtrer
              List<PreparationNid> preparationsFiltrees = _filtreType == 'tous'
                  ? preparationProvider.preparations
                  : _filtreType == 'avec_boite'
                  ? preparationProvider.preparations
                        .where((p) => p.boiteNidInstallee)
                        .toList()
                  : preparationProvider.preparations
                        .where((p) => !p.boiteNidInstallee)
                        .toList();

              // Statistiques
              final tauxBoites = preparationProvider.getTauxNidsPrepares();

              return Column(
                children: [
                  // Statistiques
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange50,
                      border: Border(
                        bottom: BorderSide(color: AppTheme.borderLight),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Total',
                          '${preparationsFiltrees.length}',
                          Icons.format_list_numbered,
                          AppTheme.info,
                        ),
                        _buildStatCard(
                          'Avec boîte',
                          '${(tauxBoites ?? 0.0).toStringAsFixed(0)}%',
                          Icons.check_box,
                          AppTheme.success,
                        ),
                        _buildStatCard(
                          'À préparer',
                          '${preparationProvider.getNidsNonPrepares().length}',
                          Icons.pending_actions,
                          AppTheme.warning,
                        ),
                      ],
                    ),
                  ),

                  // Liste
                  Expanded(
                    child: preparationsFiltrees.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.home,
                                  size: 80,
                                  color: AppTheme.accentOrange200,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _filtreType == 'tous'
                                      ? 'Aucune préparation'
                                      : 'Aucune préparation $_filtreType',
                                  style: AppTheme.titleMedium.copyWith(
                                    color: AppTheme.neutral500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Appuyez sur + pour en ajouter',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.neutral500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: preparationsFiltrees.length,
                            itemBuilder: (context, index) {
                              final preparation = preparationsFiltrees[index];
                              final accouplement = reproProvider.accouplements
                                  .firstWhere(
                                    (a) => a.id == preparation.accouplementId,
                                    orElse: () =>
                                        reproProvider.accouplements.first,
                                  );
                              final femelle = lapinProvider.lapins.firstWhere(
                                (l) => l.id == accouplement.femelleId,
                                orElse: () => lapinProvider.lapins.first,
                              );
                              return _buildPreparationCard(
                                preparation,
                                femelle.nom,
                                accouplement.dateAccouplement,
                                accouplement.dateMiseBasPrevue,
                                preparationProvider,
                              );
                            },
                          ),
                  ),
                ],
              );
            },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_prep_nid',
        onPressed: () => _showAjouterPreparationDialog(context),
        backgroundColor: AppTheme.accentBrown,
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

  Widget _buildPreparationCard(
    PreparationNid preparation,
    String nomFemelle,
    DateTime dateAccouplement,
    DateTime dateMiseBasPrevue,
    PreparationNidProvider provider,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final joursDepuis = preparation.datePreparation
        .difference(dateAccouplement)
        .inDays;
    final auBonMoment = preparation.estAuBonMoment(dateAccouplement);
    final joursAvantMiseBas = dateMiseBasPrevue
        .difference(preparation.datePreparation)
        .inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: preparation.boiteNidInstallee
          ? AppTheme.success50
          : AppTheme.warning50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: preparation.boiteNidInstallee
              ? AppTheme.success300
              : AppTheme.warning300,
          width: 1.5,
        ),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: preparation.boiteNidInstallee
              ? AppTheme.success
              : AppTheme.warning,
          child: Icon(
            preparation.boiteNidInstallee ? Icons.check_box : Icons.home,
            color: AppTheme.textOnPrimary,
          ),
        ),
        title: Text(
          nomFemelle,
          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  preparation.boiteNidInstallee
                      ? Icons.check_circle
                      : Icons.pending,
                  size: 16,
                  color: preparation.boiteNidInstallee
                      ? AppTheme.success
                      : AppTheme.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  preparation.boiteNidInstallee
                      ? 'Boîte installée'
                      : 'Sans boîte',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: preparation.boiteNidInstallee
                        ? AppTheme.success700
                        : AppTheme.warning700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'J$joursDepuis • ${_getTypeMateriau(preparation.typeMateriau)} • ${dateFormat.format(preparation.datePreparation)}',
              style: AppTheme.caption.copyWith(color: AppTheme.neutral600),
            ),
            if (joursAvantMiseBas <= 3 && joursAvantMiseBas > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.info, size: 14, color: AppTheme.info),
                  const SizedBox(width: 4),
                  Text(
                    'Mise bas dans $joursAvantMiseBas jour(s)',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.info700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            if (!auBonMoment) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.warning_amber, size: 14, color: AppTheme.warning),
                  const SizedBox(width: 4),
                  Text(
                    'Hors période recommandée (J28)',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.warning700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'modifier') {
              _showModifierPreparationDialog(context, preparation);
            } else if (value == 'supprimer') {
              _confirmerSuppression(context, preparation);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'modifier',
              child: Row(
                children: [
                  const Icon(Icons.edit, color: AppTheme.info),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context).modifier),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'supprimer',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: AppTheme.error),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context).supprimer),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Date accouplement',
                  dateFormat.format(dateAccouplement),
                ),
                _buildInfoRow(
                  'Date préparation',
                  dateFormat.format(preparation.datePreparation),
                ),
                _buildInfoRow(
                  'Date mise bas prévue',
                  dateFormat.format(dateMiseBasPrevue),
                ),
                _buildInfoRow('Jour depuis accouplement', 'J$joursDepuis'),
                _buildInfoRow(
                  'Type de matériau',
                  _getTypeMateriau(preparation.typeMateriau),
                ),
                if (preparation.quantiteMateriau != null)
                  _buildInfoRow(
                    'Quantité de matériau',
                    '${preparation.quantiteMateriau} kg',
                  ),
                _buildInfoRow(
                  'Boîte à nid',
                  preparation.boiteNidInstallee
                      ? '✅ Installée'
                      : '❌ Non installée',
                ),
                if (preparation.dispositionNid != null &&
                    preparation.dispositionNid!.isNotEmpty)
                  _buildInfoRow('Disposition', preparation.dispositionNid!),
                if (preparation.temperatureAmbiance != null)
                  _buildInfoRow(
                    'Température ambiante',
                    '${preparation.temperatureAmbiance}°C',
                  ),
                if (preparation.observations != null &&
                    preparation.observations!.isNotEmpty)
                  _buildInfoRow('Observations', preparation.observations!),
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
            width: 150,
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

  String _getTypeMateriau(String type) {
    switch (type) {
      case 'paille':
        return 'Paille';
      case 'foin':
        return 'Foin';
      case 'copeaux':
        return 'Copeaux de bois';
      case 'mixte':
        return 'Mixte';
      default:
        return type;
    }
  }

  void _showAjouterPreparationDialog(BuildContext context) {
    final reproProvider = context.read<ReproductionProvider>();
    final accouplements = reproProvider.accouplements
        .where((a) => a.statut == 'confirme')
        .toList();

    if (accouplements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).msgAucunAccouplementDisponible,
          ),
        ),
      );
      return;
    }

    int? accouplementSelectionne;
    int? materiauId = 1; // Par défaut Paille (id=1)
    String typeMateriau = 'paille'; // Backward compatibility
    bool boiteNidInstallee = true;
    final quantiteController = TextEditingController();
    final dispositionController = TextEditingController();
    final temperatureController = TextEditingController();
    final observationsController = TextEditingController();
    DateTime datePreparation = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).titlePreparerNid),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: accouplementSelectionne,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).optimisationFormAccouplement,
                    border: const OutlineInputBorder(),
                  ),
                  items: accouplements.map((acc) {
                    final lapinProvider = context.read<LapinProvider>();
                    final femelle = lapinProvider.lapins.firstWhere(
                      (l) => l.id == acc.femelleId,
                    );
                    final joursDepuis = DateTime.now()
                        .difference(acc.dateAccouplement)
                        .inDays;
                    final joursAvantMiseBas = acc.dateMiseBasPrevue
                        .difference(DateTime.now())
                        .inDays;
                    return DropdownMenuItem(
                      value: acc.id,
                      child: Text(
                        '${femelle.nom} (J$joursDepuis - Mise bas J+$joursAvantMiseBas)',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => accouplementSelectionne = value),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    'Date: ${DateFormat('dd/MM/yyyy').format(datePreparation)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppTheme.neutral400),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: datePreparation,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 7),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => datePreparation = date);
                    }
                  },
                ),
                const SizedBox(height: 12),
                // Phase 4: Sélecteur matériau avec Radio buttons
                MateriauSelector(
                  materiauIdInitial: materiauId,
                  onMateriauSelected: (int? id, String? code) {
                    setState(() {
                      materiauId = id;
                      typeMateriau = code ?? 'paille';
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantiteController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantité de matériau (kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(AppLocalizations.of(context).switchBoiteNid),
                  subtitle: Text(
                    AppLocalizations.of(context).switchBoiteNidSubtitle,
                  ),
                  value: boiteNidInstallee,
                  onChanged: (value) =>
                      setState(() => boiteNidInstallee = value),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppTheme.neutral400),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dispositionController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).optimisationFormDispositionNid,
                    border: const OutlineInputBorder(),
                    helperText: AppLocalizations.of(context).helperExempleCoin,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: temperatureController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).optimisationFormTemperatureAmbiante,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: observationsController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).optimisationFormObservations,
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
                backgroundColor: AppTheme.accentBrown,
              ),
              onPressed: () {
                if (accouplementSelectionne == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez sélectionner un accouplement'),
                    ),
                  );
                  return;
                }

                final preparation = PreparationNid(
                  accouplementId: accouplementSelectionne!,
                  datePreparation: datePreparation,
                  typeMateriau: typeMateriau, // Backward compatibility STRING
                  materiauId: materiauId, // Phase 4: FK materiau_id
                  quantiteMateriau: quantiteController.text.isNotEmpty
                      ? double.parse(quantiteController.text)
                      : null,
                  boiteNidInstallee: boiteNidInstallee,
                  dispositionNid: dispositionController.text.isNotEmpty
                      ? dispositionController.text
                      : null,
                  temperatureAmbiance: temperatureController.text.isNotEmpty
                      ? double.parse(temperatureController.text)
                      : null,
                  observations: observationsController.text.isNotEmpty
                      ? observationsController.text
                      : null,
                );

                context.read<PreparationNidProvider>().ajouterPreparation(
                  preparation,
                );
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context).commonSave),
            ),
          ],
        ),
      ),
    );
  }

  void _showModifierPreparationDialog(
    BuildContext context,
    PreparationNid preparation,
  ) {
    int? materiauId = preparation.materiauId ?? 1; // Phase 4: Restaurer FK
    String typeMateriau = preparation.typeMateriau;
    bool boiteNidInstallee = preparation.boiteNidInstallee;
    final quantiteController = TextEditingController(
      text: preparation.quantiteMateriau?.toString() ?? '',
    );
    final dispositionController = TextEditingController(
      text: preparation.dispositionNid ?? '',
    );
    final temperatureController = TextEditingController(
      text: preparation.temperatureAmbiance?.toString() ?? '',
    );
    final observationsController = TextEditingController(
      text: preparation.observations ?? '',
    );
    DateTime datePreparation = preparation.datePreparation;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).commonEdit),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    'Date: ${DateFormat('dd/MM/yyyy').format(datePreparation)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppTheme.neutral400),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: datePreparation,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 60),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => datePreparation = date);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: typeMateriau,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).optimisationFormTypeMateriau,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'paille',
                      child: Text(AppLocalizations.of(context).materiauxPaille),
                    ),
                    DropdownMenuItem(
                      value: 'foin',
                      child: Text(AppLocalizations.of(context).materiauxFoin),
                    ),
                    DropdownMenuItem(
                      value: 'copeaux',
                      child: Text(
                        AppLocalizations.of(context).materiauxCopeaux,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'mixte',
                      child: Text(AppLocalizations.of(context).materiauxMixte),
                    ),
                  ],
                  onChanged: (value) => setState(() => typeMateriau = value!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantiteController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).optimisationFormQuantiteMateriau,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(AppLocalizations.of(context).switchBoiteNid),
                  value: boiteNidInstallee,
                  onChanged: (value) =>
                      setState(() => boiteNidInstallee = value),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppTheme.neutral400),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dispositionController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).optimisationFormDispositionNid,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: temperatureController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).optimisationFormTemperatureAmbiante,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: observationsController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).optimisationFormObservations,
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
              child: Text(AppLocalizations.of(context).actionAnnuler),
            ),
            ElevatedButton(
              onPressed: () {
                final preparationModifiee = preparation.copyWith(
                  datePreparation: datePreparation,
                  typeMateriau: typeMateriau, // Backward compatibility
                  materiauId: materiauId, // Phase 4: FK materiau_id
                  quantiteMateriau: quantiteController.text.isNotEmpty
                      ? double.parse(quantiteController.text)
                      : null,
                  boiteNidInstallee: boiteNidInstallee,
                  dispositionNid: dispositionController.text.isNotEmpty
                      ? dispositionController.text
                      : null,
                  temperatureAmbiance: temperatureController.text.isNotEmpty
                      ? double.parse(temperatureController.text)
                      : null,
                  observations: observationsController.text.isNotEmpty
                      ? observationsController.text
                      : null,
                );

                context.read<PreparationNidProvider>().modifierPreparation(
                  preparationModifiee,
                );
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context).commonEdit),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmerSuppression(BuildContext context, PreparationNid preparation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).commonConfirmDeletion),
        content: Text(AppLocalizations.of(context).commonDeleteQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              context.read<PreparationNidProvider>().supprimerPreparation(
                preparation.id!,
              );
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).supprimer),
          ),
        ],
      ),
    );
  }

  void _showAideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help, color: AppTheme.accentOrange700),
            const SizedBox(width: 8),
            const Text('Aide - Préparation du nid'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Quand préparer ?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Recommandé : J28 (3 jours avant la mise bas prévue)\n'
                '• Trop tôt : matériau peut être souillé\n'
                '• Trop tard : femelle stressée',
              ),
              const SizedBox(height: 16),
              const Text(
                'Matériaux recommandés',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Paille : propre, absorbante (recommandé)\n'
                '• Foin : doux mais moins absorbant\n'
                '• Copeaux : absorbants, éviter sciure fine\n'
                '• Mixte : combinaison optimale',
              ),
              const SizedBox(height: 16),
              const Text(
                'Boîte à nid',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Dimensions : 30×40×20 cm minimum\n'
                '• Matériau : bois non traité ou plastique\n'
                '• Position : coin calme de la cage\n'
                '• Accès facile pour la femelle',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.info50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.info200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: AppTheme.info700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'La femelle complétera le nid avec ses poils avant la mise bas',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
