import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/enums/type_soin.dart';

/// Tests unitaires pour l'enum TypeSoin
void main() {
  group('TypeSoin Enum', () {
    group('fromString()', () {
      test('devrait convertir les valeurs normalisées', () {
        expect(TypeSoin.fromString('vaccination'), TypeSoin.vaccination);
        expect(TypeSoin.fromString('traitement'), TypeSoin.traitement);
        expect(TypeSoin.fromString('vermifuge'), TypeSoin.vermifuge);
        expect(TypeSoin.fromString('autre'), TypeSoin.autre);
      });

      test('devrait accepter anciennes valeurs capitalisées', () {
        expect(TypeSoin.fromString('Vaccination'), TypeSoin.vaccination);
        expect(TypeSoin.fromString('Traitement'), TypeSoin.traitement);
        expect(TypeSoin.fromString('Vermifuge'), TypeSoin.vermifuge);
        expect(TypeSoin.fromString('Autre'), TypeSoin.autre);
      });

      test('devrait gérer les variations de casse', () {
        expect(TypeSoin.fromString('VACCINATION'), TypeSoin.vaccination);
        expect(TypeSoin.fromString('TRAITEMENT'), TypeSoin.traitement);
      });

      test('devrait retourner autre par défaut pour valeur invalide', () {
        expect(TypeSoin.fromString('invalide'), TypeSoin.autre);
        expect(TypeSoin.fromString(''), TypeSoin.autre);
        expect(TypeSoin.fromString('soins divers'), TypeSoin.autre);
      });
    });

    group('toDatabase()', () {
      test('devrait retourner la valeur normalisée', () {
        expect(TypeSoin.vaccination.toDatabase(), 'vaccination');
        expect(TypeSoin.traitement.toDatabase(), 'traitement');
        expect(TypeSoin.vermifuge.toDatabase(), 'vermifuge');
        expect(TypeSoin.autre.toDatabase(), 'autre');
      });
    });

    group('Propriétés', () {
      test('devrait avoir les bons labels français', () {
        expect(TypeSoin.vaccination.label, 'Vaccination');
        expect(TypeSoin.traitement.label, 'Traitement');
        expect(TypeSoin.vermifuge.label, 'Vermifuge');
        expect(TypeSoin.autre.label, 'Autre');
      });
    });

    group('Cas d\'usage', () {
      test('devrait permettre filtrage par type', () {
        final types = [
          TypeSoin.vaccination,
          TypeSoin.traitement,
          TypeSoin.vaccination,
          TypeSoin.vermifuge,
        ];

        final vaccinations = types.where((t) => t == TypeSoin.vaccination).length;
        expect(vaccinations, 2);
      });
    });
  });
}
