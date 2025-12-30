/// Modèle de données pour une portée
class Portee {
  final int? id;
  final int accouplementId;
  final DateTime dateMiseBasReelle;
  final int nombreNes;
  final int nombreVivants;
  final int nombreMorts;
  final String? notes;

  Portee({
    this.id,
    required this.accouplementId,
    required this.dateMiseBasReelle,
    required this.nombreNes,
    required this.nombreVivants,
    required this.nombreMorts,
    this.notes,
  });

  /// Taux de survie de la portée
  double get tauxSurvie {
    if (nombreNes == 0) return 0;
    return (nombreVivants / nombreNes) * 100;
  }

  /// Âge des lapereaux en jours
  int get ageEnJours {
    return DateTime.now().difference(dateMiseBasReelle).inDays;
  }

  /// Date de sevrage recommandée (35-42 jours)
  DateTime get dateSevrage {
    return dateMiseBasReelle.add(const Duration(days: 35));
  }

  /// Les lapereaux doivent-ils être sevrés ?
  bool get doitEtreSevres {
    return ageEnJours >= 35;
  }

  /// Créer une copie avec des modifications
  Portee copyWith({
    int? id,
    int? accouplementId,
    DateTime? dateMiseBasReelle,
    int? nombreNes,
    int? nombreVivants,
    int? nombreMorts,
    String? notes,
  }) {
    return Portee(
      id: id ?? this.id,
      accouplementId: accouplementId ?? this.accouplementId,
      dateMiseBasReelle: dateMiseBasReelle ?? this.dateMiseBasReelle,
      nombreNes: nombreNes ?? this.nombreNes,
      nombreVivants: nombreVivants ?? this.nombreVivants,
      nombreMorts: nombreMorts ?? this.nombreMorts,
      notes: notes ?? this.notes,
    );
  }

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accouplement_id': accouplementId,
      'date_mise_bas_reelle': dateMiseBasReelle.toIso8601String(),
      'nombre_nes': nombreNes,
      'nombre_vivants': nombreVivants,
      'nombre_morts': nombreMorts,
      'notes': notes,
    };
  }

  /// Créer depuis un Map de la base de données
  factory Portee.fromMap(Map<String, dynamic> map) {
    return Portee(
      id: map['id'] as int?,
      accouplementId: map['accouplement_id'] as int,
      dateMiseBasReelle: DateTime.parse(map['date_mise_bas_reelle'] as String),
      nombreNes: map['nombre_nes'] as int,
      nombreVivants: map['nombre_vivants'] as int,
      nombreMorts: map['nombre_morts'] as int,
      notes: map['notes'] as String?,
    );
  }

  @override
  String toString() {
    return 'Portee{id: $id, accouplement: $accouplementId, nés: $nombreNes, vivants: $nombreVivants}';
  }
}
