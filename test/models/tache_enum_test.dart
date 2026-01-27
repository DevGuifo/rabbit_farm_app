import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/tache.dart';
import 'package:rabbit_farm_app/models/enums/tache_enums.dart';

/// Tests unitaires pour le modèle Tache avec 4 enums
void main() {
  group('Tache Model avec enums', () {
    late Tache tacheTest;
    late DateTime dateTest;

    setUp(() {
      dateTest = DateTime(2026, 1, 20);
      tacheTest = Tache(
        id: 1,
        titre: 'Vacciner lot A',
        description: 'Vaccination myxomatose',
        dateCreation: dateTest,
        datePlanification: dateTest.add(const Duration(days: 7)),
        priorite: PrioriteTache.haute,
        categorie: CategorieTache.sante,
        statut: StatutTache.aFaire,
        frequenceRecurrence: FrequenceRecurrence.mensuelle,
        estRecurrente: true,
      );
    });

    group('Création avec 4 enums', () {
      test('devrait créer une tâche avec tous les enums', () {
        expect(tacheTest.priorite, PrioriteTache.haute);
        expect(tacheTest.categorie, CategorieTache.sante);
        expect(tacheTest.statut, StatutTache.aFaire);
        expect(tacheTest.frequenceRecurrence, FrequenceRecurrence.mensuelle);
      });

      test('devrait accepter toutes les combinaisons', () {
        final tache = Tache(
          titre: 'Test',
          dateCreation: DateTime.now(),
          datePlanification: DateTime.now(),
          priorite: PrioriteTache.basse,
          categorie: CategorieTache.reproduction,
          statut: StatutTache.terminee,
        );

        expect(tache.priorite, PrioriteTache.basse);
        expect(tache.categorie, CategorieTache.reproduction);
        expect(tache.statut, StatutTache.terminee);
      });
    });

    group('toMap() avec enums', () {
      test('devrait convertir tous les enums en String', () {
        final map = tacheTest.toMap();

        expect(map['priorite'], 'haute');
        expect(map['categorie'], 'sante');
        expect(map['statut'], 'a_faire');
        expect(map['frequence_recurrence'], 'mensuelle');
      });
    });

    group('fromMap() avec enums', () {
      test('devrait recréer tâche avec enums depuis Map', () {
        final map = tacheTest.toMap();
        final tacheRecree = Tache.fromMap(map);

        expect(tacheRecree.priorite, PrioriteTache.haute);
        expect(tacheRecree.categorie, CategorieTache.sante);
        expect(tacheRecree.statut, StatutTache.aFaire);
        expect(tacheRecree.frequenceRecurrence, FrequenceRecurrence.mensuelle);
      });

      test('devrait accepter anciennes valeurs String', () {
        final mapAncien = {
          'id': 1,
          'titre': 'Test',
          'date_planification': DateTime.now().toIso8601String(),
          'date_creation': DateTime.now().toIso8601String(),
          'priorite': 'Haute', // ❌ Ancien format
          'categorie': 'Santé', // ❌ Ancien format
          'statut': 'À faire', // ❌ Ancien format
        };

        final tache = Tache.fromMap(mapAncien);
        expect(tache.priorite, PrioriteTache.haute);
        expect(tache.categorie, CategorieTache.sante);
        expect(tache.statut, StatutTache.aFaire);
      });
    });

    group('estEnRetard() avec StatutTache enum', () {
      test('devrait retourner false si tâche terminée', () {
        final tacheTerminee = tacheTest.copyWith(
          statut: StatutTache.terminee,
          datePlanification: DateTime.now().subtract(const Duration(days: 5)),
        );

        expect(tacheTerminee.estEnRetard, isFalse); // ✅ Terminée = jamais en retard
      });

      test('devrait retourner false si tâche annulée', () {
        final tacheAnnulee = tacheTest.copyWith(
          statut: StatutTache.annulee,
          datePlanification: DateTime.now().subtract(const Duration(days: 5)),
        );

        expect(tacheAnnulee.estEnRetard, isFalse);
      });

      test('devrait retourner true si échéance passée et aFaire', () {
        final tacheEnRetard = tacheTest.copyWith(
          statut: StatutTache.aFaire,
          datePlanification: DateTime.now().subtract(const Duration(days: 1)),
        );

        expect(tacheEnRetard.estEnRetard, isTrue);
      });
    });

    group('copyWith() avec enums', () {
      test('devrait copier avec nouveaux enums', () {
        final copie = tacheTest.copyWith(
          priorite: PrioriteTache.basse,
          statut: StatutTache.enCours,
        );

        expect(copie.priorite, PrioriteTache.basse);
        expect(copie.statut, StatutTache.enCours);
        expect(copie.categorie, tacheTest.categorie); // Inchangé
      });
    });

    group('Workflow statuts', () {
      test('devrait suivre cycle aFaire → enCours → terminee', () {
        var tache = tacheTest.copyWith(statut: StatutTache.aFaire);
        expect(tache.statut, StatutTache.aFaire);

        tache = tache.copyWith(statut: StatutTache.enCours);
        expect(tache.statut, StatutTache.enCours);

        tache = tache.copyWith(statut: StatutTache.terminee);
        expect(tache.statut, StatutTache.terminee);
      });

      test('devrait permettre annulation depuis tout statut', () {
        final tache = tacheTest.copyWith(statut: StatutTache.annulee);
        expect(tache.statut, StatutTache.annulee);
      });
    });
  });
}
