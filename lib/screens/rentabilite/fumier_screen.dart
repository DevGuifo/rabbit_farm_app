import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/fumier_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/snackbar_helper.dart';
import '../../models/collecte_fumier.dart';

class FumierScreen extends StatefulWidget {
  const FumierScreen({super.key});

  @override
  State<FumierScreen> createState() => _FumierScreenState();
}

class _FumierScreenState extends State<FumierScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FumierProvider>().chargerCollectes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion du Fumier'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FumierProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.collectes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco, size: 80, color: Colors.brown[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune collecte enregistrée',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Appuyez sur + pour en ajouter',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.collectes.length,
            itemBuilder: (context, index) {
              final collecte = provider.collectes[index];
              return _buildCollecteCard(collecte);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAjouterCollecteDialog(context),
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCollecteCard(CollecteFumier collecte) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(collecte.type),
          child: Icon(_getTypeIcon(collecte.type), color: Colors.white),
        ),
        title: Text(
          '${collecte.quantite} kg - ${_getTypeLabel(collecte.type)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(collecte.dateCollecte)),
            if (collecte.destination != null)
              Text(
                'Destination: ${_getDestinationLabel(collecte.destination!)}',
              ),
            if (collecte.prixVente != null)
              Text(
                'Vendu: ${collecte.prixVente!.toStringAsFixed(2)} €',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDelete(collecte),
        ),
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'crottes':
        return 'Crottes';
      case 'urine':
        return 'Urine';
      case 'mixte':
        return 'Mixte';
      default:
        return type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'crottes':
        return Colors.brown;
      case 'urine':
        return Colors.amber[800]!;
      case 'mixte':
        return Colors.brown[700]!;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'crottes':
        return Icons.eco;
      case 'urine':
        return Icons.water_drop;
      case 'mixte':
        return Icons.layers;
      default:
        return Icons.help;
    }
  }

  String _getDestinationLabel(String destination) {
    switch (destination) {
      case 'vente':
        return 'Vendu';
      case 'compost':
        return 'Compost';
      case 'utilisation_personnelle':
        return 'Utilisation personnelle';
      default:
        return destination;
    }
  }

  Future<void> _confirmDelete(CollecteFumier collecte) async {
    final confirm = await DialogHelper.showConfirmation(
      context: context,
      title: 'Supprimer la collecte',
      message: 'Voulez-vous vraiment supprimer cette collecte ?',
      isDangerous: true,
    );

    if (confirm == true && mounted) {
      try {
        await context.read<FumierProvider>().supprimerCollecte(collecte.id!);
        if (mounted) {
          SnackbarHelper.showSuccess(context, 'Collecte supprimée');
        }
      } catch (e) {
        if (mounted) {
          SnackbarHelper.showError(context, 'Erreur: $e');
        }
      }
    }
  }

  Future<void> _showAjouterCollecteDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = DateTime.now();
    String selectedType = 'crottes';
    String? selectedDestination;
    double? prixVente;
    double quantite = 0;
    String? notes;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nouvelle collecte de fumier'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      selectedDate = date;
                      (dialogContext as Element).markNeedsBuild();
                    }
                  },
                ),

                // Quantité
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Quantité (kg)',
                    prefixIcon: Icon(Icons.scale),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requis';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Nombre invalide';
                    }
                    return null;
                  },
                  onSaved: (value) => quantite = double.parse(value!),
                ),

                // Type
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    prefixIcon: Icon(Icons.eco),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'crottes', child: Text('Crottes')),
                    DropdownMenuItem(value: 'urine', child: Text('Urine')),
                    DropdownMenuItem(value: 'mixte', child: Text('Mixte')),
                  ],
                  onChanged: (value) => selectedType = value!,
                ),

                // Destination
                DropdownButtonFormField<String>(
                  value: selectedDestination,
                  decoration: const InputDecoration(
                    labelText: 'Destination (optionnel)',
                    prefixIcon: Icon(Icons.near_me),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'vente', child: Text('Vente')),
                    DropdownMenuItem(value: 'compost', child: Text('Compost')),
                    DropdownMenuItem(
                      value: 'utilisation_personnelle',
                      child: Text('Utilisation personnelle'),
                    ),
                  ],
                  onChanged: (value) => selectedDestination = value,
                ),

                // Prix de vente (si vente)
                if (selectedDestination == 'vente')
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Prix de vente (€)',
                      prefixIcon: Icon(Icons.euro),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (value) =>
                        prixVente = value != null && value.isNotEmpty
                        ? double.parse(value)
                        : null,
                  ),

                // Notes
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
                  onSaved: (value) => notes = value,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                final collecte = CollecteFumier(
                  dateCollecte: selectedDate,
                  quantite: quantite,
                  type: selectedType,
                  destination: selectedDestination,
                  prixVente: prixVente,
                  notes: notes,
                );

                try {
                  await context.read<FumierProvider>().ajouterCollecte(
                    collecte,
                  );
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Collecte enregistrée'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
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
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
