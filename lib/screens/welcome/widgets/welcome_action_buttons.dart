import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Widget pour les boutons d'action (Get Started + Log in)
/// Gère les callbacks pour la navigation
class WelcomeActionButtons extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onLogIn;

  const WelcomeActionButtons({
    super.key,
    required this.onGetStarted,
    required this.onLogIn,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Bouton "Get Started"
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onGetStarted,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNeonGreen,
              foregroundColor: const Color(0xFF0a2e12), // primary-content
              elevation: 0,
              shadowColor: AppTheme.primaryNeonGreen.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0a2e12),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: Color(0xFF0a2e12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Lien "Already have an account? Log in"
        TextButton(
          onPressed: onLogIn,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
            minimumSize: const Size(double.infinity, 40),
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.stitchTextSecDark
                    : AppTheme.stitchTextSecLight,
              ),
              children: [
                const TextSpan(text: 'Already have an account? '),
                WidgetSpan(
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.stitchTextMainDark
                          : AppTheme.stitchTextMainLight,
                      decoration: TextDecoration.underline,
                      decorationThickness: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

