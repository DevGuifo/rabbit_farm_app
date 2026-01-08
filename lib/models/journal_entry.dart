import 'dart:convert';

/// Types d'entités concernées par les événements du journal
enum TypeEntite {
  lapin,
  portee,
  accouplement,
  soin,
  pesee,
  depense,
  recette,
  vente,
  deces,
  reforme,
  quarantaine,
  sevrage,
  rituel,
  anomalie,
  aliment,
  medicament,
  cage,
  clapier,
  batiment,
  palpation,
  preparationNid,
  autre,
}

/// Types d'actions générées automatiquement
enum TypeAction {
  creation,
  modification,
  suppression,
  validation,
  annulation,
  completion,
  observation,
  anomalie,
  alerte,
  rappel,
}

/// Statut de l'événement
enum StatutEvenement {
  normal, // Action standard
  anomalie, // Problème détecté
  action, // Action requise
  info, // Information contextuelle
  succes, // Objectif atteint
}

extension TypeEntiteExtension on TypeEntite {
  String get label {
    switch (this) {
      case TypeEntite.lapin:
        return 'Lapin';
      case TypeEntite.portee:
        return 'Portée';
      case TypeEntite.accouplement:
        return 'Accouplement';
      case TypeEntite.soin:
        return 'Soin';
      case TypeEntite.pesee:
        return 'Pesée';
      case TypeEntite.depense:
        return 'Dépense';
      case TypeEntite.recette:
        return 'Recette';
      case TypeEntite.vente:
        return 'Vente';
      case TypeEntite.deces:
        return 'Décès';
      case TypeEntite.reforme:
        return 'Réforme';
      case TypeEntite.quarantaine:
        return 'Quarantaine';
      case TypeEntite.sevrage:
        return 'Sevrage';
      case TypeEntite.rituel:
        return 'Rituel';
      case TypeEntite.anomalie:
        return 'Anomalie';
      case TypeEntite.aliment:
        return 'Aliment';
      case TypeEntite.medicament:
        return 'Médicament';
      case TypeEntite.cage:
        return 'Cage';
      case TypeEntite.clapier:
        return 'Clapier';
      case TypeEntite.batiment:
        return 'Bâtiment';
      case TypeEntite.palpation:
        return 'Palpation';
      case TypeEntite.preparationNid:
        return 'Préparation nid';
      case TypeEntite.autre:
        return 'Autre';
    }
  }

  String get emoji {
    switch (this) {
      case TypeEntite.lapin:
        return '🐰';
      case TypeEntite.portee:
        return '🐣';
      case TypeEntite.accouplement:
        return '💕';
      case TypeEntite.soin:
        return '💊';
      case TypeEntite.pesee:
        return '⚖️';
      case TypeEntite.depense:
        return '💸';
      case TypeEntite.recette:
        return '💰';
      case TypeEntite.vente:
        return '🛒';
      case TypeEntite.deces:
        return '🕯️';
      case TypeEntite.reforme:
        return '📤';
      case TypeEntite.quarantaine:
        return '🔒';
      case TypeEntite.sevrage:
        return '🍼';
      case TypeEntite.rituel:
        return '📋';
      case TypeEntite.anomalie:
        return '⚠️';
      case TypeEntite.aliment:
        return '🥕';
      case TypeEntite.medicament:
        return '💉';
      case TypeEntite.cage:
        return '🏠';
      case TypeEntite.clapier:
        return '🏘️';
      case TypeEntite.batiment:
        return '🏢';
      case TypeEntite.palpation:
        return '🤰';
      case TypeEntite.preparationNid:
        return '🪺';
      case TypeEntite.autre:
        return '📝';
    }
  }
}

extension TypeActionExtension on TypeAction {
  String get label {
    switch (this) {
      case TypeAction.creation:
        return 'Création';
      case TypeAction.modification:
        return 'Modification';
      case TypeAction.suppression:
        return 'Suppression';
      case TypeAction.validation:
        return 'Validation';
      case TypeAction.annulation:
        return 'Annulation';
      case TypeAction.completion:
        return 'Complétion';
      case TypeAction.observation:
        return 'Observation';
      case TypeAction.anomalie:
        return 'Anomalie';
      case TypeAction.alerte:
        return 'Alerte';
      case TypeAction.rappel:
        return 'Rappel';
    }
  }

  String get verbe {
    switch (this) {
      case TypeAction.creation:
        return 'créé';
      case TypeAction.modification:
        return 'modifié';
      case TypeAction.suppression:
        return 'supprimé';
      case TypeAction.validation:
        return 'validé';
      case TypeAction.annulation:
        return 'annulé';
      case TypeAction.completion:
        return 'complété';
      case TypeAction.observation:
        return 'observé';
      case TypeAction.anomalie:
        return 'signalé';
      case TypeAction.alerte:
        return 'alerté';
      case TypeAction.rappel:
        return 'rappelé';
    }
  }
}

extension StatutEvenementExtension on StatutEvenement {
  String get label {
    switch (this) {
      case StatutEvenement.normal:
        return 'Normal';
      case StatutEvenement.anomalie:
        return 'Anomalie';
      case StatutEvenement.action:
        return 'Action requise';
      case StatutEvenement.info:
        return 'Information';
      case StatutEvenement.succes:
        return 'Succès';
    }
  }

  String get emoji {
    switch (this) {
      case StatutEvenement.normal:
        return '✅';
      case StatutEvenement.anomalie:
        return '⚠️';
      case StatutEvenement.action:
        return '🔔';
      case StatutEvenement.info:
        return 'ℹ️';
      case StatutEvenement.succes:
        return '🎉';
    }
  }
}

/// Entrée du journal automatique
///
/// Capture automatiquement chaque action utilisateur avec :
/// - Horodatage précis
/// - Contexte (individu, lot, rituel, type)
/// - Statut (normal / anomalie / action)
class JournalEntry {
  final int? id;
  final DateTime timestamp;
  final TypeEntite typeEntite;
  final int? entiteId;
  final String? entiteNom; // Nom lisible (ex: "Bella", "Portée #3")
  final TypeAction typeAction;
  final StatutEvenement statut;
  final String resumeAuto; // Résumé généré automatiquement
  final Map<String, dynamic> contexte; // Contexte JSON riche
  final String? noteUtilisateur; // Note optionnelle ajoutée par l'utilisateur
  final bool lu; // Marqué comme lu

  JournalEntry({
    this.id,
    required this.timestamp,
    required this.typeEntite,
    this.entiteId,
    this.entiteNom,
    required this.typeAction,
    this.statut = StatutEvenement.normal,
    required this.resumeAuto,
    this.contexte = const {},
    this.noteUtilisateur,
    this.lu = false,
  });

  /// Génère le résumé lisible complet
  String get resumeComplet {
    final emoji = typeEntite.emoji;
    final entite = entiteNom ?? typeEntite.label;
    final action = typeAction.verbe;
    return '$emoji $entite $action';
  }

  /// Résumé avec statut
  String get resumeAvecStatut {
    return '${statut.emoji} $resumeComplet';
  }

  /// Heure formatée (HH:mm)
  String get heureFormatee {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  /// Date formatée (dd/MM/yyyy)
  String get dateFormatee {
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
  }

  /// Copie avec modifications
  JournalEntry copyWith({
    int? id,
    DateTime? timestamp,
    TypeEntite? typeEntite,
    int? entiteId,
    String? entiteNom,
    TypeAction? typeAction,
    StatutEvenement? statut,
    String? resumeAuto,
    Map<String, dynamic>? contexte,
    String? noteUtilisateur,
    bool? lu,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      typeEntite: typeEntite ?? this.typeEntite,
      entiteId: entiteId ?? this.entiteId,
      entiteNom: entiteNom ?? this.entiteNom,
      typeAction: typeAction ?? this.typeAction,
      statut: statut ?? this.statut,
      resumeAuto: resumeAuto ?? this.resumeAuto,
      contexte: contexte ?? this.contexte,
      noteUtilisateur: noteUtilisateur ?? this.noteUtilisateur,
      lu: lu ?? this.lu,
    );
  }

  /// Conversion vers Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type_entite': typeEntite.name,
      'entite_id': entiteId,
      'entite_nom': entiteNom,
      'type_action': typeAction.name,
      'statut': statut.name,
      'resume_auto': resumeAuto,
      'contexte': jsonEncode(contexte),
      'note_utilisateur': noteUtilisateur,
      'lu': lu ? 1 : 0,
    };
  }

  /// Création depuis Map SQLite
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as int?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      typeEntite: TypeEntite.values.firstWhere(
        (e) => e.name == map['type_entite'],
        orElse: () => TypeEntite.autre,
      ),
      entiteId: map['entite_id'] as int?,
      entiteNom: map['entite_nom'] as String?,
      typeAction: TypeAction.values.firstWhere(
        (e) => e.name == map['type_action'],
        orElse: () => TypeAction.observation,
      ),
      statut: StatutEvenement.values.firstWhere(
        (e) => e.name == map['statut'],
        orElse: () => StatutEvenement.normal,
      ),
      resumeAuto: map['resume_auto'] as String? ?? '',
      contexte: map['contexte'] != null
          ? jsonDecode(map['contexte'] as String) as Map<String, dynamic>
          : {},
      noteUtilisateur: map['note_utilisateur'] as String?,
      lu: (map['lu'] as int?) == 1,
    );
  }

  @override
  String toString() {
    return 'JournalEntry(id: $id, timestamp: $timestamp, type: $typeEntite, action: $typeAction, statut: $statut, resume: $resumeAuto)';
  }
}

/// Statistiques du journal pour une période
class StatsJournal {
  final int totalEvenements;
  final int evenementsNormaux;
  final int anomalies;
  final int actionsRequises;
  final int nonLus;
  final Map<TypeEntite, int> parEntite;
  final Map<TypeAction, int> parAction;

  StatsJournal({
    required this.totalEvenements,
    required this.evenementsNormaux,
    required this.anomalies,
    required this.actionsRequises,
    required this.nonLus,
    required this.parEntite,
    required this.parAction,
  });

  factory StatsJournal.vide() {
    return StatsJournal(
      totalEvenements: 0,
      evenementsNormaux: 0,
      anomalies: 0,
      actionsRequises: 0,
      nonLus: 0,
      parEntite: {},
      parAction: {},
    );
  }

  factory StatsJournal.fromEntries(List<JournalEntry> entries) {
    final parEntite = <TypeEntite, int>{};
    final parAction = <TypeAction, int>{};
    int normaux = 0;
    int anomalies = 0;
    int actions = 0;
    int nonLus = 0;

    for (final entry in entries) {
      // Comptage par entité
      parEntite[entry.typeEntite] = (parEntite[entry.typeEntite] ?? 0) + 1;

      // Comptage par action
      parAction[entry.typeAction] = (parAction[entry.typeAction] ?? 0) + 1;

      // Comptage par statut
      switch (entry.statut) {
        case StatutEvenement.normal:
        case StatutEvenement.info:
        case StatutEvenement.succes:
          normaux++;
          break;
        case StatutEvenement.anomalie:
          anomalies++;
          break;
        case StatutEvenement.action:
          actions++;
          break;
      }

      // Comptage non lus
      if (!entry.lu) nonLus++;
    }

    return StatsJournal(
      totalEvenements: entries.length,
      evenementsNormaux: normaux,
      anomalies: anomalies,
      actionsRequises: actions,
      nonLus: nonLus,
      parEntite: parEntite,
      parAction: parAction,
    );
  }
}
