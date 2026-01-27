import 'package:flutter/foundation.dart';
import '../models/anomalie_tache.dart';
import '../services/database_helper.dart';
import '../utils/logger.dart';

/// Provider pour gérer les anomalies de rituels
///
/// Fournit :
/// - Création/enregistrement guidé d'anomalies
/// - Suivi des anomalies non résolues
/// - Statistiques pour le dashboard
/// - Actions rapides (isoler, surveiller)
class AnomalieProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<AnomalieTache> _anomaliesAujourdhui = [];
  List<AnomalieTache> _anomaliesNonResolues = [];
  List<AnomalieTache> _anomaliesCritiques = [];
  StatsAnomalies? _stats;
  bool _isLoading = false;

  // Getters
  List<AnomalieTache> get anomaliesAujourdhui => _anomaliesAujourdhui;
  List<AnomalieTache> get anomaliesNonResolues => _anomaliesNonResolues;
  List<AnomalieTache> get anomaliesCritiques => _anomaliesCritiques;
  StatsAnomalies? get stats => _stats;
  bool get isLoading => _isLoading;

  /// Nombre d'anomalies non résolues
  int get nombreNonResolues => _anomaliesNonResolues.length;

  /// Nombre d'anomalies critiques actives
  int get nombreCritiques => _anomaliesCritiques.length;

  /// A des anomalies critiques ?
  bool get aDesCritiques => _anomaliesCritiques.isNotEmpty;

  /// Charger toutes les données
  Future<void> chargerTout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        chargerAnomaliesAujourdhui(),
        chargerAnomaliesNonResolues(),
        chargerAnomaliesCritiques(),
        chargerStats(),
      ]);
    } catch (e, stackTrace) {
      logger.error('âŒ Erreur chargement anomalies', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger les anomalies du jour
  Future<void> chargerAnomaliesAujourdhui() async {
    try {
      _anomaliesAujourdhui = await _db.getAnomaliesAujourdhui();
      notifyListeners();
    } catch (e) {
      logger.error('âŒ Erreur chargement anomalies du jour', e);
    }
  }

  /// Charger les anomalies non résolues
  Future<void> chargerAnomaliesNonResolues() async {
    try {
      _anomaliesNonResolues = await _db.getAnomaliesNonResolues();
      notifyListeners();
    } catch (e) {
      logger.error('âŒ Erreur chargement anomalies non résolues', e);
    }
  }

  /// Charger les anomalies critiques
  Future<void> chargerAnomaliesCritiques() async {
    try {
      _anomaliesCritiques = await _db.getAnomaliesCritiques();
      notifyListeners();
    } catch (e) {
      logger.error('âŒ Erreur chargement anomalies critiques', e);
    }
  }

  /// Charger les statistiques
  Future<void> chargerStats() async {
    try {
      _stats = await _db.getStatsAnomalies();
      notifyListeners();
    } catch (e) {
      logger.error('âŒ Erreur chargement stats anomalies', e);
    }
  }

  /// Enregistrer une nouvelle anomalie depuis le rituel
  ///
  /// Cette méthode crée une trace exploitable avec :
  /// - Date automatique
  /// - Rituel et action concernés
  /// - Types sélectionnés
  /// - Portée (individu/lot)
  /// - Sévérité calculée
  /// - Action suggérée automatique
  Future<AnomalieTache?> enregistrerAnomalie({
    required int? tacheId,
    required String actionRituelId,
    required String actionRituelTitre,
    required List<TypeAnomalie> typesSelectionnes,
    required PorteeAnomalie portee,
    int? lapinId,
    String? cageId,
    String? noteLibre,
  }) async {
    if (typesSelectionnes.isEmpty) {
      logger.warning('âš ï¸ Tentative d\'enregistrer anomalie sans type');
      return null;
    }

    try {
      // Calculer la sévérité (max des types sélectionnés)
      final severite = typesSelectionnes
          .map((t) => t.severiteDefaut)
          .reduce((a, b) => a > b ? a : b);

      // Déterminer l'action suggérée principale
      ActionSuggeree actionSuggeree;
      if (portee == PorteeAnomalie.lot) {
        // Lot entier â†’ surveillance
        actionSuggeree = ActionSuggeree.surveiller;
      } else {
        // Individu â†’ action du type le plus sévère
        final typePlusSevere = typesSelectionnes.reduce(
          (a, b) => a.severiteDefaut > b.severiteDefaut ? a : b,
        );
        actionSuggeree = typePlusSevere.actionSuggeree;
      }

      final anomalie = AnomalieTache(
        dateObservation: DateTime.now(),
        tacheId: tacheId,
        actionRituelId: actionRituelId,
        actionRituelTitre: actionRituelTitre,
        typesAnomalies: typesSelectionnes,
        portee: portee,
        lapinId: lapinId,
        cageId: cageId,
        severite: severite,
        actionSuggeree: actionSuggeree,
        statut: StatutAnomalie.nouveau,
        noteLibre: noteLibre,
      );

      final id = await _db.insertAnomalieTache(anomalie);
      final anomalieAvecId = anomalie.copyWith(id: id);

      // Mettre Ã  jour les listes locales
      _anomaliesAujourdhui.insert(0, anomalieAvecId);
      _anomaliesNonResolues.insert(0, anomalieAvecId);

      if (severite == 3) {
        _anomaliesCritiques.insert(0, anomalieAvecId);
      }

      logger.info(
        '✅ Anomalie enregistrée: ${anomalie.resumeLabel} (sév. $severite)',
      );
      notifyListeners();

      return anomalieAvecId;
    } catch (e, stackTrace) {
      logger.error('âŒ Erreur enregistrement anomalie', e, stackTrace);
      return null;
    }
  }

  /// Mettre Ã  jour une anomalie existante (édition depuis la feuille guidée)
  Future<bool> mettreAJourAnomalie({
    required AnomalieTache anomalie,
    required List<TypeAnomalie> typesSelectionnes,
    required PorteeAnomalie portee,
    int? lapinId,
    String? cageId,
    String? noteLibre,
  }) async {
    if (anomalie.id == null) {
      logger.warning('âš ï¸ Mise Ã  jour anomalie sans id');
      return false;
    }
    if (typesSelectionnes.isEmpty) {
      logger.warning('âš ï¸ Mise Ã  jour anomalie sans type');
      return false;
    }

    try {
      final severite = typesSelectionnes
          .map((t) => t.severiteDefaut)
          .reduce((a, b) => a > b ? a : b);

      ActionSuggeree actionSuggeree;
      if (portee == PorteeAnomalie.lot) {
        actionSuggeree = ActionSuggeree.surveiller;
      } else {
        final typePlusSevere = typesSelectionnes.reduce(
          (a, b) => a.severiteDefaut > b.severiteDefaut ? a : b,
        );
        actionSuggeree = typePlusSevere.actionSuggeree;
      }

      final updated = anomalie.copyWith(
        typesAnomalies: typesSelectionnes,
        portee: portee,
        lapinId: lapinId,
        cageId: cageId,
        severite: severite,
        actionSuggeree: actionSuggeree,
        noteLibre: noteLibre,
      );

      await _db.updateAnomalieTache(updated);
      logger.info('✅ Anomalie ${updated.id} mise à jour');

      // Simple et sûr : recharger pour garder les listes/stats cohérentes
      await chargerTout();
      return true;
    } catch (e, stackTrace) {
      logger.error('âŒ Erreur mise Ã  jour anomalie', e, stackTrace);
      return false;
    }
  }

  /// Marquer comme "En cours de traitement"
  Future<bool> marquerEnCours(int id) async {
    try {
      await _db.updateStatutAnomalie(id, StatutAnomalie.enCours);
      await _mettreAJourLocalement(id, StatutAnomalie.enCours);
      logger.info('🔄 Anomalie $id marquée en cours');
      return true;
    } catch (e) {
      logger.error('âŒ Erreur marquage en cours', e);
      return false;
    }
  }

  /// Résoudre une anomalie
  Future<bool> resoudre(int id, {ActionSuggeree? actionPrise}) async {
    try {
      await _db.resoudreAnomalie(id, actionPrise: actionPrise);

      // Retirer des listes non résolues
      _anomaliesNonResolues.removeWhere((a) => a.id == id);
      _anomaliesCritiques.removeWhere((a) => a.id == id);

      // Mettre Ã  jour dans la liste du jour
      final index = _anomaliesAujourdhui.indexWhere((a) => a.id == id);
      if (index != -1) {
        _anomaliesAujourdhui[index] = _anomaliesAujourdhui[index].copyWith(
          statut: StatutAnomalie.resolu,
          actionPrise: actionPrise,
          dateResolution: DateTime.now(),
        );
      }

      logger.info('✅ Anomalie $id résolue');
      notifyListeners();
      return true;
    } catch (e) {
      logger.error('âŒ Erreur résolution anomalie', e);
      return false;
    }
  }

  /// Ignorer une anomalie (pas d'action nécessaire)
  Future<bool> ignorer(int id) async {
    try {
      await _db.updateStatutAnomalie(id, StatutAnomalie.ignore);

      // Retirer des listes actives
      _anomaliesNonResolues.removeWhere((a) => a.id == id);
      _anomaliesCritiques.removeWhere((a) => a.id == id);

      logger.info('â­ï¸ Anomalie $id ignorée');
      notifyListeners();
      return true;
    } catch (e) {
      logger.error('âŒ Erreur ignore anomalie', e);
      return false;
    }
  }

  /// Mettre Ã  jour localement le statut
  Future<void> _mettreAJourLocalement(int id, StatutAnomalie statut) async {
    // Mettre Ã  jour dans toutes les listes
    for (var list in [_anomaliesAujourdhui, _anomaliesNonResolues]) {
      final index = list.indexWhere((a) => a.id == id);
      if (index != -1) {
        list[index] = list[index].copyWith(statut: statut);
      }
    }
    notifyListeners();
  }

  /// Récupérer l'historique des anomalies (paginé)
  Future<List<AnomalieTache>> getHistorique({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _db.getHistoriqueAnomalies(limit: limit, offset: offset);
    } catch (e) {
      logger.error('âŒ Erreur chargement historique', e);
      return [];
    }
  }

  /// Récupérer les anomalies pour un lapin
  Future<List<AnomalieTache>> getAnomaliesPourLapin(int lapinId) async {
    try {
      return await _db.getAnomaliesPourLapin(lapinId);
    } catch (e) {
      logger.error('âŒ Erreur chargement anomalies lapin', e);
      return [];
    }
  }
}

