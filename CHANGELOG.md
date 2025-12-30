# Changelog - BunnyManager

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Non publié]

### À venir
- Dashboard central avec KPIs
- Recherche globale (lapins, cages, accouplements)
- Simplification workflow reproduction

---

## [1.1.1] - 2025-01-XX (Phase 0 - Sécurisation Git)

### Modifié
- **Git** : Nettoyage complet du repository
  - Suppression de 12 fichiers temporaires obsolètes
  - Amélioration du `.gitignore` pour ignorer scripts temporaires
  - Organisation de la documentation dans `docs/historique/`
- **Documentation** : Déplacement des fichiers temporaires (scripts Python, shell)

### Technique
- Repository Git propre et professionnel
- Structure de branches : `master` (stable) / `develop` (travail quotidien)

---

## [1.1.0] - 2024-12-21 (Phase P0 Complète)

### Ajouté
- **P0.1** : Navigation globale depuis notifications vers fiches lapins
- **P0.2** : Sauvegarde date dernière backup dans SharedPreferences
- **P0.3** : Navigation calendrier vers fiche lapin
- **P0.4** : Compression ZIP pour exports/imports
- **P0.5** : Gestion robuste des erreurs PhotoService (exceptions typées)
- **P0.6** : Logger professionnel (remplacement de tous les `print()`)

### Modifié
- Amélioration UX navigation (contexte conservé)
- Refactoring système de notifications

### Corrigé
- Bugs navigation calendrier
- Erreurs photo service (permissions, fichiers manquants)

---

## [1.0.0] - 2024-11-16 (Première release stable)

### Ajouté
- Gestion complète du cheptel (CRUD lapins)
- Suivi santé (pesées, soins, vaccinations)
- Module reproduction (accouplements, portées, sevrages)
- Gestion financière (recettes, dépenses, statistiques)
- Modules optimisation (courbes, palpations, préparation nids)
- Utilitaires (calculatrice, calendrier, exports PDF)
- Architecture MVVM avec 17 providers
- Base SQLite avec 9 tables relationnelles
- Thème Material 3 (light/dark)
- Tests unitaires (models, services)

### Technique
- Flutter SDK 3.9.2+
- SQLite version 5 (migrations automatiques)
- Architecture offline-first
- Gestion photos locale

---

## [0.1.0] - 2024-11-13 (Projet initialisé)

### Ajouté
- Création du projet Flutter
- Structure de base (lib/, assets/, test/)
- Configuration multi-plateforme (Android, iOS, Web)
- Mise en place Git

---

**Légende** :
- `Ajouté` : Nouvelles fonctionnalités
- `Modifié` : Changements dans fonctionnalités existantes
- `Déprécié` : Fonctionnalités bientôt supprimées
- `Supprimé` : Fonctionnalités retirées
- `Corrigé` : Corrections de bugs
- `Sécurité` : Correctifs de vulnérabilités

