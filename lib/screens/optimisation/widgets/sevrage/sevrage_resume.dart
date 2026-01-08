import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_theme.dart';

class SevrageResume extends StatelessWidget {
  final int totalPetits;
  final int nbMales;
  final int nbFemelles;
  final int nbCagesUtilisees;
  final double? poidsMoyen;
  final bool tousCagesSelectionnees;

  const SevrageResume({
    super.key,
    required this.totalPetits,
    required this.nbMales,
    required this.nbFemelles,
    required this.nbCagesUtilisees,
    required this.poidsMoyen,
    required this.tousCagesSelectionnees,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tousCagesSelectionnees
            ? AppTheme.surfaceDarkGreen
            : AppTheme.surfaceDarkBrown,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tousCagesSelectionnees ? AppTheme.success : AppTheme.warning,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                tousCagesSelectionnees ? Icons.check_circle : Icons.warning,
                color: tousCagesSelectionnees
                    ? AppTheme.success
                    : AppTheme.warning,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.sevrageResumeLabel,
                style: const TextStyle(
                  color: AppTheme.textOnPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResumeItem(l10n.sevrageLapreauxASevrer, '$totalPetits'),
          _buildResumeItem(l10n.sevrageMaleLabel, '$nbMales'),
          _buildResumeItem(l10n.sevrageFemaleLabel, '$nbFemelles'),
          _buildResumeItem(l10n.sevrageCagesUtilisees, '$nbCagesUtilisees'),
          if (poidsMoyen != null)
            _buildResumeItem(
              l10n.sevragePoidsMoyen,
              '${poidsMoyen!.toStringAsFixed(0)} g',
            ),
          const SizedBox(height: 12),
          if (!tousCagesSelectionnees)
            Row(
              children: [
                const Icon(Icons.info, color: AppTheme.warning, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.sevrageSelectionnerCage,
                    style: const TextStyle(
                      color: AppTheme.warning,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildResumeItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textOnPrimary70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textOnPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
