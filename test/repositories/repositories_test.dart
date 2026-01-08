import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/repositories/repositories.dart';

void main() {
  group('Repositories Structure', () {
    // Tests de structure - vérifie que les repositories existent et ont la bonne signature

    group('LapinRepository', () {
      test('est un singleton', () {
        final instance1 = LapinRepository.instance;
        final instance2 = LapinRepository.instance;

        expect(identical(instance1, instance2), isTrue);
      });

      test('expose les méthodes CRUD attendues', () {
        final repo = LapinRepository.instance;

        // Vérifie que les méthodes existent (type checking à la compilation)
        expect(repo.getAll, isA<Function>());
        expect(repo.getById, isA<Function>());
        expect(repo.insert, isA<Function>());
        expect(repo.update, isA<Function>());
        expect(repo.delete, isA<Function>());
      });

      test('expose les méthodes de filtrage', () {
        final repo = LapinRepository.instance;

        expect(repo.getMales, isA<Function>());
        expect(repo.getFemelles, isA<Function>());
        expect(repo.getByStatut, isA<Function>());
        expect(repo.count, isA<Function>());
      });

      test('expose les méthodes de généalogie', () {
        final repo = LapinRepository.instance;

        expect(repo.getRelation, isA<Function>());
        expect(repo.setParents, isA<Function>());
        expect(repo.getPere, isA<Function>());
        expect(repo.getMere, isA<Function>());
        expect(repo.getParents, isA<Function>());
        expect(repo.getEnfants, isA<Function>());
        expect(repo.getAncetres, isA<Function>());
        expect(repo.calculerConsanguinite, isA<Function>());
      });
    });

    group('ReproductionRepository', () {
      test('est un singleton', () {
        final instance1 = ReproductionRepository.instance;
        final instance2 = ReproductionRepository.instance;

        expect(identical(instance1, instance2), isTrue);
      });

      test('expose les méthodes pour accouplements', () {
        final repo = ReproductionRepository.instance;

        expect(repo.getAllAccouplements, isA<Function>());
        expect(repo.getAccouplementById, isA<Function>());
        expect(repo.insertAccouplement, isA<Function>());
        expect(repo.updateAccouplement, isA<Function>());
        expect(repo.deleteAccouplement, isA<Function>());
      });

      test('expose les méthodes pour portées', () {
        final repo = ReproductionRepository.instance;

        expect(repo.getAllPortees, isA<Function>());
        expect(repo.getPorteeById, isA<Function>());
        expect(repo.insertPortee, isA<Function>());
        expect(repo.updatePortee, isA<Function>());
        expect(repo.deletePortee, isA<Function>());
        expect(repo.getPorteeByAccouplement, isA<Function>());
      });
    });

    group('SanteRepository', () {
      test('est un singleton', () {
        final instance1 = SanteRepository.instance;
        final instance2 = SanteRepository.instance;

        expect(identical(instance1, instance2), isTrue);
      });

      test('expose les méthodes pour pesées', () {
        final repo = SanteRepository.instance;

        expect(repo.getAllPesees, isA<Function>());
        expect(repo.getPeseesByLapin, isA<Function>());
        expect(repo.insertPesee, isA<Function>());
        expect(repo.getDernierePesee, isA<Function>());
      });

      test('expose les méthodes pour soins', () {
        final repo = SanteRepository.instance;

        expect(repo.getAllSoins, isA<Function>());
        expect(repo.getSoinsByLapin, isA<Function>());
        expect(repo.insertSoin, isA<Function>());
        expect(repo.getSoinsAvecRappel, isA<Function>());
      });

      test('expose les méthodes pour décès', () {
        final repo = SanteRepository.instance;

        expect(repo.getAllDeces, isA<Function>());
        expect(repo.insertDeces, isA<Function>());
        expect(repo.getDecesByPeriode, isA<Function>());
        expect(repo.getDecesByCause, isA<Function>());
      });
    });

    group('FinanceRepository', () {
      test('est un singleton', () {
        final instance1 = FinanceRepository.instance;
        final instance2 = FinanceRepository.instance;

        expect(identical(instance1, instance2), isTrue);
      });

      test('expose les méthodes pour recettes', () {
        final repo = FinanceRepository.instance;

        expect(repo.getAllRecettes, isA<Function>());
        expect(repo.insertRecette, isA<Function>());
        expect(repo.getRecettesByPeriode, isA<Function>());
        expect(repo.getRecettesByCategorie, isA<Function>());
      });

      test('expose les méthodes pour dépenses', () {
        final repo = FinanceRepository.instance;

        expect(repo.getAllDepenses, isA<Function>());
        expect(repo.insertDepense, isA<Function>());
        expect(repo.getDepensesByPeriode, isA<Function>());
        expect(repo.getDepensesByCategorie, isA<Function>());
      });

      test('expose les méthodes de statistiques', () {
        final repo = FinanceRepository.instance;

        expect(repo.getTotalRecettes, isA<Function>());
        expect(repo.getTotalDepenses, isA<Function>());
        expect(repo.getBenefice, isA<Function>());
        expect(repo.getBeneficeByPeriode, isA<Function>());
      });
    });

    group('RituelRepository', () {
      test('est un singleton', () {
        final instance1 = RituelRepository.instance;
        final instance2 = RituelRepository.instance;

        expect(identical(instance1, instance2), isTrue);
      });

      test('expose les méthodes pour rituels', () {
        final repo = RituelRepository.instance;

        expect(repo.getRituelByDateAndType, isA<Function>());
        expect(repo.insertRituel, isA<Function>());
        expect(repo.updateRituel, isA<Function>());
        expect(repo.getHistoriqueRituels, isA<Function>());
      });

      test('expose les méthodes pour anomalies', () {
        final repo = RituelRepository.instance;

        expect(repo.insertAnomalie, isA<Function>());
        expect(repo.updateAnomalie, isA<Function>());
        expect(repo.getAnomaliesAujourdhui, isA<Function>());
        expect(repo.getAnomaliesNonResolues, isA<Function>());
        expect(repo.getAnomaliesCritiques, isA<Function>());
      });

      test('expose les méthodes pour journal', () {
        final repo = RituelRepository.instance;

        expect(repo.insertJournalEntry, isA<Function>());
        expect(repo.getJournalAujourdhui, isA<Function>());
        expect(repo.getJournalSemaine, isA<Function>());
        expect(repo.getJournalNonLu, isA<Function>());
        expect(repo.marquerJournalLu, isA<Function>());
        expect(repo.countJournalNonLu, isA<Function>());
      });
    });

    group('TacheRepository', () {
      test('est un singleton', () {
        final instance1 = TacheRepository.instance;
        final instance2 = TacheRepository.instance;

        expect(identical(instance1, instance2), isTrue);
      });

      test('expose les méthodes CRUD', () {
        final repo = TacheRepository.instance;

        expect(repo.getAllTaches, isA<Function>());
        expect(repo.getTacheById, isA<Function>());
        expect(repo.insertTache, isA<Function>());
        expect(repo.updateTache, isA<Function>());
        expect(repo.deleteTache, isA<Function>());
      });

      test('expose les méthodes de filtrage', () {
        final repo = TacheRepository.instance;

        expect(repo.getTachesByStatut, isA<Function>());
        expect(repo.getTachesByCategorie, isA<Function>());
        expect(repo.getTachesAujourdhui, isA<Function>());
        expect(repo.getTachesCetteSemaine, isA<Function>());
        expect(repo.marquerTacheTerminee, isA<Function>());
      });
    });
  });
}
