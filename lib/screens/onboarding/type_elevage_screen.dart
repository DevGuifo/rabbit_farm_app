import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/onboarding_provider.dart';
import '../../models/farm.dart';
import '../../utils/logger.dart';
import '../../theme/app_theme.dart';

/// Écran 2 : Sélection du type d'élevage
class OnboardingTypeElevageScreen extends StatefulWidget {
  const OnboardingTypeElevageScreen({super.key});

  @override
  State<OnboardingTypeElevageScreen> createState() =>
      _OnboardingTypeElevageScreenState();
}

class _OnboardingTypeElevageScreenState
    extends State<OnboardingTypeElevageScreen> {
  TypeElevage? _typeElevageSelectionne;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      'Quel type d\'élevage décrit le mieux votre situation ?',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Sous-titre
                    Text(
                      'Cette information nous aide à adapter l\'expérience à vos besoins.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Options
                    Expanded(
                      child: ListView(
                        children: [
                          _buildTypeElevageCard(
                            TypeElevage.familial,
                            'Élevage familial',
                            'Pour la consommation familiale ou comme hobby',
                            Icons.home,
                            Colors.blue.shade100,
                            Colors.blue.shade700,
                          ),
                          const SizedBox(height: 16),
                          _buildTypeElevageCard(
                            TypeElevage.semiProfessionnel,
                            'Élevage semi-professionnel',
                            'Quelques ventes locales ou marchés',
                            Icons.store,
                            Colors.orange.shade100,
                            Colors.orange.shade700,
                          ),
                          const SizedBox(height: 16),
                          _buildTypeElevageCard(
                            TypeElevage.professionnel,
                            'Élevage professionnel',
                            'Activité commerciale principale',
                            Icons.business,
                            Colors.green.shade100,
                            Colors.green.shade700,
                          ),
                        ],
                      ),
                    ),
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
                  'Type d\'élevage',
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

  Widget _buildTypeElevageCard(
    TypeElevage type,
    String titre,
    String description,
    IconData icone,
    Color backgroundIcone,
    Color couleurIcone,
  ) {
    final isSelected = _typeElevageSelectionne == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _typeElevageSelectionne = type;
        });
        logger.info('Type d\'élevage sélectionné: ${type.name}');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
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
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: backgroundIcone,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(icone, size: 32, color: couleurIcone),
            ),
            const SizedBox(width: 16),

            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
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
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 24,
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
                onPressed:
                    (_typeElevageSelectionne != null && !provider.isLoading)
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
    if (_typeElevageSelectionne == null) return;

    final provider = Provider.of<OnboardingProvider>(context, listen: false);

    logger.info(
      'Sauvegarde du type d\'élevage: ${_typeElevageSelectionne!.name}',
    );

    // Sauvegarder temporairement le type d'élevage
    final success = await provider.saveFarmInfo(
      typeElevage: _typeElevageSelectionne!,
    );

    if (success) {
      await provider.nextStep();
      if (context.mounted) {
        Navigator.pushNamed(context, '/onboarding/informations-ferme');
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
