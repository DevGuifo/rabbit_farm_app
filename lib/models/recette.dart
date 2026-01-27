import 'enums/finance_enums.dart';

/// Modèle de données pour une recette (revenu)
class Recette {
  final int? id;
  final DateTime date;
  final CategorieRecette categorie;
  final double montant;
  final String description;
  final int? lapinId; // Optionnel : lien vers un lapin vendu
  final String? notes;

  Recette({
    this.id,
    required this.date,
    required this.categorie,
    required this.montant,
    required this.description,
    this.lapinId,
    this.notes,
  });

  /// Créer une copie avec des modifications
  Recette copyWith({
    int? id,
    DateTime? date,
    CategorieRecette? categorie,
    double? montant,
    String? description,
    int? lapinId,
    String? notes,
  }) {
    return Recette(
      id: id ?? this.id,
      date: date ?? this.date,
      categorie: categorie ?? this.categorie,
      montant: montant ?? this.montant,
      description: description ?? this.description,
      lapinId: lapinId ?? this.lapinId,
      notes: notes ?? this.notes,
    );
  }

  /// Convertir en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'categorie': categorie.toDatabase(),
      'montant': montant,
      'description': description,
      'lapin_id': lapinId,
      'notes': notes,
    };
  }

  /// Créer depuis un Map de la base de données
  factory Recette.fromMap(Map<String, dynamic> map) {
    return Recette(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      categorie: CategorieRecette.fromString(map['categorie'] as String),
      montant: (map['montant'] as num).toDouble(),
      description: map['description'] as String,
      lapinId: map['lapin_id'] as int?,
      notes: map['notes'] as String?,
    );
  }

  @override
  String toString() {
    return 'Recette{id: $id, date: $date, montant: $montant€, categorie: $categorie}';
  }
}
