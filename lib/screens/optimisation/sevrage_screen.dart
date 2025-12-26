import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/sevrage.dart';
import '../../providers/sevrage_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/snackbar_helper.dart';

/// Écran de gestion des sevrages
class SevrageScreen extends StatefulWidget {
  const SevrageScreen({super.key});

  @override
  State<SevrageScreen> createState() => _SevrageScreenState();
}

class _SevrageScreenState extends State<SevrageScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SevrageProvider>().chargerSevrages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des sevrages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _afficherAide(context),
          ),
        ],
      ),
      body: Consumer<SevrageProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.sevrages.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              _buildStatistiques(provider),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.sevrages.length,
                  itemBuilder: (context, index) {
                    final sevrage = provider.sevrages[index];
                    return _buildSevrageCard(context, sevrage);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ajouterSevrage(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau sevrage'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grass_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucun sevrage enregistré',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par ajouter un sevrage',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistiques(SevrageProvider provider) {
    final poidsMoyen = provider.getPoidsMoyenSevrage();
    final totalLapereaux = provider.getTotalLapereaux();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            icon: Icons.trending_up,
            label: 'Total sevrages',
            value: provider.sevrages.length.toString(),
            color: Colors.blue,
          ),
          _buildStatCard(
            icon: Icons.pets,
            label: 'Lapereaux sevrés',
            value: totalLapereaux.toString(),
            color: Colors.green,
          ),
          _buildStatCard(
            icon: Icons.scale,
            label: 'Poids moyen',
            value: poidsMoyen != null
                ? '${poidsMoyen.toStringAsFixed(0)}g'
                : 'N/A',
            color: Colors.orange,
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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSevrageCard(BuildContext context, Sevrage sevrage) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: const Icon(Icons.grass, color: Colors.green),
        ),
        title: Text(
          'Portée #${sevrage.porteeId} - ${sevrage.nombreLapereaux} lapereaux',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Date: ${dateFormat.format(sevrage.dateSevrage)}'),
            if (sevrage.poidsMoyenSevrage != null)
              Text(
                'Poids moyen: ${sevrage.poidsMoyenSevrage!.toStringAsFixed(0)}g',
              ),
            if (sevrage.nouvelleCage != null)
              Text('Cage: ${sevrage.nouvelleCage}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'modifier',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Modifier'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'supprimer',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Supprimer', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'modifier') {
              _modifierSevrage(context, sevrage);
            } else if (value == 'supprimer') {
              _confirmerSuppression(context, sevrage);
            }
          },
        ),
      ),
    );
  }

  Future<void> _ajouterSevrage(BuildContext context) async {
    await _showSevrageForm(context, null);
  }

  Future<void> _modifierSevrage(BuildContext context, Sevrage sevrage) async {
    await _showSevrageForm(context, sevrage);
  }

  Future<void> _showSevrageForm(BuildContext context, Sevrage? sevrage) async {
    final formKey = GlobalKey<FormState>();
    final dateController = TextEditingController(
      text: sevrage != null
          ? DateFormat('dd/MM/yyyy').format(sevrage.dateSevrage)
          : DateFormat('dd/MM/yyyy').format(DateTime.now()),
    );
    final nombreController = TextEditingController(
      text: sevrage?.nombreLapereaux.toString() ?? '',
    );
    final poidsController = TextEditingController(
      text: sevrage?.poidsMoyenSevrage?.toString() ?? '',
    );
    final cageController = TextEditingController(
      text: sevrage?.nouvelleCage ?? '',
    );
    final observationsController = TextEditingController(
      text: sevrage?.observations ?? '',
    );
    final alimentationController = TextEditingController(
      text: sevrage?.alimentationPostSevrage ?? '',
    );

    DateTime selectedDate = sevrage?.dateSevrage ?? DateTime.now();
    int? selectedPorteeId = sevrage?.porteeId;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(sevrage == null ? 'Nouveau sevrage' : 'Modifier sevrage'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sélection de la portée
                  Consumer<ReproductionProvider>(
                    builder: (context, repro, child) {
                      final portees = repro.portees;
                      return DropdownButtonFormField<int>(
                        value: selectedPorteeId,
                        decoration: const InputDecoration(
                          labelText: 'Portée *',
                          border: OutlineInputBorder(),
                        ),
                        items: portees.map((portee) {
                          return DropdownMenuItem(
                            value: portee.id,
                            child: Text(
                              'Portée #${portee.id} - ${portee.nombreVivants} vivants',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedPorteeId = value);
                        },
                        validator: (value) =>
                            value == null ? 'Sélectionnez une portée' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date de sevrage
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date de sevrage *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                          dateController.text = DateFormat(
                            'dd/MM/yyyy',
                          ).format(date);
                        });
                      }
                    },
                    validator: (value) =>
                        value!.isEmpty ? 'Date requise' : null,
                  ),
                  const SizedBox(height: 16),

                  // Nombre de lapereaux
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de lapereaux sevrés *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Nombre requis';
                      if (int.tryParse(value) == null) return 'Nombre invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Poids moyen
                  TextFormField(
                    controller: poidsController,
                    decoration: const InputDecoration(
                      labelText: 'Poids moyen au sevrage (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Nouvelle cage
                  TextFormField(
                    controller: cageController,
                    decoration: const InputDecoration(
                      labelText: 'Nouvelle cage',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Alimentation post-sevrage
                  TextFormField(
                    controller: alimentationController,
                    decoration: const InputDecoration(
                      labelText: 'Alimentation post-sevrage',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Observations
                  TextFormField(
                    controller: observationsController,
                    decoration: const InputDecoration(
                      labelText: 'Observations',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
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
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate() &&
                    selectedPorteeId != null) {
                  final nouveauSevrage = Sevrage(
                    id: sevrage?.id,
                    porteeId: selectedPorteeId!,
                    dateSevrage: selectedDate,
                    nombreLapereaux: int.parse(nombreController.text),
                    poidsMoyenSevrage: poidsController.text.isNotEmpty
                        ? double.tryParse(poidsController.text)
                        : null,
                    nouvelleCage: cageController.text.isNotEmpty
                        ? cageController.text
                        : null,
                    observations: observationsController.text.isNotEmpty
                        ? observationsController.text
                        : null,
                    alimentationPostSevrage:
                        alimentationController.text.isNotEmpty
                        ? alimentationController.text
                        : null,
                  );

                  try {
                    if (sevrage == null) {
                      await context.read<SevrageProvider>().ajouterSevrage(
                        nouveauSevrage,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sevrage enregistré avec succès'),
                          ),
                        );
                      }
                    } else {
                      await context.read<SevrageProvider>().modifierSevrage(
                        nouveauSevrage,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sevrage modifié avec succès'),
                          ),
                        );
                      }
                    }
                    if (context.mounted) Navigator.pop(context);
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
              child: Text(sevrage == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmerSuppression(
    BuildContext context,
    Sevrage sevrage,
  ) async {
    final confirmed = await DialogHelper.showConfirmation(
      context: context,
      title: 'Confirmer la suppression',
      message:
          'Voulez-vous vraiment supprimer ce sevrage ?\nCette action est irréversible.',
      isDangerous: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<SevrageProvider>().supprimerSevrage(sevrage.id!);
        if (context.mounted) {
          SnackbarHelper.showSuccess(context, 'Sevrage supprimé');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _afficherAide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aide - Gestion des sevrages'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Le sevrage des lapereaux',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Le sevrage est une étape cruciale dans l\'élevage. Il se fait généralement entre 4 et 8 semaines après la naissance.',
              ),
              SizedBox(height: 16),
              Text(
                'Informations importantes :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Date de sevrage : quand les lapereaux sont séparés de la mère',
              ),
              Text('• Nombre sevrés : combien de lapereaux viables'),
              Text('• Poids moyen : pour suivre la croissance'),
              Text('• Nouvelle cage : où sont placés les lapereaux'),
              Text('• Alimentation : régime alimentaire post-sevrage'),
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
