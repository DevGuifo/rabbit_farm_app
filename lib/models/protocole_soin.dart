class ProtocoleSoin {
  final int? id;
  final String nom;
  final String description;
  final String
  type; // 'vaccination', 'vermifugation', 'prevention', 'traitement', 'routine'
  final String
  frequence; // 'annuel', 'trimestriel', 'mensuel', 'hebdomadaire', 'ponctuel'
  final List<String> medicamentsNecessaires;
  final String?
  lapinsConcernes; // 'tous', 'adultes', 'lapereaux', 'reproducteurs', 'custom'
  final double? coutEstime;
  final String? instructions;
  final bool actif;

  ProtocoleSoin({
    this.id,
    required this.nom,
    required this.description,
    required this.type,
    required this.frequence,
    required this.medicamentsNecessaires,
    this.lapinsConcernes,
    this.coutEstime,
    this.instructions,
    this.actif = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'type': type,
      'frequence': frequence,
      'medicaments_necessaires': medicamentsNecessaires.join(','),
      'lapins_concernes': lapinsConcernes,
      'cout_estime': coutEstime,
      'instructions': instructions,
      'actif': actif ? 1 : 0,
    };
  }

  factory ProtocoleSoin.fromMap(Map<String, dynamic> map) {
    return ProtocoleSoin(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      frequence: map['frequence'] as String,
      medicamentsNecessaires: (map['medicaments_necessaires'] as String)
          .split(',')
          .where((e) => e.isNotEmpty)
          .toList(),
      lapinsConcernes: map['lapins_concernes'] as String?,
      coutEstime: map['cout_estime'] != null
          ? (map['cout_estime'] as num).toDouble()
          : null,
      instructions: map['instructions'] as String?,
      actif: (map['actif'] as int) == 1,
    );
  }

  ProtocoleSoin copyWith({
    int? id,
    String? nom,
    String? description,
    String? type,
    String? frequence,
    List<String>? medicamentsNecessaires,
    String? lapinsConcernes,
    double? coutEstime,
    String? instructions,
    bool? actif,
  }) {
    return ProtocoleSoin(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      type: type ?? this.type,
      frequence: frequence ?? this.frequence,
      medicamentsNecessaires:
          medicamentsNecessaires ?? this.medicamentsNecessaires,
      lapinsConcernes: lapinsConcernes ?? this.lapinsConcernes,
      coutEstime: coutEstime ?? this.coutEstime,
      instructions: instructions ?? this.instructions,
      actif: actif ?? this.actif,
    );
  }

  /// Protocoles prédéfinis
  static List<ProtocoleSoin> protocolesParDefaut() {
    return [
      ProtocoleSoin(
        nom: 'Vaccination Annuelle',
        description: 'Vaccination myxomatose et VHD',
        type: 'vaccination',
        frequence: 'annuel',
        medicamentsNecessaires: ['Vaccin Myxomatose', 'Vaccin VHD'],
        lapinsConcernes: 'tous',
        coutEstime: 5.0,
        instructions: 'Injecter en sous-cutané. Renouveler tous les 6-12 mois.',
      ),
      ProtocoleSoin(
        nom: 'Vermifugation Trimestrielle',
        description: 'Prévention parasites internes',
        type: 'vermifugation',
        frequence: 'trimestriel',
        medicamentsNecessaires: ['Vermifuge polyvalent'],
        lapinsConcernes: 'tous',
        coutEstime: 2.0,
        instructions: 'Administrer par voie orale, renouveler tous les 3 mois.',
      ),
      ProtocoleSoin(
        nom: 'Prévention Coccidiose',
        description: 'Traitement préventif coccidiose',
        type: 'prevention',
        frequence: 'mensuel',
        medicamentsNecessaires: ['Anti-coccidien'],
        lapinsConcernes: 'lapereaux',
        coutEstime: 1.5,
        instructions: 'Ajouter dans l\'eau de boisson pendant 5 jours.',
      ),
      ProtocoleSoin(
        nom: 'Soins Post-Mise Bas',
        description: 'Surveillance et soins après mise bas',
        type: 'routine',
        frequence: 'ponctuel',
        medicamentsNecessaires: ['Désinfectant', 'Vitamines'],
        lapinsConcernes: 'reproducteurs',
        coutEstime: 3.0,
        instructions: 'Vérifier la mère et les lapereaux, désinfecter le nid.',
      ),
    ];
  }
}
