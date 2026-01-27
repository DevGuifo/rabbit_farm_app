import 'package:flutter/foundation.dart';
import '../models/tache_quotidienne.dart';
import '../services/database_helper.dart';
import '../utils/logger.dart';

/// Provider pour gérer les tâches quotidiennes (ancien "rituels")
class TacheProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  TacheQuotidienne? _tacheMatin;
  TacheQuotidienne? _tacheSoir;
  bool _isLoading = false;

  TacheQuotidienne? get tacheMatin => _tacheMatin;
  TacheQuotidienne? get tacheSoir => _tacheSoir;
  bool get isLoading => _isLoading;

  // Getters utilitaires
  bool get matinTermine => _tacheMatin?.estComplet ?? false;
  bool get soirTermine => _tacheSoir?.estComplet ?? false;
  int get anomaliesJour {
    int count = 0;
    _tacheMatin?.actions.forEach((action) {
      if (action.resultat == ResultatAction.anomalie) count++;
    });
    _tacheSoir?.actions.forEach((action) {
      if (action.resultat == ResultatAction.anomalie) count++;
    });
    return count;
  }

  /// Obtenir la tâche du jour par type
  TacheQuotidienne? getTacheDuJour(TypeTacheQuotidienne type) {
    return type == TypeTacheQuotidienne.matin ? _tacheMatin : _tacheSoir;
  }

  /// Charger les tâches du jour
  Future<void> chargerTaches() async {
    // Éviter les appels concurrents
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final today = DateTime.now();
      final dateOnly = DateTime(today.year, today.month, today.day);

      _tacheMatin = await _db.getTacheByDateAndType(
        dateOnly,
        TypeTacheQuotidienne.matin.name,
      );

      _tacheSoir = await _db.getTacheByDateAndType(
        dateOnly,
        TypeTacheQuotidienne.soir.name,
      );

      // Si aucune tâche n'existe pour aujourd'hui, en créer
      _tacheMatin ??= await _creerTacheParDefaut(TypeTacheQuotidienne.matin);
      _tacheSoir ??= await _creerTacheParDefaut(TypeTacheQuotidienne.soir);
    } catch (e) {
      logger.error('Erreur lors du chargement des tâches quotidiennes', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Créer une tâche quotidienne par défaut
  /// Gère les erreurs UNIQUE constraint en récupérant la tâche existante
  Future<TacheQuotidienne> _creerTacheParDefaut(
    TypeTacheQuotidienne type,
  ) async {
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);
    final actions = _getActionsParDefaut(type);
    final tache = TacheQuotidienne(
      date: dateOnly,
      type: type,
      actions: actions,
      dateCreation: DateTime.now(),
    );

    try {
      return await _db.insertTacheQuotidienne(tache);
    } catch (e) {
      // En cas d'erreur UNIQUE constraint, récupérer la tâche existante
      final existante = await _db.getTacheByDateAndType(dateOnly, type.name);
      if (existante != null) {
        return existante;
      }
      // Si vraiment aucune tâche, relancer l'erreur
      rethrow;
    }
  }

  /// Actions par défaut pour chaque type de tâche
  List<ActionTache> _getActionsParDefaut(TypeTacheQuotidienne type) {
    if (type == TypeTacheQuotidienne.matin) {
      return [
        ActionTache(
          id: 'eau_matin',
          titre: 'Eau propre',
          icone: '💧',
          description: 'Vérifier que tous les abreuvoirs sont remplis',
        ),
        ActionTache(
          id: 'nourriture_matin',
          titre: 'Alimentation',
          icone: '🥕',
          description: 'Distribuer la nourriture du matin',
        ),
        ActionTache(
          id: 'sante_matin',
          titre: 'État général',
          icone: '🏥',
          description: 'Observer comportement et santé',
        ),
        ActionTache(
          id: 'proprete_matin',
          titre: 'Propreté',
          icone: '🧹',
          description: 'Contrôler propreté des cages',
        ),
      ];
    } else {
      return [
        ActionTache(
          id: 'eau_soir',
          titre: 'Eau propre',
          icone: '💧',
          description: 'Vérifier que tous les abreuvoirs sont remplis',
        ),
        ActionTache(
          id: 'nourriture_soir',
          titre: 'Alimentation',
          icone: '🥕',
          description: 'Distribuer la nourriture du soir',
        ),
        ActionTache(
          id: 'sante_soir',
          titre: 'État général',
          icone: '🏥',
          description: 'Observer comportement et santé',
        ),
        ActionTache(
          id: 'securite_soir',
          titre: 'Sécurité',
          icone: '🔒',
          description: 'Fermer et sécuriser le local',
        ),
      ];
    }
  }

  /// Valider une action comme normale
  Future<void> validerNormal(TypeTacheQuotidienne type, String actionId) async {
    final tache = getTacheDuJour(type);
    if (tache == null) return;

    final actionIndex = tache.actions.indexWhere((a) => a.id == actionId);
    if (actionIndex == -1) return;

    final actionMaj = tache.actions[actionIndex].copyWith(
      resultat: ResultatAction.normal,
      heureValidation: DateTime.now(),
    );

    final actionsMaj = List<ActionTache>.from(tache.actions);
    actionsMaj[actionIndex] = actionMaj;

    final tacheMaj = tache.copyWith(actions: actionsMaj);
    await _db.updateTacheQuotidienne(tacheMaj);

    if (type == TypeTacheQuotidienne.matin) {
      _tacheMatin = tacheMaj;
    } else {
      _tacheSoir = tacheMaj;
    }
    notifyListeners();
  }

  /// Reporter une action à plus tard
  Future<void> validerPlusTard(
    TypeTacheQuotidienne type,
    String actionId,
  ) async {
    final tache = getTacheDuJour(type);
    if (tache == null) return;

    final actionIndex = tache.actions.indexWhere((a) => a.id == actionId);
    if (actionIndex == -1) return;

    final actionMaj = tache.actions[actionIndex].copyWith(
      resultat: ResultatAction.plusTard,
      heureValidation: DateTime.now(),
    );

    final actionsMaj = List<ActionTache>.from(tache.actions);
    actionsMaj[actionIndex] = actionMaj;

    final tacheMaj = tache.copyWith(actions: actionsMaj);
    await _db.updateTacheQuotidienne(tacheMaj);

    if (type == TypeTacheQuotidienne.matin) {
      _tacheMatin = tacheMaj;
    } else {
      _tacheSoir = tacheMaj;
    }
    notifyListeners();
  }

  /// Valider une action avec anomalie
  Future<void> validerAnomalie(
    TypeTacheQuotidienne type,
    String actionId, {
    String? note,
  }) async {
    final tache = getTacheDuJour(type);
    if (tache == null) return;

    final actionIndex = tache.actions.indexWhere((a) => a.id == actionId);
    if (actionIndex == -1) return;

    final actionMaj = tache.actions[actionIndex].copyWith(
      resultat: ResultatAction.anomalie,
      heureValidation: DateTime.now(),
      noteAnomalie: note,
    );

    final actionsMaj = List<ActionTache>.from(tache.actions);
    actionsMaj[actionIndex] = actionMaj;

    final tacheMaj = tache.copyWith(actions: actionsMaj);
    await _db.updateTacheQuotidienne(tacheMaj);

    if (type == TypeTacheQuotidienne.matin) {
      _tacheMatin = tacheMaj;
    } else {
      _tacheSoir = tacheMaj;
    }
    notifyListeners();
  }

  /// Obtenir les statistiques des tâches quotidiennes
  Future<Map<String, dynamic>> getStatistiquesRituels({int jours = 14}) async {
    try {
      final historique = await _db.getHistoriqueTaches(limite: jours);

      final total = historique.length;
      final completes = historique.where((t) => t.estComplet).length;
      final taux = total > 0 ? (completes / total * 100).round() : 0;

      return {
        'total': total,
        'completes': completes,
        'taux': taux,
        'serie': _calculerSerie(historique),
      };
    } catch (e) {
      logger.error('Erreur lors du calcul des statistiques', e);
      return {'total': 0, 'completes': 0, 'taux': 0, 'serie': 0};
    }
  }

  /// Calculer la série de jours consécutifs
  int _calculerSerie(List<TacheQuotidienne> historique) {
    int serie = 0;
    final today = DateTime.now();

    for (var i = 0; i < historique.length; i++) {
      final jourAttendu = today.subtract(Duration(days: i));
      final tache = historique.firstWhere(
        (t) =>
            t.date.year == jourAttendu.year &&
            t.date.month == jourAttendu.month &&
            t.date.day == jourAttendu.day &&
            t.estComplet,
        orElse: () => TacheQuotidienne(
          date: DateTime(1900),
          type: TypeTacheQuotidienne.matin,
          actions: [],
          dateCreation: DateTime.now(),
        ),
      );

      if (tache.date.year == 1900) break;
      serie++;
    }

    return serie;
  }
}
