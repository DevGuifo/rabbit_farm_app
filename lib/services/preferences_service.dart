import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../constants/preferences_keys.dart';
import '../utils/logger.dart';

/// Service singleton pour gérer les préférences utilisateur
/// 
/// Gère les préférences collectées durant l'onboarding V2 :
/// - Monnaie et unité de poids
/// - Préférences de notifications
/// - Mode de gestion (lots/individuel)
class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  /// Initialiser le service (à appeler dans main.dart)
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      logger.info('✅ PreferencesService initialisé');
    } catch (e) {
      logger.error('❌ Erreur initialisation PreferencesService: $e');
    }
  }

  /// Obtenir l'instance SharedPreferences
  Future<SharedPreferences> get prefs async {
    if (_prefs == null) {
      await initialize();
    }
    return _prefs!;
  }

  // ============================================================
  // MONNAIE
  // ============================================================

  /// Obtenir la monnaie sélectionnée
  Future<String> getCurrency() async {
    final p = await prefs;
    return p.getString(kUserCurrency) ?? PreferencesDefaults.defaultCurrency;
  }
  
  /// Obtenir la monnaie de manière synchrone
  String getCurrencySync() {
    return _prefs?.getString(kUserCurrency) ?? PreferencesDefaults.defaultCurrency;
  }

  /// Définir la monnaie
  Future<bool> setCurrency(String currencyCode) async {
    final p = await prefs;
    // Invalider le cache du formatter lors du changement de devise
    _cachedFormatter = null;
    _cachedCurrencyCode = null;
    return p.setString(kUserCurrency, currencyCode);
  }

  /// Obtenir le symbole de la monnaie actuelle
  Future<String> getCurrencySymbol() async {
    final code = await getCurrency();
    return SupportedCurrencies.getSymbol(code);
  }
  
  /// Obtenir le taux de change de la monnaie utilisateur par rapport à l'euro
  Future<double> getCurrencyRate() async {
    final code = await getCurrency();
    return SupportedCurrencies.getRate(code);
  }
  
  /// Convertir un montant depuis l'euro vers la monnaie de l'utilisateur
  Future<double> convertFromEuro(double euroAmount) async {
    final code = await getCurrency();
    return SupportedCurrencies.fromEuro(euroAmount, code);
  }
  
  /// Convertir un montant depuis la monnaie utilisateur vers l'euro
  Future<double> convertToEuro(double amount) async {
    final code = await getCurrency();
    return SupportedCurrencies.toEuro(amount, code);
  }
  
  /// Convertir de manière synchrone (utilise le cache)
  double convertFromEuroSync(double euroAmount) {
    final code = getCurrencySync();
    return SupportedCurrencies.fromEuro(euroAmount, code);
  }
  
  /// Convertir vers l'euro de manière synchrone
  double convertToEuroSync(double amount) {
    final code = getCurrencySync();
    return SupportedCurrencies.toEuro(amount, code);
  }

  // ============================================================
  // UNITÉ DE POIDS
  // ============================================================

  /// Obtenir l'unité de poids sélectionnée (kg ou lb)
  Future<String> getWeightUnit() async {
    final p = await prefs;
    return p.getString(kUserWeightUnit) ?? PreferencesDefaults.defaultWeightUnit;
  }

  /// Définir l'unité de poids
  Future<bool> setWeightUnit(String unit) async {
    final p = await prefs;
    return p.setString(kUserWeightUnit, unit);
  }

  /// Obtenir l'unité de poids de manière synchrone (fallback si non initialisé)
  String getWeightUnitSync() {
    return _prefs?.getString(kUserWeightUnit) ?? PreferencesDefaults.defaultWeightUnit;
  }

  /// Formater un poids avec l'unité appropriée
  Future<String> formatWeight(double weightKg) async {
    final unit = await getWeightUnit();
    if (unit == 'lb') {
      final weightLb = weightKg * 2.20462;
      return '${weightLb.toStringAsFixed(1)} lb';
    }
    return '${weightKg.toStringAsFixed(2)} kg';
  }

  /// Convertir un poids depuis l'unité utilisateur vers kg
  Future<double> convertToKg(double weight) async {
    final unit = await getWeightUnit();
    if (unit == 'lb') {
      return weight / 2.20462;
    }
    return weight;
  }

  // ============================================================
  // FORMATAGE MONÉTAIRE
  // ============================================================

  /// Cache pour le NumberFormat (évite recréation)
  NumberFormat? _cachedFormatter;
  String? _cachedCurrencyCode;

  /// Formater un montant avec la monnaie de l'utilisateur
  Future<String> formatMoney(double amount, {int decimals = 2}) async {
    final currencyCode = await getCurrency();
    final symbol = await getCurrencySymbol();
    
    // Réutiliser le formatter si même monnaie
    if (_cachedFormatter == null || _cachedCurrencyCode != currencyCode) {
      _cachedCurrencyCode = currencyCode;
      _cachedFormatter = NumberFormat.currency(
        locale: 'fr_FR',
        symbol: symbol,
        decimalDigits: decimals,
      );
    }
    
    return _cachedFormatter!.format(amount);
  }

  /// Formater un montant de manière synchrone (utilise cache ou défaut)
  String formatMoneySync(double amount, {int decimals = 2}) {
    if (_cachedFormatter != null) {
      return _cachedFormatter!.format(amount);
    }
    // Fallback avec euro par défaut
    return NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '€',
      decimalDigits: decimals,
    ).format(amount);
  }

  /// Obtenir un NumberFormat pour la monnaie de l'utilisateur
  Future<NumberFormat> getMoneyFormatter({int decimals = 2}) async {
    final symbol = await getCurrencySymbol();
    return NumberFormat.currency(
      locale: 'fr_FR',
      symbol: symbol,
      decimalDigits: decimals,
    );
  }

  /// Obtenir un NumberFormat synchrone (utilise le cache ou le défaut)
  NumberFormat getMoneyFormatterSync({int decimals = 2}) {
    if (_cachedFormatter != null) {
      return _cachedFormatter!;
    }
    // Fallback avec euro par défaut
    return NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '€',
      decimalDigits: decimals,
    );
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  /// Obtenir l'état des notifications santé
  Future<bool> getNotifSante() async {
    final p = await prefs;
    return p.getBool(kNotifSante) ?? PreferencesDefaults.defaultNotifSante;
  }

  /// Définir l'état des notifications santé
  Future<bool> setNotifSante(bool enabled) async {
    final p = await prefs;
    return p.setBool(kNotifSante, enabled);
  }

  /// Obtenir l'état des notifications reproduction
  Future<bool> getNotifReproduction() async {
    final p = await prefs;
    return p.getBool(kNotifReproduction) ?? PreferencesDefaults.defaultNotifReproduction;
  }

  /// Définir l'état des notifications reproduction
  Future<bool> setNotifReproduction(bool enabled) async {
    final p = await prefs;
    return p.setBool(kNotifReproduction, enabled);
  }

  /// Obtenir l'état des alertes critiques
  Future<bool> getNotifAlertes() async {
    final p = await prefs;
    return p.getBool(kNotifAlertesCritiques) ?? PreferencesDefaults.defaultNotifAlertes;
  }

  /// Définir l'état des alertes critiques
  Future<bool> setNotifAlertes(bool enabled) async {
    final p = await prefs;
    return p.setBool(kNotifAlertesCritiques, enabled);
  }

  /// Sauvegarder toutes les préférences de notification
  Future<void> setAllNotificationPreferences({
    required bool sante,
    required bool reproduction,
    required bool alertes,
  }) async {
    await Future.wait([
      setNotifSante(sante),
      setNotifReproduction(reproduction),
      setNotifAlertes(alertes),
    ]);
    logger.info('✅ Préférences notification sauvegardées');
  }

  // ============================================================
  // MODE DE GESTION
  // ============================================================

  /// Obtenir le mode de gestion actuel
  Future<GestionMode> getGestionMode() async {
    final p = await prefs;
    final value = p.getString(kGestionMode);
    return GestionModeExtension.fromDbValue(value);
  }

  /// Définir le mode de gestion
  Future<bool> setGestionMode(GestionMode mode) async {
    final p = await prefs;
    return p.setString(kGestionMode, mode.toDbValue);
  }

  // ============================================================
  // ONBOARDING V2
  // ============================================================

  /// Vérifier si l'onboarding V2 est terminé
  Future<bool> isOnboardingV2Complete() async {
    final p = await prefs;
    return p.getBool(kOnboardingV2Complete) ?? false;
  }

  /// Marquer l'onboarding V2 comme terminé
  Future<bool> setOnboardingV2Complete(bool complete) async {
    final p = await prefs;
    return p.setBool(kOnboardingV2Complete, complete);
  }

  // ============================================================
  // PRÉFÉRENCES RÉGIONALES (BATCH)
  // ============================================================

  /// Sauvegarder les préférences régionales (monnaie + unité de poids)
  Future<void> setRegionalPreferences({
    required String currency,
    required String weightUnit,
  }) async {
    await Future.wait([
      setCurrency(currency),
      setWeightUnit(weightUnit),
    ]);
    logger.info('✅ Préférences régionales sauvegardées: $currency, $weightUnit');
  }

  // ============================================================
  // UTILITAIRES
  // ============================================================

  /// Réinitialiser toutes les préférences aux valeurs par défaut
  Future<void> resetToDefaults() async {
    final p = await prefs;
    await p.setString(kUserCurrency, PreferencesDefaults.defaultCurrency);
    await p.setString(kUserWeightUnit, PreferencesDefaults.defaultWeightUnit);
    await p.setBool(kNotifSante, PreferencesDefaults.defaultNotifSante);
    await p.setBool(kNotifReproduction, PreferencesDefaults.defaultNotifReproduction);
    await p.setBool(kNotifAlertesCritiques, PreferencesDefaults.defaultNotifAlertes);
    await p.setString(kGestionMode, PreferencesDefaults.defaultGestionMode);
    await p.setBool(kOnboardingV2Complete, false);
    logger.warning('⚠️ Préférences réinitialisées aux valeurs par défaut');
  }

  /// Obtenir toutes les préférences actuelles (pour debug/récap)
  Future<Map<String, dynamic>> getAllPreferences() async {
    return {
      'currency': await getCurrency(),
      'currencySymbol': await getCurrencySymbol(),
      'weightUnit': await getWeightUnit(),
      'notifSante': await getNotifSante(),
      'notifReproduction': await getNotifReproduction(),
      'notifAlertes': await getNotifAlertes(),
      'gestionMode': (await getGestionMode()).label,
      'onboardingV2Complete': await isOnboardingV2Complete(),
    };
  }
}
