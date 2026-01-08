import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/medicament_provider.dart';
import '../../../models/medicament.dart';
import '../../../utils/dialog_helper.dart';
import '../../../theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class MedicamentDialogs {
  static Future<void> showAjouterMedicamentDialog(BuildContext context) async {
    final nomController = TextEditingController();
    final quantiteController = TextEditingController();
    final seuilController = TextEditingController();
    final prixController = TextEditingController();
    final posologieController = TextEditingController();
    final notesController = TextEditingController();
    String type = 'antibiotique';
    String unite = 'ml';
    DateTime? dateExpiration;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).commonAdd),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).rentabiliteFormNom,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).rentabiliteFormType,
                    border: const OutlineInputBorder(),
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
                        initialValue: unite,
                        decoration: const InputDecoration(
                          labelText: 'Unité',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'ml',
                            child: Text(AppLocalizations.of(context).uniteMl),
                          ),
                          DropdownMenuItem(
                            value: 'g',
                            child: Text(AppLocalizations.of(context).uniteG),
                          ),
                          DropdownMenuItem(
                            value: 'cp',
                            child: Text(AppLocalizations.of(context).uniteCp),
                          ),
                          DropdownMenuItem(
                            value: 'dose',
                            child: Text(AppLocalizations.of(context).uniteDose),
                          ),
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
                  decoration: InputDecoration(
                    labelText: "Seuil d'alerte",
                    border: const OutlineInputBorder(),
                    helperText: AppLocalizations.of(context).helperAlerteStock,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    dateExpiration == null
                        ? "Date d'expiration"
                        : 'Expire le: ${DateFormat('dd/MM/yyyy').format(dateExpiration!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppTheme.border),
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
                    if (date != null) setState(() => dateExpiration = date);
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
                  decoration: InputDecoration(
                    labelText: 'Posologie',
                    border: const OutlineInputBorder(),
                    helperText: AppLocalizations.of(
                      context,
                    ).helperExemplePosologie,
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
              child: Text(AppLocalizations.of(context).commonCancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (nomController.text.isEmpty ||
                    quantiteController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).msgNomQuantiteRequis,
                      ),
                    ),
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
              child: Text(AppLocalizations.of(context).commonAdd),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showModifierMedicamentDialog(
    BuildContext context,
    Medicament medicament,
  ) async {
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

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).commonEdit),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).rentabiliteFormNom,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).rentabiliteFormType,
                    border: const OutlineInputBorder(),
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
                        initialValue: unite,
                        decoration: const InputDecoration(
                          labelText: 'Unité',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'ml',
                            child: Text(AppLocalizations.of(context).uniteMl),
                          ),
                          DropdownMenuItem(
                            value: 'g',
                            child: Text(AppLocalizations.of(context).uniteG),
                          ),
                          DropdownMenuItem(
                            value: 'cp',
                            child: Text(AppLocalizations.of(context).uniteCp),
                          ),
                          DropdownMenuItem(
                            value: 'dose',
                            child: Text(AppLocalizations.of(context).uniteDose),
                          ),
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
                    labelText: "Seuil d'alerte",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    dateExpiration == null
                        ? "Date d'expiration"
                        : 'Expire le: ${DateFormat('dd/MM/yyyy').format(dateExpiration!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppTheme.border),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: dateExpiration ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) setState(() => dateExpiration = date);
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
              child: Text(AppLocalizations.of(context).commonCancel),
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
              child: Text(AppLocalizations.of(context).commonEdit),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showUtiliserDialog(
    BuildContext context,
    Medicament medicament,
  ) async {
    final quantiteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).titleUtiliser(medicament.nom)),
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
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (quantiteController.text.isEmpty) return;
              final quantite = double.parse(quantiteController.text);
              if (quantite > medicament.quantiteStock) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).msgQuantiteSupStock,
                    ),
                  ),
                );
                return;
              }
              final nouveauStock = medicament.quantiteStock - quantite;
              context.read<MedicamentProvider>().modifierMedicament(
                medicament.copyWith(quantiteStock: nouveauStock),
              );
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).confirmer),
          ),
        ],
      ),
    );
  }

  static Future<void> showReapprovisionnerDialog(
    BuildContext context,
    Medicament medicament,
  ) async {
    final quantiteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context).titleReapprovisionner(medicament.nom),
        ),
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
            child: Text(AppLocalizations.of(context).commonCancel),
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
            child: Text(AppLocalizations.of(context).confirmer),
          ),
        ],
      ),
    );
  }

  static Future<void> confirmerSuppression(
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
