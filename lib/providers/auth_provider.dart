import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../services/local_auth_service.dart';
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

/// Provider pour gérer l'authentification (offline-first)
///
/// Gère :
/// - L'état d'authentification
/// - L'inscription/connexion locale
/// - La vérification du PIN (offline)
/// - La session utilisateur
class AuthProvider extends ChangeNotifier {
  static final AuthProvider _instance = AuthProvider._internal();
  factory AuthProvider() => _instance;
  AuthProvider._internal();

  final AuthService _authService = AuthService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final LocalAuthService _localAuthService = LocalAuthService();

  AuthState _state = AuthState.initializing;
  String? _errorMessage;
  String? _currentUserId;

  // ============= GETTERS =============

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _currentUserId;
  bool get isAuthenticated =>
      _state == AuthState.authenticatedWithPin ||
      _state == AuthState.authenticatedNoPin;
  bool get hasPin => _state == AuthState.authenticatedWithPin;

  // ============= INITIALISATION =============

  /// Initialiser le provider
  ///
  /// Vérifie si une session existe et si un PIN est configuré
  Future<void> initialize() async {
    try {
      _setState(AuthState.initializing);

      // Initialiser le service d'authentification
      await _authService.initialize();

      // Vérifier si un userId est stocké localement
      final storedUserId = await _secureStorage.getUserId();
      final isPinSet = await _secureStorage.isPinSet();

      if (storedUserId != null) {
        _currentUserId = storedUserId;
        logger.info('✅ Utilisateur trouvé: $_currentUserId');

        if (isPinSet) {
          _setState(AuthState.authenticatedWithPin);
          logger.info('ℹ️ PIN configuré - déverrouillage requis');
        } else {
          _setState(AuthState.authenticatedNoPin);
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      logger.error('❌ Erreur lors de l\'initialisation AuthProvider: $e');
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
  Future<bool> signUp({required String email, required String password}) async {
    try {
      _setState(AuthState.authenticating);
      _clearError();

      logger.info('📝 Inscription: $email');

      final userId = await _authService.signUp(
        email: email,
        password: password,
      );

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

  // ============= CONNEXION =============

  /// Connecter un utilisateur existant
  ///
  /// [email] : Email de l'utilisateur
  /// [password] : Mot de passe
  ///
  /// Retourne true si la connexion réussit
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setState(AuthState.authenticating);
      _clearError();

      logger.info('🔐 Connexion: $email');

      final userId = await _authService.signIn(
        email: email,
        password: password,
      );

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
