import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/preparation_nid_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../models/preparation_nid.dart';
import '../../theme/app_theme.dart';

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
      appBar: AppBar(
        title: const Text('Préparation du Nid'),
        backgroundColor: const Color(0xFF8D6E63),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filtreType = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'tous', child: Text('Tous')),
              const PopupMenuItem(
                value: 'avec_boite',
                child: Text('Avec boîte'),
              ),
              const PopupMenuItem(
                value: 'sans_boite',
                child: Text('Sans boîte'),
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
                      color: Colors.brown[50],
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Total',
                          '${preparationsFiltrees.length}',
                          Icons.format_list_numbered,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Avec boîte',
                          '${(tauxBoites ?? 0.0).toStringAsFixed(0)}%',
                          Icons.check_box,
                          Colors.green,
                        ),
                        _buildStatCard(
                          'À préparer',
                          '${preparationProvider.getNidsNonPrepares().length}',
                          Icons.pending_actions,
                          Colors.orange,
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
                                  color: Colors.brown[200],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _filtreType == 'tous'
                                      ? 'Aucune préparation'
                                      : 'Aucune préparation $_filtreType',
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
        onPressed: () => _showAjouterPreparationDialog(context),
        backgroundColor: const Color(0xFF8D6E63),
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
          ? Colors.green[50]
          : Colors.orange[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: preparation.boiteNidInstallee
              ? Colors.green[300]!
              : Colors.orange[300]!,
          width: 1.5,
        ),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: preparation.boiteNidInstallee
              ? Colors.green
              : Colors.orange,
          child: Icon(
            preparation.boiteNidInstallee ? Icons.check_box : Icons.home,
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
                  preparation.boiteNidInstallee
                      ? Icons.check_circle
                      : Icons.pending,
                  size: 16,
                  color: preparation.boiteNidInstallee
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  preparation.boiteNidInstallee
                      ? 'Boîte installée'
                      : 'Sans boîte',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: preparation.boiteNidInstallee
                        ? Colors.green[700]
                        : Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'J$joursDepuis • ${_getTypeMateriau(preparation.typeMateriau)} • ${dateFormat.format(preparation.datePreparation)}',
              style: AppTheme.caption.copyWith( color: Colors.grey[600]),
            ),
            if (joursAvantMiseBas <= 3 && joursAvantMiseBas > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.info, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'Mise bas dans $joursAvantMiseBas jour(s)',
                    style: AppTheme.caption.copyWith(
                      color: Colors.blue[700],
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
                  Icon(Icons.warning_amber, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'Hors période recommandée (J28)',
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
              _showModifierPreparationDialog(context, preparation);
            } else if (value == 'supprimer') {
              _confirmerSuppression(context, preparation);
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
        const SnackBar(content: Text('Aucun accouplement confirmé disponible')),
      );
      return;
    }

    int? accouplementSelectionne;
    String typeMateriau = 'paille';
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
          title: const Text('Préparer le nid'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue:  accouplementSelectionne,
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
                    side: BorderSide(color: Colors.grey[400]!),
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
                DropdownButtonFormField<String>(
                  initialValue:  typeMateriau,
                  decoration: const InputDecoration(
                    labelText: 'Type de matériau',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'paille', child: Text('Paille')),
                    DropdownMenuItem(value: 'foin', child: Text('Foin')),
                    DropdownMenuItem(
                      value: 'copeaux',
                      child: Text('Copeaux de bois'),
                    ),
                    DropdownMenuItem(value: 'mixte', child: Text('Mixte')),
                  ],
                  onChanged: (value) => setState(() => typeMateriau = value!),
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
                  title: const Text('Boîte à nid installée'),
                  subtitle: const Text('Boîte spéciale pour le nid'),
                  value: boiteNidInstallee,
                  onChanged: (value) =>
                      setState(() => boiteNidInstallee = value),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dispositionController,
                  decoration: const InputDecoration(
                    labelText: 'Disposition du nid',
                    border: OutlineInputBorder(),
                    helperText: 'Ex: Coin gauche de la cage',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: temperatureController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Température ambiante (°C)',
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
                backgroundColor: const Color(0xFF8D6E63),
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
                  typeMateriau: typeMateriau,
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
              child: const Text('Enregistrer'),
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
          title: const Text('Modifier la préparation'),
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
                    side: BorderSide(color: Colors.grey[400]!),
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
                  initialValue:  typeMateriau,
                  decoration: const InputDecoration(
                    labelText: 'Type de matériau',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'paille', child: Text('Paille')),
                    DropdownMenuItem(value: 'foin', child: Text('Foin')),
                    DropdownMenuItem(
                      value: 'copeaux',
                      child: Text('Copeaux de bois'),
                    ),
                    DropdownMenuItem(value: 'mixte', child: Text('Mixte')),
                  ],
                  onChanged: (value) => setState(() => typeMateriau = value!),
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
                  title: const Text('Boîte à nid installée'),
                  value: boiteNidInstallee,
                  onChanged: (value) =>
                      setState(() => boiteNidInstallee = value),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dispositionController,
                  decoration: const InputDecoration(
                    labelText: 'Disposition du nid',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: temperatureController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Température ambiante (°C)',
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
                final preparationModifiee = preparation.copyWith(
                  datePreparation: datePreparation,
                  typeMateriau: typeMateriau,
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
              child: const Text('Modifier'),
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
        title: const Text('Confirmer la suppression'),
        content: const Text('Supprimer cette préparation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<PreparationNidProvider>().supprimerPreparation(
                preparation.id!,
              );
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
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
            Icon(Icons.help, color: Colors.brown[700]),
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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700]),
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
