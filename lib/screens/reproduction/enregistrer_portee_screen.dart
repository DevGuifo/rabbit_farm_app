import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/accouplement.dart';
import '../../models/portee.dart';
import '../../models/lapin.dart';
import '../../providers/reproduction_provider.dart';
import '../../providers/lapin_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../services/database_helper.dart';

/// Écran pour enregistrer une portée
class EnregistrerPorteeScreen extends StatefulWidget {
  final Accouplement accouplement;

  const EnregistrerPorteeScreen({super.key, required this.accouplement});

  @override
  State<EnregistrerPorteeScreen> createState() =>
      _EnregistrerPorteeScreenState();
}

class _EnregistrerPorteeScreenState extends State<EnregistrerPorteeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreNesController = TextEditingController();
  final _nombreVivantsController = TextEditingController();
  final _nombreMortsController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _dateMiseBasReelle = DateTime.now();
  Lapin? _male;
  Lapin? _femelle;
  bool _isLoading = true;
  bool _creerLapereaux = true;

  @override
  void initState() {
    super.initState();
    _chargerLapins();
    _nombreMortsController.text = '0';
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
    final male = await db.getLapinById(widget.accouplement.maleId);
    final femelle = await db.getLapinById(widget.accouplement.femelleId);

    setState(() {
      _male = male;
      _femelle = femelle;
      _isLoading = false;
    });
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
      firstDate: widget.accouplement.dateAccouplement,
      lastDate: DateTime.now().add(const Duration(days: 7)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _dateMiseBasReelle) {
      setState(() {
        _dateMiseBasReelle = picked;
      });
    }
  }

  /// Créer automatiquement les lapereaux
  Future<void> _creerLapereausDansDB(int nombreVivants) async {
    if (!_creerLapereaux || nombreVivants == 0) return;

    final lapinProvider = Provider.of<LapinProvider>(context, listen: false);
    final db = DatabaseHelper.instance;

    for (int i = 1; i <= nombreVivants; i++) {
      // Créer un lapereau
      final lapereau = Lapin(
        nom: '${_femelle!.nom} - Lapereau $i',
        race: _femelle!.race,
        sexe: 'Inconnu',
        dateNaissance: _dateMiseBasReelle,
        statut: 'Jeune',
        localisation: _femelle!.localisation ?? 'Nid',
      );

      final lapereauAjoute = await lapinProvider.ajouterLapin(lapereau);

      // Définir les parents
      if (lapereauAjoute.id != null &&
          _male?.id != null &&
          _femelle?.id != null) {
        await db.setParents(lapereauAjoute.id!, _male!.id!, _femelle!.id!);
      }
    }
  }

  /// Enregistrer la portée
  Future<void> _enregistrerPortee() async {
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

    final portee = Portee(
      accouplementId: widget.accouplement.id!,
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

      // Enregistrer la portée
      await reproductionProvider.ajouterPortee(portee);

      // Marquer l'accouplement comme terminé
      await reproductionProvider.terminerAccouplement(widget.accouplement.id!);

      // Créer les lapereaux
      await _creerLapereausDansDB(nombreVivants);

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          _creerLapereaux
              ? 'Portée enregistrée et $nombreVivants lapereaux créés'
              : 'Portée enregistrée avec succès',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
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
          'Enregistrer une portée',
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
            // Informations de l'accouplement
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accouplement',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.male, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_male?.nom ?? 'Inconnu')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.female, color: Colors.pink),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_femelle?.nom ?? 'Inconnue')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Accouplement: ${dateFormat.format(widget.accouplement.dateAccouplement)}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date de mise bas réelle
            Card(
              child: ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Date de mise bas'),
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
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.baby_changing_station),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              onChanged: (_) => _calculerMorts(),
            ),
            const SizedBox(height: 12),

            // Nombre de vivants
            TextFormField(
              controller: _nombreVivantsController,
              decoration: const InputDecoration(
                labelText: 'Nombre de vivants',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.favorite, color: Colors.green),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nombre de vivants';
                }
                final nombre = int.tryParse(value);
                if (nombre == null || nombre < 0) {
                  return 'Veuillez entrer un nombre valide';
                }
                return null;
              },
              onChanged: (_) => _calculerMorts(),
            ),
            const SizedBox(height: 12),

            // Nombre de morts
            TextFormField(
              controller: _nombreMortsController,
              decoration: const InputDecoration(
                labelText: 'Nombre de morts',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.heart_broken, color: Colors.red),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              readOnly: true,
            ),
            const SizedBox(height: 16),

            // Option de création automatique des lapereaux
            Card(
              child: SwitchListTile(
                title: const Text('Créer automatiquement les lapereaux'),
                subtitle: const Text(
                  'Crée une fiche pour chaque lapereau vivant',
                ),
                value: _creerLapereaux,
                onChanged: (value) {
                  setState(() {
                    _creerLapereaux = value;
                  });
                },
                secondary: const Icon(Icons.auto_awesome),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                hintText: 'Observations sur la portée...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Bouton enregistrer
            FilledButton.icon(
              onPressed: _enregistrerPortee,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer la portée'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }
}
