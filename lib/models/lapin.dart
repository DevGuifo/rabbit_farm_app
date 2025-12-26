/// Modèle de données représentant un lapin
class Lapin {
  final int? id;
  final String nom;
  final String race;
  final String sexe;
  final DateTime dateNaissance;
  final double? poids;
  final String? statut;
  final String? localisation;
  final String? photoPath;
  final String? numeroIdentification;
  final String? couleur;
  final double? prixAchat;
  final String? origine;
  final String? notes;
  final String? caracteristiques;

  Lapin({
    this.id,
    required this.nom,
    required this.race,
    required this.sexe,
    required this.dateNaissance,
    this.poids,
    this.statut,
    this.localisation,
    this.photoPath,
    this.numeroIdentification,
    this.couleur,
    this.prixAchat,
    this.origine,
    this.notes,
    this.caracteristiques,
  });

  /// Calculer l'âge du lapin en jours
  int get ageEnJours {
    return DateTime.now().difference(dateNaissance).inDays;
  }

  /// Calculer l'âge du lapin en mois
  int get ageEnMois {
    return (ageEnJours / 30).floor();
  }

  /// Obtenir une représentation textuelle de l'âge
  String get ageFormate {
    if (ageEnJours < 30) {
      return '$ageEnJours jour${ageEnJours > 1 ? 's' : ''}';
    } else if (ageEnMois < 12) {
      return '$ageEnMois mois';
    } else {
      final annees = (ageEnMois / 12).floor();
      final moisRestants = ageEnMois % 12;
      if (moisRestants == 0) {
        return '$annees an${annees > 1 ? 's' : ''}';
      } else {
        return '$annees an${annees > 1 ? 's' : ''} et $moisRestants mois';
      }
    }
  }

  /// Créer une copie du lapin avec des modifications
  Lapin copyWith({
    int? id,
    String? nom,
    String? race,
    String? sexe,
    DateTime? dateNaissance,
    double? poids,
    String? statut,
    String? localisation,
    String? photoPath,
    String? numeroIdentification,
    String? couleur,
    double? prixAchat,
    String? origine,
    String? notes,
    String? caracteristiques,
  }) {
    return Lapin(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      race: race ?? this.race,
      sexe: sexe ?? this.sexe,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      poids: poids ?? this.poids,
      statut: statut ?? this.statut,
      localisation: localisation ?? this.localisation,
      photoPath: photoPath ?? this.photoPath,
      numeroIdentification: numeroIdentification ?? this.numeroIdentification,
      couleur: couleur ?? this.couleur,
      prixAchat: prixAchat ?? this.prixAchat,
      origine: origine ?? this.origine,
      notes: notes ?? this.notes,
      caracteristiques: caracteristiques ?? this.caracteristiques,
    );
  }

  /// Convertir le lapin en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'race': race,
      'sexe': sexe,
      'date_naissance': dateNaissance.toIso8601String(),
      'poids': poids,
      'statut': statut,
      'localisation': localisation,
      'photo_path': photoPath,
      'numero_identification': numeroIdentification,
      'couleur': couleur,
      'prix_achat': prixAchat,
      'origine': origine,
      'notes': notes,
      'caracteristiques': caracteristiques,
    };
  }

  /// Créer un lapin depuis un Map de la base de données
  factory Lapin.fromMap(Map<String, dynamic> map) {
    return Lapin(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      race: map['race'] as String,
      sexe: map['sexe'] as String,
      dateNaissance: DateTime.parse(map['date_naissance'] as String),
      poids: map['poids'] as double?,
      statut: map['statut'] as String?,
      localisation: map['localisation'] as String?,
      photoPath: map['photo_path'] as String?,
      numeroIdentification: map['numero_identification'] as String?,
      couleur: map['couleur'] as String?,
      prixAchat: map['prix_achat'] as double?,
      origine: map['origine'] as String?,
      notes: map['notes'] as String?,
      caracteristiques: map['caracteristiques'] as String?,
    );
  }

  @override
  String toString() {
    return 'Lapin{id: $id, nom: $nom, race: $race, sexe: $sexe, age: $ageFormate}';
  }
}
