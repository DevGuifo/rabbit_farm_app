# 🛠️ Outils d'Internationalisation - README

**Date :** 5 janvier 2026  
**Projet :** BunnyManager i18n Tools  
**Auteur :** Lead Flutter Developer

---

## 📦 Contenu du Package i18n

Ce package contient **tous les outils nécessaires** pour auditer, planifier et implémenter l'internationalisation de BunnyManager.

### 📂 Structure des Fichiers

```
rabbit_farm_app/
├── 📘 PLAN_I18N_COMPLET.md                 # Stratégie 20 phases détaillée
├── 📙 GUIDE_UTILISATEUR_I18N.md            # Guide propriétaire non-technique
├── 📗 GUIDE_TEST_LANGUE.md                 # Procédure test FR ↔ EN
├── 📊 RESUME_EXECUTIF_I18N.md              # Résumé décisionnel
├── 📋 RAPPORT_AUDIT_LANGAGE_UX.md          # Audit vocabulaire métier (existant)
│
├── 🔧 scripts/
│   ├── audit_i18n.sh                       # Script bash audit automatique
│   └── extract_hardcoded_texts.py          # Extracteur Python textes en dur
│
├── 📦 Résultats d'audit/
│   ├── i18n_extraction_report.json         # Rapport 1820 textes détectés
│   └── nouvelles_cles_suggerees.arb        # Clés ARB suggérées (1820)
│
├── 🌍 Fichiers de traduction/
│   ├── lib/l10n/app_fr.arb                 # Traductions françaises (300 keys)
│   └── lib/l10n/app_en.arb                 # Traductions anglaises (296 keys)
│
└── ✅ Tests/
    └── test/locale_provider_test.dart      # Tests unitaires LocaleProvider
```

---

## 🚀 GUIDE D'UTILISATION RAPIDE

### 1️⃣ Audit Automatique (Bash)

**Objectif :** Détecter textes en dur, clés orphelines, statistiques ARB

**Commande :**
```bash
cd /home/guifo/Bureau/rabbit_farm_app
chmod +x scripts/audit_i18n.sh
./scripts/audit_i18n.sh
```

**Résultat attendu :**
```
🔍 AUDIT I18N - BunnyManager
📊 STATISTIQUES GLOBALES
✅ Fichiers Dart totaux: 337
✅ Clés FR (app_fr.arb): 300
✅ Clés EN (app_en.arb): 296

⚠️  DÉTECTION TEXTES EN DUR
1. Text() widgets avec strings directes: [liste...]
2. title: et label: avec strings: [liste...]
...
```

**Durée d'exécution :** ~10-15 secondes

---

### 2️⃣ Extraction Avancée (Python)

**Objectif :** Générer rapport JSON + fichier ARB avec clés suggérées

**Commande :**
```bash
cd /home/guifo/Bureau/rabbit_farm_app
python3 scripts/extract_hardcoded_texts.py .
```

**Résultat attendu :**
```
🔍 Extraction des textes en dur...
   Projet: .

✅ Rapport généré: ./i18n_extraction_report.json
✅ Nouvelles clés ARB générées: ./nouvelles_cles_suggerees.arb
   Total: 1820 clés

📊 RÉSUMÉ:
   Total textes détectés: 1820
   Par catégorie:
     - Text_widget         : 1110 textes
     - textfield           :  212 textes
     - title_string        :  176 textes
     ...
```

**Fichiers générés :**
- `i18n_extraction_report.json` (rapport détaillé)
- `nouvelles_cles_suggerees.arb` (clés prêtes à merger)

**Durée d'exécution :** ~20-30 secondes

---

### 3️⃣ Analyse du Rapport JSON

**Objectif :** Explorer les textes détectés avec contexte

**Commande :**
```bash
cd /home/guifo/Bureau/rabbit_farm_app
cat i18n_extraction_report.json | jq '.'
```

**Ou avec less pour navigation :**
```bash
cat i18n_extraction_report.json | jq '.' | less
```

**Structure du rapport :**
```json
{
  "total_files_scanned": 337,
  "total_texts_found": 1820,
  "by_category": {
    "Text_widget": {
      "count": 1110,
      "examples": [
        {
          "text": "Ajouter un lapin",
          "file": "lib/screens/cheptel/add_lapin_screen.dart",
          "line": 219,
          "context": "...",
          "suggested_key": "ajouterLapin"
        }
      ]
    }
  }
}
```

---

### 4️⃣ Inspection Fichiers ARB

**Objectif :** Voir l'état actuel des traductions

**Compter les clés FR :**
```bash
grep -c '^  "[^@]' lib/l10n/app_fr.arb
```

**Compter les clés EN :**
```bash
grep -c '^  "[^@]' lib/l10n/app_en.arb
```

**Comparer FR vs EN (trouver clés manquantes) :**
```bash
diff <(grep '^  "[^@]' lib/l10n/app_fr.arb | sed 's/:.*//') \
     <(grep '^  "[^@]' lib/l10n/app_en.arb | sed 's/:.*//')
```

**Exemple clés FR :**
```bash
head -30 lib/l10n/app_fr.arb
```

---

### 5️⃣ Validation Cohérence FR/EN

**Objectif :** Vérifier que chaque clé FR a équivalent EN

**Script de validation (à créer) :**
```bash
#!/bin/bash
# validate_arb_sync.sh

FR_KEYS=$(grep '^  "[^@]' lib/l10n/app_fr.arb | sed 's/":\s*".*//' | sed 's/\s*"//')
EN_KEYS=$(grep '^  "[^@]' lib/l10n/app_en.arb | sed 's/":\s*".*//' | sed 's/\s*"//')

echo "🔍 Vérification synchronisation FR ↔ EN"
echo ""

missing=0
for key in $FR_KEYS; do
  if ! echo "$EN_KEYS" | grep -q "^$key$"; then
    echo "❌ Clé manquante EN: $key"
    ((missing++))
  fi
done

if [ $missing -eq 0 ]; then
  echo "✅ Toutes les clés FR ont équivalent EN"
else
  echo ""
  echo "⚠️  Total clés manquantes: $missing"
fi
```

---

### 6️⃣ Tests Unitaires LocaleProvider

**Objectif :** Valider comportement changement langue

**Commande :**
```bash
cd /home/guifo/Bureau/rabbit_farm_app
flutter test test/locale_provider_test.dart
```

**Résultat attendu :**
```
00:02 +2: All tests passed!
```

**Tests couverts :**
1. `setLocaleByName()` change locale de 'fr' à 'en' et vice-versa
2. `notifyListeners()` est appelé lors du changement

---

### 7️⃣ Test Manuel Application

**Objectif :** Vérifier expérience utilisateur réelle

**Procédure détaillée :** Voir `GUIDE_TEST_LANGUE.md`

**Commandes :**
```bash
cd /home/guifo/Bureau/rabbit_farm_app
flutter clean
flutter pub get
flutter run -d linux
```

**Dans l'app :**
1. Aller dans **Paramètres → Langue**
2. Sélectionner **English**
3. Observer console pour logs 🌍🔄💾🔔✅
4. Parcourir **TOUS les écrans** et noter textes restant en FR

---

## 📊 INTERPRÉTATION DES RÉSULTATS

### Scénario 1 : Audit Bash
```
🔴 TOP 10 FICHIERS AVEC PLUS DE TEXTES EN DUR
-------------------------------------------
85 occurrences - parametres_screen.dart
51 occurrences - preparation_nid_screen.dart
...
```

**Interprétation :**
- Ces fichiers sont **prioritaires** pour refactoring
- `parametres_screen.dart` (85 textes) = ~5% du total

**Action :** Planifier refactoring en commençant par ces fichiers

---

### Scénario 2 : Extraction Python
```
📊 RÉSUMÉ:
   Total textes détectés: 1820
   Par catégorie:
     - Text_widget : 1110 textes
```

**Interprétation :**
- **1110/1820 = 61%** sont des widgets `Text()`
- Ces conversions sont **simples** : `Text('hello')` → `Text(AppLocalizations.of(context).hello)`

**Action :** Automatiser partiellement avec script Find & Replace

---

### Scénario 3 : Rapport JSON
```json
{
  "text": "Ajouter un lapin",
  "file": "lib/screens/cheptel/add_lapin_screen.dart",
  "line": 219,
  "suggested_key": "ajouterLapin"
}
```

**Interprétation :**
- Clé suggérée : `ajouterLapin` (camelCase)
- Localisation : Ligne 219 du fichier
- Contexte disponible pour comprendre usage

**Action :** Créer clé ARB, remplacer dans code

---

## 🔧 WORKFLOWS RECOMMANDÉS

### Workflow 1 : Audit Hebdomadaire (Maintenance)
```bash
#!/bin/bash
# weekly_i18n_audit.sh

echo "📅 Audit i18n hebdomadaire - $(date)"
echo ""

# 1. Audit bash
./scripts/audit_i18n.sh > audit_$(date +%Y%m%d).txt

# 2. Compter clés ARB
FR_COUNT=$(grep -c '^  "[^@]' lib/l10n/app_fr.arb)
EN_COUNT=$(grep -c '^  "[^@]' lib/l10n/app_en.arb)

echo "📊 Clés ARB: FR=$FR_COUNT | EN=$EN_COUNT"

# 3. Tests unitaires
flutter test test/locale_provider_test.dart

echo ""
echo "✅ Audit terminé - Rapport: audit_$(date +%Y%m%d).txt"
```

---

### Workflow 2 : Ajout Nouvelle Clé (Développeur)
```bash
# 1. Identifier texte en dur
grep -rn "Text('$YOUR_TEXT')" lib/

# 2. Choisir nom de clé (convention: section_action_element)
KEY="cheptel_button_add"  # Exemple

# 3. Ajouter dans app_fr.arb
cat >> lib/l10n/app_fr.arb << EOF
  "$KEY": "$YOUR_TEXT",
  "@$KEY": {
    "description": "Description courte"
  },
EOF

# 4. Ajouter dans app_en.arb (traduction)
cat >> lib/l10n/app_en.arb << EOF
  "$KEY": "$ENGLISH_TEXT",
  "@$KEY": {
    "description": "Short description"
  },
EOF

# 5. Regénérer fichiers Flutter
flutter pub get

# 6. Remplacer dans code
# Text('$YOUR_TEXT') → Text(AppLocalizations.of(context).$KEY)

# 7. Test hot reload
# Vérifier affichage FR + EN
```

---

### Workflow 3 : Refactoring Section Complète
```bash
# Exemple: Section Cheptel

# 1. Extraire tous textes de la section
python3 scripts/extract_hardcoded_texts.py . > /dev/null
jq '.by_category | to_entries[] | .value.examples[] | select(.file | contains("cheptel"))' \
   i18n_extraction_report.json > cheptel_texts.json

# 2. Créer clés ARB pour cette section
# (Édition manuelle app_fr.arb + app_en.arb)

# 3. Refactorer fichier par fichier
# lib/screens/cheptel/cheptel_screen.dart
# lib/screens/cheptel/add_lapin_screen.dart
# ...

# 4. Tests après chaque fichier
flutter run -d linux
# Tester FR + EN sur écrans modifiés

# 5. Commit par fichier
git add lib/screens/cheptel/cheptel_screen.dart lib/l10n/*.arb
git commit -m "feat(i18n): Internationaliser cheptel_screen"

# 6. Tests complets section
flutter test
flutter analyze
```

---

## ❓ FAQ Technique

### Q1 : Comment ajouter une nouvelle langue ?
```bash
# 1. Créer fichier ARB
cp lib/l10n/app_fr.arb lib/l10n/app_es.arb

# 2. Modifier locale
sed -i 's/"@@locale": "fr"/"@@locale": "es"/' lib/l10n/app_es.arb

# 3. Traduire toutes les valeurs
# (Édition manuelle ou script de traduction)

# 4. Ajouter dans lib/l10n.yaml (si pas auto-détecté)
# arb-dir: lib/l10n
# template-arb-file: app_fr.arb
# output-localization-file: app_localizations.dart

# 5. Regénérer
flutter pub get

# 6. Tester
flutter run -d linux
# Paramètres → Langue → Español
```

---

### Q2 : Comment gérer les pluriels ?
```json
// app_fr.arb
{
  "lapinsCount": "{count, plural, =0{Aucun lapin} =1{1 lapin} other{{count} lapins}}",
  "@lapinsCount": {
    "description": "Nombre de lapins (pluriel)",
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}

// Usage dans code
Text(AppLocalizations.of(context).lapinsCount(5))
// Affiche: "5 lapins"
```

---

### Q3 : Comment gérer les paramètres dynamiques ?
```json
// app_fr.arb
{
  "bienvenue": "Bienvenue {userName}!",
  "@bienvenue": {
    "description": "Message de bienvenue personnalisé",
    "placeholders": {
      "userName": {
        "type": "String"
      }
    }
  }
}

// Usage dans code
Text(AppLocalizations.of(context).bienvenue('Alice'))
// Affiche: "Bienvenue Alice!"
```

---

### Q4 : Comment débugger clés manquantes ?
```bash
# Logs d'erreur typiques:
# "NoSuchMethodError: method not found: 'maClé'"

# 1. Vérifier clé existe dans ARB
grep "maClé" lib/l10n/app_fr.arb

# 2. Regénérer fichiers Flutter
flutter clean
flutter pub get

# 3. Vérifier import AppLocalizations
grep "import.*app_localizations" lib/screens/mon_screen.dart

# 4. Relancer app
flutter run -d linux
```

---

## 📚 RÉFÉRENCES

### Documentation Flutter i18n
- [Official i18n Guide](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB File Format](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [Intl Package](https://pub.dev/packages/intl)

### Outils Externes
- [Google Translate API](https://cloud.google.com/translate) - Traduction automatique
- [POEditor](https://poeditor.com/) - Plateforme gestion traductions
- [Crowdin](https://crowdin.com/) - Traduction collaborative

---

## 🎓 FORMATION ÉQUIPE

### Pour Développeurs
**Lecture requise :**
1. `PLAN_I18N_COMPLET.md` (stratégie complète)
2. Flutter i18n official docs

**Pratique :**
- Refactorer 1 écran simple en binôme
- Code review mutuelle des clés ARB

### Pour QA/Testeurs
**Lecture requise :**
1. `GUIDE_TEST_LANGUE.md` (procédure test)

**Pratique :**
- Test changement langue sur tous écrans
- Documenter textes restant en dur
- Signaler overflow textes anglais

### Pour Product Owner
**Lecture requise :**
1. `GUIDE_UTILISATEUR_I18N.md` (guide simple)
2. `RESUME_EXECUTIF_I18N.md` (décisionnel)

---

## 📅 MAINTENANCE CONTINUE

### Checklist Post-Refactoring

- [ ] Tous textes en dur convertis (rapport audit = 0)
- [ ] Tests unitaires LocaleProvider passent
- [ ] Tests manuels FR + EN sur tous écrans
- [ ] Documentation utilisateur à jour
- [ ] Script validation FR/EN dans CI/CD
- [ ] Glossaire métier traduit en EN
- [ ] Messages d'erreur tous traduits
- [ ] Tooltips et empty states traduits

### Checklist Ajout Nouvelle Langue

- [ ] Fichier `app_XX.arb` créé avec 500+ clés
- [ ] Traduction professionnelle validée
- [ ] Test manuel complet langue XX
- [ ] Documentation mise à jour (langues supportées)
- [ ] Store listings traduits (si publication)

---

**🎯 OBJECTIF :** Rendre ces outils **partie intégrante** du workflow développement quotidien

**📧 Support :** Lead Flutter Developer i18n  
**📅 Dernière mise à jour :** 5 janvier 2026, 02h00 WAT
