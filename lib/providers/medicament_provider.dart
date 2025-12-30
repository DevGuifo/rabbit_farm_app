import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/medicament.dart';
import '../models/utilisation_medicament.dart';
import '../services/database_helper.dart';
import '../utils/logger.dart';

class MedicamentProvider with ChangeNotifier {
  final List<Medicament> _medicaments = [];
  final List<UtilisationMedicament> _utilisations = [];
  bool _isLoading = false;

  List<Medicament> get medicaments => [..._medicaments];
  List<UtilisationMedicament> get utilisations => [..._utilisations];
  bool get isLoading => _isLoading;

  /// Médicaments en alerte (rupture, seuil, expiration)
  List<Medicament> get medicamentsEnAlerte => _medicaments
      .where(
        (m) =>
            m.estEnRupture ||
            m.estSousSeuilAlerte ||
            m.estPerime ||
            m.expireSoon,
      )
      .toList();

  /// Charger tous les médicaments
  Future<void> chargerMedicaments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'medicaments',
        orderBy: 'nom ASC',
      );

      _medicaments.clear();
      _medicaments.addAll(maps.map((map) => Medicament.fromMap(map)));
    } catch (e) {
      logger.error('Erreur lors du chargement des médicaments: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger les utilisations
  Future<void> chargerUtilisations() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'utilisations_medicament',
        orderBy: 'date_utilisation DESC',
      );

      _utilisations.clear();
      _utilisations.addAll(
        maps.map((map) => UtilisationMedicament.fromMap(map)),
      );
      notifyListeners();
    } catch (e) {
      logger.error('Erreur lors du chargement des utilisations: $e');
      rethrow;
    }
  }

  /// Ajouter un médicament
  Future<void> ajouterMedicament(Medicament medicament) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final id = await db.insert(
        'medicaments',
        medicament.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final nouveauMedicament = medicament.copyWith(id: id);
      _medicaments.add(nouveauMedicament);
      notifyListeners();
    } catch (e) {
      logger.error('Erreur lors de l\'ajout du médicament: $e');
      rethrow;
    }
  }

  /// Modifier un médicament
  Future<void> modifierMedicament(Medicament medicament) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'medicaments',
        medicament.toMap(),
        where: 'id = ?',
        whereArgs: [medicament.id],
      );

      final index = _medicaments.indexWhere((m) => m.id == medicament.id);
      if (index != -1) {
        _medicaments[index] = medicament;
        notifyListeners();
      }
    } catch (e) {
      logger.error('Erreur lors de la modification du médicament: $e');
      rethrow;
    }
  }

  /// Supprimer un médicament
  Future<void> supprimerMedicament(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('medicaments', where: 'id = ?', whereArgs: [id]);

      _medicaments.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      logger.error('Erreur lors de la suppression du médicament: $e');
      rethrow;
    }
  }

  /// Enregistrer une utilisation de médicament
  Future<void> utiliserMedicament(UtilisationMedicament utilisation) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Insérer l'utilisation
      final id = await db.insert(
        'utilisations_medicament',
        utilisation.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Mettre à jour le stock du médicament
      final medicament = _medicaments.firstWhere(
        (m) => m.id == utilisation.medicamentId,
      );

      final nouveauStock =
          medicament.quantiteStock - utilisation.quantiteUtilisee;
      await modifierMedicament(
        medicament.copyWith(quantiteStock: nouveauStock),
      );

      // Ajouter l'utilisation à la liste
      _utilisations.insert(0, utilisation.copyWith(id: id));
      notifyListeners();
    } catch (e) {
      logger.error('Erreur lors de l\'enregistrement de l\'utilisation: $e');
      rethrow;
    }
  }

  /// Réapprovisionner un médicament
  Future<void> reapprovisionner(int medicamentId, double quantite) async {
    try {
      final medicament = _medicaments.firstWhere((m) => m.id == medicamentId);
      final nouveauStock = medicament.quantiteStock + quantite;

      await modifierMedicament(
        medicament.copyWith(quantiteStock: nouveauStock),
      );
    } catch (e) {
      logger.error('Erreur lors du réapprovisionnement: $e');
      rethrow;
    }
  }

  /// Obtenir l'historique d'utilisation d'un médicament
  Future<List<UtilisationMedicament>> obtenirHistoriqueMedicament(
    int medicamentId,
  ) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'utilisations_medicament',
        where: 'medicament_id = ?',
        whereArgs: [medicamentId],
        orderBy: 'date_utilisation DESC',
      );

      return maps.map((map) => UtilisationMedicament.fromMap(map)).toList();
    } catch (e) {
      logger.error('Erreur lors de la récupération de l\'historique: $e');
      rethrow;
    }
  }

  /// Obtenir les utilisations pour un lapin
  Future<List<UtilisationMedicament>> obtenirUtilisationsLapin(
    int lapinId,
  ) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'utilisations_medicament',
        where: 'lapin_id = ?',
        whereArgs: [lapinId],
        orderBy: 'date_utilisation DESC',
      );

      return maps.map((map) => UtilisationMedicament.fromMap(map)).toList();
    } catch (e) {
      logger.error(
        'Erreur lors de la récupération des utilisations du lapin: $e',
      );
      rethrow;
    }
  }

  /// Obtenir la valeur totale du stock
  double getValeurStockTotal() {
    return _medicaments.fold(0.0, (sum, medicament) {
      if (medicament.prixUnitaire != null) {
        return sum + (medicament.quantiteStock * medicament.prixUnitaire!);
      }
      return sum;
    });
  }

  /// Statistiques des médicaments
  Future<Map<String, dynamic>> obtenirStatistiques() async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Coût total du stock
      final coutStock = await db.rawQuery('''
        SELECT SUM(quantite_stock * prix_unitaire) as total 
        FROM medicaments 
        WHERE prix_unitaire IS NOT NULL
      ''');

      // Nombre total d'utilisations
      final nbUtilisations = await db.rawQuery('''
        SELECT COUNT(*) as total FROM utilisations_medicament
      ''');

      // Médicaments les plus utilisés
      final plusUtilises = await db.rawQuery('''
        SELECT m.nom, COUNT(u.id) as nb_utilisations
        FROM medicaments m
        LEFT JOIN utilisations_medicament u ON m.id = u.medicament_id
        GROUP BY m.id
        ORDER BY nb_utilisations DESC
        LIMIT 5
      ''');

      return {
        'cout_stock': coutStock.first['total'] ?? 0.0,
        'nombre_medicaments': _medicaments.length,
        'nombre_utilisations': nbUtilisations.first['total'] ?? 0,
        'medicaments_en_alerte': medicamentsEnAlerte.length,
        'plus_utilises': plusUtilises,
      };
    } catch (e) {
      logger.error('Erreur lors du calcul des statistiques: $e');
      rethrow;
    }
  }
}
