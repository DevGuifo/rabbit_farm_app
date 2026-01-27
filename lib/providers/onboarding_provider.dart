import 'package:flutter/foundation.dart';
import '../models/farm.dart';
import '../models/user_profile.dart';
import '../models/onboarding_status.dart';
import '../services/database_helper.dart';
import '../utils/logger.dart';

/// Provider gérant l'état de l'onboarding
class OnboardingProvider with ChangeNotifier {
  OnboardingStatus? _status;
  Farm? _farm;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  // Getters
  OnboardingStatus? get status => _status;
  Farm? get farm => _farm;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Vérifier si l'onboarding est terminé
  bool get isOnboardingCompleted => _status?.estTermine ?? false;

  /// Obtenir l'étape actuelle de l'onboarding
  OnboardingStep get currentStep =>
      _status?.etapeActuelle ?? OnboardingStep.nonDemarre;

  /// Obtenir le pourcentage de progression
  int get progressPercentage => _status?.pourcentageProgression ?? 0;

  /// Charger le statut d'onboarding pour un utilisateur
  Future<void> loadOnboardingStatus(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final db = DatabaseHelper.instance;

      // Convertir userId String en int pour la compatibilité DB
      final userIdInt = userId.hashCode;

      // Charger le statut d'onboarding
      _status = await db.getOnboardingStatus(userIdInt);

      // Si aucun statut trouvé, créer un nouveau
      if (_status == null) {
        _status = OnboardingStatus(
          userId: userIdInt,
          dateCreation: DateTime.now(),
        );
        await db.insertOnboardingStatus(_status!);
        _status = await db.getOnboardingStatus(userIdInt);
      }

      // Charger les données associées si disponibles
      if (_status!.estTermine) {
        _farm = await db.getFarmByUserId(userIdInt);
        _userProfile = await db.getUserProfileByUserId(userIdInt);
      }

      logger.info('Statut onboarding chargé: ${_status.toString()}');
    } catch (e) {
      logger.error('Erreur lors du chargement du statut onboarding: $e');
      _setError('Erreur lors du chargement de l\'onboarding');
    } finally {
      _setLoading(false);
    }
  }

  /// Passer à l'étape suivante de l'onboarding
  Future<bool> nextStep() async {
    if (_status == null) return false;

    final nextStep = _status!.etapeSuivante;
    if (nextStep == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final updatedStatus = _status!.copyWith(
        etapeActuelle: nextStep,
        estTermine: nextStep == OnboardingStep.termine,
        dateModification: DateTime.now(),
        dateTermine: nextStep == OnboardingStep.termine ? DateTime.now() : null,
      );

      final db = DatabaseHelper.instance;
      await db.updateOnboardingStatus(updatedStatus);
      _status = updatedStatus;

      logger.info('Progression onboarding: ${_status!.etapeString}');
      notifyListeners();
      return true;
    } catch (e) {
      logger.error('Erreur lors de la progression: $e');
      _setError('Erreur lors de la progression');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sauvegarder les informations de la ferme
  Future<bool> saveFarmInfo({
    String? nom,
    String? region,
    String? pays,
    required TypeElevage typeElevage,
    TailleElevage? tailleElevage,
  }) async {
    if (_status?.userId == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final farm = Farm(
        userId: _status!.userId!,
        nom: nom,
        region: region,
        pays: pays,
        typeElevage: typeElevage,
        tailleElevage: tailleElevage,
        dateCreation: DateTime.now(),
      );

      final db = DatabaseHelper.instance;

      // Vérifier si une ferme existe déjà
      final existingFarm = await db.getFarmByUserId(_status!.userId!);
      if (existingFarm != null) {
        final updatedFarm = farm.copyWith(
          id: existingFarm.id,
          dateModification: DateTime.now(),
        );
        await db.updateFarm(updatedFarm);
        _farm = updatedFarm;
      } else {
        await db.insertFarm(farm);
        _farm = await db.getFarmByUserId(_status!.userId!);
      }

      logger.info('Informations ferme sauvegardées: ${_farm.toString()}');
      notifyListeners();
      return true;
    } catch (e) {
      logger.error('Erreur lors de la sauvegarde des infos ferme: $e');
      _setError('Erreur lors de la sauvegarde');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sauvegarder le profil utilisateur
  Future<bool> saveUserProfile({
    RoleUtilisateur? role,
    NiveauExperience? niveauExperience,
  }) async {
    if (_status?.userId == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final profile = UserProfile(
        userId: _status!.userId!,
        role: role,
        niveauExperience: niveauExperience,
        dateCreation: DateTime.now(),
      );

      final db = DatabaseHelper.instance;

      // Vérifier si un profil existe déjà
      final existingProfile = await db.getUserProfileByUserId(_status!.userId!);
      if (existingProfile != null) {
        final updatedProfile = profile.copyWith(
          id: existingProfile.id,
          dateModification: DateTime.now(),
        );
        await db.updateUserProfile(updatedProfile);
        _userProfile = updatedProfile;
      } else {
        await db.insertUserProfile(profile);
        _userProfile = await db.getUserProfileByUserId(_status!.userId!);
      }

      logger.info('Profil utilisateur sauvegardé: ${_userProfile.toString()}');
      notifyListeners();
      return true;
    } catch (e) {
      logger.error('Erreur lors de la sauvegarde du profil: $e');
      _setError('Erreur lors de la sauvegarde');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Mettre à jour les préférences de synchronisation
  Future<bool> updateSyncPreferences(bool authorizeSync) async {
    if (_status == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final updatedStatus = _status!.copyWith(
        synchronisationAutorisee: authorizeSync,
        dateModification: DateTime.now(),
      );

      final db = DatabaseHelper.instance;
      await db.updateOnboardingStatus(updatedStatus);
      _status = updatedStatus;

      logger.info('Préférences sync mises à jour: $authorizeSync');
      notifyListeners();
      return true;
    } catch (e) {
      logger.error('Erreur lors de la mise à jour des préférences: $e');
      _setError('Erreur lors de la sauvegarde');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Terminer l'onboarding
  Future<bool> completeOnboarding() async {
    if (_status == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final completedStatus = _status!.copyWith(
        etapeActuelle: OnboardingStep.termine,
        estTermine: true,
        dateModification: DateTime.now(),
        dateTermine: DateTime.now(),
      );

      final db = DatabaseHelper.instance;
      await db.updateOnboardingStatus(completedStatus);
      _status = completedStatus;

      logger.info('🎉 Onboarding terminé avec succès');
      notifyListeners();
      return true;
    } catch (e) {
      logger.error('Erreur lors de la finalisation: $e');
      _setError('Erreur lors de la finalisation');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Réinitialiser l'onboarding (pour debug/test)
  Future<void> resetOnboarding(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      // Convertir userId String en int pour la compatibilité DB
      final userIdInt = userId.hashCode;

      final db = DatabaseHelper.instance;

      // Supprimer les données existantes
      await db.deleteFarmByUserId(userIdInt);
      await db.deleteUserProfileByUserId(userIdInt);
      await db.deleteOnboardingStatus(userIdInt);

      // Créer un nouveau statut
      final newStatus = OnboardingStatus(
        userId: userIdInt,
        dateCreation: DateTime.now(),
      );

      await db.insertOnboardingStatus(newStatus);

      // Recharger
      await loadOnboardingStatus(userId);

      logger.warning('Onboarding réinitialisé pour utilisateur $userId');
    } catch (e) {
      logger.error('Erreur lors de la réinitialisation: $e');
      _setError('Erreur lors de la réinitialisation');
    } finally {
      _setLoading(false);
    }
  }

  /// Méthodes privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Nettoyer les données
  @override
  void dispose() {
    super.dispose();
  }
}
