import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/logger.dart';
import '../../theme/app_theme.dart';

/// Écran principal de l'onboarding qui aiguille vers la bonne étape
class OnboardingMainScreen extends StatefulWidget {
  const OnboardingMainScreen({super.key});

  @override
  State<OnboardingMainScreen> createState() => _OnboardingMainScreenState();
}

class _OnboardingMainScreenState extends State<OnboardingMainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerStatutOnboarding();
    });
  }

  Future<void> _chargerStatutOnboarding() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final onboardingProvider = Provider.of<OnboardingProvider>(
      context,
      listen: false,
    );

    final userId = authProvider.currentUserId;
    if (userId == null) {
      logger.error('Pas d\'utilisateur connecté pour l\'onboarding');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    await onboardingProvider.loadOnboardingStatus(userId);

    // Navigation vers l'étape appropriée
    _navigateToCurrentStep();
  }

  void _navigateToCurrentStep() {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);

    if (provider.isOnboardingCompleted) {
      // Onboarding déjà terminé, rediriger vers l'app
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    // Rediriger vers l'onboarding V2
    Navigator.pushReplacementNamed(context, '/onboarding/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Consumer<OnboardingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Chargement...',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        _chargerStatutOnboarding();
                      },
                      child: Text(AppLocalizations.of(context).actionReessayer),
                    ),
                  ],
                ),
              ),
            );
          }

          // Si on arrive ici, c'est que le chargement est terminé
          // et _navigateToCurrentStep() va être appelé
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
