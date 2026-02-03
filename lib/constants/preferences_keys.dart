/// Clés de préférences utilisateur pour SharedPreferences
/// 
/// Ces constantes définissent les clés utilisées pour stocker
/// les préférences utilisateur collectées durant l'onboarding V2
library preferences_keys;

// ============================================================
// CLÉS SHAREDPREFERENCES
// ============================================================

/// Clé pour la monnaie sélectionnée (code ISO: EUR, XOF, USD, etc.)
const String kUserCurrency = 'user_currency';

/// Clé pour l'unité de poids (kg ou lb)
const String kUserWeightUnit = 'user_weight_unit';

/// Clé pour les notifications santé activées
const String kNotifSante = 'notif_sante';

/// Clé pour les notifications reproduction activées
const String kNotifReproduction = 'notif_reproduction';

/// Clé pour les alertes critiques activées
const String kNotifAlertesCritiques = 'notif_alertes_critiques';

/// Clé pour le mode de gestion (lots/individu/mixte)
const String kGestionMode = 'gestion_mode';

/// Clé pour savoir si l'onboarding V2 est terminé
const String kOnboardingV2Complete = 'onboarding_v2_complete';

// ============================================================
// VALEURS PAR DÉFAUT
// ============================================================

/// Classe contenant toutes les valeurs par défaut des préférences
abstract class PreferencesDefaults {
  /// Monnaie par défaut (Euro)
  static const String defaultCurrency = 'EUR';
  
  /// Unité de poids par défaut (kilogrammes)
  static const String defaultWeightUnit = 'kg';
  
  /// Notifications santé activées par défaut
  static const bool defaultNotifSante = true;
  
  /// Notifications reproduction activées par défaut
  static const bool defaultNotifReproduction = true;
  
  /// Alertes critiques activées par défaut
  static const bool defaultNotifAlertes = true;
  
  /// Mode de gestion par défaut (individuel)
  static const String defaultGestionMode = 'individuel';
}

// ============================================================
// MONNAIES SUPPORTÉES
// ============================================================

/// Représente une monnaie supportée par l'application
class SupportedCurrency {
  final String code;
  final String symbol;
  final String name;
  final String flag;
  /// Taux de change par rapport à l'euro (1 EUR = rate unités de cette devise)
  /// Exemple : 1 EUR = 655.957 FCFA
  final double rateFromEuro;

  const SupportedCurrency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
    this.rateFromEuro = 1.0,
  });
  
  /// Convertir un montant depuis l'euro vers cette devise
  double fromEuro(double euroAmount) => euroAmount * rateFromEuro;
  
  /// Convertir un montant depuis cette devise vers l'euro
  double toEuro(double amount) => amount / rateFromEuro;
}

/// Liste des monnaies supportées par l'application
/// Taux de change approximatifs (février 2026) - à mettre à jour périodiquement
abstract class SupportedCurrencies {
  static const List<SupportedCurrency> all = [
    SupportedCurrency(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      flag: '🇪🇺',
      rateFromEuro: 1.0, // Référence
    ),
    SupportedCurrency(
      code: 'XOF',
      symbol: 'FCFA',
      name: 'Franc CFA (UEMOA)',
      flag: '🇸🇳',
      rateFromEuro: 655.957, // Taux fixe officiel
    ),
    SupportedCurrency(
      code: 'XAF',
      symbol: 'FCFA',
      name: 'Franc CFA (CEMAC)',
      flag: '🇨🇲',
      rateFromEuro: 655.957, // Taux fixe officiel
    ),
    SupportedCurrency(
      code: 'MAD',
      symbol: 'DH',
      name: 'Dirham marocain',
      flag: '🇲🇦',
      rateFromEuro: 10.85, // Approximatif
    ),
    SupportedCurrency(
      code: 'TND',
      symbol: 'DT',
      name: 'Dinar tunisien',
      flag: '🇹🇳',
      rateFromEuro: 3.35, // Approximatif
    ),
    SupportedCurrency(
      code: 'USD',
      symbol: '\$',
      name: 'Dollar américain',
      flag: '🇺🇸',
      rateFromEuro: 1.08, // Approximatif
    ),
    SupportedCurrency(
      code: 'GBP',
      symbol: '£',
      name: 'Livre sterling',
      flag: '🇬🇧',
      rateFromEuro: 0.85, // Approximatif
    ),
    SupportedCurrency(
      code: 'CHF',
      symbol: 'CHF',
      name: 'Franc suisse',
      flag: '🇨🇭',
      rateFromEuro: 0.94, // Approximatif
    ),
    SupportedCurrency(
      code: 'CAD',
      symbol: 'CAD',
      name: 'Dollar canadien',
      flag: '🇨🇦',
      rateFromEuro: 1.47, // Approximatif
    ),
  ];

  /// Trouver une monnaie par son code
  static SupportedCurrency? getByCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }
  
  /// Obtenir le symbole d'une monnaie par son code
  static String getSymbol(String code) {
    return getByCode(code)?.symbol ?? code;
  }
  
  /// Obtenir le taux de change par rapport à l'euro
  static double getRate(String code) {
    return getByCode(code)?.rateFromEuro ?? 1.0;
  }
  
  /// Convertir un montant d'une devise vers une autre
  /// Les montants passent par l'euro comme devise pivot
  static double convert({
    required double amount,
    required String fromCode,
    required String toCode,
  }) {
    if (fromCode == toCode) return amount;
    
    final fromCurrency = getByCode(fromCode);
    final toCurrency = getByCode(toCode);
    
    if (fromCurrency == null || toCurrency == null) return amount;
    
    // Convertir vers euro puis vers la devise cible
    final euroAmount = fromCurrency.toEuro(amount);
    return toCurrency.fromEuro(euroAmount);
  }
  
  /// Convertir un montant en euro vers la devise spécifiée
  static double fromEuro(double euroAmount, String toCode) {
    return getByCode(toCode)?.fromEuro(euroAmount) ?? euroAmount;
  }
  
  /// Convertir un montant d'une devise vers l'euro
  static double toEuro(double amount, String fromCode) {
    return getByCode(fromCode)?.toEuro(amount) ?? amount;
  }
}

// ============================================================
// RACES COMMUNES
// ============================================================

/// Liste des races de lapins communes pré-remplies
abstract class CommonRaces {
  static const List<String> all = [
    'Néo-Zélandais',
    'Californien',
    'Rex',
    'Géant des Flandres',
    'Fauve de Bourgogne',
    'Papillon',
    'Bélier Français',
    'Argenté de Champagne',
    'Hollandais',
    'Alaska',
    'Chinchilla',
    'Angora',
    'Nain',
    'Autre',
  ];
}

// ============================================================
// MODES DE GESTION
// ============================================================

/// Modes de gestion du cheptel
enum GestionMode {
  /// Gestion individuelle (chaque lapin suivi séparément)
  individuel,
  
  /// Gestion par lots (groupes de lapins)
  lots,
  
  /// Gestion mixte (reproducteurs individuels + engraissement en lots)
  mixte,
}

/// Extension pour le mode de gestion
extension GestionModeExtension on GestionMode {
  String get label {
    switch (this) {
      case GestionMode.individuel:
        return 'Individuel';
      case GestionMode.lots:
        return 'Par lots';
      case GestionMode.mixte:
        return 'Mixte';
    }
  }

  String get description {
    switch (this) {
      case GestionMode.individuel:
        return 'Chaque lapin est suivi séparément';
      case GestionMode.lots:
        return 'Les lapins sont gérés par groupes';
      case GestionMode.mixte:
        return 'Reproducteurs individuels, engraissement en lots';
    }
  }

  String get icon {
    switch (this) {
      case GestionMode.individuel:
        return '🐰';
      case GestionMode.lots:
        return '🐇🐇';
      case GestionMode.mixte:
        return '🐰+🐇';
    }
  }

  String get toDbValue {
    switch (this) {
      case GestionMode.individuel:
        return 'individuel';
      case GestionMode.lots:
        return 'lots';
      case GestionMode.mixte:
        return 'mixte';
    }
  }

  static GestionMode fromDbValue(String? value) {
    switch (value) {
      case 'lots':
        return GestionMode.lots;
      case 'mixte':
        return GestionMode.mixte;
      default:
        return GestionMode.individuel;
    }
  }
}
