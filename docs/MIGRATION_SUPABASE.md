# Stratégie de Migration vers Supabase

## 📋 Vue d'ensemble

Ce document décrit la stratégie de migration de l'application **BunnyManager** vers une architecture avec synchronisation Supabase, tout en conservant le fonctionnement **offline-first**.

**Principe :** Migration progressive sans casser l'existant, avec possibilité de rollback à tout moment.

---

## 🎯 Objectifs

1. **Synchronisation multi-appareils** : Permettre à plusieurs utilisateurs/appareils de synchroniser leurs données
2. **Sauvegarde cloud** : Sauvegarde automatique des données dans le cloud
3. **Authentification** : Gestion des utilisateurs et authentification
4. **Offline-first maintenu** : L'application continue de fonctionner sans connexion
5. **Migration progressive** : Migration module par module sans interruption de service

---

## 🏗️ Architecture Cible

### Architecture Actuelle (Offline-Only)

```
Providers → DatabaseHelper → SQLite
```

### Architecture Cible (Offline-First avec Sync)

```
Providers → Repository Interface → [SQLiteRepository | SupabaseRepository]
                                    ↓
                              SyncService
                                    ↓
                              [SQLite + Supabase]
```

### Pattern Repository

**Avantages :**
- Abstraction de la couche de données
- Possibilité de basculer entre SQLite et Supabase
- Tests facilités (mocks)
- Migration progressive possible

**Structure :**
```
lib/
  repositories/
    interfaces/
      ilapin_repository.dart
      iaccouplement_repository.dart
      isante_repository.dart
      ...
    implementations/
      sqlite/
        sqlite_lapin_repository.dart
        sqlite_accouplement_repository.dart
        ...
      supabase/
        supabase_lapin_repository.dart
        supabase_accouplement_repository.dart
        ...
```

---

## 📊 Champs de Synchronisation Nécessaires

### Champs à ajouter à toutes les tables

```sql
-- Champs de synchronisation (à ajouter lors de la migration)
user_id TEXT,              -- ID de l'utilisateur (UUID Supabase)
created_at TEXT,           -- Date de création (ISO 8601)
updated_at TEXT,           -- Date de dernière modification (ISO 8601)
synced_at TEXT,            -- Date de dernière synchronisation (ISO 8601)
is_dirty INTEGER DEFAULT 0, -- Flag: modifications locales non synchronisées
is_deleted INTEGER DEFAULT 0, -- Soft delete: marqué comme supprimé mais conservé
sync_conflict TEXT,        -- JSON: résolution de conflits si nécessaire
```

### Modèles Dart

Les modèles devront être étendus avec ces champs (optionnels pour rétrocompatibilité) :

```dart
class Lapin {
  // ... champs existants ...
  
  // Champs de synchronisation (optionnels pour migration progressive)
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;
  final bool isDirty;
  final bool isDeleted;
  final Map<String, dynamic>? syncConflict;
}
```

---

## 🔄 Stratégie de Migration Progressive

### Phase 1 : Préparation (SANS Supabase)
- ✅ Créer interfaces Repository
- ✅ Documenter champs de sync
- ✅ Préparer scripts de migration SQL
- ✅ Créer SyncService (squelette)

**Durée estimée :** 1 semaine

### Phase 2 : Migration Base de Données
- Ajouter champs de sync à toutes les tables (migration SQL)
- Mettre à jour les modèles Dart
- Initialiser les champs pour les données existantes

**Durée estimée :** 2-3 jours

### Phase 3 : Implémentation Repository SQLite
- Créer `SQLiteLapinRepository` qui implémente `ILapinRepository`
- Migrer `DatabaseHelper` vers les repositories
- Tester que tout fonctionne comme avant

**Durée estimée :** 1 semaine

### Phase 4 : Implémentation Supabase (Parallèle)
- Créer `SupabaseLapinRepository` qui implémente `ILapinRepository`
- Implémenter SyncService
- Tests unitaires pour Supabase

**Durée estimée :** 1-2 semaines

### Phase 5 : Migration Module par Module
- Module 1 : Lapins (test)
- Module 2 : Accouplements
- Module 3 : Santé (pesées, soins)
- Module 4 : Finances
- Module 5 : Alimentation
- Module 6 : Autres modules

**Durée estimée :** 2-3 semaines

### Phase 6 : Activation Complète
- Activer sync pour tous les modules
- Tests d'intégration
- Déploiement progressif

**Durée estimée :** 1 semaine

**Total estimé :** 6-8 semaines

---

## 🔧 Points d'Extension Identifiés

### Fichiers à Modifier

1. **Modèles** (`lib/models/*.dart`)
   - Ajouter champs de sync (optionnels)
   - Mettre à jour `toMap()` et `fromMap()`

2. **DatabaseHelper** (`lib/services/database_helper.dart`)
   - Extraire logique dans repositories
   - Garder pour rétrocompatibilité initiale

3. **Providers** (`lib/providers/*.dart`)
   - Remplacer `DatabaseHelper` par `Repository`
   - Gérer les états de synchronisation

4. **Nouveaux Fichiers**
   - `lib/repositories/interfaces/*.dart` - Interfaces
   - `lib/repositories/implementations/sqlite/*.dart` - Implémentations SQLite
   - `lib/repositories/implementations/supabase/*.dart` - Implémentations Supabase
   - `lib/services/sync_service.dart` - Service de synchronisation
   - `lib/services/auth_service.dart` - Service d'authentification

---

## 🔐 Authentification

### Stratégie

- **Supabase Auth** : Gestion des utilisateurs
- **JWT Tokens** : Authentification sécurisée
- **Offline Auth** : Cache du token localement

### Flux

1. Utilisateur se connecte → Token JWT stocké localement
2. Token utilisé pour toutes les requêtes Supabase
3. Refresh automatique du token
4. Déconnexion → Suppression du token local

---

## 🔄 Synchronisation

### Stratégie de Sync

**Sync Bidirectionnelle :**
- **Sync Up** : Envoyer les modifications locales vers Supabase
- **Sync Down** : Récupérer les modifications depuis Supabase
- **Résolution de conflits** : Stratégie "Last Write Wins" ou manuelle

### Queue de Synchronisation

```dart
class SyncQueue {
  List<SyncOperation> pendingOperations;
  
  // Opérations en attente de sync
  Future<void> syncUp() async { ... }
  Future<void> syncDown() async { ... }
  Future<void> resolveConflicts() async { ... }
}
```

### Gestion des Conflits

**Stratégies possibles :**
1. **Last Write Wins** : La dernière modification gagne
2. **Manual Resolution** : L'utilisateur choisit
3. **Merge** : Fusion intelligente si possible

---

## 📝 Scripts de Migration SQL

### Migration 1 : Ajout des champs de sync

```sql
-- Migration pour ajouter les champs de synchronisation
-- Version DB : 11 (à incrémenter)

-- Table lapins
ALTER TABLE lapins ADD COLUMN user_id TEXT;
ALTER TABLE lapins ADD COLUMN created_at TEXT;
ALTER TABLE lapins ADD COLUMN updated_at TEXT;
ALTER TABLE lapins ADD COLUMN synced_at TEXT;
ALTER TABLE lapins ADD COLUMN is_dirty INTEGER DEFAULT 0;
ALTER TABLE lapins ADD COLUMN is_deleted INTEGER DEFAULT 0;
ALTER TABLE lapins ADD COLUMN sync_conflict TEXT;

-- Table accouplements
ALTER TABLE accouplements ADD COLUMN user_id TEXT;
ALTER TABLE accouplements ADD COLUMN created_at TEXT;
ALTER TABLE accouplements ADD COLUMN updated_at TEXT;
ALTER TABLE accouplements ADD COLUMN synced_at TEXT;
ALTER TABLE accouplements ADD COLUMN is_dirty INTEGER DEFAULT 0;
ALTER TABLE accouplements ADD COLUMN is_deleted INTEGER DEFAULT 0;
ALTER TABLE accouplements ADD COLUMN sync_conflict TEXT;

-- Répéter pour toutes les tables principales :
-- portees, pesees, soins, recettes, depenses, deces, aliments, etc.
```

### Initialisation des données existantes

```sql
-- Initialiser les champs pour les données existantes
UPDATE lapins SET 
  created_at = datetime('now'),
  updated_at = datetime('now'),
  is_dirty = 0,
  is_deleted = 0
WHERE created_at IS NULL;

-- Répéter pour toutes les tables
```

---

## 🧪 Tests de Non-Régression

### Checklist de Tests

- [ ] Tous les CRUD fonctionnent comme avant
- [ ] Les Providers fonctionnent sans modification
- [ ] Les écrans s'affichent correctement
- [ ] Les exports/imports fonctionnent
- [ ] Les calculs métier sont corrects
- [ ] Les notifications fonctionnent
- [ ] Les rapports PDF se génèrent

### Tests de Synchronisation

- [ ] Sync Up : Modifications locales → Supabase
- [ ] Sync Down : Modifications Supabase → Local
- [ ] Résolution de conflits
- [ ] Gestion offline (pas de connexion)
- [ ] Gestion des erreurs réseau

---

## 🚨 Stratégie de Rollback

### En cas de problème

1. **Désactiver la sync** : Basculer vers SQLite uniquement
2. **Restaurer la DB** : Utiliser une sauvegarde pré-migration
3. **Revert du code** : Retour à la version précédente via Git

### Points de Rollback

- Après Phase 1 : Aucun changement, rollback immédiat
- Après Phase 2 : Migration DB réversible (champs optionnels)
- Après Phase 3 : Basculer vers DatabaseHelper direct
- Après Phase 4 : Désactiver Supabase, utiliser SQLite uniquement

---

## 📦 Dépendances Futures

### Packages à ajouter (lors de l'implémentation)

```yaml
dependencies:
  supabase_flutter: ^2.0.0  # Client Supabase
  # Pas d'autres dépendances majeures nécessaires
```

### Configuration Supabase

```dart
// lib/config/supabase_config.dart (à créer lors de l'implémentation)
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

---

## ✅ Checklist de Préparation

### Avant de commencer l'implémentation

- [x] Documentation créée
- [ ] Interfaces Repository définies
- [ ] Champs de sync documentés dans les modèles
- [ ] Scripts de migration SQL préparés
- [ ] Plan de migration progressive validé
- [ ] Tests de non-régression définis
- [ ] Stratégie de rollback documentée

---

## 📚 Ressources

- [Documentation Supabase Flutter](https://supabase.com/docs/guides/flutter)
- [Pattern Repository](https://martinfowler.com/eaaCatalog/repository.html)
- [Offline-First Architecture](https://offlinefirst.org/)

---

**Note importante :** Ce document est une **préparation théorique**. Aucune implémentation Supabase n'est faite dans cette phase. L'objectif est de préparer l'architecture pour faciliter la migration future.

