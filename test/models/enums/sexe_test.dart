import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/enums/sexe.dart';

/// Tests unitaires pour l'enum Sexe
///
/// Vérifie :
/// - Conversion fromString() avec rétrocompatibilité
/// - Conversion toDatabase()
/// - Valeurs label et value
void main() {
  group('Sexe Enum', () {
    group('fromString()', () {
      test('devrait convertir les valeurs normalisées', () {
        expect(Sexe.fromString('male'), Sexe.male);
        expect(Sexe.fromString('femelle'), Sexe.femelle);
      });

      test('devrait accepter anciennes valeurs majuscules', () {
        expect(Sexe.fromString('Mâle'), Sexe.male);
        expect(Sexe.fromString('Femelle'), Sexe.femelle);
      });

      test('devrait accepter abréviations', () {
        expect(Sexe.fromString('M'), Sexe.male);
        expect(Sexe.fromString('F'), Sexe.femelle);
        expect(Sexe.fromString('m'), Sexe.male);
        expect(Sexe.fromString('f'), Sexe.femelle);
      });

      test('devrait accepter variations accentuées', () {
        expect(Sexe.fromString('mâle'), Sexe.male);
        expect(Sexe.fromString('MALE'), Sexe.male);
        expect(Sexe.fromString('FEMELLE'), Sexe.femelle);
      });

      test('devrait retourner male par défaut pour valeur invalide', () {
        expect(Sexe.fromString('invalide'), Sexe.male);
        expect(Sexe.fromString(''), Sexe.male);
        expect(Sexe.fromString('autre'), Sexe.male);
      });
    });

    group('toDatabase()', () {
      test('devrait retourner la valeur normalisée', () {
        expect(Sexe.male.toDatabase(), 'male');
        expect(Sexe.femelle.toDatabase(), 'femelle');
      });
    });

    group('Propriétés', () {
      test('devrait avoir les bonnes valeurs', () {
        expect(Sexe.male.value, 'male');
        expect(Sexe.femelle.value, 'femelle');
      });

      test('devrait avoir les bons labels français', () {
        expect(Sexe.male.label, 'Mâle');
        expect(Sexe.femelle.label, 'Femelle');
      });
    });

    group('Comparaisons', () {
      test('devrait comparer correctement les enums', () {
        expect(Sexe.male == Sexe.male, isTrue);
        expect(Sexe.male == Sexe.femelle, isFalse);
        expect(Sexe.femelle == Sexe.femelle, isTrue);
      });
    });
  });
}
