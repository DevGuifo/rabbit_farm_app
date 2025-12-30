import '../../interfaces/ilapin_repository.dart';
import '../../../models/lapin.dart';
import '../../../services/database_helper.dart';

/// Implémentation SQLite du repository des lapins
/// 
/// Cette implémentation utilise DatabaseHelper actuel
/// et sera utilisée lors de la migration progressive
/// 
/// **Note :** Cette implémentation n'est pas encore utilisée.
/// Elle sera activée lors de la Phase 3 de la migration Supabase.
class SQLiteLapinRepository implements ILapinRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  @override
  Future<Lapin> insert(Lapin lapin) async {
    return await _db.insertLapin(lapin);
  }

  @override
  Future<List<Lapin>> getAll() async {
    return await _db.getAllLapins();
  }

  @override
  Future<Lapin?> getById(int id) async {
    return await _db.getLapinById(id);
  }

  @override
  Future<int> update(Lapin lapin) async {
    return await _db.updateLapin(lapin);
  }

  @override
  Future<int> delete(int id) async {
    return await _db.deleteLapin(id);
  }

  @override
  Future<List<Lapin>> getBySexe(String sexe) async {
    return await _db.getLapinsBySexe(sexe);
  }

  @override
  Future<List<Lapin>> getByStatut(String statut) async {
    return await _db.getLapinsByStatut(statut);
  }

  @override
  Future<int> count() async {
    return await _db.countLapins();
  }

  @override
  Future<List<Lapin>> search(String query) async {
    final allLapins = await getAll();
    final queryLower = query.toLowerCase();
    return allLapins.where((lapin) {
      return lapin.nom.toLowerCase().contains(queryLower) ||
          (lapin.numeroIdentification?.toLowerCase().contains(queryLower) ??
              false) ||
          lapin.race.toLowerCase().contains(queryLower);
    }).toList();
  }
}

