# 🔧 CORRECTIONS PRIORITAIRES - THÈME RITUEL

Ce document liste les modifications concrètes à appliquer pour harmoniser le thème Rituel avec le Design System global.

---

## FICHIERS CONCERNÉS

1. `lib/screens/rituels/rituel_screen.dart`
2. `lib/widgets/rituel_card.dart`
3. `lib/theme/app_theme.dart` (ajouts)

---

## 1. CORRECTIONS `rituel_screen.dart`

### 1.1 Imports à ajouter

```dart
// Ajouter après les imports existants
import '../../theme/theme_variations.dart';
```

### 1.2 Remplacer les BorderRadius hardcodés

| Ligne | Avant | Après |
|-------|-------|-------|
| 181 | `borderRadius: BorderRadius.circular(20)` | `borderRadius: AppTheme.borderRadiusLarge` |
| 206 | `borderRadius: BorderRadius.circular(10)` | `borderRadius: BorderRadius.circular(AppTheme.radiusSmall)` |
| 241 | `borderRadius: BorderRadius.circular(16)` | `borderRadius: AppTheme.borderRadiusLarge` |
| 271 | `borderRadius: BorderRadius.circular(12)` | `borderRadius: AppTheme.borderRadiusMedium` |
| 410 | `borderRadius: BorderRadius.circular(12)` | `borderRadius: AppTheme.borderRadiusMedium` |
| 416 | `borderRadius: BorderRadius.circular(12)` | `borderRadius: AppTheme.borderRadiusMedium` |

### 1.3 Remplacer les fontSize hardcodés

| Ligne | Avant | Après |
|-------|-------|-------|
| 141 | `TextStyle(fontSize: 40)` | `AppTheme.displayLarge.copyWith(fontSize: 36)` |
| 276 | `TextStyle(fontSize: 28)` | `AppTheme.displayMedium` |
| 453 | `TextStyle(fontSize: 32)` | `AppTheme.displayMedium` |

### 1.4 Utiliser ThemeVariations pour les couleurs

```dart
// AVANT (ligne ~118)
final couleurPrimaire = estMatin ? AppTheme.warning : AppTheme.info;

// APRÈS
final themeVariation = ThemeVariations.getRituelVariation(estMatin);
final couleurPrimaire = themeVariation.accentColor;
```

### 1.5 Remplacer le gradient du header

```dart
// AVANT (ligne 127-135)
decoration: BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      couleurPrimaire.withValues(alpha: 0.2),
      couleurPrimaire.withValues(alpha: 0.05),
    ],
  ),
),

// APRÈS - Fond simple avec accent
decoration: BoxDecoration(
  color: themeVariation.accentLight,
  border: Border(
    bottom: BorderSide(
      color: themeVariation.accentColor.withOpacity(0.2),
      width: 1,
    ),
  ),
),
```

### 1.6 Remplacer l'emoji par une icône Material

```dart
// AVANT (ligne 141)
Text(rituel.emojiType, style: const TextStyle(fontSize: 40)),

// APRÈS
Icon(
  themeVariation.icon,
  size: 36,
  color: themeVariation.accentColor,
),
```

### 1.7 Simplifier la bannière de complétion

```dart
// AVANT (ligne 443-480)
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(...),
  ),
  child: Row(
    children: [
      const Text('🎉', style: TextStyle(fontSize: 32)),
      ...
    ],
  ),
)

// APRÈS
Container(
  padding: const EdgeInsets.all(AppTheme.spacing20),
  decoration: BoxDecoration(
    color: AppTheme.success50,
    border: Border(
      top: BorderSide(color: AppTheme.success, width: 2),
    ),
  ),
  child: Row(
    children: [
      Icon(
        Icons.celebration_rounded,
        size: 32,
        color: AppTheme.success,
      ),
      const SizedBox(width: 16),
      Expanded(...),
      ElevatedButton(
        style: AppTheme.primaryButtonStyle,
        ...
      ),
    ],
  ),
)
```

---

## 2. CORRECTIONS `rituel_card.dart`

### 2.1 Imports à ajouter

```dart
import '../theme/theme_variations.dart';
```

### 2.2 Remplacer le Container principal avec gradient

```dart
// AVANT (ligne 26-45)
Container(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        isDark ? AppTheme.cardDark : AppTheme.cardLight,
        isDark
            ? AppTheme.cardDark.withValues(alpha: 0.8)
            : AppTheme.cardLight,
      ],
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: _getBorderColor(provider), width: 2),
    boxShadow: [...],
  ),
)

// APRÈS
Container(
  margin: const EdgeInsets.symmetric(
    horizontal: AppTheme.spacing16,
    vertical: AppTheme.spacing8,
  ),
  decoration: BoxDecoration(
    color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
    borderRadius: AppTheme.borderRadiusLarge,
    border: Border.all(
      color: _getBorderColor(provider),
      width: _getBorderWidth(provider),
    ),
    boxShadow: AppTheme.cardShadow(isDark: isDark),
  ),
)
```

### 2.3 Remplacer le header avec gradient

```dart
// AVANT (ligne 111-128)
Container(
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: tousTermines
          ? [AppTheme.primaryGreen, AppTheme.primaryNeonGreen]
          : [AppTheme.warning.withValues(alpha: 0.8), AppTheme.warning],
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Icon(...),
)

// APRÈS
Container(
  padding: const EdgeInsets.all(AppTheme.spacing12),
  decoration: BoxDecoration(
    color: tousTermines
        ? AppTheme.success
        : AppTheme.warning,
    borderRadius: AppTheme.borderRadiusMedium,
  ),
  child: Icon(
    tousTermines
        ? Icons.check_circle_rounded
        : Icons.pending_actions_rounded,
    color: Colors.white,
    size: 24,
  ),
)
```

### 2.4 Remplacer les emojis dans les boutons rituel

```dart
// AVANT (ligne 234-238)
Text(
  estMatin ? '🌅' : '🌙',
  style: const TextStyle(fontSize: 28),
),

// APRÈS
Icon(
  estMatin
      ? ThemeVariations.rituelMatin.icon
      : ThemeVariations.rituelSoir.icon,
  size: 28,
  color: estMatin
      ? ThemeVariations.rituelMatin.accentColor
      : ThemeVariations.rituelSoir.accentColor,
),
```

### 2.5 Simplifier la méthode `_getBorderColor`

```dart
// Ajouter après _getBorderColor
int _getBorderWidth(RituelProvider provider) {
  if (provider.matinTermine && provider.soirTermine) {
    return 2;
  }
  return 1;
}
```

---

## 3. AJOUTS À `app_theme.dart`

### 3.1 Ajouter les méthodes de gradient standardisées (optionnel)

```dart
// Ajouter après les décorations existantes (ligne ~970)

/// Gradient d'accent léger (pour headers thématiques)
static LinearGradient accentGradientLight(Color accentColor) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      accentColor.withOpacity(0.15),
      accentColor.withOpacity(0.05),
    ],
  );
}

/// Gradient d'accent pour boutons/badges importants
static LinearGradient accentGradientSolid(Color accentColor) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      accentColor,
      accentColor.withOpacity(0.85),
    ],
  );
}
```

---

## 4. VALIDATION

Après les modifications, vérifier :

- [ ] `flutter analyze` ne montre pas de nouvelles erreurs
- [ ] Le rituel utilise les mêmes BorderRadius que les autres écrans
- [ ] Les icônes Material remplacent les emojis
- [ ] Les gradients sont supprimés ou standardisés
- [ ] Le RituelCard s'intègre visuellement au Dashboard

---

## 5. AVANT/APRÈS VISUEL

### RituelCard sur Dashboard

**AVANT :**
```
┌────────────────────────────────────────────┐
│ 🌈 Gradient coloré + bordure épaisse       │
│ ┌──────────────────────────────────────┐   │
│ │ 🎨 Gradient header    [Badge %]      │   │
│ │ 🌅🌙 Emojis         Progress bars    │   │
│ │ Texte gamifié        Cercles colorés │   │
│ └──────────────────────────────────────┘   │
│ 💬 Micro-message                           │
│ ⚠️ Anomalies bannière                      │
└────────────────────────────────────────────┘
```

**APRÈS :**
```
┌────────────────────────────────────────────┐
│ Fond uni + bordure fine                    │
│ ┌──────────────────────────────────────┐   │
│ │ [Icon] Rituel du jour    [75%]       │   │
│ │ ━━━━━━━━━━━━━━━━━━░░ Barre linéaire  │   │
│ │ ☀️ Matin ✓    🌙 Soir ○              │   │
│ └──────────────────────────────────────┘   │
│ 1 anomalie en attente                      │
└────────────────────────────────────────────┘
```

---

*Ces corrections maintiennent la fonctionnalité gamifiée tout en harmonisant le style visuel avec le reste de l'application.*
