import 'dart:convert';

/// Types d'anomalies observables lors des rituels
///
/// Chaque type a :
/// - Un emoji pour identification rapide
/// - Une description claire
/// - Une sévérité par défaut (1-3)
/// - Une action suggérée
enum TypeAnomalie {
  refusNourriture,
  apathie,
  blessureVisible,
  pertePoids,
  agressivite,
  diarrhee,
  ecoulementNasal,
  problemeRespiratoire,
  pelageAnormal,
  autre;

  /// Emoji pour affichage rapide
  String get emoji {
    switch (this) {
      case TypeAnomalie.refusNourriture:
        return '🍽️';
      case TypeAnomalie.apathie:
        return '😴';
      case TypeAnomalie.blessureVisible:
        return '🩹';
      case TypeAnomalie.pertePoids:
        return '⚖️';
      case TypeAnomalie.agressivite:
        return '😤';
      case TypeAnomalie.diarrhee:
        return '💩';
      case TypeAnomalie.ecoulementNasal:
        return '🤧';
      case TypeAnomalie.problemeRespiratoire:
        return '😮‍💨';
      case TypeAnomalie.pelageAnormal:
        return '🐰';
      case TypeAnomalie.autre:
        return '❓';
    }
  }

  /// Label utilisateur
  String get label {
    switch (this) {
      case TypeAnomalie.refusNourriture:
        return 'Refus de nourriture';
      case TypeAnomalie.apathie:
        return 'Apathie / Léthargie';
      case TypeAnomalie.blessureVisible:
        return 'Blessure visible';
      case TypeAnomalie.pertePoids:
        return 'Perte de poids apparente';
      case TypeAnomalie.agressivite:
        return 'Agressivité';
      case TypeAnomalie.diarrhee:
        return 'Diarrhée';
      case TypeAnomalie.ecoulementNasal:
        return 'Écoulement nasal';
      case TypeAnomalie.problemeRespiratoire:
        return 'Problème respiratoire';
      case TypeAnomalie.pelageAnormal:
        return 'Pelage anormal';
      case TypeAnomalie.autre:
        return 'Autre';
    }
  }

  /// Sévérité par défaut (1 = faible, 2 = moyenne, 3 = critique)
  int get severiteDefaut {
    switch (this) {
      case TypeAnomalie.refusNourriture:
        return 2;
      case TypeAnomalie.apathie:
        return 2;
      case TypeAnomalie.blessureVisible:
        return 3;
      case TypeAnomalie.pertePoids:
        return 2;
      case TypeAnomalie.agressivite:
        return 1;
      case TypeAnomalie.diarrhee:
        return 3;
      case TypeAnomalie.ecoulementNasal:
        return 2;
      case TypeAnomalie.problemeRespiratoire:
        return 3;
      case TypeAnomalie.pelageAnormal:
        return 1;
      case TypeAnomalie.autre:
        return 1;
    }
  }

  /// Action suggérée automatiquement
  ActionSuggeree get actionSuggeree {
    switch (this) {
      case TypeAnomalie.refusNourriture:
        return ActionSuggeree.surveiller;
      case TypeAnomalie.apathie:
        return ActionSuggeree.isoler;
      case TypeAnomalie.blessureVisible:
        return ActionSuggeree.soigner;
      case TypeAnomalie.pertePoids:
        return ActionSuggeree.peser;
      case TypeAnomalie.agressivite:
        return ActionSuggeree.isoler;
      case TypeAnomalie.diarrhee:
        return ActionSuggeree.isoler;
      case TypeAnomalie.ecoulementNasal:
        return ActionSuggeree.isoler;
      case TypeAnomalie.problemeRespiratoire:
        return ActionSuggeree.veterinaire;
      case TypeAnomalie.pelageAnormal:
        return ActionSuggeree.surveiller;
      case TypeAnomalie.autre:
        return ActionSuggeree.surveiller;
    }
  }
}

/// Portée de l'anomalie : individu ou lot
enum PorteeAnomalie {
  individu,
  lot;

  String get label {
    switch (this) {
      case PorteeAnomalie.individu:
        return 'Un seul sujet';
      case PorteeAnomalie.lot:
        return 'Plusieurs / Tout le lot';
    }
  }

  String get emoji {
    switch (this) {
      case PorteeAnomalie.individu:
        return '🐰';
      case PorteeAnomalie.lot:
        return '🐰🐰🐰';
    }
  }
}

/// Actions suggérées suite à une anomalie
enum ActionSuggeree {
  surveiller,
  isoler,
  soigner,
  peser,
  veterinaire,
  aucune;

  String get label {
    switch (this) {
      case ActionSuggeree.surveiller:
        return 'Mettre sous surveillance';
      case ActionSuggeree.isoler:
        return 'Isoler le sujet';
      case ActionSuggeree.soigner:
        return 'Administrer un soin';
      case ActionSuggeree.peser:
        return 'Peser le sujet';
      case ActionSuggeree.veterinaire:
        return 'Consulter un vétérinaire';
      case ActionSuggeree.aucune:
        return 'Aucune action requise';
    }
  }

  String get emoji {
    switch (this) {
      case ActionSuggeree.surveiller:
        return '👀';
      case ActionSuggeree.isoler:
        return '🔒';
      case ActionSuggeree.soigner:
        return '💊';
      case ActionSuggeree.peser:
        return '⚖️';
      case ActionSuggeree.veterinaire:
        return '👨‍⚕️';
      case ActionSuggeree.aucune:
        return '✅';
    }
  }
}

/// Statut de traitement de l'anomalie
enum StatutAnomalie {
  nouveau,
  enCours,
  resolu,
  ignore;

  String get label {
    switch (this) {
      case StatutAnomalie.nouveau:
        return 'Nouveau';
      case StatutAnomalie.enCours:
        return 'En cours';
      case StatutAnomalie.resolu:
        return 'Résolu';
      case StatutAnomalie.ignore:
        return 'Ignoré';
    }
  }

  String get emoji {
    switch (this) {
      case StatutAnomalie.nouveau:
        return '🆕';
      case StatutAnomalie.enCours:
        return '🔄';
      case StatutAnomalie.resolu:
        return '✅';
      case StatutAnomalie.ignore:
        return '⏭️';
    }
  }
}

/// Modèle d'anomalie observée lors d'un rituel
///
/// Trace exploitable avec :
/// - Date/heure automatique
/// - Rituel et action concernés
/// - Types d'anomalies (multiples possibles)
/// - Portée (individu ou lot)
/// - Action suggérée et action prise
class AnomalieRituel {
  final int? id;
  final DateTime dateObservation;
  final int? rituelId;
  final String actionRituelId;
  final String actionRituelTitre;
  final List<TypeAnomalie> typesAnomalies;
  final PorteeAnomalie portee;
  final int? lapinId; // Si individu spécifique
  final String? cageId; // Si lot/cage spécifique
  final int severite; // 1-3
  final ActionSuggeree actionSuggeree;
  final ActionSuggeree? actionPrise;
  final StatutAnomalie statut;
  final String? noteLibre; // Optionnel
  final DateTime? dateResolution;

  AnomalieRituel({
    this.id,
    required this.dateObservation,
    this.rituelId,
    required this.actionRituelId,
    required this.actionRituelTitre,
    required this.typesAnomalies,
    required this.portee,
    this.lapinId,
    this.cageId,
    required this.severite,
    required this.actionSuggeree,
    this.actionPrise,
    this.statut = StatutAnomalie.nouveau,
    this.noteLibre,
    this.dateResolution,
  });

  /// Label résumé pour affichage
  String get resumeLabel {
    if (typesAnomalies.isEmpty) return 'Anomalie observée';
    if (typesAnomalies.length == 1) {
      return typesAnomalies.first.label;
    }
    return '${typesAnomalies.length} anomalies';
  }

  /// Emojis des types
  String get emojisTypes {
    return typesAnomalies.map((t) => t.emoji).join(' ');
  }

  /// Sévérité calculée (max des types)
  int get severiteCalculee {
    if (typesAnomalies.isEmpty) return 1;
    return typesAnomalies
        .map((t) => t.severiteDefaut)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Label de sévérité
  String get severiteLabel {
    switch (severite) {
      case 1:
        return 'Faible';
      case 2:
        return 'Moyenne';
      case 3:
        return 'Critique';
      default:
        return 'Inconnue';
    }
  }

  /// Couleur de sévérité
  String get severiteColorHex {
    switch (severite) {
      case 1:
        return '#FFC107'; // warning
      case 2:
        return '#FF9800'; // orange
      case 3:
        return '#F44336'; // error
      default:
        return '#9E9E9E'; // grey
    }
  }

  /// Est résolu ?
  bool get estResolu => statut == StatutAnomalie.resolu;

  /// Nécessite action ?
  bool get necessiteAction =>
      statut == StatutAnomalie.nouveau || statut == StatutAnomalie.enCours;

  AnomalieRituel copyWith({
    int? id,
    DateTime? dateObservation,
    int? rituelId,
    String? actionRituelId,
    String? actionRituelTitre,
    List<TypeAnomalie>? typesAnomalies,
    PorteeAnomalie? portee,
    int? lapinId,
    String? cageId,
    int? severite,
    ActionSuggeree? actionSuggeree,
    ActionSuggeree? actionPrise,
    StatutAnomalie? statut,
    String? noteLibre,
    DateTime? dateResolution,
  }) {
    return AnomalieRituel(
      id: id ?? this.id,
      dateObservation: dateObservation ?? this.dateObservation,
      rituelId: rituelId ?? this.rituelId,
      actionRituelId: actionRituelId ?? this.actionRituelId,
      actionRituelTitre: actionRituelTitre ?? this.actionRituelTitre,
      typesAnomalies: typesAnomalies ?? this.typesAnomalies,
      portee: portee ?? this.portee,
      lapinId: lapinId ?? this.lapinId,
      cageId: cageId ?? this.cageId,
      severite: severite ?? this.severite,
      actionSuggeree: actionSuggeree ?? this.actionSuggeree,
      actionPrise: actionPrise ?? this.actionPrise,
      statut: statut ?? this.statut,
      noteLibre: noteLibre ?? this.noteLibre,
      dateResolution: dateResolution ?? this.dateResolution,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date_observation': dateObservation.toIso8601String(),
      'rituel_id': rituelId,
      'action_rituel_id': actionRituelId,
      'action_rituel_titre': actionRituelTitre,
      'types_anomalies': jsonEncode(typesAnomalies.map((t) => t.name).toList()),
      'portee': portee.name,
      'lapin_id': lapinId,
      'cage_id': cageId,
      'severite': severite,
      'action_suggeree': actionSuggeree.name,
      'action_prise': actionPrise?.name,
      'statut': statut.name,
      'note_libre': noteLibre,
      'date_resolution': dateResolution?.toIso8601String(),
    };
  }

  factory AnomalieRituel.fromMap(Map<String, dynamic> map) {
    // Parser les types d'anomalies
    List<TypeAnomalie> types = [];
    final typesJson = map['types_anomalies'];
    if (typesJson is String && typesJson.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(typesJson);
      types = decoded
          .map(
            (t) => TypeAnomalie.values.firstWhere(
              (e) => e.name == t,
              orElse: () => TypeAnomalie.autre,
            ),
          )
          .toList();
    }

    return AnomalieRituel(
      id: map['id'] as int?,
      dateObservation: DateTime.parse(map['date_observation'] as String),
      rituelId: map['rituel_id'] as int?,
      actionRituelId: map['action_rituel_id'] as String,
      actionRituelTitre: map['action_rituel_titre'] as String,
      typesAnomalies: types,
      portee: PorteeAnomalie.values.firstWhere(
        (e) => e.name == map['portee'],
        orElse: () => PorteeAnomalie.individu,
      ),
      lapinId: map['lapin_id'] as int?,
      cageId: map['cage_id'] as String?,
      severite: map['severite'] as int? ?? 1,
      actionSuggeree: ActionSuggeree.values.firstWhere(
        (e) => e.name == map['action_suggeree'],
        orElse: () => ActionSuggeree.surveiller,
      ),
      actionPrise: map['action_prise'] != null
          ? ActionSuggeree.values.firstWhere(
              (e) => e.name == map['action_prise'],
              orElse: () => ActionSuggeree.aucune,
            )
          : null,
      statut: StatutAnomalie.values.firstWhere(
        (e) => e.name == map['statut'],
        orElse: () => StatutAnomalie.nouveau,
      ),
      noteLibre: map['note_libre'] as String?,
      dateResolution: map['date_resolution'] != null
          ? DateTime.parse(map['date_resolution'] as String)
          : null,
    );
  }
}

/// Statistiques d'anomalies pour le dashboard
class StatsAnomalies {
  final int totalAujourdhui;
  final int totalSemaine;
  final int nonResolues;
  final int critiques;
  final Map<TypeAnomalie, int> parType;
  final Map<PorteeAnomalie, int> parPortee;

  StatsAnomalies({
    required this.totalAujourdhui,
    required this.totalSemaine,
    required this.nonResolues,
    required this.critiques,
    required this.parType,
    required this.parPortee,
  });

  /// Type le plus fréquent
  TypeAnomalie? get typeLePlusFrequent {
    if (parType.isEmpty) return null;
    return parType.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// A des anomalies critiques ?
  bool get aDesCritiques => critiques > 0;
}
