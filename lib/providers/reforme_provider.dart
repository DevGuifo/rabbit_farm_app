import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/reforme.dart';
import '../services/database_helper.dart';
import '../utils/logger.dart';

class ReformeProvider with ChangeNotifier {
  final List<Reforme> _reformes = [];
  bool _isLoading = false;

  List<Reforme> get reformes => [..._reformes];
  bool get isLoading => _isLoading;

  /// Charger toutes les réformes
  Future<void> chargerReformes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'reformes',
        orderBy: 'date_reforme DESC',
      );

      _reformes.clear();
      _reformes.addAll(maps.map((map) => Reforme.fromMap(map)));
    } catch (e) {
      logger.error('Erreur lors du chargement des réformes: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajouter une réforme
  Future<void> ajouterReforme(Reforme reforme) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final id = await db.insert(
        'reformes',
        reforme.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final nouvelleReforme = reforme.copyWith(id: id);
      _reformes.insert(0, nouvelleReforme);
      notifyListeners();
    } catch (e) {
      logger.error('Erreur lors de l\'ajout de la réforme: $e');
      rethrow;
    }
  }

  /// Modifier une réforme
  Future<void> modifierReforme(Reforme reforme) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'reformes',
        reforme.toMap(),
        where: 'id = ?',
        whereArgs: [reforme.id],
      );

      final index = _reformes.indexWhere((r) => r.id == reforme.id);
      if (index != -1) {
        _reformes[index] = reforme;
        notifyListeners();
      }
    } catch (e) {
      logger.error('Erreur lors de la modification de la réforme: $e');
      rethrow;
    }
  }

  /// Supprimer une réforme
  Future<void> supprimerReforme(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('reformes', where: 'id = ?', whereArgs: [id]);

      _reformes.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      logger.error('Erreur lors de la suppression de la réforme: $e');
      rethrow;
    }
  }

  /// Obtenir la réforme d'un lapin
  Future<Reforme?> obtenirReformeLapin(int lapinId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'reformes',
        where: 'lapin_id = ?',
        whereArgs: [lapinId],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return Reforme.fromMap(maps.first);
    } catch (e) {
      logger.error('Erreur lors de la récupération de la réforme du lapin: $e');
      return null;
    }
  }

  /// Obtenir les réformes par période
  Future<List<Reforme>> obtenirReformesParPeriode({
    required DateTime debut,
    required DateTime fin,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'reformes',
        where: 'date_reforme BETWEEN ? AND ?',
        whereArgs: [debut.toIso8601String(), fin.toIso8601String()],
        orderBy: 'date_reforme DESC',
      );

      return maps.map((map) => Reforme.fromMap(map)).toList();
    } catch (e) {
      logger.error(
        'Erreur lors de la récupération des réformes par période: $e',
      );
      rethrow;
    }
  }

  /// Obtenir le total des revenus de réforme
  double getRevenusTotal() {
    return _reformes.fold(0.0, (sum, reforme) {
      return sum + (reforme.prixVente ?? 0.0);
    });
  }

  /// Obtenir les réformes d'une période (derniers X jours)
  List<Reforme> getReformesParPeriode(int jours) {
    final dateDebut = DateTime.now().subtract(Duration(days: jours));
    return _reformes.where((r) => r.dateReforme.isAfter(dateDebut)).toList();
  }

  /// Statistiques des réformes
  Future<Map<String, dynamic>> obtenirStatistiques({
    DateTime? debut,
    DateTime? fin,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (debut != null && fin != null) {
        whereClause = 'WHERE date_reforme BETWEEN ? AND ?';
        whereArgs = [debut.toIso8601String(), fin.toIso8601String()];
      }

      // Répartition par motif
      final repartitionMotif = await db.rawQuery('''
        SELECT motif, COUNT(*) as nombre
        FROM reformes 
        $whereClause
        GROUP BY motif
      ''', whereArgs);

      // Répartition par destination
      final repartitionDestination = await db.rawQuery('''
        SELECT destination, COUNT(*) as nombre
        FROM reformes 
        $whereClause
        GROUP BY destination
      ''', whereArgs);

      // Revenus des ventes
      final revenusVentes = await db.rawQuery('''
        SELECT SUM(prix_vente) as total, COUNT(*) as nombre
        FROM reformes 
        WHERE destination = 'vente' $whereClause
      ''', whereArgs);

      // Poids moyen
      final poidsMoyen = await db.rawQuery('''
        SELECT AVG(poids_vif) as moyenne
        FROM reformes 
        WHERE poids_vif IS NOT NULL $whereClause
      ''', whereArgs);

      return {
        'nombre_total': _reformes.length,
        'repartition_motif': repartitionMotif,
        'repartition_destination': repartitionDestination,
        'revenus_ventes': revenusVentes.first['total'] ?? 0.0,
        'nombre_ventes': revenusVentes.first['nombre'] ?? 0,
        'poids_moyen': poidsMoyen.first['moyenne'] ?? 0.0,
      };
    } catch (e) {
      logger.error('Erreur lors du calcul des statistiques: $e');
      rethrow;
    }
  }

  /// Prix de vente moyen
  Future<double> obtenirPrixVenteMoyen() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery('''
        SELECT AVG(prix_vente) as moyenne
        FROM reformes
        WHERE destination = 'vente' AND prix_vente IS NOT NULL
      ''');

      return (result.first['moyenne'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      logger.error('Erreur lors du calcul du prix moyen: $e');
      return 0.0;
    }
  }
}
