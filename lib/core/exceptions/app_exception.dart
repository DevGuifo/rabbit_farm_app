/// Classe de base abstraite pour toutes les exceptions métier de l'application
abstract class AppException implements Exception {
  /// Code d'erreur unique pour identifier le type d'erreur
  final String code;

  /// Message d'erreur localisable pour l'utilisateur
  final String message;

  /// Détails techniques de l'erreur (pour le logging)
  final dynamic details;

  /// Stack trace associé (si disponible)
  final StackTrace? stackTrace;

  const AppException({
    required this.code,
    required this.message,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() => '[$code] $message';
}
