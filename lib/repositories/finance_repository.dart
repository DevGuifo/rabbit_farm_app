import '../models/recette.dart';
import '../models/depense.dart';
import '../services/database_helper.dart';

/// Repository spécialisé pour les opérations financières
///
/// Gère recettes et dépenses.
class FinanceRepository {
  static final FinanceRepository instance = FinanceRepository._init();
  FinanceRepository._init();

  final DatabaseHelper _db = DatabaseHelper.instance;

  // ============= CRUD RECETTES =============

  Future<List<Recette>> getAllRecettes() => _db.getAllRecettes();

  Future<Recette> insertRecette(Recette recette) => _db.insertRecette(recette);

  Future<int> updateRecette(Recette recette) => _db.updateRecette(recette);

  Future<int> deleteRecette(int id) => _db.deleteRecette(id);

  Future<List<Recette>> getRecettesByPeriode(DateTime debut, DateTime fin) =>
      _db.getRecettesByPeriode(debut, fin);

  Future<List<Recette>> getRecettesByCategorie(String categorie) =>
      _db.getRecettesByCategorie(categorie);

  Future<List<Recette>> getRecettesByLapin(int lapinId) =>
      _db.getRecettesByLapin(lapinId);

  // ============= CRUD DÉPENSES =============

  Future<List<Depense>> getAllDepenses() => _db.getAllDepenses();

  Future<Depense> insertDepense(Depense depense) => _db.insertDepense(depense);

  Future<int> updateDepense(Depense depense) => _db.updateDepense(depense);

  Future<int> deleteDepense(int id) => _db.deleteDepense(id);

  Future<List<Depense>> getDepensesByPeriode(DateTime debut, DateTime fin) =>
      _db.getDepensesByPeriode(debut, fin);

  Future<List<Depense>> getDepensesByCategorie(String categorie) =>
      _db.getDepensesByCategorie(categorie);

  // ============= STATISTIQUES =============

  Future<double> getTotalRecettes() => _db.getTotalRecettes();

  Future<double> getTotalRecettesByPeriode(DateTime debut, DateTime fin) =>
      _db.getTotalRecettesByPeriode(debut, fin);

  Future<Map<String, double>> getTotalRecettesByCategorie() =>
      _db.getTotalRecettesByCategorie();

  Future<double> getTotalDepenses() => _db.getTotalDepenses();

  Future<double> getTotalDepensesByPeriode(DateTime debut, DateTime fin) =>
      _db.getTotalDepensesByPeriode(debut, fin);

  Future<Map<String, double>> getTotalDepensesByCategorie() =>
      _db.getTotalDepensesByCategorie();

  Future<double> getBenefice() => _db.getBenefice();

  Future<double> getBeneficeByPeriode(DateTime debut, DateTime fin) =>
      _db.getBeneficeByPeriode(debut, fin);
}
