import 'dart:math';

/// Service de micro-messages pédagogiques
///
/// Fournit des conseils contextuels courts et bienveillants
/// pour former l'utilisateur sans cours ni texte long.
///
/// ⚠️ Principes :
/// - Jamais culpabilisant
/// - Toujours pédagogique
/// - Court et actionnable
class MicroMessageService {
  static final MicroMessageService _instance = MicroMessageService._internal();
  factory MicroMessageService() => _instance;
  MicroMessageService._internal();

  final _random = Random();

  // ============= MESSAGES PAR CONTEXTE =============

  /// Messages pour série d'observations (streak)
  static const _messagesStreak = {
    0: [
      (
        '🐰',
        'Tes lapins t\'attendent',
        '5 minutes suffisent pour un contrôle visuel.',
      ),
      (
        '👀',
        'Un coup d\'œil rapide ?',
        'Observer régulièrement, c\'est prévenir.',
      ),
      (
        '🌅',
        'Nouveau jour, nouvelle observation',
        'Les élevages performants observent 2× par jour.',
      ),
    ],
    1: [
      ('👍', 'Bon début !', 'Continue demain pour créer une habitude.'),
      ('🌱', 'Premier pas fait', 'La régularité vient avec la pratique.'),
    ],
    3: [
      ('⭐', '3 jours de suite !', 'Tu prends de bonnes habitudes.'),
      ('📈', 'Belle progression', 'La constance fait les bons éleveurs.'),
    ],
    7: [
      (
        '🔥',
        'Une semaine complète !',
        'Les élevages performants observent 2× par jour.',
      ),
      (
        '🏆',
        'Bravo ! 7 jours consécutifs',
        'Tu fais partie des éleveurs rigoureux.',
      ),
    ],
    14: [
      (
        '🌟',
        '2 semaines de régularité',
        'L\'observation est devenue un réflexe.',
      ),
      ('💪', 'Exemplaire !', 'Tes lapins te remercient.'),
    ],
  };

  /// Messages pour inactivité
  static const _messagesInactivite = {
    1: [
      ('🕐', 'Hier c\'était bien', 'Aujourd\'hui aussi ?'),
      (
        '⏰',
        'Un jour sans observation',
        'Pas grave, mais ne laisse pas passer demain.',
      ),
    ],
    2: [
      ('😴', '2 jours sans observation', 'Un petit tour rapide serait bien.'),
      ('👁️', 'Tes lapins t\'ont-ils vu ?', 'Ils ont besoin de toi.'),
    ],
    3: [
      (
        '⚠️',
        '3 jours sans observation = risque sanitaire',
        'Un problème peut passer inaperçu.',
      ),
      (
        '🏥',
        'Attention inactivité',
        '3 jours c\'est trop long entre deux visites.',
      ),
    ],
    5: [
      (
        '🚨',
        'Longue absence détectée',
        'Fais un check complet dès que possible.',
      ),
      ('📋', 'Reprise recommandée', 'Vérifie l\'état de chaque lapin.'),
    ],
  };

  /// Messages après action manquée
  static const _messagesActionManquee = [
    ('📝', 'Action non faite', 'Ce n\'est pas grave, tu peux la reporter.'),
    ('⏰', 'Reporter plutôt qu\'oublier', 'L\'important c\'est de suivre.'),
    ('💡', 'Astuce', 'Mieux vaut reporter que laisser en suspens.'),
  ];

  /// Messages après anomalie signalée
  static const _messagesAnomalie = [
    ('👁️', 'Bien vu !', 'Signaler une anomalie, c\'est déjà agir.'),
    ('✅', 'Noté', 'Tu pourras suivre l\'évolution.'),
    ('🔍', 'Observation enregistrée', 'Continue à surveiller.'),
  ];

  /// Messages de bonnes pratiques (rotation aléatoire)
  static const _bonnesPratiques = [
    (
      '💡',
      'Astuce',
      'Observer le matin ET le soir détecte 90% des problèmes tôt.',
    ),
    ('📊', 'Saviez-vous ?', 'Les élevages performants observent 2× par jour.'),
    (
      '🩺',
      'Prévention',
      'Une anomalie détectée tôt coûte 5× moins cher à traiter.',
    ),
    (
      '🐰',
      'Comportement',
      'Un lapin qui ne mange pas depuis 12h nécessite attention.',
    ),
    ('💧', 'Hydratation', 'Vérifie les abreuvoirs à chaque passage.'),
    ('🧹', 'Hygiène', 'Une litière propre = moins de maladies.'),
    ('🌡️', 'Température', 'Les lapins supportent mal la chaleur > 30°C.'),
    ('👀', 'Observation', 'Regarde les crottes : elles parlent de la santé.'),
  ];

  // ============= MÉTHODES PUBLIQUES =============

  /// Obtenir un message pour une série de jours consécutifs
  (String emoji, String titre, String astuce) getMessageStreak(
    int joursConsecutifs,
  ) {
    final seuil = _messagesStreak.keys
        .where((k) => k <= joursConsecutifs)
        .reduce((a, b) => a > b ? a : b);

    final messages = _messagesStreak[seuil]!;
    return messages[_random.nextInt(messages.length)];
  }

  /// Obtenir un message pour une période d'inactivité
  (String emoji, String titre, String astuce) getMessageInactivite(
    int joursSansActivite,
  ) {
    if (joursSansActivite <= 0) {
      return ('✅', 'Actif aujourd\'hui', 'Continue comme ça !');
    }

    final seuil = _messagesInactivite.keys
        .where((k) => k <= joursSansActivite)
        .reduce((a, b) => a > b ? a : b);

    final messages = _messagesInactivite[seuil]!;
    return messages[_random.nextInt(messages.length)];
  }

  /// Obtenir un message après une action manquée/reportée
  (String emoji, String titre, String astuce) getMessageActionManquee() {
    return _messagesActionManquee[_random.nextInt(
      _messagesActionManquee.length,
    )];
  }

  /// Obtenir un message après signalement d'anomalie
  (String emoji, String titre, String astuce) getMessageAnomalie() {
    return _messagesAnomalie[_random.nextInt(_messagesAnomalie.length)];
  }

  /// Obtenir une bonne pratique aléatoire
  (String emoji, String titre, String astuce) getBonnePratiqueAleatoire() {
    return _bonnesPratiques[_random.nextInt(_bonnesPratiques.length)];
  }

  /// Obtenir un message contextuel selon la situation
  (String emoji, String titre, String astuce) getMessageContextuel({
    required int joursConsecutifs,
    required int joursSansActivite,
    required int anomaliesOuvertes,
    required int pourcentageRituels,
  }) {
    // Priorité 1: Alerte inactivité prolongée
    if (joursSansActivite >= 3) {
      return getMessageInactivite(joursSansActivite);
    }

    // Priorité 2: Beaucoup d'anomalies
    if (anomaliesOuvertes >= 3) {
      return (
        '⚠️',
        'Plusieurs points à surveiller',
        'Traite-les un par un, commence par le plus urgent.',
      );
    }

    // Priorité 3: Encourager reprise après inactivité
    if (joursSansActivite >= 1 && joursConsecutifs == 0) {
      return getMessageInactivite(joursSansActivite);
    }

    // Priorité 4: Féliciter série
    if (joursConsecutifs >= 3) {
      return getMessageStreak(joursConsecutifs);
    }

    // Priorité 5: Rituels faibles
    if (pourcentageRituels < 50) {
      return (
        '📊',
        'Cette semaine peut s\'améliorer',
        'Même un tour rapide compte. L\'important c\'est d\'observer.',
      );
    }

    // Par défaut: bonne pratique aléatoire
    return getBonnePratiqueAleatoire();
  }

  /// Obtenir un message de félicitations après rituel complété
  String getMessageRituelComplete(int rituelsCompletesAujourdhui) {
    if (rituelsCompletesAujourdhui >= 2) {
      return '🏆 Les deux rituels du jour sont faits !';
    } else if (rituelsCompletesAujourdhui == 1) {
      return '✅ Premier rituel du jour validé !';
    }
    return '';
  }

  /// Obtenir un message d'encouragement pour continuer
  String getMessageEncouragement(int joursConsecutifs) {
    if (joursConsecutifs == 6) {
      return '🎯 Plus qu\'un jour pour atteindre une semaine !';
    } else if (joursConsecutifs == 13) {
      return '🎯 Demain ça fait 2 semaines !';
    } else if (joursConsecutifs > 0 && joursConsecutifs % 7 == 6) {
      return '🎯 Encore un jour pour la prochaine semaine complète !';
    }
    return '';
  }
}
