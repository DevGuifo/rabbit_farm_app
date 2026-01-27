import 'app_exception.dart';

/// Exception levée lors d'erreurs de permissions (caméra, stockage, etc.)
class PermissionException extends AppException {
  /// Type de permission refusée
  final PermissionType type;

  const PermissionException({
    required this.type,
    required super.message,
    super.details,
    super.stackTrace,
  }) : super(
          code: 'PERMISSION_ERROR',
        );

  /// Créer une PermissionException pour la caméra
  factory PermissionException.camera([dynamic details]) {
    return PermissionException(
      type: PermissionType.camera,
      message: 'Permission caméra refusée. Activez-la dans les paramètres.',
      details: details,
    );
  }

  /// Créer une PermissionException pour le stockage
  factory PermissionException.storage([dynamic details]) {
    return PermissionException(
      type: PermissionType.storage,
      message: 'Permission stockage refusée. Activez-la dans les paramètres.',
      details: details,
    );
  }

  /// Créer une PermissionException pour les notifications
  factory PermissionException.notifications([dynamic details]) {
    return PermissionException(
      type: PermissionType.notifications,
      message: 'Permission notifications refusée. Activez-la dans les paramètres.',
      details: details,
    );
  }

  /// Créer une PermissionException générique
  factory PermissionException.generic(PermissionType type, String message, [dynamic details]) {
    return PermissionException(
      type: type,
      message: message,
      details: details,
    );
  }
}

/// Types de permissions possibles
enum PermissionType {
  camera,
  storage,
  notifications,
  location,
  other,
}
