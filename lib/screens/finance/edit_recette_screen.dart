import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/recette.dart';
import '../../models/lapin.dart';
import '../../providers/finance_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../theme/app_theme.dart';

class EditRecetteScreen extends StatefulWidget {
  final Recette recette;

  const EditRecetteScreen({super.key, required this.recette});

  @override
  State<EditRecetteScreen> createState() => _EditRecetteScreenState();
}

class _EditRecetteScreenState extends State<EditRecetteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _montantController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notesController;
  final DateFormat _formatDate = DateFormat('dd/MM/yyyy');

  late DateTime _dateSelectionnee;
  late String _categorieSelectionnee;
  Lapin? _lapinSelectionne;

  @override
  void initState() {
    super.initState();

    // Pré-remplir avec les données existantes
    _montantController = TextEditingController(
      text: widget.recette.montant.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.recette.description,
    );
    _notesController = TextEditingController(text: widget.recette.notes ?? '');

    _dateSelectionnee = widget.recette.date;
    _categorieSelectionnee = widget.recette.categorie;

    _chargerLapin();
  }

  Future<void> _chargerLapin() async {
    if (widget.recette.lapinId != null) {
      final lapinProvider = Provider.of<LapinProvider>(context, listen: false);
      await lapinProvider.chargerLapins();
      final lapin = lapinProvider.lapins.firstWhere(
        (l) => l.id == widget.recette.lapinId,
        orElse: () => lapinProvider.lapins.first,
      );
      setState(() {
        _lapinSelectionne = lapin;
      });
    }
  }

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
          'Modifier une recette',
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
              initialValue:  _categorieSelectionnee,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'vente_lapin',
                  child: Text('Vente d\'un lapin'),
                ),
                DropdownMenuItem(
                  value: 'vente_portee',
                  child: Text('Vente d\'une portée'),
                ),
                DropdownMenuItem(value: 'autre', child: Text('Autre')),
              ],
              onChanged: (value) {
                setState(() {
                  _categorieSelectionnee = value!;
                  // Réinitialiser la sélection du lapin si la catégorie change
                  if (value != 'vente_lapin') {
                    _lapinSelectionne = null;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Sélection du lapin (uniquement pour vente_lapin)
            if (_categorieSelectionnee == 'vente_lapin') ...[
              Consumer<LapinProvider>(
                builder: (context, lapinProvider, child) {
                  return DropdownButtonFormField<Lapin>(
                    initialValue:  _lapinSelectionne,
                    decoration: const InputDecoration(
                      labelText: 'Lapin vendu (optionnel)',
                      prefixIcon: Icon(Icons.pets),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<Lapin>(
                        value: null,
                        child: Text('- Aucun -'),
                      ),
                      ...lapinProvider.lapins.map(
                        (lapin) => DropdownMenuItem(
                          value: lapin,
                          child: Text('${lapin.nom} (${lapin.race})'),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _lapinSelectionne = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

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

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Annuler'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _modifier,
                    icon: const Icon(Icons.check),
                    label: const Text('Enregistrer'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: AppTheme.success,
                      foregroundColor: AppTheme.textOnPrimary,
                    ),
                  ),
                ),
              ],
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

  void _modifier() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final montant = double.parse(_montantController.text);
    final recetteModifiee = widget.recette.copyWith(
      date: _dateSelectionnee,
      categorie: _categorieSelectionnee,
      montant: montant,
      description: _descriptionController.text,
      lapinId: _lapinSelectionne?.id,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    try {
      await Provider.of<FinanceProvider>(
        context,
        listen: false,
      ).modifierRecette(recetteModifiee);

      if (mounted) {
        SnackbarHelper.showSuccess(context, 'Recette modifiée avec succès');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          'Erreur lors de la modification : $e',
        );
      }
    }
  }
}
