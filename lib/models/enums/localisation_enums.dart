/// Énumération pour le type de cage
enum TypeCage {
  individuelle('individuelle', 'Individuelle'),
  collective('collective', 'Collective'),
  nid('nid', 'Nid');

  final String value;
  final String label;

  const TypeCage(this.value, this.label);

  static TypeCage fromString(String value) {
    final normalized = value.toLowerCase().trim();
    return TypeCage.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => TypeCage.individuelle,
    );
  }

  String toDatabase() => value;

  @override
  String toString() => label;
}

/// Énumération pour le type de clapier
enum TypeClapier {
  interieur('interieur', 'Intérieur'),
  exterieur('exterieur', 'Extérieur'),
  quarantaine('quarantaine', 'Quarantaine'),
  personnalise('personnalise', 'Personnalisé');

  final String value;
  final String label;

  const TypeClapier(this.value, this.label);

  static TypeClapier fromString(String value) {
    final normalized = value.toLowerCase().trim();
    return TypeClapier.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => TypeClapier.personnalise,
    );
  }

  String toDatabase() => value;

  @override
  String toString() => label;
}
