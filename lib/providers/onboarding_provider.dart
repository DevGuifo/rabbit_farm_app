import 'package:flutter/foundation.dart';
import '../models/farm.dart';
import '../models/user_profile.dart';
import '../models/onboarding_status.dart';
import '../models/user.dart';
import '../models/objectif_elevage.dart';
import '../services/database_helper.dart';
import '../services/secure_storage_service.dart';
import '../services/preferences_service.dart';
import '../utils/logger.dart';

/// Provider gérant l'état de l'onboarding
class OnboardingProvider with ChangeNotifier {
  OnboardingStatus? _status;
  Farm? _farm;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  // === État temporaire pour Onboarding V2 ===
  List<ObjectifElevage>? _selectedObjectifs;
  String? _selectedCurrency;
  String? _selectedWeightUnit;

  // Getters
  OnboardingStatus? get status => _status;
  Farm? get farm => _farm;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters V2
  List<ObjectifElevage>? get selectedObjectifs => _selectedObjectifs ?? _userProfile?.objectifs;
  String? get selectedCurrency => _selectedCurrency;
  String? get selectedWeightUnit => _selectedWeightUnit;

  /// Vérifier si l'onboarding est terminé
  bool get isOnboardingCompleted => _status?.estTermine ?? false;

  /// Obtenir l'étape actuelle de l'onboarding
  OnboardingStep get currentStep =>
      _status?.etapeActuelle ?? OnboardingStep.nonDemarre;

  /// Obtenir le pourcentage de progression
  int get progressPercentage => _status?.pourcentageProgression ?? 0;

  /// Charger le statut d'onboarding pour un utilisateur
  /// 
  /// [userId] est l'auth_uid (UUID string) provenant de AuthProvider
  Future<void> loadOnboardingStatus(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final db = DatabaseHelper.instance;
      final secure = SecureStorageService();
      
      // ===== STRATÉGIE DE RÉSOLUTION AUTH_UID -> DB USER ID =====
      // 1. Chercher directement en DB par auth_uid (source de vérité)
      // 2. Fallback: mapping multi-utilisateur dans SecureStorage
      // 3. Fallback: mapping legacy (linked_db_user_id)
      // 4. Fallback: recherche par email et création si nécessaire
      
      int userIdInt;
      User? dbUser;
      
      // 1. Chercher par auth_uid en DB (source de vérité v28+)
      dbUser = await db.getUserByAuthUid(userId);
      
      if (dbUser != null && dbUser.id != null) {
        userIdInt = dbUser.id!;
        // Mettre à jour le cache SecureStorage multi-user
        await secure.setLinkedDbUserIdForAuthUid(userId, userIdInt);
        logger.info('✅ Utilisateur trouvé par auth_uid en DB: $userIdInt');
      } else {
        // 2. Fallback: mapping multi-utilisateur dans SecureStorage
        final cachedDbId = await secure.getLinkedDbUserIdForAuthUid(userId);
        
        if (cachedDbId != null) {
          // Vérifier que l'utilisateur existe toujours en DB
          dbUser = await db.getUserById(cachedDbId);
          if (dbUser != null) {
            userIdInt = cachedDbId;
            // Mettre à jour auth_uid en DB si manquant
            if (dbUser.authUid == null) {
              await db.updateUserAuthUid(cachedDbId, userId);
              logger.info('✅ auth_uid mis à jour en DB pour user $cachedDbId');
            }
            logger.info('✅ Utilisateur résolu via cache multi-user: $userIdInt');
          } else {
            // L'utilisateur a été supprimé, nettoyer le cache
            await secure.clearLinkedDbUserIdForAuthUid(userId);
            userIdInt = await _createOrFindUserByEmail(db, secure, userId);
          }
        } else {
          // 3. Fallback: mapping legacy (linked_db_user_id)
          final legacyLinked = await secure.getLinkedDbUserId();
          if (legacyLinked != null) {
            final legacyId = int.tryParse(legacyLinked);
            if (legacyId != null) {
              dbUser = await db.getUserById(legacyId);
              if (dbUser != null) {
                userIdInt = legacyId;
                // Migrer vers le nouveau système
                await db.updateUserAuthUid(legacyId, userId);
                await secure.setLinkedDbUserIdForAuthUid(userId, legacyId);
                logger.info('✅ Migration legacy mapping -> multi-user: $userIdInt');
              } else {
                userIdInt = await _createOrFindUserByEmail(db, secure, userId);
              }
            } else {
              userIdInt = await _createOrFindUserByEmail(db, secure, userId);
            }
          } else {
            // 4. Fallback: recherche par email et création si nécessaire
            userIdInt = await _createOrFindUserByEmail(db, secure, userId);
          }
        }
      }

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

  /// Méthode helper pour créer ou retrouver un utilisateur par email
  /// et stocker le mapping auth_uid -> db_user_id
  Future<int> _createOrFindUserByEmail(
    DatabaseHelper db,
    SecureStorageService secure,
    String authUid,
  ) async {
    final email = await secure.getUserEmail();
    
    if (email != null) {
      // Chercher par email
      final existingUser = await db.getUserByEmail(email);
      if (existingUser != null && existingUser.id != null) {
        // Mettre à jour auth_uid si manquant
        if (existingUser.authUid == null) {
          await db.updateUserAuthUid(existingUser.id!, authUid);
        }
        await secure.setLinkedDbUserIdForAuthUid(authUid, existingUser.id!);
        logger.info('✅ Utilisateur existant trouvé par email: ${existingUser.id}');
        return existingUser.id!;
      }
      
      // Créer un nouvel utilisateur avec auth_uid
      final storedName = await secure.getUserName();
      final defaultName = storedName ?? email.split('@').first;
      final newUser = User(
        authUid: authUid,
        email: email,
        nom: defaultName,
        prenom: null,
        role: UserRole.eleveur,
        isActive: true,
        dateCreation: DateTime.now(),
        notes: null,
      );
      final newId = await db.createUser(newUser);
      await secure.setLinkedDbUserIdForAuthUid(authUid, newId);
      logger.info('✅ Nouvel utilisateur créé avec auth_uid: $newId');
      return newId;
    } else {
      // Pas d'email, créer avec email généré
      final defaultEmail = 'user_$authUid@local.com';
      final newUser = User(
        authUid: authUid,
        email: defaultEmail,
        nom: 'Utilisateur',
        prenom: null,
        role: UserRole.eleveur,
        isActive: true,
        dateCreation: DateTime.now(),
        notes: null,
      );
      final newId = await db.createUser(newUser);
      await secure.setLinkedDbUserIdForAuthUid(authUid, newId);
      logger.info('✅ Nouvel utilisateur créé (sans email): $newId');
      return newId;
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

      final secure = SecureStorageService();
      final db = DatabaseHelper.instance;
      
      // Résoudre mapping auth->db via le nouveau système
      // 1. Chercher par auth_uid en DB
      User? dbUser = await db.getUserByAuthUid(userId);
      int userIdInt;
      
      if (dbUser != null && dbUser.id != null) {
        userIdInt = dbUser.id!;
      } else {
        // 2. Fallback: mapping multi-utilisateur
        final cachedDbId = await secure.getLinkedDbUserIdForAuthUid(userId);
        if (cachedDbId != null) {
          userIdInt = cachedDbId;
        } else {
          // 3. Fallback: créer via helper
          userIdInt = await _createOrFindUserByEmail(db, secure, userId);
        }
      }

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

  /// Réinitialiser l'onboarding pour un nouvel utilisateur
  /// 
  /// Utilisé lors de l'inscription pour s'assurer que le nouvel utilisateur
  /// passe par l'onboarding V2 complet
  Future<void> resetOnboardingForNewUser(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final secure = SecureStorageService();
      final db = DatabaseHelper.instance;
      
      // Résoudre mapping auth_uid -> db user id
      User? dbUser = await db.getUserByAuthUid(userId);
      int userIdInt;
      
      if (dbUser != null && dbUser.id != null) {
        userIdInt = dbUser.id!;
      } else {
        final cachedDbId = await secure.getLinkedDbUserIdForAuthUid(userId);
        if (cachedDbId != null) {
          userIdInt = cachedDbId;
        } else {
          userIdInt = await _createOrFindUserByEmail(db, secure, userId);
        }
      }

      // Vérifier si un statut existe déjà
      final existingStatus = await db.getOnboardingStatus(userIdInt);
      
      if (existingStatus == null) {
        // Créer un nouveau statut pour le nouvel utilisateur
        final newStatus = OnboardingStatus(
          userId: userIdInt,
          dateCreation: DateTime.now(),
        );
        await db.insertOnboardingStatus(newStatus);
        _status = newStatus;
        logger.info('✅ Nouveau statut onboarding créé pour nouvel utilisateur');
      } else if (existingStatus.estTermine) {
        // Si terminé, réinitialiser (cas rare mais possible)
        await db.deleteFarmByUserId(userIdInt);
        await db.deleteUserProfileByUserId(userIdInt);
        await db.deleteOnboardingStatus(userIdInt);
        
        final newStatus = OnboardingStatus(
          userId: userIdInt,
          dateCreation: DateTime.now(),
        );
        await db.insertOnboardingStatus(newStatus);
        _status = newStatus;
        logger.warning('⚠️ Onboarding réinitialisé pour nouvel utilisateur');
      } else {
        // Onboarding en cours, ne pas toucher
        _status = existingStatus;
        logger.info('ℹ️ Onboarding en cours conservé');
      }

      // Réinitialiser les préférences V2
      await PreferencesService().setOnboardingV2Complete(false);

      notifyListeners();
    } catch (e) {
      logger.error('Erreur lors de la réinitialisation pour nouvel utilisateur: $e');
      _setError('Erreur lors de la préparation de l\'onboarding');
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================
  // MÉTHODES ONBOARDING V2
  // ===========================================================

  /// Sauvegarder les informations de la ferme (V2)
  /// 
  /// Utilisé par l'écran ElevageScreen pour sauvegarder type + taille + races
  Future<bool> saveFarmInfoV2({
    required TypeElevage typeElevage,
    TailleElevage? tailleElevage,
    List<String>? races,
  }) async {
    if (_status?.userId == null) {
      logger.error('Impossible de sauvegarder: userId null');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final db = DatabaseHelper.instance;
      final existingFarm = await db.getFarmByUserId(_status!.userId!);

      Farm farmToSave;
      if (existingFarm != null) {
        // Mise à jour
        farmToSave = existingFarm.copyWith(
          typeElevage: typeElevage,
          tailleElevage: tailleElevage,
          racesElevees: races ?? existingFarm.racesElevees,
          dateModification: DateTime.now(),
        );
        await db.updateFarm(farmToSave);
      } else {
        // Création
        farmToSave = Farm(
          userId: _status!.userId!,
          typeElevage: typeElevage,
          tailleElevage: tailleElevage,
          racesElevees: races,
          dateCreation: DateTime.now(),
        );
        await db.insertFarm(farmToSave);
        farmToSave = await db.getFarmByUserId(_status!.userId!) ?? farmToSave;
      }

      _farm = farmToSave;
      logger.info('✅ Farm V2 sauvegardée: ${_farm.toString()}');
      notifyListeners();
      return true;
    } catch (e) {
      logger.error('❌ Erreur sauvegarde Farm V2: $e');
      _setError('Erreur lors de la sauvegarde');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sauvegarder les objectifs sélectionnés (V2)
  /// 
  /// Stocke dans UserProfile.objectifs (JSON)
  Future<bool> saveObjectifs(List<ObjectifElevage> objectifs) async {
    if (_status?.userId == null) {
      logger.error('Impossible de sauvegarder objectifs: userId null');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      _selectedObjectifs = objectifs;

      final db = DatabaseHelper.instance;
      final existingProfile = await db.getUserProfileByUserId(_status!.userId!);

      UserProfile profileToSave;
      if (existingProfile != null) {
        profileToSave = existingProfile.copyWith(
          objectifs: objectifs,
          dateModification: DateTime.now(),
        );
        await db.updateUserProfile(profileToSave);
      } else {
        profileToSave = UserProfile(
          userId: _status!.userId!,
          objectifs: objectifs,
          dateCreation: DateTime.now(),
        );
        await db.insertUserProfile(profileToSave);
        profileToSave = await db.getUserProfileByUserId(_status!.userId!) ?? profileToSave;
      }

      _userProfile = profileToSave;
      logger.info('✅ Objectifs sauvegardés: ${objectifs.map((o) => o.label).join(', ')}');
      notifyListeners();
      return true;
    } catch (e) {
      logger.error('❌ Erreur sauvegarde objectifs: $e');
      _setError('Erreur lors de la sauvegarde des objectifs');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sauvegarder les préférences régionales (V2)
  /// 
  /// Stocke dans SharedPreferences via PreferencesService
  Future<bool> saveRegionalPreferences({
    required String currency,
    required String weightUnit,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _selectedCurrency = currency;
      _selectedWeightUnit = weightUnit;

      await PreferencesService().setRegionalPreferences(
        currency: currency,
        weightUnit: weightUnit,
      );

      logger.info('✅ Préférences régionales sauvegardées: $currency, $weightUnit');
      notifyListeners();
      return true;
    } catch (e) {
      logger.error('❌ Erreur sauvegarde préférences régionales: $e');
      _setError('Erreur lors de la sauvegarde des préférences');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sauvegarder les préférences de notification (V2)
  /// 
  /// Stocke dans SharedPreferences via PreferencesService
  Future<bool> saveNotificationPreferences({
    required bool sante,
    required bool reproduction,
    required bool alertes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await PreferencesService().setAllNotificationPreferences(
        sante: sante,
        reproduction: reproduction,
        alertes: alertes,
      );

      logger.info('✅ Préférences notification sauvegardées');
      notifyListeners();
      return true;
    } catch (e) {
      logger.error('❌ Erreur sauvegarde préférences notification: $e');
      _setError('Erreur lors de la sauvegarde des notifications');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Finaliser l'onboarding V2
  /// 
  /// Marque l'onboarding comme terminé dans la DB et les préférences
  Future<bool> finalizeOnboardingV2() async {
    if (_status == null) {
      logger.error('Impossible de finaliser: status null');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      // Marquer comme terminé dans la DB
      final completedStatus = _status!.copyWith(
        etapeActuelle: OnboardingStep.termine,
        estTermine: true,
        dateModification: DateTime.now(),
        dateTermine: DateTime.now(),
      );

      final db = DatabaseHelper.instance;
      await db.updateOnboardingStatus(completedStatus);
      _status = completedStatus;

      // Marquer dans SharedPreferences aussi
      await PreferencesService().setOnboardingV2Complete(true);

      logger.info('🎉 Onboarding V2 terminé avec succès !');
      notifyListeners();
      return true;
    } catch (e) {
      logger.error('❌ Erreur finalisation onboarding V2: $e');
      _setError('Erreur lors de la finalisation');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Nettoyer les données temporaires après onboarding
  void clearTemporaryData() {
    _selectedObjectifs = null;
    _selectedCurrency = null;
    _selectedWeightUnit = null;
    logger.info('🧹 Données temporaires onboarding nettoyées');
  }

  // ===========================================================
  // MÉTHODES PRIVÉES
  // ===========================================================

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
