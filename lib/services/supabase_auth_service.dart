import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'secure_storage_service.dart';

/// Service d'authentification Supabase
/// 
/// Gère :
/// - Inscription (signUp)
/// - Connexion (signIn)
/// - Déconnexion (signOut)
/// - Rafraîchissement des tokens
/// - Gestion de la session
class SupabaseAuthService {
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();

  final SecureStorageService _secureStorage = SecureStorageService();
  bool _isInitialized = false;

  /// Vérifier si Supabase est disponible et initialisé
  /// 
  /// Retourne true si Supabase peut être utilisé pour l'authentification
  bool get isAvailable => _isInitialized && SupabaseConfig.isValid;

  /// Initialiser Supabase
  /// 
  /// Doit être appelé au démarrage de l'application (dans main.dart)
  /// 
  /// En mode offline, l'initialisation échoue silencieusement pour permettre
  /// à l'application de démarrer sans réseau
  Future<void> initialize() async {
    if (_isInitialized) {
      logger.warning('Supabase déjà initialisé');
      return;
    }

    if (!SupabaseConfig.isValid) {
      logger.warning('⚠️ Configuration Supabase invalide - Mode offline uniquement');
      // Ne pas throw pour permettre le démarrage offline
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      _isInitialized = true;
      logger.info('✅ Supabase initialisé');

      // Restaurer la session si elle existe (seulement si online)
      await _restoreSession();
    } catch (e) {
      // En mode offline, ne pas bloquer le démarrage
      logger.warning('⚠️ Erreur lors de l\'initialisation Supabase (mode offline possible): $e');
      // Ne pas rethrow - permettre à l'application de démarrer en mode offline
      // L'initialisation sera réessayée lors de la prochaine connexion
    }
  }

  /// Restaurer la session depuis SecureStorage
  /// 
  /// En mode offline, cette méthode échoue silencieusement
  Future<void> _restoreSession() async {
    try {
      final accessToken = await _secureStorage.getAccessToken();
      final refreshToken = await _secureStorage.getRefreshToken();

      if (accessToken != null && refreshToken != null) {
        // Essayer de restaurer la session (peut échouer en mode offline)
        final response = await Supabase.instance.client.auth.setSession(
          accessToken,
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            logger.warning('⚠️ Timeout lors de la restauration de session (mode offline)');
            throw TimeoutException('Timeout - mode offline possible');
          },
        );

        if (response.session != null) {
          logger.info('✅ Session restaurée');
          await _saveSession(response.session!);
        } else {
          // Token invalide, nettoyer
          await _secureStorage.clearSupabaseTokens();
          logger.warning('⚠️ Session invalide, tokens supprimés');
        }
      }
    } on TimeoutException {
      // Timeout = probablement offline, ne pas nettoyer les tokens
      logger.info('ℹ️ Restauration de session ignorée (mode offline)');
    } catch (e) {
      // Erreur réseau = probablement offline, ne pas nettoyer les tokens
      logger.info('ℹ️ Restauration de session ignorée (mode offline): $e');
      // Ne pas nettoyer les tokens en cas d'erreur réseau
      // Ils seront utilisés pour le déverrouillage PIN
    }
  }

  /// Sauvegarder la session dans SecureStorage
  Future<void> _saveSession(Session session) async {
    await _secureStorage.setSupabaseTokens(
      userId: session.user.id,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
    );
  }

  /// Obtenir l'instance Supabase
  SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception('Supabase non initialisé. Appelez initialize() d\'abord.');
    }
    return Supabase.instance.client;
  }

  /// Vérifier si l'utilisateur est connecté
  /// 
  /// Retourne false si Supabase n'est pas initialisé (mode offline)
  bool get isAuthenticated {
    if (!_isInitialized) return false;
    try {
      return client.auth.currentSession != null;
    } catch (e) {
      // En cas d'erreur (ex: Supabase non initialisé), retourner false
      logger.debug('⚠️ Erreur lors de la vérification de session: $e');
      return false;
    }
  }

  /// Obtenir l'ID de l'utilisateur actuel
  /// 
  /// Retourne null si Supabase n'est pas initialisé (mode offline)
  String? get currentUserId {
    if (!_isInitialized) return null;
    try {
      return client.auth.currentUser?.id;
    } catch (e) {
      // En cas d'erreur (ex: Supabase non initialisé), retourner null
      logger.debug('⚠️ Erreur lors de la récupération du userId: $e');
      return null;
    }
  }

  /// Obtenir l'email de l'utilisateur actuel
  /// 
  /// Retourne null si Supabase n'est pas initialisé (mode offline)
  String? get currentUserEmail {
    if (!_isInitialized) return null;
    try {
      return client.auth.currentUser?.email;
    } catch (e) {
      // En cas d'erreur (ex: Supabase non initialisé), retourner null
      logger.debug('⚠️ Erreur lors de la récupération de l\'email: $e');
      return null;
    }
  }

  // ============= INSCRIPTION =============

  /// Inscrire un nouvel utilisateur
  /// 
  /// [email] : Email de l'utilisateur
  /// [password] : Mot de passe (minimum 6 caractères)
  /// 
  /// Retourne l'ID utilisateur (UUID)
  Future<String> signUp({
    required String email,
    required String password,
  }) async {
    if (!isAvailable) {
      throw Exception(
        'Le service de synchronisation n\'est pas disponible. '
        'Vérifiez votre connexion Internet ou contactez le support si le problème persiste.',
      );
    }

    try {
      logger.info('📝 Inscription de l\'utilisateur: $email');

      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Échec de l\'inscription : utilisateur non créé');
      }

      // Si une session est créée automatiquement, la sauvegarder
      if (response.session != null) {
        await _saveSession(response.session!);
        logger.info('✅ Inscription réussie, session créée');
      } else {
        logger.info('✅ Inscription réussie, email de confirmation requis');
      }

      return response.user!.id;
    } on AuthException catch (e) {
      logger.error('❌ Erreur d\'authentification: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      logger.error('❌ Erreur lors de l\'inscription: $e');
      rethrow;
    }
  }

  // ============= CONNEXION =============

  /// Connecter un utilisateur existant
  /// 
  /// [email] : Email de l'utilisateur
  /// [password] : Mot de passe
  /// 
  /// Retourne l'ID utilisateur (UUID)
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    if (!isAvailable) {
      throw Exception(
        'Le service de synchronisation n\'est pas disponible. '
        'Vérifiez votre connexion Internet ou contactez le support si le problème persiste.',
      );
    }

    try {
      logger.info('🔐 Connexion de l\'utilisateur: $email');

      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw Exception('Échec de la connexion : session non créée');
      }

      if (response.user == null) {
        throw Exception('Échec de la connexion : utilisateur non créé');
      }

      await _saveSession(response.session!);
      logger.info('✅ Connexion réussie');

      return response.user!.id;
    } on AuthException catch (e) {
      logger.error('❌ Erreur d\'authentification: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      logger.error('❌ Erreur lors de la connexion: $e');
      rethrow;
    }
  }

  // ============= DÉCONNEXION =============

  /// Déconnecter l'utilisateur actuel
  Future<void> signOut() async {
    if (!_isInitialized) {
      logger.warning('Supabase non initialisé, nettoyage local uniquement');
      await _secureStorage.clearSupabaseTokens();
      return;
    }

    try {
      logger.info('🚪 Déconnexion de l\'utilisateur');

      await client.auth.signOut();
      await _secureStorage.clearSupabaseTokens();
      await _secureStorage.clearLastSyncTimestamp();

      logger.info('✅ Déconnexion réussie');
    } catch (e) {
      logger.error('❌ Erreur lors de la déconnexion: $e');
      // Nettoyer quand même les tokens locaux
      await _secureStorage.clearSupabaseTokens();
      rethrow;
    }
  }

  // ============= RAFRAÎCHISSEMENT DE TOKEN =============

  /// Rafraîchir le token d'accès
  /// 
  /// Appelé automatiquement par Supabase, mais peut être appelé manuellement
  Future<void> refreshSession() async {
    if (!_isInitialized) {
      throw Exception('Supabase non initialisé');
    }

    try {
      final response = await client.auth.refreshSession();

      if (response.session != null) {
        await _saveSession(response.session!);
        logger.info('✅ Session rafraîchie');
      }
    } catch (e) {
      logger.error('❌ Erreur lors du rafraîchissement: $e');
      // Si le refresh échoue, déconnecter
      await signOut();
      rethrow;
    }
  }

  // ============= RÉINITIALISATION DE MOT DE PASSE =============

  /// Envoyer un email de réinitialisation de mot de passe
  Future<void> resetPassword(String email) async {
    if (!_isInitialized) {
      throw Exception('Supabase non initialisé');
    }

    try {
      logger.info('📧 Envoi email de réinitialisation pour: $email');

      await client.auth.resetPasswordForEmail(email);

      logger.info('✅ Email de réinitialisation envoyé');
    } on AuthException catch (e) {
      logger.error('❌ Erreur: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      logger.error('❌ Erreur lors de l\'envoi: $e');
      rethrow;
    }
  }

  // ============= GESTION DES ERREURS =============

  /// Convertir les exceptions AuthException en messages utilisateur
  Exception _handleAuthException(AuthException e) {
    switch (e.statusCode) {
      case 'invalid_credentials':
        return Exception('Email ou mot de passe incorrect');
      case 'email_not_confirmed':
        return Exception(
          'Veuillez confirmer votre email avant de vous connecter',
        );
      case 'signup_disabled':
        return Exception('Les inscriptions sont temporairement désactivées');
      case 'email_rate_limit_exceeded':
        return Exception(
          'Trop de tentatives. Veuillez réessayer plus tard',
        );
      case 'weak_password':
        return Exception(
          'Le mot de passe est trop faible. '
          'Utilisez au moins 6 caractères',
        );
      case 'user_already_registered':
        return Exception('Cet email est déjà utilisé');
      default:
        return Exception(e.message);
    }
  }

  // ============= ÉCOUTE DES CHANGEMENTS DE SESSION =============

  /// Écouter les changements de session (connexion/déconnexion)
  /// 
  /// Utile pour mettre à jour l'UI automatiquement
  Stream<AuthState> get authStateChanges {
    if (!_isInitialized) {
      return const Stream.empty();
    }
    return client.auth.onAuthStateChange;
  }
}

