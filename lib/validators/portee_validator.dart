import 'validation_result.dart';

/// ❌ RÈGLES BLOQUANTES pour les portées
class PorteeValidator {
  /// **P1 : Date de mise bas ≥ date d'accouplement**
  ///
  /// Gravité : 🔴 CRITIQUE
  static ValidationResult validateDateMiseBas({
    required DateTime dateMiseBas,
    required DateTime dateAccouplement,
  }) {
    if (dateMiseBas.isBefore(dateAccouplement)) {
      return const ValidationResult.error(
        '❌ La date de mise bas ne peut pas être avant la date d\'accouplement.\n'
        'Veuillez corriger les dates.',
      );
    }

    return const ValidationResult.success();
  }

  /// **P2 : Nombre de vivants ≤ nombre de nés**
  ///
  /// Gravité : 🔴 CRITIQUE
  static ValidationResult validateNombreVivants({
    required int nombreNes,
    required int nombreVivants,
  }) {
    if (nombreVivants > nombreNes) {
      return ValidationResult.error(
        '❌ Le nombre de vivants ($nombreVivants) ne peut pas dépasser le total ($nombreNes).\n'
        'Veuillez corriger les nombres.',
      );
    }

    return const ValidationResult.success();
  }

  /// **P4 : Nombre de nés > 0**
  ///
  /// Gravité : 🔴 CRITIQUE
  static ValidationResult validateNombreNes(int nombreNes) {
    if (nombreNes <= 0) {
      return const ValidationResult.error(
        '❌ Le nombre total de nés doit être supérieur à 0.\n'
        'Veuillez entrer un nombre valide.',
      );
    }

    return const ValidationResult.success();
  }

  /// **P5 : Délai réaliste mise bas (28-35 jours)**
  ///
  /// Gravité : 🟡 MOYENNE (avertissement)
  static ValidationResult validateDelaiMiseBas({
    required DateTime dateMiseBas,
    required DateTime dateAccouplement,
  }) {
    final delai = dateMiseBas.difference(dateAccouplement).inDays;

    if (delai < 28) {
      return ValidationResult.warning(
        '⚠️ Délai très court : $delai jours.\n'
        'Durée normale de gestation : 28-35 jours.\n'
        'Vérifiez les dates. Voulez-vous continuer ?',
      );
    }

    if (delai > 35) {
      return ValidationResult.warning(
        '⚠️ Délai très long : $delai jours.\n'
        'Durée normale de gestation : 28-35 jours.\n'
        'Vérifiez les dates. Voulez-vous continuer ?',
      );
    }

    return const ValidationResult.success();
  }

  /// **P6 : Nombre max de lapereaux (12 max)**
  ///
  /// Gravité : 🟡 MOYENNE (avertissement)
  static ValidationResult validateNombreMax({
    required int nombreNes,
    int nombreMax = 12,
  }) {
    if (nombreNes > nombreMax) {
      return ValidationResult.warning(
        '⚠️ Nombre élevé : $nombreNes lapereaux.\n'
        'Maximum courant : $nombreMax.\n'
        'Vérifiez votre saisie. Voulez-vous continuer ?',
      );
    }

    return const ValidationResult.success();
  }

  /// **Validation complète d'une portée**
  static List<ValidationResult> validatePortee({
    required DateTime dateMiseBas,
    required DateTime dateAccouplement,
    required int nombreNes,
    required int nombreVivants,
  }) {
    final results = <ValidationResult>[];

    // Validation date
    results.add(
      validateDateMiseBas(
        dateMiseBas: dateMiseBas,
        dateAccouplement: dateAccouplement,
      ),
    );

    // Validation nombre nés
    results.add(validateNombreNes(nombreNes));

    // Validation nombre vivants
    results.add(
      validateNombreVivants(nombreNes: nombreNes, nombreVivants: nombreVivants),
    );

    // Validation délai (avertissement)
    results.add(
      validateDelaiMiseBas(
        dateMiseBas: dateMiseBas,
        dateAccouplement: dateAccouplement,
      ),
    );

    // Validation nombre max (avertissement)
    results.add(validateNombreMax(nombreNes: nombreNes));

    return results;
  }
}
