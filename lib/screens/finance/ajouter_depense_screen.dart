import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/depense.dart';
import '../../models/enums/finance_enums.dart';
import '../../providers/finance_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

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
  CategorieDepense _categorieSelectionnee = CategorieDepense.alimentation;

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
        title: AppLocalizations.of(context).financeAjouterDepense,
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
            DropdownButtonFormField<CategorieDepense>(
              initialValue: _categorieSelectionnee,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).financeCategorie,
                prefixIcon: const Icon(Icons.category),
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: CategorieDepense.alimentation,
                  child: Text(
                    AppLocalizations.of(context).financeCategorieAlimentation,
                  ),
                ),
                DropdownMenuItem(
                  value: CategorieDepense.veterinaire,
                  child: Text(
                    AppLocalizations.of(context).financeCategorieSante,
                  ),
                ),
                DropdownMenuItem(
                  value: CategorieDepense.equipement,
                  child: Text(
                    AppLocalizations.of(context).financeCategorieEquipement,
                  ),
                ),
                DropdownMenuItem(
                  value: CategorieDepense.autre,
                  child: Text(
                    AppLocalizations.of(context).financesCategorieAutre,
                  ),
                ),
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
