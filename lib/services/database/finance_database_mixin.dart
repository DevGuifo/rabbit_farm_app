import '../../models/recette.dart';
import '../../models/depense.dart';
import 'database_base.dart';

/// Mixin contenant les opérations CRUD pour les finances
/// 
/// Ce mixin encapsule toute la logique base de données relative aux finances :
/// - CRUD recettes
/// - CRUD dépenses
/// - Calculs de bénéfices
/// - Statistiques financières
/// 
/// ## Usage
/// 
/// Ce mixin est appliqué à `DatabaseHelper` :
/// ```dart
/// class DatabaseHelper with FinanceDatabaseMixin { ... }
/// ```
/// 
/// ## Tables concernées
/// - `recettes` : revenus de l'élevage
/// - `depenses` : coûts d'exploitation
mixin FinanceDatabaseMixin on DatabaseBase {
  // ============= OPÉRATIONS CRUD SUR LES RECETTES =============

  /// Insérer une recette
  ///
  /// Définit automatiquement user_id si disponible
  Future<Recette> insertRecette(Recette recette) async {
    final db = await database;
    final map = await prepareDataForInsert(
      recette.toMap(),
      tableName: 'recettes',
    );
    final id = await db.insert('recettes', map);
    return recette.copyWith(id: id);
  }

  /// Récupérer toutes les recettes
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Recette>> getAllRecettes() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'recettes',
    );
    final result = await db.query(
      'recettes',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
    );
    return result.map((json) => Recette.fromMap(json)).toList();
  }

  /// Récupérer les recettes par période
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Recette>> getRecettesByPeriode(
    DateTime debut,
    DateTime fin,
  ) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'date >= ? AND date <= ?',
      [debut.toIso8601String(), fin.toIso8601String()],
      userId,
      tableName: 'recettes',
    );
    final result = await db.query(
      'recettes',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return result.map((json) => Recette.fromMap(json)).toList();
  }

  /// Récupérer les recettes par catégorie
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Recette>> getRecettesByCategorie(String categorie) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'categorie = ?',
      [categorie],
      userId,
      tableName: 'recettes',
    );
    final result = await db.query(
      'recettes',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return result.map((json) => Recette.fromMap(json)).toList();
  }

  /// Récupérer les recettes liées à un lapin
  Future<List<Recette>> getRecettesByLapin(int lapinId) async {
    final db = await database;
    final result = await db.query(
      'recettes',
      where: 'lapin_id = ?',
      whereArgs: [lapinId],
      orderBy: 'date DESC',
    );
    return result.map((json) => Recette.fromMap(json)).toList();
  }

  /// Calculer le total des recettes
  Future<double> getTotalRecettes() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'recettes',
    );
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(montant), 0) as total FROM recettes WHERE $where',
      whereArgs,
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Calculer le total des recettes par période
  Future<double> getTotalRecettesByPeriode(DateTime debut, DateTime fin) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'date >= ? AND date <= ?',
      [debut.toIso8601String(), fin.toIso8601String()],
      userId,
      tableName: 'recettes',
    );
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(montant), 0) as total FROM recettes WHERE $where',
      whereArgs,
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Calculer le total des recettes par catégorie
  Future<Map<String, double>> getTotalRecettesByCategorie() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'recettes',
    );
    final result = await db.rawQuery(
      'SELECT categorie, COALESCE(SUM(montant), 0) as total FROM recettes WHERE $where GROUP BY categorie',
      whereArgs,
    );

    final Map<String, double> totaux = {};
    for (var row in result) {
      final cat = row['categorie'] as String?;
      if (cat != null) {
        totaux[cat] = (row['total'] as num?)?.toDouble() ?? 0.0;
      }
    }
    return totaux;
  }

  /// Mettre à jour une recette
  Future<int> updateRecette(Recette recette) async {
    final db = await database;
    final map = recette.toMap();
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await filterColumnsForUpdate(map, 'recettes');

    return db.update(
      'recettes',
      filteredMap,
      where: 'id = ?',
      whereArgs: [recette.id],
    );
  }

  /// Supprimer une recette
  ///
  /// Utilise soft delete pour la synchronisation
  Future<int> deleteRecette(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await filterColumnsForUpdate(updateData, 'recettes');

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'recettes',
    );
    return await db.update(
      'recettes',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // ============= OPÉRATIONS CRUD SUR LES DÉPENSES =============

  /// Insérer une dépense
  ///
  /// Définit automatiquement user_id si disponible
  Future<Depense> insertDepense(Depense depense) async {
    final db = await database;
    final map = await prepareDataForInsert(
      depense.toMap(),
      tableName: 'depenses',
    );
    final id = await db.insert('depenses', map);
    return depense.copyWith(id: id);
  }

  /// Récupérer toutes les dépenses
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Depense>> getAllDepenses() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'depenses',
    );
    final result = await db.query(
      'depenses',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
    );
    return result.map((json) => Depense.fromMap(json)).toList();
  }

  /// Récupérer les dépenses par période
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Depense>> getDepensesByPeriode(
    DateTime debut,
    DateTime fin,
  ) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'date >= ? AND date <= ?',
      [debut.toIso8601String(), fin.toIso8601String()],
      userId,
      tableName: 'depenses',
    );
    final result = await db.query(
      'depenses',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return result.map((json) => Depense.fromMap(json)).toList();
  }

  /// Récupérer les dépenses par catégorie
  Future<List<Depense>> getDepensesByCategorie(String categorie) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'categorie = ?',
      [categorie],
      userId,
      tableName: 'depenses',
    );
    final result = await db.query(
      'depenses',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return result.map((json) => Depense.fromMap(json)).toList();
  }

  /// Calculer le total des dépenses
  Future<double> getTotalDepenses() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'depenses',
    );
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(montant), 0) as total FROM depenses WHERE $where',
      whereArgs,
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Calculer le total des dépenses par période
  Future<double> getTotalDepensesByPeriode(DateTime debut, DateTime fin) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'date >= ? AND date <= ?',
      [debut.toIso8601String(), fin.toIso8601String()],
      userId,
      tableName: 'depenses',
    );
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(montant), 0) as total FROM depenses WHERE $where',
      whereArgs,
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Calculer le total des dépenses par catégorie
  Future<Map<String, double>> getTotalDepensesByCategorie() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'depenses',
    );
    final result = await db.rawQuery(
      'SELECT categorie, COALESCE(SUM(montant), 0) as total FROM depenses WHERE $where GROUP BY categorie',
      whereArgs,
    );

    final Map<String, double> totaux = {};
    for (var row in result) {
      final cat = row['categorie'] as String?;
      if (cat != null) {
        totaux[cat] = (row['total'] as num?)?.toDouble() ?? 0.0;
      }
    }
    return totaux;
  }

  /// Mettre à jour une dépense
  Future<int> updateDepense(Depense depense) async {
    final db = await database;
    final map = depense.toMap();
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await filterColumnsForUpdate(map, 'depenses');

    return db.update(
      'depenses',
      filteredMap,
      where: 'id = ?',
      whereArgs: [depense.id],
    );
  }

  /// Supprimer une dépense
  ///
  /// Utilise soft delete pour la synchronisation
  Future<int> deleteDepense(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await filterColumnsForUpdate(updateData, 'depenses');

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'depenses',
    );
    return await db.update(
      'depenses',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // ============= CALCULS FINANCIERS =============

  /// Calculer le bénéfice (recettes - dépenses)
  Future<double> getBenefice() async {
    final recettes = await getTotalRecettes();
    final depenses = await getTotalDepenses();
    return recettes - depenses;
  }

  /// Calculer le bénéfice par période
  Future<double> getBeneficeByPeriode(DateTime debut, DateTime fin) async {
    final recettes = await getTotalRecettesByPeriode(debut, fin);
    final depenses = await getTotalDepensesByPeriode(debut, fin);
    return recettes - depenses;
  }

  /// Obtenir un résumé financier complet
  Future<Map<String, dynamic>> getResumeFinancier({
    DateTime? debut,
    DateTime? fin,
  }) async {
    double recettes;
    double depenses;
    
    if (debut != null && fin != null) {
      recettes = await getTotalRecettesByPeriode(debut, fin);
      depenses = await getTotalDepensesByPeriode(debut, fin);
    } else {
      recettes = await getTotalRecettes();
      depenses = await getTotalDepenses();
    }
    
    return {
      'recettes': recettes,
      'depenses': depenses,
      'benefice': recettes - depenses,
      'margeNette': recettes > 0 ? ((recettes - depenses) / recettes * 100) : 0.0,
    };
  }

  /// Obtenir l'évolution mensuelle des finances
  Future<List<Map<String, dynamic>>> getEvolutionMensuelle(int annee) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (whereRecettes, whereArgsRecettes) = await buildWhereWithUserId(
      "strftime('%Y', date) = ?",
      ['$annee'],
      userId,
      tableName: 'recettes',
    );
    
    final (whereDepenses, whereArgsDepenses) = await buildWhereWithUserId(
      "strftime('%Y', date) = ?",
      ['$annee'],
      userId,
      tableName: 'depenses',
    );

    final recettesResult = await db.rawQuery('''
      SELECT strftime('%m', date) as mois, COALESCE(SUM(montant), 0) as total
      FROM recettes 
      WHERE $whereRecettes
      GROUP BY strftime('%m', date)
    ''', whereArgsRecettes);

    final depensesResult = await db.rawQuery('''
      SELECT strftime('%m', date) as mois, COALESCE(SUM(montant), 0) as total
      FROM depenses 
      WHERE $whereDepenses
      GROUP BY strftime('%m', date)
    ''', whereArgsDepenses);

    // Combiner les résultats
    final Map<String, double> recettesParMois = {};
    final Map<String, double> depensesParMois = {};

    for (final row in recettesResult) {
      final mois = row['mois'] as String;
      recettesParMois[mois] = (row['total'] as num?)?.toDouble() ?? 0.0;
    }

    for (final row in depensesResult) {
      final mois = row['mois'] as String;
      depensesParMois[mois] = (row['total'] as num?)?.toDouble() ?? 0.0;
    }

    // Créer un tableau pour tous les mois
    final List<Map<String, dynamic>> evolution = [];
    for (int m = 1; m <= 12; m++) {
      final moisStr = m.toString().padLeft(2, '0');
      final recette = recettesParMois[moisStr] ?? 0.0;
      final depense = depensesParMois[moisStr] ?? 0.0;
      evolution.add({
        'mois': m,
        'recettes': recette,
        'depenses': depense,
        'benefice': recette - depense,
      });
    }

    return evolution;
  }
}
