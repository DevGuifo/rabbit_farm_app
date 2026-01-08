import '../models/tache.dart';
import '../services/database_helper.dart';

/// Repository spécialisé pour les tâches
///
/// Gère les tâches et rappels de l'utilisateur.
class TacheRepository {
  static final TacheRepository instance = TacheRepository._init();
  TacheRepository._init();

  final DatabaseHelper _db = DatabaseHelper.instance;

  // ============= CRUD TÂCHES =============

  Future<List<Tache>> getAllTaches() => _db.getAllTaches();

  Future<Tache?> getTacheById(int id) => _db.getTacheById(id);

  Future<Tache> insertTache(Tache tache) => _db.insertTache(tache);

  Future<int> updateTache(Tache tache) => _db.updateTache(tache);

  Future<int> deleteTache(int id) => _db.deleteTache(id);

  // ============= REQUÊTES SPÉCIALISÉES =============

  Future<List<Tache>> getTachesByStatut(String statut) =>
      _db.getTachesByStatut(statut);

  Future<List<Tache>> getTachesByCategorie(String categorie) =>
      _db.getTachesByCategorie(categorie);

  Future<List<Tache>> getTachesByLapin(int lapinId) =>
      _db.getTachesByLapin(lapinId);

  Future<List<Tache>> getTachesByPeriode(DateTime debut, DateTime fin) =>
      _db.getTachesByPeriode(debut, fin);

  Future<List<Tache>> getTachesAujourdhui() => _db.getTachesAujourdhui();

  Future<List<Tache>> getTachesCetteSemaine() => _db.getTachesCetteSemaine();

  Future<int> marquerTacheTerminee(int id) => _db.marquerTacheTerminee(id);
}
