import '../../models/lapin.dart';

/// Interface pour le repository des lapins
/// Permet d'abstraire l'accès aux données (SQLite ou Supabase)
/// 
/// Cette interface sera implémentée par :
/// - SQLiteLapinRepository (implémentation actuelle)
/// - SupabaseLapinRepository (future implémentation)
abstract class ILapinRepository {
  /// Insérer un nouveau lapin
  Future<Lapin> insert(Lapin lapin);

  /// Récupérer tous les lapins
  Future<List<Lapin>> getAll();

  /// Récupérer un lapin par son ID
  Future<Lapin?> getById(int id);

  /// Mettre à jour un lapin
  Future<int> update(Lapin lapin);

  /// Supprimer un lapin
  Future<int> delete(int id);

  /// Récupérer les lapins par sexe
  Future<List<Lapin>> getBySexe(String sexe);

  /// Récupérer les lapins par statut
  Future<List<Lapin>> getByStatut(String statut);

  /// Compter le nombre total de lapins
  Future<int> count();

  /// Rechercher des lapins par nom ou numéro d'identification
  Future<List<Lapin>> search(String query);
}

