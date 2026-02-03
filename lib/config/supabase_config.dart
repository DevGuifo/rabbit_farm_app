/// Configuration Supabase pour BunnyManager
///
/// Ce fichier centralise toute la configuration Supabase.
/// Les valeurs sont chargées depuis les variables d'environnement ou .env
///
/// IMPORTANT: Ne jamais commiter les vraies clés dans le code source !
/// Utiliser --dart-define ou un fichier .env pour les valeurs réelles.
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rabbit_farm_app/core/utils/logger.dart';

/// Configuration Supabase singleton
class SupabaseConfig {
  // Singleton pattern
  static final SupabaseConfig _instance = SupabaseConfig._internal();
  factory SupabaseConfig() => _instance;
  SupabaseConfig._internal();

  // État d'initialisation
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// URL Supabase - Peut être surchargée via --dart-define=SUPABASE_URL=xxx
  ///
  /// IMPORTANT :
  /// - La valeur par défaut ci-dessous est pour le développement.
  /// - En production, utilisez --dart-define pour surcharger.
  static const String _defaultUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://yxepbcxwlthnkhfijhuh.supabase.co',
  );

  /// Clé anonyme Supabase - Peut être surchargée via --dart-define=SUPABASE_ANON_KEY=xxx
  /// C'est la clé PUBLIQUE (anon key), PAS la service_role key !
  ///
  /// IMPORTANT :
  /// - La valeur par défaut ci-dessous est pour le développement.
  /// - En production, utilisez --dart-define pour surcharger.
  static const String _defaultAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_S4WsS_DaFGXbe7MTajeyCA_6FPUyqQV',
  );

  /// Vérifie si la configuration est valide
  bool get hasValidConfig =>
      _defaultUrl.isNotEmpty &&
      _defaultAnonKey.isNotEmpty &&
      _defaultUrl.startsWith('https://');

  /// Initialise Supabase si la configuration est valide
  ///
  /// Retourne true si l'initialisation a réussi, false sinon.
  /// En mode offline-first, l'app fonctionne même si Supabase n'est pas configuré.
  Future<bool> initialize() async {
    if (_isInitialized) {
      logger.info('SupabaseConfig: Déjà initialisé');
      return true;
    }

    if (!hasValidConfig) {
      logger.warning(
        'SupabaseConfig: Configuration manquante ou invalide. '
        'Mode offline uniquement. '
        'Définissez SUPABASE_URL et SUPABASE_ANON_KEY pour activer la sync.',
      );
      return false;
    }

    try {
      await Supabase.initialize(
        url: _defaultUrl,
        anonKey: _defaultAnonKey,
        debug: kDebugMode,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
      );

      _isInitialized = true;
      logger.info('SupabaseConfig: Initialisation réussie');
      return true;
    } catch (e) {
      logger.error('SupabaseConfig: Erreur d\'initialisation - $e');
      return false;
    }
  }

  /// Accès au client Supabase (null si non initialisé)
  SupabaseClient? get client {
    if (!_isInitialized) {
      logger.warning('SupabaseConfig: Client demandé mais non initialisé');
      return null;
    }
    return Supabase.instance.client;
  }

  /// Accès direct au client (throw si non initialisé)
  /// À utiliser uniquement quand on est SÛR que Supabase est configuré
  SupabaseClient get clientOrThrow {
    if (!_isInitialized) {
      throw StateError(
        'Supabase non initialisé. '
        'Vérifiez hasValidConfig avant d\'appeler clientOrThrow.',
      );
    }
    return Supabase.instance.client;
  }

  /// Utilisateur actuellement connecté (null si non connecté ou non initialisé)
  User? get currentUser {
    if (!_isInitialized) return null;
    return Supabase.instance.client.auth.currentUser;
  }

  /// Session actuelle (null si non connectée ou non initialisée)
  Session? get currentSession {
    if (!_isInitialized) return null;
    return Supabase.instance.client.auth.currentSession;
  }

  /// Vérifie si l'utilisateur est connecté à Supabase
  bool get isAuthenticated => currentUser != null;

  /// Stream des changements d'état d'authentification
  Stream<AuthState>? get authStateChanges {
    if (!_isInitialized) return null;
    return Supabase.instance.client.auth.onAuthStateChange;
  }
}

/// Accès global à la configuration Supabase
final supabaseConfig = SupabaseConfig();
