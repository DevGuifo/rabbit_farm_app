import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Priorités de notification pour la gestion du quota
enum NotificationPriorite {
  /// Urgences critiques - bypass toujours le quota (mise bas, urgence santé)
  critique,

  /// Notifications opérationnelles - compte dans le quota (palpation, nid, sevrage)
  operationnelle,

  /// Notifications rituelles - compte dans le quota, silencieuses (rituel matin/soir)
  rituelle,

  /// Notifications passives - jamais de push, in-app uniquement
  passive,
}

/// Gestionnaire de quota de notifications
///
/// Limite le nombre de notifications push par jour pour éviter la fatigue
/// notificationnelle. Les notifications critiques (urgences) ne sont jamais
/// bloquées.
///
/// Usage:
/// ```dart
/// final quotaManager = NotificationQuotaManager();
/// if (await quotaManager.peutEnvoyerNotification(NotificationPriorite.operationnelle)) {
///   // Envoyer la notification
///   await quotaManager.incrementerCompteur();
/// }
/// ```
class NotificationQuotaManager {
  static final NotificationQuotaManager _instance =
      NotificationQuotaManager._internal();
  factory NotificationQuotaManager() => _instance;
  NotificationQuotaManager._internal();

  // ===== CONFIGURATION =====

  /// Quota par défaut (modifiable par l'utilisateur)
  static const int defaultMaxParJour = 7;

  /// Heure de début de plage horaire par défaut (7h)
  static const int defaultHeureDebut = 7;

  /// Heure de fin de plage horaire par défaut (21h)
  static const int defaultHeureFin = 21;

  // ===== CLÉS SHARED PREFERENCES =====

  static const String _keyQuotaCount = 'notif_quota_count_';
  static const String _keyQuotaDate = 'notif_quota_date';
  static const String _keyMaxQuota = 'notif_max_quota';
  static const String _keyHeureDebut = 'notif_heure_debut';
  static const String _keyHeureFin = 'notif_heure_fin';
  static const String _keyQuotaEnabled = 'notif_quota_enabled';

  // ===== MÉTHODES PRINCIPALES =====

  /// Vérifie si une notification peut être envoyée
  ///
  /// Retourne `true` si :
  /// - La priorité est `critique` (bypass quota)
  /// - La priorité est `passive` (pas de push)
  /// - Le quota n'est pas atteint ET on est dans la plage horaire
  Future<bool> peutEnvoyerNotification(NotificationPriorite priorite) async {
    // Les notifications critiques passent toujours
    if (priorite == NotificationPriorite.critique) {
      logger.debug('🔔 Notification critique : bypass quota');
      return true;
    }

    // Les notifications passives ne sont jamais en push
    if (priorite == NotificationPriorite.passive) {
      logger.debug('📵 Notification passive : pas de push');
      return false;
    }

    // Vérifier si le quota est activé
    final prefs = await SharedPreferences.getInstance();
    final quotaEnabled = prefs.getBool(_keyQuotaEnabled) ?? true;
    if (!quotaEnabled) {
      return true;
    }

    // Vérifier la plage horaire
    if (!await estDansPlageHoraire()) {
      logger.info('🕐 Hors plage horaire : notification bloquée');
      return false;
    }

    // Vérifier le quota
    final quotaRestant = await getQuotaRestant();
    if (quotaRestant <= 0) {
      logger.info(
        '📵 Quota atteint ($defaultMaxParJour/jour) : notification bloquée',
      );
      return false;
    }

    return true;
  }

  /// Incrémente le compteur de notifications du jour
  Future<void> incrementerCompteur() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getDateKey();

    // Vérifier si on doit reset (nouveau jour)
    await _resetSiNouveauJour();

    final current = prefs.getInt('$_keyQuotaCount$today') ?? 0;
    await prefs.setInt('$_keyQuotaCount$today', current + 1);

    logger.debug(
      '📊 Compteur notifications: ${current + 1}/${await getMaxQuota()}',
    );
  }

  /// Retourne le nombre de notifications restantes pour aujourd'hui
  Future<int> getQuotaRestant() async {
    await _resetSiNouveauJour();

    final prefs = await SharedPreferences.getInstance();
    final today = _getDateKey();
    final current = prefs.getInt('$_keyQuotaCount$today') ?? 0;
    final max = await getMaxQuota();

    return max - current;
  }

  /// Retourne le nombre de notifications envoyées aujourd'hui
  Future<int> getCompteurAujourdhui() async {
    await _resetSiNouveauJour();

    final prefs = await SharedPreferences.getInstance();
    final today = _getDateKey();
    return prefs.getInt('$_keyQuotaCount$today') ?? 0;
  }

  /// Retourne le quota maximum configuré
  Future<int> getMaxQuota() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMaxQuota) ?? defaultMaxParJour;
  }

  /// Vérifie si l'heure actuelle est dans la plage horaire autorisée
  Future<bool> estDansPlageHoraire() async {
    final prefs = await SharedPreferences.getInstance();
    final heureDebut = prefs.getInt(_keyHeureDebut) ?? defaultHeureDebut;
    final heureFin = prefs.getInt(_keyHeureFin) ?? defaultHeureFin;

    final now = DateTime.now();
    final heureActuelle = now.hour;

    return heureActuelle >= heureDebut && heureActuelle < heureFin;
  }

  // ===== CONFIGURATION UTILISATEUR =====

  /// Configure le quota maximum journalier
  Future<void> configurerQuota(int max) async {
    if (max < 1 || max > 50) {
      logger.warning('⚠️ Quota invalide: $max (doit être entre 1 et 50)');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMaxQuota, max);
    logger.info('✅ Quota configuré: $max notifications/jour');
  }

  /// Configure la plage horaire autorisée
  Future<void> configurerPlageHoraire(int heureDebut, int heureFin) async {
    if (heureDebut < 0 || heureDebut > 23 || heureFin < 0 || heureFin > 23) {
      logger.warning('⚠️ Plage horaire invalide: $heureDebut-$heureFin');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHeureDebut, heureDebut);
    await prefs.setInt(_keyHeureFin, heureFin);
    logger.info('✅ Plage horaire configurée: ${heureDebut}h-${heureFin}h');
  }

  /// Active ou désactive le système de quota
  Future<void> setQuotaEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyQuotaEnabled, enabled);
    logger.info('✅ Quota ${enabled ? "activé" : "désactivé"}');
  }

  /// Vérifie si le quota est activé
  Future<bool> isQuotaEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyQuotaEnabled) ?? true;
  }

  // ===== STATISTIQUES =====

  /// Retourne les statistiques du quota
  Future<Map<String, dynamic>> getStats() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'compteurAujourdhui': await getCompteurAujourdhui(),
      'maxQuota': await getMaxQuota(),
      'quotaRestant': await getQuotaRestant(),
      'heureDebut': prefs.getInt(_keyHeureDebut) ?? defaultHeureDebut,
      'heureFin': prefs.getInt(_keyHeureFin) ?? defaultHeureFin,
      'dansPlageHoraire': await estDansPlageHoraire(),
      'quotaEnabled': await isQuotaEnabled(),
    };
  }

  // ===== MÉTHODES PRIVÉES =====

  /// Génère la clé de date pour aujourd'hui (format: YYYY-MM-DD)
  String _getDateKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Reset le compteur si on est un nouveau jour
  Future<void> _resetSiNouveauJour() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_keyQuotaDate);
    final today = _getDateKey();

    if (savedDate != today) {
      // Nouveau jour, reset le compteur
      await prefs.setString(_keyQuotaDate, today);
      await prefs.setInt('$_keyQuotaCount$today', 0);
      logger.debug('🔄 Reset quota quotidien (nouveau jour)');
    }
  }

  /// Reset manuel du compteur (pour tests)
  Future<void> resetCompteur() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getDateKey();
    await prefs.setInt('$_keyQuotaCount$today', 0);
    logger.info('🔄 Compteur quota réinitialisé');
  }
}
