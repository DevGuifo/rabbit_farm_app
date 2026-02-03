import 'dart:convert';
import 'farm.dart';
import 'objectif_elevage.dart';

/// Rôles de l'utilisateur dans l'élevage
enum RoleUtilisateur { proprietaire, employe, technicien }

/// Modèle représentant le profil utilisateur collecté durant l'onboarding
class UserProfile {
  final int? id;
  final int? userId; // Référence vers la table users
  final RoleUtilisateur? role;
  final NiveauExperience? niveauExperience;
  final List<ObjectifElevage>? objectifs; // Onboarding V2
  final DateTime dateCreation;
  final DateTime? dateModification;

  UserProfile({
    this.id,
    this.userId,
    this.role,
    this.niveauExperience,
    this.objectifs,
    required this.dateCreation,
    this.dateModification,
  });

  /// Convertir RoleUtilisateur en string
  String? get roleString {
    if (role == null) return null;
    switch (role!) {
      case RoleUtilisateur.proprietaire:
        return 'proprietaire';
      case RoleUtilisateur.employe:
        return 'employe';
      case RoleUtilisateur.technicien:
        return 'technicien';
    }
  }

  /// Convertir NiveauExperience en string
  String? get niveauExperienceString {
    if (niveauExperience == null) return null;
    switch (niveauExperience!) {
      case NiveauExperience.debutant:
        return 'debutant';
      case NiveauExperience.intermediaire:
        return 'intermediaire';
      case NiveauExperience.experimente:
        return 'experimente';
    }
  }

  /// Description conviviale du rôle
  String? get roleDescription {
    if (role == null) return null;
    switch (role!) {
      case RoleUtilisateur.proprietaire:
        return 'Propriétaire';
      case RoleUtilisateur.employe:
        return 'Employé';
      case RoleUtilisateur.technicien:
        return 'Technicien / Vétérinaire';
    }
  }

  /// Description conviviale du niveau d'expérience
  String? get niveauExperienceDescription {
    if (niveauExperience == null) return null;
    switch (niveauExperience!) {
      case NiveauExperience.debutant:
        return 'Débutant';
      case NiveauExperience.intermediaire:
        return 'Intermédiaire';
      case NiveauExperience.experimente:
        return 'Expérimenté';
    }
  }

  /// Description des objectifs
  String? get objectifsDescription {
    if (objectifs == null || objectifs!.isEmpty) return null;
    return objectifs!.map((o) => o.label).join(', ');
  }

  /// Objectifs en JSON pour stockage
  String? get objectifsJson {
    if (objectifs == null || objectifs!.isEmpty) return null;
    return jsonEncode(ObjectifElevageExtension.toJsonList(objectifs));
  }

  /// Créer UserProfile depuis une Map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    RoleUtilisateur? role;
    final roleString = map['role'] as String?;
    if (roleString != null) {
      switch (roleString) {
        case 'proprietaire':
          role = RoleUtilisateur.proprietaire;
          break;
        case 'employe':
          role = RoleUtilisateur.employe;
          break;
        case 'technicien':
          role = RoleUtilisateur.technicien;
          break;
      }
    }

    NiveauExperience? niveau;
    final niveauString = map['niveau_experience'] as String?;
    if (niveauString != null) {
      switch (niveauString) {
        case 'debutant':
          niveau = NiveauExperience.debutant;
          break;
        case 'intermediaire':
          niveau = NiveauExperience.intermediaire;
          break;
        case 'experimente':
          niveau = NiveauExperience.experimente;
          break;
      }
    }

    // Parser les objectifs depuis JSON
    List<ObjectifElevage>? objectifs;
    final objectifsJson = map['objectifs'] as String?;
    if (objectifsJson != null && objectifsJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(objectifsJson);
        objectifs = ObjectifElevageExtension.fromJsonList(decoded);
      } catch (_) {
        objectifs = null;
      }
    }

    return UserProfile(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      role: role,
      niveauExperience: niveau,
      objectifs: objectifs,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      dateModification: map['date_modification'] != null
          ? DateTime.parse(map['date_modification'] as String)
          : null,
    );
  }

  /// Convertir UserProfile en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'role': roleString,
      'niveau_experience': niveauExperienceString,
      'objectifs': objectifsJson,
      'date_creation': dateCreation.toIso8601String(),
      'date_modification': dateModification?.toIso8601String(),
    };
  }

  /// Créer une copie avec des modifications
  UserProfile copyWith({
    int? id,
    int? userId,
    RoleUtilisateur? role,
    NiveauExperience? niveauExperience,
    List<ObjectifElevage>? objectifs,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      niveauExperience: niveauExperience ?? this.niveauExperience,
      objectifs: objectifs ?? this.objectifs,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, role: $roleDescription, niveau: $niveauExperienceDescription)';
  }
}
