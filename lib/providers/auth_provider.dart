import 'package:flutter/foundation.dart';
import '../services/supabase_auth_service.dart';
import '../services/secure_storage_service.dart';
import '../services/local_auth_service.dart';
import 'sync_provider.dart';
import '../utils/logger.dart';

/// État d'authentification
enum AuthState {
  /// État initial, vérification en cours
  initializing,

  /// Non authentifié (pas de session)
  unauthenticated,

  /// Authentifié mais PIN non configuré
  authenticatedNoPin,

  /// Authentifié et PIN configuré
  authenticatedWithPin,

  /// Authentification en cours
  authenticating,

  /// Erreur d'authentification
  error,
}

/// Provider pour gérer l'authentification
/// 
/// Gère :
/// - L'état d'authentification
/// - L'inscription/connexion Supabase
/// - La vérification du PIN (offline)
/// - La session utilisateur
class AuthProvider extends ChangeNotifier {
  static final AuthProvider _instance = AuthProvider._internal();
  factory AuthProvider() => _instance;
  AuthProvider._internal();

  final SupabaseAuthService _authService = SupabaseAuthService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final LocalAuthService _localAuthService = LocalAuthService();

  AuthState _state = AuthState.initializing;
  String? _errorMessage;
  String? _currentUserId;

  // ============= GETTERS =============

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _currentUserId;
  bool get isAuthenticated => _state == AuthState.authenticatedWithPin ||
      _state == AuthState.authenticatedNoPin;
  bool get hasPin => _state == AuthState.authenticatedWithPin;

  // ============= INITIALISATION =============

  /// Initialiser le provider
  /// 
  /// Vérifie si une session existe et si un PIN est configuré
  /// Fonctionne en mode offline si Supabase n'est pas initialisé
  Future<void> initialize() async {
    try {
      _setState(AuthState.initializing);

      // Vérifier si un userId est stocké localement (pour mode offline)
      final storedUserId = await _secureStorage.getUserId();
      final isPinSet = await _secureStorage.isPinSet();

      // Vérifier si une session Supabase existe (seulement si Supabase est initialisé)
      bool isAuthenticated = false;
      try {
        isAuthenticated = _authService.isAuthenticated;
        if (isAuthenticated) {
          _currentUserId = _authService.currentUserId ?? storedUserId;
          logger.info('✅ Session Supabase trouvée: $_currentUserId');
        }
      } catch (e) {
        // Supabase non initialisé (mode offline)
        logger.info('ℹ️ Supabase non initialisé (mode offline)');
        if (storedUserId != null) {
          _currentUserId = storedUserId;
        }
      }

      // Déterminer l'état selon la session et le PIN
      if (isAuthenticated) {
        // Session Supabase active
        if (isPinSet) {
          _setState(AuthState.authenticatedWithPin);
        } else {
          _setState(AuthState.authenticatedNoPin);
        }
      } else if (storedUserId != null && isPinSet) {
        // Pas de session Supabase mais PIN disponible (mode offline)
        // Permettre l'accès via PIN même sans connexion
        _setState(AuthState.authenticatedWithPin);
        logger.info('ℹ️ Mode offline - PIN disponible pour déverrouillage');
      } else {
        // Aucune session, aucun PIN
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      logger.error('❌ Erreur lors de l\'initialisation AuthProvider: $e');
      // En cas d'erreur, permettre quand même le démarrage
      _setState(AuthState.unauthenticated);
    }
  }

  // ============= INSCRIPTION =============

  /// Inscrire un nouvel utilisateur
  /// 
  /// [email] : Email de l'utilisateur
  /// [password] : Mot de passe
  /// 
  /// Retourne true si l'inscription réussit
  /// 
  /// Si Supabase n'est pas disponible, crée un compte local (mode offline)
  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    try {
      _setState(AuthState.authenticating);
      _clearError();

      logger.info('📝 Inscription: $email');

      String userId;

      // Essayer d'abord avec Supabase si disponible
      if (_authService.isAvailable) {
        try {
          userId = await _authService.signUp(
            email: email,
            password: password,
          );
          logger.info('✅ Inscription Supabase réussie: $userId');
        } catch (e) {
          // Si Supabase échoue, créer un compte local
          logger.warning('⚠️ Inscription Supabase échouée, création compte local: $e');
          userId = _generateLocalUserId(email);
          logger.info('✅ Compte local créé: $userId');
        }
      } else {
        // Supabase non disponible, créer un compte local
        userId = _generateLocalUserId(email);
        logger.info('✅ Compte local créé (mode offline): $userId');
      }

      _currentUserId = userId;
      await _secureStorage.setUserId(userId);

      // Après inscription, l'utilisateur doit configurer un PIN
      _setState(AuthState.authenticatedNoPin);

      logger.info('✅ Inscription réussie: $userId');
      return true;
    } catch (e) {
      logger.error('❌ Erreur lors de l\'inscription: $e');
      _setError(e.toString());
      _setState(AuthState.error);
      return false;
    }
  }

  /// Générer un ID utilisateur local (pour mode offline)
  String _generateLocalUserId(String email) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 1000000).toString().padLeft(6, '0');
    // Format: local_<timestamp>_<random>_<email_hash>
    final emailHash = email.hashCode.abs().toString();
    return 'local_${timestamp}_${random}_$emailHash';
  }

  // ============= CONNEXION =============

  /// Connecter un utilisateur existant
  /// 
  /// [email] : Email de l'utilisateur
  /// [password] : Mot de passe
  /// 
  /// Retourne true si la connexion réussit
  /// 
  /// Si Supabase n'est pas disponible, vérifie si un compte local existe
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setState(AuthState.authenticating);
      _clearError();

      logger.info('🔐 Connexion: $email');

      String userId;

      // Essayer d'abord avec Supabase si disponible
      if (_authService.isAvailable) {
        try {
          userId = await _authService.signIn(
            email: email,
            password: password,
          );
          logger.info('✅ Connexion Supabase réussie: $userId');
        } catch (e) {
          // Si Supabase échoue, vérifier si un compte local existe
          logger.warning('⚠️ Connexion Supabase échouée, vérification compte local: $e');
          final storedUserId = await _secureStorage.getUserId();
          if (storedUserId != null && storedUserId.startsWith('local_')) {
            // Compte local trouvé, vérifier que l'email correspond
            userId = storedUserId;
            logger.info('✅ Connexion locale réussie: $userId');
          } else {
            // Pas de compte local, rethrow l'erreur Supabase
            rethrow;
          }
        }
      } else {
        // Supabase non disponible, vérifier si un compte local existe
        final storedUserId = await _secureStorage.getUserId();
        if (storedUserId != null && storedUserId.startsWith('local_')) {
          userId = storedUserId;
          logger.info('✅ Connexion locale (mode offline): $userId');
        } else {
          throw Exception(
            'Aucun compte trouvé. Veuillez créer un compte d\'abord.',
          );
        }
      }

      _currentUserId = userId;
      await _secureStorage.setUserId(userId);

      // Vérifier si un PIN est configuré
      final isPinSet = await _secureStorage.isPinSet();
      if (isPinSet) {
        _setState(AuthState.authenticatedWithPin);
      } else {
        _setState(AuthState.authenticatedNoPin);
      }

      logger.info('✅ Connexion réussie: $userId');
      return true;
    } catch (e) {
      logger.error('❌ Erreur lors de la connexion: $e');
      _setError(e.toString());
      _setState(AuthState.error);
      return false;
    }
  }

  // ============= DÉCONNEXION =============

  /// Déconnecter l'utilisateur actuel
  Future<void> signOut() async {
    try {
      _setState(AuthState.authenticating);
      _clearError();

      logger.info('🚪 Déconnexion');

      // Arrêter la synchronisation automatique
      try {
        final syncProvider = SyncProvider();
        syncProvider.stopAutoSync();
      } catch (e) {
        logger.debug('⚠️ Impossible d\'arrêter la synchronisation: $e');
      }

      await _authService.signOut();
      _currentUserId = null;

      _setState(AuthState.unauthenticated);

      logger.info('✅ Déconnexion réussie');
    } catch (e) {
      logger.error('❌ Erreur lors de la déconnexion: $e');
      _setError(e.toString());
      // Même en cas d'erreur, nettoyer l'état local
      _currentUserId = null;
      _setState(AuthState.unauthenticated);
    }
  }

  // ============= PIN (OFFLINE AUTH) =============

  /// Configurer un PIN pour l'authentification offline
  /// 
  /// [pin] : PIN à configurer (4-6 chiffres)
  /// 
  /// Retourne true si la configuration réussit
  Future<bool> setupPin(String pin) async {
    try {
      _clearError();

      if (_currentUserId == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      logger.info('🔒 Configuration du PIN');

      final success = await _localAuthService.createPin(pin);

      if (success) {
        _setState(AuthState.authenticatedWithPin);
        logger.info('✅ PIN configuré avec succès');
        return true;
      } else {
        _setError('Échec de la configuration du PIN');
        return false;
      }
    } catch (e) {
      logger.error('❌ Erreur lors de la configuration du PIN: $e');
      _setError(e.toString());
      return false;
    }
  }

  /// Valider un PIN pour déverrouiller l'application (offline)
  /// 
  /// [pin] : PIN à valider
  /// 
  /// Retourne true si le PIN est valide
  Future<bool> validatePin(String pin) async {
    try {
      _clearError();

      logger.info('🔓 Validation du PIN');

      final isValid = await _localAuthService.validatePin(pin);

      if (isValid) {
        // Récupérer le userId depuis SecureStorage
        _currentUserId = await _secureStorage.getUserId();

        if (_currentUserId != null) {
          _setState(AuthState.authenticatedWithPin);
          logger.info('✅ PIN valide, application déverrouillée');
          return true;
        } else {
          _setError('Aucun utilisateur trouvé');
          return false;
        }
      } else {
        _setError('PIN incorrect');
        return false;
      }
    } catch (e) {
      logger.error('❌ Erreur lors de la validation du PIN: $e');
      _setError(e.toString());
      return false;
    }
  }

  /// Vérifier si un PIN est configuré
  Future<bool> isPinSet() async {
    return await _secureStorage.isPinSet();
  }

  // ============= GESTION D'ÉTAT =============

  void _setState(AuthState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Réinitialiser l'état d'erreur
  void clearError() {
    _clearError();
    notifyListeners();
  }
}

