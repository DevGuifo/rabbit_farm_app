/// Énumération pour le motif de quarantaine
enum MotifQuarantaine {
  nouveau('nouveau', 'Nouveau lapin'),
  maladie('maladie', 'Maladie'),
  isolementSanitaire('isolement_sanitaire', 'Isolement sanitaire'),
  observation('observation', 'Observation');

  final String value;
  final String label;

  const MotifQuarantaine(this.value, this.label);

  static MotifQuarantaine fromString(String value) {
    final normalized = value.toLowerCase().trim();
    return MotifQuarantaine.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => MotifQuarantaine.observation,
    );
  }

  String toDatabase() => value;

  @override
  String toString() => label;
}

/// Énumération pour le statut de quarantaine
enum StatutQuarantaine {
  enCours('en_cours', 'En cours'),
  termine('termine', 'Terminée'),
  transfere('transfere', 'Transféré');

  final String value;
  final String label;

  const StatutQuarantaine(this.value, this.label);

  static StatutQuarantaine fromString(String value) {
    final normalized = value.toLowerCase().trim();
    return StatutQuarantaine.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => StatutQuarantaine.enCours,
    );
  }

  String toDatabase() => value;

  @override
  String toString() => label;
}
