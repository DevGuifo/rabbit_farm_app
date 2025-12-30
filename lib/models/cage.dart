/// Modèle représentant une cage dans un clapier
class Cage {
  final int? id;
  final int clapierId;
  final String numero;
  final String type; // 'individuelle', 'collective', 'nid'
  final int capacite;
  final String? description;
  final DateTime dateCreation;

  Cage({
    this.id,
    required this.clapierId,
    required this.numero,
    required this.type,
    required this.capacite,
    this.description,
    DateTime? dateCreation,
  }) : dateCreation = dateCreation ?? DateTime.now();

  /// Obtenir le statut de la cage basé sur l'occupation
  String getStatut(int occupants) {
    if (occupants == 0) return 'vide';
    if (occupants > capacite) return 'surpeuplee';
    if (occupants == capacite) return 'pleine';
    return 'normale';
  }

  /// Vérifier si la cage est disponible
  bool estDisponible(int occupants) {
    return occupants < capacite;
  }

  /// Obtenir la couleur selon le statut
  int getCouleurStatut(int occupants) {
    final statut = getStatut(occupants);
    switch (statut) {
      case 'vide':
        return 0xFF9E9E9E; // Gris
      case 'normale':
        return 0xFF4CAF50; // Vert
      case 'pleine':
        return 0xFFFF9800; // Orange
      case 'surpeuplee':
        return 0xFFFF5722; // Rouge
      default:
        return 0xFF9E9E9E;
    }
  }

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clapier_id': clapierId,
      'numero': numero,
      'type': type,
      'capacite': capacite,
      'description': description,
      'date_creation': dateCreation.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory Cage.fromMap(Map<String, dynamic> map) {
    return Cage(
      id: map['id'] as int?,
      clapierId: map['clapier_id'] as int,
      numero: map['numero'] as String,
      type: map['type'] as String,
      capacite: map['capacite'] as int,
      description: map['description'] as String?,
      dateCreation: DateTime.parse(map['date_creation'] as String),
    );
  }

  /// Créer une copie avec modifications
  Cage copyWith({
    int? id,
    int? clapierId,
    String? numero,
    String? type,
    int? capacite,
    String? description,
    DateTime? dateCreation,
  }) {
    return Cage(
      id: id ?? this.id,
      clapierId: clapierId ?? this.clapierId,
      numero: numero ?? this.numero,
      type: type ?? this.type,
      capacite: capacite ?? this.capacite,
      description: description ?? this.description,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
}
