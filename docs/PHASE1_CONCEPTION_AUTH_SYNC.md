# PHASE 1 : CONCEPTION - Authentification & Synchronisation

**Date :** 2024  
**Auteur :** Lead Flutter Engineer + Architecte Sécurité  
**Objectif :** Concevoir l'architecture complète pour l'authentification Supabase, la synchronisation des données et le système de connexion offline via PIN.

---

## 📋 TABLE DES MATIÈRES

1. [Architecture Globale](#architecture-globale)
2. [Schéma d'Authentification](#schéma-dauthentification)
3. [Schéma de Synchronisation](#schéma-de-synchronisation)
4. [Schéma PIN (Offline Auth)](#schéma-pin-offline-auth)
5. [Diagrammes de Flux](#diagrammes-de-flux)
6. [Modifications Base de Données](#modifications-base-de-données)
7. [Sécurité](#sécurité)
8. [Points d'Attention](#points-dattention)

---

## 🏗️ ARCHITECTURE GLOBALE

### Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION FLUTTER                       │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │ AuthProvider │  │ SyncProvider │  │Connectivity  │       │
│  │              │  │              │  │  Provider    │       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘       │
│         │                 │                 │               │
│  ┌──────▼─────────────────▼─────────────────▼───────┐       │
│  │           SERVICES LAYER                          │       │
│  ├───────────────────────────────────────────────────┤       │
│  │  SupabaseAuthService  │  SupabaseSyncService     │       │
│  │  LocalAuthService     │  SecureStorageService    │       │
│  └───────────────────────────────────────────────────┘       │
│                                                               │
├─────────────────────────────────────────────────────────────┤
│                    STORAGE LAYER                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐         ┌──────────────────┐         │
│  │   SQLite Local   │         │  Secure Storage   │         │
│  │  (Données App)   │         │  (PIN Hash, Token)│         │
│  └──────────────────┘         └──────────────────┘         │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTPS
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    SUPABASE CLOUD                            │
├─────────────────────────────────────────────────────────────┤
│  • Auth (Email/Password)                                     │
│  • Database (PostgreSQL)                                      │
│  • Real-time (optionnel)                                     │
└─────────────────────────────────────────────────────────────┘
```

### Principes Architecturaux

1. **OFFLINE-FIRST** : L'application fonctionne sans réseau
2. **Séparation des responsabilités** : Auth, Sync, Storage distincts
3. **Sécurité par défaut** : Aucun secret en clair
4. **Évolutivité** : Architecture extensible

---

## 🔐 SCHÉMA D'AUTHENTIFICATION

### 1. Flux d'Authentification Supabase

#### Inscription (Online uniquement)

```
┌─────────┐
│  User   │
└────┬────┘
     │
     │ 1. Email + Password
     ▼
┌─────────────────┐
│ SupabaseAuth    │
│ Service         │
└────┬────────────┘
     │
     │ 2. signUp(email, password)
     ▼
┌─────────────────┐
│   Supabase      │
│   (Cloud)       │
└────┬────────────┘
     │
     │ 3. userId (UUID)
     ▼
┌─────────────────┐
│ SecureStorage   │
│ Service         │
└────┬────────────┘
     │
     │ 4. Stocker userId + refreshToken
     ▼
┌─────────────────┐
│ LocalAuth       │
│ Service         │
└────┬────────────┘
     │
     │ 5. Créer PIN
     ▼
┌─────────────────┐
│ Hash PIN        │
│ (PBKDF2)        │
└────┬────────────┘
     │
     │ 6. Stocker hash dans SecureStorage
     ▼
┌─────────────────┐
│ Première Sync  │
└─────────────────┘
```

#### Connexion Online

```
┌─────────┐
│  User   │
└────┬────┘
     │
     │ 1. Email + Password
     ▼
┌─────────────────┐
│ SupabaseAuth    │
│ Service         │
└────┬────────────┘
     │
     │ 2. signIn(email, password)
     ▼
┌─────────────────┐
│   Supabase      │
│   (Cloud)       │
└────┬────────────┘
     │
     │ 3. Session (accessToken + refreshToken)
     ▼
┌─────────────────┐
│ SecureStorage   │
│ Service         │
└────┬────────────┘
     │
     │ 4. Stocker tokens
     │ 5. Charger userId
     ▼
┌─────────────────┐
│ Charger données │
│ locales (SQLite)│
└─────────────────┘
```

### 2. Structure de Données Auth

#### SecureStorage (Keychain/Keystore)

```dart
// Clés utilisées dans SecureStorage
class SecureStorageKeys {
  static const String userId = 'supabase_user_id';
  static const String accessToken = 'supabase_access_token';
  static const String refreshToken = 'supabase_refresh_token';
  static const String pinHash = 'local_pin_hash';
  static const String pinSalt = 'local_pin_salt';
  static const String isPinSet = 'is_pin_set';
  static const String lastSyncTimestamp = 'last_sync_timestamp';
}
```

#### Données Stockées

| Clé | Type | Description | Sécurité |
|-----|------|-------------|----------|
| `supabase_user_id` | String (UUID) | ID utilisateur Supabase | ✅ Secure Storage |
| `supabase_access_token` | String (JWT) | Token d'accès (expire) | ✅ Secure Storage |
| `supabase_refresh_token` | String | Token de rafraîchissement | ✅ Secure Storage |
| `local_pin_hash` | String | Hash PBKDF2 du PIN | ✅ Secure Storage |
| `local_pin_salt` | String | Salt pour le hash PIN | ✅ Secure Storage |
| `is_pin_set` | Boolean | Flag PIN configuré | ✅ Secure Storage |
| `last_sync_timestamp` | String (ISO8601) | Dernière sync réussie | ✅ Secure Storage |

**⚠️ INTERDICTIONS ABSOLUES :**
- ❌ Aucun mot de passe Supabase stocké localement
- ❌ Aucun PIN en clair
- ❌ Aucun token dans SharedPreferences (non sécurisé)

---

## 🔄 SCHÉMA DE SYNCHRONISATION

### 1. Champs de Synchronisation

Chaque table synchronisée doit inclure :

```sql
-- Champs de synchronisation (à ajouter à toutes les tables)
user_id TEXT NOT NULL,              -- UUID Supabase de l'utilisateur
created_at TEXT NOT NULL,           -- ISO8601 timestamp
updated_at TEXT NOT NULL,           -- ISO8601 timestamp
synced_at TEXT,                      -- ISO8601 timestamp (NULL si jamais sync)
is_dirty INTEGER NOT NULL DEFAULT 1, -- 0 = sync, 1 = à synchroniser
deleted_at TEXT,                     -- Soft delete (NULL si actif)
sync_conflict TEXT                   -- JSON des conflits (NULL si pas de conflit)
```

### 2. Tables à Synchroniser

**Priorité 1 (Essentiel) :**
- ✅ `lapins`
- ✅ `accouplements`
- ✅ `portees`
- ✅ `pesees`
- ✅ `soins`
- ✅ `recettes`
- ✅ `depenses`
- ✅ `deces`

**Priorité 2 (Important) :**
- ✅ `aliments`
- ✅ `distributions_aliment`
- ✅ `medicaments`
- ✅ `utilisations_medicament`
- ✅ `quarantaines`
- ✅ `reformes`

**Priorité 3 (Optionnel) :**
- ✅ `sevrages`
- ✅ `palpations`
- ✅ `preparations_nid`
- ✅ `protocoles_soin`

**Non synchronisées (Local uniquement) :**
- ❌ `relations` (dérivé de lapins)
- ❌ `batiments`, `clapiers`, `cages` (peut être sync plus tard)

### 3. Stratégie de Synchronisation

#### Sync UP (Local → Remote)

```
┌─────────────────┐
│  SQLite Local   │
│  (is_dirty = 1) │
└────────┬────────┘
         │
         │ 1. Récupérer tous les enregistrements avec is_dirty = 1
         ▼
┌─────────────────┐
│  SyncService    │
│  (syncUp)       │
└────────┬────────┘
         │
         │ 2. Pour chaque enregistrement :
         │    - Vérifier si existe sur Supabase (par id local)
         │    - Si existe : UPDATE
         │    - Si n'existe pas : INSERT
         │    - Si deleted_at != NULL : DELETE (soft)
         ▼
┌─────────────────┐
│   Supabase      │
│   (Cloud)       │
└────────┬────────┘
         │
         │ 3. Réponse (success/error)
         ▼
┌─────────────────┐
│  SQLite Local   │
│  (is_dirty = 0) │
│  (synced_at)    │
└─────────────────┘
```

#### Sync DOWN (Remote → Local)

```
┌─────────────────┐
│   Supabase      │
│   (Cloud)       │
└────────┬────────┘
         │
         │ 1. Récupérer tous les enregistrements modifiés depuis last_sync_timestamp
         ▼
┌─────────────────┐
│  SyncService    │
│  (syncDown)     │
└────────┬────────┘
         │
         │ 2. Pour chaque enregistrement :
         │    - Vérifier si existe localement (par id Supabase)
         │    - Si existe ET updated_at_remote > updated_at_local :
         │        → Conflit détecté
         │        → Appliquer stratégie (last update wins)
         │    - Si n'existe pas : INSERT
         │    - Si deleted_at != NULL : Soft delete local
         ▼
┌─────────────────┐
│  SQLite Local   │
│  (updated)      │
└─────────────────┘
```

#### Gestion des Conflits

**Stratégie : Last Update Wins (simple)**

```dart
if (remoteUpdatedAt > localUpdatedAt) {
  // Remote est plus récent → utiliser remote
  await updateLocal(remoteData);
} else if (localUpdatedAt > remoteUpdatedAt) {
  // Local est plus récent → marquer pour sync UP
  await markAsDirty(localData);
} else {
  // Même timestamp → pas de conflit
  // (peut arriver si sync immédiate)
}
```

**Conflits complexes (futur) :**
- Stocker les deux versions dans `sync_conflict` (JSON)
- Permettre résolution manuelle par l'utilisateur

### 4. Queue de Synchronisation

```dart
class SyncQueue {
  final List<SyncOperation> pendingOperations = [];
  
  void enqueue(SyncOperation operation) {
    pendingOperations.add(operation);
  }
  
  Future<void> processQueue() async {
    while (pendingOperations.isNotEmpty) {
      final operation = pendingOperations.removeAt(0);
      try {
        await executeOperation(operation);
      } catch (e) {
        // Réinsérer en fin de queue en cas d'erreur
        pendingOperations.add(operation);
        break; // Arrêter si erreur réseau
      }
    }
  }
}
```

---

## 🔒 SCHÉMA PIN (OFFLINE AUTH)

### 1. Création du PIN

```
┌─────────┐
│  User   │
└────┬────┘
     │
     │ 1. Saisie PIN (4-6 chiffres)
     │ 2. Confirmation PIN
     ▼
┌─────────────────┐
│ LocalAuth       │
│ Service         │
└────┬────────────┘
     │
     │ 3. Générer salt aléatoire (32 bytes)
     │ 4. Hash PIN avec PBKDF2 :
     │    hash = PBKDF2(
     │      password: PIN,
     │      salt: salt,
     │      iterations: 100000,
     │      keyLength: 32
     │    )
     ▼
┌─────────────────┐
│ SecureStorage   │
│ Service         │
└────┬────────────┘
     │
     │ 5. Stocker :
     │    - pin_hash (base64)
     │    - pin_salt (base64)
     │    - is_pin_set = true
     ▼
┌─────────────────┐
│ PIN configuré   │
└─────────────────┘
```

### 2. Validation du PIN (Offline)

```
┌─────────┐
│  User   │
└────┬────┘
     │
     │ 1. Saisie PIN
     ▼
┌─────────────────┐
│ LocalAuth       │
│ Service         │
└────┬────────────┘
     │
     │ 2. Récupérer hash + salt depuis SecureStorage
     │ 3. Hasher PIN saisi avec le même salt
     │ 4. Comparer les hashs (timing-safe)
     ▼
┌─────────────────┐
│ Hashs identiques?│
└────┬────────────┘
     │
     ├─ OUI → Déverrouiller app
     │         Charger données locales
     │
     └─ NON → Erreur
              Compteur tentatives (max 5)
              Blocage temporaire si > 5
```

### 3. Sécurité du PIN

**Algorithme :** PBKDF2 (Password-Based Key Derivation Function 2)

**Paramètres :**
- **Salt :** 32 bytes aléatoires (unique par utilisateur)
- **Iterations :** 100,000 (équilibre sécurité/performance)
- **Key Length :** 32 bytes (256 bits)
- **Hash Function :** SHA-256

**Protection contre les attaques :**
- ✅ **Brute Force :** 100k iterations ralentissent les attaques
- ✅ **Rainbow Tables :** Salt unique empêche les tables pré-calculées
- ✅ **Timing Attacks :** Comparaison timing-safe des hashs
- ✅ **Rate Limiting :** Max 5 tentatives, puis blocage 5 minutes

**Stockage :**
```dart
// Format stocké dans SecureStorage
{
  "pin_hash": "base64_encoded_hash",
  "pin_salt": "base64_encoded_salt",
  "is_pin_set": true
}
```

---

## 📊 DIAGRAMMES DE FLUX

### Flux Complet : Inscription → Première Utilisation

```
┌─────────────────────────────────────────────────────────────┐
│                    INSCRIPTION (ONLINE)                     │
└─────────────────────────────────────────────────────────────┘

1. User saisit email + password
2. SupabaseAuthService.signUp()
3. Supabase retourne userId + tokens
4. SecureStorageService.storeTokens()
5. LocalAuthService.createPin()
   ├─ User saisit PIN
   ├─ Générer salt
   ├─ Hasher PIN (PBKDF2)
   └─ SecureStorageService.storePinHash()
6. SupabaseSyncService.syncUp() (première sync)
7. App prête (données locales chargées)

┌─────────────────────────────────────────────────────────────┐
│              CONNEXION OFFLINE (PIN)                        │
└─────────────────────────────────────────────────────────────┘

1. App démarre
2. ConnectivityProvider.checkConnection() → OFFLINE
3. LocalAuthService.isPinSet() → true
4. Afficher écran PIN
5. User saisit PIN
6. LocalAuthService.validatePin()
   ├─ Récupérer hash + salt
   ├─ Hasher PIN saisi
   └─ Comparer hashs
7. PIN valide → Charger données SQLite
8. App déverrouillée

┌─────────────────────────────────────────────────────────────┐
│              CONNEXION ONLINE (Email/Password)               │
└─────────────────────────────────────────────────────────────┘

1. App démarre
2. ConnectivityProvider.checkConnection() → ONLINE
3. Afficher écran login
4. User saisit email + password
5. SupabaseAuthService.signIn()
6. Supabase retourne tokens
7. SecureStorageService.storeTokens()
8. SupabaseSyncService.syncDown() (récupérer données cloud)
9. Charger données locales
10. App prête
```

### Flux de Synchronisation Automatique

```
┌─────────────────────────────────────────────────────────────┐
│              SYNCHRONISATION AUTOMATIQUE                    │
└─────────────────────────────────────────────────────────────┘

[App en cours d'utilisation]
         │
         │ Détection réseau (ConnectivityProvider)
         ▼
    ┌─────────┐
    │ ONLINE? │
    └────┬────┘
         │
    ┌────┴────┐
    │         │
   OUI       NON
    │         │
    │         └─→ Continuer offline
    │
    ▼
[SyncProvider.autoSync()]
    │
    ├─→ 1. Sync DOWN (récupérer modifications cloud)
    │      └─→ Mettre à jour SQLite
    │
    └─→ 2. Sync UP (envoyer modifications locales)
           └─→ Marquer is_dirty = 0
```

---

## 🗄️ MODIFICATIONS BASE DE DONNÉES

### Migration SQLite (Version 11)

**Fichier :** `lib/migrations/migration_v11_sync_fields.sql`

```sql
-- Migration Version 11 : Ajout des champs de synchronisation

-- Table lapins
ALTER TABLE lapins ADD COLUMN user_id TEXT;
ALTER TABLE lapins ADD COLUMN created_at TEXT NOT NULL DEFAULT (datetime('now'));
ALTER TABLE lapins ADD COLUMN updated_at TEXT NOT NULL DEFAULT (datetime('now'));
ALTER TABLE lapins ADD COLUMN synced_at TEXT;
ALTER TABLE lapins ADD COLUMN is_dirty INTEGER NOT NULL DEFAULT 1;
ALTER TABLE lapins ADD COLUMN deleted_at TEXT;
ALTER TABLE lapins ADD COLUMN sync_conflict TEXT;

-- Table accouplements
ALTER TABLE accouplements ADD COLUMN user_id TEXT;
ALTER TABLE accouplements ADD COLUMN created_at TEXT NOT NULL DEFAULT (datetime('now'));
ALTER TABLE accouplements ADD COLUMN updated_at TEXT NOT NULL DEFAULT (datetime('now'));
ALTER TABLE accouplements ADD COLUMN synced_at TEXT;
ALTER TABLE accouplements ADD COLUMN is_dirty INTEGER NOT NULL DEFAULT 1;
ALTER TABLE accouplements ADD COLUMN deleted_at TEXT;
ALTER TABLE accouplements ADD COLUMN sync_conflict TEXT;

-- Table portees
ALTER TABLE portees ADD COLUMN user_id TEXT;
ALTER TABLE portees ADD COLUMN created_at TEXT NOT NULL DEFAULT (datetime('now'));
ALTER TABLE portees ADD COLUMN updated_at TEXT NOT NULL DEFAULT (datetime('now'));
ALTER TABLE portees ADD COLUMN synced_at TEXT;
ALTER TABLE portees ADD COLUMN is_dirty INTEGER NOT NULL DEFAULT 1;
ALTER TABLE portees ADD COLUMN deleted_at TEXT;
ALTER TABLE portees ADD COLUMN sync_conflict TEXT;

-- Table pesees
ALTER TABLE pesees ADD COLUMN user_id TEXT;
ALTER TABLE pesees ADD COLUMN created_at TEXT NOT NULL DEFAULT (datetime('now'));
ALTER TABLE pesees ADD COLUMN updated_at TEXT NOT NULL DEFAULT (datetime('now'));
ALTER TABLE pesees ADD COLUMN synced_at TEXT;
ALTER TABLE pesees ADD COLUMN is_dirty INTEGER NOT NULL DEFAULT 1;
ALTER TABLE pesees ADD COLUMN deleted_at TEXT;
ALTER TABLE pesees ADD COLUMN sync_conflict TEXT;

-- Table soins
ALTER TABLE soins ADD COLUMN user_id TEXT;
ALTER TABLE soins ADD COLUMN created_at TEXT NOT NULL DEFAULT (datetime('now'));
ALTER TABLE soins ADD COLUMN updated_at TEXT NOT NULL DEFAULT (datetime('now'));
ALTER TABLE soins ADD COLUMN synced_at TEXT;
ALTER TABLE soins ADD COLUMN is_dirty INTEGER NOT NULL DEFAULT 1;
ALTER TABLE soins ADD COLUMN deleted_at TEXT;
ALTER TABLE soins ADD COLUMN sync_conflict TEXT;

-- Table recettes
ALTER TABLE recettes ADD COLUMN user_id TEXT;
ALTER TABLE recettes ADD COLUMN created_at TEXT NOT NULL DEFAULT (datetime('now'));
ALTER TABLE recettes ADD COLUMN updated_at TEXT NOT NULL DEFAULT (datetime('now'));
ALTER TABLE recettes ADD COLUMN synced_at TEXT;
ALTER TABLE recettes ADD COLUMN is_dirty INTEGER NOT NULL DEFAULT 1;
ALTER TABLE recettes ADD COLUMN deleted_at TEXT;
ALTER TABLE recettes ADD COLUMN sync_conflict TEXT;

-- Table depenses
ALTER TABLE depenses ADD COLUMN user_id TEXT;
ALTER TABLE depenses ADD COLUMN created_at TEXT NOT NULL DEFAULT (datetime('now'));
ALTER TABLE depenses ADD COLUMN updated_at TEXT NOT NULL DEFAULT (datetime('now'));
ALTER TABLE depenses ADD COLUMN synced_at TEXT;
ALTER TABLE depenses ADD COLUMN is_dirty INTEGER NOT NULL DEFAULT 1;
ALTER TABLE depenses ADD COLUMN deleted_at TEXT;
ALTER TABLE depenses ADD COLUMN deleted_at TEXT;
ALTER TABLE depenses ADD COLUMN sync_conflict TEXT;

-- Table deces
ALTER TABLE deces ADD COLUMN user_id TEXT;
ALTER TABLE deces ADD COLUMN created_at TEXT NOT NULL DEFAULT (datetime('now'));
ALTER TABLE deces ADD COLUMN updated_at TEXT NOT NULL DEFAULT (datetime('now'));
ALTER TABLE deces ADD COLUMN synced_at TEXT;
ALTER TABLE deces ADD COLUMN is_dirty INTEGER NOT NULL DEFAULT 1;
ALTER TABLE deces ADD COLUMN deleted_at TEXT;
ALTER TABLE deces ADD COLUMN sync_conflict TEXT;

-- Index pour améliorer les performances de sync
CREATE INDEX idx_lapins_user_id ON lapins(user_id);
CREATE INDEX idx_lapins_is_dirty ON lapins(is_dirty);
CREATE INDEX idx_lapins_synced_at ON lapins(synced_at);

CREATE INDEX idx_accouplements_user_id ON accouplements(user_id);
CREATE INDEX idx_accouplements_is_dirty ON accouplements(is_dirty);

CREATE INDEX idx_portees_user_id ON portees(user_id);
CREATE INDEX idx_portees_is_dirty ON portees(is_dirty);

-- ... (index pour toutes les tables synchronisées)
```

### Schéma Supabase (PostgreSQL)

**Tables à créer dans Supabase :**

```sql
-- Exemple pour la table lapins
CREATE TABLE lapins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Champs métier (identique à SQLite)
  nom TEXT NOT NULL,
  race TEXT NOT NULL,
  sexe TEXT NOT NULL,
  date_naissance TIMESTAMPTZ NOT NULL,
  poids REAL,
  statut TEXT,
  localisation TEXT,
  photo_path TEXT,
  numero_identification TEXT,
  couleur TEXT,
  prix_achat REAL,
  origine TEXT,
  notes TEXT,
  caracteristiques TEXT,
  
  -- Champs de synchronisation
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  sync_conflict JSONB,
  
  -- Contraintes
  CONSTRAINT lapins_user_id_fkey FOREIGN KEY (user_id) 
    REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Index pour performance
CREATE INDEX idx_lapins_user_id ON lapins(user_id);
CREATE INDEX idx_lapins_updated_at ON lapins(updated_at);
CREATE INDEX idx_lapins_deleted_at ON lapins(deleted_at);

-- RLS (Row Level Security) - IMPORTANT pour sécurité
ALTER TABLE lapins ENABLE ROW LEVEL SECURITY;

-- Policy : Un utilisateur ne peut voir que ses propres données
CREATE POLICY "Users can only see their own lapins"
  ON lapins FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own lapins"
  ON lapins FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update their own lapins"
  ON lapins FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete their own lapins"
  ON lapins FOR DELETE
  USING (auth.uid() = user_id);
```

**⚠️ IMPORTANT :** Répéter pour toutes les tables synchronisées.

---

## 🔒 SÉCURITÉ

### 1. Secure Storage

**Package Flutter :** `flutter_secure_storage`

**Implémentation :**
- **Android :** Keystore (AES-256)
- **iOS :** Keychain (AES-256)
- **Linux/Windows :** LibSecret (AES-256)

**Données stockées :**
- ✅ Tokens JWT Supabase
- ✅ Hash PIN (jamais le PIN en clair)
- ✅ Salt PIN
- ✅ User ID

**Données NON stockées :**
- ❌ Mot de passe Supabase
- ❌ PIN en clair
- ❌ Clés privées

### 2. Hash PIN

**Algorithme :** PBKDF2-SHA256

**Paramètres :**
```dart
const int iterations = 100000;
const int keyLength = 32; // 256 bits
final salt = generateRandomSalt(32); // 32 bytes
final hash = pbkdf2(
  password: pin,
  salt: salt,
  iterations: iterations,
  keyLength: keyLength,
);
```

**Justification :**
- ✅ Résistant aux attaques brute force (100k iterations)
- ✅ Résistant aux rainbow tables (salt unique)
- ✅ Standard NIST recommandé
- ✅ Performance acceptable (< 100ms sur mobile)

### 3. Validation Timing-Safe

```dart
bool compareHashes(String hash1, String hash2) {
  // Utiliser une comparaison timing-safe pour éviter les attaques
  if (hash1.length != hash2.length) return false;
  
  int result = 0;
  for (int i = 0; i < hash1.length; i++) {
    result |= hash1.codeUnitAt(i) ^ hash2.codeUnitAt(i);
  }
  return result == 0;
}
```

### 4. Rate Limiting PIN

```dart
class PinAttempts {
  static const int maxAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 5);
  
  int _attempts = 0;
  DateTime? _lockedUntil;
  
  bool isLocked() {
    if (_lockedUntil == null) return false;
    return DateTime.now().isBefore(_lockedUntil!);
  }
  
  void recordFailedAttempt() {
    _attempts++;
    if (_attempts >= maxAttempts) {
      _lockedUntil = DateTime.now().add(lockoutDuration);
    }
  }
  
  void reset() {
    _attempts = 0;
    _lockedUntil = null;
  }
}
```

### 5. Row Level Security (Supabase)

**Toutes les tables Supabase doivent avoir RLS activé :**

```sql
-- Exemple de policy
CREATE POLICY "Users can only access their own data"
  ON table_name FOR ALL
  USING (auth.uid() = user_id);
```

---

## ⚠️ POINTS D'ATTENTION

### 1. Migration des Données Existantes

**Problème :** Les données existantes n'ont pas de `user_id`.

**Solution :**
1. Lors de la première connexion Supabase, récupérer le `userId`
2. Mettre à jour toutes les données locales avec ce `userId`
3. Marquer toutes les données comme `is_dirty = 1` pour première sync

```dart
Future<void> migrateExistingData(String userId) async {
  final db = await DatabaseHelper.instance.database;
  
  // Mettre à jour toutes les tables
  await db.update('lapins', {'user_id': userId}, where: 'user_id IS NULL');
  await db.update('accouplements', {'user_id': userId}, where: 'user_id IS NULL');
  // ... etc
}
```

### 2. Gestion des Conflits

**Stratégie simple (Phase 1) :** Last Update Wins

**Stratégie avancée (Phase 2) :**
- Détecter les conflits
- Stocker les deux versions
- Permettre résolution manuelle

### 3. Performance de Sync

**Optimisations :**
- Sync incrémentale (seulement les modifications depuis `last_sync_timestamp`)
- Batch les opérations (max 100 par requête)
- Index sur `user_id`, `is_dirty`, `updated_at`
- Sync en arrière-plan (ne pas bloquer l'UI)

### 4. Gestion des Erreurs

**Scénarios d'erreur :**
- ❌ Pas de réseau → Continuer offline, queue les modifications
- ❌ Token expiré → Refresh automatique
- ❌ Erreur Supabase → Logger, retry avec backoff exponentiel
- ❌ Conflit → Appliquer stratégie, notifier l'utilisateur

### 5. Tests

**Tests à prévoir :**
- ✅ Test création compte + PIN
- ✅ Test connexion offline (PIN)
- ✅ Test connexion online (email/password)
- ✅ Test sync UP (local → remote)
- ✅ Test sync DOWN (remote → local)
- ✅ Test conflits
- ✅ Test changement d'utilisateur
- ✅ Test perte de réseau pendant sync

---

## 📦 FICHIERS À CRÉER

### Services
- `lib/services/supabase_auth_service.dart`
- `lib/services/supabase_sync_service.dart`
- `lib/services/local_auth_service.dart`
- `lib/services/secure_storage_service.dart`

### Providers
- `lib/providers/auth_provider.dart`
- `lib/providers/sync_provider.dart`
- `lib/providers/connectivity_provider.dart`

### Screens
- `lib/screens/auth/login_screen.dart`
- `lib/screens/auth/signup_screen.dart`
- `lib/screens/auth/pin_screen.dart`
- `lib/screens/auth/pin_setup_screen.dart`

### Models
- `lib/models/sync_status.dart`
- `lib/models/sync_conflict.dart`

### Utils
- `lib/utils/pin_validator.dart`
- `lib/utils/pbkdf2_helper.dart`

### Config
- `lib/config/supabase_config.dart`

### Migrations
- `lib/migrations/migration_v11_sync_fields.sql`

---

## ✅ CHECKLIST PHASE 1

- [x] Architecture globale définie
- [x] Schéma d'authentification documenté
- [x] Schéma de synchronisation documenté
- [x] Schéma PIN documenté
- [x] Diagrammes de flux créés
- [x] Modifications base de données planifiées
- [x] Points de sécurité identifiés
- [x] Points d'attention documentés

---

## 🚀 PROCHAINES ÉTAPES

**PHASE 2 :** Implémentation Auth Supabase
- Créer SupabaseAuthService
- Créer AuthProvider
- Créer écrans login/signup
- Tests

**PHASE 3 :** Implémentation Login Offline (PIN)
- Créer LocalAuthService
- Créer SecureStorageService
- Créer écrans PIN
- Tests

**PHASE 4 :** Implémentation Synchronisation
- Créer SupabaseSyncService
- Créer SyncProvider
- Migration base de données
- Tests

**PHASE 5 :** Validation & Tests
- Tests end-to-end
- Tests offline
- Tests online
- Tests changement utilisateur

---

**Document créé le :** 2024  
**Version :** 1.0  
**Statut :** ✅ PRÊT POUR PHASE 2

