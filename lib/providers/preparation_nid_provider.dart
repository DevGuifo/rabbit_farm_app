import 'package:flutter/material.dart';
import '../models/preparation_nid.dart';
import '../services/database_helper.dart';
import '../utils/logger.dart';

/// Provider pour gérer les préparations de nid
class PreparationNidProvider with ChangeNotifier {
  List<PreparationNid> _preparations = [];
  bool _isLoading = false;

  List<PreparationNid> get preparations => _preparations;
  bool get isLoading => _isLoading;

  /// Charger toutes les préparations de nid depuis la base de données
  Future<void> chargerPreparations() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query(
        'preparations_nid',
        orderBy: 'date_preparation DESC',
      );
      _preparations = maps.map((map) => PreparationNid.fromMap(map)).toList();
    } catch (e) {
      logger.error('❌ Erreur lors du chargement des préparations de nid: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajouter une préparation de nid
  Future<void> ajouterPreparation(PreparationNid preparation) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final id = await db.insert('preparations_nid', preparation.toMap());
      final nouvellePreparation = preparation.copyWith(id: id);
      _preparations.insert(0, nouvellePreparation);
      notifyListeners();
    } catch (e) {
      logger.error('❌ Erreur lors de l\'ajout de la préparation de nid: $e');
      rethrow;
    }
  }

  /// Modifier une préparation de nid
  Future<void> modifierPreparation(PreparationNid preparation) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'preparations_nid',
        preparation.toMap(),
        where: 'id = ?',
        whereArgs: [preparation.id],
      );

      final index = _preparations.indexWhere((p) => p.id == preparation.id);
      if (index != -1) {
        _preparations[index] = preparation;
        notifyListeners();
      }
    } catch (e) {
      logger.error(
        '❌ Erreur lors de la modification de la préparation de nid: $e',
      );
      rethrow;
    }
  }

  /// Supprimer une préparation de nid
  Future<void> supprimerPreparation(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('preparations_nid', where: 'id = ?', whereArgs: [id]);
      _preparations.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      logger.error(
        '❌ Erreur lors de la suppression de la préparation de nid: $e',
      );
      rethrow;
    }
  }

  /// Obtenir les préparations d'un accouplement spécifique
  List<PreparationNid> getPreparationsParAccouplement(int accouplementId) {
    return _preparations
        .where((p) => p.accouplementId == accouplementId)
        .toList();
  }

  /// Obtenir une préparation par son ID
  PreparationNid? getPreparationById(int id) {
    try {
      return _preparations.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir la dernière préparation d'un accouplement
  PreparationNid? getDernierePreparation(int accouplementId) {
    final preparations = getPreparationsParAccouplement(accouplementId);
    if (preparations.isEmpty) return null;

    preparations.sort((a, b) => b.datePreparation.compareTo(a.datePreparation));
    return preparations.first;
  }

  /// Statistiques : taux de nids bien préparés
  double? getTauxNidsPrepares() {
    if (_preparations.isEmpty) return null;

    final nidsPrepares = _preparations.where((p) => p.boiteNidInstallee).length;
    return (nidsPrepares / _preparations.length) * 100;
  }

  /// Statistiques : répartition de la qualité des nids
  Map<String, int> getRepartitionQualite() {
    final Map<String, int> stats = {'avec_boite': 0, 'sans_boite': 0};

    for (final preparation in _preparations) {
      if (preparation.boiteNidInstallee) {
        stats['avec_boite'] = (stats['avec_boite'] ?? 0) + 1;
      } else {
        stats['sans_boite'] = (stats['sans_boite'] ?? 0) + 1;
      }
    }

    return stats;
  }

  /// Filtrer les préparations par qualité
  List<PreparationNid> getPreparationsParQualite(String qualite) {
    // Adapter pour le modèle existant
    return _preparations;
  }

  /// Filtrer les préparations par période
  List<PreparationNid> getPreparationsParPeriode(DateTime debut, DateTime fin) {
    return _preparations.where((p) {
      return p.datePreparation.isAfter(
            debut.subtract(const Duration(days: 1)),
          ) &&
          p.datePreparation.isBefore(fin.add(const Duration(days: 1)));
    }).toList();
  }

  /// Obtenir les préparations récentes (30 derniers jours)
  List<PreparationNid> getPreparationsRecentes() {
    final dateLimit = DateTime.now().subtract(const Duration(days: 30));
    return _preparations
        .where((p) => p.datePreparation.isAfter(dateLimit))
        .toList();
  }

  /// Statistiques : nombre de préparations par mois
  Map<String, int> getPreparationsParMois() {
    final Map<String, int> stats = {};

    for (final preparation in _preparations) {
      final mois =
          '${preparation.datePreparation.year}-${preparation.datePreparation.month.toString().padLeft(2, '0')}';
      stats[mois] = (stats[mois] ?? 0) + 1;
    }

    return stats;
  }

  /// Vérifier si un accouplement a déjà une préparation de nid
  bool accouplementDejaPreparation(int accouplementId) {
    return _preparations.any((p) => p.accouplementId == accouplementId);
  }

  /// Obtenir les nids non préparés
  List<PreparationNid> getNidsNonPrepares() {
    return _preparations.where((p) => !p.boiteNidInstallee).toList();
  }

  /// Obtenir les nids de mauvaise qualité
  List<PreparationNid> getNidsMauvaiseQualite() {
    return _preparations.where((p) => !p.boiteNidInstallee).toList();
  }

  /// Obtenir les nids excellents récents
  List<PreparationNid> getNidsExcellentsRecents() {
    final dateLimit = DateTime.now().subtract(const Duration(days: 30));
    return _preparations
        .where(
          (p) => p.boiteNidInstallee && p.datePreparation.isAfter(dateLimit),
        )
        .toList();
  }
}
