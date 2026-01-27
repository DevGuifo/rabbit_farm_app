import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/soin.dart';
import 'package:rabbit_farm_app/models/enums/type_soin.dart';

/// Tests unitaires pour le modèle Soin avec enum TypeSoin
void main() {
  group('Soin Model avec TypeSoin enum', () {
    late Soin soinTest;
    late DateTime dateTest;

    setUp(() {
      dateTest = DateTime(2026, 1, 15);
      soinTest = Soin(
        id: 1,
        lapinId: 42,
        date: dateTest,
        type: TypeSoin.vaccination,
        description: 'Vaccin myxomatose',
        medicamentId: 5,
        dosage: '0.5ml',
        dateRappel: DateTime(2026, 2, 15),
        notes: 'Rappel dans 1 mois',
      );
    });

    group('Création avec enum', () {
      test('devrait créer un soin avec TypeSoin enum', () {
        final soin = Soin(
          lapinId: 1,
          date: DateTime.now(),
          type: TypeSoin.traitement,
          description: 'Test',
        );

        expect(soin.type, TypeSoin.traitement);
        expect(soin.type.label, 'Traitement');
      });

      test('devrait accepter tous les types de soins', () {
        expect(TypeSoin.vaccination, TypeSoin.vaccination);
        expect(TypeSoin.traitement, TypeSoin.traitement);
        expect(TypeSoin.vermifuge, TypeSoin.vermifuge);
        expect(TypeSoin.autre, TypeSoin.autre);
      });
    });

    group('toMap() avec enum', () {
      test('devrait convertir TypeSoin en String normalisée', () {
        final map = soinTest.toMap();

        expect(map['type'], 'vaccination'); // ✅ Valeur DB normalisée
        expect(map['lapin_id'], 42);
        expect(map['description'], 'Vaccin myxomatose');
        expect(map['medicament_id'], 5);
      });

      test('devrait gérer tous les types correctement', () {
        final types = [
          TypeSoin.vaccination,
          TypeSoin.traitement,
          TypeSoin.vermifuge,
          TypeSoin.autre,
        ];

        for (final type in types) {
          final soin = Soin(
            lapinId: 1,
            date: DateTime.now(),
            type: type,
            description: 'Test',
          );
          final map = soin.toMap();
          expect(map['type'], type.value);
        }
      });
    });

    group('fromMap() avec enum', () {
      test('devrait recréer soin avec enum depuis Map', () {
        final map = soinTest.toMap();
        final soinRecree = Soin.fromMap(map);

        expect(soinRecree.type, TypeSoin.vaccination);
        expect(soinRecree.lapinId, 42);
        expect(soinRecree.medicamentId, 5);
      });

      test('devrait accepter anciennes valeurs String capitalisées', () {
        final mapAncien = {
          'id': 1,
          'lapin_id': 1,
          'date': DateTime.now().toIso8601String(),
          'type': 'Traitement', // ❌ Ancien format
          'description': 'Test',
        };

        final soin = Soin.fromMap(mapAncien);
        expect(soin.type, TypeSoin.traitement); // ✅ Converti
      });

      test('cycle toMap → fromMap devrait être idempotent', () {
        final map1 = soinTest.toMap();
        final soinRecree = Soin.fromMap(map1);
        final map2 = soinRecree.toMap();

        expect(map2['type'], map1['type']);
        expect(map2['lapin_id'], map1['lapin_id']);
        expect(map2['medicament_id'], map1['medicament_id']);
      });
    });

    group('Propriétés calculées', () {
      test('rappelNecessaire devrait détecter rappel passé', () {
        final soinAvecRappelPasse = Soin(
          lapinId: 1,
          date: DateTime.now().subtract(const Duration(days: 60)),
          type: TypeSoin.vaccination,
          description: 'Test',
          dateRappel: DateTime.now().subtract(const Duration(days: 1)),
        );

        expect(soinAvecRappelPasse.rappelNecessaire, isTrue);
      });

      test('joursAvantRappel devrait calculer correctement', () {
        final dateRappel = DateTime.now().add(const Duration(days: 30));
        final soin = Soin(
          lapinId: 1,
          date: DateTime.now(),
          type: TypeSoin.vaccination,
          description: 'Test',
          dateRappel: dateRappel,
        );

        expect(soin.joursAvantRappel, greaterThanOrEqualTo(29));
        expect(soin.joursAvantRappel, lessThanOrEqualTo(30));
      });
    });

    group('copyWith() avec enum', () {
      test('devrait copier avec nouveau type', () {
        final copie = soinTest.copyWith(type: TypeSoin.vermifuge);

        expect(copie.type, TypeSoin.vermifuge);
        expect(copie.lapinId, soinTest.lapinId); // Autres champs inchangés
        expect(copie.description, soinTest.description);
      });
    });

    group('Champ medicament @Deprecated', () {
      test('medicamentId devrait être utilisé prioritairement', () {
        final soin = Soin(
          lapinId: 1,
          date: DateTime.now(),
          type: TypeSoin.traitement,
          description: 'Test',
          medicamentId: 10, // ✅ Nouveau
          // medicament: 'Ivermectine', // ❌ Déprécié
        );

        expect(soin.medicamentId, 10);
      });
    });
  });
}
