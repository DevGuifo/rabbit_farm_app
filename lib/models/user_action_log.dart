/// Type d'action effectuée par un utilisateur
enum ActionType {
  /// Création d'un élément
  create,

  /// Modification d'un élément
  update,

  /// Suppression d'un élément
  delete,

  /// Consultation d'un élément
  view,

  /// Export de données
  export,

  /// Import de données
  import,

  /// Connexion
  login,

  /// Déconnexion
  logout,

  /// Changement de paramètres
  settings,
}

/// Modèle de données représentant une action effectuée par un utilisateur
class UserActionLog {
  final int? id;
  final int userId;
  final ActionType actionType;
  final String entityType; // Ex: 'lapin', 'accouplement', 'soin', etc.
  final int? entityId; // ID de l'entité concernée
  final String? description;
  final Map<String, dynamic>? details; // Détails supplémentaires en JSON
  final DateTime dateAction;

  UserActionLog({
    this.id,
    required this.userId,
    required this.actionType,
    required this.entityType,
    this.entityId,
    this.description,
    this.details,
    required this.dateAction,
  });

  /// Convertir le type d'action en String pour la base de données
  String get actionTypeString {
    switch (actionType) {
      case ActionType.create:
        return 'create';
      case ActionType.update:
        return 'update';
      case ActionType.delete:
        return 'delete';
      case ActionType.view:
        return 'view';
      case ActionType.export:
        return 'export';
      case ActionType.import:
        return 'import';
      case ActionType.login:
        return 'login';
      case ActionType.logout:
        return 'logout';
      case ActionType.settings:
        return 'settings';
    }
  }

  /// Créer un UserActionLog depuis une Map (depuis la base de données)
  factory UserActionLog.fromMap(Map<String, dynamic> map) {
    ActionType actionType;
    switch (map['action_type'] as String) {
      case 'create':
        actionType = ActionType.create;
        break;
      case 'update':
        actionType = ActionType.update;
        break;
      case 'delete':
        actionType = ActionType.delete;
        break;
      case 'view':
        actionType = ActionType.view;
        break;
      case 'export':
        actionType = ActionType.export;
        break;
      case 'import':
        actionType = ActionType.import;
        break;
      case 'login':
        actionType = ActionType.login;
        break;
      case 'logout':
        actionType = ActionType.logout;
        break;
      case 'settings':
        actionType = ActionType.settings;
        break;
      default:
        actionType = ActionType.view;
    }

    Map<String, dynamic>? details;
    if (map['details'] != null) {
      try {
        // Si c'est déjà une Map, l'utiliser directement
        if (map['details'] is Map) {
          details = Map<String, dynamic>.from(map['details'] as Map);
        } else {
          // Sinon, essayer de parser depuis JSON string
          // (nécessiterait import 'dart:convert')
        }
      } catch (e) {
        details = null;
      }
    }

    return UserActionLog(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      actionType: actionType,
      entityType: map['entity_type'] as String,
      entityId: map['entity_id'] as int?,
      description: map['description'] as String?,
      details: details,
      dateAction: DateTime.parse(map['date_action'] as String),
    );
  }

  /// Convertir le UserActionLog en Map (pour la base de données)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'action_type': actionTypeString,
      'entity_type': entityType,
      'entity_id': entityId,
      'description': description,
      'details': details?.toString(), // Stocké comme string pour simplifier
      'date_action': dateAction.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserActionLog(id: $id, userId: $userId, action: $actionTypeString, entity: $entityType, date: $dateAction)';
  }
}
