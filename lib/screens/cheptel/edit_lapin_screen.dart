import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import '../../models/lapin.dart';
import '../../models/enums/sexe.dart';
import '../../providers/lapin_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../services/error_service.dart';
import '../../widgets/parent_selector.dart';
import '../../widgets/common/common_widgets.dart';
import '../../services/database_helper.dart';
import '../../services/photo_service.dart';
import '../../theme/app_theme.dart';

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
  late final TextEditingController _numeroIdController;
  late final TextEditingController _prixAchatController;
  late final TextEditingController _notesController;
  late final TextEditingController _caracteristiquesController;

  // Valeurs sélectionnées
  late String _raceSelectionnee;
  late String _sexeSelectionne;
  String? _statutSelectionne;
  String? _couleurSelectionnee;
  String? _origineSelectionnee;
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

  final List<String> _couleurs = [
    'Blanc',
    'Noir',
    'Gris',
    'Fauve',
    'Brun',
    'Argenté',
    'Chinchilla',
    'Papillon',
    'Tricolore',
    'Autre',
  ];

  final List<String> _origines = [
    'Naissance sur place',
    'Naissance élevage', // Alias pour compatibilité
    'Achat',
    'Don',
    'Échange',
    'Autre',
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
    _numeroIdController = TextEditingController(
      text: widget.lapin.numeroIdentification ?? '',
    );
    _prixAchatController = TextEditingController(
      text: widget.lapin.prixAchat?.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.lapin.notes ?? '');
    _caracteristiquesController = TextEditingController(
      text: widget.lapin.caracteristiques ?? '',
    );

    _raceSelectionnee = widget.lapin.race;
    _sexeSelectionne = widget.lapin.sexe.label;
    _statutSelectionne = widget.lapin.statut;
    _couleurSelectionnee = widget.lapin.couleur;
    _origineSelectionnee = widget.lapin.origine;
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
    _numeroIdController.dispose();
    _prixAchatController.dispose();
    _notesController.dispose();
    _caracteristiquesController.dispose();
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
    if (!mounted) return;
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
                title: Text(AppLocalizations.of(context).cheptelPrendrePhoto),
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
                title: Text(AppLocalizations.of(context).cheptelChoisirGalerie),
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
        sexe: Sexe.fromString(_sexeSelectionne),
        dateNaissance: _dateNaissance,
        poids: _poidsController.text.isNotEmpty
            ? double.tryParse(_poidsController.text)
            : null,
        statut: _statutSelectionne,
        couleur: _couleurSelectionnee,
        origine: _origineSelectionnee,
        localisation: _localisationController.text.trim().isNotEmpty
            ? _localisationController.text.trim()
            : null,
        numeroIdentification: _numeroIdController.text.trim().isNotEmpty
            ? _numeroIdController.text.trim()
            : null,
        prixAchat: _prixAchatController.text.isNotEmpty
            ? double.tryParse(_prixAchatController.text)
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        caracteristiques: _caracteristiquesController.text.trim().isNotEmpty
            ? _caracteristiquesController.text.trim()
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
          ErrorService.showError(context, e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: Column(
        children: [
          StandardHeader(
            title: AppLocalizations.of(
              context,
            ).cheptelModifierLapin(widget.lapin.nom),
            isDark: isDark,
            showBackButton: true,
          ),
          Expanded(
            child: Form(
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
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppTheme.darkGreyLight
                                  : AppTheme.textTertiary.withValues(
                                      alpha: 0.2,
                                    ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 2,
                              ),
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
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.photoModifier,
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
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
                            icon: Icon(Icons.delete, color: AppTheme.error),
                            label: Text(
                              l10n.photoSupprimer,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nom
                  TextFormField(
                    controller: _nomController,
                    decoration: AppTheme.inputDecoration(
                      label: '${AppLocalizations.of(context).labelNom} *',
                      hint: AppLocalizations.of(context).hintNomLapin,
                      prefixIcon: Icons.pets,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context).erreurNomRequis;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Race
                  DropdownButtonFormField<String>(
                    initialValue: _raceSelectionnee,
                    decoration: AppTheme.inputDecoration(
                      label: '${AppLocalizations.of(context).labelRace} *',
                      prefixIcon: Icons.category,
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

                  // Couleur
                  DropdownButtonFormField<String>(
                    initialValue: _couleurSelectionnee,
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(context).labelCouleur,
                      prefixIcon: Icons.palette,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          AppLocalizations.of(context).labelNonSpecifiee,
                        ),
                      ),
                      ..._couleurs.map((couleur) {
                        return DropdownMenuItem(
                          value: couleur,
                          child: Text(couleur),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _couleurSelectionnee = value;
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
                          SegmentedButton<String>(
                            segments: [
                              ButtonSegment(
                                value: 'Mâle',
                                label: Text(
                                  AppLocalizations.of(context).labelSexeMale,
                                ),
                                icon: const Icon(Icons.male),
                              ),
                              ButtonSegment(
                                value: 'Femelle',
                                label: Text(
                                  AppLocalizations.of(context).labelSexeFemelle,
                                ),
                                icon: const Icon(Icons.female),
                              ),
                            ],
                            selected: {_sexeSelectionne},
                            onSelectionChanged: (values) {
                              setState(() {
                                _sexeSelectionne = values.first;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date de naissance
                  ListTile(
                    leading: const Icon(Icons.cake),
                    title: Text(
                      AppLocalizations.of(context).labelDateNaissance,
                    ),
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
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(context).labelPoidsKg,
                      hint: AppLocalizations.of(context).hintExemple25,
                      prefixIcon: Icons.monitor_weight,
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
                    initialValue: _statutSelectionne,
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(context).labelStatut,
                      prefixIcon: Icons.info_outline,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(AppLocalizations.of(context).labelAucun),
                      ),
                      ..._statuts.map((statut) {
                        return DropdownMenuItem(
                          value: statut,
                          child: Text(statut),
                        );
                      }),
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
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(context).labelLocalisation,
                      hint: AppLocalizations.of(context).hintLocalisation,
                      prefixIcon: Icons.location_on,
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),

                  // Origine
                  DropdownButtonFormField<String>(
                    initialValue: _origineSelectionnee,
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(context).labelOrigine,
                      prefixIcon: Icons.flag,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(
                          AppLocalizations.of(context).labelNonSpecifiee,
                        ),
                      ),
                      ..._origines.map((origine) {
                        return DropdownMenuItem(
                          value: origine,
                          child: Text(origine),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _origineSelectionnee = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Numéro d'identification
                  TextFormField(
                    controller: _numeroIdController,
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(
                        context,
                      ).labelNumeroIdentification,
                      hint: AppLocalizations.of(context).hintNumeroId,
                      prefixIcon: Icons.qr_code,
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),

                  // Prix d'achat
                  TextFormField(
                    controller: _prixAchatController,
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(context).labelPrixAchat,
                      hint: AppLocalizations.of(context).hintPrixAchat,
                      prefixIcon: Icons.euro,
                      suffixText: '€',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final prix = double.tryParse(value);
                        if (prix == null || prix < 0) {
                          return AppLocalizations.of(
                            context,
                          ).erreurPrixInvalide;
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Caractéristiques
                  TextFormField(
                    controller: _caracteristiquesController,
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(context).labelCaracteristiques,
                      hint: AppLocalizations.of(context).hintCaracteristiques,
                      prefixIcon: Icons.description,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: AppTheme.inputDecoration(
                      label: AppLocalizations.of(context).labelNotes,
                      hint: AppLocalizations.of(context).hintNotes,
                      prefixIcon: Icons.note,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Section Généalogie
                  Text(
                    'Généalogie (optionnel)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sélection du père
                  Consumer<LapinProvider>(
                    builder: (context, provider, child) {
                      final males = provider.lapins
                          .where(
                            (l) =>
                                l.sexe == Sexe.male && l.id != widget.lapin.id,
                          ) // Exclure le lapin lui-même
                          .toList();
                      return ParentSelector(
                        label: AppLocalizations.of(context).labelPere,
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
                                l.sexe == Sexe.femelle &&
                                l.id != widget.lapin.id,
                          ) // Exclure le lapin lui-même
                          .toList();
                      return ParentSelector(
                        label: AppLocalizations.of(context).labelMere,
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
                          label: Text(
                            AppLocalizations.of(context).commonCancel,
                          ),
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
                          label: Text(AppLocalizations.of(context).commonSave),
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
          ),
        ],
      ),
    );
  }
}
