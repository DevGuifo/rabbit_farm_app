import '../models/accouplement.dart';
import '../models/portee.dart';
import '../services/database_helper.dart';

/// Repository spécialisé pour les opérations de reproduction
///
/// Gère accouplements et portées.
class ReproductionRepository {
  static final ReproductionRepository instance = ReproductionRepository._init();
  ReproductionRepository._init();

  final DatabaseHelper _db = DatabaseHelper.instance;

  // ============= CRUD ACCOUPLEMENTS =============

  Future<List<Accouplement>> getAllAccouplements() => _db.getAllAccouplements();

  Future<Accouplement?> getAccouplementById(int id) =>
      _db.getAccouplementById(id);

  Future<Accouplement> insertAccouplement(Accouplement accouplement) =>
      _db.insertAccouplement(accouplement);

  Future<int> updateAccouplement(Accouplement accouplement) =>
      _db.updateAccouplement(accouplement);

  Future<int> deleteAccouplement(int id) => _db.deleteAccouplement(id);

  // ============= REQUÊTES ACCOUPLEMENTS =============

  Future<List<Accouplement>> getAccouplementsByStatut(String statut) =>
      _db.getAccouplementsByStatut(statut);

  Future<List<Accouplement>> getAccouplementsEnAttente() =>
      _db.getAccouplementsEnAttente();

  Future<List<Accouplement>> getAccouplementsByFemelle(int femelleId) =>
      _db.getAccouplementsByFemelle(femelleId);

  Future<List<Accouplement>> getAccouplementsByMale(int maleId) =>
      _db.getAccouplementsByMale(maleId);

  // ============= CRUD PORTÉES =============

  Future<List<Portee>> getAllPortees() => _db.getAllPortees();

  Future<Portee?> getPorteeById(int id) => _db.getPorteeById(id);

  Future<Portee> insertPortee(Portee portee) => _db.insertPortee(portee);

  Future<int> updatePortee(Portee portee) => _db.updatePortee(portee);

  Future<int> deletePortee(int id) => _db.deletePortee(id);

  // ============= REQUÊTES PORTÉES =============

  Future<Portee?> getPorteeByAccouplement(int accouplementId) =>
      _db.getPorteeByAccouplement(accouplementId);
}
