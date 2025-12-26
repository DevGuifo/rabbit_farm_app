/// Modèle représentant une alerte
class Alerte {
  final String id;
  final String titre;
  final String description;
  final TypeAlerte type;
  final PrioriteAlerte priorite;
  final DateTime dateCreation;
  final int? lapinId;
  final String? lapinNom;
  final String? action; // Action suggérée
  final bool estLue;

  Alerte({
    required this.id,
    required this.titre,
    required this.description,
    required this.type,
    required this.priorite,
    required this.dateCreation,
    this.lapinId,
    this.lapinNom,
    this.action,
    this.estLue = false,
  });

  Alerte copyWith({
    String? id,
    String? titre,
    String? description,
    TypeAlerte? type,
    PrioriteAlerte? priorite,
    DateTime? dateCreation,
    int? lapinId,
    String? lapinNom,
    String? action,
    bool? estLue,
  }) {
    return Alerte(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      type: type ?? this.type,
      priorite: priorite ?? this.priorite,
      dateCreation: dateCreation ?? this.dateCreation,
      lapinId: lapinId ?? this.lapinId,
      lapinNom: lapinNom ?? this.lapinNom,
      action: action ?? this.action,
      estLue: estLue ?? this.estLue,
    );
  }
}

/// Types d'alertes
enum TypeAlerte {
  vaccination,
  palpation,
  preparationNid,
  miseBas,
  sevrage,
  pesee,
  traitement,
  poidsAnormal,
  stockFaible,
  peremption,
  mortaliteAnormale,
  consanguinite,
  quarantaine,
  reforme,
  symptomes,
}

extension TypeAlerteExtension on TypeAlerte {
  String get label {
    switch (this) {
      case TypeAlerte.vaccination:
        return 'Vaccination';
      case TypeAlerte.palpation:
        return 'Palpation';
      case TypeAlerte.preparationNid:
        return 'Préparation nid';
      case TypeAlerte.miseBas:
        return 'Mise bas';
      case TypeAlerte.sevrage:
        return 'Sevrage';
      case TypeAlerte.pesee:
        return 'Pesée';
      case TypeAlerte.traitement:
        return 'Traitement';
      case TypeAlerte.poidsAnormal:
        return 'Poids anormal';
      case TypeAlerte.stockFaible:
        return 'Stock faible';
      case TypeAlerte.peremption:
        return 'Péremption';
      case TypeAlerte.mortaliteAnormale:
        return 'Mortalité anormale';
      case TypeAlerte.consanguinite:
        return 'Consanguinité';
      case TypeAlerte.quarantaine:
        return 'Quarantaine';
      case TypeAlerte.reforme:
        return 'Réforme';
      case TypeAlerte.symptomes:
        return 'Symptômes';
    }
  }

  String get icon {
    switch (this) {
      case TypeAlerte.vaccination:
        return '💉';
      case TypeAlerte.palpation:
        return '🤲';
      case TypeAlerte.preparationNid:
        return '🏠';
      case TypeAlerte.miseBas:
        return '🐰';
      case TypeAlerte.sevrage:
        return '👶';
      case TypeAlerte.pesee:
        return '⚖️';
      case TypeAlerte.traitement:
        return '💊';
      case TypeAlerte.poidsAnormal:
        return '⚠️';
      case TypeAlerte.stockFaible:
        return '📦';
      case TypeAlerte.peremption:
        return '📅';
      case TypeAlerte.mortaliteAnormale:
        return '☠️';
      case TypeAlerte.consanguinite:
        return '🧬';
      case TypeAlerte.quarantaine:
        return '🏥';
      case TypeAlerte.reforme:
        return '♻️';
      case TypeAlerte.symptomes:
        return '🤒';
    }
  }
}

/// Priorités d'alertes
enum PrioriteAlerte {
  urgent, // Rouge - action immédiate requise
  important, // Orange - à traiter sous 24-48h
  normal, // Cyan - information
}

extension PrioriteAlerteExtension on PrioriteAlerte {
  String get label {
    switch (this) {
      case PrioriteAlerte.urgent:
        return 'Urgent';
      case PrioriteAlerte.important:
        return 'Important';
      case PrioriteAlerte.normal:
        return 'Normal';
    }
  }

  String get colorHex {
    switch (this) {
      case PrioriteAlerte.urgent:
        return '#F44336'; // Rouge
      case PrioriteAlerte.important:
        return '#FF9800'; // Orange
      case PrioriteAlerte.normal:
        return '#00BCD4'; // Cyan
    }
  }
}
