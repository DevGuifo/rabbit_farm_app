# 🌍 PLAN D'INTERNATIONALISATION COMPLET - BunnyManager

**Date :** 5 janvier 2026  
**Objectif :** Rendre 100% de l'application multilingue (FR/EN + préparation langues africaines)  
**Expert :** Lead Flutter Developer i18n spécialisé  
**Destinataire :** Propriétaire non-technique

---

## 📊 ÉTAT DES LIEUX (Audit Complet Réalisé)

### ✅ Ce qui est DÉJÀ fait

- **300+ clés i18n** existantes dans `lib/l10n/app_fr.arb` et `app_en.arb`
- **Système i18n configuré** : `l10n.yaml`, `generate: true`, `AppLocalizations` fonctionnel
- **Sélecteur de langue** : présent dans Paramètres (FR ↔ EN)
- **Glossaire métier** : 15 termes cuniculture documentés avec tooltips
- **Rapport UX linguistique** : vocabulaire normalisé, termes techniques simplifiés

### ⚠️ Ce qui RESTE à faire

**1820 textes en dur** détectés automatiquement répartis comme suit :

| Catégorie | Nombre | Priorité | Exemples |
|-----------|--------|----------|----------|
| **Text widgets** | 1110 | 🔴 **CRITIQUE** | `Text('Ajouter un lapin')`, `Text('Enregistrer')` |
| **TextField labels/hints** | 212 | 🟠 **HAUTE** | `labelText: 'Nom *'`, `hintText: 'Entrez le poids...'` |
| **Titres d'écrans** | 176 | 🟠 **HAUTE** | `title: 'Cheptel'`, `title: 'Reproduction'` |
| **SnackBars/Messages** | 88 | 🟡 **MOYENNE** | `SnackBar(content: Text('Lapin ajouté'))` |
| **Dropdown options** | 52 | 🟢 **BASSE** | `DropdownMenuItem(child: Text('Mâle'))` |

**Fichiers les plus impactés :**
1. `parametres_screen.dart` - 85 occurrences
2. `preparation_nid_screen.dart` - 51 occurrences  
3. `calculatrice_screen.dart` - 49 occurrences
4. `courbes_croissance_screen.dart` - 46 occurrences
5. `auth_screen.dart` - 45 occurrences

---

## 🎯 STRATÉGIE D'IMPLÉMENTATION (20 Phases)

### 📦 PHASE 1-5 : Audit & Architecture (🟢 EN COURS)

**✅ Phase 1 :** Analyser état actuel des fichiers ARB  
- **Résultat :** 300 FR keys, 296 EN keys, 4 clés manquantes EN
- **Action :** Synchroniser EN avec FR

**✅ Phase 2 :** Scanner textes en dur par catégorie  
- **Résultat :** 1820 textes détectés, rapport JSON généré
- **Fichier :** `i18n_extraction_report.json`

**✅ Phase 3 :** Extraction automatique avec suggestions de clés  
- **Résultat :** `nouvelles_cles_suggerees.arb` créé avec 1820 clés
- **Action :** Review et fusion manuelle nécessaire

**🔵 Phase 4 :** Créer architecture de clés ARB  
- **Convention :** `section_action_element` (ex: `cheptel_button_add`, `form_label_name`)
- **Sections :** `common`, `screens`, `forms`, `messages`, `errors`, `tooltips`

**🔵 Phase 5 :** Enrichir app_fr.arb (référence principale)  
- **Objectif :** 500+ clés couvrant 100% de l'app
- **Inclure :** Descriptions `@key` pour chaque clé

### 📝 PHASE 6-8 : Traduction Anglaise

**Phase 6 :** Traduction EN professionnelle cuniculture  
- **Respect terminologie :** "Doe" (femelle), "Buck" (mâle), "Kindle" (portée)
- **Fichier :** `app_en.arb` complété à 100%

**Phase 7 :** Validation cohérence FR/EN  
- **Test :** Toutes les clés FR ont équivalent EN
- **Tool :** Script de validation (à créer)

**Phase 8 :** Review UX textes EN  
- **Longueur :** Vérifier overflow dans UI (EN souvent + long que FR)
- **Ton :** Pédagogique, simple, sans jargon technique

### 🔧 PHASE 9-16 : Refactoring Code (CŒUR DU TRAVAIL)

**Phase 9 :** Navigation (home, drawer, bottom bar)  
- **Fichiers :** `home_screen.dart`, `main_screen.dart`
- **Remplacement :** `Text('Cheptel')` → `Text(AppLocalizations.of(context).cheptel)`

**Phase 10 :** Section Cheptel (12 fichiers)  
- **Écrans :** Liste, ajout, édition, fiche détail
- **Focus :** Formulaires (labels, hints, validations)

**Phase 11 :** Section Reproduction (15 fichiers)  
- **Vocabulaire métier :** Saillie, palpation, sevrage, portée
- **Écrans :** Planifier, enregistrer portée, historique

**Phase 12 :** Section Santé (18 fichiers)  
- **Écrans :** Soins, pharmacie, pesées, courbes croissance
- **Messages :** Erreurs, confirmations, snackbars

**Phase 13 :** Section Finances (5 fichiers)  
- **Termes :** Recettes, dépenses, bénéfices, rentabilité

**Phase 14 :** Section Utilitaires (15 fichiers)  
- **Écrans :** Calculatrice, calendrier, tâches, journal

**Phase 15 :** Widgets réutilisables (25 fichiers)  
- **Composants :** Cards, dialogs, buttons, empty_states
- **Priorité HAUTE :** Impact multiple écrans

**Phase 16 :** Authentification (8 fichiers)  
- **Sensible :** Messages erreur, validation, instructions

### ✅ PHASE 17-19 : Validation & Documentation

**Phase 17 :** Tests changement de langue  
- **Test manuel :** Parcourir TOUS les écrans FR ↔ EN
- **Checklist :** Aucun texte en dur visible

**Phase 18 :** Documentation utilisateur  
- **Guide :** Comment ajouter une langue, modifier traductions
- **Conventions :** Nommage clés ARB, structure fichiers

**Phase 19 :** Tests automatisés i18n  
- **Vérifier :** Synchronisation FR/EN, pas de clés orphelines
- **Script :** Audit continu dans CI/CD

### 🚀 PHASE 20 : Préparation Langues Africaines

**Phase 20 :** Structure multilingue étendue  
- **Fichiers :** `app_sw.arb` (Swahili), `app_wo.arb` (Wolof)
- **Contenu :** Clés vides + instructions traduction humaine
- **Termes métier :** Identifier équivalents locaux (ex: "lapereau" en Swahili)

---

## 🛠️ OUTILS CRÉÉS (Automatisation)

### 1. Script d'Audit i18n (`scripts/audit_i18n.sh`)
```bash
chmod +x scripts/audit_i18n.sh
./scripts/audit_i18n.sh
```
**Fonction :** Détecte textes en dur, clés orphelines, statistiques ARB

### 2. Extracteur Python (`scripts/extract_hardcoded_texts.py`)
```bash
python3 scripts/extract_hardcoded_texts.py .
```
**Fonction :** Génère rapport JSON + fichier ARB avec suggestions de clés

### 3. Rapport d'Extraction (`i18n_extraction_report.json`)
**Contenu :** 1820 textes détectés avec fichier, ligne, contexte, clé suggérée

### 4. Nouvelles Clés Suggérées (`nouvelles_cles_suggerees.arb`)
**Contenu :** 1820 clés ARB prêtes à merger manuellement

---

## 📋 EXEMPLE DE CONVERSION (Processus Type)

### AVANT (Code actuel avec texte en dur)
```dart
// lib/screens/cheptel/add_lapin_screen.dart
AppBar(
  title: Text('Ajouter un lapin'),  // ❌ Texte en dur
)

TextField(
  labelText: 'Nom *',  // ❌ Texte en dur
  hintText: 'Ex: Bella',  // ❌ Texte en dur
)

ElevatedButton(
  onPressed: _save,
  child: Text('Enregistrer'),  // ❌ Texte en dur
)
```

### APRÈS (Code i18n)
```dart
// lib/screens/cheptel/add_lapin_screen.dart
AppBar(
  title: Text(AppLocalizations.of(context).cheptelTitleAdd),  // ✅ i18n
)

TextField(
  labelText: AppLocalizations.of(context).formLabelName,  // ✅ i18n
  hintText: AppLocalizations.of(context).formHintName,  // ✅ i18n
)

ElevatedButton(
  onPressed: _save,
  child: Text(AppLocalizations.of(context).commonButtonSave),  // ✅ i18n
)
```

### AJOUT dans `app_fr.arb`
```json
{
  "cheptelTitleAdd": "Ajouter un lapin",
  "@cheptelTitleAdd": {
    "description": "Titre écran ajout d'un lapin"
  },
  
  "formLabelName": "Nom *",
  "@formLabelName": {
    "description": "Label champ nom (obligatoire)"
  },
  
  "formHintName": "Ex: Bella",
  "@formHintName": {
    "description": "Exemple de nom de lapin"
  },
  
  "commonButtonSave": "Enregistrer",
  "@commonButtonSave": {
    "description": "Bouton enregistrer (action globale)"
  }
}
```

### AJOUT dans `app_en.arb`
```json
{
  "cheptelTitleAdd": "Add Rabbit",
  "@cheptelTitleAdd": {
    "description": "Title for add rabbit screen"
  },
  
  "formLabelName": "Name *",
  "@formLabelName": {
    "description": "Name field label (required)"
  },
  
  "formHintName": "Ex: Bella",
  "@formHintName": {
    "description": "Example rabbit name"
  },
  
  "commonButtonSave": "Save",
  "@commonButtonSave": {
    "description": "Save button (global action)"
  }
}
```

---

## 📈 ESTIMATION EFFORT

| Phase | Durée estimée | Complexité | Risques |
|-------|--------------|------------|---------|
| **Phases 1-5 (Audit)** | ✅ TERMINÉ | Faible | Aucun |
| **Phases 6-8 (Traduction EN)** | 2-3 jours | Moyenne | Terminologie métier |
| **Phases 9-16 (Refactoring)** | 10-15 jours | Haute | Régression UI, oublis |
| **Phases 17-19 (Validation)** | 2-3 jours | Moyenne | Tests exhaustifs |
| **Phase 20 (Langues africaines)** | 1 jour | Faible | Traducteurs externes |

**TOTAL ESTIMÉ :** 15-22 jours ouvrés

**BUDGET RECOMMANDÉ :** 20-30% de marge pour imprévus (bugs, ajustements UI)

---

## ⚠️ POINTS D'ATTENTION

### 🔴 Critiques
1. **Régression UI** : Textes anglais souvent plus longs → vérifier overflow
2. **Clés manquantes** : Si clé oubliée, app crash en mode release
3. **Contexte perdu** : `of(context)` peut échouer dans certains widgets stateless

### 🟠 Importants
4. **Performance** : AppLocalizations chargé à chaque rebuild (optimisé par Flutter)
5. **Tests** : Tester CHAQUE écran en FR ET EN avant merge
6. **Git** : Branches séparées par phase (ex: `feat/i18n-cheptel`)

### 🟡 À surveiller
7. **Pluriels** : Gérer singulier/pluriel avec paramètres ARB
8. **Dates/Nombres** : Utiliser `intl` package pour formatage localisé
9. **Images/Icons** : Certaines peuvent nécessiter adaptation culturelle

---

## 🎓 POUR LE PROPRIÉTAIRE (Explications Non-Techniques)

### Qu'est-ce qu'on fait concrètement ?

Actuellement, l'application contient des **textes "écrits en dur"** dans le code, comme :
```dart
Text('Ajouter un lapin')  // Ce texte est en français dans le code
```

**Problème :** Si un utilisateur anglophone ouvre l'app, ce texte reste en français !

**Solution :** On remplace TOUS ces textes par des **clés** qui pointent vers des fichiers de traduction :
```dart
Text(AppLocalizations.of(context).ajouterLapin)  // Clé qui cherche la traduction
```

Ces clés vont chercher la bonne traduction selon la langue choisie :
- Fichier `app_fr.arb` : `"ajouterLapin": "Ajouter un lapin"`
- Fichier `app_en.arb` : `"ajouterLapin": "Add Rabbit"`

### Pourquoi c'est important ?

1. **Accessibilité mondiale** : Éleveurs anglophones, hispanophones peuvent utiliser l'app
2. **Expansion Afrique** : Préparation Swahili, Wolof pour marchés locaux
3. **Professionnalisme** : Standard international, qualité logicielle
4. **Maintenance** : Modifier 1 seul fichier pour changer tous les textes

### Combien ça coûte ?

**Temps :** 3-4 semaines de travail développeur  
**Argent :** Coût traduction professionnelle si langues exotiques (optionnel)  
**Risque :** Faible si tests rigoureux à chaque étape

### Quand ce sera fini ?

Vous pourrez :
- ✅ Changer langue app dans Paramètres (déjà fonctionnel)
- ✅ Voir TOUTE l'interface dans la langue choisie (objectif)
- ✅ Ajouter facilement de nouvelles langues (Espagnol, Portugais, Swahili...)
- ✅ Exporter vos fichiers ARB pour traduction externe

---

## 📞 PROCHAINES ÉTAPES IMMÉDIATES

### 🔵 Action 1 : Décision Go/No-Go
**Vous devez décider** : Est-ce qu'on lance le refactoring complet maintenant ?

**Options :**
- **Option A (Recommandée)** : Refactoring complet par phases (3-4 semaines)
- **Option B (Progressive)** : Refactoring par section prioritaire (Cheptel d'abord, puis reste)
- **Option C (Minimaliste)** : Corriger seulement les 10 écrans les plus utilisés

### 🟢 Action 2 : Validation Rapport
**Lisez** le fichier `i18n_extraction_report.json` pour voir tous les textes détectés

**Commande :**
```bash
cat i18n_extraction_report.json | less
```

### 🟣 Action 3 : Test Manuel Langue Actuelle
**Testez** le changement FR ↔ EN actuel pour voir ce qui fonctionne déjà

**Procédure :**
1. Lancez l'app : `flutter run -d linux`
2. Allez dans Paramètres → Langue
3. Sélectionnez "English"
4. Parcourez tous les écrans
5. Notez ce qui reste en français (= textes en dur à corriger)

---

## 📚 RESSOURCES CRÉÉES

| Fichier | Description |
|---------|-------------|
| `scripts/audit_i18n.sh` | Script bash audit automatique |
| `scripts/extract_hardcoded_texts.py` | Extracteur Python textes en dur |
| `i18n_extraction_report.json` | Rapport complet 1820 textes |
| `nouvelles_cles_suggerees.arb` | Clés ARB suggérées (à review) |
| `PLAN_I18N_COMPLET.md` | Ce document (stratégie globale) |
| `RAPPORT_AUDIT_LANGAGE_UX.md` | Audit vocabulaire métier (existant) |

---

**🎯 Objectif Final :** Application 100% multilingue, maintenable, prête pour expansion internationale

**📅 Date cible :** Fin janvier 2026 (si démarrage immédiat)

**✍️ Document rédigé par :** Lead Flutter Developer i18n  
**📧 Questions ?** Posez-les avant de démarrer le refactoring !
