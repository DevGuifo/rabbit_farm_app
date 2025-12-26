import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/portee.dart';
import '../../models/lapin.dart';
import '../../providers/reproduction_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../services/database_helper.dart';

/// Écran pour modifier une portée existante
class EditPorteeScreen extends StatefulWidget {
  final Portee portee;

  const EditPorteeScreen({super.key, required this.portee});

  @override
  State<EditPorteeScreen> createState() => _EditPorteeScreenState();
}

class _EditPorteeScreenState extends State<EditPorteeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreNesController;
  late final TextEditingController _nombreVivantsController;
  late final TextEditingController _nombreMortsController;
  late final TextEditingController _notesController;

  late DateTime _dateMiseBasReelle;
  Lapin? _male;
  Lapin? _femelle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Pré-remplir avec les données existantes
    _nombreNesController = TextEditingController(
      text: widget.portee.nombreNes.toString(),
    );
    _nombreVivantsController = TextEditingController(
      text: widget.portee.nombreVivants.toString(),
    );
    _nombreMortsController = TextEditingController(
      text: widget.portee.nombreMorts.toString(),
    );
    _notesController = TextEditingController(text: widget.portee.notes ?? '');
    _dateMiseBasReelle = widget.portee.dateMiseBasReelle;

    _chargerLapins();
  }

  @override
  void dispose() {
    _nombreNesController.dispose();
    _nombreVivantsController.dispose();
    _nombreMortsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Charger les informations des parents
  Future<void> _chargerLapins() async {
    final db = DatabaseHelper.instance;
    final accouplement = await db.getAccouplementById(
      widget.portee.accouplementId,
    );

    if (accouplement != null) {
      final male = await db.getLapinById(accouplement.maleId);
      final femelle = await db.getLapinById(accouplement.femelleId);

      setState(() {
        _male = male;
        _femelle = femelle;
        _isLoading = false;
      });
    }
  }

  /// Calculer automatiquement le nombre de morts
  void _calculerMorts() {
    final nes = int.tryParse(_nombreNesController.text) ?? 0;
    final vivants = int.tryParse(_nombreVivantsController.text) ?? 0;
    final morts = (nes - vivants).clamp(0, nes);
    _nombreMortsController.text = morts.toString();
  }

  /// Sélectionner la date de mise bas
  Future<void> _selectionnerDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateMiseBasReelle,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _dateMiseBasReelle) {
      setState(() {
        _dateMiseBasReelle = picked;
      });
    }
  }

  /// Modifier la portée
  Future<void> _modifierPortee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nombreNes = int.parse(_nombreNesController.text);
    final nombreVivants = int.parse(_nombreVivantsController.text);
    final nombreMorts = int.parse(_nombreMortsController.text);

    if (nombreVivants + nombreMorts != nombreNes) {
      SnackbarHelper.showValidationError(
        context,
        'Le total vivants + morts doit être égal au nombre de nés',
      );
      return;
    }

    final porteeModifiee = widget.portee.copyWith(
      dateMiseBasReelle: _dateMiseBasReelle,
      nombreNes: nombreNes,
      nombreVivants: nombreVivants,
      nombreMorts: nombreMorts,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    try {
      final reproductionProvider = Provider.of<ReproductionProvider>(
        context,
        listen: false,
      );
      await reproductionProvider.modifierPortee(porteeModifiee);

      if (mounted) {
        SnackbarHelper.showSuccess(context, 'Portée modifiée avec succès');
        Navigator.of(context).pop(true);
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

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Modifier portée',
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
            // Informations parents
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Parents',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.male, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _male?.nom ?? 'Inconnu',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.female, color: Colors.pink, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _femelle?.nom ?? 'Inconnue',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date de mise bas
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date de mise bas réelle'),
                subtitle: Text(dateFormat.format(_dateMiseBasReelle)),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectionnerDate(context),
              ),
            ),
            const SizedBox(height: 16),

            // Nombre de nés
            TextFormField(
              controller: _nombreNesController,
              decoration: const InputDecoration(
                labelText: 'Nombre de lapereaux nés',
                prefixIcon: Icon(Icons.baby_changing_station),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _calculerMorts(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nombre de nés';
                }
                final nombre = int.tryParse(value);
                if (nombre == null || nombre < 0) {
                  return 'Veuillez entrer un nombre valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nombre de vivants
            TextFormField(
              controller: _nombreVivantsController,
              decoration: const InputDecoration(
                labelText: 'Nombre de vivants',
                prefixIcon: Icon(Icons.favorite, color: Colors.green),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _calculerMorts(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nombre de vivants';
                }
                final nombre = int.tryParse(value);
                if (nombre == null || nombre < 0) {
                  return 'Veuillez entrer un nombre valide';
                }
                final nes = int.tryParse(_nombreNesController.text) ?? 0;
                if (nombre > nes) {
                  return 'Ne peut pas être supérieur au nombre de nés';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nombre de morts (calculé automatiquement)
            TextFormField(
              controller: _nombreMortsController,
              decoration: const InputDecoration(
                labelText: 'Nombre de morts (calculé auto)',
                prefixIcon: Icon(Icons.heart_broken, color: Colors.red),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: false,
            ),
            const SizedBox(height: 16),

            // Avertissement
            Card(
              color: Colors.orange.shade100,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Note: La modification ne crée pas de nouveaux lapereaux. Gérez-les manuellement si nécessaire.',
                        style: TextStyle(fontSize: 12),
                      ),
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
                hintText: 'Observations sur la mise bas...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
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
                  child: FilledButton.icon(
                    onPressed: _modifierPortee,
                    icon: const Icon(Icons.save),
                    label: const Text('Enregistrer'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
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
}
