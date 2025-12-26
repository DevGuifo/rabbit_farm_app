import 'package:flutter/foundation.dart';
import '../models/evenement_personnalise.dart';
import '../services/database_helper.dart';

class EvenementPersonnaliseProvider with ChangeNotifier {
  List<EvenementPersonnalise> _evenements = [];
  bool _isLoading = false;

  List<EvenementPersonnalise> get evenements => _evenements;
  bool get isLoading => _isLoading;

  /// Charger tous les événements
  Future<void> chargerEvenements() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query(
        'evenements_personnalises',
        orderBy: 'date ASC',
      );
      _evenements = maps
          .map((map) => EvenementPersonnalise.fromMap(map))
          .toList();
    } catch (e) {
      debugPrint('Erreur chargement événements: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajouter un événement
  Future<bool> ajouterEvenement(EvenementPersonnalise evenement) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final id = await db.insert('evenements_personnalises', evenement.toMap());

      final nouvelEvenement = evenement.copyWith(id: id);
      _evenements.add(nouvelEvenement);
      _evenements.sort((a, b) => a.date.compareTo(b.date));

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erreur ajout événement: $e');
      return false;
    }
  }

  /// Modifier un événement
  Future<bool> modifierEvenement(EvenementPersonnalise evenement) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'evenements_personnalises',
        evenement.toMap(),
        where: 'id = ?',
        whereArgs: [evenement.id],
      );

      final index = _evenements.indexWhere((e) => e.id == evenement.id);
      if (index != -1) {
        _evenements[index] = evenement;
        _evenements.sort((a, b) => a.date.compareTo(b.date));
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erreur modification événement: $e');
      return false;
    }
  }

  /// Supprimer un événement
  Future<bool> supprimerEvenement(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'evenements_personnalises',
        where: 'id = ?',
        whereArgs: [id],
      );

      _evenements.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erreur suppression événement: $e');
      return false;
    }
  }

  /// Obtenir événements pour une date donnée
  List<EvenementPersonnalise> getEvenementsForDate(DateTime date) {
    return _evenements.where((e) {
      return e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day;
    }).toList();
  }

  /// Obtenir événements à venir (7 prochains jours)
  List<EvenementPersonnalise> getEvenementsAVenir() {
    final maintenant = DateTime.now();
    final dansSeptJours = maintenant.add(const Duration(days: 7));

    return _evenements.where((e) {
      return e.date.isAfter(maintenant) && e.date.isBefore(dansSeptJours);
    }).toList();
  }
}
