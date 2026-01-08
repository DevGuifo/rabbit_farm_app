import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

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
              foregroundColor: AppTheme.authContent, // primary-content
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
                  l10n.welcomeGetStarted,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.authContent,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: AppTheme.authContent,
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
                TextSpan(text: l10n.welcomeAlreadyAccount),
                WidgetSpan(
                  child: Text(
                    l10n.welcomeLogIn,
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
