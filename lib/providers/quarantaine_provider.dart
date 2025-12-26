import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/quarantaine.dart';
import '../services/database_helper.dart';

class QuarantaineProvider with ChangeNotifier {
  final List<Quarantaine> _quarantaines = [];
  bool _isLoading = false;

  List<Quarantaine> get quarantaines => [..._quarantaines];
  bool get isLoading => _isLoading;

  /// Quarantaines en cours
  List<Quarantaine> get quarantainesEnCours =>
      _quarantaines.where((q) => q.estEnCours).toList();

  /// Charger toutes les quarantaines
  Future<void> chargerQuarantaines() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'quarantaines',
        orderBy: 'date_debut DESC',
      );

      _quarantaines.clear();
      _quarantaines.addAll(maps.map((map) => Quarantaine.fromMap(map)));
    } catch (e) {
      debugPrint('Erreur lors du chargement des quarantaines: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajouter une quarantaine
  Future<void> ajouterQuarantaine(Quarantaine quarantaine) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final id = await db.insert(
        'quarantaines',
        quarantaine.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final nouvelleQuarantaine = quarantaine.copyWith(id: id);
      _quarantaines.insert(0, nouvelleQuarantaine);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout de la quarantaine: $e');
      rethrow;
    }
  }

  /// Modifier une quarantaine
  Future<void> modifierQuarantaine(Quarantaine quarantaine) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'quarantaines',
        quarantaine.toMap(),
        where: 'id = ?',
        whereArgs: [quarantaine.id],
      );

      final index = _quarantaines.indexWhere((q) => q.id == quarantaine.id);
      if (index != -1) {
        _quarantaines[index] = quarantaine;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors de la modification de la quarantaine: $e');
      rethrow;
    }
  }

  /// Terminer une quarantaine
  Future<void> terminerQuarantaine(int quarantaineId, DateTime dateFin) async {
    try {
      final quarantaine = _quarantaines.firstWhere(
        (q) => q.id == quarantaineId,
      );
      final quarantaineTerminee = quarantaine.copyWith(
        dateFin: dateFin,
        statut: 'termine',
      );

      await modifierQuarantaine(quarantaineTerminee);
    } catch (e) {
      debugPrint('Erreur lors de la terminaison de la quarantaine: $e');
      rethrow;
    }
  }

  /// Supprimer une quarantaine
  Future<void> supprimerQuarantaine(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('quarantaines', where: 'id = ?', whereArgs: [id]);

      _quarantaines.removeWhere((q) => q.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la suppression de la quarantaine: $e');
      rethrow;
    }
  }

  /// Obtenir les quarantaines d'un lapin
  Future<List<Quarantaine>> obtenirQuarantainesLapin(int lapinId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'quarantaines',
        where: 'lapin_id = ?',
        whereArgs: [lapinId],
        orderBy: 'date_debut DESC',
      );

      return maps.map((map) => Quarantaine.fromMap(map)).toList();
    } catch (e) {
      debugPrint(
        'Erreur lors de la récupération des quarantaines du lapin: $e',
      );
      rethrow;
    }
  }

  /// Vérifier si un lapin est en quarantaine
  Future<bool> estEnQuarantaine(int lapinId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'quarantaines',
        where: 'lapin_id = ? AND statut = ?',
        whereArgs: [lapinId, 'en_cours'],
        limit: 1,
      );

      return maps.isNotEmpty;
    } catch (e) {
      debugPrint('Erreur lors de la vérification de la quarantaine: $e');
      return false;
    }
  }

  /// Obtenir la durée moyenne des quarantaines
  double getDureeMoyenne() {
    if (_quarantaines.isEmpty) return 0.0;
    final totalJours = _quarantaines.fold<int>(
      0,
      (sum, quarantaine) => sum + quarantaine.dureeJours,
    );
    return totalJours / _quarantaines.length;
  }

  /// Lever une quarantaine
  Future<void> leverQuarantaine(int id, DateTime dateFin) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'quarantaines',
        {'date_fin': dateFin.toIso8601String(), 'statut': 'termine'},
        where: 'id = ?',
        whereArgs: [id],
      );

      await chargerQuarantaines();
    } catch (e) {
      debugPrint('Erreur lors de la levée de quarantaine: $e');
      rethrow;
    }
  }

  /// Statistiques des quarantaines
  Future<Map<String, dynamic>> obtenirStatistiques() async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Répartition par motif
      final repartitionMotif = await db.rawQuery('''
        SELECT motif, COUNT(*) as nombre
        FROM quarantaines
        GROUP BY motif
      ''');

      // Durée moyenne
      final dureeMoyenne = await db.rawQuery('''
        SELECT AVG(
          julianday(COALESCE(date_fin, datetime('now'))) - julianday(date_debut)
        ) as duree_moyenne
        FROM quarantaines
      ''');

      // Quarantaines par statut
      final repartitionStatut = await db.rawQuery('''
        SELECT statut, COUNT(*) as nombre
        FROM quarantaines
        GROUP BY statut
      ''');

      return {
        'nombre_total': _quarantaines.length,
        'nombre_en_cours': quarantainesEnCours.length,
        'repartition_motif': repartitionMotif,
        'duree_moyenne_jours': dureeMoyenne.first['duree_moyenne'] ?? 0.0,
        'repartition_statut': repartitionStatut,
      };
    } catch (e) {
      debugPrint('Erreur lors du calcul des statistiques: $e');
      rethrow;
    }
  }
}
