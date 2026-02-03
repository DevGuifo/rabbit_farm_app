import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Scaffold commun pour tous les écrans d'onboarding V2
/// 
/// Fournit une structure cohérente avec :
/// - En-tête avec titre et progression
/// - Zone de contenu scrollable
/// - Bouton retour optionnel
class OnboardingScaffold extends StatelessWidget {
  /// Titre principal de l'écran
  final String title;
  
  /// Sous-titre optionnel
  final String? subtitle;
  
  /// Étape actuelle (1-based)
  final int currentStep;
  
  /// Nombre total d'étapes
  final int totalSteps;
  
  /// Contenu de l'écran
  final Widget child;
  
  /// Callback pour le bouton retour (null = pas de bouton)
  final VoidCallback? onBack;

  const OnboardingScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.currentStep,
    required this.totalSteps,
    required this.child,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDarkMode : AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: onBack != null
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios, color: isDark ? AppTheme.textLight : AppTheme.textPrimary),
                onPressed: onBack,
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Indicateur de progression
              _buildProgressIndicator(isDark),
              
              const SizedBox(height: 24),
              
              // Titre
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                    ),
              ),
              
              // Sous-titre optionnel
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? AppTheme.neutral400 : AppTheme.textSecondary,
                      ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Contenu
              Expanded(child: child),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Column(
      children: [
        // Barre de progression
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: currentStep / totalSteps,
            backgroundColor: isDark ? AppTheme.neutral700 : AppTheme.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            minHeight: 6,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Texte de progression
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Étape $currentStep sur $totalSteps',
              style: TextStyle(
                color: isDark ? AppTheme.neutral400 : AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              '${((currentStep / totalSteps) * 100).round()}%',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
