class Quarantaine {
  final int? id;
  final int lapinId;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final String
  motif; // 'nouveau', 'maladie', 'isolement_sanitaire', 'observation'
  final String? symptomes;
  final String? traitement;
  final String statut; // 'en_cours', 'termine', 'transfere'
  final String? notes;

  Quarantaine({
    this.id,
    required this.lapinId,
    required this.dateDebut,
    this.dateFin,
    required this.motif,
    this.symptomes,
    this.traitement,
    required this.statut,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lapin_id': lapinId,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin?.toIso8601String(),
      'motif': motif,
      'symptomes': symptomes,
      'traitement': traitement,
      'statut': statut,
      'notes': notes,
    };
  }

  factory Quarantaine.fromMap(Map<String, dynamic> map) {
    return Quarantaine(
      id: map['id'] as int?,
      lapinId: map['lapin_id'] as int,
      dateDebut: DateTime.parse(map['date_debut'] as String),
      dateFin: map['date_fin'] != null
          ? DateTime.parse(map['date_fin'] as String)
          : null,
      motif: map['motif'] as String,
      symptomes: map['symptomes'] as String?,
      traitement: map['traitement'] as String?,
      statut: map['statut'] as String,
      notes: map['notes'] as String?,
    );
  }

  int get dureeJours {
    final fin = dateFin ?? DateTime.now();
    return fin.difference(dateDebut).inDays;
  }

  bool get estEnCours => statut == 'en_cours';

  Quarantaine copyWith({
    int? id,
    int? lapinId,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? motif,
    String? symptomes,
    String? traitement,
    String? statut,
    String? notes,
  }) {
    return Quarantaine(
      id: id ?? this.id,
      lapinId: lapinId ?? this.lapinId,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      motif: motif ?? this.motif,
      symptomes: symptomes ?? this.symptomes,
      traitement: traitement ?? this.traitement,
      statut: statut ?? this.statut,
      notes: notes ?? this.notes,
    );
  }
}
