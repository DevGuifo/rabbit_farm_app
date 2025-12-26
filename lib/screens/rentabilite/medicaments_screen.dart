import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/medicament_provider.dart';
import '../../utils/dialog_helper.dart';
import '../../models/medicament.dart';

class MedicamentsScreen extends StatefulWidget {
  const MedicamentsScreen({super.key});

  @override
  State<MedicamentsScreen> createState() => _MedicamentsScreenState();
}

class _MedicamentsScreenState extends State<MedicamentsScreen> {
  String _filtreType = 'tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicamentProvider>().chargerMedicaments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacie'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        actions: [
          // Filtre par type
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
                value: 'antibiotique',
                child: Text('Antibiotiques'),
              ),
              const PopupMenuItem(
                value: 'antiparasitaire',
                child: Text('Antiparasitaires'),
              ),
              const PopupMenuItem(value: 'vaccin', child: Text('Vaccins')),
              const PopupMenuItem(value: 'vitamine', child: Text('Vitamines')),
              const PopupMenuItem(value: 'autre', child: Text('Autres')),
            ],
          ),
        ],
      ),
      body: Consumer<MedicamentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filtrer les médicaments
          List<Medicament> medicamentsFiltres = _filtreType == 'tous'
              ? provider.medicaments
              : provider.medicaments
                    .where((m) => m.type == _filtreType)
                    .toList();

          // Alertes
          final alertes = provider.medicamentsEnAlerte;

          return Column(
            children: [
              // Bannière alertes
              if (alertes.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border(bottom: BorderSide(color: Colors.red[200]!)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '⚠️ ${alertes.length} médicament(s) en alerte',
                          style: TextStyle(
                            color: Colors.red[900],
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
                  color: Colors.pink[50],
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Total',
                      '${medicamentsFiltres.length}',
                      Icons.medication_rounded,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Alertes',
                      '${alertes.length}',
                      Icons.warning_rounded,
                      Colors.red,
                    ),
                    _buildStatCard(
                      'Valeur',
                      '${provider.getValeurStockTotal().toStringAsFixed(0)}€',
                      Icons.euro_rounded,
                      Colors.green,
                    ),
                  ],
                ),
              ),

              // Liste des médicaments
              Expanded(
                child: medicamentsFiltres.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              size: 80,
                              color: Colors.pink[200],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _filtreType == 'tous'
                                  ? 'Aucun médicament'
                                  : 'Aucun médicament de type $_filtreType',
                              style: const TextStyle(
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
                        itemCount: medicamentsFiltres.length,
                        itemBuilder: (context, index) {
                          final medicament = medicamentsFiltres[index];
                          return _buildMedicamentCard(medicament, provider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAjouterMedicamentDialog(context),
        backgroundColor: const Color(0xFFE91E63),
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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildMedicamentCard(
    Medicament medicament,
    MedicamentProvider provider,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final hasAlerte =
        medicament.estEnRupture ||
        medicament.estSousSeuilAlerte ||
        medicament.estPerime ||
        medicament.expireSoon;

    Color backgroundColor = hasAlerte ? Colors.red[50]! : Colors.white;
    Color borderColor = Colors.grey[300]!;
    String? alerteText;

    if (medicament.estPerime) {
      backgroundColor = Colors.red[50]!;
      borderColor = Colors.red[300]!;
      alerteText = '⚠️ PÉRIMÉ';
    } else if (medicament.estEnRupture) {
      backgroundColor = Colors.orange[50]!;
      borderColor = Colors.orange[300]!;
      alerteText = '⚠️ RUPTURE DE STOCK';
    } else if (medicament.expireSoon) {
      backgroundColor = Colors.yellow[50]!;
      borderColor = Colors.yellow[700]!;
      alerteText = '⚠️ Expire bientôt';
    } else if (medicament.estSousSeuilAlerte) {
      backgroundColor = Colors.amber[50]!;
      borderColor = Colors.amber[300]!;
      alerteText = '⚠️ Stock faible';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(medicament.type),
          child: Icon(_getTypeIcon(medicament.type), color: Colors.white),
        ),
        title: Text(
          medicament.nom,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  medicament.quantiteStock > 0
                      ? Icons.check_circle
                      : Icons.cancel,
                  size: 16,
                  color: medicament.quantiteStock > 0
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  '${medicament.quantiteStock} ${medicament.unite}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: medicament.quantiteStock > 0
                        ? Colors.green[700]
                        : Colors.red[700],
                  ),
                ),
                if (medicament.seuilAlerte != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(seuil: ${medicament.seuilAlerte} ${medicament.unite})',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
            if (alerteText != null) ...[
              const SizedBox(height: 4),
              Text(
                alerteText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: medicament.estPerime ? Colors.red : Colors.orange,
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'utiliser') {
              _showUtiliserDialog(context, medicament);
            } else if (value == 'reapprovisionner') {
              _showReapprovisionnerDialog(context, medicament);
            } else if (value == 'modifier') {
              _showModifierMedicamentDialog(context, medicament);
            } else if (value == 'supprimer') {
              _confirmerSuppression(context, medicament);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'utiliser',
              child: Row(
                children: [
                  Icon(Icons.remove_circle, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Utiliser'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'reapprovisionner',
              child: Row(
                children: [
                  Icon(Icons.add_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Réapprovisionner'),
                ],
              ),
            ),
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
                _buildInfoRow('Type', _getTypeLabel(medicament.type)),
                if (medicament.dateExpiration != null)
                  _buildInfoRow(
                    'Expiration',
                    dateFormat.format(medicament.dateExpiration!),
                    icon: Icons.calendar_today,
                  ),
                if (medicament.prixUnitaire != null)
                  _buildInfoRow(
                    'Prix unitaire',
                    '${medicament.prixUnitaire!.toStringAsFixed(2)} €',
                    icon: Icons.euro,
                  ),
                if (medicament.posologie != null)
                  _buildInfoRow(
                    'Posologie',
                    medicament.posologie!,
                    icon: Icons.medical_information,
                  ),
                if (medicament.notes != null && medicament.notes!.isNotEmpty)
                  _buildInfoRow('Notes', medicament.notes!, icon: Icons.note),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
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
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'antibiotique':
        return Colors.red;
      case 'antiparasitaire':
        return Colors.orange;
      case 'vaccin':
        return Colors.blue;
      case 'vitamine':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'antibiotique':
        return Icons.coronavirus_rounded;
      case 'antiparasitaire':
        return Icons.bug_report_rounded;
      case 'vaccin':
        return Icons.vaccines_rounded;
      case 'vitamine':
        return Icons.energy_savings_leaf_rounded;
      default:
        return Icons.medication_rounded;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'antibiotique':
        return 'Antibiotique';
      case 'antiparasitaire':
        return 'Antiparasitaire';
      case 'vaccin':
        return 'Vaccin';
      case 'vitamine':
        return 'Vitamine';
      default:
        return 'Autre';
    }
  }

  void _showAjouterMedicamentDialog(BuildContext context) {
    final nomController = TextEditingController();
    final quantiteController = TextEditingController();
    final seuilController = TextEditingController();
    final prixController = TextEditingController();
    final posologieController = TextEditingController();
    final notesController = TextEditingController();
    String type = 'antibiotique';
    String unite = 'ml';
    DateTime? dateExpiration;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ajouter un médicament'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'antibiotique',
                      child: Text('Antibiotique'),
                    ),
                    DropdownMenuItem(
                      value: 'antiparasitaire',
                      child: Text('Antiparasitaire'),
                    ),
                    DropdownMenuItem(value: 'vaccin', child: Text('Vaccin')),
                    DropdownMenuItem(
                      value: 'vitamine',
                      child: Text('Vitamine'),
                    ),
                    DropdownMenuItem(value: 'autre', child: Text('Autre')),
                  ],
                  onChanged: (value) => setState(() => type = value!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantiteController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantité *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: unite,
                        decoration: const InputDecoration(
                          labelText: 'Unité',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'ml', child: Text('ml')),
                          DropdownMenuItem(value: 'g', child: Text('g')),
                          DropdownMenuItem(
                            value: 'comprime',
                            child: Text('cp'),
                          ),
                          DropdownMenuItem(value: 'dose', child: Text('dose')),
                        ],
                        onChanged: (value) => setState(() => unite = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: seuilController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Seuil d\'alerte',
                    border: OutlineInputBorder(),
                    helperText: 'Alerté si stock < seuil',
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    dateExpiration == null
                        ? 'Date d\'expiration'
                        : 'Expire le: ${DateFormat('dd/MM/yyyy').format(dateExpiration!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(
                        const Duration(days: 365),
                      ),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setState(() => dateExpiration = date);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: prixController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Prix unitaire (€)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: posologieController,
                  decoration: const InputDecoration(
                    labelText: 'Posologie',
                    border: OutlineInputBorder(),
                    helperText: 'Ex: 0.5 ml/kg toutes les 12h',
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
                if (nomController.text.isEmpty ||
                    quantiteController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nom et quantité requis')),
                  );
                  return;
                }

                final medicament = Medicament(
                  nom: nomController.text,
                  type: type,
                  quantiteStock: double.parse(quantiteController.text),
                  unite: unite,
                  seuilAlerte: seuilController.text.isNotEmpty
                      ? double.parse(seuilController.text)
                      : null,
                  dateExpiration: dateExpiration,
                  prixUnitaire: prixController.text.isNotEmpty
                      ? double.parse(prixController.text)
                      : null,
                  posologie: posologieController.text.isNotEmpty
                      ? posologieController.text
                      : null,
                  notes: notesController.text.isNotEmpty
                      ? notesController.text
                      : null,
                );

                context.read<MedicamentProvider>().ajouterMedicament(
                  medicament,
                );
                Navigator.pop(context);
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  void _showModifierMedicamentDialog(
    BuildContext context,
    Medicament medicament,
  ) {
    final nomController = TextEditingController(text: medicament.nom);
    final quantiteController = TextEditingController(
      text: medicament.quantiteStock.toString(),
    );
    final seuilController = TextEditingController(
      text: medicament.seuilAlerte?.toString() ?? '',
    );
    final prixController = TextEditingController(
      text: medicament.prixUnitaire?.toString() ?? '',
    );
    final posologieController = TextEditingController(
      text: medicament.posologie ?? '',
    );
    final notesController = TextEditingController(text: medicament.notes ?? '');
    String type = medicament.type;
    String unite = medicament.unite;
    DateTime? dateExpiration = medicament.dateExpiration;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier le médicament'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'antibiotique',
                      child: Text('Antibiotique'),
                    ),
                    DropdownMenuItem(
                      value: 'antiparasitaire',
                      child: Text('Antiparasitaire'),
                    ),
                    DropdownMenuItem(value: 'vaccin', child: Text('Vaccin')),
                    DropdownMenuItem(
                      value: 'vitamine',
                      child: Text('Vitamine'),
                    ),
                    DropdownMenuItem(value: 'autre', child: Text('Autre')),
                  ],
                  onChanged: (value) => setState(() => type = value!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantiteController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantité *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: unite,
                        decoration: const InputDecoration(
                          labelText: 'Unité',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'ml', child: Text('ml')),
                          DropdownMenuItem(value: 'g', child: Text('g')),
                          DropdownMenuItem(
                            value: 'comprime',
                            child: Text('cp'),
                          ),
                          DropdownMenuItem(value: 'dose', child: Text('dose')),
                        ],
                        onChanged: (value) => setState(() => unite = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: seuilController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Seuil d\'alerte',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    dateExpiration == null
                        ? 'Date d\'expiration'
                        : 'Expire le: ${DateFormat('dd/MM/yyyy').format(dateExpiration!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: dateExpiration ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setState(() => dateExpiration = date);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: prixController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Prix unitaire (€)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: posologieController,
                  decoration: const InputDecoration(
                    labelText: 'Posologie',
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
                final medicamentModifie = medicament.copyWith(
                  nom: nomController.text,
                  type: type,
                  quantiteStock: double.parse(quantiteController.text),
                  unite: unite,
                  seuilAlerte: seuilController.text.isNotEmpty
                      ? double.parse(seuilController.text)
                      : null,
                  dateExpiration: dateExpiration,
                  prixUnitaire: prixController.text.isNotEmpty
                      ? double.parse(prixController.text)
                      : null,
                  posologie: posologieController.text.isNotEmpty
                      ? posologieController.text
                      : null,
                  notes: notesController.text.isNotEmpty
                      ? notesController.text
                      : null,
                );

                context.read<MedicamentProvider>().modifierMedicament(
                  medicamentModifie,
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

  void _showUtiliserDialog(BuildContext context, Medicament medicament) {
    final quantiteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Utiliser ${medicament.nom}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Stock actuel: ${medicament.quantiteStock} ${medicament.unite}',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantiteController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantité utilisée (${medicament.unite})',
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (quantiteController.text.isEmpty) return;

              final quantite = double.parse(quantiteController.text);
              if (quantite > medicament.quantiteStock) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quantité supérieure au stock')),
                );
                return;
              }

              final nouveauStock = medicament.quantiteStock - quantite;
              context.read<MedicamentProvider>().modifierMedicament(
                medicament.copyWith(quantiteStock: nouveauStock),
              );
              Navigator.pop(context);
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showReapprovisionnerDialog(
    BuildContext context,
    Medicament medicament,
  ) {
    final quantiteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Réapprovisionner ${medicament.nom}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Stock actuel: ${medicament.quantiteStock} ${medicament.unite}',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantiteController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantité ajoutée (${medicament.unite})',
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (quantiteController.text.isEmpty) return;

              final quantite = double.parse(quantiteController.text);
              final nouveauStock = medicament.quantiteStock + quantite;
              context.read<MedicamentProvider>().modifierMedicament(
                medicament.copyWith(quantiteStock: nouveauStock),
              );
              Navigator.pop(context);
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmerSuppression(
    BuildContext context,
    Medicament medicament,
  ) async {
    final confirmed = await DialogHelper.showConfirmation(
      context: context,
      title: 'Confirmer la suppression',
      message: 'Supprimer "${medicament.nom}" ?',
      isDangerous: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<MedicamentProvider>().supprimerMedicament(medicament.id!);
    }
  }
}
