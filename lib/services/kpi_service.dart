import '../models/lapin.dart';
import '../models/accouplement.dart';
import '../models/portee.dart';
import '../models/soin.dart';
import '../models/pesee.dart';
import '../models/deces.dart';
import '../models/medicament.dart';
import '../models/aliment.dart';
import '../models/depense.dart';
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
  final int femellesReproductrices; // ✅ NOUVEAU
  final int malesReproducteurs; // ✅ NOUVEAU

  // Reproduction
  final int accouplementsActifs;
  final int porteesActives;
  final double tauxReproduction; // %
  final int prochainesMisesBas; // dans les 7 prochains jours
  final int prochainesMisesBas14Jours; // ✅ NOUVEAU dans les 14 jours
  final double tauxSevrage; // %
  final int femellesGestantes; // ✅ NOUVEAU

  // Santé
  final int soinsUrgents;
  final int vaccinationsEnRetard;
  final int lapinsMalades;
  final double tauxMortalite; // %
  final int medicamentsCritiques; // ✅ NOUVEAU (rupture ou alerte)

  // Performance
  final double gmqMoyen; // g/jour
  final int peseesCeMois;
  final int lapinsSousPoids; // ✅ NOUVEAU

  // Finances
  final double coutAlimentationMensuel;
  final double recettesMensuelles;
  final double beneficeMensuel;
  final double depensesMensuelles; // ✅ NOUVEAU
  final int alimentsEnAlerte; // ✅ NOUVEAU

  KpiData({
    required this.totalLapins,
    required this.males,
    required this.femelles,
    required this.lapereaux,
    required this.adultes,
    required this.enQuarantaine,
    required this.femellesReproductrices,
    required this.malesReproducteurs,
    required this.accouplementsActifs,
    required this.porteesActives,
    required this.tauxReproduction,
    required this.prochainesMisesBas,
    required this.prochainesMisesBas14Jours,
    required this.tauxSevrage,
    required this.femellesGestantes,
    required this.soinsUrgents,
    required this.vaccinationsEnRetard,
    required this.lapinsMalades,
    required this.tauxMortalite,
    required this.medicamentsCritiques,
    required this.gmqMoyen,
    required this.peseesCeMois,
    required this.lapinsSousPoids,
    required this.coutAlimentationMensuel,
    required this.recettesMensuelles,
    required this.beneficeMensuel,
    required this.depensesMensuelles,
    required this.alimentsEnAlerte,
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

      // ✅ NOUVEAU : Charger médicaments et aliments
      final medicaments = await _db.getAllMedicaments();
      final aliments = await _db.getAllAliments();
      final depenses = await _db.getAllDepenses();

      // Calculer les KPIs
      final cheptelKpis = _calculerKpisCheptel(lapins, accouplements);
      final reproductionKpis = _calculerKpisReproduction(
        accouplements,
        portees,
        lapins,
      );
      final santeKpis = _calculerKpisSante(soins, lapins, deces, medicaments);
      final performanceKpis = _calculerKpisPerformance(pesees, lapins);
      final financeKpis = await _calculerKpisFinances(
        lapins,
        depenses,
        aliments,
      );

      return KpiData(
        // Cheptel
        totalLapins: cheptelKpis['total']!,
        males: cheptelKpis['males']!,
        femelles: cheptelKpis['femelles']!,
        lapereaux: cheptelKpis['lapereaux']!,
        adultes: cheptelKpis['adultes']!,
        enQuarantaine: cheptelKpis['enQuarantaine']!,
        femellesReproductrices: cheptelKpis['femellesReproductrices']!,
        malesReproducteurs: cheptelKpis['malesReproducteurs']!,

        // Reproduction
        accouplementsActifs: reproductionKpis['accouplementsActifs']!,
        porteesActives: reproductionKpis['porteesActives']!,
        tauxReproduction: reproductionKpis['tauxReproduction']!,
        prochainesMisesBas: reproductionKpis['prochainesMisesBas']!,
        prochainesMisesBas14Jours:
            reproductionKpis['prochainesMisesBas14Jours']!,
        tauxSevrage: reproductionKpis['tauxSevrage']!,
        femellesGestantes: reproductionKpis['femellesGestantes']!,

        // Santé
        soinsUrgents: santeKpis['soinsUrgents']!,
        vaccinationsEnRetard: santeKpis['vaccinationsEnRetard']!,
        lapinsMalades: santeKpis['lapinsMalades']!,
        tauxMortalite: santeKpis['tauxMortalite']!,
        medicamentsCritiques: santeKpis['medicamentsCritiques']!,

        // Performance
        gmqMoyen: performanceKpis['gmqMoyen']!,
        peseesCeMois: performanceKpis['peseesCeMois']!,
        lapinsSousPoids: performanceKpis['lapinsSousPoids']!,

        // Finances
        coutAlimentationMensuel: financeKpis['coutAlimentation']!,
        recettesMensuelles: financeKpis['recettes']!,
        beneficeMensuel: financeKpis['benefice']!,
        depensesMensuelles: financeKpis['depensesMensuelles']!,
        alimentsEnAlerte: financeKpis['alimentsEnAlerte']!.toInt(),
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
        femellesReproductrices: 0,
        malesReproducteurs: 0,
        accouplementsActifs: 0,
        porteesActives: 0,
        tauxReproduction: 0.0,
        prochainesMisesBas: 0,
        prochainesMisesBas14Jours: 0,
        tauxSevrage: 0.0,
        femellesGestantes: 0,
        soinsUrgents: 0,
        vaccinationsEnRetard: 0,
        lapinsMalades: 0,
        tauxMortalite: 0.0,
        medicamentsCritiques: 0,
        gmqMoyen: 0.0,
        peseesCeMois: 0,
        lapinsSousPoids: 0,
        coutAlimentationMensuel: 0.0,
        recettesMensuelles: 0.0,
        beneficeMensuel: 0.0,
        depensesMensuelles: 0.0,
        alimentsEnAlerte: 0,
      );
    }
  }

  /// Calculer les KPIs du cheptel
  Map<String, int> _calculerKpisCheptel(
    List<Lapin> lapins,
    List<Accouplement> accouplements,
  ) {
    final actifs = lapins
        .where((l) => l.statut != 'vendu' && l.statut != 'decede')
        .toList();

    final males = actifs
        .where(
          (l) =>
              l.sexe.toLowerCase() == 'mâle' || l.sexe.toLowerCase() == 'male',
        )
        .length;

    final femelles = actifs
        .where((l) => l.sexe.toLowerCase() == 'femelle')
        .length;

    // Calculer l'âge pour déterminer les lapereaux (< 8 semaines = 56 jours)
    final maintenant = DateTime.now();
    final lapereaux = actifs
        .where((l) => maintenant.difference(l.dateNaissance).inDays < 56)
        .length;

    final adultes = actifs.length - lapereaux;

    // Compter les lapins en quarantaine
    final enQuarantaine = actifs
        .where(
          (l) => l.statut != null && l.statut!.toLowerCase() == 'quarantaine',
        )
        .length;

    // ✅ NOUVEAU : Femelles reproductrices (statut reproductrice)
    final femellesReproductrices = actifs.where((l) {
      final sexe = l.sexe.toLowerCase();
      final estFemelle = sexe == 'femelle' || sexe == 'f';
      final statut = l.statut?.toLowerCase();
      return estFemelle && statut == 'reproductrice';
    }).length;

    // ✅ NOUVEAU : Mâles reproducteurs (statut reproducteur)
    final malesReproducteurs = actifs.where((l) {
      final sexe = l.sexe.toLowerCase();
      final estMale = sexe == 'mâle' || sexe == 'male' || sexe == 'm';
      final statut = l.statut?.toLowerCase();
      return estMale && statut == 'reproducteur';
    }).length;

    return {
      'total': actifs.length,
      'males': males,
      'femelles': femelles,
      'lapereaux': lapereaux,
      'adultes': adultes,
      'enQuarantaine': enQuarantaine,
      'femellesReproductrices': femellesReproductrices,
      'malesReproducteurs': malesReproducteurs,
    };
  }

  /// Calculer les KPIs de reproduction
  Map<String, dynamic> _calculerKpisReproduction(
    List<Accouplement> accouplements,
    List<Portee> portees,
    List<Lapin> lapins,
  ) {
    final maintenant = DateTime.now();
    final dans7Jours = maintenant.add(const Duration(days: 7));
    final dans14Jours = maintenant.add(const Duration(days: 14));

    // Accouplements actifs (en attente ou confirmés)
    final actifs = accouplements
        .where((acc) => acc.statut == 'en_attente' || acc.statut == 'confirme')
        .length;

    // Portées actives (avec lapereaux non sevrés)
    final porteesActives = portees.where((portee) {
      final agePortee = maintenant.difference(portee.dateMiseBasReelle).inDays;
      return agePortee < 42; // Portées de moins de 6 semaines
    }).length;

    // Taux de reproduction (accouplements réussis / total)
    final totalAccouplements = accouplements.length;
    final reussis = accouplements
        .where((acc) => acc.statut == 'confirme' || acc.statut == 'termine')
        .length;
    final tauxReproduction = totalAccouplements > 0
        ? (reussis / totalAccouplements) * 100
        : 0.0;

    // Prochaines mises bas (dans les 7 prochains jours)
    final prochainesMisesBas = accouplements.where((acc) {
      return (acc.statut == 'en_attente' || acc.statut == 'confirme') &&
          acc.dateMiseBasPrevue.isAfter(maintenant) &&
          acc.dateMiseBasPrevue.isBefore(dans7Jours);
    }).length;

    // ✅ NOUVEAU : Prochaines mises bas (dans les 14 jours)
    final prochainesMisesBas14Jours = accouplements.where((acc) {
      return (acc.statut == 'en_attente' || acc.statut == 'confirme') &&
          acc.dateMiseBasPrevue.isAfter(maintenant) &&
          acc.dateMiseBasPrevue.isBefore(dans14Jours);
    }).length;

    // Taux de sevrage (portées sevrées / total portées)
    final totalPortees = portees.length;
    final sevrees = portees.where((portee) {
      final agePortee = maintenant.difference(portee.dateMiseBasReelle).inDays;
      return agePortee >= 35; // Portées de plus de 5 semaines
    }).length;
    final tauxSevrage = totalPortees > 0 ? (sevrees / totalPortees) * 100 : 0.0;

    // ✅ NOUVEAU : Femelles gestantes (ayant un accouplement actif)
    final femellesGestantesIds = <int>{};
    for (final acc in accouplements) {
      if (acc.statut == 'en_attente' || acc.statut == 'confirme') {
        if (acc.dateMiseBasPrevue.isAfter(maintenant)) {
          femellesGestantesIds.add(acc.femelleId);
        }
      }
    }
    final femellesGestantes = femellesGestantesIds.length;

    return {
      'accouplementsActifs': actifs,
      'porteesActives': porteesActives,
      'tauxReproduction': tauxReproduction,
      'prochainesMisesBas': prochainesMisesBas,
      'prochainesMisesBas14Jours': prochainesMisesBas14Jours,
      'tauxSevrage': tauxSevrage,
      'femellesGestantes': femellesGestantes,
    };
  }

  /// Calculer les KPIs de santé
  Map<String, dynamic> _calculerKpisSante(
    List<Soin> soins,
    List<Lapin> lapins,
    List<Deces> deces,
    List<Medicament> medicaments,
  ) {
    final maintenant = DateTime.now();
    final dans3Jours = maintenant.add(const Duration(days: 3));

    // Soins urgents (rappels dans les 3 prochains jours)
    final soinsUrgents = soins
        .where(
          (soin) =>
              soin.dateRappel != null &&
              soin.dateRappel!.isAfter(maintenant) &&
              soin.dateRappel!.isBefore(dans3Jours),
        )
        .length;

    // Vaccinations en retard
    final vaccinationsEnRetard = soins.where((soin) {
      if (soin.type.toLowerCase().contains('vaccin') &&
          soin.dateRappel != null) {
        return soin.dateRappel!.isBefore(maintenant);
      }
      return false;
    }).length;

    // Lapins malades (en quarantaine ou avec soins récents)
    final lapinsMalades = lapins
        .where(
          (l) =>
              (l.statut != null && l.statut!.toLowerCase() == 'quarantaine') ||
              (l.statut != null && l.statut!.toLowerCase() == 'malade'),
        )
        .length;

    // Taux de mortalité (décès ce mois / total lapins)
    final debutMois = DateTime(maintenant.year, maintenant.month, 1);
    final decesCeMois = deces
        .where((d) => d.dateDeces.isAfter(debutMois))
        .length;

    final totalLapins = lapins.length;
    final tauxMortalite = totalLapins > 0
        ? (decesCeMois / totalLapins) * 100
        : 0.0;

    // ✅ NOUVEAU : Médicaments critiques (en rupture ou sous seuil d'alerte)
    final medicamentsCritiques = medicaments.where((med) {
      final estEnRupture = med.quantiteStock == 0;
      final estSousSeuilAlerte =
          med.seuilAlerte != null && med.quantiteStock < med.seuilAlerte!;
      return estEnRupture || estSousSeuilAlerte;
    }).length;

    return {
      'soinsUrgents': soinsUrgents,
      'vaccinationsEnRetard': vaccinationsEnRetard,
      'lapinsMalades': lapinsMalades,
      'tauxMortalite': tauxMortalite,
      'medicamentsCritiques': medicamentsCritiques,
    };
  }

  /// Calculer les KPIs de performance
  Map<String, dynamic> _calculerKpisPerformance(
    List<Pesee> pesees,
    List<Lapin> lapins,
  ) {
    final maintenant = DateTime.now();
    final debutMois = DateTime(maintenant.year, maintenant.month, 1);

    // Pesées ce mois
    final peseesCeMois = pesees.where((p) => p.date.isAfter(debutMois)).length;

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

    // ✅ NOUVEAU : Lapins sous-poids (poids récent < 80% du poids moyen de leur âge)
    int lapinsSousPoids = 0;

    for (final lapin in lapins) {
      if (lapin.statut == 'vendu' || lapin.statut == 'decede') continue;

      // Récupérer la dernière pesée de ce lapin
      final peseesLapin = lapinsPesees[lapin.id];
      if (peseesLapin == null || peseesLapin.isEmpty) continue;

      peseesLapin.sort((a, b) => b.date.compareTo(a.date));
      final dernierePesee = peseesLapin.first;

      // Calculer le poids moyen attendu selon l'âge
      final ageEnJours = maintenant.difference(lapin.dateNaissance).inDays;
      double poidsAttendu;

      if (ageEnJours < 56) {
        // Lapereau (0-8 semaines) : ~50g/jour depuis 100g à la naissance
        poidsAttendu = 0.1 + (ageEnJours * 0.05); // kg
      } else if (ageEnJours < 180) {
        // Jeune adulte (2-6 mois) : croissance vers 3-3.5kg
        poidsAttendu = 2.5 + ((ageEnJours - 56) / 124) * 0.8; // kg
      } else {
        // Adulte (>6 mois) : 3.5kg moyenne pour lapins moyens
        poidsAttendu = 3.5; // kg
      }

      // Seuil : moins de 80% du poids attendu
      if (dernierePesee.poids < (poidsAttendu * 0.8)) {
        lapinsSousPoids++;
      }
    }

    return {
      'gmqMoyen': gmqMoyen,
      'peseesCeMois': peseesCeMois,
      'lapinsSousPoids': lapinsSousPoids,
    };
  }

  /// Calculer les KPIs financiers
  Future<Map<String, double>> _calculerKpisFinances(
    List<Lapin> lapins,
    List<Depense> depenses,
    List<Aliment> aliments,
  ) async {
    try {
      final maintenant = DateTime.now();
      final debutMois = DateTime(maintenant.year, maintenant.month, 1);

      // Calculer le coût d'alimentation mensuel
      final lapinsActifs = lapins
          .where((l) => l.statut != 'vendu' && l.statut != 'decede')
          .length;

      // Estimation : 4 kg de granulés par lapin par mois à 0.6€/kg
      // + 4.5 kg de foin par lapin par mois à 0.3€/kg
      final coutGranules = lapinsActifs * 4 * 0.6;
      final coutFoin = lapinsActifs * 4.5 * 0.3;
      final coutAlimentation = coutGranules + coutFoin;

      // Récupérer les recettes du mois
      final recettes = await _db.getRecettesByPeriode(debutMois, maintenant);
      final recettesMensuelles = recettes.fold<double>(
        0.0,
        (sum, recette) => sum + (recette.montant),
      );

      // ✅ NOUVEAU : Dépenses mensuelles (somme des dépenses du mois en cours)
      final depensesCeMois = depenses
          .where(
            (d) =>
                d.date.isAfter(debutMois) &&
                d.date.isBefore(maintenant.add(const Duration(days: 1))),
          )
          .toList();

      final depensesMensuelles = depensesCeMois.fold<double>(
        0.0,
        (sum, depense) => sum + depense.montant,
      );

      // ✅ NOUVEAU : Aliments en alerte (proche expiration ou stock faible)
      final dans30Jours = maintenant.add(const Duration(days: 30));
      int alimentsEnAlerte = 0;

      for (final aliment in aliments) {
        // Alerte si date d'expiration dans moins de 30 jours
        final procheExpiration =
            aliment.datePeremption != null &&
            aliment.datePeremption!.isBefore(dans30Jours);

        // Alerte si stock faible (< 20% du stock initial)
        final stockFaible =
            aliment.quantiteRestante < (aliment.quantiteAchetee * 0.2);

        if (procheExpiration || stockFaible) {
          alimentsEnAlerte++;
        }
      }

      // Bénéfice = Recettes - (Coûts alimentation + Dépenses)
      final benefice =
          recettesMensuelles - (coutAlimentation + depensesMensuelles);

      return {
        'coutAlimentation': coutAlimentation,
        'recettes': recettesMensuelles,
        'benefice': benefice,
        'depensesMensuelles': depensesMensuelles,
        'alimentsEnAlerte': alimentsEnAlerte.toDouble(),
      };
    } catch (e) {
      logger.error('Erreur calcul KPIs finances: $e');
      return {
        'coutAlimentation': 0.0,
        'recettes': 0.0,
        'benefice': 0.0,
        'depensesMensuelles': 0.0,
        'alimentsEnAlerte': 0.0,
      };
    }
  }
}
