import 'package:flutter/foundation.dart';
import '../models/deces.dart';
import '../services/database_helper.dart';

/// Provider pour la gestion des décès
class DecesProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Deces> _deces = [];
  bool _isLoading = false;

  List<Deces> get deces => _deces;
  bool get isLoading => _isLoading;

  /// Charger tous les décès
  Future<void> loadDeces() async {
    _isLoading = true;
    notifyListeners();

    try {
      _deces = await _dbHelper.getAllDeces();
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des décès: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Enregistrer un décès
  Future<Deces?> enregistrerDeces(
    Deces deces, {
    required Function(int lapinId) onLapinDecede,
  }) async {
    try {
      // Insérer le décès dans la base de données
      final nouveauDeces = await _dbHelper.insertDeces(deces);

      // Mettre à jour le statut du lapin dans la base de données
      await onLapinDecede(deces.lapinId);

      // Ajouter à la liste locale
      _deces.insert(0, nouveauDeces);
      notifyListeners();

      debugPrint('✅ Décès enregistré pour le lapin ${deces.lapinId}');
      return nouveauDeces;
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'enregistrement du décès: $e');
      return null;
    }
  }

  /// Récupérer le décès d'un lapin
  Future<Deces?> getDecesByLapin(int lapinId) async {
    try {
      return await _dbHelper.getDecesByLapin(lapinId);
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération du décès: $e');
      return null;
    }
  }

  /// Récupérer les décès par période
  Future<List<Deces>> getDecesByPeriode(DateTime debut, DateTime fin) async {
    try {
      return await _dbHelper.getDecesByPeriode(debut, fin);
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des décès: $e');
      return [];
    }
  }

  /// Récupérer les décès par cause
  Future<List<Deces>> getDecesByCause(String cause) async {
    try {
      return await _dbHelper.getDecesByCause(cause);
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des décès: $e');
      return [];
    }
  }

  /// Calculer le taux de mortalité sur une période
  /// Retourne un pourcentage (0-100)
  Future<double> getTauxMortalite(
    DateTime debut,
    DateTime fin,
    int effectifTotal,
  ) async {
    try {
      final nombreDeces = await _dbHelper.countDecesByPeriode(debut, fin);
      if (effectifTotal == 0) return 0.0;
      return (nombreDeces / effectifTotal) * 100;
    } catch (e) {
      debugPrint('❌ Erreur lors du calcul du taux de mortalité: $e');
      return 0.0;
    }
  }

  /// Détecter une mortalité anormale
  /// Retourne true si le taux de mortalité dépasse le seuil (5% sur 7 jours)
  Future<bool> detecterMortaliteAnormale({
    int joursAnalyse = 7,
    double seuilPourcentage = 5.0,
  }) async {
    try {
      final maintenant = DateTime.now();
      final debut = maintenant.subtract(Duration(days: joursAnalyse));

      // Récupérer l'effectif total actif
      final lapins = await _dbHelper.getAllLapins();
      final lapinsActifs = lapins.where((l) => l.statut != 'decede').length;
      final effectifTotal =
          lapinsActifs + await _dbHelper.countDecesByPeriode(debut, maintenant);

      final tauxMortalite = await getTauxMortalite(
        debut,
        maintenant,
        effectifTotal,
      );

      return tauxMortalite > seuilPourcentage;
    } catch (e) {
      debugPrint('❌ Erreur lors de la détection de mortalité anormale: $e');
      return false;
    }
  }

  /// Obtenir les statistiques de mortalité par cause
  Future<Map<String, int>> getStatistiquesMortaliteByCause() async {
    try {
      final Map<String, int> stats = {};

      for (final cause in CauseDeces.values) {
        final decesByCause = await _dbHelper.getDecesByCause(cause);
        stats[cause] = decesByCause.length;
      }

      return stats;
    } catch (e) {
      debugPrint('❌ Erreur lors du calcul des statistiques: $e');
      return {};
    }
  }

  /// Obtenir les statistiques de mortalité par tranche d'âge
  Future<Map<String, int>> getStatistiquesMortaliteByAge() async {
    try {
      final Map<String, int> stats = {
        '0-30 jours': 0,
        '31-60 jours': 0,
        '61-150 jours': 0,
        '151-365 jours': 0,
        '1+ an': 0,
      };

      for (final deces in _deces) {
        final age = deces.ageAuDecesJours;
        if (age <= 30) {
          stats['0-30 jours'] = stats['0-30 jours']! + 1;
        } else if (age <= 60) {
          stats['31-60 jours'] = stats['31-60 jours']! + 1;
        } else if (age <= 150) {
          stats['61-150 jours'] = stats['61-150 jours']! + 1;
        } else if (age <= 365) {
          stats['151-365 jours'] = stats['151-365 jours']! + 1;
        } else {
          stats['1+ an'] = stats['1+ an']! + 1;
        }
      }

      return stats;
    } catch (e) {
      debugPrint('❌ Erreur lors du calcul des statistiques par âge: $e');
      return {};
    }
  }

  /// Calculer l'âge moyen au décès
  double getAgeMoyenDeces() {
    if (_deces.isEmpty) return 0.0;

    final totalAge = _deces.fold<int>(
      0,
      (sum, deces) => sum + deces.ageAuDecesJours,
    );

    return totalAge / _deces.length;
  }

  /// Obtenir le nombre de décès sur les 7 derniers jours
  Future<int> getNombreDecesDerniersSeptJours() async {
    final maintenant = DateTime.now();
    final debut = maintenant.subtract(const Duration(days: 7));
    return await _dbHelper.countDecesByPeriode(debut, maintenant);
  }

  /// Obtenir le nombre de décès du mois en cours
  Future<int> getNombreDecesMoisActuel() async {
    final maintenant = DateTime.now();
    final debutMois = DateTime(maintenant.year, maintenant.month, 1);
    final finMois = DateTime(maintenant.year, maintenant.month + 1, 0);
    return await _dbHelper.countDecesByPeriode(debutMois, finMois);
  }

  /// Mettre à jour un décès
  Future<bool> updateDeces(Deces deces) async {
    try {
      await _dbHelper.updateDeces(deces);

      // Mettre à jour la liste locale
      final index = _deces.indexWhere((d) => d.id == deces.id);
      if (index != -1) {
        _deces[index] = deces;
        notifyListeners();
      }

      debugPrint('✅ Décès mis à jour');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour du décès: $e');
      return false;
    }
  }

  /// Supprimer un décès
  Future<bool> deleteDeces(int id) async {
    try {
      await _dbHelper.deleteDeces(id);

      // Retirer de la liste locale
      _deces.removeWhere((d) => d.id == id);
      notifyListeners();

      debugPrint('✅ Décès supprimé');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression du décès: $e');
      return false;
    }
  }
}
