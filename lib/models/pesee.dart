/// Modèle de données pour une pesée
class Pesee {
  final int? id;
  final int lapinId;
  final DateTime date;
  final double poids; // en kg
  final String? notes;

  Pesee({
    this.id,
    required this.lapinId,
    required this.date,
    required this.poids,
    this.notes,
  });

  /// Créer une copie avec des modifications
  Pesee copyWith({
    int? id,
    int? lapinId,
    DateTime? date,
    double? poids,
    String? notes,
  }) {
    return Pesee(
      id: id ?? this.id,
      lapinId: lapinId ?? this.lapinId,
      date: date ?? this.date,
      poids: poids ?? this.poids,
      notes: notes ?? this.notes,
    );
  }

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lapin_id': lapinId,
      'date': date.toIso8601String(),
      'poids': poids,
      'notes': notes,
    };
  }

  /// Créer depuis un Map de la base de données
  factory Pesee.fromMap(Map<String, dynamic> map) {
    return Pesee(
      id: map['id'] as int?,
      lapinId: map['lapin_id'] as int,
      date: DateTime.parse(map['date'] as String),
      poids: (map['poids'] as num).toDouble(),
      notes: map['notes'] as String?,
    );
  }

  @override
  String toString() {
    return 'Pesee{id: $id, lapin: $lapinId, date: $date, poids: ${poids}kg}';
  }
}
