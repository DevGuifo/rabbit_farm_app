# PHASE 4 : SYNCHRONISATION - RAPPORT D'IMPLÉMENTATION

**Date :** 2024  
**Statut :** ✅ TERMINÉE  
**Auteur :** Lead Flutter Engineer + Architecte Sécurité

---

## 📋 RÉSUMÉ

La PHASE 4 : SYNCHRONISATION a été implémentée avec succès. L'application peut maintenant synchroniser les données entre SQLite local et Supabase cloud de manière bidirectionnelle.

---

## ✅ FICHIERS CRÉÉS/MODIFIÉS

### 1. Nouveaux Services

#### `lib/services/supabase_sync_service.dart`
- Service de synchronisation avec Supabase
- Méthodes : `syncAll()`, `syncUp()`, `syncDown()`
- Gestion des conflits (Last Update Wins)
- Préparation des données (local ↔ Supabase)

### 2. Nouveaux Providers

#### `lib/providers/sync_provider.dart`
- Provider de synchronisation
- États : `idle`, `syncing`, `success`, `error`
- Méthodes : `syncNow()`, `autoSync()`
- Comptage des changements en attente

### 3. Fichiers Modifiés

#### `lib/services/database_helper.dart`
- Migration vers version 11
- Ajout des champs de synchronisation :
  - `user_id` (TEXT)
  - `created_at` (TEXT NOT NULL)
  - `updated_at` (TEXT NOT NULL)
  - `synced_at` (TEXT)
  - `is_dirty` (INTEGER NOT NULL DEFAULT 1)
  - `deleted_at` (TEXT)
  - `sync_conflict` (TEXT)
- Index pour optimiser les requêtes de sync

---

## 🔄 FONCTIONNALITÉS IMPLÉMENTÉES

### 1. Sync UP (Local → Remote)

- Envoie tous les enregistrements avec `is_dirty = 1`
- Gère les INSERT et UPDATE
- Gère les suppressions (soft delete)
- Marque les enregistrements comme synchronisés (`is_dirty = 0`)

### 2. Sync DOWN (Remote → Local)

- Récupère les enregistrements modifiés depuis `last_sync_timestamp`
- Détecte les conflits (Last Update Wins)
- Insère les nouveaux enregistrements
- Met à jour les enregistrements existants

### 3. Gestion des Conflits

- **Stratégie :** Last Update Wins
- Si `updated_at_local > updated_at_remote` → marquer pour sync UP
- Si `updated_at_remote > updated_at_local` → UPDATE local

### 4. Tables Synchronisées

**Priorité 1 (implémentées) :**
- ✅ `lapins`
- ✅ `accouplements`
- ✅ `portees`
- ✅ `pesees`
- ✅ `soins`
- ✅ `recettes`
- ✅ `depenses`
- ✅ `deces`
- ✅ `aliments`
- ✅ `distributions_aliment`

---

## 🗄️ MIGRATION BASE DE DONNÉES

### Version 11

**Champs ajoutés à chaque table :**
```sql
user_id TEXT                    -- UUID Supabase de l'utilisateur
created_at TEXT NOT NULL        -- Date de création (ISO8601)
updated_at TEXT NOT NULL        -- Date de dernière modification (ISO8601)
synced_at TEXT                  -- Date de dernière sync (ISO8601, NULL si jamais sync)
is_dirty INTEGER NOT NULL DEFAULT 1  -- 0 = sync, 1 = à synchroniser
deleted_at TEXT                 -- Soft delete (ISO8601, NULL si actif)
sync_conflict TEXT              -- JSON des conflits (NULL si pas de conflit)
```

**Index créés :**
- `idx_{table}_user_id` : Pour filtrer par utilisateur
- `idx_{table}_is_dirty` : Pour trouver les changements en attente
- `idx_{table}_updated_at` : Pour la sync incrémentale

**Initialisation des données existantes :**
- `created_at` et `updated_at` initialisés à `datetime('now')`
- `is_dirty` initialisé à `0` (déjà synchronisé)

---

## 🔄 FLUX DE SYNCHRONISATION

### 1. Synchronisation Manuelle

```
User → SyncProvider.syncNow()
  ↓
Vérification authentification
  ↓
SupabaseSyncService.syncAll()
  ├─→ syncDown() (récupérer modifications cloud)
  │   └─→ Pour chaque table :
  │       ├─→ Récupérer enregistrements modifiés
  │       ├─→ Détecter conflits
  │       └─→ Mettre à jour local
  │
  └─→ syncUp() (envoyer modifications locales)
      └─→ Pour chaque table :
          ├─→ Récupérer enregistrements avec is_dirty = 1
          ├─→ INSERT ou UPDATE sur Supabase
          └─→ Marquer is_dirty = 0
  ↓
Mettre à jour last_sync_timestamp
  ↓
Compter changements en attente
```

### 2. Synchronisation Automatique

```
ConnectivityProvider détecte réseau
  ↓
SyncProvider.autoSync()
  ↓
Vérifications :
  ├─→ Utilisateur authentifié ?
  ├─→ Connectivité disponible ?
  ├─→ Sync déjà en cours ?
  └─→ Changements en attente ?
  ↓
Si toutes conditions OK → syncNow()
```

---

## ⚠️ LIMITATIONS ACTUELLES

### 1. Mapping ID Local ↔ ID Supabase

- **Problème :** Les IDs locaux (INTEGER) et Supabase (UUID) sont différents
- **Solution actuelle :** Recherche par `user_id` et comparaison des données
- **Solution future :** Créer une table de mapping `local_id ↔ supabase_id`

### 2. Gestion des Conflits

- **Stratégie actuelle :** Last Update Wins (simple)
- **Limitation :** Pas de résolution manuelle des conflits
- **Solution future :** Stocker les conflits dans `sync_conflict` et permettre résolution manuelle

### 3. Tables Non Synchronisées

- `relations` (dérivé de lapins)
- `batiments`, `clapiers`, `cages` (peut être ajouté plus tard)
- Tables de version 7-8 (médicaments, quarantaines, etc.)

---

## 🧪 TESTS À EFFECTUER

### Tests Manuels

- [ ] **Sync UP**
  - [ ] Créer un lapin localement
  - [ ] Vérifier que `is_dirty = 1`
  - [ ] Lancer sync UP
  - [ ] Vérifier que le lapin apparaît sur Supabase
  - [ ] Vérifier que `is_dirty = 0` après sync

- [ ] **Sync DOWN**
  - [ ] Créer un lapin sur Supabase (via dashboard)
  - [ ] Lancer sync DOWN
  - [ ] Vérifier que le lapin apparaît localement

- [ ] **Conflits**
  - [ ] Modifier un lapin localement
  - [ ] Modifier le même lapin sur Supabase
  - [ ] Lancer sync
  - [ ] Vérifier que la version la plus récente gagne

- [ ] **Suppressions**
  - [ ] Supprimer un lapin localement (soft delete)
  - [ ] Lancer sync UP
  - [ ] Vérifier que `deleted_at` est défini sur Supabase

- [ ] **Synchronisation Automatique**
  - [ ] Créer des modifications locales
  - [ ] Activer le réseau
  - [ ] Vérifier que la sync se lance automatiquement

---

## 🚀 PROCHAINES ÉTAPES

### Améliorations Futures

1. **Table de Mapping ID**
   - Créer `sync_mapping` (local_id, supabase_id, table_name)
   - Améliorer la recherche d'enregistrements

2. **Résolution Manuelle des Conflits**
   - Stocker les deux versions dans `sync_conflict`
   - Interface utilisateur pour choisir la version

3. **Sync Incrémentale Optimisée**
   - Utiliser `synced_at` pour ne récupérer que les modifications récentes
   - Batch les opérations (max 100 par requête)

4. **Synchronisation des Autres Tables**
   - Médicaments, quarantaines, réformes, etc.
   - Tables de localisation (batiments, clapiers, cages)

5. **Queue de Synchronisation**
   - Stocker les opérations en attente
   - Retry automatique en cas d'erreur

---

## ✅ CHECKLIST PHASE 4

- [x] SupabaseSyncService créé
- [x] SyncProvider créé
- [x] Migration base de données (version 11)
- [x] Champs de synchronisation ajoutés
- [x] Index créés
- [x] Sync UP implémentée
- [x] Sync DOWN implémentée
- [x] Gestion des conflits (Last Update Wins)
- [x] Gestion des suppressions (soft delete)
- [x] Documentation créée

---

## 📚 RESSOURCES

- [Documentation Supabase Flutter](https://supabase.com/docs/guides/flutter)
- [PostgREST API](https://postgrest.org/en/stable/api.html)
- [Offline-First Architecture](https://offlinefirst.org/)

---

**Document créé le :** 2024  
**Version :** 1.0  
**Statut :** ✅ PHASE 4 TERMINÉE - PRÊT POUR PHASE 5

