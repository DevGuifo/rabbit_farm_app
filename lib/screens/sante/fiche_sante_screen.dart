import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/lapin.dart';
import '../../models/pesee.dart';
import '../../models/soin.dart';
import '../../providers/sante_provider.dart';
import '../../utils/dialog_helper.dart';
import 'ajouter_pesee_screen.dart';
import 'ajouter_soin_screen.dart';
import 'edit_pesee_screen.dart';
import 'edit_soin_screen.dart';

/// Fiche de santé détaillée d'un lapin
class FicheSanteScreen extends StatefulWidget {
  final Lapin lapin;

  const FicheSanteScreen({super.key, required this.lapin});

  @override
  State<FicheSanteScreen> createState() => _FicheSanteScreenState();
}

class _FicheSanteScreenState extends State<FicheSanteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Pesee> _pesees = [];
  List<Soin> _soins = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _chargerDonnees();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _chargerDonnees() async {
    final santeProvider = Provider.of<SanteProvider>(context, listen: false);
    final pesees = await santeProvider.getPeseesByLapin(widget.lapin.id!);
    final soins = await santeProvider.getSoinsByLapin(widget.lapin.id!);

    if (mounted) {
      setState(() {
        _pesees = pesees;
        _soins = soins;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Santé de ${widget.lapin.nom}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.monitor_weight), text: 'Pesées'),
            Tab(icon: Icon(Icons.medical_services), text: 'Soins'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPeseesTab(), _buildSoinsTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _afficherMenuAjout(),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  Widget _buildPeseesTab() {
    if (_pesees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune pesée enregistrée',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Appuyez sur + pour ajouter une pesée',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Courbe de poids
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Évolution du poids',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(height: 250, child: _buildCourbePoids()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Liste des pesées
          Text(
            'Historique des pesées',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ..._pesees.map((pesee) => _buildPeseeCard(pesee)),
        ],
      ),
    );
  }

  Widget _buildCourbePoids() {
    if (_pesees.isEmpty) return const Center(child: Text('Pas de données'));

    final spots = _pesees.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.poids);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)}kg',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= _pesees.length) return const Text('');
                final date = _pesees[value.toInt()].date;
                return Text(
                  DateFormat('dd/MM').format(date),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeseeCard(Pesee pesee) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            '${pesee.poids.toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text('${pesee.poids.toStringAsFixed(2)} kg'),
        subtitle: Text(dateFormat.format(pesee.date)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pesee.notes != null && pesee.notes!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _afficherNotesPesee(pesee),
              ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue.shade700),
              onPressed: () => _modifierPesee(pesee),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _supprimerPesee(pesee),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoinsTab() {
    if (_soins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text('Aucun soin enregistré', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              'Appuyez sur + pour ajouter un soin',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _soins.length,
      itemBuilder: (context, index) {
        final soin = _soins[index];
        return _buildSoinCard(soin);
      },
    );
  }

  Widget _buildSoinCard(Soin soin) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeSoinColor(soin.type).withValues(alpha: 0.2),
          child: Icon(
            _getTypeSoinIcon(soin.type),
            color: _getTypeSoinColor(soin.type),
          ),
        ),
        title: Text(soin.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(soin.type),
            Text(dateFormat.format(soin.date)),
            if (soin.rappelNecessaire)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Rappel nécessaire',
                  style: TextStyle(fontSize: 11, color: Colors.orange),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue.shade700),
              onPressed: () => _modifierSoin(soin),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _supprimerSoin(soin),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () => _afficherDetailsSoin(soin),
      ),
    );
  }

  Color _getTypeSoinColor(String type) {
    switch (type) {
      case 'vaccination':
        return Colors.green;
      case 'traitement':
        return Colors.orange;
      case 'vermifuge':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeSoinIcon(String type) {
    switch (type) {
      case 'vaccination':
        return Icons.vaccines;
      case 'traitement':
        return Icons.medical_services;
      case 'vermifuge':
        return Icons.pest_control;
      default:
        return Icons.local_hospital;
    }
  }

  void _afficherMenuAjout() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.monitor_weight),
              title: const Text('Ajouter une pesée'),
              onTap: () {
                Navigator.of(context).pop();
                _ajouterPesee();
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Ajouter un soin'),
              onTap: () {
                Navigator.of(context).pop();
                _ajouterSoin();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _ajouterPesee() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AjouterPeseeScreen(lapin: widget.lapin),
          ),
        )
        .then((_) => _chargerDonnees());
  }

  void _ajouterSoin() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AjouterSoinScreen(lapin: widget.lapin),
          ),
        )
        .then((_) => _chargerDonnees());
  }

  void _modifierPesee(Pesee pesee) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                EditPeseeScreen(lapin: widget.lapin, pesee: pesee),
          ),
        )
        .then((_) => _chargerDonnees());
  }

  void _modifierSoin(Soin soin) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                EditSoinScreen(lapin: widget.lapin, soin: soin),
          ),
        )
        .then((_) => _chargerDonnees());
  }

  void _afficherNotesPesee(Pesee pesee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notes'),
        content: Text(pesee.notes ?? 'Aucune note'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _afficherDetailsSoin(Soin soin) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(soin.description),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Type', soin.type),
              _buildInfoRow('Date', dateFormat.format(soin.date)),
              if (soin.medicament != null)
                _buildInfoRow('Médicament', soin.medicament!),
              if (soin.dosage != null) _buildInfoRow('Dosage', soin.dosage!),
              if (soin.dateRappel != null)
                _buildInfoRow('Rappel', dateFormat.format(soin.dateRappel!)),
              if (soin.notes != null && soin.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    soin.notes!,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _supprimerPesee(Pesee pesee) async {
    final confirm = await DialogHelper.showConfirmation(
      context: context,
      title: 'Confirmer la suppression',
      message: 'Voulez-vous vraiment supprimer cette pesée ?',
      confirmLabel: 'Supprimer',
      isDangerous: true,
    );

    if (confirm == true && mounted) {
      final santeProvider = Provider.of<SanteProvider>(context, listen: false);
      await santeProvider.supprimerPesee(pesee.id!);
      _chargerDonnees();
    }
  }

  Future<void> _supprimerSoin(Soin soin) async {
    final confirm = await DialogHelper.showConfirmation(
      context: context,
      title: 'Confirmer la suppression',
      message: 'Voulez-vous vraiment supprimer ce soin ?',
      confirmLabel: 'Supprimer',
      isDangerous: true,
    );

    if (confirm == true && mounted) {
      final santeProvider = Provider.of<SanteProvider>(context, listen: false);
      await santeProvider.supprimerSoin(soin.id!);
      _chargerDonnees();
    }
  }
}
