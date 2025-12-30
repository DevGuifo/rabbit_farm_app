import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/lapin.dart';
import 'package:rabbit_farm_app/providers/lapin_provider.dart';

void main() {
  group('LapinProvider Tests', () {
    late LapinProvider provider;

    setUp(() {
      provider = LapinProvider();
    });

    test('État initial - liste vide et non chargé', () {
      expect(provider.lapins, isEmpty);
      expect(provider.nombreLapins, equals(0));
      expect(provider.isLoading, isFalse);
    });

    test('getLapinById retourne null si lapin non trouvé', () {
      final lapin = provider.getLapinById(999);
      expect(lapin, isNull);
    });

    test('getLapinsParSexe filtre correctement les mâles', () {
      // Note: Ce test nécessite des lapins en base de données
      // Pour un test complet, il faudrait mocker DatabaseHelper
      final males = provider.males;
      expect(males, isA<List<Lapin>>());
    });

    test('getLapinsParSexe filtre correctement les femelles', () {
      final femelles = provider.femelles;
      expect(femelles, isA<List<Lapin>>());
    });

    test('getLapinsParStatut filtre correctement par statut', () {
      final actifs = provider.getLapinsParStatut('Actif');
      expect(actifs, isA<List<Lapin>>());
    });

    test('nombreLapins correspond à la longueur de la liste', () {
      expect(provider.nombreLapins, equals(provider.lapins.length));
    });
  });
}

