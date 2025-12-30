-- ============================================================
-- MIGRATION : Ajout des champs de synchronisation Supabase
-- ============================================================
-- 
-- ⚠️ ATTENTION : Ce script n'est PAS exécuté automatiquement
-- Il doit être exécuté manuellement lors de la migration vers Supabase
-- 
-- Version DB cible : 11 (à incrémenter depuis la version actuelle)
-- 
-- Ce script ajoute les champs nécessaires pour la synchronisation :
-- - user_id : ID de l'utilisateur (UUID Supabase)
-- - created_at : Date de création
-- - updated_at : Date de dernière modification
-- - synced_at : Date de dernière synchronisation
-- - is_dirty : Flag modifications non synchronisées
-- - is_deleted : Soft delete
-- - sync_conflict : JSON pour résolution de conflits
-- 
-- ============================================================

-- Table : lapins
ALTER TABLE lapins ADD COLUMN user_id TEXT;
ALTER TABLE lapins ADD COLUMN created_at TEXT;
ALTER TABLE lapins ADD COLUMN updated_at TEXT;
ALTER TABLE lapins ADD COLUMN synced_at TEXT;
ALTER TABLE lapins ADD COLUMN is_dirty INTEGER DEFAULT 0;
ALTER TABLE lapins ADD COLUMN is_deleted INTEGER DEFAULT 0;
ALTER TABLE lapins ADD COLUMN sync_conflict TEXT;

-- Table : accouplements
ALTER TABLE accouplements ADD COLUMN user_id TEXT;
ALTER TABLE accouplements ADD COLUMN created_at TEXT;
ALTER TABLE accouplements ADD COLUMN updated_at TEXT;
ALTER TABLE accouplements ADD COLUMN synced_at TEXT;
ALTER TABLE accouplements ADD COLUMN is_dirty INTEGER DEFAULT 0;
ALTER TABLE accouplements ADD COLUMN is_deleted INTEGER DEFAULT 0;
ALTER TABLE accouplements ADD COLUMN sync_conflict TEXT;

-- Table : portees
ALTER TABLE portees ADD COLUMN user_id TEXT;
ALTER TABLE portees ADD COLUMN created_at TEXT;
ALTER TABLE portees ADD COLUMN updated_at TEXT;
ALTER TABLE portees ADD COLUMN synced_at TEXT;
ALTER TABLE portees ADD COLUMN is_dirty INTEGER DEFAULT 0;
ALTER TABLE portees ADD COLUMN is_deleted INTEGER DEFAULT 0;
ALTER TABLE portees ADD COLUMN sync_conflict TEXT;

-- Table : pesees
ALTER TABLE pesees ADD COLUMN user_id TEXT;
ALTER TABLE pesees ADD COLUMN created_at TEXT;
ALTER TABLE pesees ADD COLUMN updated_at TEXT;
ALTER TABLE pesees ADD COLUMN synced_at TEXT;
ALTER TABLE pesees ADD COLUMN is_dirty INTEGER DEFAULT 0;
ALTER TABLE pesees ADD COLUMN is_deleted INTEGER DEFAULT 0;
ALTER TABLE pesees ADD COLUMN sync_conflict TEXT;

-- Table : soins
ALTER TABLE soins ADD COLUMN user_id TEXT;
ALTER TABLE soins ADD COLUMN created_at TEXT;
ALTER TABLE soins ADD COLUMN updated_at TEXT;
ALTER TABLE soins ADD COLUMN synced_at TEXT;
ALTER TABLE soins ADD COLUMN is_dirty INTEGER DEFAULT 0;
ALTER TABLE soins ADD COLUMN is_deleted INTEGER DEFAULT 0;
ALTER TABLE soins ADD COLUMN sync_conflict TEXT;

-- Table : recettes
ALTER TABLE recettes ADD COLUMN user_id TEXT;
ALTER TABLE recettes ADD COLUMN created_at TEXT;
ALTER TABLE recettes ADD COLUMN updated_at TEXT;
ALTER TABLE recettes ADD COLUMN synced_at TEXT;
ALTER TABLE recettes ADD COLUMN is_dirty INTEGER DEFAULT 0;
ALTER TABLE recettes ADD COLUMN is_deleted INTEGER DEFAULT 0;
ALTER TABLE recettes ADD COLUMN sync_conflict TEXT;

-- Table : depenses
ALTER TABLE depenses ADD COLUMN user_id TEXT;
ALTER TABLE depenses ADD COLUMN created_at TEXT;
ALTER TABLE depenses ADD COLUMN updated_at TEXT;
ALTER TABLE depenses ADD COLUMN synced_at TEXT;
ALTER TABLE depenses ADD COLUMN is_dirty INTEGER DEFAULT 0;
ALTER TABLE depenses ADD COLUMN is_deleted INTEGER DEFAULT 0;
ALTER TABLE depenses ADD COLUMN sync_conflict TEXT;

-- Table : deces
ALTER TABLE deces ADD COLUMN user_id TEXT;
ALTER TABLE deces ADD COLUMN created_at TEXT;
ALTER TABLE deces ADD COLUMN updated_at TEXT;
ALTER TABLE deces ADD COLUMN synced_at TEXT;
ALTER TABLE deces ADD COLUMN is_dirty INTEGER DEFAULT 0;
ALTER TABLE deces ADD COLUMN is_deleted INTEGER DEFAULT 0;
ALTER TABLE deces ADD COLUMN sync_conflict TEXT;

-- Table : aliments
ALTER TABLE aliments ADD COLUMN user_id TEXT;
ALTER TABLE aliments ADD COLUMN created_at TEXT;
ALTER TABLE aliments ADD COLUMN updated_at TEXT;
ALTER TABLE aliments ADD COLUMN synced_at TEXT;
ALTER TABLE aliments ADD COLUMN is_dirty INTEGER DEFAULT 0;
ALTER TABLE aliments ADD COLUMN is_deleted INTEGER DEFAULT 0;
ALTER TABLE aliments ADD COLUMN sync_conflict TEXT;

-- Table : distributions_aliment
ALTER TABLE distributions_aliment ADD COLUMN user_id TEXT;
ALTER TABLE distributions_aliment ADD COLUMN created_at TEXT;
ALTER TABLE distributions_aliment ADD COLUMN updated_at TEXT;
ALTER TABLE distributions_aliment ADD COLUMN synced_at TEXT;
ALTER TABLE distributions_aliment ADD COLUMN is_dirty INTEGER DEFAULT 0;
ALTER TABLE distributions_aliment ADD COLUMN is_deleted INTEGER DEFAULT 0;
ALTER TABLE distributions_aliment ADD COLUMN sync_conflict TEXT;

-- ============================================================
-- INITIALISATION DES DONNÉES EXISTANTES
-- ============================================================
-- Initialiser les champs pour les données existantes
-- avec la date actuelle et les flags à 0

UPDATE lapins SET 
  created_at = datetime('now'),
  updated_at = datetime('now'),
  is_dirty = 0,
  is_deleted = 0
WHERE created_at IS NULL;

UPDATE accouplements SET 
  created_at = datetime('now'),
  updated_at = datetime('now'),
  is_dirty = 0,
  is_deleted = 0
WHERE created_at IS NULL;

UPDATE portees SET 
  created_at = datetime('now'),
  updated_at = datetime('now'),
  is_dirty = 0,
  is_deleted = 0
WHERE created_at IS NULL;

UPDATE pesees SET 
  created_at = datetime('now'),
  updated_at = datetime('now'),
  is_dirty = 0,
  is_deleted = 0
WHERE created_at IS NULL;

UPDATE soins SET 
  created_at = datetime('now'),
  updated_at = datetime('now'),
  is_dirty = 0,
  is_deleted = 0
WHERE created_at IS NULL;

UPDATE recettes SET 
  created_at = datetime('now'),
  updated_at = datetime('now'),
  is_dirty = 0,
  is_deleted = 0
WHERE created_at IS NULL;

UPDATE depenses SET 
  created_at = datetime('now'),
  updated_at = datetime('now'),
  is_dirty = 0,
  is_deleted = 0
WHERE created_at IS NULL;

UPDATE deces SET 
  created_at = datetime('now'),
  updated_at = datetime('now'),
  is_dirty = 0,
  is_deleted = 0
WHERE created_at IS NULL;

UPDATE aliments SET 
  created_at = datetime('now'),
  updated_at = datetime('now'),
  is_dirty = 0,
  is_deleted = 0
WHERE created_at IS NULL;

UPDATE distributions_aliment SET 
  created_at = datetime('now'),
  updated_at = datetime('now'),
  is_dirty = 0,
  is_deleted = 0
WHERE created_at IS NULL;

-- ============================================================
-- INDEX POUR OPTIMISER LES REQUÊTES DE SYNCHRONISATION
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_lapins_user_id ON lapins(user_id);
CREATE INDEX IF NOT EXISTS idx_lapins_is_dirty ON lapins(is_dirty);
CREATE INDEX IF NOT EXISTS idx_lapins_updated_at ON lapins(updated_at);

CREATE INDEX IF NOT EXISTS idx_accouplements_user_id ON accouplements(user_id);
CREATE INDEX IF NOT EXISTS idx_accouplements_is_dirty ON accouplements(is_dirty);
CREATE INDEX IF NOT EXISTS idx_accouplements_updated_at ON accouplements(updated_at);

CREATE INDEX IF NOT EXISTS idx_portees_user_id ON portees(user_id);
CREATE INDEX IF NOT EXISTS idx_portees_is_dirty ON portees(is_dirty);

CREATE INDEX IF NOT EXISTS idx_pesees_user_id ON pesees(user_id);
CREATE INDEX IF NOT EXISTS idx_pesees_is_dirty ON pesees(is_dirty);

CREATE INDEX IF NOT EXISTS idx_soins_user_id ON soins(user_id);
CREATE INDEX IF NOT EXISTS idx_soins_is_dirty ON soins(is_dirty);

CREATE INDEX IF NOT EXISTS idx_recettes_user_id ON recettes(user_id);
CREATE INDEX IF NOT EXISTS idx_recettes_is_dirty ON recettes(is_dirty);

CREATE INDEX IF NOT EXISTS idx_depenses_user_id ON depenses(user_id);
CREATE INDEX IF NOT EXISTS idx_depenses_is_dirty ON depenses(is_dirty);

CREATE INDEX IF NOT EXISTS idx_deces_user_id ON deces(user_id);
CREATE INDEX IF NOT EXISTS idx_deces_is_dirty ON deces(is_dirty);

CREATE INDEX IF NOT EXISTS idx_aliments_user_id ON aliments(user_id);
CREATE INDEX IF NOT EXISTS idx_aliments_is_dirty ON aliments(is_dirty);

CREATE INDEX IF NOT EXISTS idx_distributions_user_id ON distributions_aliment(user_id);
CREATE INDEX IF NOT EXISTS idx_distributions_is_dirty ON distributions_aliment(is_dirty);

-- ============================================================
-- FIN DE LA MIGRATION
-- ============================================================
-- 
-- Après exécution de ce script :
-- 1. Mettre à jour la version de la DB dans database_helper.dart
-- 2. Décommenter les champs de sync dans les modèles Dart
-- 3. Mettre à jour toMap() et fromMap() dans les modèles
-- 4. Tester que l'application fonctionne toujours correctement
-- 
-- ============================================================

