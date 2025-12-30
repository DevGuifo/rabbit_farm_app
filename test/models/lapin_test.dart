import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/lapin.dart';
import 'package:rabbit_farm_app/models/accouplement.dart';

void main() {
  group('Lapin Model Tests', () {
    test('Création d\'un lapin avec tous les champs', () {
      final lapin = Lapin(
        id: 1,
        nom: 'Pompon',
        sexe: 'M',
        dateNaissance: DateTime(2024, 1, 15),
        race: 'Rex',
        couleur: 'Gris',
        numeroIdentification: 'REX001',
        poids: 2.5,
        statut: 'Actif',
        localisation: 'Cage A1',
        photoPath: '/photos/pompon.jpg',
        notes: 'Très calme',
      );

      expect(lapin.id, equals(1));
      expect(lapin.nom, equals('Pompon'));
      expect(lapin.sexe, equals('M'));
      expect(lapin.race, equals('Rex'));
      expect(lapin.poids, equals(2.5));
    });

    test('Conversion lapin vers Map', () {
      final lapin = Lapin(
        nom: 'Flocon',
        sexe: 'F',
        dateNaissance: DateTime(2024, 3, 20),
        race: 'Nain',
      );

      final map = lapin.toMap();

      expect(map['nom'], equals('Flocon'));
      expect(map['sexe'], equals('F'));
      expect(map['race'], equals('Nain'));
      expect(map['date_naissance'], isNotNull);
    });

    test('Création lapin depuis Map', () {
      final map = {
        'id': 5,
        'nom': 'Caramel',
        'sexe': 'F',
        'date_naissance': DateTime(2024, 5, 10).toIso8601String(),
        'race': 'Bélier',
        'couleur': 'Marron',
        'poids': 3.2,
        'statut': 'Actif',
      };

      final lapin = Lapin.fromMap(map);

      expect(lapin.id, equals(5));
      expect(lapin.nom, equals('Caramel'));
      expect(lapin.sexe, equals('F'));
      expect(lapin.race, equals('Bélier'));
      expect(lapin.poids, equals(3.2));
    });

    test('Gestion des valeurs nullables', () {
      final lapin = Lapin(
        nom: 'Test',
        race: 'Test Race',
        sexe: 'M',
        dateNaissance: DateTime.now(),
      );

      expect(lapin.couleur, isNull);
      expect(lapin.poids, isNull);
      expect(lapin.localisation, isNull);
      expect(lapin.photoPath, isNull);
    });

    test('Clone d\'un lapin', () {
      final original = Lapin(
        id: 1,
        nom: 'Original',
        sexe: 'M',
        dateNaissance: DateTime(2024, 1, 1),
        race: 'Géant',
        poids: 4.5,
      );

      final clone = Lapin.fromMap(original.toMap());

      expect(clone.nom, equals(original.nom));
      expect(clone.sexe, equals(original.sexe));
      expect(clone.race, equals(original.race));
      expect(clone.poids, equals(original.poids));
    });

    group('estGestante', () {
      test('Femelle avec accouplement actif est gestante', () {
        final femelle = Lapin(
          id: 1,
          nom: 'Caramel',
          sexe: 'Femelle',
          dateNaissance: DateTime(2024, 1, 1),
          race: 'Rex',
        );

        final accouplement = Accouplement(
          id: 1,
          maleId: 2,
          femelleId: 1,
          dateAccouplement: DateTime.now().subtract(const Duration(days: 10)),
          dateMiseBasPrevue: DateTime.now().add(const Duration(days: 21)),
          statut: 'confirme',
        );

        expect(femelle.estGestante([accouplement]), isTrue);
      });

      test('Femelle avec accouplement en_attente est gestante', () {
        final femelle = Lapin(
          id: 1,
          nom: 'Neige',
          sexe: 'F',
          dateNaissance: DateTime(2024, 1, 1),
          race: 'Nain',
        );

        final accouplement = Accouplement(
          id: 1,
          maleId: 2,
          femelleId: 1,
          dateAccouplement: DateTime.now().subtract(const Duration(days: 5)),
          dateMiseBasPrevue: DateTime.now().add(const Duration(days: 26)),
          statut: 'en_attente',
        );

        expect(femelle.estGestante([accouplement]), isTrue);
      });

      test('Femelle avec accouplement terminé n\'est pas gestante', () {
        final femelle = Lapin(
          id: 1,
          nom: 'Caramel',
          sexe: 'Femelle',
          dateNaissance: DateTime(2024, 1, 1),
          race: 'Rex',
        );

        final accouplement = Accouplement(
          id: 1,
          maleId: 2,
          femelleId: 1,
          dateAccouplement: DateTime.now().subtract(const Duration(days: 40)),
          dateMiseBasPrevue: DateTime.now().subtract(const Duration(days: 9)),
          statut: 'termine',
        );

        expect(femelle.estGestante([accouplement]), isFalse);
      });

      test('Femelle avec date de mise bas passée n\'est pas gestante', () {
        final femelle = Lapin(
          id: 1,
          nom: 'Caramel',
          sexe: 'Femelle',
          dateNaissance: DateTime(2024, 1, 1),
          race: 'Rex',
        );

        final accouplement = Accouplement(
          id: 1,
          maleId: 2,
          femelleId: 1,
          dateAccouplement: DateTime.now().subtract(const Duration(days: 40)),
          dateMiseBasPrevue: DateTime.now().subtract(const Duration(days: 1)),
          statut: 'confirme',
        );

        expect(femelle.estGestante([accouplement]), isFalse);
      });

      test('Mâle n\'est jamais gestante', () {
        final male = Lapin(
          id: 2,
          nom: 'Flocon',
          sexe: 'Mâle',
          dateNaissance: DateTime(2024, 1, 1),
          race: 'Géant',
        );

        final accouplement = Accouplement(
          id: 1,
          maleId: 2,
          femelleId: 1,
          dateAccouplement: DateTime.now().subtract(const Duration(days: 10)),
          dateMiseBasPrevue: DateTime.now().add(const Duration(days: 21)),
          statut: 'confirme',
        );

        expect(male.estGestante([accouplement]), isFalse);
      });

      test('Femelle sans accouplement n\'est pas gestante', () {
        final femelle = Lapin(
          id: 1,
          nom: 'Caramel',
          sexe: 'Femelle',
          dateNaissance: DateTime(2024, 1, 1),
          race: 'Rex',
        );

        expect(femelle.estGestante([]), isFalse);
      });

      test('Femelle avec accouplement pour une autre femelle n\'est pas gestante', () {
        final femelle1 = Lapin(
          id: 1,
          nom: 'Caramel',
          sexe: 'Femelle',
          dateNaissance: DateTime(2024, 1, 1),
          race: 'Rex',
        );

        final accouplement = Accouplement(
          id: 1,
          maleId: 2,
          femelleId: 3, // Autre femelle
          dateAccouplement: DateTime.now().subtract(const Duration(days: 10)),
          dateMiseBasPrevue: DateTime.now().add(const Duration(days: 21)),
          statut: 'confirme',
        );

        expect(femelle1.estGestante([accouplement]), isFalse);
      });
    });
  });
}
