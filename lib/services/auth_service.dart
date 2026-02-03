import 'dart:async';
import 'dart:math';
import 'secure_storage_service.dart';
import '../utils/logger.dart';

/// Service d'authentification local (offline-first)
///
/// Gère l'authentification entièrement en local avec :
/// - Création de compte local
/// - Stockage sécurisé des identifiants
/// - Préparation pour synchronisation future
///
/// NOTE: La synchronisation Supabase sera ajoutée dans une phase ultérieure
/// comme couche optionnelle, sans modifier ce service.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SecureStorageService _secureStorage = SecureStorageService();
  bool _isInitialized = false;

  /// Indique si le service est initialisé
  bool get isInitialized => _isInitialized;

  /// Toujours disponible en mode offline-first
  bool get isAvailable => true;

  /// Initialiser le service
  Future<void> initialize() async {
    if (_isInitialized) {
      logger.warning('AuthService déjà initialisé');
      return;
    }

    try {
      _isInitialized = true;
      logger.info('✅ AuthService initialisé (mode offline-first)');
    } catch (e) {
      logger.error('❌ Erreur lors de l\'initialisation AuthService: $e');
    }
  }

  /// Vérifier si un utilisateur est authentifié localement
  Future<bool> get isAuthenticated async {
    final userId = await _secureStorage.getUserId();
    return userId != null && userId.isNotEmpty;
  }

  /// Obtenir l'ID de l'utilisateur actuel
  Future<String?> get currentUserId async {
    return await _secureStorage.getUserId();
  }

  /// Obtenir l'email de l'utilisateur actuel
  Future<String?> get currentUserEmail async {
    return await _secureStorage.getUserEmail();
  }

  // ============= INSCRIPTION =============

  /// Inscrire un nouvel utilisateur (local uniquement)
  ///
  /// [email] : Email de l'utilisateur
  /// [password] : Mot de passe (stocké de manière sécurisée)
  /// [name] : Nom complet de l'utilisateur (optionnel)
  ///
  /// Retourne l'ID utilisateur local généré
  Future<String> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      logger.info('📝 Inscription locale: $email');

      // Générer un ID utilisateur local unique
      final userId = _generateLocalUserId(email);

      // Sauvegarder les informations localement
      await _secureStorage.setUserId(userId);
      await _secureStorage.setUserEmail(email);
      if (name != null && name.isNotEmpty) {
        await _secureStorage.setUserName(name);
      }
      // Note: Le mot de passe est géré par le système de PIN local
      // et n'est pas stocké en clair

      logger.info('✅ Compte local créé: $userId');
      return userId;
    } catch (e) {
      logger.error('❌ Erreur lors de l\'inscription locale: $e');
      rethrow;
    }
  }

  /// Générer un ID utilisateur local unique
  String _generateLocalUserId(String email) {
    // Utiliser un UUIDv4 minimal pour garantir un ID local stable et non prévisible
    return _uuidV4();
  }

  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String _uuidV4() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    return '${_bytesToHex(bytes.sublist(0, 4))}-${_bytesToHex(bytes.sublist(4, 6))}-${_bytesToHex(bytes.sublist(6, 8))}-${_bytesToHex(bytes.sublist(8, 10))}-${_bytesToHex(bytes.sublist(10, 16))}';
  }

  // ============= CONNEXION =============

  /// Connecter un utilisateur existant (vérification locale)
  ///
  /// En mode offline-first, la connexion vérifie simplement
  /// si un compte local existe pour cet email.
  ///
  /// Retourne l'ID utilisateur si trouvé
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      logger.info('🔐 Connexion locale: $email');

      // Vérifier si un compte local existe
      final storedUserId = await _secureStorage.getUserId();
      final storedEmail = await _secureStorage.getUserEmail();

      if (storedUserId == null || storedEmail == null) {
        throw Exception(
          'Aucun compte trouvé. Veuillez créer un compte d\'abord.',
        );
      }

      // Vérifier que l'email correspond
      if (storedEmail.toLowerCase() != email.toLowerCase()) {
        throw Exception('Email ou mot de passe incorrect.');
      }

      // Note: La validation du mot de passe est gérée par le PIN
      // qui est vérifié après la connexion

      logger.info('✅ Connexion locale réussie: $storedUserId');
      return storedUserId;
    } catch (e) {
      logger.error('❌ Erreur lors de la connexion locale: $e');
      rethrow;
    }
  }

  // ============= DÉCONNEXION =============

  /// Déconnecter l'utilisateur actuel
  ///
  /// Note: En mode offline, cela ne supprime pas les données locales,
  /// seulement la session active.
  Future<void> signOut() async {
    try {
      logger.info('🚪 Déconnexion locale');

      // Ne pas supprimer les données utilisateur,
      // seulement les tokens de session
      await _secureStorage.clearSessionTokens();

      logger.info('✅ Déconnexion réussie');
    } catch (e) {
      logger.error('❌ Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  // ============= RÉINITIALISATION =============

  /// Réinitialiser complètement le compte local
  ///
  /// ⚠️ ATTENTION: Supprime toutes les données d'authentification
  Future<void> resetAccount() async {
    try {
      logger.warning('⚠️ Réinitialisation du compte local');

      await _secureStorage.clearAll();

      logger.info('✅ Compte local réinitialisé');
    } catch (e) {
      logger.error('❌ Erreur lors de la réinitialisation: $e');
      rethrow;
    }
  }
}
