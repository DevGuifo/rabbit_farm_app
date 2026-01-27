import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/lapin.dart';
import 'package:rabbit_farm_app/models/enums/sexe.dart';

/// Tests unitaires pour le modèle Lapin
/// 
/// Ces tests vérifient :
/// - La création d'un lapin avec enum Sexe
/// - Les conversions toMap() / fromMap()
/// - Les propriétés calculées (âge)
/// - La méthode copyWith()
void main() {
  group('Lapin Model', () {
    // Données de test réutilisables
    late Lapin lapinTest;
    late DateTime dateNaissanceTest;

    setUp(() {
      dateNaissanceTest = DateTime(2025, 6, 15); // 15 juin 2025
      lapinTest = Lapin(
        id: 1,
        nom: 'Flocon',
        race: 'Géant des Flandres',
        sexe: Sexe.male,
        dateNaissance: dateNaissanceTest,
        poids: 7.5,
        statut: 'Reproducteur',
        localisation: 'Cage A1',
        numeroIdentification: 'LAP-001',
        couleur: 'Blanc',
        prixAchat: 50.0,
        origine: 'Élevage local',
        notes: 'Bon reproducteur',
      );
    });

    group('Création', () {
      test('devrait créer un lapin avec tous les champs requis', () {
        final lapin = Lapin(
          nom: 'Test',
          race: 'Bélier',
          sexe: Sexe.femelle,
          dateNaissance: DateTime.now(),
        );

        expect(lapin.nom, 'Test');
        expect(lapin.race, 'Bélier');
        expect(lapin.sexe, Sexe.femelle);
        expect(lapin.id, isNull); // ID null pour nouveau lapin
      });

      test('devrait créer un lapin avec tous les champs optionnels', () {
        expect(lapinTest.id, 1);
        expect(lapinTest.nom, 'Flocon');
        expect(lapinTest.poids, 7.5);
        expect(lapinTest.statut, 'Reproducteur');
        expect(lapinTest.localisation, 'Cage A1');
        expect(lapinTest.numeroIdentification, 'LAP-001');
      });
    });

    group('toMap() / fromMap()', () {
      test('toMap() devrait convertir correctement le lapin en Map', () {
        final map = lapinTest.toMap();

        expect(map['id'], 1);
        expect(map['nom'], 'Flocon');
        expect(map['race'], 'Géant des Flandres');
        expect(map['sexe'], 'male'); // ✅ Valeur normalisée par enum
        expect(map['date_naissance'], dateNaissanceTest.toIso8601String());
        expect(map['poids'], 7.5);
        expect(map['statut'], 'Reproducteur');
        expect(map['localisation'], 'Cage A1');
        expect(map['numero_identification'], 'LAP-001');
      });

      test('fromMap() devrait recréer un lapin identique depuis un Map', () {
        final map = lapinTest.toMap();
        final lapinRecree = Lapin.fromMap(map);

        expect(lapinRecree.id, lapinTest.id);
        expect(lapinRecree.nom, lapinTest.nom);
        expect(lapinRecree.race, lapinTest.race);
        expect(lapinRecree.sexe, lapinTest.sexe); // ✅ Comparaison enum
        expect(lapinRecree.dateNaissance, lapinTest.dateNaissance);
        expect(lapinRecree.poids, lapinTest.poids);
        expect(lapinRecree.statut, lapinTest.statut);
      });

      test('fromMap() devrait accepter anciennes valeurs String', () {
        final mapAncien = {
          'id': 1,
          'nom': 'Test',
          'race': 'Bélier',
          'sexe': 'Mâle', // ❌ Ancien format
          'date_naissance': DateTime.now().toIso8601String(),
        };
        
        final lapin = Lapin.fromMap(mapAncien);
        expect(lapin.sexe, Sexe.male); // ✅ Converti via fromString()
      });

      test('cycle toMap → fromMap devrait être idempotent', () {
        final map1 = lapinTest.toMap();
        final lapinRecree = Lapin.fromMap(map1);
        final map2 = lapinRecree.toMap();

        // Les maps doivent être identiques
        expect(map2['nom'], map1['nom']);
        expect(map2['race'], map1['race']);
        expect(map2['poids'], map1['poids']);
      });
    });

    group('Propriétés calculées - Âge', () {
      test('ageEnJours devrait calculer correctement', () {
        final aujourdhui = DateTime.now();
        final ilY30Jours = aujourdhui.subtract(const Duration(days: 30));
        
        final lapin = Lapin(
          nom: 'Test',
          race: 'Test',
          sexe: Sexe.male,
          dateNaissance: ilY30Jours,
        );

        expect(lapin.ageEnJours, 30);
      });

      test('ageEnMois devrait calculer correctement', () {
        final aujourdhui = DateTime.now();
        final ilY90Jours = aujourdhui.subtract(const Duration(days: 90));
        
        final lapin = Lapin(
          nom: 'Test',
          race: 'Test',
          sexe: Sexe.male,
          dateNaissance: ilY90Jours,
        );

        expect(lapin.ageEnMois, 3); // 90 jours = 3 mois
      });

      test('ageFormate devrait afficher "X jours" pour moins de 30 jours', () {
        final aujourdhui = DateTime.now();
        final ilY15Jours = aujourdhui.subtract(const Duration(days: 15));
        
        final lapin = Lapin(
          nom: 'Test',
          race: 'Test',
          sexe: Sexe.male,
          dateNaissance: ilY15Jours,
        );

        expect(lapin.ageFormate, '15 jours');
      });

      test('ageFormate devrait afficher "X mois" entre 1 et 11 mois', () {
        final aujourdhui = DateTime.now();
        final ilY180Jours = aujourdhui.subtract(const Duration(days: 180));
        
        final lapin = Lapin(
          nom: 'Test',
          race: 'Test',
          sexe: Sexe.male,
          dateNaissance: ilY180Jours,
        );

        expect(lapin.ageFormate, '6 mois');
      });
    });

    group('copyWith()', () {
      test('devrait créer une copie identique sans modifications', () {
        final copie = lapinTest.copyWith();

        expect(copie.id, lapinTest.id);
        expect(copie.nom, lapinTest.nom);
        expect(copie.race, lapinTest.race);
        expect(copie.poids, lapinTest.poids);
      });

      test('devrait modifier uniquement les champs spécifiés', () {
        final copie = lapinTest.copyWith(
          nom: 'Nouveau Nom',
          poids: 8.0,
        );

        // Champs modifiés
        expect(copie.nom, 'Nouveau Nom');
        expect(copie.poids, 8.0);
        
        // Champs non modifiés
        expect(copie.id, lapinTest.id);
        expect(copie.race, lapinTest.race);
        expect(copie.sexe, lapinTest.sexe);
        expect(copie.statut, lapinTest.statut);
      });

      test('devrait pouvoir modifier le statut', () {
        final copie = lapinTest.copyWith(statut: 'Réformé');

        expect(copie.statut, 'Réformé');
        expect(copie.nom, lapinTest.nom); // Autres champs inchangés
      });
    });

    group('Filtrage par sexe', () {
      test('devrait identifier correctement un mâle', () {
        expect(lapinTest.sexe, Sexe.male);
      });

      test('devrait identifier correctement une femelle', () {
        final femelle = lapinTest.copyWith(sexe: Sexe.femelle);
        expect(femelle.sexe, Sexe.femelle);
      });
    });

    group('toString()', () {
      test('devrait retourner une représentation lisible', () {
        final str = lapinTest.toString();

        expect(str.contains('Flocon'), true);
        expect(str.contains('Géant des Flandres'), true);
        expect(str.contains('Mâle'), true);
      });
    });
  });
}
