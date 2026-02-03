import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Bouton principal pour la navigation dans l'onboarding
class OnboardingButton extends StatelessWidget {
  /// Texte du bouton
  final String text;
  
  /// Callback lors du clic (null = bouton désactivé)
  final VoidCallback? onPressed;
  
  /// Afficher un indicateur de chargement
  final bool isLoading;
  
  /// Utiliser le style secondaire (outline)
  final bool isSecondary;

  const OnboardingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSecondary) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primary,
          side: BorderSide(color: AppTheme.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildContent(),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textOnPrimary,
        disabledBackgroundColor: AppTheme.borderLight,
        disabledForegroundColor: AppTheme.textTertiary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: onPressed != null ? 2 : 0,
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textOnPrimary),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward, size: 18),
      ],
    );
  }
}

/// Bouton "Passer" pour les écrans optionnels
class OnboardingSkipButton extends StatelessWidget {
  /// Callback lors du clic
  final VoidCallback? onPressed;
  
  /// Texte personnalisé (défaut: "Passer")
  final String? text;

  const OnboardingSkipButton({
    super.key,
    this.onPressed,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextButton(
      onPressed: onPressed ?? () {
        // Par défaut, naviguer vers l'écran suivant
        Navigator.of(context).maybePop();
      },
      style: TextButton.styleFrom(
        foregroundColor: isDark ? AppTheme.neutral400 : AppTheme.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        text ?? 'Passer',
        style: const TextStyle(
          fontSize: 14,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

/// Indicateur de conseil/astuce
class OnboardingTip extends StatelessWidget {
  /// Texte du conseil
  final String text;
  
  /// Icône personnalisée
  final IconData? icon;
  
  /// Couleur de fond personnalisée
  final Color? backgroundColor;
  
  /// Couleur du texte et de l'icône
  final Color? foregroundColor;

  const OnboardingTip({
    super.key,
    required this.text,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? (isDark ? AppTheme.info900.withValues(alpha: 0.3) : AppTheme.infoLight);
    final fgColor = foregroundColor ?? (isDark ? AppTheme.info300 : AppTheme.info);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.lightbulb_outline,
            color: fgColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: fgColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
