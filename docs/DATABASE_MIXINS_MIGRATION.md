# Migration des Mixins DatabaseHelper

## Vue d'ensemble

Ce document décrit la migration progressive de `DatabaseHelper` (5200+ lignes) vers une architecture modulaire basée sur des mixins.

## Architecture cible

```
DatabaseHelper extends DatabaseBase
    with LapinDatabaseMixin      - CRUD lapins, relations ✅
    with ReproductionDatabaseMixin - accouplements, portées ✅
    with SanteDatabaseMixin      - pesées, soins, médicaments ✅
    with FinanceDatabaseMixin    - recettes, dépenses ✅
    with LocalisationDatabaseMixin - bâtiments, clapiers, cages ✅
```

## État actuel (Phase 2 complète ✅)

### ✅ Phase 1 - Préparation (Complète)

1. **DatabaseHelper hérite maintenant de DatabaseBase**
   - Import ajouté : `import 'database/database_base.dart';`
   - Déclaration : `class DatabaseHelper extends DatabaseBase`

2. **Méthodes utilitaires rendues publiques**
   - `_getCurrentUserId()` → `getCurrentUserId()` avec `@override`
   - `_buildWhereWithUserId()` → `buildWhereWithUserId()` avec `@override`
   - `_prepareDataForInsert()` → `prepareDataForInsert()` avec `@override`
   - `_filterColumnsForUpdate()` → `filterColumnsForUpdate()` avec `@override`
   - `database` getter avec `@override`

3. **Paramètres mis à jour**
   - `tableName` est maintenant `required` dans toutes les méthodes

### ✅ Phase 2 - Application des Mixins (Complète)

**Modification effectuée dans `database_helper.dart` :**

```dart
class DatabaseHelper extends DatabaseBase 
    with LapinDatabaseMixin, 
         ReproductionDatabaseMixin,
         SanteDatabaseMixin,
         FinanceDatabaseMixin {
  // ... code existant
}
```

Les 4 mixins sont maintenant appliqués à DatabaseHelper.

### 📁 Fichiers créés

| Fichier | Lignes | Responsabilité |
|---------|--------|----------------|
| `lib/services/database/database_base.dart` | ~75 | Classe abstraite et extensions |
| `lib/services/database/lapin_database_mixin.dart` | ~326 | CRUD lapins, relations, généalogie |
| `lib/services/database/reproduction_database_mixin.dart` | ~350 | Accouplements, portées |
| `lib/services/database/sante_database_mixin.dart` | ~380 | Pesées, soins, médicaments |
| `lib/services/database/finance_database_mixin.dart` | ~450 | Recettes, dépenses, statistiques |
| `lib/services/database/localisation_database_mixin.dart` | ~470 | Bâtiments, clapiers, cages |
| `lib/services/database/database.dart` | ~60 | Exports avec documentation |

## Phase 3 : Nettoyage (À faire)

### Étape 3.1 : Supprimer les méthodes dupliquées

Pour chaque mixin appliqué, supprimer les méthodes correspondantes de `DatabaseHelper`.

| Fichier | Tests | Couverture |
|---------|-------|------------|
| `test/models/lapin_test.dart` | 15 | Création, toMap/fromMap, copyWith, âge |
| `test/models/accouplement_test.dart` | 23 | Création, dates calculées, statuts |
| `test/models/portee_test.dart` | 25 | Création, tauxSurvie, sevrage |
| `test/providers/lapin_provider_simple_test.dart` | 12 | CRUD, filtres, comptage |
| `test/providers/reproduction_provider_test.dart` | 12 | Logique reproduction |
| `test/providers/sante_provider_test.dart` | 28 | Pesées, soins, score santé |
| `test/providers/finance_provider_test.dart` | 28 | Recettes, dépenses, bénéfice |

**Total : 143 tests passants ✅**

## Avantages de cette architecture

1. **Séparation des responsabilités** : Chaque mixin gère un domaine métier
2. **Testabilité** : Les mixins peuvent être testés isolément
3. **Maintenabilité** : Plus facile de trouver et modifier le code
4. **Réutilisabilité** : Les mixins peuvent être réutilisés
5. **Migration progressive** : Pas de big bang, migration étape par étape

## Risques et mitigations

| Risque | Mitigation |
|--------|-----------|
| Breaking changes | Tests automatisés (115 tests) |
| Régression | Validation après chaque étape |
| Conflits de méthodes | Vérification des signatures avec @override |

## Commandes utiles

```bash
# Vérifier les erreurs
flutter analyze

# Lancer tous les tests
flutter test

# Lancer les tests d'un fichier
flutter test test/models/lapin_test.dart

# Couverture de code
flutter test --coverage
```

## Prochaines étapes recommandées

1. [x] Appliquer les 5 mixins à `DatabaseHelper` ✅
2. [ ] Supprimer les méthodes dupliquées de DatabaseHelper
3. [ ] Réduire DatabaseHelper de 5200+ lignes à ~2500 lignes

---

*Dernière mise à jour : Janvier 2026*
*Phase 2 terminée - 5 mixins appliqués à DatabaseHelper*
