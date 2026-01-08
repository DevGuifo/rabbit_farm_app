/// Résultat d'une validation métier
///
/// Permet de retourner :
/// - isValid : true/false
/// - errorMessage : message pédagogique pour l'utilisateur
/// - severity : bloquante, avertissement, information
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final ValidationSeverity severity;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.severity = ValidationSeverity.bloquante,
  });

  /// Validation réussie
  const ValidationResult.success()
    : isValid = true,
      errorMessage = null,
      severity = ValidationSeverity.bloquante;

  /// Validation échouée avec message bloquant
  const ValidationResult.error(String message)
    : isValid = false,
      errorMessage = message,
      severity = ValidationSeverity.bloquante;

  /// Avertissement (nécessite confirmation utilisateur)
  const ValidationResult.warning(String message)
    : isValid = true,
      errorMessage = message,
      severity = ValidationSeverity.avertissement;

  /// Information (message simple)
  const ValidationResult.info(String message)
    : isValid = true,
      errorMessage = message,
      severity = ValidationSeverity.information;
}

/// Niveaux de sévérité des validations
enum ValidationSeverity {
  /// ❌ Bloquante : action interdite
  bloquante,

  /// ⚠️ Avertissement : confirmation utilisateur requise
  avertissement,

  /// ℹ️ Information : message simple
  information,
}
