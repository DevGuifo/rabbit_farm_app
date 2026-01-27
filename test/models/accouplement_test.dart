import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/accouplement.dart';
import 'package:rabbit_farm_app/models/enums/statut_accouplement.dart';

/// Tests unitaires pour le modèle Accouplement
///
/// Ces tests vérifient :
/// - La création d'instances
/// - La conversion toMap/fromMap
/// - Les propriétés calculées (datePalpation, datePreparationNid, joursAvantMiseBas)
/// - La méthode statique calculerDateMiseBasPrevue
/// - La méthode copyWith
void main() {
  group('Accouplement - Création', () {
    test('crée un accouplement avec tous les champs requis', () {
      final dateAccouplement = DateTime(2025, 1, 15);
      final dateMiseBasPrevue = DateTime(2025, 2, 15);

      final accouplement = Accouplement(
        maleId: 1,
        femelleId: 2,
        dateAccouplement: dateAccouplement,
        dateMiseBasPrevue: dateMiseBasPrevue,
      );

      expect(accouplement.id, isNull);
      expect(accouplement.maleId, 1);
      expect(accouplement.femelleId, 2);
      expect(accouplement.dateAccouplement, dateAccouplement);
      expect(accouplement.dateMiseBasPrevue, dateMiseBasPrevue);
      expect(accouplement.statut, StatutAccouplement.enAttente); // Valeur par défaut
      expect(accouplement.notes, isNull);
    });

    test('crée un accouplement avec ID et notes', () {
      final accouplement = Accouplement(
        id: 42,
        maleId: 5,
        femelleId: 10,
        dateAccouplement: DateTime(2025, 3, 1),
        dateMiseBasPrevue: DateTime(2025, 4, 1),
        statut: StatutAccouplement.confirme,
        notes: 'Accouplement réussi',
      );

      expect(accouplement.id, 42);
      expect(accouplement.statut, StatutAccouplement.confirme);
      expect(accouplement.notes, 'Accouplement réussi');
    });
  });

  group('Accouplement - calculerDateMiseBasPrevue', () {
    test('calcule 31 jours après la date d\'accouplement', () {
      final dateAccouplement = DateTime(2025, 1, 1);
      final dateMiseBasPrevue =
          Accouplement.calculerDateMiseBasPrevue(dateAccouplement);

      expect(dateMiseBasPrevue, DateTime(2025, 2, 1));
    });

    test('gère le passage de mois correctement', () {
      final dateAccouplement = DateTime(2025, 1, 15);
      final dateMiseBasPrevue =
          Accouplement.calculerDateMiseBasPrevue(dateAccouplement);

      // 15 janvier + 31 jours = 15 février
      expect(dateMiseBasPrevue, DateTime(2025, 2, 15));
    });

    test('gère le passage d\'année correctement', () {
      final dateAccouplement = DateTime(2024, 12, 10);
      final dateMiseBasPrevue =
          Accouplement.calculerDateMiseBasPrevue(dateAccouplement);

      // 10 décembre + 31 jours = 10 janvier 2025
      expect(dateMiseBasPrevue, DateTime(2025, 1, 10));
    });
  });

  group('Accouplement - Propriétés calculées', () {
    late Accouplement accouplement;

    setUp(() {
      accouplement = Accouplement(
        id: 1,
        maleId: 1,
        femelleId: 2,
        dateAccouplement: DateTime(2025, 1, 15),
        dateMiseBasPrevue: DateTime(2025, 2, 15),
      );
    });

    test('datePalpation retourne 11 jours après l\'accouplement', () {
      // 15 janvier + 11 jours = 26 janvier
      expect(accouplement.datePalpation, DateTime(2025, 1, 26));
    });

    test('datePreparationNid retourne 3 jours avant la mise bas', () {
      // 15 février - 3 jours = 12 février
      expect(accouplement.datePreparationNid, DateTime(2025, 2, 12));
    });

    test('joursAvantMiseBas calcule correctement les jours restants', () {
      // Ce test utilise DateTime.now(), donc le résultat varie
      // On vérifie juste que la valeur est cohérente
      final joursRestants = accouplement.joursAvantMiseBas;
      final difference =
          accouplement.dateMiseBasPrevue.difference(DateTime.now()).inDays;
      expect(joursRestants, difference);
    });

    test('estPasse retourne true pour une date passée', () {
      final accouplementPasse = Accouplement(
        maleId: 1,
        femelleId: 2,
        dateAccouplement: DateTime(2020, 1, 1),
        dateMiseBasPrevue: DateTime(2020, 2, 1),
      );

      expect(accouplementPasse.estPasse, isTrue);
    });

    test('estPasse retourne false pour une date future', () {
      final accouplementFutur = Accouplement(
        maleId: 1,
        femelleId: 2,
        dateAccouplement: DateTime.now().add(const Duration(days: 10)),
        dateMiseBasPrevue: DateTime.now().add(const Duration(days: 41)),
      );

      expect(accouplementFutur.estPasse, isFalse);
    });
  });

  group('Accouplement - toMap', () {
    test('convertit correctement tous les champs', () {
      final dateAccouplement = DateTime(2025, 1, 15, 10, 30);
      final dateMiseBasPrevue = DateTime(2025, 2, 15, 10, 30);

      final accouplement = Accouplement(
        id: 5,
        maleId: 1,
        femelleId: 2,
        dateAccouplement: dateAccouplement,
        dateMiseBasPrevue: dateMiseBasPrevue,
        statut: StatutAccouplement.confirme,
        notes: 'Notes test',
      );

      final map = accouplement.toMap();

      expect(map['id'], 5);
      expect(map['male_id'], 1);
      expect(map['femelle_id'], 2);
      expect(map['date_accouplement'], dateAccouplement.toIso8601String());
      expect(map['date_mise_bas_prevue'], dateMiseBasPrevue.toIso8601String());
      expect(map['statut'], 'confirme');
      expect(map['notes'], 'Notes test');
    });

    test('inclut null pour id non défini', () {
      final accouplement = Accouplement(
        maleId: 1,
        femelleId: 2,
        dateAccouplement: DateTime(2025, 1, 1),
        dateMiseBasPrevue: DateTime(2025, 2, 1),
      );

      final map = accouplement.toMap();

      expect(map['id'], isNull);
    });

    test('inclut null pour notes non définies', () {
      final accouplement = Accouplement(
        maleId: 1,
        femelleId: 2,
        dateAccouplement: DateTime(2025, 1, 1),
        dateMiseBasPrevue: DateTime(2025, 2, 1),
      );

      final map = accouplement.toMap();

      expect(map['notes'], isNull);
    });
  });

  group('Accouplement - fromMap', () {
    test('crée depuis un Map complet', () {
      final map = {
        'id': 10,
        'male_id': 3,
        'femelle_id': 7,
        'date_accouplement': '2025-01-20T14:30:00.000',
        'date_mise_bas_prevue': '2025-02-20T14:30:00.000',
        'statut': 'termine',
        'notes': 'Portée de 8 lapereaux',
      };

      final accouplement = Accouplement.fromMap(map);

      expect(accouplement.id, 10);
      expect(accouplement.maleId, 3);
      expect(accouplement.femelleId, 7);
      expect(accouplement.dateAccouplement.year, 2025);
      expect(accouplement.dateAccouplement.month, 1);
      expect(accouplement.dateAccouplement.day, 20);
      expect(accouplement.statut, 'termine');
      expect(accouplement.notes, 'Portée de 8 lapereaux');
    });

    test('gère statut null avec valeur par défaut', () {
      final map = {
        'id': 1,
        'male_id': 1,
        'femelle_id': 2,
        'date_accouplement': '2025-01-01T00:00:00.000',
        'date_mise_bas_prevue': '2025-02-01T00:00:00.000',
        'statut': null,
        'notes': null,
      };

      final accouplement = Accouplement.fromMap(map);

      expect(accouplement.statut, StatutAccouplement.enAttente);
      expect(accouplement.notes, isNull);
    });

    test('gère notes absentes', () {
      final map = {
        'id': 1,
        'male_id': 1,
        'femelle_id': 2,
        'date_accouplement': '2025-01-01T00:00:00.000',
        'date_mise_bas_prevue': '2025-02-01T00:00:00.000',
        'statut': 'en_attente', // String pour tester fromMap conversion
        // notes non défini
      };

      final accouplement = Accouplement.fromMap(map);

      expect(accouplement.notes, isNull);
    });
  });

  group('Accouplement - copyWith', () {
    late Accouplement original;

    setUp(() {
      original = Accouplement(
        id: 1,
        maleId: 1,
        femelleId: 2,
        dateAccouplement: DateTime(2025, 1, 15),
        dateMiseBasPrevue: DateTime(2025, 2, 15),
        statut: StatutAccouplement.enAttente,
        notes: 'Original',
      );
    });

    test('copie sans modifications', () {
      final copie = original.copyWith();

      expect(copie.id, original.id);
      expect(copie.maleId, original.maleId);
      expect(copie.femelleId, original.femelleId);
      expect(copie.dateAccouplement, original.dateAccouplement);
      expect(copie.dateMiseBasPrevue, original.dateMiseBasPrevue);
      expect(copie.statut, original.statut);
      expect(copie.notes, original.notes);
    });

    test('modifie le statut uniquement', () {
      final copie = original.copyWith(statut: StatutAccouplement.confirme);

      expect(copie.statut, StatutAccouplement.confirme);
      expect(copie.maleId, original.maleId); // Non modifié
    });

    test('modifie les notes uniquement', () {
      final copie = original.copyWith(notes: 'Nouvelles notes');

      expect(copie.notes, 'Nouvelles notes');
      expect(copie.statut, original.statut); // Non modifié
    });

    test('modifie plusieurs champs', () {
      final nouvelleDateMiseBas = DateTime(2025, 2, 20);
      final copie = original.copyWith(
        statut: StatutAccouplement.termine,
        dateMiseBasPrevue: nouvelleDateMiseBas,
        notes: 'Terminé avec succès',
      );

      expect(copie.statut, StatutAccouplement.termine);
      expect(copie.dateMiseBasPrevue, nouvelleDateMiseBas);
      expect(copie.notes, 'Terminé avec succès');
      expect(copie.maleId, original.maleId); // Non modifié
    });
  });

  group('Accouplement - toString', () {
    test('retourne une représentation lisible', () {
      final accouplement = Accouplement(
        id: 1,
        maleId: 5,
        femelleId: 10,
        dateAccouplement: DateTime(2025, 1, 15),
        dateMiseBasPrevue: DateTime(2025, 2, 15),
        statut: StatutAccouplement.enAttente,
      );

      final str = accouplement.toString();

      expect(str, contains('Accouplement'));
      expect(str, contains('id: 1'));
      expect(str, contains('male: 5'));
      expect(str, contains('femelle: 10'));
      expect(str, contains('statut: en_attente'));
    });
  });

  group('Accouplement - Aller-retour toMap/fromMap', () {
    test('préserve toutes les données', () {
      final original = Accouplement(
        id: 99,
        maleId: 42,
        femelleId: 84,
        dateAccouplement: DateTime(2025, 6, 15, 14, 30),
        dateMiseBasPrevue: DateTime(2025, 7, 16, 14, 30),
        statut: StatutAccouplement.confirme,
        notes: 'Notes de test avec caractères spéciaux: éàü',
      );

      final map = original.toMap();
      final restaure = Accouplement.fromMap(map);

      expect(restaure.id, original.id);
      expect(restaure.maleId, original.maleId);
      expect(restaure.femelleId, original.femelleId);
      expect(restaure.dateAccouplement, original.dateAccouplement);
      expect(restaure.dateMiseBasPrevue, original.dateMiseBasPrevue);
      expect(restaure.statut, original.statut);
      expect(restaure.notes, original.notes);
    });
  });

  group('Accouplement - Statuts valides', () {
    test('accepte tous les statuts valides', () {
      final statuts = StatutAccouplement.values;

      for (final statut in statuts) {
        final accouplement = Accouplement(
          maleId: 1,
          femelleId: 2,
          dateAccouplement: DateTime.now(),
          dateMiseBasPrevue: DateTime.now().add(const Duration(days: 31)),
          statut: statut,
        );

        expect(accouplement.statut, statut);
      }
    });
  });
}
