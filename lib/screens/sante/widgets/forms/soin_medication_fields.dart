import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/medicament_selector.dart';
import '../../../../l10n/app_localizations.dart';

/// Widget de champ de médicament avec sélecteur FK
class MedicationField extends StatelessWidget {
  final int? medicamentIdInitial;
  final Function(int?, String?)
  onMedicamentChanged; // (medicamentId, medicamentNom)

  const MedicationField({
    super.key,
    this.medicamentIdInitial,
    required this.onMedicamentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark
        ? AppTheme.success100
        : AppTheme.textSecondary;

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
        AppTheme.verticalSpace8,
        MedicamentSelector(
          medicamentIdInitial: medicamentIdInitial,
          onMedicamentSelected: onMedicamentChanged,
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
        ? AppTheme.success100
        : AppTheme.textSecondary;
    final borderColor = isDark
        ? AppTheme.surfaceDarkElevated
        : AppTheme.surfaceLight;

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
        AppTheme.verticalSpace8,
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: AppTheme.borderRadiusMedium,
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
              hintText: AppLocalizations.of(context).hintExDosage,
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
