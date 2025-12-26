class CollecteFumier {
  final int? id;
  final DateTime dateCollecte;
  final double quantite; // en kg
  final String type; // 'crottes', 'urine', 'mixte'
  final String? destination; // 'vente', 'compost', 'utilisation_personnelle'
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
      'type': type,
      'destination': destination,
      'prix_vente': prixVente,
      'notes': notes,
    };
  }

  factory CollecteFumier.fromMap(Map<String, dynamic> map) {
    return CollecteFumier(
      id: map['id'] as int?,
      dateCollecte: DateTime.parse(map['date_collecte'] as String),
      quantite: (map['quantite'] as num).toDouble(),
      type: map['type'] as String,
      destination: map['destination'] as String?,
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
    String? type,
    String? destination,
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
