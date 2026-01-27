import 'package:sqflite/sqflite.dart';
import '../../utils/logger.dart';

/// Classe de base abstraite pour les opérations de base de données
///
/// Cette classe fournit l'accès commun à la base de données SQLite
/// et des méthodes utilitaires partagées par tous les helpers spécialisés.
///
/// ## Architecture
///
/// ```
/// DatabaseHelper (singleton principal)
///     ├── LapinDatabaseMixin      - CRUD lapins, relations
///     ├── ReproductionDatabaseMixin - accouplements, portées
///     ├── SanteDatabaseMixin      - pesées, soins, médicaments
///     ├── FinanceDatabaseMixin    - recettes, dépenses
///     └── LocalisationDatabaseMixin - bâtiments, clapiers, cages
/// ```
///
/// ## Usage
///
/// Les mixins sont appliqués à DatabaseHelper pour séparer les responsabilités
/// tout en gardant un seul point d'accès à la base de données.
abstract class DatabaseBase {
  /// Accès à l'instance de base de données SQLite
  Future<Database> get database;

  /// Récupère l'ID utilisateur courant pour le multi-tenant
  Future<String?> getCurrentUserId();

  /// Prépare les données pour insertion avec user_id et created_at
  Future<Map<String, dynamic>> prepareDataForInsert(
    Map<String, dynamic> data, {
    required String tableName,
  });

  /// Filtre les colonnes inexistantes avant une mise à jour
  Future<Map<String, dynamic>> filterColumnsForUpdate(
    Map<String, dynamic> data,
    String tableName,
  );

  /// Construit une clause WHERE avec filtre user_id
  Future<(String, List<dynamic>)> buildWhereWithUserId(
    String? where,
    List<dynamic>? whereArgs,
    String? userId, {
    required String tableName,
  });
}

/// Extension de Database pour les logs en mode debug
extension DatabaseDebugExtension on Database {
  /// Execute une requête avec log optionnel
  Future<List<Map<String, dynamic>>> queryWithLog(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    bool enableLog = false,
  }) async {
    if (enableLog) {
      logger.debug('[DB] Query $table - WHERE: $where');
    }
    return await query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }
}
