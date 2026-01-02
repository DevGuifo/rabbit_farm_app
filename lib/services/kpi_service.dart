import '../models/lapin.dart';
import '../models/accouplement.dart';
import '../models/portee.dart';
import '../models/soin.dart';
import '../models/pesee.dart';
import '../models/deces.dart';
import '../services/database_helper.dart';
import '../utils/logger.dart';

/// Structure pour les KPIs complets
class KpiData {
    // Cheptel
    final int totalLapins;
    final int males;
    final int femelles;
    final int lapereaux;
    final int adultes;
    final int enQuarantaine;

    // Reproduction
    final int accouplementsActifs;
    final int porteesActives;
    final double tauxReproduction; // %
    final int prochainesMisesBas; // dans les 7 prochains jours
    final double tauxSevrage; // %

    // Santé
    final int soinsUrgents;
    final int vaccinationsEnRetard;
    final int lapinsMalades;
    final double tauxMortalite; // %

    // Performance
    final double gmqMoyen; // g/jour
    final int peseesCeMois;

    // Finances
    final double coutAlimentationMensuel;
    final double recettesMensuelles;
    final double beneficeMensuel;

    KpiData({
      required this.totalLapins,
      required this.males,
      required this.femelles,
      required this.lapereaux,
      required this.adultes,
      required this.enQuarantaine,
      required this.accouplementsActifs,
      required this.porteesActives,
      required this.tauxReproduction,
      required this.prochainesMisesBas,
      required this.tauxSevrage,
      required this.soinsUrgents,
      required this.vaccinationsEnRetard,
      required this.lapinsMalades,
      required this.tauxMortalite,
      required this.gmqMoyen,
      required this.peseesCeMois,
      required this.coutAlimentationMensuel,
      required this.recettesMensuelles,
      required this.beneficeMensuel,
    });
}

/// Service de calcul des KPIs (Key Performance Indicators)
/// 
/// Fournit des indicateurs de performance pour l'élevage :
/// - Taux de reproduction
/// - Taux de mortalité
/// - Taux de sevrage
/// - Statistiques financières
/// - Indicateurs de santé
class KpiService {
  static final KpiService _instance = KpiService._internal();
  factory KpiService() => _instance;
  KpiService._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Calculer tous les KPIs
  Future<KpiData> calculerTousLesKpis() async {
    try {
      // Charger toutes les données nécessaires
      final lapins = await _db.getAllLapins();
      final accouplements = await _db.getAllAccouplements();
      final portees = await _db.getAllPortees();
      final soins = await _db.getAllSoins();
      final pesees = await _db.getAllPesees();
      final deces = await _db.getAllDeces();

      // Calculer les KPIs
      final cheptelKpis = _calculerKpisCheptel(lapins);
      final reproductionKpis = _calculerKpisReproduction(
        accouplements,
        portees,
      );
      final santeKpis = _calculerKpisSante(soins, lapins, deces);
      final performanceKpis = _calculerKpisPerformance(pesees);
      final financeKpis = await _calculerKpisFinances(lapins);

      return KpiData(
        // Cheptel
        totalLapins: cheptelKpis['total']!,
        males: cheptelKpis['males']!,
        femelles: cheptelKpis['femelles']!,
        lapereaux: cheptelKpis['lapereaux']!,
        adultes: cheptelKpis['adultes']!,
        enQuarantaine: cheptelKpis['enQuarantaine']!,

        // Reproduction
        accouplementsActifs: reproductionKpis['accouplementsActifs']!,
        porteesActives: reproductionKpis['porteesActives']!,
        tauxReproduction: reproductionKpis['tauxReproduction']!,
        prochainesMisesBas: reproductionKpis['prochainesMisesBas']!,
        tauxSevrage: reproductionKpis['tauxSevrage']!,

        // Santé
        soinsUrgents: santeKpis['soinsUrgents']!,
        vaccinationsEnRetard: santeKpis['vaccinationsEnRetard']!,
        lapinsMalades: santeKpis['lapinsMalades']!,
        tauxMortalite: santeKpis['tauxMortalite']!,

        // Performance
        gmqMoyen: performanceKpis['gmqMoyen']!,
        peseesCeMois: performanceKpis['peseesCeMois']!,

        // Finances
        coutAlimentationMensuel: financeKpis['coutAlimentation']!,
        recettesMensuelles: financeKpis['recettes']!,
        beneficeMensuel: financeKpis['benefice']!,
      );
    } catch (e, stackTrace) {
      logger.error('Erreur lors du calcul des KPIs', e, stackTrace);
      // Retourner des valeurs par défaut en cas d'erreur
      return KpiData(
        totalLapins: 0,
        males: 0,
        femelles: 0,
        lapereaux: 0,
        adultes: 0,
        enQuarantaine: 0,
        accouplementsActifs: 0,
        porteesActives: 0,
        tauxReproduction: 0.0,
        prochainesMisesBas: 0,
        tauxSevrage: 0.0,
        soinsUrgents: 0,
        vaccinationsEnRetard: 0,
        lapinsMalades: 0,
        tauxMortalite: 0.0,
        gmqMoyen: 0.0,
        peseesCeMois: 0,
        coutAlimentationMensuel: 0.0,
        recettesMensuelles: 0.0,
        beneficeMensuel: 0.0,
      );
    }
  }

  /// Calculer les KPIs du cheptel
  Map<String, int> _calculerKpisCheptel(List<Lapin> lapins) {
    final actifs = lapins.where((l) =>
        l.statut != 'vendu' && l.statut != 'decede').toList();

    final males = actifs.where((l) =>
        l.sexe.toLowerCase() == 'mâle' ||
        l.sexe.toLowerCase() == 'male').length;

    final femelles = actifs.where((l) =>
        l.sexe.toLowerCase() == 'femelle').length;

    // Calculer l'âge pour déterminer les lapereaux (< 8 semaines = 56 jours)
    final maintenant = DateTime.now();
    final lapereaux = actifs.where((l) =>
        maintenant.difference(l.dateNaissance).inDays < 56).length;

    final adultes = actifs.length - lapereaux;

    // Compter les lapins en quarantaine
    final enQuarantaine = actifs.where((l) =>
        l.statut != null && l.statut!.toLowerCase() == 'quarantaine').length;

    return {
      'total': actifs.length,
      'males': males,
      'femelles': femelles,
      'lapereaux': lapereaux,
      'adultes': adultes,
      'enQuarantaine': enQuarantaine,
    };
  }

  /// Calculer les KPIs de reproduction
  Map<String, dynamic> _calculerKpisReproduction(
    List<Accouplement> accouplements,
    List<Portee> portees,
  ) {
    final maintenant = DateTime.now();
    final dans7Jours = maintenant.add(const Duration(days: 7));

    // Accouplements actifs (en attente ou confirmés)
    final actifs = accouplements.where((acc) =>
        acc.statut == 'en_attente' || acc.statut == 'confirme').length;

    // Portées actives (avec lapereaux non sevrés)
    final porteesActives = portees.where((portee) {
      final agePortee = maintenant.difference(portee.dateMiseBasReelle).inDays;
      return agePortee < 42; // Portées de moins de 6 semaines
    }).length;

    // Taux de reproduction (accouplements réussis / total)
    final totalAccouplements = accouplements.length;
    final reussis = accouplements.where((acc) =>
        acc.statut == 'confirme' || acc.statut == 'porte').length;
    final tauxReproduction = totalAccouplements > 0
        ? (reussis / totalAccouplements) * 100
        : 0.0;

    // Prochaines mises bas (dans les 7 prochains jours)
    final prochainesMisesBas = accouplements.where((acc) {
      return acc.statut == 'en_attente' &&
          acc.dateMiseBasPrevue.isAfter(maintenant) &&
          acc.dateMiseBasPrevue.isBefore(dans7Jours);
    }).length;

    // Taux de sevrage (portées sevrées / total portées)
    final totalPortees = portees.length;
    final sevrees = portees.where((portee) {
      final agePortee = maintenant.difference(portee.dateMiseBasReelle).inDays;
      return agePortee >= 35; // Portées de plus de 5 semaines
    }).length;
    final tauxSevrage = totalPortees > 0 ? (sevrees / totalPortees) * 100 : 0.0;

    return {
      'accouplementsActifs': actifs,
      'porteesActives': porteesActives,
      'tauxReproduction': tauxReproduction,
      'prochainesMisesBas': prochainesMisesBas,
      'tauxSevrage': tauxSevrage,
    };
  }

  /// Calculer les KPIs de santé
  Map<String, dynamic> _calculerKpisSante(
    List<Soin> soins,
    List<Lapin> lapins,
    List<Deces> deces,
  ) {
    final maintenant = DateTime.now();
    final dans3Jours = maintenant.add(const Duration(days: 3));

    // Soins urgents (rappels dans les 3 prochains jours)
    final soinsUrgents = soins.where((soin) =>
        soin.dateRappel != null &&
        soin.dateRappel!.isAfter(maintenant) &&
        soin.dateRappel!.isBefore(dans3Jours)).length;

    // Vaccinations en retard
    final vaccinationsEnRetard = soins.where((soin) {
      if (soin.type.toLowerCase().contains('vaccin') &&
          soin.dateRappel != null) {
        return soin.dateRappel!.isBefore(maintenant);
      }
      return false;
    }).length;

    // Lapins malades (en quarantaine ou avec soins récents)
    final lapinsMalades = lapins.where((l) =>
        (l.statut != null && l.statut!.toLowerCase() == 'quarantaine') ||
        (l.statut != null && l.statut!.toLowerCase() == 'malade')).length;

    // Taux de mortalité (décès ce mois / total lapins)
    final debutMois = DateTime(maintenant.year, maintenant.month, 1);
    final decesCeMois = deces.where((d) =>
        d.dateDeces.isAfter(debutMois)).length;

    final totalLapins = lapins.length;
    final tauxMortalite = totalLapins > 0
        ? (decesCeMois / totalLapins) * 100
        : 0.0;

    return {
      'soinsUrgents': soinsUrgents,
      'vaccinationsEnRetard': vaccinationsEnRetard,
      'lapinsMalades': lapinsMalades,
      'tauxMortalite': tauxMortalite,
    };
  }

  /// Calculer les KPIs de performance
  Map<String, dynamic> _calculerKpisPerformance(List<Pesee> pesees) {
    final maintenant = DateTime.now();
    final debutMois = DateTime(maintenant.year, maintenant.month, 1);

    // Pesées ce mois
    final peseesCeMois = pesees.where((p) =>
        p.date.isAfter(debutMois)).length;

    // Calculer le GMQ moyen (Gain Moyen Quotidien)
    // Pour chaque lapin, calculer le GMQ entre la première et dernière pesée
    final gmqList = <double>[];
    final lapinsPesees = <int, List<Pesee>>{};

    // Grouper les pesées par lapin
    for (final pesee in pesees) {
      lapinsPesees.putIfAbsent(pesee.lapinId, () => []).add(pesee);
    }

    // Calculer GMQ pour chaque lapin
    for (final peseesLapin in lapinsPesees.values) {
      if (peseesLapin.length < 2) continue;

      peseesLapin.sort((a, b) => a.date.compareTo(b.date));
      final premiere = peseesLapin.first;
      final derniere = peseesLapin.last;

      final jours = derniere.date.difference(premiere.date).inDays;
      if (jours > 0) {
        final gmq = ((derniere.poids - premiere.poids) * 1000) / jours;
        if (gmq > 0) {
          gmqList.add(gmq);
        }
      }
    }

    final gmqMoyen = gmqList.isNotEmpty
        ? gmqList.reduce((a, b) => a + b) / gmqList.length
        : 0.0;

    return {
      'gmqMoyen': gmqMoyen,
      'peseesCeMois': peseesCeMois,
    };
  }

  /// Calculer les KPIs financiers
  Future<Map<String, double>> _calculerKpisFinances(
    List<Lapin> lapins,
  ) async {
    try {
      // Calculer le coût d'alimentation mensuel
      final lapinsActifs = lapins.where((l) =>
          l.statut != 'vendu' && l.statut != 'decede').length;

      // Estimation : 4 kg de granulés par lapin par mois à 0.6€/kg
      // + 4.5 kg de foin par lapin par mois à 0.3€/kg
      final coutGranules = lapinsActifs * 4 * 0.6;
      final coutFoin = lapinsActifs * 4.5 * 0.3;
      final coutAlimentation = coutGranules + coutFoin;

      // Récupérer les recettes du mois
      final maintenant = DateTime.now();
      final debutMois = DateTime(maintenant.year, maintenant.month, 1);
      final recettes = await _db.getRecettesByPeriode(debutMois, maintenant);
      final recettesMensuelles = recettes.fold<double>(
        0.0,
        (sum, recette) => sum + (recette.montant),
      );

      // Bénéfice = Recettes - Coûts
      final benefice = recettesMensuelles - coutAlimentation;

      return {
        'coutAlimentation': coutAlimentation,
        'recettes': recettesMensuelles,
        'benefice': benefice,
      };
    } catch (e) {
      logger.error('Erreur calcul KPIs finances: $e');
      return {
        'coutAlimentation': 0.0,
        'recettes': 0.0,
        'benefice': 0.0,
      };
    }
  }
}

