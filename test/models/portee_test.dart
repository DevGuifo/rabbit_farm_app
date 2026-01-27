import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/portee.dart';

/// Tests unitaires pour le modèle Portee
///
/// Ces tests vérifient :
/// - La création d'instances
/// - La conversion toMap/fromMap
/// - Les propriétés calculées (tauxSurvie, ageEnJours, dateSevrage, doitEtreSevres)
/// - La méthode copyWith
void main() {
  group('Portee - Création', () {
    test('crée une portée avec tous les champs requis', () {
      final dateMiseBas = DateTime(2025, 1, 15);

      final portee = Portee(
        accouplementId: 1,
        dateMiseBasReelle: dateMiseBas,
        nombreNes: 8,
        nombreVivants: 7,
        nombreMorts: 1,
      );

      expect(portee.id, isNull);
      expect(portee.accouplementId, 1);
      expect(portee.dateMiseBasReelle, dateMiseBas);
      expect(portee.nombreNes, 8);
      expect(portee.nombreVivants, 7);
      expect(portee.nombreMorts, 1);
      expect(portee.notes, isNull);
    });

    test('crée une portée avec ID et notes', () {
      final portee = Portee(
        id: 42,
        accouplementId: 5,
        dateMiseBasReelle: DateTime(2025, 2, 1),
        nombreNes: 10,
        nombreVivants: 10,
        nombreMorts: 0,
        notes: 'Portée en parfaite santé',
      );

      expect(portee.id, 42);
      expect(portee.notes, 'Portée en parfaite santé');
    });

    test('crée une portée avec 0 mort', () {
      final portee = Portee(
        accouplementId: 1,
        dateMiseBasReelle: DateTime(2025, 1, 1),
        nombreNes: 6,
        nombreVivants: 6,
        nombreMorts: 0,
      );

      expect(portee.nombreMorts, 0);
      expect(portee.nombreNes, portee.nombreVivants);
    });
  });

  group('Portee - tauxSurvie', () {
    test('calcule 100% pour portée sans mort', () {
      final portee = Portee(
        accouplementId: 1,
        dateMiseBasReelle: DateTime(2025, 1, 1),
        nombreNes: 8,
        nombreVivants: 8,
        nombreMorts: 0,
      );

      expect(portee.tauxSurvie, 100.0);
    });

    test('calcule 50% pour moitié survivants', () {
      final portee = Portee(
        accouplementId: 1,
        dateMiseBasReelle: DateTime(2025, 1, 1),
        nombreNes: 10,
        nombreVivants: 5,
        nombreMorts: 5,
      );

      expect(portee.tauxSurvie, 50.0);
    });

    test('calcule 75% correctement', () {
      final portee = Portee(
        accouplementId: 1,
        dateMiseBasReelle: DateTime(2025, 1, 1),
        nombreNes: 8,
        nombreVivants: 6,
        nombreMorts: 2,
      );

      expect(portee.tauxSurvie, 75.0);
    });

    test('retourne 0% pour portée vide (0 nés)', () {
      final portee = Portee(
        accouplementId: 1,
        dateMiseBasReelle: DateTime(2025, 1, 1),
        nombreNes: 0,
        nombreVivants: 0,
        nombreMorts: 0,
      );

      expect(portee.tauxSurvie, 0.0);
    });

    test('calcule 0% si tous morts', () {
      final portee = Portee(
        accouplementId: 1,
        dateMiseBasReelle: DateTime(2025, 1, 1),
        nombreNes: 5,
        nombreVivants: 0,
        nombreMorts: 5,
      );

      expect(portee.tauxSurvie, 0.0);
    });
  });

  group('Portee - ageEnJours', () {
    test('calcule l\'âge correctement', () {
      // Portée d'il y a 10 jours
      final dateMiseBas = DateTime.now().subtract(const Duration(days: 10));
      final portee = Portee(
        accouplementId: 1,
        dateMiseBasReelle: dateMiseBas,
        nombreNes: 6,
        nombreVivants: 6,
        nombreMorts: 0,
      );

      expect(portee.ageEnJours, 10);
    });

    test('retourne 0 pour portée du jour', () {
      final portee = Portee(
        accouplementId: 1,
        dateMiseBasReelle: DateTime.now(),
        nombreNes: 6,
        nombreVivants: 6,
        nombreMorts: 0,
      );

      expect(portee.ageEnJours, 0);
    });
  });

  group('Portee - dateSevrage', () {
    test('calcule 35 jours après la mise bas', () {
      final dateMiseBas = DateTime(2025, 1, 15);
      final portee = Portee(
        accouplementId: 1,
        dateMiseBasReelle: dateMiseBas,
        nombreNes: 6,
        nombreVivants: 6,
        nombreMorts: 0,
      );

      // 15 janvier + 35 jours = 19 février
      expect(portee.dateSevrage, DateTime(2025, 2, 19));
    });

    test('gère le passage de mois', () {
      final dateMiseBas = DateTime(2025, 1, 1);
      final portee = Portee(
        accouplementId: 1,
        dateMiseBasReelle: dateMiseBas,
        nombreNes: 6,
        nombreVivants: 6,
        nombreMorts: 0,
      );

      // 1er janvier + 35 jours = 5 février
      expect(portee.dateSevrage, DateTime(2025, 2, 5));
    });
  });

  group('Portee - doitEtreSevres', () {
    test('retourne false pour portée récente', () {
      final portee = Portee(
        accouplementId: 1,
        dateMiseBasReelle: DateTime.now().subtract(const Duration(days: 10)),
        nombreNes: 6,
        nombreVivants: 6,
        nombreMorts: 0,
      );

      expect(portee.doitEtreSevres, isFalse);
    });

    test('retourne true pour portée de 35 jours', () {
      final portee = Portee(
        accouplementId: 1,
        dateMiseBasReelle: DateTime.now().subtract(const Duration(days: 35)),
        nombreNes: 6,
        nombreVivants: 6,
        nombreMorts: 0,
      );

      expect(portee.doitEtreSevres, isTrue);
    });

    test('retourne true pour portée de plus de 35 jours', () {
      final portee = Portee(
        accouplementId: 1,
        dateMiseBasReelle: DateTime.now().subtract(const Duration(days: 50)),
        nombreNes: 6,
        nombreVivants: 6,
        nombreMorts: 0,
      );

      expect(portee.doitEtreSevres, isTrue);
    });

    test('retourne false pour portée de 34 jours', () {
      final portee = Portee(
        accouplementId: 1,
        dateMiseBasReelle: DateTime.now().subtract(const Duration(days: 34)),
        nombreNes: 6,
        nombreVivants: 6,
        nombreMorts: 0,
      );

      expect(portee.doitEtreSevres, isFalse);
    });
  });

  group('Portee - toMap', () {
    test('convertit correctement tous les champs', () {
      final dateMiseBas = DateTime(2025, 1, 15, 14, 30);

      final portee = Portee(
        id: 5,
        accouplementId: 10,
        dateMiseBasReelle: dateMiseBas,
        nombreNes: 8,
        nombreVivants: 7,
        nombreMorts: 1,
        notes: 'Notes test',
      );

      final map = portee.toMap();

      expect(map['id'], 5);
      expect(map['accouplement_id'], 10);
      expect(map['date_mise_bas_reelle'], dateMiseBas.toIso8601String());
      expect(map['nombre_nes'], 8);
      expect(map['nombre_vivants'], 7);
      expect(map['nombre_morts'], 1);
      expect(map['notes'], 'Notes test');
    });

    test('inclut null pour id non défini', () {
      final portee = Portee(
        accouplementId: 1,
        dateMiseBasReelle: DateTime(2025, 1, 1),
        nombreNes: 6,
        nombreVivants: 6,
        nombreMorts: 0,
      );

      final map = portee.toMap();

      expect(map['id'], isNull);
    });
  });

  group('Portee - fromMap', () {
    test('crée depuis un Map complet', () {
      final map = {
        'id': 10,
        'accouplement_id': 5,
        'date_mise_bas_reelle': '2025-01-20T14:30:00.000',
        'nombre_nes': 9,
        'nombre_vivants': 8,
        'nombre_morts': 1,
        'notes': 'Belle portée',
      };

      final portee = Portee.fromMap(map);

      expect(portee.id, 10);
      expect(portee.accouplementId, 5);
      expect(portee.dateMiseBasReelle.year, 2025);
      expect(portee.dateMiseBasReelle.month, 1);
      expect(portee.dateMiseBasReelle.day, 20);
      expect(portee.nombreNes, 9);
      expect(portee.nombreVivants, 8);
      expect(portee.nombreMorts, 1);
      expect(portee.notes, 'Belle portée');
    });

    test('gère notes null', () {
      final map = {
        'id': 1,
        'accouplement_id': 1,
        'date_mise_bas_reelle': '2025-01-01T00:00:00.000',
        'nombre_nes': 6,
        'nombre_vivants': 6,
        'nombre_morts': 0,
        'notes': null,
      };

      final portee = Portee.fromMap(map);

      expect(portee.notes, isNull);
    });
  });

  group('Portee - copyWith', () {
    late Portee original;

    setUp(() {
      original = Portee(
        id: 1,
        accouplementId: 1,
        dateMiseBasReelle: DateTime(2025, 1, 15),
        nombreNes: 8,
        nombreVivants: 7,
        nombreMorts: 1,
        notes: 'Original',
      );
    });

    test('copie sans modifications', () {
      final copie = original.copyWith();

      expect(copie.id, original.id);
      expect(copie.accouplementId, original.accouplementId);
      expect(copie.nombreNes, original.nombreNes);
      expect(copie.nombreVivants, original.nombreVivants);
      expect(copie.nombreMorts, original.nombreMorts);
      expect(copie.notes, original.notes);
    });

    test('modifie nombreVivants uniquement', () {
      final copie = original.copyWith(nombreVivants: 6, nombreMorts: 2);

      expect(copie.nombreVivants, 6);
      expect(copie.nombreMorts, 2);
      expect(copie.nombreNes, original.nombreNes); // Non modifié
    });

    test('modifie les notes uniquement', () {
      final copie = original.copyWith(notes: 'Nouvelles notes');

      expect(copie.notes, 'Nouvelles notes');
      expect(copie.nombreVivants, original.nombreVivants); // Non modifié
    });
  });

  group('Portee - toString', () {
    test('retourne une représentation lisible', () {
      final portee = Portee(
        id: 1,
        accouplementId: 5,
        dateMiseBasReelle: DateTime(2025, 1, 15),
        nombreNes: 8,
        nombreVivants: 7,
        nombreMorts: 1,
      );

      final str = portee.toString();

      expect(str, contains('Portee'));
      expect(str, contains('id: 1'));
      expect(str, contains('accouplement: 5'));
      expect(str, contains('nés: 8'));
      expect(str, contains('vivants: 7'));
    });
  });

  group('Portee - Aller-retour toMap/fromMap', () {
    test('préserve toutes les données', () {
      final original = Portee(
        id: 99,
        accouplementId: 42,
        dateMiseBasReelle: DateTime(2025, 6, 15, 14, 30),
        nombreNes: 12,
        nombreVivants: 11,
        nombreMorts: 1,
        notes: 'Notes avec caractères spéciaux: éàü',
      );

      final map = original.toMap();
      final restaure = Portee.fromMap(map);

      expect(restaure.id, original.id);
      expect(restaure.accouplementId, original.accouplementId);
      expect(restaure.dateMiseBasReelle, original.dateMiseBasReelle);
      expect(restaure.nombreNes, original.nombreNes);
      expect(restaure.nombreVivants, original.nombreVivants);
      expect(restaure.nombreMorts, original.nombreMorts);
      expect(restaure.notes, original.notes);
    });
  });
}
