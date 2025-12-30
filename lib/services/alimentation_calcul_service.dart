import '../models/aliment.dart';
import '../services/database_helper.dart';
import '../utils/logger.dart';

/// Service pour les calculs métier liés à l'alimentation
/// Extrait la logique de calcul des Providers
class AlimentationCalculService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Calculer le coût par lapin par jour
  Future<double> calculerCoutParLapinParJour({
    required List<Aliment> alimentsEnStock,
    required int nombreLapins,
  }) async {
    try {
      if (nombreLapins == 0) return 0.0;

      final consommationMoyenne = await getConsommationMoyenneParJour();

      // Calculer le prix moyen au kg du stock actuel
      double prixMoyenKg = 0.0;
      double poidsTotal = 0.0;

      for (final aliment in alimentsEnStock) {
        prixMoyenKg += aliment.prixUnitaire * aliment.quantiteRestante;
        poidsTotal += aliment.quantiteRestante;
      }

      if (poidsTotal > 0) {
        prixMoyenKg /= poidsTotal;
      }

      // Coût par jour pour tous les lapins
      final coutTotal = consommationMoyenne * prixMoyenKg;

      // Coût par lapin
      return coutTotal / nombreLapins;
    } catch (e) {
      logger.error('Erreur lors du calcul du coût par lapin: $e');
      return 0.0;
    }
  }

  /// Obtenir la consommation moyenne par jour (en kg)
  /// Estimation basée sur les distributions récentes
  Future<double> getConsommationMoyenneParJour() async {
    try {
      final distributions = await _db.getAllDistributions();
      if (distributions.isEmpty) {
        // Estimation par défaut : 150g par lapin par jour
        return 0.150;
      }

      // Calculer la moyenne sur les 30 derniers jours
      final maintenant = DateTime.now();
      final ilYATrenteJours = maintenant.subtract(const Duration(days: 30));

      final distributionsRecent = distributions.where((d) {
        return d.date.isAfter(ilYATrenteJours);
      }).toList();

      if (distributionsRecent.isEmpty) return 0.150;

      final quantiteTotale = distributionsRecent.fold<double>(
        0.0,
        (sum, d) => sum + d.quantiteDistribuee,
      );

      final nombreJours = distributionsRecent.length;
      return quantiteTotale / nombreJours;
    } catch (e) {
      logger.error('Erreur lors du calcul de la consommation moyenne: $e');
      return 0.150; // Valeur par défaut
    }
  }

  /// Calculer la valeur totale du stock
  double calculerValeurStock(List<Aliment> aliments) {
    return aliments.fold<double>(
      0.0,
      (sum, aliment) =>
          sum + (aliment.prixUnitaire * aliment.quantiteRestante),
    );
  }

  /// Calculer les jours avant épuisement d'un aliment
  /// Basé sur la consommation moyenne et le stock restant
  Future<Map<int, int>> calculerJoursAvantEpuisement({
    required List<Aliment> aliments,
  }) async {
    try {
      final consommationMoyenne = await getConsommationMoyenneParJour();
      final Map<int, int> joursEpuisement = {};

      for (final aliment in aliments) {
        if (consommationMoyenne > 0) {
          final jours = (aliment.quantiteRestante / consommationMoyenne).ceil();
          joursEpuisement[aliment.id ?? -1] = jours;
        } else {
          joursEpuisement[aliment.id ?? -1] = 999;
        }
      }

      return joursEpuisement;
    } catch (e) {
      logger.error('Erreur lors du calcul des jours avant épuisement: $e');
      return {};
    }
  }
}

