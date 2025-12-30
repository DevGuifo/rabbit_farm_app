import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Widget de champ de médicament
class MedicationField extends StatelessWidget {
  final TextEditingController controller;

  const MedicationField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.primaryNeonGreen;
    final surfaceColor = isDark ? AppTheme.backgroundDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.cardLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? const Color(0xFFB4C4B7)
        : AppTheme.textSecondary;
    final borderColor = isDark
        ? const Color(0xFF2A422E)
        : const Color(0xFFDBE6DC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medication Administered (Optional)',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: TextFormField(
            controller: controller,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              color: textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter medication name',
              hintStyle: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                color: textSecondary.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                Icons.medication_outlined,
                size: 20,
                color: primaryColor,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget de champ de dosage
class DosageField extends StatelessWidget {
  final TextEditingController controller;

  const DosageField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.primaryNeonGreen;
    final surfaceColor = isDark ? AppTheme.backgroundDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.cardLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? const Color(0xFFB4C4B7)
        : AppTheme.textSecondary;
    final borderColor = isDark
        ? const Color(0xFF2A422E)
        : const Color(0xFFDBE6DC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dosage',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: TextFormField(
            controller: controller,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              color: textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Ex: 2 ml, 1 comprimé...',
              hintStyle: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                color: textSecondary.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                Icons.local_hospital_outlined,
                size: 20,
                color: primaryColor,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

