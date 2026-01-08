# Guide de Standardisation Visuelle - BunnyManager

## 🎯 Objectif
Éliminer les incohérences visuelles pour obtenir une interface uniforme et professionnelle.

## 📊 Audit des Incohérences Détectées

### 1. **Couleurs Hardcodées** (Critique)
❌ **Trouvé**: `Colors.white`, `Colors.black`, `Colors.grey`, etc.
✅ **Utiliser**: `AppTheme.*` uniquement

**Exemples à corriger**:
```dart
// ❌ MAUVAIS
Colors.white
Colors.black.withValues(alpha: 0.05)
Colors.grey.shade400

// ✅ BON
AppTheme.surfaceWhite
AppTheme.textPrimary.withValues(alpha: 0.05)
AppTheme.neutral400
```

### 2. **Tailles de Police Anarchiques** (Critique)
❌ **Trouvé**: `fontSize: 11`, `fontSize: 13`, `fontSize: 14`, `fontSize: 16`, `fontSize: 18`, `fontSize: 22`, `fontSize: 24`, `fontSize: 28`, `fontSize: 32`, `fontSize: 40`
✅ **Utiliser**: `AppTheme.bodySmall`, `AppTheme.bodyMedium`, `AppTheme.titleSmall`, etc.

**Échelle Standardisée**:
```dart
// ✅ Utiliser uniquement ces styles
AppTheme.caption        // 11px - Labels très petits
AppTheme.bodySmall      // 12px - Texte secondaire
AppTheme.bodyMedium     // 14px - Texte standard
AppTheme.bodyLarge      // 16px - Texte important
AppTheme.titleSmall     // 18px - Petits titres
AppTheme.titleMedium    // 20px - Titres moyens
AppTheme.titleLarge     // 24px - Grands titres
AppTheme.displayLarge   // 32px - Display headers
```

### 3. **Border Radius Incohérents** (Modéré)
❌ **Trouvé**: `2, 6, 8, 12, 16, 20, 24, 32, 40, 999`
✅ **Utiliser**: `AppTheme.radiusSmall`, `AppTheme.radiusMedium`, `AppTheme.radiusLarge`, `AppTheme.radiusRound`

**Standardisation**:
```dart
// ✅ Utiliser uniquement
BorderRadius.circular(AppTheme.radiusSmall)   // 8px - Petits éléments
BorderRadius.circular(AppTheme.radiusMedium)  // 12px - Cartes standards
BorderRadius.circular(AppTheme.radiusLarge)   // 16px - Grandes cartes
BorderRadius.circular(AppTheme.radiusRound)   // 999px - Badges/Pills
```

### 4. **Espacements Non Standardisés** (Modéré)
❌ **Trouvé**: Valeurs aléatoires `4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 28, 32`
✅ **Utiliser**: `AppTheme.spacing*`

**Grille d'espacement**:
```dart
// ✅ Utiliser uniquement
AppTheme.spacing4   // 4px  - Très petit
AppTheme.spacing8   // 8px  - Petit
AppTheme.spacing12  // 12px - Moyen-petit
AppTheme.spacing16  // 16px - Standard
AppTheme.spacing20  // 20px - Moyen-grand
AppTheme.spacing24  // 24px - Grand
AppTheme.spacing32  // 32px - Très grand
```

### 5. **Styles de Cartes Variés** (Critique)
❌ **Problème**: Chaque écran a son propre style de carte
✅ **Solution**: Utiliser `AppTheme.cardDecoration(isDark: isDark)`

```dart
// ✅ Style unifié
Container(
  decoration: AppTheme.cardDecoration(isDark: isDark),
  // OU
  decoration: AppTheme.actionCardDecoration(isDark: isDark),
  child: ...
)
```

### 6. **Ombres Inconsistantes** (Modéré)
❌ **Problème**: Chaque élément définit ses propres ombres
✅ **Solution**: Utiliser `AppTheme.shadowSmall` ou `AppTheme.cardShadow()`

```dart
// ✅ Ombres standardisées
boxShadow: AppTheme.shadowSmall
// OU
boxShadow: AppTheme.cardShadow(isDark: isDark)
```

## 🔧 Plan de Correction par Priorité

### Phase 1: Couleurs (Impact Visuel Maximum)
**Fichiers prioritaires**:
- [ ] `lib/screens/auth/auth_screen.dart` - Colors.white70, Colors.black54
- [ ] `lib/screens/sante/pharmacie_screen.dart` - Colors.black.withValues()
- [ ] `lib/screens/taches/gestionnaire_taches_screen.dart` - Colors.white
- [ ] `lib/screens/sante/treatments_care_screen.dart` - Colors.grey, Colors.black

### Phase 2: Typographie (Cohérence Textuelle)
**Pattern de remplacement**:
```dart
// Remplacer tous
fontSize: 11  → AppTheme.caption
fontSize: 12  → AppTheme.bodySmall
fontSize: 14  → AppTheme.bodyMedium
fontSize: 16  → AppTheme.bodyLarge
fontSize: 18  → AppTheme.titleSmall
fontSize: 20  → AppTheme.titleMedium
fontSize: 24  → AppTheme.titleLarge
fontSize: 32  → AppTheme.displayLarge
```

### Phase 3: Border Radius (Uniformité Géométrique)
**Pattern de remplacement**:
```dart
// Remplacer tous
BorderRadius.circular(8)   → BorderRadius.circular(AppTheme.radiusSmall)
BorderRadius.circular(12)  → BorderRadius.circular(AppTheme.radiusMedium)
BorderRadius.circular(16)  → BorderRadius.circular(AppTheme.radiusLarge)
BorderRadius.circular(999) → BorderRadius.circular(AppTheme.radiusRound)
```

### Phase 4: Espacements (Grille Cohérente)
**Pattern de remplacement**:
```dart
// Remplacer tous les EdgeInsets/SizedBox hardcodés
const EdgeInsets.all(16) → const EdgeInsets.all(AppTheme.spacing16)
const SizedBox(height: 8) → const SizedBox(height: AppTheme.spacing8)
```

## ✅ Checklist de Validation

Avant de considérer un fichier comme "standardisé", vérifier:

- [ ] Aucun `Colors.*` hardcodé (sauf `Colors.transparent`)
- [ ] Aucun `fontSize:` direct (utilise `AppTheme.*Style`)
- [ ] Tous les `BorderRadius.circular()` utilisent `AppTheme.radius*`
- [ ] Tous les espacements utilisent `AppTheme.spacing*`
- [ ] Les cartes utilisent `AppTheme.cardDecoration()`
- [ ] Les ombres utilisent `AppTheme.shadowSmall` ou `.cardShadow()`
- [ ] Mode sombre testé et fonctionnel

## 📈 Métriques de Succès

**Avant standardisation**:
- 150+ occurrences de `Colors.*` hardcodés
- 80+ tailles de police différentes
- 50+ valeurs de borderRadius différentes

**Après standardisation (Objectif)**:
- 0 occurrences de `Colors.*` (sauf transparent)
- 8 tailles de police (AppTheme styles)
- 4 valeurs de borderRadius (AppTheme constants)

## 🎨 Exemple de Transformation Complète

### Avant (Incohérent)
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: Colors.grey.shade300),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Text(
    'Titre',
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
)
```

### Après (Standardisé)
```dart
Container(
  padding: const EdgeInsets.all(AppTheme.spacing16),
  decoration: AppTheme.cardDecoration(isDark: isDark),
  child: Text(
    'Titre',
    style: AppTheme.titleSmall.copyWith(
      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
    ),
  ),
)
```

## 🚀 Script de Détection Automatique

Pour trouver les incohérences dans un fichier:
```bash
# Couleurs hardcodées
grep -n "Colors\.(white|black|grey|red|blue|green)" fichier.dart

# Tailles de police non standardisées
grep -n "fontSize: [0-9]" fichier.dart

# Border radius hardcodés
grep -n "BorderRadius\.circular([0-9]" fichier.dart

# Espacements hardcodés
grep -n "EdgeInsets\.\(all\|symmetric\|only\)([0-9]" fichier.dart
```

---

**Date**: 1 janvier 2026
**Version**: 1.0
**Statut**: En cours d'application
