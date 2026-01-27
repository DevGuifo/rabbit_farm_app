# 🎨 GUIDE D'UTILISATION - THEME VARIATIONS

**Version :** 1.0  
**Date :** 17 janvier 2026

---

## 📖 INTRODUCTION

Les `ThemeVariations` permettent une différenciation visuelle par fonctionnalité tout en maintenant la cohérence du Design System global.

---

## 🎯 QUAND UTILISER LES THEMEVARIATIONS

### ✅ À UTILISER pour :
- Icônes thématiques des écrans principaux
- Couleurs d'accent des cartes d'action
- Badges et chips fonctionnels
- Boutons contextuels avec thème

### ❌ NE PAS UTILISER pour :
- Composants génériques (boutons primaires, champs de texte)
- Messages d'erreur/succès (utiliser les couleurs sémantiques)
- Typographie (toujours utiliser AppTheme.textStyles)
- Layouts et espacements (toujours utiliser AppTheme.spacing*)

---

## 🚀 EXEMPLES D'UTILISATION

### 1. Icône thématique simple

```dart
import '../../theme/theme_variations.dart';

Icon(
  ThemeVariations.sante.icon,
  color: ThemeVariations.sante.accentColor,
  size: 24,
)
```

### 2. Bouton avec icône thématique

```dart
IconButton(
  icon: Icon(ThemeVariations.reproduction.icon),
  color: ThemeVariations.reproduction.accentColor,
  onPressed: () => _openReproduction(),
)
```

### 3. Carte avec décoration thématique

```dart
Container(
  decoration: ThemeVariations.finance.cardDecoration(
    isDark: isDark,
    highlighted: isSelected,
  ),
  child: ...,
)
```

### 4. Badge thématique

```dart
ThemeVariations.rituelMatin.buildChip('3/5 complété')
```

### 5. Cercle d'icône décoratif

```dart
ThemeVariations.cheptel.buildIconCircle(
  size: 64,
  isDark: isDark,
)
```

### 6. Widget ThemedIconButton (helper)

```dart
import '../widgets/common/themed_icon_button.dart';

ThemedIconButton(
  variation: ThemeVariations.sante,
  onPressed: () => _openHealth(),
  tooltip: 'Ouvrir Santé',
  size: 28,
)
```

---

## 📚 VARIATIONS DISPONIBLES

| Variation | Couleur | Icône | Utilisation |
|-----------|---------|-------|-------------|
| `cheptel` | Vert #2E7D32 | `pets_rounded` | Gestion du troupeau |
| `sante` | Vert success #2E7D32 | `medical_services_rounded` | Suivi médical |
| `reproduction` | Violet #7B1FA2 | `family_restroom_rounded` | Accouplements |
| `finance` | Vert success | `account_balance_wallet_rounded` | Comptabilité |
| `rituelMatin` | Orange warning | `wb_sunny_rounded` | Rituels matin |
| `rituelSoir` | Bleu info | `nights_stay_rounded` | Rituels soir |
| `alertes` | Rouge error | `notifications_active_rounded` | Notifications |
| `parametres` | Gris neutral600 | `settings_rounded` | Configuration |
| `alimentation` | Orange | `restaurant_rounded` | Stock nourriture |

---

## 🔄 MIGRATION DEPUIS COULEURS ISOLÉES

### Avant (❌ à éviter)
```dart
// Couleurs hardcodées par écran
Container(
  decoration: BoxDecoration(
    color: const Color(0xFF4CAF50).withOpacity(0.1),
    border: Border.all(color: Colors.green),
  ),
  child: Icon(Icons.medical_services, color: Colors.green),
)
```

### Après (✅ recommandé)
```dart
// ThemeVariation standardisée
Container(
  decoration: ThemeVariations.sante.cardDecoration(isDark: isDark),
  child: Icon(
    ThemeVariations.sante.icon,
    color: ThemeVariations.sante.accentColor,
  ),
)
```

---

## 🎨 MAPPER EMOJIS → ICONS

Pour migrer les emojis existants vers des icônes Material :

```dart
import '../../theme/theme_variations.dart';

// Avant
Text('🌅', style: TextStyle(fontSize: 28))

// Après
Icon(
  EmojiToIconMapper.getIcon('🌅'), // Retourne Icons.wb_sunny_rounded
  size: 28,
)

// Avec fallback
Icon(
  EmojiToIconMapper.getIconOrDefault('❓', fallback: Icons.help_rounded),
)
```

**Emojis mappés :**
- 🌅 → `wb_sunny_rounded`
- 🌙 → `nights_stay_rounded`
- 🎉 → `celebration_rounded`
- 💧 → `water_drop_rounded`
- 🥤 → `local_drink_rounded`
- 🍽️ → `restaurant_rounded`
- 🔍 → `search_rounded`
- 🧹 → `cleaning_services_rounded`
- ✅ → `check_circle_rounded`
- ⚠️ → `warning_rounded`
- ⏰ → `schedule_rounded`
- 🐰/🐇 → `pets_rounded`
- 💊 → `medication_rounded`
- 💉 → `vaccines_rounded`
- 💰 → `attach_money_rounded`

---

## 🛠️ BONNES PRATIQUES

### 1. Constance thématique
**Règle :** Un écran = une variation dominante
```dart
// ✅ BON : Écran Santé utilise ThemeVariations.sante partout
class SanteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(ThemeVariations.sante.icon),
      ),
      body: Column([
        ThemedIconCircle(variation: ThemeVariations.sante),
        ActionCard(iconColor: ThemeVariations.sante.accentColor),
      ]),
    );
  }
}
```

### 2. Variations secondaires
**Règle :** Accepté pour éléments non-dominants
```dart
// ✅ BON : Dashboard peut mélanger plusieurs variations
Widget build(BuildContext context) {
  return Column([
    ThemedIconButton(variation: ThemeVariations.sante, ...),
    ThemedIconButton(variation: ThemeVariations.reproduction, ...),
    ThemedIconButton(variation: ThemeVariations.finance, ...),
  ]);
}
```

### 3. Respect du Design System
**Règle :** ThemeVariations = couleurs et icônes uniquement
```dart
// ❌ INTERDIT : Ne pas créer de styles custom
Container(
  padding: const EdgeInsets.all(24), // ❌ Valeur hardcodée
  borderRadius: BorderRadius.circular(18), // ❌ Valeur non-standard
)

// ✅ BON : Utiliser les tokens AppTheme
Container(
  padding: AppTheme.paddingAllLarge, // ✅ Token standardisé
  borderRadius: AppTheme.borderRadiusLarge, // ✅ Token standardisé
)
```

---

## 📋 CHECKLIST DE MIGRATION

Pour migrer un écran vers ThemeVariations :

- [ ] Import `theme_variations.dart`
- [ ] Identifier la variation principale (ex: `sante`, `reproduction`)
- [ ] Remplacer les icônes hardcodées par `variation.icon`
- [ ] Remplacer les couleurs hardcodées par `variation.accentColor`
- [ ] Utiliser `variation.cardDecoration()` pour les containers
- [ ] Vérifier les emojis et les mapper avec `EmojiToIconMapper`
- [ ] Tester visuellement le rendu en mode clair/sombre
- [ ] Lancer `flutter analyze` pour détecter les warnings

---

## 🔗 RÉFÉRENCES

- [Design System complet](../theme/app_theme.dart)
- [Variations thématiques](../theme/theme_variations.dart)
- [Audit de cohérence](../../docs/AUDIT_THEMES_COHERENCE.md)
- [Corrections Rituel](../../docs/CORRECTIONS_THEME_RITUEL.md)

---

*Dernière mise à jour : 17 janvier 2026*
