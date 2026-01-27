import 'package:flutter/foundation.dart';
import '../models/tache.dart';
import '../models/enums/tache_enums.dart';
import '../services/database_helper.dart';
import '../utils/logger.dart';

/// Provider pour gérer l'état des tâches génériques (liste de choses à faire)
class TacheGeneriqueProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Tache> _taches = [];
  bool _isLoading = false;
  String _filtreStatut = 'tous'; // 'tous', 'a_faire', 'en_cours', 'terminee', 'annulee'
  String _filtreCategorie = 'tous'; // 'tous', 'reproduction', 'sante', etc.
  String _filtrePriorite = 'tous'; // 'tous', 'haute', 'normale', 'basse'
  String _vue = 'liste'; // 'liste', 'aujourdhui', 'semaine', 'mois', 'calendrier'
  String _recherche = '';

  List<Tache> get taches => _taches;
  bool get isLoading => _isLoading;
  String get filtreStatut => _filtreStatut;
  String get filtreCategorie => _filtreCategorie;
  String get filtrePriorite => _filtrePriorite;
  String get vue => _vue;
  String get recherche => _recherche;

  /// Tâches filtrées selon les critères actuels
  List<Tache> get tachesFiltrees {
    var resultat = List<Tache>.from(_taches);

    // Filtre par statut
    if (_filtreStatut != 'tous') {
      resultat = resultat.where((t) => t.statut.value == _filtreStatut).toList();
    }

    // Filtre par catégorie
    if (_filtreCategorie != 'tous') {
      resultat = resultat.where((t) => t.categorie.value == _filtreCategorie).toList();
    }

    // Filtre par priorité
    if (_filtrePriorite != 'tous') {
      resultat = resultat.where((t) => t.priorite.value == _filtrePriorite).toList();
    }

    // Filtre par recherche textuelle
    if (_recherche.isNotEmpty) {
      final rechercheLower = _recherche.toLowerCase();
      resultat = resultat.where((t) {
        return t.titre.toLowerCase().contains(rechercheLower) ||
            (t.description?.toLowerCase().contains(rechercheLower) ?? false) ||
            (t.notes?.toLowerCase().contains(rechercheLower) ?? false);
      }).toList();
    }

    // Filtre par vue
    switch (_vue) {
      case 'aujourdhui':
        resultat = resultat.where((t) => t.estAujourdhui).toList();
        break;
      case 'semaine':
        resultat = resultat.where((t) => t.estCetteSemaine).toList();
        break;
      case 'mois':
        final now = DateTime.now();
        final debutMois = DateTime(now.year, now.month, 1);
        final finMois = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        resultat = resultat.where((t) {
          return t.datePlanification.isAfter(debutMois.subtract(const Duration(days: 1))) &&
              t.datePlanification.isBefore(finMois.add(const Duration(days: 1)));
        }).toList();
        break;
    }

    // Tri par date et priorité
    resultat.sort((a, b) {
      // D'abord par date
      final dateCompare = a.datePlanification.compareTo(b.datePlanification);
      if (dateCompare != 0) return dateCompare;

      // Ensuite par priorité (haute > normale > basse)
      final prioriteOrder = {'haute': 3, 'normale': 2, 'basse': 1};
      final prioriteA = prioriteOrder[a.priorite.value] ?? 0;
      final prioriteB = prioriteOrder[b.priorite.value] ?? 0;
      return prioriteB.compareTo(prioriteA);
    });

    return resultat;
  }

  /// Tâches à faire (non terminées)
  List<Tache> get tachesAFaire {
    return _taches
        .where((t) => t.statut != StatutTache.terminee && t.statut != StatutTache.annulee)
        .toList()
      ..sort((a, b) => a.datePlanification.compareTo(b.datePlanification));
  }

  /// Tâches en retard
  List<Tache> get tachesEnRetard {
    return _taches.where((t) => t.estEnRetard).toList()
      ..sort((a, b) => a.datePlanification.compareTo(b.datePlanification));
  }

  /// Tâches pour aujourd'hui
  List<Tache> get tachesAujourdhui {
    return _taches.where((t) => t.estAujourdhui && t.statut != StatutTache.terminee && t.statut != StatutTache.annulee).toList();
  }

  /// Nombre de tâches en attente
  int get nombreTachesEnAttente {
    return _taches.where((t) => t.statut == StatutTache.aFaire || t.statut == StatutTache.enCours).length;
  }

  /// Charger toutes les tâches depuis la base de données
  Future<void> chargerTaches() async {
    _isLoading = true;
    notifyListeners();

    try {
      _taches = await _db.getAllTaches();
    } catch (e) {
      logger.error('Erreur lors du chargement des tâches', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajouter une tâche
  Future<Tache> ajouterTache(Tache tache) async {
    try {
      final nouvelleTache = await _db.insertTache(tache);
      _taches.insert(0, nouvelleTache);
      notifyListeners();
      return nouvelleTache;
    } catch (e) {
      logger.error('Erreur lors de l\'ajout de la tâche', e);
      rethrow;
    }
  }

  /// Modifier une tâche
  Future<void> modifierTache(Tache tache) async {
    try {
      await _db.updateTache(tache);
      final index = _taches.indexWhere((t) => t.id == tache.id);
      if (index != -1) {
        _taches[index] = tache;
        notifyListeners();
      }
    } catch (e) {
      logger.error('Erreur lors de la modification de la tâche', e);
      rethrow;
    }
  }

  /// Supprimer une tâche
  Future<void> supprimerTache(int id) async {
    try {
      await _db.deleteTache(id);
      _taches.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      logger.error('Erreur lors de la suppression de la tâche', e);
      rethrow;
    }
  }

  /// Marquer une tâche comme terminée
  Future<void> marquerTerminee(int id) async {
    try {
      await _db.marquerTacheTerminee(id);
      final index = _taches.indexWhere((t) => t.id == id);
      if (index != -1) {
        final tache = _taches[index];
        _taches[index] = tache.copyWith(
          statut: StatutTache.terminee,
          dateCompletion: DateTime.now(),
          dateModification: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      logger.error('Erreur lors du marquage de la tâche comme terminée', e);
      rethrow;
    }
  }

  /// Changer le statut d'une tâche
  Future<void> changerStatut(int id, StatutTache nouveauStatut) async {
    try {
      final index = _taches.indexWhere((t) => t.id == id);
      if (index != -1) {
        final tache = _taches[index];
        final tacheModifiee = tache.copyWith(
          statut: nouveauStatut,
          dateModification: DateTime.now(),
          dateCompletion: nouveauStatut == StatutTache.terminee ? DateTime.now() : tache.dateCompletion,
        );
        await _db.updateTache(tacheModifiee);
        _taches[index] = tacheModifiee;
        notifyListeners();
      }
    } catch (e) {
      logger.error('Erreur lors du changement de statut', e);
      rethrow;
    }
  }

  /// Définir le filtre de statut
  void setFiltreStatut(String statut) {
    _filtreStatut = statut;
    notifyListeners();
  }

  /// Définir le filtre de catégorie
  void setFiltreCategorie(String categorie) {
    _filtreCategorie = categorie;
    notifyListeners();
  }

  /// Définir le filtre de priorité
  void setFiltrePriorite(String priorite) {
    _filtrePriorite = priorite;
    notifyListeners();
  }

  /// Définir la vue
  void setVue(String vue) {
    _vue = vue;
    notifyListeners();
  }

  /// Définir la recherche
  void setRecherche(String recherche) {
    _recherche = recherche;
    notifyListeners();
  }

  /// Réinitialiser tous les filtres
  void reinitialiserFiltres() {
    _filtreStatut = 'tous';
    _filtreCategorie = 'tous';
    _filtrePriorite = 'tous';
    _vue = 'liste';
    _recherche = '';
    notifyListeners();
  }

  /// Obtenir les tâches d'un lapin
  List<Tache> getTachesParLapin(int lapinId) {
    return _taches.where((t) => t.lapinId == lapinId).toList()
      ..sort((a, b) => a.datePlanification.compareTo(b.datePlanification));
  }
}

