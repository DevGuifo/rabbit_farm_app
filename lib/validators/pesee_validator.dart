import 'validation_result.dart';

/// ❌ RÈGLES BLOQUANTES pour les pesées
class PeseeValidator {
  /// **W1 : Poids > 0**
  ///
  /// Gravité : 🔴 CRITIQUE
  static ValidationResult validatePoids(double poids) {
    if (poids <= 0) {
      return const ValidationResult.error(
        '❌ Le poids doit être supérieur à 0 kg.\n'
        'Veuillez entrer un poids valide.',
      );
    }

    // Avertissement si poids extrême (> 10 kg)
    if (poids > 10) {
      return ValidationResult.warning(
        '⚠️ Le poids saisi (${poids.toStringAsFixed(2)} kg) est très élevé.\n'
        'Vérifiez que vous n\'avez pas fait d\'erreur de saisie.\n'
        'Voulez-vous continuer ?',
      );
    }

    return const ValidationResult.success();
  }

  /// **W2 : Variation de poids réaliste (±30% max vs dernière pesée)**
  ///
  /// Gravité : 🟠 HAUTE (avertissement)
  static ValidationResult validateVariationPoids({
    required double poidsActuel,
    required double poidsPrecedent,
    double seuilVariationPourcent = 30.0,
  }) {
    final variation = ((poidsActuel - poidsPrecedent) / poidsPrecedent) * 100;
    final variationAbs = variation.abs();

    if (variationAbs > seuilVariationPourcent) {
      final signe = variation > 0 ? '+' : '';
      return ValidationResult.warning(
        '⚠️ Variation de poids importante : $signe${variation.toStringAsFixed(1)}%.\n'
        'Poids précédent : ${poidsPrecedent.toStringAsFixed(2)} kg\n'
        'Poids actuel : ${poidsActuel.toStringAsFixed(2)} kg\n'
        'Vérifiez votre saisie. Voulez-vous continuer ?',
      );
    }

    return const ValidationResult.success();
  }

  /// **W3 : Date pesée ≤ date actuelle**
  ///
  /// Gravité : 🟠 HAUTE
  static ValidationResult validateDatePesee(DateTime datePesee) {
    final maintenant = DateTime.now();
    final dateMaxAutorisee = maintenant.add(const Duration(days: 1));

    if (datePesee.isAfter(dateMaxAutorisee)) {
      return const ValidationResult.error(
        '❌ La date de pesée ne peut pas être dans le futur.\n'
        'Veuillez sélectionner une date passée.',
      );
    }

    return const ValidationResult.success();
  }

  /// **W4 : Poids cohérent avec l'âge (50g min à naissance)**
  ///
  /// Gravité : 🟡 MOYENNE (avertissement)
  static ValidationResult validatePoidsSelonAge({
    required double poids,
    required int ageEnJours,
  }) {
    // Nouveau-né (0-7 jours) : 40-80g
    if (ageEnJours <= 7) {
      if (poids < 0.040) {
        return ValidationResult.warning(
          '⚠️ Poids très faible pour un nouveau-né : ${(poids * 1000).toStringAsFixed(0)}g.\n'
          'Poids normal : 40-80g.\n'
          'Vérifiez votre saisie. Voulez-vous continuer ?',
        );
      }
      if (poids > 0.150) {
        return ValidationResult.warning(
          '⚠️ Poids très élevé pour un nouveau-né : ${(poids * 1000).toStringAsFixed(0)}g.\n'
          'Poids normal : 40-80g.\n'
          'Vérifiez votre saisie. Voulez-vous continuer ?',
        );
      }
    }

    // Sevrage (35-42 jours) : 400-800g
    if (ageEnJours >= 35 && ageEnJours <= 42) {
      if (poids < 0.300) {
        return ValidationResult.warning(
          '⚠️ Poids faible au sevrage : ${(poids * 1000).toStringAsFixed(0)}g.\n'
          'Poids normal : 400-800g.\n'
          'Surveillez l\'évolution.',
        );
      }
    }

    return const ValidationResult.success();
  }

  /// **Validation complète d'une pesée**
  static List<ValidationResult> validatePesee({
    required double poids,
    required DateTime datePesee,
    required int ageEnJours,
    double? poidsPrecedent,
  }) {
    final results = <ValidationResult>[];

    // Validation poids
    results.add(validatePoids(poids));

    // Validation date
    results.add(validateDatePesee(datePesee));

    // Validation variation (si pesée précédente)
    if (poidsPrecedent != null) {
      results.add(
        validateVariationPoids(
          poidsActuel: poids,
          poidsPrecedent: poidsPrecedent,
        ),
      );
    }

    // Validation cohérence âge (avertissement)
    results.add(validatePoidsSelonAge(poids: poids, ageEnJours: ageEnJours));

    return results;
  }
}
