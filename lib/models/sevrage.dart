class Sevrage {
  final int? id;
  final int porteeId;
  final DateTime dateSevrage;
  final int nombreLapereaux;
  final double? poidsMoyenSevrage; // kg
  final String? nouvelleCage;
  final String? observations;
  final String? alimentationPostSevrage;

  Sevrage({
    this.id,
    required this.porteeId,
    required this.dateSevrage,
    required this.nombreLapereaux,
    this.poidsMoyenSevrage,
    this.nouvelleCage,
    this.observations,
    this.alimentationPostSevrage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'portee_id': porteeId,
      'date_sevrage': dateSevrage.toIso8601String(),
      'nombre_lapereaux': nombreLapereaux,
      'poids_moyen_sevrage': poidsMoyenSevrage,
      'nouvelle_cage': nouvelleCage,
      'observations': observations,
      'alimentation_post_sevrage': alimentationPostSevrage,
    };
  }

  factory Sevrage.fromMap(Map<String, dynamic> map) {
    return Sevrage(
      id: map['id'] as int?,
      porteeId: map['portee_id'] as int,
      dateSevrage: DateTime.parse(map['date_sevrage'] as String),
      nombreLapereaux: map['nombre_lapereaux'] as int,
      poidsMoyenSevrage: map['poids_moyen_sevrage'] != null
          ? (map['poids_moyen_sevrage'] as num).toDouble()
          : null,
      nouvelleCage: map['nouvelle_cage'] as String?,
      observations: map['observations'] as String?,
      alimentationPostSevrage: map['alimentation_post_sevrage'] as String?,
    );
  }

  Sevrage copyWith({
    int? id,
    int? porteeId,
    DateTime? dateSevrage,
    int? nombreLapereaux,
    double? poidsMoyenSevrage,
    String? nouvelleCage,
    String? observations,
    String? alimentationPostSevrage,
  }) {
    return Sevrage(
      id: id ?? this.id,
      porteeId: porteeId ?? this.porteeId,
      dateSevrage: dateSevrage ?? this.dateSevrage,
      nombreLapereaux: nombreLapereaux ?? this.nombreLapereaux,
      poidsMoyenSevrage: poidsMoyenSevrage ?? this.poidsMoyenSevrage,
      nouvelleCage: nouvelleCage ?? this.nouvelleCage,
      observations: observations ?? this.observations,
      alimentationPostSevrage:
          alimentationPostSevrage ?? this.alimentationPostSevrage,
    );
  }
}
