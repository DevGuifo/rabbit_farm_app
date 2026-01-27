import 'enums/fumier_enums.dart';

class CollecteFumier {
  final int? id;
  final DateTime dateCollecte;
  final double quantite; // en kg
  final TypeFumier type;
  final DestinationFumier? destination;
  final double? prixVente; // si vendu
  final String? notes;

  CollecteFumier({
    this.id,
    required this.dateCollecte,
    required this.quantite,
    required this.type,
    this.destination,
    this.prixVente,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date_collecte': dateCollecte.toIso8601String(),
      'quantite': quantite,
      'type': type.toDatabase(),
      'destination': destination?.toDatabase(),
      'prix_vente': prixVente,
      'notes': notes,
    };
  }

  factory CollecteFumier.fromMap(Map<String, dynamic> map) {
    return CollecteFumier(
      id: map['id'] as int?,
      dateCollecte: DateTime.parse(map['date_collecte'] as String),
      quantite: (map['quantite'] as num).toDouble(),
      type: TypeFumier.fromString(map['type'] as String),
      destination: map['destination'] != null
          ? DestinationFumier.fromString(map['destination'] as String)
          : null,
      prixVente: map['prix_vente'] != null
          ? (map['prix_vente'] as num).toDouble()
          : null,
      notes: map['notes'] as String?,
    );
  }

  CollecteFumier copyWith({
    int? id,
    DateTime? dateCollecte,
    double? quantite,
    TypeFumier? type,
    DestinationFumier? destination,
    double? prixVente,
    String? notes,
  }) {
    return CollecteFumier(
      id: id ?? this.id,
      dateCollecte: dateCollecte ?? this.dateCollecte,
      quantite: quantite ?? this.quantite,
      type: type ?? this.type,
      destination: destination ?? this.destination,
      prixVente: prixVente ?? this.prixVente,
      notes: notes ?? this.notes,
    );
  }
}
