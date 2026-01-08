# 📱 Guide de Gestion des Versions - Flutter

## 🎯 Vue d'ensemble

Dans Flutter, la version de l'application est gérée de manière centralisée dans le fichier `pubspec.yaml`. Cette version est ensuite utilisée automatiquement par Android et iOS.

---

## 📋 Format de Version

Le format de version dans Flutter suit le pattern : **`X.Y.Z+B`**

### Structure :
- **X** = Version majeure (Major) - Changements majeurs, incompatibilités
- **Y** = Version mineure (Minor) - Nouvelles fonctionnalités, compatibilité arrière
- **Z** = Version de patch (Patch) - Corrections de bugs, petites améliorations
- **B** = Numéro de build (Build Number) - Incrémenté à chaque build

### Exemple actuel dans votre projet :
```yaml
version: 1.1.0+2
```
- **Version** : `1.1.0` (version majeure 1, mineure 1, patch 0)
- **Build Number** : `2` (2ème build de cette version)

---

## 🔧 Où Modifier la Version

### 1. Fichier Principal : `pubspec.yaml`

```yaml
version: 1.1.0+2
```

**C'est le seul endroit à modifier !** Flutter propage automatiquement cette version vers :
- Android (`versionName` et `versionCode`)
- iOS (`CFBundleShortVersionString` et `CFBundleVersion`)

---

## 📱 Comment ça fonctionne sur chaque plateforme

### Android
- **versionName** = `1.1.0` (affiché aux utilisateurs)
- **versionCode** = `2` (numéro interne, doit toujours augmenter)

Le fichier `android/app/build.gradle.kts` utilise automatiquement :
```kotlin
versionCode = flutter.versionCode  // = 2
versionName = flutter.versionName  // = "1.1.0"
```

### iOS
- **CFBundleShortVersionString** = `1.1.0` (version affichée)
- **CFBundleVersion** = `2` (build number)

Le fichier `ios/Runner/Info.plist` utilise :
```xml
<key>CFBundleShortVersionString</key>
<string>$(FLUTTER_BUILD_NAME)</string>  <!-- = 1.1.0 -->
<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>  <!-- = 2 -->
```

---

## 🚀 Stratégie de Versioning Recommandée

### Version Sémantique (Semantic Versioning)

#### 🔴 Version Majeure (X.0.0)
**Quand incrémenter :**
- Changements majeurs qui cassent la compatibilité
- Refonte complète de l'interface
- Changements d'API majeurs
- Migration de base de données incompatible

**Exemple :** `1.0.0` → `2.0.0`

#### 🟡 Version Mineure (0.Y.0)
**Quand incrémenter :**
- Nouvelles fonctionnalités importantes
- Nouveaux écrans ou modules
- Améliorations significatives
- Compatibilité arrière maintenue

**Exemple :** `1.1.0` → `1.2.0`

#### 🟢 Version de Patch (0.0.Z)
**Quand incrémenter :**
- Corrections de bugs
- Petites améliorations UI
- Optimisations de performance
- Corrections de sécurité

**Exemple :** `1.1.0` → `1.1.1`

#### 🔵 Build Number (+B)
**Quand incrémenter :**
- **À chaque build** (même si la version ne change pas)
- Obligatoire pour publier sur Google Play / App Store
- Doit toujours augmenter (ne peut pas diminuer)

**Exemple :** `1.1.0+2` → `1.1.0+3` → `1.1.0+4`

---

## 📝 Exemples de Workflow

### Scénario 1 : Correction de bug
```yaml
# Avant
version: 1.1.0+5

# Après correction d'un bug
version: 1.1.1+6
```

### Scénario 2 : Nouvelle fonctionnalité
```yaml
# Avant
version: 1.1.0+10

# Après ajout du gestionnaire de tâches
version: 1.2.0+11
```

### Scénario 3 : Build de test (version inchangée)
```yaml
# Avant
version: 1.1.0+5

# Nouveau build pour tester (même version)
version: 1.1.0+6  # Seul le build number change
```

### Scénario 4 : Refonte majeure
```yaml
# Avant
version: 1.5.2+25

# Après refonte complète
version: 2.0.0+26
```

---

## 🛠️ Commandes Utiles

### Voir la version actuelle
```bash
grep "version:" pubspec.yaml
```

### Build avec version spécifique
```bash
# Build avec version personnalisée
flutter build apk --build-name=1.2.0 --build-number=15

# Build release
flutter build apk --release
flutter build appbundle --release  # Pour Google Play
flutter build ios --release        # Pour App Store
```

### Vérifier la version dans le code
```dart
import 'package:package_info_plus/package_info_plus.dart';

final packageInfo = await PackageInfo.fromPlatform();
print('Version: ${packageInfo.version}');
print('Build: ${packageInfo.buildNumber}');
```

---

## 📊 Tableau de Suivi des Versions

| Version | Build | Date | Changements |
|---------|-------|------|-------------|
| 1.1.0 | 2 | 2025-01-XX | Version actuelle |
| 1.0.0 | 1 | 2025-01-XX | Version initiale |

---

## ⚠️ Règles Importantes

### ✅ À FAIRE
- ✅ Toujours incrémenter le build number à chaque build
- ✅ Suivre le semantic versioning
- ✅ Documenter les changements dans CHANGELOG.md
- ✅ Tester avant de publier une nouvelle version

### ❌ À ÉVITER
- ❌ Ne jamais diminuer le build number
- ❌ Ne pas sauter de numéros de build
- ❌ Ne pas modifier manuellement les fichiers Android/iOS (utiliser pubspec.yaml)
- ❌ Ne pas publier avec le même build number qu'une version précédente

---

## 🔄 Processus de Mise à Jour

### Pour une nouvelle version :

1. **Modifier `pubspec.yaml`**
   ```yaml
   version: 1.2.0+15  # Nouvelle version + nouveau build
   ```

2. **Mettre à jour le CHANGELOG.md**
   ```markdown
   ## [1.2.0] - 2025-01-XX
   ### Added
   - Nouveau gestionnaire de tâches
   - ...
   ```

3. **Tester l'application**
   ```bash
   flutter run --release
   ```

4. **Build pour production**
   ```bash
   flutter build apk --release
   # ou
   flutter build appbundle --release
   ```

5. **Publier sur les stores**
   - Google Play Console
   - App Store Connect

---

## 📦 Package Recommandé (Optionnel)

Pour afficher la version dans l'application :

```yaml
dependencies:
  package_info_plus: ^8.0.0
```

Usage :
```dart
import 'package:package_info_plus/package_info_plus.dart';

final info = await PackageInfo.fromPlatform();
print('App: ${info.appName}');
print('Version: ${info.version}');
print('Build: ${info.buildNumber}');
```

---

## 🎯 Résumé

**Règle d'or :** 
- Modifiez uniquement `pubspec.yaml`
- Format : `X.Y.Z+B`
- Incrémentez le build number à chaque build
- Suivez le semantic versioning pour X.Y.Z

**Fichier à modifier :** `pubspec.yaml` ligne 19

**Version actuelle :** `1.1.0+2`

