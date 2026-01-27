import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../providers/palpation_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../models/palpation.dart';
import '../../models/enums/statut_accouplement.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class PalpationScreen extends StatefulWidget {
  const PalpationScreen({super.key});

  @override
  State<PalpationScreen> createState() => _PalpationScreenState();
}

class _PalpationScreenState extends State<PalpationScreen> {
  String _filtreResultat = 'tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PalpationProvider>().chargerPalpations();
      context.read<ReproductionProvider>().chargerAccouplements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(
        title: AppLocalizations.of(context).screenPalpation,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filtreResultat = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'tous',
                child: Text(AppLocalizations.of(context).filterTous),
              ),
              PopupMenuItem(
                value: 'gestante',
                child: Text(AppLocalizations.of(context).filterGestantes),
              ),
              PopupMenuItem(
                value: 'non_gestante',
                child: Text(AppLocalizations.of(context).filterNonGestantes),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showAideDialog(context),
          ),
        ],
      ),
      body: Consumer3<PalpationProvider, ReproductionProvider, LapinProvider>(
        builder:
            (context, palpationProvider, reproProvider, lapinProvider, child) {
              if (palpationProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Filtrer
              List<Palpation> palpationsFiltrees = _filtreResultat == 'tous'
                  ? palpationProvider.palpations
                  : _filtreResultat == 'gestante'
                  ? palpationProvider.palpations
                        .where((p) => p.gestante)
                        .toList()
                  : palpationProvider.palpations
                        .where((p) => !p.gestante)
                        .toList();

              // Statistiques
              final tauxReussite = palpationProvider.getTauxReussite();
              final nombreMoyenFoetus = palpationProvider
                  .getNombreMoyenFoetus();

              return Column(
                children: [
                  // Statistiques
                  Container(
                    padding: AppTheme.paddingAllMedium,
                    decoration: BoxDecoration(
                      color: AppTheme.warningLight,
                      border: Border(
                        bottom: BorderSide(color: AppTheme.borderLight),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Total',
                          '${palpationsFiltrees.length}',
                          Icons.format_list_numbered,
                          AppTheme.info,
                        ),
                        _buildStatCard(
                          'Taux réussite',
                          '${(tauxReussite ?? 0.0).toStringAsFixed(0)}%',
                          Icons.check_circle,
                          AppTheme.success,
                        ),
                        _buildStatCard(
                          'Moy. fœtus',
                          (nombreMoyenFoetus ?? 0.0).toStringAsFixed(1),
                          Icons.child_care,
                          AppTheme.warning,
                        ),
                      ],
                    ),
                  ),

                  // Liste
                  Expanded(
                    child: palpationsFiltrees.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pregnant_woman,
                                  size: 80,
                                  color: AppTheme.accentPink.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                AppTheme.verticalSpace16,
                                Text(
                                  _filtreResultat == 'tous'
                                      ? 'Aucune palpation'
                                      : 'Aucune palpation $_filtreResultat',
                                  style: AppTheme.titleMedium.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                AppTheme.verticalSpace8,
                                Text(
                                  'Appuyez sur + pour en ajouter',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: palpationsFiltrees.length,
                            itemBuilder: (context, index) {
                              final palpation = palpationsFiltrees[index];
                              final accouplement = reproProvider.accouplements
                                  .firstWhere(
                                    (a) => a.id == palpation.accouplementId,
                                    orElse: () =>
                                        reproProvider.accouplements.first,
                                  );
                              final femelle = lapinProvider.lapins.firstWhere(
                                (l) => l.id == accouplement.femelleId,
                                orElse: () => lapinProvider.lapins.first,
                              );
                              return _buildPalpationCard(
                                palpation,
                                femelle.nom,
                                accouplement.dateAccouplement,
                                palpationProvider,
                              );
                            },
                          ),
                  ),
                ],
              );
            },
      ),
      floatingActionButton: UnifiedFAB(
        onPressed: () => _showAjouterPalpationDialog(context),
        tooltip: '${AppLocalizations.of(context).commonAjouter} palpation',
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
          style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPalpationCard(
    Palpation palpation,
    String nomFemelle,
    DateTime dateAccouplement,
    PalpationProvider provider,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final joursDepuis = palpation.datePalpation
        .difference(dateAccouplement)
        .inDays;
    final dansPeriodeRecommandee = palpation.estDansPeriodeRecommandee(
      dateAccouplement,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: palpation.gestante
          ? AppTheme.success.withValues(alpha: 0.1)
          : AppTheme.error.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: palpation.gestante
              ? AppTheme.success.withValues(alpha: 0.5)
              : AppTheme.error.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: palpation.gestante
              ? AppTheme.success
              : AppTheme.error,
          child: Icon(
            palpation.gestante ? Icons.check : Icons.close,
            color: AppTheme.surfaceWhite,
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
                  palpation.gestante ? Icons.pregnant_woman : Icons.cancel,
                  size: 16,
                  color: palpation.gestante ? AppTheme.success : AppTheme.error,
                ),
                const SizedBox(width: 4),
                Text(
                  palpation.gestante ? 'Gestante' : 'Non gestante',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: palpation.gestante
                        ? AppTheme.success
                        : AppTheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'J$joursDepuis après accouplement • ${dateFormat.format(palpation.datePalpation)}',
              style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
            ),
            if (!dansPeriodeRecommandee) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.warning_amber, size: 14, color: AppTheme.warning),
                  const SizedBox(width: 4),
                  Text(
                    'Hors période recommandée (J10-J12)',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.warning,
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
              _showModifierPalpationDialog(context, palpation);
            } else if (value == 'supprimer') {
              _confirmerSuppression(context, palpation);
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
                  'Date palpation',
                  dateFormat.format(palpation.datePalpation),
                ),
                _buildInfoRow('Jour depuis accouplement', 'J$joursDepuis'),
                _buildInfoRow(
                  'Résultat',
                  palpation.gestante ? '✅ Gestante' : '❌ Non gestante',
                ),
                if (palpation.nombreFoetusPalpes != null)
                  _buildInfoRow(
                    'Nombre de fœtus palpés',
                    '${palpation.nombreFoetusPalpes}',
                  ),
                if (palpation.temperatureCorporelle != null)
                  _buildInfoRow(
                    'Température corporelle',
                    '${palpation.temperatureCorporelle}°C',
                  ),
                if (palpation.realisePar != null &&
                    palpation.realisePar!.isNotEmpty)
                  _buildInfoRow('Réalisé par', palpation.realisePar!),
                if (palpation.observations != null &&
                    palpation.observations!.isNotEmpty)
                  _buildInfoRow('Observations', palpation.observations!),
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
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  void _showAjouterPalpationDialog(BuildContext context) {
    final reproProvider = context.read<ReproductionProvider>();
    final accouplements = reproProvider.accouplements
        .where((a) => a.statut == StatutAccouplement.confirme || a.statut == StatutAccouplement.enAttente)
        .toList();

    if (accouplements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).emptyAucunAccouplement),
        ),
      );
      return;
    }

    int? accouplementSelectionne;
    bool gestante = false;
    final nombreFoetusController = TextEditingController();
    final temperatureController = TextEditingController();
    final realiseParController = TextEditingController();
    final observationsController = TextEditingController();
    DateTime datePalpation = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).titleEnregistrerPalpation),
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
                    return DropdownMenuItem(
                      value: acc.id,
                      child: Text(
                        '${femelle.nom} (J$joursDepuis - ${DateFormat('dd/MM').format(acc.dateAccouplement)})',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => accouplementSelectionne = value),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    'Date: ${DateFormat('dd/MM/yyyy').format(datePalpation)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.borderRadiusSmall,
                    side: BorderSide(color: AppTheme.borderLight),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: datePalpation,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => datePalpation = date);
                    }
                  },
                ),
                AppTheme.verticalSpace12,
                SwitchListTile(
                  title: Text(AppLocalizations.of(context).switchGestante),
                  subtitle: Text(
                    AppLocalizations.of(context).switchGesteQuestion,
                  ),
                  value: gestante,
                  onChanged: (value) => setState(() => gestante = value),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.borderRadiusSmall,
                    side: BorderSide(color: AppTheme.borderLight),
                  ),
                ),
                if (gestante) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: nombreFoetusController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      ).optimisationFormNombreFoetus,
                      border: const OutlineInputBorder(),
                      helperText: AppLocalizations.of(
                        context,
                      ).helperEstimationPossible,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: temperatureController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).optimisationFormTemperatureCorporelle,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: realiseParController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).optimisationFormRealisepar,
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
                backgroundColor: AppTheme.warning,
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

                final palpation = Palpation(
                  accouplementId: accouplementSelectionne!,
                  datePalpation: datePalpation,
                  gestante: gestante,
                  nombreFoetusPalpes: nombreFoetusController.text.isNotEmpty
                      ? int.parse(nombreFoetusController.text)
                      : null,
                  temperatureCorporelle: temperatureController.text.isNotEmpty
                      ? double.parse(temperatureController.text)
                      : null,
                  realisePar: realiseParController.text.isNotEmpty
                      ? realiseParController.text
                      : null,
                  observations: observationsController.text.isNotEmpty
                      ? observationsController.text
                      : null,
                );

                context.read<PalpationProvider>().ajouterPalpation(palpation);
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context).commonSave),
            ),
          ],
        ),
      ),
    );
  }

  void _showModifierPalpationDialog(BuildContext context, Palpation palpation) {
    bool gestante = palpation.gestante;
    final nombreFoetusController = TextEditingController(
      text: palpation.nombreFoetusPalpes?.toString() ?? '',
    );
    final temperatureController = TextEditingController(
      text: palpation.temperatureCorporelle?.toString() ?? '',
    );
    final realiseParController = TextEditingController(
      text: palpation.realisePar ?? '',
    );
    final observationsController = TextEditingController(
      text: palpation.observations ?? '',
    );
    DateTime datePalpation = palpation.datePalpation;

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
                    'Date: ${DateFormat('dd/MM/yyyy').format(datePalpation)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.borderRadiusSmall,
                    side: BorderSide(color: AppTheme.borderLight),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: datePalpation,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 90),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => datePalpation = date);
                    }
                  },
                ),
                AppTheme.verticalSpace12,
                SwitchListTile(
                  title: Text(AppLocalizations.of(context).switchGestante),
                  value: gestante,
                  onChanged: (value) => setState(() => gestante = value),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.borderRadiusSmall,
                    side: BorderSide(color: AppTheme.borderLight),
                  ),
                ),
                if (gestante) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: nombreFoetusController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      ).optimisationFormNombreFoetus,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: temperatureController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).optimisationFormTemperatureCorporelle,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: realiseParController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(
                      context,
                    ).optimisationFormRealisepar,
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
                final palpationModifiee = palpation.copyWith(
                  datePalpation: datePalpation,
                  gestante: gestante,
                  nombreFoetusPalpes: nombreFoetusController.text.isNotEmpty
                      ? int.parse(nombreFoetusController.text)
                      : null,
                  temperatureCorporelle: temperatureController.text.isNotEmpty
                      ? double.parse(temperatureController.text)
                      : null,
                  realisePar: realiseParController.text.isNotEmpty
                      ? realiseParController.text
                      : null,
                  observations: observationsController.text.isNotEmpty
                      ? observationsController.text
                      : null,
                );

                context.read<PalpationProvider>().modifierPalpation(
                  palpationModifiee,
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

  Future<void> _confirmerSuppression(
    BuildContext context,
    Palpation palpation,
  ) async {
    final confirmed = await DialogHelper.showConfirmation(
      context: context,
      title: AppLocalizations.of(context).commonConfirmDeletion,
      message: AppLocalizations.of(context).commonDeleteQuestion,
      isDangerous: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<PalpationProvider>().supprimerPalpation(palpation.id!);
    }
  }

  void _showAideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help, color: AppTheme.warning),
            AppTheme.horizontalSpace8,
            Text(AppLocalizations.of(context).aidePalpation),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quand palper ?',
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              AppTheme.verticalSpace8,
              const Text(
                '• Période recommandée : J10 à J12 après l\'accouplement\n'
                '• Avant J10 : trop tôt, fœtus non palpables\n'
                '• Après J12 : risque de stress pour la femelle',
              ),
              AppTheme.verticalSpace16,
              Text(
                'Comment palper ?',
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Manipulez délicatement la femelle\n'
                '• Placez une main sous le ventre\n'
                '• Palpez doucement avec l\'autre main\n'
                '• Les fœtus ressemblent à des petites billes',
              ),
              const SizedBox(height: 16),
              Container(
                padding: AppTheme.paddingAllMedium,
                decoration: AppTheme.statusDecoration(AppTheme.warning),
                child: Row(
                  children: [
                    Icon(Icons.info, color: AppTheme.warning),
                    AppTheme.horizontalSpace8,
                    Expanded(
                      child: Text(
                        'Si vous n\'êtes pas sûr, consultez un vétérinaire ou un éleveur expérimenté',
                        style: AppTheme.bodySmall,
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
            child: Text(AppLocalizations.of(context).fermer),
          ),
        ],
      ),
    );
  }
}
