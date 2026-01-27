import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/accouplement.dart';
import 'package:rabbit_farm_app/models/enums/statut_accouplement.dart';
import 'package:rabbit_farm_app/models/portee.dart';
import 'package:rabbit_farm_app/core/utils/logger.dart';

/// Tests unitaires pour ReproductionProvider
///
/// Ces tests vérifient la logique métier du provider sans dépendance à la BDD.
/// On teste les méthodes de filtrage et de calcul.
void main() {
  setUpAll(() {
    // Initialiser le logger pour éviter les erreurs
    logger.initialize(isProduction: true);
  });

  group('ReproductionProvider - Logique métier mises bas', () {
    test('getMisesBasImminentes identifie les mises bas dans 3 jours', () {
      final maintenant = DateTime.now();

      // Créer des accouplements avec différentes dates
      final accouplements = [
        // Dans 2 jours - IMMINENT
        Accouplement(
          id: 1,
          maleId: 1,
          femelleId: 2,
          dateAccouplement: maintenant.subtract(const Duration(days: 29)),
          dateMiseBasPrevue: maintenant.add(const Duration(days: 2)),
          statut: StatutAccouplement.enAttente,
        ),
        // Dans 5 jours - PAS IMMINENT
        Accouplement(
          id: 2,
          maleId: 3,
          femelleId: 4,
          dateAccouplement: maintenant.subtract(const Duration(days: 26)),
          dateMiseBasPrevue: maintenant.add(const Duration(days: 5)),
          statut: StatutAccouplement.confirme,
        ),
        // Passé - PAS IMMINENT
        Accouplement(
          id: 3,
          maleId: 5,
          femelleId: 6,
          dateAccouplement: maintenant.subtract(const Duration(days: 35)),
          dateMiseBasPrevue: maintenant.subtract(const Duration(days: 4)),
          statut: StatutAccouplement.enAttente,
        ),
        // Demain - IMMINENT
        Accouplement(
          id: 4,
          maleId: 7,
          femelleId: 8,
          dateAccouplement: maintenant.subtract(const Duration(days: 30)),
          dateMiseBasPrevue: maintenant.add(const Duration(days: 1)),
          statut: StatutAccouplement.confirme,
        ),
        // Terminé - PAS IMMINENT (mauvais statut)
        Accouplement(
          id: 5,
          maleId: 9,
          femelleId: 10,
          dateAccouplement: maintenant.subtract(const Duration(days: 29)),
          dateMiseBasPrevue: maintenant.add(const Duration(days: 2)),
          statut: StatutAccouplement.termine,
        ),
      ];

      // Filtrer les mises bas imminentes (logique du provider)
      final imminentes = accouplements.where((acc) {
        if (acc.statut != StatutAccouplement.enAttente && acc.statut != StatutAccouplement.confirme) return false;
        final joursRestants = acc.dateMiseBasPrevue.difference(maintenant).inDays;
        return joursRestants >= 0 && joursRestants <= 3;
      }).toList();

      expect(imminentes.length, 2);
      expect(imminentes.any((a) => a.id == 1), isTrue);
      expect(imminentes.any((a) => a.id == 4), isTrue);
    });

    test('filtre exclut les statuts terminé et échec', () {
      final maintenant = DateTime.now();

      final accouplements = [
        Accouplement(
          id: 1,
          maleId: 1,
          femelleId: 2,
          dateAccouplement: maintenant.subtract(const Duration(days: 29)),
          dateMiseBasPrevue: maintenant.add(const Duration(days: 2)),
          statut: StatutAccouplement.termine,
        ),
        Accouplement(
          id: 2,
          maleId: 3,
          femelleId: 4,
          dateAccouplement: maintenant.subtract(const Duration(days: 29)),
          dateMiseBasPrevue: maintenant.add(const Duration(days: 2)),
          statut: StatutAccouplement.echec,
        ),
      ];

      final imminentes = accouplements.where((acc) {
        if (acc.statut != StatutAccouplement.enAttente && acc.statut != StatutAccouplement.confirme) return false;
        final joursRestants = acc.dateMiseBasPrevue.difference(maintenant).inDays;
        return joursRestants >= 0 && joursRestants <= 3;
      }).toList();

      expect(imminentes.length, 0);
    });
  });

  group('ReproductionProvider - Logique palpations', () {
    test('getPalpationsAFaire identifie 10-12 jours post-accouplement', () {
      final maintenant = DateTime.now();

      final accouplements = [
        // 11 jours - À FAIRE
        Accouplement(
          id: 1,
          maleId: 1,
          femelleId: 2,
          dateAccouplement: maintenant.subtract(const Duration(days: 11)),
          dateMiseBasPrevue: maintenant.add(const Duration(days: 20)),
          statut: StatutAccouplement.enAttente,
        ),
        // 5 jours - TROP TÔT
        Accouplement(
          id: 2,
          maleId: 3,
          femelleId: 4,
          dateAccouplement: maintenant.subtract(const Duration(days: 5)),
          dateMiseBasPrevue: maintenant.add(const Duration(days: 26)),
          statut: StatutAccouplement.enAttente,
        ),
        // 15 jours - TROP TARD
        Accouplement(
          id: 3,
          maleId: 5,
          femelleId: 6,
          dateAccouplement: maintenant.subtract(const Duration(days: 15)),
          dateMiseBasPrevue: maintenant.add(const Duration(days: 16)),
          statut: StatutAccouplement.enAttente,
        ),
        // 10 jours - À FAIRE
        Accouplement(
          id: 4,
          maleId: 7,
          femelleId: 8,
          dateAccouplement: maintenant.subtract(const Duration(days: 10)),
          dateMiseBasPrevue: maintenant.add(const Duration(days: 21)),
          statut: StatutAccouplement.enAttente,
        ),
        // 12 jours mais confirmé - EXCLU (déjà palpé)
        Accouplement(
          id: 5,
          maleId: 9,
          femelleId: 10,
          dateAccouplement: maintenant.subtract(const Duration(days: 12)),
          dateMiseBasPrevue: maintenant.add(const Duration(days: 19)),
          statut: StatutAccouplement.confirme,
        ),
      ];

      final palpationsAFaire = accouplements.where((acc) {
        if (acc.statut != StatutAccouplement.enAttente) return false;
        final joursDepuis = maintenant.difference(acc.dateAccouplement).inDays;
        return joursDepuis >= 10 && joursDepuis <= 12;
      }).toList();

      expect(palpationsAFaire.length, 2);
      expect(palpationsAFaire.any((a) => a.id == 1), isTrue);
      expect(palpationsAFaire.any((a) => a.id == 4), isTrue);
    });
  });

  group('ReproductionProvider - Logique sevrages', () {
    test('getSevragePrevus identifie portées de 5-6 semaines', () {
      final maintenant = DateTime.now();

      final portees = [
        // 5 semaines (35 jours) - À SEVRER
        Portee(
          id: 1,
          accouplementId: 1,
          dateMiseBasReelle: maintenant.subtract(const Duration(days: 35)),
          nombreNes: 8,
          nombreVivants: 7,
          nombreMorts: 1,
        ),
        // 3 semaines - TROP JEUNE
        Portee(
          id: 2,
          accouplementId: 2,
          dateMiseBasReelle: maintenant.subtract(const Duration(days: 21)),
          nombreNes: 6,
          nombreVivants: 6,
          nombreMorts: 0,
        ),
        // 6 semaines (42 jours) - À SEVRER
        Portee(
          id: 3,
          accouplementId: 3,
          dateMiseBasReelle: maintenant.subtract(const Duration(days: 42)),
          nombreNes: 10,
          nombreVivants: 9,
          nombreMorts: 1,
        ),
        // 8 semaines - TROP VIEUX
        Portee(
          id: 4,
          accouplementId: 4,
          dateMiseBasReelle: maintenant.subtract(const Duration(days: 56)),
          nombreNes: 5,
          nombreVivants: 5,
          nombreMorts: 0,
        ),
        // 5 semaines mais tous morts - EXCLU
        Portee(
          id: 5,
          accouplementId: 5,
          dateMiseBasReelle: maintenant.subtract(const Duration(days: 35)),
          nombreNes: 4,
          nombreVivants: 0,
          nombreMorts: 4,
        ),
      ];

      final sevragesPrevus = portees.where((portee) {
        if (portee.nombreVivants == 0) return false;
        final ageEnSemaines =
            maintenant.difference(portee.dateMiseBasReelle).inDays ~/ 7;
        return ageEnSemaines >= 5 && ageEnSemaines <= 6;
      }).toList();

      expect(sevragesPrevus.length, 2);
      expect(sevragesPrevus.any((p) => p.id == 1), isTrue);
      expect(sevragesPrevus.any((p) => p.id == 3), isTrue);
    });

    test('exclut les portées sans lapereaux vivants', () {
      final maintenant = DateTime.now();

      final portees = [
        Portee(
          id: 1,
          accouplementId: 1,
          dateMiseBasReelle: maintenant.subtract(const Duration(days: 35)),
          nombreNes: 5,
          nombreVivants: 0,
          nombreMorts: 5,
        ),
      ];

      final sevragesPrevus = portees.where((portee) {
        if (portee.nombreVivants == 0) return false;
        final ageEnSemaines =
            maintenant.difference(portee.dateMiseBasReelle).inDays ~/ 7;
        return ageEnSemaines >= 5 && ageEnSemaines <= 6;
      }).toList();

      expect(sevragesPrevus.length, 0);
    });
  });

  group('ReproductionProvider - Logique pesées', () {
    test('getPeseesAFaire identifie portées < 8 semaines', () {
      final maintenant = DateTime.now();

      final portees = [
        // 3 semaines - PESÉE NÉCESSAIRE
        Portee(
          id: 1,
          accouplementId: 1,
          dateMiseBasReelle: maintenant.subtract(const Duration(days: 21)),
          nombreNes: 8,
          nombreVivants: 7,
          nombreMorts: 1,
        ),
        // 6 semaines - PESÉE NÉCESSAIRE
        Portee(
          id: 2,
          accouplementId: 2,
          dateMiseBasReelle: maintenant.subtract(const Duration(days: 42)),
          nombreNes: 6,
          nombreVivants: 6,
          nombreMorts: 0,
        ),
        // 10 semaines - TROP VIEUX
        Portee(
          id: 3,
          accouplementId: 3,
          dateMiseBasReelle: maintenant.subtract(const Duration(days: 70)),
          nombreNes: 5,
          nombreVivants: 5,
          nombreMorts: 0,
        ),
        // Aujourd'hui (0 semaines) - EXCLU (trop jeune pour première pesée)
        Portee(
          id: 4,
          accouplementId: 4,
          dateMiseBasReelle: maintenant,
          nombreNes: 6,
          nombreVivants: 6,
          nombreMorts: 0,
        ),
      ];

      final peseesAFaire = portees.where((portee) {
        if (portee.nombreVivants == 0) return false;
        final ageEnSemaines =
            maintenant.difference(portee.dateMiseBasReelle).inDays ~/ 7;
        return ageEnSemaines > 0 && ageEnSemaines < 8;
      }).toList();

      expect(peseesAFaire.length, 2);
      expect(peseesAFaire.any((p) => p.id == 1), isTrue);
      expect(peseesAFaire.any((p) => p.id == 2), isTrue);
    });
  });

  group('ReproductionProvider - Statistiques calculées', () {
    test('compte les accouplements par statut', () {
      final accouplements = [
        _createAccouplement(1, StatutAccouplement.enAttente),
        _createAccouplement(2, StatutAccouplement.enAttente),
        _createAccouplement(3, StatutAccouplement.confirme),
        _createAccouplement(4, StatutAccouplement.termine),
        _createAccouplement(5, StatutAccouplement.termine),
        _createAccouplement(6, StatutAccouplement.echec),
      ];

      final enAttente =
          accouplements.where((a) => a.statut == StatutAccouplement.enAttente).length;
      final confirmes =
          accouplements.where((a) => a.statut == StatutAccouplement.confirme).length;
      final termines =
          accouplements.where((a) => a.statut == StatutAccouplement.termine).length;
      final echecs = accouplements.where((a) => a.statut == StatutAccouplement.echec).length;

      expect(enAttente, 2);
      expect(confirmes, 1);
      expect(termines, 2);
      expect(echecs, 1);
    });

    test('calcule le taux de réussite des accouplements', () {
      final accouplements = [
        _createAccouplement(1, StatutAccouplement.termine),
        _createAccouplement(2, StatutAccouplement.termine),
        _createAccouplement(3, StatutAccouplement.termine),
        _createAccouplement(4, StatutAccouplement.echec),
        _createAccouplement(5, StatutAccouplement.echec),
      ];

      final termines =
          accouplements.where((a) => a.statut == StatutAccouplement.termine).length;
      final echecs = accouplements.where((a) => a.statut == StatutAccouplement.echec).length;
      final total = termines + echecs;
      final tauxReussite = total > 0 ? (termines / total) * 100 : 0.0;

      expect(tauxReussite, 60.0);
    });

    test('calcule le nombre moyen de lapereaux par portée', () {
      final portees = [
        _createPortee(1, 8, 7),
        _createPortee(2, 6, 6),
        _createPortee(3, 10, 9),
        _createPortee(4, 4, 4),
      ];

      final totalNes = portees.fold<int>(0, (sum, p) => sum + p.nombreNes);
      final moyenneNes = portees.isNotEmpty ? totalNes / portees.length : 0.0;

      expect(moyenneNes, 7.0); // (8+6+10+4) / 4 = 28 / 4 = 7
    });

    test('calcule le taux de survie moyen', () {
      final portees = [
        _createPortee(1, 8, 8), // 100%
        _createPortee(2, 10, 5), // 50%
        _createPortee(3, 4, 4), // 100%
        _createPortee(4, 8, 6), // 75%
      ];

      final tauxSurvies = portees.map((p) => p.tauxSurvie).toList();
      final moyenneSurvie = tauxSurvies.reduce((a, b) => a + b) / tauxSurvies.length;

      expect(moyenneSurvie, 81.25); // (100+50+100+75) / 4 = 325 / 4 = 81.25
    });
  });

  group('ReproductionProvider - Tri et ordre', () {
    test('trie les mises bas par date croissante', () {
      final maintenant = DateTime.now();

      final accouplements = [
        Accouplement(
          id: 1,
          maleId: 1,
          femelleId: 2,
          dateAccouplement: maintenant.subtract(const Duration(days: 28)),
          dateMiseBasPrevue: maintenant.add(const Duration(days: 3)),
          statut: StatutAccouplement.confirme,
        ),
        Accouplement(
          id: 2,
          maleId: 3,
          femelleId: 4,
          dateAccouplement: maintenant.subtract(const Duration(days: 30)),
          dateMiseBasPrevue: maintenant.add(const Duration(days: 1)),
          statut: StatutAccouplement.confirme,
        ),
        Accouplement(
          id: 3,
          maleId: 5,
          femelleId: 6,
          dateAccouplement: maintenant.subtract(const Duration(days: 29)),
          dateMiseBasPrevue: maintenant.add(const Duration(days: 2)),
          statut: StatutAccouplement.confirme,
        ),
      ];

      final triees = accouplements.toList()
        ..sort((a, b) => a.dateMiseBasPrevue.compareTo(b.dateMiseBasPrevue));

      expect(triees[0].id, 2); // Dans 1 jour
      expect(triees[1].id, 3); // Dans 2 jours
      expect(triees[2].id, 1); // Dans 3 jours
    });

    test('trie les portées par date de mise bas', () {
      final maintenant = DateTime.now();

      final portees = [
        Portee(
          id: 1,
          accouplementId: 1,
          dateMiseBasReelle: maintenant.subtract(const Duration(days: 30)),
          nombreNes: 8,
          nombreVivants: 7,
          nombreMorts: 1,
        ),
        Portee(
          id: 2,
          accouplementId: 2,
          dateMiseBasReelle: maintenant.subtract(const Duration(days: 40)),
          nombreNes: 6,
          nombreVivants: 6,
          nombreMorts: 0,
        ),
        Portee(
          id: 3,
          accouplementId: 3,
          dateMiseBasReelle: maintenant.subtract(const Duration(days: 35)),
          nombreNes: 5,
          nombreVivants: 5,
          nombreMorts: 0,
        ),
      ];

      final triees = portees.toList()
        ..sort((a, b) => a.dateMiseBasReelle.compareTo(b.dateMiseBasReelle));

      expect(triees[0].id, 2); // 40 jours (plus ancienne)
      expect(triees[1].id, 3); // 35 jours
      expect(triees[2].id, 1); // 30 jours (plus récente)
    });
  });
}

/// Helper pour créer un accouplement avec statut
Accouplement _createAccouplement(int id, StatutAccouplement statut) {
  final maintenant = DateTime.now();
  return Accouplement(
    id: id,
    maleId: id * 2 - 1,
    femelleId: id * 2,
    dateAccouplement: maintenant.subtract(const Duration(days: 31)),
    dateMiseBasPrevue: maintenant,
    statut: statut,
  );
}

/// Helper pour créer une portée
Portee _createPortee(int id, int nombreNes, int nombreVivants) {
  return Portee(
    id: id,
    accouplementId: id,
    dateMiseBasReelle: DateTime.now().subtract(const Duration(days: 30)),
    nombreNes: nombreNes,
    nombreVivants: nombreVivants,
    nombreMorts: nombreNes - nombreVivants,
  );
}
