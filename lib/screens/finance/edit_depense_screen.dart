import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/depense.dart';
import '../../providers/finance_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';

class EditDepenseScreen extends StatefulWidget {
  final Depense depense;

  const EditDepenseScreen({super.key, required this.depense});

  @override
  State<EditDepenseScreen> createState() => _EditDepenseScreenState();
}

class _EditDepenseScreenState extends State<EditDepenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _montantController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notesController;
  final DateFormat _formatDate = DateFormat('dd/MM/yyyy');

  late DateTime _dateSelectionnee;
  late String _categorieSelectionnee;

  @override
  void initState() {
    super.initState();

    // Pré-remplir avec les données existantes
    _montantController = TextEditingController(
      text: widget.depense.montant.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.depense.description,
    );
    _notesController = TextEditingController(text: widget.depense.notes ?? '');

    _dateSelectionnee = widget.depense.date;
    _categorieSelectionnee = widget.depense.categorie;
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
      appBar: UniformAppBar(
        title: AppLocalizations.of(context).screenModifierDepense,
        icon: Icons.edit_rounded,
        iconColor: AppTheme.error,
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
            DropdownButtonFormField<String>(
              initialValue: _categorieSelectionnee,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).financeCategorie,
                prefixIcon: const Icon(Icons.category),
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'alimentation',
                  child: Text(
                    AppLocalizations.of(context).financeCategorieAlimentation,
                  ),
                ),
                DropdownMenuItem(
                  value: 'veterinaire',
                  child: Text(
                    AppLocalizations.of(context).financeCategorieSante,
                  ),
                ),
                DropdownMenuItem(
                  value: 'equipement',
                  child: Text(
                    AppLocalizations.of(context).financeCategorieEquipement,
                  ),
                ),
                DropdownMenuItem(
                  value: 'autre',
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
                  return AppLocalizations.of(
                    context,
                  ).financeVeuillezSaisirMontant;
                }
                final montant = double.tryParse(value);
                if (montant == null || montant <= 0) {
                  return AppLocalizations.of(context).financeMontantInvalide;
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
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(
                    context,
                  ).financeVeuillezSaisirDescription;
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
                    label: Text(AppLocalizations.of(context).actionAnnuler),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _modifier,
                    icon: const Icon(Icons.save),
                    label: Text(AppLocalizations.of(context).actionEnregistrer),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: AppTheme.error,
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
    final depenseModifiee = widget.depense.copyWith(
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
      ).modifierDepense(depenseModifiee);

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          AppLocalizations.of(context).financeDepenseModifiee,
        );
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
