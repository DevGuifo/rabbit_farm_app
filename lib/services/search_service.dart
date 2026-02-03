import '../models/lapin.dart';
import '../models/cage.dart';
import '../models/medicament.dart';
import '../models/tache.dart';
import '../models/aliment.dart';
import '../models/lot.dart';
import 'database_helper.dart';
import '../core/utils/logger.dart';

/// Résultat de recherche avec catégorie et données
class SearchResult {
  final SearchResultType type;
  final int id;
  final String title;
  final String subtitle;
  final String? iconEmoji;
  final dynamic data;

  const SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    this.iconEmoji,
    this.data,
  });
}

/// Types de résultats de recherche
enum SearchResultType {
  lapin('Lapin', '🐰'),
  lot('Lot', '📦'),
  cage('Cage', '🏠'),
  medicament('Médicament', '💊'),
  aliment('Aliment', '🥕'),
  tache('Tâche', '✅');

  final String label;
  final String emoji;

  const SearchResultType(this.label, this.emoji);
}

/// Service de recherche globale dans l'application
///
/// Permet de rechercher des lapins, lots, cages, médicaments,
/// aliments et tâches avec un seul champ de recherche.
class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Recherche globale dans toutes les entités
  ///
  /// [query] : Terme de recherche (minimum 2 caractères)
  /// [maxResults] : Nombre maximum de résultats par catégorie (défaut: 5)
  ///
  /// Retourne une liste de [SearchResult] triée par pertinence
  Future<List<SearchResult>> searchGlobal(
    String query, {
    int maxResults = 5,
  }) async {
    if (query.trim().length < 2) {
      return [];
    }

    final queryLower = query.toLowerCase().trim();
    final results = <SearchResult>[];

    try {
      // Recherche parallèle dans toutes les catégories
      final futures = await Future.wait([
        _searchLapins(queryLower, maxResults),
        _searchLots(queryLower, maxResults),
        _searchCages(queryLower, maxResults),
        _searchMedicaments(queryLower, maxResults),
        _searchAliments(queryLower, maxResults),
        _searchTaches(queryLower, maxResults),
      ]);

      for (final list in futures) {
        results.addAll(list);
      }

      // Trier par pertinence (correspondance exacte en premier)
      results.sort((a, b) {
        final aExact = a.title.toLowerCase().startsWith(queryLower) ? 0 : 1;
        final bExact = b.title.toLowerCase().startsWith(queryLower) ? 0 : 1;
        if (aExact != bExact) return aExact.compareTo(bExact);
        return a.title.compareTo(b.title);
      });

      return results;
    } catch (e) {
      logger.error('SearchService.searchGlobal error: $e');
      return [];
    }
  }

  /// Recherche par catégorie spécifique
  Future<List<SearchResult>> searchByType(
    String query,
    SearchResultType type, {
    int maxResults = 20,
  }) async {
    if (query.trim().length < 2) return [];

    final queryLower = query.toLowerCase().trim();

    switch (type) {
      case SearchResultType.lapin:
        return _searchLapins(queryLower, maxResults);
      case SearchResultType.lot:
        return _searchLots(queryLower, maxResults);
      case SearchResultType.cage:
        return _searchCages(queryLower, maxResults);
      case SearchResultType.medicament:
        return _searchMedicaments(queryLower, maxResults);
      case SearchResultType.aliment:
        return _searchAliments(queryLower, maxResults);
      case SearchResultType.tache:
        return _searchTaches(queryLower, maxResults);
    }
  }

  /// Recherche dans les lapins
  Future<List<SearchResult>> _searchLapins(String query, int limit) async {
    try {
      final lapins = await _db.getAllLapins();
      final results = <SearchResult>[];

      for (final lapin in lapins) {
        if (_matchLapin(lapin, query)) {
          results.add(
            SearchResult(
              type: SearchResultType.lapin,
              id: lapin.id!,
              title: lapin.nom.isNotEmpty
                  ? lapin.nom
                  : lapin.numeroIdentification ?? 'Sans nom',
              subtitle: '${lapin.race} • ${lapin.sexe.label}',
              iconEmoji: lapin.sexe.value == 'male' ? '🐰' : '🐇',
              data: lapin,
            ),
          );

          if (results.length >= limit) break;
        }
      }

      return results;
    } catch (e) {
      logger.error('SearchService._searchLapins error: $e');
      return [];
    }
  }

  bool _matchLapin(Lapin lapin, String query) {
    return lapin.nom.toLowerCase().contains(query) ||
        (lapin.numeroIdentification?.toLowerCase().contains(query) ?? false) ||
        lapin.race.toLowerCase().contains(query) ||
        (lapin.couleur?.toLowerCase().contains(query) ?? false);
  }

  /// Recherche dans les lots
  Future<List<SearchResult>> _searchLots(String query, int limit) async {
    try {
      final lots = await _db.getAllLots();
      final results = <SearchResult>[];

      for (final lot in lots) {
        if (_matchLot(lot, query)) {
          results.add(
            SearchResult(
              type: SearchResultType.lot,
              id: lot.id!,
              title: lot.identifiant,
              subtitle: '${lot.type.label} • ${lot.effectifActuel} lapins',
              iconEmoji: '📦',
              data: lot,
            ),
          );

          if (results.length >= limit) break;
        }
      }

      return results;
    } catch (e) {
      logger.error('SearchService._searchLots error: $e');
      return [];
    }
  }

  bool _matchLot(Lot lot, String query) {
    return lot.identifiant.toLowerCase().contains(query) ||
        lot.type.label.toLowerCase().contains(query) ||
        (lot.metadata.notes?.toLowerCase().contains(query) ?? false);
  }

  /// Recherche dans les cages
  Future<List<SearchResult>> _searchCages(String query, int limit) async {
    try {
      final cages = await _db.getAllCages();
      final results = <SearchResult>[];

      for (final cage in cages) {
        if (_matchCage(cage, query)) {
          results.add(
            SearchResult(
              type: SearchResultType.cage,
              id: cage.id!,
              title: cage.numero,
              subtitle: '${cage.type.label} • Capacité: ${cage.capacite}',
              iconEmoji: '🏠',
              data: cage,
            ),
          );

          if (results.length >= limit) break;
        }
      }

      return results;
    } catch (e) {
      logger.error('SearchService._searchCages error: $e');
      return [];
    }
  }

  bool _matchCage(Cage cage, String query) {
    return cage.numero.toLowerCase().contains(query) ||
        cage.type.label.toLowerCase().contains(query);
  }

  /// Recherche dans les médicaments
  Future<List<SearchResult>> _searchMedicaments(String query, int limit) async {
    try {
      final medicaments = await _db.getAllMedicaments();
      final results = <SearchResult>[];

      for (final med in medicaments) {
        if (_matchMedicament(med, query)) {
          results.add(
            SearchResult(
              type: SearchResultType.medicament,
              id: med.id!,
              title: med.nom,
              subtitle: '${med.type.label} • ${med.quantiteStock} ${med.unite}',
              iconEmoji: '💊',
              data: med,
            ),
          );

          if (results.length >= limit) break;
        }
      }

      return results;
    } catch (e) {
      logger.error('SearchService._searchMedicaments error: $e');
      return [];
    }
  }

  bool _matchMedicament(Medicament med, String query) {
    return med.nom.toLowerCase().contains(query) ||
        med.type.label.toLowerCase().contains(query) ||
        (med.posologie?.toLowerCase().contains(query) ?? false);
  }

  /// Recherche dans les aliments
  Future<List<SearchResult>> _searchAliments(String query, int limit) async {
    try {
      final aliments = await _db.getAllAliments();
      final results = <SearchResult>[];

      for (final alim in aliments) {
        if (_matchAliment(alim, query)) {
          results.add(
            SearchResult(
              type: SearchResultType.aliment,
              id: alim.id!,
              title: alim.nom,
              subtitle:
                  '${alim.type} • ${alim.quantiteRestante} ${alim.conditionnement}',
              iconEmoji: '🥕',
              data: alim,
            ),
          );

          if (results.length >= limit) break;
        }
      }

      return results;
    } catch (e) {
      logger.error('SearchService._searchAliments error: $e');
      return [];
    }
  }

  bool _matchAliment(Aliment alim, String query) {
    return alim.nom.toLowerCase().contains(query) ||
        alim.type.toLowerCase().contains(query);
  }

  /// Recherche dans les tâches
  Future<List<SearchResult>> _searchTaches(String query, int limit) async {
    try {
      final taches = await _db.getAllTaches();
      final results = <SearchResult>[];

      for (final tache in taches) {
        if (_matchTache(tache, query)) {
          results.add(
            SearchResult(
              type: SearchResultType.tache,
              id: tache.id!,
              title: tache.titre,
              subtitle: '${tache.categorie.label} • ${tache.statut.label}',
              iconEmoji: '✅',
              data: tache,
            ),
          );

          if (results.length >= limit) break;
        }
      }

      return results;
    } catch (e) {
      logger.error('SearchService._searchTaches error: $e');
      return [];
    }
  }

  bool _matchTache(Tache tache, String query) {
    return tache.titre.toLowerCase().contains(query) ||
        (tache.description?.toLowerCase().contains(query) ?? false) ||
        tache.categorie.label.toLowerCase().contains(query);
  }

  /// Obtenir les résultats groupés par catégorie
  Map<SearchResultType, List<SearchResult>> groupByType(
    List<SearchResult> results,
  ) {
    final grouped = <SearchResultType, List<SearchResult>>{};

    for (final result in results) {
      grouped.putIfAbsent(result.type, () => []);
      grouped[result.type]!.add(result);
    }

    return grouped;
  }
}
