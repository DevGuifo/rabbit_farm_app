import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Widget pour les boutons de connexion sociale (Google, Apple)
class AuthSocialButtons extends StatelessWidget {
  final bool isSignUp;
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;

  const AuthSocialButtons({
    super.key,
    this.isSignUp = true,
    this.onGooglePressed,
    this.onApplePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Séparateur "OR JOIN WITH"
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: isDark
                    ? AppTheme.stitchSurfaceDarkElevated
                    : AppTheme.stitchSurfaceLightCard,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                isSignUp ? 'OR JOIN WITH' : 'OR CONTINUE WITH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppTheme.neutral400,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: isDark
                    ? AppTheme.stitchSurfaceDarkElevated
                    : AppTheme.stitchSurfaceLightCard,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Boutons sociaux
        Row(
          children: [
            // Bouton Google
            Expanded(
              child: _buildSocialButton(
                label: 'Google',
                icon: _buildGoogleIcon(),
                isDark: isDark,
                onPressed: onGooglePressed,
              ),
            ),
            const SizedBox(width: 16),
            // Bouton Apple
            Expanded(
              child: _buildSocialButton(
                label: 'Apple',
                icon: Icon(
                  Icons.apple,
                  size: 20,
                  color: isDark ? AppTheme.textOnPrimary : AppTheme.textPrimary,
                ),
                isDark: isDark,
                onPressed: onApplePressed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Widget icon,
    required bool isDark,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDarkForest : AppTheme.textOnPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppTheme.stitchSurfaceDarkElevated : AppTheme.stitchSurfaceLightCard,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textOnPrimary
                    : AppTheme.stitchTextDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    // Logo Google simplifié (lettre G)
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: AppTheme.textOnPrimary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.neutral700,
          ),
        ),
      ),
    );
  }
}
