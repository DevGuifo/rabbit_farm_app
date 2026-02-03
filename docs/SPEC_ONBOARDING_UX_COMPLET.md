# Spécification UX Onboarding BunnyManager

**Version** : 2.0  
**Date** : 3 février 2026  
**Auteur** : Architecte Produit UX Senior  
**Durée cible** : < 3 minutes (2 minutes optimal)

---

## 📊 Diagnostic de l'Onboarding Actuel

### Problèmes identifiés

| Problème | Impact UX | Sévérité |
|----------|-----------|----------|
| Trop textuel (champs libres nom ferme, région, pays) | Fatigue utilisateur, friction | 🔴 Élevée |
| Pas de valeurs utiles collectées (monnaie, unités, objectifs) | Données inutilisables plus tard | 🔴 Élevée |
| Écrans informationnels sans vraie valeur (Synchronisation) | Perte de temps | 🟠 Moyenne |
| Aucune personnalisation contextuelle | App générique pour tous | 🟠 Moyenne |
| Pas d'explication "à quoi ça sert" | Motivation faible | 🟡 Légère |

### Données actuelles vs. utilisées

| Donnée collectée | Réellement utilisée ? |
|------------------|----------------------|
| Type d'élevage | ❌ Jamais consulté dans l'app |
| Nom ferme | ⚠️ Affiché mais non requis |
| Région/Pays | ❌ Jamais utilisé |
| Rôle utilisateur | ⚠️ Existe dans UserRole mais non lié |
| Niveau expérience | ❌ Jamais utilisé |
| Taille élevage | ❌ Jamais utilisé |

**Verdict** : L'onboarding actuel collecte des données qui ne servent à rien tout en omettant celles qui seraient utiles.

---

## 📋 ÉTAPE 1 — DONNÉES À RECUEILLIR

### Classification des données

#### 🔴 CRITIQUES (obligatoires)

| Donnée | Justification métier | Où utilisée |
|--------|---------------------|-------------|
| **Type d'élevage** | Personnalise les recommandations, seuils d'alertes | Dashboard, alertes, rapports |
| **Taille approximative** | Adapte l'interface (vue lot vs individu) | Navigation, suggestions |
| **Objectif principal** | Oriente les KPIs affichés | Dashboard, priorités |
| **Monnaie** | Affichage financier correct | Finance, rapports PDF |

#### 🟠 RECOMMANDÉES (fortement suggérées)

| Donnée | Justification métier | Où utilisée |
|--------|---------------------|-------------|
| **Unité de poids** | Éviter confusion kg/lb | Pesées, fiches lapins |
| **Races élevées** | Pré-remplir les formulaires, conseils | Ajout lapin, glossaire |
| **Notifications préférées** | Respecter le choix utilisateur | NotificationService |
| **Niveau d'expérience** | Adapter les aides contextuelles | Glossaire, tips |

#### 🟢 OPTIONNELLES (skip possible)

| Donnée | Justification métier | Où utilisée |
|--------|---------------------|-------------|
| Nom de l'élevage | Personnalisation affichage | Header, rapports PDF |
| Photo de profil | Expérience personnalisée | Paramètres |
| Localisation (région) | Stats régionales futures | Analytics (V2) |

---

## 🎨 ÉTAPE 2 — COMPOSANTS FLUTTER IDÉAUX

### Mapping donnée → composant optimal

| Donnée | Composant recommandé | Pourquoi |
|--------|---------------------|----------|
| **Type d'élevage** | `SelectableCard` (3 cartes illustrées) | Visuel, 1 tap = sélection |
| **Taille élevage** | `ChoiceChips` ou `Slider` avec paliers | Rapide, pas de clavier |
| **Objectif principal** | `SelectableCard` (4 cartes avec icônes) | Engagement émotionnel |
| **Monnaie** | `DropdownButton` avec flag + symbole | 95% des users = 1 pays |
| **Unité poids** | `SegmentedButton` (kg / lb) | 2 options = toggle |
| **Races élevées** | `FilterChip` multi-select avec "Autre" | Sélection rapide, expansible |
| **Notifications** | `SwitchListTile` par catégorie | Standard mobile attendu |
| **Niveau expérience** | `SelectableCard` (3 niveaux) | Visuel, valorisant |
| **Nom élevage** | `TextField` avec placeholder intelligent | Optionnel, 1 champ max |

### Composants à ÉVITER

| Composant | Pourquoi l'éviter |
|-----------|------------------|
| `TextField` multiple | Fatigue de saisie |
| `DatePicker` | Pas de date à collecter ici |
| `Form` complexe | Impression de paperasse |
| `Stepper` vertical | Trop technique |

---

## 🗺️ ÉTAPE 3 — PARCOURS D'ONBOARDING

### Vue d'ensemble du nouveau parcours

```
┌─────────────────────────────────────────────────────────────────┐
│                    NOUVEAU FLUX (6 écrans)                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Bienvenue      → 2. Mon élevage    → 3. Mes objectifs       │
│     (5 sec)           (30 sec)            (20 sec)              │
│     [SKIP: non]       [SKIP: non]         [SKIP: non]           │
│                                                                  │
│  4. Préférences    → 5. Notifications  → 6. Prêt !              │
│     (20 sec)          (15 sec)            (10 sec)              │
│     [SKIP: oui]       [SKIP: oui]         [SKIP: non]           │
│                                                                  │
│              TOTAL ESTIMÉ: 1 min 40 sec à 2 min 30 sec          │
└─────────────────────────────────────────────────────────────────┘
```

---

### Écran 1 : Bienvenue 🎉

**Objectif** : Créer une connexion émotionnelle, rassurer

**Durée** : 5 secondes

**Contenu** :
- Animation Lottie d'un lapin sympathique
- Titre : "Bienvenue dans BunnyManager !"
- Sous-titre : "Quelques questions pour personnaliser votre expérience"
- Badge vert : "🔒 Vos données restent sur votre appareil"
- Bouton unique : **"C'est parti !"**

**Données collectées** : Aucune

**Skip** : Non (écran de transition)

**Composant principal** : `AnimatedContainer` + `LottieAnimation`

---

### Écran 2 : Mon élevage 🐰

**Objectif** : Comprendre le contexte métier de l'utilisateur

**Durée** : 30 secondes

**Contenu** :

```
┌────────────────────────────────────────┐
│  🐰 Parlez-nous de votre élevage       │
│                                        │
│  ═══════════════════════════════════   │
│  TYPE D'ÉLEVAGE                        │
│  ┌──────────┐ ┌──────────┐ ┌────────┐  │
│  │  🏠      │ │  🏪      │ │  🏭    │  │
│  │ Familial │ │ Semi-pro │ │  Pro   │  │
│  │ <50 🐇   │ │ 50-200   │ │ >200   │  │
│  └──────────┘ └──────────┘ └────────┘  │
│                                        │
│  ═══════════════════════════════════   │
│  COMBIEN DE LAPINS ?                   │
│  ○ Moins de 20                         │
│  ○ 20 à 50                             │
│  ○ 50 à 100                            │
│  ○ 100 à 300                           │
│  ○ Plus de 300                         │
│                                        │
│  💡 Cela nous aide à adapter           │
│     l'interface à votre réalité        │
│                                        │
│  [Précédent]            [Suivant →]    │
└────────────────────────────────────────┘
```

**Données collectées** :
| Champ | Type | Stockage |
|-------|------|----------|
| `type_elevage` | `TypeElevage` enum | Table `farms` |
| `taille_elevage` | `TailleElevage` enum | Table `farms` |

**Skip** : Non (critique)

**Composants** : 
- `SelectableCard` pour type (3 cartes horizontales)
- `RadioListTile` stylisé pour taille

**Feedback visuel** : Check vert animé sur sélection

---

### Écran 3 : Mes objectifs 🎯

**Objectif** : Personnaliser le dashboard et les priorités

**Durée** : 20 secondes

**Contenu** :

```
┌────────────────────────────────────────┐
│  🎯 Quel est votre objectif principal? │
│                                        │
│  Choisissez 1 ou 2 priorités           │
│                                        │
│  ┌─────────────────┐ ┌───────────────┐ │
│  │  💰             │ │  📈           │ │
│  │  Rentabilité    │ │  Croissance   │ │
│  │  Optimiser      │ │  Agrandir mon │ │
│  │  mes marges     │ │  cheptel      │ │
│  └─────────────────┘ └───────────────┘ │
│                                        │
│  ┌─────────────────┐ ┌───────────────┐ │
│  │  🏆             │ │  📊           │ │
│  │  Qualité        │ │  Suivi        │ │
│  │  Sélection      │ │  Garder une   │ │
│  │  génétique      │ │  trace de tout│ │
│  └─────────────────┘ └───────────────┘ │
│                                        │
│  💡 Nous afficherons les KPIs adaptés  │
│                                        │
│  [Précédent]            [Suivant →]    │
└────────────────────────────────────────┘
```

**Données collectées** :
| Champ | Type | Stockage |
|-------|------|----------|
| `objectifs_principaux` | `List<ObjectifElevage>` | Table `user_profiles` (nouveau) |

**Enum suggéré** :
```dart
enum ObjectifElevage {
  rentabilite,    // 💰 Focus finances
  croissance,     // 📈 Focus reproduction
  qualite,        // 🏆 Focus génétique/sélection
  suivi,          // 📊 Focus traçabilité
}
```

**Skip** : Non (critique pour personnalisation)

**Composants** : `ChoiceChip` multi-select (max 2)

---

### Écran 4 : Préférences ⚙️

**Objectif** : Configurer les paramètres régionaux

**Durée** : 20 secondes

**Contenu** :

```
┌────────────────────────────────────────┐
│  ⚙️ Vos préférences                    │
│                                        │
│  ═══════════════════════════════════   │
│  MONNAIE                               │
│  ┌──────────────────────────────────┐  │
│  │  🇫🇷  Euro (€)               ▼   │  │
│  └──────────────────────────────────┘  │
│                                        │
│  ═══════════════════════════════════   │
│  UNITÉ DE POIDS                        │
│  ┌────────────┐ ┌────────────┐         │
│  │     kg     │ │     lb     │         │
│  └────────────┘ └────────────┘         │
│                                        │
│  ═══════════════════════════════════   │
│  RACES ÉLEVÉES (optionnel)             │
│  ┌──────┐ ┌──────────┐ ┌───────────┐   │
│  │ NZ   │ │ Californie│ │ Rex      │   │
│  └──────┘ └──────────┘ └───────────┘   │
│  ┌──────────┐ ┌──────────┐ ┌───────┐   │
│  │ Géant Fl.│ │ Fauve Bour│ │ Autre │   │
│  └──────────┘ └──────────┘ └───────┘   │
│                                        │
│  [Passer]               [Suivant →]    │
└────────────────────────────────────────┘
```

**Données collectées** :
| Champ | Type | Stockage |
|-------|------|----------|
| `monnaie` | `String` (code ISO) | `SharedPreferences` |
| `unite_poids` | `String` ('kg' / 'lb') | `SharedPreferences` |
| `races_elevees` | `List<String>` | Table `farms` (nouveau) |

**Skip** : Oui (valeurs par défaut : EUR, kg)

**Composants** :
- `DropdownButton` avec drapeaux pour monnaie
- `SegmentedButton` pour poids
- `FilterChip` wrap pour races

---

### Écran 5 : Notifications 🔔

**Objectif** : Respecter le choix utilisateur dès le départ

**Durée** : 15 secondes

**Contenu** :

```
┌────────────────────────────────────────┐
│  🔔 Quand vous prévenir ?              │
│                                        │
│  Activez les rappels qui vous aident   │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │  🩺 Santé                     🔘 │  │
│  │  Vaccinations, traitements       │  │
│  └──────────────────────────────────┘  │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │  🐣 Reproduction              🔘 │  │
│  │  Mises bas, sevrages à venir     │  │
│  └──────────────────────────────────┘  │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │  ⚠️ Alertes critiques         🔘 │  │
│  │  Mortalité, anomalies            │  │
│  └──────────────────────────────────┘  │
│                                        │
│  💡 Modifiable à tout moment dans      │
│     Paramètres > Notifications         │
│                                        │
│  [Passer]               [Suivant →]    │
└────────────────────────────────────────┘
```

**Données collectées** :
| Champ | Type | Stockage |
|-------|------|----------|
| `notif_sante` | `bool` | `SharedPreferences` |
| `notif_reproduction` | `bool` | `SharedPreferences` |
| `notif_alertes` | `bool` | `SharedPreferences` |

**Skip** : Oui (tout activé par défaut)

**Composants** : `SwitchListTile` stylisé avec icônes

---

### Écran 6 : Prêt ! 🚀

**Objectif** : Transition fluide vers l'app, petit récap

**Durée** : 10 secondes

**Contenu** :

```
┌────────────────────────────────────────┐
│                                        │
│           ✅ Tout est prêt !           │
│                                        │
│           [Animation Lottie]           │
│           Confettis / Lapin            │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │  📋 Récapitulatif                │  │
│  │  • Élevage familial              │  │
│  │  • ~30 lapins                    │  │
│  │  • Focus: Rentabilité            │  │
│  │  • Monnaie: EUR (€)              │  │
│  └──────────────────────────────────┘  │
│                                        │
│  💡 Conseil de départ :                │
│  "Commencez par ajouter vos           │
│   reproducteurs actuels"              │
│                                        │
│        [Découvrir BunnyManager]        │
│                                        │
└────────────────────────────────────────┘
```

**Données collectées** : Aucune (récapitulatif)

**Action** : Marquer onboarding terminé + naviguer vers Home

**Skip** : Non (écran final obligatoire)

**Composants** : `LottieAnimation` + `Card` récapitulative

---

## 🔗 ÉTAPE 4 — COHÉRENCE AVEC LE MODÈLE

### Mapping données → modèles existants

| Donnée onboarding | Modèle cible | Champ | Action requise |
|-------------------|--------------|-------|----------------|
| `type_elevage` | `Farm` | `typeElevage` | ✅ Existe |
| `taille_elevage` | `Farm` | `tailleElevage` | ✅ Existe |
| `objectifs` | `UserProfile` | ❌ N'existe pas | ⚠️ À ajouter |
| `monnaie` | `SharedPreferences` | `currency` | ⚠️ À ajouter |
| `unite_poids` | `SharedPreferences` | `weight_unit` | ⚠️ À ajouter |
| `races_elevees` | `Farm` | ❌ N'existe pas | ⚠️ À ajouter |
| `notif_*` | `SharedPreferences` | Partiellement | ⚠️ À unifier |

### Modifications de modèles requises

#### 1. `UserProfile` (enrichir)
```dart
class UserProfile {
  // ... existant ...
  final List<ObjectifElevage>? objectifs; // NOUVEAU
}
```

#### 2. `Farm` (enrichir)
```dart
class Farm {
  // ... existant ...
  final List<String>? racesElevees; // NOUVEAU
}
```

#### 3. Nouvelles clés `SharedPreferences`
```dart
// Préférences régionales
const String kCurrency = 'user_currency';           // 'EUR', 'XOF', 'USD'
const String kWeightUnit = 'user_weight_unit';      // 'kg', 'lb'

// Notifications granulaires
const String kNotifSante = 'notif_sante';
const String kNotifReproduction = 'notif_reproduction';
const String kNotifAlertes = 'notif_alertes_critiques';
```

### Utilisation dans l'app

| Écran/Service | Donnée utilisée | Impact |
|---------------|-----------------|--------|
| `DashboardScreen` | `objectifs` | KPIs affichés en priorité |
| `FinanceScreen` | `monnaie` | Symbole correct (€, FCFA, $) |
| `LapinCard` | `unite_poids` | Affichage poids sans confusion |
| `AjouterLapinScreen` | `racesElevees` | Dropdown pré-rempli |
| `NotificationService` | `notif_*` | Canaux activés/désactivés |
| `HomeScreen` | `type_elevage` + `taille` | Suggestions adaptées |

---

## 📐 ÉTAPE 5 — RECOMMANDATIONS UX

### Principes de design

| Principe | Application |
|----------|-------------|
| **1 idée = 1 écran** | Max 2 questions par écran |
| **Feedback immédiat** | Animation check sur chaque sélection |
| **Progression visible** | Barre + pastilles numérotées |
| **Texte minimal** | Titre + 1 ligne explicative max |
| **Skip non punitif** | Valeurs par défaut intelligentes |

### Micro-interactions recommandées

| Action | Feedback |
|--------|----------|
| Sélection carte | Scale 1.02 + bordure colorée + check animé |
| Toggle switch | Haptic feedback léger |
| Bouton Suivant | Ripple + transition slide |
| Écran final | Confettis Lottie 1.5 sec |

### Accessibilité

- Contraste AA minimum sur tous les textes
- Touch targets ≥ 48dp
- Labels explicites pour screen readers
- Navigation clavier possible

### Gestion des erreurs

| Scénario | Comportement |
|----------|--------------|
| Aucune sélection sur écran obligatoire | Bouton Suivant grisé + tooltip |
| Perte de connexion | Sans impact (offline-first) |
| Fermeture app en cours | Reprise à l'étape courante |

---

## 📊 Récapitulatif des écrans

| # | Nom | Données | Composants | Skip | Durée |
|---|-----|---------|------------|------|-------|
| 1 | Bienvenue | - | Lottie, Button | ❌ | 5s |
| 2 | Mon élevage | type, taille | Cards, Radio | ❌ | 30s |
| 3 | Mes objectifs | objectifs | ChoiceChips | ❌ | 20s |
| 4 | Préférences | monnaie, poids, races | Dropdown, Segment, Chips | ✅ | 20s |
| 5 | Notifications | notif_* | SwitchTiles | ✅ | 15s |
| 6 | Prêt ! | - | Lottie, Card | ❌ | 10s |

**Total** : 6 écrans, ~2 minutes, 4 skippables

---

## 🔄 Migration depuis l'onboarding actuel

### Écrans actuels → nouveaux

| Ancien | Nouveau | Notes |
|--------|---------|-------|
| Présentation | Bienvenue | Réduit, plus visuel |
| Type élevage | Mon élevage | Fusionné avec taille |
| Infos ferme | Préférences | Remplacé par données utiles |
| Profil utilisateur | Mes objectifs | Refocalisé sur objectifs |
| Synchronisation | ❌ Supprimé | Géré ailleurs |
| - | Notifications | NOUVEAU |
| - | Prêt ! | NOUVEAU (récap) |

### Tables DB à migrer

```sql
-- Ajouter colonne objectifs (JSON array)
ALTER TABLE user_profiles ADD COLUMN objectifs TEXT;

-- Ajouter colonne races (JSON array)
ALTER TABLE farms ADD COLUMN races_elevees TEXT;
```

---

## ✅ Checklist d'implémentation

### Phase 1 : Modèles & DB
- [ ] Ajouter `ObjectifElevage` enum
- [ ] Enrichir `UserProfile` avec `objectifs`
- [ ] Enrichir `Farm` avec `racesElevees`
- [ ] Migration DB (version +1)
- [ ] Clés SharedPreferences

### Phase 2 : Provider
- [ ] Mettre à jour `OnboardingProvider`
- [ ] Nouvelles méthodes `saveObjectifs()`, `savePreferences()`
- [ ] Validation des données

### Phase 3 : Écrans
- [ ] `WelcomeScreen` (nouveau)
- [ ] `ElevageScreen` (refonte)
- [ ] `ObjectifsScreen` (nouveau)
- [ ] `PreferencesScreen` (nouveau)
- [ ] `NotificationsScreen` (nouveau)
- [ ] `ReadyScreen` (nouveau)

### Phase 4 : Intégration
- [ ] Utiliser `monnaie` dans Finance
- [ ] Utiliser `unite_poids` dans affichages
- [ ] Utiliser `objectifs` dans Dashboard
- [ ] Tester flux complet

---

## 📎 Annexes

### A. Valeurs par défaut

| Préférence | Défaut | Raison |
|------------|--------|--------|
| Monnaie | EUR (€) | Marché cible France/Belgique |
| Unité poids | kg | Standard métrique |
| Notifications | Toutes ON | Meilleure expérience par défaut |
| Objectifs | `[suivi]` | Cas le plus général |

### B. Monnaies suggérées

| Code | Symbole | Pays |
|------|---------|------|
| EUR | € | France, Belgique, etc. |
| XOF | FCFA | Afrique de l'Ouest |
| XAF | FCFA | Afrique Centrale |
| MAD | DH | Maroc |
| TND | DT | Tunisie |
| USD | $ | International |

### C. Races pré-remplies

```dart
const List<String> racesCommunes = [
  'Néo-Zélandais',
  'Californien',
  'Rex',
  'Géant des Flandres',
  'Fauve de Bourgogne',
  'Papillon',
  'Bélier Français',
  'Argenté de Champagne',
  'Autre',
];
```

---

*Document de référence pour l'implémentation de l'onboarding V2. Ne pas générer de code à partir de ce document sans validation produit.*
