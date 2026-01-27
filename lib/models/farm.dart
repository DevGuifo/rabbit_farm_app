/// Types d'élevage disponibles
enum TypeElevage { familial, semiProfessionnel, professionnel }

/// Tailles d'élevage estimées
enum TailleElevage {
  petite, // < 50
  moyenne, // 50-200
  grande, // 200-1000
  treGrande, // > 1000
}

/// Niveaux d'expérience de l'utilisateur
enum NiveauExperience { debutant, intermediaire, experimente }

/// Modèle représentant les informations de la ferme collectées durant l'onboarding
class Farm {
  final int? id;
  final int? userId; // Référence vers la table users
  final String? nom;
  final String? region;
  final String? pays;
  final TypeElevage typeElevage;
  final TailleElevage? tailleElevage;
  final DateTime dateCreation;
  final DateTime? dateModification;

  Farm({
    this.id,
    this.userId,
    this.nom,
    this.region,
    this.pays,
    required this.typeElevage,
    this.tailleElevage,
    required this.dateCreation,
    this.dateModification,
  });

  /// Convertir TypeElevage en string
  String get typeElevageString {
    switch (typeElevage) {
      case TypeElevage.familial:
        return 'familial';
      case TypeElevage.semiProfessionnel:
        return 'semi_professionnel';
      case TypeElevage.professionnel:
        return 'professionnel';
    }
  }

  /// Convertir TailleElevage en string
  String? get tailleElevageString {
    if (tailleElevage == null) return null;
    switch (tailleElevage!) {
      case TailleElevage.petite:
        return 'petite';
      case TailleElevage.moyenne:
        return 'moyenne';
      case TailleElevage.grande:
        return 'grande';
      case TailleElevage.treGrande:
        return 'tres_grande';
    }
  }

  /// Description conviviale de la taille d'élevage
  String? get tailleDescription {
    if (tailleElevage == null) return null;
    switch (tailleElevage!) {
      case TailleElevage.petite:
        return '< 50 lapins';
      case TailleElevage.moyenne:
        return '50-200 lapins';
      case TailleElevage.grande:
        return '200-1000 lapins';
      case TailleElevage.treGrande:
        return '> 1000 lapins';
    }
  }

  /// Description conviviale du type d'élevage
  String get typeDescription {
    switch (typeElevage) {
      case TypeElevage.familial:
        return 'Élevage familial';
      case TypeElevage.semiProfessionnel:
        return 'Élevage semi-professionnel';
      case TypeElevage.professionnel:
        return 'Élevage professionnel';
    }
  }

  /// Créer une Farm depuis une Map
  factory Farm.fromMap(Map<String, dynamic> map) {
    TypeElevage type;
    switch (map['type_elevage'] as String) {
      case 'familial':
        type = TypeElevage.familial;
        break;
      case 'semi_professionnel':
        type = TypeElevage.semiProfessionnel;
        break;
      case 'professionnel':
        type = TypeElevage.professionnel;
        break;
      default:
        type = TypeElevage.familial;
    }

    TailleElevage? taille;
    final tailleString = map['taille_elevage'] as String?;
    if (tailleString != null) {
      switch (tailleString) {
        case 'petite':
          taille = TailleElevage.petite;
          break;
        case 'moyenne':
          taille = TailleElevage.moyenne;
          break;
        case 'grande':
          taille = TailleElevage.grande;
          break;
        case 'tres_grande':
          taille = TailleElevage.treGrande;
          break;
      }
    }

    return Farm(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      nom: map['nom'] as String?,
      region: map['region'] as String?,
      pays: map['pays'] as String?,
      typeElevage: type,
      tailleElevage: taille,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: map['date_modification'] != null
          ? DateTime.parse(map['date_modification'] as String)
          : null,
    );
  }

  /// Convertir Farm en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'nom': nom,
      'region': region,
      'pays': pays,
      'type_elevage': typeElevageString,
      'taille_elevage': tailleElevageString,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification?.toIso8601String(),
    };
  }

  /// Créer une copie avec des modifications
  Farm copyWith({
    int? id,
    int? userId,
    String? nom,
    String? region,
    String? pays,
    TypeElevage? typeElevage,
    TailleElevage? tailleElevage,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Farm(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nom: nom ?? this.nom,
      region: region ?? this.region,
      pays: pays ?? this.pays,
      typeElevage: typeElevage ?? this.typeElevage,
      tailleElevage: tailleElevage ?? this.tailleElevage,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  @override
  String toString() {
    return 'Farm(id: $id, nom: $nom, type: $typeDescription, taille: $tailleDescription)';
  }
}
