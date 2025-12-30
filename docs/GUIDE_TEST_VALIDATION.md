# GUIDE PRATIQUE DE TEST - VALIDATION PHASE 5

**Objectif :** Guide étape par étape pour tester toutes les fonctionnalités de l'application

---

## 🚀 PRÉPARATION

### 1. Vérifier la configuration

```bash
# Vérifier que les dépendances sont installées
flutter pub get

# Vérifier la configuration Supabase
# Fichier : lib/config/supabase_config.dart
# Vérifier que les clés sont correctes
```

### 2. Préparer l'environnement de test

- **Appareil 1** : Smartphone/Tablette (ou émulateur)
- **Appareil 2** : Autre appareil (pour tests multi-appareils)
- **Compte Supabase** : Au moins 2 comptes de test

### 3. Vérifier Supabase

1. Aller sur [Supabase Dashboard](https://app.supabase.com)
2. Vérifier que les tables sont créées
3. Vérifier que RLS est activé
4. Vérifier les policies

---

## 📱 TESTS OFFLINE

### Test 1 : Démarrage sans réseau

**Étapes :**
1. Désactiver WiFi et données mobiles
2. Fermer complètement l'application
3. Rouvrir l'application
4. Observer le comportement

**Vérifications :**
- [ ] L'app démarre sans erreur
- [ ] PinScreen s'affiche (pas AuthScreen)
- [ ] Aucune erreur de timeout
- [ ] Temps de démarrage < 3 secondes

**Logs à vérifier :**
```
✅ ConnectivityProvider initialisé (online: false)
✅ SyncProvider initialisé
⏭️ Auto-sync ignorée : pas de connexion
```

---

### Test 2 : Déverrouillage PIN offline

**Étapes :**
1. Application en mode offline
2. Saisir le PIN correct
3. Cliquer sur "Déverrouiller"

**Vérifications :**
- [ ] PIN accepté
- [ ] Navigation vers HomeScreen
- [ ] Données locales affichées
- [ ] Aucun appel réseau

**Logs à vérifier :**
```
✅ PIN validé avec succès
✅ Navigation vers HomeScreen
```

---

### Test 3 : Création de données offline

**Étapes :**
1. Application déverrouillée (offline)
2. Créer un nouveau lapin
3. Modifier un lapin existant
4. Supprimer un lapin
5. Redémarrer l'application
6. Vérifier que les données sont toujours là

**Vérifications :**
- [ ] Données créées/modifiées/supprimées
- [ ] Données visibles immédiatement
- [ ] Données persistées après redémarrage
- [ ] `is_dirty = 1` pour les modifications

**Vérification SQLite :**
```sql
-- Vérifier les enregistrements avec is_dirty = 1
SELECT * FROM lapins WHERE is_dirty = 1;
```

---

### Test 4 : Rate limiting PIN

**Étapes :**
1. Application en mode offline
2. Saisir un PIN incorrect 5 fois
3. Observer le blocage
4. Attendre 5 minutes (ou modifier l'heure système pour tester)
5. Réessayer avec le PIN correct

**Vérifications :**
- [ ] Blocage après 5 tentatives
- [ ] Message avec temps restant affiché
- [ ] Bouton désactivé pendant le blocage
- [ ] Déblocage après 5 minutes

**Logs à vérifier :**
```
⚠️ PIN incorrect. Tentatives restantes: 4
⚠️ PIN incorrect. Tentatives restantes: 3
...
🔒 Trop de tentatives. Réessayez dans 5m 0s
```

---

## 🌐 TESTS ONLINE

### Test 5 : Inscription

**Étapes :**
1. Activer le réseau
2. Ouvrir l'application
3. Aller sur AuthScreen
4. Remplir le formulaire d'inscription :
   - Email : `test@example.com`
   - Mot de passe : `password123`
   - Confirmer mot de passe : `password123`
5. Cliquer sur "S'inscrire"

**Vérifications :**
- [ ] Inscription réussie
- [ ] Navigation vers PinSetupScreen
- [ ] Compte créé dans Supabase
- [ ] Token stocké dans Secure Storage

**Vérification Supabase :**
1. Aller sur Supabase Dashboard
2. Table `auth.users`
3. Vérifier que le nouvel utilisateur existe

---

### Test 6 : Connexion

**Étapes :**
1. Application ouverte
2. Aller sur AuthScreen
3. Saisir email et mot de passe
4. Cliquer sur "Se connecter"

**Vérifications :**
- [ ] Connexion réussie
- [ ] Navigation correcte (HomeScreen ou PinSetupScreen)
- [ ] Session restaurée
- [ ] Token stocké

---

### Test 7 : Synchronisation automatique

**Préparation :**
1. Créer des données en mode offline
2. Vérifier que `is_dirty = 1`

**Étapes :**
1. Activer le réseau
2. Attendre 2-3 secondes
3. Observer les logs

**Vérifications :**
- [ ] Synchronisation automatique déclenchée
- [ ] Données envoyées à Supabase
- [ ] `is_dirty = 0` après sync
- [ ] `synced_at` mis à jour

**Logs à vérifier :**
```
🔄 Auto-sync démarrée (X changements en attente)
📤 Sync UP : Envoi des modifications locales...
📥 Sync DOWN : Récupération des modifications distantes...
✅ Synchronisation complète réussie
```

**Vérification SQLite :**
```sql
-- Vérifier que is_dirty = 0 après sync
SELECT * FROM lapins WHERE is_dirty = 0 AND synced_at IS NOT NULL;
```

**Vérification Supabase :**
1. Aller sur Supabase Dashboard
2. Table `lapins`
3. Vérifier que les données sont présentes

---

### Test 8 : Synchronisation manuelle

**Étapes :**
1. Modifier des données
2. Appeler la synchronisation manuelle (via UI ou code)
3. Observer les résultats

**Vérifications :**
- [ ] État `syncing` → `success`
- [ ] Données synchronisées
- [ ] `lastSyncTime` mis à jour

---

### Test 9 : Synchronisation bidirectionnelle (2 appareils)

**Préparation :**
- Appareil A : Compte `user1@example.com`
- Appareil B : Même compte `user1@example.com`

**Étapes :**

**Appareil A :**
1. Créer un lapin "Lapin A"
2. Synchroniser
3. Vérifier dans Supabase

**Appareil B :**
1. Synchroniser
2. Vérifier que "Lapin A" apparaît
3. Modifier "Lapin A" → "Lapin A Modifié"
4. Synchroniser

**Appareil A :**
1. Synchroniser
2. Vérifier que "Lapin A Modifié" apparaît

**Vérifications :**
- [ ] Données créées sur A apparaissent sur B
- [ ] Modifications de B apparaissent sur A
- [ ] Aucune perte de données
- [ ] Données cohérentes

---

## 👥 TESTS CHANGEMENT D'UTILISATEUR

### Test 10 : Déconnexion

**Étapes :**
1. Utilisateur authentifié
2. Aller dans Paramètres
3. Cliquer sur "Déconnexion"
4. Confirmer

**Vérifications :**
- [ ] Déconnexion réussie
- [ ] Navigation vers AuthScreen
- [ ] Tokens supprimés
- [ ] Synchronisation arrêtée

**Vérification Secure Storage :**
- Les tokens doivent être supprimés

---

### Test 11 : Connexion avec autre compte

**Préparation :**
- Compte A : `user1@example.com`
- Compte B : `user2@example.com`

**Étapes :**
1. Se déconnecter
2. Se connecter avec Compte B
3. Vérifier les données affichées

**Vérifications :**
- [ ] Connexion réussie
- [ ] Seules les données de B affichées
- [ ] Données de A isolées (user_id différent)
- [ ] RLS fonctionne

**Vérification Supabase :**
```sql
-- Vérifier l'isolation des données
SELECT * FROM lapins WHERE user_id = 'user1_id';
SELECT * FROM lapins WHERE user_id = 'user2_id';
```

---

## 🔒 TESTS DE SÉCURITÉ

### Test 12 : Vérification du stockage sécurisé

**Étapes :**
1. Configurer un PIN
2. Vérifier le stockage

**Vérifications :**
- [ ] PIN jamais stocké en clair
- [ ] Hash PIN présent (PBKDF2)
- [ ] Tokens dans Secure Storage uniquement

**Vérification SQLite :**
```sql
-- Vérifier qu'il n'y a pas de PIN en clair
SELECT * FROM sqlite_master WHERE type='table';
-- Aucune table ne doit contenir de PIN en clair
```

**Vérification Secure Storage :**
- Utiliser un outil de débogage pour vérifier Secure Storage
- Le PIN doit être hashé (PBKDF2)

---

### Test 13 : Row Level Security (RLS)

**Préparation :**
- Compte A : `user1@example.com`
- Compte B : `user2@example.com`

**Étapes :**
1. **Compte A** : Créer des données
2. **Compte B** : Tenter d'accéder aux données de A

**Vérifications :**
- [ ] Compte B ne peut pas voir les données de A
- [ ] RLS bloque l'accès
- [ ] Seules les données de B accessibles

**Vérification Supabase :**
```sql
-- En tant que user2, essayer d'accéder aux données de user1
-- Doit retourner 0 résultats
SELECT * FROM lapins WHERE user_id = 'user1_id';
```

---

## ⚡ TESTS DE PERFORMANCE

### Test 14 : Temps de démarrage

**Étapes :**
1. Mesurer le temps de démarrage offline
2. Mesurer le temps de démarrage online

**Outils :**
- Utiliser `flutter run --profile` pour les métriques
- Utiliser un chronomètre

**Objectifs :**
- Démarrage offline < 3 secondes
- Démarrage online < 5 secondes

---

### Test 15 : Synchronisation de grandes quantités

**Préparation :**
1. Créer 100+ lapins en mode offline

**Étapes :**
1. Activer le réseau
2. Synchroniser
3. Mesurer le temps

**Objectifs :**
- Synchronisation < 30 secondes pour 100 enregistrements

---

## 🐛 TESTS DE ROBUSTESSE

### Test 16 : Perte de connexion pendant la sync

**Étapes :**
1. Démarrer une synchronisation
2. Couper le réseau pendant la sync
3. Observer le comportement

**Vérifications :**
- [ ] Erreur gérée gracieusement
- [ ] État `error` avec message
- [ ] Données locales préservées
- [ ] Retry possible après reconnexion

---

### Test 17 : Conflits de synchronisation

**Préparation :**
- Appareil A et B avec le même compte

**Étapes :**
1. **Appareil A** : Modifier un lapin (offline)
2. **Appareil B** : Modifier le même lapin (offline)
3. **Appareil A** : Synchroniser
4. **Appareil B** : Synchroniser

**Vérifications :**
- [ ] Conflit détecté
- [ ] Résolution Last Update Wins
- [ ] `sync_conflict` enregistré
- [ ] Données cohérentes

---

## 📊 RAPPORT DE TEST

### Template de rapport

```
Date : [DATE]
Testeur : [NOM]
Version : [VERSION]

RÉSULTATS :
- Tests Offline : X/Y réussis
- Tests Online : X/Y réussis
- Tests Changement Utilisateur : X/Y réussis
- Tests Sécurité : X/Y réussis
- Tests Performance : X/Y réussis

BUGS IDENTIFIÉS :
1. [Description]
2. [Description]

RECOMMANDATIONS :
- [Recommandation 1]
- [Recommandation 2]
```

---

## ✅ CHECKLIST FINALE

Avant de considérer la validation comme terminée :

- [ ] Tous les tests offline réussis
- [ ] Tous les tests online réussis
- [ ] Tous les tests changement utilisateur réussis
- [ ] Tous les tests sécurité réussis
- [ ] Tous les tests performance réussis
- [ ] Tous les bugs critiques corrigés
- [ ] Documentation à jour
- [ ] Code review effectué

---

**Bon test ! 🚀**

