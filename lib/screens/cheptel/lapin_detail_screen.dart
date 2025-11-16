import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/lapin.dart';
import '../../services/database_helper.dart';
import '../../services/pdf_service.dart';
import '../../utils/dialog_helper.dart';
import '../../utils/snackbar_helper.dart';
import '../../providers/lapin_provider.dart';
import '../deces/enregistrer_deces_screen.dart';

class LapinDetailScreen extends StatefulWidget {
  final Lapin lapin;

  const LapinDetailScreen({super.key, required this.lapin});

  @override
  State<LapinDetailScreen> createState() => _LapinDetailScreenState();
}

class _LapinDetailScreenState extends State<LapinDetailScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final PdfService _pdfService = PdfService();
  final DateFormat _formatDate = DateFormat('dd/MM/yyyy');

  Map<String, Lapin?> _parents = {};
  int _nombrePesees = 0;
  int _nombreSoins = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    setState(() => _isLoading = true);

    final relations = await _db.getRelationByLapinId(widget.lapin.id!);
    if (relations != null) {
      if (relations['pereId'] != null) {
        _parents['pere'] = await _db.getLapinById(relations['pereId']!);
      }
      if (relations['mereId'] != null) {
        _parents['mere'] = await _db.getLapinById(relations['mereId']!);
      }
    }

    final pesees = await _db.getPeseesByLapin(widget.lapin.id!);
    final soins = await _db.getSoinsByLapin(widget.lapin.id!);

    setState(() {
      _nombrePesees = pesees.length;
      _nombreSoins = soins.length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.lapin.nom,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exporter en PDF',
            onPressed: _exporterPDF,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'decede') {
                _marquerCommeDecede();
              } else if (value == 'supprimer') {
                _supprimerLapin();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'decede',
                child: ListTile(
                  leading: Icon(Icons.cancel, color: Colors.orange),
                  title: Text('Marquer comme décédé'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'supprimer',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Supprimer'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte principale
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo du lapin
                          Center(
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: widget.lapin.photoPath != null
                                    ? Image.file(
                                        File(widget.lapin.photoPath!),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.pets,
                                                size: 80,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              );
                                            },
                                      )
                                    : Icon(
                                        Icons.pets,
                                        size: 80,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(Icons.badge, 'Nom', widget.lapin.nom),
                          _buildInfoRow(Icons.pets, 'Race', widget.lapin.race),
                          _buildInfoRow(
                            Icons.wc,
                            'Sexe',
                            widget.lapin.sexe == 'male' ? 'Mâle' : 'Femelle',
                          ),
                          _buildInfoRow(
                            Icons.cake,
                            'Date de naissance',
                            _formatDate.format(widget.lapin.dateNaissance),
                          ),
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Âge',
                            _calculerAge(widget.lapin.dateNaissance),
                          ),
                          _buildInfoRow(
                            Icons.monitor_weight,
                            'Poids actuel',
                            widget.lapin.poids != null
                                ? '${widget.lapin.poids!.toStringAsFixed(2)} kg'
                                : 'Non pesé',
                          ),
                          _buildInfoRow(
                            Icons.info,
                            'Statut',
                            widget.lapin.statut ?? 'Inconnu',
                          ),
                          if (widget.lapin.localisation != null)
                            _buildInfoRow(
                              Icons.location_on,
                              'Localisation',
                              widget.lapin.localisation!,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Parents
                  if (_parents.isNotEmpty) ...[
                    Text(
                      'Généalogie',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            if (_parents['pere'] != null)
                              _buildParentRow(
                                Icons.male,
                                'Père',
                                _parents['pere']!,
                              ),
                            if (_parents['mere'] != null)
                              _buildParentRow(
                                Icons.female,
                                'Mère',
                                _parents['mere']!,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Statistiques
                  Text('Suivi', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(Icons.monitor_weight, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  '$_nombrePesees',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                const Text('Pesées'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(Icons.medical_services, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  '$_nombreSoins',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                const Text('Soins'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exporterPDF,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Exporter PDF'),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  valeur,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentRow(IconData icon, String label, Lapin parent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${parent.nom} (${parent.race})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculerAge(DateTime dateNaissance) {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(dateNaissance);

    final annees = difference.inDays ~/ 365;
    final mois = (difference.inDays % 365) ~/ 30;

    if (annees > 0) {
      return '$annees an${annees > 1 ? 's' : ''} et $mois mois';
    }
    return '$mois mois';
  }

  Future<void> _exporterPDF() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _pdfService.genererFicheLapin(widget.lapin);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF généré avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération du PDF : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _marquerCommeDecede() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnregistrerDecesScreen(lapin: widget.lapin),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context); // Retour à l'écran précédent
    }
  }

  Future<void> _supprimerLapin() async {
    final confirm = await DialogHelper.showConfirmation(
      context: context,
      title: 'Supprimer le lapin',
      message:
          'Voulez-vous vraiment supprimer ${widget.lapin.nom} ?\n\nCette action est irréversible et supprimera toutes les données associées.',
      isDangerous: true,
    );

    if (confirm == true && mounted) {
      try {
        final lapinProvider = context.read<LapinProvider>();
        await lapinProvider.supprimerLapin(widget.lapin.id!);

        if (mounted) {
          Navigator.pop(context); // Retour à l'écran précédent
          SnackbarHelper.showSuccess(
            context,
            '${widget.lapin.nom} supprimé avec succès',
          );
        }
      } catch (e) {
        if (mounted) {
          SnackbarHelper.showError(context, 'Erreur: $e');
        }
      }
    }
  }
}
