import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/medicament.dart';
import '../services/database_helper.dart';
import '../theme/app_theme.dart';

/// Sélecteur de médicament avec dropdown et option d'ajout
class MedicamentSelector extends StatefulWidget {
  final int? medicamentIdInitial;
  final Function(int?, String?) onMedicamentSelected; // (id, nom)

  const MedicamentSelector({
    super.key,
    this.medicamentIdInitial,
    required this.onMedicamentSelected,
  });

  @override
  State<MedicamentSelector> createState() => _MedicamentSelectorState();
}

class _MedicamentSelectorState extends State<MedicamentSelector> {
  final _dbHelper = DatabaseHelper.instance;
  List<Medicament> _medicaments = [];
  Medicament? _medicamentSelectionne;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _chargerMedicaments();
  }

  Future<void> _chargerMedicaments() async {
    setState(() => _loading = true);

    final db = await _dbHelper.database;
    final result = await db.query('medicaments', orderBy: 'nom ASC');

    _medicaments = result.map((map) => Medicament.fromMap(map)).toList();

    // Pré-sélectionner le médicament initial
    if (widget.medicamentIdInitial != null) {
      _medicamentSelectionne = _medicaments.firstWhere(
        (m) => m.id == widget.medicamentIdInitial,
        orElse: () => _medicaments.first,
      );
    }

    setState(() => _loading = false);
  }

  void _selectionnerMedicament(Medicament? medicament) {
    setState(() => _medicamentSelectionne = medicament);
    widget.onMedicamentSelected(medicament?.id, medicament?.nom);
  }

  Future<void> _ajouterMedicament() async {
    final nomController = TextEditingController();
    final typeController = TextEditingController(text: 'autre');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).widgetAjouterMedicament),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).widgetNomMedicament,
                hintText: AppLocalizations.of(context).widgetHintMedicament,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: typeController.text,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).widgetType,
              ),
              items: [
                DropdownMenuItem(
                  value: 'vaccin',
                  child: Text(AppLocalizations.of(context).widgetVaccin),
                ),
                DropdownMenuItem(
                  value: 'antibiotique',
                  child: Text(AppLocalizations.of(context).widgetAntibiotique),
                ),
                DropdownMenuItem(
                  value: 'antiparasitaire',
                  child: Text(
                    AppLocalizations.of(context).widgetAntiparasitaire,
                  ),
                ),
                DropdownMenuItem(
                  value: 'autre',
                  child: Text(AppLocalizations.of(context).widgetAutre),
                ),
              ],
              onChanged: (v) => typeController.text = v ?? 'autre',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nomController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).widgetNomObligatoire,
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text(AppLocalizations.of(context).widgetAjouter),
          ),
        ],
      ),
    );

    if (result == true && nomController.text.trim().isNotEmpty) {
      // Créer le médicament
      final db = await _dbHelper.database;
      final id = await db.insert('medicaments', {
        'nom': nomController.text.trim(),
        'type_medicament': typeController.text,
        'quantite_stock': 0.0,
        'unite': 'ml',
        'date_creation': DateTime.now().toIso8601String(),
      });

      // Recharger la liste
      await _chargerMedicaments();

      // Sélectionner le nouveau médicament
      final nouveau = _medicaments.firstWhere((m) => m.id == id);
      _selectionnerMedicament(nouveau);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).widgetMedicamentAjoute(nouveau.nom),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark
        ? AppTheme.stitchGreenLight
        : AppTheme.textSecondary;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Médicament administré (Optionnel)',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<Medicament>(
                initialValue: _medicamentSelectionne,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(
                    context,
                  ).widgetSelectionnerMedicament,
                  prefixIcon: const Icon(Icons.medication_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _medicaments.map((med) {
                  return DropdownMenuItem(value: med, child: Text(med.nom));
                }).toList(),
                onChanged: _selectionnerMedicament,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _ajouterMedicament,
              tooltip: 'Ajouter un nouveau médicament',
              color: AppTheme.primaryNeonGreen,
            ),
          ],
        ),
      ],
    );
  }
}
