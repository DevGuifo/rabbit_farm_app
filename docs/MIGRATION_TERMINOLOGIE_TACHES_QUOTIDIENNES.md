# 📋 MIGRATION TERMINOLOGIQUE : "Rituel" → "Tâches quotidiennes"

**Date** : 19 janvier 2026  
**Objectif** : Supprimer totalement le terme abstrait "Rituel" et le remplacer par une terminologie métier claire et professionnelle.  
**Statut** : **BLUEPRINT - EN ATTENTE D'EXÉCUTION**

---

## 🎯 PHILOSOPHIE DU CHANGEMENT

### Problème identifié
Le terme **"Rituel"** est :
- ❌ **Abstrait** : évoque des pratiques mystiques/religieuses
- ❌ **Non professionnel** : inadapté au contexte d'élevage
- ❌ **Ambigu** : ne décrit pas clairement l'action attendue

### Solution adoptée
**"Tâches quotidiennes"** ou **"Tâches du jour"** :
- ✅ **Concret** : décrit précisément l'activité
- ✅ **Professionnel** : terminologie métier reconnue
- ✅ **Clair** : l'utilisateur comprend immédiatement

---

## 📁 ÉTAPE 1 : RENOMMAGES DE FICHIERS

### ✅ DÉJÀ EFFECTUÉ

```powershell
# Modèles
models/rituel.dart                    → models/tache_quotidienne.dart
models/anomalie_rituel.dart           → models/anomalie_tache.dart

# Providers
providers/rituel_provider.dart        → providers/tache_provider.dart

# Repositories
repositories/rituel_repository.dart   → repositories/tache_repository.dart

# Screens
screens/rituels/                      → screens/taches_quotidiennes/
screens/rituels/rituel_screen.dart    → screens/taches_quotidiennes/tache_screen.dart

# Widgets
widgets/rituel_card.dart              → widgets/tache_card.dart
```

**Note** : Fichier `models/tache.dart` existe déjà (gestion de tâches générales), différent de `tache_quotidienne.dart` (ancien rituel).

---

## 🔄 ÉTAPE 2 : REMPLACEMENTS DANS LE CODE DART

### A. Imports de fichiers (priorité critique)

**Commande PowerShell** :
```powershell
cd "c:\Users\GUIFO\Desktop\rabbit_farm_app"

Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    
    $content = $content `
        -replace "import '../models/rituel\.dart'", "import '../models/tache_quotidienne.dart'" `
        -replace "import '../models/anomalie_rituel\.dart'", "import '../models/anomalie_tache.dart'" `
        -replace "import '../providers/rituel_provider\.dart'", "import '../providers/tache_provider.dart'" `
        -replace "import '../repositories/rituel_repository\.dart'", "import '../repositories/tache_repository.dart'" `
        -replace "import '../screens/rituels/rituel_screen\.dart'", "import '../screens/taches_quotidiennes/tache_screen.dart'" `
        -replace "import '../../models/rituel\.dart'", "import '../../models/tache_quotidienne.dart'" `
        -replace "import '../../models/anomalie_rituel\.dart'", "import '../../models/anomalie_tache.dart'" `
        -replace "import '../../providers/rituel_provider\.dart'", "import '../../providers/tache_provider.dart'"
    
    Set-Content -Path $_.FullName -Value $content -NoNewline
}
```

### B. Classes et types (148 occurrences identifiées)

| Ancien nom | Nouveau nom | Contexte |
|------------|-------------|----------|
| `TypeRituel` | `TypeTacheQuotidienne` | Enum matin/soir |
| `ActionRituel` | `ActionTache` | Action individuelle dans une tâche |
| `Rituel` | `TacheQuotidienne` | Classe principale |
| `AnomalieRituel` | `AnomalieTache` | Anomalie détectée lors d'une tâche |
| `RituelProvider` | `TacheProvider` | Provider de state |
| `RituelRepository` | `TacheRepository` | Repository data |
| `RituelCard` | `TacheCard` | Widget carte dashboard |
| `RituelScreen` | `TacheScreen` | Écran principal |
| `RituelMiniCard` | `TacheMiniCard` | Widget carte compacte |

**Commande de remplacement** :
```powershell
Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    
    # Classes principales
    $content = $content `
        -replace '\bTypeRituel\b', 'TypeTacheQuotidienne' `
        -replace '\bActionRituel\b', 'ActionTache' `
        -replace '\bRituel\b', 'TacheQuotidienne' `
        -replace '\bAnomalieRituel\b', 'AnomalieTache' `
        -replace '\bRituelProvider\b', 'TacheProvider' `
        -replace '\bRituelRepository\b', 'TacheRepository' `
        -replace '\bRituelCard\b', 'TacheCard' `
        -replace '\bRituelScreen\b', 'TacheScreen' `
        -replace '\bRituelMiniCard\b', 'TacheMiniCard'
    
    Set-Content -Path $_.FullName -Value $content -NoNewline
}
```

### C. Variables et propriétés (82 occurrences)

| Pattern ancien | Pattern nouveau | Exemples |
|----------------|-----------------|----------|
| `rituelMatin` | `tacheMatin` | `provider.rituelMatin` → `provider.tacheMatin` |
| `rituelSoir` | `tacheSoir` | `final rituelSoir =` → `final tacheSoir =` |
| `rituel` (variable) | `tache` | `final rituel = await...` → `final tache = await...` |
| `rituelsCompletes` | `tachesCompletes` | Compteur de tâches |
| `typeRituel` | `typeTache` | Paramètre de type |
| `actionRituel` | `actionTache` | Action individuelle |
| `rituelId` | `tacheId` | ID de base de données |
| `historiqueRituels` | `historiqueTaches` | Liste historique |
| `statsRituels` | `statsTaches` | Statistiques |

**Commande de remplacement** :
```powershell
Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    
    # Variables et propriétés (ordre important : spécifique → général)
    $content = $content `
        -replace '\brituelMatin\b', 'tacheMatin' `
        -replace '\brituelSoir\b', 'tacheSoir' `
        -replace '\brituelsCompletes\b', 'tachesCompletes' `
        -replace '\bhistoriqueRituels\b', 'historiqueTaches' `
        -replace '\bstatsRituels\b', 'statsTaches' `
        -replace '\bjoursAvecRituel\b', 'joursAvecTache' `
        -replace '\bpourcentageRituels\b', 'pourcentageTaches' `
        -replace '\brituelProvider\b', 'tacheProvider' `
        -replace '\brituelId\b', 'tacheId' `
        -replace '\btypeRituel\b', 'typeTache' `
        -replace '\bactionRituel\b', 'actionTache' `
        -replace '\brituel\b', 'tache'
    
    Set-Content -Path $_.FullName -Value $content -NoNewline
}
```

### D. Commentaires et documentation (36 occurrences)

Remplacements contextuels manuels ou via :
```powershell
$content = $content `
    -replace '\/\/\/ Modèle pour les rituels quotidiens', '/// Modèle pour les tâches quotidiennes' `
    -replace 'rituels quotidiens', 'tâches quotidiennes' `
    -replace 'Rituels du jour', 'Tâches du jour' `
    -replace 'rituel quotidien', 'tâche quotidienne' `
    -replace 'Un rituel est une série', 'Une tâche quotidienne est une série' `
    -replace 'Compléter un rituel', 'Compléter une tâche' `
    -replace 'Actions rituels', 'Actions des tâches'
```

---

## 🌐 ÉTAPE 3 : LOCALISATION (i18n)

### A. Clés de traduction à renommer dans `lib/l10n/app_fr.arb`

| Ancienne clé | Nouvelle clé | Nouvelle valeur FR |
|--------------|--------------|-------------------|
| `rituelDuMatin` | `tacheDuMatin` | "Tâches du matin" |
| `rituelDuSoir` | `tacheDuSoir` | "Tâches du soir" |
| `rituelChargement` | `tacheChargement` | "Chargement..." |
| `rituelLabel` | `tacheLabel` | "Tâche {type}" |
| `rituelNormal` | `tacheNormal` | "✓ OK" |
| `rituelAnomalie` | `tacheAnomalie` | "Problème" |
| `rituelPlusTard` | `tachePlusTard` | "Reporter" |
| `rituelSnackActionValidee` | `tacheSnackActionValidee` | "Action validée" |
| `rituelSnackActionReportee` | `tacheSnackActionReportee` | "Reporté à plus tard" |
| `rituelSnackProblemeEnregistre` | `tacheSnackProblemeEnregistre` | "Problème enregistré" |
| `rituelTermine` | `tacheTerminee` | "Tâche terminée !" |
| `rituelBravo` | `tacheBravo` | "Bravo, vos lapins sont bien soignés." |
| `rituelBoutonTermine` | `tacheBoutonTermine` | "Terminé" |
| `typeEntiteRituel` | `typeEntiteTache` | "Tâche quotidienne" |
| `rituelMatin` | `tacheMatin` | "Matin" |
| `rituelSoir` | `tacheSoir` | "Soir" |
| `rituelEnCours` | `tacheEnCours` | "En cours ({done}/{total})" |
| `rituelAFaire` | `tacheAFaire` | "À faire" |
| `rituelMessageDeuxFaits` | `tacheMessageDeuxFaits` | "Les deux vérifications sont faites !" |
| `rituelMessagePremierValide` | `tacheMessagePremierValide` | "Première vérification validée" |
| `rituelMessageMatinAttend` | `tacheMessageMatinAttend` | "La vérification du matin t'attend" |
| `rituelMessageHeureSoir` | `tacheMessageHeureSoir` | "C'est l'heure du tour du soir" |
| `rituelsDuJour` | `tachesDuJour` | "Tâches du jour" |
| `rituelAppuyerCommencer` | `tacheAppuyerCommencer` | "Appuyez pour commencer" |
| `rituelMatinFaitSoirAttente` | `tacheMatinFaitSoirAttente` | "🌅 Matin ✓ • 🌙 Soir en attente" |
| `rituelMatinAttenteSoirFait` | `tacheMatinAttenteSoirFait` | "🌅 Matin en attente • 🌙 Soir ✓" |
| `rituelMatinEnCours` | `tacheMatinEnCours` | "🌅 Matin en cours..." |
| `rituelSoirEnCours` | `tacheSoirEnCours` | "🌙 Soir en cours..." |
| `rituelFait` | `tacheFait` | "✓ Fait" |
| `rituelAnomaliesAujourdhui` | `tacheAnomaliesAujourdhui` | "{count, plural, =1{{count} problème signalé aujourd'hui} other{{count} problèmes signalés aujourd'hui}}" |
| `rituelAstuceObservation` | `tacheAstuceObservation` | "5 minutes suffisent pour un contrôle visuel." |

**Total** : 30 clés à migrer dans `app_fr.arb` et `app_en.arb`.

### B. Traductions anglaises dans `lib/l10n/app_en.arb`

| Clé | Valeur EN (nouvelle) |
|-----|---------------------|
| `tacheDuMatin` | "Morning tasks" |
| `tacheDuSoir` | "Evening tasks" |
| `tacheChargement` | "Loading tasks..." |
| `tacheLabel` | "Task {type}" |
| `tacheNormal` | "Normal" |
| `tacheAnomalie` | "Issue" |
| `tachePlusTard` | "Later" |
| `tacheTerminee` | "Task complete!" |
| `tachesDuJour` | "Daily tasks" |
| `tacheAppuyerCommencer` | "Tap to start" |

---

## 🎨 ÉTAPE 4 : THEME VARIATIONS

### Fichier : `lib/theme/theme_variations.dart`

```dart
// AVANT
static const ThemeVariation rituelMatin = ThemeVariation(
  name: 'Rituel Matin',
  accentColor: AppTheme.warning,
  // ...
);

static const ThemeVariation rituelSoir = ThemeVariation(
  name: 'Rituel Soir',
  accentColor: AppTheme.info,
  // ...
);

static ThemeVariation getRituelVariation(bool estMatin) {
  return estMatin ? rituelMatin : rituelSoir;
}

// APRÈS
static const ThemeVariation tacheMatin = ThemeVariation(
  name: 'Tâche Matin',
  accentColor: AppTheme.warning,
  accentLight: AppTheme.warning50,
  accentDark: AppTheme.warning900,
  icon: Icons.wb_sunny_rounded, // Soleil levant
  iconAlt: Icons.light_mode_rounded,
);

static const ThemeVariation tacheSoir = ThemeVariation(
  name: 'Tâche Soir',
  accentColor: AppTheme.info,
  accentLight: AppTheme.info50,
  accentDark: AppTheme.info900,
  icon: Icons.nights_stay_rounded, // Lune
  iconAlt: Icons.dark_mode_rounded,
);

static ThemeVariation getTacheVariation(bool estMatin) {
  return estMatin ? tacheMatin : tacheSoir;
}
```

### Liste all dans `ThemeVariations`

```dart
static const List<ThemeVariation> all = [
  cheptel,
  sante,
  reproduction,
  finance,
  tacheMatin,  // ← rituelMatin
  tacheSoir,   // ← rituelSoir
  alertes,
  parametres,
];
```

### Commentaires

```dart
// AVANT
// RITUEL MATIN - Tâches quotidiennes du matin
// RITUEL SOIR - Tâches quotidiennes du soir

// APRÈS
// TÂCHE MATIN - Vérifications quotidiennes du matin
// TÂCHE SOIR - Vérifications quotidiennes du soir
```

---

## 🧪 ÉTAPE 5 : TESTS

### Fichier : `test/theme/theme_variations_test.dart`

```dart
// AVANT
test('getRituelVariation retourne la bonne variation', () {
  final matin = ThemeVariations.getRituelVariation(true);
  final soir = ThemeVariations.getRituelVariation(false);
  
  expect(matin, equals(ThemeVariations.rituelMatin));
  expect(soir, equals(ThemeVariations.rituelSoir));
});

test('toutes les variations ont des icônes', () {
  // Rituels
  expect(ThemeVariations.rituelMatin.icon, Icons.wb_sunny_rounded);
  expect(ThemeVariations.rituelSoir.icon, Icons.nights_stay_rounded);
});

test('liste all contient toutes les variations', () {
  expect(ThemeVariations.all, contains(ThemeVariations.rituelMatin));
  expect(ThemeVariations.all, contains(ThemeVariations.rituelSoir));
});

// APRÈS
test('getTacheVariation retourne la bonne variation', () {
  final matin = ThemeVariations.getTacheVariation(true);
  final soir = ThemeVariations.getTacheVariation(false);
  
  expect(matin, equals(ThemeVariations.tacheMatin));
  expect(soir, equals(ThemeVariations.tacheSoir));
});

test('toutes les variations ont des icônes', () {
  // Tâches quotidiennes
  expect(ThemeVariations.tacheMatin.icon, Icons.wb_sunny_rounded);
  expect(ThemeVariations.tacheSoir.icon, Icons.nights_stay_rounded);
});

test('liste all contient toutes les variations', () {
  expect(ThemeVariations.all, contains(ThemeVariations.tacheMatin));
  expect(ThemeVariations.all, contains(ThemeVariations.tacheSoir));
});
```

---

## 📊 ÉTAPE 6 : BASE DE DONNÉES (si nécessaire)

### Tables potentiellement impactées

**À vérifier dans** : `lib/services/database_helper.dart`

```sql
-- Si table nommée "rituels" existe
ALTER TABLE rituels RENAME TO taches_quotidiennes;

-- Si colonnes "rituel_id" existent
ALTER TABLE actions_rituels RENAME COLUMN rituel_id TO tache_id;
ALTER TABLE actions_rituels RENAME TO actions_taches;
```

**Note** : Nécessite une **migration de version** de base de données avec conservation des données existantes.

---

## 🛠️ ÉTAPE 7 : SERVICES

### Fichiers à modifier

| Fichier | Modifications |
|---------|---------------|
| `lib/services/journal_service.dart` | Méthode `rituel()` → `tacheQuotidienne()` |
| | `TypeEntite.rituel` → `TypeEntite.tacheQuotidienne` |
| `lib/services/notification_quota_manager.dart` | Enum `rituelle` → `tacheQuotidienne` |
| `lib/services/notification_action_handler.dart` | Actions `rituel_ok`, `rituel_probleme` → `tache_ok`, `tache_probleme` |
| `lib/services/micro_message_service.dart` | `getMessageRituelComplete()` → `getMessageTacheComplete()` |
| | `pourcentageRituels` → `pourcentageTaches` |
| `lib/services/coach_notification_service.dart` | `planifierRituelMatin()` → `planifierTachesMatin()` |
| `lib/main.dart` | Ligne 78-80 : "rituel du matin" → "tâches du matin" |

---

## 📱 ÉTAPE 8 : ÉCRANS ET WIDGETS

### Widgets impactés (10 fichiers)

1. **lib/widgets/tache_card.dart** (anciennement rituel_card.dart)
   - ✅ Fichier déjà renommé
   - Tous les `Rituel*` → `Tache*` dans le contenu
   - AppLocalizations : `rituel*` → `tache*`

2. **lib/widgets/anomalie_guidee_sheet.dart**
   - `final TypeRituel typeRituel` → `final TypeTacheQuotidienne typeTache`
   - `final ActionRituel actionRituel` → `final ActionTache actionTache`
   - `final AnomalieRituel?` → `final AnomalieTache?`
   - Ligne 250 : `'Rituel ${...}'` → `'Tâche ${...}'`

3. **lib/widgets/dashboard/discipline_section.dart**
   - `RituelProvider` → `TacheProvider`
   - `getStatistiquesRituels()` → `getStatistiquesTaches()`
   - `getHistoriqueRituels()` → `getHistoriqueTaches()`
   - `_pourcentageRituels` → `_pourcentageTaches`
   - `_getRituelEmoji()` → `_getTacheEmoji()`
   - `_getRituelColor()` → `_getTacheColor()`

4. **lib/widgets/dashboard/dashboard_skeleton.dart**
   - Ligne 31 : Commentaire "Rituels Card" → "Tâches du jour Card"

5. **lib/widgets/common/animations/gamification.dart**
   - Lignes 21, 32 : "Rituels - Encouragement" → "Tâches - Encouragement"
   - Lignes 399-437 : Méthodes `getRituels()`, `completeRituel()`, `isRituelsComplete()` → versions `Tache`
   - Ligne 504-507 : Enum `RitualType` → `TypeTacheQuotidienne` (ou renommer)
   - Ligne 965 : Widget "rituels quotidiens" → "tâches quotidiennes"
   - Ligne 1020 : Titre "Rituels du jour" → "Tâches du jour"

6. **lib/widgets/common/animations/animations.dart**
   - Ligne 37 : Commentaire "rituels" → "tâches"

### Screens impactés (1 dossier)

7. **lib/screens/taches_quotidiennes/tache_screen.dart**
   - ✅ Fichier déjà renommé et dossier `screens/rituels/` → `screens/taches_quotidiennes/`
   - Classe `RituelScreen` → `TacheScreen`
   - `final TypeRituel typeRituel` → `final TypeTacheQuotidienne typeTache`
   - Tous les `Rituel*` → `Tache*`
   - AppLocalizations : `rituel*` → `tache*`

---

## 🗂️ ÉTAPE 9 : DOCUMENTATION

### Fichiers markdown à mettre à jour

| Fichier | Ligne(s) | Changement |
|---------|----------|------------|
| `docs/GUIDE_THEME_VARIATIONS.md` | 69, 104-105, 254 | `rituelMatin`, `rituelSoir` → `tacheMatin`, `tacheSoir` |
| `docs/CORRECTIONS_THEME_RITUEL.md` | **Fichier entier** | Renommer en `CORRECTIONS_THEME_TACHES.md` et adapter contenu |
| `docs/specifications/cahier_charges_v2.md` | 72, 83, 89, 101+ | "RITUELS QUOTIDIENS" → "TÂCHES QUOTIDIENNES" |
| `docs/TODO_PLAN_AMELIORATION.md` | 118 | "rituels quotidiens" → "tâches quotidiennes" |
| `docs/rapport_audit_flutter.md` | 114 | `chargerRituelsJour` → `chargerTachesJour` |
| `docs/PRIVACY_POLICY.md` | 27 | "rituels quotidiens" → "tâches quotidiennes" |
| `.github/copilot-instructions.md` | À ajouter | Nouvelle terminologie officielle |

---

## ✅ CHECKLIST DE VALIDATION

### Compilation

```bash
flutter analyze
# Attendu : 0 erreurs (warnings acceptables)

flutter test
# Attendu : tous les tests passent
```

### Tests manuels

- [ ] Dashboard affiche "Tâches du jour" au lieu de "Rituels du jour"
- [ ] Clic sur carte ouvre "Tâches du matin" / "Tâches du soir"
- [ ] Actions des tâches affichent "Observation générale", "Nourrissage", etc.
- [ ] Notifications utilisent "Tâches du matin" dans le titre
- [ ] Paramètres mentionnent "Tâches quotidiennes"
- [ ] Journal d'activité affiche "Tâche Matin" au lieu de "Rituel Matin"
- [ ] Recherche globale : aucune occurrence de "Rituel" en UI

### Vérification i18n

```bash
# Aucune clé "rituel*" ne doit subsister en production
grep -r "rituel" lib/l10n/app_fr.arb
grep -r "Rituel" lib/**/*.dart
```

---

## 📘 RÈGLE UX OFFICIELLE POUR L'AVENIR

### ✅ TERMINOLOGIE AUTORISÉE

| Contexte | Terme recommandé | Exemple |
|----------|-----------------|---------|
| **Navigation principale** | "Tâches du jour" | Titre de section dashboard |
| **Sous-sections** | "Tâches du matin" / "Tâches du soir" | Titres d'écrans |
| **Actions unitaires** | "Observation", "Nourrissage", "Abreuvement" | Liste des actions |
| **Notifications** | "Vos tâches du matin vous attendent" | Push notifications |
| **Statistiques** | "Tâches complétées : 85%" | KPIs |
| **Historique** | "Historique des tâches quotidiennes" | Titre de page |
| **Documentation** | "Tâches quotidiennes d'élevage" | Manuel utilisateur |

### ❌ TERMINOLOGIE INTERDITE

- "Rituel" (abstrait, non professionnel)
- "Routine" (trop général)
- "Checklist" (anglicisme)
- "To-do" (anglicisme)
- "Check" (anglicisme, sauf "vérification")

### 🎯 PRINCIPE DIRECTEUR

> **Chaque mot de l'interface doit être compréhensible par un éleveur de lapins débutant sans formation technique.**

---

## 📈 STATISTIQUES DE MIGRATION

### Fichiers impactés (estimation)

| Catégorie | Nombre de fichiers | Occurrences |
|-----------|-------------------|-------------|
| **Models** | 2 | ~150 |
| **Providers** | 1 | ~80 |
| **Repositories** | 1 | ~40 |
| **Screens** | 1 | ~120 |
| **Widgets** | 6 | ~200 |
| **Services** | 5 | ~35 |
| **Tests** | 1 | ~15 |
| **i18n** | 2 | ~60 |
| **Documentation** | 7 | ~120 |
| **TOTAL** | **26 fichiers** | **~820 occurrences** |

### Temps estimé

- **Renommages de fichiers** : ✅ 5 min (FAIT)
- **Remplacements code Dart** : ⏳ 45 min
- **Mise à jour i18n** : ⏳ 30 min
- **Tests et validation** : ⏳ 20 min
- **Documentation** : ⏳ 20 min
- **TOTAL** : **~2h00** (1h55 restant)

---

## 🚀 COMMANDE D'EXÉCUTION COMPLÈTE

```powershell
# SCRIPT COMPLET DE MIGRATION
# À exécuter depuis : c:\Users\GUIFO\Desktop\rabbit_farm_app

# 1. Backup avant migration
git add -A
git commit -m "Backup avant migration terminologie Rituel → Tâches"

# 2. Remplacements classes et types
Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    
    # Classes (ordre important)
    $content = $content `
        -replace '\bTypeRituel\b', 'TypeTacheQuotidienne' `
        -replace '\bActionRituel\b', 'ActionTache' `
        -replace '\bAnomalieRituel\b', 'AnomalieTache' `
        -replace '\bRituelProvider\b', 'TacheProvider' `
        -replace '\bRituelRepository\b', 'TacheRepository' `
        -replace '\bRituelCard\b', 'TacheCard' `
        -replace '\bRituelScreen\b', 'TacheScreen' `
        -replace '\bRituelMiniCard\b', 'TacheMiniCard' `
        -replace '\bRituel\b', 'TacheQuotidienne'
    
    Set-Content -Path $_.FullName -Value $content -NoNewline
}

# 3. Remplacements variables
Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    
    $content = $content `
        -replace '\brituelMatin\b', 'tacheMatin' `
        -replace '\brituelSoir\b', 'tacheSoir' `
        -replace '\brituelsCompletes\b', 'tachesCompletes' `
        -replace '\bhistoriqueRituels\b', 'historiqueTaches' `
        -replace '\bstatsRituels\b', 'statsTaches' `
        -replace '\bpourcentageRituels\b', 'pourcentageTaches' `
        -replace '\brituelProvider\b', 'tacheProvider' `
        -replace '\brituelId\b', 'tacheId' `
        -replace '\btypeRituel\b', 'typeTache' `
        -replace '\bactionRituel\b', 'actionTache'
    
    Set-Content -Path $_.FullName -Value $content -NoNewline
}

# 4. Validation compilation
flutter analyze

# 5. Commit final
git add -A
git commit -m "Refactor: Migration terminologie Rituel → Tâches quotidiennes"
```

---

## 📞 SUPPORT

En cas d'erreur lors de la migration :
1. Vérifier les logs de compilation : `flutter analyze --verbose`
2. Tester l'application : `flutter run`
3. Consulter ce document pour les patterns de remplacement
4. Rollback si nécessaire : `git reset --hard HEAD~1`

**Date de dernière mise à jour** : 19 janvier 2026
