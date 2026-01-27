import 'package:sqflite/sqflite.dart';
import '../../models/accouplement.dart';
import '../../models/portee.dart';
import '../../utils/logger.dart';
import 'database_base.dart';

/// Mixin contenant les opérations CRUD pour la reproduction
///
/// Ce mixin encapsule toute la logique base de données relative à la reproduction :
/// - CRUD accouplements
/// - CRUD portées
/// - Filtres (par statut, par femelle, par mâle)
///
/// ## Usage
///
/// Ce mixin est appliqué à `DatabaseHelper` :
/// ```dart
/// class DatabaseHelper with ReproductionDatabaseMixin { ... }
/// ```
///
/// ## Tables concernées
/// - `accouplements` : enregistrements des accouplements
/// - `portees` : résultats des mises bas
mixin ReproductionDatabaseMixin on DatabaseBase {
  // ============= OPÉRATIONS CRUD SUR LES ACCOUPLEMENTS =============

  /// Insérer un accouplement dans la base de données
  ///
  /// Définit automatiquement user_id si disponible
  Future<Accouplement> insertAccouplement(Accouplement accouplement) async {
    final db = await database;
    final map = await prepareDataForInsert(
      accouplement.toMap(),
      tableName: 'accouplements',
    );
    final id = await db.insert('accouplements', map);
    return accouplement.copyWith(id: id);
  }

  /// Récupérer tous les accouplements
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Accouplement>> getAllAccouplements() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'accouplements',
    );
    final result = await db.query(
      'accouplements',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date_accouplement DESC',
    );
    return result.map((json) => Accouplement.fromMap(json)).toList();
  }

  /// Récupérer un accouplement par son ID
  ///
  /// Vérifie que l'accouplement appartient à l'utilisateur connecté
  Future<Accouplement?> getAccouplementById(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'accouplements',
    );
    final maps = await db.query(
      'accouplements',
      where: where,
      whereArgs: whereArgs,
    );

    if (maps.isNotEmpty) {
      return Accouplement.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Mettre à jour un accouplement
  ///
  /// Vérifie que l'accouplement appartient à l'utilisateur connecté
  /// Définit automatiquement updated_at et is_dirty
  Future<int> updateAccouplement(Accouplement accouplement) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final map = accouplement.toMap();
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await filterColumnsForUpdate(map, 'accouplements');

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [accouplement.id],
      userId,
      tableName: 'accouplements',
    );
    return db.update(
      'accouplements',
      filteredMap,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Supprimer un accouplement
  ///
  /// Vérifie que l'accouplement appartient à l'utilisateur connecté
  /// Utilise soft delete pour la synchronisation
  Future<int> deleteAccouplement(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await filterColumnsForUpdate(
      updateData,
      'accouplements',
    );

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'accouplements',
    );
    return await db.update(
      'accouplements',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Récupérer les accouplements par statut
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Accouplement>> getAccouplementsByStatut(String statut) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'statut = ?',
      [statut],
      userId,
      tableName: 'accouplements',
    );
    final result = await db.query(
      'accouplements',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date_accouplement DESC',
    );
    return result.map((json) => Accouplement.fromMap(json)).toList();
  }

  /// Récupérer les accouplements en attente (à venir)
  Future<List<Accouplement>> getAccouplementsEnAttente() async {
    return await getAccouplementsByStatut('en_attente');
  }

  /// Récupérer les accouplements d'une femelle
  Future<List<Accouplement>> getAccouplementsByFemelle(int femelleId) async {
    final db = await database;
    final result = await db.query(
      'accouplements',
      where: 'femelle_id = ?',
      whereArgs: [femelleId],
      orderBy: 'date_accouplement DESC',
    );
    return result.map((json) => Accouplement.fromMap(json)).toList();
  }

  /// Récupérer les accouplements d'un mâle
  Future<List<Accouplement>> getAccouplementsByMale(int maleId) async {
    final db = await database;
    final result = await db.query(
      'accouplements',
      where: 'male_id = ?',
      whereArgs: [maleId],
      orderBy: 'date_accouplement DESC',
    );
    return result.map((json) => Accouplement.fromMap(json)).toList();
  }

  /// Compter les accouplements par statut
  Future<int> countAccouplementsByStatut(String statut) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'statut = ?',
      [statut],
      userId,
      tableName: 'accouplements',
    );
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM accouplements WHERE $where',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ============= OPÉRATIONS CRUD SUR LES PORTÉES =============

  /// Insérer une portée dans la base de données
  ///
  /// Définit automatiquement user_id si disponible
  Future<Portee> insertPortee(Portee portee) async {
    final db = await database;
    final map = await prepareDataForInsert(
      portee.toMap(),
      tableName: 'portees',
    );
    final id = await db.insert('portees', map);
    return portee.copyWith(id: id);
  }

  /// Récupérer toutes les portées
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Portee>> getAllPortees() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'portees',
    );
    final result = await db.query(
      'portees',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date_mise_bas_reelle DESC',
    );
    return result.map((json) => Portee.fromMap(json)).toList();
  }

  /// Récupérer une portée par son ID
  Future<Portee?> getPorteeById(int id) async {
    final db = await database;
    final maps = await db.query('portees', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Portee.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Récupérer la portée d'un accouplement
  Future<Portee?> getPorteeByAccouplement(int accouplementId) async {
    final db = await database;
    final maps = await db.query(
      'portees',
      where: 'accouplement_id = ?',
      whereArgs: [accouplementId],
    );

    if (maps.isNotEmpty) {
      return Portee.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Mettre à jour une portée
  Future<int> updatePortee(Portee portee) async {
    final db = await database;
    final map = portee.toMap();
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await filterColumnsForUpdate(map, 'portees');

    return db.update(
      'portees',
      filteredMap,
      where: 'id = ?',
      whereArgs: [portee.id],
    );
  }

  /// Supprimer une portée
  ///
  /// Utilise soft delete pour la synchronisation
  Future<int> deletePortee(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await filterColumnsForUpdate(updateData, 'portees');

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'portees',
    );
    return await db.update(
      'portees',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Compter les portées de l'année en cours
  Future<int> countPorteesAnnee(int annee) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final debut = '$annee-01-01';
    final fin = '$annee-12-31';

    final (where, whereArgs) = await buildWhereWithUserId(
      "date_mise_bas_reelle BETWEEN ? AND ?",
      [debut, fin],
      userId,
      tableName: 'portees',
    );
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM portees WHERE $where',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Calculer le taux de mortalité des portées
  Future<double> getTauxMortalitePortees() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'portees',
    );
    final result = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(nombre_nes), 0) as total_nes,
        COALESCE(SUM(nombre_morts), 0) as total_morts
      FROM portees
      WHERE $where
    ''', whereArgs);

    if (result.isEmpty) return 0.0;

    final totalNes = (result.first['total_nes'] as num?)?.toDouble() ?? 0;
    final totalMorts = (result.first['total_morts'] as num?)?.toDouble() ?? 0;

    if (totalNes == 0) return 0.0;
    return (totalMorts / totalNes) * 100;
  }

  /// Créer une portée et mettre à jour l'accouplement en une transaction atomique
  ///
  /// Cette méthode garantit que la création de la portée et la mise à jour
  /// du statut de l'accouplement se font de manière atomique.
  ///
  /// Si une erreur survient, les deux opérations sont annulées.
  Future<Portee> creerPorteeComplete({
    required Portee portee,
    required int accouplementId,
  }) async {
    final db = await database;

    return await db.transaction((txn) async {
      // 1. Insérer la portée
      final porteeMap = await prepareDataForInsert(
        portee.toMap(),
        tableName: 'portees',
      );
      final porteeId = await txn.insert('portees', porteeMap);

      // 2. Mettre à jour le statut de l'accouplement à 'termine'
      await txn.update(
        'accouplements',
        {'statut': 'termine'},
        where: 'id = ?',
        whereArgs: [accouplementId],
      );

      logger.info(
        '✅ Portée créée et accouplement mis à jour (transaction atomique)',
      );

      return portee.copyWith(id: porteeId);
    });
  }

  /// Supprimer un accouplement et ses données liées en une transaction atomique
  ///
  /// Supprime : portées, palpations, préparations nid, sevrages
  Future<void> supprimerAccouplementComplet(int accouplementId) async {
    final db = await database;

    await db.transaction((txn) async {
      // Les FK CASCADE vont supprimer automatiquement :
      // - portees
      // - palpations
      // - preparations_nid
      // Et via portees CASCADE :
      // - sevrages

      await txn.delete(
        'accouplements',
        where: 'id = ?',
        whereArgs: [accouplementId],
      );

      logger.info(
        '✅ Accouplement $accouplementId supprimé avec données liées (transaction atomique)',
      );
    });
  }
}
