import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../utils/logger.dart';
import 'navigation_service.dart';
import 'notification_strings.dart';
import '../screens/reproduction/reproduction_screen.dart';
import '../screens/sante/fiche_sante_screen.dart';
import '../screens/cheptel/lapin_detail_screen.dart';
import 'database_helper.dart';
import 'notification_action_handler.dart';

/// Définition d'une action de notification
class NotificationAction {
  final String id;
  final String label;
  final bool showsUserInterface;

  const NotificationAction({
    required this.id,
    required this.label,
    this.showsUserInterface = false,
  });
}

/// Actions prédéfinies pour chaque type de notification
class NotificationActions {
  // Actions Mise Bas
  static NotificationAction get miseBasFait => NotificationAction(
    id: 'fait',
    label: NotificationStrings.notifActionMiseBasOK,
  );
  static NotificationAction get miseBasEchec => NotificationAction(
    id: 'echec',
    label: NotificationStrings.notifActionEchec,
  );
  static NotificationAction get miseBasReporter => NotificationAction(
    id: 'reporter',
    label: NotificationStrings.notifActionReporter24h,
  );

  // Actions Palpation
  static NotificationAction get palpationGestante => NotificationAction(
    id: 'gestante',
    label: NotificationStrings.notifActionGestante,
  );
  static NotificationAction get palpationNonGestante => NotificationAction(
    id: 'non_gestante',
    label: NotificationStrings.notifActionNonGestante,
  );
  static NotificationAction get palpationRefaire => NotificationAction(
    id: 'refaire',
    label: NotificationStrings.notifActionRefaire,
  );

  // Actions Nid
  static NotificationAction get nidFait => NotificationAction(
    id: 'fait',
    label: NotificationStrings.notifActionFait,
  );
  static NotificationAction get nidReporter => NotificationAction(
    id: 'reporter',
    label: NotificationStrings.notifActionReporter24h,
  );

  // Actions Sevrage
  static NotificationAction get sevrageFait => NotificationAction(
    id: 'fait',
    label: NotificationStrings.notifActionSevre,
  );
  static NotificationAction get sevrageReporter => NotificationAction(
    id: 'reporter',
    label: NotificationStrings.notifActionReporter2j,
  );

  // Actions Pesée
  static NotificationAction get peseeOk =>
      NotificationAction(id: 'ok', label: NotificationStrings.notifActionOK);
  static NotificationAction get peseeProbleme => NotificationAction(
    id: 'probleme',
    label: NotificationStrings.notifActionProbleme,
  );
  static NotificationAction get peseeReporter => NotificationAction(
    id: 'reporter',
    label: NotificationStrings.notifActionReporter24h,
  );

  // Actions Soin
  static NotificationAction get soinFait => NotificationAction(
    id: 'fait',
    label: NotificationStrings.notifActionFait,
  );
  static NotificationAction get soinReporter => NotificationAction(
    id: 'reporter',
    label: NotificationStrings.notifActionReporter24h,
  );
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Getter public pour accès depuis CoachNotificationService
  FlutterLocalNotificationsPlugin get flutterNotifications => _notifications;

  /// Accès lazy au NotificationActionHandler pour éviter la dépendance circulaire
  NotificationActionHandler get _actionHandler => NotificationActionHandler();

  bool _isInitialized = false;

  /// Initialiser le service de notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialiser les fuseaux horaires
    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      final timeZoneName = tzInfo.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      logger.info('🕒 Timezone notifications: $timeZoneName');
    } catch (e) {
      logger.warning(
        '⚠️ Impossible de détecter la timezone locale, fallback UTC: $e',
      );
      tz.setLocalLocation(tz.UTC);
    }

    // Configuration pour Android avec catégories d'actions
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Configuration pour iOS avec catégories d'actions
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: _buildIOSNotificationCategories(),
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialiser avec gestion des actions
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    // Demander les permissions pour Android 13+
    await _requestPermissions();

    _isInitialized = true;
    logger.info('✅ Service de notifications initialisé avec actions');
  }

  /// Construit les catégories de notifications pour iOS
  List<DarwinNotificationCategory> _buildIOSNotificationCategories() {
    return [
      // Catégorie Mise Bas
      DarwinNotificationCategory(
        'mise_bas_category',
        actions: [
          DarwinNotificationAction.plain(
            'fait',
            NotificationStrings.notifActionMiseBasOK,
          ),
          DarwinNotificationAction.plain(
            'echec',
            NotificationStrings.notifActionEchec,
          ),
          DarwinNotificationAction.plain(
            'reporter',
            NotificationStrings.notifActionReporter24h,
          ),
        ],
      ),
      // Catégorie Palpation
      DarwinNotificationCategory(
        'palpation_category',
        actions: [
          DarwinNotificationAction.plain(
            'gestante',
            NotificationStrings.notifActionGestante,
          ),
          DarwinNotificationAction.plain(
            'non_gestante',
            NotificationStrings.notifActionNonGestante,
          ),
          DarwinNotificationAction.plain(
            'refaire',
            NotificationStrings.notifActionRefaire,
          ),
        ],
      ),
      // Catégorie Nid
      DarwinNotificationCategory(
        'nid_category',
        actions: [
          DarwinNotificationAction.plain(
            'fait',
            NotificationStrings.notifActionFait,
          ),
          DarwinNotificationAction.plain(
            'reporter',
            NotificationStrings.notifActionReporter24h,
          ),
        ],
      ),
      // Catégorie Sevrage
      DarwinNotificationCategory(
        'sevrage_category',
        actions: [
          DarwinNotificationAction.plain(
            'fait',
            NotificationStrings.notifActionSevre,
          ),
          DarwinNotificationAction.plain(
            'reporter',
            NotificationStrings.notifActionReporter2j,
          ),
        ],
      ),
      // Catégorie Pesée
      DarwinNotificationCategory(
        'pesee_category',
        actions: [
          DarwinNotificationAction.plain(
            'ok',
            NotificationStrings.notifActionOK,
          ),
          DarwinNotificationAction.plain(
            'probleme',
            NotificationStrings.notifActionProbleme,
          ),
          DarwinNotificationAction.plain(
            'reporter',
            NotificationStrings.notifActionReporter24h,
          ),
        ],
      ),
      // Catégorie Soin
      DarwinNotificationCategory(
        'soin_category',
        actions: [
          DarwinNotificationAction.plain(
            'fait',
            NotificationStrings.notifActionFait,
          ),
          DarwinNotificationAction.plain(
            'reporter',
            NotificationStrings.notifActionReporter24h,
          ),
        ],
      ),
      // Catégorie Coach Quotidien - Rituel Matin
      DarwinNotificationCategory(
        'rituel_matin',
        actions: [
          DarwinNotificationAction.plain('rituel_ok', '✅ Oui, tout normal'),
          DarwinNotificationAction.plain(
            'rituel_probleme',
            '⚠️ J\'ai vu un problème',
          ),
          DarwinNotificationAction.plain('rituel_later', '⏰ Plus tard'),
        ],
      ),
      // Catégorie Coach Quotidien - Suivi Problème
      DarwinNotificationCategory(
        'suivi_probleme',
        actions: [
          DarwinNotificationAction.plain('suivi_resolu', '✅ Résolu'),
          DarwinNotificationAction.plain('suivi_encours', '🔄 En cours'),
          DarwinNotificationAction.plain('suivi_aide', '❓ Besoin d\'aide'),
        ],
      ),
    ];
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

  /// Callback principal pour les réponses aux notifications (tap ou action)
  void _onNotificationResponse(NotificationResponse response) async {
    final payload = response.payload;
    final actionId = response.actionId;

    logger.debug(
      '📱 Notification response: payload=$payload, action=$actionId',
    );

    if (payload == null || payload.isEmpty) return;

    // Si une action a été sélectionnée, la traiter via le handler
    if (actionId != null && actionId.isNotEmpty) {
      logger.info('🔔 Action notification: $actionId pour $payload');
      await _actionHandler.handleAction(payload, actionId);
      return;
    }

    // Sinon, c'est un tap simple - naviguer vers l'écran approprié
    await _handleNotificationNavigation(payload);
  }

  /// Callback pour les notifications en arrière-plan (statique requis)
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    // Note: En arrière-plan, on ne peut pas faire de navigation
    // Les actions sont quand même traitées via le handler
    final payload = response.payload;
    final actionId = response.actionId;

    if (payload != null && actionId != null && actionId.isNotEmpty) {
      // Créer une instance pour traiter l'action
      NotificationActionHandler().handleAction(payload, actionId);
    }
  }

  /// Gère la navigation quand on tape sur une notification (sans action)
  Future<void> _handleNotificationNavigation(String payload) async {
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
        case 'mise_bas_jour':
        case 'palpation':
        case 'nid':
        case 'sevrage':
          logger.debug('Navigation vers reproduction pour $type $id');
          navigationService.navigateTo(const ReproductionScreen());
          break;

        case 'soin':
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
        case 'pesee':
          logger.debug('Navigation vers fiche lapin pour $type $id');
          final lapin = await DatabaseHelper.instance.getLapinById(id);
          if (lapin != null) {
            navigationService.navigateTo(LapinDetailScreen(lapin: lapin));
          }
          break;

        case 'pesee_portee':
          logger.debug('Navigation vers reproduction pour pesée portée $id');
          navigationService.navigateTo(const ReproductionScreen());
          break;

        case 'enregistrer_portee':
          logger.debug(
            'Navigation vers reproduction pour enregistrer portée $id',
          );
          navigationService.navigateTo(const ReproductionScreen());
          break;

        default:
          logger.warning('Type de notification inconnu: $type');
      }
    } catch (e, stackTrace) {
      logger.error('Erreur navigation notification', e, stackTrace);
    }
  }

  // ========== FIN DES CALLBACKS DE NOTIFICATION ==========

  // ========== MÉTHODES DE PLANIFICATION ACTIONNABLES ==========

  /// Planifier une notification pour une mise bas avec boutons d'action
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

    // Actions Android pour la mise bas
    final androidDetails = AndroidNotificationDetails(
      'mise_bas_channel',
      'Rappels de mise bas',
      channelDescription: 'Notifications pour les mises bas prévues',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          NotificationActions.miseBasFait.id,
          NotificationActions.miseBasFait.label,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          NotificationActions.miseBasEchec.id,
          NotificationActions.miseBasEchec.label,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          NotificationActions.miseBasReporter.id,
          NotificationActions.miseBasReporter.label,
          showsUserInterface: true,
        ),
      ],
    );

    // iOS avec catégorie pour les actions
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'MISE_BAS_CATEGORY',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _getMiseBasNotificationId(accouplementId),
      NotificationStrings.notifMiseBasTitre,
      NotificationStrings.notifMiseBasCorps(
        nomFemelle,
        _formatDate(dateMiseBasPrevue),
      ),
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'mise_bas:$accouplementId',
    );

    logger.info(
      '✅ Rappel actionnable planifié pour $nomFemelle le ${_formatDate(dateRappel)}',
    );
  }

  /// Génère un ID unique pour les notifications de mise bas
  int _getMiseBasNotificationId(int accouplementId) => 500000 + accouplementId;

  /// Planifier une notification pour un soin avec rappel et boutons d'action
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

    // Actions Android pour les soins
    final androidDetails = AndroidNotificationDetails(
      'soin_channel',
      'Rappels de soins',
      channelDescription: 'Notifications pour les soins à effectuer',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          NotificationActions.soinFait.id,
          NotificationActions.soinFait.label,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          NotificationActions.soinReporter.id,
          NotificationActions.soinReporter.label,
          showsUserInterface: true,
        ),
      ],
    );

    // iOS avec catégorie pour les actions
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'SOIN_CATEGORY',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Utiliser un ID unique pour les soins (offset de 100000)
    await _notifications.zonedSchedule(
      100000 + soinId,
      NotificationStrings.notifSoinTitre,
      NotificationStrings.notifSoinCorps(
        nomLapin,
        typeSoin,
        _formatDate(dateRappel),
      ),
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'soin:$soinId',
    );

    logger.info(
      '✅ Rappel de soin actionnable planifié pour $nomLapin le ${_formatDate(dateRappel)}',
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

    // Actions Android pour la palpation
    final androidDetails = AndroidNotificationDetails(
      'reproduction_channel',
      'Rappels de reproduction',
      channelDescription:
          'Notifications pour les accouplements et reproductions',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          NotificationActions.palpationGestante.id,
          NotificationActions.palpationGestante.label,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          NotificationActions.palpationNonGestante.id,
          NotificationActions.palpationNonGestante.label,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          NotificationActions.palpationRefaire.id,
          NotificationActions.palpationRefaire.label,
          showsUserInterface: true,
        ),
      ],
    );

    // iOS avec catégorie pour les actions
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'PALPATION_CATEGORY',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Utiliser un ID unique pour les palpations (offset de 200000)
    await _notifications.zonedSchedule(
      200000 + accouplementId,
      NotificationStrings.notifPalpationTitre,
      NotificationStrings.notifPalpationCorps(
        nomFemelle,
        _formatDate(dateRappel),
      ),
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'palpation:$accouplementId',
    );

    logger.info(
      '✅ Rappel de palpation actionnable planifié pour $nomFemelle le ${_formatDate(dateRappel)}',
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

    // Actions Android pour le nid
    final androidDetails = AndroidNotificationDetails(
      'reproduction_channel',
      'Rappels de reproduction',
      channelDescription:
          'Notifications pour les accouplements et reproductions',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          NotificationActions.nidFait.id,
          NotificationActions.nidFait.label,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          NotificationActions.nidReporter.id,
          NotificationActions.nidReporter.label,
          showsUserInterface: true,
        ),
      ],
    );

    // iOS avec catégorie pour les actions
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'NID_CATEGORY',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Utiliser un ID unique pour les nids (offset de 300000)
    await _notifications.zonedSchedule(
      300000 + accouplementId,
      NotificationStrings.notifNidTitre,
      NotificationStrings.notifNidCorps(nomFemelle, _formatDate(dateRappel)),
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'nid:$accouplementId',
    );

    logger.info(
      '✅ Rappel de nid actionnable planifié pour $nomFemelle le ${_formatDate(dateRappel)}',
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

    // Actions Android pour les pesées
    final androidDetails = AndroidNotificationDetails(
      'pesee_channel',
      'Rappels de pesées',
      channelDescription: 'Notifications pour les pesées régulières',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          NotificationActions.peseeOk.id,
          NotificationActions.peseeOk.label,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          NotificationActions.peseeProbleme.id,
          NotificationActions.peseeProbleme.label,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          NotificationActions.peseeReporter.id,
          NotificationActions.peseeReporter.label,
          showsUserInterface: true,
        ),
      ],
    );

    // iOS avec catégorie pour les actions
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'PESEE_CATEGORY',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Utiliser un ID unique pour les pesées (offset de 400000)
    await _notifications.zonedSchedule(
      400000 + lapinId,
      NotificationStrings.notifPeseeTitre,
      NotificationStrings.notifPeseeCorps(nomLapin, _formatDate(dateRappel)),
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'pesee:$lapinId',
    );

    logger.info(
      '✅ Rappel de pesée actionnable planifié pour $nomLapin le ${_formatDate(dateRappel)}',
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
    logger.debug('❌ Rappel de nid annulé pour l\'accouplement $accouplementId');
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
