# Architecture DatabaseHelper - BunnyManager

## Vue d'ensemble

Le `DatabaseHelper` utilise une architecture basée sur des **mixins** pour séparer les responsabilités par domaine métier.

## Structure des fichiers

```
lib/services/database/
├── database.dart                    # Export principal
├── database_base.dart               # Classe abstraite de base
├── lapin_database_mixin.dart        # ~16 KB - CRUD lapins
├── reproduction_database_mixin.dart # ~13 KB - accouplements, portées
├── sante_database_mixin.dart        # ~13 KB - soins, médicaments
├── finance_database_mixin.dart      # ~16 KB - recettes, dépenses
├── localisation_database_mixin.dart # ~16 KB - cages, clapiers
└── lot_database_mixin.dart          # ~17 KB - gestion lots
```

## Mixins par domaine

| Mixin | Responsabilité | Méthodes principales |
|-------|----------------|---------------------|
| `LapinDatabaseMixin` | Lapins individuels | `getAllLapins`, `insertLapin`, `updateLapin` |
| `LotDatabaseMixin` | Gestion par lots | `getAllLots`, `updateEffectif` |
| `ReproductionDatabaseMixin` | Cycle reproduction | `insertAccouplement`, `getPortees` |
| `SanteDatabaseMixin` | Santé, médicaments | `getAllMedicaments`, `insertSoin` |
| `FinanceDatabaseMixin` | Finances | `getRecettes`, `getDepenses` |
| `LocalisationDatabaseMixin` | Cages, clapiers | `getAllCages`, `getClapiers` |

## Usage

```dart
class DatabaseHelper extends DatabaseBase
    with LapinDatabaseMixin, 
         LotDatabaseMixin,
         ReproductionDatabaseMixin,
         SanteDatabaseMixin,
         FinanceDatabaseMixin,
         LocalisationDatabaseMixin {
  // Singleton pattern
  static final DatabaseHelper instance = DatabaseHelper._internal();
}
```

## Statistiques

- **DatabaseHelper original** : 4236 lignes
- **Lignes extraites vers mixins** : ~1930 lignes
- **Total mixins** : 6 mixins, 87+ méthodes

---
*Généré le 3 février 2026*
