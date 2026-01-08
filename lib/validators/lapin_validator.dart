import 'validation_result.dart';
import '../models/lapin.dart';

/// ❌ RÈGLES BLOQUANTES pour les lapins
///
/// Ces validations empêchent la création/modification de données incohérentes
class LapinValidator {
  /// **L1-L2 : Un lapin ne peut pas être son propre père ou sa propre mère**
  ///
  /// Gravité : 🔴 CRITIQUE
  ///
  /// Exemple :
  /// ```dart
  /// final result = LapinValidator.validateParents(
  ///   lapinId: 42,
  ///   pereId: 42, // ❌ Erreur !
  ///   mereId: 10,
  /// );
  /// ```
  static ValidationResult validateParents({
    required int? lapinId,
    required int? pereId,
    required int? mereId,
  }) {
    // Pas de validation si aucun parent sélectionné
    if (pereId == null && mereId == null) {
      return const ValidationResult.success();
    }

    // L1 : Lapin = père
    if (lapinId != null && pereId == lapinId) {
      return const ValidationResult.error(
        '❌ Un lapin ne peut pas être son propre père.\n'
        'Veuillez sélectionner un autre mâle.',
      );
    }

    // L2 : Lapin = mère
    if (lapinId != null && mereId == lapinId) {
      return const ValidationResult.error(
        '❌ Un lapin ne peut pas être sa propre mère.\n'
        'Veuillez sélectionner une autre femelle.',
      );
    }

    // L3 : Père = Mère
    if (pereId != null && mereId != null && pereId == mereId) {
      return const ValidationResult.error(
        '❌ Le père et la mère doivent être différents.\n'
        'Veuillez sélectionner deux lapins distincts.',
      );
    }

    return const ValidationResult.success();
  }

  /// **L4-L5 : Sexe du père = Mâle, Sexe de la mère = Femelle**
  ///
  /// Gravité : 🔴 CRITIQUE
  ///
  /// Exemple :
  /// ```dart
  /// final result = LapinValidator.validateParentsSexe(
  ///   pere: lapinMale,
  ///   mere: lapinFemelle,
  /// );
  /// ```
  static ValidationResult validateParentsSexe({
    required Lapin? pere,
    required Lapin? mere,
  }) {
    // L4 : Père doit être mâle
    if (pere != null) {
      final sexePere = pere.sexe.toLowerCase();
      if (sexePere != 'mâle' && sexePere != 'male' && sexePere != 'm') {
        return ValidationResult.error(
          '❌ Le père doit être un mâle.\n'
          'Le lapin "${pere.nom}" est de sexe "${pere.sexe}".',
        );
      }
    }

    // L5 : Mère doit être femelle
    if (mere != null) {
      final sexeMere = mere.sexe.toLowerCase();
      if (sexeMere != 'femelle' && sexeMere != 'f') {
        return ValidationResult.error(
          '❌ La mère doit être une femelle.\n'
          'Le lapin "${mere.nom}" est de sexe "${mere.sexe}".',
        );
      }
    }

    return const ValidationResult.success();
  }

  /// **L6 : Date de naissance ≤ date actuelle**
  ///
  /// Gravité : 🔴 CRITIQUE
  static ValidationResult validateDateNaissance(DateTime dateNaissance) {
    final maintenant = DateTime.now();

    // Autoriser une tolérance de 1 jour pour décalages horaires
    final dateMaxAutorisee = maintenant.add(const Duration(days: 1));

    if (dateNaissance.isAfter(dateMaxAutorisee)) {
      return const ValidationResult.error(
        '❌ La date de naissance ne peut pas être dans le futur.\n'
        'Veuillez sélectionner une date passée.',
      );
    }

    return const ValidationResult.success();
  }

  /// **L7 : Date de décès ≥ date de naissance**
  ///
  /// Gravité : 🟠 HAUTE
  static ValidationResult validateDateDeces({
    required DateTime dateNaissance,
    required DateTime dateDeces,
  }) {
    if (dateDeces.isBefore(dateNaissance)) {
      return const ValidationResult.error(
        '❌ La date de décès ne peut pas être avant la date de naissance.\n'
        'Veuillez corriger les dates.',
      );
    }

    return const ValidationResult.success();
  }

  /// **L8 : Poids > 0**
  ///
  /// Gravité : 🔴 CRITIQUE
  static ValidationResult validatePoids(double? poids) {
    if (poids == null) {
      return const ValidationResult.success(); // Poids optionnel
    }

    if (poids <= 0) {
      return const ValidationResult.error(
        '❌ Le poids doit être supérieur à 0 kg.\n'
        'Veuillez entrer un poids valide.',
      );
    }

    // Avertissement si poids extrême (> 10 kg pour un lapin)
    if (poids > 10) {
      return ValidationResult.warning(
        '⚠️ Le poids saisi (${poids.toStringAsFixed(2)} kg) est très élevé.\n'
        'Vérifiez que vous n\'avez pas fait d\'erreur de saisie.',
      );
    }

    return const ValidationResult.success();
  }

  /// **L9 : Nom unique par cage**
  ///
  /// Gravité : 🟡 MOYENNE
  static ValidationResult validateNomUniqueDansCage({
    required String nom,
    required int? cageId,
    required List<Lapin> lapinsDansCage,
    int? lapinIdExistant, // Pour l'édition
  }) {
    if (cageId == null) {
      return const ValidationResult.success(); // Pas de cage = pas de contrainte
    }

    // Chercher un lapin avec le même nom dans la cage
    final doublonTrouve = lapinsDansCage.any((l) {
      // Ignorer le lapin actuel lors de l'édition
      if (lapinIdExistant != null && l.id == lapinIdExistant) {
        return false;
      }
      return l.nom.toLowerCase() == nom.toLowerCase() && l.cageId == cageId;
    });

    if (doublonTrouve) {
      return ValidationResult.warning(
        '⚠️ Un lapin nommé "$nom" existe déjà dans cette cage.\n'
        'Cela peut prêter à confusion. Voulez-vous continuer ?',
      );
    }

    return const ValidationResult.success();
  }

  /// **Validation complète d'un lapin**
  ///
  /// Exécute toutes les validations critiques en une seule fois
  static List<ValidationResult> validateLapin({
    required int? lapinId,
    required String nom,
    required DateTime dateNaissance,
    required double? poids,
    required int? pereId,
    required int? mereId,
    required Lapin? pere,
    required Lapin? mere,
    int? cageId,
    List<Lapin>? lapinsDansCage,
  }) {
    final results = <ValidationResult>[];

    // Validation parents (IDs)
    results.add(
      validateParents(lapinId: lapinId, pereId: pereId, mereId: mereId),
    );

    // Validation parents (sexe)
    results.add(validateParentsSexe(pere: pere, mere: mere));

    // Validation date naissance
    results.add(validateDateNaissance(dateNaissance));

    // Validation poids
    results.add(validatePoids(poids));

    // Validation nom unique (si cage spécifiée)
    if (cageId != null && lapinsDansCage != null) {
      results.add(
        validateNomUniqueDansCage(
          nom: nom,
          cageId: cageId,
          lapinsDansCage: lapinsDansCage,
          lapinIdExistant: lapinId,
        ),
      );
    }

    return results;
  }

  /// **Vérifier si toutes les validations sont valides**
  static bool areAllValid(List<ValidationResult> results) {
    return results.every(
      (r) =>
          r.isValid && r.severity != ValidationSeverity.bloquante || r.isValid,
    );
  }

  /// **Obtenir le premier message d'erreur bloquant**
  static String? getFirstBlockingError(List<ValidationResult> results) {
    final blockingError = results.firstWhere(
      (r) => !r.isValid && r.severity == ValidationSeverity.bloquante,
      orElse: () => const ValidationResult.success(),
    );

    return blockingError.errorMessage;
  }
}
