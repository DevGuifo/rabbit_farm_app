import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/lapin.dart';
import '../../models/soin.dart';
import '../../providers/sante_provider.dart';
import '../../utils/snackbar_helper.dart';

/// Écran pour ajouter un soin
class AjouterSoinScreen extends StatefulWidget {
  final Lapin lapin;

  const AjouterSoinScreen({super.key, required this.lapin});

  @override
  State<AjouterSoinScreen> createState() => _AjouterSoinScreenState();
}

class _AjouterSoinScreenState extends State<AjouterSoinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _medicamentController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  String _typeSoin = 'vaccination';
  DateTime _date = DateTime.now();
  DateTime? _dateRappel;
  bool _avecRappel = false;

  final List<String> _typesSoins = [
    'vaccination',
    'traitement',
    'vermifuge',
    'autre',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _medicamentController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectionnerDate(BuildContext context, bool isRappel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isRappel
          ? (_dateRappel ?? DateTime.now().add(const Duration(days: 30)))
          : _date,
      firstDate: isRappel ? DateTime.now() : widget.lapin.dateNaissance,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() {
        if (isRappel) {
          _dateRappel = picked;
        } else {
          _date = picked;
        }
      });
    }
  }

  Future<void> _enregistrerSoin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final soin = Soin(
      lapinId: widget.lapin.id!,
      date: _date,
      type: _typeSoin,
      description: _descriptionController.text,
      medicament: _medicamentController.text.isNotEmpty
          ? _medicamentController.text
          : null,
      dosage: _dosageController.text.isNotEmpty ? _dosageController.text : null,
      dateRappel: _avecRappel ? _dateRappel : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    try {
      final santeProvider = Provider.of<SanteProvider>(context, listen: false);
      await santeProvider.ajouterSoin(soin);

      if (mounted) {
        SnackbarHelper.showSuccess(context, 'Soin enregistré avec succès');
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
          'Soin de ${widget.lapin.nom}',
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
            // Informations du lapin
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: widget.lapin.sexe == 'Mâle'
                          ? Colors.blue.shade100
                          : Colors.pink.shade100,
                      child: Icon(
                        widget.lapin.sexe == 'Mâle' ? Icons.male : Icons.female,
                        color: widget.lapin.sexe == 'Mâle'
                            ? Colors.blue
                            : Colors.pink,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.lapin.nom,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.lapin.race} • ${widget.lapin.ageFormate}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date du soin
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date du soin'),
                subtitle: Text(dateFormat.format(_date)),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectionnerDate(context, false),
              ),
            ),
            const SizedBox(height: 16),

            // Type de soin
            DropdownButtonFormField<String>(
              value: _typeSoin,
              decoration: const InputDecoration(
                labelText: 'Type de soin',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _typesSoins.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeLabel(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _typeSoin = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Ex: Vaccination myxomatose',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Médicament
            TextFormField(
              controller: _medicamentController,
              decoration: const InputDecoration(
                labelText: 'Médicament (optionnel)',
                hintText: 'Nom du médicament',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
            ),
            const SizedBox(height: 16),

            // Dosage
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage (optionnel)',
                hintText: 'Ex: 1ml',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication_liquid),
              ),
            ),
            const SizedBox(height: 16),

            // Option rappel
            Card(
              child: SwitchListTile(
                title: const Text('Prévoir un rappel'),
                subtitle: _avecRappel && _dateRappel != null
                    ? Text('Rappel le ${dateFormat.format(_dateRappel!)}')
                    : const Text('Aucun rappel'),
                value: _avecRappel,
                onChanged: (value) {
                  setState(() {
                    _avecRappel = value;
                    if (value && _dateRappel == null) {
                      _dateRappel = _date.add(const Duration(days: 30));
                    }
                  });
                },
                secondary: const Icon(Icons.notification_add),
              ),
            ),

            if (_avecRappel)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton.icon(
                  onPressed: () => _selectionnerDate(context, true),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _dateRappel != null
                        ? 'Modifier la date du rappel'
                        : 'Choisir la date du rappel',
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                hintText: 'Observations complémentaires...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Bouton enregistrer
            FilledButton.icon(
              onPressed: _enregistrerSoin,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer le soin'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'vaccination':
        return 'Vaccination';
      case 'traitement':
        return 'Traitement';
      case 'vermifuge':
        return 'Vermifuge';
      case 'autre':
        return 'Autre';
      default:
        return type;
    }
  }
}
