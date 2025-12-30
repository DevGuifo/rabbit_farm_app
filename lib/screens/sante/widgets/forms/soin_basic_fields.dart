import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_theme.dart';

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
        ? const Color(0xFFB4C4B7)
        : AppTheme.textSecondary;
    final borderColor = isDark
        ? const Color(0xFF2A422E)
        : const Color(0xFFDBE6DC);

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
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: primaryColor,
                ),
                const SizedBox(width: 12),
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
        ? const Color(0xFFB4C4B7)
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
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1F13) : const Color(0xFFF0F4F1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _SegmentedOption(
                value: 'vaccination',
                label: 'Vaccination',
                isSelected: typeSoin == 'vaccination',
                onTap: onChanged,
                primaryColor: primaryColor,
                surfaceColor: surfaceColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                isDark: isDark,
              ),
              const SizedBox(width: 4),
              _SegmentedOption(
                value: 'traitement',
                label: 'Treatment',
                isSelected: typeSoin == 'traitement',
                onTap: onChanged,
                primaryColor: primaryColor,
                surfaceColor: surfaceColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                isDark: isDark,
              ),
              const SizedBox(width: 4),
              _SegmentedOption(
                value: 'observation',
                label: 'Obs.',
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
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
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
        ? const Color(0xFFB4C4B7)
        : AppTheme.textSecondary;
    final borderColor = isDark
        ? const Color(0xFF2A422E)
        : const Color(0xFFDBE6DC);

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
              hintText: 'Describe the health event...',
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
        ? const Color(0xFFB4C4B7)
        : AppTheme.textSecondary;
    final borderColor = isDark
        ? const Color(0xFF2A422E)
        : const Color(0xFFDBE6DC);

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

