import 'enums/statut_accouplement.dart';

/// Modèle de données pour un accouplement
class Accouplement {
  final int? id;
  final int maleId;
  final int femelleId;
  final DateTime dateAccouplement;
  final DateTime dateMiseBasPrevue;
  final StatutAccouplement statut;
  final String? notes;

  Accouplement({
    this.id,
    required this.maleId,
    required this.femelleId,
    required this.dateAccouplement,
    required this.dateMiseBasPrevue,
    this.statut = StatutAccouplement.enAttente,
    this.notes,
  });

  /// Calculer la date de mise bas prévue (31 jours après l'accouplement)
  static DateTime calculerDateMiseBasPrevue(DateTime dateAccouplement) {
    return dateAccouplement.add(const Duration(days: 31));
  }

  /// Calculer la date de palpation recommandée (10-12 jours après l'accouplement)
  DateTime get datePalpation {
    return dateAccouplement.add(const Duration(days: 11));
  }

  /// Calculer la date de préparation du nid (3 jours avant la mise bas)
  DateTime get datePreparationNid {
    return dateMiseBasPrevue.subtract(const Duration(days: 3));
  }

  /// Nombre de jours restants avant la mise bas
  int get joursAvantMiseBas {
    return dateMiseBasPrevue.difference(DateTime.now()).inDays;
  }

  /// L'accouplement est-il passé ?
  bool get estPasse {
    return DateTime.now().isAfter(dateMiseBasPrevue);
  }

  /// Créer une copie avec des modifications
  Accouplement copyWith({
    int? id,
    int? maleId,
    int? femelleId,
    DateTime? dateAccouplement,
    DateTime? dateMiseBasPrevue,
    StatutAccouplement? statut,
    String? notes,
  }) {
    return Accouplement(
      id: id ?? this.id,
      maleId: maleId ?? this.maleId,
      femelleId: femelleId ?? this.femelleId,
      dateAccouplement: dateAccouplement ?? this.dateAccouplement,
      dateMiseBasPrevue: dateMiseBasPrevue ?? this.dateMiseBasPrevue,
      statut: statut ?? this.statut,
      notes: notes ?? this.notes,
    );
  }

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'male_id': maleId,
      'femelle_id': femelleId,
      'date_accouplement': dateAccouplement.toIso8601String(),
      'date_mise_bas_prevue': dateMiseBasPrevue.toIso8601String(),
      'statut': statut.toDatabase(),
      'notes': notes,
    };
  }

  /// Créer depuis un Map de la base de données
  factory Accouplement.fromMap(Map<String, dynamic> map) {
    return Accouplement(
      id: map['id'] as int?,
      maleId: map['male_id'] as int,
      femelleId: map['femelle_id'] as int,
      dateAccouplement: DateTime.parse(map['date_accouplement'] as String),
      dateMiseBasPrevue: DateTime.parse(map['date_mise_bas_prevue'] as String),
      statut: StatutAccouplement.fromString(
        map['statut'] as String? ?? 'en_attente',
      ),
      notes: map['notes'] as String?,
    );
  }

  @override
  String toString() {
    return 'Accouplement{id: $id, male: $maleId, femelle: $femelleId, date: $dateAccouplement, statut: $statut}';
  }
}
