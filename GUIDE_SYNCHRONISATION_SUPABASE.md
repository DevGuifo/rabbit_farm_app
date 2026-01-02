# Guide de Synchronisation Supabase

## 📋 Vue d'ensemble

Ce guide explique comment activer et utiliser la synchronisation des données avec Supabase dans l'application Rabbit Farm.

---

## ✅ Prérequis

1. **Configuration Supabase** : ✅ Déjà configurée
   - URL : `https://xyufnlmelzzppqjgpxak.supabase.co`
   - Clé anonyme : Configurée dans `lib/config/supabase_config.dart`

2. **Compte utilisateur** : Créer un compte via l'application

---

## 🚀 Étape 1 : Créer les tables dans Supabase

Les tables doivent être créées dans votre projet Supabase pour que la synchronisation fonctionne.

### Instructions :

1. Aller sur https://supabase.com/dashboard
2. Sélectionner votre projet
3. Aller dans **SQL Editor**
4. Ouvrir le fichier : `lib/migrations/supabase_create_tables_idempotent.sql`
5. Copier tout le contenu du fichier
6. Coller dans l'éditeur SQL de Supabase
7. Cliquer sur **Run** (ou `Ctrl+Enter`)

### ✅ Vérification

Après l'exécution, vous devriez voir :
- ✅ 10 tables créées (lapins, accouplements, portees, pesees, soins, recettes, depenses, deces, aliments, distributions_aliment)
- ✅ Index créés
- ✅ Row Level Security (RLS) activé
- ✅ Policies créées (chaque utilisateur ne voit que ses propres données)
- ✅ Triggers créés (mise à jour automatique de `updated_at`)

---

## 🔄 Étape 2 : Comment fonctionne la synchronisation

### Synchronisation automatique

La synchronisation démarre automatiquement quand :
- ✅ Vous êtes connecté avec un compte Supabase
- ✅ Vous avez une connexion Internet
- ✅ Il y a des modifications locales à synchroniser

### Synchronisation manuelle

Vous pouvez forcer une synchronisation manuelle via le code :
```dart
final syncProvider = SyncProvider();
await syncProvider.syncNow();
```

### Types de synchronisation

1. **Sync UP (Local → Supabase)** :
   - Envoie toutes les modifications locales vers Supabase
   - Marque les enregistrements avec `is_dirty = 1`
   - Après synchronisation, `is_dirty = 0` et `synced_at` est mis à jour

2. **Sync DOWN (Supabase → Local)** :
   - Récupère les modifications depuis Supabase
   - Met à jour les enregistrements locaux
   - Utilise `updated_at` pour détecter les modifications

---

## 📊 Tables synchronisées

Les tables suivantes sont synchronisées automatiquement :

1. **lapins** - Tous les lapins
2. **accouplements** - Tous les accouplements
3. **portees** - Toutes les portées
4. **pesees** - Toutes les pesées
5. **soins** - Tous les soins
6. **recettes** - Toutes les recettes
7. **depenses** - Toutes les dépenses
8. **deces** - Tous les décès

---

## 🔍 Vérifier l'état de la synchronisation

### Dans le code

```dart
final syncProvider = SyncProvider();

// État de la synchronisation
print('État: ${syncProvider.state}');
print('En cours: ${syncProvider.isSyncing}');
print('Dernière sync: ${syncProvider.lastSyncTime}');
print('Changements en attente: ${syncProvider.pendingChanges}');
```

### États possibles

- `idle` : Aucune synchronisation en cours
- `syncing` : Synchronisation en cours
- `success` : Dernière synchronisation réussie
- `error` : Erreur lors de la dernière synchronisation

---

## 🛠️ Dépannage

### Problème : La synchronisation ne démarre pas

**Vérifications :**
1. ✅ Supabase est configuré (voir `lib/config/supabase_config.dart`)
2. ✅ Vous êtes connecté avec un compte Supabase (pas un compte local)
3. ✅ Les tables sont créées dans Supabase (voir Étape 1)
4. ✅ Vous avez une connexion Internet

### Problème : Erreur "User ID non disponible"

**Solution :**
- Déconnectez-vous et reconnectez-vous avec votre compte Supabase
- Vérifiez que l'authentification Supabase fonctionne

### Problème : Erreur "Table does not exist"

**Solution :**
- Exécutez le script SQL dans Supabase (voir Étape 1)
- Vérifiez que toutes les tables sont créées

### Problème : Les données ne se synchronisent pas

**Vérifications :**
1. Vérifiez que les enregistrements ont `is_dirty = 1` dans la base locale
2. Vérifiez les logs de l'application pour voir les erreurs
3. Vérifiez que Row Level Security (RLS) est activé dans Supabase

---

## 📝 Notes importantes

### Sécurité

- ✅ **Row Level Security (RLS)** est activé : chaque utilisateur ne voit que ses propres données
- ✅ Les données sont isolées par `user_id`
- ✅ Les policies Supabase empêchent l'accès aux données d'autres utilisateurs

### Performance

- La synchronisation se fait en arrière-plan
- Les modifications locales sont marquées avec `is_dirty = 1`
- La synchronisation ne bloque pas l'utilisation de l'application

### Mode Offline

- ✅ L'application fonctionne toujours en mode offline
- Les modifications sont stockées localement avec `is_dirty = 1`
- La synchronisation reprend automatiquement quand la connexion est rétablie

---

## ✅ Checklist de vérification

Avant d'utiliser la synchronisation, vérifiez :

- [ ] Configuration Supabase dans `lib/config/supabase_config.dart`
- [ ] Tables créées dans Supabase (script SQL exécuté)
- [ ] Compte utilisateur créé et connecté
- [ ] Connexion Internet disponible
- [ ] Synchronisation automatique démarrée (dans `splash_screen.dart`)

---

## 🎉 C'est tout !

Une fois ces étapes complétées, la synchronisation fonctionnera automatiquement. Vos données seront synchronisées entre votre appareil et Supabase, et vous pourrez accéder à vos données depuis plusieurs appareils.

---

**Date de création :** Janvier 2025  
**Version :** 1.0

