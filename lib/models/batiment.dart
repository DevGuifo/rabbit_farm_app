/// Modèle représentant un bâtiment d'élevage
class Batiment {
  final int? id;
  final String nom;
  final String? description;
  final DateTime dateCreation;

  Batiment({
    this.id,
    required this.nom,
    this.description,
    DateTime? dateCreation,
  }) : dateCreation = dateCreation ?? DateTime.now();

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'date_creation': dateCreation.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory Batiment.fromMap(Map<String, dynamic> map) {
    return Batiment(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      description: map['description'] as String?,
      dateCreation: DateTime.parse(map['date_creation'] as String),
    );
  }

  /// Créer une copie avec modifications
  Batiment copyWith({
    int? id,
    String? nom,
    String? description,
    DateTime? dateCreation,
  }) {
    return Batiment(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
}
