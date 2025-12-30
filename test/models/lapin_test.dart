import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/lapin.dart';

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
  });
}
