import 'package:flutter/foundation.dart';
import '../models/recette.dart';
import '../models/depense.dart';
import '../models/journal_entry.dart';
import '../services/database_helper.dart';
import '../services/journal_service.dart';

class FinanceProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final JournalService _journal = JournalService();

  List<Recette> _recettes = [];
  List<Depense> _depenses = [];

  List<Recette> get recettes => _recettes;
  List<Depense> get depenses => _depenses;

  double get totalRecettes => _recettes.fold(0.0, (sum, r) => sum + r.montant);
  double get totalDepenses => _depenses.fold(0.0, (sum, d) => sum + d.montant);
  double get benefice => totalRecettes - totalDepenses;

  /// Charger toutes les recettes et dépenses
  Future<void> chargerTout() async {
    _recettes = await _db.getAllRecettes();
    _depenses = await _db.getAllDepenses();
    notifyListeners();
  }

  /// Ajouter une recette
  Future<void> ajouterRecette(Recette recette) async {
    final nouvelleRecette = await _db.insertRecette(recette);
    _recettes.insert(0, nouvelleRecette);
    notifyListeners();

    // 📝 Journal automatique
    await _journal.recette(
      action: TypeAction.creation,
      recetteId: nouvelleRecette.id!,
      montant: nouvelleRecette.montant,
      categorie: nouvelleRecette.categorie,
      contexte: {
        'date': nouvelleRecette.date.toIso8601String(),
        'description': nouvelleRecette.description,
      },
    );
  }

  /// Ajouter une dépense
  Future<void> ajouterDepense(Depense depense) async {
    final nouvelleDepense = await _db.insertDepense(depense);
    _depenses.insert(0, nouvelleDepense);
    notifyListeners();

    // 📝 Journal automatique
    await _journal.depense(
      action: TypeAction.creation,
      depenseId: nouvelleDepense.id!,
      montant: nouvelleDepense.montant,
      categorie: nouvelleDepense.categorie,
      contexte: {
        'date': nouvelleDepense.date.toIso8601String(),
        'description': nouvelleDepense.description,
      },
    );
  }

  /// Mettre à jour une recette
  Future<void> modifierRecette(Recette recette) async {
    await _db.updateRecette(recette);
    final index = _recettes.indexWhere((r) => r.id == recette.id);
    if (index != -1) {
      _recettes[index] = recette;
      notifyListeners();
    }
  }

  /// Mettre à jour une dépense
  Future<void> modifierDepense(Depense depense) async {
    await _db.updateDepense(depense);
    final index = _depenses.indexWhere((d) => d.id == depense.id);
    if (index != -1) {
      _depenses[index] = depense;
      notifyListeners();
    }
  }

  /// Supprimer une recette
  Future<void> supprimerRecette(int id) async {
    await _db.deleteRecette(id);
    _recettes.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  /// Supprimer une dépense
  Future<void> supprimerDepense(int id) async {
    await _db.deleteDepense(id);
    _depenses.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  /// Obtenir les recettes par période
  Future<List<Recette>> getRecettesByPeriode(
    DateTime debut,
    DateTime fin,
  ) async {
    return await _db.getRecettesByPeriode(debut, fin);
  }

  /// Obtenir les dépenses par période
  Future<List<Depense>> getDepensesByPeriode(
    DateTime debut,
    DateTime fin,
  ) async {
    return await _db.getDepensesByPeriode(debut, fin);
  }

  /// Obtenir le total des recettes par catégorie
  Future<Map<String, double>> getTotalRecettesByCategorie() async {
    return await _db.getTotalRecettesByCategorie();
  }

  /// Obtenir le total des dépenses par catégorie
  Future<Map<String, double>> getTotalDepensesByCategorie() async {
    return await _db.getTotalDepensesByCategorie();
  }

  /// Obtenir le bénéfice par période
  Future<double> getBeneficeByPeriode(DateTime debut, DateTime fin) async {
    return await _db.getBeneficeByPeriode(debut, fin);
  }

  /// Obtenir les recettes d'un lapin
  Future<List<Recette>> getRecettesByLapin(int lapinId) async {
    return await _db.getRecettesByLapin(lapinId);
  }
}
