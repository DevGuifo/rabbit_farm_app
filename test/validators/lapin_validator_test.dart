import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/validators/lapin_validator.dart';
import 'package:rabbit_farm_app/validators/validation_result.dart';
import 'package:rabbit_farm_app/models/lapin.dart';

/// Tests unitaires pour LapinValidator
///
/// ✅ Couvre les règles critiques L1-L9
void main() {
  group('LapinValidator - Règles généalogiques', () {
    test('L1 : Un lapin ne peut pas être son propre père', () {
      final result = LapinValidator.validateParents(
        lapinId: 42,
        pereId: 42, // ❌ Même ID
        mereId: 10,
      );

      expect(result.isValid, false);
      expect(result.severity, ValidationSeverity.bloquante);
      expect(result.errorMessage, contains('propre père'));
    });

    test('L2 : Un lapin ne peut pas être sa propre mère', () {
      final result = LapinValidator.validateParents(
        lapinId: 42,
        pereId: 10,
        mereId: 42, // ❌ Même ID
      );

      expect(result.isValid, false);
      expect(result.severity, ValidationSeverity.bloquante);
      expect(result.errorMessage, contains('propre mère'));
    });

    test('L3 : Père et mère doivent être différents', () {
      final result = LapinValidator.validateParents(
        lapinId: 42,
        pereId: 10,
        mereId: 10, // ❌ Même ID
      );

      expect(result.isValid, false);
      expect(result.severity, ValidationSeverity.bloquante);
      expect(result.errorMessage, contains('différents'));
    });

    test('✅ Validation OK : parents distincts', () {
      final result = LapinValidator.validateParents(
        lapinId: 42,
        pereId: 10,
        mereId: 20,
      );

      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });

    test('✅ Validation OK : aucun parent sélectionné', () {
      final result = LapinValidator.validateParents(
        lapinId: 42,
        pereId: null,
        mereId: null,
      );

      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });
  });

  group('LapinValidator - Sexe des parents', () {
    test('L4 : Le père doit être mâle', () {
      final pereIncorrect = Lapin(
        id: 10,
        nom: 'Bella',
        race: 'Géant',
        sexe: 'Femelle', // ❌ Pas un mâle
        dateNaissance: DateTime(2023, 1, 1),
      );

      final result = LapinValidator.validateParentsSexe(
        pere: pereIncorrect,
        mere: null,
      );

      expect(result.isValid, false);
      expect(result.severity, ValidationSeverity.bloquante);
      expect(result.errorMessage, contains('doit être un mâle'));
    });

    test('L5 : La mère doit être femelle', () {
      final mereIncorrecte = Lapin(
        id: 20,
        nom: 'Max',
        race: 'Géant',
        sexe: 'Mâle', // ❌ Pas une femelle
        dateNaissance: DateTime(2023, 1, 1),
      );

      final result = LapinValidator.validateParentsSexe(
        pere: null,
        mere: mereIncorrecte,
      );

      expect(result.isValid, false);
      expect(result.severity, ValidationSeverity.bloquante);
      expect(result.errorMessage, contains('doit être une femelle'));
    });

    test('✅ Validation OK : père mâle, mère femelle', () {
      final pere = Lapin(
        id: 10,
        nom: 'Max',
        race: 'Géant',
        sexe: 'Mâle',
        dateNaissance: DateTime(2023, 1, 1),
      );

      final mere = Lapin(
        id: 20,
        nom: 'Bella',
        race: 'Géant',
        sexe: 'Femelle',
        dateNaissance: DateTime(2023, 1, 1),
      );

      final result = LapinValidator.validateParentsSexe(pere: pere, mere: mere);

      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });
  });

  group('LapinValidator - Date de naissance', () {
    test('L6 : Date de naissance ne peut pas être dans le futur', () {
      final dateFutur = DateTime.now().add(const Duration(days: 10));

      final result = LapinValidator.validateDateNaissance(dateFutur);

      expect(result.isValid, false);
      expect(result.severity, ValidationSeverity.bloquante);
      expect(result.errorMessage, contains('futur'));
    });

    test('✅ Validation OK : date passée', () {
      final datePasse = DateTime.now().subtract(const Duration(days: 30));

      final result = LapinValidator.validateDateNaissance(datePasse);

      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });

    test('✅ Validation OK : date actuelle', () {
      final dateAujourdhui = DateTime.now();

      final result = LapinValidator.validateDateNaissance(dateAujourdhui);

      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });
  });

  group('LapinValidator - Poids', () {
    test('L8 : Poids doit être > 0', () {
      final result = LapinValidator.validatePoids(0.0);

      expect(result.isValid, false);
      expect(result.severity, ValidationSeverity.bloquante);
      expect(result.errorMessage, contains('supérieur à 0'));
    });

    test('L8 : Poids négatif interdit', () {
      final result = LapinValidator.validatePoids(-1.5);

      expect(result.isValid, false);
      expect(result.severity, ValidationSeverity.bloquante);
      expect(result.errorMessage, contains('supérieur à 0'));
    });

    test('⚠️ Avertissement : poids extrême', () {
      final result = LapinValidator.validatePoids(15.0); // 15 kg !

      expect(result.isValid, true); // Pas bloquant
      expect(result.severity, ValidationSeverity.avertissement);
      expect(result.errorMessage, contains('très élevé'));
    });

    test('✅ Validation OK : poids normal', () {
      final result = LapinValidator.validatePoids(3.5);

      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });

    test('✅ Validation OK : poids null (optionnel)', () {
      final result = LapinValidator.validatePoids(null);

      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });
  });

  group('LapinValidator - Date de décès', () {
    test('L7 : Date de décès ne peut pas être avant la naissance', () {
      final dateNaissance = DateTime(2024, 1, 1);
      final dateDeces = DateTime(2023, 12, 1); // ❌ Avant la naissance

      final result = LapinValidator.validateDateDeces(
        dateNaissance: dateNaissance,
        dateDeces: dateDeces,
      );

      expect(result.isValid, false);
      expect(result.severity, ValidationSeverity.bloquante);
      expect(result.errorMessage, contains('avant la date de naissance'));
    });

    test('✅ Validation OK : date de décès après la naissance', () {
      final dateNaissance = DateTime(2024, 1, 1);
      final dateDeces = DateTime(2025, 1, 1);

      final result = LapinValidator.validateDateDeces(
        dateNaissance: dateNaissance,
        dateDeces: dateDeces,
      );

      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });
  });

  group('LapinValidator - Validation complète', () {
    test('❌ Échec si au moins une règle bloquante échoue', () {
      final pere = Lapin(
        id: 10,
        nom: 'Max',
        race: 'Géant',
        sexe: 'Femelle', // ❌ Erreur !
        dateNaissance: DateTime(2023, 1, 1),
      );

      final results = LapinValidator.validateLapin(
        lapinId: null,
        nom: 'Bébé',
        dateNaissance: DateTime.now(),
        poids: 2.0,
        pereId: 10,
        mereId: null,
        pere: pere,
        mere: null,
      );

      final hasError = results.any(
        (r) => !r.isValid && r.severity == ValidationSeverity.bloquante,
      );

      expect(hasError, true);
    });

    test('✅ Succès si toutes les règles passent', () {
      final pere = Lapin(
        id: 10,
        nom: 'Max',
        race: 'Géant',
        sexe: 'Mâle',
        dateNaissance: DateTime(2023, 1, 1),
      );

      final mere = Lapin(
        id: 20,
        nom: 'Bella',
        race: 'Géant',
        sexe: 'Femelle',
        dateNaissance: DateTime(2023, 1, 1),
      );

      final results = LapinValidator.validateLapin(
        lapinId: null,
        nom: 'Bébé',
        dateNaissance: DateTime.now(),
        poids: 2.0,
        pereId: 10,
        mereId: 20,
        pere: pere,
        mere: mere,
      );

      final hasError = results.any(
        (r) => !r.isValid && r.severity == ValidationSeverity.bloquante,
      );

      expect(hasError, false);
    });
  });
}
