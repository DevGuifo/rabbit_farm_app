import 'package:sqflite/sqflite.dart';
import '../../models/batiment.dart';
import '../../models/clapier.dart';
import '../../models/cage.dart';
import 'database_base.dart';
import '../../core/exceptions/validation_exception.dart';

/// Mixin pour les opérations de base de données liées à la localisation
///
/// Ce mixin gère les opérations CRUD pour :
/// - Bâtiments (structures principales)
/// - Clapiers (zones/sections dans un bâtiment)
/// - Cages (emplacements individuels dans un clapier)
///
/// ## Hiérarchie
/// ```
/// Bâtiment
///   └── Clapier
///         └── Cage
///               └── Lapin (via localisation)
/// ```
///
/// ## Usage
/// Ce mixin est appliqué à DatabaseHelper :
/// ```dart
/// class DatabaseHelper extends DatabaseBase with LocalisationDatabaseMixin {
///   // ...
/// }
/// ```
mixin LocalisationDatabaseMixin on DatabaseBase {
  // ============= OPÉRATIONS SUR LES BÂTIMENTS =============

  /// Insérer un bâtiment
  Future<Batiment> insertBatiment(Batiment batiment) async {
    final db = await database;
    final map = await prepareDataForInsert(
      batiment.toMap(),
      tableName: 'batiments',
    );
    final id = await db.insert('batiments', map);
    return batiment.copyWith(id: id);
  }

  /// Récupérer tous les bâtiments
  Future<List<Batiment>> getAllBatiments() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'batiments',
    );

    final result = await db.query(
      'batiments',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'nom ASC',
    );
    return result.map((json) => Batiment.fromMap(json)).toList();
  }

  /// Récupérer un bâtiment par ID
  Future<Batiment?> getBatimentById(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'batiments',
    );

    final maps = await db.query(
      'batiments',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Batiment.fromMap(maps.first);
  }

  /// Mettre à jour un bâtiment
  Future<int> updateBatiment(Batiment batiment) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final map = batiment.toMap();
    final filteredMap = await filterColumnsForUpdate(map, 'batiments');

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [batiment.id],
      userId,
      tableName: 'batiments',
    );

    return db.update(
      'batiments',
      filteredMap,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Supprimer un bâtiment (cascade sur clapiers et cages)
  Future<int> deleteBatiment(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'batiments',
    );

    return await db.delete('batiments', where: where, whereArgs: whereArgs);
  }

  /// Compter le nombre de bâtiments
  Future<int> countBatiments() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'batiments',
    );

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM batiments${' WHERE $where'}',
      whereArgs.isEmpty ? null : whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ============= OPÉRATIONS SUR LES CLAPIERS =============

  /// Insérer un clapier
  Future<Clapier> insertClapier(Clapier clapier) async {
    final db = await database;
    final map = await prepareDataForInsert(
      clapier.toMap(),
      tableName: 'clapiers',
    );
    final id = await db.insert('clapiers', map);
    return clapier.copyWith(id: id);
  }

  /// Récupérer tous les clapiers d'un bâtiment
  Future<List<Clapier>> getClapiersByBatiment(int batimentId) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'batiment_id = ?',
      [batimentId],
      userId,
      tableName: 'clapiers',
    );

    final result = await db.query(
      'clapiers',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'nom ASC',
    );
    return result.map((json) => Clapier.fromMap(json)).toList();
  }

  /// Récupérer tous les clapiers
  Future<List<Clapier>> getAllClapiers() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'clapiers',
    );

    final result = await db.query(
      'clapiers',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'nom ASC',
    );
    return result.map((json) => Clapier.fromMap(json)).toList();
  }

  /// Récupérer un clapier par ID
  Future<Clapier?> getClapierById(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'clapiers',
    );

    final maps = await db.query(
      'clapiers',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Clapier.fromMap(maps.first);
  }

  /// Mettre à jour un clapier
  Future<int> updateClapier(Clapier clapier) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final map = clapier.toMap();
    final filteredMap = await filterColumnsForUpdate(map, 'clapiers');

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [clapier.id],
      userId,
      tableName: 'clapiers',
    );

    return db.update(
      'clapiers',
      filteredMap,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Supprimer un clapier (cascade sur cages)
  Future<int> deleteClapier(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'clapiers',
    );

    return await db.delete('clapiers', where: where, whereArgs: whereArgs);
  }

  /// Compter le nombre de clapiers dans un bâtiment
  Future<int> countClapiersByBatiment(int batimentId) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'batiment_id = ?',
      [batimentId],
      userId,
      tableName: 'clapiers',
    );

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM clapiers WHERE $where',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ============= OPÉRATIONS SUR LES CAGES =============

  /// Insérer une cage
  Future<Cage> insertCage(Cage cage) async {
    final db = await database;
    final map = await prepareDataForInsert(cage.toMap(), tableName: 'cages');
    final id = await db.insert('cages', map);
    return cage.copyWith(id: id);
  }

  /// Récupérer toutes les cages d'un clapier
  Future<List<Cage>> getCagesByClapier(int clapierId) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'clapier_id = ?',
      [clapierId],
      userId,
      tableName: 'cages',
    );

    final result = await db.query(
      'cages',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'numero ASC',
    );
    return result.map((json) => Cage.fromMap(json)).toList();
  }

  /// Récupérer toutes les cages
  Future<List<Cage>> getAllCages() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'cages',
    );

    final result = await db.query(
      'cages',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'numero ASC',
    );
    return result.map((json) => Cage.fromMap(json)).toList();
  }

  /// Récupérer une cage par ID
  Future<Cage?> getCageById(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'cages',
    );

    final maps = await db.query(
      'cages',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Cage.fromMap(maps.first);
  }

  /// Récupérer une cage par numéro
  Future<Cage?> getCageByNumero(String numero) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'numero = ?',
      [numero],
      userId,
      tableName: 'cages',
    );

    final maps = await db.query(
      'cages',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Cage.fromMap(maps.first);
  }

  /// Mettre à jour une cage
  Future<int> updateCage(Cage cage) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final map = cage.toMap();
    final filteredMap = await filterColumnsForUpdate(map, 'cages');

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [cage.id],
      userId,
      tableName: 'cages',
    );

    return db.update('cages', filteredMap, where: where, whereArgs: whereArgs);
  }

  /// Supprimer une cage (vérifie les occupants d'abord)
  Future<int> deleteCage(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();

    // 🔒 SECURITÉ P0.2 : Vérifier les occupants avant suppression
    final occupants = await getOccupantsCage(id);
    if (occupants > 0) {
      throw ValidationException(
        reason:
            'Impossible de supprimer cette cage car elle contient $occupants lapin(s). '
            'Veuillez d\'abord déplacer ou retirer les lapins.',
      );
    }

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'cages',
    );

    return await db.delete('cages', where: where, whereArgs: whereArgs);
  }

  /// Compter le nombre de cages dans un clapier
  Future<int> countCagesByClapier(int clapierId) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'clapier_id = ?',
      [clapierId],
      userId,
      tableName: 'cages',
    );

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM cages WHERE $where',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Compter le nombre total de cages
  Future<int> countAllCages() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'cages',
    );

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM cages${' WHERE $where'}',
      whereArgs.isEmpty ? null : whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Obtenir le nombre d'occupants d'une cage
  Future<int> getOccupantsCage(int cageId) async {
    final db = await database;
    // ✅ P0.2 : Utilisation de la FK cage_id (plus sûr que le string localisation)
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM lapins WHERE cage_id = ?',
      [cageId],
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

  /// Vérifier si une cage est disponible (pas pleine)
  Future<bool> isCageDisponible(int cageId) async {
    final cage = await getCageById(cageId);
    if (cage == null) return false;

    final occupants = await getOccupantsCage(cageId);
    return occupants < cage.capacite;
  }

  /// Obtenir la capacité restante d'une cage
  Future<int> getCapaciteRestanteCage(int cageId) async {
    final cage = await getCageById(cageId);
    if (cage == null) return 0;

    final occupants = await getOccupantsCage(cageId);
    return cage.capacite - occupants;
  }

  /// Obtenir les cages disponibles (avec de la place)
  Future<List<Map<String, dynamic>>> getCagesDisponibles() async {
    final db = await database;

    // Requête pour obtenir les cages avec leur occupation
    final result = await db.rawQuery('''
      SELECT 
        c.id as cageId,
        c.numero as cageNumero,
        c.capacite as cageCapacite,
        c.type as cageType,
        cl.nom as clapierNom,
        b.nom as batimentNom,
        COALESCE(
          (SELECT COUNT(*) FROM lapins l WHERE l.localisation = c.numero),
          0
        ) as occupantCount
      FROM cages c
      JOIN clapiers cl ON c.clapier_id = cl.id
      JOIN batiments b ON cl.batiment_id = b.id
      HAVING occupantCount < c.capacite
      ORDER BY b.nom, cl.nom, c.numero
    ''');

    return result;
  }

  // ============= STATISTIQUES =============

  /// Statistiques globales de localisation
  Future<Map<String, dynamic>> getStatistiquesLocalisation() async {
    final db = await database;

    final batimentsCount = await countBatiments();

    final clapiersResult = await db.rawQuery('SELECT COUNT(*) FROM clapiers');
    final clapiersCount = Sqflite.firstIntValue(clapiersResult) ?? 0;

    final cagesResult = await db.rawQuery('SELECT COUNT(*) FROM cages');
    final cagesCount = Sqflite.firstIntValue(cagesResult) ?? 0;

    final capaciteResult = await db.rawQuery('SELECT SUM(capacite) FROM cages');
    final capaciteTotale = Sqflite.firstIntValue(capaciteResult) ?? 0;

    final occupantsResult = await db.rawQuery('''
      SELECT COUNT(*) FROM lapins l 
      WHERE l.localisation IS NOT NULL AND l.localisation != ''
    ''');
    final occupantsTotal = Sqflite.firstIntValue(occupantsResult) ?? 0;

    return {
      'batiments': batimentsCount,
      'clapiers': clapiersCount,
      'cages': cagesCount,
      'capaciteTotale': capaciteTotale,
      'occupantsTotal': occupantsTotal,
      'tauxOccupation': capaciteTotale > 0
          ? (occupantsTotal / capaciteTotale * 100).round()
          : 0,
    };
  }
}
