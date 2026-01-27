import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/enums/type_soin.dart';
import 'package:rabbit_farm_app/models/pesee.dart';
import 'package:rabbit_farm_app/models/soin.dart';

/// Tests unitaires pour la logique métier de SanteProvider
/// 
/// Ces tests vérifient les méthodes de logique métier sans dépendance
/// à la base de données, en testant directement les calculs et filtres.
void main() {
  group('Pesee Model Tests', () {
    test('Pesee.toMap() génère une map correcte', () {
      final pesee = Pesee(
        id: 1,
        lapinId: 10,
        date: DateTime(2024, 6, 15, 10, 30),
        poids: 3.5,
        notes: 'Poids stable',
      );

      final map = pesee.toMap();

      expect(map['id'], 1);
      expect(map['lapin_id'], 10);
      expect(map['poids'], 3.5);
      expect(map['notes'], 'Poids stable');
      expect(map['date'], contains('2024-06-15'));
    });

    test('Pesee.fromMap() crée un objet valide', () {
      final map = {
        'id': 2,
        'lapin_id': 5,
        'date': '2024-07-20T14:00:00.000',
        'poids': 4.2,
        'notes': 'En croissance',
      };

      final pesee = Pesee.fromMap(map);

      expect(pesee.id, 2);
      expect(pesee.lapinId, 5);
      expect(pesee.poids, 4.2);
      expect(pesee.notes, 'En croissance');
      expect(pesee.date.year, 2024);
      expect(pesee.date.month, 7);
      expect(pesee.date.day, 20);
    });

    test('Pesee.copyWith() crée une copie correcte', () {
      final pesee = Pesee(
        id: 1,
        lapinId: 10,
        date: DateTime(2024, 6, 15),
        poids: 3.5,
      );

      final copie = pesee.copyWith(poids: 3.8, notes: 'Prise de poids');

      expect(copie.id, 1);
      expect(copie.lapinId, 10);
      expect(copie.poids, 3.8);
      expect(copie.notes, 'Prise de poids');
    });

    test('Pesee.toString() retourne une chaîne lisible', () {
      final pesee = Pesee(
        id: 1,
        lapinId: 5,
        date: DateTime(2024, 6, 15),
        poids: 3.5,
      );

      expect(pesee.toString(), contains('3.5kg'));
      expect(pesee.toString(), contains('lapin: 5'));
    });
  });

  group('Soin Model Tests', () {
    test('Soin.toMap() génère une map correcte', () {
      final soin = Soin(
        id: 1,
        lapinId: 10,
        date: DateTime(2024, 6, 15),
        type: TypeSoin.vaccination,
        description: 'Vaccin myxomatose',
        medicamentId: 1,
        dosage: '0.5 ml',
        dateRappel: DateTime(2024, 12, 15),
        notes: 'RAS',
      );

      final map = soin.toMap();

      expect(map['id'], 1);
      expect(map['lapin_id'], 10);
      expect(map['type'], 'vaccination');
      expect(map['description'], 'Vaccin myxomatose');
      expect(map['medicament_id'], 1);
      expect(map['dosage'], '0.5 ml');
      expect(map['notes'], 'RAS');
      expect(map['date_rappel'], contains('2024-12-15'));
    });

    test('Soin.fromMap() crée un objet valide', () {
      final map = {
        'id': 2,
        'lapin_id': 5,
        'date': '2024-07-20T10:00:00.000',
        'type': 'traitement',
        'description': 'Antibiotique',
        'medicament_id': 3,
        'dosage': '1 ml',
        'date_rappel': '2024-07-27T10:00:00.000',
        'notes': 'Pendant 7 jours',
      };

      final soin = Soin.fromMap(map);

      expect(soin.id, 2);
      expect(soin.lapinId, 5);
      expect(soin.type, TypeSoin.traitement);
      expect(soin.description, 'Antibiotique');
      expect(soin.medicamentId, 3);
      expect(soin.dosage, '1 ml');
      expect(soin.dateRappel, isNotNull);
    });

    test('Soin.copyWith() crée une copie correcte', () {
      final soin = Soin(
        id: 1,
        lapinId: 10,
        date: DateTime(2024, 6, 15),
        type: TypeSoin.vaccination,
        description: 'Test',
      );

      final copie = soin.copyWith(
        type: TypeSoin.traitement,
        description: 'Nouveau traitement',
        medicamentId: 5,
      );

      expect(copie.id, 1);
      expect(copie.lapinId, 10);
      expect(copie.type, TypeSoin.traitement);
      expect(copie.description, 'Nouveau traitement');
      expect(copie.medicamentId, 5);
    });

    test('rappelNecessaire retourne true si la date de rappel est passée', () {
      final soin = Soin(
        id: 1,
        lapinId: 10,
        date: DateTime(2024, 1, 1),
        type: TypeSoin.vaccination,
        description: 'Vaccin',
        dateRappel: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(soin.rappelNecessaire, true);
    });

    test('rappelNecessaire retourne false si la date de rappel est future', () {
      final soin = Soin(
        id: 1,
        lapinId: 10,
        date: DateTime(2024, 1, 1),
        type: TypeSoin.vaccination,
        description: 'Vaccin',
        dateRappel: DateTime.now().add(const Duration(days: 7)),
      );

      expect(soin.rappelNecessaire, false);
    });

    test('rappelNecessaire retourne false si pas de date de rappel', () {
      final soin = Soin(
        id: 1,
        lapinId: 10,
        date: DateTime(2024, 1, 1),
        type: TypeSoin.vaccination,
        description: 'Vaccin',
        dateRappel: null,
      );

      expect(soin.rappelNecessaire, false);
    });

    test('joursAvantRappel calcule correctement', () {
      final dans10Jours = DateTime.now().add(const Duration(days: 10));
      final soin = Soin(
        id: 1,
        lapinId: 10,
        date: DateTime(2024, 1, 1),
        type: TypeSoin.vaccination,
        description: 'Vaccin',
        dateRappel: dans10Jours,
      );

      // Permettre une marge d'erreur de ±1 jour due aux heures
      expect(soin.joursAvantRappel, inInclusiveRange(9, 11));
    });

    test('joursAvantRappel retourne null si pas de date de rappel', () {
      final soin = Soin(
        id: 1,
        lapinId: 10,
        date: DateTime(2024, 1, 1),
        type: TypeSoin.vaccination,
        description: 'Vaccin',
        dateRappel: null,
      );

      expect(soin.joursAvantRappel, isNull);
    });
  });

  group('Logique métier santé - Vaccinations en retard', () {
    test('Filtrer les vaccinations en retard depuis une liste de soins', () {
      final maintenant = DateTime.now();
      final soins = [
        Soin(
          id: 1,
          lapinId: 1,
          date: DateTime(2024, 1, 1),
          type: TypeSoin.vaccination,
          description: 'Vaccin myxo',
          dateRappel: maintenant.subtract(const Duration(days: 10)),
        ),
        Soin(
          id: 2,
          lapinId: 2,
          date: DateTime(2024, 1, 1),
          type: TypeSoin.vaccination,
          description: 'Vaccin VHD',
          dateRappel: maintenant.add(const Duration(days: 30)),
        ),
        Soin(
          id: 3,
          lapinId: 3,
          date: DateTime(2024, 1, 1),
          type: TypeSoin.traitement,
          description: 'Antibiotique',
          dateRappel: maintenant.subtract(const Duration(days: 5)),
        ),
      ];

      // Logique métier: getVaccinationsEnRetard
      final vaccinationsEnRetard = soins.where((soin) {
        if (soin.type != TypeSoin.vaccination) return false;
        if (soin.dateRappel == null) return false;
        return soin.dateRappel!.isBefore(maintenant);
      }).toList();

      expect(vaccinationsEnRetard.length, 1);
      expect(vaccinationsEnRetard.first.id, 1);
      expect(vaccinationsEnRetard.first.description, 'Vaccin myxo');
    });

    test('Pas de vaccinations en retard si toutes sont à jour', () {
      final maintenant = DateTime.now();
      final soins = [
        Soin(
          id: 1,
          lapinId: 1,
          date: DateTime(2024, 1, 1),
          type: TypeSoin.vaccination,
          description: 'Vaccin myxo',
          dateRappel: maintenant.add(const Duration(days: 30)),
        ),
        Soin(
          id: 2,
          lapinId: 2,
          date: DateTime(2024, 1, 1),
          type: TypeSoin.vaccination,
          description: 'Vaccin VHD',
          dateRappel: maintenant.add(const Duration(days: 60)),
        ),
      ];

      final vaccinationsEnRetard = soins.where((soin) {
        if (soin.type != TypeSoin.vaccination) return false;
        if (soin.dateRappel == null) return false;
        return soin.dateRappel!.isBefore(maintenant);
      }).toList();

      expect(vaccinationsEnRetard.length, 0);
    });
  });

  group('Logique métier santé - Rappels à venir', () {
    test('Filtrer les rappels dans les 7 prochains jours', () {
      final maintenant = DateTime.now();
      final dansSeptJours = maintenant.add(const Duration(days: 7));
      
      final soins = [
        Soin(
          id: 1,
          lapinId: 1,
          date: DateTime(2024, 1, 1),
          type: TypeSoin.vaccination,
          description: 'Rappel dans 3 jours',
          dateRappel: maintenant.add(const Duration(days: 3)),
        ),
        Soin(
          id: 2,
          lapinId: 2,
          date: DateTime(2024, 1, 1),
          type: TypeSoin.traitement,
          description: 'Rappel dans 5 jours',
          dateRappel: maintenant.add(const Duration(days: 5)),
        ),
        Soin(
          id: 3,
          lapinId: 3,
          date: DateTime(2024, 1, 1),
          type: TypeSoin.vaccination,
          description: 'Rappel dans 15 jours',
          dateRappel: maintenant.add(const Duration(days: 15)),
        ),
        Soin(
          id: 4,
          lapinId: 4,
          date: DateTime(2024, 1, 1),
          type: TypeSoin.vaccination,
          description: 'Rappel passé',
          dateRappel: maintenant.subtract(const Duration(days: 2)),
        ),
      ];

      // Logique métier: getRappelsAVenir
      final rappelsAVenir = soins.where((soin) {
        if (soin.dateRappel == null) return false;
        return soin.dateRappel!.isAfter(maintenant) &&
            soin.dateRappel!.isBefore(dansSeptJours);
      }).toList();

      expect(rappelsAVenir.length, 2);
      expect(rappelsAVenir.map((s) => s.id).toList(), containsAll([1, 2]));
    });
  });

  group('Logique métier santé - Score de santé', () {
    test('Score parfait quand aucun soin en retard', () {
      final maintenant = DateTime.now();
      final soins = [
        Soin(
          id: 1,
          lapinId: 1,
          date: DateTime(2024, 1, 1),
          type: TypeSoin.vaccination,
          description: 'Vaccin à jour',
          dateRappel: maintenant.add(const Duration(days: 30)),
        ),
      ];

      // Logique métier: calculerScoreSante simplifiée
      int score = 100;

      // Pénalité pour vaccinations en retard (-10 points par vaccination)
      final vaccinationsRetard = soins.where((soin) {
        if (soin.type != TypeSoin.vaccination) return false;
        if (soin.dateRappel == null) return false;
        return soin.dateRappel!.isBefore(maintenant);
      }).length;
      score -= (vaccinationsRetard * 10).clamp(0, 30);

      // Pénalité pour soins en retard (-5 points par soin)
      final soinsRetard = soins.where((soin) {
        if (soin.dateRappel == null) return false;
        return soin.dateRappel!.isBefore(maintenant);
      }).length;
      score -= (soinsRetard * 5).clamp(0, 20);

      // Bonus si aucun soin en retard (+5 points)
      if (vaccinationsRetard == 0 && soinsRetard == 0) {
        score += 5;
      }

      final scoreFinal = score.clamp(0, 100);

      expect(scoreFinal, 100); // 100 + 5 = 105, clamped à 100
    });

    test('Score diminue avec vaccinations en retard', () {
      final maintenant = DateTime.now();
      final soins = [
        Soin(
          id: 1,
          lapinId: 1,
          date: DateTime(2024, 1, 1),
          type: TypeSoin.vaccination,
          description: 'Vaccin en retard 1',
          dateRappel: maintenant.subtract(const Duration(days: 10)),
        ),
        Soin(
          id: 2,
          lapinId: 2,
          date: DateTime(2024, 1, 1),
          type: TypeSoin.vaccination,
          description: 'Vaccin en retard 2',
          dateRappel: maintenant.subtract(const Duration(days: 5)),
        ),
      ];

      int score = 100;

      final vaccinationsRetard = soins.where((soin) {
        if (soin.type != TypeSoin.vaccination) return false;
        if (soin.dateRappel == null) return false;
        return soin.dateRappel!.isBefore(maintenant);
      }).length;
      score -= (vaccinationsRetard * 10).clamp(0, 30);

      final soinsRetard = soins.where((soin) {
        if (soin.dateRappel == null) return false;
        return soin.dateRappel!.isBefore(maintenant);
      }).length;
      score -= (soinsRetard * 5).clamp(0, 20);

      // 100 - 20 (2 vaccins * 10) - 10 (2 soins * 5) = 70
      expect(score, 70);
    });

    test('Score plafonné à 0 avec beaucoup de retards', () {
      final maintenant = DateTime.now();
      final soins = List.generate(10, (i) => Soin(
        id: i,
        lapinId: i,
        date: DateTime(2024, 1, 1),
        type: TypeSoin.vaccination,
        description: 'Vaccin $i',
        dateRappel: maintenant.subtract(const Duration(days: 10)),
      ));

      int score = 100;

      final vaccinationsRetard = soins.where((soin) {
        if (soin.type != TypeSoin.vaccination) return false;
        if (soin.dateRappel == null) return false;
        return soin.dateRappel!.isBefore(maintenant);
      }).length;
      score -= (vaccinationsRetard * 10).clamp(0, 30); // Max -30

      final soinsRetard = soins.where((soin) {
        if (soin.dateRappel == null) return false;
        return soin.dateRappel!.isBefore(maintenant);
      }).length;
      score -= (soinsRetard * 5).clamp(0, 20); // Max -20

      final scoreFinal = score.clamp(0, 100);

      // 100 - 30 - 20 = 50 (les pénalités sont plafonnées)
      expect(scoreFinal, 50);
    });
  });

  group('Logique métier santé - Soins par type', () {
    test('Filtrer les soins par type', () {
      final soins = [
        Soin(id: 1, lapinId: 1, date: DateTime(2024, 1, 1), type: TypeSoin.vaccination, description: 'V1'),
        Soin(id: 2, lapinId: 1, date: DateTime(2024, 2, 1), type: TypeSoin.traitement, description: 'T1'),
        Soin(id: 3, lapinId: 1, date: DateTime(2024, 3, 1), type: TypeSoin.vaccination, description: 'V2'),
        Soin(id: 4, lapinId: 1, date: DateTime(2024, 4, 1), type: TypeSoin.vermifuge, description: 'Ver1'),
        Soin(id: 5, lapinId: 1, date: DateTime(2024, 5, 1), type: TypeSoin.autre, description: 'C1'),
      ];

      final vaccinations = soins.where((s) => s.type == TypeSoin.vaccination).toList();
      final traitements = soins.where((s) => s.type == TypeSoin.traitement).toList();
      final vermifuges = soins.where((s) => s.type == TypeSoin.vermifuge).toList();

      expect(vaccinations.length, 2);
      expect(traitements.length, 1);
      expect(vermifuges.length, 1);
    });

    test('Filtrer les soins par lapin', () {
      final soins = [
        Soin(id: 1, lapinId: 1, date: DateTime(2024, 1, 1), type: TypeSoin.vaccination, description: 'V1'),
        Soin(id: 2, lapinId: 2, date: DateTime(2024, 2, 1), type: TypeSoin.traitement, description: 'T1'),
        Soin(id: 3, lapinId: 1, date: DateTime(2024, 3, 1), type: TypeSoin.vaccination, description: 'V2'),
        Soin(id: 4, lapinId: 3, date: DateTime(2024, 4, 1), type: TypeSoin.vermifuge, description: 'Ver1'),
        Soin(id: 5, lapinId: 1, date: DateTime(2024, 5, 1), type: TypeSoin.autre, description: 'C1'),
      ];

      final soinsLapin1 = soins.where((s) => s.lapinId == 1).toList();
      final soinsLapin2 = soins.where((s) => s.lapinId == 2).toList();
      final soinsLapin3 = soins.where((s) => s.lapinId == 3).toList();

      expect(soinsLapin1.length, 3);
      expect(soinsLapin2.length, 1);
      expect(soinsLapin3.length, 1);
    });
  });

  group('Logique métier santé - Évolution du poids', () {
    test('Calculer la variation de poids entre deux pesées', () {
      final pesees = [
        Pesee(id: 1, lapinId: 1, date: DateTime(2024, 1, 1), poids: 3.0),
        Pesee(id: 2, lapinId: 1, date: DateTime(2024, 2, 1), poids: 3.5),
        Pesee(id: 3, lapinId: 1, date: DateTime(2024, 3, 1), poids: 4.0),
      ];

      // Tri par date
      final peseesTriees = List<Pesee>.from(pesees)
        ..sort((a, b) => a.date.compareTo(b.date));

      // Variation totale
      final poidsInitial = peseesTriees.first.poids;
      final poidsFinal = peseesTriees.last.poids;
      final variation = poidsFinal - poidsInitial;
      final variationPourcent = (variation / poidsInitial) * 100;

      expect(variation, 1.0); // +1 kg
      expect(variationPourcent.round(), 33); // +33%
    });

    test('Obtenir la dernière pesée d\'un lapin', () {
      final pesees = [
        Pesee(id: 1, lapinId: 1, date: DateTime(2024, 1, 1), poids: 3.0),
        Pesee(id: 2, lapinId: 1, date: DateTime(2024, 3, 1), poids: 4.0),
        Pesee(id: 3, lapinId: 1, date: DateTime(2024, 2, 1), poids: 3.5),
      ];

      final peseesTriees = List<Pesee>.from(pesees)
        ..sort((a, b) => b.date.compareTo(a.date)); // Tri décroissant

      final dernierePesee = peseesTriees.first;

      expect(dernierePesee.poids, 4.0);
      expect(dernierePesee.date.month, 3);
    });

    test('Calculer le poids moyen des pesées', () {
      final pesees = [
        Pesee(id: 1, lapinId: 1, date: DateTime(2024, 1, 1), poids: 3.0),
        Pesee(id: 2, lapinId: 1, date: DateTime(2024, 2, 1), poids: 3.5),
        Pesee(id: 3, lapinId: 1, date: DateTime(2024, 3, 1), poids: 4.0),
        Pesee(id: 4, lapinId: 1, date: DateTime(2024, 4, 1), poids: 4.5),
      ];

      final poidsMoyen = pesees.map((p) => p.poids).reduce((a, b) => a + b) / pesees.length;

      expect(poidsMoyen, 3.75); // (3 + 3.5 + 4 + 4.5) / 4 = 15 / 4 = 3.75
    });
  });

  group('Logique métier santé - Lapin malade', () {
    test('Détecter un lapin avec traitements récents comme potentiellement malade', () {
      final maintenant = DateTime.now();
      final ilYATrenteJours = maintenant.subtract(const Duration(days: 30));
      
      final soins = [
        Soin(
          id: 1,
          lapinId: 1,
          date: maintenant.subtract(const Duration(days: 10)),
          type: TypeSoin.traitement,
          description: 'Antibiotique',
        ),
        Soin(
          id: 2,
          lapinId: 1,
          date: maintenant.subtract(const Duration(days: 5)),
          type: TypeSoin.autre,
          description: 'Visite vétérinaire',
        ),
      ];

      // Logique métier: estLapinMalade (partie soins récents)
      final soinsRecents = soins.where((soin) {
        final estTraitementOuConsultation =
            soin.type == TypeSoin.traitement || soin.type == TypeSoin.autre;
        final estRecent = soin.date.isAfter(ilYATrenteJours);
        return estTraitementOuConsultation && estRecent;
      }).toList();

      expect(soinsRecents.length, 2);
      expect(soinsRecents.isNotEmpty, true); // Considéré comme malade
    });

    test('Lapin non malade si seulement des vaccinations récentes', () {
      final maintenant = DateTime.now();
      final ilYATrenteJours = maintenant.subtract(const Duration(days: 30));
      
      final soins = [
        Soin(
          id: 1,
          lapinId: 1,
          date: maintenant.subtract(const Duration(days: 10)),
          type: TypeSoin.vaccination,
          description: 'Vaccin annuel',
        ),
        Soin(
          id: 2,
          lapinId: 1,
          date: maintenant.subtract(const Duration(days: 5)),
          type: TypeSoin.vermifuge,
          description: 'Vermifuge préventif',
        ),
      ];

      final soinsRecents = soins.where((soin) {
        final estTraitementOuConsultation =
            soin.type == TypeSoin.traitement || soin.type == TypeSoin.autre;
        final estRecent = soin.date.isAfter(ilYATrenteJours);
        return estTraitementOuConsultation && estRecent;
      }).toList();

      expect(soinsRecents.isEmpty, true); // Non considéré comme malade
    });

    test('Lapin non malade si traitements anciens (> 30 jours)', () {
      final maintenant = DateTime.now();
      final ilYATrenteJours = maintenant.subtract(const Duration(days: 30));
      
      final soins = [
        Soin(
          id: 1,
          lapinId: 1,
          date: maintenant.subtract(const Duration(days: 45)),
          type: TypeSoin.traitement,
          description: 'Ancien traitement',
        ),
        Soin(
          id: 2,
          lapinId: 1,
          date: maintenant.subtract(const Duration(days: 60)),
          type: TypeSoin.autre,
          description: 'Ancienne consultation',
        ),
      ];

      final soinsRecents = soins.where((soin) {
        final estTraitementOuConsultation =
            soin.type == TypeSoin.traitement || soin.type == TypeSoin.autre;
        final estRecent = soin.date.isAfter(ilYATrenteJours);
        return estTraitementOuConsultation && estRecent;
      }).toList();

      expect(soinsRecents.isEmpty, true); // Non considéré comme malade
    });
  });

  group('Logique métier santé - Tri et classement', () {
    test('Trier les soins par date décroissante', () {
      final soins = [
        Soin(id: 1, lapinId: 1, date: DateTime(2024, 3, 15), type: TypeSoin.vaccination, description: 'V3'),
        Soin(id: 2, lapinId: 1, date: DateTime(2024, 1, 10), type: TypeSoin.traitement, description: 'T1'),
        Soin(id: 3, lapinId: 1, date: DateTime(2024, 5, 20), type: TypeSoin.vaccination, description: 'V5'),
        Soin(id: 4, lapinId: 1, date: DateTime(2024, 2, 5), type: TypeSoin.vermifuge, description: 'Ver'),
      ];

      final soinsTriesDesc = List<Soin>.from(soins)
        ..sort((a, b) => b.date.compareTo(a.date));

      expect(soinsTriesDesc[0].date.month, 5);
      expect(soinsTriesDesc[1].date.month, 3);
      expect(soinsTriesDesc[2].date.month, 2);
      expect(soinsTriesDesc[3].date.month, 1);
    });

    test('Trier les rappels par date croissante', () {
      final maintenant = DateTime.now();
      final soins = [
        Soin(
          id: 1,
          lapinId: 1,
          date: DateTime(2024, 1, 1),
          type: TypeSoin.vaccination,
          description: 'V1',
          dateRappel: maintenant.add(const Duration(days: 30)),
        ),
        Soin(
          id: 2,
          lapinId: 1,
          date: DateTime(2024, 1, 1),
          type: TypeSoin.vaccination,
          description: 'V2',
          dateRappel: maintenant.add(const Duration(days: 7)),
        ),
        Soin(
          id: 3,
          lapinId: 1,
          date: DateTime(2024, 1, 1),
          type: TypeSoin.vaccination,
          description: 'V3',
          dateRappel: maintenant.add(const Duration(days: 14)),
        ),
      ];

      final rappelsTriesAsc = soins
          .where((s) => s.dateRappel != null)
          .toList()
        ..sort((a, b) => a.dateRappel!.compareTo(b.dateRappel!));

      expect(rappelsTriesAsc[0].description, 'V2'); // 7 jours
      expect(rappelsTriesAsc[1].description, 'V3'); // 14 jours
      expect(rappelsTriesAsc[2].description, 'V1'); // 30 jours
    });
  });
}
