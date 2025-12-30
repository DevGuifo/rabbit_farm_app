# Plan de Migration Progressive vers Supabase

## 📋 Vue d'ensemble

Ce document détaille le plan de migration progressive de l'application BunnyManager vers Supabase, module par module, avec des points de validation et de rollback à chaque étape.

---

## 🎯 Principes de Migration

1. **Aucune régression** : Chaque phase doit maintenir toutes les fonctionnalités existantes
2. **Migration progressive** : Un module à la fois pour minimiser les risques
3. **Tests continus** : Validation après chaque étape
4. **Rollback possible** : Possibilité de revenir en arrière à tout moment
5. **Offline-first maintenu** : L'application fonctionne toujours sans connexion

---

## 📅 Phases de Migration

### Phase 1 : Préparation ✅ (TERMINÉE)

**Objectif :** Préparer l'architecture sans modifier le code existant

**Tâches :**
- ✅ Documentation de la stratégie (MIGRATION_SUPABASE.md)
- ✅ Création des interfaces Repository
- ✅ Documentation des champs de sync dans les modèles
- ✅ Script de migration SQL préparé
- ✅ Squelette SyncService créé

**Validation :**
- [x] Documentation complète
- [x] Interfaces Repository définies
- [x] Scripts SQL prêts

**Durée :** 1 semaine ✅

---

### Phase 2 : Migration Base de Données

**Objectif :** Ajouter les champs de synchronisation à la base de données

**Tâches :**
1. Exécuter le script `migration_sync_fields.sql`
2. Incrémenter la version de la DB dans `database_helper.dart` (version 11)
3. Mettre à jour `_upgradeDB()` pour gérer la migration
4. Tester que les données existantes sont préservées

**Validation :**
- [ ] Migration SQL exécutée avec succès
- [ ] Toutes les tables ont les nouveaux champs
- [ ] Les données existantes sont initialisées correctement
- [ ] L'application fonctionne normalement après migration

**Rollback :**
- Restaurer une sauvegarde pré-migration
- Revenir à la version DB précédente

**Durée estimée :** 2-3 jours

---

### Phase 3 : Implémentation Repository SQLite

**Objectif :** Migrer DatabaseHelper vers le pattern Repository (SQLite uniquement)

**Tâches :**
1. Créer `SQLiteLapinRepository` (déjà créé, à compléter)
2. Créer `SQLiteAccouplementRepository`
3. Créer `SQLiteSanteRepository`
4. Créer `SQLiteFinanceRepository`
5. Migrer les Providers pour utiliser les repositories
6. Tester que tout fonctionne comme avant

**Ordre de migration des modules :**
1. **Lapins** (module de base, utilisé partout)
2. **Accouplements** (dépend de Lapins)
3. **Santé** (pesées, soins)
4. **Finances** (recettes, dépenses)
5. **Alimentation** (aliments, distributions)
6. **Autres modules**

**Validation :**
- [ ] Tous les CRUD fonctionnent
- [ ] Les Providers fonctionnent sans modification visible
- [ ] Les écrans s'affichent correctement
- [ ] Tests de non-régression passent

**Rollback :**
- Revenir à l'utilisation directe de DatabaseHelper
- Les repositories peuvent coexister avec DatabaseHelper

**Durée estimée :** 1 semaine

---

### Phase 4 : Implémentation Supabase (Parallèle)

**Objectif :** Créer les implémentations Supabase des repositories

**Prérequis :**
- Compte Supabase créé
- Projet Supabase configuré
- Tables créées dans Supabase (même schéma que SQLite)

**Tâches :**
1. Ajouter dépendance `supabase_flutter`
2. Configurer Supabase (URL, anon key)
3. Créer `SupabaseLapinRepository`
4. Créer `SupabaseAccouplementRepository`
5. Créer `SupabaseSanteRepository`
6. Créer `SupabaseFinanceRepository`
7. Implémenter SyncService
8. Tests unitaires pour Supabase

**Validation :**
- [ ] Connexion Supabase fonctionne
- [ ] CRUD Supabase fonctionne
- [ ] SyncService fonctionne
- [ ] Tests unitaires passent

**Durée estimée :** 1-2 semaines

---

### Phase 5 : Migration Module par Module

**Objectif :** Basculer progressivement chaque module vers Supabase

#### Module 1 : Lapins (Test)

**Tâches :**
1. Créer un flag de configuration pour activer Supabase
2. Basculer `LapinProvider` vers `SupabaseLapinRepository`
3. Tester en mode offline (doit fonctionner avec SQLite)
4. Tester en mode online (doit synchroniser)
5. Valider avec données réelles

**Validation :**
- [ ] Fonctionne en offline
- [ ] Synchronise en online
- [ ] Pas de perte de données
- [ ] Performance acceptable

**Rollback :**
- Désactiver le flag de configuration
- Revenir à SQLiteLapinRepository

**Durée estimée :** 3-5 jours

#### Module 2 : Accouplements

**Tâches :**
1. Basculer `ReproductionProvider` vers `SupabaseAccouplementRepository`
2. Tester synchronisation
3. Valider avec données réelles

**Validation :** Même que Module 1

**Durée estimée :** 2-3 jours

#### Module 3 : Santé (Pesées, Soins)

**Tâches :**
1. Basculer `SanteProvider` vers `SupabaseSanteRepository`
2. Tester synchronisation
3. Valider avec données réelles

**Durée estimée :** 2-3 jours

#### Module 4 : Finances

**Tâches :**
1. Basculer `FinanceProvider` vers `SupabaseFinanceRepository`
2. Tester synchronisation
3. Valider avec données réelles

**Durée estimée :** 2-3 jours

#### Module 5 : Alimentation

**Tâches :**
1. Créer repositories pour Alimentation
2. Basculer `AlimentationProvider`
3. Tester synchronisation

**Durée estimée :** 2-3 jours

#### Module 6 : Autres modules

**Tâches :**
1. Migrer les modules restants
2. Tests finaux

**Durée estimée :** 1 semaine

**Total Phase 5 :** 2-3 semaines

---

### Phase 6 : Activation Complète

**Objectif :** Activer la synchronisation pour tous les modules

**Tâches :**
1. Activer sync pour tous les modules
2. Tests d'intégration complets
3. Tests de performance
4. Tests de résolution de conflits
5. Documentation utilisateur
6. Déploiement progressif (beta testers)

**Validation :**
- [ ] Tous les modules synchronisent
- [ ] Pas de perte de données
- [ ] Performance acceptable
- [ ] Gestion des erreurs robuste
- [ ] Documentation complète

**Durée estimée :** 1 semaine

---

## 🧪 Tests de Non-Régression

### Checklist par Phase

#### Phase 2 (Migration DB)
- [ ] Tous les écrans s'affichent
- [ ] Tous les CRUD fonctionnent
- [ ] Les données existantes sont préservées
- [ ] Les exports/imports fonctionnent
- [ ] Les rapports PDF se génèrent

#### Phase 3 (Repository SQLite)
- [ ] Tous les écrans s'affichent
- [ ] Tous les CRUD fonctionnent
- [ ] Les Providers fonctionnent
- [ ] Les calculs métier sont corrects
- [ ] Les notifications fonctionnent

#### Phase 4 (Supabase)
- [ ] Connexion Supabase fonctionne
- [ ] CRUD Supabase fonctionne
- [ ] SyncService fonctionne
- [ ] Tests unitaires passent

#### Phase 5 (Migration Module par Module)
- [ ] Module fonctionne en offline
- [ ] Module synchronise en online
- [ ] Pas de perte de données
- [ ] Performance acceptable
- [ ] Autres modules non affectés

#### Phase 6 (Activation Complète)
- [ ] Tous les modules synchronisent
- [ ] Pas de perte de données
- [ ] Performance globale acceptable
- [ ] Gestion des erreurs robuste

---

## 🚨 Stratégie de Rollback

### Points de Rollback par Phase

#### Phase 2
- **Action :** Restaurer sauvegarde pré-migration
- **Impact :** Perte des données créées après migration
- **Complexité :** Faible

#### Phase 3
- **Action :** Revenir à DatabaseHelper direct
- **Impact :** Aucun (repositories peuvent coexister)
- **Complexité :** Faible

#### Phase 4
- **Action :** Désactiver Supabase, utiliser SQLite uniquement
- **Impact :** Aucun (Supabase est optionnel)
- **Complexité :** Faible

#### Phase 5
- **Action :** Désactiver le flag de configuration pour le module
- **Impact :** Le module revient à SQLite uniquement
- **Complexité :** Faible

#### Phase 6
- **Action :** Désactiver sync globalement
- **Impact :** Application fonctionne en offline uniquement
- **Complexité :** Faible

---

## 📊 Métriques de Succès

### Critères de Validation par Phase

#### Phase 2
- ✅ Migration DB réussie
- ✅ Aucune perte de données
- ✅ Application fonctionne normalement

#### Phase 3
- ✅ Tous les tests passent
- ✅ Performance équivalente ou meilleure
- ✅ Code plus maintenable

#### Phase 4
- ✅ Supabase fonctionne
- ✅ SyncService fonctionne
- ✅ Tests unitaires passent

#### Phase 5
- ✅ Chaque module synchronise correctement
- ✅ Pas de régression
- ✅ Performance acceptable

#### Phase 6
- ✅ Tous les modules synchronisent
- ✅ Pas de perte de données
- ✅ Utilisateurs satisfaits

---

## 📝 Checklist Globale

### Avant de commencer
- [x] Documentation complète
- [x] Interfaces Repository créées
- [x] Scripts de migration préparés
- [ ] Compte Supabase créé
- [ ] Projet Supabase configuré
- [ ] Tests de non-régression définis

### Pendant la migration
- [ ] Sauvegardes régulières de la DB
- [ ] Tests après chaque étape
- [ ] Documentation des problèmes rencontrés
- [ ] Communication avec l'équipe

### Après la migration
- [ ] Tous les tests passent
- [ ] Documentation à jour
- [ ] Formation utilisateurs
- [ ] Monitoring en place

---

## 🎯 Prochaines Étapes

1. **Valider ce plan** avec l'équipe
2. **Créer le compte Supabase** et configurer le projet
3. **Commencer Phase 2** : Migration de la base de données
4. **Tester chaque phase** avant de passer à la suivante

---

**Note :** Ce plan est une **préparation théorique**. L'implémentation réelle se fera lors de la migration effective vers Supabase.

