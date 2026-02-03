/// Objectifs d'élevage pour personnaliser le dashboard et les KPIs
/// 
/// Collecté durant l'onboarding V2 (écran 3)
/// Stocké dans UserProfile.objectifs
enum ObjectifElevage {
  /// Focus sur l'optimisation des marges et revenus
  rentabilite,
  
  /// Focus sur l'agrandissement du cheptel
  croissance,
  
  /// Focus sur la sélection génétique et la qualité
  qualite,
  
  /// Focus sur la traçabilité et le suivi complet
  suivi,
}

/// Extension pour ajouter des propriétés aux objectifs
extension ObjectifElevageExtension on ObjectifElevage {
  /// Label court pour l'affichage
  String get label {
    switch (this) {
      case ObjectifElevage.rentabilite:
        return 'Rentabilité';
      case ObjectifElevage.croissance:
        return 'Croissance';
      case ObjectifElevage.qualite:
        return 'Qualité';
      case ObjectifElevage.suivi:
        return 'Suivi';
    }
  }

  /// Description détaillée pour l'onboarding
  String get description {
    switch (this) {
      case ObjectifElevage.rentabilite:
        return 'Optimiser mes marges';
      case ObjectifElevage.croissance:
        return 'Agrandir mon cheptel';
      case ObjectifElevage.qualite:
        return 'Sélection génétique';
      case ObjectifElevage.suivi:
        return 'Garder une trace de tout';
    }
  }

  /// Icône emoji pour l'affichage
  String get icon {
    switch (this) {
      case ObjectifElevage.rentabilite:
        return '💰';
      case ObjectifElevage.croissance:
        return '📈';
      case ObjectifElevage.qualite:
        return '🏆';
      case ObjectifElevage.suivi:
        return '📊';
    }
  }

  /// Valeur pour stockage en base de données
  String get toDbValue {
    switch (this) {
      case ObjectifElevage.rentabilite:
        return 'rentabilite';
      case ObjectifElevage.croissance:
        return 'croissance';
      case ObjectifElevage.qualite:
        return 'qualite';
      case ObjectifElevage.suivi:
        return 'suivi';
    }
  }

  /// Créer depuis une valeur de base de données
  static ObjectifElevage? fromDbValue(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'rentabilite':
        return ObjectifElevage.rentabilite;
      case 'croissance':
        return ObjectifElevage.croissance;
      case 'qualite':
        return ObjectifElevage.qualite;
      case 'suivi':
        return ObjectifElevage.suivi;
      default:
        return null;
    }
  }

  /// Convertir une liste JSON en liste d'objectifs
  static List<ObjectifElevage> fromJsonList(List<dynamic>? jsonList) {
    if (jsonList == null) return [];
    return jsonList
        .map((e) => ObjectifElevageExtension.fromDbValue(e.toString()))
        .whereType<ObjectifElevage>()
        .toList();
  }

  /// Convertir une liste d'objectifs en liste JSON
  static List<String> toJsonList(List<ObjectifElevage>? objectifs) {
    if (objectifs == null) return [];
    return objectifs.map((o) => o.toDbValue).toList();
  }
}
