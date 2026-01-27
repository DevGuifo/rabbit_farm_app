import 'package:sqflite/sqflite.dart';
import '../../models/lapin.dart';
import 'database_base.dart';

/// Mixin contenant les opérations CRUD pour les lapins
///
/// Ce mixin encapsule toute la logique base de données relative aux lapins :
/// - CRUD lapins
/// - Relations (père/mère)
/// - Filtres (par sexe, statut)
/// - Comptage
///
/// ## Usage
///
/// Ce mixin est appliqué à `DatabaseHelper` :
/// ```dart
/// class DatabaseHelper with LapinDatabaseMixin { ... }
/// ```
///
/// ## Tables concernées
/// - `lapins` : données principales
/// - `relations` : liens père/mère
mixin LapinDatabaseMixin on DatabaseBase {
  // ============= OPÉRATIONS CRUD SUR LES LAPINS =============

  /// Insérer un lapin dans la base de données
  ///
  /// Définit automatiquement user_id si disponible
  Future<Lapin> insertLapin(Lapin lapin) async {
    final db = await database;
    final map = await prepareDataForInsert(lapin.toMap(), tableName: 'lapins');
    final id = await db.insert('lapins', map);
    return lapin.copyWith(id: id);
  }

  /// Récupérer tous les lapins
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Lapin>> getAllLapins() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'lapins',
    );
    final result = await db.query(
      'lapins',
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'nom ASC',
    );
    return result.map((json) => Lapin.fromMap(json)).toList();
  }

  /// Récupérer un lapin par son ID
  ///
  /// Vérifie que le lapin appartient à l'utilisateur connecté
  Future<Lapin?> getLapinById(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'lapins',
    );
    final maps = await db.query('lapins', where: where, whereArgs: whereArgs);

    if (maps.isNotEmpty) {
      return Lapin.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Mettre à jour un lapin
  ///
  /// Vérifie que le lapin appartient à l'utilisateur connecté
  /// Définit automatiquement updated_at
  Future<int> updateLapin(Lapin lapin) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final map = lapin.toMap();
    // Définir updated_at automatiquement (si colonne existe)
    final now = DateTime.now().toIso8601String();
    map['updated_at'] = now;
    // Marquer comme dirty pour synchronisation (si colonne existe)
    map['is_dirty'] = 1;

    // Filtrer les colonnes inexistantes
    final filteredMap = await filterColumnsForUpdate(map, 'lapins');

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [lapin.id],
      userId,
      tableName: 'lapins',
    );
    return db.update('lapins', filteredMap, where: where, whereArgs: whereArgs);
  }

  /// Supprimer un lapin
  ///
  /// Vérifie que le lapin appartient à l'utilisateur connecté
  /// Utilise soft delete (is_deleted = 1) pour la synchronisation
  Future<int> deleteLapin(int id) async {
    final db = await database;
    final userId = await getCurrentUserId();

    // Soft delete : marquer comme supprimé au lieu de supprimer réellement
    final updateData = {
      'is_deleted': 1,
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Filtrer les colonnes inexistantes
    final filteredData = await filterColumnsForUpdate(updateData, 'lapins');

    final (where, whereArgs) = await buildWhereWithUserId(
      'id = ?',
      [id],
      userId,
      tableName: 'lapins',
    );
    return await db.update(
      'lapins',
      filteredData,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Récupérer les lapins par sexe
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Lapin>> getLapinsBySexe(String sexe) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'sexe = ?',
      [sexe],
      userId,
      tableName: 'lapins',
    );
    final result = await db.query(
      'lapins',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'nom ASC',
    );
    return result.map((json) => Lapin.fromMap(json)).toList();
  }

  /// Récupérer les lapins par statut
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<List<Lapin>> getLapinsByStatut(String statut) async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      'statut = ?',
      [statut],
      userId,
      tableName: 'lapins',
    );
    final result = await db.query(
      'lapins',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'nom ASC',
    );
    return result.map((json) => Lapin.fromMap(json)).toList();
  }

  /// Compter le nombre total de lapins
  ///
  /// Filtre automatiquement par user_id si un utilisateur est connecté
  Future<int> countLapins() async {
    final db = await database;
    final userId = await getCurrentUserId();

    final (where, whereArgs) = await buildWhereWithUserId(
      null,
      null,
      userId,
      tableName: 'lapins',
    );
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM lapins WHERE $where',
      whereArgs.isEmpty ? null : whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ============= OPÉRATIONS SUR LES RELATIONS (GÉNÉALOGIE) =============

  /// Récupérer les IDs des parents d'un lapin
  Future<Map<String, int?>?> getRelationByLapinId(int lapinId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'relations',
      where: 'lapin_id = ?',
      whereArgs: [lapinId],
    );
    if (maps.isEmpty) return null;
    return {
      'pereId': maps.first['pere_id'] as int?,
      'mereId': maps.first['mere_id'] as int?,
    };
  }

  /// Enregistrer les parents d'un lapin
  Future<void> setParents(int lapinId, int? pereId, int? mereId) async {
    final db = await database;

    // Supprimer la relation existante si elle existe
    await db.delete('relations', where: 'lapin_id = ?', whereArgs: [lapinId]);

    // Insérer la nouvelle relation
    await db.insert('relations', {
      'lapin_id': lapinId,
      'pere_id': pereId,
      'mere_id': mereId,
    });
  }

  /// Récupérer le père d'un lapin
  Future<Lapin?> getPere(int lapinId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT l.* FROM lapins l
      INNER JOIN relations r ON l.id = r.pere_id
      WHERE r.lapin_id = ?
    ''',
      [lapinId],
    );

    if (result.isNotEmpty) {
      return Lapin.fromMap(result.first);
    }
    return null;
  }

  /// Récupérer la mère d'un lapin
  Future<Lapin?> getMere(int lapinId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT l.* FROM lapins l
      INNER JOIN relations r ON l.id = r.mere_id
      WHERE r.lapin_id = ?
    ''',
      [lapinId],
    );

    if (result.isNotEmpty) {
      return Lapin.fromMap(result.first);
    }
    return null;
  }

  /// Récupérer les enfants d'un lapin (en tant que père ou mère)
  Future<List<Lapin>> getEnfants(int lapinId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT l.* FROM lapins l
      INNER JOIN relations r ON l.id = r.lapin_id
      WHERE r.pere_id = ? OR r.mere_id = ?
    ''',
      [lapinId, lapinId],
    );

    return result.map((json) => Lapin.fromMap(json)).toList();
  }

  /// Récupérer les frères et sœurs d'un lapin
  Future<List<Lapin>> getFreresSoeurs(int lapinId) async {
    final db = await database;

    // D'abord récupérer les parents
    final relation = await getRelationByLapinId(lapinId);
    if (relation == null) return [];

    final pereId = relation['pereId'];
    final mereId = relation['mereId'];

    if (pereId == null && mereId == null) return [];

    // Chercher les lapins ayant les mêmes parents
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (pereId != null && mereId != null) {
      whereClause = '(r.pere_id = ? OR r.mere_id = ?) AND r.lapin_id != ?';
      whereArgs = [pereId, mereId, lapinId];
    } else if (pereId != null) {
      whereClause = 'r.pere_id = ? AND r.lapin_id != ?';
      whereArgs = [pereId, lapinId];
    } else {
      whereClause = 'r.mere_id = ? AND r.lapin_id != ?';
      whereArgs = [mereId, lapinId];
    }

    final result = await db.rawQuery('''
      SELECT DISTINCT l.* FROM lapins l
      INNER JOIN relations r ON l.id = r.lapin_id
      WHERE $whereClause
    ''', whereArgs);

    return result.map((json) => Lapin.fromMap(json)).toList();
  }

  // ============= MÉTHODES DE GÉNÉALOGIE ET CONSANGUINITÉ =============

  /// Récupérer les deux parents d'un lapin
  Future<Map<String, Lapin?>> getParents(int lapinId) async {
    final pere = await getPere(lapinId);
    final mere = await getMere(lapinId);
    return {'pere': pere, 'mere': mere};
  }

  /// Récupérer les ancêtres d'un lapin (récursif sur N générations)
  Future<Map<String, dynamic>> getAncetres(
    int lapinId, {
    int generations = 3,
  }) async {
    final lapin = await getLapinById(lapinId);
    if (lapin == null) return {};

    Map<String, dynamic> arbre = {'lapin': lapin, 'pere': null, 'mere': null};

    if (generations > 0) {
      final parents = await getParents(lapinId);
      if (parents['pere'] != null) {
        arbre['pere'] = await getAncetres(
          parents['pere']!.id!,
          generations: generations - 1,
        );
      }
      if (parents['mere'] != null) {
        arbre['mere'] = await getAncetres(
          parents['mere']!.id!,
          generations: generations - 1,
        );
      }
    }

    return arbre;
  }

  /// Calculer le coefficient de consanguinité selon l'algorithme de Wright
  /// F = Σ (1/2)^(n+1) * (1 + FA)
  /// où n = nombre de générations dans le chemin commun, FA = consanguinité de l'ancêtre commun
  Future<double> calculerConsanguinite(int lapinId) async {
    final parents = await getParents(lapinId);
    final pere = parents['pere'];
    final mere = parents['mere'];

    // Si pas de parents, pas de consanguinité
    if (pere == null || mere == null || pere.id == null || mere.id == null) {
      return 0.0;
    }

    // Si les parents sont les mêmes (impossible mais vérification)
    if (pere.id == mere.id) {
      return 1.0; // Consanguinité maximale
    }

    // Récupérer tous les ancêtres du père et de la mère (jusqu'à 5 générations pour précision)
    final ancetresPere = await _collecterTousAncetres(
      pere.id!,
      maxGenerations: 5,
    );
    final ancetresMere = await _collecterTousAncetres(
      mere.id!,
      maxGenerations: 5,
    );

    // Trouver les ancêtres communs
    final ancetresCommuns = ancetresPere.keys.toSet().intersection(
      ancetresMere.keys.toSet(),
    );

    if (ancetresCommuns.isEmpty) {
      return 0.0; // Pas d'ancêtres communs = pas de consanguinité
    }

    // Calculer le coefficient de consanguinité selon Wright
    double coefficientTotal = 0.0;

    for (final ancetreId in ancetresCommuns) {
      // Récupérer les chemins vers cet ancêtre commun depuis le père et la mère
      final cheminsPere = await _trouverCheminsVersAncetre(
        pere.id!,
        ancetreId,
        ancetresPere,
      );
      final cheminsMere = await _trouverCheminsVersAncetre(
        mere.id!,
        ancetreId,
        ancetresMere,
      );

      // Pour chaque combinaison de chemins
      for (final cheminPere in cheminsPere) {
        for (final cheminMere in cheminsMere) {
          // Longueur totale du chemin (père -> ancêtre + ancêtre -> mère)
          final longueurChemin = cheminPere.length + cheminMere.length;

          // Calculer la consanguinité de l'ancêtre commun (récursif)
          final consanguiniteAncetre = await calculerConsanguinite(ancetreId);

          // Formule de Wright : (1/2)^(n+1) * (1 + FA)
          final contribution =
              (1 / (1 << (longueurChemin + 1))) * (1 + consanguiniteAncetre);
          coefficientTotal += contribution;
        }
      }
    }

    return coefficientTotal.clamp(0.0, 1.0);
  }

  /// Collecter tous les ancêtres d'un lapin avec leur profondeur
  Future<Map<int, int>> _collecterTousAncetres(
    int lapinId, {
    int maxGenerations = 5,
    int profondeur = 0,
    Map<int, int>? resultat,
  }) async {
    resultat ??= {};
    if (profondeur >= maxGenerations) return resultat;

    final parents = await getParents(lapinId);
    final pere = parents['pere'];
    final mere = parents['mere'];

    if (pere != null && pere.id != null) {
      // Enregistrer l'ancêtre avec sa profondeur minimale
      if (!resultat.containsKey(pere.id!) ||
          resultat[pere.id]! > profondeur + 1) {
        resultat[pere.id!] = profondeur + 1;
      }
      await _collecterTousAncetres(
        pere.id!,
        maxGenerations: maxGenerations,
        profondeur: profondeur + 1,
        resultat: resultat,
      );
    }

    if (mere != null && mere.id != null) {
      if (!resultat.containsKey(mere.id!) ||
          resultat[mere.id]! > profondeur + 1) {
        resultat[mere.id!] = profondeur + 1;
      }
      await _collecterTousAncetres(
        mere.id!,
        maxGenerations: maxGenerations,
        profondeur: profondeur + 1,
        resultat: resultat,
      );
    }

    return resultat;
  }

  /// Trouver tous les chemins vers un ancêtre commun
  Future<List<List<int>>> _trouverCheminsVersAncetre(
    int lapinId,
    int ancetreId,
    Map<int, int> ancetres,
  ) async {
    if (lapinId == ancetreId) {
      return [[]]; // Chemin vide (on est déjà à l'ancêtre)
    }

    if (!ancetres.containsKey(ancetreId)) {
      return []; // Ancêtre non accessible depuis ce lapin
    }

    // Récupérer les parents de ce lapin
    return _trouverCheminsRecursif(lapinId, ancetreId, ancetres, {});
  }

  /// Trouver les chemins récursivement (avec protection contre les cycles)
  Future<List<List<int>>> _trouverCheminsRecursif(
    int lapinId,
    int ancetreId,
    Map<int, int> ancetres,
    Set<int> visite,
  ) async {
    if (lapinId == ancetreId) {
      return [[]];
    }

    if (visite.contains(lapinId)) {
      return []; // Cycle détecté
    }

    visite.add(lapinId);
    final parents = await getParents(lapinId);
    final pere = parents['pere'];
    final mere = parents['mere'];

    List<List<int>> chemins = [];

    if (pere != null && pere.id != null) {
      final cheminsPere = await _trouverCheminsRecursif(
        pere.id!,
        ancetreId,
        ancetres,
        Set.from(visite),
      );
      for (final chemin in cheminsPere) {
        chemins.add([pere.id!, ...chemin]);
      }
    }

    if (mere != null && mere.id != null) {
      final cheminsMere = await _trouverCheminsRecursif(
        mere.id!,
        ancetreId,
        ancetres,
        Set.from(visite),
      );
      for (final chemin in cheminsMere) {
        chemins.add([mere.id!, ...chemin]);
      }
    }

    return chemins;
  }
}
