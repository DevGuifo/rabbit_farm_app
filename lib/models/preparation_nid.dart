class PreparationNid {
  final int? id;
  final int accouplementId;
  final DateTime datePreparation;
  final String typeMateriau; // ⚠️ DEPRECATED - Utiliser materiauId
  final int? materiauId; // FK vers materiaux.id (Phase 2 Refactoring)
  final double? quantiteMateriau; // kg
  final bool boiteNidInstallee;
  final String? dispositionNid;
  final String? observations;
  final double? temperatureAmbiance;

  PreparationNid({
    this.id,
    required this.accouplementId,
    required this.datePreparation,
    required this.typeMateriau,
    this.materiauId,
    this.quantiteMateriau,
    required this.boiteNidInstallee,
    this.dispositionNid,
    this.observations,
    this.temperatureAmbiance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accouplement_id': accouplementId,
      'date_preparation': datePreparation.toIso8601String(),
      'type_materiau': typeMateriau,
      'materiau_id': materiauId,
      'quantite_materiau': quantiteMateriau,
      'boite_nid_installee': boiteNidInstallee ? 1 : 0,
      'disposition_nid': dispositionNid,
      'observations': observations,
      'temperature_ambiance': temperatureAmbiance,
    };
  }

  factory PreparationNid.fromMap(Map<String, dynamic> map) {
    return PreparationNid(
      id: map['id'] as int?,
      accouplementId: map['accouplement_id'] as int,
      datePreparation: DateTime.parse(map['date_preparation'] as String),
      typeMateriau: map['type_materiau'] as String,
      materiauId: map['materiau_id'] as int?,
      quantiteMateriau: map['quantite_materiau'] != null
          ? (map['quantite_materiau'] as num).toDouble()
          : null,
      boiteNidInstallee: (map['boite_nid_installee'] as int) == 1,
      dispositionNid: map['disposition_nid'] as String?,
      observations: map['observations'] as String?,
      temperatureAmbiance: map['temperature_ambiance'] != null
          ? (map['temperature_ambiance'] as num).toDouble()
          : null,
    );
  }

  /// Vérifier si préparé au bon moment (J28 recommandé)
  bool estAuBonMoment(DateTime dateAccouplement) {
    final joursDepuisAccouplement = datePreparation
        .difference(dateAccouplement)
        .inDays;
    return joursDepuisAccouplement >= 27 && joursDepuisAccouplement <= 29;
  }

  PreparationNid copyWith({
    int? id,
    int? accouplementId,
    DateTime? datePreparation,
    String? typeMateriau,
    int? materiauId,
    double? quantiteMateriau,
    bool? boiteNidInstallee,
    String? dispositionNid,
    String? observations,
    double? temperatureAmbiance,
  }) {
    return PreparationNid(
      id: id ?? this.id,
      accouplementId: accouplementId ?? this.accouplementId,
      datePreparation: datePreparation ?? this.datePreparation,
      typeMateriau: typeMateriau ?? this.typeMateriau,
      materiauId: materiauId ?? this.materiauId,
      quantiteMateriau: quantiteMateriau ?? this.quantiteMateriau,
      boiteNidInstallee: boiteNidInstallee ?? this.boiteNidInstallee,
      dispositionNid: dispositionNid ?? this.dispositionNid,
      observations: observations ?? this.observations,
      temperatureAmbiance: temperatureAmbiance ?? this.temperatureAmbiance,
    );
  }
}
