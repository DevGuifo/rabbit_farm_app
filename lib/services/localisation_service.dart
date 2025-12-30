import 'package:sqflite/sqflite.dart';
import '../models/batiment.dart';
import '../models/clapier.dart';
import '../models/cage.dart';
import 'database_helper.dart';

/// Extension pour gérer la hiérarchie de localisation
extension LocalisationExtension on DatabaseHelper {
  // ========== BÂTIMENTS ==========

  /// Créer les tables de localisation
  Future<void> createLocalisationTables(Database db) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';

    // Table des bâtiments
    await db.execute('''
      CREATE TABLE IF NOT EXISTS batiments (
        id $idType,
        nom $textType,
        description $textTypeNullable,
        date_creation $textType
      )
    ''');

    // Table des clapiers/zones
    await db.execute('''
      CREATE TABLE IF NOT EXISTS clapiers (
        id $idType,
        batiment_id INTEGER NOT NULL,
        nom $textType,
        type $textType,
        description $textTypeNullable,
        date_creation $textType,
        FOREIGN KEY (batiment_id) REFERENCES batiments (id) ON DELETE CASCADE
      )
    ''');

    // Table des cages
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cages (
        id $idType,
        clapier_id INTEGER NOT NULL,
        numero $textType,
        type $textType,
        capacite INTEGER NOT NULL,
        description $textTypeNullable,
        date_creation $textType,
        FOREIGN KEY (clapier_id) REFERENCES clapiers (id) ON DELETE CASCADE
      )
    ''');

    // Créer index pour améliorer les performances
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_clapiers_batiment ON clapiers(batiment_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cages_clapier ON cages(clapier_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_lapins_localisation ON lapins(localisation)',
    );
  }

  /// Ajouter un bâtiment
  Future<int> ajouterBatiment(Batiment batiment) async {
    final db = await database;
    return await db.insert('batiments', batiment.toMap());
  }

  /// Obtenir tous les bâtiments
  Future<List<Batiment>> getAllBatiments() async {
    final db = await database;
    final maps = await db.query('batiments', orderBy: 'nom ASC');
    return maps.map((map) => Batiment.fromMap(map)).toList();
  }

  /// Obtenir un bâtiment par ID
  Future<Batiment?> getBatimentById(int id) async {
    final db = await database;
    final maps = await db.query(
      'batiments',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Batiment.fromMap(maps.first);
  }

  /// Modifier un bâtiment
  Future<int> modifierBatiment(Batiment batiment) async {
    final db = await database;
    return await db.update(
      'batiments',
      batiment.toMap(),
      where: 'id = ?',
      whereArgs: [batiment.id],
    );
  }

  /// Supprimer un bâtiment
  Future<int> supprimerBatiment(int id) async {
    final db = await database;
    return await db.delete('batiments', where: 'id = ?', whereArgs: [id]);
  }

  // ========== CLAPIERS ==========

  /// Ajouter un clapier
  Future<int> ajouterClapier(Clapier clapier) async {
    final db = await database;
    return await db.insert('clapiers', clapier.toMap());
  }

  /// Obtenir tous les clapiers d'un bâtiment
  Future<List<Clapier>> getClapiersByBatiment(int batimentId) async {
    final db = await database;
    final maps = await db.query(
      'clapiers',
      where: 'batiment_id = ?',
      whereArgs: [batimentId],
      orderBy: 'nom ASC',
    );
    return maps.map((map) => Clapier.fromMap(map)).toList();
  }

  /// Obtenir un clapier par ID
  Future<Clapier?> getClapierById(int id) async {
    final db = await database;
    final maps = await db.query(
      'clapiers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Clapier.fromMap(maps.first);
  }

  /// Modifier un clapier
  Future<int> modifierClapier(Clapier clapier) async {
    final db = await database;
    return await db.update(
      'clapiers',
      clapier.toMap(),
      where: 'id = ?',
      whereArgs: [clapier.id],
    );
  }

  /// Supprimer un clapier
  Future<int> supprimerClapier(int id) async {
    final db = await database;
    return await db.delete('clapiers', where: 'id = ?', whereArgs: [id]);
  }

  // ========== CAGES ==========

  /// Ajouter une cage
  Future<int> ajouterCage(Cage cage) async {
    final db = await database;
    return await db.insert('cages', cage.toMap());
  }

  /// Obtenir toutes les cages d'un clapier
  Future<List<Cage>> getCagesByClapier(int clapierId) async {
    final db = await database;
    final maps = await db.query(
      'cages',
      where: 'clapier_id = ?',
      whereArgs: [clapierId],
      orderBy: 'numero ASC',
    );
    return maps.map((map) => Cage.fromMap(map)).toList();
  }

  /// Obtenir une cage par ID
  Future<Cage?> getCageById(int id) async {
    final db = await database;
    final maps = await db.query(
      'cages',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Cage.fromMap(maps.first);
  }

  /// Obtenir une cage par numéro
  Future<Cage?> getCageByNumero(String numero) async {
    final db = await database;
    final maps = await db.query(
      'cages',
      where: 'numero = ?',
      whereArgs: [numero],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Cage.fromMap(maps.first);
  }

  /// Modifier une cage
  Future<int> modifierCage(Cage cage) async {
    final db = await database;
    return await db.update(
      'cages',
      cage.toMap(),
      where: 'id = ?',
      whereArgs: [cage.id],
    );
  }

  /// Supprimer une cage
  Future<int> supprimerCage(int id) async {
    final db = await database;
    // Vérifier qu'elle est vide
    final occupants = await getOccupantsCage(id);
    if (occupants > 0) {
      throw Exception('Impossible de supprimer une cage occupée');
    }
    return await db.delete('cages', where: 'id = ?', whereArgs: [id]);
  }

  /// Obtenir le nombre d'occupants d'une cage
  Future<int> getOccupantsCage(int cageId) async {
    final db = await database;
    final cage = await getCageById(cageId);
    if (cage == null) return 0;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM lapins WHERE localisation = ?',
      [cage.numero],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Obtenir le nombre d'occupants par numéro de cage
  Future<int> getOccupantsCageByNumero(String numero) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM lapins WHERE localisation = ?',
      [numero],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Obtenir les cages disponibles (non pleines)
  Future<List<Map<String, dynamic>>> getCagesDisponibles() async {
    final db = await database;
    final cages = await db.query('cages');

    List<Map<String, dynamic>> cagesDisponibles = [];
    for (var cageMap in cages) {
      final cage = Cage.fromMap(cageMap);
      final occupants = await getOccupantsCage(cage.id!);

      if (cage.estDisponible(occupants)) {
        // Retourner les données dans le format attendu par tous les écrans
        cagesDisponibles.add({
          // Données du modèle Cage
          'id': cage.id,
          'clapier_id': cage.clapierId,
          'numero': cage.numero,
          'type': cage.type,
          'capacite': cage.capacite,
          'description': cage.description,
          'date_creation': cage.dateCreation.toIso8601String(),
          // Données calculées
          'occupants_actuels': occupants,
          'disponible': cage.capacite - occupants,
          'statut': cage.getStatut(occupants),
        });
      }
    }

    return cagesDisponibles;
  }

  /// Obtenir les cages disponibles d'un clapier spécifique
  Future<List<Map<String, dynamic>>> getCagesDisponiblesByClapier(
    int clapierId,
  ) async {
    final cages = await getCagesByClapier(clapierId);
    List<Map<String, dynamic>> cagesDisponibles = [];

    for (var cage in cages) {
      final occupants = await getOccupantsCage(cage.id!);

      if (cage.estDisponible(occupants)) {
        cagesDisponibles.add({
          'id': cage.id,
          'clapier_id': cage.clapierId,
          'numero': cage.numero,
          'type': cage.type,
          'capacite': cage.capacite,
          'description': cage.description,
          'date_creation': cage.dateCreation.toIso8601String(),
          'occupants_actuels': occupants,
          'disponible': cage.capacite - occupants,
          'statut': cage.getStatut(occupants),
        });
      }
    }

    return cagesDisponibles;
  }

  /// Vérifier si une cage peut accueillir un nouveau lapin
  Future<bool> cagePeutAccueillir(String numeroCage) async {
    final cage = await getCageByNumero(numeroCage);
    if (cage == null) return false;

    final occupants = await getOccupantsCageByNumero(numeroCage);
    return cage.estDisponible(occupants);
  }

  /// Déplacer un lapin vers une nouvelle cage
  Future<void> deplacerLapin(int lapinId, String nouveauNumeroCage) async {
    // Vérifier que la cage cible peut accueillir le lapin
    final peutAccueillir = await cagePeutAccueillir(nouveauNumeroCage);
    if (!peutAccueillir) {
      throw Exception('La cage est pleine');
    }

    final db = await database;
    await db.update(
      'lapins',
      {'localisation': nouveauNumeroCage},
      where: 'id = ?',
      whereArgs: [lapinId],
    );
  }

  /// Obtenir la hiérarchie complète : Bâtiment > Clapier > Cage
  Future<Map<String, dynamic>> getHierarchieComplete() async {
    final batiments = await getAllBatiments();
    List<Map<String, dynamic>> hierarchie = [];

    for (var batiment in batiments) {
      final clapiers = await getClapiersByBatiment(batiment.id!);
      List<Map<String, dynamic>> clapiersData = [];

      for (var clapier in clapiers) {
        final cages = await getCagesByClapier(clapier.id!);
        List<Map<String, dynamic>> cagesData = [];

        for (var cage in cages) {
          final occupants = await getOccupantsCage(cage.id!);
          cagesData.add({
            'cage': cage,
            'occupants': occupants,
            'statut': cage.getStatut(occupants),
            'disponible': cage.estDisponible(occupants),
          });
        }

        clapiersData.add({'clapier': clapier, 'cages': cagesData});
      }

      hierarchie.add({'batiment': batiment, 'clapiers': clapiersData});
    }

    return {'hierarchie': hierarchie};
  }

  /// Générer un numéro de cage automatique
  Future<String> genererNumeroCage(int clapierId) async {
    final clapier = await getClapierById(clapierId);
    if (clapier == null) throw Exception('Clapier introuvable');

    final batiment = await getBatimentById(clapier.batimentId);
    if (batiment == null) throw Exception('Bâtiment introuvable');

    final cages = await getCagesByClapier(clapierId);
    final numero = cages.length + 1;

    // Format: BATIMENT-TYPE-NUMERO
    final typeAbrege = clapier.type.substring(0, 3).toUpperCase();
    return '${batiment.nom}-$typeAbrege-${numero.toString().padLeft(2, '0')}';
  }

  /// Initialiser des données par défaut
  Future<void> initialiserLocalisationParDefaut() async {
    final batiments = await getAllBatiments();
    if (batiments.isNotEmpty) return; // Déjà initialisé

    // Créer bâtiment par défaut
    final batimentId = await ajouterBatiment(
      Batiment(nom: 'A', description: 'Bâtiment principal'),
    );

    // Créer clapier par défaut
    final clapierId = await ajouterClapier(
      Clapier(batimentId: batimentId, nom: 'Intérieur', type: 'interieur'),
    );

    // Créer quelques cages par défaut
    for (int i = 1; i <= 5; i++) {
      await ajouterCage(
        Cage(
          clapierId: clapierId,
          numero: 'A-INT-${i.toString().padLeft(2, '0')}',
          type: i == 5 ? 'nid' : 'individuelle',
          capacite: i == 5 ? 1 : 1,
        ),
      );
    }
  }
}
