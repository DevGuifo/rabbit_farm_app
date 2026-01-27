import 'validation_result.dart';
import '../models/lapin.dart';
import '../models/accouplement.dart';
import '../models/enums/sexe.dart';
import '../models/enums/statut_accouplement.dart';

/// ❌ RÈGLES BLOQUANTES pour les accouplements
class AccouplementValidator {
  /// **R1-R2 : Accouplement Mâle/Femelle uniquement, Mâle ≠ Femelle**
  ///
  /// Gravité : 🔴 CRITIQUE
  static ValidationResult validateMaleFemelle({
    required Lapin male,
    required Lapin femelle,
  }) {
    // R2 : Même lapin pour les deux
    if (male.id == femelle.id) {
      return const ValidationResult.error(
        '❌ Un lapin ne peut pas s\'accoupler avec lui-même.\n'
        'Veuillez sélectionner deux lapins différents.',
      );
    }

    // R1 : Mâle doit être mâle
    if (male.sexe != Sexe.male) {
      return ValidationResult.error(
        '❌ Le lapin "${male.nom}" n\'est pas un mâle.\n'
        'Sexe actuel : "${male.sexe.label}". Veuillez sélectionner un mâle.',
      );
    }

    // R1 : Femelle doit être femelle
    if (femelle.sexe != Sexe.femelle) {
      return ValidationResult.error(
        '❌ Le lapin "${femelle.nom}" n\'est pas une femelle.\n'
        'Sexe actuel : "${femelle.sexe.label}". Veuillez sélectionner une femelle.',
      );
    }

    return const ValidationResult.success();
  }

  /// **R3 : Femelle non gestante au moment de l'accouplement**
  ///
  /// Gravité : 🔴 CRITIQUE
  static ValidationResult validateFemelleNonGestante({
    required Lapin femelle,
    required List<Accouplement> accouplements,
  }) {
    final estGestante = femelle.estGestante(accouplements);

    if (estGestante) {
      return ValidationResult.error(
        '❌ La femelle "${femelle.nom}" est déjà gestante.\n'
        'Impossible de planifier un nouvel accouplement.',
      );
    }

    return const ValidationResult.success();
  }

  /// **R4 : Âge minimum reproducteur (5 mois)**
  ///
  /// Gravité : 🟠 HAUTE (avertissement)
  static ValidationResult validateAgeMinimum({
    required Lapin male,
    required Lapin femelle,
    int ageMinimumMois = 5,
  }) {
    // Vérifier le mâle
    if (male.ageEnMois < ageMinimumMois) {
      return ValidationResult.warning(
        '⚠️ Le mâle "${male.nom}" a ${male.ageEnMois} mois.\n'
        'Âge recommandé : $ageMinimumMois mois minimum.\n'
        'Voulez-vous continuer ?',
      );
    }

    // Vérifier la femelle
    if (femelle.ageEnMois < ageMinimumMois) {
      return ValidationResult.warning(
        '⚠️ La femelle "${femelle.nom}" a ${femelle.ageEnMois} mois.\n'
        'Âge recommandé : $ageMinimumMois mois minimum.\n'
        'Voulez-vous continuer ?',
      );
    }

    return const ValidationResult.success();
  }

  /// **R5 : Pas d'accouplement consanguin direct (père/fille, mère/fils)**
  ///
  /// Gravité : 🟠 HAUTE (avertissement)
  static ValidationResult validateConsanguinite({
    required Lapin male,
    required Lapin femelle,
    required Map<String, int?> parentsMale, // {pere: id, mere: id}
    required Map<String, int?> parentsFemelle,
  }) {
    // Père/fille : le mâle est le père de la femelle
    if (parentsFemelle['pere'] == male.id) {
      return ValidationResult.warning(
        '⚠️ Accouplement consanguin détecté :\n'
        'Le mâle "${male.nom}" est le père de la femelle "${femelle.nom}".\n'
        'Cela peut réduire la qualité génétique.\n'
        'Voulez-vous continuer ?',
      );
    }

    // Mère/fils : la femelle est la mère du mâle
    if (parentsMale['mere'] == femelle.id) {
      return ValidationResult.warning(
        '⚠️ Accouplement consanguin détecté :\n'
        'La femelle "${femelle.nom}" est la mère du mâle "${male.nom}".\n'
        'Cela peut réduire la qualité génétique.\n'
        'Voulez-vous continuer ?',
      );
    }

    // Frère/sœur : même père OU même mère
    final memePere =
        parentsMale['pere'] != null &&
        parentsFemelle['pere'] != null &&
        parentsMale['pere'] == parentsFemelle['pere'];

    final memeMere =
        parentsMale['mere'] != null &&
        parentsFemelle['mere'] != null &&
        parentsMale['mere'] == parentsFemelle['mere'];

    if (memePere || memeMere) {
      return ValidationResult.warning(
        '⚠️ Accouplement consanguin détecté :\n'
        'Le mâle "${male.nom}" et la femelle "${femelle.nom}" sont frère/sœur.\n'
        'Cela peut réduire la qualité génétique.\n'
        'Voulez-vous continuer ?',
      );
    }

    return const ValidationResult.success();
  }

  /// **R6 : Date d'accouplement ≤ date actuelle**
  ///
  /// Gravité : 🟠 HAUTE
  static ValidationResult validateDateAccouplement(DateTime dateAccouplement) {
    final maintenant = DateTime.now();
    final dateMaxAutorisee = maintenant.add(const Duration(days: 1));

    if (dateAccouplement.isAfter(dateMaxAutorisee)) {
      return const ValidationResult.error(
        '❌ La date d\'accouplement ne peut pas être dans le futur.\n'
        'Veuillez sélectionner une date passée.',
      );
    }

    return const ValidationResult.success();
  }

  /// **R7 : Limite de portées par an (5 max)**
  ///
  /// Gravité : 🟡 MOYENNE (avertissement)
  static ValidationResult validateLimitePorteesParAn({
    required Lapin femelle,
    required List<Accouplement> accouplements,
    int limiteParAn = 5,
  }) {
    final maintenant = DateTime.now();
    final debutAnnee = DateTime(maintenant.year, 1, 1);

    // Compter les accouplements de cette femelle cette année
    final accouplementsCetteAnnee = accouplements.where((a) {
      return a.femelleId == femelle.id &&
          a.dateAccouplement.isAfter(debutAnnee) &&
          a.statut != StatutAccouplement.echec;
    }).length;

    if (accouplementsCetteAnnee >= limiteParAn) {
      return ValidationResult.warning(
        '⚠️ La femelle "${femelle.nom}" a déjà $accouplementsCetteAnnee accouplements cette année.\n'
        'Limite recommandée : $limiteParAn portées/an.\n'
        'Voulez-vous continuer ?',
      );
    }

    return const ValidationResult.success();
  }

  /// **Validation complète d'un accouplement**
  static List<ValidationResult> validateAccouplement({
    required Lapin male,
    required Lapin femelle,
    required DateTime dateAccouplement,
    required List<Accouplement> accouplements,
    required Map<String, int?> parentsMale,
    required Map<String, int?> parentsFemelle,
  }) {
    final results = <ValidationResult>[];

    // Validation mâle/femelle
    results.add(validateMaleFemelle(male: male, femelle: femelle));

    // Validation femelle non gestante
    results.add(
      validateFemelleNonGestante(
        femelle: femelle,
        accouplements: accouplements,
      ),
    );

    // Validation âge minimum (avertissement)
    results.add(validateAgeMinimum(male: male, femelle: femelle));

    // Validation consanguinité (avertissement)
    results.add(
      validateConsanguinite(
        male: male,
        femelle: femelle,
        parentsMale: parentsMale,
        parentsFemelle: parentsFemelle,
      ),
    );

    // Validation date
    results.add(validateDateAccouplement(dateAccouplement));

    // Validation limite portées/an (avertissement)
    results.add(
      validateLimitePorteesParAn(
        femelle: femelle,
        accouplements: accouplements,
      ),
    );

    return results;
  }
}
