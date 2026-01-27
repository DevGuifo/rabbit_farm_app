/// Énumération pour le statut d'un accouplement
enum StatutAccouplement {
  enAttente('en_attente', 'En attente'),
  confirme('confirme', 'Confirmé'),
  echec('echec', 'Échec'),
  termine('termine', 'Terminé');

  final String value;
  final String label;

  const StatutAccouplement(this.value, this.label);

  /// Convertir une chaîne en enum
  static StatutAccouplement fromString(String value) {
    final normalized = value.toLowerCase().trim().replaceAll(' ', '_');

    // Support des anciennes valeurs avec accents
    if (normalized == 'confirme' || normalized.contains('confirmé')) {
      return StatutAccouplement.confirme;
    }
    if (normalized == 'échec' || normalized.contains('echec')) {
      return StatutAccouplement.echec;
    }
    if (normalized == 'terminé' || normalized.contains('termine')) {
      return StatutAccouplement.termine;
    }

    return StatutAccouplement.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => StatutAccouplement.enAttente,
    );
  }

  /// Convertir vers String pour la BDD
  String toDatabase() => value;

  @override
  String toString() => label;
}
