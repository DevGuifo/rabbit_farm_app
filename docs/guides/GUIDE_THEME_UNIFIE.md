# Guide du Thème Unifié - BunnyManager

**Date**: 1 janvier 2026  
**Objectif**: Assurer la cohérence visuelle dans toute l'application

## ⚠️ Problème Identifié

L'application utilise **plusieurs systèmes de couleurs incohérents** :
- ❌ `Colors.blue`, `Colors.red`, `Colors.green` hardcodés
- ❌ Couleurs spécifiques par écran (brown pour fumier, etc.)
- ❌ Multiples nuances de vert (`primaryGreen`, `primaryNeonGreen`, `success`)
- ❌ Thèmes différents entre écrans (Stitch, Material, custom)

## ✅ Solution : AppTheme Centralisé

**Fichier unique** : `lib/theme/app_theme.dart`

### Palette de Couleurs Unifiée

```dart
// ✅ TOUJOURS utiliser AppTheme
import 'package:rabbit_farm_app/theme/app_theme.dart';

// Couleurs primaires
AppTheme.primaryGreen      // #4CAF50 - Couleur principale
AppTheme.primaryYellow     // #F9F506 - FAB, accents
AppTheme.primaryNeonGreen  // #13EC25 - Reproduction

// États & Actions
AppTheme.success  // ✅ Vert - Actions réussies
AppTheme.warning  // ⚠️ Orange - Alertes
AppTheme.error    // ❌ Rouge - Erreurs
AppTheme.info     // ℹ️ Bleu - Informations

// Accents secondaires
AppTheme.accentAmber  // Alimentation, fumier
AppTheme.accentPink   // Finance, ventes
AppTheme.accentTeal   // Santé alternative
AppTheme.accentCyan   // Informations

// Textes
AppTheme.textPrimary    // Noir - Texte principal
AppTheme.textSecondary  // Gris - Texte secondaire
AppTheme.textLight      // Blanc/Clair - Mode sombre

// Fonds
AppTheme.backgroundLight  // Mode clair
AppTheme.backgroundDark   // Mode sombre
AppTheme.cardLight        // Cartes claires
AppTheme.cardDark         // Cartes sombres
```

## 🚫 Règles Strictes

### ❌ À NE JAMAIS FAIRE

```dart
// ❌ INTERDIT - Couleurs hardcodées
backgroundColor: Colors.blue
foregroundColor: Colors.red
color: Colors.green
Icon(Icons.check, color: Colors.brown)

// ❌ INTERDIT - Couleurs personnalisées
backgroundColor: Color(0xFF123456)
color: Color.fromRGBO(255, 0, 0, 1.0)
```

### ✅ À FAIRE

```dart
// ✅ CORRECT - Utiliser AppTheme
backgroundColor: AppTheme.primaryGreen
foregroundColor: AppTheme.textLight
color: AppTheme.success
Icon(Icons.check, color: AppTheme.success)

// ✅ CORRECT - Adapter au mode sombre
final isDark = Theme.of(context).brightness == Brightness.dark;
color: isDark ? AppTheme.textLight : AppTheme.textPrimary
backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight
```

## 📋 Mappings par Fonctionnalité

### AppBars

```dart
// ✅ Par défaut
AppBar(
  backgroundColor: AppTheme.primaryGreen,
  foregroundColor: Colors.white,
)

// ✅ Santé
AppBar(
  backgroundColor: AppTheme.primaryNeonGreen,
  foregroundColor: AppTheme.textPrimary,
)

// ✅ Finance
AppBar(
  backgroundColor: AppTheme.accentPink,
  foregroundColor: AppTheme.textLight,
)

// ✅ Alimentation / Fumier
AppBar(
  backgroundColor: AppTheme.accentAmber,
  foregroundColor: Colors.white,
)
```

### FloatingActionButtons

```dart
// ✅ Par défaut (jaune signature)
FloatingActionButton(
  backgroundColor: AppTheme.primaryYellow,
  foregroundColor: AppTheme.textPrimary,
)

// ✅ Actions spécifiques
FloatingActionButton(
  backgroundColor: AppTheme.primaryGreen,  // Général
  backgroundColor: AppTheme.success,        // Validation
  backgroundColor: AppTheme.info,           // Information
)
```

### Snackbars

```dart
// ✅ Succès
SnackBar(
  content: Text('Opération réussie'),
  backgroundColor: AppTheme.success,
)

// ✅ Erreur
SnackBar(
  content: Text('Une erreur est survenue'),
  backgroundColor: AppTheme.error,
)

// ✅ Warning
SnackBar(
  content: Text('Attention !'),
  backgroundColor: AppTheme.warning,
)

// ✅ Info
SnackBar(
  content: Text('Information'),
  backgroundColor: AppTheme.info,
)
```

### Boutons

```dart
// ✅ Bouton primaire
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryGreen,
    foregroundColor: Colors.white,
  ),
)

// ✅ Bouton de validation
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.success,
  ),
)

// ✅ Bouton de suppression
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.error,
  ),
)

// ✅ Bouton secondaire
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: AppTheme.primaryGreen,
  ),
)
```

### Indicateurs de Statut

```dart
// ✅ Statut positif
Container(
  color: AppTheme.success.withValues(alpha: 0.1),
  child: Icon(Icons.check_circle, color: AppTheme.success),
)

// ✅ Statut warning
Container(
  color: AppTheme.warning.withValues(alpha: 0.1),
  child: Icon(Icons.warning, color: AppTheme.warning),
)

// ✅ Statut erreur
Container(
  color: AppTheme.error.withValues(alpha: 0.1),
  child: Icon(Icons.error, color: AppTheme.error),
)
```

## 🔍 Audit & Corrections

### Commandes de Vérification

```bash
# Trouver les Colors.* hardcodés
grep -r "Colors\.(blue|red|green|brown|orange|pink|purple|amber)" lib/screens/

# Trouver les Color() personnalisées
grep -r "Color(0x" lib/screens/

# Analyser un écran spécifique
grep "backgroundColor:\|color:" lib/screens/mon_screen.dart
```

### Écrans Corrigés (Session actuelle)

| Écran | Avant | Après |
|-------|-------|-------|
| fumier_screen.dart | `Colors.brown` | `AppTheme.accentAmber` |
| fumier_screen.dart | `Colors.green/red` | `AppTheme.success/error` |

### Écrans À Corriger (Priorité)

| Fichier | Ligne | Problème | Solution |
|---------|-------|----------|----------|
| auth/auth_screen.dart | Multiple | `Colors.blue/red/orange` | `AppTheme.info/error/warning` |
| auth/pin_screen.dart | 165 | `Colors.orange` | `AppTheme.warning` |
| parametres/parametres_screen.dart | Multiple | `Colors.red/green/orange` | `AppTheme.error/success/warning` |
| optimisation/protocoles_screen.dart | 503 | `Colors.red` | `AppTheme.error` |

## 📐 Espacements & Bordures

```dart
// ✅ Utiliser les constantes
padding: EdgeInsets.all(AppTheme.spacing16)
margin: EdgeInsets.symmetric(horizontal: AppTheme.spacing20)
borderRadius: BorderRadius.circular(AppTheme.radiusMedium)

// ❌ Ne pas hardcoder
padding: EdgeInsets.all(16)  // ❌
borderRadius: BorderRadius.circular(12)  // ❌
```

## 🎨 Thèmes Contextuels

### Mode Sombre / Clair

```dart
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return Container(
    color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
    child: Text(
      'Mon texte',
      style: TextStyle(
        color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
      ),
    ),
  );
}
```

### Écrans Spécialisés

| Section | Couleur Primaire | Usage |
|---------|------------------|-------|
| Cheptel | `primaryGreen` | Général, lapins |
| Santé | `primaryNeonGreen` | Soins, pharmacie |
| Reproduction | `primaryNeonGreen` | Accouplements, portées |
| Finance | `accentPink` | Recettes, dépenses |
| Alimentation | `accentAmber` | Stocks, distribution |
| Fumier | `accentAmber` | Collectes, ventes |

## ✅ Checklist Nouvel Écran

Avant de créer/modifier un écran, vérifier :

- [ ] Import de `app_theme.dart`
- [ ] Aucun `Colors.*` hardcodé
- [ ] Aucun `Color(0x...)` personnalisé
- [ ] AppBar utilise `AppTheme.*`
- [ ] FAB utilise `AppTheme.primaryYellow` ou équivalent
- [ ] Snackbars utilisent `AppTheme.success/error/warning`
- [ ] Boutons utilisent `AppTheme.*`
- [ ] Support mode sombre avec `isDark`
- [ ] Espacements utilisent `AppTheme.spacing*`
- [ ] Border radius utilisent `AppTheme.radius*`

## 🚀 Prochaines Étapes

1. **Audit complet** : Scanner tous les écrans
2. **Corrections prioritaires** : auth_screen, parametres_screen
3. **Documentation widgets** : Créer composants réutilisables
4. **Tests visuels** : Vérifier cohérence sur tous les écrans
5. **Guidelines design** : Documenter patterns UI communs

## 📖 Ressources

- **Thème principal** : [lib/theme/app_theme.dart](lib/theme/app_theme.dart)
- **Rapport responsive** : [RAPPORT_DASHBOARD_RESPONSIVE.md](RAPPORT_DASHBOARD_RESPONSIVE.md)
- **Cahier des charges** : [cahier_charges_app_elevage.md](cahier_charges_app_elevage.md)

---

**Note** : Ce guide doit être suivi strictement pour maintenir la cohérence visuelle de l'application. Toute déviation crée une expérience utilisateur fragmentée.
