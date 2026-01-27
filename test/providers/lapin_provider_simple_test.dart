import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/lapin.dart';
import 'package:rabbit_farm_app/models/enums/sexe.dart';
import 'package:rabbit_farm_app/providers/lapin_provider.dart';
import 'package:rabbit_farm_app/repositories/lapin_repository.dart';
import 'package:rabbit_farm_app/core/utils/logger.dart';

/// Mock simplifié de DatabaseHelper pour les tests unitaires
///
/// Cette classe permet de tester LapinProvider sans dépendre
/// d'une vraie base de données SQLite.
///
/// ## Usage
///
/// ```dart
/// final mockRepo = MockLapinRepository();
/// final provider = LapinProvider.withRepository(mockRepo);
/// ```
/// Mock simplifié de LapinRepository pour les tests unitaires
class MockLapinRepository implements LapinRepository {
  List<Lapin> _lapins = [];
  int _nextId = 1;

  MockLapinRepository();

  /// Configure les données de test
  void setLapins(List<Lapin> lapins) {
    _lapins = lapins;
    _nextId = lapins.isEmpty
        ? 1
        : (lapins.map((l) => l.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
  }

  @override
  Future<List<Lapin>> getAll() async {
    return List.from(_lapins);
  }

  @override
  Future<Lapin> insert(Lapin lapin) async {
    final lapinAvecId = lapin.copyWith(id: _nextId++);
    _lapins.add(lapinAvecId);
    return lapinAvecId;
  }

  @override
  Future<int> update(Lapin lapin) async {
    final index = _lapins.indexWhere((l) => l.id == lapin.id);
    if (index != -1) {
      _lapins[index] = lapin;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> delete(int id) async {
    final lengthBefore = _lapins.length;
    _lapins.removeWhere((l) => l.id == id);
    return lengthBefore - _lapins.length;
  }

  @override
  Future<int> count() async {
    return _lapins.length;
  }

  @override
  Future<Lapin?> getById(int id) async {
    try {
      return _lapins.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Lapin>> getMales() async {
    return _lapins.where((l) => l.sexe == Sexe.male).toList();
  }

  @override
  Future<List<Lapin>> getFemelles() async {
    return _lapins.where((l) => l.sexe == Sexe.femelle).toList();
  }

  @override
  Future<List<Lapin>> getByStatut(String statut) async {
    return _lapins.where((l) => l.statut == statut).toList();
  }

  // Méthodes non utilisées dans ce test mais requises par l'interface
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Tests unitaires pour LapinProvider avec mock simplifié
void main() {
  late MockLapinRepository mockRepo;
  late LapinProvider provider;
  late List<Lapin> lapinsTest;

  // Initialiser le logger une fois pour tous les tests
  setUpAll(() {
    logger.initialize(isProduction: true); // Mode silencieux pour les tests
  });

  setUp(() {
    mockRepo = MockLapinRepository();
    // ... setup data ...
    lapinsTest = [
      Lapin(
        id: 1,
        nom: 'Flocon',
        race: 'Géant des Flandres',
        sexe: Sexe.male,
        dateNaissance: DateTime(2024, 1, 15),
        poids: 7.5,
        statut: 'Reproducteur',
      ),
      Lapin(
        id: 2,
        nom: 'Neige',
        race: 'Rex',
        sexe: Sexe.femelle,
        dateNaissance: DateTime(2024, 3, 20),
        poids: 4.5,
        statut: 'Reproductrice',
      ),
      Lapin(
        id: 3,
        nom: 'Caramel',
        race: 'Bélier',
        sexe: Sexe.male,
        dateNaissance: DateTime(2024, 6, 10),
        poids: 3.0,
        statut: 'Actif',
      ),
      Lapin(
        id: 4,
        nom: 'Cannelle',
        race: 'Bélier',
        sexe: Sexe.femelle,
        dateNaissance: DateTime(2024, 5, 5),
        poids: 3.0,
        statut: 'Gestante',
      ),
    ];

    mockRepo.setLapins(List.from(lapinsTest));
    provider = LapinProvider.withRepository(mockRepo);
  });

  group('LapinProvider - Chargement', () {
    test('chargerLapins() charge tous les lapins', () async {
      await provider.chargerLapins();

      expect(provider.lapins.length, 4);
      expect(provider.isLoading, false);
    });

    test('total retourne le nombre correct', () async {
      await provider.chargerLapins();

      expect(provider.nombreLapins, 4);
    });
  });

  group('LapinProvider - Filtres', () {
    setUp(() async {
      await provider.chargerLapins();
    });

    test('males retourne uniquement les mâles', () {
      final males = provider.males;

      expect(males.length, 2);
      expect(males.every((l) => l.sexe == Sexe.male), true);
    });

    test('femelles retourne uniquement les femelles', () {
      final femelles = provider.femelles;

      expect(femelles.length, 2);
      expect(femelles.every((l) => l.sexe == Sexe.femelle), true);
    });

    test('getLapinById trouve un lapin existant', () {
      final lapin = provider.getLapinById(1);

      expect(lapin, isNotNull);
      expect(lapin!.nom, 'Flocon');
    });

    test('getLapinById retourne null pour ID inexistant', () {
      final lapin = provider.getLapinById(999);

      expect(lapin, isNull);
    });
  });

  group('LapinProvider - CRUD', () {
    setUp(() async {
      await provider.chargerLapins();
    });

    test('ajouterLapin ajoute un nouveau lapin', () async {
      final nouveauLapin = Lapin(
        nom: 'Nouveau',
        race: 'Rex',
        sexe: Sexe.male,
        dateNaissance: DateTime.now(),
      );

      final lapinAjoute = await provider.ajouterLapin(nouveauLapin);

      expect(lapinAjoute.id, isNotNull);
      expect(provider.lapins.length, 5);
      expect(provider.lapins.any((l) => l.nom == 'Nouveau'), true);
    });

    test('modifierLapin met à jour un lapin existant', () async {
      final lapinModifie = lapinsTest[0].copyWith(poids: 8.0);

      await provider.modifierLapin(lapinModifie);

      final lapin = provider.getLapinById(1);
      expect(lapin!.poids, 8.0);
    });

    test('supprimerLapin retire un lapin', () async {
      await provider.supprimerLapin(1);

      expect(provider.lapins.length, 3);
      expect(provider.getLapinById(1), isNull);
    });
  });

  group('LapinProvider - Cheptel vide', () {
    test('gère un cheptel vide correctement', () async {
      mockRepo.setLapins([]);

      await provider.chargerLapins();

      expect(provider.lapins, isEmpty);
      expect(provider.males, isEmpty);
      expect(provider.femelles, isEmpty);
      expect(provider.nombreLapins, 0);
    });
  });

  group('LapinProvider - Comptage par sexe', () {
    setUp(() async {
      await provider.chargerLapins();
    });

    test('nombreLapins retourne le total correct', () {
      expect(provider.nombreLapins, 4);
    });

    test('getLapinsParSexe retourne les bons lapins', () {
      final males = provider.getLapinsParSexe(Sexe.male);
      final femelles = provider.getLapinsParSexe(Sexe.femelle);

      expect(males.length, 2);
      expect(femelles.length, 2);
    });
  });

  group('LapinProvider - Statistiques Cheptel', () {
    setUp(() async {
      await provider.chargerLapins();
    });

    test(
      'getStatistiquesCheptel retourne les stats correctes sans reproProvider',
      () {
        final stats = provider.getStatistiquesCheptel(null);

        expect(stats['total'], 4);
        expect(stats.containsKey('males'), true);
        expect(stats.containsKey('femelles'), true);
        expect(stats.containsKey('gestantes'), true);
        expect(stats.containsKey('lapereaux'), true);
        expect(stats.containsKey('porteesActives'), true);
      },
    );

    test('getStatistiquesCheptel compte correctement les reproducteurs', () {
      final stats = provider.getStatistiquesCheptel(null);

      // Flocon est Reproducteur (Mâle)
      expect(stats['males'], 1);
      // Neige est Reproductrice (Femelle)
      expect(stats['femelles'], 1);
    });

    test('getStatistiquesCheptel gère un cheptel vide', () async {
      mockRepo.setLapins([]);
      await provider.chargerLapins();

      final stats = provider.getStatistiquesCheptel(null);

      expect(stats['total'], 0);
      expect(stats['males'], 0);
      expect(stats['femelles'], 0);
      expect(stats['gestantes'], 0);
      expect(stats['lapereaux'], 0);
    });
  });

  group('LapinProvider - Variation Stats', () {
    setUp(() async {
      await provider.chargerLapins();
    });

    test('getVariationStat retourne un format pourcentage valide', () {
      final variation = provider.getVariationStat('total', 10);

      // Vérifie que le format est correcte (+X%, -X%, ou 0%)
      expect(variation.contains('%'), true);
    });

    test('getVariationStat avec valeur 0 retourne 0%', () {
      final variation = provider.getVariationStat('total', 0);

      expect(variation, '0%');
    });
  });

  group('LapinProvider - UpdateStatut', () {
    setUp(() async {
      await provider.chargerLapins();
    });

    test('updateStatut modifie le statut d\'un lapin existant', () async {
      await provider.updateStatut(1, 'Vendu');

      final lapin = provider.getLapinById(1);
      expect(lapin!.statut, 'Vendu');
    });

    test('updateStatut conserve les autres propriétés du lapin', () async {
      final lapinAvant = provider.getLapinById(1)!;
      final nomAvant = lapinAvant.nom;
      final raceAvant = lapinAvant.race;

      await provider.updateStatut(1, 'Réforme');

      final lapinApres = provider.getLapinById(1)!;
      expect(lapinApres.nom, nomAvant);
      expect(lapinApres.race, raceAvant);
      expect(lapinApres.statut, 'Réforme');
    });

    test('updateStatut lève une exception pour un ID inexistant', () async {
      expect(() => provider.updateStatut(999, 'Test'), throwsStateError);
    });
  });
}
