import 'validation_result.dart';
import '../models/cage.dart';
import '../models/lapin.dart';

/// ❌ RÈGLES BLOQUANTES pour la localisation
class LocalisationValidator {
  /// **LOC1 : Capacité cage respectée**
  ///
  /// Gravité : 🟠 HAUTE (avertissement)
  static ValidationResult validateCapaciteCage({
    required Cage cage,
    required int nombreOccupantsActuels,
    int nombreAjout = 1,
  }) {
    final capacite = cage.capacite;
    final nouveauTotal = nombreOccupantsActuels + nombreAjout;

    if (nouveauTotal > capacite) {
      return ValidationResult.warning(
        '⚠️ Capacité de la cage dépassée.\n'
        'Capacité : $capacite lapin(s)\n'
        'Occupants actuels : $nombreOccupantsActuels\n'
        'Après ajout : $nouveauTotal\n'
        'Voulez-vous continuer ?',
      );
    }

    // Information si proche de la capacité max
    if (nouveauTotal == capacite) {
      return ValidationResult.info(
        'ℹ️ La cage sera pleine après cet ajout ($nouveauTotal/$capacite).',
      );
    }

    return const ValidationResult.success();
  }

  /// **LOC2 : Pas 2 lapins même nom dans même cage**
  ///
  /// Gravité : 🟡 MOYENNE (avertissement)
  static ValidationResult validateNomUniqueDansCage({
    required String nomLapin,
    required List<Lapin> lapinsDansCage,
    int? lapinIdExistant, // Pour l'édition
  }) {
    // Chercher un lapin avec le même nom dans la cage
    final doublonTrouve = lapinsDansCage.any((l) {
      // Ignorer le lapin actuel lors de l'édition
      if (lapinIdExistant != null && l.id == lapinIdExistant) {
        return false;
      }
      return l.nom.toLowerCase() == nomLapin.toLowerCase();
    });

    if (doublonTrouve) {
      return ValidationResult.warning(
        '⚠️ Un lapin nommé "$nomLapin" existe déjà dans cette cage.\n'
        'Cela peut prêter à confusion. Voulez-vous continuer ?',
      );
    }

    return const ValidationResult.success();
  }

  /// **LOC3 : Sevrage vers cage disponible uniquement**
  ///
  /// Gravité : 🟠 HAUTE
  static ValidationResult validateCageDisponiblePourSevrage({
    required Cage cage,
    required int nombreOccupantsActuels,
    required int nombreLapereaux,
  }) {
    final capacite = cage.capacite;
    final nouveauTotal = nombreOccupantsActuels + nombreLapereaux;

    if (nouveauTotal > capacite) {
      return ValidationResult.error(
        '❌ Capacité insuffisante pour le sevrage.\n'
        'Capacité : $capacite lapin(s)\n'
        'Occupants actuels : $nombreOccupantsActuels\n'
        'Lapereaux à sevrer : $nombreLapereaux\n'
        'Veuillez choisir une autre cage.',
      );
    }

    return const ValidationResult.success();
  }

  /// **Validation complète pour l'ajout d'un lapin dans une cage**
  static List<ValidationResult> validateAjoutLapinDansCage({
    required Cage cage,
    required int nombreOccupantsActuels,
    required String nomLapin,
    required List<Lapin> lapinsDansCage,
    int? lapinIdExistant,
  }) {
    final results = <ValidationResult>[];

    // Validation capacité
    results.add(
      validateCapaciteCage(
        cage: cage,
        nombreOccupantsActuels: nombreOccupantsActuels,
      ),
    );

    // Validation nom unique
    results.add(
      validateNomUniqueDansCage(
        nomLapin: nomLapin,
        lapinsDansCage: lapinsDansCage,
        lapinIdExistant: lapinIdExistant,
      ),
    );

    return results;
  }
}
