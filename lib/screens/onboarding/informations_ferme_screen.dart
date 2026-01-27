import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/onboarding_provider.dart';
import '../../models/farm.dart';
import '../../utils/logger.dart';
import '../../theme/app_theme.dart';

/// Écran 3 : Informations minimales de la ferme
class OnboardingInformationsFermeScreen extends StatefulWidget {
  const OnboardingInformationsFermeScreen({super.key});

  @override
  State<OnboardingInformationsFermeScreen> createState() =>
      _OnboardingInformationsFermeScreenState();
}

class _OnboardingInformationsFermeScreenState
    extends State<OnboardingInformationsFermeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _regionController = TextEditingController();
  final _paysController = TextEditingController();
  TailleElevage? _tailleElevageSelectionnee;

  @override
  void dispose() {
    _nomController.dispose();
    _regionController.dispose();
    _paysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
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
                        'Parlez-nous de votre élevage',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Sous-titre
                      Text(
                        'Ces informations sont optionnelles mais nous aident à mieux vous accompagner.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Nom de la ferme
                      _buildTextField(
                        controller: _nomController,
                        label: 'Nom de la ferme',
                        hint: 'Ferme des Lapins Heureux',
                        icon: Icons.home_outlined,
                        isRequired: false,
                      ),
                      const SizedBox(height: 20),

                      // Région
                      _buildTextField(
                        controller: _regionController,
                        label: 'Région',
                        hint: 'Bretagne, Île-de-France...',
                        icon: Icons.location_on_outlined,
                        isRequired: false,
                      ),
                      const SizedBox(height: 20),

                      // Pays
                      _buildTextField(
                        controller: _paysController,
                        label: 'Pays',
                        hint: 'France',
                        icon: Icons.flag_outlined,
                        isRequired: false,
                      ),
                      const SizedBox(height: 24),

                      // Taille de l'élevage
                      _buildTailleElevageSection(),
                      const SizedBox(height: 24),

                      // Note de confidentialité
                      _buildConfidentialiteNote(),
                    ],
                  ),
                ),

                // Boutons d'action
                _buildActionButtons(context),
              ],
            ),
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
                  'Informations ferme',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: isRequired
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildTailleElevageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Taille estimée de l\'élevage',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Options de taille
        ...TailleElevage.values.map((taille) => _buildTailleOption(taille)),
      ],
    );
  }

  Widget _buildTailleOption(TailleElevage taille) {
    final isSelected = _tailleElevageSelectionnee == taille;
    String titre, description;

    switch (taille) {
      case TailleElevage.petite:
        titre = 'Petit élevage';
        description = 'Moins de 50 lapins';
        break;
      case TailleElevage.moyenne:
        titre = 'Élevage moyen';
        description = '50 à 200 lapins';
        break;
      case TailleElevage.grande:
        titre = 'Grand élevage';
        description = '200 à 1000 lapins';
        break;
      case TailleElevage.treGrande:
        titre = 'Très grand élevage';
        description = 'Plus de 1000 lapins';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tailleElevageSelectionnee = taille;
          });
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
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              const SizedBox(width: 12),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidentialiteNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aucune adresse précise n\'est demandée. Ces informations restent sur votre appareil.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.blue.shade700),
            ),
          ),
        ],
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

    logger.info('Sauvegarde des informations ferme');

    // Récupérer le type d'élevage depuis la ferme existante
    final farm = provider.farm;
    if (farm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: Type d\'élevage manquant'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Sauvegarder les informations de la ferme
    final success = await provider.saveFarmInfo(
      nom: _nomController.text.trim().isEmpty
          ? null
          : _nomController.text.trim(),
      region: _regionController.text.trim().isEmpty
          ? null
          : _regionController.text.trim(),
      pays: _paysController.text.trim().isEmpty
          ? null
          : _paysController.text.trim(),
      typeElevage: farm.typeElevage, // Garder le type existant
      tailleElevage: _tailleElevageSelectionnee,
    );

    if (success) {
      await provider.nextStep();
      if (context.mounted) {
        Navigator.pushNamed(context, '/onboarding/profil-utilisateur');
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
