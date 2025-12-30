import 'package:flutter/foundation.dart';
import '../models/pesee.dart';
import '../models/soin.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../utils/logger.dart';

/// Provider pour gérer l'état des pesées et soins
class SanteProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService();

  List<Pesee> _pesees = [];
  List<Soin> _soins = [];
  bool _isLoading = false;

  // Cache du score de santé avec timestamp
  int? _scoreSanteCache;
  DateTime? _scoreSanteCacheTimestamp;

  List<Pesee> get pesees => _pesees;
  List<Soin> get soins => _soins;
  bool get isLoading => _isLoading;

  /// Charger toutes les pesées depuis la base de données
  Future<void> chargerPesees() async {
    _isLoading = true;
    notifyListeners();

    try {
      _pesees = await _db.getAllPesees();
    } catch (e) {
      logger.error('Erreur lors du chargement des pesées', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger tous les soins depuis la base de données
  Future<void> chargerSoins() async {
    _isLoading = true;
    notifyListeners();

    try {
      _soins = await _db.getAllSoins();
    } catch (e) {
      logger.error('Erreur lors du chargement des soins', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger pesées et soins
  Future<void> chargerTout() async {
    await Future.wait([chargerPesees(), chargerSoins()]);
  }

  /// Ajouter une pesée
  Future<Pesee> ajouterPesee(Pesee pesee) async {
    try {
      final nouvellePesee = await _db.insertPesee(pesee);
      _pesees.insert(0, nouvellePesee);

      // Planifier un rappel de pesée hebdomadaire pour ce lapin
      final lapin = await _db.getLapinById(pesee.lapinId);
      if (lapin != null) {
        // Annuler l'ancien rappel s'il existe
        await _notificationService.annulerRappelPesee(pesee.lapinId);
        // Planifier le nouveau rappel (7 jours après cette pesée)
        await _notificationService.planifierRappelPeseeHebdomadaire(
          lapinId: pesee.lapinId,
          nomLapin: lapin.nom,
          dateDernierePesee: pesee.date,
        );
      }

      notifyListeners();
      return nouvellePesee;
    } catch (e) {
      logger.error('Erreur lors de l\'ajout de la pesée', e);
      rethrow;
    }
  }

  /// Modifier une pesée
  Future<void> modifierPesee(Pesee pesee) async {
    try {
      await _db.updatePesee(pesee);
      final index = _pesees.indexWhere((p) => p.id == pesee.id);
      if (index != -1) {
        _pesees[index] = pesee;
        notifyListeners();
      }
    } catch (e) {
      logger.error('Erreur lors de la modification de la pesée', e);
      rethrow;
    }
  }

  /// Supprimer une pesée
  Future<void> supprimerPesee(int id) async {
    try {
      await _db.deletePesee(id);
      _pesees.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      logger.error('Erreur lors de la suppression de la pesée', e);
      rethrow;
    }
  }

  /// Obtenir les pesées d'un lapin spécifique
  List<Pesee> getPeseesParLapin(int lapinId) {
    return _pesees.where((p) => p.lapinId == lapinId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Ajouter un soin
  Future<Soin> ajouterSoin(Soin soin) async {
    try {
      final nouveauSoin = await _db.insertSoin(soin);
      _soins.insert(0, nouveauSoin);

      // Planifier une notification si le soin a une date de rappel
      if (nouveauSoin.dateRappel != null && nouveauSoin.id != null) {
        final lapin = await _db.getLapinById(nouveauSoin.lapinId);
        if (lapin != null) {
          await _notificationService.planifierRappelSoin(
            soinId: nouveauSoin.id!,
            dateRappel: nouveauSoin.dateRappel!,
            nomLapin: lapin.nom,
            typeSoin: nouveauSoin.type,
          );
        }
      }

      invaliderCacheScore();
      notifyListeners();
      return nouveauSoin;
    } catch (e) {
      logger.error('Erreur lors de l\'ajout du soin', e);
      rethrow;
    }
  }

  /// Modifier un soin
  Future<void> modifierSoin(Soin soin) async {
    try {
      await _db.updateSoin(soin);
      final index = _soins.indexWhere((s) => s.id == soin.id);
      if (index != -1) {
        _soins[index] = soin;

        // Gérer les notifications
        if (soin.id != null) {
          // Annuler l'ancienne notification
          await _notificationService.annulerRappelSoin(soin.id!);

          // Replanifier si le soin a une date de rappel
          if (soin.dateRappel != null) {
            final lapin = await _db.getLapinById(soin.lapinId);
            if (lapin != null) {
              await _notificationService.planifierRappelSoin(
                soinId: soin.id!,
                dateRappel: soin.dateRappel!,
                nomLapin: lapin.nom,
                typeSoin: soin.type,
              );
            }
          }
        }

        invaliderCacheScore();
        notifyListeners();
      }
    } catch (e) {
      logger.error('Erreur lors de la modification du soin', e);
      rethrow;
    }
  }

  /// Supprimer un soin
  Future<void> supprimerSoin(int id) async {
    try {
      // Annuler la notification associée
      await _notificationService.annulerRappelSoin(id);

      await _db.deleteSoin(id);
      _soins.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      logger.error('Erreur lors de la suppression du soin', e);
      rethrow;
    }
  }

  /// Récupérer les pesées d'un lapin
  Future<List<Pesee>> getPeseesByLapin(int lapinId) async {
    try {
      return await _db.getPeseesByLapin(lapinId);
    } catch (e) {
      logger.error('Erreur lors de la récupération des pesées', e);
      return [];
    }
  }

  /// Récupérer les soins d'un lapin
  Future<List<Soin>> getSoinsByLapin(int lapinId) async {
    try {
      return await _db.getSoinsByLapin(lapinId);
    } catch (e) {
      logger.error('Erreur lors de la récupération des soins', e);
      return [];
    }
  }

  /// Récupérer les soins avec rappel nécessaire
  Future<List<Soin>> getSoinsAvecRappel() async {
    try {
      return await _db.getSoinsAvecRappel();
    } catch (e) {
      logger.error('Erreur lors de la récupération des rappels', e);
      return [];
    }
  }

  /// Obtenir les soins avec rappel (synchrone, depuis les données chargées)
  List<Soin> get soinsAvecRappel {
    return _soins.where((soin) => soin.dateRappel != null).toList()..sort(
      (a, b) => (a.dateRappel ?? DateTime.now()).compareTo(
        b.dateRappel ?? DateTime.now(),
      ),
    );
  }

  /// LOGIQUE MÉTIER POUR LE DASHBOARD

  /// Obtenir les vaccinations en retard
  List<Soin> getVaccinationsEnRetard() {
    final maintenant = DateTime.now();
    return _soins.where((soin) {
      if (soin.type != 'Vaccination') return false;
      if (soin.dateRappel == null) return false;
      return soin.dateRappel!.isBefore(maintenant);
    }).toList()..sort((a, b) => a.dateRappel!.compareTo(b.dateRappel!));
  }

  /// Obtenir les rappels de soins à venir (dans les 7 prochains jours)
  List<Soin> getRappelsAVenir() {
    final maintenant = DateTime.now();
    final dansSeptJours = maintenant.add(const Duration(days: 7));
    return _soins.where((soin) {
      if (soin.dateRappel == null) return false;
      return soin.dateRappel!.isAfter(maintenant) &&
          soin.dateRappel!.isBefore(dansSeptJours);
    }).toList()..sort((a, b) => a.dateRappel!.compareTo(b.dateRappel!));
  }

  /// Calculer le score de santé du cheptel (0-100)
  /// Basé sur: vaccination à jour, absence de soins en retard, pesées régulières
  /// Utilise un cache de 1h pour optimiser les performances
  Future<int> calculerScoreSante() async {
    // Vérifier si le cache est valide (moins de 1h)
    final maintenant = DateTime.now();
    if (_scoreSanteCache != null && _scoreSanteCacheTimestamp != null) {
      final diffMinutes = maintenant
          .difference(_scoreSanteCacheTimestamp!)
          .inMinutes;
      if (diffMinutes < 60) {
        return _scoreSanteCache!;
      }
    }

    // Recalculer le score
    int score = 100;

    // Pénalité pour vaccinations en retard (-10 points par vaccination)
    final vaccinationsRetard = getVaccinationsEnRetard();
    score -= (vaccinationsRetard.length * 10).clamp(0, 30);

    // Pénalité pour soins en retard (-5 points par soin)
    final soinsRetard = _soins.where((soin) {
      if (soin.dateRappel == null) return false;
      return soin.dateRappel!.isBefore(DateTime.now());
    }).length;
    score -= (soinsRetard * 5).clamp(0, 20);

    // Bonus si aucun soin en retard (+5 points)
    if (vaccinationsRetard.isEmpty && soinsRetard == 0) {
      score += 5;
    }

    final scoreFinal = score.clamp(0, 100);

    // Mettre à jour le cache
    _scoreSanteCache = scoreFinal;
    _scoreSanteCacheTimestamp = maintenant;

    return scoreFinal;
  }

  /// Vérifier si un lapin est malade
  /// Un lapin est considéré comme malade s'il a :
  /// - Des soins récents de type "Traitement" ou "Consultation" (dans les 30 derniers jours)
  /// - Un statut "Malade" dans la base de données
  Future<bool> estLapinMalade(int lapinId) async {
    try {
      // Vérifier le statut dans la base de données
      final lapin = await _db.getLapinById(lapinId);
      if (lapin?.statut == 'Malade') {
        return true;
      }

      // Vérifier les soins récents (traitements ou consultations dans les 30 derniers jours)
      final soins = await _db.getSoinsByLapin(lapinId);
      final maintenant = DateTime.now();
      final ilYATrenteJours = maintenant.subtract(const Duration(days: 30));

      final soinsRecents = soins.where((soin) {
        final estTraitementOuConsultation =
            soin.type == 'Traitement' || soin.type == 'Consultation';
        final estRecent = soin.date.isAfter(ilYATrenteJours);
        return estTraitementOuConsultation && estRecent;
      }).toList();

      // Si le lapin a des soins récents de type traitement/consultation, il est considéré comme malade
      return soinsRecents.isNotEmpty;
    } catch (e) {
      logger.error('Erreur lors de la vérification si le lapin est malade: $e');
      return false;
    }
  }

  /// Obtenir la liste des IDs des lapins malades
  Future<List<int>> getLapinsMalades() async {
    try {
      final lapins = await _db.getAllLapins();
      final lapinsMalades = <int>[];

      for (final lapin in lapins) {
        if (lapin.id == null) continue;
        if (await estLapinMalade(lapin.id!)) {
          lapinsMalades.add(lapin.id!);
        }
      }

      return lapinsMalades;
    } catch (e) {
      logger.error('Erreur lors de la récupération des lapins malades: $e');
      return [];
    }
  }

  /// Invalider le cache du score de santé (appeler après ajout/modification de soins)
  void invaliderCacheScore() {
    _scoreSanteCache = null;
    _scoreSanteCacheTimestamp = null;
  }
}
