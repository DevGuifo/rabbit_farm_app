import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/depense.dart';
import '../../providers/finance_provider.dart';
import '../../theme/app_theme.dart';

class AjouterDepenseScreen extends StatefulWidget {
  const AjouterDepenseScreen({super.key});

  @override
  State<AjouterDepenseScreen> createState() => _AjouterDepenseScreenState();
}

class _AjouterDepenseScreenState extends State<AjouterDepenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final DateFormat _formatDate = DateFormat('dd/MM/yyyy');

  DateTime _dateSelectionnee = DateTime.now();
  String _categorieSelectionnee = 'alimentation';

  @override
  void dispose() {
    _montantController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Ajouter une dépense',
          style: AppTheme.titleLarge.copyWith(
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
            // Date
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(_formatDate.format(_dateSelectionnee)),
                onTap: _selectionnerDate,
              ),
            ),
            const SizedBox(height: 16),

            // Catégorie
            DropdownButtonFormField<String>(
              initialValue: _categorieSelectionnee,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'alimentation',
                  child: Text('Alimentation'),
                ),
                DropdownMenuItem(
                  value: 'veterinaire',
                  child: Text('Vétérinaire'),
                ),
                DropdownMenuItem(
                  value: 'equipement',
                  child: Text('Équipement'),
                ),
                DropdownMenuItem(value: 'autre', child: Text('Autre')),
              ],
              onChanged: (value) {
                setState(() {
                  _categorieSelectionnee = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Montant
            TextFormField(
              controller: _montantController,
              decoration: const InputDecoration(
                labelText: 'Montant (€)',
                prefixIcon: Icon(Icons.euro),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir un montant';
                }
                final montant = double.tryParse(value);
                if (montant == null || montant <= 0) {
                  return 'Veuillez saisir un montant valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir une description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Bouton d'ajout
            ElevatedButton.icon(
              onPressed: _enregistrer,
              icon: const Icon(Icons.check),
              label: const Text('Enregistrer la dépense'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppTheme.error,
                foregroundColor: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectionnerDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateSelectionnee,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );

    if (date != null) {
      setState(() {
        _dateSelectionnee = date;
      });
    }
  }

  void _enregistrer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final montant = double.parse(_montantController.text);
    final depense = Depense(
      date: _dateSelectionnee,
      categorie: _categorieSelectionnee,
      montant: montant,
      description: _descriptionController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    try {
      await Provider.of<FinanceProvider>(
        context,
        listen: false,
      ).ajouterDepense(depense);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dépense ajoutée avec succès'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout : $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}
