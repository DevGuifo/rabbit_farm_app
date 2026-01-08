# Cahier des charges v2.0 - Application d'élevage de lapins Flutter Android

## 1. PRÉSENTATION DU PROJET

### 1.1 Contexte
Développement d'une application mobile Android avec Flutter pour la gestion d'élevage de lapins, fonctionnant entièrement en local sans connexion internet requise.

### 1.2 Vision et philosophie produit

**🎯 VISION CENTRALE**

Cette application n'est pas un simple outil de gestion, c'est un **système de transformation des pratiques d'élevage**.

**Principe fondamental** : Un bon cuniculteur n'est pas celui qui sait, mais celui qui **observe tous les jours**.

**Le vrai problème en Afrique** :
- ❌ Ce n'est pas le manque d'élevage
- ❌ Ce n'est pas le manque de connaissances
- ✅ C'est le manque de **routines**, d'**observation** et de **discipline**

**L'app doit donc** :
1. **POUSSER** l'éleveur à observer quotidiennement
2. **RAPPELER** les actions critiques
3. **QUESTIONNER** pour guider l'observation
4. **DOCUMENTER** automatiquement sans effort de saisie

> ⚠️ **Règle d'or** : Si l'app se contente de "permettre de saisir", elle échouera. Elle doit créer des **habitudes** et un **rythme**.

### 1.3 Objectifs transformés
- ✅ Créer des **rituels quotidiens** (pas juste faciliter la gestion)
- ✅ **Automatiser la documentation** (éliminer la paperasse, pas les traces)
- ✅ Former un **réflexe d'observation** systématique
- ✅ Devenir un **coach silencieux** qui guide sans juger
- ✅ Optimiser la rentabilité par la **rigueur**, pas juste les données

### 1.4 Cible
- Éleveurs amateurs et professionnels de lapins en Afrique
- Utilisateurs possédant un smartphone Android
- Personnes ayant besoin de **discipline** et de **méthode**, pas juste d'un outil

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
- **Performance** : Temps de réponse < 1 seconde pour actions quotidiennes
- **Simplicité** : Maximum 2 clics pour actions courantes

## 3. FONCTIONNALITÉS PRINCIPALES

### 3.1 RITUELS QUOTIDIENS (NOUVEAU - PRIORITAIRE)

**Concept** : Remplacer le tableau de bord traditionnel par un **guide quotidien**.

#### 3.1.1 Écran principal transformé

Au lieu de "Voici tes données" → **"Voici ce que TU DOIS FAIRE aujourd'hui"**

**Structure de l'écran d'accueil** :

```
🌅 RITUEL DU MATIN (7h-9h)
├─ 🔍 Observer les femelles gestantes (3)
├─ 🍽️ Vérifier l'alimentation - Lot A
├─ 🌡️ Contrôle température bâtiment 1
└─ ⚠️ 2 anomalies à suivre

🌆 RITUEL DU SOIR (17h-19h)
├─ 🧼 Nettoyage zone B
├─ 💧 Vérifier abreuvoirs
└─ 📋 Clôture de journée
```

**Boutons d'action rapide** :
- ✅ Tout est normal
- ⚠️ Anomalie observée
- ❌ Incident/Perte
- ⏰ Reporter (avec justification simple)

#### 3.1.2 Rituels configurables

**Types de rituels** :
- **Quotidiens** : Observation, nourrissage, nettoyage
- **Hebdomadaires** : Pesées, désinfection complète
- **Mensuels** : Inventaire, bilan sanitaire
- **Saisonniers** : Préparation hiver/été

**Personnalisation** :
- Heures des rituels (matin/midi/soir)
- Fréquence par activité
- Priorisation automatique selon contexte (météo, saison, événements)

#### 3.1.3 Observation guidée (CRITIQUE)

**Principe** : Les éleveurs ne savent pas toujours **quoi** observer.

**Quand l'utilisateur clique "Anomalie"** :

```
⚠️ QU'AS-TU OBSERVÉ ?

Comportement :
⬜ Refus de nourriture
⬜ Agressivité inhabituelle
⬜ Léthargie

Physique :
⬜ Perte de poids visible
⬜ Blessure
⬜ Problème respiratoire
⬜ Diarrhée

Environnement :
⬜ Cage sale
⬜ Abreuvoir vide
⬜ Température anormale

⬜ Autre (texte libre optionnel)
```

**Pas de texte obligatoire** → Juste cocher → L'app génère automatiquement :
- Date et heure
- Contexte (lot, individu, localisation)
- Historique
- Actions suggérées

### 3.2 Gestion du cheptel - MODE LOTS + EXCEPTIONS

**🧩 PRINCIPE FONDAMENTAL** :

> **Le lot est la norme, l'individu est l'exception**

#### 3.2.1 Gestion par lots

**Création de lots** :
- Lot de reproducteurs
- Lot d'engraissement par tranche d'âge
- Lot de quarantaine
- Lot de sevrage

**Actions sur les lots** :
- Nourrissage → LOT
- Nettoyage → LOT
- Observation générale → LOT
- Pesée groupe → LOT
- Transfert entre lots

**Informations du lot** :
- Effectif actuel
- Âge moyen
- Poids moyen
- Localisation (bâtiment/zone)
- Statut sanitaire
- Historique simplifié

#### 3.2.2 Suivi individuel (par exception uniquement)

**Un lapin devient individuel quand** :
- Reproducteur (mâle/femelle)
- Anomalie détectée
- Traitement spécifique nécessaire
- Destiné à la vente comme reproducteur
- Suivi généalogique requis

**Fiche individuelle** :
- Nom/Numéro d'identification
- Numéro de puce/tatouage (reproducteurs)
- Sexe, race (liste déroulante standardisée), couleur
- Date de naissance
- Poids actuel + historique des pesées
- Statut (reproducteur, suivi spécial, vendu, décédé)
- Photo (obligatoire pour reproducteurs)
- Localisation (cage, bâtiment)

**Généalogie** (reproducteurs uniquement) :
- Saisie des parents (père/mère)
- Affichage de l'arbre généalogique sur 4 générations
- Génération automatique du pedigree imprimable
- Calcul du taux de consanguinité

### 3.3 Gestion de la reproduction

**Planification des accouplements** :
- Sélection du mâle et de la femelle
- Date d'accouplement
- Date de mise bas prévue (calcul automatique 31 jours)
- **Génération automatique des rituels** :
  - Palpation (J+10 à J+12)
  - Préparation du nid (J+28)
  - Surveillance mise bas (J+31)

**Suivi des portées** :
- Enregistrement des naissances
- Nombre de lapereaux nés/vivants/morts
- Suivi du poids des lapereaux (en lot)
- Sevrage et identification individuelle si nécessaire

### 3.4 Suivi sanitaire simplifié

**Carnet de santé** :
- Par lot : Traitements préventifs, vaccinations
- Par individu : Soins spécifiques, traitements curatifs

**Observations quotidiennes** (via rituels) :
- État général du lot
- Anomalies individuelles détectées
- Actions correctives prises

**Suivi de croissance** :
- Pesées hebdomadaires (lots)
- Courbes de croissance moyennes
- Alertes poids anormal

### 3.5 Gestion financière

**Recettes** :
- Ventes de lapins (par lot ou individuel)
- Catégories de vente (reproducteur, chair, etc.)
- Prix de vente

**Dépenses** :
- Alimentation (par lot)
- Frais vétérinaires
- Équipements
- Catégorisation des dépenses

**Tableaux de bord** :
- Bilan mensuel/annuel
- Rentabilité par lot
- Coût de production

### 3.6 NOTIFICATIONS PÉDAGOGIQUES (TRANSFORMÉES)

**❌ Mauvais** : "Palpation prévue aujourd'hui"

**✅ Bon** :
```
🐰 RITUEL DU JOUR
As-tu vérifié les femelles accouplées 
il y a 10 jours ?

[✔️ Oui, tout est normal]
[⚠️ J'ai remarqué un problème]
[⏰ Plus tard]
```

**Chaque clic = une donnée enregistrée automatiquement**

**Types de notifications intelligentes** :
- Rituels quotidiens (matin/soir)
- Événements critiques (mise bas imminente)
- Rappels d'actions non effectuées
- Messages éducatifs discrets
- Alertes anomalies non suivies

### 3.7 Outils pratiques

**Cartes de cages** :
- Génération automatique avec QR codes
- Informations essentielles (lot/individu, âge, traitements)
- Export PDF pour impression étiquettes

**Calculatrices intégrées** :
- Calcul de rations alimentaires par lot
- Dosages médicaments selon le poids
- Coût de production par animal/lot
- Rentabilité prévisionnelle

**Rapports simplifiés** :
- Statistiques de reproduction
- Bilan sanitaire
- Rapport financier
- Analyse par lot
- Export en PDF/CSV

## 4. INTERFACE UTILISATEUR

### 4.1 Principes ergonomiques transformés

**Règles absolues** :
- ✅ **Maximum 2 clics** pour actions courantes
- ✅ **Boutons > Formulaires** (cocher, pas écrire)
- ✅ **Actions > Données** (faire, pas saisir)
- ✅ **Guidance > Liberté** (l'app propose, l'utilisateur valide)

### 4.2 Écrans principaux réorganisés

1. **🏠 Rituels quotidiens** : Écran principal avec actions du jour
2. **📊 Miroir de rigueur** : Indicateurs de discipline (remplace dashboard classique)
3. **🐰 Cheptel (Lots + Individus)** : Gestion par lots avec exceptions
4. **👶 Reproduction** : Planification et suivi
5. **🏥 Santé** : Observations et traitements
6. **💰 Finances** : Gestion comptable simplifiée
7. **📈 Rapports** : Statistiques et exports
8. **⚙️ Paramètres** : Configuration et rituels personnalisés

### 4.3 TABLEAU DE BORD "MIROIR DE RIGUEUR"

**Objectif** : Montrer la **discipline**, pas juste les données.

**3 questions visuelles** :

```
📅 MA RÉGULARITÉ
┌─────────────────────────────┐
│ Jours consécutifs avec      │
│ observation complète : 12 🔥│
└─────────────────────────────┘

⚠️ MES ACTIONS EN ATTENTE
┌─────────────────────────────┐
│ Anomalies non suivies : 3   │
│ Rituels en retard : 1       │
└─────────────────────────────┘

✅ MA PERFORMANCE HEBDOMADAIRE
┌─────────────────────────────┐
│ Rituels respectés : 85%     │
│ ██████████░░░░░             │
└─────────────────────────────┘
```

**Messages éducatifs discrets** :
- "Les élevages performants observent 2x/jour"
- "3 jours sans observation = risque sanitaire"
- "Une anomalie non suivie coûte en moyenne X"

### 4.4 Navigation simplifiée

**Barre de navigation** :
- 🏠 Rituels (écran principal)
- 📊 Rigueur (miroir)
- 🐰 Cheptel
- 📋 Actions rapides (FAB - Floating Action Button)

**Actions rapides contextuelles** :
- ✅ Tout est normal
- ⚠️ Signaler anomalie
- 📸 Prendre photo
- 💊 Traitement rapide
- 📝 Note libre

## 5. ÉDUCATION SILENCIEUSE (NOUVEAU)

### 5.1 Principe

**Former sans cours, sans texte long**

### 5.2 Méthodes d'intégration

**Messages contextuels** :
- Lors de l'utilisation : conseils brefs
- Basés sur les actions : "Bonne pratique !"
- Comparaisons anonymes : "Les éleveurs réguliers gagnent +30%"

**Tooltips éducatifs** :
- À la première utilisation d'une fonction
- Rappels occasionnels de bonnes pratiques
- Explications sur les calculs automatiques

**Gamification discrète** :
- Séries de jours consécutifs
- Badges de régularité (non intrusifs)
- Progression visible dans le "Miroir de rigueur"

## 6. FONCTIONNALITÉS AVANCÉES

### 6.1 Sauvegarde et restauration
- Export complet de la base de données
- Import depuis un fichier de sauvegarde
- Sauvegarde automatique périodique
- Partage de sauvegardes (email, cloud personnel)

### 6.2 Personnalisation
- Paramétrage des rituels quotidiens
- Configuration des lots types
- Personnalisation des catégories de dépenses
- Configuration des rappels et notifications
- Thèmes visuels (clair/sombre)

### 6.3 Historique et traçabilité automatique

**Documentation passive** :
- Chaque action génère automatiquement une trace
- Historique complet sans saisie manuelle
- Traçabilité par lot et par individu
- Export des historiques

## 7. SÉCURITÉ ET CONFIDENTIALITÉ

### 7.1 Protection des données
- Chiffrement de la base de données SQLite
- Pas de transmission de données externes
- Sauvegarde locale sécurisée
- Option de code PIN pour l'accès

### 7.2 Permissions Android Flutter
- **Stockage** : WRITE_EXTERNAL_STORAGE, READ_EXTERNAL_STORAGE
- **Appareil photo** : CAMERA (via image_picker)
- **Notifications** : VIBRATE, RECEIVE_BOOT_COMPLETED
- **Configuration dans android/app/src/main/AndroidManifest.xml**
- Pas de permission internet requise

## 8. MODÈLE DE DONNÉES

### 8.1 Tables principales

**Lots** :
- id, nom, type, effectif, age_moyen, poids_moyen, statut, localisation, date_creation

**Lapins** (individuels uniquement) :
- id, lot_id (nullable), nom, numero, sexe, race, date_naissance, poids, statut, photo, localisation

**Rituels** :
- id, titre, description, type (quotidien/hebdo/mensuel), heure, jours_semaine, actif

**Actions_rituels** (historique) :
- id, rituel_id, date_execution, statut (ok/anomalie/skip), observations, utilisateur

**Observations** :
- id, date, type (lot/individu), cible_id, categorie, details (JSON), actions_prises

**Accouplements** :
- id, male_id, femelle_id, date_accouplement, date_prevue_mise_bas, resultat

**Portees** :
- id, accouplement_id, date_naissance, nb_nes, nb_vivants, nb_morts, lot_sevrage_id

**Soins** :
- id, date, type (lot/individu), cible_id, nature, produit, dosage, observations

**Transactions** :
- id, date, type (recette/depense), montant, categorie, description, lot_id, lapin_id

## 9. LIVRABLES

### 9.1 Application Flutter
- Fichier APK signé et optimisé
- Code source Flutter documenté
- Architecture des widgets et état documentée
- Configuration des packages tiers utilisés
- Base de données SQLite avec données de test et rituels pré-configurés

### 9.2 Documentation Flutter
- Manuel utilisateur avec focus sur les rituels
- Guide de démarrage rapide (première semaine)
- Documentation technique Flutter
- Guide de setup de l'environnement de développement
- Documentation de l'architecture des données
- Procédures de build et déploiement

### 9.3 Support
- FAQ intégrée à l'application
- Tutoriels vidéo des rituels quotidiens
- Support par email pendant 6 mois

## 10. PLANNING ET BUDGET

### 10.1 Phases de développement Flutter

1. **Setup et architecture Flutter** : 1 semaine
   - Configuration de l'environnement Flutter
   - Structure du projet et architecture de données
   - Configuration des packages essentiels

2. **Modèles de données et base SQLite** : 2 semaines
   - Création des modèles Dart (lots, lapins, rituels, observations, etc.)
   - Setup de la base SQLite avec sqflite
   - DAO (Data Access Objects) et repositories

3. **Interface utilisateur Flutter** : 5 semaines
   - Écran principal "Rituels quotidiens"
   - "Miroir de rigueur" (dashboard transformé)
   - Gestion des lots et individus
   - Widgets personnalisés réutilisables
   - Navigation et routing
   - Responsive design

4. **Logique métier et fonctionnalités** : 4 semaines
   - Gestion d'état (Provider/Riverpod)
   - Système de rituels et automatisation
   - Observation guidée avec boutons simples
   - Fonctionnalités de reproduction et santé
   - Génération de rapports et exports
   - Système de notifications pédagogiques

5. **Tests et optimisations Flutter** : 2 semaines
   - Tests unitaires et d'intégration
   - Tests de performance (< 1s pour actions courantes)
   - Tests utilisateurs (validation ergonomie)
   - Optimisation de l'app (taille, vitesse)

6. **Build et livraison** : 1 semaine
   - Build de production Android
   - Documentation complète
   - Génération de l'APK signé

**Durée totale estimée** : 15 semaines

### 10.2 Jalons principaux Flutter
- Validation de l'architecture Flutter : Semaine 1
- Modèles de données et SQLite opérationnels : Semaine 3
- Interface "Rituels" fonctionnelle : Semaine 6
- Système d'observation guidée : Semaine 8
- Version alpha (rituels + lots + observations) : Semaine 11
- Version bêta complète : Semaine 13
- Version finale Android : Semaine 15

### 10.3 Budget estimé
- Développement : À définir selon le prestataire
- Tests : Inclus dans le développement
- Maintenance première année : 15% du coût de développement

## 11. CRITÈRES D'ACCEPTATION

### 11.1 Fonctionnels
- ✅ Système de rituels quotidiens opérationnel
- ✅ Observation guidée avec boutons simples
- ✅ Gestion par lots + exceptions individuelles
- ✅ Documentation automatique fonctionnelle
- ✅ "Miroir de rigueur" avec indicateurs de discipline
- ✅ Notifications pédagogiques actives
- ✅ Actions en maximum 2 clics
- ✅ Import/export de données fonctionnel

### 11.2 Techniques
- ✅ Application stable sans crash
- ✅ Temps de réponse < 1 seconde pour actions courantes
- ✅ Temps de réponse < 2 secondes pour rapports
- ✅ Consommation mémoire optimisée
- ✅ Compatibilité Android 7.0+

### 11.3 Ergonomiques et pédagogiques
- ✅ Interface validée par tests utilisateurs réels (éleveurs africains)
- ✅ Navigation en maximum 2 clics pour actions quotidiennes
- ✅ Saisie réduite au minimum (privilégier les boutons)
- ✅ Messages éducatifs discrets et pertinents
- ✅ Création d'habitudes mesurée sur 2 semaines de test

### 11.4 Impact sur les pratiques
- ✅ Utilisateurs testeurs effectuent les rituels quotidiens
- ✅ Augmentation mesurable de la fréquence d'observation
- ✅ Diminution des anomalies non suivies
- ✅ Feedback positif sur l'aspect "coach"

## 12. MAINTENANCE ET ÉVOLUTIONS

### 12.1 Maintenance corrective
- Correction de bugs pendant 12 mois
- Mises à jour de sécurité
- Adaptation aux nouvelles versions Android
- Amélioration continue des rituels selon retours utilisateurs

### 12.2 Évolutions possibles (Phase 2)

**Extensions métier** :
- Ajout de nouvelles espèces d'animaux
- Module de gestion des aliments et rationnement avancé
- Intégration avec des balances connectées
- Templates de rituels par type d'élevage

**Améliorations du système de rituels** :
- Rituels adaptatifs selon saison et contexte
- Rituels collaboratifs (si passage multi-utilisateurs)
- IA pour détection d'anomalies via photos
- Synchronisation avec calendriers externes

**Dimension communautaire** (long terme) :
- Partage anonyme de statistiques de rigueur
- Benchmarking entre éleveurs
- Base de connaissances collaborative
- Conseils d'éleveurs expérimentés

---

**Version du document** : 2.0  
**Date** : Janvier 2026  
**Statut** : Cahier des charges mis à jour avec philosophie "Coach & Rituels"  

## ANNEXE : DIFFÉRENCES CLÉS AVEC VERSION 1.0

### Ce qui change fondamentalement :

1. **Philosophie** : De "outil de gestion" à "coach quotidien créateur d'habitudes"
2. **Écran principal** : De "dashboard statistiques" à "rituels du jour"
3. **Gestion** : De "tout individuel" à "lots + exceptions"
4. **Saisie** : De "formulaires" à "boutons simples + automatisation"
5. **Notifications** : De "alarmes" à "messages pédagogiques"
6. **Dashboard** : De "vue des données" à "miroir de rigueur"
7. **Priorité** : L'observation guidée quotidienne avant tout le reste

### Ce qui reste :
- Stack technique Flutter inchangée
- Stockage local SQLite
- Fonctionnalités de reproduction et santé
- Gestion financière
- Exports et rapports