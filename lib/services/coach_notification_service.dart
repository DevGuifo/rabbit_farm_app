import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/journal_entry.dart';
import '../utils/logger.dart';
import 'notification_service.dart';
import 'journal_service.dart';
import 'database_helper.dart';

/// Service de notifications comportementales
///
/// Transforme les notifications en coach quotidien :
/// - Max 3 notifications par jour
/// - Pas de notification si tout est à jour
/// - Chaque réponse génère une trace
class CoachNotificationService {
  static final CoachNotificationService _instance =
      CoachNotificationService._internal();
  factory CoachNotificationService() => _instance;
  CoachNotificationService._internal();

  final NotificationService _notificationService = NotificationService();
  final JournalService _journal = JournalService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Constantes
  static const int _maxNotificationsParJour = 3;
  static const String _keyNotifCount = 'coach_notif_count_';
  static const String _keyVerifMatinDone = 'coach_verif_matin_done_';

  // IDs de notifications coach
  static const int idVerifMatin = 9000;
  static const int idRappelMidi = 9001;
  static const int idBilanSoir = 9002;

  // ============= GESTION QUOTAS =============

  /// Obtenir le nombre de notifications envoyées aujourd'hui
  Future<int> _getNotifCountToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return prefs.getInt('$_keyNotifCount$today') ?? 0;
  }

  /// Incrémenter le compteur de notifications
  Future<void> _incrementNotifCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final current = prefs.getInt('$_keyNotifCount$today') ?? 0;
    await prefs.setInt('$_keyNotifCount$today', current + 1);
  }

  /// Vérifier si on peut encore envoyer une notification
  Future<bool> peutEnvoyerNotification() async {
    final count = await _getNotifCountToday();
    return count < _maxNotificationsParJour;
  }

  /// Vérifier si la vérification du matin a déjà été faite
  Future<bool> verificationMatinFaite() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return prefs.getBool('$_keyVerifMatinDone$today') ?? false;
  }

  /// Marquer la vérification du matin comme faite
  Future<void> _marquerVerificationMatinFaite() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setBool('$_keyVerifMatinDone$today', true);
  }

  // ============= NOTIFICATION VERIFICATION MATIN =============

  /// Planifier la notification "Vérification du matin" pour 7h
  Future<void> planifierVerificationMatin() async {
    // Vérifier si déjà fait aujourd'hui
    if (await verificationMatinFaite()) {
      logger.info(
        '📵 Vérification matin déjà faite aujourd\'hui, pas de notification',
      );
      return;
    }

    // Vérifier quota
    if (!await peutEnvoyerNotification()) {
      logger.info(
        '📵 Quota notifications atteint ($_maxNotificationsParJour/jour)',
      );
      return;
    }

    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 7, 0);

    // Si 7h est passé, planifier pour demain
    if (now.isAfter(scheduledTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notificationService.flutterNotifications.zonedSchedule(
      idVerifMatin,
      '🌅 Vérification du matin',
      'As-tu observé ton élevage ce matin ?',
      tzScheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'coach_channel',
          'Coach Quotidien',
          channelDescription: 'Notifications de coaching quotidien',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: const BigTextStyleInformation(
            'Prends quelques minutes pour observer tes lapins.\n'
            'Un éleveur attentif = un élevage en bonne santé ! 🐰',
          ),
          actions: const [
            AndroidNotificationAction(
              'verif_ok',
              '✅ Oui, tout normal',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              'verif_probleme',
              '⚠️ J\'ai vu un problème',
              showsUserInterface: true,
            ),
            AndroidNotificationAction('verif_later', '⏰ Plus tard'),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          categoryIdentifier: 'verif_quotidienne',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Répéter chaque jour
      payload: 'coach:$idVerifMatin', // Payload pour le handler
    );

    logger.info(
      '🌅 Notification vérification matin planifiée pour ${scheduledTime.hour}h',
    );
  }

  /// Envoyer immédiatement la notification rituel matin (pour test)
  Future<void> envoyerVerificationMatinMaintenant() async {
    // Vérifier si déjà fait
    if (await verificationMatinFaite()) {
      logger.info('📵 Rituel matin déjà fait aujourd\'hui');
      return;
    }

    // Vérifier quota
    if (!await peutEnvoyerNotification()) {
      logger.info('📵 Quota notifications atteint');
      return;
    }

    await _notificationService.flutterNotifications.show(
      idVerifMatin,
      '🌅 Vérification du matin',
      'As-tu observé ton élevage ce matin ?',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'coach_channel',
          'Coach Quotidien',
          channelDescription: 'Notifications de coaching quotidien',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: const BigTextStyleInformation(
            'Prends quelques minutes pour observer tes lapins.\n'
            'Un éleveur attentif = un élevage en bonne santé ! 🐰',
          ),
          actions: const [
            AndroidNotificationAction(
              'verif_ok',
              '✅ Oui, tout normal',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              'verif_probleme',
              '⚠️ J\'ai vu un problème',
              showsUserInterface: true,
            ),
            AndroidNotificationAction('verif_later', '⏰ Plus tard'),
          ],
        ),
      ),
      payload: 'coach:$idVerifMatin',
    );

    await _incrementNotifCount();
    logger.info('🌅 Notification rituel matin envoyée');
  }

  // ============= HANDLERS DE RÉPONSE =============

  /// Traiter la réponse à une notification coach
  Future<void> handleResponse(String actionId, int notificationId) async {
    logger.info(
      '🎯 Coach response: $actionId pour notification $notificationId',
    );

    switch (actionId) {
      case 'verif_ok':
        await _handleVerifOk();
        break;
      case 'verif_probleme':
        await _handleVerifProbleme();
        break;
      case 'verif_later':
        await _handleVerifLater();
        break;
      case 'suivi_resolu':
        await _handleSuiviResolu();
        break;
      case 'suivi_encours':
        await _handleSuiviEncours();
        break;
      case 'suivi_aide':
        await _handleSuiviAide();
        break;
      default:
        logger.warning('⚠️ Action coach inconnue: $actionId');
    }
  }

  /// Réponse: "Oui, tout est normal"
  Future<void> _handleVerifOk() async {
    // Marquer comme fait
    await _marquerVerificationMatinFaite();

    // Enregistrer dans le journal
    await _journal.enregistrer(
      typeEntite: TypeEntite.verification,
      typeAction: TypeAction.validation,
      entiteNom: 'Observation matinale',
      resumeAuto: 'Observation matinale validée - Tout normal',
      statut: StatutEvenement.succes,
      contexte: {
        'reponse': 'tout_normal',
        'heure': DateTime.now().toIso8601String(),
      },
    );

    // Mettre à jour le rituel du jour si existe
    await _updateVerificationJour(true);

    logger.info('✅ Rituel matin: Tout normal enregistré');
  }

  /// Réponse: "J'ai vu un problème"
  Future<void> _handleVerifProbleme() async {
    // Marquer comme fait (même si problème, l'observation est faite)
    await _marquerVerificationMatinFaite();

    // Enregistrer dans le journal avec statut anomalie
    await _journal.enregistrer(
      typeEntite: TypeEntite.verification,
      typeAction: TypeAction.observation,
      entiteNom: 'Observation matinale',
      resumeAuto: 'Observation matinale - Problème signalé',
      statut: StatutEvenement.action,
      contexte: {
        'reponse': 'probleme_vu',
        'heure': DateTime.now().toIso8601String(),
        'action_requise': 'Détailler le problème dans l\'app',
      },
    );

    // Mettre à jour le rituel avec anomalie
    await _updateVerificationJour(false);

    // Planifier un rappel de suivi dans 2h
    await _planifierRappelSuivi();

    logger.info('⚠️ Rituel matin: Problème signalé');
  }

  /// Réponse: "Plus tard"
  Future<void> _handleVerifLater() async {
    // Ne PAS marquer comme fait

    // Enregistrer dans le journal
    await _journal.enregistrer(
      typeEntite: TypeEntite.verification,
      typeAction: TypeAction.rappel,
      entiteNom: 'Observation matinale',
      resumeAuto: 'Observation reportée',
      statut: StatutEvenement.info,
      contexte: {
        'reponse': 'reporter',
        'heure': DateTime.now().toIso8601String(),
      },
    );

    // Planifier un rappel dans 1h (si quota OK)
    if (await peutEnvoyerNotification()) {
      await _planifierRappelDansUneHeure();
    }

    logger.info('⏰ Rituel matin: Reporté');
  }

  /// Réponse suivi: "Résolu"
  Future<void> _handleSuiviResolu() async {
    await _journal.enregistrer(
      typeEntite: TypeEntite.verification,
      typeAction: TypeAction.validation,
      entiteNom: 'Suivi problème',
      resumeAuto: 'Problème résolu par l\'éleveur',
      statut: StatutEvenement.succes,
      contexte: {
        'reponse': 'resolu',
        'heure': DateTime.now().toIso8601String(),
      },
    );
    logger.info('✅ Suivi: Problème résolu');
  }

  /// Réponse suivi: "En cours"
  Future<void> _handleSuiviEncours() async {
    await _journal.enregistrer(
      typeEntite: TypeEntite.verification,
      typeAction: TypeAction.observation,
      entiteNom: 'Suivi problème',
      resumeAuto: 'Problème en cours de résolution',
      statut: StatutEvenement.action,
      contexte: {
        'reponse': 'en_cours',
        'heure': DateTime.now().toIso8601String(),
      },
    );
    logger.info('🔄 Suivi: En cours de résolution');
  }

  /// Réponse suivi: "Besoin d'aide"
  Future<void> _handleSuiviAide() async {
    await _journal.enregistrer(
      typeEntite: TypeEntite.verification,
      typeAction: TypeAction.alerte,
      entiteNom: 'Suivi problème',
      resumeAuto: 'L\'éleveur demande de l\'aide',
      statut: StatutEvenement.anomalie,
      contexte: {
        'reponse': 'besoin_aide',
        'heure': DateTime.now().toIso8601String(),
        'action_requise': 'Consulter un vétérinaire ou expert',
      },
    );
    logger.info('❓ Suivi: Besoin d\'aide signalé');
  }

  /// Planifier un rappel dans 1 heure
  Future<void> _planifierRappelDansUneHeure() async {
    final scheduledTime = DateTime.now().add(const Duration(hours: 1));
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notificationService.flutterNotifications.zonedSchedule(
      idRappelMidi,
      '🔔 Rappel observation',
      'N\'oublie pas d\'observer tes lapins !',
      tzScheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'coach_channel',
          'Coach Quotidien',
          channelDescription: 'Notifications de coaching quotidien',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          actions: const [
            AndroidNotificationAction(
              'verif_ok',
              '✅ C\'est fait',
              showsUserInterface: true,
            ),
            AndroidNotificationAction('verif_later', '⏰ Plus tard'),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'coach:$idRappelMidi',
    );

    await _incrementNotifCount();
    logger.info('🔔 Rappel planifié dans 1h');
  }

  /// Planifier un rappel de suivi après signalement de problème
  Future<void> _planifierRappelSuivi() async {
    if (!await peutEnvoyerNotification()) return;

    final scheduledTime = DateTime.now().add(const Duration(hours: 2));
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notificationService.flutterNotifications.zonedSchedule(
      idBilanSoir,
      '🔍 Suivi du problème',
      'As-tu pu résoudre le problème observé ce matin ?',
      tzScheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'coach_channel',
          'Coach Quotidien',
          channelDescription: 'Notifications de coaching quotidien',
          importance: Importance.high,
          priority: Priority.high,
          actions: const [
            AndroidNotificationAction(
              'suivi_resolu',
              '✅ Résolu',
              showsUserInterface: true,
            ),
            AndroidNotificationAction('suivi_encours', '🔄 En cours'),
            AndroidNotificationAction(
              'suivi_aide',
              '❓ Besoin d\'aide',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'coach:$idBilanSoir',
    );

    await _incrementNotifCount();
    logger.info('🔍 Rappel suivi planifié dans 2h');
  }

  // ============= MISE À JOUR RITUELS =============

  /// Mettre à jour le rituel du jour
  Future<void> _updateVerificationJour(bool toutNormal) async {
    try {
      final today = DateTime.now();
      final dateStr = DateTime(
        today.year,
        today.month,
        today.day,
      ).toIso8601String().substring(0, 10);

      // Chercher le rituel du matin pour aujourd'hui
      final db = await _db.database;
      final rituels = await db.query(
        'rituels',
        where: 'date LIKE ? AND type = ?',
        whereArgs: ['$dateStr%', 'matin'],
        limit: 1,
      );

      if (rituels.isNotEmpty) {
        final tacheId = rituels.first['id'] as int;

        // Mettre à jour comme complété
        await db.update(
          'rituels',
          {'date_completion': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [tacheId],
        );

        logger.info('📋 Rituel matin mis à jour (ID: $tacheId)');
      }
    } catch (e) {
      logger.error('❌ Erreur mise à jour rituel: $e');
    }
  }

  // ============= VÉRIFICATION INTELLIGENTE =============

  /// Vérifier si une notification est nécessaire
  ///
  /// Retourne false si:
  /// - Le rituel est déjà fait
  /// - Le quota est atteint
  /// - Il n'y a rien de nouveau à signaler
  Future<bool> notificationNecessaire() async {
    // Rituel déjà fait ?
    if (await verificationMatinFaite()) {
      return false;
    }

    // Quota atteint ?
    if (!await peutEnvoyerNotification()) {
      return false;
    }

    return true;
  }

  /// Annuler toutes les notifications coach en attente
  Future<void> annulerToutesNotificationsCoach() async {
    await _notificationService.flutterNotifications.cancel(idVerifMatin);
    await _notificationService.flutterNotifications.cancel(idRappelMidi);
    await _notificationService.flutterNotifications.cancel(idBilanSoir);
    logger.info('🚫 Toutes les notifications coach annulées');
  }

  /// Obtenir les statistiques de coaching
  Future<Map<String, dynamic>> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    return {
      'notificationsAujourdhui': prefs.getInt('$_keyNotifCount$today') ?? 0,
      'maxParJour': _maxNotificationsParJour,
      'verificationMatinFaite': await verificationMatinFaite(),
      'peutEnvoyerNotif': await peutEnvoyerNotification(),
    };
  }
}
