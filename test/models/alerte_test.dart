import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/alerte.dart';

void main() {
  group('Alerte Model Tests', () {
    test('Création d\'une alerte avec paramètres requis', () {
      final alerte = Alerte(
        id: 'test_1',
        titre: 'Test Alerte',
        description: 'Description de test',
        type: TypeAlerte.vaccination,
        priorite: PrioriteAlerte.normal,
        dateCreation: DateTime(2024, 1, 15),
      );

      expect(alerte.id, 'test_1');
      expect(alerte.titre, 'Test Alerte');
      expect(alerte.description, 'Description de test');
      expect(alerte.type, TypeAlerte.vaccination);
      expect(alerte.priorite, PrioriteAlerte.normal);
      expect(alerte.lapinId, isNull);
      expect(alerte.lapinNom, isNull);
      expect(alerte.action, isNull);
      expect(alerte.estLue, false);
    });

    test('Création d\'une alerte avec tous les paramètres', () {
      final alerte = Alerte(
        id: 'test_2',
        titre: 'Vaccination urgente',
        description: 'Rappel vaccination pour Luna',
        type: TypeAlerte.vaccination,
        priorite: PrioriteAlerte.urgent,
        dateCreation: DateTime(2024, 2, 20),
        lapinId: 42,
        lapinNom: 'Luna',
        action: 'Programmer vaccination',
        estLue: true,
      );

      expect(alerte.lapinId, 42);
      expect(alerte.lapinNom, 'Luna');
      expect(alerte.action, 'Programmer vaccination');
      expect(alerte.estLue, true);
    });

    test('copyWith() crée une copie avec modifications', () {
      final original = Alerte(
        id: 'original',
        titre: 'Titre Original',
        description: 'Description originale',
        type: TypeAlerte.pesee,
        priorite: PrioriteAlerte.normal,
        dateCreation: DateTime(2024, 1, 1),
        estLue: false,
      );

      final copie = original.copyWith(
        titre: 'Titre Modifié',
        estLue: true,
        priorite: PrioriteAlerte.urgent,
      );

      expect(copie.id, 'original'); // Non modifié
      expect(copie.titre, 'Titre Modifié'); // Modifié
      expect(copie.description, 'Description originale'); // Non modifié
      expect(copie.estLue, true); // Modifié
      expect(copie.priorite, PrioriteAlerte.urgent); // Modifié
      expect(original.estLue, false); // L'original n'est pas modifié
    });

    test('copyWith() permet d\'ajouter lapinId et lapinNom', () {
      final alerte = Alerte(
        id: 'test',
        titre: 'Test',
        description: 'Desc',
        type: TypeAlerte.traitement,
        priorite: PrioriteAlerte.important,
        dateCreation: DateTime.now(),
      );

      final copie = alerte.copyWith(lapinId: 10, lapinNom: 'Pompon');

      expect(copie.lapinId, 10);
      expect(copie.lapinNom, 'Pompon');
    });
  });

  group('TypeAlerte Extension Tests', () {
    test('label retourne le libellé correct pour chaque type', () {
      expect(TypeAlerte.vaccination.label, 'Vaccination');
      expect(TypeAlerte.palpation.label, 'Palpation');
      expect(TypeAlerte.preparationNid.label, 'Préparation nid');
      expect(TypeAlerte.miseBas.label, 'Mise bas');
      expect(TypeAlerte.sevrage.label, 'Sevrage');
      expect(TypeAlerte.pesee.label, 'Pesée');
      expect(TypeAlerte.traitement.label, 'Traitement');
      expect(TypeAlerte.poidsAnormal.label, 'Poids anormal');
      expect(TypeAlerte.stockFaible.label, 'Stock faible');
      expect(TypeAlerte.peremption.label, 'Péremption');
      expect(TypeAlerte.mortaliteAnormale.label, 'Mortalité anormale');
      expect(TypeAlerte.consanguinite.label, 'Consanguinité');
      expect(TypeAlerte.quarantaine.label, 'Quarantaine');
      expect(TypeAlerte.reforme.label, 'Réforme');
      expect(TypeAlerte.symptomes.label, 'Symptômes');
    });

    test('icon retourne l\'emoji correct pour chaque type', () {
      expect(TypeAlerte.vaccination.icon, '💉');
      expect(TypeAlerte.palpation.icon, '🤲');
      expect(TypeAlerte.preparationNid.icon, '🏠');
      expect(TypeAlerte.miseBas.icon, '🐰');
      expect(TypeAlerte.sevrage.icon, '👶');
      expect(TypeAlerte.pesee.icon, '⚖️');
      expect(TypeAlerte.traitement.icon, '💊');
      expect(TypeAlerte.poidsAnormal.icon, '⚠️');
      expect(TypeAlerte.stockFaible.icon, '📦');
      expect(TypeAlerte.peremption.icon, '📅');
      expect(TypeAlerte.mortaliteAnormale.icon, '☠️');
      expect(TypeAlerte.consanguinite.icon, '🧬');
      expect(TypeAlerte.quarantaine.icon, '🏥');
      expect(TypeAlerte.reforme.icon, '♻️');
      expect(TypeAlerte.symptomes.icon, '🤒');
    });

    test('Tous les TypeAlerte ont un label et icon définis', () {
      for (final type in TypeAlerte.values) {
        expect(type.label, isNotEmpty);
        expect(type.icon, isNotEmpty);
      }
    });
  });

  group('PrioriteAlerte Tests', () {
    test('Ordre des priorités (urgent < important < normal)', () {
      // L'index détermine l'ordre de tri
      expect(PrioriteAlerte.urgent.index, lessThan(PrioriteAlerte.important.index));
      expect(PrioriteAlerte.important.index, lessThan(PrioriteAlerte.normal.index));
    });

    test('Tri des alertes par priorité', () {
      final alertes = [
        Alerte(
          id: '1',
          titre: 'Normal',
          description: '',
          type: TypeAlerte.pesee,
          priorite: PrioriteAlerte.normal,
          dateCreation: DateTime.now(),
        ),
        Alerte(
          id: '2',
          titre: 'Urgent',
          description: '',
          type: TypeAlerte.vaccination,
          priorite: PrioriteAlerte.urgent,
          dateCreation: DateTime.now(),
        ),
        Alerte(
          id: '3',
          titre: 'Important',
          description: '',
          type: TypeAlerte.traitement,
          priorite: PrioriteAlerte.important,
          dateCreation: DateTime.now(),
        ),
      ];

      alertes.sort((a, b) => a.priorite.index.compareTo(b.priorite.index));

      expect(alertes[0].titre, 'Urgent');
      expect(alertes[1].titre, 'Important');
      expect(alertes[2].titre, 'Normal');
    });
  });

  group('Scénarios d\'utilisation des alertes', () {
    test('Créer une liste d\'alertes et filtrer les non lues', () {
      final alertes = [
        Alerte(
          id: '1',
          titre: 'Alerte 1',
          description: 'Desc 1',
          type: TypeAlerte.vaccination,
          priorite: PrioriteAlerte.urgent,
          dateCreation: DateTime.now(),
          estLue: true,
        ),
        Alerte(
          id: '2',
          titre: 'Alerte 2',
          description: 'Desc 2',
          type: TypeAlerte.pesee,
          priorite: PrioriteAlerte.normal,
          dateCreation: DateTime.now(),
          estLue: false,
        ),
        Alerte(
          id: '3',
          titre: 'Alerte 3',
          description: 'Desc 3',
          type: TypeAlerte.traitement,
          priorite: PrioriteAlerte.important,
          dateCreation: DateTime.now(),
          estLue: false,
        ),
      ];

      final nonLues = alertes.where((a) => !a.estLue).toList();

      expect(nonLues.length, 2);
      expect(nonLues.map((a) => a.id).toList(), ['2', '3']);
    });

    test('Filtrer les alertes par type', () {
      final alertes = [
        Alerte(
          id: '1',
          titre: 'Vaccination A',
          description: '',
          type: TypeAlerte.vaccination,
          priorite: PrioriteAlerte.normal,
          dateCreation: DateTime.now(),
        ),
        Alerte(
          id: '2',
          titre: 'Pesée',
          description: '',
          type: TypeAlerte.pesee,
          priorite: PrioriteAlerte.normal,
          dateCreation: DateTime.now(),
        ),
        Alerte(
          id: '3',
          titre: 'Vaccination B',
          description: '',
          type: TypeAlerte.vaccination,
          priorite: PrioriteAlerte.urgent,
          dateCreation: DateTime.now(),
        ),
      ];

      final vaccinations =
          alertes.where((a) => a.type == TypeAlerte.vaccination).toList();

      expect(vaccinations.length, 2);
    });

    test('Compter les alertes urgentes', () {
      final alertes = [
        Alerte(
          id: '1',
          titre: 'A1',
          description: '',
          type: TypeAlerte.vaccination,
          priorite: PrioriteAlerte.urgent,
          dateCreation: DateTime.now(),
        ),
        Alerte(
          id: '2',
          titre: 'A2',
          description: '',
          type: TypeAlerte.pesee,
          priorite: PrioriteAlerte.normal,
          dateCreation: DateTime.now(),
        ),
        Alerte(
          id: '3',
          titre: 'A3',
          description: '',
          type: TypeAlerte.traitement,
          priorite: PrioriteAlerte.urgent,
          dateCreation: DateTime.now(),
        ),
      ];

      final urgentes =
          alertes.where((a) => a.priorite == PrioriteAlerte.urgent).length;

      expect(urgentes, 2);
    });
  });
}
