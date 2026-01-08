# 🔔 Système de Notifications Automatiques Intelligentes

## ✅ Implémentation Complétée

Un système intelligent de notifications automatiques a été implémenté pour l'application Rabbit Farm.

---

## 🎯 Fonctionnalités Implémentées

### 1. **Notifications d'Accouplements** 🐰

#### Palpation (10-12 jours après accouplement)
- ✅ Notification automatique 11 jours après l'accouplement
- ✅ Rappel pour vérifier la gestation

#### Préparation du Nid (28 jours après accouplement)
- ✅ Notification automatique 28 jours après l'accouplement
- ✅ Rappel pour préparer le nid 3 jours avant la mise bas

#### Mise Bas (3 jours avant + jour J)
- ✅ Notification 3 jours avant la date prévue
- ✅ Notification le jour même de la mise bas (8h du matin)

### 2. **Notifications de Portées** 👶

#### Sevrage (5-6 semaines après mise bas)
- ✅ Notification automatique 2 jours avant le sevrage (35 jours après mise bas)
- ✅ Indique le nombre de lapereaux à sevrer

#### Pesées Hebdomadaires des Lapereaux
- ✅ Notifications automatiques chaque semaine pendant 5 semaines
- ✅ Rappels pour peser les lapereaux de la portée

### 3. **Notifications de Soins** 💉

#### Rappels de Soins
- ✅ Notifications pour les soins avec date de rappel
- ✅ Navigation vers la fiche santé du lapin

#### Vaccinations Récurrentes
- ✅ Rappels annuels automatiques (1 an après la vaccination)
- ✅ Détection automatique des vaccinations

### 4. **Notifications de Pesées** ⚖️

#### Pesées Hebdomadaires
- ✅ Rappels automatiques chaque semaine pour tous les lapins
- ✅ Basé sur la dernière pesée enregistrée

---

## 🔧 Architecture Technique

### Services Créés

#### 1. `SmartNotificationService`
- **Fichier** : `lib/services/smart_notification_service.dart`
- **Rôle** : Scanner automatiquement les données et planifier toutes les notifications
- **Méthode principale** : `scanAndScheduleAllNotifications()`

#### 2. `NotificationService` (Amélioré)
- **Fichier** : `lib/services/notification_service.dart`
- **Nouvelle méthode** : `planifierNotification()` - Méthode générique pour planifier n'importe quelle notification
- **Navigation** : Gestion améliorée des nouveaux types de notifications

### Intégration

#### Au Démarrage
- ✅ Initialisation dans `main.dart`
- ✅ Scan automatique au démarrage (en arrière-plan)
- ✅ Scan dans `splash_screen.dart` après chargement des données

#### Après Modifications
- ✅ Scan automatique après ajout d'accouplement
- ✅ Scan automatique après ajout de portée
- ✅ Scan automatique après modification importante

---

## 📅 Calendrier des Notifications

### Pour un Accouplement (31 jours de gestation)

| Jour | Notification | Description |
|------|-------------|-------------|
| +10-12 | 🔍 Palpation | Vérifier la gestation |
| +28 | 🏠 Préparation Nid | Préparer le nid (3 jours avant mise bas) |
| +28 | 🐰 Mise Bas (3 jours avant) | Rappel 3 jours avant |
| +31 | 🐰 Mise Bas (jour J) | Notification le jour même à 8h |

### Pour une Portée

| Semaine | Notification | Description |
|---------|-------------|-------------|
| 1-5 | ⚖️ Pesée Hebdomadaire | Pesée des lapereaux chaque semaine |
| 5 | 🍼 Sevrage | Rappel 2 jours avant le sevrage (35 jours) |

### Pour les Soins

| Type | Notification | Description |
|------|-------------|-------------|
| Soin avec rappel | 💉 Rappel de soin | À la date de rappel définie |
| Vaccination | 💉 Rappel annuel | 1 an après la vaccination |

### Pour les Pesées

| Type | Notification | Description |
|------|-------------|-------------|
| Pesée hebdomadaire | ⚖️ Rappel de pesée | Chaque semaine pour tous les lapins |

---

## 🎨 Types de Notifications

### Canaux de Notification

1. **`mise_bas_channel`** - Mises bas prévues
2. **`reproduction_channel`** - Accouplements et reproductions
3. **`soin_channel`** - Soins et vaccinations
4. **`pesee_channel`** - Pesées régulières
5. **`sevrage_channel`** - Sevrages

### IDs de Notification

Les notifications utilisent des IDs uniques avec des offsets :
- **Accouplements** : `accouplementId` (1-99999)
- **Soins** : `100000 + soinId`
- **Palpations** : `200000 + accouplementId`
- **Nids** : `300000 + accouplementId`
- **Pesées** : `400000 + lapinId`
- **Mise bas jour J** : `500000 + accouplementId`
- **Sevrages** : `600000 + porteeId`
- **Pesées portée** : `700000 + (porteeId * 10) + semaine`

---

## 🔄 Fonctionnement Automatique

### Scan Automatique

Le système scanne automatiquement :

1. **Au démarrage de l'application**
   - Après chargement des données
   - En arrière-plan (ne bloque pas l'interface)

2. **Après chaque modification importante**
   - Ajout d'accouplement
   - Ajout de portée
   - Modification de statut

3. **Périodiquement** (à implémenter)
   - Tous les jours à minuit
   - Pour mettre à jour les notifications

### Logique Intelligente

- ✅ **Évite les doublons** : Vérifie si une notification existe déjà
- ✅ **Ignore les dates passées** : Ne planifie que les notifications futures
- ✅ **Gère les statuts** : Annule les notifications si l'accouplement est annulé
- ✅ **Mise à jour automatique** : Replanifie si les dates changent

---

## 📱 Navigation depuis les Notifications

Quand l'utilisateur clique sur une notification :

| Type | Navigation |
|------|-----------|
| `mise_bas` | → Écran Reproduction |
| `mise_bas_jour` | → Écran Reproduction |
| `palpation` | → Écran Reproduction |
| `nid` | → Écran Reproduction |
| `soin` | → Fiche Santé du lapin |
| `sevrage` | → Écran Reproduction |
| `pesee` | → Fiche Santé du lapin |
| `pesee_portee` | → Écran Reproduction |
| `alerte` | → Détails du lapin |

---

## 🛠️ Utilisation

### Pour l'Utilisateur

**Aucune action requise !** Le système fonctionne automatiquement :

1. ✅ Créez un accouplement → Notifications planifiées automatiquement
2. ✅ Enregistrez une portée → Notifications de sevrage planifiées
3. ✅ Ajoutez un soin avec rappel → Notification planifiée
4. ✅ L'application démarre → Toutes les notifications sont vérifiées

### Pour le Développeur

#### Forcer un Scan Manuel

```dart
final smartNotificationService = SmartNotificationService();
await smartNotificationService.scanAndScheduleAllNotifications();
```

#### Vérifier les Notifications Planifiées

```dart
final notificationService = NotificationService();
final pending = await notificationService.getNotificationsEnAttente();
print('${pending.length} notifications planifiées');
```

---

## 📊 Statistiques

### Notifications Planifiées

Le système peut planifier :
- ✅ **4 notifications** par accouplement (palpation, nid, mise bas x2)
- ✅ **6 notifications** par portée (5 pesées + 1 sevrage)
- ✅ **1 notification** par soin avec rappel
- ✅ **1 notification** hebdomadaire par lapin

**Exemple** : Pour un élevage avec :
- 10 accouplements actifs → **40 notifications**
- 5 portées → **30 notifications**
- 20 lapins → **20 notifications hebdomadaires**
- 15 soins avec rappels → **15 notifications**

**Total** : ~105 notifications planifiées

---

## 🔍 Dépannage

### Problème : Les notifications ne s'affichent pas

**Vérifications :**
1. ✅ Permissions de notification accordées
2. ✅ Service initialisé (`SmartNotificationService.initialize()`)
3. ✅ Scan exécuté (`scanAndScheduleAllNotifications()`)
4. ✅ Dates futures (pas de dates passées)

### Problème : Trop de notifications

**Solution :**
- Le système évite automatiquement les doublons
- Les notifications passées ne sont pas planifiées
- Les notifications sont annulées si l'événement est annulé

### Problème : Notifications manquantes

**Solution :**
- Forcer un scan manuel depuis le code
- Vérifier que les données sont correctement enregistrées
- Vérifier les logs pour voir les erreurs

---

## 🎉 Résultat

L'application dispose maintenant d'un **système complet de notifications automatiques** qui :

- ✅ **Planifie automatiquement** toutes les notifications nécessaires
- ✅ **Scanne régulièrement** les données pour mettre à jour les notifications
- ✅ **Gère intelligemment** les dates et statuts
- ✅ **Navigue automatiquement** vers les écrans pertinents
- ✅ **Fonctionne en arrière-plan** sans bloquer l'interface

**L'utilisateur n'a plus besoin de se souvenir des dates importantes !** 🎯

---

**Date de création** : Janvier 2025  
**Version** : 1.0  
**Statut** : ✅ Implémenté et fonctionnel

