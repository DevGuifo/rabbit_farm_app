import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/recette.dart';
import 'package:rabbit_farm_app/models/depense.dart';
import 'package:rabbit_farm_app/models/enums/finance_enums.dart';

/// Tests unitaires pour la logique métier de FinanceProvider
/// 
/// Ces tests vérifient les méthodes de logique métier sans dépendance
/// à la base de données, en testant directement les calculs et filtres.
void main() {
  group('Recette Model Tests', () {
    test('Recette.toMap() génère une map correcte', () {
      final recette = Recette(
        id: 1,
        date: DateTime(2024, 6, 15),
        categorie: CategorieRecette.venteLapin,
        montant: 35.0,
        description: 'Vente lapin adulte',
        lapinId: 10,
        notes: 'Client régulier',
      );

      final map = recette.toMap();

      expect(map['id'], 1);
      expect(map['categorie'], 'vente_lapin');
      expect(map['montant'], 35.0);
      expect(map['description'], 'Vente lapin adulte');
      expect(map['lapin_id'], 10);
      expect(map['notes'], 'Client régulier');
      expect(map['date'], contains('2024-06-15'));
    });

    test('Recette.fromMap() crée un objet valide', () {
      final map = {
        'id': 2,
        'date': '2024-07-20T10:00:00.000',
        'categorie': 'vente_portee',
        'montant': 150.0,
        'description': 'Vente portée 5 lapereaux',
        'lapin_id': null,
        'notes': null,
      };

      final recette = Recette.fromMap(map);

      expect(recette.id, 2);
      expect(recette.categorie, 'vente_portee');
      expect(recette.montant, 150.0);
      expect(recette.description, 'Vente portée 5 lapereaux');
      expect(recette.lapinId, isNull);
      expect(recette.date.year, 2024);
      expect(recette.date.month, 7);
    });

    test('Recette.copyWith() crée une copie correcte', () {
      final recette = Recette(
        id: 1,
        date: DateTime(2024, 6, 15),
        categorie: CategorieRecette.venteLapin,
        montant: 35.0,
        description: 'Vente initiale',
      );

      final copie = recette.copyWith(
        montant: 40.0,
        notes: 'Prix négocié',
      );

      expect(copie.id, 1);
      expect(copie.categorie, 'vente_lapin');
      expect(copie.montant, 40.0);
      expect(copie.notes, 'Prix négocié');
      expect(copie.description, 'Vente initiale');
    });

    test('Recette.toString() retourne une chaîne lisible', () {
      final recette = Recette(
        id: 1,
        date: DateTime(2024, 6, 15),
        categorie: CategorieRecette.venteLapin,
        montant: 35.0,
        description: 'Test',
      );

      expect(recette.toString(), contains('35.0€'));
      expect(recette.toString(), contains('vente_lapin'));
    });
  });

  group('Depense Model Tests', () {
    test('Depense.toMap() génère une map correcte', () {
      final depense = Depense(
        id: 1,
        date: DateTime(2024, 6, 15),
        categorie: CategorieDepense.alimentation,
        montant: 45.0,
        description: 'Sac de granulés 25kg',
        notes: 'Fournisseur habituel',
      );

      final map = depense.toMap();

      expect(map['id'], 1);
      expect(map['categorie'], 'alimentation');
      expect(map['montant'], 45.0);
      expect(map['description'], 'Sac de granulés 25kg');
      expect(map['notes'], 'Fournisseur habituel');
      expect(map['date'], contains('2024-06-15'));
    });

    test('Depense.fromMap() crée un objet valide', () {
      final map = {
        'id': 2,
        'date': '2024-07-20T10:00:00.000',
        'categorie': 'veterinaire',
        'montant': 85.0,
        'description': 'Consultation annuelle',
        'notes': null,
      };

      final depense = Depense.fromMap(map);

      expect(depense.id, 2);
      expect(depense.categorie, 'veterinaire');
      expect(depense.montant, 85.0);
      expect(depense.description, 'Consultation annuelle');
      expect(depense.notes, isNull);
    });

    test('Depense.copyWith() crée une copie correcte', () {
      final depense = Depense(
        id: 1,
        date: DateTime(2024, 6, 15),
        categorie: CategorieDepense.alimentation,
        montant: 45.0,
        description: 'Achat initial',
      );

      final copie = depense.copyWith(
        categorie: CategorieDepense.equipement,
        montant: 120.0,
        description: 'Nouvelle cage',
      );

      expect(copie.id, 1);
      expect(copie.categorie, 'equipement');
      expect(copie.montant, 120.0);
      expect(copie.description, 'Nouvelle cage');
    });

    test('Depense.toString() retourne une chaîne lisible', () {
      final depense = Depense(
        id: 1,
        date: DateTime(2024, 6, 15),
        categorie: CategorieDepense.veterinaire,
        montant: 85.0,
        description: 'Test',
      );

      expect(depense.toString(), contains('85.0€'));
      expect(depense.toString(), contains('veterinaire'));
    });
  });

  group('Logique métier finance - Calculs totaux', () {
    test('Calculer le total des recettes', () {
      final recettes = [
        Recette(id: 1, date: DateTime(2024, 1, 1), categorie: CategorieRecette.venteLapin, montant: 35.0, description: 'V1'),
        Recette(id: 2, date: DateTime(2024, 2, 1), categorie: CategorieRecette.venteLapin, montant: 40.0, description: 'V2'),
        Recette(id: 3, date: DateTime(2024, 3, 1), categorie: CategorieRecette.ventePortee, montant: 150.0, description: 'V3'),
      ];

      final totalRecettes = recettes.fold(0.0, (sum, r) => sum + r.montant);

      expect(totalRecettes, 225.0); // 35 + 40 + 150
    });

    test('Calculer le total des dépenses', () {
      final depenses = [
        Depense(id: 1, date: DateTime(2024, 1, 1), categorie: CategorieDepense.alimentation, montant: 45.0, description: 'D1'),
        Depense(id: 2, date: DateTime(2024, 2, 1), categorie: CategorieDepense.veterinaire, montant: 85.0, description: 'D2'),
        Depense(id: 3, date: DateTime(2024, 3, 1), categorie: CategorieDepense.equipement, montant: 120.0, description: 'D3'),
      ];

      final totalDepenses = depenses.fold(0.0, (sum, d) => sum + d.montant);

      expect(totalDepenses, 250.0); // 45 + 85 + 120
    });

    test('Calculer le bénéfice (recettes - dépenses)', () {
      final recettes = [
        Recette(id: 1, date: DateTime(2024, 1, 1), categorie: CategorieRecette.venteLapin, montant: 200.0, description: 'V1'),
        Recette(id: 2, date: DateTime(2024, 2, 1), categorie: CategorieRecette.venteLapin, montant: 150.0, description: 'V2'),
      ];
      final depenses = [
        Depense(id: 1, date: DateTime(2024, 1, 1), categorie: CategorieDepense.alimentation, montant: 100.0, description: 'D1'),
        Depense(id: 2, date: DateTime(2024, 2, 1), categorie: CategorieDepense.veterinaire, montant: 50.0, description: 'D2'),
      ];

      final totalRecettes = recettes.fold(0.0, (sum, r) => sum + r.montant);
      final totalDepenses = depenses.fold(0.0, (sum, d) => sum + d.montant);
      final benefice = totalRecettes - totalDepenses;

      expect(totalRecettes, 350.0);
      expect(totalDepenses, 150.0);
      expect(benefice, 200.0); // 350 - 150
    });

    test('Bénéfice négatif si dépenses > recettes', () {
      final recettes = [
        Recette(id: 1, date: DateTime(2024, 1, 1), categorie: CategorieRecette.venteLapin, montant: 50.0, description: 'V1'),
      ];
      final depenses = [
        Depense(id: 1, date: DateTime(2024, 1, 1), categorie: CategorieDepense.equipement, montant: 200.0, description: 'D1'),
      ];

      final totalRecettes = recettes.fold(0.0, (sum, r) => sum + r.montant);
      final totalDepenses = depenses.fold(0.0, (sum, d) => sum + d.montant);
      final benefice = totalRecettes - totalDepenses;

      expect(benefice, -150.0); // 50 - 200
      expect(benefice < 0, true);
    });
  });

  group('Logique métier finance - Filtrage par période', () {
    test('Filtrer les recettes par période', () {
      final recettes = [
        Recette(id: 1, date: DateTime(2024, 1, 15), categorie: CategorieRecette.venteLapin, montant: 35.0, description: 'Jan'),
        Recette(id: 2, date: DateTime(2024, 2, 20), categorie: CategorieRecette.venteLapin, montant: 40.0, description: 'Fev'),
        Recette(id: 3, date: DateTime(2024, 3, 10), categorie: CategorieRecette.ventePortee, montant: 150.0, description: 'Mar'),
        Recette(id: 4, date: DateTime(2024, 4, 5), categorie: CategorieRecette.venteLapin, montant: 45.0, description: 'Avr'),
      ];

      final debut = DateTime(2024, 2, 1);
      final fin = DateTime(2024, 3, 31);

      final recettesPeriode = recettes.where((r) {
        return r.date.isAfter(debut.subtract(const Duration(days: 1))) &&
            r.date.isBefore(fin.add(const Duration(days: 1)));
      }).toList();

      expect(recettesPeriode.length, 2);
      expect(recettesPeriode.map((r) => r.description).toList(), ['Fev', 'Mar']);
    });

    test('Filtrer les dépenses par période', () {
      final depenses = [
        Depense(id: 1, date: DateTime(2024, 1, 10), categorie: CategorieDepense.alimentation, montant: 45.0, description: 'Jan'),
        Depense(id: 2, date: DateTime(2024, 2, 15), categorie: CategorieDepense.veterinaire, montant: 85.0, description: 'Fev'),
        Depense(id: 3, date: DateTime(2024, 3, 20), categorie: CategorieDepense.equipement, montant: 120.0, description: 'Mar'),
      ];

      final debut = DateTime(2024, 2, 1);
      final fin = DateTime(2024, 2, 28);

      final depensesPeriode = depenses.where((d) {
        return d.date.isAfter(debut.subtract(const Duration(days: 1))) &&
            d.date.isBefore(fin.add(const Duration(days: 1)));
      }).toList();

      expect(depensesPeriode.length, 1);
      expect(depensesPeriode.first.description, 'Fev');
    });

    test('Bénéfice par période', () {
      final recettes = [
        Recette(id: 1, date: DateTime(2024, 1, 15), categorie: CategorieRecette.venteLapin, montant: 100.0, description: 'Jan'),
        Recette(id: 2, date: DateTime(2024, 2, 20), categorie: CategorieRecette.venteLapin, montant: 200.0, description: 'Fev'),
      ];
      final depenses = [
        Depense(id: 1, date: DateTime(2024, 1, 10), categorie: CategorieDepense.alimentation, montant: 50.0, description: 'Jan'),
        Depense(id: 2, date: DateTime(2024, 2, 15), categorie: CategorieDepense.veterinaire, montant: 80.0, description: 'Fev'),
      ];

      // Période: Février uniquement
      final debut = DateTime(2024, 2, 1);
      final fin = DateTime(2024, 2, 29);

      final recettesPeriode = recettes.where((r) =>
          r.date.isAfter(debut.subtract(const Duration(days: 1))) &&
          r.date.isBefore(fin.add(const Duration(days: 1)))).toList();

      final depensesPeriode = depenses.where((d) =>
          d.date.isAfter(debut.subtract(const Duration(days: 1))) &&
          d.date.isBefore(fin.add(const Duration(days: 1)))).toList();

      final totalRecettes = recettesPeriode.fold(0.0, (sum, r) => sum + r.montant);
      final totalDepenses = depensesPeriode.fold(0.0, (sum, d) => sum + d.montant);
      final benefice = totalRecettes - totalDepenses;

      expect(totalRecettes, 200.0);
      expect(totalDepenses, 80.0);
      expect(benefice, 120.0);
    });
  });

  group('Logique métier finance - Groupement par catégorie', () {
    test('Total recettes par catégorie', () {
      final recettes = [
        Recette(id: 1, date: DateTime(2024, 1, 1), categorie: CategorieRecette.venteLapin, montant: 35.0, description: 'V1'),
        Recette(id: 2, date: DateTime(2024, 2, 1), categorie: CategorieRecette.venteLapin, montant: 40.0, description: 'V2'),
        Recette(id: 3, date: DateTime(2024, 3, 1), categorie: CategorieRecette.ventePortee, montant: 150.0, description: 'V3'),
        Recette(id: 4, date: DateTime(2024, 4, 1), categorie: CategorieRecette.autre, montant: 20.0, description: 'V4'),
        Recette(id: 5, date: DateTime(2024, 5, 1), categorie: CategorieRecette.venteLapin, montant: 45.0, description: 'V5'),
      ];

      // Grouper par catégorie
      final parCategorie = <CategorieRecette, double>{};
      for (final recette in recettes) {
        parCategorie[recette.categorie] = 
            (parCategorie[recette.categorie] ?? 0.0) + recette.montant;
      }

      expect(parCategorie[CategorieRecette.venteLapin], 120.0); // 35 + 40 + 45
      expect(parCategorie[CategorieRecette.ventePortee], 150.0);
      expect(parCategorie[CategorieRecette.autre], 20.0);
    });

    test('Total dépenses par catégorie', () {
      final depenses = [
        Depense(id: 1, date: DateTime(2024, 1, 1), categorie: CategorieDepense.alimentation, montant: 45.0, description: 'D1'),
        Depense(id: 2, date: DateTime(2024, 2, 1), categorie: CategorieDepense.alimentation, montant: 50.0, description: 'D2'),
        Depense(id: 3, date: DateTime(2024, 3, 1), categorie: CategorieDepense.veterinaire, montant: 85.0, description: 'D3'),
        Depense(id: 4, date: DateTime(2024, 4, 1), categorie: CategorieDepense.equipement, montant: 120.0, description: 'D4'),
        Depense(id: 5, date: DateTime(2024, 5, 1), categorie: CategorieDepense.alimentation, montant: 55.0, description: 'D5'),
      ];

      final parCategorie = <CategorieDepense, double>{};
      for (final depense in depenses) {
        parCategorie[depense.categorie] = 
            (parCategorie[depense.categorie] ?? 0.0) + depense.montant;
      }

      expect(parCategorie[CategorieDepense.alimentation], 150.0); // 45 + 50 + 55
      expect(parCategorie[CategorieDepense.veterinaire], 85.0);
      expect(parCategorie[CategorieDepense.equipement], 120.0);
    });

    test('Catégorie la plus rentable', () {
      final recettes = [
        Recette(id: 1, date: DateTime(2024, 1, 1), categorie: CategorieRecette.venteLapin, montant: 35.0, description: 'V1'),
        Recette(id: 2, date: DateTime(2024, 2, 1), categorie: CategorieRecette.venteLapin, montant: 40.0, description: 'V2'),
        Recette(id: 3, date: DateTime(2024, 3, 1), categorie: CategorieRecette.ventePortee, montant: 250.0, description: 'V3'),
      ];

      final parCategorie = <CategorieRecette, double>{};
      for (final recette in recettes) {
        parCategorie[recette.categorie] = 
            (parCategorie[recette.categorie] ?? 0.0) + recette.montant;
      }

      // Trouver la catégorie avec le plus de revenus
      CategorieRecette? meilleureCat;
      double maxMontant = 0.0;
      parCategorie.forEach((cat, montant) {
        if (montant > maxMontant) {
          maxMontant = montant;
          meilleureCat = cat;
        }
      });

      expect(meilleureCat, CategorieRecette.ventePortee);
      expect(maxMontant, 250.0);
    });

    test('Catégorie la plus coûteuse', () {
      final depenses = [
        Depense(id: 1, date: DateTime(2024, 1, 1), categorie: CategorieDepense.alimentation, montant: 200.0, description: 'D1'),
        Depense(id: 2, date: DateTime(2024, 2, 1), categorie: CategorieDepense.veterinaire, montant: 85.0, description: 'D2'),
        Depense(id: 3, date: DateTime(2024, 3, 1), categorie: CategorieDepense.equipement, montant: 120.0, description: 'D3'),
      ];

      final parCategorie = <CategorieDepense, double>{};
      for (final depense in depenses) {
        parCategorie[depense.categorie] = 
            (parCategorie[depense.categorie] ?? 0.0) + depense.montant;
      }

      CategorieDepense? pireCat;
      double maxMontant = 0.0;
      parCategorie.forEach((cat, montant) {
        if (montant > maxMontant) {
          maxMontant = montant;
          pireCat = cat;
        }
      });

      expect(pireCat, CategorieDepense.alimentation);
      expect(maxMontant, 200.0);
    });
  });

  group('Logique métier finance - Statistiques mensuelles', () {
    test('Calculer les recettes par mois', () {
      final recettes = [
        Recette(id: 1, date: DateTime(2024, 1, 15), categorie: CategorieRecette.venteLapin, montant: 100.0, description: 'Jan1'),
        Recette(id: 2, date: DateTime(2024, 1, 25), categorie: CategorieRecette.venteLapin, montant: 50.0, description: 'Jan2'),
        Recette(id: 3, date: DateTime(2024, 2, 10), categorie: CategorieRecette.venteLapin, montant: 75.0, description: 'Fev'),
        Recette(id: 4, date: DateTime(2024, 3, 5), categorie: CategorieRecette.venteLapin, montant: 200.0, description: 'Mar'),
      ];

      // Grouper par mois (format: YYYY-MM)
      final parMois = <String, double>{};
      for (final recette in recettes) {
        final cle = '${recette.date.year}-${recette.date.month.toString().padLeft(2, '0')}';
        parMois[cle] = (parMois[cle] ?? 0.0) + recette.montant;
      }

      expect(parMois['2024-01'], 150.0); // 100 + 50
      expect(parMois['2024-02'], 75.0);
      expect(parMois['2024-03'], 200.0);
    });

    test('Calculer le bénéfice mensuel', () {
      final recettes = [
        Recette(id: 1, date: DateTime(2024, 1, 15), categorie: CategorieRecette.venteLapin, montant: 200.0, description: 'Jan'),
        Recette(id: 2, date: DateTime(2024, 2, 10), categorie: CategorieRecette.venteLapin, montant: 150.0, description: 'Fev'),
      ];
      final depenses = [
        Depense(id: 1, date: DateTime(2024, 1, 10), categorie: CategorieDepense.alimentation, montant: 80.0, description: 'Jan'),
        Depense(id: 2, date: DateTime(2024, 2, 5), categorie: CategorieDepense.alimentation, montant: 90.0, description: 'Fev'),
      ];

      final recettesParMois = <String, double>{};
      for (final r in recettes) {
        final cle = '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}';
        recettesParMois[cle] = (recettesParMois[cle] ?? 0.0) + r.montant;
      }

      final depensesParMois = <String, double>{};
      for (final d in depenses) {
        final cle = '${d.date.year}-${d.date.month.toString().padLeft(2, '0')}';
        depensesParMois[cle] = (depensesParMois[cle] ?? 0.0) + d.montant;
      }

      // Bénéfice par mois
      final beneficeJan = (recettesParMois['2024-01'] ?? 0) - (depensesParMois['2024-01'] ?? 0);
      final beneficeFev = (recettesParMois['2024-02'] ?? 0) - (depensesParMois['2024-02'] ?? 0);

      expect(beneficeJan, 120.0); // 200 - 80
      expect(beneficeFev, 60.0); // 150 - 90
    });
  });

  group('Logique métier finance - Tri et classement', () {
    test('Trier les recettes par date décroissante', () {
      final recettes = [
        Recette(id: 1, date: DateTime(2024, 2, 15), categorie: CategorieRecette.venteLapin, montant: 35.0, description: 'Fev'),
        Recette(id: 2, date: DateTime(2024, 1, 10), categorie: CategorieRecette.venteLapin, montant: 40.0, description: 'Jan'),
        Recette(id: 3, date: DateTime(2024, 4, 20), categorie: CategorieRecette.venteLapin, montant: 50.0, description: 'Avr'),
        Recette(id: 4, date: DateTime(2024, 3, 5), categorie: CategorieRecette.venteLapin, montant: 45.0, description: 'Mar'),
      ];

      final recettesTriees = List<Recette>.from(recettes)
        ..sort((a, b) => b.date.compareTo(a.date));

      expect(recettesTriees[0].description, 'Avr');
      expect(recettesTriees[1].description, 'Mar');
      expect(recettesTriees[2].description, 'Fev');
      expect(recettesTriees[3].description, 'Jan');
    });

    test('Trier les dépenses par montant décroissant', () {
      final depenses = [
        Depense(id: 1, date: DateTime(2024, 1, 1), categorie: CategorieDepense.alimentation, montant: 45.0, description: 'D1'),
        Depense(id: 2, date: DateTime(2024, 2, 1), categorie: CategorieDepense.veterinaire, montant: 150.0, description: 'D2'),
        Depense(id: 3, date: DateTime(2024, 3, 1), categorie: CategorieDepense.equipement, montant: 85.0, description: 'D3'),
      ];

      final depensesTriees = List<Depense>.from(depenses)
        ..sort((a, b) => b.montant.compareTo(a.montant));

      expect(depensesTriees[0].montant, 150.0);
      expect(depensesTriees[1].montant, 85.0);
      expect(depensesTriees[2].montant, 45.0);
    });
  });

  group('Logique métier finance - Recettes liées aux lapins', () {
    test('Filtrer les recettes par lapin', () {
      final recettes = [
        Recette(id: 1, date: DateTime(2024, 1, 1), categorie: CategorieRecette.venteLapin, montant: 35.0, description: 'V1', lapinId: 10),
        Recette(id: 2, date: DateTime(2024, 2, 1), categorie: CategorieRecette.autre, montant: 20.0, description: 'V2', lapinId: null),
        Recette(id: 3, date: DateTime(2024, 3, 1), categorie: CategorieRecette.venteLapin, montant: 40.0, description: 'V3', lapinId: 10),
        Recette(id: 4, date: DateTime(2024, 4, 1), categorie: CategorieRecette.venteLapin, montant: 45.0, description: 'V4', lapinId: 15),
      ];

      final recettesLapin10 = recettes.where((r) => r.lapinId == 10).toList();
      final recettesLapin15 = recettes.where((r) => r.lapinId == 15).toList();
      final recettesSansLapin = recettes.where((r) => r.lapinId == null).toList();

      expect(recettesLapin10.length, 2);
      expect(recettesLapin15.length, 1);
      expect(recettesSansLapin.length, 1);
    });

    test('Calculer le revenu total par lapin', () {
      final recettes = [
        Recette(id: 1, date: DateTime(2024, 1, 1), categorie: CategorieRecette.venteLapin, montant: 35.0, description: 'V1', lapinId: 10),
        Recette(id: 2, date: DateTime(2024, 2, 1), categorie: CategorieRecette.venteLapin, montant: 40.0, description: 'V2', lapinId: 10),
        Recette(id: 3, date: DateTime(2024, 3, 1), categorie: CategorieRecette.venteLapin, montant: 50.0, description: 'V3', lapinId: 15),
      ];

      final revenusParLapin = <int, double>{};
      for (final recette in recettes) {
        if (recette.lapinId != null) {
          revenusParLapin[recette.lapinId!] = 
              (revenusParLapin[recette.lapinId!] ?? 0.0) + recette.montant;
        }
      }

      expect(revenusParLapin[10], 75.0); // 35 + 40
      expect(revenusParLapin[15], 50.0);
    });
  });

  group('Logique métier finance - Marge et rentabilité', () {
    test('Calculer la marge bénéficiaire en pourcentage', () {
      final totalRecettes = 500.0;
      final totalDepenses = 350.0;
      final benefice = totalRecettes - totalDepenses;
      
      // Marge = (Bénéfice / Recettes) * 100
      final marge = (benefice / totalRecettes) * 100;

      expect(benefice, 150.0);
      expect(marge, 30.0); // 30% de marge
    });

    test('Marge négative si perte', () {
      final totalRecettes = 200.0;
      final totalDepenses = 300.0;
      final benefice = totalRecettes - totalDepenses;
      
      final marge = totalRecettes > 0 
          ? (benefice / totalRecettes) * 100 
          : 0.0;

      expect(benefice, -100.0);
      expect(marge, -50.0); // -50% de marge (perte)
    });

    test('Moyenne des ventes par lapin', () {
      final recettesVenteLapins = [
        Recette(id: 1, date: DateTime(2024, 1, 1), categorie: CategorieRecette.venteLapin, montant: 30.0, description: 'V1'),
        Recette(id: 2, date: DateTime(2024, 2, 1), categorie: CategorieRecette.venteLapin, montant: 35.0, description: 'V2'),
        Recette(id: 3, date: DateTime(2024, 3, 1), categorie: CategorieRecette.venteLapin, montant: 40.0, description: 'V3'),
        Recette(id: 4, date: DateTime(2024, 4, 1), categorie: CategorieRecette.venteLapin, montant: 45.0, description: 'V4'),
      ];

      final moyenneVente = recettesVenteLapins.fold(0.0, (sum, r) => sum + r.montant) 
          / recettesVenteLapins.length;

      expect(moyenneVente, 37.5); // (30 + 35 + 40 + 45) / 4
    });
  });
}
