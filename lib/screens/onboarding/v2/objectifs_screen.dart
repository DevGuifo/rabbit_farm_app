import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/objectif_elevage.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../widgets/onboarding/onboarding_scaffold.dart';
import '../../../widgets/onboarding/selectable_card.dart';
import '../../../widgets/onboarding/onboarding_button.dart';
import '../../../theme/app_theme.dart';
import '../../../core/utils/logger.dart';

/// Écran 3 : Mes objectifs (Onboarding V2)
class ObjectifsScreen extends StatefulWidget {
  const ObjectifsScreen({super.key});

  @override
  State<ObjectifsScreen> createState() => _ObjectifsScreenState();
}

class _ObjectifsScreenState extends State<ObjectifsScreen> {
  final Set<ObjectifElevage> _selectedObjectifs = {};
  final int maxSelection = 2;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: '🎯 Quel est votre objectif principal ?',
      subtitle: 'Choisissez 1 ou 2 priorités',
      currentStep: 2,
      totalSteps: 6,
      onBack: () => Navigator.pop(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Grille d'objectifs
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: ObjectifElevage.values.map((objectif) {
                final isSelected = _selectedObjectifs.contains(objectif);
                final canSelect = _selectedObjectifs.length < maxSelection || isSelected;
                
                return SelectableCard(
                  title: objectif.label,
                  subtitle: objectif.description,
                  emoji: objectif.icon,
                  isSelected: isSelected,
                  onTap: () {
                    if (canSelect) {
                      setState(() {
                        if (isSelected) {
                          _selectedObjectifs.remove(objectif);
                        } else {
                          _selectedObjectifs.add(objectif);
                        }
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
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
                    'Nous afficherons les KPIs adaptés à vos priorités',
                    style: TextStyle(
                      color: AppTheme.info,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Bouton suivant
          Consumer<OnboardingProvider>(
            builder: (context, provider, _) {
              return OnboardingButton(
                text: 'Suivant',
                onPressed: _selectedObjectifs.isNotEmpty ? _handleNext : null,
                isLoading: provider.isLoading,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext() async {
    if (_selectedObjectifs.isEmpty) return;

    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final success = await provider.saveObjectifs(_selectedObjectifs.toList());

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/onboarding/preferences');
    } else if (mounted) {
      logger.error('Échec de la sauvegarde des objectifs');
    }
  }
}
