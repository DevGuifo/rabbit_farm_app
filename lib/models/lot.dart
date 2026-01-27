/// Modèle de données représentant un Lot de lapins
///
/// Un lot est l'unité de gestion principale pour les élevages à grande échelle.
/// Il permet de gérer des groupes de lapins (engraissement, reproduction, mixte)
/// sans avoir à suivre chaque individu individuellement.
///
/// **Structure d'identifiant LP-XXXX-XX-XXX :**
/// - LP : Préfixe Lot
/// - XXXX : Année (4 chiffres)
/// - XX : Mois (2 chiffres)
/// - XXX : Numéro séquentiel (3 chiffres, 001-999)
///
/// Exemple: LP-2026-01-001 = Premier lot créé en janvier 2026
library;

import 'dart:convert';

/// Types de lots disponibles
enum TypeLot {
  engraissement('engraissement', 'Engraissement'),
  reproduction('reproduction', 'Reproduction'),
  mixte('mixte', 'Mixte');

  final String value;
  final String label;
  const TypeLot(this.value, this.label);

  static TypeLot fromString(String value) {
    return TypeLot.values.firstWhere(
      (t) => t.value == value.toLowerCase(),
      orElse: () => TypeLot.mixte,
    );
  }
}

/// Statuts possibles d'un lot
enum StatutLot {
  actif('actif', 'Actif'),
  enAttente('en_attente', 'En attente'),
  termine('termine', 'Terminé'),
  vendu('vendu', 'Vendu'),
  reforme('reforme', 'Réformé');

  final String value;
  final String label;
  const StatutLot(this.value, this.label);

  static StatutLot fromString(String value) {
    return StatutLot.values.firstWhere(
      (s) => s.value == value.toLowerCase(),
      orElse: () => StatutLot.actif,
    );
  }
}

/// Métadonnées d'un lot (stockées en JSON)
class LotMetadata {
  final int? ageMoyenJours;
  final String? origine;
  final String? race;
  final double? poidsEntree;
  final double? poidsMoyen;
  final String? notes;
  final Map<String, dynamic>? custom;

  const LotMetadata({
    this.ageMoyenJours,
    this.origine,
    this.race,
    this.poidsEntree,
    this.poidsMoyen,
    this.notes,
    this.custom,
  });

  Map<String, dynamic> toMap() {
    return {
      'age_moyen_jours': ageMoyenJours,
      'origine': origine,
      'race': race,
      'poids_entree': poidsEntree,
      'poids_moyen': poidsMoyen,
      'notes': notes,
      'custom': custom,
    };
  }

  factory LotMetadata.fromMap(Map<String, dynamic> map) {
    return LotMetadata(
      ageMoyenJours: map['age_moyen_jours'] as int?,
      origine: map['origine'] as String?,
      race: map['race'] as String?,
      poidsEntree: (map['poids_entree'] as num?)?.toDouble(),
      poidsMoyen: (map['poids_moyen'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      custom: map['custom'] as Map<String, dynamic>?,
    );
  }

  LotMetadata copyWith({
    int? ageMoyenJours,
    String? origine,
    String? race,
    double? poidsEntree,
    double? poidsMoyen,
    String? notes,
    Map<String, dynamic>? custom,
  }) {
    return LotMetadata(
      ageMoyenJours: ageMoyenJours ?? this.ageMoyenJours,
      origine: origine ?? this.origine,
      race: race ?? this.race,
      poidsEntree: poidsEntree ?? this.poidsEntree,
      poidsMoyen: poidsMoyen ?? this.poidsMoyen,
      notes: notes ?? this.notes,
      custom: custom ?? this.custom,
    );
  }

  String toJson() => jsonEncode(toMap());
  
  factory LotMetadata.fromJson(String json) {
    if (json.isEmpty) return const LotMetadata();
    try {
      return LotMetadata.fromMap(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return const LotMetadata();
    }
  }
}

/// Modèle principal représentant un Lot
class Lot {
  final int? id;
  
  /// Identifiant unique au format LP-XXXX-XX-XXX
  final String identifiant;
  
  /// Date de création du lot
  final DateTime dateCreation;
  
  /// Effectif initial du lot
  final int effectifInitial;
  
  /// Effectif actuel (calculé ou stocké)
  final int effectifActuel;
  
  /// Type de lot (engraissement, reproduction, mixte)
  final TypeLot type;
  
  /// Statut du lot
  final StatutLot statut;
  
  /// Cage/Localisation assignée (FK vers cages.id)
  final int? cageId;
  
  /// Métadonnées supplémentaires (JSON)
  final LotMetadata metadata;
  
  /// Photo du lot (optionnelle)
  final String? photoPath;
  
  /// Indique si ce lot contient des individus détaillés
  final bool hasIndividus;

  const Lot({
    this.id,
    required this.identifiant,
    required this.dateCreation,
    required this.effectifInitial,
    required this.effectifActuel,
    required this.type,
    required this.statut,
    this.cageId,
    this.metadata = const LotMetadata(),
    this.photoPath,
    this.hasIndividus = false,
  });

  /// Générer un identifiant unique pour un nouveau lot
  /// Format: LP-YYYY-MM-NNN
  static String genererIdentifiant(DateTime date, int sequence) {
    final annee = date.year.toString();
    final mois = date.month.toString().padLeft(2, '0');
    final seq = sequence.toString().padLeft(3, '0');
    return 'LP-$annee-$mois-$seq';
  }

  /// Parser un identifiant pour extraire les composants
  static Map<String, dynamic>? parseIdentifiant(String identifiant) {
    final regex = RegExp(r'^LP-(\d{4})-(\d{2})-(\d{3})$');
    final match = regex.firstMatch(identifiant);
    if (match == null) return null;
    
    return {
      'annee': int.parse(match.group(1)!),
      'mois': int.parse(match.group(2)!),
      'sequence': int.parse(match.group(3)!),
    };
  }

  /// Âge du lot en jours
  int get ageEnJours {
    return DateTime.now().difference(dateCreation).inDays;
  }

  /// Âge du lot en semaines
  int get ageEnSemaines {
    return (ageEnJours / 7).floor();
  }

  /// Âge moyen des individus (depuis metadata ou calculé depuis création)
  int get ageMoyenIndividus {
    if (metadata.ageMoyenJours != null) {
      return metadata.ageMoyenJours! + ageEnJours;
    }
    return ageEnJours;
  }

  /// Taux de mortalité (pertes / effectif initial)
  double get tauxMortalite {
    if (effectifInitial == 0) return 0;
    return ((effectifInitial - effectifActuel) / effectifInitial) * 100;
  }

  /// Variation d'effectif
  int get variationEffectif => effectifActuel - effectifInitial;

  /// Description résumée du lot
  String get resume {
    return '${type.label} - $effectifActuel sujets';
  }

  /// Créer une copie du lot avec des modifications
  Lot copyWith({
    int? id,
    String? identifiant,
    DateTime? dateCreation,
    int? effectifInitial,
    int? effectifActuel,
    TypeLot? type,
    StatutLot? statut,
    int? cageId,
    LotMetadata? metadata,
    String? photoPath,
    bool? hasIndividus,
  }) {
    return Lot(
      id: id ?? this.id,
      identifiant: identifiant ?? this.identifiant,
      dateCreation: dateCreation ?? this.dateCreation,
      effectifInitial: effectifInitial ?? this.effectifInitial,
      effectifActuel: effectifActuel ?? this.effectifActuel,
      type: type ?? this.type,
      statut: statut ?? this.statut,
      cageId: cageId ?? this.cageId,
      metadata: metadata ?? this.metadata,
      photoPath: photoPath ?? this.photoPath,
      hasIndividus: hasIndividus ?? this.hasIndividus,
    );
  }

  /// Convertir le lot en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'identifiant': identifiant,
      'date_creation': dateCreation.toIso8601String(),
      'effectif_initial': effectifInitial,
      'effectif_actuel': effectifActuel,
      'type': type.value,
      'statut': statut.value,
      'cage_id': cageId,
      'metadata': metadata.toJson(),
      'photo_path': photoPath,
      'has_individus': hasIndividus ? 1 : 0,
    };
  }

  /// Créer un lot depuis un Map de la base de données
  factory Lot.fromMap(Map<String, dynamic> map) {
    return Lot(
      id: map['id'] as int?,
      identifiant: map['identifiant'] as String,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      effectifInitial: map['effectif_initial'] as int,
      effectifActuel: map['effectif_actuel'] as int,
      type: TypeLot.fromString(map['type'] as String),
      statut: StatutLot.fromString(map['statut'] as String),
      cageId: map['cage_id'] as int?,
      metadata: LotMetadata.fromJson(map['metadata'] as String? ?? ''),
      photoPath: map['photo_path'] as String?,
      hasIndividus: (map['has_individus'] as int?) == 1,
    );
  }

  @override
  String toString() {
    return 'Lot{id: $id, identifiant: $identifiant, type: ${type.label}, effectif: $effectifActuel}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lot && other.id == id && other.identifiant == identifiant;
  }

  @override
  int get hashCode => id.hashCode ^ identifiant.hashCode;
}

/// Extension pour les opérations groupées sur les lots
extension LotOperations on List<Lot> {
  /// Effectif total de tous les lots
  int get effectifTotal => fold(0, (sum, lot) => sum + lot.effectifActuel);

  /// Lots actifs uniquement
  List<Lot> get actifs => where((l) => l.statut == StatutLot.actif).toList();

  /// Lots par type
  List<Lot> parType(TypeLot type) => where((l) => l.type == type).toList();

  /// Lots avec mortalité élevée (> 10%)
  List<Lot> get avecMortaliteElevee => 
      where((l) => l.tauxMortalite > 10).toList();
}
