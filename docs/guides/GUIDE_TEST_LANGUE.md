# Guide de Test - Changement de Langue

## 🎯 Objectif
Vérifier que le changement de langue FR ↔ EN fonctionne correctement.

## ✅ Tests Automatiques Passés
```bash
flutter test test/locale_provider_test.dart
# Résultat: ✅ All tests passed!
# Le LocaleProvider fonctionne correctement en isolation
```

## 📋 Test Manuel

### Étapes à suivre:

1. **Lancer l'application**
   ```bash
   flutter run -d linux
   ```

2. **Naviguer vers Paramètres**
   - Cliquer sur l'icône Paramètres (⚙️) dans la barre de navigation

3. **Ouvrir le dialogue de langue**
   - Trouver la section "Langue"
   - Cliquer sur le bouton pour changer la langue

4. **Sélectionner English**
   - Cliquer sur "English" dans le dialogue
   - Le dialogue se ferme automatiquement

5. **Observer la console**
   ```
   Logs attendus dans la console:
   🌍 setLocaleByName appelé avec: English
   ✅ Locale trouvée: en
   🔄 Changement de fr vers en
   💾 Locale sauvegardée: en
   🔔 Notification des listeners...
   ✅ Changement de locale terminé
   ```

6. **Vérifier l'interface**
   - L'interface DOIT se mettre à jour immédiatement
   - Tous les textes doivent passer en anglais
   - Le dialogue doit afficher "Confirm" au lieu de "Confirmer"

7. **Tester le retour au français**
   - Répéter les étapes 3-6 en sélectionnant "Français"

## 🐛 Diagnostic si ça ne marche pas

### Scénario 1: Les logs apparaissent mais l'UI ne change pas
**Cause probable**: Le MaterialApp ne se reconstruit pas malgré le `ValueKey`

**Solution**:
```dart
// Vérifier que le Consumer2 entoure bien le MaterialApp dans main.dart
Consumer2<ThemeProvider, LocaleProvider>(
  builder: (context, themeProvider, localeProvider, child) {
    return MaterialApp(
      key: ValueKey(localeProvider.locale.languageCode),
      locale: localeProvider.locale,
      // ...
    );
  },
)
```

### Scénario 2: Aucun log n'apparaît
**Cause probable**: La méthode `setLocaleByName()` n'est pas appelée

**Vérification**:
```bash
# Chercher les appels dans le code
grep -r "setLocaleByName" lib/screens/parametres/
```

### Scénario 3: Les logs montrent "Locale identique"
**Cause probable**: La locale est déjà celle demandée mais l'UI affiche l'ancienne

**Solution**: Forcer le rechargement complet
```dart
// Dans setLocale(), toujours appeler notifyListeners() même si locale identique
if (_locale == newLocale) {
  logger.warning('Locale identique: ${newLocale.languageCode}');
  notifyListeners(); // ← Ajouter cette ligne
  return;
}
```

## 📊 État Actuel du Code

### Fichiers Modifiés ✅
- [x] `lib/providers/locale_provider.dart` - Logs debug ajoutés
- [x] `lib/l10n/app_en.arb` - Clés harmonisées (exportDonnees, importRestauration, confirmerSuppression)
- [x] `test/locale_provider_test.dart` - Tests unitaires créés

### Configuration Vérifiée ✅
- [x] `MaterialApp` a `key: ValueKey(localeProvider.locale.languageCode)`
- [x] `MaterialApp` a `locale: localeProvider.locale`
- [x] Dialog utilise `Consumer<LocaleProvider>`
- [x] `Consumer2<ThemeProvider, LocaleProvider>` entoure MaterialApp
- [x] ARB files ont 322 clés chacun (FR et EN)

### Compilation ✅
```bash
flutter analyze
# Résultat: No issues found! (8 infos inoffensifs)
```

## 🔧 Commandes Utiles

```bash
# Lancer avec logs visibles
flutter run -d linux

# Relancer après modifications
r  # Hot reload
R  # Hot restart

# Tester en isolation
flutter test test/locale_provider_test.dart

# Vérifier la génération l10n
flutter pub get
# Les fichiers générés sont dans .dart_tool/flutter_gen/gen_l10n/

# Nettoyer et régénérer complètement
flutter clean && flutter pub get
```

## 📝 Rapport de Bug (si nécessaire)

Si le problème persiste après ces tests, documenter :
1. ✅ Logs de la console lors du changement de langue
2. ✅ Capture d'écran du dialogue avant/après sélection
3. ✅ Version de Flutter : `flutter --version`
4. ✅ Comportement observé vs comportement attendu

---

**Date de création**: $(date)  
**Versions testées**: Flutter 3.x, Linux Desktop  
**Status**: Tests unitaires ✅ | Tests manuels ⏳
