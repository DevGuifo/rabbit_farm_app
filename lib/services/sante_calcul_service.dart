import '../models/soin.dart';
import '../models/lapin.dart';
import '../services/database_helper.dart';
import '../utils/logger.dart';

/// Service pour les calculs métier liés à la santé
/// Extrait la logique de calcul des Providers
class SanteCalculService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Calculer le score de santé du cheptel (0-100)
  /// Basé sur: vaccination à jour, absence de soins en retard, pesées régulières
  Future<int> calculerScoreSante({
    required List<Soin> soins,
    required List<Lapin> lapins,
  }) async {
    try {
      int score = 100;

      // Pénalité pour vaccinations en retard (-10 points par vaccination)
      final vaccinationsRetard = _getVaccinationsEnRetard(soins);
      score -= (vaccinationsRetard.length * 10).clamp(0, 30);

      // Pénalité pour soins en retard (-5 points par soin)
      final soinsRetard = _getSoinsEnRetard(soins);
      score -= (soinsRetard.length * 5).clamp(0, 20);

      // Bonus si aucun soin en retard (+5 points)
      if (vaccinationsRetard.isEmpty && soinsRetard.isEmpty) {
        score += 5;
      }

      return score.clamp(0, 100);
    } catch (e) {
      logger.error('Erreur lors du calcul du score de santé: $e');
      return 0;
    }
  }

  /// Obtenir les vaccinations en retard
  List<Soin> _getVaccinationsEnRetard(List<Soin> soins) {
    final maintenant = DateTime.now();
    return soins.where((soin) {
      if (soin.type != 'Vaccination') return false;
      if (soin.dateRappel == null) return false;
      return soin.dateRappel!.isBefore(maintenant);
    }).toList();
  }

  /// Obtenir les soins en retard
  List<Soin> _getSoinsEnRetard(List<Soin> soins) {
    final maintenant = DateTime.now();
    return soins.where((soin) {
      if (soin.dateRappel == null) return false;
      return soin.dateRappel!.isBefore(maintenant);
    }).toList();
  }

  /// Calculer le taux de mortalité sur une période
  /// Retourne un pourcentage (0-100)
  Future<double> calculerTauxMortalite({
    required DateTime debut,
    required DateTime fin,
    required int effectifTotal,
  }) async {
    try {
      if (effectifTotal == 0) return 0.0;
      final nombreDeces = await _db.countDecesByPeriode(debut, fin);
      return (nombreDeces / effectifTotal) * 100;
    } catch (e) {
      logger.error('Erreur lors du calcul du taux de mortalité: $e');
      return 0.0;
    }
  }

  /// Détecter une mortalité anormale
  /// Retourne true si le taux de mortalité dépasse le seuil
  Future<bool> detecterMortaliteAnormale({
    int joursAnalyse = 7,
    double seuilPourcentage = 5.0,
  }) async {
    try {
      final maintenant = DateTime.now();
      final debut = maintenant.subtract(Duration(days: joursAnalyse));

      // Récupérer l'effectif total actif
      final lapins = await _db.getAllLapins();
      final lapinsActifs = lapins.where((l) => l.statut != 'decede').length;
      final nombreDeces = await _db.countDecesByPeriode(debut, maintenant);
      final effectifTotal = lapinsActifs + nombreDeces;

      final tauxMortalite = await calculerTauxMortalite(
        debut: debut,
        fin: maintenant,
        effectifTotal: effectifTotal,
      );

      return tauxMortalite > seuilPourcentage;
    } catch (e) {
      logger.error('Erreur lors de la détection de mortalité anormale: $e');
      return false;
    }
  }
}

