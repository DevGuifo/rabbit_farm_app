import '../services/database_helper.dart';
import '../services/kpi_service.dart';
import '../models/kpi_history_entry.dart';
import '../utils/logger.dart';

/// Service pour gérer l'historique des KPIs (Phase 4)
/// Enregistre automatiquement les KPIs quotidiens pour graphiques de tendance
class KpiHistoryService {
  static final KpiHistoryService _instance = KpiHistoryService._internal();
  factory KpiHistoryService() => _instance;
  KpiHistoryService._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final KpiService _kpiService = KpiService();

  /// Enregistrer les KPIs du jour
  /// Appelé automatiquement au démarrage de l'app (1x/jour)
  Future<void> enregistrerKpisQuotidiens() async {
    try {
      final maintenant = DateTime.now();
      final aujourdhui = DateTime(
        maintenant.year,
        maintenant.month,
        maintenant.day,
      );

      // Vérifier si KPIs déjà enregistrés aujourd'hui
      final dernierMortalite = await _db.getLatestKpiEntry('mortalite');
      if (dernierMortalite != null) {
        final derniereMaj = DateTime(
          dernierMortalite.date.year,
          dernierMortalite.date.month,
          dernierMortalite.date.day,
        );

        if (derniereMaj.isAtSameMomentAs(aujourdhui)) {
          logger.info('📊 KPIs déjà enregistrés aujourd\'hui, skip');
          return;
        }
      }

      // Calculer les KPIs actuels
      final kpis = await _kpiService.calculerTousLesKpis();

      // Préparer batch d'entrées
      final entries = <KpiHistoryEntry>[
        // Santé
        KpiHistoryEntry(
          date: aujourdhui,
          kpiName: 'mortalite',
          value: kpis.tauxMortalite,
        ),
        KpiHistoryEntry(
          date: aujourdhui,
          kpiName: 'lapins_malades',
          value: kpis.lapinsMalades.toDouble(),
        ),

        // Performance
        KpiHistoryEntry(date: aujourdhui, kpiName: 'gmq', value: kpis.gmqMoyen),
        KpiHistoryEntry(
          date: aujourdhui,
          kpiName: 'lapins_sous_poids',
          value: kpis.lapinsSousPoids.toDouble(),
        ),

        // Reproduction
        KpiHistoryEntry(
          date: aujourdhui,
          kpiName: 'taux_reproduction',
          value: kpis.tauxReproduction,
        ),
        KpiHistoryEntry(
          date: aujourdhui,
          kpiName: 'taux_sevrage',
          value: kpis.tauxSevrage,
        ),
        KpiHistoryEntry(
          date: aujourdhui,
          kpiName: 'femelles_gestantes',
          value: kpis.femellesGestantes.toDouble(),
        ),

        // Finances
        KpiHistoryEntry(date: aujourdhui, kpiName: 'roi', value: kpis.roi),
        KpiHistoryEntry(
          date: aujourdhui,
          kpiName: 'benefice_mensuel',
          value: kpis.beneficeMensuel,
        ),
        KpiHistoryEntry(
          date: aujourdhui,
          kpiName: 'recettes_mensuelles',
          value: kpis.recettesMensuelles,
        ),
        KpiHistoryEntry(
          date: aujourdhui,
          kpiName: 'depenses_mensuelles',
          value: kpis.depensesMensuelles,
        ),

        // Cheptel
        KpiHistoryEntry(
          date: aujourdhui,
          kpiName: 'total_lapins',
          value: kpis.totalLapins.toDouble(),
        ),
        KpiHistoryEntry(
          date: aujourdhui,
          kpiName: 'lapereaux',
          value: kpis.lapereaux.toDouble(),
        ),
      ];

      // Enregistrer en batch pour performance
      await _db.insertKpiHistoryBatch(entries);

      logger.info(
        '✅ ${entries.length} KPIs enregistrés pour ${aujourdhui.toIso8601String().substring(0, 10)}',
      );

      // Nettoyage : supprimer entrées > 90 jours (garder 3 mois)
      final supprimees = await _db.deleteOldKpiHistory(90);
      if (supprimees > 0) {
        logger.info('🗑️ $supprimees anciennes entrées KPI supprimées (>90j)');
      }
    } catch (e, stackTrace) {
      logger.error('❌ Erreur enregistrement KPIs quotidiens', e, stackTrace);
    }
  }

  /// Charger les données de tendance pour un KPI spécifique
  /// Retourne une liste de Map pour fl_chart
  Future<List<Map<String, dynamic>>> chargerTendanceKpi({
    required String kpiName,
    int jours = 7,
  }) async {
    try {
      final historique = await _db.getKpiHistory(kpiName: kpiName, days: jours);

      if (historique.isEmpty) {
        logger.warning('⚠️ Aucune donnée historique pour $kpiName');
        return [];
      }

      // Convertir en format {date, value} pour graphique
      return historique.map((entry) {
        return {'date': entry.date, 'value': entry.value};
      }).toList();
    } catch (e) {
      logger.error('❌ Erreur chargement tendance $kpiName', e);
      return [];
    }
  }

  /// Initialiser historique avec données rétroactives (optionnel)
  /// Appeler seulement lors du premier lancement Phase 4
  Future<void> initialiserHistoriqueRetroactif() async {
    try {
      // Vérifier si historique existe déjà
      final existant = await _db.getLatestKpiEntry('mortalite');
      if (existant != null) {
        logger.info('📊 Historique KPI déjà initialisé, skip');
        return;
      }

      logger.info('🔄 Initialisation historique KPI rétroactif (7 jours)...');

      // Générer entrées pour les 7 derniers jours avec valeurs actuelles
      // (simulation car pas de vraies données historiques)
      final kpis = await _kpiService.calculerTousLesKpis();
      final maintenant = DateTime.now();

      for (var i = 7; i >= 0; i--) {
        final date = maintenant.subtract(Duration(days: i));
        final jourNormalise = DateTime(date.year, date.month, date.day);

        // Varier légèrement les valeurs pour simuler évolution
        final variation = (i - 3.5) * 0.05; // -17.5% à +17.5%

        await _db.insertKpiHistoryBatch([
          KpiHistoryEntry(
            date: jourNormalise,
            kpiName: 'mortalite',
            value: (kpis.tauxMortalite * (1 + variation)).clamp(0, 100),
          ),
          KpiHistoryEntry(
            date: jourNormalise,
            kpiName: 'gmq',
            value: (kpis.gmqMoyen * (1 - variation)).clamp(0, 100),
          ),
          KpiHistoryEntry(
            date: jourNormalise,
            kpiName: 'roi',
            value: (kpis.roi * (1 + variation * 2)),
          ),
          KpiHistoryEntry(
            date: jourNormalise,
            kpiName: 'taux_reproduction',
            value: (kpis.tauxReproduction * (1 + variation)).clamp(0, 100),
          ),
        ]);
      }

      logger.info('✅ Historique rétroactif initialisé (8 jours)');
    } catch (e, stackTrace) {
      logger.error(
        '❌ Erreur initialisation historique rétroactif',
        e,
        stackTrace,
      );
    }
  }
}
