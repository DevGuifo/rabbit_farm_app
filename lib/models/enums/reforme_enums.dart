/// Énumération pour le motif de réforme
enum MotifReforme {
  age('age', 'Âge'),
  improductif('improductif', 'Improductif'),
  maladie('maladie', 'Maladie'),
  genetique('genetique', 'Génétique'),
  comportement('comportement', 'Comportement'),
  autre('autre', 'Autre');

  final String value;
  final String label;

  const MotifReforme(this.value, this.label);

  static MotifReforme fromString(String value) {
    final normalized = value.toLowerCase().trim();
    return MotifReforme.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => MotifReforme.autre,
    );
  }

  String toDatabase() => value;

  @override
  String toString() => label;
}

/// Énumération pour la destination après réforme
enum DestinationReforme {
  vente('vente', 'Vente'),
  abattage('abattage', 'Abattage'),
  don('don', 'Don'),
  autre('autre', 'Autre');

  final String value;
  final String label;

  const DestinationReforme(this.value, this.label);

  static DestinationReforme fromString(String value) {
    final normalized = value.toLowerCase().trim();
    return DestinationReforme.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => DestinationReforme.autre,
    );
  }

  String toDatabase() => value;

  @override
  String toString() => label;
}
