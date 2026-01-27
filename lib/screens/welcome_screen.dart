import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'auth/auth_screen.dart';
import '../utils/onboarding_navigation_helper.dart';
import 'welcome/widgets/welcome_brand_header.dart';
import 'welcome/widgets/welcome_hero_section.dart';
import 'welcome/widgets/welcome_content.dart';
import 'welcome/widgets/welcome_pagination_dots.dart';
import 'welcome/widgets/welcome_action_buttons.dart';

/// Écran de bienvenue (Welcome/Onboarding)
/// Affiche le design Stitch avec logo, image hero, titre, description et boutons d'action
/// Gère la navigation basée sur le statut d'onboarding après "Get Started" ou "Log in"
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  /// Constante pour la clé SharedPreferences
  static const String _hasSeenWelcomeKey = 'has_seen_welcome';

  /// Vérifie si l'utilisateur a déjà vu l'écran de bienvenue
  static Future<bool> hasSeenWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenWelcomeKey) ?? false;
  }

  /// Marque l'écran de bienvenue comme vu
  static Future<void> markWelcomeAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenWelcomeKey, true);
  }

  /// Réinitialise l'état (utile pour les tests)
  static Future<void> resetWelcomeState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasSeenWelcomeKey);
  }

  void _handleGetStarted(BuildContext context) async {
    // Marquer comme vu
    await markWelcomeAsSeen();

    // Naviguer basé sur le statut d'onboarding
    if (!context.mounted) return;
    OnboardingNavigationHelper.navigateBasedOnOnboardingStatus(context);
  }

  void _handleLogIn(BuildContext context) async {
    // Marquer comme vu (même si l'utilisateur clique sur "Log in")
    await markWelcomeAsSeen();

    // Naviguer vers AuthScreen en mode Sign In
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthScreen(initialIsSignUp: false),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Espace pour la status bar iOS
                      const SizedBox(height: 12),

                      // Section Hero (centrée verticalement)
                      // Laisser le contenu prendre l'espace naturel, le scroll gérera le reste
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo / Brand Header
                          const WelcomeBrandHeader(),
                          const SizedBox(height: 32),

                          // Hero Image Section
                          const WelcomeHeroSection(),
                          const SizedBox(height: 32),

                          // Content (Titre + Description)
                          const WelcomeContent(),
                          const SizedBox(height: 24),

                          // Pagination Dots
                          const WelcomePaginationDots(),
                        ],
                      ),

                      // Action Buttons (en bas)
                      Padding(
                        padding: const EdgeInsets.only(top: 32, bottom: 8),
                        child: WelcomeActionButtons(
                          onGetStarted: () => _handleGetStarted(context),
                          onLogIn: () => _handleLogIn(context),
                        ),
                      ),

                      // Espace pour l'indicateur home iOS
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
