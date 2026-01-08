# Fix : Changement de langue - BunnyManager

> Date : 4 janvier 2026  
> Problème : L'application ne changeait pas toujours de langue

---

## 🐛 Problème identifié

L'utilisateur signalait que le changement de langue FR ↔ EN ne fonctionnait pas systématiquement dans l'application.

**Causes :**
1. MaterialApp n'avait pas de clé unique pour forcer le rebuild complet
2. Le dialog de sélection de langue utilisait `Provider.of<LocaleProvider>(context, listen: false)` qui ne réagissait pas aux changements

---

## ✅ Solutions implémentées

### 1. Ajout d'une clé unique à MaterialApp

**Fichier :** `lib/main.dart`

```dart
// AVANT
return MaterialApp(
  title: 'BunnyManager',
  locale: localeProvider.locale,
  // ...
);

// APRÈS
return MaterialApp(
  key: ValueKey(localeProvider.locale.languageCode), // ← Force rebuild
  title: 'BunnyManager',
  locale: localeProvider.locale,
  // ...
);
```

**Pourquoi ?** La clé `ValueKey` basée sur le code de langue force Flutter à reconstruire complètement le MaterialApp quand la locale change, garantissant que tous les widgets descendants utilisent la nouvelle langue.

---

### 2. Utilisation de Consumer dans le dialog de langue

**Fichier :** `lib/screens/parametres/parametres_screen.dart`

```dart
// AVANT
void _handleLanguage() {
  final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
  
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      content: StatefulBuilder(
        builder: (context, setStateDialog) {
          return Column(
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  localeProvider.setLocaleByName('English'); // Pas de feedback visuel
                  Navigator.pop(dialogContext);
                },
              ),
              // ...
            ],
          );
        },
      ),
    ),
  );
}

// APRÈS
void _handleLanguage() {
  showDialog(
    context: context,
    builder: (dialogContext) => Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return AlertDialog(
          content: Column(
            children: [
              ListTile(
                title: const Text('English'),
                leading: Icon(
                  localeProvider.locale.languageCode == 'en'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                onTap: () async {
                  await localeProvider.setLocaleByName('English');
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
              ),
              // ...
            ],
          ),
        );
      },
    ),
  );
}
```

**Pourquoi ?**
- `Consumer<LocaleProvider>` écoute les changements du provider
- Les boutons radio se mettent à jour visuellement quand la langue change
- `await` assure que le changement est sauvegardé avant de fermer le dialog
- `if (dialogContext.mounted)` évite les erreurs si le dialog est déjà fermé

---

## 🧪 Test de validation

### Scénario de test

1. Lancer l'application : `flutter run`
2. Naviguer vers **Paramètres** (icône ⚙️ en bas)
3. Section **GÉNÉRAL** → Taper sur **Langue**
4. Sélectionner **English**
   - ✅ Le bouton radio doit se cocher instantanément
   - ✅ Le dialog se ferme
   - ✅ L'interface passe en anglais immédiatement
5. Retourner dans **Settings** → **Language**
6. Sélectionner **Français**
   - ✅ Le bouton radio doit se cocher instantanément
   - ✅ L'interface repasse en français immédiatement

### Résultats attendus

| Action | Résultat |
|--------|----------|
| Clic sur langue | Dialog s'ouvre avec la langue actuelle cochée |
| Sélection nouvelle langue | Bouton radio se coche, dialog se ferme |
| Interface | Tous les textes migrés changent instantanément |
| Navigation | Titres d'écrans et boutons en nouvelle langue |
| Persistance | La langue est conservée après redémarrage |

---

## 📋 Fichiers modifiés

| Fichier | Modification |
|---------|--------------|
| `lib/main.dart` | Ajout de `key: ValueKey(localeProvider.locale.languageCode)` |
| `lib/screens/parametres/parametres_screen.dart` | Remplacement de StatefulBuilder par Consumer<LocaleProvider> |

---

## 🔧 Architecture finale

```
main()
  └─ LocaleProvider (initialisé avec loadLocale())
       ↓
  MultiProvider
       ↓
  Consumer2<ThemeProvider, LocaleProvider>
       ↓
  MaterialApp (key: ValueKey(locale.languageCode))
       ↓ locale: localeProvider.locale
       ↓
  Tous les écrans → AppLocalizations.of(context).cleTraduction
```

### Flux de changement de langue

```
User tap "English"
       ↓
localeProvider.setLocaleByName('English')
       ↓
_locale = Locale('en', 'US')
prefs.setString('app_locale', 'en')
notifyListeners() ← Déclenche le rebuild
       ↓
Consumer2 détecte le changement
       ↓
MaterialApp reconstruit avec nouvelle key
       ↓
AppLocalizations.delegate charge app_en.arb
       ↓
Tous les widgets utilisant AppLocalizations.of(context) se mettent à jour
```

---

## 💾 État des traductions

| Fichier | Clés | État |
|---------|------|------|
| `lib/l10n/app_fr.arb` | 300+ | ✅ Complet |
| `lib/l10n/app_en.arb` | 300+ | ✅ Complet |

**Textes migrés :** ~110 fichiers utilisent AppLocalizations  
**Textes restants :** ~191 textes hardcodés (migration progressive en cours)

---

## 🚀 Prochaines étapes

### Pour améliorer le changement de langue

1. **Notification visuelle :**
   ```dart
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text('Langue changée en $languageName')),
   );
   ```

2. **Animation de transition :**
   ```dart
   return AnimatedSwitcher(
     duration: Duration(milliseconds: 300),
     child: MaterialApp(
       key: ValueKey(localeProvider.locale.languageCode),
       // ...
     ),
   );
   ```

3. **Ajouter plus de langues :**
   - Créer `app_sw.arb` (Swahili)
   - Créer `app_pt.arb` (Portugais)
   - Mettre à jour `LocaleProvider.supportedLocales`

---

## 📞 Référence

- **Documentation i18n :** `/docs/GUIDE_INTERNATIONALISATION.md`
- **Provider pattern :** `lib/providers/locale_provider.dart`
- **Fichiers ARB :** `lib/l10n/app_*.arb`
- **Configuration :** `l10n.yaml`

---

*Correction validée : 4 janvier 2026*  
*Compilé sans erreurs : 0 error, 8 infos mineures*
