/// Énumération pour le type de soin vétérinaire
enum TypeSoin {
  vaccination('vaccination', 'Vaccination'),
  traitement('traitement', 'Traitement'),
  vermifuge('vermifuge', 'Vermifuge'),
  autre('autre', 'Autre');

  final String value;
  final String label;

  const TypeSoin(this.value, this.label);

  /// Convertir une chaîne en enum
  static TypeSoin fromString(String value) {
    final normalized = value.toLowerCase().trim();
    return TypeSoin.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => TypeSoin.autre,
    );
  }

  /// Convertir vers String pour la BDD
  String toDatabase() => value;

  @override
  String toString() => label;
}
