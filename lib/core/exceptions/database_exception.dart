import 'app_exception.dart';

/// Exception levée lors d'erreurs de base de données (SQLite/Supabase)
class DatabaseException extends AppException {
  /// Type d'opération qui a échoué
  final String operation;

  const DatabaseException({
    required this.operation,
    required super.message,
    super.details,
    super.stackTrace,
  }) : super(
          code: 'DATABASE_ERROR',
        );

  /// Créer une DatabaseException pour une erreur de connexion
  factory DatabaseException.connectionError([dynamic details]) {
    return DatabaseException(
      operation: 'connect',
      message: 'Impossible de se connecter à la base de données',
      details: details,
    );
  }

  /// Créer une DatabaseException pour une erreur de requête
  factory DatabaseException.queryError(String operation, [dynamic details]) {
    return DatabaseException(
      operation: operation,
      message: 'Erreur lors de l\'exécution de la requête',
      details: details,
    );
  }

  /// Créer une DatabaseException pour une erreur d'insertion
  factory DatabaseException.insertError([dynamic details]) {
    return DatabaseException(
      operation: 'insert',
      message: 'Impossible d\'enregistrer les données',
      details: details,
    );
  }

  /// Créer une DatabaseException pour une erreur de mise à jour
  factory DatabaseException.updateError([dynamic details]) {
    return DatabaseException(
      operation: 'update',
      message: 'Impossible de modifier les données',
      details: details,
    );
  }

  /// Créer une DatabaseException pour une erreur de suppression
  factory DatabaseException.deleteError([dynamic details]) {
    return DatabaseException(
      operation: 'delete',
      message: 'Impossible de supprimer les données',
      details: details,
    );
  }
}
