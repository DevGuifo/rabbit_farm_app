import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../utils/logger.dart';
import 'navigation_service.dart';
import '../screens/reproduction/reproduction_screen.dart';
import '../screens/sante/fiche_sante_screen.dart';
import '../screens/cheptel/lapin_detail_screen.dart';
import 'database_helper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialiser le service de notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialiser les fuseaux horaires
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));

    // Configuration pour Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Configuration pour iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialiser
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Demander les permissions pour Android 13+
    await _requestPermissions();

    _isInitialized = true;
    logger.info('✅ Service de notifications initialisé');
  }

  /// Demander les permissions de notification
  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// Callback quand une notification est tapée
  void _onNotificationTapped(NotificationResponse response) async {
    final payload = response.payload;
    logger.debug('Notification tapée: $payload');

    if (payload == null || payload.isEmpty) return;

    try {
      // Parser le payload (format: "type:id")
      final parts = payload.split(':');
      if (parts.length != 2) {
        logger.warning('Format de payload invalide: $payload');
        return;
      }

      final type = parts[0];
      final id = int.tryParse(parts[1]);

      if (id == null) {
        logger.warning('ID invalide dans le payload: $payload');
        return;
      }

      final context = navigationService.currentContext;
      if (context == null) {
        logger.warning('Contexte de navigation non disponible');
        return;
      }

      // Navigation selon le type de notification
      switch (type) {
        case 'mise_bas':
          // Naviguer vers l'écran de reproduction
          logger.debug('Navigation vers reproduction pour accouplement $id');
          navigationService.navigateTo(const ReproductionScreen());
          break;

        case 'soin':
          // Récupérer le lapin associé au soin et naviguer vers sa fiche santé
          logger.debug('Navigation vers fiche santé pour soin $id');
          final soin = await DatabaseHelper.instance.getSoinById(id);
          if (soin != null) {
            final lapin = await DatabaseHelper.instance.getLapinById(
              soin.lapinId,
            );
            if (lapin != null) {
              navigationService.navigateTo(FicheSanteScreen(lapin: lapin));
            }
          }
          break;

        case 'alerte':
          // Naviguer vers la fiche du lapin concerné
          logger.debug('Navigation vers fiche lapin pour alerte $id');
          final lapin = await DatabaseHelper.instance.getLapinById(id);
          if (lapin != null) {
            navigationService.navigateTo(LapinDetailScreen(lapin: lapin));
          }
          break;

        case 'palpation':
          // Naviguer vers l'écran de reproduction
          logger.debug('Navigation vers reproduction pour palpation $id');
          navigationService.navigateTo(const ReproductionScreen());
          break;

        case 'nid':
          // Naviguer vers l'écran de reproduction
          logger.debug('Navigation vers reproduction pour préparation nid $id');
          navigationService.navigateTo(const ReproductionScreen());
          break;

        case 'mise_bas_jour':
          // Naviguer vers l'écran de reproduction
          logger.debug('Navigation vers reproduction pour mise bas aujourd\'hui $id');
          navigationService.navigateTo(const ReproductionScreen());
          break;

        case 'sevrage':
          // Naviguer vers l'écran d'optimisation (sevrage)
          logger.debug('Navigation vers sevrage pour portée $id');
          // Import nécessaire : import '../screens/optimisation/sevrage_screen.dart';
          navigationService.navigateTo(const ReproductionScreen());
          break;

        case 'pesee':
          // Naviguer vers la fiche santé du lapin
          logger.debug('Navigation vers fiche santé pour pesée $id');
          final lapin = await DatabaseHelper.instance.getLapinById(id);
          if (lapin != null) {
            navigationService.navigateTo(FicheSanteScreen(lapin: lapin));
          }
          break;

        case 'pesee_portee':
          // Naviguer vers l'écran de reproduction
          logger.debug('Navigation vers reproduction pour pesée portée $id');
          navigationService.navigateTo(const ReproductionScreen());
          break;

        default:
          logger.warning('Type de notification inconnu: $type');
      }
    } catch (e, stackTrace) {
      logger.error(
        'Erreur lors du traitement de la notification',
        e,
        stackTrace,
      );
    }
  }

  /// Planifier une notification pour une mise bas
  Future<void> planifierRappelMiseBas({
    required int accouplementId,
    required DateTime dateMiseBasPrevue,
    required String nomFemelle,
  }) async {
    if (!_isInitialized) await initialize();

    // Calculer la date de rappel (3 jours avant)
    final dateRappel = dateMiseBasPrevue.subtract(const Duration(days: 3));

    // Ne pas planifier si la date est déjà passée
    if (dateRappel.isBefore(DateTime.now())) {
      logger.warning(
        '⚠️ Date de rappel déjà passée pour l\'accouplement $accouplementId',
      );
      return;
    }

    final scheduledDate = tz.TZDateTime.from(dateRappel, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'mise_bas_channel',
      'Rappels de mise bas',
      channelDescription: 'Notifications pour les mises bas prévues',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      accouplementId, // ID unique basé sur l'accouplement
      '🐰 Mise bas prévue dans 3 jours',
      'La femelle $nomFemelle devrait mettre bas le ${_formatDate(dateMiseBasPrevue)}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'mise_bas:$accouplementId',
    );

    logger.info(
      '✅ Rappel planifié pour $nomFemelle le ${_formatDate(dateRappel)}',
    );
  }

  /// Planifier une notification pour un soin avec rappel
  Future<void> planifierRappelSoin({
    required int soinId,
    required DateTime dateRappel,
    required String nomLapin,
    required String typeSoin,
  }) async {
    if (!_isInitialized) await initialize();

    // Ne pas planifier si la date est déjà passée
    if (dateRappel.isBefore(DateTime.now())) {
      logger.warning('⚠️ Date de rappel déjà passée pour le soin $soinId');
      return;
    }

    final scheduledDate = tz.TZDateTime.from(dateRappel, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'soin_channel',
      'Rappels de soins',
      channelDescription: 'Notifications pour les soins à effectuer',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Utiliser un ID unique pour les soins (offset de 100000)
    await _notifications.zonedSchedule(
      100000 + soinId,
      '💉 Rappel de soin',
      '$nomLapin - $typeSoin le ${_formatDate(dateRappel)}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'soin:$soinId',
    );

    logger.info(
      '✅ Rappel de soin planifié pour $nomLapin le ${_formatDate(dateRappel)}',
    );
  }

  /// Planifier une notification pour la palpation (10 jours après accouplement)
  Future<void> planifierRappelPalpation({
    required int accouplementId,
    required DateTime dateAccouplement,
    required String nomFemelle,
  }) async {
    if (!_isInitialized) await initialize();

    // Calculer la date de rappel (10 jours après l'accouplement)
    final dateRappel = dateAccouplement.add(const Duration(days: 10));

    // Ne pas planifier si la date est déjà passée
    if (dateRappel.isBefore(DateTime.now())) {
      logger.warning(
        '⚠️ Date de rappel palpation déjà passée pour l\'accouplement $accouplementId',
      );
      return;
    }

    final scheduledDate = tz.TZDateTime.from(dateRappel, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'reproduction_channel',
      'Rappels de reproduction',
      channelDescription: 'Notifications pour les accouplements et reproductions',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Utiliser un ID unique pour les palpations (offset de 200000)
    await _notifications.zonedSchedule(
      200000 + accouplementId,
      '🔍 Rappel de palpation',
      'Palpation prévue pour $nomFemelle le ${_formatDate(dateRappel)}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'palpation:$accouplementId',
    );

    logger.info(
      '✅ Rappel de palpation planifié pour $nomFemelle le ${_formatDate(dateRappel)}',
    );
  }

  /// Planifier une notification pour la préparation du nid (28 jours après accouplement)
  Future<void> planifierRappelNid({
    required int accouplementId,
    required DateTime dateAccouplement,
    required String nomFemelle,
  }) async {
    if (!_isInitialized) await initialize();

    // Calculer la date de rappel (28 jours après l'accouplement)
    final dateRappel = dateAccouplement.add(const Duration(days: 28));

    // Ne pas planifier si la date est déjà passée
    if (dateRappel.isBefore(DateTime.now())) {
      logger.warning(
        '⚠️ Date de rappel nid déjà passée pour l\'accouplement $accouplementId',
      );
      return;
    }

    final scheduledDate = tz.TZDateTime.from(dateRappel, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'reproduction_channel',
      'Rappels de reproduction',
      channelDescription: 'Notifications pour les accouplements et reproductions',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Utiliser un ID unique pour les nids (offset de 300000)
    await _notifications.zonedSchedule(
      300000 + accouplementId,
      '🏠 Préparation du nid',
      'Préparer le nid pour $nomFemelle le ${_formatDate(dateRappel)}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'nid:$accouplementId',
    );

    logger.info(
      '✅ Rappel de nid planifié pour $nomFemelle le ${_formatDate(dateRappel)}',
    );
  }

  /// Planifier un rappel de pesée hebdomadaire pour un lapin
  Future<void> planifierRappelPeseeHebdomadaire({
    required int lapinId,
    required String nomLapin,
    DateTime? dateDernierePesee,
  }) async {
    if (!_isInitialized) await initialize();

    // Calculer la date de rappel (7 jours après la dernière pesée, ou dans 7 jours si pas de pesée)
    final dateReference = dateDernierePesee ?? DateTime.now();
    final dateRappel = dateReference.add(const Duration(days: 7));

    // Ne pas planifier si la date est déjà passée
    if (dateRappel.isBefore(DateTime.now())) {
      logger.warning(
        '⚠️ Date de rappel pesée déjà passée pour le lapin $lapinId',
      );
      return;
    }

    final scheduledDate = tz.TZDateTime.from(dateRappel, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'pesee_channel',
      'Rappels de pesées',
      channelDescription: 'Notifications pour les pesées régulières',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Utiliser un ID unique pour les pesées (offset de 400000)
    await _notifications.zonedSchedule(
      400000 + lapinId,
      '⚖️ Rappel de pesée',
      'Pesée hebdomadaire pour $nomLapin le ${_formatDate(dateRappel)}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'pesee:$lapinId',
    );

    logger.info(
      '✅ Rappel de pesée planifié pour $nomLapin le ${_formatDate(dateRappel)}',
    );
  }

  /// Annuler une notification de mise bas
  Future<void> annulerRappelMiseBas(int accouplementId) async {
    await _notifications.cancel(accouplementId);
    logger.debug(
      '❌ Rappel de mise bas annulé pour l\'accouplement $accouplementId',
    );
  }

  /// Annuler une notification de palpation
  Future<void> annulerRappelPalpation(int accouplementId) async {
    await _notifications.cancel(200000 + accouplementId);
    logger.debug(
      '❌ Rappel de palpation annulé pour l\'accouplement $accouplementId',
    );
  }

  /// Annuler une notification de nid
  Future<void> annulerRappelNid(int accouplementId) async {
    await _notifications.cancel(300000 + accouplementId);
    logger.debug(
      '❌ Rappel de nid annulé pour l\'accouplement $accouplementId',
    );
  }

  /// Annuler un rappel de pesée
  Future<void> annulerRappelPesee(int lapinId) async {
    await _notifications.cancel(400000 + lapinId);
    logger.debug('❌ Rappel de pesée annulé pour le lapin $lapinId');
  }

  /// Annuler une notification de soin
  Future<void> annulerRappelSoin(int soinId) async {
    await _notifications.cancel(100000 + soinId);
    logger.debug('❌ Rappel de soin annulé pour le soin $soinId');
  }

  /// Annuler toutes les notifications
  Future<void> annulerToutesLesNotifications() async {
    await _notifications.cancelAll();
    logger.info('❌ Toutes les notifications annulées');
  }

  /// Obtenir les notifications en attente
  Future<List<PendingNotificationRequest>> getNotificationsEnAttente() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Afficher une notification immédiate (pour les tests)
  Future<void> afficherNotificationTest() async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test',
      channelDescription: 'Canal de test',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999999,
      '🔔 Notification de test',
      'Le système de notifications fonctionne correctement !',
      details,
    );
  }

  /// Planifier une notification personnalisée
  /// 
  /// Méthode générique pour planifier n'importe quelle notification
  Future<void> planifierNotification({
    required int notificationId,
    required String titre,
    required String corps,
    required DateTime date,
    required String payload,
    String channelId = 'default_channel',
    String channelName = 'Notifications',
    String channelDescription = 'Notifications générales',
    Importance importance = Importance.defaultImportance,
    Priority priority = Priority.defaultPriority,
  }) async {
    if (!_isInitialized) await initialize();

    if (date.isBefore(DateTime.now())) {
      logger.warning('⚠️ Date de notification déjà passée: $date');
      return;
    }

    final scheduledDate = tz.TZDateTime.from(date, tz.local);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: priority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      notificationId,
      titre,
      corps,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    logger.info('✅ Notification planifiée: $titre le ${_formatDate(date)}');
  }

  /// Formater une date
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
