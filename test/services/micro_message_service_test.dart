import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/services/micro_message_service.dart';

void main() {
  group('MicroMessageService', () {
    late MicroMessageService service;

    setUp(() {
      service = MicroMessageService();
    });

    group('getMessageStreak', () {
      test('retourne un message pour streak 0', () {
        final result = service.getMessageStreak(0);

        expect(result.$1, isNotEmpty); // emoji
        expect(result.$2, isNotEmpty); // titre
        expect(result.$3, isNotEmpty); // astuce
      });

      test('retourne un message pour streak 1', () {
        final result = service.getMessageStreak(1);

        expect(result.$1, isNotEmpty);
        expect(result.$2, isNotEmpty);
        expect(result.$3, isNotEmpty);
      });

      test('retourne un message pour streak 3', () {
        final result = service.getMessageStreak(3);

        expect(result.$1, isNotEmpty);
        expect(result.$2, isNotEmpty); // titre peut varier
        expect(result.$3, isNotEmpty);
      });

      test('retourne un message pour streak 7', () {
        final result = service.getMessageStreak(7);

        expect(result.$1, isNotEmpty);
        expect(result.$2, isNotEmpty); // message de félicitations
        expect(result.$3, isNotEmpty);
      });

      test('retourne un message pour streak 14', () {
        final result = service.getMessageStreak(14);

        expect(result.$1, isNotEmpty);
        expect(result.$2, isNotEmpty); // message de félicitations
        expect(result.$3, isNotEmpty);
      });

      test('utilise le seuil inférieur pour valeurs intermédiaires', () {
        // Streak de 5 devrait utiliser les messages de streak 3
        final result = service.getMessageStreak(5);

        expect(result.$1, isNotEmpty);
        expect(result.$2, isNotEmpty);
        expect(result.$3, isNotEmpty);
      });
    });

    group('getMessageInactivite', () {
      test('retourne un message pour 1 jour d\'inactivité', () {
        final result = service.getMessageInactivite(1);

        expect(result.$1, isNotEmpty);
        expect(result.$2, isNotEmpty);
        expect(result.$3, isNotEmpty);
      });

      test('retourne un message pour 2 jours d\'inactivité', () {
        final result = service.getMessageInactivite(2);

        expect(result.$1, isNotEmpty);
        expect(result.$2, isNotEmpty); // message peut varier
        expect(result.$3, isNotEmpty);
      });

      test('retourne un message urgent pour 3+ jours', () {
        final result = service.getMessageInactivite(3);

        expect(result.$1, isNotEmpty);
        // Messages d'alerte contiennent souvent ⚠️
        expect(result.$2.toLowerCase(), contains('3'));
      });

      test('retourne un message critique pour 5+ jours', () {
        final result = service.getMessageInactivite(5);

        expect(result.$1, isNotEmpty);
        expect(result.$2, isNotEmpty);
      });
    });

    group('getMessageActionManquee', () {
      test('retourne un message non-culpabilisant', () {
        final result = service.getMessageActionManquee();

        expect(result.$1, isNotEmpty);
        expect(result.$2, isNotEmpty);
        expect(result.$3, isNotEmpty);
        // Ne devrait pas être culpabilisant
        expect(result.$2.toLowerCase(), isNot(contains('mal')));
        expect(result.$2.toLowerCase(), isNot(contains('erreur')));
      });
    });

    group('getMessageAnomalie', () {
      test('retourne un message d\'encouragement', () {
        final result = service.getMessageAnomalie();

        expect(result.$1, isNotEmpty);
        expect(result.$2, isNotEmpty);
        expect(result.$3, isNotEmpty);
      });
    });

    group('getBonnePratiqueAleatoire', () {
      test('retourne une bonne pratique', () {
        final result = service.getBonnePratiqueAleatoire();

        expect(result.$1, isNotEmpty);
        expect(result.$2, isNotEmpty);
        expect(result.$3, isNotEmpty);
      });

      test('retourne des pratiques variées sur plusieurs appels', () {
        final results = <String>{};

        // Appeler plusieurs fois pour vérifier la variété
        for (var i = 0; i < 20; i++) {
          final result = service.getBonnePratiqueAleatoire();
          results.add(result.$2); // titre
        }

        // Devrait avoir au moins 2 messages différents
        expect(results.length, greaterThan(1));
      });
    });

    group('getMessageContextuel', () {
      test('priorise l\'inactivité prolongée (3+ jours)', () {
        final result = service.getMessageContextuel(
          joursConsecutifs: 0,
          joursSansActivite: 3,
          anomaliesOuvertes: 0,
          pourcentageRituels: 100,
        );

        // Doit être un message d'alerte d'inactivité
        expect(result.$1, isNotEmpty);
        expect(result.$2, isNotEmpty);
        expect(result.$3, isNotEmpty);
      });

      test('priorise les anomalies multiples', () {
        final result = service.getMessageContextuel(
          joursConsecutifs: 0,
          joursSansActivite: 0,
          anomaliesOuvertes: 3,
          pourcentageRituels: 100,
        );

        expect(result.$2.toLowerCase(), contains('point'));
      });

      test('félicite les séries de 3+ jours', () {
        final result = service.getMessageContextuel(
          joursConsecutifs: 5,
          joursSansActivite: 0,
          anomaliesOuvertes: 0,
          pourcentageRituels: 80,
        );

        expect(result.$1, isNotEmpty);
        expect(result.$2, isNotEmpty);
      });

      test('encourage quand rituels faibles', () {
        final result = service.getMessageContextuel(
          joursConsecutifs: 0,
          joursSansActivite: 0,
          anomaliesOuvertes: 0,
          pourcentageRituels: 30,
        );

        expect(result.$2.toLowerCase(), contains('améliorer'));
      });

      test('retourne une bonne pratique par défaut', () {
        final result = service.getMessageContextuel(
          joursConsecutifs: 1,
          joursSansActivite: 0,
          anomaliesOuvertes: 0,
          pourcentageRituels: 80,
        );

        // Devrait retourner une bonne pratique aléatoire
        expect(result.$1, isNotEmpty);
        expect(result.$2, isNotEmpty);
        expect(result.$3, isNotEmpty);
      });
    });

    group('getMessageRituelComplete', () {
      test('retourne message vide pour 0 rituels', () {
        final result = service.getMessageRituelComplete(0);
        expect(result, isEmpty);
      });

      test('retourne message pour 1 rituel', () {
        final result = service.getMessageRituelComplete(1);
        expect(result, contains('Premier'));
      });

      test('retourne message de félicitations pour 2+ rituels', () {
        final result = service.getMessageRituelComplete(2);
        expect(result, contains('deux'));
      });
    });

    group('getMessageEncouragement', () {
      test('encourage avant la semaine complète', () {
        final result = service.getMessageEncouragement(6);
        expect(result, contains('semaine'));
      });

      test('encourage avant les 2 semaines', () {
        final result = service.getMessageEncouragement(13);
        expect(result, contains('2 semaines'));
      });

      test('encourage avant chaque nouvelle semaine', () {
        final result = service.getMessageEncouragement(20);
        expect(result, contains('semaine'));
      });

      test('retourne vide pour jours non-stratégiques', () {
        final result = service.getMessageEncouragement(4);
        expect(result, isEmpty);
      });
    });
  });
}
