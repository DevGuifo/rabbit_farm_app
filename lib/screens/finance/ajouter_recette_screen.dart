import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/enums/finance_enums.dart';
import '../../models/recette.dart';
import '../../models/lapin.dart';
import '../../providers/finance_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class AjouterRecetteScreen extends StatefulWidget {
  const AjouterRecetteScreen({super.key});

  @override
  State<AjouterRecetteScreen> createState() => _AjouterRecetteScreenState();
}

class _AjouterRecetteScreenState extends State<AjouterRecetteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final DateFormat _formatDate = DateFormat('dd/MM/yyyy');

  DateTime _dateSelectionnee = DateTime.now();
  CategorieRecette _categorieSelectionnee = CategorieRecette.venteLapin;
  Lapin? _lapinSelectionne;

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
      appBar: SimpleAppBar(
        title: AppLocalizations.of(context).financeAjouterRecette,
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
                title: Text(AppLocalizations.of(context).financeDate),
                subtitle: Text(_formatDate.format(_dateSelectionnee)),
                onTap: _selectionnerDate,
              ),
            ),
            const SizedBox(height: 16),

            // Catégorie
            DropdownButtonFormField<CategorieRecette>(
              initialValue: _categorieSelectionnee,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).financeCategorie,
                prefixIcon: const Icon(Icons.category),
                border: const OutlineInputBorder(),
              ),
              items: CategorieRecette.values
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat.label),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _categorieSelectionnee = value!;
                  // Réinitialiser la sélection du lapin si la catégorie change
                  if (value != CategorieRecette.venteLapin) {
                    _lapinSelectionne = null;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Sélection du lapin (uniquement pour vente_lapin)
            if (_categorieSelectionnee == CategorieRecette.venteLapin) ...[
              Consumer<LapinProvider>(
                builder: (context, lapinProvider, child) {
                  return DropdownButtonFormField<Lapin>(
                    initialValue: _lapinSelectionne,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).financeLapinVendu,
                      prefixIcon: const Icon(Icons.pets),
                      border: const OutlineInputBorder(),
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
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).financeMontant,
                prefixIcon: const Icon(Icons.euro),
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context).erreurMontantInvalide;
                }
                final montant = double.tryParse(value);
                if (montant == null || montant <= 0) {
                  return AppLocalizations.of(context).erreurMontantInvalide;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).financeDescription,
                prefixIcon: const Icon(Icons.description),
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context).erreurDescriptionRequise;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).financeNotes,
                prefixIcon: const Icon(Icons.note),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            // Espace pour FormActionBar
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: FormActionBar(
        onCancel: () => Navigator.pop(context),
        onSave: _enregistrer,
        saveText: AppLocalizations.of(context).commonSave,
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
    final recette = Recette(
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
      ).ajouterRecette(recette);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recette ajoutée avec succès'),
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
