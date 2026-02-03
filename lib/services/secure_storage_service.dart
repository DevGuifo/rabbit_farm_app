import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger.dart';

/// Service de stockage sécurisé pour données sensibles
///
/// Utilise flutter_secure_storage qui s'appuie sur :
/// - Android : Keystore (AES-256)
/// - iOS : Keychain (AES-256)
/// - Linux : LibSecret
/// - Windows : Win32 API
class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ============= CLÉS DE STOCKAGE =============

  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyPinHash = 'local_pin_hash';
  static const String _keyPinSalt = 'local_pin_salt';
  static const String _keyIsPinSet = 'is_pin_set';
  static const String _keyLastSyncTimestamp = 'last_sync_timestamp';
  // Mapping local: stocke l'ID DB lié à l'utilisateur auth actuel
  static const String _keyLinkedDbUserId = 'linked_db_user_id';

  // ============= MÉTHODES GÉNÉRIQUES =============

  /// Stocker une valeur de manière sécurisée
  Future<void> write(String key, String? value) async {
    try {
      if (value == null) {
        await _storage.delete(key: key);
      } else {
        await _storage.write(key: key, value: value);
      }
    } catch (e) {
      logger.error('Erreur lors de l\'écriture dans SecureStorage: $e');
      rethrow;
    }
  }

  /// Lire une valeur de manière sécurisée
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      logger.error('Erreur lors de la lecture depuis SecureStorage: $e');
      return null;
    }
  }

  /// Supprimer une valeur
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      logger.error('Erreur lors de la suppression depuis SecureStorage: $e');
    }
  }

  /// Supprimer toutes les valeurs (déconnexion)
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      logger.info('✅ Toutes les données sécurisées supprimées');
    } catch (e) {
      logger.error('Erreur lors de la suppression complète: $e');
      rethrow;
    }
  }

  // ============= MÉTHODES SPÉCIFIQUES - SUPABASE =============

  /// Stocker l'ID utilisateur Supabase
  Future<void> setUserId(String userId) async {
    await write(_keyUserId, userId);
    logger.info('✅ User ID stocké');
  }

  /// Récupérer l'ID utilisateur Supabase
  Future<String?> getUserId() async {
    return await read(_keyUserId);
  }

  /// Stocker le token d'accès Supabase
  Future<void> setAccessToken(String token) async {
    await write(_keyAccessToken, token);
  }

  /// Récupérer le token d'accès Supabase
  Future<String?> getAccessToken() async {
    return await read(_keyAccessToken);
  }

  /// Stocker le token de rafraîchissement Supabase
  Future<void> setRefreshToken(String token) async {
    await write(_keyRefreshToken, token);
  }

  /// Récupérer le token de rafraîchissement Supabase
  Future<String?> getRefreshToken() async {
    return await read(_keyRefreshToken);
  }

  /// Stocker les tokens Supabase
  Future<void> setSupabaseTokens({
    required String userId,
    required String accessToken,
    required String refreshToken,
  }) async {
    await setUserId(userId);
    await setAccessToken(accessToken);
    await setRefreshToken(refreshToken);
    logger.info('✅ Tokens Supabase stockés');
  }

  /// Supprimer les tokens Supabase
  Future<void> clearSupabaseTokens() async {
    await delete(_keyUserId);
    await delete(_keyAccessToken);
    await delete(_keyRefreshToken);
    logger.info('✅ Tokens Supabase supprimés');
  }

  // ============= MÉTHODES SPÉCIFIQUES - PIN =============

  /// Stocker le hash du PIN
  Future<void> setPinHash(String hash) async {
    await write(_keyPinHash, hash);
  }

  /// Récupérer le hash du PIN
  Future<String?> getPinHash() async {
    return await read(_keyPinHash);
  }

  /// Stocker le salt du PIN
  Future<void> setPinSalt(String salt) async {
    await write(_keyPinSalt, salt);
  }

  /// Récupérer le salt du PIN
  Future<String?> getPinSalt() async {
    return await read(_keyPinSalt);
  }

  /// Stocker le hash et le salt du PIN
  Future<void> setPinCredentials({
    required String hash,
    required String salt,
  }) async {
    await setPinHash(hash);
    await setPinSalt(salt);
    await setIsPinSet(true);
    logger.info('✅ PIN stocké (hash + salt)');
  }

  /// Vérifier si un PIN est configuré
  Future<bool> isPinSet() async {
    final value = await read(_keyIsPinSet);
    return value == 'true';
  }

  /// Marquer le PIN comme configuré
  Future<void> setIsPinSet(bool value) async {
    await write(_keyIsPinSet, value.toString());
  }

  /// Supprimer les données PIN
  Future<void> clearPin() async {
    await delete(_keyPinHash);
    await delete(_keyPinSalt);
    await setIsPinSet(false);
    logger.info('✅ PIN supprimé');
  }

  // ============= MÉTHODES SPÉCIFIQUES - SYNC =============

  /// Stocker le timestamp de la dernière synchronisation
  Future<void> setLastSyncTimestamp(String timestamp) async {
    await write(_keyLastSyncTimestamp, timestamp);
  }

  /// Récupérer le timestamp de la dernière synchronisation
  Future<String?> getLastSyncTimestamp() async {
    return await read(_keyLastSyncTimestamp);
  }

  /// Supprimer le timestamp de synchronisation
  Future<void> clearLastSyncTimestamp() async {
    await delete(_keyLastSyncTimestamp);
  }

  // ============= MÉTHODES SPÉCIFIQUES - EMAIL =============

  /// Stocker l'email utilisateur
  Future<void> setUserEmail(String email) async {
    await write(_keyUserEmail, email);
    logger.info('✅ Email utilisateur stocké');
  }

  /// Récupérer l'email utilisateur
  Future<String?> getUserEmail() async {
    return await read(_keyUserEmail);
  }

  /// Stocker l'ID de l'utilisateur dans la base locale (mapping auth_uid -> local DB id)
  /// @deprecated Utiliser setLinkedDbUserIdForAuthUid pour le multi-utilisateur
  Future<void> setLinkedDbUserId(String dbUserId) async {
    await write(_keyLinkedDbUserId, dbUserId);
    logger.info('✅ Mapping auth->db stocké');
  }

  /// Récupérer l'ID DB lié à l'utilisateur authentifié
  /// @deprecated Utiliser getLinkedDbUserIdForAuthUid pour le multi-utilisateur
  Future<String?> getLinkedDbUserId() async {
    return await read(_keyLinkedDbUserId);
  }

  /// Supprimer le mapping local entre auth uid et user DB
  /// @deprecated Utiliser clearLinkedDbUserIdForAuthUid pour le multi-utilisateur
  Future<void> clearLinkedDbUserId() async {
    await delete(_keyLinkedDbUserId);
    logger.info('✅ Mapping auth->db supprimé');
  }

  // ============= MÉTHODES MULTI-UTILISATEURS =============
  // Préfixe pour les mappings par authUid
  static const String _keyAuthDbMappingPrefix = 'auth_db_mapping_';

  /// Stocker le mapping auth_uid -> DB user id (multi-utilisateurs)
  ///
  /// [authUid] : L'identifiant d'authentification (UUID)
  /// [dbUserId] : L'ID de l'utilisateur dans la table users (int)
  Future<void> setLinkedDbUserIdForAuthUid(String authUid, int dbUserId) async {
    await write('$_keyAuthDbMappingPrefix$authUid', dbUserId.toString());
    logger.info('✅ Mapping multi-user auth->db stocké pour $authUid');
  }

  /// Récupérer l'ID DB lié à un auth_uid spécifique (multi-utilisateurs)
  ///
  /// [authUid] : L'identifiant d'authentification (UUID)
  /// Retourne l'ID DB (int) ou null si non trouvé
  Future<int?> getLinkedDbUserIdForAuthUid(String authUid) async {
    final value = await read('$_keyAuthDbMappingPrefix$authUid');
    if (value == null) return null;
    return int.tryParse(value);
  }

  /// Supprimer le mapping pour un auth_uid spécifique (multi-utilisateurs)
  ///
  /// [authUid] : L'identifiant d'authentification (UUID)
  Future<void> clearLinkedDbUserIdForAuthUid(String authUid) async {
    await delete('$_keyAuthDbMappingPrefix$authUid');
    logger.info('✅ Mapping multi-user supprimé pour $authUid');
  }

  // ============= MÉTHODES SPÉCIFIQUES - NOM =============

  /// Stocker le nom complet de l'utilisateur
  Future<void> setUserName(String name) async {
    await write(_keyUserName, name);
    logger.info('✅ Nom utilisateur stocké');
  }

  /// Récupérer le nom complet de l'utilisateur
  Future<String?> getUserName() async {
    return await read(_keyUserName);
  }

  // ============= MÉTHODES DE NETTOYAGE =============

  /// Supprimer uniquement les tokens de session (pas les données utilisateur)
  Future<void> clearSessionTokens() async {
    await delete(_keyAccessToken);
    await delete(_keyRefreshToken);
    logger.info('✅ Tokens de session supprimés');
  }

  /// Supprimer toutes les données (déconnexion complète)
  Future<void> clearAll() async {
    await deleteAll();
    logger.info('✅ Toutes les données supprimées');
  }
}
