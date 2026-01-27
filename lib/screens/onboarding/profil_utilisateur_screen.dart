import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/onboarding_provider.dart';
import '../../models/user_profile.dart';
import '../../models/farm.dart'; // Import explicite pour NiveauExperience
import '../../utils/logger.dart';
import '../../theme/app_theme.dart';

/// Écran 4 : Profil utilisateur minimal
class OnboardingProfilUtilisateurScreen extends StatefulWidget {
  const OnboardingProfilUtilisateurScreen({super.key});

  @override
  State<OnboardingProfilUtilisateurScreen> createState() =>
      _OnboardingProfilUtilisateurScreenState();
}

class _OnboardingProfilUtilisateurScreenState
    extends State<OnboardingProfilUtilisateurScreen> {
  RoleUtilisateur? _roleSelectionne;
  NiveauExperience? _niveauSelectionne;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Barre de progression
              _buildProgressBar(context),
              const SizedBox(height: 40),

              // Contenu principal
              Expanded(
                child: ListView(
                  children: [
                    // Titre
                    Text(
                      'Dites-nous en plus sur vous',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Sous-titre
                    Text(
                      'Ces informations sont optionnelles et nous aident à personnaliser l\'expérience.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Section Rôle
                    _buildRoleSection(),
                    const SizedBox(height: 32),

                    // Section Niveau d'expérience
                    _buildNiveauExperienceSection(),
                  ],
                ),
              ),

              // Boutons d'action
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        final progress = provider.progressPercentage / 100.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profil utilisateur',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  '${provider.progressPercentage}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_outline, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              'Quel est votre rôle ?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Options de rôles
        _buildRoleCard(
          RoleUtilisateur.proprietaire,
          'Propriétaire',
          'Vous possédez l\'élevage',
          Icons.admin_panel_settings_outlined,
          Colors.blue.shade100,
          Colors.blue.shade700,
        ),
        const SizedBox(height: 12),
        _buildRoleCard(
          RoleUtilisateur.employe,
          'Employé',
          'Vous travaillez dans l\'élevage',
          Icons.work_outline,
          Colors.green.shade100,
          Colors.green.shade700,
        ),
        const SizedBox(height: 12),
        _buildRoleCard(
          RoleUtilisateur.technicien,
          'Technicien / Vétérinaire',
          'Vous apportez un support technique',
          Icons.medical_services_outlined,
          Colors.orange.shade100,
          Colors.orange.shade700,
        ),
      ],
    );
  }

  Widget _buildRoleCard(
    RoleUtilisateur role,
    String titre,
    String description,
    IconData icone,
    Color backgroundIcone,
    Color couleurIcone,
  ) {
    final isSelected = _roleSelectionne == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _roleSelectionne = role;
        });
        logger.info('Rôle sélectionné: ${role.name}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: backgroundIcone,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icone, size: 24, color: couleurIcone),
            ),
            const SizedBox(width: 16),

            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Indicateur de sélection
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNiveauExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star_outline, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              'Niveau d\'expérience',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Options de niveau d'expérience
        _buildNiveauCard(
          NiveauExperience.debutant,
          'Débutant',
          'Vous commencez dans l\'élevage',
          1,
        ),
        const SizedBox(height: 12),
        _buildNiveauCard(
          NiveauExperience.intermediaire,
          'Intermédiaire',
          'Vous avez quelques années d\'expérience',
          2,
        ),
        const SizedBox(height: 12),
        _buildNiveauCard(
          NiveauExperience.experimente,
          'Expérimenté',
          'Vous maîtrisez l\'élevage',
          3,
        ),
      ],
    );
  }

  Widget _buildNiveauCard(
    NiveauExperience niveau,
    String titre,
    String description,
    int nombreEtoiles,
  ) {
    final isSelected = _niveauSelectionne == niveau;

    return GestureDetector(
      onTap: () {
        setState(() {
          _niveauSelectionne = niveau;
        });
        logger.info('Niveau d\'expérience sélectionné: ${niveau.name}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Étoiles
            Row(
              children: List.generate(3, (index) {
                return Icon(
                  index < nombreEtoiles ? Icons.star : Icons.star_outline,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.orange.shade400,
                  size: 20,
                );
              }),
            ),
            const SizedBox(width: 16),

            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Indicateur de sélection
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            // Bouton Précédent
            Expanded(
              child: OutlinedButton(
                onPressed: provider.isLoading
                    ? null
                    : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(AppLocalizations.of(context).cheptelBtnPrecedent),
              ),
            ),
            const SizedBox(width: 16),

            // Bouton Suivant
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: !provider.isLoading
                    ? () => _handleSuivant(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Suivant',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleSuivant(BuildContext context) async {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);

    logger.info('Sauvegarde du profil utilisateur');

    // Sauvegarder le profil utilisateur (optionnel)
    final success = await provider.saveUserProfile(
      role: _roleSelectionne,
      niveauExperience: _niveauSelectionne,
    );

    if (success) {
      await provider.nextStep();
      if (context.mounted) {
        Navigator.pushNamed(context, '/onboarding/synchronisation');
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Une erreur est survenue'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }
}
