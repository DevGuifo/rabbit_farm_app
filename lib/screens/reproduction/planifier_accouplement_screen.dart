import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/accouplement.dart';
import '../../models/lapin.dart';
import '../../providers/lapin_provider.dart';
import '../../providers/reproduction_provider.dart';
import '../../utils/snackbar_helper.dart';
import 'package:intl/intl.dart';

/// Écran pour planifier un nouvel accouplement
class PlanifierAccouplementScreen extends StatefulWidget {
  const PlanifierAccouplementScreen({super.key});

  @override
  State<PlanifierAccouplementScreen> createState() =>
      _PlanifierAccouplementScreenState();
}

class _PlanifierAccouplementScreenState
    extends State<PlanifierAccouplementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  Lapin? _maleSelectionne;
  Lapin? _femelleSelectionnee;
  DateTime _dateAccouplement = DateTime.now();
  DateTime? _dateMiseBasPrevue;

  @override
  void initState() {
    super.initState();
    _calculerDateMiseBasPrevue();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Calculer automatiquement la date de mise bas prévue (31 jours)
  void _calculerDateMiseBasPrevue() {
    setState(() {
      _dateMiseBasPrevue = Accouplement.calculerDateMiseBasPrevue(
        _dateAccouplement,
      );
    });
  }

  /// Sélectionner la date d'accouplement
  Future<void> _selectionnerDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateAccouplement,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _dateAccouplement) {
      setState(() {
        _dateAccouplement = picked;
        _calculerDateMiseBasPrevue();
      });
    }
  }

  /// Sélectionner un mâle reproducteur
  Future<void> _selectionnerMale(BuildContext context) async {
    final lapinProvider = Provider.of<LapinProvider>(context, listen: false);
    final males = lapinProvider.lapins.where((l) => l.sexe == 'Mâle').toList();

    if (males.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Aucun mâle disponible')));
      }
      return;
    }

    final Lapin? selected = await showDialog<Lapin>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner un mâle'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: males.length,
            itemBuilder: (context, index) {
              final male = males[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.male)),
                title: Text(male.nom),
                subtitle: Text('${male.race} - ${male.ageFormate}'),
                onTap: () => Navigator.of(context).pop(male),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _maleSelectionne = selected;
      });
    }
  }

  /// Sélectionner une femelle reproductrice
  Future<void> _selectionnerFemelle(BuildContext context) async {
    final lapinProvider = Provider.of<LapinProvider>(context, listen: false);
    final femelles = lapinProvider.lapins
        .where((l) => l.sexe == 'Femelle')
        .toList();

    if (femelles.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune femelle disponible')),
        );
      }
      return;
    }

    final Lapin? selected = await showDialog<Lapin>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner une femelle'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: femelles.length,
            itemBuilder: (context, index) {
              final femelle = femelles[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.female)),
                title: Text(femelle.nom),
                subtitle: Text('${femelle.race} - ${femelle.ageFormate}'),
                onTap: () => Navigator.of(context).pop(femelle),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _femelleSelectionnee = selected;
      });
    }
  }

  /// Enregistrer l'accouplement
  Future<void> _enregistrerAccouplement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_maleSelectionne == null) {
      SnackbarHelper.showValidationError(
        context,
        'Veuillez sélectionner un mâle',
      );
      return;
    }

    if (_femelleSelectionnee == null) {
      SnackbarHelper.showValidationError(
        context,
        'Veuillez sélectionner une femelle',
      );
      return;
    }

    final accouplement = Accouplement(
      maleId: _maleSelectionne!.id!,
      femelleId: _femelleSelectionnee!.id!,
      dateAccouplement: _dateAccouplement,
      dateMiseBasPrevue: _dateMiseBasPrevue!,
      statut: 'en_attente',
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    try {
      final reproductionProvider = Provider.of<ReproductionProvider>(
        context,
        listen: false,
      );
      await reproductionProvider.ajouterAccouplement(accouplement);

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          'Accouplement planifié avec succès',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Erreur : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Planifier un accouplement',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Sélection du mâle
            Card(
              child: ListTile(
                leading: const Icon(Icons.male, color: Colors.blue),
                title: Text(
                  _maleSelectionne?.nom ?? 'Sélectionner un mâle',
                  style: TextStyle(
                    fontWeight: _maleSelectionne != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: _maleSelectionne != null
                    ? Text(
                        '${_maleSelectionne!.race} - ${_maleSelectionne!.ageFormate}',
                      )
                    : const Text('Appuyez pour sélectionner'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectionnerMale(context),
              ),
            ),
            const SizedBox(height: 8),

            // Sélection de la femelle
            Card(
              child: ListTile(
                leading: const Icon(Icons.female, color: Colors.pink),
                title: Text(
                  _femelleSelectionnee?.nom ?? 'Sélectionner une femelle',
                  style: TextStyle(
                    fontWeight: _femelleSelectionnee != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: _femelleSelectionnee != null
                    ? Text(
                        '${_femelleSelectionnee!.race} - ${_femelleSelectionnee!.ageFormate}',
                      )
                    : const Text('Appuyez pour sélectionner'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectionnerFemelle(context),
              ),
            ),
            const SizedBox(height: 16),

            // Date d'accouplement
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date d\'accouplement'),
                subtitle: Text(dateFormat.format(_dateAccouplement)),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectionnerDate(context),
              ),
            ),
            const SizedBox(height: 8),

            // Date de mise bas prévue (automatique)
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                leading: const Icon(Icons.event_available),
                title: const Text('Mise bas prévue'),
                subtitle: Text(
                  _dateMiseBasPrevue != null
                      ? dateFormat.format(_dateMiseBasPrevue!)
                      : 'Non calculée',
                ),
                trailing: const Chip(label: Text('Auto')),
              ),
            ),
            const SizedBox(height: 16),

            // Informations calculées
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dates importantes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.healing,
                      'Palpation recommandée',
                      dateFormat.format(
                        _dateAccouplement.add(const Duration(days: 11)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.home,
                      'Préparation du nid',
                      _dateMiseBasPrevue != null
                          ? dateFormat.format(
                              _dateMiseBasPrevue!.subtract(
                                const Duration(days: 3),
                              ),
                            )
                          : '-',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                hintText: 'Observations, conditions particulières...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Bouton enregistrer
            FilledButton.icon(
              onPressed: _enregistrerAccouplement,
              icon: const Icon(Icons.save),
              label: const Text('Planifier l\'accouplement'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: TextStyle(color: Colors.grey[600])),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
