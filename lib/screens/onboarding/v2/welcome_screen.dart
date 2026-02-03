import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Écran 1 : Bienvenue (Onboarding V2)
/// 
/// Premier écran de l'onboarding V2, destiné à créer une connexion émotionnelle
/// et rassurer l'utilisateur sur la confidentialité des données.
class WelcomeScreenV2 extends StatelessWidget {
  const WelcomeScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDarkMode : AppTheme.backgroundLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.08),
              
                      // Animation / Icône lapin
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.pets,
                          size: 64,
                          color: AppTheme.primary,
                        ),
                      ),
              
                      const SizedBox(height: 24),
              
                      // Titre
                      Text(
                        'Bienvenue dans BunnyManager !',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                            ),
                        textAlign: TextAlign.center,
                      ),
              
                      const SizedBox(height: 12),
              
                      // Sous-titre
                      Text(
                        'Quelques questions pour personnaliser votre expérience',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppTheme.neutral400 : AppTheme.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
              
                      const SizedBox(height: 24),
              
                      // Badge sécurité
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.success900.withValues(alpha: 0.3) : AppTheme.success50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? AppTheme.success700 : AppTheme.success200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: isDark ? AppTheme.success400 : AppTheme.success700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Vos données restent sur votre appareil',
                                style: TextStyle(
                                  color: isDark ? AppTheme.success400 : AppTheme.success700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              
                      SizedBox(height: constraints.maxHeight * 0.1),
              
                      // Estimation du temps
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: isDark ? AppTheme.neutral500 : AppTheme.textTertiary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Environ 2 minutes',
                      style: TextStyle(
                        color: isDark ? AppTheme.neutral500 : AppTheme.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bouton principal
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/onboarding/elevage');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'C\'est parti !',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
