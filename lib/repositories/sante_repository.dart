import '../models/pesee.dart';
import '../models/soin.dart';
import '../models/medicament.dart';
import '../models/deces.dart';
import '../services/database_helper.dart';

/// Repository spécialisé pour les opérations de santé
///
/// Gère pesées, soins, médicaments et décès.
class SanteRepository {
  static final SanteRepository instance = SanteRepository._init();
  SanteRepository._init();

  final DatabaseHelper _db = DatabaseHelper.instance;

  // ============= CRUD PESÉES =============

  Future<List<Pesee>> getAllPesees() => _db.getAllPesees();

  Future<List<Pesee>> getPeseesByLapin(int lapinId) =>
      _db.getPeseesByLapin(lapinId);

  Future<Pesee> insertPesee(Pesee pesee) => _db.insertPesee(pesee);

  Future<int> updatePesee(Pesee pesee) => _db.updatePesee(pesee);

  Future<int> deletePesee(int id) => _db.deletePesee(id);

  Future<Pesee?> getDernierePesee(int lapinId) => _db.getDernierePesee(lapinId);

  Future<List<Pesee>> getPeseesByPeriode(DateTime debut, DateTime fin) =>
      _db.getPeseesByPeriode(debut, fin);

  // ============= CRUD SOINS =============

  Future<List<Soin>> getAllSoins() => _db.getAllSoins();

  Future<List<Soin>> getSoinsByLapin(int lapinId) =>
      _db.getSoinsByLapin(lapinId);

  Future<Soin?> getSoinById(int id) => _db.getSoinById(id);

  Future<Soin> insertSoin(Soin soin) => _db.insertSoin(soin);

  Future<int> updateSoin(Soin soin) => _db.updateSoin(soin);

  Future<int> deleteSoin(int id) => _db.deleteSoin(id);

  Future<List<Soin>> getSoinsAvecRappel() => _db.getSoinsAvecRappel();

  Future<List<Soin>> getSoinsByType(String type) => _db.getSoinsByType(type);

  Future<List<Soin>> getSoinsByPeriode(DateTime debut, DateTime fin) =>
      _db.getSoinsByPeriode(debut, fin);

  // ============= CRUD MÉDICAMENTS =============

  Future<List<Medicament>> getAllMedicaments() => _db.getAllMedicaments();

  Future<Medicament> insertMedicament(Medicament medicament) =>
      _db.insertMedicament(medicament);

  // ============= CRUD DÉCÈS =============

  Future<List<Deces>> getAllDeces() => _db.getAllDeces();

  Future<Deces?> getDecesByLapin(int lapinId) => _db.getDecesByLapin(lapinId);

  Future<Deces> insertDeces(Deces deces) => _db.insertDeces(deces);

  Future<int> updateDeces(Deces deces) => _db.updateDeces(deces);

  Future<int> deleteDeces(int id) => _db.deleteDeces(id);

  Future<List<Deces>> getDecesByPeriode(DateTime debut, DateTime fin) =>
      _db.getDecesByPeriode(debut, fin);

  Future<List<Deces>> getDecesByCause(String cause) =>
      _db.getDecesByCause(cause);

  Future<int> countDecesByPeriode(DateTime debut, DateTime fin) =>
      _db.countDecesByPeriode(debut, fin);
}
