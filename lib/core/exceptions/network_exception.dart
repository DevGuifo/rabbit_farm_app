import 'app_exception.dart';

/// Exception levée lors d'erreurs réseau (timeout, connexion échouée, etc.)
class NetworkException extends AppException {
  /// Type d'erreur réseau
  final NetworkErrorType type;

  const NetworkException({
    required this.type,
    required super.message,
    super.details,
    super.stackTrace,
  }) : super(
          code: 'NETWORK_ERROR',
        );

  /// Créer une NetworkException pour un timeout
  factory NetworkException.timeout([Duration? timeout]) {
    return NetworkException(
      type: NetworkErrorType.timeout,
      message: timeout != null
          ? 'La connexion a expiré après ${timeout.inSeconds} secondes'
          : 'La connexion a expiré. Veuillez réessayer.',
    );
  }

  /// Créer une NetworkException pour une connexion échouée
  factory NetworkException.connectionFailed([dynamic details]) {
    return NetworkException(
      type: NetworkErrorType.connectionFailed,
      message: 'Impossible de se connecter au serveur',
      details: details,
    );
  }

  /// Créer une NetworkException pour une erreur HTTP
  factory NetworkException.httpError(int statusCode, [String? message]) {
    return NetworkException(
      type: NetworkErrorType.httpError,
      message: message ?? 'Erreur HTTP $statusCode',
      details: {'statusCode': statusCode},
    );
  }

  /// Créer une NetworkException pour une erreur générique
  factory NetworkException.generic(String message, [dynamic details]) {
    return NetworkException(
      type: NetworkErrorType.unknown,
      message: message,
      details: details,
    );
  }
}

/// Types d'erreurs réseau possibles
enum NetworkErrorType {
  timeout,
  connectionFailed,
  httpError,
  unknown,
}
