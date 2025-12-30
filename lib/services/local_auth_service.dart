import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../services/secure_storage_service.dart';
import '../utils/logger.dart';

/// Service d'authentification locale via PIN
/// 
/// Gère :
/// - Création du PIN (hash avec PBKDF2)
/// - Validation du PIN (offline)
/// - Stockage sécurisé du hash
class LocalAuthService {
  static final LocalAuthService _instance = LocalAuthService._internal();
  factory LocalAuthService() => _instance;
  LocalAuthService._internal();

  final SecureStorageService _secureStorage = SecureStorageService();

  // Paramètres PBKDF2
  static const int _iterations = 100000; // 100k iterations pour sécurité
  static const int _keyLength = 32; // 256 bits
  static const int _saltLength = 32; // 32 bytes

  // ============= CRÉATION DU PIN =============

  /// Créer et stocker un PIN
  /// 
  /// [pin] : PIN à configurer (4-6 chiffres recommandé)
  /// 
  /// Retourne true si la création réussit
  Future<bool> createPin(String pin) async {
    try {
      // Valider le PIN
      if (!_isValidPin(pin)) {
        logger.error('❌ PIN invalide');
        return false;
      }

      logger.info('🔒 Création du PIN');

      // Générer un salt aléatoire
      final salt = _generateSalt();

      // Hasher le PIN avec PBKDF2
      final hash = await _hashPin(pin, salt);

      // Stocker le hash et le salt dans SecureStorage
      await _secureStorage.setPinCredentials(
        hash: base64Encode(hash),
        salt: base64Encode(salt),
      );

      logger.info('✅ PIN créé et stocké avec succès');
      return true;
    } catch (e) {
      logger.error('❌ Erreur lors de la création du PIN: $e');
      return false;
    }
  }

  // ============= VALIDATION DU PIN =============

  /// Valider un PIN
  /// 
  /// [pin] : PIN à valider
  /// 
  /// Retourne true si le PIN est correct
  Future<bool> validatePin(String pin) async {
    try {
      // Récupérer le hash et le salt depuis SecureStorage
      final storedHash = await _secureStorage.getPinHash();
      final storedSalt = await _secureStorage.getPinSalt();

      if (storedHash == null || storedSalt == null) {
        logger.error('❌ PIN non configuré');
        return false;
      }

      // Hasher le PIN saisi avec le même salt
      final saltBytes = base64Decode(storedSalt);
      final computedHash = await _hashPin(pin, saltBytes);
      final computedHashBase64 = base64Encode(computedHash);

      // Comparer les hashs (timing-safe)
      final isValid = _compareHashes(storedHash, computedHashBase64);

      if (isValid) {
        logger.info('✅ PIN valide');
      } else {
        logger.warning('⚠️ PIN invalide');
      }

      return isValid;
    } catch (e) {
      logger.error('❌ Erreur lors de la validation du PIN: $e');
      return false;
    }
  }

  // ============= SUPPRESSION DU PIN =============

  /// Supprimer le PIN configuré
  Future<void> deletePin() async {
    try {
      await _secureStorage.clearPin();
      logger.info('✅ PIN supprimé');
    } catch (e) {
      logger.error('❌ Erreur lors de la suppression du PIN: $e');
      rethrow;
    }
  }

  // ============= VÉRIFICATION =============

  /// Vérifier si un PIN est configuré
  Future<bool> isPinSet() async {
    return await _secureStorage.isPinSet();
  }

  // ============= MÉTHODES PRIVÉES =============

  /// Valider le format du PIN
  /// 
  /// Accepte 4-6 chiffres
  bool _isValidPin(String pin) {
    if (pin.isEmpty) return false;
    if (pin.length < 4 || pin.length > 6) return false;

    // Vérifier que ce sont uniquement des chiffres
    final regex = RegExp(r'^\d+$');
    return regex.hasMatch(pin);
  }

  /// Générer un salt aléatoire
  List<int> _generateSalt() {
    final random = Random.secure();
    return List<int>.generate(_saltLength, (i) => random.nextInt(256));
  }

  /// Hasher un PIN avec PBKDF2
  /// 
  /// [pin] : PIN en clair
  /// [salt] : Salt (bytes)
  /// 
  /// Retourne le hash (bytes)
  Future<List<int>> _hashPin(String pin, List<int> salt) async {
    // Convertir le PIN en bytes
    final pinBytes = utf8.encode(pin);

    // PBKDF2 avec SHA-256
    // Note: crypto package ne supporte pas directement PBKDF2
    // On utilise une implémentation basée sur HMAC-SHA256
    return _pbkdf2(pinBytes, salt, _iterations, _keyLength);
  }

  /// Implémentation PBKDF2 basée sur HMAC-SHA256
  /// 
  /// [password] : Mot de passe en bytes
  /// [salt] : Salt en bytes
  /// [iterations] : Nombre d'itérations
  /// [keyLength] : Longueur de la clé en bytes
  /// 
  /// Retourne la clé dérivée
  List<int> _pbkdf2(
    List<int> password,
    List<int> salt,
    int iterations,
    int keyLength,
  ) {
    final hmac = Hmac(sha256, password);
    final result = <int>[];

    // Calculer le nombre de blocs nécessaires
    final blocksNeeded = (keyLength / 32).ceil();

    for (int i = 1; i <= blocksNeeded; i++) {
      // U1 = HMAC(password, salt || i)
      final u1Input = <int>[...salt, ..._intToBytes(i)];
      var u = hmac.convert(u1Input).bytes;
      final t = List<int>.from(u);

      // U2, U3, ... U_iterations
      for (int j = 1; j < iterations; j++) {
        u = hmac.convert(u).bytes;
        // XOR avec le résultat précédent
        for (int k = 0; k < t.length; k++) {
          t[k] ^= u[k];
        }
      }

      result.addAll(t);
    }

    // Tronquer à la longueur demandée
    return result.take(keyLength).toList();
  }

  /// Convertir un entier en bytes (big-endian)
  List<int> _intToBytes(int value) {
    return [
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];
  }

  /// Comparer deux hashs de manière timing-safe
  /// 
  /// Évite les attaques par timing
  bool _compareHashes(String hash1, String hash2) {
    if (hash1.length != hash2.length) return false;

    int result = 0;
    for (int i = 0; i < hash1.length; i++) {
      result |= hash1.codeUnitAt(i) ^ hash2.codeUnitAt(i);
    }

    return result == 0;
  }
}

