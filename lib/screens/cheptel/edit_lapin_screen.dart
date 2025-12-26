import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lapin.dart';
import '../../providers/lapin_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/parent_selector.dart';
import '../../services/database_helper.dart';
import '../../services/photo_service.dart';

/// Écran pour modifier un lapin existant
class EditLapinScreen extends StatefulWidget {
  final Lapin lapin;

  const EditLapinScreen({super.key, required this.lapin});

  @override
  State<EditLapinScreen> createState() => _EditLapinScreenState();
}

class _EditLapinScreenState extends State<EditLapinScreen> {
  final _formKey = GlobalKey<FormState>();
  final PhotoService _photoService = PhotoService();

  // Contrôleurs de formulaire
  late final TextEditingController _nomController;
  late final TextEditingController _poidsController;
  late final TextEditingController _localisationController;

  // Valeurs sélectionnées
  late String _raceSelectionnee;
  late String _sexeSelectionne;
  String? _statutSelectionne;
  late DateTime _dateNaissance;
  String? _photoPath;

  // Parents sélectionnés
  Lapin? _pereSelectionne;
  Lapin? _mereSelectionnee;

  // Listes déroulantes
  final List<String> _races = [
    'Géant des Flandres',
    'Fauve de Bourgogne',
    'Bélier Nain',
    'Blanc de Hotot',
    'Néo-Zélandais',
    'Californien',
    'Rex',
    'Angora',
    'Papillon',
    'Argenté de Champagne',
  ];

  final List<String> _statuts = [
    'Jeune',
    'Reproducteur',
    'Reproductrice',
    'Engraissement',
    'Quarantaine',
    'Retraite',
  ];

  @override
  void initState() {
    super.initState();

    // Pré-remplir avec les données du lapin existant
    _nomController = TextEditingController(text: widget.lapin.nom);
    _poidsController = TextEditingController(
      text: widget.lapin.poids?.toString() ?? '',
    );
    _localisationController = TextEditingController(
      text: widget.lapin.localisation ?? '',
    );

    _raceSelectionnee = widget.lapin.race;
    _sexeSelectionne = widget.lapin.sexe;
    _statutSelectionne = widget.lapin.statut;
    _dateNaissance = widget.lapin.dateNaissance;
    _photoPath = widget.lapin.photoPath;

    _chargerParents();
  }

  /// Charger les parents du lapin
  Future<void> _chargerParents() async {
    final db = DatabaseHelper.instance;
    final parents = await db.getParents(widget.lapin.id!);

    if (parents['pere'] != null) {
      setState(() {
        _pereSelectionne = parents['pere'];
      });
    }

    if (parents['mere'] != null) {
      setState(() {
        _mereSelectionnee = parents['mere'];
      });
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _poidsController.dispose();
    _localisationController.dispose();
    super.dispose();
  }

  /// Sélectionner la date de naissance
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateNaissance,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateNaissance) {
      setState(() {
        _dateNaissance = picked;
      });
    }
  }

  /// Afficher le dialogue de choix de source photo
  Future<void> _afficherDialoguePhoto() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Prendre une photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final photoPath = await _photoService.prendrePhoto();
                  if (photoPath != null) {
                    setState(() {
                      _photoPath = photoPath;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () async {
                  Navigator.pop(context);
                  final photoPath = await _photoService.selectionnerPhoto();
                  if (photoPath != null) {
                    setState(() {
                      _photoPath = photoPath;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Modifier le lapin
  Future<void> _modifierLapin() async {
    if (_formKey.currentState!.validate()) {
      final lapinModifie = widget.lapin.copyWith(
        nom: _nomController.text.trim(),
        race: _raceSelectionnee,
        sexe: _sexeSelectionne,
        dateNaissance: _dateNaissance,
        poids: _poidsController.text.isNotEmpty
            ? double.tryParse(_poidsController.text)
            : null,
        statut: _statutSelectionne,
        localisation: _localisationController.text.trim().isNotEmpty
            ? _localisationController.text.trim()
            : null,
        photoPath: _photoPath,
      );

      try {
        // Afficher un indicateur de chargement
        if (mounted) {
          SnackbarHelper.showLoading(context, 'Modification en cours...');
        }

        // Modifier le lapin via le provider
        await Provider.of<LapinProvider>(
          context,
          listen: false,
        ).modifierLapin(lapinModifie);

        // Mettre à jour les parents si nécessaire
        await DatabaseHelper.instance.setParents(
          lapinModifie.id!,
          _pereSelectionne?.id,
          _mereSelectionnee?.id,
        );

        // Retour à l'écran précédent
        if (mounted) {
          Navigator.pop(
            context,
            true,
          ); // true indique que la modification a réussi

          // Message de confirmation
          SnackbarHelper.showSuccess(
            context,
            '${lapinModifie.nom} a été modifié avec succès',
          );
        }
      } catch (e) {
        // Afficher un message d'erreur
        if (mounted) {
          SnackbarHelper.showError(context, 'Erreur: ${e.toString()}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Modifier ${widget.lapin.nom}',
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
          padding: const EdgeInsets.all(16.0),
          children: [
            // Photo
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _afficherDialoguePhoto,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[400]!, width: 2),
                      ),
                      child: _photoPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(_photoPath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 48,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Modifier la photo',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (_photoPath != null)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _photoPath = null;
                        });
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Supprimer la photo',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nom
            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: 'Nom *',
                hintText: 'Ex: Flocon',
                prefixIcon: Icon(Icons.pets),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Race
            DropdownButtonFormField<String>(
              value: _raceSelectionnee,
              decoration: const InputDecoration(
                labelText: 'Race *',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _races.map((race) {
                return DropdownMenuItem(value: race, child: Text(race));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _raceSelectionnee = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Sexe
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sexe *',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Mâle'),
                            value: 'Mâle',
                            groupValue: _sexeSelectionne,
                            onChanged: (value) {
                              setState(() {
                                _sexeSelectionne = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Femelle'),
                            value: 'Femelle',
                            groupValue: _sexeSelectionne,
                            onChanged: (value) {
                              setState(() {
                                _sexeSelectionne = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date de naissance
            ListTile(
              leading: const Icon(Icons.cake),
              title: const Text('Date de naissance'),
              subtitle: Text(
                '${_dateNaissance.day}/${_dateNaissance.month}/${_dateNaissance.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),

            // Poids
            TextFormField(
              controller: _poidsController,
              decoration: const InputDecoration(
                labelText: 'Poids (kg)',
                hintText: 'Ex: 2.5',
                prefixIcon: Icon(Icons.monitor_weight),
                border: OutlineInputBorder(),
                suffixText: 'kg',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final poids = double.tryParse(value);
                  if (poids == null || poids <= 0) {
                    return 'Veuillez entrer un poids valide';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Statut
            DropdownButtonFormField<String>(
              value: _statutSelectionne,
              decoration: const InputDecoration(
                labelText: 'Statut',
                prefixIcon: Icon(Icons.info),
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Aucun')),
                ..._statuts.map((statut) {
                  return DropdownMenuItem(value: statut, child: Text(statut));
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _statutSelectionne = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Localisation
            TextFormField(
              controller: _localisationController,
              decoration: const InputDecoration(
                labelText: 'Localisation',
                hintText: 'Ex: Cage A1',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),

            // Section Généalogie
            Text(
              'Généalogie (optionnel)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Sélection du père
            Consumer<LapinProvider>(
              builder: (context, provider, child) {
                final males = provider.lapins
                    .where(
                      (l) =>
                          l.sexe.toLowerCase() == 'mâle' &&
                          l.id != widget.lapin.id,
                    ) // Exclure le lapin lui-même
                    .toList();
                return ParentSelector(
                  label: 'Père',
                  icon: Icons.male,
                  parentSelectionne: _pereSelectionne,
                  lapinsDisponibles: males,
                  onChanged: (lapin) {
                    setState(() {
                      _pereSelectionne = lapin;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 12),

            // Sélection de la mère
            Consumer<LapinProvider>(
              builder: (context, provider, child) {
                final femelles = provider.lapins
                    .where(
                      (l) =>
                          l.sexe.toLowerCase() == 'femelle' &&
                          l.id != widget.lapin.id,
                    ) // Exclure le lapin lui-même
                    .toList();
                return ParentSelector(
                  label: 'Mère',
                  icon: Icons.female,
                  parentSelectionne: _mereSelectionnee,
                  lapinsDisponibles: femelles,
                  onChanged: (lapin) {
                    setState(() {
                      _mereSelectionnee = lapin;
                    });
                  },
                );
              },
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
                    onPressed: _modifierLapin,
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
