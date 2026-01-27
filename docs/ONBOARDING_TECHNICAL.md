# Onboarding Post-Compte - Résumé Technique

## Vue d'ensemble

L'onboarding post-compte est une séquence de 5 écrans affichée **obligatoirement** après la création/connexion du compte, avant l'accès aux fonctionnalités métier.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         FLUX D'ONBOARDING                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  AuthScreen → PinSetupScreen → OnboardingMainScreen → HomeScreen │
│         ↓                              ↓                         │
│     Sign Up                    5 Écrans séquentiels              │
│     Sign In                                                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Fichiers Clés

### Écrans (lib/screens/onboarding/)
| Fichier | Description |
|---------|-------------|
| `onboarding_main_screen.dart` | Contrôleur principal, aiguillage vers l'étape courante |
| `presentation_screen.dart` | Écran 1 - Présentation simple |
| `type_elevage_screen.dart` | Écran 2 - Sélection type d'élevage |
| `informations_ferme_screen.dart` | Écran 3 - Informations ferme (optionnelles) |
| `profil_utilisateur_screen.dart` | Écran 4 - Profil utilisateur (optionnel) |
| `synchronisation_screen.dart` | Écran 5 - Consentement synchronisation |

### Modèles (lib/models/)
| Fichier | Description |
|---------|-------------|
| `farm.dart` | Données ferme + enums (TypeElevage, TailleElevage, NiveauExperience) |
| `user_profile.dart` | Profil utilisateur + enum RoleUtilisateur |
| `onboarding_status.dart` | État de progression + enum OnboardingStep |

### Provider (lib/providers/)
| Fichier | Méthodes principales |
|---------|---------------------|
| `onboarding_provider.dart` | `loadOnboardingStatus()`, `nextStep()`, `saveFarmInfo()`, `saveUserProfile()`, `updateSyncPreferences()`, `completeOnboarding()` |

### Utilitaire (lib/utils/)
| Fichier | Méthodes principales |
|---------|---------------------|
| `onboarding_navigation_helper.dart` | `navigateBasedOnOnboardingStatus()`, `completeOnboardingAndNavigate()`, `isOnboardingRequired()` |

## Base de données (SQLite)

### Tables créées
```sql
-- Table farms
CREATE TABLE farms (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  nom TEXT,
  region TEXT,
  pays TEXT,
  type_elevage TEXT NOT NULL,
  taille_elevage TEXT,
  date_creation TEXT NOT NULL,
  date_modification TEXT
);

-- Table user_profiles
CREATE TABLE user_profiles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  role TEXT,
  niveau_experience TEXT,
  date_creation TEXT NOT NULL,
  date_modification TEXT
);

-- Table onboarding_status
CREATE TABLE onboarding_status (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER UNIQUE,
  etape_actuelle TEXT NOT NULL DEFAULT 'non_demarre',
  est_termine INTEGER NOT NULL DEFAULT 0,
  synchronisation_autorisee INTEGER NOT NULL DEFAULT 1,
  date_creation TEXT NOT NULL,
  date_modification TEXT,
  date_termine TEXT
);
```

## Points d'intégration

### 1. Après inscription (auth_screen.dart)
```dart
// Après sign up réussi → PinSetupScreen
Navigator.pushReplacement(context, MaterialPageRoute(
  builder: (_) => const PinSetupScreen(),
));
```

### 2. Après configuration PIN (pin_setup_screen.dart)
```dart
// Après PIN configuré → Vérification onboarding
await OnboardingNavigationHelper.navigateBasedOnOnboardingStatus(context);
```

### 3. Après validation PIN (pin_screen.dart)
```dart
// Après PIN validé → Vérification onboarding
OnboardingNavigationHelper.navigateBasedOnOnboardingStatus(context);
```

### 4. Fin d'onboarding (synchronisation_screen.dart)
```dart
// Terminer et aller à HomeScreen
await OnboardingNavigationHelper.completeOnboardingAndNavigate(context);
```

## États d'onboarding (OnboardingStep)

| Étape | Valeur | Progression |
|-------|--------|-------------|
| Non démarré | `nonDemarre` | 0% |
| Présentation | `presentation` | 16% |
| Type d'élevage | `typeElevage` | 32% |
| Infos ferme | `informationsFerme` | 48% |
| Profil utilisateur | `profilUtilisateur` | 64% |
| Synchronisation | `synchronisation` | 80% |
| Terminé | `termine` | 100% |

## Règles métier

1. **Non skippable en V1** : `peutEtreSkip` retourne toujours `false`
2. **Données optionnelles** : Seul le type d'élevage est obligatoire
3. **Synchronisation par défaut** : Activée mais désactivable
4. **Offline-first** : Tout fonctionne sans connexion

## Tests recommandés

1. ✅ Création compte → Onboarding affiché
2. ✅ Reconnexion après onboarding → HomeScreen direct
3. ✅ Navigation arrière dans onboarding → Fonctionne
4. ✅ Données sauvegardées en local
5. ✅ Reprise à l'étape courante après fermeture app

## Dépendances

- `provider` : Gestion d'état
- `sqflite` : Base de données locale
- Aucune dépendance externe pour l'onboarding

---

*Dernière mise à jour : Janvier 2026*
