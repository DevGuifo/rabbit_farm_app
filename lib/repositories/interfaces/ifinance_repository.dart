import '../../models/recette.dart';
import '../../models/depense.dart';

/// Interface pour le repository des finances
/// Regroupe les opérations sur les recettes et dépenses
abstract class IFinanceRepository {
  // ========== RECETTES ==========

  /// Insérer une recette
  Future<Recette> insertRecette(Recette recette);

  /// Récupérer toutes les recettes
  Future<List<Recette>> getAllRecettes();

  /// Récupérer une recette par ID
  Future<Recette?> getRecetteById(int id);

  /// Mettre à jour une recette
  Future<int> updateRecette(Recette recette);

  /// Supprimer une recette
  Future<int> deleteRecette(int id);

  /// Récupérer les recettes par période
  Future<List<Recette>> getRecettesByPeriode(DateTime debut, DateTime fin);

  /// Récupérer les recettes par catégorie
  Future<List<Recette>> getRecettesByCategorie(String categorie);

  // ========== DÉPENSES ==========

  /// Insérer une dépense
  Future<Depense> insertDepense(Depense depense);

  /// Récupérer toutes les dépenses
  Future<List<Depense>> getAllDepenses();

  /// Récupérer une dépense par ID
  Future<Depense?> getDepenseById(int id);

  /// Mettre à jour une dépense
  Future<int> updateDepense(Depense depense);

  /// Supprimer une dépense
  Future<int> deleteDepense(int id);

  /// Récupérer les dépenses par période
  Future<List<Depense>> getDepensesByPeriode(DateTime debut, DateTime fin);

  /// Récupérer les dépenses par catégorie
  Future<List<Depense>> getDepensesByCategorie(String categorie);
}

