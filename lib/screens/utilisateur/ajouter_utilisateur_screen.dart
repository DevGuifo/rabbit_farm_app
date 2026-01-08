import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../services/permission_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/uniform_app_bar.dart';

/// Écran d'ajout/édition d'utilisateur
class AjouterUtilisateurScreen extends StatefulWidget {
  final User? user; // Si fourni, mode édition

  const AjouterUtilisateurScreen({super.key, this.user});

  @override
  State<AjouterUtilisateurScreen> createState() =>
      _AjouterUtilisateurScreenState();
}

class _AjouterUtilisateurScreenState extends State<AjouterUtilisateurScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _notesController = TextEditingController();

  UserRole _role = UserRole.eleveur;
  bool _isActive = true;

  final PermissionService _permissionService = PermissionService();

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      // Mode édition
      _emailController.text = widget.user!.email;
      _nomController.text = widget.user!.nom;
      _prenomController.text = widget.user!.prenom ?? '';
      _notesController.text = widget.user!.notes ?? '';
      _role = widget.user!.role;
      _isActive = widget.user!.isActive;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _enregistrerUtilisateur() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userProvider = context.read<UserProvider>();

    bool success;
    if (widget.user != null) {
      // Mode édition
      final user = widget.user!.copyWith(
        email: _emailController.text.trim(),
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim().isEmpty
            ? null
            : _prenomController.text.trim(),
        role: _role,
        isActive: _isActive,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      success = await userProvider.mettreAJourUser(user);
    } else {
      // Mode création
      success = await userProvider.creerUser(
        email: _emailController.text.trim(),
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim().isEmpty
            ? null
            : _prenomController.text.trim(),
        role: _role,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    }

    if (mounted) {
      if (success) {
        SnackbarHelper.showSuccess(
          context,
          widget.user != null
              ? 'Utilisateur modifié avec succès'
              : 'Utilisateur créé avec succès',
        );
        Navigator.pop(context, true);
      } else {
        SnackbarHelper.showError(
          context,
          userProvider.errorMessage ?? 'Erreur lors de l\'enregistrement',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDarkMode
          : AppTheme.backgroundLight,
      appBar: UniformAppBar(
        title: widget.user != null
            ? 'Modifier l\'utilisateur'
            : 'Nouvel utilisateur',
        icon: Icons.person_add_rounded,
        iconColor: AppTheme.info,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            onPressed: _enregistrerUtilisateur,
            tooltip: AppLocalizations.of(context).tooltipEnregistrer,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).utilisateurFormEmail,
                hintText: 'exemple@email.com',
                prefixIcon: const Icon(Icons.email_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: widget.user == null, // Email non modifiable en édition
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context).validationEmailRequis;
                }
                if (!value.contains('@')) {
                  return AppLocalizations.of(context).validationEmailInvalide;
                }
                return null;
              },
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

            // Rôle
            DropdownButtonFormField<UserRole>(
              initialValue: _role,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).utilisateurFormRole,
                prefixIcon: const Icon(Icons.admin_panel_settings_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_permissionService.getRoleName(role)),
                      Text(
                        _permissionService.getRoleDescription(role),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _role = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Statut actif (seulement en édition)
            if (widget.user != null)
              SwitchListTile(
                title: Text(
                  AppLocalizations.of(context).switchUtilisateurActif,
                ),
                subtitle: Text(
                  AppLocalizations.of(context).switchUtilisateurActifSubtitle,
                ),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                activeThumbColor: AppTheme.primaryNeonGreen,
              ),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).utilisateurFormNotes,
                hintText: 'Notes supplémentaires...',
                prefixIcon: const Icon(Icons.note_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Bouton Enregistrer
            ElevatedButton(
              onPressed: _enregistrerUtilisateur,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNeonGreen,
                foregroundColor: AppTheme.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.user != null ? 'Modifier' : 'Créer',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
