# Instructions pour changer l'icône de l'application

## Étape 1 : Préparer l'image

L'image du lapin vert que vous avez fournie doit être :
1. Sauvegardée dans `assets/logo/bunny_icon.png`
2. Format PNG avec fond transparent (ou fond blanc)
3. Taille recommandée : 1024x1024 pixels minimum

## Étape 2 : Installer flutter_launcher_icons

Ajoutez cette dépendance dev dans `pubspec.yaml` :

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

Puis ajoutez cette configuration à la fin de `pubspec.yaml` :

```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/logo/bunny_icon.png"
  adaptive_icon_background: "#4CAF50"
  adaptive_icon_foreground: "assets/logo/bunny_icon.png"
```

## Étape 3 : Générer les icônes

Exécutez ces commandes :

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

## Alternative : Génération manuelle

Si vous préférez générer manuellement les icônes Android :

1. Allez sur https://icon.kitchen/
2. Uploadez votre image du lapin
3. Configurez :
   - Shape : Circle ou Square
   - Background : #4CAF50 (vert)
   - Foreground : Votre image
4. Téléchargez le pack Android
5. Remplacez les fichiers dans :
   - `android/app/src/main/res/mipmap-hdpi/`
   - `android/app/src/main/res/mipmap-mdpi/`
   - `android/app/src/main/res/mipmap-xhdpi/`
   - `android/app/src/main/res/mipmap-xxhdpi/`
   - `android/app/src/main/res/mipmap-xxxhdpi/`

## Fichiers à sauvegarder

Sauvegardez l'image fournie comme :
- `assets/logo/bunny_icon.png` (icône principale)
- Remplace aussi `assets/images/logo.png` pour le splash screen

## Après le changement

Rebuild l'application :
```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

**Note** : L'icône du lapin vert sera utilisée pour :
- Icône de l'application Android
- Logo dans le splash screen
- Représentation de l'app sur l'appareil
