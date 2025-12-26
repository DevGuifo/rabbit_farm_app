import 'package:flutter/material.dart';
import '../models/sevrage.dart';
import '../services/database_helper.dart';

/// Provider pour gérer les sevrages
class SevrageProvider with ChangeNotifier {
  List<Sevrage> _sevrages = [];
  bool _isLoading = false;

  List<Sevrage> get sevrages => _sevrages;
  bool get isLoading => _isLoading;

  /// Charger tous les sevrages depuis la base de données
  Future<void> chargerSevrages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query('sevrages', orderBy: 'date_sevrage DESC');
      _sevrages = maps.map((map) => Sevrage.fromMap(map)).toList();
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des sevrages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajouter un sevrage
  Future<void> ajouterSevrage(Sevrage sevrage) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final id = await db.insert('sevrages', sevrage.toMap());
      final nouveauSevrage = sevrage.copyWith(id: id);
      _sevrages.insert(0, nouveauSevrage);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'ajout du sevrage: $e');
      rethrow;
    }
  }

  /// Modifier un sevrage
  Future<void> modifierSevrage(Sevrage sevrage) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'sevrages',
        sevrage.toMap(),
        where: 'id = ?',
        whereArgs: [sevrage.id],
      );

      final index = _sevrages.indexWhere((s) => s.id == sevrage.id);
      if (index != -1) {
        _sevrages[index] = sevrage;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la modification du sevrage: $e');
      rethrow;
    }
  }

  /// Supprimer un sevrage
  Future<void> supprimerSevrage(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('sevrages', where: 'id = ?', whereArgs: [id]);
      _sevrages.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression du sevrage: $e');
      rethrow;
    }
  }

  /// Obtenir les sevrages d'une portée spécifique
  List<Sevrage> getSevragesParPortee(int porteeId) {
    return _sevrages.where((s) => s.porteeId == porteeId).toList();
  }

  /// Obtenir un sevrage par son ID
  Sevrage? getSevrageById(int id) {
    try {
      return _sevrages.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Statistiques : âge moyen au sevrage (en jours)
  double? getAgeMoyenSevrage() {
    if (_sevrages.isEmpty) return null;

    // Ici il faudrait calculer l'âge à partir de la date de naissance de la portée
    // Pour l'instant on retourne null, à implémenter avec les données de portée
    return null;
  }

  /// Statistiques : poids moyen au sevrage
  double? getPoidsMoyenSevrage() {
    final sevragesAvecPoids = _sevrages
        .where((s) => s.poidsMoyenSevrage != null)
        .toList();
    if (sevragesAvecPoids.isEmpty) return null;

    final total = sevragesAvecPoids.fold<double>(
      0,
      (sum, s) => sum + s.poidsMoyenSevrage!,
    );
    return total / sevragesAvecPoids.length;
  }

  /// Statistiques : nombre total de lapereaux sevrés
  int getTotalLapereaux() {
    return _sevrages.fold<int>(0, (sum, s) => sum + s.nombreLapereaux);
  }

  /// Statistiques : taux de réussite (nombre de sevrages / nombre de portées)
  double? getTauxReussite(int nombrePortees) {
    if (nombrePortees == 0) return null;
    return (_sevrages.length / nombrePortees) * 100;
  }

  /// Filtrer les sevrages par période
  List<Sevrage> getSevragesParPeriode(DateTime debut, DateTime fin) {
    return _sevrages.where((s) {
      return s.dateSevrage.isAfter(debut.subtract(const Duration(days: 1))) &&
          s.dateSevrage.isBefore(fin.add(const Duration(days: 1)));
    }).toList();
  }

  /// Obtenir les sevrages récents (30 derniers jours)
  List<Sevrage> getSevragesRecents() {
    final dateLimit = DateTime.now().subtract(const Duration(days: 30));
    return _sevrages.where((s) => s.dateSevrage.isAfter(dateLimit)).toList();
  }

  /// Statistiques : nombre de sevrages par mois
  Map<String, int> getSevragesParMois() {
    final Map<String, int> stats = {};

    for (final sevrage in _sevrages) {
      final mois =
          '${sevrage.dateSevrage.year}-${sevrage.dateSevrage.month.toString().padLeft(2, '0')}';
      stats[mois] = (stats[mois] ?? 0) + 1;
    }

    return stats;
  }

  /// Vérifier si une portée a déjà été sevrée
  bool porteeDejaSevre(int porteeId) {
    return _sevrages.any((s) => s.porteeId == porteeId);
  }
}
