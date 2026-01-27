/// Mode Focus pour notifications
/// Permet à l'utilisateur de contrôler la quantité de notifications
enum ModeFocus {
  /// Toutes les notifications
  normal,

  /// Urgence + Action requise uniquement
  essentiel,

  /// Urgence seulement
  urgencesOnly,

  /// Aucun push, in-app uniquement
  silent,
}

extension ModeFocusExtension on ModeFocus {
  String get label {
    switch (this) {
      case ModeFocus.normal:
        return 'Normal';
      case ModeFocus.essentiel:
        return 'Essentiel';
      case ModeFocus.urgencesOnly:
        return 'Urgences seulement';
      case ModeFocus.silent:
        return 'Silencieux';
    }
  }

  String get description {
    switch (this) {
      case ModeFocus.normal:
        return 'Toutes les notifications (recommandé)';
      case ModeFocus.essentiel:
        return 'Urgences et actions requises uniquement';
      case ModeFocus.urgencesOnly:
        return 'Urgences critiques seulement';
      case ModeFocus.silent:
        return 'Aucun push, centre alertes uniquement';
    }
  }

  String get icon {
    switch (this) {
      case ModeFocus.normal:
        return '🔔';
      case ModeFocus.essentiel:
        return '⚡';
      case ModeFocus.urgencesOnly:
        return '🚨';
      case ModeFocus.silent:
        return '🔕';
    }
  }
}
