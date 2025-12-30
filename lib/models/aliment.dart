/// Modèle représentant un aliment dans l'inventaire
class Aliment {
  final int? id;
  final String nom;
  final String type; // granules, foin, legumes, cereales, complement
  final String? marque;
  final String? fournisseur;
  final String conditionnement; // sac 5kg, 25kg, vrac
  final double quantiteAchetee; // kg
  final double quantiteRestante; // kg
  final double prixUnitaire; // par kg
  final double prixTotal;
  final DateTime dateAchat;
  final DateTime? datePeremption;
  final String? composition; // JSON: {proteines: 16, fibres: 15, ...}
  final String? lieuStockage;
  final String? photoPath;

  Aliment({
    this.id,
    required this.nom,
    required this.type,
    this.marque,
    this.fournisseur,
    required this.conditionnement,
    required this.quantiteAchetee,
    required this.quantiteRestante,
    required this.prixUnitaire,
    required this.prixTotal,
    required this.dateAchat,
    this.datePeremption,
    this.composition,
    this.lieuStockage,
    this.photoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'type': type,
      'marque': marque,
      'fournisseur': fournisseur,
      'conditionnement': conditionnement,
      'quantite_achetee': quantiteAchetee,
      'quantite_restante': quantiteRestante,
      'prix_unitaire': prixUnitaire,
      'prix_total': prixTotal,
      'date_achat': dateAchat.toIso8601String(),
      'date_peremption': datePeremption?.toIso8601String(),
      'composition': composition,
      'lieu_stockage': lieuStockage,
      'photo_path': photoPath,
    };
  }

  factory Aliment.fromMap(Map<String, dynamic> map) {
    return Aliment(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      type: map['type'] as String,
      marque: map['marque'] as String?,
      fournisseur: map['fournisseur'] as String?,
      conditionnement: map['conditionnement'] as String,
      quantiteAchetee: (map['quantite_achetee'] as num).toDouble(),
      quantiteRestante: (map['quantite_restante'] as num).toDouble(),
      prixUnitaire: (map['prix_unitaire'] as num).toDouble(),
      prixTotal: (map['prix_total'] as num).toDouble(),
      dateAchat: DateTime.parse(map['date_achat'] as String),
      datePeremption: map['date_peremption'] != null
          ? DateTime.parse(map['date_peremption'] as String)
          : null,
      composition: map['composition'] as String?,
      lieuStockage: map['lieu_stockage'] as String?,
      photoPath: map['photo_path'] as String?,
    );
  }

  Aliment copyWith({
    int? id,
    String? nom,
    String? type,
    String? marque,
    String? fournisseur,
    String? conditionnement,
    double? quantiteAchetee,
    double? quantiteRestante,
    double? prixUnitaire,
    double? prixTotal,
    DateTime? dateAchat,
    DateTime? datePeremption,
    String? composition,
    String? lieuStockage,
    String? photoPath,
  }) {
    return Aliment(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      type: type ?? this.type,
      marque: marque ?? this.marque,
      fournisseur: fournisseur ?? this.fournisseur,
      conditionnement: conditionnement ?? this.conditionnement,
      quantiteAchetee: quantiteAchetee ?? this.quantiteAchetee,
      quantiteRestante: quantiteRestante ?? this.quantiteRestante,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      prixTotal: prixTotal ?? this.prixTotal,
      dateAchat: dateAchat ?? this.dateAchat,
      datePeremption: datePeremption ?? this.datePeremption,
      composition: composition ?? this.composition,
      lieuStockage: lieuStockage ?? this.lieuStockage,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

/// Types d'aliments
class TypeAliment {
  static const String granules = 'granules';
  static const String foin = 'foin';
  static const String legumes = 'legumes';
  static const String cereales = 'cereales';
  static const String complement = 'complement';

  static const List<String> values = [
    granules,
    foin,
    legumes,
    cereales,
    complement,
  ];

  static String getLabel(String type) {
    switch (type) {
      case granules:
        return 'Granulés/Pellets';
      case foin:
        return 'Foin';
      case legumes:
        return 'Légumes et verdure';
      case cereales:
        return 'Céréales';
      case complement:
        return 'Compléments';
      default:
        return type;
    }
  }
}

/// Modèle représentant une distribution d'aliment
class DistributionAliment {
  final int? id;
  final int alimentId;
  final DateTime date;
  final double quantiteDistribuee; // kg
  final String? cagesConcernees; // JSON array ou texte
  final String? observations;

  DistributionAliment({
    this.id,
    required this.alimentId,
    required this.date,
    required this.quantiteDistribuee,
    this.cagesConcernees,
    this.observations,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'aliment_id': alimentId,
      'date': date.toIso8601String(),
      'quantite_distribuee': quantiteDistribuee,
      'cages_concernees': cagesConcernees,
      'observations': observations,
    };
  }

  factory DistributionAliment.fromMap(Map<String, dynamic> map) {
    return DistributionAliment(
      id: map['id'] as int?,
      alimentId: map['aliment_id'] as int,
      date: DateTime.parse(map['date'] as String),
      quantiteDistribuee: (map['quantite_distribuee'] as num).toDouble(),
      cagesConcernees: map['cages_concernees'] as String?,
      observations: map['observations'] as String?,
    );
  }

  DistributionAliment copyWith({
    int? id,
    int? alimentId,
    DateTime? date,
    double? quantiteDistribuee,
    String? cagesConcernees,
    String? observations,
  }) {
    return DistributionAliment(
      id: id ?? this.id,
      alimentId: alimentId ?? this.alimentId,
      date: date ?? this.date,
      quantiteDistribuee: quantiteDistribuee ?? this.quantiteDistribuee,
      cagesConcernees: cagesConcernees ?? this.cagesConcernees,
      observations: observations ?? this.observations,
    );
  }
}
