import '../../models/pesee.dart';
import '../../models/soin.dart';
import '../../models/medicament.dart';
import 'database_base.dart';

/// Mixin contenant les opérations CRUD pour la santé des lapins
/// 
/// Ce mixin encapsule toute la logique base de données relative à la santé :
/// - CRUD pesées
/// - CRUD soins
/// - CRUD médicaments
/// 
/// ## Usage
/// 
/// Ce mixin est appliqué à `DatabaseHelper` :
/// ```dart
/// class DatabaseHelper with SanteDatabaseMixin { ... }
/// ```
/// 
/// ## Tables concernées
/// - `pesees` : historique des pesées
/// - `soins` : traitements et vaccinations
/// - `medicaments` : stock de médicaments
mixin SanteDatabaseMixin on DatabaseBase {
  // ============= OPÉRATIONS CRUD SUR LES PESÉES =============

  /// Insérer une pesée dans la base de données
  ///
  /// Définit automatiquement user_id si disponible
  Future<Pesee> insertPesee(Pesee pesee) async {
    final db = await database;
    final map = await prepareDataForInsert(pesee.toMap(), tableName: 'pesees');
    final id = await db.insert('pesees', map);
    return pesee.copyWith(id: id);
  }

  /// Récupérer toutes les pesées
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Pesee>> getAllPesees() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'pesees',
    );
    final result = await db.query(
      'pesees',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
    );
    return result.map((json) => Pesee.fromMap(json)).toList();
  }

  /// Récupérer les pesées d'un lapin
  Future<List<Pesee>> getPeseesByLapin(int lapinId) async {
    final db = await database;
    final result = await db.query(
      'pesees',
      where: 'lapin_id = ?',
      whereArgs: [lapinId],
      orderBy: 'date ASC',
    );
    return result.map((json) => Pesee.fromMap(json)).toList();
  }

  /// Récupérer la dernière pesée d'un lapin
  Future<Pesee?> getDernierePesee(int lapinId) async {
    final db = await database;
    final result = await db.query(
      'pesees',
      where: 'lapin_id = ?',
      whereArgs: [lapinId],
      orderBy: 'date DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Pesee.fromMap(result.first);
    }
    return null;
  }

  /// Mettre à jour une pesée
  Future<int> updatePesee(Pesee pesee) async {
    final db = await database;
    final map = pesee.toMap();
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await filterColumnsForUpdate(map, 'pesees');

    return db.update(
      'pesees',
      filteredMap,
      where: 'id = ?',
      whereArgs: [pesee.id],
    );
  }

  /// Supprimer une pesée
  ///
  /// Utilise soft delete pour la synchronisation
  Future<int> deletePesee(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await filterColumnsForUpdate(updateData, 'pesees');

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'pesees',
    );
    return await db.update(
      'pesees',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Récupérer les pesées par période
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Pesee>> getPeseesByPeriode(DateTime debut, DateTime fin) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'date >= ? AND date <= ?',
      [debut.toIso8601String(), fin.toIso8601String()],
      userId,
      tableName: 'pesees',
    );
    final result = await db.query(
      'pesees',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return result.map((json) => Pesee.fromMap(json)).toList();
  }

  /// Calculer la moyenne de poids sur une période
  Future<double?> getPoidssMoyenPeriode(DateTime debut, DateTime fin) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'date >= ? AND date <= ?',
      [debut.toIso8601String(), fin.toIso8601String()],
      userId,
      tableName: 'pesees',
    );
    final result = await db.rawQuery(
      'SELECT AVG(poids) as moyenne FROM pesees WHERE $where',
      whereArgs,
    );
    if (result.isEmpty) return null;
    return (result.first['moyenne'] as num?)?.toDouble();
  }

  // ============= OPÉRATIONS CRUD SUR LES SOINS =============

  /// Insérer un soin dans la base de données
  ///
  /// Définit automatiquement user_id si disponible
  Future<Soin> insertSoin(Soin soin) async {
    final db = await database;
    final map = await prepareDataForInsert(soin.toMap(), tableName: 'soins');
    final id = await db.insert('soins', map);
    return soin.copyWith(id: id);
  }

  /// Récupérer tous les soins
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Soin>> getAllSoins() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'soins',
    );
    final result = await db.query(
      'soins',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
    );
    return result.map((json) => Soin.fromMap(json)).toList();
  }

  /// Récupérer les soins d'un lapin
  Future<List<Soin>> getSoinsByLapin(int lapinId) async {
    final db = await database;
    final result = await db.query(
      'soins',
      where: 'lapin_id = ?',
      whereArgs: [lapinId],
      orderBy: 'date DESC',
    );
    return result.map((json) => Soin.fromMap(json)).toList();
  }

  /// Récupérer un soin par son ID
  Future<Soin?> getSoinById(int id) async {
    final db = await database;
    final result = await db.query(
      'soins',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Soin.fromMap(result.first);
  }

  /// Récupérer les soins avec rappel nécessaire
  Future<List<Soin>> getSoinsAvecRappel() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final result = await db.query(
      'soins',
      where: 'date_rappel IS NOT NULL AND date_rappel <= ?',
      whereArgs: [now],
      orderBy: 'date_rappel ASC',
    );
    return result.map((json) => Soin.fromMap(json)).toList();
  }

  /// Récupérer les soins par type
  Future<List<Soin>> getSoinsByType(String type) async {
    final db = await database;
    final result = await db.query(
      'soins',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return result.map((json) => Soin.fromMap(json)).toList();
  }

  /// Mettre à jour un soin
  Future<int> updateSoin(Soin soin) async {
    final db = await database;
    final map = soin.toMap();
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await filterColumnsForUpdate(map, 'soins');

    return db.update(
      'soins',
      filteredMap,
      where: 'id = ?',
      whereArgs: [soin.id],
    );
  }

  /// Supprimer un soin
  ///
  /// Utilise soft delete pour la synchronisation
  Future<int> deleteSoin(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await filterColumnsForUpdate(updateData, 'soins');

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'soins',
    );
    return await db.update(
      'soins',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Récupérer les soins par période
  Future<List<Soin>> getSoinsByPeriode(DateTime debut, DateTime fin) async {
    final db = await database;
    final result = await db.query(
      'soins',
      where: 'date >= ? AND date <= ?',
      whereArgs: [debut.toIso8601String(), fin.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((json) => Soin.fromMap(json)).toList();
  }

  /// Compter les soins par type
  Future<Map<String, int>> countSoinsByType() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'soins',
    );
    final result = await db.rawQuery('''
      SELECT type, COUNT(*) as count 
      FROM soins 
      WHERE $where
      GROUP BY type
    ''', whereArgs);

    final Map<String, int> counts = {};
    for (final row in result) {
      final type = row['type'] as String?;
      final count = row['count'] as int?;
      if (type != null && count != null) {
        counts[type] = count;
      }
    }
    return counts;
  }

  // ============= OPÉRATIONS CRUD SUR LES MÉDICAMENTS =============

  /// Insérer un médicament dans la base de données
  Future<Medicament> insertMedicament(Medicament medicament) async {
    final db = await database;
    final map = await prepareDataForInsert(
      medicament.toMap(),
      tableName: 'medicaments',
    );
    final id = await db.insert('medicaments', map);
    return medicament.copyWith(id: id);
  }

  /// Récupérer tous les médicaments
  Future<List<Medicament>> getAllMedicaments() async {
    final db = await database;
    final result = await db.query('medicaments', orderBy: 'nom ASC');
    return result.map((json) => Medicament.fromMap(json)).toList();
  }

  /// Récupérer un médicament par son ID
  Future<Medicament?> getMedicamentById(int id) async {
    final db = await database;
    final result = await db.query(
      'medicaments',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Medicament.fromMap(result.first);
  }

  /// Mettre à jour un médicament
  Future<int> updateMedicament(Medicament medicament) async {
    final db = await database;
    final map = medicament.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();

    final filteredMap = await filterColumnsForUpdate(map, 'medicaments');

    return db.update(
      'medicaments',
      filteredMap,
      where: 'id = ?',
      whereArgs: [medicament.id],
    );
  }

  /// Supprimer un médicament
  Future<int> deleteMedicament(int id) async {
    final db = await database;
    return db.delete('medicaments', where: 'id = ?', whereArgs: [id]);
  }

  /// Récupérer les médicaments périmés ou bientôt périmés
  Future<List<Medicament>> getMedicamentsPerimes({int joursAvant = 30}) async {
    final db = await database;
    final dateLimite = DateTime.now().add(Duration(days: joursAvant));
    
    final result = await db.query(
      'medicaments',
      where: 'date_peremption IS NOT NULL AND date_peremption <= ?',
      whereArgs: [dateLimite.toIso8601String()],
      orderBy: 'date_peremption ASC',
    );
    return result.map((json) => Medicament.fromMap(json)).toList();
  }

  /// Récupérer les médicaments avec stock faible
  Future<List<Medicament>> getMedicamentsStockFaible({int seuilMin = 5}) async {
    final db = await database;
    final result = await db.query(
      'medicaments',
      where: 'quantite_stock IS NOT NULL AND quantite_stock <= ?',
      whereArgs: [seuilMin],
      orderBy: 'quantite_stock ASC',
    );
    return result.map((json) => Medicament.fromMap(json)).toList();
  }
}
