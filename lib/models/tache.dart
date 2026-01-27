import 'enums/tache_enums.dart';

/// Modèle de données pour une tâche
class Tache {
  final int? id;
  final String titre;
  final String? description;
  final DateTime datePlanification;
  final PrioriteTache priorite;
  final CategorieTache categorie;
  final StatutTache statut;
  final int? lapinId; // Optionnel - association à un lapin
  final bool estRecurrente;
  final FrequenceRecurrence? frequenceRecurrence;
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
    this.priorite = PrioriteTache.normale,
    this.categorie = CategorieTache.autre,
    this.statut = StatutTache.aFaire,
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
    if (statut == StatutTache.terminee || statut == StatutTache.annulee) {
      return false;
    }
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
    return datePlanification.isAfter(
          debutSemaine.subtract(const Duration(days: 1)),
        ) &&
        datePlanification.isBefore(finSemaine.add(const Duration(days: 1)));
  }

  /// Créer une copie avec des modifications
  Tache copyWith({
    int? id,
    String? titre,
    String? description,
    DateTime? datePlanification,
    PrioriteTache? priorite,
    CategorieTache? categorie,
    StatutTache? statut,
    int? lapinId,
    bool? estRecurrente,
    FrequenceRecurrence? frequenceRecurrence,
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
      'priorite': priorite.toDatabase(),
      'categorie': categorie.toDatabase(),
      'statut': statut.toDatabase(),
      'lapin_id': lapinId,
      'est_recurrente': estRecurrente ? 1 : 0,
      'frequence_recurrence': frequenceRecurrence?.toDatabase(),
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
      priorite: PrioriteTache.fromString(
        map['priorite'] as String? ?? 'normale',
      ),
      categorie: CategorieTache.fromString(
        map['categorie'] as String? ?? 'autre',
      ),
      statut: StatutTache.fromString(map['statut'] as String? ?? 'a_faire'),
      lapinId: map['lapin_id'] as int?,
      estRecurrente: (map['est_recurrente'] as int? ?? 0) == 1,
      frequenceRecurrence: map['frequence_recurrence'] != null
          ? FrequenceRecurrence.fromString(
              map['frequence_recurrence'] as String,
            )
          : null,
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
