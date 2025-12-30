-- ============================================================
-- SCRIPT DE CRÉATION DES TABLES SUPABASE (IDEMPOTENT)
-- ============================================================
-- 
-- Ce script crée toutes les tables nécessaires dans Supabase
-- avec les champs de synchronisation et Row Level Security (RLS)
-- 
-- ✅ IDEMPOTENT : Peut être exécuté plusieurs fois sans erreur
-- 
-- ⚠️ IMPORTANT : Exécuter ce script dans l'éditeur SQL de Supabase
-- 
-- Instructions :
-- 1. Aller sur https://supabase.com/dashboard
-- 2. Sélectionner votre projet
-- 3. Aller dans SQL Editor
-- 4. Coller ce script
-- 5. Exécuter
-- 
-- ============================================================

-- ============================================================
-- TABLE : lapins
-- ============================================================

CREATE TABLE IF NOT EXISTS lapins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  
  -- Champs métier
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
  sync_conflict JSONB
);

-- Ajouter la contrainte foreign key si elle n'existe pas
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'lapins_user_id_fkey'
  ) THEN
    ALTER TABLE lapins 
    ADD CONSTRAINT lapins_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Index pour lapins
CREATE INDEX IF NOT EXISTS idx_lapins_user_id ON lapins(user_id);
CREATE INDEX IF NOT EXISTS idx_lapins_updated_at ON lapins(updated_at);
CREATE INDEX IF NOT EXISTS idx_lapins_deleted_at ON lapins(deleted_at);

-- ============================================================
-- TABLE : accouplements
-- ============================================================

CREATE TABLE IF NOT EXISTS accouplements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  
  -- Champs métier
  male_id INTEGER,
  femelle_id INTEGER,
  date_accouplement TIMESTAMPTZ NOT NULL,
  date_mise_bas_prevue TIMESTAMPTZ NOT NULL,
  statut TEXT NOT NULL,
  notes TEXT,
  
  -- Champs de synchronisation
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  sync_conflict JSONB
);

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'accouplements_user_id_fkey'
  ) THEN
    ALTER TABLE accouplements 
    ADD CONSTRAINT accouplements_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_accouplements_user_id ON accouplements(user_id);
CREATE INDEX IF NOT EXISTS idx_accouplements_updated_at ON accouplements(updated_at);
CREATE INDEX IF NOT EXISTS idx_accouplements_deleted_at ON accouplements(deleted_at);

-- ============================================================
-- TABLE : portees
-- ============================================================

CREATE TABLE IF NOT EXISTS portees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  
  -- Champs métier
  accouplement_id INTEGER,
  date_mise_bas_reelle TIMESTAMPTZ NOT NULL,
  nombre_nes INTEGER NOT NULL,
  nombre_vivants INTEGER NOT NULL,
  nombre_morts INTEGER NOT NULL,
  notes TEXT,
  
  -- Champs de synchronisation
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  sync_conflict JSONB
);

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'portees_user_id_fkey'
  ) THEN
    ALTER TABLE portees 
    ADD CONSTRAINT portees_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_portees_user_id ON portees(user_id);
CREATE INDEX IF NOT EXISTS idx_portees_updated_at ON portees(updated_at);
CREATE INDEX IF NOT EXISTS idx_portees_deleted_at ON portees(deleted_at);

-- ============================================================
-- TABLE : pesees
-- ============================================================

CREATE TABLE IF NOT EXISTS pesees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  
  -- Champs métier
  lapin_id INTEGER,
  date TIMESTAMPTZ NOT NULL,
  poids REAL NOT NULL,
  notes TEXT,
  
  -- Champs de synchronisation
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  sync_conflict JSONB
);

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'pesees_user_id_fkey'
  ) THEN
    ALTER TABLE pesees 
    ADD CONSTRAINT pesees_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_pesees_user_id ON pesees(user_id);
CREATE INDEX IF NOT EXISTS idx_pesees_updated_at ON pesees(updated_at);
CREATE INDEX IF NOT EXISTS idx_pesees_deleted_at ON pesees(deleted_at);

-- ============================================================
-- TABLE : soins
-- ============================================================

CREATE TABLE IF NOT EXISTS soins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  
  -- Champs métier
  lapin_id INTEGER,
  date TIMESTAMPTZ NOT NULL,
  type TEXT NOT NULL,
  description TEXT NOT NULL,
  medicament TEXT,
  dosage TEXT,
  date_rappel TIMESTAMPTZ,
  notes TEXT,
  
  -- Champs de synchronisation
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  sync_conflict JSONB
);

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'soins_user_id_fkey'
  ) THEN
    ALTER TABLE soins 
    ADD CONSTRAINT soins_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_soins_user_id ON soins(user_id);
CREATE INDEX IF NOT EXISTS idx_soins_updated_at ON soins(updated_at);
CREATE INDEX IF NOT EXISTS idx_soins_deleted_at ON soins(deleted_at);

-- ============================================================
-- TABLE : recettes
-- ============================================================

CREATE TABLE IF NOT EXISTS recettes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  
  -- Champs métier
  date TIMESTAMPTZ NOT NULL,
  categorie TEXT NOT NULL,
  montant REAL NOT NULL,
  description TEXT NOT NULL,
  lapin_id INTEGER,
  notes TEXT,
  
  -- Champs de synchronisation
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  sync_conflict JSONB
);

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'recettes_user_id_fkey'
  ) THEN
    ALTER TABLE recettes 
    ADD CONSTRAINT recettes_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_recettes_user_id ON recettes(user_id);
CREATE INDEX IF NOT EXISTS idx_recettes_updated_at ON recettes(updated_at);
CREATE INDEX IF NOT EXISTS idx_recettes_deleted_at ON recettes(deleted_at);

-- ============================================================
-- TABLE : depenses
-- ============================================================

CREATE TABLE IF NOT EXISTS depenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  
  -- Champs métier
  date TIMESTAMPTZ NOT NULL,
  categorie TEXT NOT NULL,
  montant REAL NOT NULL,
  description TEXT NOT NULL,
  notes TEXT,
  
  -- Champs de synchronisation
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  sync_conflict JSONB
);

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'depenses_user_id_fkey'
  ) THEN
    ALTER TABLE depenses 
    ADD CONSTRAINT depenses_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_depenses_user_id ON depenses(user_id);
CREATE INDEX IF NOT EXISTS idx_depenses_updated_at ON depenses(updated_at);
CREATE INDEX IF NOT EXISTS idx_depenses_deleted_at ON depenses(deleted_at);

-- ============================================================
-- TABLE : deces
-- ============================================================

CREATE TABLE IF NOT EXISTS deces (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  
  -- Champs métier
  lapin_id INTEGER,
  date_deces TIMESTAMPTZ NOT NULL,
  age_au_deces_jours INTEGER NOT NULL,
  cause TEXT NOT NULL,
  circonstances_detaillees TEXT NOT NULL,
  autopsie_realisee BOOLEAN NOT NULL DEFAULT false,
  resultats_autopsie TEXT,
  mesures_preventives TEXT,
  
  -- Champs de synchronisation
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  sync_conflict JSONB
);

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'deces_user_id_fkey'
  ) THEN
    ALTER TABLE deces 
    ADD CONSTRAINT deces_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_deces_user_id ON deces(user_id);
CREATE INDEX IF NOT EXISTS idx_deces_updated_at ON deces(updated_at);
CREATE INDEX IF NOT EXISTS idx_deces_deleted_at ON deces(deleted_at);

-- ============================================================
-- TABLE : aliments
-- ============================================================

CREATE TABLE IF NOT EXISTS aliments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  
  -- Champs métier
  nom TEXT NOT NULL,
  type TEXT NOT NULL,
  marque TEXT,
  fournisseur TEXT,
  conditionnement TEXT,
  quantite_achetee REAL NOT NULL,
  quantite_restante REAL NOT NULL,
  prix_unitaire REAL NOT NULL,
  prix_total REAL NOT NULL,
  date_achat TIMESTAMPTZ NOT NULL,
  date_peremption TIMESTAMPTZ,
  composition TEXT,
  lieu_stockage TEXT,
  photo_path TEXT,
  
  -- Champs de synchronisation
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  sync_conflict JSONB
);

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'aliments_user_id_fkey'
  ) THEN
    ALTER TABLE aliments 
    ADD CONSTRAINT aliments_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_aliments_user_id ON aliments(user_id);
CREATE INDEX IF NOT EXISTS idx_aliments_updated_at ON aliments(updated_at);
CREATE INDEX IF NOT EXISTS idx_aliments_deleted_at ON aliments(deleted_at);

-- ============================================================
-- TABLE : distributions_aliment
-- ============================================================

CREATE TABLE IF NOT EXISTS distributions_aliment (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  
  -- Champs métier
  aliment_id INTEGER,
  date TIMESTAMPTZ NOT NULL,
  quantite_distribuee REAL NOT NULL,
  cages_concernees TEXT,
  observations TEXT,
  
  -- Champs de synchronisation
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  sync_conflict JSONB
);

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'distributions_aliment_user_id_fkey'
  ) THEN
    ALTER TABLE distributions_aliment 
    ADD CONSTRAINT distributions_aliment_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_distributions_user_id ON distributions_aliment(user_id);
CREATE INDEX IF NOT EXISTS idx_distributions_updated_at ON distributions_aliment(updated_at);
CREATE INDEX IF NOT EXISTS idx_distributions_deleted_at ON distributions_aliment(deleted_at);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================
-- 
-- Activer RLS sur toutes les tables pour la sécurité
-- 

DO $$ 
BEGIN
  ALTER TABLE lapins ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$ 
BEGIN
  ALTER TABLE accouplements ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$ 
BEGIN
  ALTER TABLE portees ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$ 
BEGIN
  ALTER TABLE pesees ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$ 
BEGIN
  ALTER TABLE soins ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$ 
BEGIN
  ALTER TABLE recettes ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$ 
BEGIN
  ALTER TABLE depenses ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$ 
BEGIN
  ALTER TABLE deces ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$ 
BEGIN
  ALTER TABLE aliments ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$ 
BEGIN
  ALTER TABLE distributions_aliment ENABLE ROW LEVEL SECURITY;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ============================================================
-- POLICIES : lapins
-- ============================================================

DROP POLICY IF EXISTS "Users can only see their own lapins" ON lapins;
CREATE POLICY "Users can only see their own lapins"
  ON lapins FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only insert their own lapins" ON lapins;
CREATE POLICY "Users can only insert their own lapins"
  ON lapins FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only update their own lapins" ON lapins;
CREATE POLICY "Users can only update their own lapins"
  ON lapins FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only delete their own lapins" ON lapins;
CREATE POLICY "Users can only delete their own lapins"
  ON lapins FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- POLICIES : accouplements
-- ============================================================

DROP POLICY IF EXISTS "Users can only see their own accouplements" ON accouplements;
CREATE POLICY "Users can only see their own accouplements"
  ON accouplements FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only insert their own accouplements" ON accouplements;
CREATE POLICY "Users can only insert their own accouplements"
  ON accouplements FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only update their own accouplements" ON accouplements;
CREATE POLICY "Users can only update their own accouplements"
  ON accouplements FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only delete their own accouplements" ON accouplements;
CREATE POLICY "Users can only delete their own accouplements"
  ON accouplements FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- POLICIES : portees
-- ============================================================

DROP POLICY IF EXISTS "Users can only see their own portees" ON portees;
CREATE POLICY "Users can only see their own portees"
  ON portees FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only insert their own portees" ON portees;
CREATE POLICY "Users can only insert their own portees"
  ON portees FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only update their own portees" ON portees;
CREATE POLICY "Users can only update their own portees"
  ON portees FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only delete their own portees" ON portees;
CREATE POLICY "Users can only delete their own portees"
  ON portees FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- POLICIES : pesees
-- ============================================================

DROP POLICY IF EXISTS "Users can only see their own pesees" ON pesees;
CREATE POLICY "Users can only see their own pesees"
  ON pesees FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only insert their own pesees" ON pesees;
CREATE POLICY "Users can only insert their own pesees"
  ON pesees FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only update their own pesees" ON pesees;
CREATE POLICY "Users can only update their own pesees"
  ON pesees FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only delete their own pesees" ON pesees;
CREATE POLICY "Users can only delete their own pesees"
  ON pesees FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- POLICIES : soins
-- ============================================================

DROP POLICY IF EXISTS "Users can only see their own soins" ON soins;
CREATE POLICY "Users can only see their own soins"
  ON soins FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only insert their own soins" ON soins;
CREATE POLICY "Users can only insert their own soins"
  ON soins FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only update their own soins" ON soins;
CREATE POLICY "Users can only update their own soins"
  ON soins FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only delete their own soins" ON soins;
CREATE POLICY "Users can only delete their own soins"
  ON soins FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- POLICIES : recettes
-- ============================================================

DROP POLICY IF EXISTS "Users can only see their own recettes" ON recettes;
CREATE POLICY "Users can only see their own recettes"
  ON recettes FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only insert their own recettes" ON recettes;
CREATE POLICY "Users can only insert their own recettes"
  ON recettes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only update their own recettes" ON recettes;
CREATE POLICY "Users can only update their own recettes"
  ON recettes FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only delete their own recettes" ON recettes;
CREATE POLICY "Users can only delete their own recettes"
  ON recettes FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- POLICIES : depenses
-- ============================================================

DROP POLICY IF EXISTS "Users can only see their own depenses" ON depenses;
CREATE POLICY "Users can only see their own depenses"
  ON depenses FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only insert their own depenses" ON depenses;
CREATE POLICY "Users can only insert their own depenses"
  ON depenses FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only update their own depenses" ON depenses;
CREATE POLICY "Users can only update their own depenses"
  ON depenses FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only delete their own depenses" ON depenses;
CREATE POLICY "Users can only delete their own depenses"
  ON depenses FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- POLICIES : deces
-- ============================================================

DROP POLICY IF EXISTS "Users can only see their own deces" ON deces;
CREATE POLICY "Users can only see their own deces"
  ON deces FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only insert their own deces" ON deces;
CREATE POLICY "Users can only insert their own deces"
  ON deces FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only update their own deces" ON deces;
CREATE POLICY "Users can only update their own deces"
  ON deces FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only delete their own deces" ON deces;
CREATE POLICY "Users can only delete their own deces"
  ON deces FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- POLICIES : aliments
-- ============================================================

DROP POLICY IF EXISTS "Users can only see their own aliments" ON aliments;
CREATE POLICY "Users can only see their own aliments"
  ON aliments FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only insert their own aliments" ON aliments;
CREATE POLICY "Users can only insert their own aliments"
  ON aliments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only update their own aliments" ON aliments;
CREATE POLICY "Users can only update their own aliments"
  ON aliments FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only delete their own aliments" ON aliments;
CREATE POLICY "Users can only delete their own aliments"
  ON aliments FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- POLICIES : distributions_aliment
-- ============================================================

DROP POLICY IF EXISTS "Users can only see their own distributions_aliment" ON distributions_aliment;
CREATE POLICY "Users can only see their own distributions_aliment"
  ON distributions_aliment FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only insert their own distributions_aliment" ON distributions_aliment;
CREATE POLICY "Users can only insert their own distributions_aliment"
  ON distributions_aliment FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only update their own distributions_aliment" ON distributions_aliment;
CREATE POLICY "Users can only update their own distributions_aliment"
  ON distributions_aliment FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can only delete their own distributions_aliment" ON distributions_aliment;
CREATE POLICY "Users can only delete their own distributions_aliment"
  ON distributions_aliment FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- TRIGGERS : Mise à jour automatique de updated_at
-- ============================================================
-- 
-- Créer une fonction pour mettre à jour updated_at automatiquement
-- 

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Appliquer le trigger à toutes les tables (idempotent)
DROP TRIGGER IF EXISTS update_lapins_updated_at ON lapins;
CREATE TRIGGER update_lapins_updated_at BEFORE UPDATE ON lapins
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_accouplements_updated_at ON accouplements;
CREATE TRIGGER update_accouplements_updated_at BEFORE UPDATE ON accouplements
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_portees_updated_at ON portees;
CREATE TRIGGER update_portees_updated_at BEFORE UPDATE ON portees
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_pesees_updated_at ON pesees;
CREATE TRIGGER update_pesees_updated_at BEFORE UPDATE ON pesees
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_soins_updated_at ON soins;
CREATE TRIGGER update_soins_updated_at BEFORE UPDATE ON soins
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_recettes_updated_at ON recettes;
CREATE TRIGGER update_recettes_updated_at BEFORE UPDATE ON recettes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_depenses_updated_at ON depenses;
CREATE TRIGGER update_depenses_updated_at BEFORE UPDATE ON depenses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_deces_updated_at ON deces;
CREATE TRIGGER update_deces_updated_at BEFORE UPDATE ON deces
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_aliments_updated_at ON aliments;
CREATE TRIGGER update_aliments_updated_at BEFORE UPDATE ON aliments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_distributions_aliment_updated_at ON distributions_aliment;
CREATE TRIGGER update_distributions_aliment_updated_at BEFORE UPDATE ON distributions_aliment
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- FIN DU SCRIPT
-- ============================================================
-- 
-- ✅ Tables créées (idempotent)
-- ✅ Index créés (idempotent)
-- ✅ RLS activé (idempotent)
-- ✅ Policies créées (idempotent)
-- ✅ Triggers créés (idempotent)
-- 
-- Votre base de données Supabase est maintenant prête pour la synchronisation !
-- 
-- ============================================================

