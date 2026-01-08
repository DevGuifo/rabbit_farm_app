# Cahier des charges - Application d'élevage de lapins Flutter Android

## 1. PRÉSENTATION DU PROJET

### 1.1 Contexte
Développement d'une application mobile Android avec Flutter pour la gestion d'élevage de lapins, fonctionnant entièrement en local sans connexion internet requise.

### 1.2 Objectifs
- Faciliter la gestion quotidienne d'un élevage de lapins
- Éliminer la paperasse traditionnelle
- Améliorer le suivi de la reproduction et de la santé des animaux
- Optimiser la rentabilité de l'élevage

### 1.3 Cible
- Éleveurs amateurs et professionnels de lapins
- Utilisateurs possédant un smartphone Android
- Personnes souhaitant une solution locale sans dépendance cloud

## 2. SPÉCIFICATIONS TECHNIQUES

### 2.1 Plateforme
- **Framework** : Flutter 3.0+
- **Langage** : Dart
- **OS cible** : Android 7.0 (API 24) minimum
- **Base de données** : SQLite locale (package sqflite)
- **Stockage** : Stockage interne de l'appareil
- **Sauvegarde** : Export/Import via fichiers locaux

### 2.2 Stack technique Flutter
- **Framework** : Flutter 3.0+ avec Dart
- **Base de données** : sqflite (SQLite pour Flutter)
- **Navigation** : go_router ou Navigator 2.0
- **Gestion d'état** : Provider ou Riverpod
- **Stockage local** : shared_preferences + path_provider
- **Photos** : image_picker
- **Notifications** : flutter_local_notifications
- **PDF/Export** : pdf + printing packages
- **Charts** : fl_chart pour les graphiques

### 2.3 Contraintes techniques
- Fonctionnement 100% hors ligne
- Aucune connexion internet requise
- Stockage local sécurisé
- Interface responsive adaptée aux smartphones et tablettes

## 3. FONCTIONNALITÉS PRINCIPALES

### 3.1 Gestion du cheptel
- **Ajout/Modification/Suppression de lapins**
  - Nom/Numéro d'identification
  - Numéro de puce/tatouage
  - Sexe, race (liste déroulante standardisée), couleur
  - Date de naissance
  - Poids actuel + historique des pesées
  - Statut (reproducteur, engraissement, vendu, décédé, quarantaine)
  - Photo (obligatoire pour identification)
  - Localisation (cage, bâtiment)

- **Généalogie**
  - Saisie des parents (père/mère)
  - Affichage de l'arbre généalogique sur 4 générations
  - Génération automatique du pedigree imprimable
  - Calcul du taux de consanguinité

### 3.2 Gestion de la reproduction
- **Planification des accouplements**
  - Sélection du mâle et de la femelle
  - Date d'accouplement
  - Date de mise bas prévue (calcul automatique)
  - Rappels/notifications

- **Suivi des portées**
  - Enregistrement des naissances
  - Nombre de lapereaux nés/vivants/morts
  - Suivi du poids des lapereaux
  - Sevrage et identification individuelle

### 3.3 Suivi sanitaire
- **Carnet de santé par animal**
  - Vaccinations
  - Traitements médicaux
  - Observations vétérinaires
  - Rappels de vaccination

- **Suivi de croissance**
  - Pesées régulières
  - Courbes de croissance
  - Alertes poids anormal

### 3.4 Gestion financière
- **Recettes**
  - Ventes de lapins
  - Catégories de vente (reproducteur, chair, etc.)
  - Prix de vente par animal

- **Dépenses**
  - Alimentation
  - Frais vétérinaires
  - Équipements
  - Catégorisation des dépenses

- **Tableaux de bord**
  - Bilan mensuel/annuel
  - Rentabilité par animal
  - Coût de production

### 3.5 Outils pratiques
- **Cartes de cages**
  - Génération automatique avec QR codes
  - Informations essentielles (nom, âge, parents, traitements)
  - Export PDF pour impression étiquettes

- **Rappels et notifications**
  - Accouplements programmés
  - Dates de mise bas (calcul automatique 31 jours)
  - Palpation (10-12 jours post-accouplement)
  - Préparation du nid (3 jours avant mise bas)
  - Vaccinations et traitements
  - Pesées hebdomadaires des lapereaux
  - Sevrage (5-6 semaines)

- **Gestionnaire de tâches**
  - **Création de tâches personnalisées**
    - Titre et description
    - Date et heure de planification
    - Priorité (haute, normale, basse)
    - Catégorie (reproduction, santé, alimentation, entretien, administratif, autre)
    - Association à un lapin spécifique (optionnel)
    - Pièces jointes (photos, notes)
  
  - **Statuts de tâches**
    - À faire
    - En cours
    - Terminée
    - Annulée
    - Reportée
  
  - **Tâches récurrentes**
    - Création de tâches répétitives (quotidienne, hebdomadaire, mensuelle)
    - Génération automatique des occurrences
    - Modification d'une occurrence unique sans affecter la série
  
  - **Organisation et filtres**
    - Vue par date (aujourd'hui, cette semaine, ce mois)
    - Filtres par statut, priorité, catégorie
    - Recherche textuelle
    - Tri par date, priorité, statut
    - Vue calendrier mensuel
  
  - **Intégration avec les données**
    - Tâches automatiques générées depuis les événements (accouplements, soins, etc.)
    - Conversion des notifications en tâches
    - Lien direct vers les fiches concernées (lapin, accouplement, soin)
  
  - **Suivi et historique**
    - Liste des tâches terminées avec date de complétion
    - Statistiques de productivité (tâches complétées/jour, semaine, mois)
    - Historique des modifications
    - Export des tâches en PDF/CSV
  
  - **Notifications intelligentes**
    - Rappels avant l'échéance (configurable)
    - Notifications pour les tâches prioritaires
    - Badge avec nombre de tâches en attente
    - Notification silencieuse pour les tâches non urgentes

- **Calculatrices intégrées**
  - Calcul de rations alimentaires
  - Dosages médicaments selon le poids
  - Coût de production par animal
  - Rentabilité prévisionelle

- **Rapports avancés**
  - Statistiques de reproduction (fertilité, prolificité)
  - Bilan sanitaire avec alertes
  - Rapport financier détaillé
  - Analyse génétique (consanguinité)
  - Courbes de croissance
  - Export en PDF/CSV/Excel

## 4. INTERFACE UTILISATEUR

### 4.1 Principes ergonomiques
- Interface intuitive et épurée
- Navigation simple à un ou deux clics
- Saisie rapide des données
- Utilisation possible d'une seule main

### 4.2 Écrans principaux
1. **Tableau de bord** : Vue d'ensemble du cheptel et tâches du jour
2. **Liste des lapins** : Gestion du cheptel
3. **Reproduction** : Planification et suivi
4. **Santé** : Suivi sanitaire
5. **Finances** : Gestion comptable
6. **Gestionnaire de tâches** : Organisation et suivi des tâches quotidiennes
7. **Rapports** : Statistiques et exports
8. **Paramètres** : Configuration de l'application

### 4.3 Éléments d'interface
- Icônes représentatives et universelles
- Couleurs différenciées par section
- Formulaires avec validation des données
- Listes avec recherche et tri
- Graphiques simples pour les statistiques

## 5. FONCTIONNALITÉS AVANCÉES (OPTIONNELLES)

### 5.1 Sauvegarde et restauration
- Export complet de la base de données
- Import depuis un fichier de sauvegarde
- Sauvegarde automatique périodique
- Partage de sauvegardes (email, cloud personnel)

### 5.2 Personnalisation
- Paramétrage des races disponibles
- Personnalisation des catégories de dépenses
- Configuration des rappels
- Thèmes visuels (clair/sombre)

### 5.3 Utilitaires
- Calculatrice de gestation
- Calendrier de reproduction
- Conseils d'élevage intégrés
- Glossaire des termes techniques

## 6. SÉCURITÉ ET CONFIDENTIALITÉ

### 6.1 Protection des données
- Chiffrement de la base de données SQLite
- Pas de transmission de données externes
- Sauvegarde locale sécurisée
- Option de code PIN pour l'accès

### 6.2 Permissions Android Flutter
- **Stockage** : WRITE_EXTERNAL_STORAGE, READ_EXTERNAL_STORAGE
- **Appareil photo** : CAMERA (via image_picker)
- **Notifications** : VIBRATE, RECEIVE_BOOT_COMPLETED
- **Configuration dans android/app/src/main/AndroidManifest.xml**
- Pas de permission internet requise

## 7. LIVRABLES

### 7.1 Application Flutter
- Fichier APK signé et optimisé
- Code source Flutter documenté
- Architecture des widgets et état documentée
- Configuration des packages tiers utilisés
- Base de données SQLite avec données de test

### 7.2 Documentation Flutter
- Manuel utilisateur de l'application
- Documentation technique Flutter
- Guide de setup de l'environnement de développement
- Documentation de l'architecture des données
- Procédures de build et déploiement

### 7.3 Support
- FAQ intégrée à l'application
- Tutoriels vidéo (optionnel)
- Support par email pendant 6 mois

## 8. PLANNING ET BUDGET

### 8.1 Phases de développement Flutter
1. **Setup et architecture Flutter** : 1 semaine
   - Configuration de l'environnement Flutter
   - Structure du projet et architecture de données
   - Configuration des packages essentiels

2. **Modèles de données et base SQLite** : 2 semaines
   - Création des modèles Dart (lapins, accouplements, portées, soins, finances, **tâches**)
   - Setup de la base SQLite avec sqflite
   - DAO (Data Access Objects) et repositories
   - Table `taches` avec champs : id, titre, description, date_planification, priorite, categorie, statut, lapin_id (optionnel), date_creation, date_modification, date_completion, est_recurrente, frequence_recurrence

3. **Interface utilisateur Flutter** : 4 semaines
   - Widgets personnalisés réutilisables
   - Écrans principaux avec Material Design
   - Navigation et routing
   - Responsive design

4. **Logique métier et fonctionnalités** : 4 semaines
   - Gestion d'état (Provider/Riverpod)
   - Fonctionnalités de reproduction et santé
   - **Gestionnaire de tâches complet** (création, modification, statuts, récurrence)
   - Génération de rapports et exports
   - Système de notifications

5. **Tests et optimisations Flutter** : 2 semaines
   - Tests unitaires et d'intégration
   - Tests de performance
   - Optimisation de l'app (taille, vitesse)

6. **Build et livraison** : 1 semaine
   - Build de production Android
   - Documentation Flutter
   - Génération de l'APK signé

**Durée totale estimée** : 14 semaines

### 8.2 Jalons principaux Flutter
- Validation de l'architecture Flutter : Semaine 1
- Modèles de données et SQLite opérationnels : Semaine 3
- Interface utilisateur de base : Semaine 7
- Version alpha (fonctionnalités core) : Semaine 10
- Version bêta complète : Semaine 12
- Version finale Android : Semaine 14

### 8.3 Budget estimé
- Développement : À définir selon le prestataire
- Tests : Inclus dans le développement
- Maintenance première année : 15% du coût de développement

## 9. CRITÈRES D'ACCEPTATION

### 9.1 Fonctionnels
- Toutes les fonctionnalités principales opérationnelles
- **Gestionnaire de tâches complet** avec création, modification, statuts et récurrence
- Import/export de données fonctionnel
- Génération de rapports correcte
- Notifications et rappels actifs

### 9.2 Techniques
- Application stable sans crash
- Temps de réponse < 2 secondes
- Consommation mémoire optimisée
- Compatibilité Android 7.0+

### 9.3 Ergonomiques
- Interface intuitive validée par tests utilisateurs
- Navigation fluide
- Saisie rapide des données
- Affichage adapté à différentes tailles d'écran

## 10. MAINTENANCE ET ÉVOLUTIONS

### 10.1 Maintenance corrective
- Correction de bugs pendant 12 mois
- Mises à jour de sécurité
- Adaptation aux nouvelles versions Android

### 10.2 Évolutions possibles
- Ajout de nouvelles espèces d'animaux
- Fonction d'importation de données externes
- Intégration avec des balances connectées
- Module de gestion des aliments et rationnement
- **Améliorations du gestionnaire de tâches** :
  - Collaboration multi-utilisateurs (si passage en mode cloud)
  - Templates de tâches pré-configurées
  - Synchronisation avec calendriers externes (Google Calendar, etc.)
  - Rappels vocaux
  - Géolocalisation pour tâches sur site

---

**Version du document** : 1.0  
**Date** : Juillet 2025  
**Statut** : Projet