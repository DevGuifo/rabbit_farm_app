import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/onboarding/onboarding_main_screen.dart';
import '../screens/home_screen.dart';
import '../utils/logger.dart';

/// Utilitaire pour gérer la navigation selon l'état de l'onboarding
class OnboardingNavigationHelper {
  /// Vérifie l'état de l'onboarding et navigue vers l'écran approprié
  ///
  /// Cette méthode doit être appelée après qu'un utilisateur se connecte
  /// ou après que le PIN est configuré/validé
  static Future<void> navigateBasedOnOnboardingStatus(
    BuildContext context, {
    bool replaceCurrentRoute = true,
  }) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final onboardingProvider = Provider.of<OnboardingProvider>(
        context,
        listen: false,
      );

      // Vérifier qu'un utilisateur est connecté
      final userId = authProvider.currentUserId;
      if (userId == null) {
        logger.warning(
          'Aucun utilisateur connecté lors de la vérification onboarding',
        );
        return;
      }

      // Charger l'état de l'onboarding
      await onboardingProvider.loadOnboardingStatus(userId);

      if (!context.mounted) return;

      Widget destinationScreen;
      String routeName;

      if (onboardingProvider.isOnboardingCompleted) {
        // Onboarding terminé → Aller à l'écran principal
        destinationScreen = const HomeScreen();
        routeName = '/home';
        logger.info('Onboarding terminé, navigation vers HomeScreen');
      } else {
        // Onboarding non terminé → Aller à l'onboarding
        destinationScreen = const OnboardingMainScreen();
        routeName = '/onboarding';
        logger.info('Onboarding requis, navigation vers OnboardingMainScreen');
      }

      // Navigation
      if (replaceCurrentRoute) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                destinationScreen,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      } else {
        Navigator.pushNamed(context, routeName);
      }
    } catch (e) {
      logger.error('Erreur lors de la vérification de l\'onboarding: $e');

      if (context.mounted) {
        // En cas d'erreur, aller vers l'écran principal par défaut
        final destinationScreen = const HomeScreen();
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                destinationScreen,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    }
  }

  /// Vérifie si l'onboarding est nécessaire pour un utilisateur donné
  /// sans navigation. Utile pour la logique conditionnelle.
  static Future<bool> isOnboardingRequired(
    BuildContext context,
    String userId,
  ) async {
    try {
      final onboardingProvider = Provider.of<OnboardingProvider>(
        context,
        listen: false,
      );
      await onboardingProvider.loadOnboardingStatus(userId);
      return !onboardingProvider.isOnboardingCompleted;
    } catch (e) {
      logger.error('Erreur lors de la vérification de l\'état onboarding: $e');
      // En cas d'erreur, considérer que l'onboarding est nécessaire par sécurité
      return true;
    }
  }

  /// Marque l'onboarding comme terminé et navigue vers l'écran principal
  static Future<void> completeOnboardingAndNavigate(
    BuildContext context,
  ) async {
    try {
      final onboardingProvider = Provider.of<OnboardingProvider>(
        context,
        listen: false,
      );

      final success = await onboardingProvider.completeOnboarding();
      if (success && context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false, // Supprimer toute la pile de navigation
        );

        // Message de bienvenue
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Bienvenue dans BunnyManager !'),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      logger.error('Erreur lors de la finalisation de l\'onboarding: $e');
    }
  }
}
