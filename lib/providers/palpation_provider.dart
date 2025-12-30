import 'package:flutter/material.dart';
import '../models/palpation.dart';
import '../services/database_helper.dart';
import '../utils/logger.dart';

/// Provider pour gérer les palpations
class PalpationProvider with ChangeNotifier {
  List<Palpation> _palpations = [];
  bool _isLoading = false;

  List<Palpation> get palpations => _palpations;
  bool get isLoading => _isLoading;

  /// Charger toutes les palpations depuis la base de données
  Future<void> chargerPalpations() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query('palpations', orderBy: 'date_palpation DESC');
      _palpations = maps.map((map) => Palpation.fromMap(map)).toList();
    } catch (e) {
      logger.error('❌ Erreur lors du chargement des palpations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajouter une palpation
  Future<void> ajouterPalpation(Palpation palpation) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final id = await db.insert('palpations', palpation.toMap());
      final nouvellePalpation = palpation.copyWith(id: id);
      _palpations.insert(0, nouvellePalpation);
      notifyListeners();
    } catch (e) {
      logger.error('❌ Erreur lors de l\'ajout de la palpation: $e');
      rethrow;
    }
  }

  /// Modifier une palpation
  Future<void> modifierPalpation(Palpation palpation) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'palpations',
        palpation.toMap(),
        where: 'id = ?',
        whereArgs: [palpation.id],
      );

      final index = _palpations.indexWhere((p) => p.id == palpation.id);
      if (index != -1) {
        _palpations[index] = palpation;
        notifyListeners();
      }
    } catch (e) {
      logger.error('❌ Erreur lors de la modification de la palpation: $e');
      rethrow;
    }
  }

  /// Supprimer une palpation
  Future<void> supprimerPalpation(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('palpations', where: 'id = ?', whereArgs: [id]);
      _palpations.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      logger.error('❌ Erreur lors de la suppression de la palpation: $e');
      rethrow;
    }
  }

  /// Obtenir les palpations d'un accouplement spécifique
  List<Palpation> getPalpationsParAccouplement(int accouplementId) {
    return _palpations
        .where((p) => p.accouplementId == accouplementId)
        .toList();
  }

  /// Obtenir une palpation par son ID
  Palpation? getPalpationById(int id) {
    try {
      return _palpations.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir la dernière palpation d'un accouplement
  Palpation? getDernierePalpation(int accouplementId) {
    final palpations = getPalpationsParAccouplement(accouplementId);
    if (palpations.isEmpty) return null;

    palpations.sort((a, b) => b.datePalpation.compareTo(a.datePalpation));
    return palpations.first;
  }

  /// Statistiques : taux de réussite des palpations positives
  double? getTauxReussite() {
    if (_palpations.isEmpty) return null;

    final positives = _palpations.where((p) => p.gestante == true).length;
    return (positives / _palpations.length) * 100;
  }

  /// Statistiques : répartition des résultats
  Map<String, int> getRepartitionResultats() {
    final Map<String, int> stats = {'positif': 0, 'negatif': 0};

    for (final palpation in _palpations) {
      if (palpation.gestante) {
        stats['positif'] = (stats['positif'] ?? 0) + 1;
      } else {
        stats['negatif'] = (stats['negatif'] ?? 0) + 1;
      }
    }

    return stats;
  }

  /// Statistiques : nombre moyen de fœtus estimés
  double? getNombreMoyenFoetus() {
    final palpationsAvecFoetus = _palpations
        .where((p) => p.nombreFoetusPalpes != null)
        .toList();
    if (palpationsAvecFoetus.isEmpty) return null;

    final total = palpationsAvecFoetus.fold<double>(
      0,
      (sum, p) => sum + p.nombreFoetusPalpes!.toDouble(),
    );
    return total / palpationsAvecFoetus.length;
  }

  /// Filtrer les palpations par résultat
  List<Palpation> getPalpationsParResultat(String resultat) {
    final bool estPositif = resultat == 'positif';
    return _palpations.where((p) => p.gestante == estPositif).toList();
  }

  /// Filtrer les palpations par période
  List<Palpation> getPalpationsParPeriode(DateTime debut, DateTime fin) {
    return _palpations.where((p) {
      return p.datePalpation.isAfter(debut.subtract(const Duration(days: 1))) &&
          p.datePalpation.isBefore(fin.add(const Duration(days: 1)));
    }).toList();
  }

  /// Obtenir les palpations récentes (30 derniers jours)
  List<Palpation> getPalpationsRecentes() {
    final dateLimit = DateTime.now().subtract(const Duration(days: 30));
    return _palpations
        .where((p) => p.datePalpation.isAfter(dateLimit))
        .toList();
  }

  /// Statistiques : nombre de palpations par mois
  Map<String, int> getPalpationsParMois() {
    final Map<String, int> stats = {};

    for (final palpation in _palpations) {
      final mois =
          '${palpation.datePalpation.year}-${palpation.datePalpation.month.toString().padLeft(2, '0')}';
      stats[mois] = (stats[mois] ?? 0) + 1;
    }

    return stats;
  }

  /// Vérifier si un accouplement a déjà été palpé
  bool accouplementDejaPalpe(int accouplementId) {
    return _palpations.any((p) => p.accouplementId == accouplementId);
  }

  /// Obtenir les palpations positives récentes
  List<Palpation> getPalpationsPositivesRecentes() {
    final dateLimit = DateTime.now().subtract(const Duration(days: 30));
    return _palpations
        .where((p) => p.gestante == true && p.datePalpation.isAfter(dateLimit))
        .toList();
  }
}
