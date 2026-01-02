import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../models/portee.dart';
import '../models/soin.dart';
import '../utils/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service intelligent de notifications automatiques
/// 
/// Scanne automatiquement les données et planifie toutes les notifications nécessaires :
/// - Accouplements : palpation, préparation nid, mise bas
/// - Portées : sevrage, pesées hebdomadaires des lapereaux
/// - Soins : rappels de vaccinations et traitements
/// - Pesées : rappels hebdomadaires
class SmartNotificationService {
  static final SmartNotificationService _instance =
      SmartNotificationService._internal();
  factory SmartNotificationService() => _instance;
  SmartNotificationService._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService();

  bool _isInitialized = false;

  /// Initialiser le service
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _notificationService.initialize();
    _isInitialized = true;
    logger.info('✅ SmartNotificationService initialisé');
  }

  /// Scanner et planifier toutes les notifications nécessaires
  /// 
  /// Cette méthode doit être appelée :
  /// - Au démarrage de l'application
  /// - Après chaque modification importante (accouplement, portée, soin)
  /// - Périodiquement (tous les jours)
  Future<void> scanAndScheduleAllNotifications() async {
    if (!_isInitialized) await initialize();

    try {
      logger.info('🔄 Début du scan des notifications...');

      // 1. Scanner les accouplements
      await _scanAccouplements();

      // 2. Scanner les portées
      await _scanPortees();

      // 3. Scanner les soins avec rappels
      await _scanSoins();

      // 4. Scanner les pesées pour rappels hebdomadaires
      await _scanPesees();

      logger.info('✅ Scan des notifications terminé');
    } catch (e, stackTrace) {
      logger.error(
        '❌ Erreur lors du scan des notifications',
        e,
        stackTrace,
      );
    }
  }

  /// Scanner les accouplements et planifier les notifications
  Future<void> _scanAccouplements() async {
    try {
      final accouplements = await _db.getAllAccouplements();
      int count = 0;

      for (final accouplement in accouplements) {
        // Seulement pour les accouplements en attente ou confirmés
        if (accouplement.statut != 'en_attente' &&
            accouplement.statut != 'confirme') {
          continue;
        }

        if (accouplement.id == null) continue;

        final femelle = await _db.getLapinById(accouplement.femelleId);
        if (femelle == null) continue;

        // 1. Notification de palpation (10-12 jours après accouplement)
        final datePalpation = accouplement.dateAccouplement
            .add(const Duration(days: 11)); // 11 jours = milieu de la fenêtre
        if (datePalpation.isAfter(DateTime.now())) {
          await _notificationService.planifierRappelPalpation(
            accouplementId: accouplement.id!,
            dateAccouplement: accouplement.dateAccouplement,
            nomFemelle: femelle.nom,
          );
          count++;
        }

        // 2. Notification de préparation du nid (3 jours avant mise bas = 28 jours après accouplement)
        final dateNid = accouplement.dateAccouplement
            .add(const Duration(days: 28));
        if (dateNid.isAfter(DateTime.now())) {
          await _notificationService.planifierRappelNid(
            accouplementId: accouplement.id!,
            dateAccouplement: accouplement.dateAccouplement,
            nomFemelle: femelle.nom,
          );
          count++;
        }

        // 3. Notification de mise bas (3 jours avant la date prévue)
        final dateRappelMiseBas = accouplement.dateMiseBasPrevue
            .subtract(const Duration(days: 3));
        if (dateRappelMiseBas.isAfter(DateTime.now())) {
          await _notificationService.planifierRappelMiseBas(
            accouplementId: accouplement.id!,
            dateMiseBasPrevue: accouplement.dateMiseBasPrevue,
            nomFemelle: femelle.nom,
          );
          count++;
        }

        // 4. Notification du jour de mise bas (le jour même)
        if (accouplement.dateMiseBasPrevue.isAfter(DateTime.now()) &&
            accouplement.dateMiseBasPrevue
                .difference(DateTime.now())
                .inDays <= 1) {
          await _scheduleMiseBasDayNotification(
            accouplementId: accouplement.id!,
            dateMiseBas: accouplement.dateMiseBasPrevue,
            nomFemelle: femelle.nom,
          );
          count++;
        }
      }

      logger.info('✅ $count notifications d\'accouplements planifiées');
    } catch (e) {
      logger.error('❌ Erreur lors du scan des accouplements: $e');
    }
  }

  /// Scanner les portées et planifier les notifications de sevrage
  Future<void> _scanPortees() async {
    try {
      final portees = await _db.getAllPortees();
      int count = 0;

      for (final portee in portees) {
        if (portee.id == null) continue;

        // Calculer la date de sevrage (5-6 semaines = 35-42 jours après mise bas)
        // On planifie à 5 semaines (35 jours) pour rappel
        final dateSevrage = portee.dateMiseBasReelle
            .add(const Duration(days: 35));

        // Seulement si la date de sevrage est dans le futur
        if (dateSevrage.isAfter(DateTime.now())) {
          await _scheduleSevrageNotification(
            porteeId: portee.id!,
            dateSevrage: dateSevrage,
            portee: portee,
          );
          count++;

          // Planifier les pesées hebdomadaires des lapereaux
          // (toutes les semaines jusqu'au sevrage)
          await _scheduleWeeklyPeseeForPortee(portee);
        }
      }

      logger.info('✅ $count notifications de sevrage planifiées');
    } catch (e) {
      logger.error('❌ Erreur lors du scan des portées: $e');
    }
  }

  /// Scanner les soins et planifier les rappels
  Future<void> _scanSoins() async {
    try {
      final soins = await _db.getAllSoins();
      int count = 0;

      for (final soin in soins) {
        if (soin.id == null) continue;

        // Si le soin a une date de rappel
        if (soin.dateRappel != null &&
            soin.dateRappel!.isAfter(DateTime.now())) {
          final lapin = await _db.getLapinById(soin.lapinId);
          if (lapin != null) {
            await _notificationService.planifierRappelSoin(
              soinId: soin.id!,
              dateRappel: soin.dateRappel!,
              nomLapin: lapin.nom,
              typeSoin: soin.type,
            );
            count++;
          }
        }

        // Pour les vaccinations, planifier les rappels annuels
        if (soin.type.toLowerCase().contains('vaccin')) {
          await _scheduleVaccinationReminder(soin);
        }
      }

      logger.info('✅ $count notifications de soins planifiées');
    } catch (e) {
      logger.error('❌ Erreur lors du scan des soins: $e');
    }
  }

  /// Scanner les pesées et planifier les rappels hebdomadaires
  Future<void> _scanPesees() async {
    try {
      final lapins = await _db.getAllLapins();

      for (final lapin in lapins) {
        if (lapin.id == null) continue;

        // Récupérer la dernière pesée
        final allPesees = await _db.getAllPesees();
        final peseesLapin = allPesees
            .where((p) => p.lapinId == lapin.id)
            .toList();
        DateTime? dateDernierePesee;

        if (peseesLapin.isNotEmpty) {
          // Trier par date décroissante
          peseesLapin.sort((a, b) => b.date.compareTo(a.date));
          dateDernierePesee = peseesLapin.first.date;
        }

        // Planifier la prochaine pesée hebdomadaire
        await _notificationService.planifierRappelPeseeHebdomadaire(
          lapinId: lapin.id!,
          nomLapin: lapin.nom,
          dateDernierePesee: dateDernierePesee,
        );
      }

      logger.info(
        '✅ Rappels de pesées planifiés pour ${lapins.length} lapins',
      );
    } catch (e) {
      logger.error('❌ Erreur lors du scan des pesées: $e');
    }
  }

  /// Planifier une notification pour le jour de la mise bas
  Future<void> _scheduleMiseBasDayNotification({
    required int accouplementId,
    required DateTime dateMiseBas,
    required String nomFemelle,
  }) async {
    if (!_isInitialized) await initialize();

    // Planifier pour le matin du jour de mise bas (8h)
    final scheduledDate = DateTime(
      dateMiseBas.year,
      dateMiseBas.month,
      dateMiseBas.day,
      8,
      0,
    );

    if (scheduledDate.isBefore(DateTime.now())) return;

    // ID unique pour le jour de mise bas (offset de 500000)
    await _notificationService.planifierNotification(
      notificationId: 500000 + accouplementId,
      titre: '🐰 Mise bas prévue aujourd\'hui',
      corps: 'La femelle $nomFemelle devrait mettre bas aujourd\'hui',
      date: scheduledDate,
      payload: 'mise_bas_jour:$accouplementId',
      channelId: 'mise_bas_channel',
      channelName: 'Rappels de mise bas',
      channelDescription: 'Notifications pour les mises bas prévues',
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  /// Planifier une notification de sevrage
  Future<void> _scheduleSevrageNotification({
    required int porteeId,
    required DateTime dateSevrage,
    required Portee portee,
  }) async {
    if (!_isInitialized) await initialize();

    // Planifier 2 jours avant le sevrage
    final dateRappel = dateSevrage.subtract(const Duration(days: 2));

    if (dateRappel.isBefore(DateTime.now())) return;

    // ID unique pour les sevrages (offset de 600000)
    await _notificationService.planifierNotification(
      notificationId: 600000 + porteeId,
      titre: '🍼 Rappel de sevrage',
      corps: 'Sevrage prévu le ${_formatDate(dateSevrage)} pour ${portee.nombreVivants} lapereaux',
      date: dateRappel,
      payload: 'sevrage:$porteeId',
      channelId: 'sevrage_channel',
      channelName: 'Rappels de sevrage',
      channelDescription: 'Notifications pour les sevrages à effectuer',
      importance: Importance.high,
      priority: Priority.high,
    );

    logger.info(
      '✅ Notification de sevrage planifiée pour le ${_formatDate(dateSevrage)}',
    );
  }

  /// Planifier les pesées hebdomadaires pour une portée
  Future<void> _scheduleWeeklyPeseeForPortee(Portee portee) async {
    if (portee.id == null) return;

    // Planifier une pesée chaque semaine pendant 5 semaines (jusqu'au sevrage)
    for (int semaine = 1; semaine <= 5; semaine++) {
      final datePesee = portee.dateMiseBasReelle
          .add(Duration(days: 7 * semaine));

      if (datePesee.isBefore(DateTime.now())) continue;

      // ID unique pour les pesées de portée (offset de 700000)
      await _notificationService.planifierNotification(
        notificationId: 700000 + (portee.id! * 10) + semaine,
        titre: '⚖️ Pesée hebdomadaire - Semaine $semaine',
        corps: 'Pesée des lapereaux de la portée (${portee.nombreVivants} lapereaux)',
        date: datePesee,
        payload: 'pesee_portee:${portee.id}',
        channelId: 'pesee_channel',
        channelName: 'Rappels de pesées',
        channelDescription: 'Notifications pour les pesées régulières',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
    }
  }

  /// Planifier un rappel de vaccination annuel
  Future<void> _scheduleVaccinationReminder(Soin soin) async {
    if (soin.id == null) return;

    // Planifier un rappel 1 an après la vaccination
    final dateRappel = soin.date.add(const Duration(days: 365));

    if (dateRappel.isBefore(DateTime.now())) return;

    final lapin = await _db.getLapinById(soin.lapinId);
    if (lapin == null) return;

    await _notificationService.planifierRappelSoin(
      soinId: soin.id!,
      dateRappel: dateRappel,
      nomLapin: lapin.nom,
      typeSoin: 'Rappel de vaccination',
    );
  }

  /// Formater une date
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

