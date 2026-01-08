/// Modèle pour les rituels quotidiens d'élevage
///
/// Un rituel est une série d'actions routinières (matin/soir) que l'éleveur
/// effectue chaque jour. Chaque action se valide en 1 clic sans saisie texte.
library;

import 'dart:convert';

/// Types de rituels disponibles
enum TypeRituel { matin, soir }

/// Résultat d'une action de rituel (1 clic = 1 action)
enum ResultatAction {
  nonFait, // ⏳ Pas encore fait
  normal, // ✅ Tout est normal
  anomalie, // ⚠️ Anomalie observée
  plusTard, // ⏰ Reporter à plus tard
}

/// Une action individuelle dans un rituel
class ActionRituel {
  final String id;
  final String titre;
  final String icone;
  final String description;
  ResultatAction resultat;
  DateTime? heureValidation;
  String? noteAnomalie; // Optionnel - uniquement si anomalie

  ActionRituel({
    required this.id,
    required this.titre,
    required this.icone,
    required this.description,
    this.resultat = ResultatAction.nonFait,
    this.heureValidation,
    this.noteAnomalie,
  });

  bool get estFait =>
      resultat != ResultatAction.nonFait && resultat != ResultatAction.plusTard;
  bool get aAnomalie => resultat == ResultatAction.anomalie;

  ActionRituel copyWith({
    String? id,
    String? titre,
    String? icone,
    String? description,
    ResultatAction? resultat,
    DateTime? heureValidation,
    String? noteAnomalie,
  }) {
    return ActionRituel(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      icone: icone ?? this.icone,
      description: description ?? this.description,
      resultat: resultat ?? this.resultat,
      heureValidation: heureValidation ?? this.heureValidation,
      noteAnomalie: noteAnomalie ?? this.noteAnomalie,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'icone': icone,
      'description': description,
      'resultat': resultat.name,
      'heureValidation': heureValidation?.toIso8601String(),
      'noteAnomalie': noteAnomalie,
    };
  }

  factory ActionRituel.fromMap(Map<String, dynamic> map) {
    return ActionRituel(
      id: map['id'] as String,
      titre: map['titre'] as String,
      icone: map['icone'] as String,
      description: map['description'] as String,
      resultat: ResultatAction.values.firstWhere(
        (e) => e.name == map['resultat'],
        orElse: () => ResultatAction.nonFait,
      ),
      heureValidation: map['heureValidation'] != null
          ? DateTime.parse(map['heureValidation'] as String)
          : null,
      noteAnomalie: map['noteAnomalie'] as String?,
    );
  }
}

/// Rituel complet (matin ou soir)
class Rituel {
  final int? id;
  final DateTime date;
  final TypeRituel type;
  final List<ActionRituel> actions;
  final DateTime dateCreation;
  DateTime? dateCompletion;

  Rituel({
    this.id,
    required this.date,
    required this.type,
    required this.actions,
    required this.dateCreation,
    this.dateCompletion,
  });

  /// Statut global du rituel
  bool get estComplet {
    return actions.every((a) => a.estFait);
  }

  /// Le rituel est en cours (au moins une action faite, mais pas toutes)
  bool get estEnCours {
    final faites = actions.where((a) => a.estFait).length;
    return faites > 0 && faites < actions.length;
  }

  /// Pourcentage de complétion
  double get pourcentageCompletion {
    if (actions.isEmpty) return 0;
    final faites = actions.where((a) => a.estFait).length;
    return faites / actions.length;
  }

  /// Nombre d'actions faites
  int get nombreActionsFaites => actions.where((a) => a.estFait).length;

  /// Nombre d'anomalies détectées
  int get nombreAnomalies => actions.where((a) => a.aAnomalie).length;

  /// Label du type
  String get labelType => type == TypeRituel.matin ? 'Matin' : 'Soir';

  /// Emoji du type
  String get emojiType => type == TypeRituel.matin ? '🌅' : '🌙';

  /// Statut textuel
  String get statutTexte {
    if (estComplet) return 'Terminé';
    if (nombreActionsFaites > 0) {
      return 'En cours ($nombreActionsFaites/${actions.length})';
    }
    return 'À faire';
  }

  Rituel copyWith({
    int? id,
    DateTime? date,
    TypeRituel? type,
    List<ActionRituel>? actions,
    DateTime? dateCreation,
    DateTime? dateCompletion,
  }) {
    return Rituel(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      actions: actions ?? this.actions,
      dateCreation: dateCreation ?? this.dateCreation,
      dateCompletion: dateCompletion ?? this.dateCompletion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'type': type.name,
      'actions': actions.map((a) => a.toMap()).toList(),
      'date_creation': dateCreation.toIso8601String(),
      'date_completion': dateCompletion?.toIso8601String(),
    };
  }

  factory Rituel.fromMap(Map<String, dynamic> map) {
    final actionsJson = map['actions'];
    List<ActionRituel> actionsList = [];

    if (actionsJson is String) {
      // JSON string from database
      final List<dynamic> decoded = actionsJson.isNotEmpty
          ? List<dynamic>.from(_parseJson(actionsJson))
          : [];
      actionsList = decoded
          .map((a) => ActionRituel.fromMap(a as Map<String, dynamic>))
          .toList();
    } else if (actionsJson is List) {
      actionsList = actionsJson
          .map((a) => ActionRituel.fromMap(a as Map<String, dynamic>))
          .toList();
    }

    return Rituel(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      type: TypeRituel.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TypeRituel.matin,
      ),
      actions: actionsList,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateCompletion: map['date_completion'] != null
          ? DateTime.parse(map['date_completion'] as String)
          : null,
    );
  }

  static List<dynamic> _parseJson(String json) {
    // Simple JSON parsing for list
    return jsonDecode(json) as List<dynamic>;
  }

  @override
  String toString() {
    return 'Rituel{type: $labelType, date: $date, statut: $statutTexte}';
  }
}

/// Actions par défaut pour le rituel du MATIN
List<ActionRituel> actionsRituelMatin() {
  return [
    ActionRituel(
      id: 'observation_matin',
      titre: 'Observation générale',
      icone: '👁️',
      description: 'Vérifier l\'état général des lapins',
    ),
    ActionRituel(
      id: 'nourrissage_matin',
      titre: 'Nourrissage',
      icone: '🥕',
      description: 'Distribuer la ration du matin',
    ),
    ActionRituel(
      id: 'abreuvement_matin',
      titre: 'Abreuvement',
      icone: '💧',
      description: 'Vérifier et remplir les abreuvoirs',
    ),
    ActionRituel(
      id: 'verification_sante',
      titre: 'Vérification sanitaire',
      icone: '🏥',
      description: 'Détecter les signes de maladie',
    ),
  ];
}

/// Actions par défaut pour le rituel du SOIR
List<ActionRituel> actionsRituelSoir() {
  return [
    ActionRituel(
      id: 'observation_soir',
      titre: 'Observation générale',
      icone: '👁️',
      description: 'Vérifier l\'état général des lapins',
    ),
    ActionRituel(
      id: 'nourrissage_soir',
      titre: 'Nourrissage',
      icone: '🥕',
      description: 'Distribuer la ration du soir',
    ),
    ActionRituel(
      id: 'abreuvement_soir',
      titre: 'Abreuvement',
      icone: '💧',
      description: 'Vérifier les abreuvoirs',
    ),
    ActionRituel(
      id: 'nettoyage',
      titre: 'Nettoyage',
      icone: '🧹',
      description: 'Nettoyer les déjections si nécessaire',
    ),
    ActionRituel(
      id: 'securisation',
      titre: 'Sécurisation',
      icone: '🔒',
      description: 'Fermer et sécuriser le clapier',
    ),
  ];
}
