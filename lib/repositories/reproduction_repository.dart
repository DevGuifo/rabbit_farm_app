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

  // ============= OPÉRATIONS TRANSACTIONNELLES =============

  /// Enregistrer une mise bas de manière atomique
  ///
  /// Cette méthode garantit que la portée est créée ET l'accouplement
  /// est marqué comme terminé dans une seule transaction.
  /// En cas d'erreur, aucune modification n'est appliquée (rollback).
  ///
  /// Paramètres:
  /// - [portee]: La portée à créer
  /// - [accouplementId]: L'ID de l'accouplement à clôturer
  ///
  /// Retourne la portée créée avec son ID
  Future<Portee> enregistrerMiseBas({
    required Portee portee,
    required int accouplementId,
  }) async {
    return await _db.transaction((txn) async {
      // 1. Insérer la portée
      final porteeData = await _db.prepareDataForInsert(
        portee.toMap(),
        tableName: 'portees',
      );
      final porteeId = await txn.insert('portees', porteeData);

      // 2. Mettre à jour l'accouplement (statut = termine)
      final accouplementData = {
        'statut': 'termine',
        'updated_at': DateTime.now().toIso8601String(),
        'is_dirty': 1,
      };
      final filteredData = await _db.filterColumnsForUpdate(
        accouplementData,
        'accouplements',
      );
      await txn.update(
        'accouplements',
        filteredData,
        where: 'id = ?',
        whereArgs: [accouplementId],
      );

      // 3. Retourner la portée avec son ID
      return portee.copyWith(id: porteeId);
    });
  }
}
