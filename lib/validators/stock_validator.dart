import 'validation_result.dart';

/// ❌ RÈGLES BLOQUANTES pour les stocks
class StockValidator {
  /// **ST1 : Quantité ≥ 0 (pas de stock négatif)**
  ///
  /// Gravité : 🔴 CRITIQUE
  static ValidationResult validateQuantitePositive(double quantite) {
    if (quantite < 0) {
      return const ValidationResult.error(
        '❌ La quantité ne peut pas être négative.\n'
        'Veuillez entrer une quantité valide.',
      );
    }

    return const ValidationResult.success();
  }

  /// **ST2 : Sortie stock ≤ stock existant**
  ///
  /// Gravité : 🔴 CRITIQUE
  static ValidationResult validateSortieStock({
    required double stockActuel,
    required double quantiteSortie,
    required String nomArticle,
    required String unite,
  }) {
    if (quantiteSortie > stockActuel) {
      return ValidationResult.error(
        '❌ Stock insuffisant : "$nomArticle".\n'
        'Stock disponible : $stockActuel $unite\n'
        'Quantité demandée : $quantiteSortie $unite',
      );
    }

    // Avertissement si proche de la rupture
    final stockRestant = stockActuel - quantiteSortie;
    if (stockRestant <= 0) {
      return ValidationResult.warning(
        '⚠️ Cette opération épuisera le stock de "$nomArticle".\n'
        'Pensez à réapprovisionner.',
      );
    }

    return const ValidationResult.success();
  }

  /// **ST3 : Prix unitaire > 0**
  ///
  /// Gravité : 🟡 MOYENNE
  static ValidationResult validatePrixUnitaire(double? prixUnitaire) {
    if (prixUnitaire == null) {
      return const ValidationResult.success(); // Prix optionnel
    }

    if (prixUnitaire <= 0) {
      return const ValidationResult.error(
        '❌ Le prix unitaire doit être supérieur à 0.\n'
        'Veuillez entrer un prix valide.',
      );
    }

    return const ValidationResult.success();
  }

  /// **Validation complète pour un médicament**
  static List<ValidationResult> validateMedicament({
    required double quantiteStock,
    required double? prixUnitaire,
  }) {
    final results = <ValidationResult>[];

    // Validation quantité
    results.add(validateQuantitePositive(quantiteStock));

    // Validation prix
    results.add(validatePrixUnitaire(prixUnitaire));

    return results;
  }

  /// **Validation complète pour un aliment**
  static List<ValidationResult> validateAliment({
    required double quantiteStock,
    required double? prixUnitaire,
  }) {
    final results = <ValidationResult>[];

    // Validation quantité
    results.add(validateQuantitePositive(quantiteStock));

    // Validation prix
    results.add(validatePrixUnitaire(prixUnitaire));

    return results;
  }
}
