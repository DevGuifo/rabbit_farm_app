import 'package:flutter/foundation.dart';
import '../models/recette.dart';
import '../models/depense.dart';
import '../models/journal_entry.dart';
import '../repositories/finance_repository.dart';
import '../services/journal_service.dart';
import '../services/preferences_service.dart';
import '../constants/preferences_keys.dart';

class FinanceProvider with ChangeNotifier {
  final FinanceRepository _repository;
  final JournalService _journal;
  final PreferencesService _prefs;

  FinanceProvider()
    : _repository = FinanceRepository.instance,
      _journal = JournalService(),
      _prefs = PreferencesService();

  @visibleForTesting
  FinanceProvider.withRepository(
    FinanceRepository repository, {
    JournalService? journalService,
    PreferencesService? prefsService,
  }) : _repository = repository,
       _journal = journalService ?? JournalService(),
       _prefs = prefsService ?? PreferencesService();

  List<Recette> _recettes = [];
  List<Depense> _depenses = [];

  List<Recette> get recettes => _recettes;
  List<Depense> get depenses => _depenses;

  /// Convertit un montant d'une devise source vers la devise de l'utilisateur
  double _convertirVersDeviseUtilisateur(double montant, String sourceCode) {
    final userCurrencyCode = _prefs.getCurrencySync();
    if (sourceCode == userCurrencyCode) {
      return montant; // Pas de conversion nécessaire
    }
    // Convertir via EUR comme intermédiaire
    return SupportedCurrencies.convert(
      amount: montant,
      fromCode: sourceCode,
      toCode: userCurrencyCode,
    );
  }

  /// Total des recettes converti dans la devise de l'utilisateur
  double get totalRecettes => _recettes.fold(0.0, (sum, r) => 
      sum + _convertirVersDeviseUtilisateur(r.montant, r.currency));
  
  /// Total des dépenses converti dans la devise de l'utilisateur
  double get totalDepenses => _depenses.fold(0.0, (sum, d) => 
      sum + _convertirVersDeviseUtilisateur(d.montant, d.currency));
  
  /// Bénéfice net converti dans la devise de l'utilisateur
  double get benefice => totalRecettes - totalDepenses;

  /// Charger toutes les recettes et dépenses
  Future<void> chargerTout() async {
    _recettes = await _repository.getAllRecettes();
    _depenses = await _repository.getAllDepenses();
    notifyListeners();
  }

  /// Ajouter une recette
  /// La devise de l'utilisateur est automatiquement associée à la recette
  Future<void> ajouterRecette(Recette recette) async {
    // Associer la devise de l'utilisateur si non définie
    final userCurrencyCode = _prefs.getCurrencySync();
    final recetteAvecDevise = recette.currency == 'EUR' 
        ? recette.copyWith(currency: userCurrencyCode)
        : recette;
    
    final nouvelleRecette = await _repository.insertRecette(recetteAvecDevise);
    _recettes.insert(0, nouvelleRecette);
    notifyListeners();

    // 📝 Journal automatique
    await _journal.recette(
      action: TypeAction.creation,
      recetteId: nouvelleRecette.id!,
      montant: nouvelleRecette.montant,
      categorie: nouvelleRecette.categorie.label,
      contexte: {
        'date': nouvelleRecette.date.toIso8601String(),
        'description': nouvelleRecette.description,
        'currency': nouvelleRecette.currency,
      },
    );
  }

  /// Ajouter une dépense
  /// La devise de l'utilisateur est automatiquement associée à la dépense
  Future<void> ajouterDepense(Depense depense) async {
    // Associer la devise de l'utilisateur si non définie
    final userCurrencyCode = _prefs.getCurrencySync();
    final depenseAvecDevise = depense.currency == 'EUR'
        ? depense.copyWith(currency: userCurrencyCode)
        : depense;
    
    final nouvelleDepense = await _repository.insertDepense(depenseAvecDevise);
    _depenses.insert(0, nouvelleDepense);
    notifyListeners();

    // 📝 Journal automatique
    await _journal.depense(
      action: TypeAction.creation,
      depenseId: nouvelleDepense.id!,
      montant: nouvelleDepense.montant,
      categorie: nouvelleDepense.categorie.label,
      contexte: {
        'date': nouvelleDepense.date.toIso8601String(),
        'description': nouvelleDepense.description,
        'currency': nouvelleDepense.currency,
      },
    );
  }

  /// Mettre à jour une recette
  Future<void> modifierRecette(Recette recette) async {
    await _repository.updateRecette(recette);
    final index = _recettes.indexWhere((r) => r.id == recette.id);
    if (index != -1) {
      _recettes[index] = recette;
      notifyListeners();
    }
  }

  /// Mettre à jour une dépense
  Future<void> modifierDepense(Depense depense) async {
    await _repository.updateDepense(depense);
    final index = _depenses.indexWhere((d) => d.id == depense.id);
    if (index != -1) {
      _depenses[index] = depense;
      notifyListeners();
    }
  }

  /// Supprimer une recette
  Future<void> supprimerRecette(int id) async {
    await _repository.deleteRecette(id);
    _recettes.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  /// Supprimer une dépense
  Future<void> supprimerDepense(int id) async {
    await _repository.deleteDepense(id);
    _depenses.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  /// Obtenir les recettes par période
  Future<List<Recette>> getRecettesByPeriode(
    DateTime debut,
    DateTime fin,
  ) async {
    return await _repository.getRecettesByPeriode(debut, fin);
  }

  /// Obtenir les dépenses par période
  Future<List<Depense>> getDepensesByPeriode(
    DateTime debut,
    DateTime fin,
  ) async {
    return await _repository.getDepensesByPeriode(debut, fin);
  }

  /// Obtenir le total des recettes par catégorie
  Future<Map<String, double>> getTotalRecettesByCategorie() async {
    return await _repository.getTotalRecettesByCategorie();
  }

  /// Obtenir le total des dépenses par catégorie
  Future<Map<String, double>> getTotalDepensesByCategorie() async {
    return await _repository.getTotalDepensesByCategorie();
  }

  /// Obtenir le bénéfice par période
  Future<double> getBeneficeByPeriode(DateTime debut, DateTime fin) async {
    return await _repository.getBeneficeByPeriode(debut, fin);
  }

  /// Obtenir les recettes d'un lapin
  Future<List<Recette>> getRecettesByLapin(int lapinId) async {
    return await _repository.getRecettesByLapin(lapinId);
  }
}
