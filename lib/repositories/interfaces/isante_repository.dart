import '../../models/pesee.dart';
import '../../models/soin.dart';

/// Interface pour le repository de la santé
/// Regroupe les opérations sur les pesées et soins
abstract class ISanteRepository {
  // ========== PESÉES ==========

  /// Insérer une pesée
  Future<Pesee> insertPesee(Pesee pesee);

  /// Récupérer toutes les pesées
  Future<List<Pesee>> getAllPesees();

  /// Récupérer une pesée par ID
  Future<Pesee?> getPeseeById(int id);

  /// Mettre à jour une pesée
  Future<int> updatePesee(Pesee pesee);

  /// Supprimer une pesée
  Future<int> deletePesee(int id);

  /// Récupérer les pesées d'un lapin
  Future<List<Pesee>> getPeseesByLapin(int lapinId);

  /// Récupérer les pesées par période
  Future<List<Pesee>> getPeseesByPeriode(DateTime debut, DateTime fin);

  // ========== SOINS ==========

  /// Insérer un soin
  Future<Soin> insertSoin(Soin soin);

  /// Récupérer tous les soins
  Future<List<Soin>> getAllSoins();

  /// Récupérer un soin par ID
  Future<Soin?> getSoinById(int id);

  /// Mettre à jour un soin
  Future<int> updateSoin(Soin soin);

  /// Supprimer un soin
  Future<int> deleteSoin(int id);

  /// Récupérer les soins d'un lapin
  Future<List<Soin>> getSoinsByLapin(int lapinId);

  /// Récupérer les soins par période
  Future<List<Soin>> getSoinsByPeriode(DateTime debut, DateTime fin);
}

