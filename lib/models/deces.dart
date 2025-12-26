/// Modèle représentant un décès de lapin
class Deces {
  final int? id;
  final int lapinId;
  final DateTime dateDeces;
  final int ageAuDecesJours;
  final String
  cause; // maladie, accident, mise_bas, naturel, euthanasie, inconnu
  final String circonstancesDetailees;
  final bool autopsieRealisee;
  final String? resultatsAutopsie;
  final String? mesuresPreventives;

  Deces({
    this.id,
    required this.lapinId,
    required this.dateDeces,
    required this.ageAuDecesJours,
    required this.cause,
    required this.circonstancesDetailees,
    this.autopsieRealisee = false,
    this.resultatsAutopsie,
    this.mesuresPreventives,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lapin_id': lapinId,
      'date_deces': dateDeces.toIso8601String(),
      'age_au_deces_jours': ageAuDecesJours,
      'cause': cause,
      'circonstances_detaillees': circonstancesDetailees,
      'autopsie_realisee': autopsieRealisee ? 1 : 0,
      'resultats_autopsie': resultatsAutopsie,
      'mesures_preventives': mesuresPreventives,
    };
  }

  /// Créer depuis un Map de la base de données
  factory Deces.fromMap(Map<String, dynamic> map) {
    return Deces(
      id: map['id'] as int?,
      lapinId: map['lapin_id'] as int,
      dateDeces: DateTime.parse(map['date_deces'] as String),
      ageAuDecesJours: map['age_au_deces_jours'] as int,
      cause: map['cause'] as String,
      circonstancesDetailees: map['circonstances_detaillees'] as String,
      autopsieRealisee: (map['autopsie_realisee'] as int) == 1,
      resultatsAutopsie: map['resultats_autopsie'] as String?,
      mesuresPreventives: map['mesures_preventives'] as String?,
    );
  }

  /// Créer une copie avec modifications
  Deces copyWith({
    int? id,
    int? lapinId,
    DateTime? dateDeces,
    int? ageAuDecesJours,
    String? cause,
    String? circonstancesDetailees,
    bool? autopsieRealisee,
    String? resultatsAutopsie,
    String? mesuresPreventives,
  }) {
    return Deces(
      id: id ?? this.id,
      lapinId: lapinId ?? this.lapinId,
      dateDeces: dateDeces ?? this.dateDeces,
      ageAuDecesJours: ageAuDecesJours ?? this.ageAuDecesJours,
      cause: cause ?? this.cause,
      circonstancesDetailees:
          circonstancesDetailees ?? this.circonstancesDetailees,
      autopsieRealisee: autopsieRealisee ?? this.autopsieRealisee,
      resultatsAutopsie: resultatsAutopsie ?? this.resultatsAutopsie,
      mesuresPreventives: mesuresPreventives ?? this.mesuresPreventives,
    );
  }

  @override
  String toString() {
    return 'Deces{id: $id, lapinId: $lapinId, cause: $cause, date: $dateDeces}';
  }
}

/// Énumération des causes de décès
class CauseDeces {
  static const String maladie = 'maladie';
  static const String accident = 'accident';
  static const String miseBas = 'mise_bas';
  static const String naturel = 'naturel';
  static const String euthanasie = 'euthanasie';
  static const String inconnu = 'inconnu';

  static const List<String> values = [
    maladie,
    accident,
    miseBas,
    naturel,
    euthanasie,
    inconnu,
  ];

  static String getLabel(String cause) {
    switch (cause) {
      case maladie:
        return 'Maladie';
      case accident:
        return 'Accident';
      case miseBas:
        return 'Mise bas difficile';
      case naturel:
        return 'Mort naturelle';
      case euthanasie:
        return 'Euthanasie';
      case inconnu:
        return 'Cause inconnue';
      default:
        return cause;
    }
  }
}
