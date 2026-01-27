import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/lapin.dart';
import '../../../../models/enums/sexe.dart';
import '../../../../providers/lapin_provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/parent_selector.dart';

/// Page 3 du formulaire d'ajout de lapin : Généalogie
class LapinFormPage3Genealogy extends StatelessWidget {
  final Lapin? pereSelectionne;
  final Function(Lapin?) onPereChanged;
  final Lapin? mereSelectionnee;
  final Function(Lapin?) onMereChanged;

  const LapinFormPage3Genealogy({
    super.key,
    required this.pereSelectionne,
    required this.onPereChanged,
    required this.mereSelectionnee,
    required this.onMereChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      children: [
        FadeInDown(
          child: Text(
            'Généalogie',
            style: AppTheme.headingLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeInDown(
          delay: const Duration(milliseconds: 100),
          child: Text(
            'Informations sur les parents (optionnel)',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(height: 32),

        // Illustration
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Icon(
                Icons.family_restroom,
                size: 64,
                color: AppTheme.accentPink,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Sélection du père
        FadeInUp(
          delay: const Duration(milliseconds: 300),
          child: Consumer<LapinProvider>(
            builder: (context, provider, child) {
              final males = provider.lapins
                  .where((l) => l.sexe == Sexe.male)
                  .toList();
              return ParentSelector(
                label: AppLocalizations.of(context).labelPere,
                icon: Icons.male,
                parentSelectionne: pereSelectionne,
                lapinsDisponibles: males,
                onChanged: onPereChanged,
              );
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // Sélection de la mère
        FadeInUp(
          delay: const Duration(milliseconds: 350),
          child: Consumer<LapinProvider>(
            builder: (context, provider, child) {
              final femelles = provider.lapins
                  .where((l) => l.sexe == Sexe.femelle)
                  .toList();
              return ParentSelector(
                label: AppLocalizations.of(context).labelMere,
                icon: Icons.female,
                parentSelectionne: mereSelectionnee,
                lapinsDisponibles: femelles,
                onChanged: onMereChanged,
              );
            },
          ),
        ),
        const SizedBox(height: 32),

        // Info message
        FadeInUp(
          delay: const Duration(milliseconds: 400),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: AppTheme.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'La généalogie vous permet de tracer l\'ascendance et d\'éviter les accouplements consanguins.',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.info),
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
