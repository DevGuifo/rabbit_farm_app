import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import '../../models/lapin.dart';
import '../../models/enums/sexe.dart';
import '../../providers/lapin_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../services/error_service.dart';
import '../../services/database_helper.dart';
import '../../services/photo_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/uniform_app_bar.dart';
import 'widgets/add_lapin/lapin_form_page1_identity.dart';
import 'widgets/add_lapin/lapin_form_page2_details.dart';
import 'widgets/add_lapin/lapin_form_page3_genealogy.dart';

// ✅ NOUVEAUTÉ : Import des validators
import '../../validators/lapin_validator.dart';
import '../../validators/validation_result.dart';
import '../../widgets/validation_message_widget.dart';

/// Écran pour ajouter un nouveau lapin avec **VALIDATION MÉTIER COMPLÈTE**
///
/// ✅ Respecte les règles :
/// - L1-L5 : Validation généalogique complète
/// - L6 : Date de naissance dans le passé
/// - L8 : Poids > 0
/// - L9 : Nom unique par cage
class AddLapinScreenWithValidation extends StatefulWidget {
  const AddLapinScreenWithValidation({super.key});

  @override
  State<AddLapinScreenWithValidation> createState() =>
      _AddLapinScreenWithValidationState();
}

class _AddLapinScreenWithValidationState
    extends State<AddLapinScreenWithValidation> {
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
  int? _cageId;

  // Parents sélectionnés
  Lapin? _pereSelectionne;
  Lapin? _mereSelectionnee;

  // ✅ NOUVEAUTÉ : État de validation
  List<ValidationResult> _validationResults = [];

  @override
  void initState() {
    super.initState();
    // Valider à chaque changement
    _nomController.addListener(_validerFormulaire);
    _poidsController.addListener(_validerFormulaire);
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
    _pageController.dispose();
    super.dispose();
  }

  /// ✅ NOUVEAUTÉ : Validation métier en temps réel
  void _validerFormulaire() {
    setState(() {
      final lapinProvider = Provider.of<LapinProvider>(context, listen: false);

      // Récupérer les lapins de la cage (si cage sélectionnée)
      List<Lapin>? lapinsDansCage;
      if (_cageId != null) {
        lapinsDansCage = lapinProvider.lapins
            .where((l) => l.cageId == _cageId)
            .toList();
      }

      // Exécuter toutes les validations
      _validationResults = LapinValidator.validateLapin(
        lapinId: null, // Nouveau lapin
        nom: _nomController.text.trim(),
        dateNaissance: _dateNaissance,
        poids: _poidsController.text.isNotEmpty
            ? double.tryParse(_poidsController.text)
            : null,
        pereId: _pereSelectionne?.id,
        mereId: _mereSelectionnee?.id,
        pere: _pereSelectionne,
        mere: _mereSelectionnee,
        cageId: _cageId,
        lapinsDansCage: lapinsDansCage,
      );
    });
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

  /// ✅ MODIFIÉ : Enregistrer avec gestion des avertissements
  Future<void> _enregistrerLapin() async {
    // Validation : photo obligatoire
    if (_photoPath == null || _photoPath!.isEmpty) {
      SnackbarHelper.showError(
        context,
        '⚠️ Une photo est obligatoire pour identifier le lapin',
      );
      return;
    }

    // ✅ NOUVEAUTÉ : Vérifier les erreurs bloquantes
    if (ValidationHelper.hasBlockingError(_validationResults)) {
      final message = ValidationHelper.getFirstBlockingError(
        _validationResults,
      );
      SnackbarHelper.showError(context, message ?? 'Erreur de validation');
      return;
    }

    // ✅ NOUVEAUTÉ : Gérer les avertissements
    final avertissements = _validationResults
        .where(
          (r) =>
              r.severity == ValidationSeverity.avertissement &&
              r.errorMessage != null,
        )
        .toList();

    if (avertissements.isNotEmpty) {
      // Afficher dialogue de confirmation
      ValidationHelper.showWarningDialog(
        context,
        avertissements.first.errorMessage!,
        _procederEnregistrement,
      );
      return;
    }

    // Pas d'avertissement : enregistrer directement
    await _procederEnregistrement();
  }

  /// ✅ NOUVEAUTÉ : Méthode séparée pour l'enregistrement réel
  Future<void> _procederEnregistrement() async {
    if (_formKey.currentState!.validate()) {
      final nouveauLapin = Lapin(
        nom: _nomController.text.trim(),
        race: _raceSelectionnee,
        sexe: Sexe.fromString(_sexeSelectionne),
        dateNaissance: _dateNaissance,
        poids: _poidsController.text.isNotEmpty
            ? double.tryParse(_poidsController.text)
            : null,
        statut: _statutSelectionne,
        localisation: _localisationController.text.trim().isNotEmpty
            ? _localisationController.text.trim()
            : null,
        cageId: _cageId,
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
        if (mounted) {
          SnackbarHelper.showLoading(context, 'Enregistrement en cours...');
        }

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

        if (mounted) {
          await Provider.of<LapinProvider>(
            context,
            listen: false,
          ).chargerLapins();
        }

        if (mounted) {
          Navigator.pop(context);
          SnackbarHelper.showSuccess(
            context,
            '${nouveauLapin.nom} a été ajouté au cheptel',
          );
        }
      } catch (e) {
        if (mounted) {
          ErrorService.showError(context, e);
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
      appBar: SimpleAppBar(
        title: AppLocalizations.of(context).cheptelAjouterLapin,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation(AppTheme.primaryGreen),
          ),
        ),
      ),
      body: Column(
        children: [
          // ✅ NOUVEAUTÉ : Messages de validation en haut
          if (_validationResults.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: ValidationMessageWidget(
                validationResults: _validationResults,
              ),
            ),

          // Formulaire
          Expanded(
            child: Form(
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
                    onRaceChanged: (race) =>
                        setState(() => _raceSelectionnee = race),
                    onCouleurChanged: (couleur) =>
                        setState(() => _couleurSelectionnee = couleur),
                    onSexeChanged: (sexe) =>
                        setState(() => _sexeSelectionne = sexe),
                    onDateChanged: (date) {
                      setState(() => _dateNaissance = date);
                      _validerFormulaire();
                    },
                  ),
                  LapinFormPage2Details(
                    poidsController: _poidsController,
                    statutSelectionne: _statutSelectionne,
                    localisationController: _localisationController,
                    origineSelectionnee: _origineSelectionnee,
                    prixAchatController: _prixAchatController,
                    caracteristiquesController: _caracteristiquesController,
                    notesController: _notesController,
                    cageIdInitiale: _cageId,
                    onStatutChanged: (statut) =>
                        setState(() => _statutSelectionne = statut),
                    onOrigineChanged: (origine) =>
                        setState(() => _origineSelectionnee = origine),
                    onCageIdChanged: (cageId) {
                      setState(() => _cageId = cageId);
                      _validerFormulaire();
                    },
                  ),
                  LapinFormPage3Genealogy(
                    pereSelectionne: _pereSelectionne,
                    mereSelectionnee: _mereSelectionnee,
                    onPereChanged: (pere) {
                      setState(() => _pereSelectionne = pere);
                      _validerFormulaire();
                    },
                    onMereChanged: (mere) {
                      setState(() => _mereSelectionnee = mere);
                      _validerFormulaire();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildNavigationBar() {
    // ✅ NOUVEAUTÉ : Désactiver le bouton si erreur bloquante
    final peutEnregistrer =
        !ValidationHelper.hasBlockingError(_validationResults) &&
        (_photoPath != null && _photoPath!.isNotEmpty);

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
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousPage,
                icon: const Icon(Icons.arrow_back),
                label: Text(AppLocalizations.of(context).cheptelBtnPrecedent),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),

          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: FilledButton.icon(
              onPressed: (_currentStep == 2 && !peutEnregistrer)
                  ? null // ✅ Désactivé si validation échoue
                  : () {
                      if (_currentStep < 2) {
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
              label: Text(
                _currentStep < 2
                    ? AppLocalizations.of(context).btnSuivant
                    : AppLocalizations.of(context).btnEnregistrer,
              ),
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
