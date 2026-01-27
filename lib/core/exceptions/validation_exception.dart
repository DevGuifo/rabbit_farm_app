import 'app_exception.dart';

/// Exception levée lors d'erreurs de validation métier
class ValidationException extends AppException {
  /// Champ qui a échoué la validation (optionnel)
  final String? field;

  /// Raison de l'échec de validation
  final String reason;

  const ValidationException({
    required this.reason,
    this.field,
    super.details,
    super.stackTrace,
  }) : super(
          code: 'VALIDATION_ERROR',
          message: field != null
              ? 'Erreur de validation pour le champ "$field": $reason'
              : 'Erreur de validation: $reason',
        );

  /// Créer une ValidationException pour un champ obligatoire manquant
  factory ValidationException.requiredField(String fieldName) {
    return ValidationException(
      field: fieldName,
      reason: 'Ce champ est obligatoire',
    );
  }

  /// Créer une ValidationException pour un format invalide
  factory ValidationException.invalidFormat(String fieldName, String expectedFormat) {
    return ValidationException(
      field: fieldName,
      reason: 'Format invalide. Format attendu: $expectedFormat',
    );
  }
}
