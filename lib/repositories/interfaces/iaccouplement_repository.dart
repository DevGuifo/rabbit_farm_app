import '../../models/accouplement.dart';

/// Interface pour le repository des accouplements
/// Permet d'abstraire l'accès aux données (SQLite ou Supabase)
abstract class IAccouplementRepository {
  /// Insérer un nouvel accouplement
  Future<Accouplement> insert(Accouplement accouplement);

  /// Récupérer tous les accouplements
  Future<List<Accouplement>> getAll();

  /// Récupérer un accouplement par son ID
  Future<Accouplement?> getById(int id);

  /// Mettre à jour un accouplement
  Future<int> update(Accouplement accouplement);

  /// Supprimer un accouplement
  Future<int> delete(int id);

  /// Récupérer les accouplements en attente
  Future<List<Accouplement>> getEnAttente();

  /// Récupérer les accouplements par période
  Future<List<Accouplement>> getByPeriode(DateTime debut, DateTime fin);
}

