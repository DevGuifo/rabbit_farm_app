# 🚀 GitHub Actions - Configuration Future (Optionnel)

**Date :** 8 janvier 2026  
**Status :** 📝 **PROPOSITION** (non implémenté)  
**Priorité :** Basse (amélioration future)

---

## 🎯 OBJECTIF

Automatiser les vérifications de build Flutter à chaque push GitHub pour détecter les erreurs plus tôt.

---

## ⚠️ PRÉ-REQUIS

**Avant d'activer GitHub Actions, vous devez :**

1. ✅ Être à l'aise avec les 3 commandes Git de base
2. ✅ Avoir commit/push au moins 10 fois sans aide
3. ✅ Comprendre les messages Git (status, log, push)

**Estimation maturité Git requise :** 1 mois d'utilisation quotidienne

---

## 📋 FONCTIONNALITÉS PROPOSÉES

### Workflow Basique (flutter-ci.yml)

**Déclencheurs :**
- ✅ À chaque `git push` sur branche `develop`
- ✅ À chaque Pull Request vers `develop` ou `main`

**Actions Automatiques :**
1. ✅ Installer Flutter SDK (version 3.9.2)
2. ✅ Exécuter `flutter pub get` (dépendances)
3. ✅ Exécuter `flutter analyze` (linting)
4. ✅ Exécuter `flutter test` (tests unitaires - si implémentés)
5. ✅ Construire APK release (`flutter build apk --release`)
6. ✅ Notifier par email si échec

**Durée estimée :** 5-10 minutes par build automatique

---

## 📄 FICHIER DE CONFIGURATION PROPOSÉ

**Emplacement :** `.github/workflows/flutter-ci.yml`

```yaml
name: Flutter CI

on:
  push:
    branches: [ develop, main ]
  pull_request:
    branches: [ develop, main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: 📥 Checkout code
      uses: actions/checkout@v4

    - name: ☕ Setup Java 17
      uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '17'

    - name: 🐦 Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.9.2'
        channel: 'stable'

    - name: 📦 Install dependencies
      run: flutter pub get

    - name: 🔍 Analyze code
      run: flutter analyze

    - name: 🧪 Run tests
      run: flutter test
      continue-on-error: true  # Ne pas bloquer si tests manquants

    - name: 🏗️ Build APK
      run: flutter build apk --release

    - name: 📊 Upload APK artifact
      uses: actions/upload-artifact@v3
      with:
        name: app-release-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🎓 COMMENT ACTIVER (Quand Prêt)

### Étape 1 : Créer le Fichier

```bash
cd /home/guifo/Bureau/rabbit_farm_app
mkdir -p .github/workflows
nano .github/workflows/flutter-ci.yml
# Coller le contenu YAML ci-dessus
# Ctrl+O pour sauvegarder, Ctrl+X pour quitter
```

### Étape 2 : Commit & Push

```bash
git add .github/workflows/flutter-ci.yml
git commit -m "ci: Ajout workflow GitHub Actions pour build automatique Flutter"
git push
```

### Étape 3 : Vérifier sur GitHub

1. Aller sur https://github.com/DevGuifo/rabbit_farm_app
2. Onglet **"Actions"** (barre du haut)
3. Voir le workflow "Flutter CI" en cours d'exécution

**Premier build :** ~8-10 minutes (installation Flutter)  
**Builds suivants :** ~5 minutes (cache Flutter)

---

## 💰 COÛT

**GitHub Actions Gratuit :**
- ✅ **2000 minutes/mois** pour dépôts publics
- ✅ **Illimité** pour dépôts publics (depuis 2024)

**Estimation utilisation BunnyManager :**
- 1 push/jour × 5 min = **5 min/jour**
- 20 jours/mois = **100 min/mois**

**Verdict :** ✅ Largement dans les limites gratuites

---

## ✅ AVANTAGES

1. **Détection précoce d'erreurs** : Build échoue sur GitHub avant de découvrir sur téléphone
2. **Historique builds** : Voir tous les builds passés, succès/échecs
3. **APK automatique** : Télécharger APK depuis GitHub Actions (pas besoin Flutter local)
4. **Badge status** : Afficher badge "Build Passing" sur README.md
5. **Notifications email** : Recevoir email si build échoue

---

## ⚠️ INCONVÉNIENTS

1. **Complexité accrue** : Un système de plus à comprendre
2. **Temps attente** : 5-10 min pour voir résultat (vs instantané local)
3. **Debugging distant** : Plus difficile de corriger erreurs sur serveur GitHub
4. **Dépendance GitHub** : Si GitHub Actions en panne, build bloqué

---

## 🎯 QUAND ACTIVER ?

### ✅ Activer Si :

- [ ] Vous êtes à l'aise avec Git (1+ mois d'utilisation)
- [ ] Vous avez une équipe (plusieurs personnes pushent)
- [ ] Vous voulez automatiser les vérifications de qualité
- [ ] Vous avez des tests unitaires (`flutter test` fonctionne)

### ❌ Ne PAS Activer Si :

- [ ] Vous débutez avec Git (<1 mois)
- [ ] Vous travaillez seul et rarement
- [ ] Vous préférez tester manuellement localement
- [ ] Vous n'avez pas encore de tests unitaires

---

## 🆘 SUPPORT

### Si Vous Activez et Ça Échoue

1. **Aller sur GitHub** → Onglet "Actions"
2. **Cliquer sur le workflow échoué** (croix rouge ❌)
3. **Lire les logs** (texte en rouge)
4. **Copier/coller l'erreur** au développeur

### Désactiver Temporairement

```bash
# Renommer pour désactiver (Git ne verra plus le fichier)
cd /home/guifo/Bureau/rabbit_farm_app
mv .github/workflows/flutter-ci.yml .github/workflows/flutter-ci.yml.disabled
git add .github/workflows/
git commit -m "ci: Désactivation temporaire GitHub Actions"
git push
```

---

## 🔮 ÉVOLUTIONS FUTURES POSSIBLES

### Phase 2 : Tests Automatiques

```yaml
- name: 🧪 Run widget tests
  run: flutter test --coverage

- name: 📊 Upload coverage to Codecov
  uses: codecov/codecov-action@v3
```

### Phase 3 : Déploiement Automatique

```yaml
- name: 🚀 Deploy to Google Play (Alpha)
  uses: r0adkll/upload-google-play@v1
  with:
    serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
    packageName: com.example.rabbit_farm_app
    releaseFiles: build/app/outputs/bundle/release/app-release.aab
    track: alpha
```

### Phase 4 : Notifications Discord/Slack

```yaml
- name: 📢 Notify Discord on failure
  if: failure()
  uses: sarisia/actions-status-discord@v1
  with:
    webhook: ${{ secrets.DISCORD_WEBHOOK }}
    status: ${{ job.status }}
```

---

## 📊 EXEMPLE RÉSULTAT ATTENDU

### Build Réussi ✅

```
✅ Flutter CI #42
Branch: develop
Commit: 1d1864d
Duration: 5m 23s

✅ Checkout code
✅ Setup Flutter
✅ Install dependencies
✅ Analyze code (80 warnings, 0 errors)
✅ Run tests (12 passed)
✅ Build APK (79.7 MB)
✅ Upload artifact
```

### Build Échoué ❌

```
❌ Flutter CI #43
Branch: develop
Commit: abc1234
Duration: 2m 45s

✅ Checkout code
✅ Setup Flutter
✅ Install dependencies
❌ Analyze code
   Error: lib/main.dart:25:10: Undefined name 'nonExistentFunction'
```

**Action :** Corriger l'erreur localement, commit, push → Re-déclenche build

---

## 📚 RESSOURCES COMPLÉMENTAIRES

- **GitHub Actions Documentation** : https://docs.github.com/en/actions
- **Flutter CI Best Practices** : https://docs.flutter.dev/deployment/cd
- **Exemples Workflows Flutter** : https://github.com/subosito/flutter-action

---

## ✅ DÉCISION RECOMMANDÉE

**Pour Propriétaire Non-Développeur BunnyManager :**

🔴 **NE PAS ACTIVER MAINTENANT**

**Raisons :**
1. Priorité sur maîtrise Git de base (3 commandes)
2. Projet solo (pas d'équipe nécessitant CI/CD)
3. Build local fonctionne bien (`flutter build apk --release`)
4. Ajout complexité pour gain marginal actuel

**Re-évaluer dans 3-6 mois** si :
- Équipe s'agrandit (2+ développeurs)
- Tests unitaires implémentés
- Besoin déploiements fréquents

---

**Proposition établie par :** Lead Flutter Developer  
**Date :** 8 janvier 2026  
**Révision recommandée :** Avril 2026

---

*Ce document reste dans le projet comme référence future. Aucune action requise actuellement.*
