import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../utils/logger.dart';
import 'photo_exceptions.dart';

/// Service singleton pour gérer les photos des lapins
class PhotoService {
  static final PhotoService _instance = PhotoService._internal();
  factory PhotoService() => _instance;
  PhotoService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Prendre une photo avec l'appareil photo
  Future<String?> prendrePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo == null) {
        logger.debug('Prise de photo annulée par l\'utilisateur');
        return null;
      }

      return await _sauvegarderPhoto(photo);
    } on PlatformException catch (e) {
      logger.error('Erreur de permission ou appareil photo', e);
      throw PhotoPermissionDeniedException(e);
    } catch (e, stackTrace) {
      logger.error('Erreur lors de la prise de photo', e, stackTrace);
      throw PhotoException('Erreur lors de la prise de photo', e);
    }
  }

  /// Sélectionner une photo depuis la galerie
  Future<String?> selectionnerPhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo == null) {
        logger.debug('Sélection de photo annulée par l\'utilisateur');
        return null;
      }

      return await _sauvegarderPhoto(photo);
    } on PlatformException catch (e) {
      logger.error('Erreur de permission galerie', e);
      throw PhotoPermissionDeniedException(e);
    } catch (e, stackTrace) {
      logger.error('Erreur lors de la sélection de photo', e, stackTrace);
      throw PhotoException('Erreur lors de la sélection de photo', e);
    }
  }

  /// Sauvegarder une photo dans le dossier de l'application
  Future<String> _sauvegarderPhoto(XFile photo) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String photosDir = path.join(appDir.path, 'photos');

      // Créer le dossier photos s'il n'existe pas
      final Directory dir = Directory(photosDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Générer un nom de fichier unique
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(photo.path);
      final String fileName = 'lapin_$timestamp$extension';
      final String savedPath = path.join(photosDir, fileName);

      // Copier le fichier
      final File file = File(photo.path);
      await file.copy(savedPath);

      logger.info('Photo sauvegardée: $savedPath');
      return savedPath;
    } catch (e, stackTrace) {
      logger.error('Erreur lors de la sauvegarde de la photo', e, stackTrace);
      throw PhotoSaveException(e);
    }
  }

  /// Supprimer une photo
  Future<bool> supprimerPhoto(String photoPath) async {
    try {
      final File file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
        logger.info('Photo supprimée: $photoPath');
        return true;
      }
      logger.warning('Photo inexistante: $photoPath');
      return false;
    } catch (e, stackTrace) {
      logger.error('Erreur lors de la suppression de la photo', e, stackTrace);
      throw PhotoDeleteException(e);
    }
  }

  /// Vérifier si une photo existe
  Future<bool> photoExiste(String photoPath) async {
    try {
      final File file = File(photoPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Obtenir la taille d'une photo en Mo
  Future<double> getTaillePhoto(String photoPath) async {
    try {
      final File file = File(photoPath);
      if (await file.exists()) {
        final int bytes = await file.length();
        return bytes / (1024 * 1024); // Convertir en Mo
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Afficher un dialogue pour choisir entre caméra et galerie
  Future<String?> choisirSourcePhoto() async {
    // Cette méthode sera appelée depuis l'UI avec un dialogue
    // Elle retourne null, l'UI doit gérer le dialogue
    return null;
  }
}
