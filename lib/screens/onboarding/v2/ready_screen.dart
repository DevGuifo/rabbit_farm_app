import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../models/objectif_elevage.dart';
import '../../../theme/app_theme.dart';

/// Écran 6 : Prêt ! (Onboarding V2)
class ReadyScreen extends StatelessWidget {
  const ReadyScreen({super.key});

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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.05),

                      // Animation / Check
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.success900.withValues(alpha: 0.3) : AppTheme.success50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: 64,
                          color: isDark ? AppTheme.success400 : AppTheme.success600,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Titre
                      Text(
                        'Tout est prêt !',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Récapitulatif
                      Consumer<OnboardingProvider>(
                        builder: (context, provider, _) {
                          final farm = provider.farm;
                          final objectifs = provider.selectedObjectifs;
                          final currency = provider.selectedCurrency;

                          return Card(
                            elevation: 0,
                            color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: isDark ? AppTheme.neutral700 : AppTheme.borderLight),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: AppTheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Récapitulatif',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  if (farm != null) ...[
                                    _buildInfoRow(
                                      '• Élevage ${farm.typeDescription}',
                                      isDark,
                                    ),
                                    _buildInfoRow(
                                      '• ${farm.tailleDescription ?? "Taille non définie"}',
                                      isDark,
                                    ),
                                  ],

                                  if (objectifs != null && objectifs.isNotEmpty)
                                    _buildInfoRow(
                                      '• Focus: ${objectifs.map((o) => o.label).join(", ")}',
                                      isDark,
                                    ),

                                  if (currency != null)
                                    _buildInfoRow('• Monnaie: $currency', isDark),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Conseil de départ
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.info900.withValues(alpha: 0.3) : AppTheme.infoLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: isDark ? AppTheme.info300 : AppTheme.info,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Conseil de départ :',
                                    style: TextStyle(
                                      color: isDark ? AppTheme.info300 : AppTheme.info,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Commencez par ajouter vos reproducteurs actuels',
                                    style: TextStyle(
                                      color: isDark ? AppTheme.info300 : AppTheme.info,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: constraints.maxHeight * 0.05),

                      // Bouton principal
                      SizedBox(
                        width: double.infinity,
                        child: Consumer<OnboardingProvider>(
                          builder: (context, provider, _) {
                            return ElevatedButton(
                              onPressed: provider.isLoading
                                  ? null
                                  : () => _handleFinish(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: AppTheme.textOnPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: provider.isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppTheme.textOnPrimary,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Découvrir BunnyManager',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          },
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

  Widget _buildInfoRow(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: isDark ? AppTheme.textLight : AppTheme.textPrimary),
      ),
    );
  }

  Future<void> _handleFinish(BuildContext context) async {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);

    // Finaliser l'onboarding
    final success = await provider.finalizeOnboardingV2();

    if (success && context.mounted) {
      // Nettoyer les données temporaires
      provider.clearTemporaryData();

      // Rediriger vers le home
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
