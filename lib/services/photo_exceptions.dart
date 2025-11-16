/// Exceptions personnalisées pour le service photo
class PhotoException implements Exception {
  final String message;
  final dynamic originalError;

  PhotoException(this.message, [this.originalError]);

  @override
  String toString() => 'PhotoException: $message';
}

/// Exception levée quand l'utilisateur refuse la permission
class PhotoPermissionDeniedException extends PhotoException {
  PhotoPermissionDeniedException([dynamic originalError])
    : super('Permission d\'accès aux photos refusée', originalError);
}

/// Exception levée quand la sauvegarde échoue
class PhotoSaveException extends PhotoException {
  PhotoSaveException([dynamic originalError])
    : super('Impossible de sauvegarder la photo', originalError);
}

/// Exception levée quand la photo ne peut pas être supprimée
class PhotoDeleteException extends PhotoException {
  PhotoDeleteException([dynamic originalError])
    : super('Impossible de supprimer la photo', originalError);
}
