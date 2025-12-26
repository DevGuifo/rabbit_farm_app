class Reforme {
  final int? id;
  final int lapinId;
  final DateTime dateReforme;
  final String
  motif; // 'age', 'improductif', 'maladie', 'genetique', 'comportement', 'autre'
  final String destination; // 'vente', 'abattage', 'don', 'autre'
  final double? prixVente;
  final double? poidsVif;
  final String? notes;

  Reforme({
    this.id,
    required this.lapinId,
    required this.dateReforme,
    required this.motif,
    required this.destination,
    this.prixVente,
    this.poidsVif,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lapin_id': lapinId,
      'date_reforme': dateReforme.toIso8601String(),
      'motif': motif,
      'destination': destination,
      'prix_vente': prixVente,
      'poids_vif': poidsVif,
      'notes': notes,
    };
  }

  factory Reforme.fromMap(Map<String, dynamic> map) {
    return Reforme(
      id: map['id'] as int?,
      lapinId: map['lapin_id'] as int,
      dateReforme: DateTime.parse(map['date_reforme'] as String),
      motif: map['motif'] as String,
      destination: map['destination'] as String,
      prixVente: map['prix_vente'] != null
          ? (map['prix_vente'] as num).toDouble()
          : null,
      poidsVif: map['poids_vif'] != null
          ? (map['poids_vif'] as num).toDouble()
          : null,
      notes: map['notes'] as String?,
    );
  }

  Reforme copyWith({
    int? id,
    int? lapinId,
    DateTime? dateReforme,
    String? motif,
    String? destination,
    double? prixVente,
    double? poidsVif,
    String? notes,
  }) {
    return Reforme(
      id: id ?? this.id,
      lapinId: lapinId ?? this.lapinId,
      dateReforme: dateReforme ?? this.dateReforme,
      motif: motif ?? this.motif,
      destination: destination ?? this.destination,
      prixVente: prixVente ?? this.prixVente,
      poidsVif: poidsVif ?? this.poidsVif,
      notes: notes ?? this.notes,
    );
  }
}
