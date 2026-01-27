import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/permission_service.dart';
import '../../services/photo_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/snackbar_helper.dart';
import '../../services/secure_storage_service.dart';
import '../../widgets/uniform_app_bar.dart';
import '../../services/error_service.dart';

/// Écran d'édition du profil utilisateur actuel
class EditerProfilScreen extends StatefulWidget {
  const EditerProfilScreen({super.key});

  @override
  State<EditerProfilScreen> createState() => _EditerProfilScreenState();
}

class _EditerProfilScreenState extends State<EditerProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _notesController = TextEditingController();
  final _photoService = PhotoService();

  User? _currentUser;
  bool _isLoading = true;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _chargerProfil();
  }

  Future<void> _chargerProfil() async {
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    // Initialiser l'utilisateur actuel si nécessaire
    if (userProvider.currentUser == null) {
      final secureStorage = SecureStorageService();
      final email = await secureStorage.getUserEmail();
      final userId = authProvider.currentUserId;

      await userProvider.initializeCurrentUser(userId, email);
    }

    final user = userProvider.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
        _nomController.text = user.nom;
        _prenomController.text = user.prenom ?? '';
        _notesController.text = user.notes ?? '';
        _photoPath = user.photoPath;
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _enregistrerProfil() async {
    if (!_formKey.currentState!.validate() || _currentUser == null) {
      return;
    }

    final userProvider = context.read<UserProvider>();

    final user = _currentUser!.copyWith(
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim().isEmpty
          ? null
          : _prenomController.text.trim(),
      photoPath: _photoPath,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final success = await userProvider.mettreAJourUser(user);

    if (mounted) {
      if (success) {
        SnackbarHelper.showSuccess(context, 'Profil modifié avec succès');
        Navigator.pop(context, true);
      } else {
        SnackbarHelper.showError(
          context,
          userProvider.errorMessage ?? 'Erreur lors de l\'enregistrement',
        );
      }
    }
  }

  Future<void> _selectionnerPhoto() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(AppLocalizations.of(context).photoTakePicture),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);
                  try {
                    final photoPath = await _photoService.prendrePhoto();
                    if (photoPath != null && mounted) {
                      setState(() {
                        _photoPath = photoPath;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ErrorService.showError(context, e);
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(context).photoChooseGallery),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);
                  try {
                    final photoPath = await _photoService.selectionnerPhoto();
                    if (photoPath != null && mounted) {
                      setState(() {
                        _photoPath = photoPath;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ErrorService.showError(context, e);
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final permissionService = PermissionService();

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark
            ? AppTheme.backgroundDarkMode
            : AppTheme.backgroundLight,
        appBar: SimpleAppBar(title: 'Mon profil'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: isDark
            ? AppTheme.backgroundDarkMode
            : AppTheme.backgroundLight,
        appBar: SimpleAppBar(title: 'Mon profil'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppTheme.error),
              const SizedBox(height: 16),
              Text(
                'Erreur',
                style: AppTheme.titleLarge.copyWith(
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Impossible de charger votre profil',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDarkMode
          : AppTheme.backgroundLight,
      appBar: SimpleAppBar(
        title: 'Mon profil',
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: _enregistrerProfil,
            tooltip: AppLocalizations.of(context).tooltipEnregistrer,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo de profil
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.primaryNeonGreen.withValues(
                      alpha: 0.2,
                    ),
                    backgroundImage: _photoPath != null
                        ? _isAssetPath(_photoPath!)
                              ? AssetImage(_photoPath!)
                              : FileImage(File(_photoPath!)) as ImageProvider
                        : null,
                    child: _photoPath == null
                        ? Text(
                            _currentUser!.nomComplet.isNotEmpty
                                ? _currentUser!.nomComplet[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 48,
                              color: AppTheme.primaryNeonGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryNeonGreen,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: AppTheme.textOnPrimary,
                        ),
                        onPressed: _selectionnerPhoto,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Email (non modifiable)
            TextFormField(
              initialValue: _currentUser!.email,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                ).utilisateurFormEmail.replaceAll(' *', ''),
                prefixIcon: const Icon(Icons.email_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),

            // Nom
            TextFormField(
              controller: _nomController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).utilisateurFormNom,
                hintText: 'Dupont',
                prefixIcon: const Icon(Icons.person_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context).validationNomPrenomRequis;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Prénom
            TextFormField(
              controller: _prenomController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).utilisateurFormPrenom,
                hintText: 'Jean',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rôle (affichage seulement)
            TextFormField(
              initialValue: permissionService.getRoleName(_currentUser!.role),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                ).utilisateurFormRole.replaceAll(' *', ''),
                prefixIcon: const Icon(Icons.admin_panel_settings_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).utilisateurFormNotes,
                hintText: 'Notes personnelles...',
                prefixIcon: const Icon(Icons.note_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Informations supplémentaires
            Card(
              color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations',
                      style: AppTheme.titleSmall.copyWith(
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Date de création',
                      _currentUser!.dateCreation.toString().split(' ')[0],
                      Icons.calendar_today_rounded,
                    ),
                    if (_currentUser!.derniereConnexion != null)
                      _buildInfoRow(
                        'Dernière connexion',
                        _currentUser!.derniereConnexion!.toString().split(
                          ' ',
                        )[0],
                        Icons.access_time_rounded,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton Enregistrer
            ElevatedButton(
              onPressed: _enregistrerProfil,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNeonGreen,
                foregroundColor: AppTheme.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Enregistrer les modifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Vérifie si le chemin est un asset path (commence par 'assets/')
  bool _isAssetPath(String path) {
    return path.startsWith('assets/');
  }
}
