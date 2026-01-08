import 'package:flutter/material.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';
import 'package:rabbit_farm_app/l10n/app_localizations.dart';

class SevrageExtraFields extends StatelessWidget {
  final TextEditingController observationsController;
  final TextEditingController alimentationController;

  const SevrageExtraFields({
    super.key,
    required this.observationsController,
    required this.alimentationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.textOnPrimary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: 0.04),
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
          TextFormField(
            controller: observationsController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(
                context,
              ).optimisationFormObservations,
              hintText: 'État de santé, comportement...',
              prefixIcon: Icon(Icons.notes, color: AppTheme.textSecondary),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: AppTheme.cardLight,
            ),
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: alimentationController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(
                context,
              ).optimisationFormAlimentationPost,
              hintText: 'Granulés, foin, légumes...',
              prefixIcon: Icon(Icons.restaurant, color: AppTheme.textSecondary),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: AppTheme.cardLight,
            ),
            style: TextStyle(color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
