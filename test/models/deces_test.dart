import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/deces.dart';

void main() {
  group('Deces Model Tests', () {
    test('Création d\'un décès avec paramètres requis', () {
      final deces = Deces(
        lapinId: 1,
        dateDeces: DateTime(2024, 6, 15),
        ageAuDecesJours: 365,
        cause: 'maladie',
        circonstancesDetailees: 'Myxomatose',
      );

      expect(deces.id, isNull);
      expect(deces.lapinId, 1);
      expect(deces.dateDeces, DateTime(2024, 6, 15));
      expect(deces.ageAuDecesJours, 365);
      expect(deces.cause, 'maladie');
      expect(deces.circonstancesDetailees, 'Myxomatose');
      expect(deces.autopsieRealisee, false);
      expect(deces.resultatsAutopsie, isNull);
      expect(deces.mesuresPreventives, isNull);
    });

    test('Création d\'un décès avec tous les paramètres', () {
      final deces = Deces(
        id: 10,
        lapinId: 5,
        dateDeces: DateTime(2024, 3, 20),
        ageAuDecesJours: 730,
        cause: 'euthanasie',
        circonstancesDetailees: 'Tumeur mammaire avancée',
        autopsieRealisee: true,
        resultatsAutopsie: 'Métastases confirmées',
        mesuresPreventives: 'Contrôle régulier des femelles reproductrices',
      );

      expect(deces.id, 10);
      expect(deces.autopsieRealisee, true);
      expect(deces.resultatsAutopsie, 'Métastases confirmées');
      expect(deces.mesuresPreventives, contains('femelles'));
    });

    test('toMap() génère le bon format', () {
      final dateDeces = DateTime(2024, 5, 10, 14, 30);
      final deces = Deces(
        id: 3,
        lapinId: 7,
        dateDeces: dateDeces,
        ageAuDecesJours: 180,
        cause: 'accident',
        circonstancesDetailees: 'Chute de la cage',
        autopsieRealisee: true,
        resultatsAutopsie: 'Fracture cervicale',
        mesuresPreventives: 'Vérifier les fermetures des cages',
      );

      final map = deces.toMap();

      expect(map['id'], 3);
      expect(map['lapin_id'], 7);
      expect(map['date_deces'], dateDeces.toIso8601String());
      expect(map['age_au_deces_jours'], 180);
      expect(map['cause'], 'accident');
      expect(map['circonstances_detaillees'], 'Chute de la cage');
      expect(map['autopsie_realisee'], 1); // SQLite bool = 1
      expect(map['resultats_autopsie'], 'Fracture cervicale');
      expect(map['mesures_preventives'], 'Vérifier les fermetures des cages');
    });

    test('toMap() convertit autopsieRealisee false en 0', () {
      final deces = Deces(
        lapinId: 1,
        dateDeces: DateTime.now(),
        ageAuDecesJours: 100,
        cause: 'naturel',
        circonstancesDetailees: 'Vieillesse',
        autopsieRealisee: false,
      );

      final map = deces.toMap();

      expect(map['autopsie_realisee'], 0);
    });

    test('fromMap() crée un objet correct', () {
      final map = {
        'id': 15,
        'lapin_id': 8,
        'date_deces': '2024-07-25T10:00:00.000',
        'age_au_deces_jours': 420,
        'cause': 'mise_bas',
        'circonstances_detaillees': 'Complication lors de la mise bas',
        'autopsie_realisee': 1,
        'resultats_autopsie': 'Hémorragie interne',
        'mesures_preventives': 'Surveiller les mises bas difficiles',
      };

      final deces = Deces.fromMap(map);

      expect(deces.id, 15);
      expect(deces.lapinId, 8);
      expect(deces.dateDeces.year, 2024);
      expect(deces.dateDeces.month, 7);
      expect(deces.dateDeces.day, 25);
      expect(deces.ageAuDecesJours, 420);
      expect(deces.cause, 'mise_bas');
      expect(deces.circonstancesDetailees, 'Complication lors de la mise bas');
      expect(deces.autopsieRealisee, true);
      expect(deces.resultatsAutopsie, 'Hémorragie interne');
      expect(deces.mesuresPreventives, 'Surveiller les mises bas difficiles');
    });

    test('fromMap() gère les valeurs nulles optionnelles', () {
      final map = {
        'id': 1,
        'lapin_id': 2,
        'date_deces': '2024-01-01T00:00:00.000',
        'age_au_deces_jours': 90,
        'cause': 'inconnu',
        'circonstances_detaillees': 'Trouvé mort',
        'autopsie_realisee': 0,
        'resultats_autopsie': null,
        'mesures_preventives': null,
      };

      final deces = Deces.fromMap(map);

      expect(deces.autopsieRealisee, false);
      expect(deces.resultatsAutopsie, isNull);
      expect(deces.mesuresPreventives, isNull);
    });

    test('copyWith() crée une copie avec modifications', () {
      final original = Deces(
        id: 1,
        lapinId: 5,
        dateDeces: DateTime(2024, 1, 1),
        ageAuDecesJours: 200,
        cause: 'maladie',
        circonstancesDetailees: 'Initiale',
        autopsieRealisee: false,
      );

      final copie = original.copyWith(
        cause: 'accident',
        circonstancesDetailees: 'Modifié',
        autopsieRealisee: true,
        resultatsAutopsie: 'Nouveaux résultats',
      );

      expect(copie.id, 1); // Non modifié
      expect(copie.lapinId, 5); // Non modifié
      expect(copie.cause, 'accident'); // Modifié
      expect(copie.circonstancesDetailees, 'Modifié'); // Modifié
      expect(copie.autopsieRealisee, true); // Modifié
      expect(copie.resultatsAutopsie, 'Nouveaux résultats'); // Ajouté
      expect(original.cause, 'maladie'); // L'original n'est pas modifié
    });

    test('toString() retourne une représentation lisible', () {
      final deces = Deces(
        id: 5,
        lapinId: 10,
        dateDeces: DateTime(2024, 8, 15),
        ageAuDecesJours: 300,
        cause: 'naturel',
        circonstancesDetailees: 'Mort de vieillesse',
      );

      final str = deces.toString();

      expect(str, contains('id: 5'));
      expect(str, contains('lapinId: 10'));
      expect(str, contains('cause: naturel'));
    });
  });

  group('CauseDeces Tests', () {
    test('values contient toutes les causes possibles', () {
      expect(CauseDeces.values, contains('maladie'));
      expect(CauseDeces.values, contains('accident'));
      expect(CauseDeces.values, contains('mise_bas'));
      expect(CauseDeces.values, contains('naturel'));
      expect(CauseDeces.values, contains('euthanasie'));
      expect(CauseDeces.values, contains('inconnu'));
      expect(CauseDeces.values.length, 6);
    });

    test('Constantes statiques correspondent aux valeurs', () {
      expect(CauseDeces.maladie, 'maladie');
      expect(CauseDeces.accident, 'accident');
      expect(CauseDeces.miseBas, 'mise_bas');
      expect(CauseDeces.naturel, 'naturel');
      expect(CauseDeces.euthanasie, 'euthanasie');
      expect(CauseDeces.inconnu, 'inconnu');
    });

    test('getLabel() retourne le libellé correct', () {
      expect(CauseDeces.getLabel('maladie'), 'Maladie');
      expect(CauseDeces.getLabel('accident'), 'Accident');
      expect(CauseDeces.getLabel('mise_bas'), 'Mise bas difficile');
      expect(CauseDeces.getLabel('naturel'), 'Mort naturelle');
      expect(CauseDeces.getLabel('euthanasie'), 'Euthanasie');
      expect(CauseDeces.getLabel('inconnu'), 'Cause inconnue');
    });

    test('getLabel() retourne la valeur brute pour cause inconnue', () {
      expect(CauseDeces.getLabel('autre_cause'), 'autre_cause');
      expect(CauseDeces.getLabel('custom'), 'custom');
    });
  });

  group('Scénarios d\'utilisation des décès', () {
    test('Filtrer les décès par cause', () {
      final deces = [
        Deces(
          lapinId: 1,
          dateDeces: DateTime(2024, 1, 1),
          ageAuDecesJours: 100,
          cause: 'maladie',
          circonstancesDetailees: 'A',
        ),
        Deces(
          lapinId: 2,
          dateDeces: DateTime(2024, 2, 1),
          ageAuDecesJours: 200,
          cause: 'accident',
          circonstancesDetailees: 'B',
        ),
        Deces(
          lapinId: 3,
          dateDeces: DateTime(2024, 3, 1),
          ageAuDecesJours: 150,
          cause: 'maladie',
          circonstancesDetailees: 'C',
        ),
      ];

      final maladies = deces.where((d) => d.cause == 'maladie').toList();

      expect(maladies.length, 2);
      expect(maladies.map((d) => d.lapinId).toList(), [1, 3]);
    });

    test('Calculer l\'âge moyen au décès', () {
      final deces = [
        Deces(
          lapinId: 1,
          dateDeces: DateTime(2024, 1, 1),
          ageAuDecesJours: 365,
          cause: 'naturel',
          circonstancesDetailees: 'A',
        ),
        Deces(
          lapinId: 2,
          dateDeces: DateTime(2024, 2, 1),
          ageAuDecesJours: 730,
          cause: 'naturel',
          circonstancesDetailees: 'B',
        ),
        Deces(
          lapinId: 3,
          dateDeces: DateTime(2024, 3, 1),
          ageAuDecesJours: 548,
          cause: 'maladie',
          circonstancesDetailees: 'C',
        ),
      ];

      final ageMoyen =
          deces.map((d) => d.ageAuDecesJours).reduce((a, b) => a + b) /
              deces.length;

      expect(ageMoyen, closeTo(547.67, 0.1));
    });

    test('Filtrer les décès par période', () {
      final deces = [
        Deces(
          lapinId: 1,
          dateDeces: DateTime(2024, 1, 15),
          ageAuDecesJours: 100,
          cause: 'maladie',
          circonstancesDetailees: 'A',
        ),
        Deces(
          lapinId: 2,
          dateDeces: DateTime(2024, 3, 20),
          ageAuDecesJours: 200,
          cause: 'accident',
          circonstancesDetailees: 'B',
        ),
        Deces(
          lapinId: 3,
          dateDeces: DateTime(2024, 6, 1),
          ageAuDecesJours: 150,
          cause: 'naturel',
          circonstancesDetailees: 'C',
        ),
      ];

      final debut = DateTime(2024, 2, 1);
      final fin = DateTime(2024, 5, 1);

      final decesDansPeriode = deces
          .where((d) =>
              d.dateDeces.isAfter(debut) && d.dateDeces.isBefore(fin))
          .toList();

      expect(decesDansPeriode.length, 1);
      expect(decesDansPeriode.first.lapinId, 2);
    });

    test('Compter les autopsies réalisées', () {
      final deces = [
        Deces(
          lapinId: 1,
          dateDeces: DateTime.now(),
          ageAuDecesJours: 100,
          cause: 'maladie',
          circonstancesDetailees: 'A',
          autopsieRealisee: true,
        ),
        Deces(
          lapinId: 2,
          dateDeces: DateTime.now(),
          ageAuDecesJours: 200,
          cause: 'accident',
          circonstancesDetailees: 'B',
          autopsieRealisee: false,
        ),
        Deces(
          lapinId: 3,
          dateDeces: DateTime.now(),
          ageAuDecesJours: 150,
          cause: 'maladie',
          circonstancesDetailees: 'C',
          autopsieRealisee: true,
        ),
      ];

      final nbAutopsies = deces.where((d) => d.autopsieRealisee).length;

      expect(nbAutopsies, 2);
    });

    test('Statistiques par cause de décès', () {
      final deces = [
        Deces(
            lapinId: 1,
            dateDeces: DateTime.now(),
            ageAuDecesJours: 100,
            cause: 'maladie',
            circonstancesDetailees: 'A'),
        Deces(
            lapinId: 2,
            dateDeces: DateTime.now(),
            ageAuDecesJours: 200,
            cause: 'maladie',
            circonstancesDetailees: 'B'),
        Deces(
            lapinId: 3,
            dateDeces: DateTime.now(),
            ageAuDecesJours: 150,
            cause: 'accident',
            circonstancesDetailees: 'C'),
        Deces(
            lapinId: 4,
            dateDeces: DateTime.now(),
            ageAuDecesJours: 300,
            cause: 'naturel',
            circonstancesDetailees: 'D'),
      ];

      final stats = <String, int>{};
      for (final d in deces) {
        stats[d.cause] = (stats[d.cause] ?? 0) + 1;
      }

      expect(stats['maladie'], 2);
      expect(stats['accident'], 1);
      expect(stats['naturel'], 1);
    });
  });
}
