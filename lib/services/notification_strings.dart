import 'package:shared_preferences/shared_preferences.dart';

/// Helper pour accéder aux chaînes de notification traduites sans contexte
/// Utilisé par NotificationService qui ne peut pas accéder à AppLocalizations
class NotificationStrings {
  static String _currentLocale = 'fr';

  /// Initialiser la locale depuis les préférences
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLocale = prefs.getString('app_locale') ?? 'fr';
  }

  /// Mettre à jour la locale
  static Future<void> setLocale(String locale) async {
    _currentLocale = locale;
  }

  // ===== TITRES DE NOTIFICATIONS =====

  static String get notifMiseBasTitre => _currentLocale == 'en'
      ? '🐰 Birth due in 3 days'
      : '🐰 Mise bas prévue dans 3 jours';

  static String get notifSoinTitre =>
      _currentLocale == 'en' ? '💉 Care reminder' : '💉 Rappel de soin';

  static String get notifPalpationTitre => _currentLocale == 'en'
      ? '🔍 Palpation reminder'
      : '🔍 Rappel de palpation';

  static String get notifNidTitre =>
      _currentLocale == 'en' ? '🏠 Nest preparation' : '🏠 Préparation du nid';

  static String get notifPeseeTitre =>
      _currentLocale == 'en' ? '⚖️ Weighing reminder' : '⚖️ Rappel de pesée';

  // ===== CORPS DE NOTIFICATIONS =====

  static String notifMiseBasCorps(String nomFemelle, String date) {
    return _currentLocale == 'en'
        ? '🐰 It\'s D-Day for $nomFemelle! Check the nest.'
        : '🐰 C\'est le jour J pour $nomFemelle ! Surveillez le nid.';
  }

  static String notifSoinCorps(String nomLapin, String typeSoin, String date) {
    return _currentLocale == 'en'
        ? '❤️ $nomLapin needs a little care: $typeSoin'
        : '❤️ $nomLapin a besoin d\'un petit soin : $typeSoin';
  }

  static String notifPalpationCorps(String nomFemelle, String date) {
    return _currentLocale == 'en'
        ? '🔍 Time to check if $nomFemelle is expecting!'
        : '🔍 Il est temps de vérifier si $nomFemelle attend des petits !';
  }

  static String notifNidCorps(String nomFemelle, String date) {
    return _currentLocale == 'en'
        ? '🏠 Birth is coming soon. Is $nomFemelle\'s nest ready?'
        : '🏠 La mise bas approche. Le nid de $nomFemelle est-il prêt ?';
  }

  static String notifPeseeCorps(String nomLapin, String date) {
    return _currentLocale == 'en'
        ? '⚖️ Weekly weighing time for $nomLapin.'
        : '⚖️ C\'est l\'heure de la pesée hebdo pour $nomLapin.';
  }

  // ===== ACTIONS DE NOTIFICATIONS =====

  static String get notifActionMiseBasOK =>
      _currentLocale == 'en' ? '✅ Birth OK' : '✅ Mise bas OK';

  static String get notifActionEchec =>
      _currentLocale == 'en' ? '❌ Failed' : '❌ Échec';

  static String get notifActionReporter24h => '⏰ +24h';

  static String get notifActionGestante =>
      _currentLocale == 'en' ? '✅ Pregnant' : '✅ Gestante';

  static String get notifActionNonGestante =>
      _currentLocale == 'en' ? '❌ No' : '❌ Non';

  static String get notifActionRefaire =>
      _currentLocale == 'en' ? '❓ Redo' : '❓ Refaire';

  static String get notifActionFait =>
      _currentLocale == 'en' ? '✅ Done' : '✅ Fait';

  static String get notifActionSevre =>
      _currentLocale == 'en' ? '✅ Weaned' : '✅ Sevré';

  static String get notifActionReporter2j =>
      _currentLocale == 'en' ? '⏰ +2d' : '⏰ +2j';

  static String get notifActionOK => '✅ OK';

  static String get notifActionProbleme =>
      _currentLocale == 'en' ? '⚠️ Prob' : '⚠️ Pb';
}
