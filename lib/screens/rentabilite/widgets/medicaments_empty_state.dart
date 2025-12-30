import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class MedicamentsEmptyState extends StatelessWidget {
  final String filtreType;

  const MedicamentsEmptyState({super.key, required this.filtreType});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: AppTheme.accentPink.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            filtreType == 'tous'
                ? 'Aucun médicament'
                : 'Aucun médicament de type $filtreType',
            style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'Appuyez sur + pour en ajouter',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
