import 'app_exception.dart';

/// Exception levée lorsqu'une ressource n'est pas trouvée
class NotFoundException extends AppException {
  /// Type de ressource non trouvée
  final String resourceType;

  /// Identifiant de la ressource recherchée
  final dynamic resourceId;

  const NotFoundException({
    required this.resourceType,
    this.resourceId,
    String? message,
    super.details,
    super.stackTrace,
  }) : super(
          code: 'NOT_FOUND',
          message: message ??
              (resourceId != null
                  ? '$resourceType avec l\'ID $resourceId introuvable'
                  : '$resourceType introuvable'),
        );

  /// Créer une NotFoundException pour un lapin
  factory NotFoundException.lapin(int lapinId) {
    return NotFoundException(
      resourceType: 'Lapin',
      resourceId: lapinId,
      message: 'Lapin introuvable',
    );
  }

  /// Créer une NotFoundException pour un accouplement
  factory NotFoundException.accouplement(int accouplementId) {
    return NotFoundException(
      resourceType: 'Accouplement',
      resourceId: accouplementId,
      message: 'Accouplement introuvable',
    );
  }

  /// Créer une NotFoundException pour une portée
  factory NotFoundException.portee(int porteeId) {
    return NotFoundException(
      resourceType: 'Portée',
      resourceId: porteeId,
      message: 'Portée introuvable',
    );
  }

  /// Créer une NotFoundException pour un soin
  factory NotFoundException.soin(int soinId) {
    return NotFoundException(
      resourceType: 'Soin',
      resourceId: soinId,
      message: 'Soin introuvable',
    );
  }

  /// Créer une NotFoundException pour une pesée
  factory NotFoundException.pesee(int peseeId) {
    return NotFoundException(
      resourceType: 'Pesée',
      resourceId: peseeId,
      message: 'Pesée introuvable',
    );
  }
}
