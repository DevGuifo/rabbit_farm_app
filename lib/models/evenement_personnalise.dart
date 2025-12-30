/// Modèle d'événement personnalisé pour le calendrier
class EvenementPersonnalise {
  final int? id;
  final String titre;
  final String? description;
  final DateTime date;
  final String? heure; // Format HH:mm
  final String? categorie; // Tâche, Rappel, Rendez-vous, etc.
  final int? lapinId;
  final bool important;
  final bool notificationActive;
  final String? couleur; // Hex color

  EvenementPersonnalise({
    this.id,
    required this.titre,
    this.description,
    required this.date,
    this.heure,
    this.categorie,
    this.lapinId,
    this.important = false,
    this.notificationActive = false,
    this.couleur,
  });

  /// Créer depuis Map (DB)
  factory EvenementPersonnalise.fromMap(Map<String, dynamic> map) {
    return EvenementPersonnalise(
      id: map['id'] as int?,
      titre: map['titre'] as String,
      description: map['description'] as String?,
      date: DateTime.parse(map['date'] as String),
      heure: map['heure'] as String?,
      categorie: map['categorie'] as String?,
      lapinId: map['lapin_id'] as int?,
      important: (map['important'] as int?) == 1,
      notificationActive: (map['notification_active'] as int?) == 1,
      couleur: map['couleur'] as String?,
    );
  }

  /// Convertir vers Map (DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'date': date.toIso8601String(),
      'heure': heure,
      'categorie': categorie,
      'lapin_id': lapinId,
      'important': important ? 1 : 0,
      'notification_active': notificationActive ? 1 : 0,
      'couleur': couleur,
    };
  }

  /// Créer une copie avec modifications
  EvenementPersonnalise copyWith({
    int? id,
    String? titre,
    String? description,
    DateTime? date,
    String? heure,
    String? categorie,
    int? lapinId,
    bool? important,
    bool? notificationActive,
    String? couleur,
  }) {
    return EvenementPersonnalise(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      date: date ?? this.date,
      heure: heure ?? this.heure,
      categorie: categorie ?? this.categorie,
      lapinId: lapinId ?? this.lapinId,
      important: important ?? this.important,
      notificationActive: notificationActive ?? this.notificationActive,
      couleur: couleur ?? this.couleur,
    );
  }
}
