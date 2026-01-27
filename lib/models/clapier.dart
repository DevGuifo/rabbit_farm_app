import 'enums/localisation_enums.dart';

/// Modèle représentant un clapier/zone dans un bâtiment
class Clapier {
  final int? id;
  final int batimentId;
  final String nom;
  final TypeClapier type;
  final String? description;
  final DateTime dateCreation;

  Clapier({
    this.id,
    required this.batimentId,
    required this.nom,
    this.type = TypeClapier.interieur,
    this.description,
    DateTime? dateCreation,
  }) : dateCreation = dateCreation ?? DateTime.now();

  /// Obtenir l'icône selon le type
  String get icone {
    switch (type) {
      case TypeClapier.interieur:
        return 'meeting_room';
      case TypeClapier.exterieur:
        return 'grass';
      case TypeClapier.quarantaine:
        return 'health_and_safety';
      default:
        return 'location_on';
    }
  }

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batiment_id': batimentId,
      'nom': nom,
      'type': type.toDatabase(),
      'description': description,
      'date_creation': dateCreation.toIso8601String(),
    };
  }

  /// Créer depuis Map de la base de données
  factory Clapier.fromMap(Map<String, dynamic> map) {
    return Clapier(
      id: map['id'] as int?,
      batimentId: map['batiment_id'] as int,
      nom: map['nom'] as String,
      type: TypeClapier.fromString(map['type'] as String? ?? 'interieur'),
      description: map['description'] as String?,
      dateCreation: DateTime.parse(map['date_creation'] as String),
    );
  }

  /// Créer une copie avec modifications
  Clapier copyWith({
    int? id,
    int? batimentId,
    String? nom,
    TypeClapier? type,
    String? description,
    DateTime? dateCreation,
  }) {
    return Clapier(
      id: id ?? this.id,
      batimentId: batimentId ?? this.batimentId,
      nom: nom ?? this.nom,
      type: type ?? this.type,
      description: description ?? this.description,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
}
