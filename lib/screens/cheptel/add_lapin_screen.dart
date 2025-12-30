import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lapin.dart';
import '../../providers/lapin_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../services/database_helper.dart';
import '../../services/photo_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/add_lapin/lapin_form_page1_identity.dart';
import 'widgets/add_lapin/lapin_form_page2_details.dart';
import 'widgets/add_lapin/lapin_form_page3_genealogy.dart';

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
    // Validation : photo obligatoire
    if (_photoPath == null || _photoPath!.isEmpty) {
      SnackbarHelper.showError(
        context,
        '⚠️ Une photo est obligatoire pour identifier le lapin',
      );
      return;
    }

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
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
            LapinFormPage1Identity(
              nomController: _nomController,
              numeroIdController: _numeroIdController,
              photoPath: _photoPath,
              raceSelectionnee: _raceSelectionnee,
              couleurSelectionnee: _couleurSelectionnee,
              sexeSelectionne: _sexeSelectionne,
              dateNaissance: _dateNaissance,
              onPhotoTap: _afficherDialoguePhoto,
              onPhotoRemove: () => setState(() => _photoPath = null),
              onRaceChanged: (race) => setState(() => _raceSelectionnee = race),
              onCouleurChanged: (couleur) =>
                  setState(() => _couleurSelectionnee = couleur),
              onSexeChanged: (sexe) => setState(() => _sexeSelectionne = sexe),
              onDateChanged: (date) => setState(() => _dateNaissance = date),
            ),
            LapinFormPage2Details(
              poidsController: _poidsController,
              statutSelectionne: _statutSelectionne,
              localisationController: _localisationController,
              origineSelectionnee: _origineSelectionnee,
              prixAchatController: _prixAchatController,
              caracteristiquesController: _caracteristiquesController,
              notesController: _notesController,
              onStatutChanged: (statut) =>
                  setState(() => _statutSelectionne = statut),
              onOrigineChanged: (origine) =>
                  setState(() => _origineSelectionnee = origine),
            ),
            LapinFormPage3Genealogy(
              pereSelectionne: _pereSelectionne,
              mereSelectionnee: _mereSelectionnee,
              onPereChanged: (pere) => setState(() => _pereSelectionne = pere),
              onMereChanged: (mere) => setState(() => _mereSelectionnee = mere),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

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
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
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
              onPressed: (_currentStep == 2 && (_photoPath == null || _photoPath!.isEmpty))
                  ? null // Désactiver si pas de photo sur la dernière page
                  : () {
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
