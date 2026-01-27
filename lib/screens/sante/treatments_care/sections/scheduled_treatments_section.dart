import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/lapin.dart';
import '../../../../models/soin.dart';
import '../../../../models/enums/sexe.dart';
import '../../../../models/enums/type_soin.dart';
import '../../../../providers/sante_provider.dart';
import '../../../../providers/lapin_provider.dart';
import '../../../../theme/app_theme.dart';
import '../widgets/history_item_card.dart';
import '../../fiche_sante_screen.dart';

/// Section Scheduled Treatments - Affiche tous les soins avec date de rappel
class ScheduledTreatmentsSection extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;
  final bool isDark;
  final Color surfaceColor;
  final Color primaryColor;
  final Color textPrimary;
  final Color textSecondary;

  const ScheduledTreatmentsSection({
    super.key,
    required this.searchQuery,
    required this.selectedFilter,
    required this.isDark,
    required this.surfaceColor,
    required this.primaryColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Traitements planifiés',
            style: AppTheme.titleMedium.copyWith(color: textPrimary),
          ),
        ),
        const SizedBox(height: 16),
        Consumer2<SanteProvider, LapinProvider>(
          builder: (context, santeProvider, lapinProvider, _) {
            final soins = santeProvider.soins;
            final lapins = lapinProvider.lapins;

            // All treatments with reminder date
            var scheduledSoins =
                soins.where((s) => s.dateRappel != null).toList()
                  ..sort((a, b) => a.dateRappel!.compareTo(b.dateRappel!));

            // Apply search filter
            scheduledSoins = _applySearchFilter(scheduledSoins, lapins);

            // Apply type filter
            scheduledSoins = _applyTypeFilter(scheduledSoins);

            if (scheduledSoins.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'Aucun traitement planifié',
                    style: TextStyle(color: textSecondary),
                  ),
                ),
              );
            }

            return Column(
              children: scheduledSoins.map((soin) {
                final lapin = _getLapin(lapins, soin.lapinId);
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 12,
                  ),
                  child: HistoryItemCard(
                    lapin: lapin,
                    soin: soin,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FicheSanteScreen(lapin: lapin),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  List<Soin> _applySearchFilter(List<Soin> soins, List<Lapin> lapins) {
    if (searchQuery.isEmpty) return soins;

    final searchLower = searchQuery.toLowerCase();
    return soins.where((soin) {
      final lapin = _getLapin(lapins, soin.lapinId);
      return lapin.nom.toLowerCase().contains(searchLower) ||
          (lapin.numeroIdentification?.toLowerCase().contains(searchLower) ??
              false) ||
          soin.description.toLowerCase().contains(searchLower) ||
          soin.type.label.toLowerCase().contains(searchLower);
    }).toList();
  }

  List<Soin> _applyTypeFilter(List<Soin> soins) {
    if (selectedFilter == 'all') return soins;

    return soins.where((s) {
      if (selectedFilter == 'treatments') {
        return s.type == TypeSoin.traitement;
      } else if (selectedFilter == 'care') {
        return s.type == TypeSoin.vermifuge || s.type == TypeSoin.autre;
      } else if (selectedFilter == 'vaccines') {
        return s.type == TypeSoin.vaccination;
      }
      return true;
    }).toList();
  }

  Lapin _getLapin(List<Lapin> lapins, int? lapinId) {
    return lapins.firstWhere(
      (l) => l.id == lapinId,
      orElse: () => Lapin(
        nom: 'Unknown',
        numeroIdentification: 'N/A',
        dateNaissance: DateTime.now(),
        sexe: Sexe.male,
        race: 'N/A',
      ),
    );
  }
}
