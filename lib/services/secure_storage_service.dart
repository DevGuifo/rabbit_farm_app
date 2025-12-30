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
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // ============= CLÉS DE STOCKAGE =============

  static const String _keyUserId = 'supabase_user_id';
  static const String _keyAccessToken = 'supabase_access_token';
  static const String _keyRefreshToken = 'supabase_refresh_token';
  static const String _keyPinHash = 'local_pin_hash';
  static const String _keyPinSalt = 'local_pin_salt';
  static const String _keyIsPinSet = 'is_pin_set';
  static const String _keyLastSyncTimestamp = 'last_sync_timestamp';

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
}

