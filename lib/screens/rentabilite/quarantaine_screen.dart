import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/quarantaine_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../models/quarantaine.dart';
import '../../theme/app_theme.dart';

class QuarantaineScreen extends StatefulWidget {
  const QuarantaineScreen({super.key});

  @override
  State<QuarantaineScreen> createState() => _QuarantaineScreenState();
}

class _QuarantaineScreenState extends State<QuarantaineScreen> {
  String _filtreStatut = 'tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuarantaineProvider>().chargerQuarantaines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quarantaine'),
        backgroundColor: AppTheme.accentAmber,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filtreStatut = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'tous', child: Text('Tous')),
              const PopupMenuItem(value: 'en_cours', child: Text('En cours')),
              const PopupMenuItem(value: 'termine', child: Text('Terminés')),
            ],
          ),
        ],
      ),
      body: Consumer2<QuarantaineProvider, LapinProvider>(
        builder: (context, quarantaineProvider, lapinProvider, child) {
          if (quarantaineProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filtrer
          List<Quarantaine> quarantainesFiltrees = _filtreStatut == 'tous'
              ? quarantaineProvider.quarantaines
              : quarantaineProvider.quarantaines
                    .where((q) => q.statut == _filtreStatut)
                    .toList();

          // Statistiques
          final enCours = quarantaineProvider.quarantainesEnCours;
          final dureeAvg = quarantaineProvider.getDureeMoyenne();

          return Column(
            children: [
              // Bannière alertes
              if (enCours.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    border: Border(
                      bottom: BorderSide(color: Colors.orange[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '⚠️ ${enCours.length} lapin(s) actuellement en quarantaine',
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.orange[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Statistiques
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Total',
                      '${quarantainesFiltrees.length}',
                      Icons.format_list_numbered,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'En cours',
                      '${enCours.length}',
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Durée moy.',
                      '${dureeAvg.toStringAsFixed(0)}j',
                      Icons.timer,
                      Colors.green,
                    ),
                  ],
                ),
              ),

              // Liste
              Expanded(
                child: quarantainesFiltrees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.health_and_safety,
                              size: 80,
                              color: Colors.orange[200],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _filtreStatut == 'tous'
                                  ? 'Aucune quarantaine'
                                  : 'Aucune quarantaine $_filtreStatut',
                              style: AppTheme.bodyMedium.copyWith(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Appuyez sur + pour en ajouter',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: quarantainesFiltrees.length,
                        itemBuilder: (context, index) {
                          final quarantaine = quarantainesFiltrees[index];
                          final lapin = lapinProvider.lapins.firstWhere(
                            (l) => l.id == quarantaine.lapinId,
                            orElse: () => lapinProvider.lapins.first,
                          );
                          return _buildQuarantaineCard(
                            quarantaine,
                            lapin.nom,
                            quarantaineProvider,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAjouterQuarantaineDialog(context),
        backgroundColor: AppTheme.accentAmber,
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
        Text(
          value,
          style: AppTheme.titleLarge.copyWith(
            color: color,
          ),
        ),
        Text(label, style: AppTheme.caption.copyWith( color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildQuarantaineCard(
    Quarantaine quarantaine,
    String nomLapin,
    QuarantaineProvider provider,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final estEnCours = quarantaine.estEnCours;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: estEnCours ? Colors.orange[50] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: estEnCours ? Colors.orange[300]! : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getMotifColor(quarantaine.motif),
          child: Icon(
            estEnCours ? Icons.warning : Icons.check_circle,
            color: Colors.white,
          ),
        ),
        title: Text(
          nomLapin,
          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  estEnCours ? Icons.access_time : Icons.check,
                  size: 16,
                  color: estEnCours ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  estEnCours
                      ? 'En cours (${quarantaine.dureeJours}j)'
                      : 'Terminé',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: estEnCours ? Colors.orange[700] : Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${_getMotifLabel(quarantaine.motif)} • Début: ${dateFormat.format(quarantaine.dateDebut)}',
              style: AppTheme.caption.copyWith( color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: estEnCours
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'lever') {
                    _leverQuarantaine(context, quarantaine);
                  } else if (value == 'observation') {
                    _ajouterObservation(context, quarantaine);
                  } else if (value == 'supprimer') {
                    _confirmerSuppression(context, quarantaine);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'lever',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Lever quarantaine'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'observation',
                    child: Row(
                      children: [
                        Icon(Icons.note_add, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Ajouter observation'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'supprimer',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer'),
                      ],
                    ),
                  ),
                ],
              )
            : IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: () => _confirmerSuppression(context, quarantaine),
              ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Motif', _getMotifLabel(quarantaine.motif)),
                _buildInfoRow(
                  'Début',
                  dateFormat.format(quarantaine.dateDebut),
                ),
                if (quarantaine.dateFin != null)
                  _buildInfoRow('Fin', dateFormat.format(quarantaine.dateFin!)),
                _buildInfoRow('Durée', '${quarantaine.dureeJours} jours'),
                if (quarantaine.symptomes != null &&
                    quarantaine.symptomes!.isNotEmpty)
                  _buildInfoRow('Symptômes', quarantaine.symptomes!),
                if (quarantaine.traitement != null &&
                    quarantaine.traitement!.isNotEmpty)
                  _buildInfoRow('Traitement', quarantaine.traitement!),
                if (quarantaine.notes != null && quarantaine.notes!.isNotEmpty)
                  _buildInfoRow('Notes', quarantaine.notes!),
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
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: AppTheme.bodyMedium.copyWith(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Color _getMotifColor(String motif) {
    switch (motif) {
      case 'nouveau':
        return Colors.blue;
      case 'maladie':
        return Colors.red;
      case 'isolement_sanitaire':
        return Colors.orange;
      case 'observation':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getMotifLabel(String motif) {
    switch (motif) {
      case 'nouveau':
        return 'Nouvel arrivant';
      case 'maladie':
        return 'Maladie';
      case 'isolement_sanitaire':
        return 'Isolement sanitaire';
      case 'observation':
        return 'Observation';
      default:
        return motif;
    }
  }

  void _showAjouterQuarantaineDialog(BuildContext context) {
    final lapinProvider = context.read<LapinProvider>();
    int? lapinSelectionne;
    String motif = 'nouveau';
    final symptomesController = TextEditingController();
    final traitementController = TextEditingController();
    final notesController = TextEditingController();
    DateTime dateDebut = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Mettre en quarantaine'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: lapinSelectionne,
                  decoration: const InputDecoration(
                    labelText: 'Lapin *',
                    border: OutlineInputBorder(),
                  ),
                  items: lapinProvider.lapins.map((lapin) {
                    return DropdownMenuItem(
                      value: lapin.id,
                      child: Text(lapin.nom),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => lapinSelectionne = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: motif,
                  decoration: const InputDecoration(
                    labelText: 'Motif',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'nouveau',
                      child: Text('Nouvel arrivant'),
                    ),
                    DropdownMenuItem(value: 'maladie', child: Text('Maladie')),
                    DropdownMenuItem(
                      value: 'isolement_sanitaire',
                      child: Text('Isolement sanitaire'),
                    ),
                    DropdownMenuItem(
                      value: 'observation',
                      child: Text('Observation'),
                    ),
                  ],
                  onChanged: (value) => setState(() => motif = value!),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    'Date début: ${DateFormat('dd/MM/yyyy').format(dateDebut)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: dateDebut,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => dateDebut = date);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: symptomesController,
                  decoration: const InputDecoration(
                    labelText: 'Symptômes observés',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: traitementController,
                  decoration: const InputDecoration(
                    labelText: 'Traitement appliqué',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (lapinSelectionne == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez sélectionner un lapin'),
                    ),
                  );
                  return;
                }

                final quarantaine = Quarantaine(
                  lapinId: lapinSelectionne!,
                  dateDebut: dateDebut,
                  motif: motif,
                  symptomes: symptomesController.text.isNotEmpty
                      ? symptomesController.text
                      : null,
                  traitement: traitementController.text.isNotEmpty
                      ? traitementController.text
                      : null,
                  statut: 'en_cours',
                  notes: notesController.text.isNotEmpty
                      ? notesController.text
                      : null,
                );

                context.read<QuarantaineProvider>().ajouterQuarantaine(
                  quarantaine,
                );
                Navigator.pop(context);
              },
              child: const Text('Mettre en quarantaine'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _leverQuarantaine(
    BuildContext context,
    Quarantaine quarantaine,
  ) async {
    final confirmed = await DialogHelper.showConfirmation(
      context: context,
      title: 'Lever la quarantaine',
      message: 'Confirmez-vous que ce lapin peut sortir de quarantaine ?',
      confirmLabel: 'Confirmer',
      icon: Icons.check_circle,
    );

    if (confirmed == true && context.mounted) {
      context.read<QuarantaineProvider>().leverQuarantaine(
        quarantaine.id!,
        DateTime.now(),
      );
    }
  }

  void _ajouterObservation(BuildContext context, Quarantaine quarantaine) {
    final observationController = TextEditingController(
      text: quarantaine.notes ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une observation'),
        content: TextField(
          controller: observationController,
          decoration: const InputDecoration(
            labelText: 'Observation',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final quarantaineModifiee = quarantaine.copyWith(
                notes: observationController.text,
              );
              context.read<QuarantaineProvider>().modifierQuarantaine(
                quarantaineModifiee,
              );
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmerSuppression(
    BuildContext context,
    Quarantaine quarantaine,
  ) async {
    final confirmed = await DialogHelper.showConfirmation(
      context: context,
      title: 'Confirmer la suppression',
      message: 'Supprimer cette quarantaine ?',
      isDangerous: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<QuarantaineProvider>().supprimerQuarantaine(quarantaine.id!);
    }
  }
}
