/// Module de base de données découpé
/// 
/// Cette bibliothèque exporte tous les composants de la couche base de données
/// restructurée selon le principe de responsabilité unique (SRP).
/// 
/// ## Architecture
/// 
/// ```
/// lib/services/database/
/// ├── database_base.dart              - Classe abstraite de base
/// ├── lapin_database_mixin.dart       - CRUD lapins, relations (~280 lignes)
/// ├── reproduction_database_mixin.dart - accouplements, portées (~350 lignes)
/// ├── sante_database_mixin.dart       - pesées, soins, médicaments (~380 lignes)
/// ├── finance_database_mixin.dart     - recettes, dépenses (~450 lignes)
/// └── database.dart                   - Export principal (ce fichier)
/// ```
/// 
/// ## Usage
/// 
/// Ces mixins sont destinés à être appliqués au `DatabaseHelper` principal :
/// 
/// ```dart
/// class DatabaseHelper extends DatabaseBase
///     with LapinDatabaseMixin, 
///          ReproductionDatabaseMixin,
///          SanteDatabaseMixin,
///          FinanceDatabaseMixin {
///   // ...
/// }
/// ```
/// 
/// ## Migration progressive
/// 
/// Cette restructuration est faite progressivement :
/// 1. Les mixins sont créés et testés
/// 2. DatabaseHelper applique les mixins
/// 3. Le code existant continue à fonctionner via DatabaseHelper.instance
/// 4. Les nouveaux tests utilisent les mixins directement
/// 
/// ## Statistiques de refactoring
/// 
/// | Mixin | Lignes | Méthodes |
/// |-------|--------|----------|
/// | LapinDatabaseMixin | ~280 | 12 |
/// | ReproductionDatabaseMixin | ~350 | 15 |
/// | SanteDatabaseMixin | ~380 | 18 |
/// | FinanceDatabaseMixin | ~450 | 20 |
/// | LocalisationDatabaseMixin | ~470 | 22 |
/// | **Total extrait** | ~1930 | 87 |
/// 
/// DatabaseHelper original : 5220 lignes → après migration complète : ~3300 lignes
library;

export 'database_base.dart';
export 'lapin_database_mixin.dart';
export 'reproduction_database_mixin.dart';
export 'sante_database_mixin.dart';
export 'finance_database_mixin.dart';
export 'localisation_database_mixin.dart';
