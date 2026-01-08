/// Modèle de données pour un soin vétérinaire
class Soin {
  final int? id;
  final int lapinId;
  final DateTime date;
  final String type; // 'vaccination', 'traitement', 'vermifuge', 'autre'
  final String description;
  final String? medicament; // ⚠️ DEPRECATED - Utiliser medicamentId
  final int? medicamentId; // FK vers medicaments.id (Phase 2 Refactoring)
  final String? dosage;
  final DateTime? dateRappel;
  final String? notes;

  Soin({
    this.id,
    required this.lapinId,
    required this.date,
    required this.type,
    required this.description,
    this.medicament,
    this.medicamentId,
    this.dosage,
    this.dateRappel,
    this.notes,
  });

  /// Vérifier si un rappel est nécessaire
  bool get rappelNecessaire {
    if (dateRappel == null) return false;
    return DateTime.now().isAfter(dateRappel!);
  }

  /// Nombre de jours avant le rappel
  int? get joursAvantRappel {
    if (dateRappel == null) return null;
    return dateRappel!.difference(DateTime.now()).inDays;
  }

  /// Créer une copie avec des modifications
  Soin copyWith({
    int? id,
    int? lapinId,
    DateTime? date,
    String? type,
    String? description,
    String? medicament,
    int? medicamentId,
    String? dosage,
    DateTime? dateRappel,
    String? notes,
  }) {
    return Soin(
      id: id ?? this.id,
      lapinId: lapinId ?? this.lapinId,
      date: date ?? this.date,
      type: type ?? this.type,
      description: description ?? this.description,
      medicament: medicament ?? this.medicament,
      medicamentId: medicamentId ?? this.medicamentId,
      dosage: dosage ?? this.dosage,
      dateRappel: dateRappel ?? this.dateRappel,
      notes: notes ?? this.notes,
    );
  }

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lapin_id': lapinId,
      'date': date.toIso8601String(),
      'type': type,
      'description': description,
      'medicament': medicament,
      'medicament_id': medicamentId,
      'dosage': dosage,
      'date_rappel': dateRappel?.toIso8601String(),
      'notes': notes,
    };
  }

  /// Créer depuis un Map de la base de données
  factory Soin.fromMap(Map<String, dynamic> map) {
    return Soin(
      id: map['id'] as int?,
      lapinId: map['lapin_id'] as int,
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String,
      description: map['description'] as String,
      medicament: map['medicament'] as String?,
      medicamentId: map['medicament_id'] as int?,
      dosage: map['dosage'] as String?,
      dateRappel: map['date_rappel'] != null
          ? DateTime.parse(map['date_rappel'] as String)
          : null,
      notes: map['notes'] as String?,
    );
  }

  @override
  String toString() {
    return 'Soin{id: $id, lapin: $lapinId, type: $type, date: $date}';
  }
}
