import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/farm.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/onboarding/onboarding_scaffold.dart';
import '../../../widgets/onboarding/selectable_card.dart';
import '../../../widgets/onboarding/onboarding_button.dart';
import '../../../theme/app_theme.dart';
import '../../../core/utils/logger.dart';

/// Paliers de taille pour l'onboarding (plus granulaires que TailleElevage)
enum _TaillePalier { moins20, de20a50, de50a100, de100a300, plus300 }

extension _TaillePalierExt on _TaillePalier {
  String get label {
    switch (this) {
      case _TaillePalier.moins20:
        return 'Moins de 20';
      case _TaillePalier.de20a50:
        return '20 à 50';
      case _TaillePalier.de50a100:
        return '50 à 100';
      case _TaillePalier.de100a300:
        return '100 à 300';
      case _TaillePalier.plus300:
        return 'Plus de 300';
    }
  }

  /// Convertir vers TailleElevage pour stockage
  TailleElevage get toTailleElevage {
    switch (this) {
      case _TaillePalier.moins20:
      case _TaillePalier.de20a50:
        return TailleElevage.petite;
      case _TaillePalier.de50a100:
        return TailleElevage.moyenne;
      case _TaillePalier.de100a300:
        return TailleElevage.grande;
      case _TaillePalier.plus300:
        return TailleElevage.treGrande;
    }
  }
}

/// Écran 2 : Mon élevage (Onboarding V2)
class ElevageScreenV2 extends StatefulWidget {
  const ElevageScreenV2({super.key});

  @override
  State<ElevageScreenV2> createState() => _ElevageScreenV2State();
}

class _ElevageScreenV2State extends State<ElevageScreenV2> {
  TypeElevage? _selectedType;
  _TaillePalier? _selectedPalier;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return OnboardingScaffold(
      title: '🐰 Parlez-nous de votre élevage',
      currentStep: 1,
      totalSteps: 6,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type d'élevage
            Text(
              'TYPE D\'ÉLEVAGE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.neutral400 : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: SelectableCard(
                    title: 'Familial',
                    subtitle: '< 50 🐇',
                    emoji: '🏠',
                    isSelected: _selectedType == TypeElevage.familial,
                    onTap: () =>
                        setState(() => _selectedType = TypeElevage.familial),
                    minHeight: 90,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableCard(
                    title: 'Semi-pro',
                    subtitle: '50-200',
                    emoji: '🏪',
                    isSelected: _selectedType == TypeElevage.semiProfessionnel,
                    onTap: () => setState(
                      () => _selectedType = TypeElevage.semiProfessionnel,
                    ),
                    minHeight: 90,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableCard(
                    title: 'Pro',
                    subtitle: '> 200',
                    emoji: '🏭',
                    isSelected: _selectedType == TypeElevage.professionnel,
                    onTap: () => setState(
                      () => _selectedType = TypeElevage.professionnel,
                    ),
                    minHeight: 90,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Taille de l'élevage
            Text(
              'COMBIEN DE LAPINS ?',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.neutral400 : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            ...(_TaillePalier.values.map(
              (palier) => _buildTailleOption(palier, isDark),
            )),

            const SizedBox(height: 12),

            // Conseil
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.infoLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppTheme.info, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cela nous aide à adapter l\'interface à votre réalité',
                      style: TextStyle(color: AppTheme.info, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Boutons navigation
            Consumer<OnboardingProvider>(
              builder: (context, provider, _) {
                final canProceed =
                    _selectedType != null && _selectedPalier != null;

                return OnboardingButton(
                  text: 'Suivant',
                  onPressed: canProceed ? _handleNext : null,
                  isLoading: provider.isLoading,
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTailleOption(_TaillePalier palier, bool isDark) {
    return RadioListTile<_TaillePalier>(
      title: Text(
        palier.label,
        style: TextStyle(
          color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
        ),
      ),
      value: palier,
      groupValue: _selectedPalier,
      onChanged: (value) => setState(() => _selectedPalier = value),
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: AppTheme.primary,
    );
  }

  Future<void> _handleNext() async {
    if (_selectedType == null || _selectedPalier == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<OnboardingProvider>(context, listen: false);

    // Initialiser l'onboarding si nécessaire
    if (provider.status == null) {
      final userId = authProvider.currentUserId;
      if (userId != null) {
        await provider.loadOnboardingStatus(userId);
      }
    }

    // Sauvegarder les données
    final success = await provider.saveFarmInfoV2(
      typeElevage: _selectedType!,
      tailleElevage: _selectedPalier!.toTailleElevage,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/onboarding/objectifs');
    } else {
      logger.error('Échec de la sauvegarde des infos ferme');
    }
  }
}
