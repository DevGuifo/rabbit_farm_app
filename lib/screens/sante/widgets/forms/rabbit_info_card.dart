import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../models/lapin.dart';
import '../../../../theme/app_theme.dart';

/// Widget d'information du lapin sélectionné
///
/// Usage:
/// ```dart
/// RabbitInfoCard(lapin: selectedRabbit)
/// ```
class RabbitInfoCard extends StatelessWidget {
  final Lapin lapin;

  const RabbitInfoCard({super.key, required this.lapin});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.primaryNeonGreen;
    final surfaceColor = isDark ? AppTheme.backgroundDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.cardLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? AppTheme.success100
        : AppTheme.textSecondary;

    return Container(
      padding: AppTheme.paddingAllMedium,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppTheme.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor, width: 2.5),
            ),
            child: ClipOval(
              child:
                  lapin.photoPath != null && File(lapin.photoPath!).existsSync()
                  ? Image.file(File(lapin.photoPath!), fit: BoxFit.cover)
                  : Icon(Icons.pets, size: 32, color: textSecondary),
            ),
          ),
          AppTheme.horizontalSpace16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    borderRadius: AppTheme.borderRadiusSmall,
                  ),
                  child: Text(
                    'SELECTED RABBIT',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                AppTheme.verticalSpace8,
                Text(
                  lapin.nom,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                AppTheme.verticalSpace4,
                Text(
                  'ID: ${lapin.numeroIdentification}',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
