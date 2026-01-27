# Politique de Confidentialité - BunnyManager

**Dernière mise à jour :** Décembre 2024  
**Version de l'application :** 1.3.0

---

## 1. Introduction

BunnyManager ("nous", "notre", "l'application") est une application mobile de gestion d'élevage de lapins professionnelle développée pour Android et iOS. Cette politique de confidentialité explique comment nous collectons, utilisons, stockons et protégeons vos données.

**En utilisant BunnyManager, vous acceptez les pratiques décrites dans cette politique.**

---

## 2. Données Collectées

### 2.1 Données d'élevage

L'application collecte et stocke les données suivantes relatives à votre élevage :

- **Informations sur les lapins** : nom, race, sexe, date de naissance, poids, statut, localisation, numéro d'identification, photos
- **Données de reproduction** : accouplements, portées, dates de mise bas, sevrages
- **Données de santé** : pesées, soins, médicaments administrés, vaccinations, traitements
- **Données financières** : recettes, dépenses, coûts d'alimentation et de médicaments
- **Données d'alimentation** : types d'aliments, quantités distribuées, stocks
- **Données de gestion** : tâches, rituels quotidiens, alertes, anomalies observées
- **Journal d'activités** : historique des actions effectuées dans l'application

### 2.2 Données utilisateur

- **Informations de compte** : adresse email (pour l'authentification locale)
- **Préférences** : thème (clair/sombre), langue, paramètres de notifications
- **Code PIN** : stocké de manière sécurisée et chiffrée localement (jamais transmis)

### 2.3 Données techniques

- **Photos** : images des lapins prises via l'appareil photo ou sélectionnées depuis la galerie
- **Fichiers** : exports Excel, PDF générés, sauvegardes locales

---

## 3. Stockage des Données

### 3.1 Stockage local (principal)

**Toutes vos données sont stockées localement sur votre appareil** dans une base de données SQLite chiffrée. Aucune donnée n'est transmise à des serveurs externes sans votre consentement explicite.

- **Base de données SQLite** : stockée dans le répertoire privé de l'application
- **Photos** : stockées dans le répertoire de documents de l'application
- **Fichiers d'export** : stockés dans le répertoire de téléchargements ou partagés directement

### 3.2 Synchronisation optionnelle (Supabase)

L'application propose une fonctionnalité de **synchronisation optionnelle** via Supabase pour sauvegarder vos données dans le cloud et les synchroniser entre plusieurs appareils.

**Cette synchronisation est désactivée par défaut** et nécessite :
- Votre consentement explicite lors de l'onboarding
- La configuration d'un compte Supabase (optionnel)
- Une connexion Internet active

**Si vous activez la synchronisation :**
- Vos données sont chiffrées en transit (HTTPS/TLS)
- Les données sont stockées sur les serveurs Supabase (hébergés en Europe)
- Vous pouvez désactiver la synchronisation à tout moment depuis les paramètres
- La désactivation n'efface pas vos données locales

**Si vous n'activez pas la synchronisation :**
- Toutes vos données restent 100% locales sur votre appareil
- Aucune donnée n'est transmise à des serveurs externes

---

## 4. Permissions Utilisées

### 4.1 Permissions Android

L'application demande les permissions suivantes :

| Permission | Justification | Utilisation |
|------------|---------------|-------------|
| `POST_NOTIFICATIONS` | Rappels de tâches importantes (mises bas, palpations, soins) | Notifications locales pour les événements critiques de l'élevage |
| `SCHEDULE_EXACT_ALARM` | Planification précise des rappels | Planification des notifications à des heures précises |
| `USE_EXACT_ALARM` | Planification précise des rappels | Planification des notifications à des heures précises |
| `RECEIVE_BOOT_COMPLETED` | Réinitialisation des notifications après redémarrage | Réactivation automatique des notifications planifiées après redémarrage de l'appareil |
| `VIBRATE` | Retour haptique pour les notifications | Vibration lors de la réception de notifications importantes |
| **Caméra** (runtime) | Prise de photos des lapins | Identification visuelle des lapins via photos |
| **Stockage** (runtime) | Sauvegarde des photos et exports | Stockage des photos prises et des fichiers d'export (Excel, PDF) |

### 4.2 Permissions iOS

L'application demande les permissions suivantes sur iOS :

| Permission | Justification | Utilisation |
|------------|---------------|-------------|
| **Notifications** | Rappels de tâches importantes | Notifications locales pour les événements critiques de l'élevage (mises bas, palpations, soins) |
| **Caméra** (runtime) | Prise de photos des lapins | Identification visuelle des lapins via photos |
| **Photos** (runtime) | Sélection depuis la galerie | Sélection de photos existantes pour les fiches des lapins |
| **Stockage** (runtime) | Sauvegarde des exports | Sauvegarde des fichiers d'export (Excel, PDF) dans le répertoire de fichiers |

**Toutes les permissions sont demandées uniquement au moment de l'utilisation** (runtime permissions), et vous pouvez les refuser sans empêcher l'utilisation de l'application (certaines fonctionnalités seront simplement désactivées).

---

## 5. Utilisation des Données

Vos données sont utilisées uniquement pour :

- **Fonctionnalités de l'application** : gestion de l'élevage, calculs de statistiques, génération de rapports
- **Notifications** : rappels de tâches importantes (mises bas, soins, pesées)
- **Synchronisation** : si activée, synchronisation entre vos appareils
- **Amélioration de l'application** : statistiques anonymisées d'utilisation (si activées)

**Nous ne vendons, ne louons, ni ne partageons vos données avec des tiers** à des fins commerciales.

---

## 6. Durée de Conservation

- **Données locales** : conservées indéfiniment sur votre appareil jusqu'à ce que vous supprimiez l'application ou effaciez les données manuellement
- **Données synchronisées** : conservées sur Supabase tant que votre compte est actif et que la synchronisation est activée
- **Exports** : les fichiers Excel/PDF générés restent sur votre appareil jusqu'à ce que vous les supprimiez manuellement

---

## 7. Vos Droits

Vous avez le droit de :

- **Accéder à vos données** : toutes vos données sont accessibles depuis l'application
- **Modifier vos données** : vous pouvez modifier ou supprimer toute donnée depuis l'application
- **Exporter vos données** : fonctionnalité d'export Excel/PDF intégrée
- **Supprimer vos données** : vous pouvez supprimer l'application ou effacer les données depuis les paramètres
- **Désactiver la synchronisation** : à tout moment depuis les paramètres
- **Demander la suppression de vos données synchronisées** : contactez-nous si vous avez activé la synchronisation

---

## 8. Sécurité

Nous mettons en œuvre des mesures de sécurité appropriées pour protéger vos données :

- **Chiffrement local** : base de données SQLite chiffrée
- **Stockage sécurisé** : utilisation de `flutter_secure_storage` pour les données sensibles (PIN, tokens)
- **Chiffrement en transit** : toutes les communications avec Supabase utilisent HTTPS/TLS
- **Authentification locale** : code PIN optionnel pour protéger l'accès à l'application
- **Pas de transmission automatique** : aucune donnée n'est transmise sans votre consentement explicite

---

## 9. Données des Tiers

L'application utilise les services suivants :

- **Supabase** (optionnel) : service de backend pour la synchronisation optionnelle
  - Politique de confidentialité : https://supabase.com/privacy
  - Hébergement : Europe (RGPD compliant)

**Si vous n'activez pas la synchronisation, aucune donnée n'est transmise à Supabase.**

---

## 10. Modifications de cette Politique

Nous pouvons mettre à jour cette politique de confidentialité occasionnellement. Les modifications seront publiées dans cette page avec une date de "Dernière mise à jour" révisée.

**Nous vous recommandons de consulter régulièrement cette page** pour rester informé de la façon dont nous protégeons vos données.

---

## 11. Contact

Pour toute question concernant cette politique de confidentialité ou vos données :

- **Email** : [À compléter avec votre adresse email de contact]
- **Application** : Section "Paramètres" > "Contact" (si disponible)

---

## 12. Conformité RGPD

Cette application respecte le Règlement Général sur la Protection des Données (RGPD) :

- **Consentement explicite** : synchronisation optionnelle uniquement avec consentement
- **Droit à l'oubli** : suppression des données possible à tout moment
- **Portabilité des données** : fonctionnalité d'export intégrée
- **Transparence** : cette politique explique clairement l'utilisation des données
- **Minimisation** : seules les données nécessaires sont collectées

---

**En utilisant BunnyManager, vous reconnaissez avoir lu et compris cette politique de confidentialité.**
