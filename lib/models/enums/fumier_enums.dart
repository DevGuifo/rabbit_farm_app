/// Énumération pour le type de fumier
enum TypeFumier {
  crottes('crottes', 'Crottes'),
  urine('urine', 'Urine'),
  mixte('mixte', 'Mixte');

  final String value;
  final String label;

  const TypeFumier(this.value, this.label);

  static TypeFumier fromString(String value) {
    final normalized = value.toLowerCase().trim();
    return TypeFumier.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => TypeFumier.mixte,
    );
  }

  String toDatabase() => value;

  @override
  String toString() => label;
}

/// Énumération pour la destination du fumier
enum DestinationFumier {
  vente('vente', 'Vente'),
  compost('compost', 'Compost'),
  utilisationPersonnelle('utilisation_personnelle', 'Utilisation personnelle');

  final String value;
  final String label;

  const DestinationFumier(this.value, this.label);

  static DestinationFumier fromString(String value) {
    final normalized = value.toLowerCase().trim();
    return DestinationFumier.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => DestinationFumier.utilisationPersonnelle,
    );
  }

  String toDatabase() => value;

  @override
  String toString() => label;
}
