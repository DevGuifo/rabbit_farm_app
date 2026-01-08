# 🐰 BunnyManager - Gestion d'Élevage Cunicole

<img src="assets/logo/logo.png" alt="BunnyManager Logo" width="200"/>

**Version :** 1.2.0+5  
**Date :** 8 janvier 2026  
**Status :** ✅ Production Ready (i18n 100% FR/EN)

## 📱 Application Mobile Flutter

Application complète de gestion d'élevage de lapins avec :
- 🌍 **Support multilingue** (Français, Anglais) - Internationalisation 100%
- 📊 **Suivi santé, reproduction, finances** - Gestion offline-first SQLite
- 📈 **Tableau de bord avec KPI temps réel** - Statistiques exploitables
- 🔒 **Mode offline-first** - Aucune connexion requise
- 📄 **Exports PDF professionnels** - Rapports, pedigrees, fiches lapins
- 🎨 **Thème Material 3** - Light/Dark modes adaptatifs

## 🏆 Accomplissements Récents

✅ **Internationalisation 100%** (Phase P1.2 - Janvier 2026)  
✅ **30 chaînes dialogues FR/EN** internationalisées  
✅ **Build release validé** (79.7 MB APK, 0 erreur)  
✅ **Workflow Git simplifié** pour non-développeur  

Voir [Rapport Final GO/NO-GO](docs/rapports/RAPPORT_FINAL_GO_NOGO_V1.md)

## 📱 Fonctionnalités

- **Cheptel** : Gestion complète des lapins (identité, poids, généalogie, photos)
- **Santé** : Suivi vétérinaire, pesées, vaccinations, protocoles de soins
- **Reproduction** : Accouplements, portées, sevrages, pedigrees
- **Finances** : Recettes, dépenses, rentabilité, exports comptables
- **Optimisation** : Courbes de croissance, palpations, préparation nids
- **Utilitaires** : Calculatrices, calendrier, exports PDF, backups/restore

## 🏗 Architecture

- **Framework** : Flutter 3.9.2+ / Dart 3.9+
- **Base de données** : SQLite (offline-first) - 14 tables, 3167 lignes
- **State Management** : Provider (17 providers)
- **Pattern** : MVVM (Models → Services → Providers → Views)
- **Internationalisation** : flutter_localizations (5306+ clés FR/EN)
- **Backend optionnel** : Supabase (sync cloud)

## 📂 Structure du Projet

```
lib/
├── main.dart                    # Entry point (17 MultiProvider setup)
├── models/                      # Data models (Lapin, Pesee, Soin, Accouplement, etc.)
├── providers/                   # State management (17 ChangeNotifier providers)
├── services/                    # Business logic (DatabaseHelper, NotificationService, PdfService)
├── screens/                     # UI organisée par fonctionnalité
│   ├── cheptel/                # Gestion lapins, localisation
│   ├── sante/                  # Santé, pesées, vaccinations
│   ├── reproduction/           # Accouplements, portées, sevrages
│   ├── parametres/             # Settings, thème, langue
│   └── utilitaire/             # Calculatrices, exports
├── widgets/                     # Composants réutilisables (lapin_card, animations)
├── constants/                   # Constantes app
├── theme/                       # app_theme.dart (Material 3 light/dark)
├── l10n/                        # Fichiers i18n (app_fr.arb, app_en.arb)
└── utils/                       # Helpers (logger, formatters, pdf_generator)
```

## 🚀 Démarrage Rapide

### Prérequis
- **Flutter SDK** : 3.9.2+
- **Dart** : 3.9+
- **Android Studio** / VS Code
- **Git** (pour cloner le repository)

### Installation & Lancement

```bash
# 1. Cloner le repository
git clone https://github.com/DevGuifo/rabbit_farm_app.git
cd rabbit_farm_app

# 2. Installer les dépendances
flutter pub get

# 3. Lancer l'app en debug (hot reload activé)
flutter run

# 4. Build production Android (release)
flutter clean
flutter build apk --release
# APK disponible : build/app/outputs/flutter-apk/app-release.apk (~80 MB)
```

### Vérification Build

```bash
flutter analyze    # Linting (attendu: ~80 warnings info, 0 erreur)
flutter test       # Unit tests (si implémentés)
```

## 📚 Documentation

### Pour Non-Développeur
- **[Guide GitHub Simple](docs/guides/GUIDE_GITHUB_SIMPLE.md)** - 3 commandes Git essentielles pour propriétaire non-technique

### Pour Utilisateurs
- **[Guide Utilisateur](docs/guides/GUIDE_UTILISATEUR.md)** - Manuel complet de l'application
- **[Guide Test Application](docs/guides/GUIDE_TEST_APPLICATION.md)** - Procédures de test
- **[Guide Règles Métier](docs/guides/GUIDE_REGLES_METIER.md)** - Logique métier élevage

### Pour Développeurs
- **[Guide Synchronisation Supabase](docs/guides/GUIDE_SYNCHRONISATION_SUPABASE.md)** - Setup backend cloud
- **[Guide Thème Unifié](docs/guides/GUIDE_THEME_UNIFIE.md)** - Système Material 3
- **[Guide Dashboard](docs/guides/GUIDE_DASHBOARD.md)** - KPI et statistiques

### Rapports & Audits
- **[Rapport Final GO/NO-GO V1](docs/rapports/RAPPORT_FINAL_GO_NOGO_V1.md)** - Évaluation publication V1
- **[Rapport Phase P1.1 i18n](docs/rapports/RAPPORT_PHASE_P1.1_I18N_DIALOGUES.md)** - Internationalisation dialogues
- **[Rapport Phase P1.2 i18n](docs/rapports/RAPPORT_PHASE_P1.2_I18N_COMPLETE.md)** - i18n 100%

### Spécifications
- **[Cahier des Charges](docs/specifications/cahier_charges_app_elevage.md)** - Spécifications complètes
- **[Cahier des Charges V2](docs/specifications/cahier_charges_v2.md)** - Extensions prévues

### Archives
Documentation historique disponible dans [docs/archives/](docs/archives/)

## 🛠️ Stack Technique

| Domaine | Package | Version | Usage |
|---------|---------|---------|-------|
| **Database** | `sqflite` | ^2.3.0 | SQLite local (14 tables) |
| **State** | `provider` | ^6.1.0 | MVVM (17 providers) |
| **PDF** | `printing` | ^5.11.0 | Exports (fiches, pedigrees) |
| **Photos** | `image_picker` | ^1.0.7 | Capture/sélection images |
| **i18n** | `flutter_localizations` | SDK | FR/EN (5306+ clés) |
| **Notifications** | `flutter_local_notifications` | ^17.0.0 | Rappels vaccinations/accouplements |
| **Charts** | `fl_chart` | ^0.69.0 | Courbes croissance |
| **Dates** | `intl` | ^0.20.2 | Formatage FR (DD/MM/YYYY) |

## 🎨 Design & UX

- **Thème** : Material 3 (light/dark modes adaptatifs)
- **Palette** : Vert primaire (#4CAF50), interface minimaliste
- **Cible** : Éleveurs professionnels (terrain, environnements solaires)
- **Accessibilité** : Support grandes polices, contrastes WCAG AA

## 📦 Build Production

### Android APK (Release)

```bash
flutter clean
flutter pub get
flutter build apk --release

# APK disponible dans :
# build/app/outputs/flutter-apk/app-release.apk (~80 MB)
```

### iOS (si macOS disponible)

```bash
flutter build ios --release
# Nécessite Xcode et certificats Apple Developer
```

## 🤝 Contribution

Projet propriétaire privé - Contact : [DevGuifo](https://github.com/DevGuifo)

## 📄 Licence

Propriétaire © 2024-2026 BunnyManager

## 👤 Auteur

Développé par **DevGuifo** avec assistance GitHub Copilot

---

**Version actuelle** : 1.2.0+5 (Voir [CHANGELOG.md](CHANGELOG.md))  
**Dernière mise à jour** : 8 janvier 2026

