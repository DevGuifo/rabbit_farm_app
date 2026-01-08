import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import '../services/notification_strings.dart';

/// Provider pour gérer la langue de l'application
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale _locale = const Locale('fr', 'FR');

  Locale get locale => _locale;

  /// Langues supportées
  static const Map<String, Locale> supportedLocales = {
    'Français': Locale('fr', 'FR'),
    'English': Locale('en', 'US'),
  };

  /// Nom de la langue actuelle
  String get languageName {
    for (final entry in supportedLocales.entries) {
      if (entry.value.languageCode == _locale.languageCode) {
        return entry.key;
      }
    }
    return 'Français';
  }

  /// Charger la langue sauvegardée
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey) ?? 'fr';

    logger.info('📖 Chargement locale: $languageCode');

    if (languageCode == 'en') {
      _locale = const Locale('en', 'US');
    } else {
      _locale = const Locale('fr', 'FR');
    }

    // Synchroniser avec NotificationStrings
    await NotificationStrings.setLocale(languageCode);

    logger.info('✅ Locale définie: ${_locale.languageCode}');
    notifyListeners();
  }

  /// Changer la langue
  Future<void> setLocale(Locale newLocale) async {
    logger.info(
      '🔄 Changement de ${_locale.languageCode} vers ${newLocale.languageCode}',
    );

    if (_locale == newLocale) {
      logger.warning('⚠️ Locale identique, pas de changement');
      return;
    }

    _locale = newLocale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, newLocale.languageCode);

    // Synchroniser avec NotificationStrings
    await NotificationStrings.setLocale(newLocale.languageCode);

    logger.info('💾 Locale sauvegardée: ${newLocale.languageCode}');
    logger.info('🔔 Notification des listeners...');

    notifyListeners();

    logger.info('✅ Changement de locale terminé');
  }

  /// Changer la langue par nom
  Future<void> setLocaleByName(String languageName) async {
    logger.info('🌍 setLocaleByName appelé avec: $languageName');
    final locale = supportedLocales[languageName];
    if (locale != null) {
      logger.info('✅ Locale trouvée: ${locale.languageCode}');
      await setLocale(locale);
    } else {
      logger.error('❌ Langue non supportée: $languageName');
    }
  }

  /// Basculer entre les langues
  Future<void> toggleLocale() async {
    if (_locale.languageCode == 'fr') {
      await setLocale(const Locale('en', 'US'));
    } else {
      await setLocale(const Locale('fr', 'FR'));
    }
  }
}
