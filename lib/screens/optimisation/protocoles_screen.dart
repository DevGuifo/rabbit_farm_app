import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/protocole_soin.dart';
import '../../providers/protocole_soin_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/snackbar_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import '../../l10n/app_localizations.dart';

/// Écran de gestion des protocoles de soin
class ProtocolesScreen extends StatefulWidget {
  const ProtocolesScreen({super.key});

  @override
  State<ProtocolesScreen> createState() => _ProtocolesScreenState();
}

class _ProtocolesScreenState extends State<ProtocolesScreen> {
  String _filtreType = 'tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProtocoleSoinProvider>().chargerProtocoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(
        title: AppLocalizations.of(context).screenProtocolesSoin,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _filtreType = value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'tous',
                child: Text(AppLocalizations.of(context).filterTous),
              ),
              PopupMenuItem(
                value: 'vaccination',
                child: Text(AppLocalizations.of(context).typeVaccination),
              ),
              PopupMenuItem(
                value: 'traitement',
                child: Text(AppLocalizations.of(context).typeTraitement),
              ),
              PopupMenuItem(
                value: 'prevention',
                child: Text(AppLocalizations.of(context).typePrevention),
              ),
              PopupMenuItem(
                value: 'routine',
                child: Text(AppLocalizations.of(context).typeRoutine),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ProtocoleSoinProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<ProtocoleSoin> protocoles;
          if (_filtreType == 'tous') {
            protocoles = provider.protocoles;
          } else {
            protocoles = provider.getProtocolesParType(_filtreType);
          }

          if (protocoles.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              _buildStatistiques(provider),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: protocoles.length,
                  itemBuilder: (context, index) {
                    final protocole = protocoles[index];
                    return _buildProtocoleCard(context, protocole);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: UnifiedFAB.extended(
        onPressed: () => _ajouterProtocole(context),
        label: AppLocalizations.of(context).labelNouveauProtocole,
        icon: Icons.add,
        tooltip: AppLocalizations.of(context).labelNouveauProtocole,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: AppTheme.neutral400,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).emptyAucunProtocole,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Créez des protocoles de soin réutilisables',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.neutral600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistiques(ProtocoleSoinProvider provider) {
    final stats = provider.getRepartitionActivite();
    final coutTotal = provider.getCoutTotalProtocolesActifs();

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.accentPurple50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            icon: Icons.check_circle,
            label: AppLocalizations.of(context).labelActifs,
            value: stats['actifs'].toString(),
            color: AppTheme.success,
          ),
          _buildStatCard(
            icon: Icons.cancel,
            label: AppLocalizations.of(context).labelInactifs,
            value: stats['inactifs'].toString(),
            color: AppTheme.neutral500,
          ),
          _buildStatCard(
            icon: Icons.euro,
            label: AppLocalizations.of(context).labelCoutTotal,
            value: '${coutTotal.toStringAsFixed(0)}€',
            color: AppTheme.accentPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.titleLarge.copyWith(color: color)),
        Text(
          label,
          style: AppTheme.caption.copyWith(color: AppTheme.neutral500),
        ),
      ],
    );
  }

  Widget _buildProtocoleCard(BuildContext context, ProtocoleSoin protocole) {
    Color typeColor;
    IconData typeIcon;

    switch (protocole.type) {
      case 'vaccination':
        typeColor = AppTheme.info;
        typeIcon = Icons.vaccines;
        break;
      case 'traitement':
        typeColor = AppTheme.error;
        typeIcon = Icons.medication;
        break;
      case 'prevention':
        typeColor = AppTheme.success;
        typeIcon = Icons.shield;
        break;
      case 'routine':
        typeColor = AppTheme.warning;
        typeIcon = Icons.schedule;
        break;
      default:
        typeColor = AppTheme.neutral500;
        typeIcon = Icons.medical_services;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor.withValues(alpha: 0.2),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(
          protocole.nom,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            decoration: protocole.actif ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              protocole.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(protocole.type),
                  backgroundColor: typeColor.withValues(alpha: 0.1),
                  labelStyle: AppTheme.caption.copyWith(
                    fontSize: 11,
                    color: typeColor,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text(protocole.frequence),
                  visualDensity: VisualDensity.compact,
                  labelStyle: AppTheme.bodyMedium.copyWith(fontSize: 11),
                ),
                if (protocole.coutEstime != null)
                  Chip(
                    label: Text('${protocole.coutEstime!.toStringAsFixed(0)}€'),
                    visualDensity: VisualDensity.compact,
                    labelStyle: AppTheme.bodyMedium.copyWith(fontSize: 11),
                  ),
              ],
            ),
          ],
        ),
        trailing: Switch(
          value: protocole.actif,
          onChanged: (value) {
            context.read<ProtocoleSoinProvider>().toggleActif(protocole.id!);
          },
        ),
        onTap: () => _modifierProtocole(context, protocole),
      ),
    );
  }

  Future<void> _ajouterProtocole(BuildContext context) async {
    await _showProtocoleForm(context, null);
  }

  Future<void> _modifierProtocole(
    BuildContext context,
    ProtocoleSoin protocole,
  ) async {
    await _showProtocoleForm(context, protocole);
  }

  Future<void> _showProtocoleForm(
    BuildContext context,
    ProtocoleSoin? protocole,
  ) async {
    final formKey = GlobalKey<FormState>();
    final nomController = TextEditingController(text: protocole?.nom ?? '');
    final descriptionController = TextEditingController(
      text: protocole?.description ?? '',
    );
    final frequenceController = TextEditingController(
      text: protocole?.frequence ?? '',
    );
    final medicamentsController = TextEditingController(
      text: protocole?.medicamentsNecessaires.join(', ') ?? '',
    );
    final lapinsController = TextEditingController(
      text: protocole?.lapinsConcernes ?? 'tous',
    );
    final coutController = TextEditingController(
      text: protocole?.coutEstime?.toString() ?? '',
    );
    final instructionsController = TextEditingController(
      text: protocole?.instructions ?? '',
    );

    String selectedType = protocole?.type ?? 'routine';
    bool actif = protocole?.actif ?? true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            protocole == null
                ? AppLocalizations.of(context).labelNouveauProtocole
                : AppLocalizations.of(context).btnModifier,
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nomController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      ).optimisationFormNomProtocole,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty
                        ? AppLocalizations.of(context).validationNomRequis
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      ).optimisationFormType,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'vaccination',
                        child: Text(
                          AppLocalizations.of(context).typeVaccination,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'traitement',
                        child: Text(
                          AppLocalizations.of(context).typeTraitement,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'prevention',
                        child: Text(
                          AppLocalizations.of(context).typePrevention,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'routine',
                        child: Text(AppLocalizations.of(context).typeRoutine),
                      ),
                    ],
                    onChanged: (value) => setState(() => selectedType = value!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      ).optimisationFormDescription,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty
                        ? AppLocalizations.of(
                            context,
                          ).validationDescriptionRequise
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: frequenceController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      ).optimisationFormFrequence,
                      border: const OutlineInputBorder(),
                      hintText: AppLocalizations.of(context).hintExTous3Mois,
                    ),
                    validator: (v) => v!.isEmpty
                        ? AppLocalizations.of(
                            context,
                          ).validationFrequenceRequise
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: medicamentsController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      ).optimisationFormMedicaments,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty
                        ? AppLocalizations.of(
                            context,
                          ).validationMedicamentsRequis
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: lapinsController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      ).optimisationFormLapinsConcernes,
                      border: const OutlineInputBorder(),
                      hintText: AppLocalizations.of(
                        context,
                      ).hintTousAdultesLapereaux,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: coutController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      ).optimisationFormCoutEstime,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: instructionsController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      ).optimisationFormInstructions,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(
                      AppLocalizations.of(context).switchProtocoleActif,
                    ),
                    value: actif,
                    onChanged: (value) => setState(() => actif = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).commonCancel),
            ),
            if (protocole != null)
              TextButton(
                onPressed: () async {
                  final confirmed = await DialogHelper.showConfirmation(
                    context: context,
                    title: AppLocalizations.of(context).titleSupprimerProtocole,
                    message: 'Cette action est irréversible.',
                    isDangerous: true,
                  );
                  if (confirmed == true && context.mounted) {
                    await context
                        .read<ProtocoleSoinProvider>()
                        .supprimerProtocole(protocole.id!);
                    if (context.mounted) {
                      Navigator.pop(context);
                      SnackbarHelper.showSuccess(context, 'Protocole supprimé');
                    }
                  }
                },
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: AppTheme.error),
                ),
              ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final medicaments = medicamentsController.text
                      .split(',')
                      .map((m) => m.trim())
                      .where((m) => m.isNotEmpty)
                      .toList();

                  final nouveauProtocole = ProtocoleSoin(
                    id: protocole?.id,
                    nom: nomController.text,
                    description: descriptionController.text,
                    type: selectedType,
                    frequence: frequenceController.text,
                    medicamentsNecessaires: medicaments,
                    lapinsConcernes: lapinsController.text.isNotEmpty
                        ? lapinsController.text
                        : null,
                    coutEstime: coutController.text.isNotEmpty
                        ? double.tryParse(coutController.text)
                        : null,
                    instructions: instructionsController.text.isNotEmpty
                        ? instructionsController.text
                        : null,
                    actif: actif,
                  );

                  try {
                    if (protocole == null) {
                      await context
                          .read<ProtocoleSoinProvider>()
                          .ajouterProtocole(nouveauProtocole);
                    } else {
                      await context
                          .read<ProtocoleSoinProvider>()
                          .modifierProtocole(nouveauProtocole);
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            protocole == null
                                ? 'Protocole créé'
                                : 'Protocole modifié',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: $e'),
                          backgroundColor: AppTheme.error,
                        ),
                      );
                    }
                  }
                }
              },
              child: Text(
                protocole == null
                    ? AppLocalizations.of(context).ajouter
                    : AppLocalizations.of(context).modifier,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
