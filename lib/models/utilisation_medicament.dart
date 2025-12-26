class UtilisationMedicament {
  final int? id;
  final int medicamentId;
  final int? lapinId; // peut être null si traitement collectif
  final DateTime dateUtilisation;
  final double quantiteUtilisee;
  final String? motif;
  final String? notes;

  UtilisationMedicament({
    this.id,
    required this.medicamentId,
    this.lapinId,
    required this.dateUtilisation,
    required this.quantiteUtilisee,
    this.motif,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicament_id': medicamentId,
      'lapin_id': lapinId,
      'date_utilisation': dateUtilisation.toIso8601String(),
      'quantite_utilisee': quantiteUtilisee,
      'motif': motif,
      'notes': notes,
    };
  }

  factory UtilisationMedicament.fromMap(Map<String, dynamic> map) {
    return UtilisationMedicament(
      id: map['id'] as int?,
      medicamentId: map['medicament_id'] as int,
      lapinId: map['lapin_id'] as int?,
      dateUtilisation: DateTime.parse(map['date_utilisation'] as String),
      quantiteUtilisee: (map['quantite_utilisee'] as num).toDouble(),
      motif: map['motif'] as String?,
      notes: map['notes'] as String?,
    );
  }

  UtilisationMedicament copyWith({
    int? id,
    int? medicamentId,
    int? lapinId,
    DateTime? dateUtilisation,
    double? quantiteUtilisee,
    String? motif,
    String? notes,
  }) {
    return UtilisationMedicament(
      id: id ?? this.id,
      medicamentId: medicamentId ?? this.medicamentId,
      lapinId: lapinId ?? this.lapinId,
      dateUtilisation: dateUtilisation ?? this.dateUtilisation,
      quantiteUtilisee: quantiteUtilisee ?? this.quantiteUtilisee,
      motif: motif ?? this.motif,
      notes: notes ?? this.notes,
    );
  }
}
