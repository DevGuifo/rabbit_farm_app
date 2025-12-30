import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/palpation_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../models/palpation.dart';
import '../../theme/app_theme.dart';

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
      appBar: AppBar(
        title: const Text('Palpation'),
        backgroundColor: AppTheme.warning,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filtreResultat = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'tous', child: Text('Tous')),
              const PopupMenuItem(value: 'gestante', child: Text('Gestantes')),
              const PopupMenuItem(
                value: 'non_gestante',
                child: Text('Non gestantes'),
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Total',
                          '${palpationsFiltrees.length}',
                          Icons.format_list_numbered,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Taux réussite',
                          '${(tauxReussite ?? 0.0).toStringAsFixed(0)}%',
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Moy. fœtus',
                          (nombreMoyenFoetus ?? 0.0).toStringAsFixed(1),
                          Icons.child_care,
                          Colors.orange,
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
                                  color: Colors.pink[200],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _filtreResultat == 'tous'
                                      ? 'Aucune palpation'
                                      : 'Aucune palpation $_filtreResultat',
                                  style: AppTheme.titleMedium.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Appuyez sur + pour en ajouter',
                                  style: AppTheme.bodyMedium.copyWith(color: Colors.grey),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAjouterPalpationDialog(context),
        backgroundColor: AppTheme.warning,
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
        Text(label, style: AppTheme.caption.copyWith(color: Colors.grey[600])),
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
      color: palpation.gestante ? Colors.green[50] : Colors.red[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: palpation.gestante ? Colors.green[300]! : Colors.red[300]!,
          width: 1.5,
        ),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: palpation.gestante ? Colors.green : Colors.red,
          child: Icon(
            palpation.gestante ? Icons.check : Icons.close,
            color: Colors.white,
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
                  color: palpation.gestante ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  palpation.gestante ? 'Gestante' : 'Non gestante',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: palpation.gestante
                        ? Colors.green[700]
                        : Colors.red[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'J$joursDepuis après accouplement • ${dateFormat.format(palpation.datePalpation)}',
              style: AppTheme.caption.copyWith( color: Colors.grey[600]),
            ),
            if (!dansPeriodeRecommandee) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.warning_amber, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'Hors période recommandée (J10-J12)',
                    style: AppTheme.caption.copyWith(
                      color: Colors.orange[700],
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
            const PopupMenuItem(
              value: 'modifier',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Modifier'),
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

  void _showAjouterPalpationDialog(BuildContext context) {
    final reproProvider = context.read<ReproductionProvider>();
    final accouplements = reproProvider.accouplements
        .where((a) => a.statut == 'confirme' || a.statut == 'en_attente')
        .toList();

    if (accouplements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun accouplement disponible pour palpation'),
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
          title: const Text('Enregistrer une palpation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: accouplementSelectionne,
                  decoration: const InputDecoration(
                    labelText: 'Accouplement *',
                    border: OutlineInputBorder(),
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
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[400]!),
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
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Gestante'),
                  subtitle: const Text('La femelle est-elle gestante ?'),
                  value: gestante,
                  onChanged: (value) => setState(() => gestante = value),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
                if (gestante) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: nombreFoetusController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de fœtus palpés',
                      border: OutlineInputBorder(),
                      helperText: 'Estimation si possible',
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: temperatureController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Température corporelle (°C)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: realiseParController,
                  decoration: const InputDecoration(
                    labelText: 'Réalisé par',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
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
              child: const Text('Enregistrer'),
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
          title: const Text('Modifier la palpation'),
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
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[400]!),
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
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Gestante'),
                  value: gestante,
                  onChanged: (value) => setState(() => gestante = value),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
                if (gestante) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: nombreFoetusController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de fœtus palpés',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: temperatureController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Température corporelle (°C)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: realiseParController,
                  decoration: const InputDecoration(
                    labelText: 'Réalisé par',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
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
              child: const Text('Modifier'),
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
      title: 'Confirmer la suppression',
      message: 'Supprimer cette palpation ?',
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
            Icon(Icons.help, color: Colors.pink[700]),
            const SizedBox(width: 8),
            const Text('Aide - Palpation'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Quand palper ?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Période recommandée : J10 à J12 après l\'accouplement\n'
                '• Avant J10 : trop tôt, fœtus non palpables\n'
                '• Après J12 : risque de stress pour la femelle',
              ),
              const SizedBox(height: 16),
              const Text(
                'Comment palper ?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Si vous n\'êtes pas sûr, consultez un vétérinaire ou un éleveur expérimenté',
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
