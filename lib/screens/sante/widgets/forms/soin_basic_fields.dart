import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Widget de sélection de date
class DateFieldWidget extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const DateFieldWidget({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.primaryNeonGreen;
    final surfaceColor = isDark ? AppTheme.backgroundDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.cardLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? AppTheme.stitchGreenLight
        : AppTheme.textSecondary;
    final borderColor = isDark
        ? AppTheme.stitchSurfaceDarkCard
        : AppTheme.stitchSurfaceLightAlt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        AppTheme.verticalSpace8,
        InkWell(
          onTap: onTap,
          borderRadius: AppTheme.borderRadiusMedium,
          child: Container(
            padding: AppTheme.paddingHorizontal.add(
              const EdgeInsets.symmetric(vertical: 14),
            ),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: AppTheme.borderRadiusMedium,
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: primaryColor,
                ),
                AppTheme.horizontalSpace12,
                Text(
                  DateFormat('MMMM dd, yyyy', 'fr_FR').format(date),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget de sélection du type d'événement
class EventTypeSelector extends StatelessWidget {
  final String typeSoin;
  final ValueChanged<String> onChanged;

  const EventTypeSelector({
    super.key,
    required this.typeSoin,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.primaryNeonGreen;
    final surfaceColor = isDark ? AppTheme.backgroundDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.cardLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? AppTheme.stitchGreenLight
        : AppTheme.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Type',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        AppTheme.verticalSpace8,
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.santeSurfaceDark
                : AppTheme.santeSurfaceLight,
            borderRadius: AppTheme.borderRadiusMedium,
          ),
          child: Row(
            children: [
              _SegmentedOption(
                value: 'vaccination',
                label: AppLocalizations.of(context).labelVaccination,
                isSelected: typeSoin == 'vaccination',
                onTap: onChanged,
                primaryColor: primaryColor,
                surfaceColor: surfaceColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                isDark: isDark,
              ),
              AppTheme.horizontalSpace4,
              _SegmentedOption(
                value: 'traitement',
                label: AppLocalizations.of(context).labelTreatment,
                isSelected: typeSoin == 'traitement',
                onTap: onChanged,
                primaryColor: primaryColor,
                surfaceColor: surfaceColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                isDark: isDark,
              ),
              AppTheme.horizontalSpace4,
              _SegmentedOption(
                value: 'observation',
                label: AppLocalizations.of(context).labelObs,
                isSelected: typeSoin == 'observation',
                onTap: onChanged,
                primaryColor: primaryColor,
                surfaceColor: surfaceColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SegmentedOption extends StatelessWidget {
  final String value;
  final String label;
  final bool isSelected;
  final ValueChanged<String> onTap;
  final Color primaryColor;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  const _SegmentedOption({
    required this.value,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? surfaceColor : Colors.transparent,
            borderRadius: AppTheme.borderRadiusMedium,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.textPrimary.withValues(
                        alpha: isDark ? 0.3 : 0.08,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? textPrimary : textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget de champ de description
class DescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const DescriptionField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.backgroundDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.cardLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? AppTheme.stitchGreenLight
        : AppTheme.textSecondary;
    final borderColor = isDark
        ? AppTheme.stitchSurfaceDarkCard
        : AppTheme.stitchSurfaceLightAlt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
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
            maxLines: 5,
            minLines: 5,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              color: textPrimary,
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).hintDescribeHealthEvent,
              hintStyle: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                color: textSecondary.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer une description';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

/// Widget de champ dropdown pour le type de soin
class TypeSoinDropdown extends StatelessWidget {
  final String typeSoin;
  final ValueChanged<String> onChanged;
  final List<String> typesSoins;

  const TypeSoinDropdown({
    super.key,
    required this.typeSoin,
    required this.onChanged,
    required this.typesSoins,
  });

  String _getTypeLabel(String type) {
    switch (type) {
      case 'vaccination':
        return 'Vaccination';
      case 'traitement':
        return 'Traitement';
      case 'vermifuge':
        return 'Vermifuge';
      case 'autre':
        return 'Autre';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.primaryNeonGreen;
    final surfaceColor = isDark ? AppTheme.backgroundDark : AppTheme.cardLight;
    final textPrimary = isDark ? AppTheme.cardLight : AppTheme.textPrimary;
    final textSecondary = isDark
        ? AppTheme.stitchGreenLight
        : AppTheme.textSecondary;
    final borderColor = isDark
        ? AppTheme.stitchSurfaceDarkCard
        : AppTheme.stitchSurfaceLightAlt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de soin (Dropdown)',
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
          child: DropdownButtonFormField<String>(
            initialValue: typeSoin,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: Icon(
                Icons.medical_services_outlined,
                size: 20,
                color: primaryColor,
              ),
            ),
            dropdownColor: surfaceColor,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              color: textPrimary,
            ),
            items: typesSoins.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getTypeLabel(type)),
              );
            }).toList(),
            onChanged: (value) => onChanged(value!),
          ),
        ),
      ],
    );
  }
}
