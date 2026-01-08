/// Test Phase 4 Refactoring: Validation des FK (cage_id, medicament_id, materiau_id)
///
/// Ce test vérifie que les modifications UI Phase 4 stockent correctement les FK
/// tout en maintenant la backward compatibility avec les champs STRING.
///
/// Usage: flutter test test/refactoring_phase4_test.dart
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/services/database_helper.dart';
import 'package:rabbit_farm_app/models/lapin.dart';
import 'package:rabbit_farm_app/models/soin.dart';
import 'package:rabbit_farm_app/models/medicament.dart';
import 'package:rabbit_farm_app/models/batiment.dart';
import 'package:rabbit_farm_app/models/clapier.dart';
import 'package:rabbit_farm_app/models/cage.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  group('Phase 4 Refactoring - FK Validation', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      // Utiliser la DB réelle (pas de sqflite_ffi pour éviter dépendances)
      dbHelper = DatabaseHelper.instance;
      await dbHelper.database; // Force l'initialisation
    });

    test('1. Lapin avec cage_id FK - Insertion et vérification', () async {
      // ARRANGE: Créer la structure Bâtiment > Clapier > Cage
      final batiment = await dbHelper.insertBatiment(
        Batiment(nom: 'Bâtiment Test'),
      );

      final clapier = await dbHelper.insertClapier(
        Clapier(nom: 'Clapier Test', batimentId: batiment.id!),
      );

      final cage = await dbHelper.insertCage(
        Cage(
          clapierId: clapier.id!,
          numero: 'C1-Test',
          type: 'individuelle',
          capacite: 1,
        ),
      );

      // ACT: Créer un lapin avec cage_id FK
      final lapin = await dbHelper.insertLapin(
        Lapin(
          nom: 'Fluffy Test ${DateTime.now().millisecondsSinceEpoch}',
          sexe: 'M',
          race: 'Néo-Zélandais',
          dateNaissance: DateTime(2025, 1, 1),
          cageId: cage.id, // ✅ Phase 4: FK
          localisation: 'C1-Test', // ✅ Backward compatibility STRING
        ),
      );

      // ASSERT: Vérifier en DB
      final db = await dbHelper.database;
      final result = await db.query(
        'lapins',
        where: 'id = ?',
        whereArgs: [lapin.id],
      );

      expect(result.length, 1);
      expect(result[0]['cage_id'], cage.id); // ✅ FK stockée
      expect(result[0]['localisation'], 'C1-Test'); // ✅ STRING présent

      debugPrint(
        '✅ Test 1 PASS: Lapin avec cage_id=${cage.id} stocké correctement',
      );
    });

    test('2. Soin avec medicament_id FK - Insertion et vérification', () async {
      // ARRANGE: Créer un lapin et un médicament
      final lapin = await dbHelper.insertLapin(
        Lapin(
          nom: 'Lapinou Test ${DateTime.now().millisecondsSinceEpoch}',
          sexe: 'F',
          race: 'Californien',
          dateNaissance: DateTime(2025, 6, 1),
        ),
      );

      final medicament = await dbHelper.insertMedicament(
        Medicament(
          nom: 'Ivermectine Test ${DateTime.now().millisecondsSinceEpoch}',
          type: 'antiparasitaire',
          quantiteStock: 100.0,
          unite: 'ml',
        ),
      );

      // ACT: Créer un soin avec medicament_id FK
      final soin = await dbHelper.insertSoin(
        Soin(
          lapinId: lapin.id!,
          date: DateTime.now(),
          type: 'traitement',
          description: 'Vermifuge test',
          medicamentId: medicament.id, // ✅ Phase 4: FK
          medicament: medicament.nom, // ✅ Backward compatibility STRING
          dosage: '0.2ml',
        ),
      );

      // ASSERT: Vérifier en DB
      final db = await dbHelper.database;
      final result = await db.query(
        'soins',
        where: 'id = ?',
        whereArgs: [soin.id],
      );

      expect(result.length, 1);
      expect(result[0]['medicament_id'], medicament.id); // ✅ FK stockée
      expect(result[0]['medicament'], medicament.nom); // ✅ STRING présent

      debugPrint(
        '✅ Test 2 PASS: Soin avec medicament_id=${medicament.id} stocké correctement',
      );
    });

    test(
      '3. PreparationNid avec materiau_id FK - Insertion et vérification',
      () async {
        // ARRANGE: Créer accouplement (requis pour PreparationNid)
        final male = await dbHelper.insertLapin(
          Lapin(
            nom: 'Mâle Test ${DateTime.now().millisecondsSinceEpoch}',
            sexe: 'M',
            race: 'Néo-Zélandais',
            dateNaissance: DateTime(2024, 1, 1),
          ),
        );

        final femelle = await dbHelper.insertLapin(
          Lapin(
            nom: 'Femelle Test ${DateTime.now().millisecondsSinceEpoch}',
            sexe: 'F',
            race: 'Néo-Zélandais',
            dateNaissance: DateTime(2024, 1, 1),
          ),
        );

        final db = await dbHelper.database;
        final accouplementId = await db.insert('accouplements', {
          'male_id': male.id,
          'femelle_id': femelle.id,
          'date_accouplement': DateTime.now().toIso8601String(),
          'date_mise_bas_prevue': DateTime.now()
              .add(Duration(days: 31))
              .toIso8601String(),
          'statut': 'confirme',
        });

        // ACT: Créer préparation nid avec materiau_id FK
        // materiau_id: 1=Paille, 2=Foin, 3=Copeaux, 4=Mixte
        final preparationId = await db.insert('preparations_nid', {
          'accouplement_id': accouplementId,
          'date_preparation': DateTime.now().toIso8601String(),
          'materiau_id': 2, // ✅ Phase 4: FK (Foin)
          'type_materiau': 'foin', // ✅ Backward compatibility STRING
          'boite_nid_installee': 1,
          'quantite_materiau': 1.5,
        });

        // ASSERT: Vérifier en DB
        final result = await db.query(
          'preparations_nid',
          where: 'id = ?',
          whereArgs: [preparationId],
        );

        expect(result.length, 1);
        expect(result[0]['materiau_id'], 2); // ✅ FK stockée
        expect(result[0]['type_materiau'], 'foin'); // ✅ STRING présent

        debugPrint(
          '✅ Test 3 PASS: PreparationNid avec materiau_id=2 stocké correctement',
        );
      },
    );

    test(
      '4. Backward compatibility - Champs STRING toujours présents',
      () async {
        // ARRANGE & ACT: Créer données sans FK (comme dans ancienne version)
        final lapin = await dbHelper.insertLapin(
          Lapin(
            nom: 'Legacy Test ${DateTime.now().millisecondsSinceEpoch}',
            sexe: 'M',
            race: 'Fauve',
            dateNaissance: DateTime(2024, 1, 1),
            localisation: 'Bâtiment A - C5', // ✅ Ancien format STRING
            // cageId: null, // Pas de FK
          ),
        );

        final soin = await dbHelper.insertSoin(
          Soin(
            lapinId: lapin.id!,
            date: DateTime.now(),
            type: 'vaccination',
            description: 'Myxomatose',
            medicament: 'Vaccin Nobivac', // ✅ Ancien format STRING
            // medicamentId: null, // Pas de FK
          ),
        );

        // ASSERT: Vérifier que les données sont acceptées
        final db = await dbHelper.database;

        final lapinResult = await db.query(
          'lapins',
          where: 'id = ?',
          whereArgs: [lapin.id],
        );
        expect(lapinResult[0]['localisation'], 'Bâtiment A - C5');
        expect(lapinResult[0]['cage_id'], null); // FK nullable

        final soinResult = await db.query(
          'soins',
          where: 'id = ?',
          whereArgs: [soin.id],
        );
        expect(soinResult[0]['medicament'], 'Vaccin Nobivac');
        expect(soinResult[0]['medicament_id'], null); // FK nullable

        debugPrint(
          '✅ Test 4 PASS: Backward compatibility maintenue (FK null acceptées)',
        );
      },
    );

    test('5. Vérification structure table materiaux', () async {
      // ASSERT: Vérifier que la table materiaux existe avec 4 enregistrements seed
      final db = await dbHelper.database;
      final result = await db.query('materiaux', orderBy: 'id ASC');

      expect(result.length, 4);
      expect(result[0]['code'], 'paille');
      expect(result[1]['code'], 'foin');
      expect(result[2]['code'], 'copeaux');
      expect(result[3]['code'], 'mixte');

      debugPrint('✅ Test 5 PASS: Table materiaux avec 4 seed records');
    });

    test('6. Validation contraintes FK - CASCADE DELETE', () async {
      // ARRANGE: Créer hiérarchie complète
      final batiment = await dbHelper.insertBatiment(
        Batiment(
          nom: 'Bâtiment CASCADE ${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

      final clapier = await dbHelper.insertClapier(
        Clapier(nom: 'Clapier CASCADE', batimentId: batiment.id!),
      );

      final cage = await dbHelper.insertCage(
        Cage(
          clapierId: clapier.id!,
          numero: 'C-CASCADE',
          type: 'individuelle',
          capacite: 1,
        ),
      );

      final lapin = await dbHelper.insertLapin(
        Lapin(
          nom: 'Cascade Test ${DateTime.now().millisecondsSinceEpoch}',
          sexe: 'F',
          race: 'Géant des Flandres',
          dateNaissance: DateTime(2025, 1, 1),
          cageId: cage.id,
        ),
      );

      // ACT: Supprimer le bâtiment (devrait cascader)
      await dbHelper.deleteBatiment(batiment.id!);

      // ASSERT: Vérifier que le lapin existe toujours mais cageId=null (ON DELETE SET NULL)
      final db = await dbHelper.database;
      final lapinResult = await db.query(
        'lapins',
        where: 'id = ?',
        whereArgs: [lapin.id],
      );

      // Avec ON DELETE SET NULL: lapin existe, cage_id=null
      // Avec ON DELETE CASCADE: lapin n'existe plus
      if (lapinResult.isNotEmpty) {
        expect(lapinResult[0]['cage_id'], null);
        debugPrint('✅ Test 6 PASS: CASCADE DELETE avec SET NULL fonctionne');
      } else {
        debugPrint('✅ Test 6 PASS: CASCADE DELETE strict fonctionne');
      }
    });

    test('7. Version DB - Vérification migration à v17', () async {
      final db = await dbHelper.database;
      final result = await db.rawQuery('PRAGMA user_version');
      final version = Sqflite.firstIntValue(result) ?? 0;

      expect(
        version,
        greaterThanOrEqualTo(17),
        reason: 'DB version doit être ≥17 pour inclure les FK Phase 4',
      );

      debugPrint('✅ Test 7 PASS: DB version=$version (Phase 4 migrée)');
    });
  });
}
