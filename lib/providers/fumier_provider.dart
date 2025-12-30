import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/collecte_fumier.dart';
import '../services/database_helper.dart';
import '../utils/logger.dart';

class FumierProvider with ChangeNotifier {
  final List<CollecteFumier> _collectes = [];
  bool _isLoading = false;

  List<CollecteFumier> get collectes => [..._collectes];
  bool get isLoading => _isLoading;

  /// Charger toutes les collectes
  Future<void> chargerCollectes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'collectes_fumier',
        orderBy: 'date_collecte DESC',
      );

      _collectes.clear();
      _collectes.addAll(maps.map((map) => CollecteFumier.fromMap(map)));
    } catch (e) {
      logger.error('Erreur lors du chargement des collectes: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajouter une nouvelle collecte
  Future<void> ajouterCollecte(CollecteFumier collecte) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final id = await db.insert(
        'collectes_fumier',
        collecte.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final nouvelleCollecte = collecte.copyWith(id: id);
      _collectes.insert(0, nouvelleCollecte);
      notifyListeners();
    } catch (e) {
      logger.error('Erreur lors de l\'ajout de la collecte: $e');
      rethrow;
    }
  }

  /// Modifier une collecte existante
  Future<void> modifierCollecte(CollecteFumier collecte) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'collectes_fumier',
        collecte.toMap(),
        where: 'id = ?',
        whereArgs: [collecte.id],
      );

      final index = _collectes.indexWhere((c) => c.id == collecte.id);
      if (index != -1) {
        _collectes[index] = collecte;
        notifyListeners();
      }
    } catch (e) {
      logger.error('Erreur lors de la modification de la collecte: $e');
      rethrow;
    }
  }

  /// Supprimer une collecte
  Future<void> supprimerCollecte(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('collectes_fumier', where: 'id = ?', whereArgs: [id]);

      _collectes.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      logger.error('Erreur lors de la suppression de la collecte: $e');
      rethrow;
    }
  }

  /// Statistiques des collectes
  Future<Map<String, dynamic>> obtenirStatistiques({
    DateTime? debut,
    DateTime? fin,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (debut != null && fin != null) {
        whereClause = 'WHERE date_collecte BETWEEN ? AND ?';
        whereArgs = [debut.toIso8601String(), fin.toIso8601String()];
      }

      // Quantité totale collectée
      final quantiteTotale = await db.rawQuery('''
        SELECT SUM(quantite) as total 
        FROM collectes_fumier 
        $whereClause
      ''', whereArgs);

      // Revenus des ventes
      final revenusVentes = await db.rawQuery('''
        SELECT SUM(prix_vente) as total 
        FROM collectes_fumier 
        WHERE destination = 'vente' $whereClause
      ''', whereArgs);

      // Répartition par type
      final repartitionType = await db.rawQuery('''
        SELECT type, SUM(quantite) as total, COUNT(*) as nombre
        FROM collectes_fumier 
        $whereClause
        GROUP BY type
      ''', whereArgs);

      // Répartition par destination
      final repartitionDestination = await db.rawQuery('''
        SELECT destination, SUM(quantite) as total, COUNT(*) as nombre
        FROM collectes_fumier 
        $whereClause
        GROUP BY destination
      ''', whereArgs);

      return {
        'quantite_totale': quantiteTotale.first['total'] ?? 0.0,
        'revenus_ventes': revenusVentes.first['total'] ?? 0.0,
        'repartition_type': repartitionType,
        'repartition_destination': repartitionDestination,
        'nombre_collectes': _collectes.length,
      };
    } catch (e) {
      logger.error('Erreur lors du calcul des statistiques: $e');
      rethrow;
    }
  }

  /// Obtenir les collectes par période
  Future<List<CollecteFumier>> obtenirCollectesParPeriode({
    required DateTime debut,
    required DateTime fin,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'collectes_fumier',
        where: 'date_collecte BETWEEN ? AND ?',
        whereArgs: [debut.toIso8601String(), fin.toIso8601String()],
        orderBy: 'date_collecte DESC',
      );

      return maps.map((map) => CollecteFumier.fromMap(map)).toList();
    } catch (e) {
      logger.error(
        'Erreur lors de la récupération des collectes par période: $e',
      );
      rethrow;
    }
  }
}
