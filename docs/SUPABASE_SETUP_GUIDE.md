# Guide de Configuration Supabase

**Date :** 2024  
**Auteur :** Lead Flutter Engineer

---

## 📋 Vue d'Ensemble

Ce guide vous explique comment configurer Supabase pour l'application BunnyManager, étape par étape.

---

## 🚀 ÉTAPE 1 : Créer un Projet Supabase

1. Aller sur https://supabase.com
2. Créer un compte (si nécessaire)
3. Cliquer sur **"New Project"**
4. Remplir les informations :
   - **Name :** `rabbit-farm-app` (ou votre nom)
   - **Database Password :** Choisir un mot de passe fort
   - **Region :** Choisir la région la plus proche
5. Cliquer sur **"Create new project"**
6. Attendre la création (2-3 minutes)

---

## 🔧 ÉTAPE 2 : Récupérer les Clés API

1. Dans le dashboard Supabase, aller dans **Settings > API**
2. Copier les valeurs suivantes :
   - **Project URL** : `https://xxxxx.supabase.co`
   - **anon public key** : `sb_publishable_xxxxx`

3. Mettre à jour `lib/config/supabase_config.dart` :
   ```dart
   static const String url = 'https://xxxxx.supabase.co';
   static const String anonKey = 'sb_publishable_xxxxx';
   ```

---

## 🗄️ ÉTAPE 3 : Créer les Tables

1. Dans le dashboard Supabase, aller dans **SQL Editor**
2. Cliquer sur **"New query"**
3. Ouvrir le fichier `lib/migrations/supabase_create_tables.sql`
4. Copier tout le contenu
5. Coller dans l'éditeur SQL
6. Cliquer sur **"Run"** (ou `Ctrl+Enter`)
7. Vérifier qu'il n'y a pas d'erreurs

**✅ Résultat attendu :**
- 10 tables créées
- Index créés
- RLS activé
- Policies créées
- Triggers créés

---

## 🔒 ÉTAPE 4 : Vérifier Row Level Security (RLS)

1. Aller dans **Table Editor**
2. Vérifier que toutes les tables sont listées
3. Pour chaque table, vérifier que **RLS** est activé (icône de cadenas)

**Tables à vérifier :**
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

## 🧪 ÉTAPE 5 : Tester la Configuration

### Test 1 : Vérifier les Tables

1. Aller dans **Table Editor**
2. Sélectionner la table `lapins`
3. Vérifier que les colonnes suivantes existent :
   - `id` (UUID)
   - `user_id` (UUID)
   - `nom` (TEXT)
   - `race` (TEXT)
   - `sexe` (TEXT)
   - `date_naissance` (TIMESTAMPTZ)
   - `created_at` (TIMESTAMPTZ)
   - `updated_at` (TIMESTAMPTZ)
   - `synced_at` (TIMESTAMPTZ)
   - `deleted_at` (TIMESTAMPTZ)
   - `sync_conflict` (JSONB)

### Test 2 : Vérifier RLS

1. Créer un utilisateur de test dans **Authentication > Users**
2. Se connecter avec cet utilisateur dans l'application
3. Essayer d'insérer un lapin
4. Vérifier que le lapin apparaît dans Supabase avec le bon `user_id`

### Test 3 : Vérifier les Policies

1. Dans **SQL Editor**, exécuter :
   ```sql
   SELECT * FROM lapins;
   ```
2. Vous devriez voir uniquement les lapins de l'utilisateur connecté
3. Si vous voyez tous les lapins, les policies ne fonctionnent pas correctement

---

## ⚠️ DÉPANNAGE

### Erreur : "relation does not exist"

**Cause :** Les tables n'ont pas été créées.

**Solution :**
1. Vérifier que le script SQL a été exécuté complètement
2. Vérifier dans **Table Editor** que les tables existent
3. Ré-exécuter le script si nécessaire

### Erreur : "permission denied"

**Cause :** RLS bloque l'accès.

**Solution :**
1. Vérifier que RLS est activé sur la table
2. Vérifier que les policies existent
3. Vérifier que l'utilisateur est authentifié

### Erreur : "foreign key constraint"

**Cause :** Référence à un utilisateur inexistant.

**Solution :**
1. Vérifier que `user_id` correspond à un utilisateur dans `auth.users`
2. Vérifier que l'utilisateur est bien authentifié

### Erreur : "column does not exist"

**Cause :** Colonne manquante dans la table.

**Solution :**
1. Vérifier que toutes les colonnes sont créées
2. Comparer avec le schéma SQLite
3. Ajouter les colonnes manquantes manuellement si nécessaire

---

## 📊 STRUCTURE DES TABLES

### Schéma Général

Chaque table synchronisée contient :

1. **Identifiants**
   - `id` : UUID (généré par Supabase)
   - `user_id` : UUID (référence à `auth.users`)

2. **Champs Métier**
   - Colonnes spécifiques à chaque table
   - Types : TEXT, INTEGER, REAL, TIMESTAMPTZ, BOOLEAN

3. **Champs de Synchronisation**
   - `created_at` : Date de création
   - `updated_at` : Date de dernière modification
   - `synced_at` : Date de dernière synchronisation
   - `deleted_at` : Soft delete (NULL si actif)
   - `sync_conflict` : JSON pour résolution de conflits

---

## 🔐 SÉCURITÉ

### Row Level Security (RLS)

- ✅ Activé sur toutes les tables
- ✅ Policies pour SELECT, INSERT, UPDATE, DELETE
- ✅ Chaque utilisateur ne voit que ses propres données

### Policies

Chaque table a 4 policies :
1. **SELECT** : `auth.uid() = user_id`
2. **INSERT** : `auth.uid() = user_id`
3. **UPDATE** : `auth.uid() = user_id`
4. **DELETE** : `auth.uid() = user_id`

### Clés API

- ✅ **anon key** : Publique, utilisée côté client
- ✅ **service_role key** : Secrète, jamais utilisée côté client
- ⚠️ Ne jamais commiter les clés dans le repository

---

## 📝 NOTES IMPORTANTES

### Mapping ID Local ↔ Supabase

- **SQLite** : IDs locaux (INTEGER)
- **Supabase** : IDs UUID
- **Solution actuelle** : Recherche par `user_id` et comparaison des données
- **Solution future** : Table de mapping `sync_mapping`

### Références Entre Tables

- Les références (ex: `lapin_id`, `accouplement_id`) sont des INTEGER locaux
- Elles seront mappées via la table de mapping (à implémenter)
- Pour l'instant, elles sont stockées mais non utilisées dans les requêtes Supabase

### Triggers

- Le trigger `update_updated_at_column()` met à jour automatiquement `updated_at`
- Fonctionne sur toutes les tables synchronisées
- Garantit que `updated_at` est toujours à jour

---

## ✅ CHECKLIST DE CONFIGURATION

- [ ] Projet Supabase créé
- [ ] Clés API récupérées
- [ ] Configuration mise à jour dans `supabase_config.dart`
- [ ] Script SQL exécuté avec succès
- [ ] Tables créées (10 tables)
- [ ] Index créés
- [ ] RLS activé sur toutes les tables
- [ ] Policies créées (40 policies au total)
- [ ] Triggers créés (10 triggers)
- [ ] Test d'insertion réussi
- [ ] Test de sélection réussi (avec RLS)

---

## 🚀 PROCHAINES ÉTAPES

Une fois Supabase configuré :

1. **Tester l'authentification**
   - Créer un compte dans l'application
   - Vérifier qu'il apparaît dans Supabase

2. **Tester la synchronisation**
   - Créer des données localement
   - Lancer sync UP
   - Vérifier sur Supabase

3. **Tester la récupération**
   - Modifier des données sur Supabase
   - Lancer sync DOWN
   - Vérifier localement

---

**Document créé le :** 2024  
**Version :** 1.0  
**Statut :** ✅ PRÊT POUR UTILISATION

