/// Énumération pour le type de médicament
enum TypeMedicament {
  antibiotique('antibiotique', 'Antibiotique'),
  antiparasitaire('antiparasitaire', 'Antiparasitaire'),
  vitamine('vitamine', 'Vitamine'),
  vaccin('vaccin', 'Vaccin'),
  autre('autre', 'Autre');

  final String value;
  final String label;

  const TypeMedicament(this.value, this.label);

  static TypeMedicament fromString(String value) {
    final normalized = value.toLowerCase().trim();
    return TypeMedicament.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => TypeMedicament.autre,
    );
  }

  String toDatabase() => value;

  @override
  String toString() => label;
}
