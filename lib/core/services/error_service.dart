import '../exceptions/app_exception.dart';
import '../exceptions/database_exception.dart';
import '../exceptions/network_exception.dart';
import '../exceptions/permission_exception.dart';
import '../exceptions/validation_exception.dart';
import '../exceptions/not_found_exception.dart';
import '../utils/logger.dart';

/// Catégories d'erreurs pour affichage adapté
enum ErrorCategory {
  network,
  database,
  validation,
  permission,
  notFound,
  unknown,
}

/// Résultat de l'analyse d'une erreur
class ErrorInfo {
  final String userMessage;
  final String technicalMessage;
  final ErrorCategory category;
  final bool isRecoverable;
  final String? recoveryAction;

  const ErrorInfo({
    required this.userMessage,
    required this.technicalMessage,
    required this.category,
    this.isRecoverable = true,
    this.recoveryAction,
  });
}

/// Service centralisé de gestion des erreurs
///
/// Cette classe fournit :
/// - Logging automatique des erreurs
/// - Conversion des erreurs techniques en messages utilisateur
/// - Catégorisation des erreurs pour affichage adapté
class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  /// Traiter une erreur et retourner les informations pour l'UI
  ErrorInfo handleError(dynamic error, [StackTrace? stackTrace]) {
    // 1. Logger l'erreur technique
    _logError(error, stackTrace);

    // 2. Analyser et catégoriser l'erreur
    return _analyzeError(error);
  }

  /// Logger l'erreur avec les détails techniques
  void _logError(dynamic error, StackTrace? stackTrace) {
    if (error is AppException) {
      logger.error(
        '❌ [${error.code}] ${error.message}',
        error.details,
        error.stackTrace ?? stackTrace,
      );
    } else {
      logger.error(
        '❌ Erreur inattendue: ${error.runtimeType}',
        error,
        stackTrace,
      );
    }
  }

  /// Analyser l'erreur et générer les informations utilisateur
  ErrorInfo _analyzeError(dynamic error) {
    // Erreurs de base de données
    if (error is DatabaseException) {
      return ErrorInfo(
        userMessage: _getDatabaseUserMessage(error.operation),
        technicalMessage: error.message,
        category: ErrorCategory.database,
        isRecoverable: true,
        recoveryAction: 'Réessayez ou vérifiez l\'espace disponible',
      );
    }

    // Erreurs réseau
    if (error is NetworkException) {
      return ErrorInfo(
        userMessage: 'Problème de connexion. Vérifiez votre réseau.',
        technicalMessage: error.message,
        category: ErrorCategory.network,
        isRecoverable: true,
        recoveryAction: 'Vérifiez votre connexion internet et réessayez',
      );
    }

    // Erreurs de validation
    if (error is ValidationException) {
      return ErrorInfo(
        userMessage: error.message,
        technicalMessage: error.message,
        category: ErrorCategory.validation,
        isRecoverable: true,
        recoveryAction: 'Corrigez les informations saisies',
      );
    }

    // Erreurs de permission
    if (error is PermissionException) {
      return ErrorInfo(
        userMessage: 'Vous n\'avez pas les droits nécessaires.',
        technicalMessage: error.message,
        category: ErrorCategory.permission,
        isRecoverable: false,
      );
    }

    // Erreurs not found
    if (error is NotFoundException) {
      return ErrorInfo(
        userMessage: 'L\'élément demandé n\'existe pas ou a été supprimé.',
        technicalMessage: error.message,
        category: ErrorCategory.notFound,
        isRecoverable: false,
      );
    }

    // Autres AppException
    if (error is AppException) {
      return ErrorInfo(
        userMessage: error.message,
        technicalMessage: '${error.code}: ${error.details}',
        category: ErrorCategory.unknown,
        isRecoverable: true,
      );
    }

    // Erreurs standard Dart
    if (error is FormatException) {
      return ErrorInfo(
        userMessage: 'Données invalides. Vérifiez le format.',
        technicalMessage: error.message,
        category: ErrorCategory.validation,
        isRecoverable: true,
      );
    }

    if (error is StateError) {
      return ErrorInfo(
        userMessage: 'L\'opération n\'est pas possible dans cet état.',
        technicalMessage: error.message,
        category: ErrorCategory.unknown,
        isRecoverable: false,
      );
    }

    // Erreur inconnue
    return ErrorInfo(
      userMessage: 'Une erreur inattendue s\'est produite.',
      technicalMessage: error.toString(),
      category: ErrorCategory.unknown,
      isRecoverable: true,
      recoveryAction:
          'Fermez et relancez l\'application si le problème persiste',
    );
  }

  /// Obtenir un message utilisateur pour les erreurs de base de données
  String _getDatabaseUserMessage(String operation) {
    switch (operation) {
      case 'insert':
        return 'Impossible d\'enregistrer. Vérifiez les informations.';
      case 'update':
        return 'Impossible de modifier. Réessayez plus tard.';
      case 'delete':
        return 'Impossible de supprimer. L\'élément est peut-être utilisé ailleurs.';
      case 'connect':
        return 'Problème d\'accès aux données. Redémarrez l\'application.';
      default:
        return 'Erreur lors de l\'accès aux données.';
    }
  }

  /// Méthode utilitaire pour exécuter une action avec gestion d'erreur
  ///
  /// Exemple d'utilisation :
  /// ```dart
  /// final result = await errorService.tryExecute(
  ///   () => provider.ajouterLapin(lapin),
  ///   onError: (info) => showSnackBar(info.userMessage),
  /// );
  /// ```
  Future<T?> tryExecute<T>(
    Future<T> Function() action, {
    void Function(ErrorInfo)? onError,
    T? defaultValue,
  }) async {
    try {
      return await action();
    } catch (e, stack) {
      final errorInfo = handleError(e, stack);
      onError?.call(errorInfo);
      return defaultValue;
    }
  }
}

/// Instance globale du service d'erreur
final errorService = ErrorService();
