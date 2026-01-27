import '../models/batiment.dart';
import '../models/clapier.dart';
import '../models/cage.dart';
import '../models/enums/localisation_enums.dart'; // Pour TypeClapier, TypeCage
import '../services/database_helper.dart';

/// Repository pour gérer la localisation (Bâtiments, Clapiers, Cages)
class LocalisationRepository {
  static final LocalisationRepository instance = LocalisationRepository._init();
  LocalisationRepository._init();

  final DatabaseHelper _db = DatabaseHelper.instance;

  // ============= BÂTIMENTS =============

  Future<List<Batiment>> getAllBatiments() => _db.getAllBatiments();

  Future<Batiment?> getBatimentById(int id) => _db.getBatimentById(id);

  Future<Batiment> insertBatiment(Batiment batiment) =>
      _db.insertBatiment(batiment);

  Future<int> updateBatiment(Batiment batiment) => _db.updateBatiment(batiment);

  Future<int> deleteBatiment(int id) => _db.deleteBatiment(id);

  Future<int> countBatiments() => _db.countBatiments();

  // ============= CLAPIERS =============

  Future<List<Clapier>> getAllClapiers() => _db.getAllClapiers();

  Future<List<Clapier>> getClapiersByBatiment(int batimentId) =>
      _db.getClapiersByBatiment(batimentId);

  Future<Clapier?> getClapierById(int id) => _db.getClapierById(id);

  Future<Clapier> insertClapier(Clapier clapier) => _db.insertClapier(clapier);

  Future<int> updateClapier(Clapier clapier) => _db.updateClapier(clapier);

  Future<int> deleteClapier(int id) => _db.deleteClapier(id);

  // ============= CAGES =============

  Future<List<Cage>> getAllCages() => _db.getAllCages();

  Future<List<Cage>> getCagesByClapier(int clapierId) =>
      _db.getCagesByClapier(clapierId);

  Future<Cage?> getCageById(int id) => _db.getCageById(id);

  Future<Cage?> getCageByNumero(String numero) => _db.getCageByNumero(numero);

  Future<Cage> insertCage(Cage cage) => _db.insertCage(cage);

  Future<int> updateCage(Cage cage) => _db.updateCage(cage);

  Future<int> deleteCage(int id) => _db.deleteCage(id);

  Future<int> getOccupantsCage(int cageId) => _db.getOccupantsCage(cageId);

  Future<List<Map<String, dynamic>>> getCagesDisponibles() =>
      _db.getCagesDisponibles();

  // ============= LOGIQUE MÉTIER =============

  /// Générer un numéro de cage automatique (ex: A-INT-01)
  Future<String> genererNumeroCage(int clapierId) async {
    final clapier = await getClapierById(clapierId);
    if (clapier == null) throw Exception('Clapier introuvable');

    final batiment = await getBatimentById(clapier.batimentId);
    if (batiment == null) throw Exception('Bâtiment introuvable');

    final cages = await getCagesByClapier(clapierId);
    final numero = cages.length + 1;

    // Format: BATIMENT-TYPE-NUMERO
    // Note: TypeClapier doit avoir une méthode ou extension pour abréviation, sinon string brute
    final typeStr = clapier.type.toString().split('.').last;
    final typeAbrege = typeStr.length >= 3
        ? typeStr.substring(0, 3).toUpperCase()
        : typeStr.toUpperCase();

    return '${batiment.nom}-$typeAbrege-${numero.toString().padLeft(2, '0')}';
  }

  /// Initialiser des données par défaut si vide
  Future<void> initialiserLocalisationParDefaut() async {
    final batiments = await getAllBatiments();
    if (batiments.isNotEmpty) return;

    // Bâtiment A
    final batA = await insertBatiment(
      Batiment(nom: 'A', description: 'Bâtiment principal'),
    );

    // Clapier Intérieur
    final clapier = await insertClapier(
      Clapier(
        batimentId: batA.id!,
        nom: 'Intérieur',
        type: TypeClapier.interieur,
      ),
    );

    // 5 Cages
    for (int i = 1; i <= 5; i++) {
      await insertCage(
        Cage(
          clapierId: clapier.id!,
          numero: 'A-INT-${i.toString().padLeft(2, '0')}',
          type: i == 5 ? TypeCage.nid : TypeCage.individuelle,
          capacite: 1,
        ),
      );
    }
  }
}
