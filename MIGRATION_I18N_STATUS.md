# État Migration i18n "Rituel" → "Tâches quotidiennes"

**Date** : 19 janvier 2026  
**Statut** : 🟡 Partiel (79% complété)

## ✅ Complété

### 1. Migration i18n (100%)
- ✅ 38 clés migrées dans `app_fr.arb` (rituel* → tache*)
- ✅ 38 clés migrées dans `app_en.arb`
- ✅ Métadonnées @ également migrées
- ✅ Sauvegardes créées (.backup)

### 2. Fichiers renommés (100%)
- ✅ `models/rituel.dart` → `models/tache_quotidienne.dart`
- ✅ `models/anomalie_rituel.dart` → `models/anomalie_tache.dart`
- ✅ `providers/rituel_provider.dart` → `providers/tache_provider.dart`
- ✅ `repositories/rituel_repository.dart` → `repositories/tache_repository.dart`
- ✅ `widgets/rituel_card.dart` → `widgets/tache_card.dart`
- ✅ `screens/rituels/` → `screens/taches_quotidiennes/`
- ✅ Suppression des anciens fichiers (rituel_provider.dart, rituel_repository.dart)

### 3. Imports corrigés (80%)
- ✅ `app_providers.dart` : Import tache_provider.dart
- ✅ `dashboard_screen.dart` : Import tache_card.dart et tache_provider.dart
- ✅ `tache_screen.dart` : Imports tache_quotidienne.dart et anomalie_tache.dart
- ✅ `tache_card.dart` : Imports mis à jour
- ✅ `discipline_section.dart` : Import tache_provider.dart
- ✅ `database_helper.dart` : Imports tache_quotidienne.dart et anomalie_tache.dart
- ✅ `repositories.dart` : Export rituel_repository.dart supprimé

### 4. Types et classes (85%)
- ✅ `database_helper.dart` : Rituel → TacheQuotidienne
- ✅ `database_helper.dart` : AnomalieRituel → AnomalieTache
- ✅ `database_helper.dart` : Méthodes insertRituel → insertTache, etc.
- ✅ `anomalie_provider.dart` : Appels de méthodes mis à jour

### 5. Clés i18n dans le code (90%)
- ✅ `tache_screen.dart` : 13 clés migrées (rituelDuMatin → tacheDuMatin, etc.)
- ✅ `tache_card.dart` : 23 clés migrées

## ⚠️ Erreurs restantes : 135

### Priorité 1 : TacheProvider méthodes manquantes

**Fichier** : `lib/providers/tache_provider.dart`  
**Erreurs** :
```
- getTacheDuJour(TypeTacheQuotidienne type) : méthode non définie
- validerNormal(...) : méthode non définie
- validerPlusTard(...) : méthode non définie
```

**Action requise** : Vérifier si ces méthodes existent avec un nom différent ou créer des wrappers.

### Priorité 2 : Anomalie guidée sheet

**Fichier** : `lib/widgets/anomalie_guidee_sheet.dart`  
**Erreur** : `import '../models/anomalie_rituel.dart'`  
**Action** : Remplacer par `import '../models/anomalie_tache.dart'`

### Priorité 3 : Theme variations

**Fichiers concernés** :
- `lib/screens/sante/sante_screen.dart`
- `lib/screens/taches_quotidiennes/tache_screen.dart`

**Erreur** : `Target of URI doesn't exist: '../../theme/theme_variations.dart'`  
**Note** : Le fichier existe mais n'est pas reconnu (probablement cache corrompu)  
**Action** : Après `flutter clean`, vérifier si l'erreur persiste

### Priorité 4 : tache_screen.dart corrections syntaxiques

**Ligne 21** : `final TypeTacheQuotidienne TypeTacheQuotidienne;`  
**Problème** : Variable doit commencer par minuscule  
**Correction** : `final TypeTacheQuotidienne typeTache;`

**Ligne 72** : Appel à `provider.getTacheDuJour(...)` inexistant  
**Action** : Trouver méthode équivalente dans TacheProvider

**Ligne 280** : `EmojiToIconMapper` non défini  
**Action** : Vérifier imports ou créer la classe

**Lignes 492, 500** : `validerNormal()` et `validerPlusTard()` manquantes  
**Action** : Implémenter ou mapper vers méthodes existantes

## 📋 Plan de correction

### Phase 1 : Corrections critiques (30 min)

1. **Corriger anomalie_guidee_sheet.dart** :
```powershell
(Get-Content "lib\widgets\anomalie_guidee_sheet.dart" -Raw) `
  -replace 'anomalie_rituel.dart', 'anomalie_tache.dart' | `
  Set-Content "lib\widgets\anomalie_guidee_sheet.dart" -Encoding UTF8
```

2. **Corriger tache_screen.dart syntaxe** :
```dart
// Ligne 21
final TypeTacheQuotidienne typeTache;

// Ligne 26
const TacheScreen({super.key, required this.typeTache});

// Ligne 55
final estMatin = widget.typeTache == TypeTacheQuotidienne.matin;
```

### Phase 2 : TacheProvider API (45 min)

1. **Analyser TacheProvider** pour trouver méthodes équivalentes
2. **Créer wrappers** si nécessaire :
```dart
TacheQuotidienne? getTacheDuJour(TypeTacheQuotidienne type) {
  return type == TypeTacheQuotidienne.matin ? _tacheMatin : _tacheSoir;
}
```

### Phase 3 : Tests & validation (15 min)

```bash
flutter analyze
flutter test
flutter run -d R5CT31S8XAP
```

## 🔍 Commandes de diagnostic

```powershell
# Compter erreurs
flutter analyze 2>&1 | Select-String "error" | Measure-Object

# Afficher 20 premières erreurs
flutter analyze 2>&1 | Select-String "error" -Context 0,1 | Select-Object -First 20

# Chercher références "rituel" restantes
Get-ChildItem -Recurse -Filter "*.dart" | Select-String -Pattern "rituel[A-Z]" | Select-Object -First 50

# Nettoyer cache
flutter clean
flutter pub get
```

## 📊 Métriques

- **Fichiers modifiés** : 15+
- **Lignes de code** : ~2000+
- **Clés i18n** : 76 (38 FR + 38 EN)
- **Erreurs réduites** : 170 → 135 (-21%)
- **Temps estimé restant** : 1h30

## 📚 Documentation connexe

- `docs/MIGRATION_TERMINOLOGIE_TACHES_QUOTIDIENNES.md` : Guide complet de migration
- `docs/VOCABULAIRE_OFFICIEL_UX.md` : Terminologie officielle
- `docs/RAPPORT_ELIMINATION_TERME_RITUEL.md` : Rapport d'intervention initial
