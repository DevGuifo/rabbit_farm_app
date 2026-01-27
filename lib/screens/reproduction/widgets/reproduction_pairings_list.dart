import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';
import '../../../models/accouplement.dart';
import '../../../models/lapin.dart';
import '../../../models/enums/sexe.dart';
import '../../../providers/lapin_provider.dart';
import 'reproduction_pairing_card.dart';
import 'package:rabbit_farm_app/widgets/common/common_widgets.dart';

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
        child: EmptyState(
          isDark: isDark,
          icon: Icons.favorite_border,
          title: AppLocalizations.of(context).reproAucunAccouplement,
          subtitle: AppLocalizations.of(context).reproPlanifierPourCommencer,
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
            sexe: Sexe.femelle,
            dateNaissance: DateTime.now(),
            id: -1,
          ),
        );
        final male = lapinProvider.lapins.firstWhere(
          (l) => l.id == pairing.maleId,
          orElse: () => Lapin(
            nom: 'Mâle introuvable',
            race: '',
            sexe: Sexe.male,
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
