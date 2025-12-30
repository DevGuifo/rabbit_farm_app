# 🐰 BunnyManager - Gestion d'Élevage de Lapins

<img src="assets/logo/logo.png" alt="BunnyManager Logo" width="200"/>

**BunnyManager** est une application mobile Flutter offline-first pour la gestion complète d'élevages de lapins professionnels.

## 📱 Fonctionnalités

- **Cheptel** : Gestion des lapins (identité, poids, généalogie)
- **Santé** : Suivi vétérinaire, pesées, vaccinations
- **Reproduction** : Accouplements, portées, sevrages
- **Finances** : Recettes, dépenses, rentabilité
- **Optimisation** : Courbes de croissance, palpations, préparation nids
- **Utilitaires** : Calculatrice, calendrier, exports, rapports PDF

## 🏗 Architecture

- **Framework** : Flutter 3.9+
- **Database** : SQLite (offline-first)
- **State Management** : Provider
- **Pattern** : MVVM (Models-Views-ViewModels)

## 📂 Structure du projet

```
lib/
├── main.dart                    # Entry point
├── models/                      # Data models (Lapin, Pesee, etc.)
├── providers/                   # State management (17 providers)
├── services/                    # Business logic (DatabaseHelper, NotificationService)
├── screens/                     # UI par fonctionnalité
├── widgets/                     # Composants réutilisables
├── constants/                   # Constantes app
└── utils/                       # Helpers (logger, formatters)
```

## 🚀 Installation

### Prérequis
- Flutter SDK 3.9.2+
- Dart 3.9+
- Android Studio / Xcode (pour builds natifs)
- Git (pour la gestion de version)

### Commandes

```bash
# 1. Cloner le repository
git clone https://github.com/VOTRE_USERNAME/rabbit-farm-app.git
cd rabbit-farm-app

# 2. Installer les dépendances
flutter pub get

# 3. Vérifier que tout compile
flutter analyze

# 4. Lancer l'app en debug
flutter run

# 5. Build production Android
flutter build apk --release
```

### Mode Offline-First

L'application fonctionne **entièrement en mode offline** :
- Toutes les données sont stockées localement (SQLite)
- Aucune connexion Internet requise pour l'utilisation normale
- Synchronisation Supabase optionnelle (si configurée)

### Authentification

Deux modes d'authentification disponibles :
1. **Supabase** (si configuré) : Inscription/Connexion avec email
2. **PIN Offline** : Déverrouillage avec un code PIN (4-6 chiffres)

Pour utiliser le mode offline uniquement, configurez simplement un PIN lors du premier lancement.

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Analyse du code
flutter analyze
```

## 📝 Documentation

### Documentation principale
- [Cahier des charges](cahier_charges_app_elevage.md)
- [Changelog](CHANGELOG.md)
- [Guide utilisateur](GUIDE_UTILISATEUR.md)
- [Guide de test](GUIDE_TEST_APPLICATION.md)

### Documentation technique
- [Rapport d'audit technique](RAPPORT_AUDIT_TECHNIQUE_COMPLET.md)
- [Rapport final corrections](RAPPORT_FINAL_CORRECTIONS.md)
- [Guide Supabase](docs/SUPABASE_SETUP_GUIDE.md)
- [Migration Supabase](docs/MIGRATION_SUPABASE.md)

### Documentation historique
Les fichiers temporaires et anciens rapports sont dans `docs/historique/`

## 🛠 Technologies

| Domaine | Package | Version |
|---------|---------|---------|
| Database | `sqflite` | ^2.3.0 |
| State | `provider` | ^6.1.0 |
| PDF | `printing` | ^5.11.0 |
| Photos | `image_picker` | ^1.0.7 |
| Notifications | `flutter_local_notifications` | ^17.0.0 |
| Charts | `fl_chart` | ^0.69.0 |

## 🎨 Design

- **Thème** : Material 3 (light/dark modes)
- **Palette** : Vert primaire (#4CAF50), interface minimaliste
- **Cible** : Éleveurs professionnels (terrain, solaire)

## 📄 Licence

Ce projet est privé et non publié sur pub.dev.

## 👤 Auteur

Projet développé en solo avec GitHub Copilot.

## 📞 Support

Pour toute question : ouvrir une issue GitHub.

---

**Version actuelle** : 1.1.0+2 (Voir [CHANGELOG.md](CHANGELOG.md))

