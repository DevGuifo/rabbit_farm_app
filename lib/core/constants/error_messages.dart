/// Messages d'erreur standardisés pour l'application
/// Utilisés par ErrorService pour afficher des messages cohérents
class ErrorMessages {
  // Messages génériques
  static const String genericError =
      'Une erreur inattendue est survenue. Veuillez réessayer.';
  static const String unknownError =
      'Une erreur inconnue s\'est produite. Contactez le support si le problème persiste.';

  // Erreurs de base de données
  static const String databaseError =
      'Une erreur de base de données est survenue. Veuillez réessayer.';
  static const String databaseConnectionError =
      'Impossible de se connecter à la base de données.';
  static const String databaseQueryError =
      'Erreur lors de la récupération des données.';
  static const String databaseInsertError =
      'Impossible d\'enregistrer les données. Vérifiez les informations saisies.';
  static const String databaseUpdateError =
      'Impossible de modifier les données. Vérifiez les informations saisies.';
  static const String databaseDeleteError =
      'Impossible de supprimer les données.';

  // Erreurs de validation
  static const String validationError =
      'Les données saisies ne sont pas valides.';
  static const String requiredField = 'Ce champ est obligatoire.';
  static const String invalidFormat = 'Le format saisi n\'est pas valide.';
  static const String invalidDate = 'La date saisie n\'est pas valide.';
  static const String invalidNumber = 'Le nombre saisi n\'est pas valide.';
  static const String invalidEmail = 'L\'adresse email n\'est pas valide.';

  // Erreurs de fichiers
  static const String fileNotFound = 'Le fichier demandé est introuvable.';
  static const String fileReadError =
      'Impossible de lire le fichier. Vérifiez les permissions.';
  static const String fileWriteError =
      'Impossible d\'écrire le fichier. Vérifiez les permissions.';
  static const String fileDeleteError = 'Impossible de supprimer le fichier.';
  static const String filePermissionError =
      'Permission refusée pour accéder au fichier.';

  // Erreurs réseau (pour future sync)
  static const String networkError =
      'Problème de connexion. Vérifiez votre connexion internet.';
  static const String networkTimeout =
      'La connexion a expiré. Veuillez réessayer.';
  static const String networkConnectionFailed =
      'Impossible de se connecter au serveur.';

  // Erreurs de permissions
  static const String permissionDenied =
      'Permission refusée. Veuillez autoriser l\'accès dans les paramètres.';
  static const String cameraPermissionDenied =
      'Permission caméra refusée. Activez-la dans les paramètres.';
  static const String storagePermissionDenied =
      'Permission stockage refusée. Activez-la dans les paramètres.';

  // Erreurs spécifiques aux fonctionnalités
  static const String lapinNotFound = 'Lapin introuvable.';
  static const String lapinAlreadyExists = 'Un lapin avec ce nom existe déjà.';
  static const String accouplementNotFound = 'Accouplement introuvable.';
  static const String porteeNotFound = 'Portée introuvable.';
  static const String soinNotFound = 'Soin introuvable.';
  static const String peseeNotFound = 'Pesée introuvable.';

  // Messages de succès standardisés
  static const String saveSuccess = 'Données enregistrées avec succès.';
  static const String updateSuccess = 'Données modifiées avec succès.';
  static const String deleteSuccess = 'Données supprimées avec succès.';
  static const String exportSuccess = 'Export réalisé avec succès.';
  static const String importSuccess = 'Import réalisé avec succès.';

  // Messages d'avertissement
  static const String unsavedChanges =
      'Vous avez des modifications non enregistrées.';
  static const String confirmDelete = 'Êtes-vous sûr de vouloir supprimer ?';
  static const String dataLossWarning =
      'Cette action peut entraîner une perte de données.';

  /// Générer un message d'erreur personnalisé avec contexte
  static String customError(String context, String details) {
    return '$context : $details';
  }

  /// Générer un message d'erreur pour une opération spécifique
  static String operationError(String operation, String reason) {
    return 'Impossible de $operation. $reason';
  }
}
