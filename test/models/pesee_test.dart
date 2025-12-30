import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/pesee.dart';

void main() {
  group('Pesee Model Tests', () {
    test('Création d\'une pesée valide', () {
      final pesee = Pesee(
        id: 1,
        lapinId: 10,
        date: DateTime(2024, 11, 1),
        poids: 2.85,
        notes: 'Bonne croissance',
      );

      expect(pesee.id, equals(1));
      expect(pesee.lapinId, equals(10));
      expect(pesee.poids, equals(2.85));
      expect(pesee.notes, equals('Bonne croissance'));
    });

    test('Conversion pesée vers Map', () {
      final pesee = Pesee(lapinId: 5, date: DateTime(2024, 10, 15), poids: 3.2);

      final map = pesee.toMap();

      expect(map['lapin_id'], equals(5));
      expect(map['poids'], equals(3.2));
      expect(map['date'], isNotNull);
    });

    test('Création pesée depuis Map', () {
      final map = {
        'id': 3,
        'lapin_id': 7,
        'date': DateTime(2024, 9, 20).toIso8601String(),
        'poids': 2.1,
        'remarques': 'Test',
      };

      final pesee = Pesee.fromMap(map);

      expect(pesee.id, equals(3));
      expect(pesee.lapinId, equals(7));
      expect(pesee.poids, equals(2.1));
    });

    test('Pesée sans remarques', () {
      final pesee = Pesee(lapinId: 1, date: DateTime.now(), poids: 2.5);

      expect(pesee.notes, isNull);
    });
  });
}
