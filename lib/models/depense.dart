import 'enums/finance_enums.dart';

/// Modèle de données pour une dépense
class Depense {
  final int? id;
  final DateTime date;
  final CategorieDepense categorie;
  final double montant;
  final String description;
  final String? notes;
  /// Code de la devise utilisée (ex: 'EUR', 'XOF', 'USD')
  /// Par défaut 'EUR' pour la rétrocompatibilité
  final String currency;

  Depense({
    this.id,
    required this.date,
    required this.categorie,
    required this.montant,
    required this.description,
    this.notes,
    this.currency = 'EUR',
  });

  /// Créer une copie avec des modifications
  Depense copyWith({
    int? id,
    DateTime? date,
    CategorieDepense? categorie,
    double? montant,
    String? description,
    String? notes,
    String? currency,
  }) {
    return Depense(
      id: id ?? this.id,
      date: date ?? this.date,
      categorie: categorie ?? this.categorie,
      montant: montant ?? this.montant,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      currency: currency ?? this.currency,
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
      'notes': notes,
      'currency': currency,
    };
  }

  /// Créer depuis un Map de la base de données
  factory Depense.fromMap(Map<String, dynamic> map) {
    return Depense(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      categorie: CategorieDepense.fromString(map['categorie'] as String),
      montant: (map['montant'] as num).toDouble(),
      description: map['description'] as String,
      notes: map['notes'] as String?,
      currency: map['currency'] as String? ?? 'EUR',
    );
  }

  @override
  String toString() {
    return 'Depense{id: $id, date: $date, montant: $montant $currency, categorie: $categorie}';
  }
}
