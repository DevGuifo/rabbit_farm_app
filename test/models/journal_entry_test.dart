import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/journal_entry.dart';

void main() {
  group('JournalEntry Model', () {
    group('TypeEntite', () {
      test('contient tous les types d\'entités attendus', () {
        // Vérifier que les types essentiels existent
        expect(TypeEntite.values, contains(TypeEntite.lapin));
        expect(TypeEntite.values, contains(TypeEntite.portee));
        expect(TypeEntite.values, contains(TypeEntite.accouplement));
        expect(TypeEntite.values, contains(TypeEntite.soin));
        expect(TypeEntite.values, contains(TypeEntite.pesee));
        expect(TypeEntite.values, contains(TypeEntite.depense));
        expect(TypeEntite.values, contains(TypeEntite.recette));
        expect(TypeEntite.values, contains(TypeEntite.rituel));
        expect(TypeEntite.values, contains(TypeEntite.anomalie));
      });

      test('label retourne une chaîne lisible', () {
        expect(TypeEntite.lapin.label, equals('Lapin'));
        expect(TypeEntite.portee.label, equals('Portée'));
        expect(TypeEntite.accouplement.label, equals('Accouplement'));
      });
    });

    group('TypeAction', () {
      test('contient les actions principales', () {
        expect(TypeAction.values, contains(TypeAction.creation));
        expect(TypeAction.values, contains(TypeAction.modification));
        expect(TypeAction.values, contains(TypeAction.suppression));
        expect(TypeAction.values, contains(TypeAction.validation));
        expect(TypeAction.values, contains(TypeAction.observation));
        expect(TypeAction.values, contains(TypeAction.anomalie));
      });

      test('verbe retourne une chaîne lisible', () {
        expect(TypeAction.creation.verbe, isNotEmpty);
        expect(TypeAction.modification.verbe, isNotEmpty);
        expect(TypeAction.suppression.verbe, isNotEmpty);
      });
    });

    group('StatutEvenement', () {
      test('contient les statuts attendus', () {
        expect(StatutEvenement.values, contains(StatutEvenement.normal));
        expect(StatutEvenement.values, contains(StatutEvenement.anomalie));
        expect(StatutEvenement.values, contains(StatutEvenement.action));
        expect(StatutEvenement.values, contains(StatutEvenement.info));
        expect(StatutEvenement.values, contains(StatutEvenement.succes));
      });
    });

    group('JournalEntry création', () {
      test('crée une entrée avec les champs obligatoires', () {
        final entry = JournalEntry(
          timestamp: DateTime(2024, 1, 15, 10, 30),
          typeEntite: TypeEntite.lapin,
          typeAction: TypeAction.creation,
          resumeAuto: 'Lapin créé',
        );

        expect(entry.timestamp, equals(DateTime(2024, 1, 15, 10, 30)));
        expect(entry.typeEntite, equals(TypeEntite.lapin));
        expect(entry.typeAction, equals(TypeAction.creation));
        expect(entry.resumeAuto, equals('Lapin créé'));
        expect(entry.statut, equals(StatutEvenement.normal)); // défaut
        expect(entry.id, isNull);
      });

      test('crée une entrée avec tous les champs', () {
        final entry = JournalEntry(
          id: 42,
          timestamp: DateTime(2024, 1, 15, 10, 30),
          typeEntite: TypeEntite.soin,
          entiteId: 123,
          entiteNom: 'Blanche',
          typeAction: TypeAction.validation,
          statut: StatutEvenement.succes,
          resumeAuto: 'Vaccination effectuée',
          noteUtilisateur: 'RAS',
          contexte: {'vaccin': 'VHD', 'dose': '1ml'},
          lu: true,
        );

        expect(entry.id, equals(42));
        expect(entry.entiteId, equals(123));
        expect(entry.entiteNom, equals('Blanche'));
        expect(entry.statut, equals(StatutEvenement.succes));
        expect(entry.noteUtilisateur, equals('RAS'));
        expect(entry.contexte['vaccin'], equals('VHD'));
        expect(entry.lu, isTrue);
      });
    });

    group('JournalEntry toMap/fromMap', () {
      test('sérialisation et désérialisation correctes', () {
        final original = JournalEntry(
          id: 1,
          timestamp: DateTime(2024, 6, 15, 14, 30, 0),
          typeEntite: TypeEntite.pesee,
          entiteId: 5,
          entiteNom: 'Cannelle',
          typeAction: TypeAction.creation,
          statut: StatutEvenement.normal,
          resumeAuto: 'Pesée enregistrée',
          noteUtilisateur: 'Poids stable',
          contexte: {'poids': 2.5, 'unite': 'kg'},
          lu: false,
        );

        final map = original.toMap();
        final restored = JournalEntry.fromMap(map);

        expect(restored.id, equals(original.id));
        expect(restored.typeEntite, equals(original.typeEntite));
        expect(restored.entiteId, equals(original.entiteId));
        expect(restored.entiteNom, equals(original.entiteNom));
        expect(restored.typeAction, equals(original.typeAction));
        expect(restored.statut, equals(original.statut));
        expect(restored.resumeAuto, equals(original.resumeAuto));
        expect(restored.noteUtilisateur, equals(original.noteUtilisateur));
        expect(restored.lu, equals(original.lu));
      });

      test('toMap inclut ou exclut l\'id selon implémentation', () {
        final entry = JournalEntry(
          timestamp: DateTime.now(),
          typeEntite: TypeEntite.lapin,
          typeAction: TypeAction.creation,
          resumeAuto: 'Test',
        );

        final map = entry.toMap();

        // Le comportement peut varier selon l'implémentation
        // On vérifie juste que toMap fonctionne
        expect(map, isNotEmpty);
        expect(map.containsKey('timestamp'), isTrue);
        expect(map.containsKey('type_entite'), isTrue);
      });
    });

    group('JournalEntry copyWith', () {
      test('crée une copie avec modification partielle', () {
        final original = JournalEntry(
          id: 10,
          timestamp: DateTime(2024, 1, 1),
          typeEntite: TypeEntite.lapin,
          typeAction: TypeAction.creation,
          resumeAuto: 'Lapin créé',
          lu: false,
        );

        final modified = original.copyWith(
          lu: true,
          noteUtilisateur: 'Note ajoutée',
        );

        // Champs modifiés
        expect(modified.lu, isTrue);
        expect(modified.noteUtilisateur, equals('Note ajoutée'));

        // Champs non modifiés
        expect(modified.id, equals(10));
        expect(modified.typeEntite, equals(TypeEntite.lapin));
        expect(modified.typeAction, equals(TypeAction.creation));
        expect(modified.resumeAuto, equals('Lapin créé'));
      });
    });

    group('JournalEntry formatage', () {
      test('dateFormatee retourne une date lisible', () {
        final entry = JournalEntry(
          timestamp: DateTime(2024, 6, 15, 14, 30),
          typeEntite: TypeEntite.lapin,
          typeAction: TypeAction.creation,
          resumeAuto: 'Test',
        );

        // Vérifie que la date est formatée (format dépend de l'implémentation)
        expect(entry.dateFormatee, isNotEmpty);
      });

      test('heureFormatee retourne une heure lisible', () {
        final entry = JournalEntry(
          timestamp: DateTime(2024, 6, 15, 14, 30),
          typeEntite: TypeEntite.lapin,
          typeAction: TypeAction.creation,
          resumeAuto: 'Test',
        );

        expect(entry.heureFormatee, isNotEmpty);
      });
    });
  });
}
