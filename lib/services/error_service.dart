import 'package:flutter/material.dart';
import '../utils/logger.dart';
import '../utils/snackbar_helper.dart';
import '../utils/dialog_helper.dart';
import '../constants/error_messages.dart';

/// Types d'erreurs possibles dans l'application
enum ErrorType {
  database, // Erreurs de base de données
  network, // Erreurs réseau (pour future sync)
  validation, // Erreurs de validation
  file, // Erreurs de fichiers
  permission, // Erreurs de permissions
  unknown, // Erreurs inconnues
}

/// Service centralisé pour la gestion des erreurs
/// Standardise les messages utilisateur et le logging
class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  /// Gérer une erreur et afficher un message à l'utilisateur
  /// 
  /// [error] : L'exception ou l'erreur
  /// [context] : Le contexte Flutter (optionnel, pour afficher un message)
  /// [errorType] : Le type d'erreur (détecté automatiquement si non fourni)
  /// [userMessage] : Message personnalisé pour l'utilisateur (optionnel)
  /// [showToUser] : Si true, affiche un message à l'utilisateur
  /// [logError] : Si true, log l'erreur
  Future<void> handleError({
    required dynamic error,
    BuildContext? context,
    ErrorType? errorType,
    String? userMessage,
    bool showToUser = true,
    bool logError = true,
    StackTrace? stackTrace,
  }) async {
    // Déterminer le type d'erreur si non fourni
    final type = errorType ?? _detectErrorType(error);

    // Logger l'erreur
    if (logError) {
      _logError(error, type, stackTrace);
    }

    // Générer le message utilisateur
    final message = userMessage ?? _generateUserMessage(error, type);

    // Afficher à l'utilisateur si demandé et contexte disponible
    if (showToUser && context != null) {
      _showErrorToUser(context, message, type);
    }
  }

  /// Gérer une erreur silencieusement (seulement logging)
  void handleErrorSilently({
    required dynamic error,
    ErrorType? errorType,
    StackTrace? stackTrace,
  }) {
    handleError(
      error: error,
      errorType: errorType,
      showToUser: false,
      stackTrace: stackTrace,
    );
  }

  /// Détecter le type d'erreur à partir de l'exception
  ErrorType _detectErrorType(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('database') ||
        errorString.contains('sqlite') ||
        errorString.contains('sqflite')) {
      return ErrorType.database;
    }

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket')) {
      return ErrorType.network;
    }

    if (errorString.contains('validation') ||
        errorString.contains('invalid') ||
        errorString.contains('format')) {
      return ErrorType.validation;
    }

    if (errorString.contains('file') ||
        errorString.contains('permission') ||
        errorString.contains('access denied')) {
      return ErrorType.permission;
    }

    if (errorString.contains('file') ||
        errorString.contains('not found') ||
        errorString.contains('cannot read')) {
      return ErrorType.file;
    }

    return ErrorType.unknown;
  }

  /// Générer un message utilisateur clair à partir de l'erreur
  String _generateUserMessage(dynamic error, ErrorType type) {
    switch (type) {
      case ErrorType.database:
        return ErrorMessages.databaseError;

      case ErrorType.network:
        return ErrorMessages.networkError;

      case ErrorType.validation:
        if (error is String) {
          return error; // Utiliser le message d'erreur directement si c'est une string
        }
        return ErrorMessages.validationError;

      case ErrorType.file:
        return ErrorMessages.fileReadError;

      case ErrorType.permission:
        return ErrorMessages.permissionDenied;

      case ErrorType.unknown:
        if (error is String) {
          return error;
        }
        return ErrorMessages.genericError;
    }
  }

  /// Logger l'erreur avec les détails
  void _logError(dynamic error, ErrorType type, StackTrace? stackTrace) {
    final errorMessage = error.toString();
    final typeString = type.toString().split('.').last;

    if (stackTrace != null) {
      logger.error(
        '[$typeString] $errorMessage',
        error,
        stackTrace,
      );
    } else {
      logger.error('[$typeString] $errorMessage', error);
    }
  }

  /// Afficher l'erreur à l'utilisateur
  void _showErrorToUser(BuildContext context, String message, ErrorType type) {
    // Pour les erreurs de validation, utiliser un snackbar (moins intrusif)
    if (type == ErrorType.validation) {
      SnackbarHelper.showValidationError(context, message);
      return;
    }

    // Pour les autres erreurs, utiliser un snackbar d'erreur
    SnackbarHelper.showError(context, message);
  }

  /// Gérer une erreur avec un dialog (pour erreurs critiques)
  Future<void> handleErrorWithDialog({
    required BuildContext context,
    required dynamic error,
    ErrorType? errorType,
    String? title,
    String? userMessage,
    VoidCallback? onRetry,
    bool logError = true,
    StackTrace? stackTrace,
  }) async {
    final type = errorType ?? _detectErrorType(error);
    final message = userMessage ?? _generateUserMessage(error, type);
    final errorTitle = title ?? 'Erreur';

    if (logError) {
      _logError(error, type, stackTrace);
    }

    await DialogHelper.showError(
      context: context,
      title: errorTitle,
      message: message,
    );

    // Si une action de retry est fournie, on peut l'appeler après
    if (onRetry != null) {
      // L'utilisateur peut déclencher le retry manuellement
    }
  }

  /// Wrapper pour les opérations async avec gestion d'erreur automatique
  Future<T?> executeWithErrorHandling<T>({
    required Future<T> Function() operation,
    BuildContext? context,
    String? userMessage,
    T? defaultValue,
    bool showToUser = true,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      await handleError(
        error: e,
        context: context,
        userMessage: userMessage,
        showToUser: showToUser,
        stackTrace: stackTrace,
      );
      return defaultValue;
    }
  }

  /// Créer un message d'erreur formaté pour les logs
  String formatErrorForLog(dynamic error, ErrorType type) {
    final timestamp = DateTime.now().toIso8601String();
    final typeString = type.toString().split('.').last;
    return '[$timestamp] [$typeString] ${error.toString()}';
  }
}

