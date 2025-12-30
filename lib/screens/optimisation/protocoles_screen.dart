import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/protocole_soin.dart';
import '../../providers/protocole_soin_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/snackbar_helper.dart';
import '../../theme/app_theme.dart';

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
      appBar: AppBar(
        title: const Text('Protocoles de soin'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _filtreType = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'tous', child: Text('Tous')),
              const PopupMenuItem(
                value: 'vaccination',
                child: Text('Vaccination'),
              ),
              const PopupMenuItem(
                value: 'traitement',
                child: Text('Traitement'),
              ),
              const PopupMenuItem(
                value: 'prevention',
                child: Text('Prévention'),
              ),
              const PopupMenuItem(value: 'routine', child: Text('Routine')),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ajouterProtocole(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau protocole'),
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
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun protocole',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Créez des protocoles de soin réutilisables',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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
      color: Colors.purple[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            icon: Icons.check_circle,
            label: 'Actifs',
            value: stats['actifs'].toString(),
            color: Colors.green,
          ),
          _buildStatCard(
            icon: Icons.cancel,
            label: 'Inactifs',
            value: stats['inactifs'].toString(),
            color: Colors.grey,
          ),
          _buildStatCard(
            icon: Icons.euro,
            label: 'Coût total',
            value: '${coutTotal.toStringAsFixed(0)}€',
            color: Colors.purple,
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
        Text(
          value,
          style: AppTheme.titleLarge.copyWith(
            color: color,
          ),
        ),
        Text(label, style: AppTheme.caption.copyWith(color: Colors.grey)),
      ],
    );
  }

  Widget _buildProtocoleCard(BuildContext context, ProtocoleSoin protocole) {
    Color typeColor;
    IconData typeIcon;

    switch (protocole.type) {
      case 'vaccination':
        typeColor = Colors.blue;
        typeIcon = Icons.vaccines;
        break;
      case 'traitement':
        typeColor = Colors.red;
        typeIcon = Icons.medication;
        break;
      case 'prevention':
        typeColor = Colors.green;
        typeIcon = Icons.shield;
        break;
      case 'routine':
        typeColor = Colors.orange;
        typeIcon = Icons.schedule;
        break;
      default:
        typeColor = Colors.grey;
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
                  labelStyle: AppTheme.caption.copyWith(fontSize: 11, color: typeColor),
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
            protocole == null ? 'Nouveau protocole' : 'Modifier protocole',
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du protocole *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Nom requis' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue:  selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'vaccination',
                        child: Text('Vaccination'),
                      ),
                      DropdownMenuItem(
                        value: 'traitement',
                        child: Text('Traitement'),
                      ),
                      DropdownMenuItem(
                        value: 'prevention',
                        child: Text('Prévention'),
                      ),
                      DropdownMenuItem(
                        value: 'routine',
                        child: Text('Routine'),
                      ),
                    ],
                    onChanged: (value) => setState(() => selectedType = value!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description *',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Description requise' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: frequenceController,
                    decoration: const InputDecoration(
                      labelText: 'Fréquence *',
                      border: OutlineInputBorder(),
                      hintText: 'Ex: Tous les 3 mois',
                    ),
                    validator: (v) => v!.isEmpty ? 'Fréquence requise' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: medicamentsController,
                    decoration: const InputDecoration(
                      labelText: 'Médicaments (séparés par virgule) *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Médicaments requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: lapinsController,
                    decoration: const InputDecoration(
                      labelText: 'Lapins concernés',
                      border: OutlineInputBorder(),
                      hintText: 'tous, adultes, lapereaux, etc.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: coutController,
                    decoration: const InputDecoration(
                      labelText: 'Coût estimé (€)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Instructions',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Protocole actif'),
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
              child: const Text('Annuler'),
            ),
            if (protocole != null)
              TextButton(
                onPressed: () async {
                  final confirmed = await DialogHelper.showConfirmation(
                    context: context,
                    title: 'Supprimer ce protocole ?',
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
                  style: TextStyle(color: Colors.red),
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
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: Text(protocole == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        ),
      ),
    );
  }
}
