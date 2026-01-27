/// Énumération pour la catégorie de dépense
enum CategorieDepense {
  alimentation('alimentation', 'Alimentation'),
  veterinaire('veterinaire', 'Vétérinaire'),
  equipement('equipement', 'Équipement'),
  autre('autre', 'Autre');

  final String value;
  final String label;

  const CategorieDepense(this.value, this.label);

  static CategorieDepense fromString(String value) {
    final normalized = value.toLowerCase().trim();
    return CategorieDepense.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => CategorieDepense.autre,
    );
  }

  String toDatabase() => value;

  @override
  String toString() => label;
}

/// Énumération pour la catégorie de recette
enum CategorieRecette {
  venteLapin('vente_lapin', 'Vente de lapin'),
  ventePortee('vente_portee', 'Vente de portée'),
  autre('autre', 'Autre');

  final String value;
  final String label;

  const CategorieRecette(this.value, this.label);

  static CategorieRecette fromString(String value) {
    final normalized = value.toLowerCase().trim();
    return CategorieRecette.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => CategorieRecette.autre,
    );
  }

  String toDatabase() => value;

  @override
  String toString() => label;
}
