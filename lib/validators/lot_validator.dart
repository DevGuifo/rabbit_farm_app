import '../services/database_helper.dart';
import 'validation_result.dart';

/// Validator pour les règles métier sur les Lots
///
/// Règles implémentées :
/// - LT1 : Un lot ne peut pas être supprimé s'il contient des lapins
/// - LT2 : Un lot ne peut pas avoir un effectif négatif
/// - LT3 : L'identifiant doit être au format LP-YYYY-MM-XXX
class LotValidator {
  final DatabaseHelper _db;

  LotValidator() : _db = DatabaseHelper.instance;

  /// Constructeur pour les tests avec injection de dépendance
  LotValidator.withDatabase(this._db);

  /// LT1 : Vérifier qu'un lot peut être supprimé
  ///
  /// Un lot ne peut pas être supprimé s'il contient des lapins (lot_id référencé).
  /// Retourne une erreur si des lapins sont associés, sinon succès.
  Future<ValidationResult> validateSuppression(int lotId) async {
    try {
      final nombreLapins = await _db.countIndividusByLotId(lotId);

      if (nombreLapins > 0) {
        return ValidationResult.error(
          'Impossible de supprimer ce lot : $nombreLapins lapin(s) y sont encore associés. '
          'Veuillez d\'abord retirer ou réassigner ces lapins.',
        );
      }

      return const ValidationResult.success();
    } catch (e) {
      return ValidationResult.error(
        'Erreur lors de la vérification : ${e.toString()}',
      );
    }
  }

  /// LT2 : Vérifier que l'effectif est valide
  ///
  /// L'effectif ne peut pas être négatif.
  ValidationResult validateEffectif(int effectif) {
    if (effectif < 0) {
      return const ValidationResult.error(
        'L\'effectif ne peut pas être négatif.',
      );
    }
    return const ValidationResult.success();
  }

  /// LT3 : Vérifier le format de l'identifiant
  ///
  /// Format attendu : LP-YYYY-MM-XXX (ex: LP-2026-01-001)
  ValidationResult validateIdentifiant(String identifiant) {
    final regex = RegExp(r'^LP-\d{4}-\d{2}-\d{3}$');

    if (!regex.hasMatch(identifiant)) {
      return ValidationResult.error(
        'L\'identifiant doit être au format LP-YYYY-MM-XXX (ex: LP-2026-01-001). '
        'Reçu : $identifiant',
      );
    }

    return const ValidationResult.success();
  }

  /// Vérifier qu'un lot existe avant assignation
  Future<ValidationResult> validateLotExiste(int lotId) async {
    try {
      final lot = await _db.getLotById(lotId);

      if (lot == null) {
        return ValidationResult.error('Le lot #$lotId n\'existe pas.');
      }

      return const ValidationResult.success();
    } catch (e) {
      return ValidationResult.error(
        'Erreur lors de la vérification du lot : ${e.toString()}',
      );
    }
  }

  /// Vérifier si un lapin peut être retiré d'un lot
  ///
  /// Avertissement si c'est le dernier lapin du lot.
  Future<ValidationResult> validateRetraitLapin(int lotId) async {
    try {
      final nombreLapins = await _db.countIndividusByLotId(lotId);

      if (nombreLapins == 1) {
        return const ValidationResult.warning(
          'Ce lapin est le dernier du lot. Le lot restera vide après cette action.',
        );
      }

      return const ValidationResult.success();
    } catch (e) {
      return const ValidationResult.success(); // Fail silently, not critical
    }
  }
}
