import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/services/search_service.dart';

void main() {
  group('SearchResult', () {
    test('creates SearchResult with all required fields', () {
      const result = SearchResult(
        type: SearchResultType.lapin,
        id: 1,
        title: 'Flocon',
        subtitle: 'Géant des Flandres • Mâle',
      );

      expect(result.type, SearchResultType.lapin);
      expect(result.id, 1);
      expect(result.title, 'Flocon');
      expect(result.subtitle, 'Géant des Flandres • Mâle');
      expect(result.iconEmoji, isNull);
      expect(result.data, isNull);
    });

    test('creates SearchResult with optional fields', () {
      const result = SearchResult(
        type: SearchResultType.medicament,
        id: 42,
        title: 'Ivermectine',
        subtitle: 'Antiparasitaire • 50ml',
        iconEmoji: '💊',
        data: {'custom': 'data'},
      );

      expect(result.iconEmoji, '💊');
      expect(result.data, isNotNull);
    });
  });

  group('SearchResultType', () {
    test('has correct label and emoji for lapin', () {
      expect(SearchResultType.lapin.label, 'Lapin');
      expect(SearchResultType.lapin.emoji, '🐰');
    });

    test('has correct label and emoji for lot', () {
      expect(SearchResultType.lot.label, 'Lot');
      expect(SearchResultType.lot.emoji, '📦');
    });

    test('has correct label and emoji for cage', () {
      expect(SearchResultType.cage.label, 'Cage');
      expect(SearchResultType.cage.emoji, '🏠');
    });

    test('has correct label and emoji for medicament', () {
      expect(SearchResultType.medicament.label, 'Médicament');
      expect(SearchResultType.medicament.emoji, '💊');
    });

    test('has correct label and emoji for aliment', () {
      expect(SearchResultType.aliment.label, 'Aliment');
      expect(SearchResultType.aliment.emoji, '🥕');
    });

    test('has correct label and emoji for tache', () {
      expect(SearchResultType.tache.label, 'Tâche');
      expect(SearchResultType.tache.emoji, '✅');
    });

    test('all enum values are defined', () {
      expect(SearchResultType.values.length, 6);
    });
  });

  group('SearchService', () {
    late SearchService searchService;

    setUp(() {
      searchService = SearchService();
    });

    test('is singleton', () {
      final instance1 = SearchService();
      final instance2 = SearchService();
      expect(identical(instance1, instance2), true);
    });

    test('searchGlobal returns empty list for short query', () async {
      final results = await searchService.searchGlobal('a');
      expect(results, isEmpty);
    });

    test('searchGlobal returns empty list for empty query', () async {
      final results = await searchService.searchGlobal('');
      expect(results, isEmpty);
    });

    test('searchGlobal returns empty list for whitespace query', () async {
      final results = await searchService.searchGlobal('   ');
      expect(results, isEmpty);
    });

    test('searchByType returns empty list for short query', () async {
      final results = await searchService.searchByType(
        'a',
        SearchResultType.lapin,
      );
      expect(results, isEmpty);
    });

    test('groupByType correctly groups results', () {
      const results = [
        SearchResult(
          type: SearchResultType.lapin,
          id: 1,
          title: 'L1',
          subtitle: '',
        ),
        SearchResult(
          type: SearchResultType.lapin,
          id: 2,
          title: 'L2',
          subtitle: '',
        ),
        SearchResult(
          type: SearchResultType.cage,
          id: 3,
          title: 'C1',
          subtitle: '',
        ),
        SearchResult(
          type: SearchResultType.medicament,
          id: 4,
          title: 'M1',
          subtitle: '',
        ),
      ];

      final grouped = searchService.groupByType(results);

      expect(grouped.length, 3);
      expect(grouped[SearchResultType.lapin]?.length, 2);
      expect(grouped[SearchResultType.cage]?.length, 1);
      expect(grouped[SearchResultType.medicament]?.length, 1);
      expect(grouped[SearchResultType.tache], isNull);
    });

    test('groupByType returns empty map for empty list', () {
      final grouped = searchService.groupByType([]);
      expect(grouped, isEmpty);
    });
  });
}
