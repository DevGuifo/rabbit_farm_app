import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import '../../../models/accouplement.dart';
import '../../../models/lapin.dart';
import '../../../providers/lapin_provider.dart';
import 'reproduction_pairing_card.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

/// Liste des accouplements avec filtre optionnel
/// Widget modulaire pour composition dans orchestrateur
class ReproductionPairingsList extends StatelessWidget {
  final bool isDark;
  final List<Accouplement> accouplements;
  final bool showAll;
  final Function(Accouplement) onEditTap;
  final Function(int) onDeleteTap;

  const ReproductionPairingsList({
    super.key,
    required this.isDark,
    required this.accouplements,
    required this.showAll,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final lapinProvider = context.read<LapinProvider>();
    final displayedPairings = showAll
        ? accouplements
        : accouplements.take(3).toList();

    if (displayedPairings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.favorite_border,
                size: 64,
                color: (isDark ? AppTheme.textLight : AppTheme.textPrimary)
                    .withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).reproAucunAccouplement,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textLight : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).reproPlanifierPourCommencer,
                style: AppTheme.bodyMedium.copyWith(
                  color: isDark
                      ? AppTheme.textSecondary.withValues(alpha: 0.7)
                      : AppTheme.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: List.generate(displayedPairings.length, (index) {
        final pairing = displayedPairings[index];
        final femelle = lapinProvider.lapins.firstWhere(
          (l) => l.id == pairing.femelleId,
          orElse: () => Lapin(
            nom: 'Femelle introuvable',
            race: '',
            sexe: 'F',
            dateNaissance: DateTime.now(),
            id: -1,
          ),
        );
        final male = lapinProvider.lapins.firstWhere(
          (l) => l.id == pairing.maleId,
          orElse: () => Lapin(
            nom: 'Mâle introuvable',
            race: '',
            sexe: 'M',
            dateNaissance: DateTime.now(),
            id: -1,
          ),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ReproductionPairingCard(
            isDark: isDark,
            pairing: pairing,
            femelle: femelle,
            male: male,
            onEditTap: () => onEditTap(pairing),
            onDeleteTap: () => onDeleteTap(pairing.id!),
          ),
        );
      }),
    );
  }
}
