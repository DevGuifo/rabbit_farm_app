import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/validators/accouplement_validator.dart';
import 'package:rabbit_farm_app/validators/validation_result.dart';
import 'package:rabbit_farm_app/models/lapin.dart';
import 'package:rabbit_farm_app/models/accouplement.dart';

/// Tests unitaires pour AccouplementValidator
///
/// ✅ Couvre les règles critiques R1-R7
void main() {
  group('AccouplementValidator - Mâle/Femelle', () {
    test('R1 : Accouplement mâle/femelle uniquement', () {
      final male1 = Lapin(
        id: 1,
        nom: 'Max',
        race: 'Géant',
        sexe: 'Mâle',
        dateNaissance: DateTime(2023, 1, 1),
      );

      final male2 = Lapin(
        id: 2,
        nom: 'Rocky',
        race: 'Géant',
        sexe: 'Mâle', // ❌ Deux mâles
        dateNaissance: DateTime(2023, 1, 1),
      );

      final result = AccouplementValidator.validateMaleFemelle(
        male: male1,
        femelle: male2,
      );

      expect(result.isValid, false);
      expect(result.severity, ValidationSeverity.bloquante);
    });

    test('R2 : Un lapin ne peut pas s\'accoupler avec lui-même', () {
      final lapin = Lapin(
        id: 1,
        nom: 'Max',
        race: 'Géant',
        sexe: 'Mâle',
        dateNaissance: DateTime(2023, 1, 1),
      );

      final result = AccouplementValidator.validateMaleFemelle(
        male: lapin,
        femelle: lapin, // ❌ Même lapin
      );

      expect(result.isValid, false);
      expect(result.severity, ValidationSeverity.bloquante);
      expect(result.errorMessage, contains('lui-même'));
    });

    test('✅ Validation OK : mâle et femelle distincts', () {
      final male = Lapin(
        id: 1,
        nom: 'Max',
        race: 'Géant',
        sexe: 'Mâle',
        dateNaissance: DateTime(2023, 1, 1),
      );

      final femelle = Lapin(
        id: 2,
        nom: 'Bella',
        race: 'Géant',
        sexe: 'Femelle',
        dateNaissance: DateTime(2023, 1, 1),
      );

      final result = AccouplementValidator.validateMaleFemelle(
        male: male,
        femelle: femelle,
      );

      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });
  });

  group('AccouplementValidator - Femelle gestante', () {
    test('R3 : Femelle non gestante au moment de l\'accouplement', () {
      final femelle = Lapin(
        id: 2,
        nom: 'Bella',
        race: 'Géant',
        sexe: 'Femelle',
        dateNaissance: DateTime(2023, 1, 1),
      );

      // Accouplement actif existant
      final accouplementsActifs = [
        Accouplement(
          id: 1,
          maleId: 1,
          femelleId: 2,
          dateAccouplement: DateTime.now().subtract(const Duration(days: 10)),
          dateMiseBasPrevue: DateTime.now().add(const Duration(days: 21)),
          statut: 'en_attente', // ❌ Femelle déjà gestante
        ),
      ];

      final result = AccouplementValidator.validateFemelleNonGestante(
        femelle: femelle,
        accouplements: accouplementsActifs,
      );

      expect(result.isValid, false);
      expect(result.severity, ValidationSeverity.bloquante);
      expect(result.errorMessage, contains('déjà gestante'));
    });

    test('✅ Validation OK : femelle non gestante', () {
      final femelle = Lapin(
        id: 2,
        nom: 'Bella',
        race: 'Géant',
        sexe: 'Femelle',
        dateNaissance: DateTime(2023, 1, 1),
      );

      final result = AccouplementValidator.validateFemelleNonGestante(
        femelle: femelle,
        accouplements: [], // Aucun accouplement actif
      );

      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });
  });

  group('AccouplementValidator - Âge minimum', () {
    test('R4 : Avertissement si âge < 5 mois', () {
      final jeuneMale = Lapin(
        id: 1,
        nom: 'Jeune Max',
        race: 'Géant',
        sexe: 'Mâle',
        dateNaissance: DateTime.now().subtract(
          const Duration(days: 90),
        ), // 3 mois
      );

      final femelle = Lapin(
        id: 2,
        nom: 'Bella',
        race: 'Géant',
        sexe: 'Femelle',
        dateNaissance: DateTime(2023, 1, 1),
      );

      final result = AccouplementValidator.validateAgeMinimum(
        male: jeuneMale,
        femelle: femelle,
      );

      expect(result.isValid, true); // Pas bloquant
      expect(result.severity, ValidationSeverity.avertissement);
      expect(result.errorMessage, contains('3 mois'));
    });

    test('✅ Validation OK : âge ≥ 5 mois', () {
      final male = Lapin(
        id: 1,
        nom: 'Max',
        race: 'Géant',
        sexe: 'Mâle',
        dateNaissance: DateTime.now().subtract(
          const Duration(days: 180),
        ), // 6 mois
      );

      final femelle = Lapin(
        id: 2,
        nom: 'Bella',
        race: 'Géant',
        sexe: 'Femelle',
        dateNaissance: DateTime.now().subtract(const Duration(days: 200)),
      );

      final result = AccouplementValidator.validateAgeMinimum(
        male: male,
        femelle: femelle,
      );

      expect(result.isValid, true);
      expect(result.severity, ValidationSeverity.avertissement);
      expect(result.errorMessage, null);
    });
  });

  group('AccouplementValidator - Consanguinité', () {
    test('R5 : Avertissement père/fille', () {
      final pere = Lapin(
        id: 1,
        nom: 'Max',
        race: 'Géant',
        sexe: 'Mâle',
        dateNaissance: DateTime(2022, 1, 1),
      );

      final fille = Lapin(
        id: 2,
        nom: 'Bella',
        race: 'Géant',
        sexe: 'Femelle',
        dateNaissance: DateTime(2023, 1, 1),
      );

      // Bella a pour père Max
      final parentsFille = {'pere': 1, 'mere': 10};
      final parentsPere = {'pere': null, 'mere': null};

      final result = AccouplementValidator.validateConsanguinite(
        male: pere,
        femelle: fille,
        parentsMale: parentsPere,
        parentsFemelle: parentsFille,
      );

      expect(result.isValid, true); // Pas bloquant
      expect(result.severity, ValidationSeverity.avertissement);
      expect(result.errorMessage, contains('consanguin'));
    });

    test('✅ Validation OK : pas de lien de parenté', () {
      final male = Lapin(
        id: 1,
        nom: 'Max',
        race: 'Géant',
        sexe: 'Mâle',
        dateNaissance: DateTime(2023, 1, 1),
      );

      final femelle = Lapin(
        id: 2,
        nom: 'Bella',
        race: 'Géant',
        sexe: 'Femelle',
        dateNaissance: DateTime(2023, 1, 1),
      );

      final parentsMale = {'pere': 10, 'mere': 20};
      final parentsFemelle = {'pere': 30, 'mere': 40};

      final result = AccouplementValidator.validateConsanguinite(
        male: male,
        femelle: femelle,
        parentsMale: parentsMale,
        parentsFemelle: parentsFemelle,
      );

      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });
  });

  group('AccouplementValidator - Date d\'accouplement', () {
    test('R6 : Date d\'accouplement ne peut pas être dans le futur', () {
      final dateFutur = DateTime.now().add(const Duration(days: 5));

      final result = AccouplementValidator.validateDateAccouplement(dateFutur);

      expect(result.isValid, false);
      expect(result.severity, ValidationSeverity.bloquante);
      expect(result.errorMessage, contains('futur'));
    });

    test('✅ Validation OK : date passée', () {
      final datePasse = DateTime.now().subtract(const Duration(days: 2));

      final result = AccouplementValidator.validateDateAccouplement(datePasse);

      expect(result.isValid, true);
      expect(result.errorMessage, null);
    });
  });
}
