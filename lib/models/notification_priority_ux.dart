import '../services/notification_quota_manager.dart';

/// Modèle de priorités UX pour les notifications
/// 
/// Hiérarchie claire à 4 niveaux pour guider l'utilisateur
/// sans le submerger. Implémente les recommandations de l'audit.
enum NotificationPrioriteUX {
  /// 🚨 URGENCE : Vie de l'animal en jeu
  /// Ex: Mise bas difficile, symptôme grave, mortalité anormale
  /// → Toujours push, son + vibration, bypass quota
  urgence,

  /// ⚠️ ACTION REQUISE : À faire aujourd'hui
  /// Ex: Palpation J10, préparation nid, sevrage
  /// → Push si quota disponible, son léger
  actionRequise,

  /// 📋 RAPPEL : À planifier cette semaine
  /// Ex: Pesée hebdo, vaccination prochaine
  /// → Consolidé en résumé, silencieux
  rappel,

  /// ℹ️ INFO : Pour information uniquement
  /// Ex: Stock faible, stats, résumé
  /// → In-app uniquement, jamais de push
  info,
}

extension NotificationPrioriteUXExtension on NotificationPrioriteUX {
  /// Label français pour affichage
  String get label {
    switch (this) {
      case NotificationPrioriteUX.urgence:
        return 'Urgence';
      case NotificationPrioriteUX.actionRequise:
        return 'Action requise';
      case NotificationPrioriteUX.rappel:
        return 'Rappel';
      case NotificationPrioriteUX.info:
        return 'Information';
    }
  }

  /// Emoji associé
  String get emoji {
    switch (this) {
      case NotificationPrioriteUX.urgence:
        return '🚨';
      case NotificationPrioriteUX.actionRequise:
        return '⚠️';
      case NotificationPrioriteUX.rappel:
        return '📋';
      case NotificationPrioriteUX.info:
        return 'ℹ️';
    }
  }

  /// Convertir vers NotificationPriorite (backend)
  NotificationPriorite toBackendPriority() {
    switch (this) {
      case NotificationPrioriteUX.urgence:
        return NotificationPriorite.critique;
      case NotificationPrioriteUX.actionRequise:
        return NotificationPriorite.operationnelle;
      case NotificationPrioriteUX.rappel:
        return NotificationPriorite.rituelle;
      case NotificationPrioriteUX.info:
        return NotificationPriorite.passive;
    }
  }
}

/// Catégories cohérentes pour emojis de notifications
enum NotificationCategorie {
  reproduction, // 🐰
  sante, // ❤️
  suivi, // 📊
  stock, // 📦
  urgence, // 🚨
  info, // ℹ️
}

extension NotificationCategorieExtension on NotificationCategorie {
  String get emoji {
    switch (this) {
      case NotificationCategorie.reproduction:
        return '🐰';
      case NotificationCategorie.sante:
        return '❤️';
      case NotificationCategorie.suivi:
        return '📊';
      case NotificationCategorie.stock:
        return '📦';
      case NotificationCategorie.urgence:
        return '🚨';
      case NotificationCategorie.info:
        return 'ℹ️';
    }
  }
}
