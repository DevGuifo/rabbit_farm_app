# Guide d'Internationalisation (i18n) - BunnyManager

> 📖 **Document non-technique** destiné aux contributeurs, traducteurs et partenaires du projet.

---

## 📋 Table des matières

1. [Pourquoi certains mots sont remplacés ?](#-pourquoi-certains-mots-sont-remplacés-)
2. [Vocabulaire technique de la cuniculture](#-vocabulaire-technique-de-la-cuniculture)
3. [Structure des fichiers de traduction](#-structure-des-fichiers-de-traduction)
4. [Comment ajouter une nouvelle langue ?](#-comment-ajouter-une-nouvelle-langue-)
5. [Bonnes pratiques pour les traducteurs](#-bonnes-pratiques-pour-les-traducteurs)
6. [Questions fréquentes](#-questions-fréquentes)

---

## 🎯 Pourquoi certains mots sont remplacés ?

### Objectifs pédagogiques

BunnyManager est conçu pour être utilisé par des éleveurs de lapins dans des contextes très différents :
- **Éleveurs africains** débutant dans la cuniculture
- **Coopératives agricoles** en zone rurale
- **ONG et projets de développement** formant des éleveurs
- **Éleveurs professionnels** en Europe et ailleurs

Pour cette raison, nous avons établi des **principes de vocabulaire** :

| Principe | Explication | Exemple |
|----------|-------------|---------|
| **Neutralité culturelle** | Éviter les références religieuses ou culturelles spécifiques | "Mise bas" au lieu de "accouchement" |
| **Précision technique** | Utiliser le jargon professionnel de la cuniculture | "Saillie" au lieu de "accouplement" |
| **Pédagogie** | Rester compréhensible pour les débutants | Tooltips explicatifs sur les termes techniques |
| **Universalité** | Faciliter la traduction vers d'autres langues | Phrases courtes et claires |

### Exemples de remplacements effectués

| ❌ Avant | ✅ Après | Raison |
|---------|---------|--------|
| "Breeding" | "Saillie" | Terme professionnel français |
| "Active" | "Actifs/Actives" | Accord grammatical français |
| "All" / "Tous" | "Tous" | Cohérence linguistique |
| "Gestating" | "Gestantes" | Vocabulaire cuniculture |
| "Palpation required" | "Palpation requise" | Français naturel |
| "Ready to wean" | "Prêtes à sevrer" | Terminologie élevage |

---

## 🐰 Vocabulaire technique de la cuniculture

Ces termes sont utilisés dans toute l'application avec des **tooltips explicatifs** :

### Reproduction

| Terme | Définition | Anglais |
|-------|-----------|---------|
| **Saillie** | Accouplement contrôlé entre un mâle et une femelle | Mating |
| **Mise bas** | Naissance des lapereaux (aussi appelée parturition) | Kindling |
| **Gestation** | Période de grossesse, environ 31 jours chez le lapin | Gestation |
| **Palpation** | Diagnostic de gestation par toucher abdominal (10-14 jours) | Palpation |
| **Portée** | Ensemble des lapereaux nés d'une même mise bas | Litter |

### Animaux

| Terme | Définition | Anglais |
|-------|-----------|---------|
| **Lapereaux** | Jeunes lapins de la naissance au sevrage | Kits |
| **Femelle reproductrice** | Lapine destinée à la reproduction | Breeding doe |
| **Mâle reproducteur** | Lapin mâle destiné à la reproduction | Breeding buck |

### Élevage

| Terme | Définition | Anglais |
|-------|-----------|---------|
| **Sevrage** | Séparation des lapereaux de la mère (4-8 semaines) | Weaning |
| **Clapier** | Logement individuel ou collectif pour les lapins | Hutch |
| **Nid** | Boîte maternité préparée par la femelle avant mise bas | Nest |
| **GMQ** | Gain Moyen Quotidien - indicateur de croissance (g/jour) | ADG (Average Daily Gain) |
| **Réforme** | Retrait définitif d'un animal du cheptel reproducteur | Culling |
| **Consanguinité** | Parenté génétique entre deux reproducteurs | Inbreeding |

---

## 📁 Structure des fichiers de traduction

Les traductions sont stockées dans le dossier `lib/l10n/` au format **ARB** (Application Resource Bundle) :

```
lib/l10n/
├── app_fr.arb    ← Français (langue principale)
├── app_en.arb    ← Anglais
└── (futures langues ici)
```

### Format d'un fichier ARB

```json
{
  "@@locale": "fr",
  "navCheptel": "Cheptel",
  "navSante": "Santé",
  "verifierFemelleGestation": "Vérifier {count} femelle(s) pour gestation",
  "@verifierFemelleGestation": {
    "placeholders": {
      "count": {"type": "int"}
    }
  }
}
```

**Éléments clés :**
- `"@@locale"` : code de la langue (fr, en, sw, pt...)
- `"cleSimple"` : texte sans variable
- `"cleAvecVariable"` : utilise `{nomVariable}` pour les valeurs dynamiques
- `@cleDescription` : métadonnées et descriptions pour les traducteurs

---

## 🌍 Comment ajouter une nouvelle langue ?

### Étape 1 : Créer le fichier ARB

1. **Copier** le fichier `lib/l10n/app_fr.arb` (référence complète)
2. **Renommer** en `app_XX.arb` où `XX` est le code ISO de la langue :
   - `sw` = Swahili
   - `pt` = Portugais
   - `ar` = Arabe
   - `wo` = Wolof
   - etc.

### Étape 2 : Traduire les textes

1. **Modifier** `"@@locale": "XX"` avec le code de votre langue
2. **Traduire** chaque valeur (les clés restent identiques)

**Exemple pour Swahili (`app_sw.arb`) :**
```json
{
  "@@locale": "sw",
  "navCheptel": "Mifugo",
  "navSante": "Afya",
  "navReproduction": "Uzazi",
  "femelles": "Majike",
  "males": "Madume",
  "lapereaux": "Watoto wa sungura"
}
```

### Étape 3 : Déclarer la langue

Modifier le fichier `l10n.yaml` à la racine du projet :

```yaml
arb-dir: lib/l10n
template-arb-file: app_fr.arb
output-localization-file: app_localizations.dart
```

Puis ajouter la locale dans `lib/main.dart` :

```dart
supportedLocales: const [
  Locale('fr', 'FR'),
  Locale('en', 'US'),
  Locale('sw', 'KE'),  // ← Nouvelle langue
],
```

### Étape 4 : Régénérer les fichiers

Exécuter dans le terminal :
```bash
flutter pub get
```

Les fichiers de traduction seront automatiquement générés.

---

## ✅ Bonnes pratiques pour les traducteurs

### À faire ✅

- **Conserver les variables** : `{count}`, `{time}`, `{version}` doivent rester intacts
- **Respecter le contexte** : un terme peut avoir plusieurs traductions selon le contexte
- **Adapter les unités** : kg, g, € peuvent changer selon les régions
- **Tester visuellement** : certains textes peuvent être trop longs pour les boutons

### À éviter ❌

- Ne pas traduire les **clés** (texte avant les deux-points)
- Ne pas ajouter/supprimer de **clés** sans synchroniser toutes les langues
- Éviter les **abréviations non standard**
- Ne pas utiliser de **références culturelles locales** (fêtes, expressions idiomatiques)

### Exemple de traduction correcte

| Clé | Français | Anglais ✅ | Anglais ❌ |
|-----|----------|-----------|-----------|
| `miseBasPrevue` | Mise bas prévue | Expected kindling | Baby bunnies coming |
| `palpationRequise` | Palpation requise | Palpation required | Touch the belly |
| `verifierFemelleGestation` | Vérifier {count} femelle(s) | Check {count} doe(s) | Check {count} rabbits |

---

## ❓ Questions fréquentes

### Pourquoi utiliser "Saillie" plutôt que "Accouplement" ?

"Saillie" est le terme technique professionnel en cuniculture et élevage. Il est plus précis et reconnu par les vétérinaires et techniciens agricoles.

### Les tooltips sont-ils traduits ?

Oui ! Les définitions du glossaire sont disponibles dans chaque langue. Les traducteurs doivent adapter les explications au contexte local.

### Comment gérer le pluriel ?

Flutter gère automatiquement les pluriels avec la syntaxe ICU :
```json
"nombreLapins": "{count, plural, =0{Aucun lapin} =1{1 lapin} other{{count} lapins}}"
```

### Puis-je modifier le vocabulaire technique ?

Le vocabulaire technique (saillie, mise bas, sevrage...) doit rester cohérent dans toute l'application. Si une modification est nécessaire, elle doit être discutée avec l'équipe pour maintenir la cohérence.

### Comment signaler une erreur de traduction ?

1. Créer une **issue GitHub** avec le label `traduction`
2. Indiquer : langue, clé concernée, texte actuel, proposition

---

## 📊 État des traductions

| Langue | Code | Progression | Responsable |
|--------|------|-------------|-------------|
| 🇫🇷 Français | `fr` | ✅ 100% | Équipe core |
| 🇬🇧 Anglais | `en` | ✅ 100% | Équipe core |
| 🇰🇪 Swahili | `sw` | ⏳ Planifié | - |
| 🇧🇷 Portugais | `pt` | ⏳ Planifié | - |
| 🇸🇳 Wolof | `wo` | ⏳ Planifié | - |

---

## 📞 Contact

Pour toute question sur les traductions ou le vocabulaire :
- **Issues GitHub** : étiquette `i18n` ou `traduction`
- **Email** : (à définir)

---

*Document mis à jour : Janvier 2025*
*Version BunnyManager : 1.2.0*
