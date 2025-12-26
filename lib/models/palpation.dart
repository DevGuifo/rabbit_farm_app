class Palpation {
  final int? id;
  final int accouplementId;
  final DateTime datePalpation;
  final bool gestante;
  final int? nombreFoetusPalpes;
  final String? observations;
  final String? realisePar;
  final double? temperatureCorporelle;

  Palpation({
    this.id,
    required this.accouplementId,
    required this.datePalpation,
    required this.gestante,
    this.nombreFoetusPalpes,
    this.observations,
    this.realisePar,
    this.temperatureCorporelle,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accouplement_id': accouplementId,
      'date_palpation': datePalpation.toIso8601String(),
      'gestante': gestante ? 1 : 0,
      'nombre_foetus_palpes': nombreFoetusPalpes,
      'observations': observations,
      'realise_par': realisePar,
      'temperature_corporelle': temperatureCorporelle,
    };
  }

  factory Palpation.fromMap(Map<String, dynamic> map) {
    return Palpation(
      id: map['id'] as int?,
      accouplementId: map['accouplement_id'] as int,
      datePalpation: DateTime.parse(map['date_palpation'] as String),
      gestante: (map['gestante'] as int) == 1,
      nombreFoetusPalpes: map['nombre_foetus_palpes'] as int?,
      observations: map['observations'] as String?,
      realisePar: map['realise_par'] as String?,
      temperatureCorporelle: map['temperature_corporelle'] != null
          ? (map['temperature_corporelle'] as num).toDouble()
          : null,
    );
  }

  /// Vérifier si la palpation est dans la période recommandée (J10-J12)
  bool estDansPeriodeRecommandee(DateTime dateAccouplement) {
    final joursDepuisAccouplement = datePalpation
        .difference(dateAccouplement)
        .inDays;
    return joursDepuisAccouplement >= 10 && joursDepuisAccouplement <= 12;
  }

  Palpation copyWith({
    int? id,
    int? accouplementId,
    DateTime? datePalpation,
    bool? gestante,
    int? nombreFoetusPalpes,
    String? observations,
    String? realisePar,
    double? temperatureCorporelle,
  }) {
    return Palpation(
      id: id ?? this.id,
      accouplementId: accouplementId ?? this.accouplementId,
      datePalpation: datePalpation ?? this.datePalpation,
      gestante: gestante ?? this.gestante,
      nombreFoetusPalpes: nombreFoetusPalpes ?? this.nombreFoetusPalpes,
      observations: observations ?? this.observations,
      realisePar: realisePar ?? this.realisePar,
      temperatureCorporelle:
          temperatureCorporelle ?? this.temperatureCorporelle,
    );
  }
}
