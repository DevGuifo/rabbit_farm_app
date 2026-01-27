import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/models/batiment.dart';
import 'package:rabbit_farm_app/models/clapier.dart';
import 'package:rabbit_farm_app/models/cage.dart';
import 'package:rabbit_farm_app/models/enums/localisation_enums.dart';

void main() {
  group('Batiment Model Tests', () {
    test('Création d\'un bâtiment avec paramètres requis', () {
      final batiment = Batiment(nom: 'Bâtiment A');

      expect(batiment.nom, 'Bâtiment A');
      expect(batiment.id, isNull);
      expect(batiment.description, isNull);
      expect(batiment.dateCreation, isNotNull);
    });

    test('Création d\'un bâtiment avec tous les paramètres', () {
      final date = DateTime(2024, 1, 15);
      final batiment = Batiment(
        id: 1,
        nom: 'Bâtiment Principal',
        description: 'Le bâtiment principal de l\'élevage',
        dateCreation: date,
      );

      expect(batiment.id, 1);
      expect(batiment.nom, 'Bâtiment Principal');
      expect(batiment.description, 'Le bâtiment principal de l\'élevage');
      expect(batiment.dateCreation, date);
    });

    test('toMap() génère le bon format', () {
      final date = DateTime(2024, 1, 15, 10, 30);
      final batiment = Batiment(
        id: 1,
        nom: 'Bâtiment A',
        description: 'Description test',
        dateCreation: date,
      );

      final map = batiment.toMap();

      expect(map['id'], 1);
      expect(map['nom'], 'Bâtiment A');
      expect(map['description'], 'Description test');
      expect(map['date_creation'], date.toIso8601String());
    });

    test('fromMap() crée un objet correct', () {
      final map = {
        'id': 2,
        'nom': 'Bâtiment B',
        'description': 'Test description',
        'date_creation': '2024-02-20T14:30:00.000',
      };

      final batiment = Batiment.fromMap(map);

      expect(batiment.id, 2);
      expect(batiment.nom, 'Bâtiment B');
      expect(batiment.description, 'Test description');
      expect(batiment.dateCreation.year, 2024);
      expect(batiment.dateCreation.month, 2);
      expect(batiment.dateCreation.day, 20);
    });

    test('copyWith() crée une copie avec modifications', () {
      final original = Batiment(id: 1, nom: 'Original');
      final copy = original.copyWith(nom: 'Modifié', description: 'Nouvelle description');

      expect(copy.id, 1); // Non modifié
      expect(copy.nom, 'Modifié'); // Modifié
      expect(copy.description, 'Nouvelle description'); // Ajouté
      expect(original.nom, 'Original'); // L'original n'est pas modifié
    });

    test('fromMap() avec description null', () {
      final map = {
        'id': 1,
        'nom': 'Bâtiment',
        'description': null,
        'date_creation': '2024-01-01T00:00:00.000',
      };

      final batiment = Batiment.fromMap(map);
      expect(batiment.description, isNull);
    });
  });

  group('Clapier Model Tests', () {
    test('Création d\'un clapier avec paramètres requis', () {
      final clapier = Clapier(
        batimentId: 1,
        nom: 'Zone A',
      );

      expect(clapier.batimentId, 1);
      expect(clapier.nom, 'Zone A');
      expect(clapier.type, TypeClapier.interieur); // Valeur par défaut
      expect(clapier.id, isNull);
      expect(clapier.description, isNull);
    });

    test('Création d\'un clapier avec tous les paramètres', () {
      final date = DateTime(2024, 3, 10);
      final clapier = Clapier(
        id: 1,
        batimentId: 2,
        nom: 'Quarantaine',
        type: TypeClapier.quarantaine,
        description: 'Zone d\'isolation',
        dateCreation: date,
      );

      expect(clapier.id, 1);
      expect(clapier.batimentId, 2);
      expect(clapier.nom, 'Quarantaine');
      expect(clapier.type, TypeClapier.quarantaine);
      expect(clapier.description, 'Zone d\'isolation');
      expect(clapier.dateCreation, date);
    });

    test('icone getter retourne la bonne icône', () {
      expect(Clapier(batimentId: 1, nom: 'A', type: TypeClapier.interieur).icone, 'meeting_room');
      expect(Clapier(batimentId: 1, nom: 'B', type: TypeClapier.exterieur).icone, 'grass');
      expect(Clapier(batimentId: 1, nom: 'C', type: TypeClapier.quarantaine).icone, 'health_and_safety');
      expect(Clapier(batimentId: 1, nom: 'D', type: TypeClapier.personnalise).icone, 'location_on');
    });

    test('icone getter est insensible à la casse', () {
      expect(Clapier(batimentId: 1, nom: 'A', type: TypeClapier.fromString('INTERIEUR')).icone, 'meeting_room');
      expect(Clapier(batimentId: 1, nom: 'B', type: TypeClapier.fromString('Exterieur')).icone, 'grass');
    });

    test('toMap() génère le bon format', () {
      final date = DateTime(2024, 4, 5);
      final clapier = Clapier(
        id: 3,
        batimentId: 2,
        nom: 'Zone Test',
        type: TypeClapier.exterieur,
        description: 'Description test',
        dateCreation: date,
      );

      final map = clapier.toMap();

      expect(map['id'], 3);
      expect(map['batiment_id'], 2);
      expect(map['nom'], 'Zone Test');
      expect(map['type'], 'exterieur');
      expect(map['description'], 'Description test');
      expect(map['date_creation'], date.toIso8601String());
    });

    test('fromMap() crée un objet correct', () {
      final map = {
        'id': 5,
        'batiment_id': 3,
        'nom': 'Zone Extérieure',
        'type': 'exterieur',
        'description': 'Partie extérieure',
        'date_creation': '2024-05-15T09:00:00.000',
      };

      final clapier = Clapier.fromMap(map);

      expect(clapier.id, 5);
      expect(clapier.batimentId, 3);
      expect(clapier.nom, 'Zone Extérieure');
      expect(clapier.type, 'exterieur');
      expect(clapier.description, 'Partie extérieure');
    });

    test('fromMap() utilise interieur comme type par défaut', () {
      final map = {
        'id': 1,
        'batiment_id': 1,
        'nom': 'Zone',
        'type': null,
        'date_creation': '2024-01-01T00:00:00.000',
      };

      final clapier = Clapier.fromMap(map);
      expect(clapier.type, 'interieur');
    });

    test('copyWith() crée une copie avec modifications', () {
      final original = Clapier(
        id: 1,
        batimentId: 1,
        nom: 'Original',
        type: TypeClapier.interieur,
      );
      final copy = original.copyWith(
        nom: 'Modifié',
        type: TypeClapier.quarantaine,
      );

      expect(copy.id, 1);
      expect(copy.batimentId, 1);
      expect(copy.nom, 'Modifié');
      expect(copy.type, TypeClapier.quarantaine);
      expect(original.nom, 'Original');
    });
  });

  group('Cage Model Tests', () {
    test('Création d\'une cage avec paramètres requis', () {
      final cage = Cage(
        clapierId: 1,
        numero: 'A-01',
        type: TypeCage.individuelle,
        capacite: 1,
      );

      expect(cage.clapierId, 1);
      expect(cage.numero, 'A-01');
      expect(cage.type, TypeCage.individuelle);
      expect(cage.capacite, 1);
      expect(cage.id, isNull);
      expect(cage.description, isNull);
    });

    test('Création d\'une cage collective', () {
      final cage = Cage(
        clapierId: 2,
        numero: 'B-COLL-01',
        type: TypeCage.collective,
        capacite: 6,
        description: 'Grande cage collective',
      );

      expect(cage.type, TypeCage.collective);
      expect(cage.capacite, 6);
      expect(cage.description, 'Grande cage collective');
    });

    group('getStatut() tests', () {
      late Cage cage;

      setUp(() {
        cage = Cage(
          clapierId: 1,
          numero: 'TEST-01',
          type: TypeCage.collective,
          capacite: 4,
        );
      });

      test('retourne "vide" quand occupants = 0', () {
        expect(cage.getStatut(0), 'vide');
      });

      test('retourne "normale" quand occupants < capacite', () {
        expect(cage.getStatut(1), 'normale');
        expect(cage.getStatut(2), 'normale');
        expect(cage.getStatut(3), 'normale');
      });

      test('retourne "pleine" quand occupants = capacite', () {
        expect(cage.getStatut(4), 'pleine');
      });

      test('retourne "surpeuplee" quand occupants > capacite', () {
        expect(cage.getStatut(5), 'surpeuplee');
        expect(cage.getStatut(10), 'surpeuplee');
      });
    });

    group('estDisponible() tests', () {
      late Cage cage;

      setUp(() {
        cage = Cage(
          clapierId: 1,
          numero: 'TEST-01',
          type: TypeCage.individuelle,
          capacite: 2,
        );
      });

      test('retourne true quand occupants < capacite', () {
        expect(cage.estDisponible(0), true);
        expect(cage.estDisponible(1), true);
      });

      test('retourne false quand occupants >= capacite', () {
        expect(cage.estDisponible(2), false);
        expect(cage.estDisponible(3), false);
      });
    });

    group('getCouleurStatut() tests', () {
      late Cage cage;

      setUp(() {
        cage = Cage(
          clapierId: 1,
          numero: 'TEST-01',
          type: TypeCage.individuelle,
          capacite: 2,
        );
      });

      test('retourne gris pour statut vide', () {
        expect(cage.getCouleurStatut(0), 0xFF9E9E9E);
      });

      test('retourne vert pour statut normale', () {
        expect(cage.getCouleurStatut(1), 0xFF4CAF50);
      });

      test('retourne orange pour statut pleine', () {
        expect(cage.getCouleurStatut(2), 0xFFFF9800);
      });

      test('retourne rouge pour statut surpeuplee', () {
        expect(cage.getCouleurStatut(3), 0xFFFF5722);
      });
    });

    test('toMap() génère le bon format', () {
      final date = DateTime(2024, 6, 20);
      final cage = Cage(
        id: 10,
        clapierId: 5,
        numero: 'A-INT-03',
        type: TypeCage.nid,
        capacite: 1,
        description: 'Cage nid pour mise bas',
        dateCreation: date,
      );

      final map = cage.toMap();

      expect(map['id'], 10);
      expect(map['clapier_id'], 5);
      expect(map['numero'], 'A-INT-03');
      expect(map['type'], 'nid');
      expect(map['capacite'], 1);
      expect(map['description'], 'Cage nid pour mise bas');
      expect(map['date_creation'], date.toIso8601String());
    });

    test('fromMap() crée un objet correct', () {
      final map = {
        'id': 7,
        'clapier_id': 3,
        'numero': 'B-EXT-05',
        'type': 'collective',
        'capacite': 8,
        'description': 'Grande cage extérieure',
        'date_creation': '2024-07-10T12:00:00.000',
      };

      final cage = Cage.fromMap(map);

      expect(cage.id, 7);
      expect(cage.clapierId, 3);
      expect(cage.numero, 'B-EXT-05');
      expect(cage.type, 'collective');
      expect(cage.capacite, 8);
      expect(cage.description, 'Grande cage extérieure');
    });

    test('copyWith() crée une copie avec modifications', () {
      final original = Cage(
        id: 1,
        clapierId: 1,
        numero: 'A-01',
        type: TypeCage.individuelle,
        capacite: 1,
      );
      final copy = original.copyWith(
        numero: 'A-02',
        capacite: 2,
        type: TypeCage.collective,
      );

      expect(copy.id, 1);
      expect(copy.clapierId, 1);
      expect(copy.numero, 'A-02');
      expect(copy.type, TypeCage.collective);
      expect(copy.capacite, 2);
      expect(original.numero, 'A-01');
      expect(original.capacite, 1);
    });
  });

  group('Tests d\'intégration des modèles de localisation', () {
    test('Relation Batiment -> Clapier -> Cage', () {
      final batiment = Batiment(id: 1, nom: 'Bâtiment Principal');
      final clapier = Clapier(
        id: 1,
        batimentId: batiment.id!,
        nom: 'Zone Intérieure',
        type: TypeClapier.interieur,
      );
      final cage = Cage(
        id: 1,
        clapierId: clapier.id!,
        numero: 'A-INT-01',
        type: TypeCage.individuelle,
        capacite: 1,
      );

      expect(clapier.batimentId, batiment.id);
      expect(cage.clapierId, clapier.id);
    });

    test('Gestion complète d\'une hiérarchie', () {
      // Simule une structure complète - le batiment et clapiers sont utilisés
      // pour définir la hiérarchie, les cages référencent les clapiers par ID
      // ignore: unused_local_variable
      final batiment = Batiment(id: 1, nom: 'A');
      
      // ignore: unused_local_variable
      final clapiers = [
        Clapier(id: 1, batimentId: 1, nom: 'Intérieur', type: TypeClapier.interieur),
        Clapier(id: 2, batimentId: 1, nom: 'Extérieur', type: TypeClapier.exterieur),
      ];

      final cages = [
        Cage(id: 1, clapierId: 1, numero: 'A-INT-01', type: TypeCage.individuelle, capacite: 1),
        Cage(id: 2, clapierId: 1, numero: 'A-INT-02', type: TypeCage.individuelle, capacite: 1),
        Cage(id: 3, clapierId: 2, numero: 'A-EXT-01', type: TypeCage.collective, capacite: 4),
      ];

      // Vérifier que les cages du clapier 1 sont correctement liées
      final cagesClapier1 = cages.where((c) => c.clapierId == 1).toList();
      expect(cagesClapier1.length, 2);
      expect(cagesClapier1.every((c) => c.numero.contains('INT')), true);

      // Vérifier que les cages du clapier 2 sont correctement liées  
      final cagesClapier2 = cages.where((c) => c.clapierId == 2).toList();
      expect(cagesClapier2.length, 1);
      expect(cagesClapier2.first.type, TypeCage.collective);
    });

    test('Calcul de capacité totale d\'un clapier', () {
      final cages = [
        Cage(id: 1, clapierId: 1, numero: 'A-01', type: TypeCage.individuelle, capacite: 1),
        Cage(id: 2, clapierId: 1, numero: 'A-02', type: TypeCage.individuelle, capacite: 1),
        Cage(id: 3, clapierId: 1, numero: 'A-03', type: TypeCage.collective, capacite: 4),
        Cage(id: 4, clapierId: 1, numero: 'A-04', type: TypeCage.collective, capacite: 6),
      ];

      final capaciteTotale = cages.fold<int>(0, (sum, cage) => sum + cage.capacite);
      expect(capaciteTotale, 12);
    });

    test('Filtrage des cages disponibles', () {
      final cages = [
        Cage(id: 1, clapierId: 1, numero: 'A-01', type: TypeCage.individuelle, capacite: 1),
        Cage(id: 2, clapierId: 1, numero: 'A-02', type: TypeCage.individuelle, capacite: 1),
        Cage(id: 3, clapierId: 1, numero: 'A-03', type: TypeCage.collective, capacite: 4),
      ];

      final occupations = {1: 1, 2: 0, 3: 2}; // cage_id: nb_occupants

      final disponibles = cages.where((cage) {
        final occupants = occupations[cage.id] ?? 0;
        return cage.estDisponible(occupants);
      }).toList();

      expect(disponibles.length, 2); // A-02 (vide) et A-03 (2/4)
      expect(disponibles.map((c) => c.numero).toList(), ['A-02', 'A-03']);
    });
  });
}
