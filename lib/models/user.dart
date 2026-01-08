/// Rôles disponibles pour les utilisateurs
enum UserRole {
  /// Administrateur - Accès complet
  admin,
  
  /// Éleveur - Accès complet aux données d'élevage
  eleveur,
  
  /// Assistant - Accès limité (lecture + certaines actions)
  assistant,
  
  /// Observateur - Accès en lecture seule
  observateur,
}

/// Modèle de données représentant un utilisateur
class User {
  final int? id;
  final String email;
  final String nom;
  final String? prenom;
  final UserRole role;
  final String? photoPath;
  final bool isActive;
  final DateTime dateCreation;
  final DateTime? derniereConnexion;
  final String? notes;

  User({
    this.id,
    required this.email,
    required this.nom,
    this.prenom,
    this.role = UserRole.eleveur,
    this.photoPath,
    this.isActive = true,
    required this.dateCreation,
    this.derniereConnexion,
    this.notes,
  });

  /// Nom complet de l'utilisateur
  String get nomComplet {
    if (prenom != null && prenom!.isNotEmpty) {
      return '$prenom $nom';
    }
    return nom;
  }

  /// Convertir le rôle en String pour la base de données
  String get roleString {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.eleveur:
        return 'eleveur';
      case UserRole.assistant:
        return 'assistant';
      case UserRole.observateur:
        return 'observateur';
    }
  }

  /// Créer un User depuis une Map (depuis la base de données)
  factory User.fromMap(Map<String, dynamic> map) {
    UserRole role;
    switch (map['role'] as String) {
      case 'admin':
        role = UserRole.admin;
        break;
      case 'eleveur':
        role = UserRole.eleveur;
        break;
      case 'assistant':
        role = UserRole.assistant;
        break;
      case 'observateur':
        role = UserRole.observateur;
        break;
      default:
        role = UserRole.eleveur;
    }

    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      nom: map['nom'] as String,
      prenom: map['prenom'] as String?,
      role: role,
      photoPath: map['photo_path'] as String?,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      dateCreation: DateTime.parse(map['date_creation'] as String),
      derniereConnexion: map['derniere_connexion'] != null
          ? DateTime.parse(map['derniere_connexion'] as String)
          : null,
      notes: map['notes'] as String?,
    );
  }

  /// Convertir le User en Map (pour la base de données)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'role': roleString,
      'photo_path': photoPath,
      'is_active': isActive ? 1 : 0,
      'date_creation': dateCreation.toIso8601String(),
      'derniere_connexion': derniereConnexion?.toIso8601String(),
      'notes': notes,
    };
  }

  /// Créer une copie du User avec des modifications
  User copyWith({
    int? id,
    String? email,
    String? nom,
    String? prenom,
    UserRole? role,
    String? photoPath,
    bool? isActive,
    DateTime? dateCreation,
    DateTime? derniereConnexion,
    String? notes,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      role: role ?? this.role,
      photoPath: photoPath ?? this.photoPath,
      isActive: isActive ?? this.isActive,
      dateCreation: dateCreation ?? this.dateCreation,
      derniereConnexion: derniereConnexion ?? this.derniereConnexion,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, nom: $nomComplet, role: $roleString)';
  }
}

