import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/lapin.dart';
import '../../providers/lapin_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/parent_selector.dart';
import '../../services/database_helper.dart';
import '../../services/photo_service.dart';
import '../../theme/app_theme.dart';

/// Écran pour ajouter un nouveau lapin avec UI moderne
class AddLapinScreen extends StatefulWidget {
  const AddLapinScreen({super.key});

  @override
  State<AddLapinScreen> createState() => _AddLapinScreenState();
}

class _AddLapinScreenState extends State<AddLapinScreen> {
  final _formKey = GlobalKey<FormState>();
  final PhotoService _photoService = PhotoService();
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Contrôleurs de formulaire
  final _nomController = TextEditingController();
  final _poidsController = TextEditingController();
  final _localisationController = TextEditingController();
  final _numeroIdController = TextEditingController();
  final _prixAchatController = TextEditingController();
  final _notesController = TextEditingController();
  final _caracteristiquesController = TextEditingController();

  // Valeurs sélectionnées
  String _raceSelectionnee = 'Géant des Flandres';
  String _sexeSelectionne = 'Mâle';
  String? _statutSelectionne;
  String? _couleurSelectionnee;
  String? _origineSelectionnee;
  DateTime _dateNaissance = DateTime.now();
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
    'Achat',
    'Don',
    'Échange',
    'Autre',
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _poidsController.dispose();
    _localisationController.dispose();
    _numeroIdController.dispose();
    _prixAchatController.dispose();
    _notesController.dispose();
    _caracteristiquesController.dispose();
    _pageController.dispose();
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

  /// Enregistrer le lapin
  Future<void> _enregistrerLapin() async {
    if (_formKey.currentState!.validate()) {
      final nouveauLapin = Lapin(
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
        numeroIdentification: _numeroIdController.text.trim().isNotEmpty
            ? _numeroIdController.text.trim()
            : null,
        couleur: _couleurSelectionnee,
        prixAchat: _prixAchatController.text.isNotEmpty
            ? double.tryParse(_prixAchatController.text)
            : null,
        origine: _origineSelectionnee,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        caracteristiques: _caracteristiquesController.text.trim().isNotEmpty
            ? _caracteristiquesController.text.trim()
            : null,
      );

      try {
        // Afficher un indicateur de chargement
        if (mounted) {
          SnackbarHelper.showLoading(context, 'Enregistrement en cours...');
        }

        // Ajouter le lapin via le provider
        final lapinAjoute = await DatabaseHelper.instance.insertLapin(
          nouveauLapin,
        );

        // Enregistrer les parents si sélectionnés
        if (_pereSelectionne != null || _mereSelectionnee != null) {
          await DatabaseHelper.instance.setParents(
            lapinAjoute.id!,
            _pereSelectionne?.id,
            _mereSelectionnee?.id,
          );
        }

        // Recharger la liste des lapins
        if (mounted) {
          await Provider.of<LapinProvider>(
            context,
            listen: false,
          ).chargerLapins();
        }

        // Retour à l'écran précédent
        if (mounted) {
          Navigator.pop(context);

          // Message de confirmation
          SnackbarHelper.showSuccess(
            context,
            '${nouveauLapin.nom} a été ajouté au cheptel',
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

  void _nextPage() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.pets, color: AppTheme.primaryGreen),
            ),
            const SizedBox(width: 12),
            const Text('Ajouter un lapin'),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(AppTheme.primaryGreen),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildPage1Identite(),
            _buildPage2Details(),
            _buildPage3Genealogie(),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  // ============= PAGE 1 : IDENTITÉ =============
  Widget _buildPage1Identite() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      children: [
        FadeInDown(
          child: Text(
            'Informations de base',
            style: AppTheme.headingLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeInDown(
          delay: const Duration(milliseconds: 100),
          child: Text(
            'Remplissez les informations essentielles du lapin',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(height: 32),

        // Photo
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _afficherDialoguePhoto,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: _photoPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusLarge - 2,
                            ),
                            child: Image.file(
                              File(_photoPath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                size: 48,
                                color: AppTheme.primaryGreen,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ajouter une photo',
                                style: AppTheme.labelMedium.copyWith(
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (_photoPath != null) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => setState(() => _photoPath = null),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text('Supprimer'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Nom
        FadeInUp(
          delay: const Duration(milliseconds: 300),
          child: TextFormField(
            controller: _nomController,
            decoration: InputDecoration(
              labelText: 'Nom',
              hintText: 'Ex: Flocon, Caramel...',
              prefixIcon: const Icon(Icons.badge_outlined),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            textCapitalization: TextCapitalization.words,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // N° Identification
        FadeInUp(
          delay: const Duration(milliseconds: 350),
          child: TextFormField(
            controller: _numeroIdController,
            decoration: InputDecoration(
              labelText: 'N° Identification *',
              hintText: 'Tatouage, puce...',
              prefixIcon: const Icon(Icons.qr_code_2),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le numéro d\'identification est obligatoire';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // Race
        FadeInUp(
          delay: const Duration(milliseconds: 400),
          child: DropdownButtonFormField<String>(
            value: _raceSelectionnee,
            decoration: InputDecoration(
              labelText: 'Race *',
              prefixIcon: const Icon(Icons.pets),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            items: _races.map((race) {
              return DropdownMenuItem(value: race, child: Text(race));
            }).toList(),
            onChanged: (value) {
              setState(() => _raceSelectionnee = value!);
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // Couleur
        FadeInUp(
          delay: const Duration(milliseconds: 450),
          child: DropdownButtonFormField<String>(
            value: _couleurSelectionnee,
            decoration: InputDecoration(
              labelText: 'Couleur',
              prefixIcon: const Icon(Icons.palette_outlined),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Non spécifié')),
              ..._couleurs.map((couleur) {
                return DropdownMenuItem(value: couleur, child: Text(couleur));
              }).toList(),
            ],
            onChanged: (value) {
              setState(() => _couleurSelectionnee = value);
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // Sexe
        FadeInUp(
          delay: const Duration(milliseconds: 500),
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wc, color: AppTheme.primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sexe *',
                        style: AppTheme.labelLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              setState(() => _sexeSelectionne = 'Mâle'),
                          icon: const Icon(Icons.male),
                          label: const Text('Mâle'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: _sexeSelectionne == 'Mâle'
                                ? AppTheme.accentBlue.withOpacity(0.1)
                                : null,
                            foregroundColor: _sexeSelectionne == 'Mâle'
                                ? AppTheme.accentBlue
                                : null,
                            side: BorderSide(
                              color: _sexeSelectionne == 'Mâle'
                                  ? AppTheme.accentBlue
                                  : AppTheme.border,
                              width: _sexeSelectionne == 'Mâle' ? 2 : 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              setState(() => _sexeSelectionne = 'Femelle'),
                          icon: const Icon(Icons.female),
                          label: const Text('Femelle'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: _sexeSelectionne == 'Femelle'
                                ? Colors.pink.withOpacity(0.1)
                                : null,
                            foregroundColor: _sexeSelectionne == 'Femelle'
                                ? Colors.pink
                                : null,
                            side: BorderSide(
                              color: _sexeSelectionne == 'Femelle'
                                  ? Colors.pink
                                  : AppTheme.border,
                              width: _sexeSelectionne == 'Femelle' ? 2 : 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // Date de naissance
        FadeInUp(
          delay: const Duration(milliseconds: 550),
          child: InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date de naissance *',
                prefixIcon: const Icon(Icons.cake_outlined),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_dateNaissance.day.toString().padLeft(2, '0')}/${_dateNaissance.month.toString().padLeft(2, '0')}/${_dateNaissance.year}',
                    style: AppTheme.bodyLarge,
                  ),
                  const Icon(Icons.calendar_today, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============= PAGE 2 : DÉTAILS =============
  Widget _buildPage2Details() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      children: [
        FadeInDown(
          child: Text(
            'Informations complémentaires',
            style: AppTheme.headingLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeInDown(
          delay: const Duration(milliseconds: 100),
          child: Text(
            'Détails physiques et origine',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(height: 32),

        // Poids
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: TextFormField(
            controller: _poidsController,
            decoration: InputDecoration(
              labelText: 'Poids',
              hintText: 'Ex: 2.5',
              prefixIcon: const Icon(Icons.monitor_weight_outlined),
              suffixText: 'kg',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final poids = double.tryParse(value);
                if (poids == null || poids <= 0) {
                  return 'Poids invalide';
                }
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // Statut
        FadeInUp(
          delay: const Duration(milliseconds: 250),
          child: DropdownButtonFormField<String>(
            value: _statutSelectionne,
            decoration: InputDecoration(
              labelText: 'Statut',
              prefixIcon: const Icon(Icons.info_outline),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Non défini')),
              ..._statuts.map((statut) {
                return DropdownMenuItem(value: statut, child: Text(statut));
              }).toList(),
            ],
            onChanged: (value) {
              setState(() => _statutSelectionne = value);
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // Localisation
        FadeInUp(
          delay: const Duration(milliseconds: 300),
          child: TextFormField(
            controller: _localisationController,
            decoration: InputDecoration(
              labelText: 'Localisation',
              hintText: 'Ex: Cage A1, Enclos 2...',
              prefixIcon: const Icon(Icons.location_on_outlined),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            textCapitalization: TextCapitalization.characters,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),

        // Origine
        FadeInUp(
          delay: const Duration(milliseconds: 350),
          child: DropdownButtonFormField<String>(
            value: _origineSelectionnee,
            decoration: InputDecoration(
              labelText: 'Origine',
              prefixIcon: const Icon(Icons.history_outlined),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Non spécifié')),
              ..._origines.map((origine) {
                return DropdownMenuItem(value: origine, child: Text(origine));
              }).toList(),
            ],
            onChanged: (value) {
              setState(() => _origineSelectionnee = value);
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // Prix d'achat (si origine = Achat)
        if (_origineSelectionnee == 'Achat')
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: TextFormField(
              controller: _prixAchatController,
              decoration: InputDecoration(
                labelText: 'Prix d\'achat',
                hintText: 'Ex: 25.00',
                prefixIcon: const Icon(Icons.euro_outlined),
                suffixText: '€',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
          ),
        const SizedBox(height: AppTheme.spacing24),

        // Caractéristiques
        FadeInUp(
          delay: const Duration(milliseconds: 450),
          child: TextFormField(
            controller: _caracteristiquesController,
            decoration: InputDecoration(
              labelText: 'Caractéristiques particulières',
              hintText: 'Signes distinctifs, marques...',
              prefixIcon: const Icon(Icons.stars_outlined),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // Notes
        FadeInUp(
          delay: const Duration(milliseconds: 500),
          child: TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Notes',
              hintText: 'Observations générales...',
              prefixIcon: const Icon(Icons.note_outlined),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
      ],
    );
  }

  // ============= PAGE 3 : GÉNÉALOGIE =============
  Widget _buildPage3Genealogie() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      children: [
        FadeInDown(
          child: Text(
            'Généalogie',
            style: AppTheme.headingLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeInDown(
          delay: const Duration(milliseconds: 100),
          child: Text(
            'Informations sur les parents (optionnel)',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(height: 32),

        // Illustration
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Icon(
                Icons.family_restroom,
                size: 64,
                color: AppTheme.accentPurple,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Sélection du père
        FadeInUp(
          delay: const Duration(milliseconds: 300),
          child: Consumer<LapinProvider>(
            builder: (context, provider, child) {
              final males = provider.lapins
                  .where((l) => l.sexe.toLowerCase() == 'mâle')
                  .toList();
              return ParentSelector(
                label: 'Père',
                icon: Icons.male,
                parentSelectionne: _pereSelectionne,
                lapinsDisponibles: males,
                onChanged: (lapin) {
                  setState(() => _pereSelectionne = lapin);
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // Sélection de la mère
        FadeInUp(
          delay: const Duration(milliseconds: 350),
          child: Consumer<LapinProvider>(
            builder: (context, provider, child) {
              final femelles = provider.lapins
                  .where((l) => l.sexe.toLowerCase() == 'femelle')
                  .toList();
              return ParentSelector(
                label: 'Mère',
                icon: Icons.female,
                parentSelectionne: _mereSelectionnee,
                lapinsDisponibles: femelles,
                onChanged: (lapin) {
                  setState(() => _mereSelectionnee = lapin);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 32),

        // Info message
        FadeInUp(
          delay: const Duration(milliseconds: 400),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'La généalogie vous permet de tracer l\'ascendance et d\'éviter les accouplements consanguins.',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.info),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============= BARRE DE NAVIGATION =============
  Widget _buildNavigationBar() {
    return Container(
      padding: EdgeInsets.only(
        left: AppTheme.spacing20,
        right: AppTheme.spacing20,
        bottom: MediaQuery.of(context).padding.bottom + AppTheme.spacing16,
        top: AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton Précédent
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousPage,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Précédent'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),

          // Bouton Suivant / Enregistrer
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: FilledButton.icon(
              onPressed: () {
                if (_currentStep < 2) {
                  // Validation de la page 1
                  if (_currentStep == 0) {
                    if (_numeroIdController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Le numéro d\'identification est obligatoire',
                          ),
                          backgroundColor: AppTheme.warning,
                        ),
                      );
                      return;
                    }
                  }
                  _nextPage();
                } else {
                  _enregistrerLapin();
                }
              },
              icon: Icon(_currentStep < 2 ? Icons.arrow_forward : Icons.save),
              label: Text(_currentStep < 2 ? 'Suivant' : 'Enregistrer'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
