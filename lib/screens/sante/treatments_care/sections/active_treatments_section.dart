import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/lapin.dart';
import '../../../../models/soin.dart';
import '../../../../providers/sante_provider.dart';
import '../../../../providers/lapin_provider.dart';
import '../../../../theme/app_theme.dart';
import '../widgets/treatment_card.dart';
import '../../fiche_sante_screen.dart';

/// Section Active Treatments - Affiche les traitements avec rappels futurs (< 30 jours)
class ActiveTreatmentsSection extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;
  final bool isDark;
  final Color surfaceColor;
  final Color primaryColor;
  final Color textPrimary;
  final Color textSecondary;

  const ActiveTreatmentsSection({
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
            'Active Treatments',
            style: AppTheme.titleMedium.copyWith(color: textPrimary),
          ),
        ),
        const SizedBox(height: 16),
        Consumer2<SanteProvider, LapinProvider>(
          builder: (context, santeProvider, lapinProvider, _) {
            final soins = santeProvider.soins;
            final lapins = lapinProvider.lapins;

            // Filter active treatments (with future reminder dates < 30 days)
            var activeSoins = soins
                .where(
                  (s) =>
                      s.dateRappel != null &&
                      s.dateRappel!.isAfter(DateTime.now()) &&
                      s.dateRappel!.isBefore(
                        DateTime.now().add(const Duration(days: 30)),
                      ),
                )
                .toList();

            // Apply search filter
            activeSoins = _applySearchFilter(activeSoins, lapins);

            // Apply type filter
            activeSoins = _applyTypeFilter(activeSoins);

            if (activeSoins.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No active treatments',
                    style: TextStyle(color: textSecondary),
                  ),
                ),
              );
            }

            return Column(
              children: activeSoins.take(3).map((soin) {
                final lapin = _getLapin(lapins, soin.lapinId);
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: TreatmentCard(
                    lapin: lapin,
                    soin: soin,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    primaryColor: primaryColor,
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
          soin.type.toLowerCase().contains(searchLower);
    }).toList();
  }

  List<Soin> _applyTypeFilter(List<Soin> soins) {
    if (selectedFilter == 'all') return soins;

    return soins.where((s) {
      final typeLower = s.type.toLowerCase();
      if (selectedFilter == 'treatments') {
        return typeLower == 'traitement';
      } else if (selectedFilter == 'care') {
        return typeLower == 'vermifuge' || typeLower == 'autre';
      } else if (selectedFilter == 'vaccines') {
        return typeLower == 'vaccination';
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
        sexe: 'Inconnu',
        race: 'N/A',
      ),
    );
  }
}
