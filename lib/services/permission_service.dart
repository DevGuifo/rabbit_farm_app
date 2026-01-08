import '../models/user.dart';

/// Service de gestion des permissions basées sur les rôles
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Vérifier si un rôle peut créer des éléments
  bool canCreate(UserRole role, String entityType) {
    switch (role) {
      case UserRole.admin:
      case UserRole.eleveur:
        return true; // Tous les types
      case UserRole.assistant:
        // L'assistant peut créer certains éléments mais pas tous
        return [
          'pesee',
          'soin',
          'tache',
          'note',
        ].contains(entityType.toLowerCase());
      case UserRole.observateur:
        return false; // Lecture seule
    }
  }

  /// Vérifier si un rôle peut modifier des éléments
  bool canUpdate(UserRole role, String entityType) {
    switch (role) {
      case UserRole.admin:
      case UserRole.eleveur:
        return true; // Tous les types
      case UserRole.assistant:
        // L'assistant peut modifier certains éléments
        return [
          'pesee',
          'soin',
          'tache',
          'note',
        ].contains(entityType.toLowerCase());
      case UserRole.observateur:
        return false; // Lecture seule
    }
  }

  /// Vérifier si un rôle peut supprimer des éléments
  bool canDelete(UserRole role, String entityType) {
    switch (role) {
      case UserRole.admin:
        return true; // Tous les types
      case UserRole.eleveur:
        // L'éleveur peut supprimer la plupart des éléments
        return ![
          'user', // Pas de suppression d'utilisateurs
        ].contains(entityType.toLowerCase());
      case UserRole.assistant:
        // L'assistant peut supprimer seulement ses propres éléments
        return [
          'tache',
          'note',
        ].contains(entityType.toLowerCase());
      case UserRole.observateur:
        return false; // Lecture seule
    }
  }

  /// Vérifier si un rôle peut voir des éléments
  bool canView(UserRole role, String entityType) {
    // Tous les rôles peuvent voir (lecture)
    return true;
  }

  /// Vérifier si un rôle peut exporter des données
  bool canExport(UserRole role) {
    switch (role) {
      case UserRole.admin:
      case UserRole.eleveur:
        return true;
      case UserRole.assistant:
      case UserRole.observateur:
        return false;
    }
  }

  /// Vérifier si un rôle peut importer des données
  bool canImport(UserRole role) {
    switch (role) {
      case UserRole.admin:
      case UserRole.eleveur:
        return true;
      case UserRole.assistant:
      case UserRole.observateur:
        return false;
    }
  }

  /// Vérifier si un rôle peut gérer les utilisateurs
  bool canManageUsers(UserRole role) {
    return role == UserRole.admin;
  }

  /// Vérifier si un rôle peut modifier les paramètres
  bool canModifySettings(UserRole role) {
    switch (role) {
      case UserRole.admin:
      case UserRole.eleveur:
        return true;
      case UserRole.assistant:
      case UserRole.observateur:
        return false;
    }
  }

  /// Obtenir le nom du rôle en français
  String getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.eleveur:
        return 'Éleveur';
      case UserRole.assistant:
        return 'Assistant';
      case UserRole.observateur:
        return 'Observateur';
    }
  }

  /// Obtenir la description du rôle
  String getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Accès complet à toutes les fonctionnalités et gestion des utilisateurs';
      case UserRole.eleveur:
        return 'Accès complet aux données d\'élevage';
      case UserRole.assistant:
        return 'Accès limité : peut créer/modifier pesées, soins et tâches';
      case UserRole.observateur:
        return 'Accès en lecture seule';
    }
  }
}

