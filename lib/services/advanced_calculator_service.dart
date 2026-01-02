/// Structure pour les résultats de ration
class RationResult {
  final double granules; // en grammes
  final double foinMin; // en grammes
  final double foinMax; // en grammes
  final double eau; // en ml
  final Map<String, String> details;

  RationResult({
    required this.granules,
    required this.foinMin,
    required this.foinMax,
    required this.eau,
    this.details = const {},
  });

  Map<String, String> toMap() {
    return {
      'granules': '${granules.toStringAsFixed(0)} g',
      'foin': '$foinMin-$foinMax g',
      'eau': '${eau.toStringAsFixed(0)} ml',
      ...details,
    };
  }
}

/// Service de calculs avancés pour dosages et rations
/// 
/// Fournit des méthodes pour :
/// - Calculs de dosages médicaux (avec dilution, concentration)
/// - Calculs de rations alimentaires (individuelles et de groupe)
/// - Conversions d'unités
/// - Calculs de coûts
class AdvancedCalculatorService {
  static final AdvancedCalculatorService _instance =
      AdvancedCalculatorService._internal();
  factory AdvancedCalculatorService() => _instance;
  AdvancedCalculatorService._internal();

  // ============================================
  // CALCULS DE DOSAGES
  // ============================================

  /// Calculer la dose à administrer selon le poids
  /// 
  /// [poidsKg] : Poids du lapin en kg
  /// [dosageParKg] : Dosage en ml/kg ou mg/kg
  /// Retourne la dose totale à administrer
  double calculerDose({
    required double poidsKg,
    required double dosageParKg,
  }) {
    return poidsKg * dosageParKg;
  }

  /// Calculer la dose avec dilution
  /// 
  /// [poidsKg] : Poids du lapin en kg
  /// [dosageParKg] : Dosage en mg/kg
  /// [concentrationMere] : Concentration du produit mère (mg/ml)
  /// Retourne le volume à prélever en ml
  double calculerDoseAvecDilution({
    required double poidsKg,
    required double dosageParKg,
    required double concentrationMere,
  }) {
    final doseNecessaire = calculerDose(
      poidsKg: poidsKg,
      dosageParKg: dosageParKg,
    );
    return doseNecessaire / concentrationMere;
  }

  /// Calculer la dilution nécessaire
  /// 
  /// [concentrationInitiale] : Concentration initiale (mg/ml)
  /// [concentrationSouhaitee] : Concentration souhaitée (mg/ml)
  /// [volumeFinal] : Volume final souhaité (ml)
  /// Retourne un map avec 'volumeProduit' et 'volumeDiluant'
  Map<String, double> calculerDilution({
    required double concentrationInitiale,
    required double concentrationSouhaitee,
    required double volumeFinal,
  }) {
    final volumeProduit =
        (concentrationSouhaitee * volumeFinal) / concentrationInitiale;
    final volumeDiluant = volumeFinal - volumeProduit;

    return {
      'volumeProduit': volumeProduit,
      'volumeDiluant': volumeDiluant,
      'volumeFinal': volumeFinal,
    };
  }

  /// Calculer le dosage pour plusieurs lapins
  /// 
  /// [poidsTotal] : Somme des poids de tous les lapins (kg)
  /// [dosageParKg] : Dosage en ml/kg ou mg/kg
  /// Retourne la dose totale pour le groupe
  double calculerDoseGroupe({
    required double poidsTotal,
    required double dosageParKg,
  }) {
    return poidsTotal * dosageParKg;
  }

  /// Calculer le coût d'un traitement
  /// 
  /// [doseUtilisee] : Dose utilisée (ml ou g)
  /// [prixUnitaire] : Prix par unité (€/ml ou €/g)
  /// [unite] : Unité ('ml', 'g', 'comprime')
  /// Retourne le coût total
  double calculerCoutTraitement({
    required double doseUtilisee,
    required double prixUnitaire,
    required String unite,
  }) {
    return doseUtilisee * prixUnitaire;
  }

  // ============================================
  // CALCULS DE RATIONS ALIMENTAIRES
  // ============================================

  /// Calculer la ration quotidienne pour un lapin
  /// 
  /// [poidsKg] : Poids du lapin en kg
  /// [statutPhysiologique] : 'lapereau', 'jeune', 'adulte', 'gestante', 'allaitante'
  /// [niveauActivite] : 'faible', 'normal', 'eleve' (optionnel, défaut: 'normal')
  /// Retourne un RationResult avec les quantités recommandées
  RationResult calculerRation({
    required double poidsKg,
    required String statutPhysiologique,
    String niveauActivite = 'normal',
  }) {
    double granulePourcentage;
    double foinMin;
    double foinMax;
    double eau;

    // Coefficients de base selon le statut physiologique
    switch (statutPhysiologique.toLowerCase()) {
      case 'lapereau':
        granulePourcentage = 0.08; // 8% du poids corporel
        foinMin = 50;
        foinMax = 80;
        eau = poidsKg * 120; // 120 ml/kg
        break;

      case 'jeune':
        granulePourcentage = 0.05; // 5% du poids corporel
        foinMin = 80;
        foinMax = 120;
        eau = poidsKg * 100; // 100 ml/kg
        break;

      case 'gestante':
        granulePourcentage = 0.06; // 6% du poids corporel
        foinMin = 100;
        foinMax = 150;
        eau = poidsKg * 150; // 150 ml/kg
        break;

      case 'allaitante':
        granulePourcentage = 0.08; // 8% du poids corporel
        foinMin = 150;
        foinMax = 200;
        eau = poidsKg * 200; // 200 ml/kg
        break;

      case 'adulte':
      default:
        granulePourcentage = 0.03; // 3% du poids corporel
        foinMin = 100;
        foinMax = 150;
        eau = poidsKg * 100; // 100 ml/kg
        break;
    }

    // Ajustement selon le niveau d'activité
    double facteurActivite = 1.0;
    switch (niveauActivite.toLowerCase()) {
      case 'faible':
        facteurActivite = 0.9;
        break;
      case 'eleve':
        facteurActivite = 1.15;
        break;
      default:
        facteurActivite = 1.0;
    }

    final granules = (poidsKg * 1000 * granulePourcentage) * facteurActivite;
    final foinMinAjuste = foinMin * facteurActivite;
    final foinMaxAjuste = foinMax * facteurActivite;
    final eauAjustee = eau * facteurActivite;

    return RationResult(
      granules: granules,
      foinMin: foinMinAjuste,
      foinMax: foinMaxAjuste,
      eau: eauAjustee,
      details: {
        'statut': statutPhysiologique,
        'niveauActivite': niveauActivite,
        'facteurActivite': '${(facteurActivite * 100).toStringAsFixed(0)}%',
      },
    );
  }

  /// Calculer la ration pour un groupe de lapins
  /// 
  /// [lapins] : Liste de maps avec 'poids' (kg) et 'statut' (optionnel)
  /// Retourne un RationResult avec les quantités totales
  RationResult calculerRationGroupe(List<Map<String, dynamic>> lapins) {
    double totalGranules = 0;
    double totalFoinMin = 0;
    double totalFoinMax = 0;
    double totalEau = 0;

    for (final lapin in lapins) {
      final poids = (lapin['poids'] as num?)?.toDouble() ?? 0.0;
      final statut = lapin['statut'] as String? ?? 'adulte';

      if (poids > 0) {
        final ration = calculerRation(
          poidsKg: poids,
          statutPhysiologique: statut,
        );

        totalGranules += ration.granules;
        totalFoinMin += ration.foinMin;
        totalFoinMax += ration.foinMax;
        totalEau += ration.eau;
      }
    }

    return RationResult(
      granules: totalGranules,
      foinMin: totalFoinMin,
      foinMax: totalFoinMax,
      eau: totalEau,
      details: {
        'nombreLapins': lapins.length.toString(),
        'poidsTotal': lapins
                .map((l) => (l['poids'] as num?)?.toDouble() ?? 0.0)
                .fold(0.0, (a, b) => a + b)
                .toStringAsFixed(2),
      },
    );
  }

  /// Calculer le coût d'alimentation mensuel
  /// 
  /// [rationQuotidienne] : RationResult quotidienne
  /// [prixGranules] : Prix des granulés (€/kg)
  /// [prixFoin] : Prix du foin (€/kg)
  /// Retourne le coût mensuel en euros
  double calculerCoutAlimentationMensuel({
    required RationResult rationQuotidienne,
    required double prixGranules,
    required double prixFoin,
  }) {
    // Calculer les quantités mensuelles (30 jours)
    final granulesMensuels = (rationQuotidienne.granules / 1000) * 30;
    final foinMensuel = ((rationQuotidienne.foinMin + rationQuotidienne.foinMax) / 2 / 1000) * 30;

    final coutGranules = granulesMensuels * prixGranules;
    final coutFoin = foinMensuel * prixFoin;

    return coutGranules + coutFoin;
  }

  // ============================================
  // CONVERSIONS D'UNITÉS
  // ============================================

  /// Convertir ml en mg selon la concentration
  double mlVersMg({
    required double volumeMl,
    required double concentrationMgMl,
  }) {
    return volumeMl * concentrationMgMl;
  }

  /// Convertir mg en ml selon la concentration
  double mgVersMl({
    required double masseMg,
    required double concentrationMgMl,
  }) {
    return masseMg / concentrationMgMl;
  }

  /// Convertir kg en grammes
  double kgVersGrammes(double poidsKg) {
    return poidsKg * 1000;
  }

  /// Convertir grammes en kg
  double grammesVersKg(double poidsGrammes) {
    return poidsGrammes / 1000;
  }
}
