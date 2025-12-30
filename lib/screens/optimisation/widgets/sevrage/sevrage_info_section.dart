import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import '../../../../models/portee.dart';
import '../../../../models/lapin.dart';

class SevrageInfoSection extends StatelessWidget {
  final Portee portee;
  final Lapin mere;

  const SevrageInfoSection({
    super.key,
    required this.portee,
    required this.mere,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations de la portée',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.pets,
                  'Mère',
                  mere.nom,
                  Colors.pink,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.baby_changing_station,
                  'Nés',
                  '${portee.nombreNes}',
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.check_circle,
                  'Vivants',
                  '${portee.nombreVivants}',
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.show_chart,
                  'Survie',
                  '${portee.tauxSurvie.toStringAsFixed(0)}%',
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
