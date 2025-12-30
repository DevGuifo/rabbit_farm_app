import '../models/lapin.dart';
import '../services/database_helper.dart';
import '../providers/alimentation_provider.dart';
import '../providers/medicament_provider.dart';
import '../utils/logger.dart';

/// Service pour calculer la rentabilité par lapin
class RentabiliteService {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final AlimentationProvider _alimentationProvider;
  final MedicamentProvider _medicamentProvider;

  RentabiliteService({
    required AlimentationProvider alimentationProvider,
    required MedicamentProvider medicamentProvider,
  })  : _alimentationProvider = alimentationProvider,
        _medicamentProvider = medicamentProvider;

  /// Calculer le coût total d'un lapin
  Future<Map<String, double>> calculerCoutLapin(int lapinId) async {
    try {
      // 1. Coût d'achat initial
      final lapin = await _db.getLapinById(lapinId);
      if (lapin == null) {
        logger.warning('Lapin $lapinId introuvable pour calcul rentabilité');
        return {
          'achat': 0.0,
          'alimentation': 0.0,
          'soins': 0.0,
          'medicaments': 0.0,
          'autres': 0.0,
          'total': 0.0,
        };
      }

      final coutAchat = lapin.prixAchat ?? 0.0;

      // 2. Coût alimentation (proportionnel selon période)
      final coutAlimentation = await _calculerCoutAlimentation(lapinId, lapin);

      // 3. Coût soins/vétérinaires (estimation)
      final coutSoins = await _calculerCoutSoins(lapinId);

      // 4. Coût médicaments
      final coutMedicaments = await _calculerCoutMedicaments(lapinId);

      // 5. Coût autres (quarantaine, etc.)
      final coutAutres = await _calculerCoutAutres(lapinId);

      final coutTotal = coutAchat +
          coutAlimentation +
          coutSoins +
          coutMedicaments +
          coutAutres;

      return {
        'achat': coutAchat,
        'alimentation': coutAlimentation,
        'soins': coutSoins,
        'medicaments': coutMedicaments,
        'autres': coutAutres,
        'total': coutTotal,
      };
    } catch (e) {
      logger.error('❌ Erreur calcul coût lapin $lapinId: $e');
      return {
        'achat': 0.0,
        'alimentation': 0.0,
        'soins': 0.0,
        'medicaments': 0.0,
        'autres': 0.0,
        'total': 0.0,
      };
    }
  }

  /// Calculer les revenus d'un lapin
  Future<Map<String, double>> calculerRevenusLapin(int lapinId) async {
    try {
      // 1. Recettes directes (ventes)
      final recettes = await _db.getRecettesByLapin(lapinId);
      final revenusVentes = recettes.fold(0.0, (sum, r) => sum + r.montant);

      // 2. Réforme (si applicable)
      final db = await _db.database;
      final reformes = await db.query(
        'reformes',
        where: 'lapin_id = ?',
        whereArgs: [lapinId],
      );
      final revenusReforme = reformes.fold(0.0, (sum, r) {
        final prixVente = r['prix_vente'] as num?;
        return sum + (prixVente?.toDouble() ?? 0.0);
      });

      return {
        'ventes': revenusVentes,
        'reforme': revenusReforme,
        'total': revenusVentes + revenusReforme,
      };
    } catch (e) {
      logger.error('❌ Erreur calcul revenus lapin $lapinId: $e');
      return {
        'ventes': 0.0,
        'reforme': 0.0,
        'total': 0.0,
      };
    }
  }

  /// Calculer la rentabilité d'un lapin
  Future<Map<String, dynamic>> calculerRentabiliteLapin(int lapinId) async {
    try {
      final couts = await calculerCoutLapin(lapinId);
      final revenus = await calculerRevenusLapin(lapinId);

      final benefice = revenus['total']! - couts['total']!;
      final rentabilite = couts['total']! > 0
          ? (benefice / couts['total']!) * 100
          : (revenus['total']! > 0 ? 100.0 : 0.0);

      return {
        'couts': couts,
        'revenus': revenus,
        'benefice': benefice,
        'rentabilite': rentabilite,
      };
    } catch (e) {
      logger.error('❌ Erreur calcul rentabilité lapin $lapinId: $e');
      return {
        'couts': {
          'achat': 0.0,
          'alimentation': 0.0,
          'soins': 0.0,
          'medicaments': 0.0,
          'autres': 0.0,
          'total': 0.0,
        },
        'revenus': {
          'ventes': 0.0,
          'reforme': 0.0,
          'total': 0.0,
        },
        'benefice': 0.0,
        'rentabilite': 0.0,
      };
    }
  }

  /// Calculer le coût d'alimentation pour un lapin
  Future<double> _calculerCoutAlimentation(int lapinId, Lapin lapin) async {
    try {
      // Obtenir le nombre total de lapins actifs
      final tousLapins = await _db.getAllLapins();
      final lapinsActifs = tousLapins
          .where((l) => l.statut != 'vendu' && l.statut != 'decede')
          .length;

      if (lapinsActifs == 0) return 0.0;

      // Calculer le coût moyen par lapin par jour
      final coutParLapinParJour =
          await _alimentationProvider.getCoutParLapinParJour(lapinsActifs);

      // Calculer le nombre de jours depuis l'achat/naissance
      final dateReference = lapin.prixAchat != null && lapin.prixAchat! > 0
          ? lapin.dateNaissance // Si acheté, utiliser date de naissance
          : lapin.dateNaissance;
      final joursDepuisReference =
          DateTime.now().difference(dateReference).inDays;

      // Coût total alimentation
      return coutParLapinParJour * joursDepuisReference;
    } catch (e) {
      logger.error('❌ Erreur calcul coût alimentation: $e');
      return 0.0;
    }
  }

  /// Calculer le coût des soins pour un lapin
  Future<double> _calculerCoutSoins(int lapinId) async {
    try {
      final soins = await _db.getSoinsByLapin(lapinId);

      // Estimation : 15€ par soin (consultation + traitement moyen)
      // En production, on pourrait ajouter un champ "coût" dans le modèle Soin
      return soins.length * 15.0;
    } catch (e) {
      logger.error('❌ Erreur calcul coût soins: $e');
      return 0.0;
    }
  }

  /// Calculer le coût des médicaments pour un lapin
  Future<double> _calculerCoutMedicaments(int lapinId) async {
    try {
      final utilisations = await _medicamentProvider.obtenirUtilisationsLapin(
        lapinId,
      );

      double coutTotal = 0.0;

      for (final utilisation in utilisations) {
        // Récupérer le médicament pour obtenir son prix
        final medicament = _medicamentProvider.medicaments.firstWhere(
          (m) => m.id == utilisation.medicamentId,
          orElse: () => throw Exception('Médicament introuvable'),
        );

        if (medicament.prixUnitaire != null) {
          // Calculer le coût selon la quantité utilisée
          coutTotal += utilisation.quantiteUtilisee * medicament.prixUnitaire!;
        }
      }

      return coutTotal;
    } catch (e) {
      logger.error('❌ Erreur calcul coût médicaments: $e');
      return 0.0;
    }
  }

  /// Calculer les coûts autres (quarantaine, etc.)
  Future<double> _calculerCoutAutres(int lapinId) async {
    try {
      // Pour l'instant, retourner 0
      // À l'avenir, on pourrait calculer les coûts de quarantaine, etc.
      return 0.0;
    } catch (e) {
      logger.error('❌ Erreur calcul coût autres: $e');
      return 0.0;
    }
  }
}

