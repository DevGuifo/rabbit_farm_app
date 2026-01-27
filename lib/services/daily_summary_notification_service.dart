import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../utils/logger.dart';
import 'notification_service.dart';
import 'database_helper.dart';
import '../models/enums/statut_accouplement.dart';
import '../models/notification_priority_ux.dart';

/// Service de notification résumé quotidien
/// Génère une notification unique le matin récapitulant la journée
class DailySummaryNotificationService {
  static final DailySummaryNotificationService _instance =
      DailySummaryNotificationService._internal();
  factory DailySummaryNotificationService() => _instance;
  DailySummaryNotificationService._internal();

  final NotificationService _notificationService = NotificationService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  static const int idResume = 8000;
  static const String _keyLastSummary = 'last_daily_summary_date';

  /// Planifier le résumé quotidien pour 8h
  Future<void> planifierResumQuotidien() async {
    try {
      final now = DateTime.now();
      var scheduledTime = DateTime(now.year, now.month, now.day, 8, 0);

      // Si 8h est passé, planifier pour demain
      if (now.isAfter(scheduledTime)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _notificationService.flutterNotifications.zonedSchedule(
        idResume,
        '🌅 Votre journée d\'éleveur',
        'Consultez vos actions du jour',
        tzScheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_summary_channel',
            'Résumé quotidien',
            channelDescription: 'Récapitulatif des actions de la journée',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // Répéter chaque jour
        payload: 'daily_summary:0',
      );

      logger.info('✅ Résumé quotidien planifié pour 8h');
    } catch (e) {
      logger.error('❌ Erreur planification résumé: $e');
    }
  }

  /// Générer et envoyer le résumé maintenant (pour test ou trigger manuel)
  Future<void> envoyerResumeMaintenant() async {
    try {
      // Vérifier qu'on n'a pas déjà envoyé aujourd'hui
      final prefs = await SharedPreferences.getInstance();
      final lastSummaryDate = prefs.getString(_keyLastSummary);
      final today = DateTime.now().toIso8601String().substring(0, 10);

      if (lastSummaryDate == today) {
        logger.info('📵 Résumé déjà envoyé aujourd\'hui');
        return;
      }

      // Récupérer les actions du jour
      final actions = await _getActionsJour();

      if (actions.isEmpty) {
        logger.info('📵 Aucune action aujourd\'hui, pas de résumé');
        return;
      }

      // Construire le message
      final titre = '🌅 Votre journée d\'éleveur';
      final corps = await _construireMessageResume(actions);

      // Envoyer la notification
      await _notificationService.flutterNotifications.show(
        idResume,
        titre,
        corps,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_summary_channel',
            'Résumé quotidien',
            channelDescription: 'Récapitulatif des actions de la journée',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(''),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'daily_summary:0',
      );

      // Marquer comme envoyé
      await prefs.setString(_keyLastSummary, today);

      logger.info('✅ Résumé quotidien envoyé: ${actions.length} actions');
    } catch (e) {
      logger.error('❌ Erreur envoi résumé: $e');
    }
  }

  /// Récupérer les actions prévues pour aujourd'hui
  Future<List<ActionJour>> _getActionsJour() async {
    final actions = <ActionJour>[];
    final aujourdhui = DateTime.now();

    try {
      // 1. Palpations à faire (J10-12)
      final accouplements = await _db.getAllAccouplements();
      for (final acc in accouplements) {
        if (acc.statut != StatutAccouplement.enAttente && acc.statut != StatutAccouplement.confirme) continue;

        final joursDepuis =
            aujourdhui.difference(acc.dateAccouplement).inDays;
        if (joursDepuis >= 10 && joursDepuis <= 12) {
          final femelle = await _db.getLapinById(acc.femelleId);
          if (femelle != null) {
            actions.add(ActionJour(
              type: TypeActionJour.palpation,
              description: 'Palpation ${femelle.nom}',
              priorite: NotificationPrioriteUX.actionRequise,
            ));
          }
        }
      }

      // 2. Mises bas du jour
      for (final acc in accouplements) {
        if (acc.statut != StatutAccouplement.confirme) continue;

        final joursJusque =
            acc.dateMiseBasPrevue.difference(aujourdhui).inDays;
        if (joursJusque == 0) {
          final femelle = await _db.getLapinById(acc.femelleId);
          if (femelle != null) {
            actions.add(ActionJour(
              type: TypeActionJour.miseBas,
              description: 'Mise bas ${femelle.nom}',
              priorite: NotificationPrioriteUX.urgence,
            ));
          }
        }
      }

      // 3. Sevrages à faire
      final portees = await _db.getAllPortees();
      for (final portee in portees) {
        final joursDepuis =
            aujourdhui.difference(portee.dateMiseBasReelle).inDays;
        if (joursDepuis >= 35 && joursDepuis <= 42) {
          actions.add(ActionJour(
            type: TypeActionJour.sevrage,
            description: 'Sevrage portée #${portee.id}',
            priorite: NotificationPrioriteUX.actionRequise,
          ));
        }
      }

      // 4. Pesées en retard (>7 jours)
      final lapins = await _db.getAllLapins();
      int peseesEnRetard = 0;
      for (final lapin in lapins) {
        if (lapin.statut == 'decede' || lapin.statut == 'vendu') continue;

        final pesees = await _db.getPeseesByLapin(lapin.id!);
        if (pesees.isEmpty) {
          peseesEnRetard++;
        } else {
          pesees.sort((a, b) => b.date.compareTo(a.date));
          final derniere = pesees.first;
          final joursDepuis = aujourdhui.difference(derniere.date).inDays;
          if (joursDepuis > 7) peseesEnRetard++;
        }
      }

      if (peseesEnRetard > 0) {
        actions.add(ActionJour(
          type: TypeActionJour.pesee,
          description: '$peseesEnRetard pesée${peseesEnRetard > 1 ? 's' : ''} en retard',
          priorite: NotificationPrioriteUX.rappel,
        ));
      }

      // 5. Soins avec rappel aujourd'hui
      final soins = await _db.getAllSoins();
      int soinsAFaire = 0;
      for (final soin in soins) {
        if (soin.dateRappel != null) {
          final diff = aujourdhui.difference(soin.dateRappel!).inDays;
          if (diff == 0) soinsAFaire++;
        }
      }

      if (soinsAFaire > 0) {
        actions.add(ActionJour(
          type: TypeActionJour.soin,
          description: '$soinsAFaire soin${soinsAFaire > 1 ? 's' : ''} à faire',
          priorite: NotificationPrioriteUX.actionRequise,
        ));
      }
    } catch (e) {
      logger.error('Erreur récupération actions jour: $e');
    }

    // Trier par priorité
    actions.sort((a, b) => a.priorite.index.compareTo(b.priorite.index));

    return actions;
  }

  /// Construire le message résumé
  Future<String> _construireMessageResume(List<ActionJour> actions) async {
    if (actions.isEmpty) {
      return 'Aucune action prévue aujourd\'hui 🎉';
    }

    final lignes = <String>[];
    lignes.add('Aujourd\'hui :');

    for (final action in actions.take(5)) {
      // Max 5 actions
      final emoji = action.priorite.emoji;
      lignes.add('$emoji ${action.description}');
    }

    if (actions.length > 5) {
      lignes.add('... et ${actions.length - 5} autre${actions.length - 5 > 1 ? 's' : ''}');
    }

    // Ajouter compteur lapins
    final lapins = await _db.getAllLapins();
    final vivants = lapins.where((l) => l.statut != 'decede' && l.statut != 'vendu').length;
    lignes.add('\nTout va bien pour tes $vivants lapins 🐰');

    return lignes.join('\n');
  }
}

/// Type d'action de la journée
enum TypeActionJour {
  palpation,
  miseBas,
  sevrage,
  pesee,
  soin,
}

/// Action de la journée
class ActionJour {
  final TypeActionJour type;
  final String description;
  final NotificationPrioriteUX priorite;

  ActionJour({
    required this.type,
    required this.description,
    required this.priorite,
  });
}
