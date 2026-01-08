import 'package:flutter/foundation.dart';
import '../models/journal_entry.dart';
import '../services/journal_service.dart';
import '../services/database_helper.dart';

/// Période de consultation du journal
enum PeriodeJournal { aujourdhui, semaine, mois, personnalisee }

extension PeriodeJournalExtension on PeriodeJournal {
  String get label {
    switch (this) {
      case PeriodeJournal.aujourdhui:
        return "Aujourd'hui";
      case PeriodeJournal.semaine:
        return 'Cette semaine';
      case PeriodeJournal.mois:
        return 'Ce mois';
      case PeriodeJournal.personnalisee:
        return 'Personnalisée';
    }
  }
}

/// Provider pour la gestion du journal automatique
///
/// Permet de consulter l'historique par jour/semaine/mois
/// et d'ajouter des notes optionnelles (jamais obligatoires).
class JournalProvider extends ChangeNotifier {
  final JournalService _journalService = JournalService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  // État
  List<JournalEntry> _entries = [];
  PeriodeJournal _periodeActuelle = PeriodeJournal.aujourdhui;
  TypeEntite? _filtreEntite;
  StatutEvenement? _filtreStatut;
  bool _isLoading = false;
  String? _erreur;
  int _countNonLus = 0;
  Map<String, dynamic> _stats = {};

  // Getters
  List<JournalEntry> get entries => _entries;
  PeriodeJournal get periodeActuelle => _periodeActuelle;
  TypeEntite? get filtreEntite => _filtreEntite;
  StatutEvenement? get filtreStatut => _filtreStatut;
  bool get isLoading => _isLoading;
  String? get erreur => _erreur;
  int get countNonLus => _countNonLus;
  Map<String, dynamic> get stats => _stats;

  /// Entrées filtrées selon les critères actuels
  List<JournalEntry> get entriesFiltrees {
    var result = _entries;

    if (_filtreEntite != null) {
      result = result.where((e) => e.typeEntite == _filtreEntite).toList();
    }

    if (_filtreStatut != null) {
      result = result.where((e) => e.statut == _filtreStatut).toList();
    }

    return result;
  }

  /// Entrées groupées par date
  Map<String, List<JournalEntry>> get entriesParDate {
    final grouped = <String, List<JournalEntry>>{};
    for (final entry in entriesFiltrees) {
      final dateKey = entry.dateFormatee;
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(entry);
    }
    return grouped;
  }

  /// Statistiques du journal
  StatsJournal get statsCalculees => StatsJournal.fromEntries(_entries);

  /// Charger le journal selon la période
  Future<void> chargerJournal([PeriodeJournal? periode]) async {
    _isLoading = true;
    _erreur = null;
    notifyListeners();

    try {
      _periodeActuelle = periode ?? _periodeActuelle;

      switch (_periodeActuelle) {
        case PeriodeJournal.aujourdhui:
          _entries = await _journalService.aujourdhui();
          break;
        case PeriodeJournal.semaine:
          _entries = await _journalService.semaine();
          break;
        case PeriodeJournal.mois:
          _entries = await _journalService.mois();
          break;
        case PeriodeJournal.personnalisee:
          // Géré par chargerPeriodePersonnalisee
          break;
      }

      _countNonLus = await _journalService.countNonLus();
      _stats = await _journalService.stats();
    } catch (e) {
      _erreur = 'Erreur chargement journal: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger une période personnalisée
  Future<void> chargerPeriodePersonnalisee(DateTime debut, DateTime fin) async {
    _isLoading = true;
    _erreur = null;
    _periodeActuelle = PeriodeJournal.personnalisee;
    notifyListeners();

    try {
      _entries = await _db.getJournalPeriode(debut, fin);
      _countNonLus = await _journalService.countNonLus();
    } catch (e) {
      _erreur = 'Erreur chargement période: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger les entrées non lues uniquement
  Future<void> chargerNonLus() async {
    _isLoading = true;
    _erreur = null;
    notifyListeners();

    try {
      _entries = await _journalService.nonLus();
      _countNonLus = _entries.length;
    } catch (e) {
      _erreur = 'Erreur chargement non lus: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger l'historique d'une entité spécifique
  Future<void> chargerHistoriqueEntite(TypeEntite type, int id) async {
    _isLoading = true;
    _erreur = null;
    notifyListeners();

    try {
      _entries = await _journalService.historiqueEntite(type, id);
    } catch (e) {
      _erreur = 'Erreur chargement historique: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Appliquer un filtre par type d'entité
  void filtrerParEntite(TypeEntite? type) {
    _filtreEntite = type;
    notifyListeners();
  }

  /// Appliquer un filtre par statut
  void filtrerParStatut(StatutEvenement? statut) {
    _filtreStatut = statut;
    notifyListeners();
  }

  /// Réinitialiser tous les filtres
  void reinitialiserFiltres() {
    _filtreEntite = null;
    _filtreStatut = null;
    notifyListeners();
  }

  /// Marquer une entrée comme lue
  Future<void> marquerLu(int id) async {
    try {
      await _journalService.marquerLu(id);

      // Mettre à jour localement
      final index = _entries.indexWhere((e) => e.id == id);
      if (index != -1) {
        _entries[index] = _entries[index].copyWith(lu: true);
        _countNonLus = _entries.where((e) => !e.lu).length;
        notifyListeners();
      }
    } catch (e) {
      _erreur = 'Erreur marquage lu: $e';
      notifyListeners();
    }
  }

  /// Marquer toutes les entrées comme lues
  Future<void> marquerToutLu() async {
    try {
      await _journalService.marquerToutLu();

      // Mettre à jour localement
      _entries = _entries.map((e) => e.copyWith(lu: true)).toList();
      _countNonLus = 0;
      notifyListeners();
    } catch (e) {
      _erreur = 'Erreur marquage tout lu: $e';
      notifyListeners();
    }
  }

  /// Ajouter une note utilisateur (optionnelle, jamais obligatoire)
  Future<void> ajouterNote(int id, String note) async {
    try {
      await _journalService.ajouterNote(id, note);

      // Mettre à jour localement
      final index = _entries.indexWhere((e) => e.id == id);
      if (index != -1) {
        _entries[index] = _entries[index].copyWith(noteUtilisateur: note);
        notifyListeners();
      }
    } catch (e) {
      _erreur = 'Erreur ajout note: $e';
      notifyListeners();
    }
  }

  /// Rafraîchir le compteur de non lus
  Future<void> rafraichirCountNonLus() async {
    try {
      _countNonLus = await _journalService.countNonLus();
      notifyListeners();
    } catch (e) {
      // Silencieux
    }
  }

  /// Effacer l'erreur
  void effacerErreur() {
    _erreur = null;
    notifyListeners();
  }
}
