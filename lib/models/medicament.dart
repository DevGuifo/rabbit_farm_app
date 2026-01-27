import 'enums/medicament_enums.dart';

class Medicament {
  final int? id;
  final String nom;
  final TypeMedicament type;
  final double quantiteStock; // en ml ou g selon unite
  final String unite; // 'ml', 'g', 'comprime', 'dose'
  final double? seuilAlerte; // quantité minimum avant alerte
  final DateTime? dateExpiration;
  final double? prixUnitaire;
  final String? posologie;
  final String? notes;

  Medicament({
    this.id,
    required this.nom,
    required this.type,
    required this.quantiteStock,
    required this.unite,
    this.seuilAlerte,
    this.dateExpiration,
    this.prixUnitaire,
    this.posologie,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'type': type.toDatabase(),
      'quantite_stock': quantiteStock,
      'unite': unite,
      'seuil_alerte': seuilAlerte,
      'date_expiration': dateExpiration?.toIso8601String(),
      'prix_unitaire': prixUnitaire,
      'posologie': posologie,
      'notes': notes,
    };
  }

  factory Medicament.fromMap(Map<String, dynamic> map) {
    return Medicament(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      type: TypeMedicament.fromString(map['type'] as String),
      quantiteStock: (map['quantite_stock'] as num).toDouble(),
      unite: map['unite'] as String,
      seuilAlerte: map['seuil_alerte'] != null
          ? (map['seuil_alerte'] as num).toDouble()
          : null,
      dateExpiration: map['date_expiration'] != null
          ? DateTime.parse(map['date_expiration'] as String)
          : null,
      prixUnitaire: map['prix_unitaire'] != null
          ? (map['prix_unitaire'] as num).toDouble()
          : null,
      posologie: map['posologie'] as String?,
      notes: map['notes'] as String?,
    );
  }

  bool get estEnRupture => quantiteStock <= 0;

  bool get estSousSeuilAlerte =>
      seuilAlerte != null && quantiteStock <= seuilAlerte!;

  bool get estPerime =>
      dateExpiration != null && dateExpiration!.isBefore(DateTime.now());

  bool get expireSoon =>
      dateExpiration != null &&
      dateExpiration!.difference(DateTime.now()).inDays <= 30 &&
      !estPerime;

  Medicament copyWith({
    int? id,
    String? nom,
    TypeMedicament? type,
    double? quantiteStock,
    String? unite,
    double? seuilAlerte,
    DateTime? dateExpiration,
    double? prixUnitaire,
    String? posologie,
    String? notes,
  }) {
    return Medicament(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      type: type ?? this.type,
      quantiteStock: quantiteStock ?? this.quantiteStock,
      unite: unite ?? this.unite,
      seuilAlerte: seuilAlerte ?? this.seuilAlerte,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      posologie: posologie ?? this.posologie,
      notes: notes ?? this.notes,
    );
  }
}
