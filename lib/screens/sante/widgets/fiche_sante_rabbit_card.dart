import 'package:flutter/material.dart';
import 'dart:io';
import '../../../models/lapin.dart';
import '../../../models/pesee.dart';
import 'package:rabbit_farm_app/theme/app_theme.dart';

class FicheSanteRabbitCard extends StatelessWidget {
  final Lapin lapin;
  final List<Pesee> pesees;
  final VoidCallback? onEdit;

  const FicheSanteRabbitCard({
    super.key,
    required this.lapin,
    required this.pesees,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final textMain = isDark ? AppTheme.textLight : AppTheme.backgroundDarkMode;
    final textSub = isDark ? AppTheme.border : AppTheme.textSecondary;

    final age = lapin.ageFormate;
    final poidKg = pesees.isNotEmpty
        ? pesees.last.poids.toStringAsFixed(1)
        : (lapin.poids?.toStringAsFixed(1) ?? '?');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: AppTheme.paddingAllMedium,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.backgroundDark.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: isDark
            ? Border.all(color: AppTheme.cardLight.withValues(alpha: 0.05))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.2),
              borderRadius: AppTheme.borderRadiusMedium,
            ),
            child: ClipRRect(
              borderRadius: AppTheme.borderRadiusMedium,
              child:
                  lapin.photoPath != null && File(lapin.photoPath!).existsSync()
                  ? Image.file(File(lapin.photoPath!), fit: BoxFit.cover)
                  : Icon(Icons.pets, size: 48, color: AppTheme.textSecondary),
            ),
          ),
          AppTheme.horizontalSpace16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${lapin.nom}',
                        style: TextStyle(
                          color: textMain,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (onEdit != null)
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 20,
                          color: isDark
                              ? AppTheme.primaryGreen.withValues(alpha: 0.8)
                              : AppTheme.primaryGreen,
                        ),
                        onPressed: onEdit,
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(32, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
                Text(
                  '${lapin.race} • ${lapin.sexe == 'Mâle' ? 'Mâle reproducteur' : 'Femelle reproductrice'}',
                  style: TextStyle(
                    color: textSub,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppTheme.verticalSpace4,
                Text(
                  'Age: $age • Cage ${lapin.localisation ?? 'N/A'}',
                  style: TextStyle(color: textSub, fontSize: 14),
                ),
                AppTheme.verticalSpace8,
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: lapin.statut == 'Malade'
                            ? AppTheme.error.withValues(alpha: 0.1)
                            : AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: AppTheme.borderRadiusLarge,
                        border: Border.all(
                          color: lapin.statut == 'Malade'
                              ? AppTheme.error.withValues(alpha: 0.3)
                              : AppTheme.primaryGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: lapin.statut == 'Malade'
                                  ? AppTheme.error
                                  : AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          AppTheme.horizontalSpace4,
                          Text(
                            lapin.statut == 'Malade' ? 'Malade' : 'Sain',
                            style: TextStyle(
                              color: lapin.statut == 'Malade'
                                  ? AppTheme.error
                                  : AppTheme.primaryGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppTheme.horizontalSpace8,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.santeCardDark
                            : AppTheme.santeCardLight,
                        borderRadius: AppTheme.borderRadiusLarge,
                      ),
                      child: Text(
                        '$poidKg kg',
                        style: TextStyle(
                          color: textSub,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
