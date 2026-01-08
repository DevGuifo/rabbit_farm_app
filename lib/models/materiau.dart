/// Modèle représentant un matériau utilisé pour les nids
class Materiau {
  final int? id;
  final String nom;
  final String? description;
  final double? prixUnitaire;
  final double? stockActuel;

  Materiau({
    this.id,
    required this.nom,
    this.description,
    this.prixUnitaire,
    this.stockActuel,
  });

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'prix_unitaire': prixUnitaire,
      'stock_actuel': stockActuel,
    };
  }

  /// Créer depuis Map de la base de données
  factory Materiau.fromMap(Map<String, dynamic> map) {
    return Materiau(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      description: map['description'] as String?,
      prixUnitaire: map['prix_unitaire'] != null
          ? (map['prix_unitaire'] as num).toDouble()
          : null,
      stockActuel: map['stock_actuel'] != null
          ? (map['stock_actuel'] as num).toDouble()
          : null,
    );
  }

  /// Créer une copie avec modifications
  Materiau copyWith({
    int? id,
    String? nom,
    String? description,
    double? prixUnitaire,
    double? stockActuel,
  }) {
    return Materiau(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      stockActuel: stockActuel ?? this.stockActuel,
    );
  }

  @override
  String toString() {
    return 'Materiau{id: $id, nom: $nom}';
  }
}
