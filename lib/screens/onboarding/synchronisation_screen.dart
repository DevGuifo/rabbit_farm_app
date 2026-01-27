import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/logger.dart';
import '../../utils/onboarding_navigation_helper.dart';
import '../../theme/app_theme.dart';

/// Écran 5 : Synchronisation et transparence
class OnboardingSynchronisationScreen extends StatefulWidget {
  const OnboardingSynchronisationScreen({super.key});

  @override
  State<OnboardingSynchronisationScreen> createState() =>
      _OnboardingSynchronisationScreenState();
}

class _OnboardingSynchronisationScreenState
    extends State<OnboardingSynchronisationScreen> {
  bool _synchronisationAutorisee = true; // Activée par défaut

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
                      'Synchronisation et transparence',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Sous-titre
                    Text(
                      'Votre transparence nous aide à améliorer l\'application pour tous.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Explication principale
                    _buildExplicationCard(),
                    const SizedBox(height: 24),

                    // Options de synchronisation
                    _buildSynchronisationOption(),
                    const SizedBox(height: 24),

                    // Que synchronisons-nous
                    _buildQueSynchronisonNous(),
                    const SizedBox(height: 24),

                    // Ce qui n'est jamais synchronisé
                    _buildCeQuiNestJamaisSynchronise(),
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
                  'Synchronisation',
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

  Widget _buildExplicationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.sync, size: 48, color: Colors.blue.shade700),
          const SizedBox(height: 16),
          Text(
            'Certaines données anonymes sont synchronisées pour améliorer l\'application.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSynchronisationOption() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_sync, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Text(
                'Votre choix',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Switch de synchronisation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _synchronisationAutorisee
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _synchronisationAutorisee
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Autoriser la synchronisation des données anonymes',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _synchronisationAutorisee
                              ? Theme.of(context).primaryColor
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _synchronisationAutorisee
                            ? 'Activée - Merci de nous aider !'
                            : 'Désactivée - Votre choix est respecté',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _synchronisationAutorisee,
                  onChanged: (value) {
                    setState(() {
                      _synchronisationAutorisee = value;
                    });
                    logger.info(
                      'Synchronisation ${value ? 'activée' : 'désactivée'}',
                    );
                  },
                  activeThumbColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueSynchronisonNous() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.upload_outlined, color: Colors.green.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ce qui est synchronisé (anonyme)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Liste des données synchronisées
          _buildListeItem(
            Icons.analytics,
            'Statistiques d\'élevage (nombres, moyennes)',
            'Pour améliorer les calculs et recommandations',
          ),
          _buildListeItem(
            Icons.trending_up,
            'Performances générales',
            'Pour optimiser les fonctionnalités',
          ),
          _buildListeItem(
            Icons.bug_report,
            'Erreurs techniques (logs)',
            'Pour corriger les bugs rapidement',
          ),
        ],
      ),
    );
  }

  Widget _buildCeQuiNestJamaisSynchronise() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ce qui N\'EST JAMAIS synchronisé',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Liste des données JAMAIS synchronisées
          _buildListeItem(
            Icons.person,
            'Informations personnelles',
            'Nom, adresse, coordonnées',
            couleur: Colors.red.shade700,
          ),
          _buildListeItem(
            Icons.pets,
            'Noms de vos lapins',
            'Identités individuelles',
            couleur: Colors.red.shade700,
          ),
          _buildListeItem(
            Icons.photo,
            'Photos et images',
            'Aucune image n\'est envoyée',
            couleur: Colors.red.shade700,
          ),
          _buildListeItem(
            Icons.location_off,
            'Localisation précise',
            'Adresses ou coordonnées GPS',
            couleur: Colors.red.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildListeItem(
    IconData icone,
    String titre,
    String description, {
    Color? couleur,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: couleur ?? const Color(0xFF5A6C7D)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: couleur ?? const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: couleur?.withValues(alpha: 0.8) ?? const Color(0xFF5A6C7D),
                  ),
                ),
              ],
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

            // Bouton Terminer
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: !provider.isLoading
                    ? () => _handleTerminer(context)
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
                        'Terminer',
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

  void _handleTerminer(BuildContext context) async {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);

    logger.info('Finalisation de l\'onboarding');

    // Sauvegarder les préférences de synchronisation
    await provider.updateSyncPreferences(_synchronisationAutorisee);

    // Terminer l'onboarding et naviguer
    if (!context.mounted) return;
    await OnboardingNavigationHelper.completeOnboardingAndNavigate(context);
  }
}
