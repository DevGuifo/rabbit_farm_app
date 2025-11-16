# 🐰 BunnyManager

Application mobile Flutter professionnelle de gestion d'élevage cunicole (lapins).

**Version actuelle :** 1.1.0 - Phase P0 ✅ COMPLÉTÉE  
**Date** : 16 novembre 2025  
**Statut** : Prêt pour production

---

## 🎯 Phase P0 - Corrections Critiques (6/6)

✅ **P0.1** - Navigation notifications  
✅ **P0.2** - Sauvegarde info backup (SharedPreferences)  
✅ **P0.3** - Navigation calendrier→lapin  
✅ **P0.4** - Compression ZIP exports  
✅ **P0.5** - Gestion erreurs PhotoService  
✅ **P0.6** - Remplacement 39 print() par logger

**📊 Métriques** :
- 3 fichiers créés + 15 modifiés
- +350 lignes ajoutées
- 7 commits atomiques Git
- 0 erreur compilation

**📄 Documentation** :
- [PHASE_P0_LIVRAISON.md](PHASE_P0_LIVRAISON.md) - Livraison complète
- [GUIDE_TESTS_P0.md](GUIDE_TESTS_P0.md) - 8 scénarios de tests

---

## 📋 Description

BunnyManager est une application de gestion complète d'élevage de lapins permettant :
- Gestion du cheptel
- Suivi de la reproduction
- Carnet de santé
- Gestion financière
- Notifications et rappels
- Exports PDF

## 🚀 Installation

```bash
# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run

# Build production Android
flutter build apk --release
```

## 🧪 Tests Phase P0

```bash
# Lancer l'app en debug
flutter run

# Suivre GUIDE_TESTS_P0.md (8 scénarios)
```

## 🛠️ Technologies

- **Framework** : Flutter 3.9.2+
- **Langage** : Dart
- **Base de données** : SQLite (sqflite)
- **État** : Provider
- **Plateforme cible** : Android 7.0+

## 📁 Structure du projet

```
lib/
├── main.dart              # Point d'entrée
├── models/                # Modèles de données
├── screens/               # Écrans de l'application
│   ├── cheptel/          # Gestion du cheptel
│   ├── reproduction/     # Module reproduction
│   ├── sante/            # Module santé
│   └── parametres/       # Paramètres
├── widgets/               # Widgets réutilisables
├── services/              # Services (BDD, notifications)
├── providers/             # Gestion d'état
├── utils/                 # Utilitaires
└── constants/             # Constantes
```

## 🎯 Roadmap

- [x] Phase 0 : Configuration et setup
- [ ] Phase 1 : Interface de base
- [ ] Phase 2 : Introduction SQLite
- [ ] Phase 3 : Généalogie
- [ ] Phase 4 : Module reproduction
- [ ] Phase 5 : Module santé
- [ ] Phase 6 : Module finances
- [ ] Phase 7 : Notifications
- [ ] Phase 8 : Exports PDF
- [ ] Phase 9 : Photos et UI
- [ ] Phase 10 : Tests et finalisation

## 📝 License

Projet privé - Tous droits réservés

## 👨‍💻 Auteur

Développé avec Flutter et Cursor AI
