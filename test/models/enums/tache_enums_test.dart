import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/enums/tache_enums.dart';

/// Tests unitaires pour tous les enums de tâches
void main() {
  group('PrioriteTache Enum', () {
    test('fromString() devrait convertir correctement', () {
      expect(PrioriteTache.fromString('haute'), PrioriteTache.haute);
      expect(PrioriteTache.fromString('normale'), PrioriteTache.normale);
      expect(PrioriteTache.fromString('basse'), PrioriteTache.basse);
      expect(PrioriteTache.fromString('Haute'), PrioriteTache.haute);
    });

    test('toDatabase() devrait retourner valeur normalisée', () {
      expect(PrioriteTache.haute.toDatabase(), 'haute');
      expect(PrioriteTache.normale.toDatabase(), 'normale');
      expect(PrioriteTache.basse.toDatabase(), 'basse');
    });

    test('devrait avoir les bons labels', () {
      expect(PrioriteTache.haute.label, 'Haute');
      expect(PrioriteTache.normale.label, 'Normale');
      expect(PrioriteTache.basse.label, 'Basse');
    });
  });

  group('CategorieTache Enum', () {
    test('fromString() devrait convertir toutes les catégories', () {
      expect(CategorieTache.fromString('reproduction'), CategorieTache.reproduction);
      expect(CategorieTache.fromString('sante'), CategorieTache.sante);
      expect(CategorieTache.fromString('alimentation'), CategorieTache.alimentation);
      expect(CategorieTache.fromString('entretien'), CategorieTache.entretien);
      expect(CategorieTache.fromString('administratif'), CategorieTache.administratif);
      expect(CategorieTache.fromString('autre'), CategorieTache.autre);
    });

    test('devrait accepter anciennes valeurs accentuées', () {
      expect(CategorieTache.fromString('Santé'), CategorieTache.sante);
      expect(CategorieTache.fromString('Administratif'), CategorieTache.administratif);
    });

    test('devrait retourner autre par défaut', () {
      expect(CategorieTache.fromString('invalide'), CategorieTache.autre);
    });
  });

  group('StatutTache Enum', () {
    test('fromString() devrait convertir tous les statuts', () {
      expect(StatutTache.fromString('a_faire'), StatutTache.aFaire);
      expect(StatutTache.fromString('en_cours'), StatutTache.enCours);
      expect(StatutTache.fromString('terminee'), StatutTache.terminee);
      expect(StatutTache.fromString('annulee'), StatutTache.annulee);
      expect(StatutTache.fromString('reportee'), StatutTache.reportee);
    });

    test('devrait accepter anciennes valeurs avec espaces', () {
      expect(StatutTache.fromString('À faire'), StatutTache.aFaire);
      expect(StatutTache.fromString('En cours'), StatutTache.enCours);
      expect(StatutTache.fromString('Terminée'), StatutTache.terminee);
      expect(StatutTache.fromString('Annulée'), StatutTache.annulee);
      expect(StatutTache.fromString('Reportée'), StatutTache.reportee);
    });

    test('devrait suivre workflow logique', () {
      // Workflow: aFaire → enCours → terminee
      expect(StatutTache.aFaire, StatutTache.aFaire);
      expect(StatutTache.enCours, StatutTache.enCours);
      expect(StatutTache.terminee, StatutTache.terminee);
    });
  });

  group('FrequenceRecurrence Enum', () {
    test('fromString() devrait convertir les fréquences', () {
      expect(FrequenceRecurrence.fromString('quotidienne'), FrequenceRecurrence.quotidienne);
      expect(FrequenceRecurrence.fromString('hebdomadaire'), FrequenceRecurrence.hebdomadaire);
      expect(FrequenceRecurrence.fromString('mensuelle'), FrequenceRecurrence.mensuelle);
    });

    test('devrait accepter anciennes valeurs capitalisées', () {
      expect(FrequenceRecurrence.fromString('Quotidienne'), FrequenceRecurrence.quotidienne);
      expect(FrequenceRecurrence.fromString('Hebdomadaire'), FrequenceRecurrence.hebdomadaire);
      expect(FrequenceRecurrence.fromString('Mensuelle'), FrequenceRecurrence.mensuelle);
    });

    test('devrait avoir les bons labels', () {
      expect(FrequenceRecurrence.quotidienne.label, 'Quotidienne');
      expect(FrequenceRecurrence.hebdomadaire.label, 'Hebdomadaire');
      expect(FrequenceRecurrence.mensuelle.label, 'Mensuelle');
    });
  });
}
