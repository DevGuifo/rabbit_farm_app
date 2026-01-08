import 'package:flutter/foundation.dart';
import '../models/rituel.dart';
import '../services/database_helper.dart';
import '../utils/logger.dart';

/// Provider pour gérer les rituels quotidiens
///
/// Gère automatiquement les rituels matin/soir du jour courant.
/// Crée les rituels au besoin et persiste les validations.
class RituelProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Rituel? _rituelMatin;
  Rituel? _rituelSoir;
  bool _isLoading = false;
  DateTime _dateActuelle = DateTime.now();

  // Getters
  Rituel? get rituelMatin => _rituelMatin;
  Rituel? get rituelSoir => _rituelSoir;
  bool get isLoading => _isLoading;
  DateTime get dateActuelle => _dateActuelle;

  /// Rituel matin terminé ?
  bool get matinTermine => _rituelMatin?.estComplet ?? false;

  /// Rituel soir terminé ?
  bool get soirTermine => _rituelSoir?.estComplet ?? false;

  /// Tous les rituels du jour terminés ?
  bool get jourComplet => matinTermine && soirTermine;

  /// Nombre total d'anomalies du jour
  int get anomaliesJour {
    return (_rituelMatin?.nombreAnomalies ?? 0) +
        (_rituelSoir?.nombreAnomalies ?? 0);
  }

  /// Déterminer quel rituel afficher en priorité
  Rituel? get rituelEnCours {
    final heure = DateTime.now().hour;
    // Avant 14h = rituel matin, après = rituel soir
    if (heure < 14) {
      return _rituelMatin;
    } else {
      return _rituelSoir;
    }
  }

  /// Charger ou créer les rituels du jour
  Future<void> chargerRituelsJour() async {
    _isLoading = true;
    notifyListeners();

    try {
      final aujourdhui = DateTime.now();
      _dateActuelle = aujourdhui;
      final dateJour = DateTime(
        aujourdhui.year,
        aujourdhui.month,
        aujourdhui.day,
      );

      // Charger rituel matin
      _rituelMatin = await _chargerOuCreerRituel(dateJour, TypeRituel.matin);

      // Charger rituel soir
      _rituelSoir = await _chargerOuCreerRituel(dateJour, TypeRituel.soir);

      logger.info('✅ Rituels du ${_formatDate(dateJour)} chargés');
    } catch (e, stackTrace) {
      logger.error('❌ Erreur chargement rituels', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger ou créer un rituel spécifique
  Future<Rituel> _chargerOuCreerRituel(DateTime date, TypeRituel type) async {
    // Chercher en base
    final rituelExistant = await _db.getRituelByDateAndType(date, type.name);

    if (rituelExistant != null) {
      return rituelExistant;
    }

    // Créer un nouveau rituel
    final actions = type == TypeRituel.matin
        ? actionsRituelMatin()
        : actionsRituelSoir();

    final nouveauRituel = Rituel(
      date: date,
      type: type,
      actions: actions,
      dateCreation: DateTime.now(),
    );

    // Sauvegarder en base
    final rituelSauvegarde = await _db.insertRituel(nouveauRituel);
    logger.info(
      '📝 Nouveau rituel ${type.name} créé pour ${_formatDate(date)}',
    );

    return rituelSauvegarde;
  }

  /// Valider une action d'un rituel (1 clic)
  Future<void> validerAction({
    required TypeRituel typeRituel,
    required String actionId,
    required ResultatAction resultat,
    String? noteAnomalie,
  }) async {
    try {
      final rituel = typeRituel == TypeRituel.matin
          ? _rituelMatin
          : _rituelSoir;
      if (rituel == null) return;

      // Trouver et mettre à jour l'action
      final actionIndex = rituel.actions.indexWhere((a) => a.id == actionId);
      if (actionIndex == -1) return;

      final actionMaj = rituel.actions[actionIndex].copyWith(
        resultat: resultat,
        heureValidation: DateTime.now(),
        noteAnomalie: noteAnomalie,
      );

      // Mettre à jour la liste des actions
      final nouvellesActions = List<ActionRituel>.from(rituel.actions);
      nouvellesActions[actionIndex] = actionMaj;

      // Vérifier si le rituel est maintenant complet
      final estComplet = nouvellesActions.every((a) => a.estFait);

      final rituelMaj = rituel.copyWith(
        actions: nouvellesActions,
        dateCompletion: estComplet ? DateTime.now() : null,
      );

      // Sauvegarder en base
      await _db.updateRituel(rituelMaj);

      // Mettre à jour le state local
      if (typeRituel == TypeRituel.matin) {
        _rituelMatin = rituelMaj;
      } else {
        _rituelSoir = rituelMaj;
      }

      logger.info('✅ Action "${actionMaj.titre}" validée: ${resultat.name}');
      notifyListeners();
    } catch (e, stackTrace) {
      logger.error('❌ Erreur validation action', e, stackTrace);
    }
  }

  /// Valider une action comme "Normal" (raccourci)
  Future<void> validerNormal(TypeRituel type, String actionId) async {
    await validerAction(
      typeRituel: type,
      actionId: actionId,
      resultat: ResultatAction.normal,
    );
  }

  /// Valider une action comme "Anomalie"
  Future<void> validerAnomalie(
    TypeRituel type,
    String actionId, {
    String? note,
  }) async {
    await validerAction(
      typeRituel: type,
      actionId: actionId,
      resultat: ResultatAction.anomalie,
      noteAnomalie: note,
    );
  }

  /// Reporter une action à plus tard
  Future<void> validerPlusTard(TypeRituel type, String actionId) async {
    await validerAction(
      typeRituel: type,
      actionId: actionId,
      resultat: ResultatAction.plusTard,
    );
  }

  /// Réinitialiser une action (pour la refaire)
  Future<void> reinitialiserAction(TypeRituel type, String actionId) async {
    await validerAction(
      typeRituel: type,
      actionId: actionId,
      resultat: ResultatAction.nonFait,
    );
  }

  /// Obtenir l'historique des rituels
  Future<List<Rituel>> getHistoriqueRituels({int limite = 14}) async {
    try {
      return await _db.getHistoriqueRituels(limite: limite);
    } catch (e) {
      logger.error('❌ Erreur chargement historique rituels', e);
      return [];
    }
  }

  /// Statistiques des rituels sur une période
  Future<Map<String, dynamic>> getStatistiquesRituels({int jours = 7}) async {
    try {
      final historique = await getHistoriqueRituels(limite: jours * 2);

      int rituelsComplets = 0;
      int totalRituels = historique.length;
      int totalAnomalies = 0;

      for (final rituel in historique) {
        if (rituel.estComplet) rituelsComplets++;
        totalAnomalies += rituel.nombreAnomalies;
      }

      return {
        'rituelsComplets': rituelsComplets,
        'totalRituels': totalRituels,
        'tauxCompletion': totalRituels > 0
            ? (rituelsComplets / totalRituels * 100).round()
            : 0,
        'totalAnomalies': totalAnomalies,
      };
    } catch (e) {
      logger.error('❌ Erreur calcul statistiques rituels', e);
      return {
        'rituelsComplets': 0,
        'totalRituels': 0,
        'tauxCompletion': 0,
        'totalAnomalies': 0,
      };
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
