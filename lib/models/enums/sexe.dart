/// Énumération pour le sexe d'un lapin
enum Sexe {
  male('male', 'Mâle'),
  femelle('femelle', 'Femelle'),
  inconnu('inconnu', 'Inconnu');

  final String value;
  final String label;

  const Sexe(this.value, this.label);

  /// Convertir une chaîne en enum Sexe
  static Sexe fromString(String value) {
    final normalized = value.toLowerCase().trim();

    // Supporter les anciennes valeurs
    if (normalized == 'male' || normalized == 'mâle' || normalized == 'm') {
      return Sexe.male;
    }
    if (normalized == 'femelle' || normalized == 'f') {
      return Sexe.femelle;
    }
    if (normalized == 'inconnu' || normalized == '?' || normalized == 'indéterminé') {
      return Sexe.inconnu;
    }

    // Par défaut, chercher par value
    return Sexe.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => Sexe.male,
    );
  }

  /// Convertir vers String pour la BDD
  String toDatabase() => value;

  @override
  String toString() => label;
}
