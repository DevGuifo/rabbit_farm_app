import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../services/notification_consolidator.dart';
import '../models/portee.dart';
import '../models/enums/statut_accouplement.dart';
import '../utils/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service intelligent de notifications automatiques
///
/// Scanne les données, consolide les événements similaires et planifie les notifications.
/// Implémente la logique "Moins mais Mieux" de l'audit UX 2026.
class SmartNotificationService {
  static final SmartNotificationService _instance =
      SmartNotificationService._internal();
  factory SmartNotificationService() => _instance;
  SmartNotificationService._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService();
  final NotificationConsolidator _consolidator = NotificationConsolidator();

  bool _isInitialized = false;

  /// Initialiser le service
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _notificationService.initialize();
    _isInitialized = true;
    logger.info('✅ SmartNotificationService initialisé (Mode Consolidé)');
  }

  /// Scanner, consolider et planifier toutes les notifications
  Future<void> scanAndScheduleAllNotifications() async {
    if (!_isInitialized) await initialize();

    try {
      logger.info('🔄 Début du scan et consolidation des notifications...');

      // 1. Collecte des événements bruts
      await _processAccouplements();
      await _processPortees();
      await _processSoins();

      // 2. Traitement des pesées avec consolidation
      await _processPeseesConsolidees();

      // 3. Traitement des stocks avec consolidation
      await _processStocksConsolides();

      logger.info('✅ Scan et planification terminés');
    } catch (e, stackTrace) {
      logger.error(
        '❌ Erreur lors du smart scan des notifications',
        e,
        stackTrace,
      );
    }
  }

  /// Traiter les accouplements (Mise bas, Palpation, Nid)
  Future<void> _processAccouplements() async {
    try {
      final accouplements = await _db.getAllAccouplements();
      int count = 0;

      for (final accouplement in accouplements) {
        if (accouplement.statut != StatutAccouplement.enAttente &&
            accouplement.statut != StatutAccouplement.confirme) {
          continue;
        }
        if (accouplement.id == null) continue;

        final femelle = await _db.getLapinById(accouplement.femelleId);
        if (femelle == null) continue;

        // A. Palpation (J+11)
        final datePalpation = accouplement.dateAccouplement.add(
          const Duration(days: 11),
        );
        if (datePalpation.isAfter(DateTime.now())) {
          await _notificationService.planifierRappelPalpation(
            accouplementId: accouplement.id!,
            dateAccouplement: accouplement.dateAccouplement,
            nomFemelle: femelle.nom,
          );
          count++;
        }

        // B. Préparation Nid (J+28)
        final dateNid = accouplement.dateAccouplement.add(
          const Duration(days: 28),
        );
        if (dateNid.isAfter(DateTime.now())) {
          await _notificationService.planifierRappelNid(
            accouplementId: accouplement.id!,
            dateAccouplement: accouplement.dateAccouplement,
            nomFemelle: femelle.nom,
          );
          count++;
        }

        // C. Mise Bas Jour J (Matin 8h)
        // Note: Suppression du rappel J-3 (anxiogène) selon audit UX
        if (accouplement.dateMiseBasPrevue.isAfter(DateTime.now()) &&
            accouplement.dateMiseBasPrevue.difference(DateTime.now()).inDays <=
                30) {
          // On planifie le jour même à 8h00
          await _scheduleMiseBasDayNotification(
            accouplementId: accouplement.id!,
            dateMiseBas: accouplement.dateMiseBasPrevue,
            nomFemelle: femelle.nom,
          );
          count++;
        }
      }
      logger.info('🐰 $count notifications reproduction planifiées');
    } catch (e) {
      logger.error('❌ Erreur process accouplements: $e');
    }
  }

  /// Traiter les portées (Sevrage, Pesées Portée)
  Future<void> _processPortees() async {
    try {
      final portees = await _db.getAllPortees();
      int count = 0;

      for (final portee in portees) {
        if (portee.id == null) continue;

        // Sevrage à 35 jours
        final dateSevrage = portee.dateMiseBasReelle.add(
          const Duration(days: 35),
        );
        if (dateSevrage.isAfter(DateTime.now())) {
          await _scheduleSevrageNotification(
            porteeId: portee.id!,
            dateSevrage: dateSevrage,
            portee: portee,
          );
          count++;
        }

        // Pesées hebdo des lapereaux (Jusqu'à 5 semaines)
        // On ne consolide pas encore celles-ci car liées à une portée spécifique
        await _scheduleWeeklyPeseeForPortee(portee);
      }
      logger.info('🍼 $count notifications sevrage planifiées');
    } catch (e) {
      logger.error('❌ Erreur process portées: $e');
    }
  }

  /// Traiter les soins individuels (Vaccins, Traitements)
  Future<void> _processSoins() async {
    try {
      final soins = await _db.getAllSoins();
      int count = 0;

      for (final soin in soins) {
        if (soin.id == null) continue;

        // Rappel programmé
        if (soin.dateRappel != null &&
            soin.dateRappel!.isAfter(DateTime.now())) {
          final lapin = await _db.getLapinById(soin.lapinId);
          if (lapin != null) {
            await _notificationService.planifierRappelSoin(
              soinId: soin.id!,
              dateRappel: soin.dateRappel!,
              nomLapin: lapin.nom,
              typeSoin: soin.type.label,
            );
            count++;
          }
        }

        // Rappel annuel Vaccin
        if (soin.type.label.toLowerCase().contains('vaccin')) {
          final dateRappelAn = soin.date.add(const Duration(days: 365));
          if (dateRappelAn.isAfter(DateTime.now())) {
            final lapin = await _db.getLapinById(soin.lapinId);
            if (lapin != null) {
              await _notificationService.planifierRappelSoin(
                soinId: soin.id!,
                dateRappel: dateRappelAn,
                nomLapin: lapin.nom,
                typeSoin: 'Rappel Vaccin An',
              );
            }
          }
        }
      }
      logger.info('💉 $count notifications soins planifiées');
    } catch (e) {
      logger.error('❌ Erreur process soins: $e');
    }
  }

  /// Traiter les pesées avec consolidation
  Future<void> _processPeseesConsolidees() async {
    try {
      // 1. Récupérer toutes les pesées à faire
      final peseesEnAttente = await _consolidator.getPeseesEnAttente();

      // 2. Tenter la consolidation
      final consolidatedNotif = await _consolidator.consoliderPesees(
        peseesEnAttente,
      );

      if (consolidatedNotif != null) {
        // --- CAS CONSOLIDÉ ---
        // On planifie une seule notification résumé pour DEMAIN MATIN (ou aujourd'hui si tôt)
        // Pour simplifier, on la met à 9h00 le jour de la prochaine échéance la plus proche
        final dateCible = peseesEnAttente
            .map((p) => p.datePrevue)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        final dateNotif = DateTime(
          dateCible.year,
          dateCible.month,
          dateCible.day,
          9,
          0,
        ); // 9h00 digest

        if (dateNotif.isAfter(DateTime.now())) {
          await _notificationService.planifierNotification(
            notificationId: 888000, // ID fixe pour le digest pesée
            titre: consolidatedNotif.titre,
            corps: consolidatedNotif.corps,
            date: dateNotif,
            payload: consolidatedNotif.payload,
            channelId: 'pesee_channel',
            channelName: 'Rappels Pesées',
            importance: Importance.defaultImportance,
          );
          logger.info(
            '⚖️ NOTIFICATION CONSOLIDÉE: ${peseesEnAttente.length} pesées -> 1 notif',
          );
        }
      } else {
        // --- CAS INDIVIDUEL (Pas assez pour consolider) ---
        for (final p in peseesEnAttente) {
          await _notificationService.planifierRappelPeseeHebdomadaire(
            lapinId: p.lapinId,
            nomLapin: p.nomLapin,
            dateDernierePesee: p.datePrevue.subtract(const Duration(days: 7)),
          );
        }
        logger.info(
          '⚖️ ${peseesEnAttente.length} notifications pesées individuelles (sous seuil)',
        );
      }
    } catch (e) {
      logger.error('❌ Erreur process pesées: $e');
    }
  }

  /// Traiter les stocks avec consolidation
  Future<void> _processStocksConsolides() async {
    try {
      final stocksFaibles = await _consolidator.getStocksFaibles();
      final consolidatedNotif = await _consolidator.consoliderStocks(
        stocksFaibles,
      );

      if (consolidatedNotif != null) {
        // Notification stock : on la met à 18h00 (après le travail)
        final now = DateTime.now();
        var dateNotif = DateTime(now.year, now.month, now.day, 18, 0);
        if (dateNotif.isBefore(now)) {
          dateNotif = dateNotif.add(const Duration(days: 1));
        }

        await _notificationService.planifierNotification(
          notificationId: 999000, // ID fixe pour stock
          titre: consolidatedNotif.titre,
          corps: consolidatedNotif.corps,
          date: dateNotif,
          payload: consolidatedNotif.payload,
          channelId: 'stock_channel',
          channelName: 'Alertes Stocks',
          importance: Importance.defaultImportance,
        );
        logger.info(
          '📦 NOTIFICATION CONSOLIDÉE: ${stocksFaibles.length} produits -> 1 notif',
        );
      }
    } catch (e) {
      logger.error('❌ Erreur process stocks: $e');
    }
  }

  // === Helpers privés ===

  Future<void> _scheduleMiseBasDayNotification({
    required int accouplementId,
    required DateTime dateMiseBas,
    required String nomFemelle,
  }) async {
    // 8h00 le jour J
    final scheduledDate = DateTime(
      dateMiseBas.year,
      dateMiseBas.month,
      dateMiseBas.day,
      8,
      0,
    );
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notificationService.planifierNotification(
      notificationId: 500000 + accouplementId,
      titre: '🐰 C\'est le jour J !', // Wording amélioré
      corps: 'Mise bas prévue pour $nomFemelle. Préparez le calme.',
      date: scheduledDate,
      payload: 'mise_bas_jour:$accouplementId',
      channelId: 'mise_bas_channel',
      channelName: 'Mise bas',
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  Future<void> _scheduleSevrageNotification({
    required int porteeId,
    required DateTime dateSevrage,
    required Portee portee,
  }) async {
    // Rappel le matin du sevrage
    final dateRappel = DateTime(
      dateSevrage.year,
      dateSevrage.month,
      dateSevrage.day,
      9,
      0,
    );
    if (dateRappel.isBefore(DateTime.now())) return;

    await _notificationService.planifierNotification(
      notificationId: 600000 + porteeId,
      titre: '🍼 L\'heure de l\'indépendance !',
      corps:
          'Sevrage prévu le ${_formatDate(dateSevrage)} pour la portée de ${portee.nombreVivants} lapereaux.',
      date: dateRappel,
      payload: 'sevrage:$porteeId',
      channelId: 'sevrage_channel',
      channelName: 'Sevrage',
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  Future<void> _scheduleWeeklyPeseeForPortee(Portee portee) async {
    if (portee.id == null) return;
    for (int semaine = 1; semaine <= 5; semaine++) {
      final datePesee = portee.dateMiseBasReelle.add(
        Duration(days: 7 * semaine),
      );
      // Rappel à 10h le jour de la pesée
      final dateRappel = DateTime(
        datePesee.year,
        datePesee.month,
        datePesee.day,
        10,
        0,
      );

      if (dateRappel.isBefore(DateTime.now())) continue;

      await _notificationService.planifierNotification(
        notificationId: 700000 + (portee.id! * 10) + semaine,
        titre: '⚖️ Pesée Portée - Semaine $semaine',
        corps: 'Pesée des ${portee.nombreVivants} lapereaux.',
        date: dateRappel,
        payload: 'pesee_portee:${portee.id}',
        channelId: 'pesee_channel',
        channelName: 'Pesée Portée',
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
