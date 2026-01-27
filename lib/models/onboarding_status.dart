/// Statut du processus d'onboarding
enum OnboardingStep {
  nonDemarre,
  presentation,
  typeElevage,
  informationsFerme,
  profilUtilisateur,
  synchronisation,
  termine,
}

/// Modèle pour suivre l'état de l'onboarding de l'utilisateur
class OnboardingStatus {
  final int? id;
  final int? userId; // Référence vers la table users
  final OnboardingStep etapeActuelle;
  final bool estTermine;
  final bool synchronisationAutorisee;
  final DateTime dateCreation;
  final DateTime? dateModification;
  final DateTime? dateTermine;

  OnboardingStatus({
    this.id,
    this.userId,
    this.etapeActuelle = OnboardingStep.nonDemarre,
    this.estTermine = false,
    this.synchronisationAutorisee = true,
    required this.dateCreation,
    this.dateModification,
    this.dateTermine,
  });

  /// Convertir OnboardingStep en string
  String get etapeString {
    switch (etapeActuelle) {
      case OnboardingStep.nonDemarre:
        return 'non_demarre';
      case OnboardingStep.presentation:
        return 'presentation';
      case OnboardingStep.typeElevage:
        return 'type_elevage';
      case OnboardingStep.informationsFerme:
        return 'informations_ferme';
      case OnboardingStep.profilUtilisateur:
        return 'profil_utilisateur';
      case OnboardingStep.synchronisation:
        return 'synchronisation';
      case OnboardingStep.termine:
        return 'termine';
    }
  }

  /// Obtenir l'étape suivante
  OnboardingStep? get etapeSuivante {
    switch (etapeActuelle) {
      case OnboardingStep.nonDemarre:
        return OnboardingStep.presentation;
      case OnboardingStep.presentation:
        return OnboardingStep.typeElevage;
      case OnboardingStep.typeElevage:
        return OnboardingStep.informationsFerme;
      case OnboardingStep.informationsFerme:
        return OnboardingStep.profilUtilisateur;
      case OnboardingStep.profilUtilisateur:
        return OnboardingStep.synchronisation;
      case OnboardingStep.synchronisation:
        return OnboardingStep.termine;
      case OnboardingStep.termine:
        return null;
    }
  }

  /// Vérifier si l'onboarding peut être passé (pour debug uniquement)
  bool get peutEtreSkip => false; // V1: non skippable

  /// Pourcentage de progression (0-100)
  int get pourcentageProgression {
    switch (etapeActuelle) {
      case OnboardingStep.nonDemarre:
        return 0;
      case OnboardingStep.presentation:
        return 16;
      case OnboardingStep.typeElevage:
        return 32;
      case OnboardingStep.informationsFerme:
        return 48;
      case OnboardingStep.profilUtilisateur:
        return 64;
      case OnboardingStep.synchronisation:
        return 80;
      case OnboardingStep.termine:
        return 100;
    }
  }

  /// Créer OnboardingStatus depuis une Map
  factory OnboardingStatus.fromMap(Map<String, dynamic> map) {
    OnboardingStep etape;
    switch (map['etape_actuelle'] as String) {
      case 'non_demarre':
        etape = OnboardingStep.nonDemarre;
        break;
      case 'presentation':
        etape = OnboardingStep.presentation;
        break;
      case 'type_elevage':
        etape = OnboardingStep.typeElevage;
        break;
      case 'informations_ferme':
        etape = OnboardingStep.informationsFerme;
        break;
      case 'profil_utilisateur':
        etape = OnboardingStep.profilUtilisateur;
        break;
      case 'synchronisation':
        etape = OnboardingStep.synchronisation;
        break;
      case 'termine':
        etape = OnboardingStep.termine;
        break;
      default:
        etape = OnboardingStep.nonDemarre;
    }

    return OnboardingStatus(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      etapeActuelle: etape,
      estTermine: (map['est_termine'] as int? ?? 0) == 1,
      synchronisationAutorisee:
          (map['synchronisation_autorisee'] as int? ?? 1) == 1,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: map['date_modification'] != null
          ? DateTime.parse(map['date_modification'] as String)
          : null,
      dateTermine: map['date_termine'] != null
          ? DateTime.parse(map['date_termine'] as String)
          : null,
    );
  }

  /// Convertir OnboardingStatus en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'etape_actuelle': etapeString,
      'est_termine': estTermine ? 1 : 0,
      'synchronisation_autorisee': synchronisationAutorisee ? 1 : 0,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification?.toIso8601String(),
      'date_termine': dateTermine?.toIso8601String(),
    };
  }

  /// Créer une copie avec des modifications
  OnboardingStatus copyWith({
    int? id,
    int? userId,
    OnboardingStep? etapeActuelle,
    bool? estTermine,
    bool? synchronisationAutorisee,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? dateTermine,
  }) {
    return OnboardingStatus(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      etapeActuelle: etapeActuelle ?? this.etapeActuelle,
      estTermine: estTermine ?? this.estTermine,
      synchronisationAutorisee:
          synchronisationAutorisee ?? this.synchronisationAutorisee,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      dateTermine: dateTermine ?? this.dateTermine,
    );
  }

  @override
  String toString() {
    return 'OnboardingStatus(etape: $etapeString, termine: $estTermine, progression: $pourcentageProgression%)';
  }
}
