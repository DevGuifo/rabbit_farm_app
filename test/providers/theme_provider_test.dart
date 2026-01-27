import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rabbit_farm_app/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeProvider Tests', () {
    setUp(() async {
      // Réinitialiser SharedPreferences avant chaque test
      SharedPreferences.setMockInitialValues({});
    });

    test('Initialisation par défaut avec ThemeMode.system', () {
      final provider = ThemeProvider();

      expect(provider.themeMode, ThemeMode.system);
    });

    test('setThemeMode() change le thème correctement', () async {
      final provider = ThemeProvider();

      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, ThemeMode.dark);

      await provider.setThemeMode(ThemeMode.light);
      expect(provider.themeMode, ThemeMode.light);

      await provider.setThemeMode(ThemeMode.system);
      expect(provider.themeMode, ThemeMode.system);
    });

    test('setThemeMode() ne fait rien si le même mode est défini', () async {
      final provider = ThemeProvider();
      await provider.setThemeMode(ThemeMode.dark);

      // Appeler à nouveau avec le même thème
      final initialMode = provider.themeMode;
      await provider.setThemeMode(ThemeMode.dark);

      expect(provider.themeMode, initialMode);
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('toggleTheme() bascule de light à dark', () async {
      final provider = ThemeProvider();
      await provider.setThemeMode(ThemeMode.light);

      await provider.toggleTheme();

      expect(provider.themeMode, ThemeMode.dark);
    });

    test('toggleTheme() bascule de dark à light', () async {
      final provider = ThemeProvider();
      await provider.setThemeMode(ThemeMode.dark);

      await provider.toggleTheme();

      expect(provider.themeMode, ThemeMode.light);
    });

    test('toggleTheme() bascule de system à light', () async {
      final provider = ThemeProvider();
      // Par défaut c'est system

      await provider.toggleTheme();

      expect(provider.themeMode, ThemeMode.light);
    });

    group('themeModeName getter', () {
      test('retourne "Clair" pour ThemeMode.light', () async {
        final provider = ThemeProvider();
        await provider.setThemeMode(ThemeMode.light);

        expect(provider.themeModeName, 'Clair');
      });

      test('retourne "Sombre" pour ThemeMode.dark', () async {
        final provider = ThemeProvider();
        await provider.setThemeMode(ThemeMode.dark);

        expect(provider.themeModeName, 'Sombre');
      });

      test('retourne "Système" pour ThemeMode.system', () {
        final provider = ThemeProvider();
        // Par défaut

        expect(provider.themeModeName, 'Système');
      });
    });

    group('themeModeIcon getter', () {
      test('retourne Icons.light_mode pour ThemeMode.light', () async {
        final provider = ThemeProvider();
        await provider.setThemeMode(ThemeMode.light);

        expect(provider.themeModeIcon, Icons.light_mode);
      });

      test('retourne Icons.dark_mode pour ThemeMode.dark', () async {
        final provider = ThemeProvider();
        await provider.setThemeMode(ThemeMode.dark);

        expect(provider.themeModeIcon, Icons.dark_mode);
      });

      test('retourne Icons.brightness_auto pour ThemeMode.system', () {
        final provider = ThemeProvider();

        expect(provider.themeModeIcon, Icons.brightness_auto);
      });
    });

    test('loadTheme() charge le thème depuis SharedPreferences', () async {
      // Pré-configurer SharedPreferences avec un thème dark (index 1)
      SharedPreferences.setMockInitialValues({'theme_mode': 1});

      final provider = ThemeProvider();
      await provider.loadTheme();

      // ThemeMode.values[1] = ThemeMode.dark
      expect(provider.themeMode, ThemeMode.values[1]);
    });

    test('loadTheme() utilise system par défaut si aucune préférence', () async {
      SharedPreferences.setMockInitialValues({});

      final provider = ThemeProvider();
      await provider.loadTheme();

      expect(provider.themeMode, ThemeMode.system);
    });

    test('setThemeMode() persiste le thème dans SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      final provider = ThemeProvider();
      await provider.setThemeMode(ThemeMode.light);

      // Vérifier que le thème a été sauvegardé
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), ThemeMode.light.index);
    });

    test('notifyListeners est appelé après setThemeMode', () async {
      final provider = ThemeProvider();
      var notified = false;
      provider.addListener(() => notified = true);

      await provider.setThemeMode(ThemeMode.dark);

      expect(notified, true);
    });

    test('notifyListeners est appelé après loadTheme', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 2}); // system

      final provider = ThemeProvider();
      var notified = false;
      provider.addListener(() => notified = true);

      await provider.loadTheme();

      expect(notified, true);
    });
  });

  group('ThemeProvider - Scénarios réels', () {
    test('Cycle complet: load, change, save, reload', () async {
      // Simuler un utilisateur qui ouvre l'app, change le thème, et réouvre l'app
      SharedPreferences.setMockInitialValues({});

      // Premier lancement
      final provider1 = ThemeProvider();
      await provider1.loadTheme();
      expect(provider1.themeMode, ThemeMode.system);

      // L'utilisateur change vers dark
      await provider1.setThemeMode(ThemeMode.dark);

      // Simuler une fermeture/réouverture de l'app
      final prefs = await SharedPreferences.getInstance();
      final savedValue = prefs.getInt('theme_mode');
      expect(savedValue, ThemeMode.dark.index);

      // Deuxième lancement avec les valeurs sauvegardées
      SharedPreferences.setMockInitialValues({'theme_mode': savedValue!});
      final provider2 = ThemeProvider();
      await provider2.loadTheme();

      expect(provider2.themeMode, ThemeMode.dark);
    });

    test('Multiples bascules consécutives', () async {
      final provider = ThemeProvider();
      await provider.setThemeMode(ThemeMode.light);

      // Toggle plusieurs fois
      await provider.toggleTheme(); // -> dark
      expect(provider.themeMode, ThemeMode.dark);

      await provider.toggleTheme(); // -> light
      expect(provider.themeMode, ThemeMode.light);

      await provider.toggleTheme(); // -> dark
      expect(provider.themeMode, ThemeMode.dark);
    });
  });
}
