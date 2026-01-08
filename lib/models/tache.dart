/// Modèle de données pour une tâche
class Tache {
  final int? id;
  final String titre;
  final String? description;
  final DateTime datePlanification;
  final String priorite; // 'haute', 'normale', 'basse'
  final String categorie; // 'reproduction', 'sante', 'alimentation', 'entretien', 'administratif', 'autre'
  final String statut; // 'a_faire', 'en_cours', 'terminee', 'annulee', 'reportee'
  final int? lapinId; // Optionnel - association à un lapin
  final bool estRecurrente;
  final String? frequenceRecurrence; // 'quotidienne', 'hebdomadaire', 'mensuelle', null
  final DateTime dateCreation;
  final DateTime? dateModification;
  final DateTime? dateCompletion;
  final String? notes;
  final String? pieceJointePath; // Chemin vers photo/document

  Tache({
    this.id,
    required this.titre,
    this.description,
    required this.datePlanification,
    this.priorite = 'normale',
    this.categorie = 'autre',
    this.statut = 'a_faire',
    this.lapinId,
    this.estRecurrente = false,
    this.frequenceRecurrence,
    required this.dateCreation,
    this.dateModification,
    this.dateCompletion,
    this.notes,
    this.pieceJointePath,
  });

  /// Vérifier si la tâche est en retard
  bool get estEnRetard {
    if (statut == 'terminee' || statut == 'annulee') return false;
    return DateTime.now().isAfter(datePlanification);
  }

  /// Nombre de jours avant/après l'échéance
  int get joursAvantEcheance {
    final difference = datePlanification.difference(DateTime.now()).inDays;
    return difference;
  }

  /// Vérifier si la tâche est pour aujourd'hui
  bool get estAujourdhui {
    final now = DateTime.now();
    return datePlanification.year == now.year &&
        datePlanification.month == now.month &&
        datePlanification.day == now.day;
  }

  /// Vérifier si la tâche est pour cette semaine
  bool get estCetteSemaine {
    final now = DateTime.now();
    final debutSemaine = now.subtract(Duration(days: now.weekday - 1));
    final finSemaine = debutSemaine.add(const Duration(days: 6));
    return datePlanification.isAfter(debutSemaine.subtract(const Duration(days: 1))) &&
        datePlanification.isBefore(finSemaine.add(const Duration(days: 1)));
  }

  /// Créer une copie avec des modifications
  Tache copyWith({
    int? id,
    String? titre,
    String? description,
    DateTime? datePlanification,
    String? priorite,
    String? categorie,
    String? statut,
    int? lapinId,
    bool? estRecurrente,
    String? frequenceRecurrence,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? dateCompletion,
    String? notes,
    String? pieceJointePath,
  }) {
    return Tache(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      datePlanification: datePlanification ?? this.datePlanification,
      priorite: priorite ?? this.priorite,
      categorie: categorie ?? this.categorie,
      statut: statut ?? this.statut,
      lapinId: lapinId ?? this.lapinId,
      estRecurrente: estRecurrente ?? this.estRecurrente,
      frequenceRecurrence: frequenceRecurrence ?? this.frequenceRecurrence,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      dateCompletion: dateCompletion ?? this.dateCompletion,
      notes: notes ?? this.notes,
      pieceJointePath: pieceJointePath ?? this.pieceJointePath,
    );
  }

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'date_planification': datePlanification.toIso8601String(),
      'priorite': priorite,
      'categorie': categorie,
      'statut': statut,
      'lapin_id': lapinId,
      'est_recurrente': estRecurrente ? 1 : 0,
      'frequence_recurrence': frequenceRecurrence,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification?.toIso8601String(),
      'date_completion': dateCompletion?.toIso8601String(),
      'notes': notes,
      'piece_jointe_path': pieceJointePath,
    };
  }

  /// Créer depuis un Map de la base de données
  factory Tache.fromMap(Map<String, dynamic> map) {
    return Tache(
      id: map['id'] as int?,
      titre: map['titre'] as String,
      description: map['description'] as String?,
      datePlanification: DateTime.parse(map['date_planification'] as String),
      priorite: map['priorite'] as String? ?? 'normale',
      categorie: map['categorie'] as String? ?? 'autre',
      statut: map['statut'] as String? ?? 'a_faire',
      lapinId: map['lapin_id'] as int?,
      estRecurrente: (map['est_recurrente'] as int? ?? 0) == 1,
      frequenceRecurrence: map['frequence_recurrence'] as String?,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: map['date_modification'] != null
          ? DateTime.parse(map['date_modification'] as String)
          : null,
      dateCompletion: map['date_completion'] != null
          ? DateTime.parse(map['date_completion'] as String)
          : null,
      notes: map['notes'] as String?,
      pieceJointePath: map['piece_jointe_path'] as String?,
    );
  }

  @override
  String toString() {
    return 'Tache(id: $id, titre: $titre, statut: $statut, datePlanification: $datePlanification)';
  }
}

