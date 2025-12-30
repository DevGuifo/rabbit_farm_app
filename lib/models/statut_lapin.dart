/// Énumération des statuts possibles d'un lapin
enum StatutLapin {
  lapereau, // 0-8 semaines
  jeune, // 8 semaines - 5 mois
  adulte, // 5+ mois
  reproducteurActif,
  reproducteurRepos,
  gestante,
  allaitante,
  malade,
  quarantaine,
  reforme,
  vendu,
  decede,
}

/// Extensions pour StatutLapin
extension StatutLapinExtension on StatutLapin {
  /// Libellé français
  String get label {
    switch (this) {
      case StatutLapin.lapereau:
        return 'Lapereau';
      case StatutLapin.jeune:
        return 'Jeune';
      case StatutLapin.adulte:
        return 'Adulte';
      case StatutLapin.reproducteurActif:
        return 'Reproducteur actif';
      case StatutLapin.reproducteurRepos:
        return 'Reproducteur au repos';
      case StatutLapin.gestante:
        return 'Gestante';
      case StatutLapin.allaitante:
        return 'Allaitante';
      case StatutLapin.malade:
        return 'Malade';
      case StatutLapin.quarantaine:
        return 'En quarantaine';
      case StatutLapin.reforme:
        return 'Réformé';
      case StatutLapin.vendu:
        return 'Vendu';
      case StatutLapin.decede:
        return 'Décédé';
    }
  }

  /// Couleur associée au statut
  String get colorHex {
    switch (this) {
      case StatutLapin.lapereau:
        return '#FFB84D'; // Orange clair
      case StatutLapin.jeune:
        return '#4ECDC4'; // Cyan
      case StatutLapin.adulte:
        return '#4CAF50'; // Vert
      case StatutLapin.reproducteurActif:
        return '#2196F3'; // Bleu
      case StatutLapin.reproducteurRepos:
        return '#9E9E9E'; // Gris
      case StatutLapin.gestante:
        return '#FF6B9D'; // Rose
      case StatutLapin.allaitante:
        return '#E91E63'; // Rose foncé
      case StatutLapin.malade:
        return '#FF5722'; // Rouge-orange
      case StatutLapin.quarantaine:
        return '#FF9800'; // Orange
      case StatutLapin.reforme:
        return '#795548'; // Marron
      case StatutLapin.vendu:
        return '#607D8B'; // Bleu-gris
      case StatutLapin.decede:
        return '#424242'; // Gris foncé
    }
  }

  /// Icône associée au statut
  String get icon {
    switch (this) {
      case StatutLapin.lapereau:
        return '🐰';
      case StatutLapin.jeune:
        return '🐇';
      case StatutLapin.adulte:
        return '🐰';
      case StatutLapin.reproducteurActif:
        return '💕';
      case StatutLapin.reproducteurRepos:
        return '😴';
      case StatutLapin.gestante:
        return '🤰';
      case StatutLapin.allaitante:
        return '🍼';
      case StatutLapin.malade:
        return '🤒';
      case StatutLapin.quarantaine:
        return '🏥';
      case StatutLapin.reforme:
        return '♻️';
      case StatutLapin.vendu:
        return '💰';
      case StatutLapin.decede:
        return '☠️';
    }
  }

  /// Indique si le lapin est actif dans le cheptel
  bool get estActif {
    return this != StatutLapin.vendu && this != StatutLapin.decede;
  }

  /// Indique si le lapin peut se reproduire
  bool get peutSeReproduire {
    return this == StatutLapin.reproducteurActif;
  }

  /// Valeur pour la base de données
  String get dbValue {
    return name;
  }
}

/// Helper pour convertir depuis/vers la base de données
class StatutLapinHelper {
  static StatutLapin fromString(String? value) {
    if (value == null) return StatutLapin.jeune;

    try {
      return StatutLapin.values.firstWhere(
        (e) => e.name == value,
        orElse: () => StatutLapin.adulte,
      );
    } catch (e) {
      return StatutLapin.adulte;
    }
  }

  /// Déterminer le statut automatiquement selon l'âge
  static StatutLapin determinerParAge(int ageEnJours, String? statutActuel) {
    // Si déjà un statut spécial, le garder
    if (statutActuel != null) {
      final statut = fromString(statutActuel);
      if (statut == StatutLapin.gestante ||
          statut == StatutLapin.allaitante ||
          statut == StatutLapin.malade ||
          statut == StatutLapin.quarantaine ||
          statut == StatutLapin.reproducteurActif ||
          statut == StatutLapin.reproducteurRepos ||
          statut == StatutLapin.reforme ||
          statut == StatutLapin.vendu ||
          statut == StatutLapin.decede) {
        return statut;
      }
    }

    // Détermination automatique par âge
    if (ageEnJours < 56) {
      // < 8 semaines
      return StatutLapin.lapereau;
    } else if (ageEnJours < 150) {
      // 8 semaines - 5 mois
      return StatutLapin.jeune;
    } else {
      return StatutLapin.adulte;
    }
  }

  /// Valider une transition de statut
  static bool peutTransitionner(
    StatutLapin actuel,
    StatutLapin nouveau,
    int ageEnJours,
  ) {
    // Décédé et vendu sont finaux
    if (actuel == StatutLapin.decede || actuel == StatutLapin.vendu) {
      return false;
    }

    // Lapereau ne peut pas être reproducteur
    if (ageEnJours < 150 &&
        (nouveau == StatutLapin.reproducteurActif ||
            nouveau == StatutLapin.gestante ||
            nouveau == StatutLapin.allaitante)) {
      return false;
    }

    // Mâle ne peut pas être gestante/allaitante
    // (vérification faite dans le provider avec le sexe)

    return true;
  }
}
