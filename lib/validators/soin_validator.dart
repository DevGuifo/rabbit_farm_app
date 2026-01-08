import 'validation_result.dart';
import '../models/medicament.dart';
import '../models/lapin.dart';

/// ❌ RÈGLES BLOQUANTES pour les soins et médicaments
class SoinValidator {
  /// **S1 : Stock disponible > 0 avant utilisation**
  ///
  /// Gravité : 🔴 CRITIQUE
  static ValidationResult validateStockDisponible({
    required Medicament medicament,
    required double quantiteUtilisee,
  }) {
    if (medicament.quantiteStock <= 0) {
      return ValidationResult.error(
        '❌ Stock épuisé : "${medicament.nom}".\n'
        'Veuillez réapprovisionner avant d\'administrer ce médicament.',
      );
    }

    if (quantiteUtilisee > medicament.quantiteStock) {
      return ValidationResult.error(
        '❌ Stock insuffisant : "${medicament.nom}".\n'
        'Stock disponible : ${medicament.quantiteStock} ${medicament.unite}\n'
        'Quantité demandée : $quantiteUtilisee ${medicament.unite}',
      );
    }

    return const ValidationResult.success();
  }

  /// **S2 : Dose > 0**
  ///
  /// Gravité : 🟠 HAUTE
  static ValidationResult validateDose(double dose) {
    if (dose <= 0) {
      return const ValidationResult.error(
        '❌ La dose doit être supérieure à 0.\n'
        'Veuillez entrer une dose valide.',
      );
    }

    return const ValidationResult.success();
  }

  /// **S3 : Lapin vivant uniquement**
  ///
  /// Gravité : 🔴 CRITIQUE
  static ValidationResult validateLapinVivant(Lapin lapin) {
    final statut = lapin.statut?.toLowerCase();

    if (statut == 'décédé' || statut == 'decede' || statut == 'mort') {
      return ValidationResult.error(
        '❌ Impossible d\'administrer un soin.\n'
        'Le lapin "${lapin.nom}" est décédé.',
      );
    }

    return const ValidationResult.success();
  }

  /// **S4 : Médicament non périmé**
  ///
  /// Gravité : 🟠 HAUTE (avertissement)
  static ValidationResult validateMedicamentNonPerime(Medicament medicament) {
    if (medicament.estPerime) {
      return ValidationResult.warning(
        '⚠️ Médicament périmé : "${medicament.nom}".\n'
        'Date d\'expiration : ${medicament.dateExpiration?.toString().split(' ')[0]}\n'
        'Il est recommandé de ne pas l\'utiliser.\n'
        'Voulez-vous continuer ?',
      );
    }

    if (medicament.expireSoon) {
      return ValidationResult.warning(
        '⚠️ Médicament proche de la péremption : "${medicament.nom}".\n'
        'Date d\'expiration : ${medicament.dateExpiration?.toString().split(' ')[0]}\n'
        'Utilisez-le rapidement.',
      );
    }

    return const ValidationResult.success();
  }

  /// **S5 : Respect délai entre deux injections (14 jours)**
  ///
  /// Gravité : 🟡 MOYENNE (avertissement)
  static ValidationResult validateDelaiEntreInjections({
    required DateTime dateDernierSoin,
    required DateTime dateNouveauSoin,
    int delaiMinimumJours = 14,
  }) {
    final delai = dateNouveauSoin.difference(dateDernierSoin).inDays;

    if (delai < delaiMinimumJours) {
      return ValidationResult.warning(
        '⚠️ Délai court entre deux soins : $delai jours.\n'
        'Délai recommandé : $delaiMinimumJours jours minimum.\n'
        'Vérifiez le protocole. Voulez-vous continuer ?',
      );
    }

    return const ValidationResult.success();
  }

  /// **Validation complète d'un soin**
  static List<ValidationResult> validateSoin({
    required Lapin lapin,
    required Medicament? medicament,
    required double? dose,
    DateTime? dateDernierSoin,
    required DateTime dateNouveauSoin,
  }) {
    final results = <ValidationResult>[];

    // Validation lapin vivant
    results.add(validateLapinVivant(lapin));

    // Validation médicament (si utilisé)
    if (medicament != null && dose != null) {
      // Validation stock
      results.add(
        validateStockDisponible(medicament: medicament, quantiteUtilisee: dose),
      );

      // Validation dose
      results.add(validateDose(dose));

      // Validation péremption (avertissement)
      results.add(validateMedicamentNonPerime(medicament));
    }

    // Validation délai entre injections (si soin précédent)
    if (dateDernierSoin != null) {
      results.add(
        validateDelaiEntreInjections(
          dateDernierSoin: dateDernierSoin,
          dateNouveauSoin: dateNouveauSoin,
        ),
      );
    }

    return results;
  }
}
