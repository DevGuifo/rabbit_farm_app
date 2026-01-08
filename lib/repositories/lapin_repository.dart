import '../models/lapin.dart';
import '../services/database_helper.dart';

/// Repository spécialisé pour les opérations sur les lapins
///
/// Délègue à DatabaseHelper pour la rétrocompatibilité
/// mais offre une interface plus propre et testable.
class LapinRepository {
  static final LapinRepository instance = LapinRepository._init();
  LapinRepository._init();

  final DatabaseHelper _db = DatabaseHelper.instance;

  // ============= CRUD LAPINS =============

  Future<List<Lapin>> getAll() => _db.getAllLapins();

  Future<Lapin?> getById(int id) => _db.getLapinById(id);

  Future<Lapin> insert(Lapin lapin) => _db.insertLapin(lapin);

  Future<int> update(Lapin lapin) => _db.updateLapin(lapin);

  Future<int> delete(int id) => _db.deleteLapin(id);

  // ============= REQUÊTES SPÉCIALISÉES =============

  Future<List<Lapin>> getMales() => _db.getLapinsBySexe('mâle');

  Future<List<Lapin>> getFemelles() => _db.getLapinsBySexe('femelle');

  Future<List<Lapin>> getByStatut(String statut) =>
      _db.getLapinsByStatut(statut);

  Future<int> count() => _db.countLapins();

  // ============= RELATIONS / GÉNÉALOGIE =============

  Future<Map<String, int?>?> getRelation(int lapinId) =>
      _db.getRelationByLapinId(lapinId);

  Future<void> setParents(int lapinId, int? pereId, int? mereId) =>
      _db.setParents(lapinId, pereId, mereId);

  Future<Lapin?> getPere(int lapinId) => _db.getPere(lapinId);

  Future<Lapin?> getMere(int lapinId) => _db.getMere(lapinId);

  Future<Map<String, Lapin?>> getParents(int lapinId) =>
      _db.getParents(lapinId);

  Future<List<Lapin>> getEnfants(int lapinId) => _db.getEnfants(lapinId);

  Future<Map<String, dynamic>> getAncetres(
    int lapinId, {
    int generations = 3,
  }) => _db.getAncetres(lapinId, generations: generations);

  Future<double> calculerConsanguinite(int lapinId) =>
      _db.calculerConsanguinite(lapinId);
}
