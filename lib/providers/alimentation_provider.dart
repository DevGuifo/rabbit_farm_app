import 'package:flutter/foundation.dart';
import '../models/aliment.dart';
import '../services/database_helper.dart';
import '../utils/logger.dart';

/// Provider pour la gestion de l'alimentation
class AlimentationProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Aliment> _aliments = [];
  List<DistributionAliment> _distributions = [];
  bool _isLoading = false;

  List<Aliment> get aliments => _aliments;
  List<Aliment> get alimentsEnStock =>
      _aliments.where((a) => a.quantiteRestante > 0).toList();
  List<DistributionAliment> get distributions => _distributions;
  bool get isLoading => _isLoading;

  /// Charger tous les aliments
  Future<void> loadAliments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _aliments = await _dbHelper.getAllAliments();
    } catch (e) {
      logger.error('❌ Erreur lors du chargement des aliments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger toutes les distributions
  Future<void> loadDistributions() async {
    try {
      _distributions = await _dbHelper.getAllDistributions();
      notifyListeners();
    } catch (e) {
      logger.error('❌ Erreur lors du chargement des distributions: $e');
    }
  }

  /// Ajouter un aliment
  Future<Aliment?> ajouterAliment(Aliment aliment) async {
    try {
      final nouveauAliment = await _dbHelper.insertAliment(aliment);
      _aliments.insert(0, nouveauAliment);
      notifyListeners();

      logger.error('✅ Aliment ajouté: ${aliment.nom}');
      return nouveauAliment;
    } catch (e) {
      logger.error('❌ Erreur lors de l\'ajout de l\'aliment: $e');
      return null;
    }
  }

  /// Distribuer un aliment (met à jour le stock)
  Future<bool> distribuerAliment(DistributionAliment distribution) async {
    try {
      // Vérifier que l'aliment existe
      final aliment = _aliments.firstWhere(
        (a) => a.id == distribution.alimentId,
      );

      // Vérifier qu'il y a assez de stock
      if (aliment.quantiteRestante < distribution.quantiteDistribuee) {
        logger.error('❌ Stock insuffisant pour ${aliment.nom}');
        return false;
      }

      // Enregistrer la distribution
      final nouvelleDistribution = await _dbHelper.insertDistributionAliment(
        distribution,
      );
      _distributions.insert(0, nouvelleDistribution);

      // Mettre à jour le stock de l'aliment
      final alimentMisAJour = aliment.copyWith(
        quantiteRestante:
            aliment.quantiteRestante - distribution.quantiteDistribuee,
      );
      await _dbHelper.updateAliment(alimentMisAJour);

      // Mettre à jour la liste locale
      final index = _aliments.indexWhere((a) => a.id == aliment.id);
      if (index != -1) {
        _aliments[index] = alimentMisAJour;
      }

      notifyListeners();
      logger.error(
        '✅ Distribution enregistrée: ${distribution.quantiteDistribuee}kg de ${aliment.nom}',
      );
      return true;
    } catch (e) {
      logger.error('❌ Erreur lors de la distribution: $e');
      return false;
    }
  }

  /// Mettre à jour le stock d'un aliment manuellement
  Future<bool> mettreAJourStock(int alimentId, double nouvelleQuantite) async {
    try {
      final aliment = _aliments.firstWhere((a) => a.id == alimentId);
      final alimentMisAJour = aliment.copyWith(
        quantiteRestante: nouvelleQuantite,
      );

      await _dbHelper.updateAliment(alimentMisAJour);

      // Mettre à jour la liste locale
      final index = _aliments.indexWhere((a) => a.id == alimentId);
      if (index != -1) {
        _aliments[index] = alimentMisAJour;
      }

      notifyListeners();
      logger.error('✅ Stock mis à jour pour ${aliment.nom}');
      return true;
    } catch (e) {
      logger.error('❌ Erreur lors de la mise à jour du stock: $e');
      return false;
    }
  }

  /// Obtenir le stock disponible d'un aliment
  double getStockDisponible(int alimentId) {
    try {
      final aliment = _aliments.firstWhere((a) => a.id == alimentId);
      return aliment.quantiteRestante;
    } catch (e) {
      return 0.0;
    }
  }

  /// Calculer la consommation moyenne par jour
  Future<double> getConsommationMoyenneParJour({int jours = 30}) async {
    try {
      final maintenant = DateTime.now();
      final debut = maintenant.subtract(Duration(days: jours));

      final consommationTotale = await _dbHelper.getConsommationByPeriode(
        debut,
        maintenant,
      );

      return consommationTotale / jours;
    } catch (e) {
      logger.error('❌ Erreur lors du calcul de la consommation moyenne: $e');
      return 0.0;
    }
  }

  /// Calculer le nombre de jours avant épuisement du stock
  Future<Map<int, int>> getJoursAvantEpuisement() async {
    try {
      final consommationMoyenne = await getConsommationMoyenneParJour();
      if (consommationMoyenne == 0) return {};

      final Map<int, int> joursRestants = {};

      for (final aliment in alimentsEnStock) {
        final jours = (aliment.quantiteRestante / consommationMoyenne).floor();
        joursRestants[aliment.id!] = jours;
      }

      return joursRestants;
    } catch (e) {
      logger.error('❌ Erreur lors du calcul des jours avant épuisement: $e');
      return {};
    }
  }

  /// Obtenir les aliments avec stock faible (< 7 jours)
  Future<List<Aliment>> getAlimentsStockFaible() async {
    try {
      final joursEpuisement = await getJoursAvantEpuisement();
      return alimentsEnStock.where((aliment) {
        final jours = joursEpuisement[aliment.id] ?? 999;
        return jours < 7;
      }).toList();
    } catch (e) {
      logger.error('❌ Erreur lors de la récupération des stocks faibles: $e');
      return [];
    }
  }

  /// Obtenir les aliments proches de la péremption
  Future<List<Aliment>> getAlimentsPeremptionProche({int jours = 30}) async {
    try {
      return await _dbHelper.getAlimentsPeremptionProche(jours);
    } catch (e) {
      logger.error('❌ Erreur lors de la récupération des péremptions: $e');
      return [];
    }
  }

  /// Calculer le coût par lapin par jour
  Future<double> getCoutParLapinParJour(int nombreLapins) async {
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
      logger.error('❌ Erreur lors du calcul du coût par lapin: $e');
      return 0.0;
    }
  }

  /// Calculer la valeur totale du stock
  Future<double> getValeurStock() async {
    try {
      return await _dbHelper.getValeurStock();
    } catch (e) {
      logger.error('❌ Erreur lors du calcul de la valeur du stock: $e');
      return 0.0;
    }
  }

  /// Obtenir les aliments par type
  List<Aliment> getAlimentsByType(String type) {
    return _aliments.where((a) => a.type == type).toList();
  }

  /// Obtenir les distributions par période
  Future<List<DistributionAliment>> getDistributionsByPeriode(
    DateTime debut,
    DateTime fin,
  ) async {
    try {
      return await _dbHelper.getDistributionsByPeriode(debut, fin);
    } catch (e) {
      logger.error('❌ Erreur lors de la récupération des distributions: $e');
      return [];
    }
  }

  /// Obtenir l'évolution de la consommation (7 derniers jours)
  Future<Map<DateTime, double>> getEvolutionConsommation() async {
    try {
      final Map<DateTime, double> evolution = {};
      final maintenant = DateTime.now();

      for (int i = 6; i >= 0; i--) {
        final jour = DateTime(
          maintenant.year,
          maintenant.month,
          maintenant.day - i,
        );
        final jourSuivant = jour.add(const Duration(days: 1));

        final consommation = await _dbHelper.getConsommationByPeriode(
          jour,
          jourSuivant,
        );

        evolution[jour] = consommation;
      }

      return evolution;
    } catch (e) {
      logger.error('❌ Erreur lors de la récupération de l\'évolution: $e');
      return {};
    }
  }

  /// Mettre à jour un aliment
  Future<bool> updateAliment(Aliment aliment) async {
    try {
      await _dbHelper.updateAliment(aliment);

      final index = _aliments.indexWhere((a) => a.id == aliment.id);
      if (index != -1) {
        _aliments[index] = aliment;
        notifyListeners();
      }

      logger.error('✅ Aliment mis à jour');
      return true;
    } catch (e) {
      logger.error('❌ Erreur lors de la mise à jour de l\'aliment: $e');
      return false;
    }
  }

  /// Supprimer un aliment
  Future<bool> deleteAliment(int id) async {
    try {
      await _dbHelper.deleteAliment(id);
      _aliments.removeWhere((a) => a.id == id);
      notifyListeners();

      logger.error('✅ Aliment supprimé');
      return true;
    } catch (e) {
      logger.error('❌ Erreur lors de la suppression de l\'aliment: $e');
      return false;
    }
  }

  /// Supprimer une distribution
  Future<bool> deleteDistribution(int id) async {
    try {
      await _dbHelper.deleteDistributionAliment(id);
      _distributions.removeWhere((d) => d.id == id);
      notifyListeners();

      logger.error('✅ Distribution supprimée');
      return true;
    } catch (e) {
      logger.error('❌ Erreur lors de la suppression de la distribution: $e');
      return false;
    }
  }
}
