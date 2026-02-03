import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../widgets/onboarding/onboarding_scaffold.dart';
import '../../../widgets/onboarding/onboarding_button.dart';
import '../../../constants/preferences_keys.dart';
import '../../../theme/app_theme.dart';
import '../../../core/utils/logger.dart';

/// Écran 4 : Préférences (Onboarding V2)
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  String _selectedCurrency = PreferencesDefaults.defaultCurrency;
  String _selectedWeightUnit = PreferencesDefaults.defaultWeightUnit;
  final Set<String> _selectedRaces = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return OnboardingScaffold(
      title: '⚙️ Vos préférences',
      currentStep: 3,
      totalSteps: 6,
      onBack: () => Navigator.pop(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Monnaie
          Text(
            'MONNAIE',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.neutral400 : AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          
          DropdownButtonFormField<String>(
            value: _selectedCurrency,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.euro),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
            ),
            dropdownColor: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
            items: SupportedCurrencies.all.map((currency) {
              return DropdownMenuItem(
                value: currency.code,
                child: Text('${currency.flag}  ${currency.name} (${currency.symbol})'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedCurrency = value!),
          ),
          
          const SizedBox(height: 24),
          
          // Unité de poids
          Text(
            'UNITÉ DE POIDS',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.neutral400 : AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'kg', label: Text('kg')),
              ButtonSegment(value: 'lb', label: Text('lb')),
            ],
            selected: {_selectedWeightUnit},
            onSelectionChanged: (Set<String> selection) {
              setState(() => _selectedWeightUnit = selection.first);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Races élevées
          Text(
            'RACES ÉLEVÉES (optionnel)',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.neutral400 : AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CommonRaces.all.map((race) {
                  final isSelected = _selectedRaces.contains(race);
                  return FilterChip(
                    label: Text(race),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedRaces.add(race);
                        } else {
                          _selectedRaces.remove(race);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Boutons navigation
          Row(
            children: [
              const OnboardingSkipButton(),
              const Spacer(),
              Consumer<OnboardingProvider>(
                builder: (context, provider, _) {
                  return OnboardingButton(
                    text: 'Suivant',
                    onPressed: _handleNext,
                    isLoading: provider.isLoading,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext() async {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    
    // Sauvegarder préférences régionales
    final regionalSuccess = await provider.saveRegionalPreferences(
      currency: _selectedCurrency,
      weightUnit: _selectedWeightUnit,
    );

    if (!regionalSuccess) {
      logger.warning('Échec sauvegarde préférences régionales, continue');
    }

    // Sauvegarder races si sélectionnées et farm existe
    if (_selectedRaces.isNotEmpty && provider.farm != null) {
      await provider.saveFarmInfoV2(
        typeElevage: provider.farm!.typeElevage,
        tailleElevage: provider.farm?.tailleElevage,
        races: _selectedRaces.toList(),
      );
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/onboarding/notifications');
    }
  }
}
