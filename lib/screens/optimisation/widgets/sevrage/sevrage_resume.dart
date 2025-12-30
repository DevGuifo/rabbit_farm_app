import 'package:flutter/material.dart';
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tousCagesSelectionnees
            ? const Color(0xFF1E3A28)
            : const Color(0xFF3A2A1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tousCagesSelectionnees ? Colors.green : Colors.orange,
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
                color: tousCagesSelectionnees ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              const Text(
                'Résumé du sevrage',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResumeItem('Lapereaux à sevrer', '$totalPetits'),
          _buildResumeItem('Mâles', '$nbMales'),
          _buildResumeItem('Femelles', '$nbFemelles'),
          _buildResumeItem('Cages utilisées', '$nbCagesUtilisees'),
          if (poidsMoyen != null)
            _buildResumeItem(
              'Poids moyen',
              '${poidsMoyen!.toStringAsFixed(0)} g',
            ),
          const SizedBox(height: 12),
          if (!tousCagesSelectionnees)
            const Row(
              children: [
                Icon(Icons.info, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Veuillez sélectionner une cage pour chaque lapereau',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
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
            style: AppTheme.bodyMedium.copyWith(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
