/// Énumération pour la priorité d'une tâche
enum PrioriteTache {
  haute('haute', 'Haute'),
  normale('normale', 'Normale'),
  basse('basse', 'Basse');

  final String value;
  final String label;

  const PrioriteTache(this.value, this.label);

  static PrioriteTache fromString(String value) {
    final normalized = value.toLowerCase().trim();
    return PrioriteTache.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => PrioriteTache.normale,
    );
  }

  String toDatabase() => value;

  @override
  String toString() => label;
}

/// Énumération pour la catégorie d'une tâche
enum CategorieTache {
  reproduction('reproduction', 'Reproduction'),
  sante('sante', 'Santé'),
  alimentation('alimentation', 'Alimentation'),
  entretien('entretien', 'Entretien'),
  administratif('administratif', 'Administratif'),
  autre('autre', 'Autre');

  final String value;
  final String label;

  const CategorieTache(this.value, this.label);

  static CategorieTache fromString(String value) {
    final normalized = value.toLowerCase().trim();

    // Support des anciennes valeurs avec accents
    if (normalized.contains('santé') || normalized == 'sante') {
      return CategorieTache.sante;
    }

    return CategorieTache.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => CategorieTache.autre,
    );
  }

  String toDatabase() => value;

  @override
  String toString() => label;
}

/// Énumération pour le statut d'une tâche
enum StatutTache {
  aFaire('a_faire', 'À faire'),
  enCours('en_cours', 'En cours'),
  terminee('terminee', 'Terminée'),
  annulee('annulee', 'Annulée'),
  reportee('reportee', 'Reportée');

  final String value;
  final String label;

  const StatutTache(this.value, this.label);

  static StatutTache fromString(String value) {
    final normalized = value.toLowerCase().trim().replaceAll(' ', '_');

    // Support des anciennes valeurs avec accents
    if (normalized.contains('à_faire') || normalized == 'a_faire') {
      return StatutTache.aFaire;
    }
    if (normalized.contains('terminée') || normalized == 'terminee') {
      return StatutTache.terminee;
    }
    if (normalized.contains('annulée') || normalized == 'annulee') {
      return StatutTache.annulee;
    }
    if (normalized.contains('reportée') || normalized == 'reportee') {
      return StatutTache.reportee;
    }

    return StatutTache.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => StatutTache.aFaire,
    );
  }

  String toDatabase() => value;

  @override
  String toString() => label;
}

/// Énumération pour la fréquence de récurrence d'une tâche
enum FrequenceRecurrence {
  quotidienne('quotidienne', 'Quotidienne'),
  hebdomadaire('hebdomadaire', 'Hebdomadaire'),
  mensuelle('mensuelle', 'Mensuelle');

  final String value;
  final String label;

  const FrequenceRecurrence(this.value, this.label);

  static FrequenceRecurrence fromString(String value) {
    final normalized = value.toLowerCase().trim();
    return FrequenceRecurrence.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => FrequenceRecurrence.quotidienne,
    );
  }

  String toDatabase() => value;

  @override
  String toString() => label;
}
